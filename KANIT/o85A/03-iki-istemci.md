# IS-EMRI-o85-A SS8 madde 3 — İKİ İSTEMCİ (CANLI)

**Ne ölçüldü:** aynı hesabın **iki gerçek istemcisi** (iki farklı `clientId`,
Flutter'ın `SyncPuller`/`SyncPusher`'ının yaptığı HTTP çağrıları elle
tekrarlanarak) — gerçek çalışan backend'e (`docker compose up`, **aynı imaj**,
sunucu kodu bu dilimde değişmedi) karşı. `GET /v1/projects` **yok** (o85-B'nin
işi, §1) ⇒ ölçüm tamamen `/v1/sync` cursor protokolüyledir — §1'in "registry
entityType-agnostik" iddiası burada **canlı olarak sınandı**.

Script: `KANIT/o85A/_canli_tur_o85a.py` · ham çıktı: `KANIT/o85A/03-iki-istemci-ham.txt`
(348 satır, tam JSON gövdeleriyle). Backend: `docker compose up -d` (postgres
sağlıklı + migrator tamamlandı + api `/health/ready` 200).

## Senaryo ve sonuç (6/6 adım GEÇTİ)

| # | Eylem | İstemci | Doğrulama | Sonuç |
|---|---|---|---|---|
| 1 | Liste yarat ("İş") | A | `applied[0].code == "Applied"` | ✅ |
| 2 | **TAZE kurulum**, `sinceCursor:null` | B | A'nın listesi `snapshot`'ta **TAM DEĞERLE** (`name == "İş"`, `entityId` eşleşiyor) | ✅ (C2 kanıtı) |
| 3 | O listede görev yarat ("Rapor yaz", `projectId` **AYNI op'ta**) | A | `applied[0].code == "Applied"` | ✅ (B3 kanıtı) |
| 4 | **ARTIMLI** pull (kendi kaydettiği `nextCursor`'dan) | B | Görev `changes[].payload`'da, `fields.projectId.value == proje_id` **TAM EŞLEŞME** | ✅ |
| 5 | Görevi Gelen Kutusu'na taşı (`projectId: null`) | A | `applied[0].code == "Applied"` | ✅ (B2 kanıtı) |
| 6 | **ARTIMLI** pull | B | `fields.projectId` alanı **VAR** (atlanmadı) VE `value == null` | ✅ |

Her iddia **tam değer eşleşmesiyle** kontrol edildi (yalnız "boş değil" değil)
— o83-G'nin "boş liste her iddiayı geçirir" dersinin bu ölçüme uygulanışı:
script `SystemExit` ile **DÜŞER** eğer beklenen entityId/alan/değer tam olarak
bulunmazsa (bkz. `_canli_tur_o85a.py` içindeki `raise SystemExit("[DÜŞ] ...")`
satırları) — sessizce "geçti" yazmaz.

## Kanıtladığı iş emri maddeleri

- **K1/D1** (liste=Project, gerçek WireOp ile yaratılıyor)
- **C2** (adım 2 — snapshot dalı açılmasaydı B'nin ilk kurulumu listeyi
  GÖRMEZDİ; bu tam olarak "temiz kurulumda liste görünmez" riskiydi, §5 C2)
- **B3** (adım 3 — `title` + `projectId` TEK `WireOp`'ta, iki ayrı op DEĞİL)
- **B2** (adım 5/6 — `Yazim(null)` gerçekten tele çıkıyor: `projectId` alanı
  ATLANMADI, `value:null` olarak taşındı ve karşı taraf bunu ayırt edebildi —
  "alan hiç gelmedi" ile "alan geldi ama null" arasındaki fark KABUL
  maddesinin kalbi)
- **KABUL "bir cihazda oluşturulan liste ötekinde belirir"** ve **"görev
  taşıma ötekinde yansır"** — ikisi de canlı, iki gerçek istemciyle ölçüldü.

## Sınır (dürüstçe belirtilmeli)

Bu ölçüm **protokol seviyesindedir** (HTTP + `/v1/sync`), Flutter UI'ının
kendisi çalıştırılmadı — aynı yöntem o83-G'nin kimlik ölçümünde de kullanıldı
(bkz. `KANIT/o83/_canli_tur.py`) ve gerekçesi aynıdır: istemcinin
`SyncPuller`/`SyncPusher`'ı bu HTTP çağrılarının **birebir aynısını** üretir
(`gorev_deposu.dart`'taki `WireOp(...).toJson()` çağrıları, `liste_dilimi_test.dart`
ve `KANIT/o85A/02-op-ornekleri.json`'daki gerçek çıktılarla birebir aynı
şekildedir) — ekranın kendisi ayrıca `liste_baglam_test.dart` (D4) ve
`liste_dilimi_test.dart` widget/birim testleriyle ölçüldü.
