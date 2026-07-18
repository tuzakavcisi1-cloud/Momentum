# Kalan Kurulum Adımları — Onur (kendi terminalinde)

> **Bağlam:** GitHub bağlantısı + ADR 0002 tamam. Bu 3 kurulum **slice-2a'ya (sıradaki kod işi) gerekmez**; Android / Windows-masaüstü / DB dilimlerinde lazım olacak. Cowork'teki DC bağlantısı kararsız olduğundan bunları **kendi terminalinde** koşmak en güvenilir yol.
>
> **ÖNEMLİ:** winget sistem kurulumları ve `wsl --install` **Yönetici PowerShell** ister → Başlat → "PowerShell" → sağ tık → **"Yönetici olarak çalıştır"**. Android adımı admin istemez.
>
> **Sıra:** Android → VS C++ → Docker → WSL2 → **tek reboot en sonda**.

---

## 1) Android SDK Command-line Tools + lisanslar  (admin YOK, reboot YOK)

En güvenilir yol Android Studio üzerinden (URL sürüm derdi olmasın):

1. **Android Studio** → **Settings → Languages & Frameworks → Android SDK → "SDK Tools" sekmesi**
2. **"Android SDK Command-line Tools (latest)"** kutusunu işaretle → **Apply / OK** (indirir)
3. Normal (admin olmayan) terminalde lisansları kabul et:
   ```powershell
   flutter doctor --android-licenses
   ```
   Çıkan tüm sorulara `y`. Sonra `flutter doctor` ile teyit et.

---

## 2) Visual Studio C++ Build Tools  (ADMIN, reboot YOK, ~birkaç GB)

Yönetici PowerShell'de:
```powershell
winget install --id Microsoft.VisualStudio.2022.BuildTools -e --accept-package-agreements --accept-source-agreements --override "--quiet --wait --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"
```
Flutter'ın Windows masaüstü derlemesi için MSVC + Windows SDK kurar. UAC çıkarsa onayla.
*(Not: `flutter doctor` sonrasında hâlâ C++ isterse, alternatif: VS Community + "Desktop development with C++" workload'u.)*

---

## 3) Docker Desktop  (ADMIN, kurulum reboot istemez)

Yönetici PowerShell'de:
```powershell
winget install --id Docker.DockerDesktop -e --accept-package-agreements --accept-source-agreements
```

---

## 4) WSL2  (ADMIN) → sonra REBOOT

Yönetici PowerShell'de:
```powershell
wsl --install
```
WSL2 + varsayılan Ubuntu'yu kurar ve gerekli Windows özelliklerini açar. **Bittiğinde bilgisayarı yeniden başlat.**

---

## Reboot sonrası — doğrulama

Yeni terminalde:
```powershell
wsl -l -v
docker --version
flutter doctor
```
- **Docker Desktop'ı bir kez aç** (WSL2 backend'i devreye alsın).
- **PostgreSQL'i bu adımda kurma** — slice-2b'de Docker Compose ile gelecek.

---

## Opsiyonel — PATH hijyeni (build'i etkilemiyor)
Bazı kabuklar SDK'sız x86 `dotnet`'i öne alıyor; 64-bit SDK (`C:\Program Files\dotnet`, 9.0.316) kurulu ve Claude Code onu doğru kullanıyor (slice-1 derlendi). İstersen makine PATH'inde 64-bit'i x86'nın önüne aldırırız — Cowork'te "PATH'i düzelt" de, yaparım.

---
*Bittiğinde/ tamamladığın adımları söyle; hafızaya (PROJE_HAFIZA) işlerim. slice-2a spec'i temiz yeni oturumda "başla" ile.*
