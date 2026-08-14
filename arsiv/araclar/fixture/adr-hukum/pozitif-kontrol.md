# G52/d — pozitif kontrol (ayrı fixture, spec §5/G52/d)

Bu belge `adr-hukum-kapisi.py`'nin G52 tarayıcısının KENDİ TETİK AİLESİNİ
tanıyıp tanımadığını sınar — gerçek bir denetim hedefi DEĞİLDİR.

Bilinen tetik: bu satırın kendisi bir şeyin **ÖLÇÜLEMEDİ** olduğunu iddia
ediyor (D-K170-9 regex ailesi burada tetiklenmelidir). Tarayıcı bu satırı
BULAMAZSA (M271: bu satır silinirse) araç kendi pozitif kontrolünü kaybeder
ve G52/d **ORTAM HATASI** vermek ZORUNDADIR — sessizce YEŞİL DEMEZ.
