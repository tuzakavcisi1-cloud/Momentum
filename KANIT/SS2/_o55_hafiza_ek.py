# -*- coding: utf-8 -*-
# K133-EK: budama olculdu; K133'un "T2 hala SARI" cumlesi bayatladi, duzeltme kaydi.
import sys, os, hashlib
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
YOL = r"C:\dev\Momentum\PROJE_HAFIZA.md"
ANCHOR = """kodu `T1`'de **Claude Code'un elinden** girer. Şık metnindeki *"ürün kodu akar"* ifadesi **sonraki
el** içindir; radar bir sonraki koşumda **üçüncü sıfırı** görecektir.
"""
EK = ANCHOR + """
## K133-EK — `DURUM.md` §5 BUDANDI (Onur kilitledi, aynı oturum)

🔴 **K133'ün kendi kusuru AYNI OTURUMDA kapatıldı.** Yukarıda *"budama tahmin edildi, ölçülmedi;
`T2` hâlâ SARI"* yazıyor — **o cümle artık bayattır** ve düzeltmesi budur.

Onur budamayı kilitledi. `DURUM.md` §5'teki dört kilidin (`K58` · `K117/K126` · `K127` ·
`K129/K130`) **GEREKÇESİ** hafızaya devredildi, **BEYANLARI korundu**: banner bayatlığı
(`B-O50-2`) · tavan bedeli · K127'nin kapısızlığı (`B-O52-2`) · `A13`'ün yaşayan beş sınırı
(`B-O53-1`…`5`). Gizlenmiş sınır **üretilmedi**.

**Kanonik gerekçe:** §5 başlığının kendisi *"tek satır; gerekçe `PROJE_HAFIZA.md`'de"* diyor ve bu
dört madde **kendi kurallarını ihlal ediyordu** (5–10 satır). Üstelik `K58` ile `K117/K126`'nın
gerekçe metni `belge-tavan-kapisi.py`'nin **KENDİ banner'ında zaten yazılı** ⇒ `DURUM.md`'deki
kopya bir `kanonik-kopya` kusuruydu (radar bu sınıfı bu dosyada **5 turdur** sayıyor).

**ÖLÇÜLDÜ — TAHMİN EDİLMEDİ:** 31.610 → **30.588 b** · sha8 **`431D2FE7`** · delta **−1.022** ·
pay **2.180 b** (eşik 1.638) ⇒ `T2` `DURUM.md` için **YEŞİL**. `tek-kopya` YEŞİL (canlı budama
**%3,2** < %10 sınırı) · `sayi-tazeligi` TEMİZ. Betik pay değerini **kendi ölçümünden** deftere
yazdı; bu, K133'te ısıran `olcum-aracinin-varsayimi` sınıfının mekanik karşılığıdır.

🔴 **`BORCLAR.md` BİLEREK SARI BIRAKILDI** (pay **857 b**). `K117`/`K126`'nın kendi ölçülmüş dersi:
*"bu dosyada budama ancak bir borç KAPANDIĞINDA işe yarar"* — bu turda kapanan borç **yok**, açılan
**dört** var (`B-SS2-1`…`4`). Tavan kararı `K40` gereği **Onur'da**; `SS2` `T1`–`T8` bitip borçlar
kapanınca yeniden bakılır. **Beyan edilmiş sınır:** bir sonraki checkpoint `BORCLAR.md`'ye yazarsa
`T1` KIRMIZI verecektir.
"""
with open(YOL, "rb") as f: ham = f.read()
metin = ham.decode("utf-8")
if metin.count(ANCHOR) != 1:
    print("HATA: anchor %d kez bulundu." % metin.count(ANCHOR)); sys.exit(2)
metin = metin.replace(ANCHOR, EK, 1)
yeni = metin.encode("utf-8")
if len(yeni) <= len(ham):
    print("HATA: append-only dosya buyumedi."); sys.exit(3)
tmp, yedk = YOL + ".tmp", YOL + ".yedek"
with open(tmp, "wb") as f: f.write(yeni)
if os.path.exists(yedk): os.remove(yedk)
os.rename(YOL, yedk)
try: os.rename(tmp, YOL)
except Exception as e:
    os.rename(yedk, YOL); print("HATA: takas patladi, GERI ALINDI:", e); sys.exit(4)
with open(YOL, "rb") as f: son = f.read()
if son != yeni:
    os.remove(YOL); os.rename(yedk, YOL); print("HATA: sha uyusmadi, GERI ALINDI."); sys.exit(5)
os.remove(yedk)
print("PROJE_HAFIZA.md: %d -> %d bayt (+%d)" % (len(ham), len(son), len(son)-len(ham)))
