# W1 SPEC — BAĞIMSIZ DENETİM · MERCEK: **KOŞULABİLİRLİK**

> **Denetlenen:** `GOREV_CLAUDE_CODE\GOREV-W1-web-yuruyen-iskelet.md` (19.941 b, HENÜZ KİLİTLİ DEĞİL)
> **Denetçi:** bağımsız ajan — spec'i yazan el (Cowork oturum 57) DEĞİL. `K127` gereği **kilitten ÖNCE**.
> **Tarih:** 4 Ağu 2026 · **Ham ölçüm betikleri:** `KANIT\W1\_denetim_olcum.py` … `_denetim_olcum5.py`
> **Tek soru:** *"bu adım, `## 4b`'deki ortam kalkınca FİİLEN yapılabiliyor mu?"* (`SS2` oturum 56
> kusur sınıfı: **KOŞULAMAZ KABUL ŞARTI**)

**HÜKÜM: 3 BLOKER · 7 MAJOR · 5 MINOR ⇒ BU HÂLİYLE KİLİTLENMEMELİ.**

---

## 0. ÖNCE: SPEC'İN DOĞRU ÇIKAN TARAFI (körü körüne kötülemiyorum)

`## 2. ÖLÇÜLMÜŞ TABAN` tablosunun **yedi satırının yedisini de kendim ölçtüm; hepsi DOĞRU:**

| taban iddiası | benim ölçümüm | hüküm |
|---|---|---|
| `main.dart.js` **2.769.788 b**, mtime **15:38** | `2769788 b  2026-08-04 15:38:03` (`_denetim_olcum.py` §2) | ✅ **BİREBİR** |
| Drift web bağlantısı TAM BAĞLI | `veritabani.dart:174` `web: DriftWebOptions(` · `:180 onResult: (sonuc) {` | ✅ |
| ölçüm kancası `MOMENTUM-G6-KANIT` basıyor | `veritabani.dart:183` `'MOMENTUM-G6-KANIT chosenImplementation=${sonuc.chosenImplementation} '` | ✅ |
| `web/sqlite3.wasm` · `web/drift_worker.js` yerinde | `748.424 b` / `351.218 b`, ikisi de VAR | ✅ |
| `kIsWeb` **yalnız 2**, ikisi de `ag/signalr_json_sinyal.dart` | `:5 import ... show kIsWeb;` · `:102 if (kIsWeb) {` | ✅ (ama bkz. **MAJOR-1**) |
| **92 backend dosyasının HİÇBİRİNDE** CORS yok, pozitif kontrol geçti | `_o57_cors.py` yeniden koştu: `taranan backend dosyasi: 92` · `AddCors YOK` · `UseCors YOK` · `WithOrigins YOK` · `AllowAnyOrigin YOK` · `'builder.Services' gecen dosya: 1 / 92` | ✅ **BİREBİR** |
| `_senkronSunucuUrl` = `http://10.0.2.2:5298`, `String.fromEnvironment` ile ezilebilir | `main.dart:22-25` `const String _senkronSunucuUrl = String.fromEnvironment('SENKRON_SUNUCU_URL', defaultValue: 'http://10.0.2.2:5298',);` | ✅ |

**Ve `SS2`'nin kusuru bu spec'te TEKRARLANMIYOR** — kabul kriterlerinin varsaydığı iki UI etkileşimi
üründe **GERÇEKTEN VAR** (bunu özellikle aradım):

- *"Görev eklenir"* → `gorev_listesi_ekrani.dart:132-136`
  `GorevEkleAlani(onEkle: (baslik) => unawaited(_yerelYaz(() => widget.depo.ekle(baslik)),),)` — **VAR**
- *"**Yenile**"* → `gorev_listesi_ekrani.dart:82-88`
  `IconButton(key: const ValueKey('elle_yenile_dugmesi'), icon: const Icon(Icons.refresh), tooltip: 'Yenile', onPressed: () => widget.onYenile!(),)` — **VAR**, ve üretim yolunda
  `main.dart:77` `onYenile: dongu == null ? null : () => elleYenile(dongu!)` ile **null DEĞİL**.

**Ortam da fiilen ayakta/kaldırılabilir:**
`docker ps` ⇒ `momentum-postgres | Up 6 hours (healthy)` · `flutter devices` ⇒
`Chrome (web) • chrome • web-javascript • Google Chrome 150.0.7871.187` · `netstat` ⇒ `:5000` **boş**,
`:5298` **boş** · `KANIT/A11/_backend_dogrula.py` (2.100 b) ve `KANIT/A11/_mutant_kosucu.py` (10.415 b)
**GERÇEKTEN VAR** — spec'in bu iki atfı **sarkan değil**. `spec-kapi-kapsama.py` (kriter 5) kendi
koşumumda **EXIT 0** verdi. `kapi-ad-teklik-kapisi.py` **YEŞİL** (G35–G38 çakışmıyor).
`radar.py --olc-urun-kodu GIT_REF` bayrağı **var** (kriter 10 koşulabilir).

Bunlar spec'in gövdesinin sağlam olduğunu gösteriyor. Aşağıdakiler o gövdedeki deliklerdir.

---

## 1. BLOKER

### 🔴 BLOKER-1 — `G36`'NIN ÜÇ AYAĞININ ÜÇÜ DE TARAYICININ **GERÇEK** PREFLIGHT'INI TAKLİT ETMİYOR: `Content-Type` YOK ⇒ KAPI YEŞİL, ÜRÜN ÖLÜ

**Nerede:** `## 5. KAPILAR` → `G36/a`; `## 5` → `G35/d`; `## 6` → `M192`
**GÜVEN: KESİN** (kod okumasıyla; canlı koşum yapılmadı — bkz. §4)

Spec'in `G36/a` ayağı, preflight probunu **birebir** şöyle tarif ediyor:

