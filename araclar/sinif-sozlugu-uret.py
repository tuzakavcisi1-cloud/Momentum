# -*- coding: utf-8 -*-
"""GOREV-ADR0004-KAPISI T1 -- `araclar/sinif-sozlugu.json`'un ÜRETİCİSİ (K148-b).

Başlangıç kümesi PROJE_RADAR.jsonl'daki TÜM kayıtların `siniflar` alanlarından
BETİKLE türetilir (ELLE SAYILMAZ). Bu betik bir KEZ çalıştırılıp çıktısı
`araclar/sinif-sozlugu.json`'a yazılır; sonraki her yeni sınıf adı için sözlük
ELLE (bu betik yeniden koşulmadan) güncellenir -- D-K170-5 defterin append-only
olduğunu, sözlüğün ise canlı bir belge olduğunu ayırır.

`tanim` alanları bu betiği yazan elin (Claude Code) bu projedeki 67 oturumluk
sözlüğe dayanan YORUMUDUR -- her biri PROJE_RADAR.jsonl'daki gerçek kullanım
bağlamından (defterin `not` alanları) OKUNARAK yazılmıştır, uydurulmamıştır.
"""
import hashlib
import json
import os
import sys
import difflib

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

KOK = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DEFTER = os.path.join(KOK, "PROJE_RADAR.jsonl")
HEDEF = os.path.join(KOK, "araclar", "sinif-sozlugu.json")

