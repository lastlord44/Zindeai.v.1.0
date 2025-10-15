#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Zararlı Besin Temizleyici
Tüm mega JSON dosyalarındaki zararlı besinleri temizler
"""

import json
import os
from typing import List, Dict

# YASAK KELİMELER - Zararlı ve yabancı besinler
YASAK_KELIMELER = [
    # Yabancı Supplement/Protein Ürünleri
    'whey',
    'protein shake',
    'protein powder',
    'protein smoothie',
    'smoothie',
    'vegan protein',
    'protein bite',
    'protein tozu',
    'casein',
    'bcaa',
    'kreatin',
    'gainer',
    'supplement',
    'cottage cheese',
    'cottage',
    
    # Yabancı Yemekler
    'smoothie bowl',
    'chia pudding',
    'acai bowl',
    'quinoa',
    'hummus wrap',
    'falafel wrap',
    'burrito',
    'taco',
    'sushi',
    'poke bowl',
    'ramen',
    'pad thai',
    'curry',
    'bagel',
    'gravlax',
    'rice cake',
    
    # UN ÜRÜNLERİ (Sağlıksız Karbonhidrat) - EKLENEN
    'poğaça',
    'pogaca',
    'pişi',
    'pisi',
    'börek',
    'borek',
    'sigara böreği',
    'sigara boregi',
    'simit',
    'croissant',
    'kruvasan',
    'hamburger',
    'burger',
    'pizza',
    'sandviç',
    'sandwich',
    'pide',
    'lahmacun',
    'gözleme',
    'gozleme',
    'tost',
    'galeta',
    'kraker',
    
    # Kızartma ve Fast Food
    'kızarmış',
    'kizarmis',
    'cips',
    'chips',
    'patates kızartması',
    'french fries',
    'nugget',
    'crispy',
    'fried',
    'tavuk burger',
    'sosisli',
    'hot dog',
    'döner',
    'doner',
    'kokoreç',
    'kokorec',
]

# AKTİF JSON DOSYALARI
JSON_DOSYALARI = [
    # KAHVALTI
    'assets/data/mega_kahvalti_batch_1.json',
    'assets/data/mega_kahvalti_batch_2.json',
    'assets/data/mega_kahvalti_batch_3.json',
    # ÖĞLE
    'assets/data/mega_ogle_batch_1.json',
    'assets/data/mega_ogle_batch_2.json',
    'assets/data/mega_ogle_batch_3.json',
    'assets/data/mega_ogle_batch_4.json',
    # AKŞAM
    'assets/data/mega_aksam_batch_1.json',
    'assets/data/mega_aksam_batch_2.json',
    'assets/data/mega_aksam_batch_3.json',
    'assets/data/mega_aksam_batch_4.json',
    # ARA ÖĞÜN 1
    'assets/data/mega_ara_ogun_1_batch_1.json',
    'assets/data/mega_ara_ogun_1_batch_2.json',
    'assets/data/mega_ara_ogun_1_batch_3.json',
    # ARA ÖĞÜN 2
    'assets/data/mega_ara_ogun_2_batch_1.json',
    'assets/data/mega_ara_ogun_2_batch_2.json',
    'assets/data/mega_ara_ogun_2_batch_3.json',
    'assets/data/mega_ara_ogun_2_batch_4.json',
    'assets/data/mega_ara_ogun_2_batch_5.json',
]

def zararli_besin_mi(yemek_adi: str) -> bool:
    """Yemeğin zararlı besin olup olmadığını kontrol et"""
    ad_lower = yemek_adi.lower()
    
    for yasak in YASAK_KELIMELER:
        if yasak.lower() in ad_lower:
            return True
    
    return False

def temizle_json_dosyasi(dosya_yolu: str) -> Dict:
    """Bir JSON dosyasını temizle"""
    print(f"\nIsleniyor: {dosya_yolu}")
    
    # Dosya var mı kontrol et
    if not os.path.exists(dosya_yolu):
        print(f"   Dosya bulunamadi!")
        return {
            'toplam': 0,
            'temiz': 0,
            'silinen': 0,
        }
    
    # JSON oku
    with open(dosya_yolu, 'r', encoding='utf-8') as f:
        yemekler = json.load(f)
    
    toplam = len(yemekler)
    print(f"   Toplam yemek: {toplam}")
    
    # Temiz yemekleri filtrele
    temiz_yemekler = []
    silinen_yemekler = []
    
    for yemek in yemekler:
        yemek_adi = yemek.get('meal_name', '')
        
        if zararli_besin_mi(yemek_adi):
            silinen_yemekler.append(yemek_adi)
        else:
            temiz_yemekler.append(yemek)
    
    temiz_sayi = len(temiz_yemekler)
    silinen_sayi = len(silinen_yemekler)
    
    print(f"   Temiz: {temiz_sayi}")
    print(f"   Silinen: {silinen_sayi}")
    
    # Silinen yemekleri göster (ilk 5)
    if silinen_yemekler:
        print(f"   Silinen ornekler:")
        for yemek in silinen_yemekler[:5]:
            print(f"      - {yemek}")
        if len(silinen_yemekler) > 5:
            print(f"      ... ve {len(silinen_yemekler) - 5} tane daha")
    
    # Temiz JSON'ı yaz
    with open(dosya_yolu, 'w', encoding='utf-8') as f:
        json.dump(temiz_yemekler, f, ensure_ascii=False, indent=2)
    
    print(f"   Kaydedildi!")
    
    return {
        'toplam': toplam,
        'temiz': temiz_sayi,
        'silinen': silinen_sayi,
        'silinen_liste': silinen_yemekler,
    }

def main():
    """Ana fonksiyon"""
    print("ZARARLI BESIN TEMIZLEYICI BASLADI")
    print("=" * 60)
    
    toplam_stats = {
        'toplam_yemek': 0,
        'temiz_yemek': 0,
        'silinen_yemek': 0,
    }
    
    # Her dosyayı temizle
    for dosya in JSON_DOSYALARI:
        stats = temizle_json_dosyasi(dosya)
        
        toplam_stats['toplam_yemek'] += stats['toplam']
        toplam_stats['temiz_yemek'] += stats['temiz']
        toplam_stats['silinen_yemek'] += stats['silinen']
    
    # Özet
    print("\n" + "=" * 60)
    print("OZET RAPOR")
    print("=" * 60)
    print(f"Toplam yemek sayisi: {toplam_stats['toplam_yemek']}")
    print(f"Temiz yemek: {toplam_stats['temiz_yemek']}")
    print(f"Silinen yemek: {toplam_stats['silinen_yemek']}")
    if toplam_stats['toplam_yemek'] > 0:
        print(f"Temizlik orani: {(toplam_stats['temiz_yemek'] / toplam_stats['toplam_yemek'] * 100):.1f}%")
    else:
        print("Temizlik orani: 0%")
    print("\nTEMIZLIK TAMAMLANDI!")
    print("\nSimdi yapilmasi gerekenler:")
    print("   1. Uygulamayi TAMAMEN KAPAT (Hot restart degil!)")
    print("   2. Hive DB'yi temizle: Remove-Item -Recurse -Force hive_db")
    print("   3. Uygulamayi tekrar baslat: flutter run")
    print("   4. 30-60 saniye bekle (Migration calisacak)")
    print("   5. 'Plan Olustur' butonuna bas")
    print("\nArtik sadece SAGLIKLI Turk mutfagi yemekleri gelecek!")

if __name__ == '__main__':
    main()
