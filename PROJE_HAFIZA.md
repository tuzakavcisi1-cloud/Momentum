# PROJE_HAFIZA.md — Momentum (Çok Platformlu Görev Yönetimi)

> Bu dosya projenin TEK canlı hafızasıdır. Her oturumda ÖNCE bu dosyayı + `CLAUDE.md`'yi TAM oku.
> Kanonik konum: `C:\Users\gulci\Desktop\MEMO ÖDEV PROGRAMLAR\TO DO LİST\Momentum`

## ⏭ DEVİR NOTU (18 Tem 2026 — oturum 2 kapanış)
- **Son yapılan:** Ortam kuruldu+doğrulandı: **.NET 9 SDK 9.0.316 (64-bit, makine PATH'inde öne alındı)**, **Flutter 3.44.6 + Dart 3.12.2** (`C:\src\flutter`, kullanıcı PATH). **`git init` (branch `main`) + kapsamlı `.gitignore`/`.gitattributes` + ilk commit `a12b3a2`** (14 dosya, iskelet .gitkeep'lerle korundu). Repo kimliği (repo-yerel): Onur Kesim / onurkesimbjk@gmail.com.
- **PostgreSQL — ERTELENDİ (Onur kararı):** Native `initdb` bu makinede çalışmıyor: **sistem locale tr-TR / ANSI cp1254**; initdb "Türkiye"deki non-ASCII `ü`'yü reddediyor. Üç varyasyon (`--no-locale`, açık `--lc-*=C`, ICU) + `LC_ALL=C` env + `Set-Culture` — hiçbiri çözmüyor (sistem locale'i değiştirip reboot gerek). Docker da WSL2 istiyor (kurulu değil → reboot). Karar: **DB ertelendi**, kalıcılık diliminde **Docker** ile kurulacak. Atıl yarım kurulum: `C:\Program Files\PostgreSQL\16` (servis/cluster YOK, port boş; kalıcı silme Onur onayı bekliyor).
- **Sıradaki ilk iş:** Backend **omurga** dikey dilimi → **ADR 0001 (genel mimari: Clean Architecture + senkron stratejisi)** tasarımını işaretlenebilir şıklarla sun → onay → engineering/red-team kapıları → KİLİT → ilk GOREV_CLAUDE_CODE spec (solution + katmanlar + health ucu) → Claude Code build → verify. DB gerektiğinde ayrı adım: Docker (WSL2+reboot).
- **Açık karar:** DB kurulumu kalıcılık diliminde netleşecek (Docker varsayılan). **Dosyalar:** bu dosya + CLAUDE.md.

## PROJE (tek cümle)
Çok platformlu (Flutter: Android/iOS/Web/Windows) + N-katmanlı .NET 9 backend + PostgreSQL ile; çevrimdışı-öncelikli senkron ve gerçek zamanlı işbirliği vitrinli bir görev yönetimi (to-do) uygulaması. Bağlam: önemli bir yazılım şirketinden gelen işe-alım/portfolyo ödevi; **ODAK = mimari & kod kalitesi.**

## KİLİTLENEN KARARLAR
- **Olgunluk:** işlevsel prototip ama deploy-edilebilir KALİTEDE; portfolyo + "yayına götürme sürecini biliyoruz" (CI/CD, store paketleme, imzalama artefaktları — fiilen yayınlanmayacak).
- **Ana vitrin (taç mücevher):** (1) çevrimdışı-öncelikli senkron + çakışma çözümü, (2) gerçek zamanlı işbirliği. **İKİSİ BİRDEN.**
- **Farklılaştırıcılar (dördü de):** NLP hızlı ekleme, Kanban+Takvim görünümü, Time-blocking + Google Takvim, AI asistan (görev bölme/öneri).
- **Çekirdek:** görev/proje/liste/etiket/öncelik/tarih-sontarih/tekrar(RRULE)/hatırlatıcı/arama/karanlık mod.
- **Tempo:** dengeli ~4-6 hafta; strateji **OMURGA-ÖNCE / DİKEY-DİLİM** (önce mimari+senkron+kimlik, sonra özellikler dikey dilim).
- **Teknoloji:** Flutter istemci (local-first: Drift/SQLite + senkron kuyruğu) + .NET 9/ASP.NET Core (Clean Architecture/DDD/CQRS) + PostgreSQL; real-time **SignalR**; AI için **Semantic Kernel**.
- **Platform gerçeği:** Mac YOK. iOS yalnız CI'da (macOS runner) DERLENİR (fiili cihaz/simülatör testi YOK, kod-hazır). Android + Web CANLI. Windows masaüstü bu PC'de derlenebilir (VS C++ toolchain gerekir — sonraki dilimde kurulacak).
- **Figma:** BAĞLANMADI (Flutter widget + design-system dokümanıyla). **GitHub:** bağlanacak — ilk push anında authorize (Claude in Chrome ile).