TANIMLAR = {
    "alinti-beyan-ayrimi": "Bir metnin ALINTI mı yoksa BEYAN mı olduğu ayrıştırılmamış; ikisi karıştırılınca kaynak-atıf ölçümü yanlış sonuç verir.",
    "arac-bicim-uyusmazligi": "Bir aracın beklediği girdi biçimi (dizin/dosya, bayrak) ile çağıranın verdiği biçim uyuşmuyor.",
    "arac-yanlis-pozitifi": "Ölçüm aracının KENDİSİ, ürün kusuru olmadığı hâlde bir bulguyu yanlışlıkla KIRMIZI/pozitif işaretliyor.",
    "artefakt-buyumesi": "Bir belge/spec turdan tura büyüyor ve büyüme kendi başına yeni çapraz-atıf/çelişki kusuru doğuruyor (R4 freninin konusu).",
    "atif-edilen-dosya-depoda-yok": "Bir metin var-olmayan bir dosyaya `dosya:satır` biçiminde atıf yapıyor.",
    "baglanamayan-iddia": "Bir iddianın dayandığı ağ kaynağına/servise bağlanılamıyor (ORTAM HATASI sınıfının konusu).",
    "bayat-atif": "Bir atıf (kimlik, sayı, konum) yazıldığı andan sonra kaynağı değişmiş ve güncellenmemiş.",
    "bayat-capraz-atif": "İki belge birbirine atıf yapıyor ama biri güncellenince öteki BAYATLADI.",
    "bayat-defter-beyani": "Bir defter/kayıt satırı, kendi güncel durumunu yansıtmayan eski bir beyan taşıyor.",
    "bayat-iddia": "Bir zamanlar doğru olan ama artık gerçeği yansıtmayan, güncellenmemiş bir iddia.",
    "bayat-sayi-kopyasi": "Bir sayı (bayt/satır/adet) başka bir yere kopyalanmış ve kaynağı değişince kopya BAYATLAMIŞ.",
    "belge-tavani": "Bir belgenin bayt tavanını aşması/aşma riski taşıması (belge-tavan-kapisi.py'nin konusu).",
    "beyan-olcum-ayrismasi": "Bir belgenin BEYAN ettiği değer ile gerçek ÖLÇÜMÜN birbirinden AYRIŞMASI (henüz çelişki denecek kadar keskin değil).",
    "beyan-olcum-celiskisi": "Bir belgenin BEYAN ettiği değer ile gerçek ÖLÇÜM doğrudan ÇELİŞİYOR.",
    "beyanli-sinir-kapandi": "Daha önce açıkça beyan edilmiş bir sınır, bu turda ölçülerek KAPATILDI (olumlu kapanış kaydı).",
    "beyansiz-sinir": "Bir ölçülmemiş/eksik alan spec'te BEYAN EDİLMEDEN bırakılmış.",
    "beyansiz-tercih": "Birden çok seçenek arasında bir tercih yapılmış ama gerekçesi/beyanı yazılmamış.",
    "bicim-K81": "K81'in zorunlu kıldığı spec başlık biçimine (## 5. KAPILAR / ## 6. MUTANTLAR) uyulmaması.",
    "bicim-ihlali": "Bir aracın/belgenin beklenen biçim sözleşmesini (genel) ihlal etmesi.",
    "bozuk-ikili-kanit": "İkili (binary) bir kanıt dosyası bozuk/okunamaz durumda.",
    "cagrilmayan-kapi": "Var olan bir kapı, açılış/checkpoint protokolünde HİÇ çağrılmıyor (kör kapı kadar kör).",
    "capraz-atif": "İki belge/dosya birbirine atıf yapıyor; atfın güncelliği ayrıca izlenmesi gereken bir yüktür.",
    "checkpoint-gecikmesi": "Bir karar/kilit anında yazılması gereken checkpoint GECİKEREK yazıldı.",
    "cift-olcen-vaka": "Aynı vakayı iki farklı ayak/mutant AYNI ANDA ölçüyor -- kapsama iddiası şişirilmiş olabilir.",
    "cozulemeyen-ad": "Bir sembolik ad (sabit/değişken) statik olarak koda çözülemiyor.",
    "cozum-yeterliligi-olculmedi": "Önerilen bir çözümün asıl sorunu YETERİNCE çözüp çözmediği hiç ölçülmemiş.",
    "crlf-sizmasi": "LF bekleyen bir dosyaya CRLF (satır sonu) sızması (K60/append-only yazım kusuru).",
    "dairesel-kanit": "Bir kanıt, kendi ürettiği aracın çıktısına dayanıyor -- döngüsel doğrulama.",
    "defter-durustlugu": "Bir defter (PROJE_RADAR.jsonl vb.) kaydının kendi ölçtüğü şeyi dürüstçe yansıtıp yansıtmadığı (D1-D5).",
    "defter-yazilmadi": "Bir kilit/karar anında defter kaydı YAZILMASI gerekirken yazılmamış.",
    "desen-taklidi": "Bir metin, gerçek bir ölçüm deseninin YÜZEYSEL taklidini taşıyor ama gerçek koşulu sağlamıyor.",
    "devralinmis-kirmizi": "Bir önceki turdan devralınan KIRMIZI bulgu bu turda da düzeltilmeden duruyor.",
    "doktrin-celiskisi": "Projenin iki kuralı/doktrini birbiriyle ÇELİŞİYOR.",
    "eksik-envanter": "Bir envanter tablosu (KAPILAR.md, DURUM.md §6) gerçek dosya kümesinin GERİSİNDE kalmış.",
    "el-dagilimi-yok": "Bir spec, işi HANGİ ELİN (Claude Code/Cowork/Onur) yapacağını YAZMAMIŞ.",
    "envantersiz-kapi": "Yazılmış bir kapı, hiçbir envanter tablosunda GÖRÜNMÜYOR (üç kez ısırmış sınıf).",
    "esdeger-mutant": "Bir mutant, hedeflediği kuralın ÇEKİRDEK iddiasını aslında hiç ölçmüyor (eşdeğer/etkisiz mutasyon).",
    "fikirsiz-uretec": "Deterministik olması gereken bir üreteç (ID/sha) koşumdan koşuma FARKLI sonuç veriyor.",
    "gizlenmis-sinir": "Bir sınır/eksiklik AÇIKÇA BEYAN EDİLMEDEN gizli tutulmuş (beyansiz-sinir'in kasıtlı hâli).",
    "ic-celiski": "Bir belgenin/spec'in İÇİNDE iki cümlesi birbiriyle çelişiyor.",
    "k60-ihlali": "K60'ın atomik-yazım kuralı (tmp->takas) ihlal edilmiş, yarım/bozuk dosya riski doğmuş.",
    "kagit-test-celiskisi": "Kâğıt üzerinde (paper review) doğru görünen bir iddia, gerçek koşumda ÇELİŞİYOR.",
    "kanit-eksik": "Bir iddianın arkasında KANIT dosyası/ölçümü eksik.",
    "kanit-eksikligi": "Sunulan kanıtın kendisi YETERSİZ/eksik kalmış (kanit-eksik'in kanıtın niteliğine odaklı hâli).",
    "kanit-kisaltmasi": "Bir kanıt, tam ham çıktı yerine KISALTILMIŞ/özetlenmiş biçimde sunulmuş.",
    "kanit-yolu-uyusmazligi": "Bir belgenin belirttiği kanıt DOSYA YOLU ile gerçek konum UYUŞMUYOR.",
    "kanit-zehirlenmesi": "Bir kanıt, kendi ölçtüğü şeyi bozacak biçimde başka bir süreçten KİRLENMİŞ.",
    "kanonik-kopya": "Bir metin, kanonik kaynağından KOPYALANIP değiştirilmiş (kaynak değişince kopya sessizce BAYATLAR).",
    "kapi-celiskisi": "İki kapı/ayak AYNI konuda birbiriyle ÇELİŞEN hüküm veriyor.",
    "kapisiz-kilit": "Bir kilit/karar alınmış ama onu ZORLAYAN mekanik bir kapı YOK.",
    "kapisiz-teslimat": "Bir iş teslim edilmiş ama onu doğrulayan kapı hiç KOŞULMAMIŞ.",
    "kapsam-boslugu": "Bir spec'in KAPSAM bölümü, gerçekte etkilenen bir alanı BOŞ bırakmış.",
    "kapsam-disi-ayni-sinif": "Kapsam dışı bırakılmış bir alanda AYNI kusur sınıfı yine de görülüyor.",
    "kapsam-yazilmamis": "Bir aracın/kapının KAPSAMI (neyi ölçüp neyi ölçmediği) yazılı değil.",
    "kaynagini-eksik-okuma": "Bir el, atıf yaptığı kaynağı TAM OKUMADAN üzerine hüküm kurmuş.",
    "kendi-beyanini-okumama": "Bir el, kendi ÖNCEDEN yazdığı beyanı/sınırı unutup yeniden aynı kusuru yapmış.",
    "kendi-kusurunu-uretme": "Bir ölçüm aracı, ÖLÇTÜĞÜ ürün değil KENDİ kusurunu bulguya yazmış.",
    "kilit": "FAZ İŞARETİDİR -- checkpoint'in 'karar KİLİTLENDİ' anını imler; gerçek bir kusur SINIFI DEĞİLDİR (kriter 9).",
    "kilit-kapsam-tasmasi": "Bir kilit kararı, üzerinde anlaşılan KAPSAMIN dışına taşıp başka bir alanı da bağlamış.",
    "kilit-sonek-normalize": "Kilit kimliklerinin (K21 vb.) sonek/varyant biçimleri NORMALİZE edilmeden karşılaştırılmış.",
    "kodlama-bozulmasi": "Bir dosyanın karakter kodlaması (UTF-8/cp1254 vb.) BOZULMUŞ, karakterler hatalı çıkmış.",
    "kor-harness": "Bir test/ölçüm harness'i, ölçmesi gereken sınıfı GÖRMEDEN yeşil veriyor.",
    "kor-kapi": "Bir kapı BULGUSUZ (yeşil) dönüyor ama gerçekte hiç ISIRMIYOR -- mutantla kanıtlanmamış.",
    "kor-kriter": "Bir kabul kriteri, gerçekte hiçbir kusuru YAKALAYAMAYACAK biçimde yazılmış.",
    "kor-mutant": "Bir mutant, hiçbir ayağı KIRMIZIYA düşürmeden sessizce geçiyor (ölü mutantın bir türü).",
    "kosulamaz-kabul-sarti": "Bir kabul kriteri, bu ortamda FİİLEN koşulamayacak bir önkoşula bağlanmış.",
    "kriter-ici-celiski": "Tek bir kabul kriterinin İÇİNDE birbirini yalanlayan iki şart var.",
    "mekaniklestirme": "FAZ İŞARETİDİR -- checkpoint'in 'K53/2 gereği mekanik kapıya geçildi' anını imler; kusur SINIFI DEĞİLDİR (kriter 9).",
    "olcemedigini-sanmak": "Bir el, aslında ölçülebilecek bir şeyi 'ölçülemez' SANIP hiç denememiş.",
    "olculemedi-sanmak": "Bir belge bir şeyi '[ÖLÇÜLEMEDİ]' diye İŞARETLEMİŞ ama fiilen ölçüm mümkünmüş (olcemedigini-sanmak ile aynı köke yakın, farklı yazım/turda doğdu -- D-K170-5 geçmişi onarmaz).",
    "olculemez-assert": "Bir test/kapı, hiçbir girdiyle asla tetiklenemeyecek bir `assert` taşıyor.",
    "olculemez-kapi": "Bir kapı, tasarımı gereği HİÇBİR mutantla ısırtılamıyor.",
    "olculemez-kriter": "Bir kabul kriteri, ölçülebilir bir sonuca BAĞLANAMAMIŞ (soyut/öznel).",
    "olculmemis-etiket": "Bir metne 'ölçüldü' etiketi konmuş ama arkasında gerçek bir ölçüm YOK.",
    "olculmemis-iddia": "Bir iddia hiçbir ölçümle DESTEKLENMEMİŞ.",
    "olculmemis-tahmin": "Bir sayı/sonuç TAHMİN edilmiş ama `[TAHMİN]` diye işaretlenmemiş.",
    "olculmemis-varsayim": "Bir varsayım (ör. ortam/araç davranışı) hiç TEST EDİLMEDEN doğru kabul edilmiş.",
    "olculmeyen-kapsam": "Bir kapının/kapının kapsamının bir KISMI hiçbir ayakla ölçülmüyor.",
    "olculmus-mayini-recete-etme": "Daha önce ISIRDIĞI ölçülmüş bir ortam mayını, aynı reçeteyle tekrar ÖNERİLMİŞ.",
    "olculmus-uyariyi-yok-sayma": "ORTAM.md/CLAUDE.md'de ÖLÇÜLMÜŞ bir uyarı bilerek ya da bilmeyerek YOK SAYILMIŞ.",
    "olcum-araci-boslugu": "Belirli bir sınıfı ölçecek HİÇBİR araç yok (envanterde boşluk).",
    "olcum-aracinin-varsayimi": "Ölçüm ARACININ KENDİSİ, doğrulanmamış bir varsayımı davranışına GÖMMÜŞ.",
    "olcum-ayagi-yanlis": "Bir ayağın ölçüm MANTIĞI yanlış kurulmuş (yanlış değişkeni/dosyayı okuyor).",
    "olcum-belirsizligi": "Bir ölçümün SONUCU birden çok şekilde yorumlanabilir, tek bir hükme varmıyor.",
    "olcum-noktasi-yok": "Bir iddia için ÖLÇÜLECEK somut bir nokta/koordinat hiç tanımlanmamış.",
    "olcum-ortami-kusuru": "Bulgu ürün kusuru DEĞİL, ölçümün koştuğu ORTAMIN kendi kusuru.",
    "olcum-sanilan-varsayim": "Bir VARSAYIM, fiilen yapılmış bir ÖLÇÜM sanılıp öyle sunulmuş (olcum-aracinin-varsayimi'ndan farklı: burada hata YORUMLAMADA, orada ARACIN kendi tasarımında).",
    "olgusal-yanlis-iddia": "Bir iddia, doğrulanabilir bir OLGUYLA doğrudan ÇELİŞİYOR.",
    "olu-ayak": "Bir kapı ayağı artık hiçbir vakayı ÖLÇMÜYOR ama hâlâ tabloda duruyor.",
    "olu-beyan": "Artık geçerli olmayan bir beyan, güncellenmeden belgede KALMIŞ.",
    "olu-dosya": "Kullanılmayan/atıfsız bir dosya depoda GEREKSİZ yer kaplıyor.",
    "olu-mutant": "Bir mutant uygulandığında HİÇBİR ayağı kırmızıya düşürmüyor (kapıyı ısırmıyor).",
    "olu-mutant-onarimi": "Ölü çıkan bir mutant, hedefini ısıracak biçimde ONARILMIŞ.",
    "olu-tuzak": "Bir kapıya konan tuzak/pozitif kontrol artık hiçbir girdiyle TETİKLENEMİYOR.",
    "onarim-komsu-satiri-bozdu": "Bir satırı düzeltirken KOMŞU satır yanlışlıkla bozulmuş.",
    "radar-kirmizisini-olcmeden-tur-acmak": "Radar KIRMIZI iken, o kırmızıyı ÖLÇMEDEN yeni bir kâğıt/spec turu açılmış (K40 ihlali).",
    "saat-sapmasi-olculmemis": "Cowork'ün UTC saat sapması (ORTAM.md) bir checkpoint'te ÖLÇÜLMEDEN tarihe yansımış.",
    "sabit-windows-yolu": "Bir betikte Windows'a ÖZGÜ sabit bir yol, taşınabilirlik gözetilmeden gömülü.",
    "sahte-yesil": "Bir adım yapılmamışken/okunmamışken 'yapıldı/okundu' diye İŞARETLENMİŞ.",
    "sarkan-atif": "Bir atıf (dosya:satır) artık VAR OLMAYAN bir konuma işaret ediyor.",
    "sayi-tutarsizligi": "Aynı şeyi sayan iki yer FARKLI sayı veriyor.",
    "sessiz-veri-kaybi": "Bir işlem veri kaybediyor ama hiçbir HATA/uyarı vermiyor.",
    "sessiz-yutma": "Bir hata/istisna GÖRÜNMEDEN yutuluyor, çağıran yeşil sanıyor.",
    "tablo-hucre": "Bir tablo hücresi (KAPILAR.md/DURUM.md) yanlış/eksik değer taşıyor.",
    "tatmin-edilemez-ayak": "Bir kapı ayağı, tasarımı gereği HİÇBİR gerçek girdiyle tatmin edilemiyor.",
    "ters-yon": "Bir karşılaştırma/atıf BEKLENENİN TERSİ yönde kurulmuş (A→B yerine B→A).",
    "uygulanamaz-mutant": "Tanımlanan bir mutant, bu ortamda/kodda FİİLEN uygulanamıyor.",
    "vaka-degil-sinif": "Bir denetim bulgusu TEK BİR VAKAYI kapatmış ama altındaki genel SINIFI kapatmamış (K161).",
    "var-olmayan-artefakta-hukum": "Bir belge, henüz VAR OLMAYAN bir artefakt üzerine hüküm kuruyor.",
    "yanlis-hedef-fonksiyon": "Bir mutant/kapı, hedeflediğini SANDIĞI fonksiyondan FARKLI bir fonksiyonu değiştiriyor/ölçüyor.",
    "yanlis-kapsam": "Bir kural/araç, belirtilenden FARKLI bir kapsamı ölçüyor.",
    "yanlis-pozitif": "Bir kapı, gerçekte sorun olmayan bir durumu HATALI biçimde KIRMIZI gösteriyor.",
    "yanlis-pozitif-taban": "Yanlış-pozitifin dayandığı TABAN/pin değeri kendisi hatalı (yanlis-pozitif'ten farklı: burada hata sonuçta değil referans değerde).",
    "yanlis-sinif-beyani": "Bir bulgu, gerçek kök nedeninden FARKLI bir kusur sınıfına YAZILMIŞ.",
    "yeni-mayin": "Bu turda YENİ keşfedilmiş, ORTAM.md'ye henüz eklenmemiş bir ortam mayını.",
}

