# CLAUDE.md — Momentum (kalıcı proje talimatı)

> Her oturumda ÖNCE `PROJE_HAFIZA.md` + bu dosyayı TAM oku. Güncel durum ve devir notu orada.

## Çalışma tarzı
- Türkçe çalış. Dürüst ol, bilgi uydurma; emin değilsen söyle.
- Onur onaylamadan büyük/geri alınamaz iş başlatma; komut çalıştırmadan önce ne yapacağını kısaca söyle.
- **Üreten ≠ denetleyen:** hiçbir çıktı kendi üreticisi tarafından onaylanmaz; bağımsız denetçi kapılardan geçer.
- Çıktıyı teslim etmeden önce kendin doğrula (build logu, test, manifest, bağımlılık).

## İş akışı (her dikey dilim) [PAZARLIKSIZ]
`ADR/tasarım kilidi → engineering skill doğrulama → red-team → KİLİT → GOREV_CLAUDE_CODE spec → Claude Code build → verify zinciri (otomatik kapılar) → uzman denetçi ajanlar → red-team EN SON → düzeltme → kapanış + KANIT`

## Denetçi kapıları
- **Otomatik (verify):** backend build+test+analyzer+güvenlik; frontend analyze+test+a11y; OpenAPI kontrat; **taç mücevher kapısı** (senkron/çakışmayı bağımsız 2. implementasyonla doğrula + idempotency). Her kapı MUTANT testiyle ısırdığını kanıtlar (KÖR KAPI YOK).
- **Uzman ajanlar (kilitte):** architecture, code-review, testing-strategy, accessibility-review, risk-assessment, RED-TEAM EN SON.

## Oturum sağlığı ve devir [K21 — PAZARLIKSIZ]
Devir kararı **ölçülür, hissedilmez.** Canlı bağlam = transcript'teki son mesajın
`input + cache_read + cache_creation` toplamı (`~/.claude/projects/*/<oturum-id>.jsonl`; kendi oturum-id'nle).
🟢 **<%55 devam** (devir/temiz-oturum önerisi YOK) · 🟡 **%55-75** eldeki maddeyi bitir, checkpoint yaz,
yeni büyük iş başlatma — **"dolu bağlamda ADR yazma yasağı" BURADAN başlar** · 🔴 **>%75** devir notu yaz, kapat.
**Ölçemezsen yeşil de kırmızı da varsayma: ölçemediğini söyle, Onur'a sor.** Her büyük iş başında ve her
checkpoint'te ölçümü **raporla**.

## Git — sandbox'tan okuma [ÖLÇÜLDÜ, PAZARLIKSIZ]
Cowork bağlı diskte **düz `git status` KOŞMAZ**: mount `unlink`'e izin vermediği için git
`.git/index.lock`'u silemez ve **bayat kilit bırakır** — Onur'un bir sonraki `git add`/`commit`'i
*"Unable to create '.git/index.lock': File exists"* ile patlar. **Her zaman:**
`git --no-optional-locks status --porcelain` (kontrollü testle doğrulandı: kilit bırakmıyor).
Aynı kural `git log`/`git diff` için de geçerlidir. Kilit oluşursa sandbox onu **silemez**,
yalnız `mv` ile kenara alabilir; kalıcı silmeyi Onur yapar.

> ### ⏱ ERRATA (26 Tem 2026, oturum 26 — Onur onayıyla): *"sandbox'tan commit ETME"* KURALININ KAPSAMI ÖLÇÜLDÜ
> Kural **KALDIRILMADI**; **kapsamı** daraltıldı ve gerekçesi yazıya geçti. Yasağın ölçülmüş sebebi **mount'a özgüdür:**
> konteynerin mount'u `unlink`'e izin vermediği için git `.git/index.lock`'u silemez ve **bayat kilit** bırakır.
> - **`device_bash` / mount yolu (`/sessions/.../mnt/...`) ile `git add`/`commit`/`push`: HÂLÂ YASAK.** Kuralın konusu budur.
> - **Desktop Commander ile (Onur'un makinesinde YERLİ PowerShell) commit: İZİNLİ.** Mount yolu kullanılmaz.
>   **Ölçüldü (26 Tem 2026, iki commit — `0c5fbc5` ve `7dcc863`):** ağaç temiz kaldı, `.git/index.lock` **oluşmadı**
>   (`Test-Path .git\index.lock` ⇒ `False`).
> - **PAZARLIKSIZ KOŞUL — her commit'ten SONRA:** `git --no-optional-locks status --porcelain` **ve**
>   `Test-Path .git\index.lock` koşulur; kilit varsa Onur'a **hemen** bildirilir (sandbox onu **silemez**, yalnız `mv` ile kenara alabilir).
> - **`--no-optional-locks` her git çağrısında ZORUNLU kalır** (okuma da yazma da).
> - **PUSH hâlâ Onur'un işidir** — bu errata push'a izin VERMEZ.

## Kırmızı çizgiler (değişmez) [PAZARLIKSIZ]
1. Sırlar repoya girmez (.env + .gitignore + secret yönetimi).
2. PII minimumda; gizlilik-öncelikli.
3. Yeni bağımlılık = lisans + CVE kontrolü.
4. Kalıcı silme / para-hesap işlemi / güvenlik ayarı değişimi → Onur onayı şart.
5. Build artefaktları git-ignore.

## Rol bölümü
Cowork = tasarım/ADR/spec/orkestrasyon/hafıza/denetim; Claude Code = build. Cowork, Code'un beyanına güvenmez; her artefaktı bağımsız doğrular (Desktop Commander ile gerçek FS'ten).

## Hafıza kuralı (checkpoint)
`PROJE_HAFIZA.md` YERİNDE güncellenir — karar/kapı/kilit/devir anında, küçük ve anında. Oturum sonunda toplu yazma YOK. Onur "güncelle" demesini bekleme.

## Ortam
Windows / PowerShell. Kanonik kök: `...\TO DO LİST\Momentum`. Mac yok → iOS CI-only. Build/kod bu klasörde (OneDrive'da değil, senkron derdi yok).
