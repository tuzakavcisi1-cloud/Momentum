## 🔒 CHECKPOINT — K126 · **`GOREV-A13` KİLİTLENDİ** (Onur kilitledi, 3 Ağu 2026, oturum 52)

Onur üç kararı birlikte verdi: ① `A13` **KİLİTLE — Claude Code'a hazır** ② `BORCLAR.md` tavanı için
*"önerini uygula"* ⇒ **24 → 32 KB yükseltme** (gerekçe aşağıda, K40 şartıyla) ③ commit **kilitten
sonra, tek commit**.

**KİLİTLENEN ARTEFAKT:** `GOREV_CLAUDE_CODE/GOREV-A13-ios-iskeleti-ci.md` —
**20.940 b · `56871800`** · U+FFFD **0** · CRLF **0** (kimlik **son yazımdan SONRA** ölçüldü).
Bu andan sonra dosyanın **her değişen baytı kilidi bozar**; `tek-kopya-kapisi.py`'nin **`kilitli`**
sınıfına girer ve sapması **her açılışta** ölçülür.

**KİLİDİN DAYANDIĞI ÖLÇÜMLER (hepsi Cowork'ün kendi koşumu, K26):**
`spec-kapi-kapsama.py` altın küme **21/21** → spec **EXIT 0 / BULGU YOK** ·
`kapi-ad-teklik-kapisi.py` **YEŞİL** (`G27`–`G30` hiçbir spec'le çakışmıyor) ·
`tek-kopya-kapisi.py` **YEŞİL** · `sayi-tazeligi.py` **TEMİZ**.
Kapsam: **4 kapı** (`A13/G27`–`G30`) · **7 kural** (`D-A13-1`–`7`) · **8 mutant** (`M162`–`M169`) ·
**1 gerekçeli borç** (`D-A13-4`). *Koşan* mutant sınıfı **tam 3** ⇒ **K53/3 tavanı dolu**,
dördüncüsü açılamaz.

🔴 **KİLİDİN İÇİNDE BEYAN EDİLEN ÜÇ SINIR — kabul edilmiş, gizlenmemiş:**
① **iOS yalnız DERLENİR, ÇALIŞTIRILMAZ** — bu dilim *"iOS hedefi derleniyor"*u kanıtlar,
*"iOS destekleniyor"*u **kanıtlamaz** ② **backend `verify` CI'ya girmez** (`D-A13-4`) ⇒ CI yeşili
*"sistem çalışıyor"* **demez** ③ **`workflow` token yetkisi [DOĞRULANMADI]** — GitHub,
`.github/workflows/` ekleyen push'u yetki yoksa **reddeder**; `gh` token'ında yetki **yok**
(`gist, read:org, repo`), push ise **GCM** kullanıyor ve onun yetkisi ölçülemiyor. Patlarsa
çözüm **Onur'un** koşacağı `gh auth refresh -h github.com -s workflow`. **Bu bir ürün kusuru
değildir ve kabul kriterlerini düşürmez.**

## 🔓 `BORCLAR.md` TAVANI **24.576 → 32.768 B** (Onur, 3 Ağu 2026 — K117'nin ikinci gevşetmesi)

**Ölçülmüş gerekçe, K117'nin kendi dersinin doğrudan uygulanmasıdır.** K117 şunu yazmıştı:
*"bu dosyada budama ancak bir borç KAPANDIĞINDA işe yarar; anlatımı kısaltarak yer açma girişimi
ölçülerek başarısızdır"* (oturum 48: 2 kalem kapandı, 2 yeni doğdu, net **+258 b**).
Bugün ölçülen durum: `T2` **SARI**, 24.252/24.576, pay **324 b** (eşik 1.228) ve **kapanan borç
YOK** — `B-O51-1` açık, üstüne `B-O52-1` doğdu. ⇒ Budama bu turda **ölçülerek işe yaramaz**;
geriye kalan tek dürüst seçenek eşiktir.

🔴 **BEYAN EDİLMİŞ BEDEL: BU İKİNCİ GEVŞETMEDİR (16 → 24 → 32 KB).** Tavan artık `DURUM.md` ile
**eşit**; *"borç listesi canlı durumun yarısı kadar kalmalı"* tasarımı **ölmüştür** ve bu yazıya
geçirilmiştir. Karşılığında K40'ın şartı **ödendi**: `belge-tavan-kapisi.py`'nin altın kümesine
yeni tavanı **pinleyen** vaka eklendi (vaka **13**), küme **12/12 → 13/13**.
🔴 **Sınırı BEYAN EDEN her kopya aynı anda kapatıldı** (bu projede `kanonik-kopya` altı kez ısırdı):
araç kapsam tablosu · `DURUM.md` §5 K117 satırı. `PROJE_HAFIZA.md`'deki K117 metni append-only
olduğu için **dokunulmadı** — bu checkpoint onun **düzeltme notudur**.

## SIRADAKİ İŞ — DEĞİŞMEDİ

`A13` build'i **Claude Code'undur** (K34-f · rol bölümü). Cowork ortamı **kaldırmaz, ölçer**.
🔴 `A13` kabul edilene kadar `urun_kodu_satiri` **0'dır**; `R8` bu oturumda ısırmadı ama
**düşmedi de** — iskelet ve CI dosyası repoya girdiğinde düşer.
