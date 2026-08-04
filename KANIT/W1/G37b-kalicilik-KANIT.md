# G37/b — "KALICI" İDDİASI, BACKEND KAPALIYKEN (D-W1-6)

## Sıra (spec'in PAZARLIKSIZ dediği sıra ile birebir)

1. Backend Claude Code tarafından kapatıldı: `taskkill /F /PID 20116`.
2. Kapanış **ölçüldü** (varsayılmadı): `netstat -ano | findstr :5298` → LISTENING satırı **0**
   (`G37b-backend-kapali-netstat.txt`).
3. Onur, backend KAPALIYKEN uygulamaya `onur yeni` başlıklı bir görev ekledi.
4. Bu görevin sunucuya HİÇ gitmediği doğrudan Postgres'e sorularak ölçüldü
   (API zaten erişilemezdi): `select count(*) from tasks where title='onur yeni'`
   → **0** (`G37b-backend-kapaliyken-psql-kontrol.txt`).
5. Onur **F5** ile tam sayfa yenileme yaptı (backend HÂLÂ kapalı).
6. İKİNCİ `MOMENTUM-G6-KANIT` satırı `_web_kanit.py` ile yoklanarak yakalandı
   (`G37b-ikinci-acilis-kaniti.txt`) — uygulama gerçekten sıfırdan yeniden başladı,
   `missingFeatures` yine BOŞ DEĞİL, açıkça not edildi (G37/c).
7. Onur ekran görüntüsü attı: **`onur yeni` görevi listede, "Çevrimdışı" rozetiyle
   duruyor.** Bu, yerel Drift/IndexedDB deposunun backend'siz de KENDİ BAŞINA
   kalıcı olduğunun doğrudan kanıtıdır — v1'in kör noktası (backend açıkken
   F5 testi kalıcılığı değil senkronu ölçerdi) burada TEKRARLANMADI, çünkü
   backend'in gerçekten kapalı olduğu netstat ile ölçüldü.

## Sonuç

G37/a, G37/b, G37/c — üçü de canlı ölçümle GEÇTİ. `missingFeatures`in boş
olmaması ayrı bir borç olarak (W1 kapsamı dışı, COOP/COEP başlıkları) not
edilecek.