> **a)** *(pozitif)* `OPTIONS /v1/sync` · `Origin: http://localhost:5000` ·
> `Access-Control-Request-Method: POST` · `Access-Control-Request-Headers: x-momentum-dev-user`
> ⇒ **2xx** **ve** yanıtta `Access-Control-Allow-Origin: http://localhost:5000` (🔴 **`*` DEĞİL**)
> **ve** `Access-Control-Allow-Headers` içinde `x-momentum-dev-user`.

Ürünün **gerçekte gönderdiği** başlıklar ise `src\client\lib\ag\http_senkron_agi.dart:30-36`:

```dart
      final yanit = await _istemci
          .post(
            senkronUcNoktasi,
            headers: {
              'Content-Type': 'application/json',
              _devKullaniciBasligi: actorId,
            },
```

`Content-Type: application/json` **CORS-safelisted DEĞİLDİR** (Fetch Standard'ın güvenli listesi yalnız
`application/x-www-form-urlencoded`, `multipart/form-data`, `text/plain` değerlerini kapsar). Yani
Chrome'un bu POST için attığı preflight'ın `Access-Control-Request-Headers` değeri
**`content-type,x-momentum-dev-user`** olur — spec'in probunun gönderdiği tek başlık değil.

Ve spec, uygulamayı **`content-type`'ı ASLA izin listesine yazmayacak** bir şekle itiyor:

> **d)** İzinli başlıklar arasında `X-Momentum-Dev-User` **adıyla** geçer. 🔴 Yalnız
> `AllowAnyHeader()` **YETMEZ**

> | M192 | statik | `W1/G35/d` | `WithHeaders("X-Momentum-Dev-User")` → yalnız `AllowAnyHeader()` | `cors-kapisi.py` **KIRMIZI** |

🔴 **Ölçüm:** spec metninde `Content-Type` **x0**, `content-type` **x0** (`_denetim_olcum5.py` §4).
Kelime spec'te **HİÇ GEÇMİYOR**.

**Başarısızlık senaryosu (somut):** Claude Code `WithOrigins("http://localhost:5000")
.WithHeaders("X-Momentum-Dev-User").WithMethods("POST")` yazar.
① `G35/a,b,c,d` **YEŞİL** (statik metin hepsini içeriyor). ② `G36/a` **YEŞİL** — prob yalnız
`x-momentum-dev-user` istediği için ACAH tam olarak onu döner. ③ `G36/b` **YEŞİL** (evil.local reddedilir).
④ `G36/c` **YEŞİL** — çünkü **ham POST bir tarayıcı değildir, preflight HİÇ ATMAZ**; ACAO döner, 200 döner.
⑤ Tarayıcıda `G37`/`G38`: Chrome preflight'ında `content-type` ister, izin listesinde yoktur, isteği
**bloklar** ⇒ `G38/a` psql sayımı artmaz, `G38/b` inmez. **Dört kapının üçü yeşil, ürün ölü** — ve
spec'in `## 1. AMAÇ`'ı *"tek ölçülmüş bloker CORS'un hiç olmamasıdır"* dediği için kusur **CORS'ta
aranmaz**, Drift'e / porta / dart-define'a yazılır.

Bu tam olarak **kör kapı**dır ve spec'in kendi `## 8/7` maddesinin denetçiye sorduğu sorunun cevabıdır:
`G36`'nın hiçbir ayağı *"tarayıcının FİİLEN attığı istek"*i ölçmüyor.

**Kapanış yolu (öneri, kilit Onur'da):** ① `G35/d`'yi *"izinli başlıklar `X-Momentum-Dev-User` **VE**
`Content-Type` adıyla geçer"* diye genişlet; ② `G36/a`'nın probunu
`Access-Control-Request-Headers: content-type,x-momentum-dev-user` yap ve ACAH'ın **ikisini de**
içerdiğini ölç; ③ `M192`'nin yanına `M192b` ekle: *"`Content-Type` izin listesinden çıkarılır"* ⇒
`_preflight.py` **KIRMIZI** (statik değil **koşan** olmak zorunda değil — `cors-kapisi.py` de ısırabilir).

---

### 🔴 BLOKER-2 — `G38/b` (ve `G38/a`'nın "başlık birebir" ayağı) `## 4b`'DEKİ KOMUTLA **KOŞULAMAZ**: TARAYICININ `devUserId`'Sİ RASTGELE ÜRETİLİR VE HİÇBİR YERE BASILMAZ

**Nerede:** `## 4b` ③ · `## 5` → `G38/a`, `G38/b` · `## 6` → `M197`
**GÜVEN: KESİN**

`## 4b` ③ tarayıcıyı şu komutla kaldırıyor:

> ③ Tarayıcı: `flutter run -d chrome --web-port=5000 --dart-define=SENKRON_SUNUCU_URL=http://localhost:5298`

Bu komutta **`--dart-define=DEV_USER_ID=<GUID>` YOKTUR.** Ölçüm: spec metninde `DEV_USER_ID` **x0**,
`devUserId` **x0**, `owner_id` **x0** (`_denetim_olcum5.py` §4).

Sonuç zinciri (hepsi ölçüldü):

1. `main.dart:31` `const String devUserIdEzmesi = String.fromEnvironment('DEV_USER_ID');` — define
   verilmezse **boş dize**.
2. `ayarlari_hazirla.dart:22-23`: `final ayarlar = await deposu.yukleVeyaOlustur(); if (ezme.isEmpty || ezme == ayarlar.devUserId) return ayarlar;` — ezme boşsa **depodan gelen (yeni kurulumda RASTGELE üretilmiş)** `devUserId` kullanılır. `main.dart:30` yorumu bunu zaten yazıyor:
   *"`DEV_USER_ID` ezmesi -- iki cihazi ayni kullanici yapmanin yolu (**bugune kadar `devUserId` her kurulumda rastgeleydi**)"*.
3. Tarayıcı ilk kez açıldığında OPFS deposu **boştur** ⇒ taze, **kimsenin bilmediği** bir GUID.
4. İstemci bu GUID'i **HİÇBİR YERE BASMIYOR**. Ölçüm: `lib/` içindeki **tüm** `print(` satırları
   **ikidir** (`_denetim_olcum5.py` §2):
   `ag\signalr_json_sinyal.dart:90  print('[sinyal] $mesaj');` ve
   `veri\veritabani.dart:182  print(` (MOMENTUM-G6-KANIT). **`devUserId` konsola çıkmaz.**
5. Sunucu tarafı **sahip-kapsamlıdır**. Canlı DB'den ölçüldü:
   ```
   Table "public.tasks"
    entity_id | uuid | not null
    owner_id  | uuid | not null
   Indexes: "ix_tasks_owner_deleted_listpos_entity" btree (owner_id, is_deleted, list_pos, entity_id)
   ```
   ve tabloda **zaten `179` satır**, `select distinct owner_id` **onlarca farklı sahip** döndürüyor.

**Başarısızlık senaryosu:** `G38/b` — *"Sunucuda üretilen bir değişiklik (doğrudan `POST /v1/sync` ile)
web'de **Yenile** sonrası **iner**"* — o POST'un `X-Momentum-Dev-User` başlığına **hangi GUID'i**
yazacağını bilen kimse yoktur. Rastgele/sabit bir GUID yazılırsa satır **başka bir sahibe** düşer,
tarayıcı **hiçbir zaman görmez**, ve ayak *"web senkronu çalışmıyor"* diye **YANLIŞ KIRMIZI** verir.
Aynı şekilde `G38/a`'nın *"satır sayılır"* ayağı 179 satırlık, çok-sahipli bir tabloya karşı
sahip filtresi olmadan koşarsa `M197`'nin *"sayım artmaz"* beklentisi gürültüye gömülür.

`A10/Y3` bu tuzağı **zaten çözmüş** ve `main.dart`'a bir bayrak koymuştu; `## 4b` o bayrağı kullanmıyor.

**Kapanış yolu:** `## 4b` ③'e `--dart-define=DEV_USER_ID=<sabit GUID>` ekle (K-red-line: kod'a gömme,
komut satırında ver) ve `G38/a`/`G38/b`'nin psql/POST adımlarını **o GUID'e** bağla.

