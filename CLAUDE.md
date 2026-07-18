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