AYRI_TUTULDU_GEREKCELERI = {
    ("kanit-eksik", "kanit-eksikligi"):
        "Yüzeysel benzer ama odak farklı: 'kanit-eksik' bir İDDİANIN arkasında kanıt dosyasının hiç OLMAMASI; "
        "'kanit-eksikligi' VAR OLAN kanıtın NİTELİK olarak yetersiz kalmasıdır. D-K170-5 geçmişi onarmaz: "
        "iki ad da PROJE_RADAR.jsonl'da farklı turlarda gerçek bulgulara yazılmış, birleştirilmez.",
    ("olcemedigini-sanmak", "olculemedi-sanmak"):
        "Aynı köke yakın iki yazım -- biri EYLEME odaklı ('sanıp denememek'), diğeri BELGENİN ETİKETİNE "
        "odaklı ('[ÖLÇÜLEMEDİ] diye işaretlemek'). D-K170-5 gereği geçmiş kayıtlar (append-only) "
        "birleştirilmez; ADR 0004'ün kendi R1'i tam bu iki adın AYRI sayılmasından doğdu (spec §1).",
    ("olcum-aracinin-varsayimi", "olcum-sanilan-varsayim"):
        "Farklı kavramlar: 'olcum-aracinin-varsayimi' ARACIN TASARIMINA gömülü doğrulanmamış bir varsayımdır "
        "(örn. izolasyon-olc.py'nin playwright varsayımı); 'olcum-sanilan-varsayim' bir İNSAN/EL'in düz bir "
        "varsayımı fiilen yapılmış bir ölçüm SANMASIDIR -- hata birinde ARACIN davranışında, ötekinde "
        "YORUMLAMADADIR.",
    ("yanlis-pozitif", "yanlis-pozitif-taban"):
        "D-K170-6'nın kendi ölçülmüş örneği: 'yanlis-pozitif' bir kapının SONUÇTA hatalı KIRMIZI vermesi; "
        "'yanlis-pozitif-taban' o kapının dayandığı REFERANS/PİN DEĞERİNİN kendisinin en başından hatalı "
        "olmasıdır -- kavramlar FARKLIDIR (denetçi A, ADR0004 kapı spec'i §0a).",
    ("arac-yanlis-pozitifi", "yanlis-pozitif"):
        "D-K170-6'nın kendi ölçülmüş örneği: 'yanlis-pozitif' GENEL sınıftır (kapı/kural/insan hangi "
        "kaynaktan gelirse gelsin); 'arac-yanlis-pozitifi' ÖZEL olarak ölçüm ARACININ KENDİSİNİN ürettiği "
        "yanlış-pozitiftir -- nitelikli alt-küme, genel sınıfla birleştirilmez (ADR0004 kapı spec'i §0a).",
}


