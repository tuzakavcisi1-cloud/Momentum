# G55/d — pozitif kontrol (ayrı fixture, spec §5/G55/d)

Bu belge `adr-hukum-kapisi.py`'nin G55 tarayıcısının KENDİ ARAÇ-ADI TESPİTİNİ
tanıyıp tanımadığını sınar — gerçek bir denetim hedefi DEĞİLDİR.

Bilinen araç adı: `radar.py` (bu satırdaki `.py` uzantılı ad tarayıcının
ARAÇ-ADI deseniyle bulunmalıdır). Tarayıcı bu adı BULAMAZSA (M287: bu satır
silinirse) araç kendi pozitif kontrolünü kaybeder ve G55/d **ORTAM HATASI**
vermek ZORUNDADIR — sessizce YEŞİL DEMEZ.