## DENETÇİ MİMARİSİ (üreten ≠ denetleyen)
- **Katman 1 — Otomatik kapılar (verify zinciri):** backend `dotnet build`+test+analyzer+güvenlik taraması; frontend `flutter analyze`+test+a11y smoke; OpenAPI kontrat testi; **TAÇ MÜCEVHER KAPISI** (senkron/çakışma mantığını uygulama kodunu çağırmadan bağımsız 2. implementasyonla yeniden hesapla + idempotency); her kapı MUTANT testiyle "ısırdığını" kanıtlar (kör kapı yok).
- **Katman 2 — Uzman denetçi ajanlar (her kilit, bağımsız alt-ajan):** mimari (`engineering:architecture`/`system-design`), kod&güvenlik (`engineering:code-review`), test (`engineering:testing-strategy`), UX/a11y (`design:accessibility-review`/`design-critique`), süreç/risk (`operations:risk-assessment` + `engineering:deploy-checklist`), **RED-TEAM EN SON.**
- **İş akışı:** ADR/tasarım kilidi → engineering skill doğrulama → red-team → KİLİT → GOREV_CLAUDE_CODE spec → Claude Code build → verify zinciri → uzman denetçiler → red-team → düzeltme → kapanış + KANIT.
- **Rol bölümü:** Cowork = tasarım/ADR/spec/orkestrasyon/hafıza/kapı; Claude Code = build. Cowork, Code'un beyanına güvenmez; artefaktı bağımsız doğrular.

## KIRMIZI ÇİZGİLER [PAZARLIKSIZ]
1. Sırlar (connection string, API key, JWT secret) repoya GİRMEZ — kullanıcı-sırrı yönetimi/.env + `.gitignore`.
2. Kişisel veri (PII) minimumda; gizlilik-öncelikli tasarım.
3. Bağımlılık eklerken lisans + CVE kontrolü (kapı).
4. Kalıcı silme, para/hesap işlemi, güvenlik ayarı değişimi → Onur onayı olmadan YOK.
5. Build artefaktları (`bin/`,`obj/`,`build/`,`node_modules/`) git-ignore.

