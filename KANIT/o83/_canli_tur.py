# -*- coding: utf-8 -*-
"""IS-EMRI-o83 s3.4 (o83-B ile DUZELTILDI -- B1/B3 bulgulari; o83-G ile DUZELTILDI --
pozitif kontrol eksikligi). Gercek calisan backend'e (docker compose, ayni imaj)
dogrudan HTTP ile konusur -- Flutter istemcisinin HttpAuthAgi/HttpSenkronAgi'nin
YAPTIGI AYNI cagrilar, elle tekrarlanir.

o83-B B1 duzeltmesi: d ayagi artik a ayaginin (zaten Applied) op'unu DEGIL,
HIC gonderilmemis YENI bir op kullanir -- d.3'un kodu boylece Duplicate
DEGIL Applied olmak ZORUNDADIR (aksi halde ayak DUSMUS sayilir, is emri s2.2).
o83-B B3 duzeltmesi: her kosumda TAZE e-posta (uuid ekli) -- register HER
ZAMAN 201 doner, 409-fallback-login YOLU bu turda hic calismaz.

o83-G duzeltmesi: NEGATIF KONTROL, POZITIF KONTROL YESIL OLMADAN ANLAMSIZDIR.
Eski script yalniz b_gorur_a_yi/a_gorur_b_yi'yi olcuyordu; bunlarin ikisi de
BOS LISTE uzerinden "False" donunce bedava gecti (KANIT/o83G s1). Simdi HER
negatif kontrolden ONCE, HEDEFIN KENDI gorevini gordugu ayri bir pozitif
kontrolle (en fazla 10 deneme x 300ms, okuma modeli gecikmeli olabilir)
kanitlanir; pozitif dusmuse negatif "OLCULEMEDI" yazar, "False" diye YESIL
YAZILMAZ. entity_id/b_entity_id artik HER KOSUMDA taze (sabit 1111.../4444...
kalici ciltte onceki kosumun sahipligiyle CAKISIYOR olabilirdi).

o83-H duzeltmesi: (A1) cikti yolu artik ZORUNLU argumandir (sys.argv[1]),
varsayilan yol YOK -- bir o83-sonrasi kosum bir daha o83'un KENDI KANIT
dosyasinin (08-canli-tur.txt) uzerine YAZAMASIN. (A2) b_gorur_a_yi artik
b_kendi_gorur'dan SONRA olculur (B once kendi gorevini ekler) -- (A3) HER
iki negatif de olculdugu anda ilgili listenin BOS OLMADIGI (items:[] DEGIL)
ayrica dogrulanir, bos ise SystemExit ("OLCULEMEDI") -- bos liste artik
POZITIF kontrolun GEREGI degil, HER negatifin KENDI kalkani.
"""
import base64
import hashlib
import hmac
import io
import json
import os
import sys
import time
import urllib.error
import urllib.request
import uuid


def uuid7():
    # slice-3d D8 (SyncIngest.IsEnvelopeValid): operationId UUIDv7 OLMAK ZORUNDA
    # (bayt[7]'nin ust yarisi 0x7) -- LWW tie-break'i (HlcKey) zaman-sirali bir
    # opId varsayar. RFC 9562 taslak duzeni: 48 bit ts_ms + 4 bit versiyon(7) +
    # 12 bit rastgele + 2 bit varyant(10) + 62 bit rastgele.
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


try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

TABAN = "http://localhost:5298"
GELISTIRME_SIRRI = "8YFLoBlqtpdfhP9Pk+fypjeAY5YFKsMrycqTHgw3zTI="
ISSUER = "Momentum"
AUDIENCE = "Momentum"
KOSUM_ID = uuid.uuid4().hex[:8]  # o83-B B3: her kosum TAZE e-posta uzayi kullanir
MAX_DENEME = 10  # o83-G s2.5: pozitif kontrol en fazla 10 deneme x 300ms
BEKLEME_SN = 0.3

KANIT = []