---

### 🔴 BLOKER-3 — KOŞAN MUTANTLARI, ORTAM YENİDEN BAŞLATMALARINI, **F5**'İ VE **EKRAN GÖRÜNTÜSÜNÜ** KİM KOŞACAK BELİRSİZ — VE `K80` İLE DOĞRUDAN ÇELİŞİYOR

**Nerede:** `## 7` başlığı + kriter 6/7/9 · `## 4b` · `## 5` → `G37/a,b,c` · `## 6` → `M195`, `M196`, `M197`
**GÜVEN: KESİN** (belge çelişkisi) / **ÖLÇÜLEMEDİ** (flutter'ın F5 davranışı)

Spec `## 7`'nin başlığı: *"**KABUL KRİTERLERİ (hepsi Cowork'ün KENDİ koşumuyla — `K26`)**"*.
Kriter 7: *"**Üç koşan mutantın üçü de ısırır**"*. Mutantlar:

> | M195 | **koşan** | … | CORS politikası kaldırılır, backend **yeniden başlatılır** |
> | M196 | **koşan** | … | İzinli origin `http://localhost:5001` yapılır, backend yeniden başlatılır |
> | M197 | **koşan** | … | `--dart-define=SENKRON_SUNUCU_URL` **kaldırılır** |

`M197`'nin geri alınması `flutter run`'ın **yeniden başlatılmasıdır** (dart-define derleme zamanıdır).
Yani kabul turu **en az 6 backend yeniden başlatma + 2 tarayıcı yeniden başlatma** ister.

Ama `CLAUDE.md` `K80` ve `ORTAM.md` **PAZARLIKSIZ** olarak şunu diyor:

> **Cowork ortamı KALDIRMAZ, DOĞRULAR.** … Cowork yalnız **ölçer** ve sonucu raporlar. *(CLAUDE.md, K80)*

> 🔴 **Kapatmayı Cowork YALNIZ Onur'un açık izniyle yapar; YENİDEN BAŞLATMAZ (K80 ayakta).** *(ORTAM.md)*

Spec `## 4b` ortamı **Claude Code**'a veriyor (*"Ortamı Claude Code kaldırır"*), `## 7` kabulü
**Cowork**'e veriyor. **Koşan mutantların ve ortam yeniden başlatmalarının eli HİÇBİR YERDE
YAZMIYOR.** Aynı boşluk `G37`'nin üç ayağında daha keskin:

> **a)** … konsolda `MOMENTUM-G6-KANIT …` satırı **birebir** yakalanır …
> **b)** Görev eklenir → **sayfa yenilenir (F5)** → görev **hâlâ listededir**. *Ölçüm:* … + **ekran görüntüsü** …

`## 4b` ③ *"Konsol satırları **yakalanır**, ekrandan okunmaz"* diyor ama **hangi araçla** olduğunu
yazmıyor. Karşılaştır: `G36` için `## 4` T3 açıkça bir artefakt tanımlıyor
(*"`KANIT/W1/_preflight.py` — `G36`'nın üç ayağını ölçer"*). `G37`/`G38` için T5 yalnız
*"ölçümü, ham çıktılar `KANIT/W1/`'e"* diyor — **artefakt YOK, komut YOK, el YOK.**

Ve Claude Code'un elinde tarayıcı/klavye kontrolü **yok**: `C:\dev\Momentum\.mcp.json` **tek** sunucu
tanımlıyor —
```json
{ "mcpServers": { "dart": { "type": "stdio", "command": "dart",
    "args": ["pub","global","run","dart_mcp_server"], "env": {} } } }
```
Ekran görüntüsü alan, F5'e basan hiçbir araç yok. (Cowork'ün `computer_*` araçları var ama `K80` ona
ortamı kaldırmayı yasaklıyor — kilidi Onur'un vermesi gerekir.)

