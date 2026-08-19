# -*- coding: utf-8 -*-
"""IS-EMRI-o85-A SS8 madde 3 (03-iki-istemci.md) icin CANLI olcum uretici.
o83/o83-G'nin AYNI yontemi: gercek calisan backend'e (docker compose, AYNI
imaj -- sunucu kodu bu dilimde DEGISMEDI) dogrudan HTTP ile konusulur, Flutter
istemcisinin SyncPuller/SyncPusher'inin YAPTIGI cagrilar elle tekrarlanir.
`GET /v1/projects` YOK (o85-B'nin isi, s1) -- olcum TAMAMEN `/v1/sync` cursor
protokoluyledir (registry entityType-agnostik, s1'in kendi iddiasi -- BURADA
CANLI OLARAK SINANIYOR).

Senaryo: TEK hesap, IKI clientId (iki GERCEK cihaz simulasyonu -- ayni
kullanicinin iki cihazi, K1/K5 senaryosunun ta kendisi):
  1) Istemci A: liste yaratir ("Is").
  2) Istemci B (TAZE kurulum, sinceCursor:null): o listeyi kendi ILK
     pull'unda GORUR mu? (C2 -- snapshot dali acilmazsa GORMEZ.)
  3) Istemci A: o listede bir gorev yaratir (title+projectId TEK op, B3).
  4) Istemci B (kendi KAYDETTIGI cursor'dan, ARTIMLI pull): gorevi
     `changes`'te GORUR mu, projectId DOGRU mu?
  5) Istemci A: ayni gorevi Gelen Kutusu'na tasir (projectId: null, B2).
  6) Istemci B (yine ARTIMLI): projectId'nin NULL'A DONDUGUNU gorur mu?

HER iddia TAM DEGER esleşmesiyle kontrol edilir (yalniz "bos degil" DEGIL) --
o83-G'nin "bos liste her iddiayi gecirir" dersinin PAZARLIKSIZ uygulanmasi.
"""
import json
import os
import sys
import time
import urllib.error
import urllib.request
import uuid

# mine #4 (CLAUDE.md): Windows konsolu cp1254 -- Turkce karakterler (İş)
# mojibake basar. Konsol GORUNTUSU ETKILENIR, dosyaya yazim ZATEN utf-8
# (asagida encoding="utf-8" acikca verilir) -- ama print() de dogru olsun.
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


