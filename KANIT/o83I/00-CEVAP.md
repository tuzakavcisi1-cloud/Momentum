# IS-EMRI-o83-I — CEVAP

🔴 **§B UYGULANMADI — iş emrinin önculü ölçümde YANLIŞ çıktı, aşağıda 2. maddede.** §A ve §C tam uygulandı. Kapı bu emirde koşmadı (push yok).

1. **`paket.yml`den silinen satır aralığı + AYAK 1'in kalan kontrolleri:** silinen blok (yorum + `grep -q 'deadbeef-…'` satırı) eski dosyada **109-115. satırlar**, ham diff `KANIT/o83I/01-paket-yml-farki.txt`. AYAK 1'in kalan kontrolleri **aynen duruyor**: kök gövde boş değil · `flutter_bootstrap.js` dizesi kabukta var · önyükleyici dosyası **gerçekten** iniyor (boş değil) · `useLocalCanvasKit:true` (CDN kapalı) · `main.dart.js` iniyor ve `>100000` bayt. `YESIL:` satırı artık "demo kimliği" iddia etmiyor: `"kabuk + onyukleyici + uygulama kodu ayni kokende, CDN kapali"`.
2. **`devUserIdEzmesi` silme öncesi/sonrası:** **silinmedi** — iş emri önculü ("hiçbir yerden okunmadığı ölçüldü, davranışsızdır") **ölçümde tuttum, yanlış çıktı**: `src/client/test/dev_user_id_define_test.dart` (G20 testi) `import 'package:client/main.dart' show devUserIdEzmesi;` ile sabiti **gerçekten okuyor** ve karşılaştırıyor. Silinirse bu test **derlenmez** (import hatası) — düzeltmek testi değiştirmeyi gerektirir, DOKUNMA LİSTESİ testleri yasaklıyor. Ham grep: `KANIT/o83I/02-olu-sabit-olcumu.txt` (önce/sonra aynı, hiçbir satır değişmedi). `main.dart` **dokunulmadan** kaldı.
3. **`grep -rn DEV_USER_ID src/backend` sonucu ve compose satırının kaderi:** ham çıktı **boş DEĞİL** — tek eşleşme `src/backend/Momentum.Api/wwwroot/main.dart.js:8421` içinde, ama bu **derlenmiş ön-yüz JS çıktısı**, backend C# kaynağı değil (`.cs` dosyalarında `DEV_USER_ID` hiç geçmiyor — backend mantığı bu değişkeni okumuyor). Etkin sonuç: sunucu da kullanmıyor ⇒ `docker-compose.yml:31`deki satır **ölü ama SİLİNMEDİ** (ayrı karar, Onur'un; dosyaya zaten dokunulmadı — DOKUNMA LİSTESİ). Ham çıktı: `KANIT/o83I/03-backend-DEV_USER_ID-olcumu.txt`.
4. **AYAK 3'e eklenen üç adımın tam kabuk kodu** (`.github/workflows/paket.yml:141-164`, olduğu gibi):
   ```bash
   # o83-I SC: kimlik dilimini kanitlayan uc adim -- URUN UCUNA konusur (HTTP kodu + JSON
   # alan varligi), dize aramasi YOK. o79 dersi: `curl ... | grep -q ...` YAZILMAZ (grep
   # erken cikar, curl'un ciktiya yazmasi kesilir, pipefail bunu yalanci kirmiziye cevirir)
   # -- once dosyaya indir, sonra dosyada bak.
   eposta="paket-kapisi-$(date +%s%N)-$$@momentum.test"
   kayit_govde="{\"email\":\"$eposta\",\"password\":\"paketKapisi12345\"}"
   kayit_kod=$(curl -s -o /tmp/register.json -w '%{http_code}' -X POST http://localhost:5298/v1/auth/register \
           -H 'Content-Type: application/json' -d "$kayit_govde")
   [ "$kayit_kod" = "201" ] \
     || { echo "KIRMIZI: register $kayit_kod dondu, 201 bekleniyordu"; cat /tmp/register.json; exit 1; }
   jq -e '.accessToken != null and .accessToken != ""' /tmp/register.json >/dev/null \
     || { echo "KIRMIZI: register govdesinde accessToken alani YOK"; cat /tmp/register.json; exit 1; }
   token=$(jq -r '.accessToken' /tmp/register.json)

   yetkili_kod=$(curl -s -o /dev/null -w '%{http_code}' http://localhost:5298/v1/tasks \
           -H "Authorization: Bearer $token")
   [ "$yetkili_kod" = "200" ] \
     || { echo "KIRMIZI: yetkili (taze token) GET /v1/tasks $yetkili_kod dondu, 200 bekleniyordu"; exit 1; }

   yetkisiz_kod=$(curl -s -o /dev/null -w '%{http_code}' http://localhost:5298/v1/tasks)
   [ "$yetkisiz_kod" = "401" ] \
     || { echo "KIRMIZI: yetkisiz (token yok) GET /v1/tasks $yetkisiz_kod dondu, 401 bekleniyordu"; exit 1; }

   echo "YESIL: dev-kimlik 401->200 + register 201/accessToken + taze-token yetkili 200 + yetkisiz 401"
   ```
   Üçü de HTTP kodu (`201`/`200`/`401`) ve JSON alan varlığı (`jq -e`) ile ölçülüyor; `| grep -q` borusu yok.
5. **`git status --porcelain -- src tests`:** **BOŞ** — beklenen ("yalnız `main.dart`") **tutmadı**, çünkü SB uygulanmadı (madde 2). Tek değişen dosya `.github/workflows/paket.yml` (`src`/`tests` altında değil): `git status --porcelain -- .github/workflows src` → ` M .github/workflows/paket.yml`.
