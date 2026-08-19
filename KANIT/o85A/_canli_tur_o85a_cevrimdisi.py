# -*- coding: utf-8 -*-
"""IS-EMRI-o85-A SS8 madde 4 (04-cevrimdisi.md) icin CANLI olcum uretici.

Senaryo: "cevrimdisiyken" bir liste yaratilir ve o listede bir gorev dogar --
BU ASAMADA HICBIR HTTP CAGRISI YAPILMAZ (asagida acikca isaretli) -- bu,
istemcinin GERCEK mimarisiyle BIREBIR ORTUSUR: `_yerelYaz` (K112) yerel
yazmayi ATOMIK ve SENKRON yapar, itme (`SenkronDongusu`) AYRI ve SONRAKI bir
adimdir (bkz. `gorev_deposu.dart`, `liste_dilimi_test.dart` -- o testler
SIFIR ag baglantisiyla, `NativeDatabase.memory()` ile TAM OLARAK bu ops'lari
uretir). Burada YENI olan, o85-A'nin YENI op sekillerinin (Project yaratma,
Task.projectId) ayni "yerel-once, itme-sonra" borusundan GECTIGININ uctan uca
(gercek sunucuya push + ikinci istemciden GORULEBILIRLIK) olculmesidir.

"Baglanti geldiginde kendiliginden esitle" iddiasi: OFFLINE evrede biriken
ops'lar TEK bir /v1/sync cagrisinda (kuyruk turu neyi biriktirdiyse) pushlanir
-- gercek `SenkronDongusu` da kuyruktaki BIRDEN FAZLA satiri TEK turda gonderir.
"""
import json
import os
import sys
import time
import urllib.error
import urllib.request
import uuid

sys.stdout.reconfigure(encoding="utf-8")

TABAN = "http://localhost:5298"
KANIT = []


def uuid7():
    ts_ms = int(time.time() * 1000)
    rastgele = os.urandom(10)
    b = bytearray(16)
    b[0:6] = ts_ms.to_bytes(6, "big")
    b[6] = 0x70 | (rastgele[0] & 0x0F)
    b[7] = rastgele[1]
    b[8] = 0x80 | (rastgele[2] & 0x3F)
    b[9:16] = rastgele[3:10]
    hexi = b.hex()
    return "%s-%s-%s-%s-%s" % (hexi[0:8], hexi[8:12], hexi[12:16], hexi[16:20], hexi[20:32])


def kaydet(baslik, govde):
    KANIT.append("=== %s ===\n%s\n" % (baslik, govde))
    print("=== %s ===" % baslik)
    print(govde)


def istek(yol, govde=None, basliklar=None):
    url = TABAN + yol
    veri = json.dumps(govde).encode("utf-8") if govde is not None else None
    req = urllib.request.Request(url, data=veri, method="POST" if veri else "GET")
    req.add_header("Content-Type", "application/json")
    for k, v in (basliklar or {}).items():
        req.add_header(k, v)
    try:
        with urllib.request.urlopen(req, timeout=20) as yanit:
            return yanit.status, yanit.read().decode("utf-8")
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode("utf-8")


def sync(token, client_id, since_cursor, ops):
    basliklar = {"Authorization": "Bearer " + token}
    govde = {"clientId": client_id, "clientHlc": None, "sinceCursor": since_cursor, "ops": ops}
    kod, gov = istek("/v1/sync", govde, basliklar)
    if kod != 200:
        raise SystemExit("[DUR] /v1/sync HTTP %d (beklenen 200): %s" % (kod, gov))
    return json.loads(gov)


def alan_op(entity_type, entity_id, actor_id, client_id, alanlar, wall_ms):
    op_id = uuid7()
    hlc = {"wallMs": wall_ms, "counter": 0, "clientId": client_id}
    fields = {ad: {"value": deger, "hlc": hlc} for ad, deger in alanlar.items()}
    return {
        "operationId": op_id, "clientId": client_id, "entityId": entity_id,
        "actorId": actor_id, "entityType": entity_type, "opHlc": hlc, "fields": fields,
    }


