# G38/a + G38/b — TAM DOĞRULAMA (backend AÇIKKEN, Faz 1)

## G38/a — Web'de eklenen görev sunucu veritabanında görünür

**Ölçüm ekrandan DEĞİL** (spec §5/G38/a):
- ÖNCESİ: `docker exec momentum-postgres psql ... select count(*) from tasks where owner_id='11111111-1111-1111-1111-111111111111' and title='W1-DENEME-BASLIGI-OTURUM57'` → **0** (`G38a-psql-ONCESI.txt`)
- Onur tarayıcıda (flutter run -d chrome'un AÇTIĞI pencerede) metin kutusuna `W1-DENEME-BASLIGI-OTURUM57` yazıp ekledi.
- SONRASI: aynı sorgu → **1**. Tam satır: `entity_id=0000ce51-b794-762b-bc0e-47ea64b52a4c title=W1-DENEME-BASLIGI-OTURUM57 owner_id=11111111-1111-1111-1111-111111111111` (`G38a-psql-SONRASI.txt`) — başlık **birebir** eşleşiyor.

## G38/b — Sunucuda aynı GUID sahibiyle üretilen bir değişiklik Yenile sonrası iner

- Doğrudan `POST /v1/sync` ile (UI KULLANILMADI), `X-Momentum-Dev-User: 11111111-...` başlığıyla, gerçek UUIDv7 operationId ile, sunucuda `W1-SUNUCUDAN-DEGISIKLIK-OTURUM57` başlıklı yeni bir görev üretildi. `applied: Applied` (`G38b-sunucu-degisiklik-post.txt`).
- `psql` ile doğrulandı: satır Postgres'te var (`G38b-psql-sunucu-kaydi.txt`).
- İkinci bir server-side op (`W1-INKREMENTAL-TEST`) ile server'ın INCREMENTAL (sinceCursor'lı) pull yolu ayrıca izole test edildi — sunucu tarafı BİREBİR doğru çalışıyor (1 change döndü).
- Onur "Yenile"ye bastı (ve ayrıca uygulamayı yeniden açtı) → **ekran görüntüsüyle doğrulandı**: liste hem `W1-DENEME-BASLIGI-OTURUM57` hem `W1-SUNUCUDAN-DEGISIKLIK-OTURUM57` hem `W1-INKREMENTAL-TEST` satırlarını gösteriyor.

## Yol boyunca bulunan ve düzeltilen GERÇEK kusur (spec kapsamı dışı ama W1'i bloke ediyordu)

`src/client/web/drift_worker.js` sürümü (`drift-2.34.0` etiketinden) pubspec.lock'un
resolve ettiği `drift: 2.34.3` ile UYUŞMUYORDU (`sqlite3.wasm` zaten doğruydu,
`sqlite3-3.5.0`). Sonuç: her tarayıcı açılışında `WebAssembly.instantiate():
Import #10 "dart" "xFileControl": function import requires a callable`
LinkError'ı ile veritabanı katmanı hiç açılmıyordu — `main()` `runApp()`'a hiç
ulaşamıyordu (ekranda yalnızca boş sayfa). Onur'un onayıyla `araclar/
web-varlik-indir.py`'deki `drift_worker.js` etiketi `drift-2.34.3`'e güncellendi,
eski pin silinip yeniden TOFU ile pinlendi (`araclar/web-varlik.sha256`).
Ayrıca öğrenilen ikinci bulgu: `flutter run -d chrome` yalnızca KENDİ açtığı
pencereye "main() çalıştır" sinyalini gönderiyor -- elle açılan başka bir
sekme/pencere dosyaları indirir ama uygulamayı hiç BAŞLATMAZ.

## missingFeatures (G37/c gereği AÇIKÇA yazılıyor, sessiz geçilmiyor)

Her açılışta ölçülen: `chosenImplementation=WasmStorageImplementation.sharedIndexedDb`
`missingFeatures={MissingBrowserFeature.dedicatedWorkersInSharedWorkers,
MissingBrowserFeature.sharedArrayBuffers}`. OPFS-özel implementasyona
DÜŞÜLEMEDİ -- muhtemel sebep: `flutter run`'ın geliştirme sunucusu
Cross-Origin-Isolation (COOP/COEP) başlıklarını göndermiyor. Bu W1'in
kapsamı dışında bir borç olarak kaydedilecek.
