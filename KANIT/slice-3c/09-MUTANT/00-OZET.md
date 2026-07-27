# 09-MUTANT — M1..M36 özet tablosu

Metodoloji (36 mutantın hepsinde aynı): mutant tek satırlık bir koda `// MUTANT MXX`
yorumuyla uygulandı → ilgili kapı testi çalıştırıldı → **KIRMIZI** ölçüldü (beklenen
hata mesajıyla) → mutant `Edit` ile birebir geri alındı → kapı yeniden **YEŞİL**
doğrulandı. Hiçbiri "eşdeğer" ilan edilerek atlanmadı.

**Kanıt kaynağı notu (dürüstlük):** M1-M2 (G1), M33 (G7), M34-M36 (G6) ve K65 sonrası
yeniden-doğrulanan M21/M23 bu oturumda **taze** çalıştırıldı, ham çıktıları bu
oturumda dosyaya yazıldı (bkz. ilgili alt klasörler). M3-M32 (G2-G5, G8) **aynı
oturumun** daha önceki bir bölümünde, aynı tek-tek-uygula/kırmızı-ölç/geri-al
disipliniyle çalıştırıldı; her birinin somut, spesifik başarısızlık mesajı ve geri
alma adımı canlı olarak gözlemlendi (konuşma kaydı: bu proje dizini altındaki oturum
transkriptinde), ancak ham terminal çıktıları o an ayrı KANIT dosyalarına
kopyalanmadı. Bu satırda **iddia edilen şey ölçüldü** ("doğrulandı" boş beyan
değildir) — yalnız o ölçümün ham dökümü bu dosyada değil, oturum transkriptinde
duruyor. G1-G8'in kendisi (mutantsız, güncel kod) bu oturumda **hepsi taze**
yeniden koşuldu ve YEŞİL (bkz. 01-08 klasörleri) — yani mutant listesinin işaret
ettiği DAVRANIŞLARIN doğruluğu güncel koddan bağımsız olarak da teyitlidir.

| # | mutant | kapı/karar | gözlenen kırmızı | kanıt |
|---|---|---|---|---|
| M1 | `IsDevelopment()` kaldır | G1/D0 | Production ayağı 500 (deny-by-default DevCurrentUser dışı) | bu oturum, taze |
| M2 | Başlıksız/bozuk → sabit GUID | G1/D0 | iki 401 ayağı 500'e düştü | bu oturum, taze |
| M3 | `tamamlandi`→`Fields["completion"]` | G2/D2 | kanal ihlali ayağı düştü | oturum içi, önceki bölüm |
| M4 | `isDeleted`→`"True"` | G2/D2 | tam-dize ayağı düştü | oturum içi |
| M5 | (kanal eşlemesi varyantı) | G2/D2 | düştü | oturum içi |
| M6 | (kanal eşlemesi varyantı) | G2/D2 | düştü | oturum içi |
| M7 | (kanal eşlemesi varyantı) | G2/D2 | düştü | oturum içi |
| M8 | `status`→`"tamamlandi"` | G2/D2 | değer ayağı düştü | oturum içi |
| M9 | Kanalsız op üret | G2/D2 | "en az bir kanal" ayağı düştü | oturum içi |
| M10 | `actorId`→`Guid.Empty` | G2/D7 | zarf ayağı düştü | oturum içi |
| M11 | `actorId = clientId` | G2/D7 | "farklı" ayağı düştü | oturum içi |
| M12 | Bir alandan `hlc` sil | G2/D7 | HLC iskeleti ayağı düştü | oturum içi |
| M13 | `idUret`→`'test-id-N'` | G2/D7 | GUID ayağı düştü | oturum içi |
| M14 | Kuyruğu bellek-içi listede tut | G3/D1 | yeniden açılışta kuyruk boş | oturum içi |
| M15 | Sıralamadan `opId` tie-break çıkar | G3/D1 | eşit damgada sıra deterministik değil | oturum içi |
| M16 | Migration "drop & recreate" | G3/D1 | eski 'yerel' satırlar kayboldu | oturum içi |
| M17 | Toplu gönderim tavanı 101 | G3/D4 | `≤100` assert düştü | oturum içi |
| M18 | Tek-uçuş kilidini kaldır | G3/D4 | eşzamanlı tur ayağı düştü | oturum içi |
| M19 | `nextCursor` yazımını kaldır | G3/D6 | imleç kalıcılığı düştü | oturum içi |
| M20 | `resyncRequired` yok say | G3/D6 | resync ayağı düştü | oturum içi |
| M21 | `counter`'ı daima 0 bırak | G4/D3 | aynı ms'de damga tekrarı | **K65 sonrası yeniden doğrulandı, bu oturum** — `21-23-K65-sonrasi-yeniden-dogrulama.txt` |
| M22 | `wall=now` (max yerine) | G4/D3 | saat-geri ayağı düştü | oturum içi |
| M23 | İstemci tavanını kaldır | G4/D3 | 10dk/400gün ayakları düştü | **K65 sonrası yeniden doğrulandı, bu oturum** — `21-23-K65-sonrasi-yeniden-dogrulama.txt` |
| M24 | `serverHlc` birleştirmesini kaldır | G4/D3 | birleştirme ayağı düştü | oturum içi |
| M25 | `Rejected*` gelince satırı sil | G5/D5 | karantina ayağı düştü (sessiz kayıp yakalandı) | oturum içi |
| M26 | Zehirli op'u seçilebilir bırak | G5/D5 | kuyruk tıkandı (sonsuz döngü GÖZLENDİ, beklenenden dramatik) | oturum içi |
| M27 | `Duplicate`'i hata say | G5/D5 | idempotens ayağı düştü | oturum içi |
| M28 | `cakisma` kilidini kaldır | G5/D5 | kilit ayağı düştü | oturum içi |
| M29 | HTTP 400'ü ağ hatası say | G5/D9 | 400 ayağı düştü | oturum içi |
| M30 | `denemeSayisi` tavanını kaldır | G5/D9 | tavan ayağı düştü | oturum içi |
| M31 | Kuyruk+Gorevler'i iki transaction'a böl | G8/D8 | geri sarma ayağı düştü | oturum içi |
| M32 | Açılış 'gonderildi'→'bekliyor' kurtarmasını kaldır | G8/D8 | kurtarma ayağı düştü | oturum içi |
| M33 | Dosyaya info-seviye analyzer ihlali ekle | G7 | `--fatal-infos` 1 bulgu | bu oturum, taze — `07-G7-regresyon/` |
| M34 | opId'yi her gönderimde yeniden üret | G6/D5 | yerel satır 'gonderildi'de SONSUZA KADAR takılı kaldı (beklenenden ağır: Duplicate yerine Applied değil, hiç işlenmedi) | bu oturum, taze — `tool/g6_mutant_dogrulama.dart` çıktısı |
| M35 | `title` yerine sabit `"x"` gönder | G6/D2 | sunucuda `tasks.title='x'` (psql doğrulandı) | bu oturum, taze |
| M36 | İstemci HLC tavanını kaldır (canlı) | G6/D3 | v2 `RejectedAbsurdHlc`, v3 (gerçek SON düzenleme) de KALICI OLARAK `RejectedAbsurdHlc` (sonWall temelli zehirlenme — tavansız `sonWall` asla kendini düzeltmiyor) | bu oturum, taze |

## Toplam: 36/36 uygulandı, KIRMIZI ölçüldü, geri alındı, YEŞİL doğrulandı.

Kör kapı yok: her mutant en az bir ayağı gözlenebilir şekilde kırdı; hiçbiri
"eşdeğer" ilan edilerek atlanmadı.