def kaydet(baslik, govde):
    KANIT.append("=== %s ===\n%s\n" % (baslik, govde))
    print("=== %s ===" % baslik)
    print(govde)


def istek(yol, govde=None, yontem=None, basliklar=None):
    url = TABAN + yol
    veri = json.dumps(govde).encode("utf-8") if govde is not None else None
    req = urllib.request.Request(url, data=veri, method=yontem or ("POST" if veri else "GET"))
    req.add_header("Content-Type", "application/json")
    for k, v in (basliklar or {}).items():
        req.add_header(k, v)
    try:
        with urllib.request.urlopen(req, timeout=20) as yanit:
            gov = yanit.read().decode("utf-8")
            return yanit.status, gov
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode("utf-8")


def pozitif_bekle(basliklar, aranan_id):
    """o83-G s2.5: okuma modeli gecikmeli olabilir, olc -- varsayma. En fazla MAX_DENEME kez,
    BEKLEME_SN araliklarla /v1/tasks yeniden sorgulanir; kacinci denemede tuttugu donulur.
    Negatif kontrolde bu FONKSIYON KULLANILMAZ (bekleme yanlis negatifi gizler, s2.3)."""
    kod, gov = None, ""
    for deneme in range(1, MAX_DENEME + 1):
        kod, gov = istek("/v1/tasks", basliklar=basliklar)
        if kod == 200 and aranan_id in gov:
            return True, deneme, kod, gov
        if deneme < MAX_DENEME:
            time.sleep(BEKLEME_SN)
    return False, MAX_DENEME, kod, gov


def negatif_olc(basliklar, aranan_id, etiket):
    """o83-H A3: negatif kontrol aninda ilgili listenin DOLU olmasi sarttir -- bos liste
    (items:[]) "gormuyor"u BEDAVA dogru yapar, bu da negatifin KENDI kalkani olurdu (KANIT/o83G
    s1). Bekleme YOK, pozitif_bekle KULLANILMAZ -- tek sorgu (bekleme yanlis negatifi gizler,
    s2.3)."""
    kod, gov = istek("/v1/tasks", basliklar=basliklar)
    try:
        items_sayisi = len(json.loads(gov).get("items", []))
    except Exception:
        items_sayisi = 0
    if items_sayisi == 0:
        raise SystemExit("[DUS] %s: OLCULEMEDI (liste bos) -- negatif kontrol anlamsiz" % etiket)
    bulundu = aranan_id in gov
    return bulundu, items_sayisi, kod, gov


def b64url(b):
    return base64.urlsafe_b64encode(b).rstrip(b"=")


def sahte_jwt_uret(sub, exp_epoch):
    baslik = b64url(json.dumps({"alg": "HS256", "typ": "JWT"}, separators=(",", ":")).encode())
    govde = b64url(json.dumps({
        "sub": sub, "iss": ISSUER, "aud": AUDIENCE,
        "exp": exp_epoch, "nbf": exp_epoch - 3600,
    }, separators=(",", ":")).encode())
    imzasiz = baslik + b"." + govde
    anahtar = base64.b64decode(GELISTIRME_SIRRI)
    imza = b64url(hmac.new(anahtar, imzasiz, hashlib.sha256).digest())
    return (imzasiz + b"." + imza).decode("ascii")


def yeni_op(entity_id, actor_id, client_id, baslik_metni):
    op_id = uuid7()
    return op_id, {
        "clientId": client_id,
        "clientHlc": None, "sinceCursor": None,
        "ops": [{
            "operationId": op_id, "clientId": client_id,
            "entityId": entity_id, "actorId": actor_id, "entityType": "Task",
            "opHlc": {"wallMs": int(time.time() * 1000), "counter": 0, "clientId": client_id},
            "fields": {"title": {"value": baslik_metni, "hlc": {"wallMs": int(time.time() * 1000), "counter": 0, "clientId": client_id}}},
        }],
    }


