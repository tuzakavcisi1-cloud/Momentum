# -*- coding: utf-8 -*-
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from yardimcilar import mesaj, kanit_yaz  # noqa: E402

BURASI = os.path.dirname(os.path.abspath(__file__))

gunluk = []
gunluk.append(mesaj("ADIM 6 -- B cevrimici oldu, bekleyen op VARKEN otomatik tur kosuldu (Yenile BASILMADI)"))
gunluk.append(mesaj("Tetikleyici: svc wifi/data enable -> B nin kendi ag/SignalR yeniden baglanma mantigi"))
gunluk.append(mesaj("  (K68 yoklama yasagi geregi olay-tabanli -- sabit sleep/poll DEGIL, postgrese YOKLAMA ile"))
gunluk.append(mesaj("  dogrulandi, uygulamanin KENDI tetikleyicisi degil)"))
gunluk.append(mesaj(""))
gunluk.append(mesaj("OLCUM 1 -- B nin bekleyen B1 opu (op_id=019ff7d5-352e-7518-8e9a-23b128d3f247) postgrese"))
gunluk.append(mesaj("  ULASTI: 13.5 sn de result_code=Applied, first_seen_at=2026-08-12 21:24:06 UTC"))
gunluk.append(mesaj(""))
gunluk.append(mesaj("OLCUM 2 -- sunucu tarafi CRDT birlestirme DOGRU calisti: tasks.title HALA 'A1'"))
gunluk.append(mesaj("  (B nin pushu Applied DONDU ama alan-seviyesi LWW A nin GEC HLC sini korudu -- cakisma"))
gunluk.append(mesaj("  islem seviyesinde degil alan seviyesinde cozuluyor, beklenen mimari)"))
gunluk.append(mesaj(""))
gunluk.append(mesaj("OLCUM 3 -- GORSEL: 09-adim6-B-cakisma-ekran.png -- B nin listesinde satir basligi 'A1'"))
gunluk.append(mesaj("  (sunucunun kazanan degeri, dogru cekildi) VE kirmizi unlem ROZETI goruluyor -- cakisma"))
gunluk.append(mesaj("  ISARETI CIKTI. Liste satirinda YALNIZ rozet var; spec S5'in uyardigi 'rozet tek basina"))
gunluk.append(mesaj("  yeterli degildir' geregi bir sonraki adimda cakisma cozum EKRANININ icerigi de olculecek."))

kanit_yaz(os.path.join(BURASI, "10-adim6-cakisma-gorundu.txt"), gunluk)
print("\n".join(gunluk))