def alan_op(entity_type, entity_id, actor_id, client_id, alanlar):
    op_id = uuid7()
    now = int(time.time() * 1000)
    hlc = {"wallMs": now, "counter": 0, "clientId": client_id}
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
    eposta = "o85a-iki-istemci-%s@momentum.test" % kosum_id
    kod, gov = istek("/v1/auth/register", {"email": eposta, "password": "sifreO85a12345"})
    kaydet("0) POST /v1/auth/register (TEK hesap, IKI istemci bunu paylasir)",
           "HTTP %d\n%s" % (kod, gov))
    if kod != 201:
        raise SystemExit("[DUR] register 201 DONMEDI (HTTP %d)" % kod)
    hesap = json.loads(gov)
    token = hesap["accessToken"]
    actor_id = hesap["userId"]

    CLIENT_A = "aaaaaaaa-1111-4aaa-8aaa-aaaaaaaaaaaa"
    CLIENT_B = "bbbbbbbb-2222-4bbb-8bbb-bbbbbbbbbbbb"
    proje_id = str(uuid.uuid4())
    gorev_id = str(uuid.uuid4())

    kaydet("TAZE KIMLIKLER", "proje_id = %s\ngorev_id = %s\nCLIENT_A = %s\nCLIENT_B = %s"
           % (proje_id, gorev_id, CLIENT_A, CLIENT_B))

    # --- 1) Istemci A: liste yaratir ---
    op1 = alan_op("Project", proje_id, actor_id, CLIENT_A, {"name": "İş"})
    r1 = sync(token, CLIENT_A, None, [op1])
    kaydet("1) Istemci A -- POST /v1/sync (liste 'İş' yaratir)", json.dumps(r1, ensure_ascii=False, indent=2))
    if r1["applied"][0]["code"] != "Applied":
        raise SystemExit("[DUS] A'nin liste op'u Applied DONMEDI: %s" % r1["applied"])

    # --- 2) Istemci B, TAZE kurulum: A'nin yarattigi listeyi GORUR MU? (C2) ---
    r2 = sync(token, CLIENT_B, None, [])
    kaydet("2) Istemci B -- POST /v1/sync (TAZE kurulum, sinceCursor:null, POZITIF: A'nin listesini gorur mu)",
           json.dumps(r2, ensure_ascii=False, indent=2))
    proje_snapshot = [e for e in r2["snapshot"] if e["entityType"] == "Project" and e["entityId"] == proje_id]
    if not proje_snapshot:
        raise SystemExit("[DUS] B'nin ILK pull'unda A'nin listesi YOK -- C2 (snapshot dali) DUSTU")
    ad_alani = next((s for s in proje_snapshot[0]["scalars"] if s["field"] == "name"), None)
    if ad_alani is None or ad_alani["value"] != "İş":
        raise SystemExit("[DUS] B'de listenin adi YANLIS/YOK: %s" % proje_snapshot)
    b_cursor = r2["nextCursor"]

    # --- 3) Istemci A: o listede bir gorev yaratir (title+projectId TEK op, B3) ---
    op3 = alan_op("Task", gorev_id, actor_id, CLIENT_A, {"title": "Rapor yaz", "projectId": proje_id})
    r3 = sync(token, CLIENT_A, None, [op3])
    kaydet("3) Istemci A -- POST /v1/sync ('İş' listesinde 'Rapor yaz' gorevi dogar, projectId AYNI op'ta)",
           json.dumps(r3, ensure_ascii=False, indent=2))
    if r3["applied"][0]["code"] != "Applied":
        raise SystemExit("[DUS] A'nin gorev op'u Applied DONMEDI: %s" % r3["applied"])

    # --- 4) Istemci B, KAYDETTIGI cursor'dan ARTIMLI pull: gorevi `changes`'te gorur mu? ---
    r4 = sync(token, CLIENT_B, b_cursor, [])
    kaydet("4) Istemci B -- POST /v1/sync (ARTIMLI, kendi cursor'undan, POZITIF: yeni gorevi gorur mu)",
           json.dumps(r4, ensure_ascii=False, indent=2))
    # `changes[i]` = {cursor, payload: WireOp}; WireOp.entityType/entityId/fields
    # `payload` ALTINDADIR -- duz degil (canli cagriyla OLCULDU, tahmin edilmedi).
    gorev_yukleri = [c["payload"] for c in r4["changes"]
                     if c["payload"]["entityType"] == "Task" and c["payload"]["entityId"] == gorev_id]
    if not gorev_yukleri:
        raise SystemExit("[DUS] B'nin ARTIMLI pull'unda yeni gorev YOK -- B3/senkron DUSTU")
    proj_alani = gorev_yukleri[0]["fields"].get("projectId")
    if proj_alani is None or proj_alani["value"] != proje_id:
        raise SystemExit("[DUS] B'de gorevin projectId'si YANLIS/YOK: %s" % gorev_yukleri)
    b_cursor = r4["nextCursor"]

    # --- 5) Istemci A: ayni gorevi Gelen Kutusu'na tasir (projectId: null, B2 -- GERCEK tel yazimi) ---
    op5 = alan_op("Task", gorev_id, actor_id, CLIENT_A, {"projectId": None})
    r5 = sync(token, CLIENT_A, None, [op5])
    kaydet("5) Istemci A -- POST /v1/sync (gorevi Gelen Kutusu'na tasir, projectId:null)",
           json.dumps(r5, ensure_ascii=False, indent=2))
    if r5["applied"][0]["code"] != "Applied":
        raise SystemExit("[DUS] A'nin tasima op'u Applied DONMEDI: %s" % r5["applied"])

    # --- 6) Istemci B, yine ARTIMLI: projectId'nin NULL'A DONDUGUNU gorur mu? ---
    r6 = sync(token, CLIENT_B, b_cursor, [])
    kaydet("6) Istemci B -- POST /v1/sync (ARTIMLI, POZITIF: tasimayi gorur mu -- projectId artik null)",
           json.dumps(r6, ensure_ascii=False, indent=2))
    tasima_yukleri = [c["payload"] for c in r6["changes"]
                      if c["payload"]["entityType"] == "Task" and c["payload"]["entityId"] == gorev_id
                      and "projectId" in (c["payload"]["fields"] or {})]
    if not tasima_yukleri:
        raise SystemExit("[DUS] B'nin ARTIMLI pull'unda tasima YOK -- B2/senkron DUSTU")
    tasima_alani = tasima_yukleri[0]["fields"]["projectId"]
    # B2 PAZARLIKSIZ: alan SADECE mevcut olmakla kalmaz (Yazim(null) atlanmadi,
    # "field" anahtari TELDE VAR), value'su da GERCEKTEN null'dur.
    if "value" not in tasima_alani or tasima_alani["value"] is not None:
        raise SystemExit("[DUS] B'de projectId HALA DOLU (null DEGIL): %s" % tasima_yukleri)

    ozet = [
        "1) A liste yaratti -> Applied",
        "2) B (TAZE kurulum) A'nin listesini GORDU (snapshot, C2 kaniti)",
        "3) A o listede gorev yaratti (title+projectId TEK op, B3) -> Applied",
        "4) B (ARTIMLI) yeni gorevi GORDU, projectId DOGRU (changes, senkron kaniti)",
        "5) A gorevi Gelen Kutusu'na tasidi (projectId:null, B2) -> Applied",
        "6) B (ARTIMLI) tasimayi GORDU, projectId NULL (changes, senkron kaniti)",
        "SONUC: TUM adimlar GECTI -- iki istemci gercekten mirror'landi.",
    ]
    kaydet("OZET", "\n".join(ozet))

    with open(cikti_yolu, "w", encoding="utf-8") as f:
        f.write("\n".join(KANIT))
    print("\n[YAZILDI] %s" % cikti_yolu)


if __name__ == "__main__":
    main()
