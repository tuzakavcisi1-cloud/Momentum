# -*- coding: utf-8 -*-
"""Oturum 56 -- kriter 8 UI surucusu. K86: uiautomator dump uygulama cizilmeden
cagrilirsa 'null root node' verir ve DOSYA OLUSMAZ => sabit bekleme YOK,
ciktida 'dumped to' gorunene kadar TAVANLI yoklanir."""
import os, re, subprocess, sys, time, xml.etree.ElementTree as ET
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
ADB = r"C:\Users\gulci\AppData\Local\Android\Sdk\platform-tools\adb.exe"
D = os.path.dirname(os.path.abspath(__file__))


def adb(seri, *args, timeout=60):
    p = subprocess.run([ADB, "-s", seri] + list(args), capture_output=True,
                       text=True, encoding="utf-8", errors="replace", timeout=timeout)
    return p.returncode, (p.stdout or "") + (p.stderr or "")


def dump(seri, tavan=12):
    """UI agacini ceker. Doner: (kok_element, ham_xml_yolu)"""
    for deneme in range(tavan):
        kod, cikti = adb(seri, "shell", "uiautomator", "dump", "/sdcard/ui.xml")
        if "dumped to" in cikti:
            break
        time.sleep(1.5)
    else:
        raise SystemExit("[KIRMIZI] %s: 'dumped to' %d denemede GORULMEDI -- ekran cizilmemis olabilir."
                         % (seri, tavan))
    yerel = os.path.join(D, "_ui_%s.xml" % seri.replace(":", "_"))
    adb(seri, "pull", "/sdcard/ui.xml", yerel)
    return ET.parse(yerel).getroot(), yerel


def dugumler(kok):
    out = []
    for n in kok.iter("node"):
        a = n.attrib
        if a.get("text") or a.get("content-desc") or a.get("resource-id"):
            out.append({
                "text": a.get("text", ""), "desc": a.get("content-desc", ""),
                "id": a.get("resource-id", ""), "cls": a.get("class", ""),
                "clickable": a.get("clickable", ""), "bounds": a.get("bounds", ""),
                "checked": a.get("checked", ""),
            })
    return out


def merkez(bounds):
    m = re.findall(r"\d+", bounds)
    x1, y1, x2, y2 = map(int, m[:4])
    return (x1 + x2) // 2, (y1 + y2) // 2


def bul(dugum_listesi, **kriter):
    for d in dugum_listesi:
        if all(k in d and (v.lower() in d[k].lower()) for k, v in kriter.items()):
            return d
    return None


def yazdir(seri, ds, baslik=""):
    print("=" * 78)
    print("EKRAN: %s  %s  (%d dugum)" % (seri, baslik, len(ds)))
    for d in ds:
        print("  [%s%s]%s text=%r desc=%r id=%s %s" % (
            "C" if d["clickable"] == "true" else " ", d["cls"].split(".")[-1][:14],
            "[X]" if d["checked"] == "true" else ("[ ]" if d["checked"] == "false" else "   "),
            d["text"][:60], d["desc"][:50], d["id"].split("/")[-1][:30], d["bounds"]))


def dokun(seri, parca, alan="desc"):
    """Verilen alt dizeyi TASIYAN dugume dokunur. Once dump eder, dokunur, sonra
    tekrar dump edip DEGISIMI raporlar -- korukorune 'dokundum' demez."""
    kok, _ = dump(seri)
    ds = dugumler(kok)
    hedef = [d for d in ds if parca.lower() in d[alan].lower()]
    if len(hedef) != 1:
        yazdir(seri, ds, "(hedef bulunamadi)")
        raise SystemExit("[KIRMIZI] %s: '%s' icin %d dugum -- dokunulmadi." % (seri, parca, len(hedef)))
    d = hedef[0]
    x, y = merkez(d["bounds"])
    print("DOKUNUS: %s  (%d,%d)  desc=%r  onceki checked=%s" % (seri, x, y, d["desc"][:40], d["checked"]))
    adb(seri, "shell", "input", "tap", str(x), str(y))
    time.sleep(2.0)
    kok2, _ = dump(seri)
    ds2 = dugumler(kok2)
    yeni = [q for q in ds2 if parca.lower() in q[alan].lower()]
    print("SONRASI : checked=%s" % (yeni[0]["checked"] if yeni else "DUGUM YOK"))
    return ds2


if __name__ == "__main__":
    if sys.argv[1] == "dokun":
        dokun(sys.argv[2], sys.argv[3])
    else:
        for seri in sys.argv[1:]:
            kok, yol = dump(seri)
            yazdir(seri, dugumler(kok))
