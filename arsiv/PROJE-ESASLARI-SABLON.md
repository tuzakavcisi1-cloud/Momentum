# <PROJE ADI> — PROJE ESASLARI (CLAUDE.md)
`MOD: NORMAL` *(para/hukuk/güvenlik projesinde: `MOD: KRİTİK` — tek farkı teslim turu 2 olur)*

> Bu dosya ≤ 8 KB kalır ve projenin TEK talimat dosyasıdır. Yanında tek `DURUM.md` yaşar (≤ 8 KB,
> yerinde güncellenir: ne yapıldı · sıradaki iş · bilinen sınırlar). İsteğe bağlı `ARSIV.md`
> append-only tarihçedir ve AÇILIŞTA OKUNMAZ. Başka canlı belge/defter (borç, kimlik, kapı,
> ortam defteri) AÇILMAZ. Bu iki dosya için kapı, mutant, altın küme yazılmaz; gözle denetlenir.

## 1. NE (≤3 satır)
<Ürün tek cümle. Kim için, hangi platformlar. Varsa işveren brief'inin/ödev metninin yolu.>

## 2. BİTTİ LİSTESİ (≤10 madde, ürün diliyle, kilitli)
*Yasak kelimeler: spec, ADR, kapı, mutant, altın küme, kabul hükmü, borç. Varsa brief/sözleşme
metninden türetilir. Madde eklemek = açık tarih/kapsam kararı. Sayaç (kaç ✅ / toplam) DURUM.md'nin
ilk satırında durur ve dilim kapanışında güncellenir — açılışa ek adım getirmez.*
- [ ] Kullanıcı ...
- [ ] Kullanıcı ...

## 3. SIRADAKİ İŞ (tek madde)
<Şu anki tek dikey dilim. Dikey dilim = veri + arayüz + canlıda çalışır; kullanıcıya görünen
davranışla bitmeden "bitti" sayılmaz. Katman katman ilerlemek yasak.>

## 4. ORTAM MAYINLARI (≤10 satır, yalnız ÖLÇÜLMÜŞ olanlar)
<Örn: mount'ta düz `git status` yasak → `git --no-optional-locks status --porcelain` ·
yollar saf ASCII · push Onur'da · ...>

## 5. KAPSAM DIŞI (kesilenler — gizlenmez)
<Kesilen her bitti-maddesi ve bilinçli yapılmayanlar buraya VE README'ye yazılır.>

---

## İŞLEYİŞ (v2 — TESLİM KURALLARI'nın halefi; değişmez blok)

1. **Takvim kutusu:** her maddeye gün verilir; kutu dolarsa MADDE kesilir, süre uzamaz; kesilen §5'e ve README'ye yazılır. Kalan madde > kalan gün ise hemen kes.
2. **Dikey dilim pazarlıksız** (§3'teki tanım). Dilim sonunda çalışan üründe elle tek doğrulama.
3. **Kapı bütçesi %10:** projeye özel denetim/araç kodu, ürün kodunun %10'unu geçemez (normal birim/widget testleri orana girmez — onlar üründür). Ölçüm tek satırdır, bu dosyanın §4'üne yazılır (örn. `araç dizini satır toplamı / ürün dizini satır toplamı`) ve CI'da koşar; ölçüm için ayrı araç dosyası açılmaz. Aşımda yeni kapı yazılmaz: ya kapı silinir ya kural tek cümleye döner.
4. **Kâğıt denetim turu = 0.** Spec/ADR/plan/iş emri denetlenmez; denetim yalnız koşan artefakta. "Üreten ≠ denetleyen" TESLİMDE uygulanır: kullanıcıya değen her teslimde TEK bağımsız tur, CANLI çıktıya bakılır (`MOD: KRİTİK` ise 2 tur). Ajan beyanları güvenilirdir; teslim başına rastgele 1 beyan doğrulanır — sonucu DURUM.md "bilinen sınırlar"a tek cümle yazılır; tutmazsa o dilim %100 doğrulamaya döner. Ayrı sicil defteri açılmaz.
5. **Açılış ≤3 komut:** git durumu · DURUM.md · test durumu. Kapılar CI'da koşar, oturumda değil.
6. **Borç defteri tutulmaz.** Üç seçenek: ŞİMDİ YAP · KAPSAMDAN KES (§5 + README) · SİL.
7. **Tek vitrin.** İkinci "vay" birincinin bitişini geciktirir; diğerleri §5'e.
8. **Kural yaşam döngüsü:** kalıcı kural ancak aynı sınıf İKİ kez ısırınca doğar; ya CI'da mekanik koşar ya tek cümledir; §4'e girer ve girerken bir satır silinir. Kurallar birbirine kimlik numarasıyla atıf veremez. Olay bir kez ısırdıysa yeri DURUM.md "bilinen sınırlar"dır, kural değil.
9. **Haftalık tek soru:** "Bu hafta bitti listesinde kaç madde ✅'ye döndü?" Cevap 0 ise o hafta yapılan her şey gözden geçirilir.
10. **Taban:** bu dosya için kapı/mutant/altın küme/denetim turu yazılmaz. Çelişki çıkarsa öncelik: MUTLAK SINIRLAR > global anayasa > bu dosya > diğer her şey.
