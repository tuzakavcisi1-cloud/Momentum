# İŞ EMRİ o83-D — `seen` DÖKÜMÜ: PERMÜTASYON MU, UFUK MU?

`MOD: NORMAL` · kutu **18-21 Ağu 2026** · yazan: Cowork · koşacak: **Claude Code**
Kilit: [Onur, 18 Ağu 2026] — o83-C ölçtü: izole 15/15 GEÇTİ, tam pakette 2/2 DÜŞTÜ.
Suçlu `MaxPoolSize` **değil**, bağlam. Şimdi bağlamın **neyi** bozduğu ölçülecek.

---

## 0. DEMİR KURAL

🔴 **ADR YOK · SPEC YOK · kâğıt denetim turu YOK.** Bu bir **ÖLÇÜM**, düzeltme değil.
🔴 **HİÇBİR ŞEY DÜZELTİLMEYECEK.** Ne ürün, ne test iddiası, ne konteyner düzeni.
Bu iş emrinin çıktısı **bir dosya ve bir cevap**tır. Düzeltme kararı Onur'da.

---

## 1. SORU (tek soru, üç olası cevap)

`DispatcherTests.Cursor_correctness_is_unaffected_by_concurrent_dispatch_single_owner`
tam pakette düşerken `seen.Count.ShouldBe(25)` **geçiyor**, `seen[i].ShouldContain("v{i}")`
**düşüyor**. Yani 25 satır var ama sıra tutmuyor.

**Soru: `seen` bir PERMÜTASYON mu (aynı 25 satır, farklı sıra), yoksa TEKRAR/EKSİK mi var?**

| cevap | teşhis | (karar Onur'da) |
|---|---|---|
| Permütasyon | ürün sıra kusuru | senkron vitrininin merkezinde |
| Tekrar ve/veya eksik | sayfalama/ufuk artefaktı | test koşum ortamı |

**Cowork'ün mekanizma adayı (ÖLÇÜLECEK, varsayılmayacak):** `SyncPuller.cs:38`
`WHERE commit_xid < pg_snapshot_xmin(pg_current_snapshot())` — `pg_snapshot_xmin`
**küme-geneldir** (`TestSupport.cs:13` yorumu: *"xid/xmin are cluster-global"*). Test
veritabanı test-başına, **küme 69 test tarafından paylaşılıyor**.

---

## 2. ÖLÇÜM

### 2.1 Bağlam: TAM PAKET

Test **düştüğü yerde** ölçülür — `dotnet test tests/Momentum.Persistence.Tests` (69 test,
tek süreç). İzole koşum **yasak**, o zaten geçiyor (o83-C, 15/15).

Düşene kadar tekrarla, **en fazla 3 koşum**. 3'te de geçerse: "tam pakette bu turda
ÜRETİLEMEDİ" yaz ve **DUR** — o83-C'nin 2/2'si ile çelişir, bu başlı başına bir bulgudur.

### 2.2 Geçici enstrümantasyon

`DispatcherTests.cs`e, **yalnız bu testin içine**, iddia satırlarından **ÖNCE** dökümü yaz.
Assertion'lar **aynen kalır** (gevşetme YOK). Dosyaya yazılacaklar:

1. `seen` listesinin **tamamı**, sırayla, indeksli — her satır için yalnız `"v<N>"` alanının
   değeri (payload'ın tamamı değil, çıktı şişmesin).
2. Beklenen sıra: `v0..v24`.
3. **Türetilmiş üç sayı:** benzersiz eleman sayısı · tekrar eden var mı · eksik olan var mı.
   (Permütasyon ⇔ benzersiz=25, tekrar=0, eksik=0.)
4. `SELECT commit_xid::text, server_seq, payload::text FROM outbox_messages ORDER BY commit_xid, server_seq`
   — ham DB sırası (bu testin veritabanında).
5. `SELECT pg_snapshot_xmin(pg_current_snapshot())::text` ve
   `SELECT max(commit_xid)::text FROM outbox_messages` — **ufuk geride mi**, tek bakışta görünsün.
6. Çekme döngüsünün her turunda: `since` cursor'ı, dönen satır sayısı, `HasMore`.

Çıktı → `KANIT/o83D/01-seen-dokumu.txt`

### 2.3 Enstrümantasyon GERİ ALINIR

Ölçüm bitince `DispatcherTests.cs` **tabana bayt-özdeş** döner.
Kanıt: `sha256` önce/sonra + `git --no-optional-locks diff --stat -- tests/Momentum.Persistence.Tests/DispatcherTests.cs`
**boş**. (o83-C'deki desen; orada çalıştı.)

---

## 3. CEVAP FORMATI

`00-CEVAP.md` içine, başka hiçbir şey olmadan:

1. **Permütasyon mu?** EVET / HAYIR — üç sayıyla (benzersiz · tekrar · eksik).
2. `seen`in ilk 5 elemanı ve beklenen ilk 5 elemanı, yan yana.
3. **Ufuk geride miydi?** `pg_snapshot_xmin` vs `max(commit_xid)` — sayılarla.
4. DB'deki ham sıra (`ORDER BY commit_xid, server_seq`) **doğru** muydu, yani kusur
   **yazmada** mı **okumada** mı?
5. Kaç koşumda üretildi (1/3, 2/3, 3/3).

**Yorum yok, öneri yok, düzeltme yok.** Sayılar ve DUR.

---

## 4. KABUL ÖLÇÜTÜ

- [ ] `KANIT/o83D/01-seen-dokumu.txt` ham çıktıyla var
- [ ] `KANIT/o83D/00-CEVAP.md` §3'ün beş maddesini sayılarla cevaplıyor
- [ ] `DispatcherTests.cs` tabana bayt-özdeş döndü (`sha256` + `git diff --stat` boş)
- [ ] Ürün kodu, test iddiası, konteyner düzeni **değişmedi**

## 5. DOKUNMA LİSTESİ

- ❌ **ÜRÜN KODU** — `src/backend`, `src/client/lib`
- ❌ Testin **iddiaları** — `ShouldBe`/`ShouldContain` satırları aynen kalır
- ❌ `TestSupport.cs` — havuz ayarı bugünkü haliyle (`MaxPoolSize=4`) kalır
- ❌ Konteyner düzeni / `max_connections` / `verify.ps1`
- ❌ Düzeltme önerisi yazmak — §3'te "yorum yok" diyor
- ✅ **İZİN:** `DispatcherTests.cs`e **geçici** enstrümantasyon (§2.2), §2.3 ile geri alınmak üzere
- ❌ Push — push Onur'da.

## 6. YAN İŞ (ölçüm bittikten sonra, tek satır)

`KANIT/o83/_gecici_kanit/`, `KANIT/o83/_verify_stdout.txt`, `KANIT/o83/_verify_stderr.txt`
ve `.git/index.lock.bayat-cowork` kaldırılır.
