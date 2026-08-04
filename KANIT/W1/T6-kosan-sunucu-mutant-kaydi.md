# T6 — 2 koşan-sunucu mutant kaydı (M195, M196)

Her ikisi de gerçek backend'i yeniden başlatmayı gerektirir (derleme/tarayıcı istemez).
`_preflight.py` ile canlı ölçüldü.

## M195 — CORS politikası tamamen kaldırılır, backend yeniden başlatılır

Program.cs'ten hem `AddCors` hem `UseCors` blokları (D-W1-2 işaretli ikisi de) silindi,
backend yeniden derlenip başlatıldı.

```
G36/a: HTTP=405 ACAO=None ACAH=None -> KALDI
G36/b: HTTP=405 ACAO=None -> GECTI (DONMEMELI)
G36/c: HTTP=200 ACAO=None -> KALDI
HUKUM: BAZI AYAKLAR DUSTU: {'G36/a': False, 'G36/c': False}
```

**ISIRDI** — hedeflenen `W1/G36/a` + `W1/G36/c` KIRMIZI verdi (`Access-Control-Allow-Origin`
hiçbir yanıtta dönmedi). Geri alındı, sha256 tabanla eşleşti
(`1e31f5b47697c6b342604efe73f070985730820632c4245fb02843795fee8301`).

## M196 — Politika `SetIsOriginAllowed(_ => true)` yapılır (origin yankılanır)

```
G36/a: HTTP=204 ACAO='http://localhost:5000' ACAH='Content-Type,X-Momentum-Dev-User' -> GECTI
G36/b: HTTP=204 ACAO='http://evil.local' -> KALDI (DONMEMELI)
G36/c: HTTP=200 ACAO='http://localhost:5000' -> GECTI
HUKUM: BAZI AYAKLAR DUSTU: {'G36/b': False}
```

**ISIRDI** — ve tam denetimin (B2) istediği şekilde: `G36/a` ve `G36/c` YEŞİL kaldı
(v1'in `M196`'sının eşdeğer-mutant kusuru burada TEKRARLANMADI), yalnız `G36/b`
(negatif ayak, origin-yankılayan politikanın GERÇEK hedefi) `evil.local`
başlığının GERÇEKTEN alındığını göstererek KIRMIZI verdi. Geri alındı, sha256
tabanla eşleşti.

## Sonuç

**2/2 koşan-sunucu mutant ISIRDI**, beklendiği gibi. Backend temiz kodla
yeniden başlatıldı ve `_preflight.py` üç ayağın da (G36/a,b,c) tekrar
**HEPSİ GEÇTİ** verdiği doğrulandı (`G36-preflight-ham.txt` son hâli).