**Başarısızlık senaryosu:** Kilit sonrası Claude Code `## 4b`'yi koşar, backend + Chrome ayağa kalkar,
sonra `G37/b` için **F5'e basacak kimse olmaz**; `M195`–`M197` için **backend'i yeniden başlatacak
yetkili el olmaz**. Kabul turu ortada durur ve/veya `K80` sessizce çiğnenir.

**Kapanış yolu:** `## 4b`'ye dördüncü madde ekle — *"koşan mutant turunu ve `flutter run` yeniden
başlatmalarını **Claude Code** koşar; Cowork yalnız ham çıktıyı **doğrular**"* — ve `G37` için bir
artefakt adı ver (ör. `KANIT/W1/_web_konsol.py`: `flutter run`'ı alt süreçte başlatıp stdout'u
**tavanlı yoklamayla** dosyaya yazar; F5 yerine **CDP** ile `Page.reload` çağırır, ekran görüntüsünü
`Page.captureScreenshot` ile alır — böylece "el" gerekmez).

---

## 2. MAJOR

### 🟠 MAJOR-1 — `M194` KÖR OLABİLİR: `kIsWeb` DOSYADA **İKİ** YERDE GEÇİYOR, BİRİ `import` SATIRI

**Nerede:** `## 5` → `G38/c` · `## 6` → `M194` · `## 2` taban tablosu
**GÜVEN: KESİN**

> | M194 | statik | `W1/G38/c` | `signalr_json_sinyal.dart`'taki `if (kIsWeb)` dalı **silinir** | `cors-kapisi.py` **KIRMIZI** |

Ölçüm (`_denetim_olcum.py` §1) — dosyada `kIsWeb` geçen **tüm** satırlar:

```
ag\signalr_json_sinyal.dart  :5    import 'package:flutter/foundation.dart' show kIsWeb;
ag\signalr_json_sinyal.dart  :102  if (kIsWeb) {
```

`cors-kapisi.py` `G38/c`'yi **`kIsWeb` dizgesini arayarak** ölçerse, `:102` silindiğinde `:5` **yerinde
kalır** ⇒ kapı **YEŞİL** döner, `M194` **ısırmaz** — yani `G38/c` kör kalır ve bunu hiçbir şey ölçmez.
Spec `G38/c`'yi *"`if (kIsWeb)` dalı **durur**"* diye yazıyor ama kapının **hangi dizgeyi** araması
gerektiğini (`if (kIsWeb)`, sadece `kIsWeb` değil) **yazmıyor**.

`## 2` taban satırı (*"`kIsWeb` … yalnız **2**"*) sayısal olarak doğru ama **yanıltıcı**: gerçek
dal **BİR** tanedir; ikincisi import'tur.

**Kapanış:** `G38/c`'yi *"`if (kIsWeb)` **alt dizgesi** kod satırında geçer"* diye yaz; `M194`'ün
yanına `M194b` ekle — *"yalnız `import ... show kIsWeb;` bırakılır, dal silinir"* ⇒ **KIRMIZI**.

---

### 🟠 MAJOR-2 — `/* */` BLOK YORUM YOLU **MUTANTSIZ**: `K135`'İN ÖLÇÜLMÜŞ KUSURU TAM DA BLOK YOLDU

**Nerede:** `## 5` → `G35` giriş cümlesi ve `G37/d` · `## 6` → `M193`, `M193b`, `M198b`
**GÜVEN: KESİN**

`G35`'in giriş cümlesi:

