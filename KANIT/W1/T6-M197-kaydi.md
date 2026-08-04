# T6 — M197 (koşan uygulama)

**Mutasyon:** `--dart-define=SENKRON_SUNUCU_URL` KALDIRILARAK yeniden derlendi
(varsayılan `http://10.0.2.2:5298`'e düşer — masaüstü tarayıcısından erişilemez).

## Kırmızı ölçüm

- ÖNCESİ: `select count(*) from tasks where title='M197-TEST'` → **0**.
- Onur, yanlış-URL'li derlemede uygulamaya `M197-TEST` başlıklı görevi ekledi.
- SONRASI: aynı sorgu → **YİNE 0** (`T6-M197-kirmizi-psql.txt`). Görev hiçbir
  zaman gerçek sunucuya ulaşmadı — G38/a'nın KIRMIZI vereceği tam olarak budur.

## Pozitif kontrol (aynı tur, düzeltilmiş derleme)

- `--dart-define=SENKRON_SUNUCU_URL=http://localhost:5298` geri eklenip
  yeniden derlendi/başlatıldı; backend de yeniden ayağa kaldırıldı.
- ÖNCESİ: `select count(*) from tasks where title='M197-POZITIF-KONTROL'` → **0**.
- Onur aynı başlıkla bir görev ekledi.
- SONRASI: **1** (`T6-M197-pozitif-kontrol-psql.txt`) — mekanizmanın doğru
  yapılandırmayla GERÇEKTEN çalıştığı aynı oturumda kanıtlandı.

## Sonuç

**M197 ISIRDI** ve pozitif kontrolle doğrulandı (0→0 yanlış URL'de, 0→1 doğru
URL'de). Bu, T6'nın SON mutantıydı — **18/18 mutant tamamlandı**:
14 statik + 2 koşan-sunucu (M195, M196) + 2 koşan-uygulama (M197, M199).