def _pair_key(a, b):
    return tuple(sorted((a, b)))


def main():
    kayitlar = []
    with open(DEFTER, encoding="utf-8") as f:
        for satir in f:
            satir = satir.strip()
            if not satir or satir.startswith("#"):
                continue
            try:
                kayitlar.append(json.loads(satir))
            except Exception:
                continue

    tum_siniflar = sorted({s for k in kayitlar for s in (k.get("siniflar") or [])})
    print("PROJE_RADAR.jsonl'dan BETIKLE turetilen distinct sinif sayisi: %d" % len(tum_siniflar))

    eksik_tanim = [ad for ad in tum_siniflar if ad not in TANIMLAR]
    if eksik_tanim:
        print("HATA: tanimlanmamis sinif adlari:", eksik_tanim)
        return 1

    girdiler = []
    for ad in tum_siniflar:
        girdiler.append({"ad": ad, "tanim": TANIMLAR[ad]})

    # >=0.82 ciftleri bul ve ayri_tutuldu gerekcesini isle
    ad_indeksi = {g["ad"]: g for g in girdiler}
    ciftler = []
    for i in range(len(tum_siniflar)):
        for j in range(i + 1, len(tum_siniflar)):
            a, b = tum_siniflar[i], tum_siniflar[j]
            r = difflib.SequenceMatcher(None, a, b).ratio()
            if r >= 0.82:
                ciftler.append((round(r, 3), a, b))
    print("Bulunan >=0.82 cift sayisi: %d" % len(ciftler))
    for r, a, b in ciftler:
        gerekce = AYRI_TUTULDU_GEREKCELERI.get(_pair_key(a, b))
        if not gerekce:
            print("HATA: gerekcesiz cift:", a, b, r)
            return 1
        # D-K170-6: girdi bicimi {ad, tanim, ayri_tutuldu?} -- ayri_tutuldu ALANI
        # HER IKI girdiye de (birbirine referansla) yazilir.
        ad_indeksi[a].setdefault("ayri_tutuldu", {})[b] = {"benzerlik": r, "gerekce": gerekce}
        ad_indeksi[b].setdefault("ayri_tutuldu", {})[a] = {"benzerlik": r, "gerekce": gerekce}

    cikti = {
        "uretim_kaynagi": "PROJE_RADAR.jsonl (betikle turetildi, elle sayilmadi -- K148-b)",
        "uretim_araci": "araclar/sinif-sozlugu-uret.py",
        "toplam_kayit_taranan": len(kayitlar),
        "toplam_distinct_sinif": len(tum_siniflar),
        "girdiler": girdiler,
    }

    tmp = HEDEF + ".tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(cikti, f, ensure_ascii=False, indent=2, sort_keys=False)
        f.write("\n")
    os.replace(tmp, HEDEF)
    print("YAZILDI:", HEDEF)
    return 0


if __name__ == "__main__":
    sys.exit(main())