> Dört ayak da `araclar/cors-kapisi.py` ile **kod satırında** ölçülür — 🔴 `//` **ve** `/* */`
> yorumları **atılarak** (`K135`: `ss2-kapisi.py`'nin blok yorum kör kapısı bu projede **ısırdı**…)

`G37/d` aynı cümleyi tekrarlıyor. Ama yorum-atlamayı ölçen **üç mutantın üçü de `//` satır yorumudur:**

> | M193 | … doğru satır **yalnız yorumda** bırakılır (`// app.UseCors(...)`) |
> | M193b | … dosyaya yalnız **fazladan yorum** eklenir (`// app.UseCors(...)`) |
> | M198b | … önek **yalnız yorumda** bırakılır (`// MOMENTUM-G6-KANIT`) |

`/* ... */` ile yazılmış **tek bir mutant yok.** Oysa `K135`'in doğduğu ölçüm (`ss2-kapisi.py`
docstring'i, `araclar\ss2-kapisi.py:20-25`) tam olarak blok yolu işaret ediyor:

> 🔴 **BLOK YORUM (`/* ... */`) DA ATILIR [oturum 56'da ONARILDI -- ONCESINDE KOR
> KAPIYDI].** Olculmus gerekce (`KANIT/o56/14-g33c-yorum-olcumu.txt`): gercek kod
> `schemaVersion => 4` iken dogru deger YALNIZ blok yorumda birakilinca arac
> YANLIS SUSUYORDU (vaka D) … **`//` ayagi (M171b/M171c) blok yolunu GORMUYORDU.**

Yani `ss2-kapisi.py`'de `//` mutantlarının blok yolunu **görmediği ölçülmüştür** — ve W1 aynı hatayı
tekrarlıyor: `//` mutantı yazıp blok yolu iddia ediyor. `spec-kapi-kapsama.py` bunu **yakalayamaz**
(yalnız kapı düzeyinde kapsama ölçer; kendi beyan edilmiş sınırı: *"bu betik mutantin GERCEKTEN
ISIRDIGINI olcmez"*). `## 6b`'de de beyan edilmiş bir borç **yok**.

**Kapanış:** `M193c` ekle — gerçek `app.UseCors(...)` silinir, doğru satır **`/* app.UseCors(...) */`**
içinde bırakılır ⇒ **KIRMIZI**; ve `M193d` yanlış-pozitif kontrolü (yalnız fazladan blok yorum eklenir)
⇒ **SUSMALI**. Statik sınıf **tavansızdır** (`K53/3`), bedel saniyelerdir.

---

### 🟠 MAJOR-3 — `D-W1-1` + `D-W1-2` BİRLİKTE **KAYITSIZ POLİTİKA** İSTİSNASI ÜRETEBİLİR VE KRİTER 1'İ DÜŞÜREBİLİR (`dotnet test` API'yi **Development**'ta ayağa kaldırıyor)

**Nerede:** `## 3` → `D-W1-1`, `D-W1-2` · `## 7` kriter 1
**GÜVEN: KESİN** (test yüzeyi ölçüldü) / **ZAYIF** (istisnanın fiilen atılacağı — koşulmadı)

> **`D-W1-1`** … liste boşsa politika **hiç kaydedilmez**.
> **`D-W1-2`** … `builder.Services.AddCors(...)` **ve** `app.UseCors(...)` **ikisi de**
> `IsDevelopment()` koşulunun **içindedir**.

Bu iki cümle birlikte okunduğunda **`UseCors` yalnız `IsDevelopment()`'a**, `AddCors` ise
**`IsDevelopment()` + liste-boş-değil**'e bağlanır. O hâlde liste boşken `app.UseCors("<ad>")`
**kayıtlı olmayan bir politikaya** işaret eder ve ASP.NET Core ilk istekte
`InvalidOperationException: The CORS policy '<ad>' was not found` fırlatır.

Bunun **teorik olmadığını** ölçtüm: kriter 1'in koştuğu `verify.ps1` → `dotnet test Momentum.sln`,
ve testler API'yi **Development** ortamında ayağa kaldırıyor:

```
tests\Momentum.Api.Tests\DevKimlikKapisiTestleri.cs:  await using var uygulama = new WebApplicationFactory<Program>()
tests\Momentum.Api.Tests\DevKimlikKapisiTestleri.cs:      .WithWebHostBuilder(b => b.UseEnvironment("Development"));
tests\Momentum.Persistence.Tests\DevKimlikKapisi200Testleri.cs:  ... b.UseEnvironment("Development");
tests\Momentum.Api.Tests\HubRejectionTests.cs:        await using var factory = new WebApplicationFactory<Program>();
```
(`WebApplicationFactory<Program>` varsayılanı da **Development**'tır.)

Ayrıca `appsettings.Development.json` **BUGÜN YOK** (ölçüldü: `YOK src/backend/Momentum.Api/appsettings.Development.json`;
dizinde yalnız `appsettings.json`, 142 b, içinde `Cors` anahtarı yok). `T1` onu yaratacak — ama test
host'unun content root'unda çözülüp çözülmeyeceği **spec'te hiç düşünülmemiş**. `D-W1-2`'nin gerekçesi
*"üretimde politika var olmaz"* diyor; **testin de Development olduğu** hiçbir yerde geçmiyor.

**Kapanış:** `D-W1-2`'ye tek cümle ekle: *"`UseCors` ile `AddCors` **AYNI** koşula bağlanır
(`IsDevelopment() && origins.Length > 0`); ikisinin koşulu ayrışırsa host kayıtsız politikayla patlar."*
Ve `M190`'ın yanına bir ayak: liste boşken host **açılır ve istek 500 vermez**.

---

### 🟠 MAJOR-4 — `B-W1-1` ve `B-W1-2` **`BORCLAR.md`'DE YOK** (0 geçiş) VE HİÇBİR GÖREV/KRİTER ONLARI YAZMIYOR ⇒ SARKAN ATIF

**Nerede:** `## 6b` · `## 4` (T1–T6) · `## 7` (kriter 1–10)
**GÜVEN: KESİN**

`## 6b` iki kez atıfta bulunuyor:

> Borç: `BORCLAR.md` → **`B-W1-1`**. … Borç: `BORCLAR.md` → **`B-W1-2`**.

Ölçüm (`_denetim_olcum3.py` §1), `BORCLAR.md` (29.045 b):
```
  B-W1-1     gecis: 0
  B-W1-2     gecis: 0
  B-O52-1    gecis: 1     :229   ### `B-O52-1` — K81 BİÇİM STANDARDI YARIM: ...
```

Kontrol olarak baktığım `B-O52-1` **var**; `B-W1-1`/`B-W1-2` **yok**. Ve `## 4`'ün altı görevinde
*"`BORCLAR.md`'ye `B-W1-1`/`B-W1-2` yazılır"* adımı **yok**, `## 7`'nin on kriterinde de onları
denetleyen bir madde **yok**. Yani `K53/3`'ün *"mutantsız kalacaksa gerekçesiyle yazılır"* şartı
**yazılmayacak bir kayda** dayandırılmış oluyor.

*(Not: `## 6b`'nin `B-O52-1`'e benzemesi beklenirdi; bu, borç kaydının biçiminin de belli olduğunu
gösteriyor — eksik olan yalnız kaydın kendisi ve onu yazan adım.)*

---

### 🟠 MAJOR-5 — `## 6b`'DEKİ BORÇ BEYANLARI `spec-kapi-kapsama.py`'NİN AYRIŞTIRDIĞI BİÇİMDE **DEĞİL** ⇒ SPEC'İN *"araç gerekçesiz borcu reddeder"* İDDİASI BU SPEC'TE **ÖLÜ**

**Nerede:** `## 6b` ilk cümle · `## 7` kriter 5
**GÜVEN: KESİN** (aracı kendim koşturdum)

`## 6b`:

> `K53/3`: mutantsız kalan **kural** gerekçesiyle burada beyan edilir; … `spec-kapi-kapsama.py`
> gerekçesiz borcu **reddeder**.

Aracın borç ayrıştırıcısı (`araclar\spec-kapi-kapsama.py:130-134`) **tek** biçim tanır:

```python
        m = re.match(r"^\s*-\s*KURAL:\s*([^|]+)\|\s*GEREKCE:\s*(.*)$", s)
```

W1'in `## 6b`'si bunun yerine düz prozadır (`- **\`W1/G37/a\` · … — mutantsız.** Gerekçe: …`).
Kendi koşumum (kriter 5):

```
KAPI  (4): G35, G36, G37, G38
KURAL (0):
MUTANT(12): M189, M190, M191, M192, M193, M194, M195, M196, M197, M198, M193b, M198b
BULGU YOK: ... EXIT=0
```

`KURAL (0)` ve *"BEYAN EDILMIS MUTANT BORCU"* satırının **hiç basılmaması** şunu kanıtlar: araç bu
spec'te **hiçbir kural envanteri çıkarmadı** (`## 3`'teki `D-W1-1…7` kararları `###` başlığı
olmadığı için görünmez) ve **hiçbir borç görmedi**. Kriter 5'in EXIT 0'ı bu yüzden **borçlar hakkında
sıfır bilgi taşıyor** — kapı kapsamasını ölçüyor, o kadar.

🔴 İkinci katman: araç, gate-**ayağı** (`W1/G37/a`) diye bir kavram **tanımıyor**. Borçlar aracın
biçiminde yazılsaydı `S6 GEREKSIZ BORC: … envanterde boyle bir kural yok` verirdi. Yani `## 6b` **hangi
biçimde yazılırsa yazılsın araç tarafından doğru ölçülemez.** Bu, kapatılması gereken bir **araç
borcudur** (`B-O52-1`'in kardeşi), spec'in yazım hatası değil — ama spec bunu **beyan etmiyor**,
tersine ölçüldüğünü ima ediyor.

**Kapanış:** `## 6b`'ye tek satır ekle: *"🔴 `spec-kapi-kapsama.py` **ayak** düzeyinde borcu
ölçemez (yalnız `KURAL` tanır); bu bölüm bugün **elle** denetlenir — borç: `BORCLAR.md` → `B-W1-3`."*

---

### 🟠 MAJOR-6 — İZİNLİ ORIGIN'İN **NEREDE** DURACAĞI İKİRCİKLİ; `M191` VE `M196` YALNIZ "KOD İÇİNDE AÇIK DİZE" ŞIKKINA GÖRE YAZILMIŞ

**Nerede:** `## 3` → `D-W1-1` · `## 4` → T1 · `## 6` → `M191`, `M196`
**GÜVEN: KESİN**

> **`D-W1-1`** … İzinli origin **açık dizeyle** verilir (`http://localhost:5000`) **ya da**
> yapılandırmadan (`Cors:AllowedOrigins`) okunur

> **T1** … izinli origin listesi **`appsettings.Development.json`'da `Cors:AllowedOrigins`**.

`D-W1-1` iki şık bırakıyor, `T1` ikincisini **emrediyor**. `T1` izlenirse `Program.cs`'te
`WithOrigins(izinliOriginler)` gibi bir **değişken** olur, `"http://localhost:5000"` **literali olmaz**.
Ama mutant tablosu literale bağlı:

> | M191 | statik | … | `WithOrigins("http://localhost:5000")` → `AllowAnyOrigin()` |
> | M196 | **koşan** | … | İzinli origin `http://localhost:5001` **yapılır** |

`M191`'in *"ne bozulur"* hücresi **var olmayacak bir metni** hedefliyor; `M196`'nın hangi dosyayı
(kod mu `appsettings.Development.json` mı) düzenleyeceği yazmıyor — bu, kriter 7'nin
*"kaynak **bayt-özdeştir**"* şartının **hangi dosyaya** uygulanacağını da belirsiz bırakıyor.

**Kapanış:** `T1`'i `D-W1-1`'le hizala (tek şık seç) ve `M191`/`M196`'nın hedef dosyasını **adıyla** yaz.

---

### 🟠 MAJOR-7 — `D-W1-3`'ÜN GEREKÇESİ BU KOD TABANINDA **DOĞRULANMADI**: `Program.cs`'TE `UseRouting` **YOK** (x0, ölçüldü)

**Nerede:** `## 3` → `D-W1-3`
**GÜVEN: KESİN** (ölçüm) / **ZAYIF** (sonucun yanlış olduğu iddiası — sonuç doğru kalıyor)

> **`D-W1-3` — SIRA DERLEMEDE GÖRÜNMEZ ⇒ PREFLIGHT **CANLI** ÖLÇÜLÜR.**
> `UseCors` yanlış sıraya konursa (**routing/endpoint eşlemesinden sonra**) derleme **sessizce geçer**,
> preflight yine boş döner.

Ölçüm (`_denetim_olcum.py` §3, `Program.cs`):
```
  UseRouting                       x0
  MapHub                           x1
  IsDevelopment                    x1
```

`Program.cs` ne `UseRouting` ne `UseEndpoints` çağırıyor; `WebApplication` bunları **otomatik** olarak
zincirin başına/sonuna ekler. Bu yüzden `app.UseCors(...)`'ı kaynak sırasında `app.MapHub(...)`'dan
**sonra** yazmak bile ara katmanı **uç nokta katmanından önce** bırakır — `D-W1-3`'ün tarif ettiği
başarısızlık bu dosyada **böyle üretilemez**. `D-W1-3` "ölçülmüş taban" diliyle yazılmış ama
**ölçülmemiş** bir nedensellik iddiasıdır.

🔴 **Sonuç (canlı kapı) yine de doğrudur** — ama gerekçesi **BLOKER-1**'dir (prob başlıkları), bu değil.
Yanlış gerekçe, `G36`'nın gerçek riskinin görülmesini **engelledi**.

---

## 3. MINOR

### 🟡 MINOR-1 — `cors-kapisi.py` adı kapsamını yanlış anlatıyor **ve** `ss2-kapisi.py`'de zaten sertleşmiş yorum-atlama kodunu sıfırdan yazdırıyor
**GÜVEN: KESİN**

`G37/d`, `M194`, `M198`, `M198b` **Dart** dosyalarını (`veri/veritabani.dart`,
`ag/signalr_json_sinyal.dart`) `cors-kapisi.py` ile ölçtürüyor — "CORS kapısı" adı bunu taşımıyor.
Ayrıca `araclar\ss2-kapisi.py` (15.649 b) **zaten** aynı işi yapan, altın kümeyle pinlenmiş iki
fonksiyona sahip:
```
:44   def _blok_yorumsuz(metin):
:89   def _yorumsuz_satirlar(metin):
:25   ... Onarim `_blok_yorumsuz()`'tadir; altin kume vaka 11-14 ile pinli.
```
`T2` yeni bir kopya yazdırıyor. **MAJOR-2 ile birlikte okunmalı:** yeni kopya, eskisinin ısırarak
öğrendiği blok-yorum kusurunu **yeniden doğurabilir** ve W1'de onu ölçen mutant yok.

### 🟡 MINOR-2 — `G38/a`'nın psql sorgusu `"…"` olarak **boş** bırakılmış
**GÜVEN: KESİN.** `G38/a`: `docker exec momentum-postgres psql -U momentum -d momentum -c "…"`.
Tablo/sütun adı hiç geçmiyor (spec'te `owner_id` **x0**). Canlı DB'den ölçüldü: tablo `public.tasks`,
sütunlar `entity_id, owner_id, title, is_deleted, …`. En az bunlar yazılmalı (BLOKER-2 ile birlikte).

### 🟡 MINOR-3 — Kriter 7'nin "kaynak **bayt-özdeştir**" şartı `M197` için anlamsız
**GÜVEN: KESİN.** `M197` bir **komut satırı bayrağını** kaldırıyor, dosya değiştirmiyor; `sha256`
karşılaştırması onun için boş bir tören. Kriterin mutant tablosuna karşı denetlenmediğini gösteriyor.

### 🟡 MINOR-4 — `## 4b` ③ `flutter run`'ın **hangi dizinde** koşacağını yazmıyor
**GÜVEN: KESİN.** ② adımı `cd src\backend\Momentum.Api` diyor; ③ `cd src\client` demiyor. Ayrıca
`ORTAM.md`'nin iki kalkanı (`flutter` bu makinede **`.bat`**: `C:\src\flutter\bin\flutter.bat`;
`PROGRAMFILES(X86)` enjeksiyonu) `## 4b`'de anılmıyor — `KANIT/o57/_o57_web_olcum.py` ikisini de
uyguluyor, yani bilgi projede var ama spec'e taşınmamış.

### 🟡 MINOR-5 — `G36/a`'nın *"2xx"* ifadesi gevşek
**GÜVEN: KESİN.** ASP.NET Core preflight'ı **204** ile kısa devre yapar. `2xx` yazmak, uç noktanın
`405`/`200` döndüğü (yani `UseCors`'un hiç çalışmadığı) bir hâli de "2xx değil" diye ayıklar; sorun
değil, ama `204` yazmak ayağı **daha keskin** yapardı.

---

## 4. NE ÖLÇÜLEMEDİ  *(BOŞ OLAMAZ — ve boş değil)*

1. **Uygulamayı FİİLEN KOŞMADIM.** Backend ayağa kaldırılmadı (`netstat :5298` **boş**), Chrome
   açılmadı. `K80` + görev kapsamı gereği ortam kaldırılmadı. Dolayısıyla **BLOKER-1 canlı olarak
   doğrulanmadı** — kanıtı kod okumasıdır (istemcinin gönderdiği başlıklar + Fetch güvenli-liste
   kuralı), canlı preflight değil.
2. **ASP.NET Core'un `SimpleRequestHeaders` güvenli listesi DLL'den doğrulanamadı.**
   `Microsoft.AspNetCore.Cors.dll` (10.0.10 ve 9.0.18, 91.944 b) içinde `Accept-Language`,
   `Content-Language`, `Content-Type`, `Access-Control-Request-Headers` dizgeleri **ham olarak
   bulunamadı** (başlık adları `Microsoft.Net.Http.Headers`'tan geliyor). ⇒ **.NET tarafının tam
   davranışı ÖLÇÜLEMEDİ.** BLOKER-1 bu ölçüme dayanmıyor; tarayıcı tarafına dayanıyor.
3. **`flutter run -d chrome`'un `print()` çıktısını terminale iletip iletmediği ve F5'ten sonra
   bağlantıyı koruyup korumadığı ÖLÇÜLMEDİ.** `G37/a`+`G37/b`'nin "ikinci `MOMENTUM-G6-KANIT` satırı"
   şartının fiilen yakalanabilirliği **bilinmiyor**. Bu, BLOKER-3'ün en riskli tarafıdır.
4. **Drift'in bu makinede hangi `chosenImplementation`ı seçtiği ve `missingFeatures`ın boş olup
   olmadığı ÖLÇÜLMEDİ** ⇒ `G37/b`'nin *"kalıcı"* iddiasının geçip geçmeyeceği **bilinmiyor**
   (`flutter run` COOP/COEP başlığı vermez; en iyi ihtimalle `opfsLocks`'a düşülür — **varsayım,
   ölçüm değil**).
5. **`flutter build web` yeniden koşulmadı.** Spec'in *"EXIT 0, 57,3 s"* iddiasının **süre** kısmı
   ölçülmedi; artefaktın boyutu (2.769.788 b) ve mtime'ı (15:38:03) taban tablosuyla **birebir**
   uyuştuğu için iddia **dolaylı olarak doğrulandı**, yeniden üretilmedi.
6. **Kriter 1 (`verify.ps1`), kriter 2 (`flutter analyze --fatal-infos`), kriter 3 (`flutter test`)
   KOŞULMADI.** MAJOR-3'ün fiilen kriter 1'i düşürüp düşürmeyeceği bu yüzden **ZAYIF** güvendedir.
7. **`araclar/cors-kapisi.py` ve `KANIT/W1/_preflight.py` henüz YOK** (ölçüldü) ⇒ `G35`/`G36`'nın
   ölçüm araçlarının gerçekten ısırıp ısırmayacağı **tanım gereği** ölçülemez. `M195`/`M196`/`M197`
   (koşan sınıf) de ölçülemedi.
8. **`PROJE_HAFIZA.md` gövdesi okunmadı.** Spec'in andığı 24 kimliğin (`K135`, `K133`, `K127`, `K126`,
   `K112`, `K108`, `K95`, `K86`, `K81`, `K80`, `K79`, `K77`, `K73`, `K61`, `K58`, `K56`, `K55`, `K53`,
   `K44-a`, `K41`, `K26`, `M171c`, `M172`, `R8`) yalnız **geçtiğini saydım** (hepsi ≥3 kez geçiyor,
   sarkan K-atfı **yok**); **içeriklerinin spec'in iddia ettiği şeyi söyleyip söylemediği ÖLÇÜLMEDİ**
   — tek istisna `K135`, onu `ss2-kapisi.py`'nin docstring'inden birebir doğruladım (MAJOR-2).
9. **`KAPILAR.md`, `DESIGN.md`, `docs/ADR/**`, `GOREV-SS2-cakisma-cozumu.md` hiç açılmadı.**
   `ADR 0004` (spec `## 8/2`'de kapsam dışı bırakılan belge) **hiç aranmadı** — var mı bilmiyorum.
10. **`iddia-kapisi.py`, `sayi-tazeligi.py`, `belge-tavan-kapisi.py`, `tek-kopya-kapisi.py` W1 spec'ine
    karşı KOŞULMADI.** Spec içindeki sayısal iddiaların tazeliği bu araçlarla ölçülmedi.
11. **`_o57_r8_mutant.py`, `_o57_web_yuzey.py`, `_o57_spec_bicim.py`, `_o57_defter_dogrula.py`
    açılmadı/koşulmadı** — spec'in başlığındaki `R8` mutant iddiası **kanıtsız kabul edildi**
    (yalnız dosyanın var olduğunu ölçtüm).

---

## 5. BAĞIMSIZ EKSİKLİK KRİTİĞİ *(kendi denetimimin kusurları)*

**Hangi iddiayı kanıtsız kabul ettim:**
- Spec'in `## 2` tablosundaki *"`flutter build web` EXIT 0, **57,3 s**"* — süreyi hiç ölçmedim.
- Başlıktaki *"`KANIT/o57/_o57_r8_mutant.py`: kontrol ⇒ R8 susuyor, mutant ⇒ SERT DURAK"* — betiği
  ne açtım ne koşturdum.
- `K126`, `K127`, `K133`, `K53/1`, `K44-a`, `K80` metinlerinin spec'te alıntılanan hâlleri — yalnız
  `CLAUDE.md` ve `ORTAM.md`'deki karşılıklarını okudum; `PROJE_HAFIZA.md`'deki kanonik metinleri değil.
- `WebApplicationFactory`'nin varsayılan ortamının Development olduğu — **hatırladığım** bir .NET
  davranışı, bu makinede **ölçmedim** (ölçtüğüm şey, testlerin `UseEnvironment("Development")`'ı
  **açıkça** çağırdığıdır; o kadarı kesin).

**Hangi dosyayı hiç açmadım:** `PROJE_HAFIZA.md` (916.170 b — yalnız kimlik saydım), `KAPILAR.md`,
`DESIGN.md`, `PROJE_TALIMATI.md`, `docs/**`, `araclar/radar.py`, `araclar/iddia-kapisi.py`,
`araclar/tek-kopya-kapisi.py`, `tests/**` (yalnız `findstr` ile taradım, tek bir test dosyasını
baştan sona okumadım), `Momentum.Infrastructure/Sync/*` (yalnız arama), `gorev_ekle_alani.dart`
(ekleme akışını ekranın çağrı satırından doğruladım, widget'ın kendisini **açmadım** — `SS2`
kusurunun tam olarak bu katmanda doğduğunu bilerek; **bu benim en zayıf noktam**).

**Hangi yolu hiç denemedim:** ① Geçici bir CORS politikası yazıp **gerçek Chrome preflight'ını**
ölçmek — BLOKER-1'i **çalışan kodla** kesinleştirmenin tek yolu buydu ve yapılmadı. ② `flutter run
-d chrome`'u koşup F5 davranışını ve `missingFeatures`ı ölçmek — BLOKER-3 ve ÖLÇÜLEMEDİ-3/4 bu yüzden
açık kaldı. ③ `verify.ps1`'i koşup MAJOR-3'ü kesinleştirmek. Üçü de "ortamı kaldırmak" demekti;
`K80` gereği yapmadım — **ama bu, bulguların temiz olduğu anlamına GELMEZ**, yalnız canlı katmanın
ölçülmediği anlamına gelir.

---

## 6. HÜKÜM

**BU SPEC BU HÂLİYLE KİLİTLENMEMELİ.** Üç blokerin üçü de **kâğıt üzerinde** kapatılabilir (bir
`--dart-define` bayrağı, bir `Content-Type` kelimesi, bir "eli adlandıran" cümle) — hiçbiri mimari
değişiklik istemiyor, yani `K53/1`'in ikinci tur eşiğini **tetiklemez**: **düzelt → kilitle**.

`K53/1`'in kendi gerekçesi bu turda bir kez daha doğrulandı: **üç blokerin ve yedi majorun HİÇBİRİ
koşan kod gerektirmedi**; hepsi bir okuma + on beş mekanik ölçümle bulundu.

**Ham ölçümler:** `KANIT\W1\_denetim_olcum.py` · `_denetim_olcum2.py` · `_denetim_olcum3.py` ·
`_denetim_olcum4.py` · `_denetim_olcum5.py` (hepsi bu denetim turunda yazıldı ve koştu).
