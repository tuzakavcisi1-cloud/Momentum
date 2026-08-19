# arsiv/DURUM-arsiv-o85.md — DURUM.md'den taşınanlar (20 Ağu 2026, oturum 85)

Append-only. **Açılışta OKUNMAZ.** Yalnız *"bu karar neden alındı?"* diye sorulunca açılır.
Taşıma gerekçesi: `DURUM.md` 9.074 bayta çıkmıştı (bütçe 8 KB); DİLİM 2 kapanışı eklenirken
**kapanmış** maddeler buraya alındı, **canlı** olanların hepsi DURUM.md'de kaldı.

---

## 1. "Oturum 74–80" özet bloğu (DURUM.md'den kaldırıldı)

**Pinler:** takvim günü `DateTime.utc(y,m,d)`, tek nokta `GorevSatiri.takvimGunu`, `intl` **0.20.2** ·
`gorev_etiketleri` SALT-EKLEME, tombstone TELE ÇIKMAZ · doğal dil dört alan TEK `WireOp`+`transaction`,
ayrıştırıcı SAF · `arama_eslestirme.dart` SAF, katlama tablosu TEK KAYNAK.

**Paket:** `Dockerfile` + compose (postgres → ayrı migrator → api) + `paket.yml`; gerçek makinede
ölçüldü (17 Ağu): `crossOriginIsolated=true` · drift **opfsLocks** · çift yönlü senkron iki gerçek
istemcide. 708/708, `analyze` 0.

**Dersler:** kâğıt denetimi migration'ın v1 yolunu KOŞAMAZ · ortamı değil **DİKİŞİ** ölç ·
🔴 kör kapı: **dize değil VARLIK · sayı değil AD · ÜRÜN UCU**.
*(Son iki ders DURUM.md "Kalıcı dersler" başlığında YAŞAMAYA DEVAM EDİYOR.)*

## 2. DİLİM 1 — KİMLİK bloğu (kapandı 19 Ağu)

**`v1.0.1` teslim edildi (17 Ağu)** → `a332b25`, APK sha256 tuttu; kapılar `ci #70`=`39e0699` ·
`paket #9`·`pages #10`=`a332b25`. o82 README okuması: 7 bulgu düzeltildi.

🔴 **[Onur kilidi, 18 Ağu] BOŞLUKLAR KAPATILACAK.** ÖDEV kilidine göre teslim eksikti: §4(a)
parite **6/10** (liste · proje · tekrar · hatırlatıcı yok) · §4(b) taç mücevher **1/2** (işbirliği
vitrini yok) · §6.1 kimlik dilimi **teslim edilmedi**. Sıra **kimlik → liste(+proje klasörü) →
işbirliği → tekrar → hatırlatıcı**; liste, işbirliğinin **ön koşuludur** (ÖDEV §8(5)).

🔴 **[19 Ağu] DİLİM 1 KİMLİK BİTTİ.** Kapı beyanı, commit'le (cihaz Chrome): `ci #73` · `paket #11` ·
`pages #12` — **üçü de `aa04d04`** ve yeşil. Canlı izolasyon dört kontrolle ölçüldü (`KANIT/o83G`):
kendi görevini görüyor / ötekininkini görmüyor, **hiçbiri boş liste üstünde değil**.
`verify.ps1` EXIT 0 (142/142). Yol boyunca kapanan iki kusur: `SyncPuller` gölgelenmiş `ORDER BY`
(sessiz veri kaybı, `KANIT/o84`) ve `paket` AYAK 1'in bayat dize kontrolü.

## 3. Kapanmış "bilinen sınırlar" maddeleri

**md.26 [o78]** `dispose()` mutantı SAĞ KALIYOR (flutter_test leak-tracking kapalı) — kapsanmayan
sınıf, kapı yalanı değil. *(Bilgi olarak kalıyor; canlı bir kısıt değil.)*

**md.30 [o81 §5] — "üç kapı da son kodla koştu" beyanı TUTMADI** (cihaz Chrome, 17 Ağu):
`pages #8` = **o78 kodu** ⇒ canlı demo teslim edilen kod DEĞİLDİ. Kapı beyanı bundan sonra **commit
ile birlikte** yazılır. **[o84] `pages` push'ta KOŞMAZ — elle tetiklenir.**
*(Kural DURUM.md "Kalıcı dersler"e taşındı; o85'te sha `run kaydından` okunarak uygulandı.)*

**md.31 [o83-D/E/F + o84 · KAPANDI 18 Ağu] "flake" değildi:** `SyncPuller`de
`SELECT commit_xid::text … ORDER BY commit_xid` — cast'ın çıktı adı sütunu **gölgeliyordu** ⇒ sıra
METİN, `WHERE` SAYISAL; basamak sınırında satırlar **sessizce kayboluyordu** (canlı: 510'un 500'ü
teslim). `v1.0.1` bununla teslim edildi. Kanıt `KANIT/o84` + `KANIT/o83F`; `Cursor_correctness_…`
3/3 ⇒ ayrı flake YOK. **Ders: zamanlamaya benzeyen kusurdan önce `EXPLAIN Sort Key`'e bak.**
*(Ders DURUM.md "Kalıcı dersler"e taşındı.)*

## 4. CLAUDE.md'den sıkıştırılanlar (bilgi kaybı yok, yalnız kelime)

- §4/2 git yazma maddesinin uzun hâli: *"`git add -A` YASAK (başka elin **commit'lenmemiş** işini
  kör alır)"* · *"Mount'tan commit YASAK — **Desktop Commander ya da Claude Code'dan** yapılır"*.
- §4/3: *"`--platform chrome` **bu ortamda** sonuç üretmez."*
- §4/8: *"(sandbox silemez)"* gerekçesi.
- §5 [18 Ağu GERİ ALINDI] maddesinden *"proje"* kelimesi çıkarıldı — klasör o85'te **kesildi**,
  bu yüzden geri alınanlar listesinde durması yanıltıcıydı.

## 5. Oturum 85'te doğan iki komut tuzağı (CLAUDE.md §4/1'e tek cümle olarak girdi)

1. `git rev-parse --short A B` → **"Needed a single revision"**; `--short` **tek** revizyon alır.
2. `git status --porcelain=v2 --branch` (yolsuz) mount'ta **45 sn tavanını aştı** — mayın 1 zaten
   yazıyordu, dar yol verilmeden status koşulmaz. (O turda `index.lock` bırakmadı, yoklandı.)
