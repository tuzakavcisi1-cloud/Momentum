# `SS2` KRİTER 8 — UÇTAN UCA, COWORK'ÜN KENDİ KOŞUMU (4 Ağu 2026, oturum 56)

🔴 **BEYAN EDİLMİŞ SAPMA (Onur kilitledi):** çakışma **başlıkla değil TAMAMLANMA anahtarıyla**
üretildi. Gerekçe ölçüldü: **uygulamada başlık düzenleyen bir etkileşim YOK**
(`KANIT/o56/34-KRITER8-SPEC-KOSULAMAZ.md`; `duzenle()` yalnız `cakismaCoz`'dan çağrılıyor).
Spec'in ④/⑤ adımlarının **lafzı** koşulamadı; **mekanizması** (G32 dört şart · G33 rozet +
projeksiyon · G34 çözüm) tam olarak koşuldu.

## Ortam (Claude Code kaldırdı, Cowork ölçtü — K80)
- `momentum-postgres` **Up (healthy)** · backend `0.0.0.0:5298` **LISTENING** (PID 10404)
- Hazırlık **portla değil** üçlüyle: `/health/live` **200** · `/health/ready` **200** ·
  `POST /v1/sync` başlıksız **401** → `X-Momentum-Dev-User` ile **200** (`02-backend-dogrula-ciktisi.txt`)
- `adb devices`: **`emulator-5554`** (B) + **`fba69c15`** (A, fiziksel telefon) — ikisi de `device`
- A'nın taşıması **USB tüneli**: `reverse --list` ⇒ `UsbFfs tcp:5298 tcp:5298`;
  **emülatörde reverse YOK** (kontrol geçti, `05-reverse-list-telefon.txt`)
- İki APK, **aynı** `DEV_USER_ID=1111…1111`, farklı `SENKRON_SUNUCU_URL` (B `10.0.2.2`, A `127.0.0.1`)

## Adım adım ölçüm
| # | adım | kanıt | hüküm |
|---|---|---|---|
| ④a | B **çevrimdışı** (`svc wifi/data disable`) | `41-B-cevrimdisi.txt`: `nc: connect: Network is unreachable` ×3 | 🟢 **bayrakla değil PROBLA** ölçüldü |
| ④b | B'de `PROBE-B` tamamlandı | `43-B-sonra.txt`: `[X]` + rozet **"Çevrimdışısınız. Değişiklikler kaydedildi"** | 🟢 op kuyrukta |
| ⑤ | A çevrimiçi **iki dokunuş** (Tamamlandı → Açık) | `47-A-dokunus1b.txt` `[X]` · `48-A-dokunus2.txt` `[ ]` | 🟢 A'nın yazımı **HLC olarak SONRA** |
| ⑥a | B **çevrimiçi** | `49-B-cevrimici.txt`: 2. yoklamada `nc` **EXIT 0**, ~6 s | 🟢 ölçüldü |
| ⑥b | Bekleyen op varken tur ⇒ **ÇAKIŞMA** | `50-B-cakisma.txt`: satırda yeni düğme — **"Bu görev başka bir cihazda da değişti."** | 🟢 **ROZET ÇIKTI** |
| ⑥c | Ekran iki değeri gösteriyor | `52-cozum-sayfasi-TAM-METIN.txt`: `'Çakışma var'` · **`'Tamamlanma durumu\nBenimki\nTamamlandı\nOnlarınki\nAçık'`** | 🟢 `B` ↔ `A` görünür |
| ⑦a | *Benimkini tut* | `53-…`: sayfa **"Çakışan bir değişiklik bulunamadı."** (boş durumda **buton YOK**) | 🟢 kayıt kapandı |
| ⑦b | B'de kazanan **B'nin** değeri + projeksiyon | `54-B-liste-son.txt`: `[X]` + **"Gönderilmemiş değişiklik"** | 🟢 projeksiyon **yazıldı**, op kuyrukta |
| ⑦c | Kuyruk boşaldı | `58-B-yenile.txt`: `[X]`, **rozet YOK** | 🟢 sunucuya ulaştı |
| ⑦d | **A'ya ULAŞTI** | `59-A-SON-ULASTI.txt`: telefonda `PROBE-B` **`[X]`** | 🟢 **çift yön kapandı** |

## İki `clientId` ve HLC sırası (spec'in şartı — sunucu veritabanından ÖLÇÜLDÜ)
`63-db-clientid.txt` · `64-db-hlc.txt` (`processed_operations`):

| rol | `clientId` | op HLC | sunucuya varış |
|---|---|---|---|
| **A** (telefon) | `019fcc78-aa7b-7c74-aa33-fd37fc9aebdc` | `1785842888883.00000001` | 11:28:10 |
| **A** (telefon) | *aynı* | **`1785842911692.00000002`** | 11:28:32 |
| **B** (emülatör) | `019fcc71-8358-71ca-8b6e-e968848cf9dc` | **`1785842734501.00000001`** | **11:29:36** |
| **B** (emülatör) | *aynı* | `1785843026289.00000002` (*Benimkini tut*) | 11:32:26 |

🔴 **Kanıtın çekirdeği:** B'nin çevrimdışı yazımı **11:25:34'te ÜRETİLDİ** ama sunucuya
**11:29:36'da ULAŞTI** (4 dk sonra) ⇒ gerçekten kuyrukta bekledi. A'nın son yazımının HLC'si
(`…911692`) B'ninkinden (`…734501`) **BÜYÜK** ⇒ **A kazanan, B kaybeden** — uygulamanın ekranı da
bunu aynen söyledi (*Benimki = Tamamlandı* [B], *Onlarınki = Açık* [A]).

## Bu koşumun ürettiği ÖLÇÜM KUSURLARI (gizlenmiyor)
1. 🔴 **`toybox nc` probu ilk yazımında 40 s ASTI:** başarılı bağlantı `stdin`'i bekliyordu.
   `stdin=DEVNULL` ile onarıldı (`_net.py`). **Probun kusuru üründe değil ölçümdeydi.**
2. 🔴 **Dökümdeki satır sınırı DOKUNMA ALANI DEĞİLDİR:** `CheckBox` semantics düğümü satırın
   tamamını kaplıyor ama gerçek hit-test alanı **solda ~132 px**. Satır merkezine dokunmak
   *hiçbir şey yapmadı* ve ilk turda **"ısırmadı" sanılabilirdi** (oturum 55'in mutant dersinin
   UI'daki kardeşi). Sol kenara dokununca çalıştı.
3. 🟡 Telefon **kilitlendi** ve bir kez **yatay** döndü; `settings put system user_rotation 0` +
   `accelerometer_rotation 0` ile dikey sabitlendi. 🔴 **ESKİ DEĞER `accelerometer_rotation=1`
   İDİ — oturum sonunda GERİ ALINMALI.** `svc power stayon usb` de açıldı.
4. 🟡 Emülatörde **Pixel Launcher ANR** verdi (boş RAM **624 MiB**'a düşmüştü); kapatıldı,
   uygulama etkilenmedi.
5. 🟡 Kuyruk kendiliğinden boşalmadı; **Yenile** ile bir tur zorlandı. Bu bir **ürün kusuru
   iddiası DEĞİLDİR** — A11 kabulünde kuyruk 4 s'de boşalmıştı; burada ölçülen tek şey
   *"zorlanan turda boşaldı"*tır. Kendiliğinden boşalma süresi bu koşumda **ÖLÇÜLMEDİ**.
