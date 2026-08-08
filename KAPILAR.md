# KAPILAR.md — Momentum · KAPI-TETİK TABLOSU

> 🔴 **AÇILIŞTA OKUNMAZ.** Açılış protokolü **`DURUM.md` + `CLAUDE.md`** ile sınırlıdır (K53/K83);
> burası yalnız *"bu kapı hangi olayda koşar?"* diye sorulduğunda açılır. `DURUM.md` §2 buraya
> tek satırlık tetik referansıyla bağlanır. Yerleşim kararı **Onur'un** (oturum 42, şık **B**);
> gerekçe: A şıkkı `DURUM.md`'yi 25.092 → 28.799 b yapıp payı **yarılıyordu** ⇒ K58'in R4 frenine ters.
> **TAVAN: ≤ 16.384 b** — `belge-tavan-kapisi.py` kapsamına oturum 42'de **eklendi**.
> Gerekçe ve kilit: `PROJE_HAFIZA.md` **K89**. Tablo içeriği **oturum 41'de** ölçüldü ve orada kilitlendi.

---

## KAPI-TETİK TABLOSU (mekanikleştirme — oturum 41)

**Ne:** Her kapının HANGİ OLAYDA ve HANGİ ORTAMDA koşacağını tek yerde beyan eder.

**Neden mekanikleştirme (yeni tur/keşif DEĞİL):** "çağrılmayan/geç-çağrılan kapı" sınıfı bu turda birkaç kez ısırdı — ① `sayi-tazeligi.py` protokolde yokken elle koşulup KIRMIZI verdi (oturum 39); ② `design-token-kapisi.py` açılış hükümleri arasında beklenirken DURUM §2'nin numaralı listesinde YOK; ③ bataryayı sandbox'ta koşmak `tek-kopya-mutant`/`sayi-tazeligi`'de SAHTE SARI üretti — ortam hücresi hiçbir yerde beyan edilmemişti. Bu sınıf **koşan kod OLMADAN ölçülebilir** (bir kapının doğru olay+ortamda çağrılıp çağrılmadığı statik/mekanik bir sorudur) ⇒ radar KIRMIZI'da MEKANİKLEŞTİR şıkı geçerlidir (K53/2, ispat yükü karşılandı).

🔴 **BEYAN EDİLMİŞ ZAYIF KONTROL:** bu tablo bilgiyi mekanikleştirir; onu ZORLAYAN bir kapı henüz YOK. DURUM.md bayt-tavanı gibi (K58): sınıf tabloya rağmen tekrar ısırdığında `kapi-tetik-kapisi.py` yazılır. Şimdi araç yazılmadı çünkü radar KIRMIZI + koşan-uygulama mutant tavanı; tablo, sınıfı kapatan en ucuz mekanik adımdır.

**Kaynak:** olay eşlemesi DURUM §2 + CLAUDE.md (İş akışı / Hafıza kuralı / Git / K21 / K40)'tan OKUNDU; ortam eşlemesi oturum 41 ölçümleri (✓✓ = hem sandbox hem Windows koşuldu) + §7 kanlı uyarılardan.

