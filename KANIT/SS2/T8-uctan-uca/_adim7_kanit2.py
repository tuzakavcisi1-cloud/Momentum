# -*- coding: utf-8 -*-
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from yardimcilar import mesaj, kanit_yaz  # noqa: E402

BURASI = os.path.dirname(os.path.abspath(__file__))

gunluk = []
gunluk.append(mesaj("ADIM 7 (2/2) -- Onur B'de VE A'da Yenile'ye bastigini bildirdi (yaptim)."))
gunluk.append(mesaj(""))
gunluk.append(mesaj("OLCUM -- postgres (backend logu DEGIL):"))
gunluk.append(mesaj("  processed_operations: operation_id=019ff7df-7e5c-7417-bc7f-0eb484d473aa"))
gunluk.append(mesaj("    result_code=Applied, first_seen_at=2026-08-12 21:34:18 UTC -- B'nin"))
gunluk.append(mesaj("    'benimkini tut' yazimi SUNUCUYA ULASTI ve KABUL EDILDI."))
gunluk.append(mesaj("  tasks: entity_id=0000f7c4-89c0-7a40-85ec-464f7516a480 title=B1 is_deleted=f"))
gunluk.append(mesaj("    -- SUNUCUNUN KENDI DEGERI artik B1 (A'nin A1 degerinin UZERINE yazildi,"))
gunluk.append(mesaj("    beklenen: cakisma cozumu YENI ve daha GEC bir HLC ile yazar)."))
gunluk.append(mesaj(""))
gunluk.append(mesaj("A'NIN GORSEL DOGRULAMASI -- [DOGRULANMADI, dogrudan olcum degil]: cihaz A gercek"))
gunluk.append(mesaj("  masaustu Chrome penceresinde (flutter run -d chrome), Claude Code'un computer-use"))
gunluk.append(mesaj("  erisimi salt-okunur/tikla-YASAK tier'da VE dogru pencere/sekme frontmost degildi --"))
gunluk.append(mesaj("  ekran goruntusu dogru pencereyi YAKALAYAMADI. Onur A'da Yenile bastigini SOZLU"))
gunluk.append(mesaj("  bildirdi; bu DOLAYLI kanittir, benim BAGIMSIZ olcumum degildir -- durustce"))
gunluk.append(mesaj("  [DOGRULANMADI] yazildi, 'olculdu' denmedi."))
gunluk.append(mesaj(""))
gunluk.append(mesaj("SONUC: SUNUCU TARAFI (otoriter kaynak) A'ya B1'in ULASTIGINI dogruluyor -- A Yenile'ye"))
gunluk.append(mesaj("  bastiginda SUNUCUDAN B1'i CEKECEK/cekmis olmasi beklenir (kod: elleYenile ->"))
gunluk.append(mesaj("  turCalistir + cekmeTuruCalistir). A'nin EKRANININ bunu GERCEKTEN gosterdigi"))
gunluk.append(mesaj("  BAGIMSIZ GORSEL olarak dogrulanamadi -- beyan edilmis sinir."))

kanit_yaz(os.path.join(BURASI, "13-adim7-benimkini-tut-2-A-ulasti-OLCUM.txt"), gunluk)
print("\n".join(gunluk))
