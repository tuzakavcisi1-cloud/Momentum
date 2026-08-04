# T6 — 14 statik mutant kaydı (M189–M194, M198, M198b + harfli varyantlar)

Taban sha256 (T6 başlangıcı):
```
src/backend/Momentum.Api/Program.cs                1e31f5b47697c6b342604efe73f070985730820632c4245fb02843795fee8301
src/client/lib/veri/veritabani.dart                fe8f89b4558dbc5fd881e34080bf114e1a3390258e00f38c0e5eae7d0ee09c0f
src/client/lib/ag/signalr_json_sinyal.dart         525888e3da7bc088836e59c55d0ab728c83eba8311620b7be34552c7894f2548
```

Her mutant: değişiklik → `python araclar/cors-kapisi.py .` → sonuç → Edit ile geri alma (asla `git restore` değil) → sha256 doğrulaması.

| mutant | değişiklik | sonuç |
|---|---|---|
| M189 | `app.UseCors();` silindi | **ISIRDI**: `[G35a]` + `[G35b]` |
| M189b | `builder.Services.AddCors(...)` silindi | **ISIRDI**: `[G35a]` + `[G35b]` + `[G35d]`×2 (kollateral — başlık dizgeleri o çağrının içindeydi) |
| M190 | `UseCors` bloğun DIŞINA taşındı (dosyada hâlâ var) | **ISIRDI**: yalnız `[G35b]` — `[G35a]` beklendiği gibi SESSİZ kaldı (dosya geneli arama görür, blok-aralığı arama yakalar) |
| M190b | `AddCors` bloğun DIŞINA taşındı | **ISIRDI**: yalnız `[G35b]` |
| M191 | `WithOrigins(...)` → `AllowAnyOrigin()` | **ISIRDI**: `[G35c]` |
| M191b | Kod bozulmadı; `AllowAnyOrigin` yalnız yorumda | **SESSİZ KALDI** (beklenen — yanlış-pozitif kontrolü) |
| M192 | `Content-Type` başlığı çıkarıldı | **ISIRDI**: `[G35d]` |
| M192b | `X-Momentum-Dev-User` başlığı çıkarıldı | **ISIRDI**: `[G35d]` |
| M193 | Gerçek `app.UseCors();` silindi, `//` yorumda bırakıldı | **ISIRDI**: `[G35a]` + `[G35b]` (`//` yolu ısırdı) |
| M193b | Kod bozulmadı; fazladan `//` yorum eklendi | **SESSİZ KALDI** (beklenen) |
| M193c | Gerçek `app.UseCors();` silindi, `/* ... */` blokta bırakıldı | **ISIRDI**: `[G35a]` + `[G35b]` (K135 blok yolu ısırdı) |
| M194 | `signalr_json_sinyal.dart`: `if (kIsWeb) { ... }` dalı silindi, import bırakıldı | **ISIRDI**: `[G38c]` (çıplak dizge kaçırırdı, yakalandı) |
| M198 | `veritabani.dart`: `MOMENTUM-G6-KANIT` öneki değiştirildi | **ISIRDI**: `[G37d]` |
| M198b | Gerçek `print` silindi, önek `/* ... */` blokta bırakıldı | **ISIRDI**: `[G37d]` |

## Sonuç

**14/14 statik mutant** beklendiği gibi davrandı (12 ISIRDI, 2 — M191b/M193b — beklenen istisna olarak SESSİZ kaldı). Her mutasyon sonrası sha256 taban ile **birebir eşleşti**:
```
src/backend/Momentum.Api/Program.cs                1e31f5b47697c6b342604efe73f070985730820632c4245fb02843795fee8301
src/client/lib/veri/veritabani.dart                fe8f89b4558dbc5fd881e34080bf114e1a3390258e00f38c0e5eae7d0ee09c0f
src/client/lib/ag/signalr_json_sinyal.dart         525888e3da7bc088836e59c55d0ab728c83eba8311620b7be34552c7894f2548
```
Son `cors-kapisi.py .` koşumu: **BULGU YOK**.
