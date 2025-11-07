#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
100 Öğle Yemeğini Düzeltip Dart Migration Koduna Çeviren Script
"""

import json
import re

# Sağlanan 100 öğle yemeği verisi (kullanıcıdan alınan)
ogle_yemekleri_json = """
[
{
"id": "OGLE_B1_201",
"ad": "Tavuk #1 - Tavuklu Sebzeli Fırın Makarna (Tam Buğday)",
"kategori": "Öğle",
"ogun": "ogle",
"kalori": 496,
"protein": 41,
"karbonhidrat": 53,
"yag": 13,
"malzemeler": ["Tavuk göğsü 150g", "Tam buğday makarna 70g", "Brokoli 120g", "Havuç 80g", "Yoğurt 100g", "Zeytinyağı 8g"],
"hazirlamaSuresi": 23,
"zorluk": "kolay",
"etiketler": ["pratik", "türk mutfağı", "ekonomik", "yüksek protein", "kalsiyum", "doyurucu"]
}
]
"""

def parse_number(value):
    """Sayısal değerleri parse et (string'den sayıya çevir)"""
    if isinstance(value, (int, float)):
        return value
    if isinstance(value, str):
        # "180g (haşlanmış)" gibi değerleri temizle
        cleaned = re.sub(r'[^\d.]', '', value)
        try:
            return float(cleaned) if '.' in cleaned else int(cleaned)
        except:
            return 0
    return 0

def zorluk_to_enum(zorluk):
    """Zorluk string'ini Dart enum'a çevir"""
    if isinstance(zorluk, str):
        z = zorluk.lower()
        if z == "kolay":
            return "Zorluk.kolay"
        elif z == "orta":
            return "Zorluk.orta"
        elif z == "zor":
            return "Zorluk.zor"
    return "Zorluk.kolay"

def generate_dart_yemek(yemek):
    """Tek bir yemek için Dart kodu oluştur"""
    protein = parse_number(yemek.get('protein', 0))
    karb = parse_number(yemek.get('karbonhidrat', 0))
    yag = parse_number(yemek.get('yag', 0))
    kalori = parse_number(yemek.get('kalori', 0))
    sure = parse_number(yemek.get('hazirlamaSuresi', 0))
    
    malzemeler = yemek.get('malzemeler', [])
    malzemeler_str = ', '.join([f"'{m}'" for m in malzemeler])
    
    etiketler = yemek.get('etiketler', [])
    etiketler_str = ', '.join([f"'{e}'" for e in etiketler])
    
    return f"""      Yemek(
        id: '{yemek.get('id', '')}',
        ad: '{yemek.get('ad', '')}',
        ogun: OgunTipi.ogle,
        kalori: {kalori},
        protein: {protein},
        karbonhidrat: {karb},
        yag: {yag},
        malzemeler: [{malzemeler_str}],
        hazirlamaSuresi: {sure},
        zorluk: {zorluk_to_enum(yemek.get('zorluk', 'kolay'))},
        etiketler: [{etiketler_str}],
      ),"""

def main():
    try:
        data = json.loads(ogle_yemekleri_json)
        print(f"✅ {len(data)} yemek bulundu")
        
        dart_code_lines = []
        for yemek in data:
            dart_code_lines.append(generate_dart_yemek(yemek))
        
        dart_code = '\n'.join(dart_code_lines)
        
        # Dosyaya yaz
        with open('scripts/generated_yemekler.dart', 'w', encoding='utf-8') as f:
            f.write(dart_code)
        
        print(f"✅ Dart kodu oluşturuldu: scripts/generated_yemekler.dart")
        print(f"✅ Toplam {len(data)} yemek dönüştürüldü")
        
    except Exception as e:
        print(f"❌ Hata: {e}")

if __name__ == "__main__":
    main()