## ORTAM DURUMU (18 Tem 2026, Windows PC — oturum 2 tanısı)
- **KURULU:** git, Node/npm, Claude Code (`claude.exe`), Android Studio + Android SDK, winget. Mimari AMD64. Desktop OneDrive'da DEĞİL.
- **.NET (çözüldü ✓):** 64-bit .NET 9 SDK **9.0.316** kuruldu (`C:\Program Files\dotnet`). Eski x86 (`C:\Program Files (x86)\dotnet`, SDK'sız) duruyor ama makine PATH'inde 64-bit **öne alındı** (indeks 0 vs 6). Doğrulandı: `dotnet` → 9.0.316, `--list-sdks` → 9.0.316.
- **Flutter (✓):** Flutter **3.44.6** stable + Dart **3.12.2** (`C:\src\flutter`); `bin` kullanıcı PATH'ine eklendi (yeni terminal görüyor, doğrulandı). Doctor GAP'leri (sonraki dilimlerde çözülecek, omurgayı engellemez): Android cmdline-tools + lisanslar eksik; Visual Studio C++ (Windows masaüstü) yok — doctor VS kontrolü `%PROGRAMFILES(X86)%` env'i olmadığı için çöktü. Chrome(web)+cihazlar OK.
- **git (✓):** Repo başlatıldı — branch `main`, ilk commit `a12b3a2`, `.gitignore`+`.gitattributes` (sırlar/`bin`/`obj`/`build`/`.env` hariç). Kimlik repo-yerel: Onur Kesim / onurkesimbjk@gmail.com.
- **PostgreSQL (ERTELENDİ):** Native `initdb` tr-TR/cp1254 sistem locale'i yüzünden çalışmıyor (non-ASCII `ü`; bayrak/env/culture çözmedi). Atıl yarım kurulum `C:\Program Files\PostgreSQL\16` (servis yok). Karar: kalıcılık diliminde **Docker** (WSL2+reboot gerekli).
- **EKSİK (sonraki dilim):** DB (Docker+WSL2, reboot), VS C++ Build Tools (Windows masaüstü dilimi), Android cmdline-tools+lisans (Android dilimi).

## KARAR GÜNLÜĞÜ
- **18 Tem 2026:** Proje başladı. Pazar+disiplin araştırıldı (2 alt-ajan). Teknoloji .NET+Flutter+Postgres kilitlendi. Denetçi mimarisi onaylandı (`engineering`+`design`+`operations` plugin'leri kuruldu). Kapsam: 2 taç mücevher + 4 farklılaştırıcı, omurga-önce. İsim: **Momentum**. Platform: Mac yok → iOS CI-only. Kurulumlar Onur onayıyla winget'le başladı.
- **18 Tem 2026 (oturum 2 — planlama):** Ortam tanısı: .NET 9 SDK'nın kurulmadığı tespit edildi (devir notu düzeltildi). Onur onayıyla kilitlenen kurulum kararları: bu oturumda tam kurulum, Native PostgreSQL 16 (Docker ertelendi), Flutter git clone stable → `C:\src\flutter`. 64-bit .NET 9 SDK PATH'te öne alınacak; eski x86'ya dokunulmayacak.
- **18 Tem 2026 (oturum 2 — yürütme):** .NET 9 SDK 9.0.316 (64-bit) kuruldu, makine PATH'inde x86'nın önüne alındı (doğrulandı). Flutter 3.44.6 stable kuruldu (`flutter doctor` çalıştı; Android cmdline-tools/lisans + VS C++ eksikleri sonraki dilimlere). `git init` (main) + `.gitignore`/`.gitattributes` + ilk commit `a12b3a2`. **PostgreSQL kararı değişti → ERTELENDİ:** tr-TR/cp1254 sistem locale'i initdb'yi kırıyor (bayrak/env/culture çözmedi); WSL2 yok → native ve Docker ikisi de reboot ister. Onur: DB'yi ertele, kalıcılık diliminde Docker. Atıl `C:\Program Files\PostgreSQL\16` (silme onay bekliyor).

## AÇIK İŞLER / SONRAKİ ADIMLAR
1. ✓ .NET 9 + Flutter kuruldu; `flutter doctor` çalıştı (Android cmdline-tools/lisans + VS C++ sonraki dilimlerde).
2. ✓ `git init` (main) + `.gitignore`/`.gitattributes` + ilk commit `a12b3a2`.
3. **SIRADA:** İlk ADR (`docs/ADR/0001-genel-mimari.md`) — Clean Architecture + senkron stratejisi (tasarımı şıklarla sun → onay → kapılar → kilit).
4. `verify` iskeleti (`tests/`) + ilk mutant/ısırma testi kurgusu.
5. İlk GOREV_CLAUDE_CODE spec (backend omurga: solution + katmanlar + sağlık ucu).
6. DB: kalıcılık diliminde Docker Desktop (WSL2+reboot) → PostgreSQL (compose). Atıl `C:\Program Files\PostgreSQL\16` temizliği (Onur onayıyla).
7. İlk push'ta GitHub authorize (Claude in Chrome ile).
