# o71 — `D-W3-4` CORP: COWORK BAĞIMSIZ KABUL HÜKMÜ

**Ölçen:** Cowork (K26 — üreten ≠ denetleyen). **Üreten:** Claude Code.
**Tarih:** 12 Ağu 2026 (cihazdan ölçüldü: `TZ=Europe/Istanbul date` ⇒ 2026-08-12 21:17).
**Commit'ler:** `d6c87c7` (ürün + 6 test) · `2495fc3` (7. test, BULGU 1 kapanışı).

## 1. NE ÖLÇÜLDÜ — Code'un beyanına BAKILMADI, artefakt söküldü

| ölçüm | araç / yol | sonuç |
|---|---|---|
| ürün kodu satırı | `radar.py . --olc-urun-kodu 6fcb500` | **23** (+17 `IzolasyonBasliklari.cs`, +6 `IstemciServisi.cs`) — elle sayılmadı |
| `R8` | `radar.py .` | 🟢 **SUSTU** (o71 ürün kodu üretti; üçüncü sıfır kırıldı) |
| kaynak diff | `git diff HEAD~2..HEAD -- src/**` | CORP **yalnız** `StaticFileOptions.OnPrepareResponse`'ta; `/v1`, `/health`, `/hubs`, `/scalar` bu seçenekleri **hiç görmüyor** ⇒ `D-W3-4` karşılandı |
| ölü beyan | `IzolasyonBasliklari.cs` `<remarks>` | *"CORP bu iskelette YOKTUR … ölçülmeden yazılmaz"* **aynı commit'te** düzeltildi |
| mutant `M231` | `KANIT/o71/03-MUTANT-M231.txt` | ISIRDI · beklenen küme **birebir**: `['SPA_geri_dusus_belgesi_CORP_tasir','Statik_dosya_CORP_same_origin_tasir']` |
| mutant `M231b` | `KANIT/o71/03-MUTANT-M231b.txt` | ISIRDI · beklenen küme **birebir**: `['Health_live_CORP_tasimaz','Sync_ucnoktasi_CORP_tasimaz']` |
| mutant sonrası kimlik | özet | taban↔son sha8 **özdeş** (`8AACC4B1` / `E5E85F17`) ⇒ yama geri alındı |
| `verify.ps1` | `KANIT/o71/06-verify-ps1.txt` | **EXITCODE=0** · 5+21+44+56 = **126** test · CVE 0 |
| ek test koşumu | `KANIT/o71/07-EK-TEST.txt` | `Momentum.Api.Tests` **22/22** · EXITCODE=0 |
| ortam | `KANIT/o71/01`,`03`,`04`,`05b` | `momentum-postgres` Up (healthy) · hazırlık üçlüsü ölçüldü · backend **yoklamayla** kapatıldı (`:5298` LISTENING yok) · 🔴 `adb` **cihaz YOK** |
| push | `rev-list --left-right --count origin/main...HEAD` | **0 2** — `d6c87c7` ve `2495fc3` **İTİLMEDİ** (PUSH ONUR'DA) |
| kapılar | `araclar/` | tek-kopya **YEŞİL** · belge-tavan **YEŞİL** · sayı-tazeliği **TEMİZ** · kapı-ad-teklik **YEŞİL** |

## 2. HÜKÜM

🟢 **KABUL EDİLİR.** `D-W3-4` (CORP yalnız statik yanıtlara) ürün kodunda **koşuyor** ve
**yedi test + iki mutantla** ısırıyor. `G44/e`'nin hedeflediği davranış artık üründe var;
`G44` **kapısı** hâlâ yazılmadı (aşağıya bakınız) — bu kabul **davranışın** kabulüdür, kapının değil.

## 3. BEYAN EDİLMİŞ SINIRLAR — *"neyi ölçmedik"*

1. 🔴 **`G43`/`G44` STATİK KAPILARI KOŞULMADI** çünkü **yazılmadı** (`T6`, `K175`② + `R8` yasağı).
   Kapıların ilan edilmiş kapsamı (`Program.cs`) bugünkü ürünle **uyuşmuyor** — `B-O71-1`.
2. 🔴 **`dotnet`/`verify.ps1` Cowork tarafından KOŞULAMADI** — `device_bash`'in Linux VM'inde
   .NET yok. Bu iki ölçüm **Code'un ham çıktısından** okundu; bağımsız yeniden koşum
   **YAPILMADI**. Cowork'ün bağımsız katkısı: kaynak diff, mutant özeti ↔ ham dosya tutarlılığı,
   sha özdeşliği, git ölçümleri ve kapılar.
3. 🔴 **`verify.ps1` 7. testi GÖRMEDİ.** `2495fc3` sonrası yalnız `Momentum.Api.Tests` koştu (22/22).
   Toplam test **127**'dir ama bu sayı **`verify.ps1` ile ölçülmedi** (`B-O71-2` yüzünden yeniden koşulmadı).
4. 🔴 **Canlı HTTP (`G46`) koşulmadı** — bu dilim yalnız in-process `WebApplicationFactory` ile ölçüldü.
5. 🔴 **`adb` cihaz YOK** ⇒ `SS2` kriter 8 uçtan uca **hâlâ açık** (`D-SS2-11`).
