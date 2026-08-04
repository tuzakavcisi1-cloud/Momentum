# T6 — M199 (koşan uygulama)

**Mutasyon:** `src/client/web/drift_worker.js` geçici olarak `.M199-yedek` adına
taşındı (silinmedi, yeniden adlandırıldı — geri alma garantili).

**Yeniden koşum:** Backend kapatıldı (`netstat` ile LISTENING=0 ölçüldü),
Onur AYNI çalışan `flutter run -d chrome` penceresinde **sert yenileme**
(Ctrl+Shift+R) yaptı.

## Ölçülen (üç ayak da KIRMIZI)

```
Starting application from main method in: org-dartlang-app:/web_entrypoint.dart.
MOMENTUM-G6-KANIT chosenImplementation=WasmStorageImplementation.inMemory missingFeatures={MissingBrowserFeature.workerError}
```

- **`chosenImplementation` DEĞİŞTİ**: `WasmStorageImplementation.sharedIndexedDb` →
  `WasmStorageImplementation.inMemory`.
- **`missingFeatures` FARKLI DOLDU**: `{workerError}` (öncekinden tamamen farklı --
  `dedicatedWorkersInSharedWorkers`/`sharedArrayBuffers` değil, worker dosyası HİÇ
  BULUNAMADIĞI için ayrı bir hata sınıfı).
- **F5 sonrası görev KAYBOLDU**: Onur "M199-TEST" başlıklı bir görev ekledi (in-memory
  depo bunu ANLIK gösterdi), ardından backend KAPALIYKEN F5 yaptı — görev **listede
  kalmadı** (in-memory depo sayfa yenilemesinde sıfırlanır). Onur'un kendi gözlemiyle
  doğrulandı: *"kayboldu"*.

## Geri alma

`drift_worker.js.M199-yedek` → `drift_worker.js` adına geri taşındı.
`sha256sum drift_worker.js` → `4db0469de8ceabad8d5cd3d920614486ba587e100e39523f36f704a3aec5f26c`
— `araclar/web-varlik.sha256` pinli değeriyle **birebir eşleşti**.

## Sonuç

**M199 ISIRDI** — spec'in beklediği ÜÇ ayağın (chosenImplementation değişimi,
missingFeatures dolması, F5 sonrası kalıcılık kaybı) hepsi canlı ölçümle
doğrulandı.