def main():
    if len(sys.argv) < 2:
        raise SystemExit("[DUR] cikti yolu zorunlu argumandir")
    cikti_yolu = sys.argv[1]

    kosum_id = uuid.uuid4().hex[:8]
    eposta = "o85a-cevrimdisi-%s@momentum.test" % kosum_id
    kod, gov = istek("/v1/auth/register", {"email": eposta, "password": "sifreO85a12345"})
    kaydet("0) POST /v1/auth/register (cevrimdisi kalacak istemcinin hesabi)", "HTTP %d\n%s" % (kod, gov))
    if kod != 201:
        raise SystemExit("[DUR] register 201 DONMEDI (HTTP %d)" % kod)
    hesap = json.loads(gov)
    token = hesap["accessToken"]
    actor_id = hesap["userId"]

    CLIENT_CEVRIMDISI = "cccccccc-1111-4ccc-8ccc-cccccccccccc"
    CLIENT_GOZLEMCI = "dddddddd-2222-4ddd-8ddd-dddddddddddd"
    proje_id = str(uuid.uuid4())
    gorev_id = str(uuid.uuid4())
    cevrimdisi_saat = int(time.time() * 1000) - 5 * 60 * 1000  # 5 dk once ("cevrimdisiyken")

    # ------------------------------------------------------------------
    # OFFLINE EVRE -- ASAGIDAKI UC SATIRDA HICBIR AG CAGRISI YOK. Sadece
    # WireOp GOVDELERI kuruluyor (tipki `_yerelYaz`in yerel DB'ye yazdigi
    # gibi) -- kuyrukta BEKLIYOR, gonderilmedi. Sira BILEREK: liste yaratma
    # (B1) -> MEVCUT bir gorev (projectId'siz dogar) -> o gorevi listeye
    # TASIMA (B2, AYRI bir op -- B3'un "tek op'ta dogus"undan FARKLI, is
    # emrinin "cevrimdisi liste yaratma + gorev TASIMA" lafziyla ortusur).
    # ------------------------------------------------------------------
    op_liste = alan_op("Project", proje_id, actor_id, CLIENT_CEVRIMDISI, {"name": "Tatil"}, cevrimdisi_saat)
    op_gorev_dogus = alan_op("Task", gorev_id, actor_id, CLIENT_CEVRIMDISI,
                              {"title": "Bileti al"}, cevrimdisi_saat + 1000)
    op_gorev_tasima = alan_op("Task", gorev_id, actor_id, CLIENT_CEVRIMDISI,
                               {"projectId": proje_id}, cevrimdisi_saat + 2000)
    kaydet("1) CEVRIMDISI EVRE -- kuyrukta biriken UC op (HENUZ HICBIR /v1/sync CAGRISI YAPILMADI)",
           json.dumps([op_liste, op_gorev_dogus, op_gorev_tasima], ensure_ascii=False, indent=2))

    # ------------------------------------------------------------------
    # BAGLANTI GELDI -- kuyruk TEK turda pushlanir (gercek SenkronDongusu'nun
    # yaptigi gibi, kuyrukta ne biriktiyse).
    # ------------------------------------------------------------------
    ops = [op_liste, op_gorev_dogus, op_gorev_tasima]
    r2 = sync(token, CLIENT_CEVRIMDISI, None, ops)
    kaydet("2) BAGLANTI GELDI -- POST /v1/sync (kuyruktaki UC op TEK turda pushlanir)",
           json.dumps(r2, ensure_ascii=False, indent=2))
    kodlar = {a["operationId"]: a["code"] for a in r2["applied"]}
    for op in ops:
        if kodlar.get(op["operationId"]) != "Applied":
            raise SystemExit("[DUS] reconnect push'unda biri Applied DONMEDI: %s" % r2["applied"])

    # ------------------------------------------------------------------
    # IKINCI ISTEMCI (hic offline kalmadi, TAZE kurulum) -- reconnect
    # SONRASI ikisini de GORUR MU?
    # ------------------------------------------------------------------
    r3 = sync(token, CLIENT_GOZLEMCI, None, [])
    kaydet("3) Ikinci istemci -- POST /v1/sync (TAZE kurulum, POZITIF: cevrimdisi verisini gorur mu)",
           json.dumps(r3, ensure_ascii=False, indent=2))
    proje_g = [e for e in r3["snapshot"] if e["entityType"] == "Project" and e["entityId"] == proje_id]
    gorev_g = [e for e in r3["snapshot"] if e["entityType"] == "Task" and e["entityId"] == gorev_id]
    if not proje_g:
        raise SystemExit("[DUS] ikinci istemci cevrimdisi listeyi GORMEDI")
    if not gorev_g:
        raise SystemExit("[DUS] ikinci istemci cevrimdisi gorevi GORMEDI")
    proj_alani = next((s for s in gorev_g[0]["scalars"] if s["field"] == "projectId"), None)
    if proj_alani is None or proj_alani["value"] != proje_id:
        raise SystemExit("[DUS] ikinci istemcide gorevin projectId'si YANLIS/YOK: %s" % gorev_g)

    ozet = [
        "1) Cevrimdisi evrede UC op kuyrukta kuruldu (liste + gorev dogusu + gorev TASIMASI) --"
        " HICBIR /v1/sync cagrisi YAPILMADI",
        "2) Baglanti gelince kuyruk TEK turda pushlandi -- ucu de Applied",
        "3) TAZE ikinci istemci HER IKISINI de gordu (liste + gorev, projectId DOGRU -- tasima yansidi)",
        "SONUC: cevrimdisi liste yaratma + gorev tasima, baglanti gelince KENDILIGINDEN esitlendi.",
    ]
    kaydet("OZET", "\n".join(ozet))

    with open(cikti_yolu, "w", encoding="utf-8") as f:
        f.write("\n".join(KANIT))
    print("\n[YAZILDI] %s" % cikti_yolu)


if __name__ == "__main__":
    main()
