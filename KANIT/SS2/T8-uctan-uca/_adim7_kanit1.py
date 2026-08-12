# -*- coding: utf-8 -*-
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from yardimcilar import mesaj, kanit_yaz  # noqa: E402

BURASI = os.path.dirname(os.path.abspath(__file__))

gunluk = []
gunluk.append(mesaj("ADIM 7 (1/2) -- Benimkini tut. Onur B de basti, HENUZ HICBIR YERDE Yenile basmadi."))
gunluk.append(mesaj(""))
gunluk.append(mesaj("OLCUM 1 -- GORSEL: 11-adim7-B-benimkini-tut-ekran.png -- B nin listesinde satir basligi"))
gunluk.append(mesaj("  artik 'B1' (PROJEKSIYON YAZILDI, spec'in 'B'nin listesinde B1 gorunur' sarti GECTI)."))
gunluk.append(mesaj("  Rozet yerine kalem-ikonlu 'Gonderilmedi' (not-sent) etiketi goruluyor."))
gunluk.append(mesaj(""))
gunluk.append(mesaj("OLCUM 2 -- B lokal sqlite (adb run-as exec-out): gorevler.baslik=B1,"))
gunluk.append(mesaj("  senkron_durumu=senkronize (lokal DB durumu) ANCAK senkron_kuyrugu HALA 1 satir tasiyor:"))
gunluk.append(mesaj("  op_id=019ff7df-7e5c-7417-bc7f-0eb484d473aa durum=bekliyor deneme_sayisi=0 son_hata_kodu=None"))
gunluk.append(mesaj("  -- yani bu op HENUZ HIC DENENMEDI (basarisiz-yeniden-deneme DEGIL, ilk kez kuyrukta)."))
gunluk.append(mesaj(""))
gunluk.append(mesaj("KAYNAK OKUMA -- src/client/lib/veri/gorev_deposu.dart:435-462 cakismaCoz():"))
gunluk.append(mesaj("  benimkiniTut icin AYNI duzenle() metodunu tek transaction icinde cagiriyor (fields:title"))
gunluk.append(mesaj("  icin), sonra cakisma_kayitlari siliniyor. rozetDikisi() D2 kural 3 (satir 123) BU DURUMU"))
gunluk.append(mesaj("  ONCEDEN ADLANDIRILMIS bir taban durumu olarak modelliyor: 'ucusta=0,bekleyen>0,K!=yerel"))
gunluk.append(mesaj("  => gonderilmemis (YENI)' -- yani B'nin ekranindaki 'Gonderilmedi' etiketi BEKLENEN/"))
gunluk.append(mesaj("  TASARLANMIS bir ara durum, sasirtici bir bulgu DEGIL. S11'in uyardigi sey (cakismaCoz'un"))
gunluk.append(mesaj("  ic transaction/savepoint dogrulugu) burada gozlenmedi -- yazma TEK transaction icinde"))
gunluk.append(mesaj("  basariyla tamamlandi (kuyruk satiri VAR, bozulmus/eksik degil)."))
gunluk.append(mesaj(""))
gunluk.append(mesaj("SONUC: B'nin push'u otomatik TETIKLENMEDI (onYerelYazma widget-seviyesi kancasi cakisma"))
gunluk.append(mesaj("  cozum ekraninda BAGLI DEGIL gibi gorunuyor) -- ama bu, kilitli spec'in kendisinin de"))
gunluk.append(mesaj("  varsaydigi 'A'ya ulasma AYRI bir adimdir, tetikleyici Onur tarafindan YAZILIR' seklindeki"))
gunluk.append(mesaj("  beklentiyle TUTARLI. Sonraki adim: B'de ACIKCA Yenile tetiklenecek (tetikleyici birebir"))
gunluk.append(mesaj("  yazilacak), sonra A'da."))

kanit_yaz(os.path.join(BURASI, "11-adim7-benimkini-tut-1-olcum.txt"), gunluk)
print("\n".join(gunluk))