| kapı | olay(lar) [kaynak] | ortam | ölçüm dayanağı |
|---|---|---|---|
| `tek-kopya-kapisi.py` | Açılış [§2/2]; commit-öncesi [ÖNERİ] | her ikisi | ✓✓ YEŞİL / YEŞİL |
| `belge-tavan-kapisi.py` | Açılış [§2/3]; checkpoint-öncesi [Hafıza k.] | her ikisi | ✓✓ YEŞİL / YEŞİL |
| `sayi-tazeligi.py` | Açılış [§2/4]; checkpoint [sayaç dokunur] | **Windows/DC** | ✓✓ sandbox SAHTE-SARI, Windows TEMİZ |
| `oturum-sagligi.py` | Açılış [§2/5 golden + §2/8 token]; checkpoint [K21] | golden: her ikisi · token: transcript-erişimli ortam | ✓✓ golden 26/26; S4 bu tur sandbox'tan ERİŞİLEMEDİ |
| `radar.py` | Açılış [§2/6, K40]; HER checkpoint [K40 + jsonl 1 satır] | her ikisi | ✓✓ KIRMIZI / KIRMIZI |
| `design-token-kapisi.py` | Build-verify/dilim-kapanışı [İş akışı]; açılış-nöbetçi [handoff hüküm, §2'de numaralı DEĞİL] | her ikisi | ✓✓ EXIT0 / EXIT0 |
| `hafiza-dizin.py` | Checkpoint: PROJE_HAFIZA'ya yeni kayıt SONRASI | **Windows/DC** | §7 ölçüldü: sandbox mount `.yedek` unlink FAIL ⇒ exit 1 |
| `dosya-kimlik.py` | Checkpoint / HER tek-kopya yazımından SONRA | her ikisi | ✓✓ bayt/sha özdeş (DURUM 25092/3873FBA1) |
| `tek-kopya-mutant.py` | Dilim-kapanışı: `tek-kopya-kapisi` değişince [§9] | **Windows/DC** | 🔴 **10/11** — `M2b` ÖLÜ KURGU; *"Windows 11/11"* varsayımı o64'te ÇÜRÜTÜLDÜ (`B-O64-1`) |
| `verify.ps1` | Build-verify [İş akışı: backend build+test+CVE] | **Windows/DC** | .ps1 + flutter/dotnet zinciri; doğası gereği |
| `spec-kapi-kapsama.py` | Dilim-kapanışı: GOREV spec kilidi [K81] | her ikisi [çıkarım] | bu tur KOŞULMADI |
| G-serisi build-verify: `iddia-kapisi` · `yoklama-yasagi-kapisi` · `pub-cve-kapisi` · `pub-lisans-kapisi` | Build-verify/dilim-kapanışı [İş akışı + Denetçi kapıları] | çoğu her ikisi; `pub-*` **ağ ister** | bu tur KOŞULMADI (ana koşum Claude Code build'inde) |
| Uzman ajanlar + red-team EN SON | Kilit / dilim-kapanışı [Denetçi kapıları] | Cowork orkestrasyon | — |

**Ortam kısaltması:** "her ikisi" = sandbox (Cowork Linux) VE Windows/DC'de aynı hüküm ÖLÇÜLDÜ; "**Windows/DC**" = sandbox'ta güvenilmez (satır-sonu / `unlink` / PowerShell farkı) ⇒ YALNIZ Windows/DC'de koş.

**Envanter (oturum 42'de yeniden sayıldı):** `araclar\` altında **20** dosya var (19 `.py` + `verify.ps1`). Yukarıdaki 8 çekirdek + `tek-kopya-mutant` + `verify.ps1` + `spec-kapi-kapsama` + G-serisi 4 = **15 olay-tetikli**; ayrıca `adr-kapi-taramasi` (dondurulmuş, koşmaz — K41) + 4 olay-bağımsız yardımcı (`lisans-yokla`, `pub-surum-olc`, `mcp-arac-probe`, `web-varlik-indir`).

---

## OTURUM 42 DOĞRULAMASI (Windows/DC — 30 Tem 2026)

Tablo yazılırken şu kapılar **yeniden koşuldu** ve hüküm tuttu: `tek-kopya` **YEŞİL** · `belge-tavan` **YEŞİL** · `sayi-tazeligi` **TEMİZ** · `oturum-sagligi --altin-kume` **26/26 EXIT 0** ve `oturum-sagligi .` **KANONİK+D1 SARI / S4 OLCULMEDI** · `radar --altin-kume` **18/18 EXIT 0** ve `radar .` **KIRMIZI** (yapısal; 🔒 K83/DURDUR yürürlükte) · `design-token-kapisi` **EXIT 0**.

🔴 **BEYAN EDİLMİŞ SINIR:** oturum 42'de **yalnız Windows/DC ayağı** koşuldu. Tablodaki `✓✓` işaretleri **oturum 41'in** kanıtıdır ve bu oturumda yeniden üretilmemiştir; sandbox ayağının bugünkü hâli **[DOĞRULANMADI]**.
