# -*- coding: utf-8 -*-
# Oturum 55: BORCLAR.md'nin radar defteri kaydi (D1 bayatligini kapatir).
import sys, json, io
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
YOL = r"C:\dev\Momentum\PROJE_RADAR.jsonl"
k = {"tarih":"2026-08-03","oturum":55,"urun_kodu_satiri":0,"artefakt":"BORCLAR.md","tur":16,
     "asama":"SS2 v3 kilidinin dort borcu yazildi (B-SS2-1..4); sarkan atif KAPANDI",
     "bulgu":{"bloker":0,"major":0,"minor":1},
     "siniflar":["sarkan-atif","olcum-aracinin-varsayimi"],
     "bayt":31911,"kapatilan":1,"uretilen":1,
     "not":"KAPANAN: spec §8 B-SS2-1/2/3'e atif yapiyordu ve BORCLAR.md'de KARSILIGI YOKTU (v2'de de yoktu) -- kilit onlari SARKAN ATIF yapacakti; dordu de yazildi (B-SS2-1..3 kisa kimlikle + kanonik metin spec §8'de, B-SS2-4 tam metinle). URETILEN: bu yazim T2'yi SARI'ya dusurdu (31911/32768, pay 857 b, esik 1638) ve ayni turda DURUM.md de SARI kaldi (pay 1158). K117/K126'nin dersi geregi budama ancak bir borc KAPANINCA ise yarar; bu turda kapanan borc YOK, acilan 4 var. TAVAN/BUDAMA KARARI K40 GEREGI ONUR'DA -- arac tavani kendi degistirmez."}
with io.open(YOL, "a", encoding="utf-8", newline="\n") as f:
    f.write(json.dumps(k, ensure_ascii=True) + "\n")
print("PROJE_RADAR.jsonl: BORCLAR.md tur 16 kaydi eklendi.")
