## 🔒 CHECKPOINT — K122 · **OTURUM 51 AÇILIŞI: 10/10 ÖLÇÜLDÜ · `A12` TABANI ALINDI · SPEC'TE BAYAT SAYI BULUNDU** (3 Ağu 2026, oturum 51)

🔴 **Tarih cihazdan ÖLÇÜLDÜ: `2026-08-03 00:03 +03:00`.** Bulut aynı anda *"2 Ağu"* diyordu —
`ORTAM.md`'nin 00:00–03:00 penceresi bu checkpoint'te **fiilen** koştu ve yanlış tarih yazılmasını önledi.

**AÇILIŞ PROTOKOLÜ (§2, 10/10 — hepsi ölçüldü, hiçbiri varsayılmadı):**
`tek-kopya-kapisi` **YEŞİL/0** (11 dosya HEAD ile tutarlı) · `belge-tavan-kapisi` **YEŞİL/0**
(`DURUM.md` 30.452/32.768, pay %7,1) · `sayi-tazeligi` **TEMİZ/0** · `kapi-ad-teklik-kapisi` **YEŞİL/0** ·
`oturum-sagligi --altin-kume` **26/26 EXIT 0**, proje koşumu **SARI** (3 bayat defter kaydı + devir notu
kimlik bloğu **AYRIŞTIRILAMADI**) · `radar --altin-kume` **18/18 EXIT 0**, proje **KIRMIZI/17 artefakt**
(yapısal; **K83/DURDUR yürürlükte ⇒ dört-şık ritüeli TEKRARLANMADI**) · git: `fetch` **koştu**,
`25b1212`, **0 geri / 1 ileri**, `.git/index.lock` **YOK** · ortam: `momentum-postgres` **Up(healthy)** ·
`:5298` **LISTENING 18312** · `emulator-5554` **device**.
🟢 **Backend hazırlık ÜÇLÜSÜ geçti** (`_backend_dogrula.py`): `/health/live` **200** · `/health/ready`
**200** · `/v1/sync` **401 → 200**. Devir notunun *"backend ayakta"* iddiası bu kez doğru çıktı — ama
**PID okunarak değil, üç uç ölçülerek** doğrulandı (K80).
🟢 **`S4` = 162.603 token ⇒ YEŞİL.** Ölçüm **bulutta**, kendi oturum-id'siyle
(`/root/.claude/projects/-home-claude/05b5b288-db00-5029-8d2e-c0b804b48d16.jsonl`, aracın stage'lenmiş
kopyası **sha8 `7054DEB1`** ile disktekiyle **özdeş** doğrulandı — `device_stage_files` bayat kopya
sunmadı). **Payda yanlışlama testi koştu:** 162.603 < 1M ⇒ pencere varsayımı **ölü değil**, renk ilan
edilebilir.

**TEMİZLİK (Onur onayladı, geri alınabilir):** Claude Code'un 9 untracked artığı
(`.git-commit-msg-*.txt` · `_a11-*` · `_probe*`) `_SILINECEKLER\oturum-50-code-artiklari\` altına
**TAŞINDI**; kalıcı silme **YAPILMADI** (kırmızı çizgi 4 — silme Onur'un işidir). Köprü taşımaların
ortasında **bir kez düştü** (`device not connected`), tek dosya için tekrar denendi ve geçti —
`ORTAM.md`'nin köprü maddesi yine ısırdı.

**`A12` KABUL KRİTERİ 0 İÇİN BAĞIMSIZ TABAN ALINDI:**
`KANIT/A12/00-COWORK-TABAN-ONCESI.txt` **4.754 b / `AF42E7E7`** — 23 spec'in her biri için onarım
**ÖNCESİ** `KAPI/KURAL/MUTANT` envanteri ve bulguları. Üreteci: `KANIT/A12/_cowork_taban.py`.
Builder onarım sonrası aynı ölçümü **kendi** tekrarlayacak (spec §7/0: *"Cowork'ün ölçümüne
güvenilmez"*) — bu dosya **karşılaştırma referansıdır, kanıt yerine geçmez**.

🔴 **ÖLÇÜLEN SAPMA — `GOREV-A12`'nin §2 ve §9/1'inde yazan *"SEKİZ eski spec `[S0]` ile okunmuyor"*
BAYATTIR; ÖLÇÜLEN SAYI **10**.** Eksik sayılan ikisi: `GOREV-slice-3e-G12.md` ve
`GOREV-slice-3e-iskelet.md` (ikincisi `'## 5.' veya '## 6.' bölümü bulunamadı` ile, diğer dokuzu
`§5'te hiç '### G<n>' kapı başlığı yok` ile durdu). 🔴 **Birincisinin `[S0]` verdiği `CLAUDE.md`'nin
K81 maddesinde ZATEN YAZILIYDI** — yani sayı, kendi projesinin **yazılı kanıtıyla** çelişiyordu.
Spec sayısı da 22 → **23** (A12'nin kendisi eklendi; bu doğal ve kusur değil).

**Sınıf: `bayat-iddia`.** `sayi-tazeligi.py` bu sınıfın **yalnız bir alt kümesini** ölçer
(*"altın küme N/M"* kalıbı); *"sekiz eski spec"* **serbest metindir** ve hiçbir kapının kapsamında
değildir. Bu, K73'ün *"kural prozada değil kapıda yaşar"* doktrininin **henüz kapatılmamış** bir yüzeyi.

**NE YAPILDI / NE YAPILMADI (bilerek):**
- **Spec METNİNE DOKUNULMADI.** Gerekçe tembellik değil kural: radar **KIRMIZI** ⇒ yeni tur YASAK (K40),
  ve K53 kâğıt-denetim tavanı 1'dir. Bir sayıyı düzeltmek için spec'i açmak, kapanmış bir turu yeniden açar.
- Sapma builder'a **yazılı olarak** iletildi; spec §7/0 zaten *"kendin ölç"* diyor ⇒ mekanizma sağlam.
- 🔴 **BEYAN EDİLMİŞ BEDEL:** düzeltilmezse **bir sonraki el bu sayıya dayanır.** Bu satır, o elin
  uyarılmış olduğunun kaydıdır. Onur isterse tek satırlık düzeltme ayrı bir tur olarak açılabilir.

**KİLİT DEĞİŞMEDİ.** `GOREV-A12` build'i **Claude Code'a devredildi** (K34-f: aracı **yazan** elden
**ayrı** el), kabul kriterlerini **Cowork** koşacak (K26: üreten ≠ denetleyen). Cihaz/backend
**gerekmez**; ortam kaldırılmadı, yalnız **ölçüldü**.

🔴 **AÇIK KALAN, BU OTURUMDA KAPANMAYAN:** `A12` **ürün kodu değildir** — `R8` sayacını **düşürmez**.
Radar şu an `R8` vermiyor, ama A12'den sonra bir oturum daha araç/belge işi olursa **sert durak yanar**
ve o oturum ürün koduyla başlamak **zorundadır** (K53/4).
