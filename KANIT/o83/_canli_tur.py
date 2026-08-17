# -*- coding: utf-8 -*-
"""IS-EMRI-o83 s3.4 -- canli tur (Claude Code). Gercek calisan backend'e
(docker compose, ayni imaj) dogrudan HTTP ile konusur -- Flutter istemcisinin
HttpAuthAgi/HttpSenkronAgi'nin YAPTIGI AYNI cagrilar, elle tekrarlanir.
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


def main():
    ozet = []

    # --- a) Hesap A acilir, giris yapilir (register=auto-login), gorev eklenir ---
    kod, gov = istek("/v1/auth/register", {"email": "canli-a@momentum.test", "password": "sifreA12345"})
    kaydet("a) POST /v1/auth/register (A)", "HTTP %d\n%s" % (kod, gov))
    if kod != 201:
        ozet.append("[DUR] A kaydi basarisiz (%d) -- belki zaten var, login deneniyor" % kod)
        kod, gov = istek("/v1/auth/login", {"email": "canli-a@momentum.test", "password": "sifreA12345"})
        kaydet("a) POST /v1/auth/login (A, fallback)", "HTTP %d\n%s" % (kod, gov))
    a = json.loads(gov)
    a_yetkili = {"Authorization": "Bearer " + a["accessToken"]}

    entity_id = "11111111-1111-1111-1111-111111111111"
    op_id = uuid7()
    sync_govdesi = {
        "clientId": "33333333-3333-3333-3333-333333333333",
        "clientHlc": None, "sinceCursor": None,
        "ops": [{
            "operationId": op_id, "clientId": "33333333-3333-3333-3333-333333333333",
            "entityId": entity_id, "actorId": a["userId"], "entityType": "Task",
            "opHlc": {"wallMs": int(time.time() * 1000), "counter": 0, "clientId": "33333333-3333-3333-3333-333333333333"},
            "fields": {"title": {"value": "A'nin canli gorevi", "hlc": {"wallMs": int(time.time() * 1000), "counter": 0, "clientId": "33333333-3333-3333-3333-333333333333"}}},
        }],
    }
    kod, gov = istek("/v1/sync", sync_govdesi, basliklar=a_yetkili)
    kaydet("a) POST /v1/sync (A gorev ekler, Bearer A)", "HTTP %d\n%s" % (kod, gov[:500]))
    ozet.append("a) A kaydoldu+giris yapti+gorev ekledi -> HTTP %d" % kod)

    # --- b/c) Hesap B acilir -- A'nin gorevini GORMEMELI; B kendi gorevini eklerse A GORMEMELI ---
    kod, gov = istek("/v1/auth/register", {"email": "canli-b@momentum.test", "password": "sifreB12345"})
    kaydet("b) POST /v1/auth/register (B)", "HTTP %d\n%s" % (kod, gov))
    if kod != 201:
        kod, gov = istek("/v1/auth/login", {"email": "canli-b@momentum.test", "password": "sifreB12345"})
        kaydet("b) POST /v1/auth/login (B, fallback)", "HTTP %d\n%s" % (kod, gov))
    b = json.loads(gov)
    b_yetkili = {"Authorization": "Bearer " + b["accessToken"]}

    kod, gov = istek("/v1/tasks", basliklar=b_yetkili)
    b_gorur_a_yi = entity_id in gov
    kaydet("b) GET /v1/tasks (Bearer B)", "HTTP %d\nA'nin gorevini icerir mi: %s\n%s" % (kod, b_gorur_a_yi, gov[:800]))
    ozet.append("b) B, A'nin gorevini GORUYOR MU: %s (beklenen: False)" % b_gorur_a_yi)

    b_entity_id = "44444444-4444-4444-4444-444444444444"
    b_op_id = uuid7()
    sync_govdesi_b = {
        "clientId": "66666666-6666-6666-6666-666666666666",
        "clientHlc": None, "sinceCursor": None,
        "ops": [{
            "operationId": b_op_id, "clientId": "66666666-6666-6666-6666-666666666666",
            "entityId": b_entity_id, "actorId": b["userId"], "entityType": "Task",
            "opHlc": {"wallMs": int(time.time() * 1000), "counter": 0, "clientId": "66666666-6666-6666-6666-666666666666"},
            "fields": {"title": {"value": "B'nin canli gorevi", "hlc": {"wallMs": int(time.time() * 1000), "counter": 0, "clientId": "66666666-6666-6666-6666-666666666666"}}},
        }],
    }
    kod, gov = istek("/v1/sync", sync_govdesi_b, basliklar=b_yetkili)
    kaydet("c) POST /v1/sync (B gorev ekler, Bearer B)", "HTTP %d\n%s" % (kod, gov[:500]))

    kod, gov = istek("/v1/tasks", basliklar=a_yetkili)
    a_gorur_b_yi = b_entity_id in gov
    kaydet("c) GET /v1/tasks (Bearer A)", "HTTP %d\nB'nin gorevini icerir mi: %s\n%s" % (kod, a_gorur_b_yi, gov[:800]))
    ozet.append("c) A, B'nin gorevini GORUYOR MU: %s (beklenen: False)" % a_gorur_b_yi)

    # --- d) erisim token'i suresi dolunca ne olur -- ZORLANDI (bilinen Development
    #        sirriyla, GECERLI ama SURESI GECMIS bir JWT elle imzalanir; canli
    #        register/login akisinin URETTIGI GERCEK refresh token'la eslenir) ---
    sahte_suresi_gecmis = sahte_jwt_uret(a["userId"], int(time.time()) - 60)
    kod, gov = istek("/v1/sync", sync_govdesi, basliklar={"Authorization": "Bearer " + sahte_suresi_gecmis})
    kaydet("d) POST /v1/sync (SURESI GECMIS JWT, ayni imza sirriyla ZORLANDI)", "HTTP %d\n%s" % (kod, gov[:300]))
    ozet.append("d.1) suresi gecmis JWT ile push -> HTTP %d (beklenen: 401)" % kod)

    kod, gov = istek("/v1/auth/refresh", {"refreshToken": a["refreshToken"]})
    kaydet("d) POST /v1/auth/refresh (A'nin GERCEK refresh token'i)", "HTTP %d\n%s" % (kod, gov))
    ozet.append("d.2) refresh -> HTTP %d" % kod)
    a_yenilenmis = json.loads(gov)

    kod, gov = istek("/v1/sync", sync_govdesi, basliklar={"Authorization": "Bearer " + a_yenilenmis["accessToken"]})
    kaydet("d) POST /v1/sync (YENILENMIS token ile AYNI op TEKRAR gonderilir)", "HTTP %d\n%s" % (kod, gov[:500]))
    ozet.append("d.3) yenilenmis token ile ayni op tekrar -> HTTP %d (beklenen: 200, kayip yok)" % kod)

    # --- e) Authorization basligiyla 200, basliksiz 401 ---
    kod, gov = istek("/v1/tasks", basliklar=a_yetkili)
    ozet.append("e.1) GET /v1/tasks + Authorization -> HTTP %d (beklenen: 200)" % kod)
    kod2, gov2 = istek("/v1/tasks")
    ozet.append("e.2) GET /v1/tasks basliksiz -> HTTP %d (beklenen: 401)" % kod2)
    kaydet("e) yetkili/yetkisiz GET /v1/tasks", "yetkili=%d\nyetkisiz=%d" % (kod, kod2))

    kaydet("OZET", "\n".join(ozet))

    with io.open(r"C:\dev\Momentum\KANIT\o83\08-canli-tur.txt", "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(KANIT))


if __name__ == "__main__":
    main()