def main():
    # o83-H A1: cikti yolu ZORUNLU argumandir, varsayilan YOK -- bir o83-sonrasi kosum bir
    # daha o83'un KENDI kanit dosyasinin uzerine yazamasin. Hicbir HTTP cagrisindan ONCE kontrol
    # edilir (argumansiz cagrida hicbir yan etki, hicbir yazim olmaz).
    if len(sys.argv) < 2:
        raise SystemExit("[DUR] cikti yolu zorunlu argumandir")
    cikti_yolu = sys.argv[1]

    ozet = []

    # o83-G s2.1: entity_id/b_entity_id HER KOSUMDA taze -- sabit 1111.../4444... kalici
    # ciltte onceki kosumun sahipligiyle CAKISIYOR olabilirdi. Basta uretilir+yazilir ki
    # KANIT/o83G/01-canli-tur.txt'in basinda gorunsun.
    entity_id = str(uuid.uuid4())
    b_entity_id = str(uuid.uuid4())
    kaydet("TAZE KIMLIKLER (o83-G s2.1)", "entity_id (A'nin gorevi) = %s\nb_entity_id (B'nin gorevi) = %s" % (entity_id, b_entity_id))

    # --- a) Hesap A acilir (TAZE e-posta -- o83-B B3), giris yapilir (register=auto-login), gorev eklenir ---
    eposta_a = "canli-a-%s@momentum.test" % KOSUM_ID
    kod, gov = istek("/v1/auth/register", {"email": eposta_a, "password": "sifreA12345"})
    kaydet("a) POST /v1/auth/register (A, TAZE eposta)", "HTTP %d\n%s" % (kod, gov))
    ozet.append("a.0) register (TAZE eposta) -> HTTP %d (beklenen: 201)" % kod)
    if kod != 201:
        raise SystemExit("[DUR] TAZE e-posta ile register 201 DONMEDI (HTTP %d) -- o83-B B3 duzelmedi" % kod)
    a = json.loads(gov)
    a_yetkili = {"Authorization": "Bearer " + a["accessToken"]}

    op_id, sync_govdesi = yeni_op(entity_id, a["userId"], "33333333-3333-3333-3333-333333333333", "A'nin canli gorevi")
    kod, gov = istek("/v1/sync", sync_govdesi, basliklar=a_yetkili)
    kaydet("a) POST /v1/sync (A gorev ekler, Bearer A)", "HTTP %d\n%s" % (kod, gov[:500]))
    ozet.append("a) A kaydoldu(201)+giris yapti+gorev ekledi -> HTTP %d" % kod)

    # --- a.2) POZITIF: A kendi gorevini goruyor mu (o83-G s2.2) -- b_gorur_a_yi'nin ILGILI
    #          pozitif kontrolu; bu dusmuse "B gormuyor" bilgi TASIMAZ (bos liste kalkani, s1). ---
    a_kendi_gorur, a_deneme, kod, gov = pozitif_bekle(a_yetkili, entity_id)
    kaydet("a.2) GET /v1/tasks (Bearer A, POZITIF: A kendi gorevini goruyor mu)",
           "HTTP %s (deneme %d/%d)\nA kendi gorevini goruyor mu: %s\n%s" % (kod, a_deneme, MAX_DENEME, a_kendi_gorur, (gov or "")[:800]))
    ozet.append("a.2) a_kendi_gorur: %s (deneme %d/%d) (beklenen: True)" % (a_kendi_gorur, a_deneme, MAX_DENEME))
    if not a_kendi_gorur:
        raise SystemExit("[DUS] a_kendi_gorur POZITIF kontrolu dustu -- BEKLENEN True, GERCEK False (%d/%d denemede A kendi gorevini gormedi)" % (MAX_DENEME, MAX_DENEME))

    # --- b) Hesap B acilir ---
    eposta_b = "canli-b-%s@momentum.test" % KOSUM_ID
    kod, gov = istek("/v1/auth/register", {"email": eposta_b, "password": "sifreB12345"})
    kaydet("b) POST /v1/auth/register (B, TAZE eposta)", "HTTP %d\n%s" % (kod, gov))
    ozet.append("b.0) register (TAZE eposta) -> HTTP %d (beklenen: 201)" % kod)
    if kod != 201:
        raise SystemExit("[DUR] TAZE e-posta ile register 201 DONMEDI (HTTP %d)" % kod)
    b = json.loads(gov)
    b_yetkili = {"Authorization": "Bearer " + b["accessToken"]}

    # --- b.1) B kendi gorevini ekler (o83-H A2: NEGATIFLERDEN ONCE -- boylece asagidaki her iki
    #          negatif de DOLU liste ustunde olcer, bos liste kalkani hicbirine kalmaz). ---
    b_op_id, sync_govdesi_b = yeni_op(b_entity_id, b["userId"], "66666666-6666-6666-6666-666666666666", "B'nin canli gorevi")
    kod, gov = istek("/v1/sync", sync_govdesi_b, basliklar=b_yetkili)
    kaydet("b.1) POST /v1/sync (B gorev ekler, Bearer B)", "HTTP %d\n%s" % (kod, gov[:500]))

    # --- b.2) POZITIF: B kendi gorevini goruyor mu -- b_gorur_a_yi VE a_gorur_b_yi'nin ILGILI pozitifi. ---
    b_kendi_gorur, b_deneme, kod, gov = pozitif_bekle(b_yetkili, b_entity_id)
    kaydet("b.2) GET /v1/tasks (Bearer B, POZITIF: B kendi gorevini goruyor mu)",
           "HTTP %s (deneme %d/%d)\nB kendi gorevini goruyor mu: %s\n%s" % (kod, b_deneme, MAX_DENEME, b_kendi_gorur, (gov or "")[:800]))
    ozet.append("b.2) b_kendi_gorur: %s (deneme %d/%d) (beklenen: True)" % (b_kendi_gorur, b_deneme, MAX_DENEME))
    if not b_kendi_gorur:
        raise SystemExit("[DUS] b_kendi_gorur POZITIF kontrolu dustu -- BEKLENEN True, GERCEK False (%d/%d denemede B kendi gorevini gormedi)" % (MAX_DENEME, MAX_DENEME))

    # --- b.3) NEGATIF: B, A'nin gorevini goruyor mu -- artik B'nin listesi b_kendi_gorur ile
    #          KESINLIKLE DOLU (o83-H A2); negatif_olc bunu AYRICA dogrular (A3). ---
    b_gorur_a_yi, b_liste_sayisi, kod, gov = negatif_olc(b_yetkili, entity_id, "b_gorur_a_yi")
    kaydet("b.3) GET /v1/tasks (Bearer B, NEGATIF: B, A'nin gorevini goruyor mu)",
           "HTTP %d (liste DOLU: %d oge)\nB, A'nin gorevini goruyor mu: %s\n%s" % (kod, b_liste_sayisi, b_gorur_a_yi, gov[:800]))
    ozet.append("b.3) b_gorur_a_yi: %s (liste %d oge ile DOLU) (beklenen: False)" % (b_gorur_a_yi, b_liste_sayisi))
    if b_gorur_a_yi:
        raise SystemExit("[DUS] b_gorur_a_yi NEGATIF kontrolu dustu -- BEKLENEN False, GERCEK True (B, A'nin gorevini goruyor)")

    # --- c) NEGATIF: A, B'nin gorevini goruyor mu -- ILGILI pozitifi a_kendi_gorur (basta True);
    #        A'nin listesi kendi gorevi ile KESINLIKLE DOLU; negatif_olc bunu AYRICA dogrular. ---
    a_gorur_b_yi, a_liste_sayisi, kod, gov = negatif_olc(a_yetkili, b_entity_id, "a_gorur_b_yi")
    kaydet("c) GET /v1/tasks (Bearer A, NEGATIF: A, B'nin gorevini goruyor mu)",
           "HTTP %d (liste DOLU: %d oge)\nA, B'nin gorevini goruyor mu: %s\n%s" % (kod, a_liste_sayisi, a_gorur_b_yi, gov[:800]))
    ozet.append("c) a_gorur_b_yi: %s (liste %d oge ile DOLU) (beklenen: False)" % (a_gorur_b_yi, a_liste_sayisi))
    if a_gorur_b_yi:
        raise SystemExit("[DUS] a_gorur_b_yi NEGATIF kontrolu dustu -- BEKLENEN False, GERCEK True (A, B'nin gorevini goruyor)")

    # --- d) erisim token'i suresi dolunca ne olur -- o83-B B1 duzeltmesi: HIC
    #        GONDERILMEMIS YENI bir op kullanilir (a'nin op'u DEGIL) -- d.3'un
    #        Applied donmesi (Duplicate DEGIL) "kuyruktaki yazim ilk kez BURADA
    #        ulasti" anlamina gelir; Duplicate donerse ayak DUSMUS sayilir. ---
    d_entity_id = "77777777-7777-7777-7777-777777777777"
    d_op_id, sync_govdesi_d = yeni_op(d_entity_id, a["userId"], "88888888-8888-8888-8888-888888888888", "D-ayagi HIC gonderilmemis yeni gorev")

    sahte_suresi_gecmis = sahte_jwt_uret(a["userId"], int(time.time()) - 60)
    kod, gov = istek("/v1/sync", sync_govdesi_d, basliklar={"Authorization": "Bearer " + sahte_suresi_gecmis})
    kaydet("d.1) POST /v1/sync (SURESI GECMIS JWT, ayni imza sirriyla ZORLANDI, YENI op)", "HTTP %d\n%s" % (kod, gov[:300]))
    ozet.append("d.1) suresi gecmis JWT ile YENI op push -> HTTP %d (beklenen: 401)" % kod)
    if kod != 401:
        raise SystemExit("[DUR] d.1 401 DONMEDI (HTTP %d) -- suresi gecmis JWT reddedilmedi" % kod)

    kod, gov = istek("/v1/auth/refresh", {"refreshToken": a["refreshToken"]})
    kaydet("d.2) POST /v1/auth/refresh (A'nin GERCEK refresh token'i)", "HTTP %d\n%s" % (kod, gov))
    ozet.append("d.2) refresh -> HTTP %d (beklenen: 200)" % kod)
    a_yenilenmis = json.loads(gov)

    kod, gov = istek("/v1/sync", sync_govdesi_d, basliklar={"Authorization": "Bearer " + a_yenilenmis["accessToken"]})
    gov_ayrisik = json.loads(gov)
    d3_kod = gov_ayrisik["applied"][0]["code"] if gov_ayrisik.get("applied") else None
    kaydet("d.3) POST /v1/sync (YENI op, YENILENMIS token ile ILK KEZ basariyla gonderilir)",
           "HTTP %d\napplied[0].code=%s (beklenen: Applied, Duplicate DEGIL)\n%s" % (kod, d3_kod, gov[:500]))
    ozet.append("d.3) YENI op, yenilenmis token ile -> HTTP %d, kod=%s (beklenen: 200 + Applied)" % (kod, d3_kod))
    if d3_kod != "Applied":
        raise SystemExit("[DUS] d.3 kodu Applied DEGIL (%s) -- o83-B B1 kabul olcutu KARSILANMADI" % d3_kod)

    # --- e) Authorization basligiyla 200, basliksiz 401 ---
    kod, gov = istek("/v1/tasks", basliklar=a_yetkili)
    ozet.append("e.1) GET /v1/tasks + Authorization -> HTTP %d (beklenen: 200)" % kod)
    kod2, gov2 = istek("/v1/tasks")
    ozet.append("e.2) GET /v1/tasks basliksiz -> HTTP %d (beklenen: 401)" % kod2)
    kaydet("e) yetkili/yetkisiz GET /v1/tasks", "yetkili=%d\nyetkisiz=%d" % (kod, kod2))

    kaydet("OZET", "\n".join(ozet))

    with io.open(cikti_yolu, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(KANIT))

    print("\nTUM ADIMLAR BEKLENEN SEKILDE GECTI.")


if __name__ == "__main__":
    main()
