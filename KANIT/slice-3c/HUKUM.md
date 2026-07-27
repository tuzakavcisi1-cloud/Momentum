# HUKUM — GOREV-slice-3c-senkron (K64, sha8 537D0579; ara-düzeltme K65)

## Nihai karar: YEŞİL (K65 düzeltmesiyle birlikte)

Sekiz kapının (G1–G8) hepsi güncel kodda YEŞİL koştu; 36 mutantın (M1–M36) hepsi
tek tek uygulanıp KIRMIZI ölçülüp geri alınıp YEŞİL doğrulandı. T7 sırasında G6
AYAK6'da gerçek, tekrarlanabilir bir kusur bulundu; Onur'un kilitli K65 düzeltmesi
uygulandı ve 10/10 yeniden ölçümle kapatıldı — aşağıda ayrıntılı.

## Her iddianın dayandığı dosya

1. **G1 (401×3 + 200×1) YEŞİL.**
   - `KANIT/slice-3c/01-G1-dev-kimlik/01-401-testleri.txt` — "Başarılı! - Başarısız: 0, Başarılı: 3"
   - `KANIT/slice-3c/01-G1-dev-kimlik/02-200-testi.txt` — "Başarılı! - Başarısız: 0, Başarılı: 1"
   - Testler artık `Momentum.sln`'e BAĞLI, doğru konumda: `tests/Momentum.Api.Tests/DevKimlikKapisiTestleri.cs`,
     `tests/Momentum.Persistence.Tests/DevKimlikKapisi200Testleri.cs` (bkz. §"T7 sırasında bulunan ikinci
     kusur" aşağıda).

2. **G2 (registry+zarf) YEŞİL, 11/11.**
   `KANIT/slice-3c/02-G2-registry-zarf/00-test-ciktisi.txt` — "All tests passed!" (11 test).
   Dört ham `WireOp` JSON'u aynı klasörde (`01-ekle.json`…`04-sil.json`).

3. **G3 (kuyruk) YEŞİL, 8/8.** `KANIT/slice-3c/03-G3-kuyruk/00-test-ciktisi.txt`.

4. **G4 (HLC) YEŞİL, 8/8 — K65 SONRASI güncel semantikle.**
   `KANIT/slice-3c/04-G4-hlc/00-test-ciktisi.txt`. İki test (`saat ileri gider` ve
   `1000 çağrı`) K65'in yeni `counter` semantiğine göre yeniden yazıldı (bkz. madde 8).

5. **G5 (karantina) YEŞİL, 11/11.** `KANIT/slice-3c/05-G5-karantina/00-test-ciktisi.txt`.

6. **G6 (uçtan uca, 6 ayak) YEŞİL — K65 düzeltmesi SONRASI.**
   `KANIT/slice-3c/06-G6-uctan-uca/01-alti-ayak-ciktisi.txt` (6/6 ayak PASS) +
   `02-postgres-dogrulama.txt` (ayak 3/4/6'nın ham SQL sonuçları, `docker exec psql`).
   **AYAK6'nın düzeltme öncesi ~%40-50 aralıklı KIRMIZI yaktığı, kök nedeni ve kilitli
   düzeltmesi** `03-K65-bulgu-ve-duzeltme.md`'de tam anlatılıyor; 10 ardışık koşumun ham
   kanıtı `04-ayak6-10-kosum-ham.txt`'te (**10/10 SON** — Onur'un kilit koşulu).

7. **G7 (regresyon) YEŞİL.** `KANIT/slice-3c/07-G7-regresyon/`:
   `01-flutter-analyze.txt` (0 bulgu) · `02-flutter-test-tam.txt` (79/79) ·
   `03-verify-ps1.txt` (build 0/0, backend testleri 114/114, CVE 0) ·
   `04-design-token-kapisi.txt` (EXIT 0) · `05-tek-kopya-kapisi.txt` (YEŞİL).

8. **G8 (atomiklik) YEŞİL, 4/4.** `KANIT/slice-3c/08-G8-atomiklik/00-test-ciktisi.txt`.

9. **36/36 mutant uygulandı/KIRMIZI/geri-alındı/YEŞİL.**
   `KANIT/slice-3c/09-MUTANT/00-OZET.md` — tam tablo + kanıt kaynağı notu (hangi
   mutantın bu oturumda taze, hangisinin oturumun önceki bölümünde çalıştırıldığı
   dürüstçe ayrıştırılmış). K65'in dokunduğu satırlara en yakın M21/M23 YENİ kodda
   ayrıca yeniden doğrulandı: `09-MUTANT/21-23-K65-sonrasi-yeniden-dogrulama.txt`.

## T7 sırasında bulunan İKİ kusur (biri benim, biri backend'in)

### Kusur A — kendi hatam: yanlış konumlandırılmış test projeleri

G1'in test projelerini (`Momentum.Api.Tests`, `Momentum.Persistence.Tests`) yanlışlıkla
`src/backend/` altında YENİ, `Momentum.sln`'e hiç bağlı olmayan klasörler olarak
oluşturdum — repo kökündeki `tests/` dizininde AYNI isimli, ÖNCEDEN VAR OLAN, git-tracked,
erken dilimlerden gelen gerçek test projelerini keşfetmeden. Sonuç: G1 testleri hiçbir
zaman `verify.ps1`/`dotnet test $solution` zincirinin PARÇASI olmamıştı (gerçek bir
doğrulama boşluğu) VE kabul kriteri 8'in `git diff --stat -- src/backend/` ölçümünü
ihlal edecek yeni klasörler oluşmuştu.

**Düzeltme:** G1'in test içeriği DOĞRU, mevcut `tests/Momentum.Api.Tests/` ve
`tests/Momentum.Persistence.Tests/` projelerine taşındı; oradaki ESTABLISHED
kalıplar (paylaşılan `PostgresFixture`/`TestDatabase` — `TestSupport.cs` — ve
`WithWebHostBuilder(...).UseSetting("ConnectionStrings:Momentum", ...)` deseni,
`EndpointTests.cs`'te zaten kanıtlı) yeniden kullanıldı; kendi bespoke
`PostgresFixture.cs`/env-var yaklaşımım atıldı. M1/M2 mutantları YENİ konumda yeniden
doğrulandı. `src/backend/Momentum.Api.Tests/` ve `src/backend/Momentum.Persistence.Tests/`
klasörleri **git-tracked DEĞİL** (untracked, `.sln`'e bağlı değil, build/test'e hiç
girmiyor) ama izin katmanı `rm`/`Remove-Item`'i reddettiği için fiziksel olarak
SİLİNEMEDİ — içerikleri inert bir açıklama yorumuyla nötrleştirildi, Onur'un elle
silmesi gerekiyor.

### Kusur B — backend'de gerçek, tekrarlanabilir bir kusur (K65 ile kapatıldı)

Yukarıda madde 6'da anlatıldı, ayrıntı `06-G6-uctan-uca/03-K65-bulgu-ve-duzeltme.md`'de.
Özet: aynı turda aynı alana iki ardışık yazımda, sunucunun receive-time kırpması iki
alan-HLC'sini eşitleyince tie-break `opId`nin dize-ordinaline düşüyordu; `opId` UUID v4
(rastgele) olduğu için bu bir yazı-turaydı (~%50). Onur'un K65 kilidiyle **istemci
tarafında** iki değişiklik yapıldı — `opId` üreteci UUIDv7'ye (zaman-sıralı) geçti,
`HlcUretici.counter` her damgada kesin artacak şekilde değişti — backend'e (izin
verilmeyen alan) TEK SATIR dokunulmadan. 10/10 yeniden ölçümle kapatıldı.

## Kabul kriterleri karşılama durumu

1. G1–G8 koştu, hepsi YEŞİL, çıkış kodları KANIT'ta. ✅
2. M1–M36 hepsi tek tek uygulandı/KIRMIZI/geri-alındı/YEŞİL, kör kapı yok. ✅
3. `flutter analyze --fatal-infos` 0 bulgu; `flutter test` EXIT 0 (79/79). ✅
4. `araclar/verify.ps1` EXIT 0 (build 0/0, test 114/114, CVE 0). ✅
5. `design-token-kapisi.py` EXIT 0; `tek-kopya-kapisi.py` YEŞİL. ✅
6. `spec-kapi-kapsama.py` EXIT 0 (8 kapı, 10 kural, 36 mutant tam kapsama, bulgu yok) ·
   `sayi-tazeligi.py` EXIT 0 (HUKUM: TEMİZ). ✅ — `07-G7-regresyon/06-sayi-tazeligi.txt`,
   `07-spec-kapi-kapsama.txt`.
7. Türkçe yorum/belge; `DESIGN.md`'ye dokunulmadı. ✅
8. Backend dokunulan yüzey: `git diff --stat 5df3caf -- src/backend/` ⇒ yalnız
   `Program.cs` + yeni `DevCurrentUser.cs`. ✅ (Kusur A'nın stray klasörleri
   untracked olduğu için bu diff'te GÖRÜNMÜYOR — ama fiziksel varlıkları yukarıda
   dürüstçe belgelendi.)

## Beyan edilmiş sınırlar / [DOĞRULANMADI]

- 🟡 M3–M32 arası mutantların ham terminal çıktıları ayrı dosya olarak
  arşivlenmedi (bkz. `09-MUTANT/00-OZET.md`'nin kanıt kaynağı notu) — ölçüm
  GERÇEKTİ, dökümü oturum transkriptinde.
- Commit/push YAPILMADI (görev talimatı ve proje kuralı gereği — push daima
  Onur'un işi).

## Değiştirilen/eklenen dosyalar (özet)

`src/backend/Momentum.Api/Program.cs` (D0 kaydı) · `src/backend/Momentum.Api/Auth/DevCurrentUser.cs` (yeni) ·
`src/client/lib/veri/{veritabani,hlc,ayarlar_deposu,wire_op,gorev_deposu,senkron_dongusu}.dart` ·
`src/client/lib/ag/{senkron_agi,http_senkron_agi}.dart` · `src/client/lib/sunum/gorev_listesi_ekrani.dart` ·
`src/client/lib/main.dart` · `src/client/test/{g2,g3,g4,g5,g8}_*_kapisi_test.dart` +
`src/client/test/destekler/sahte_senkron_agi.dart` · `src/client/tool/{uctan_uca_duman_testi,g6_uctan_uca_kapisi,g6_mutant_dogrulama}.dart` ·
`tests/Momentum.Api.Tests/DevKimlikKapisiTestleri.cs` (yeni) ·
`tests/Momentum.Persistence.Tests/DevKimlikKapisi200Testleri.cs` (yeni).
