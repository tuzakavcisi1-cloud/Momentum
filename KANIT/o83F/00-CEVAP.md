# IS-EMRI-o83-F — CEVAP

1. **Ölçülen X / seçilen B / yazılan xid / satır sayısı:** Test1: X=745, B=100, xid=[88..112], 25 satır. Test2: X=752, B=100 (yakılan işlem=0, X zaten >599), xid=[90..599], 510 satır (=B/10 + 500).
2. **Düzeltme öncesi:** Test1 = **Failed** (`page.Changes[0].PayloadJson` beklenen `"v0"` yerine `{"title": "v12"}`). Test2 = **Failed** (`seen.Count` beklenen `510`, gerçek `500` — 10 kayıp).
3. **Düzeltme sonrası:** Test1 = **Passed**. Test2 = **Passed**.
4. **Tam paket 3 koşum:** her koşumda 71/71 geçti, 0 başarısız (69 mevcut + 2 yeni). `Cursor_correctness_is_unaffected_by_concurrent_dispatch_single_owner` outcome: koşum 1/3 = **Passed**, koşum 2/3 = **Passed**, koşum 3/3 = **Passed** — yanlışlanabilir tahmin doğrulandı, kovalama yok.
5. **`SyncPuller.cs`te değişen satır sayısı:** `git diff --stat` = 3 eklenen / 2 silinen satır = 1 yorum satırı + tek `command.CreateRawCommandAsync` ifadesi içindeki 2 satır (SELECT listesi, ORDER BY).
6. **`git status --porcelain -- src tests`:** ` M src/backend/Momentum.Infrastructure/Sync/SyncPuller.cs` · `?? tests/Momentum.Persistence.Tests/PullCursorOrderTests.cs` — başka hiçbir dosya yok. `DispatcherTests.cs`: bu emir başlamadan ÖNCE zaten sha256 ile taban ile bayt-özdeşti (o83-D'nin geçici enstrümantasyonu daha önce geri alınmıştı) — bu emirde ona dokunulmadı.
