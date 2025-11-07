#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
150 Sağlıklı Kahvaltı JSON Oluşturucu
Dinamik isim ve makro bazlı sistem
"""

import json
import random

def generate_meals():
    """150 sağlıklı kahvaltı oluştur"""
    meals = []
    
    # ========================================================================
    # KATEGORİ 1: YÜKSEK PROTEİN KAHVALTILAR (40 adet)
    # ========================================================================
    
    # Yumurta bazlı
    for i in range(1, 16):
        yumurta_sayi = random.choice([2, 3, 4])
        protein = yumurta_sayi * 6 + random.randint(5, 15)
        karb = random.randint(15, 35)
        yag = random.randint(10, 20)
        kalori = protein * 4 + karb * 4 + yag * 9
        
        malzemeler = [
            f"Yumurta ({yumurta_sayi} adet)",
            random.choice(["Beyaz Peynir (50g)", "Lor Peyniri (80g)", "Kaşar (40g)"]),
            random.choice(["Tam Buğday Ekmeği (2 dilim)", "Çavdar Ekmeği (2 dilim)"]),
            random.choice(["Domates (1 adet)", "Cherry Domates (5 adet)"]),
            random.choice(["Salatalık (1 adet)", "Yeşil Biber (1 adet)"])
        ]
        
        meals.append({
            "meal_id": f"kahvalti_saglikli_{len(meals)+1:03d}",
            "meal_name": f"Protein Kahvaltı: {malzemeler[0].split('(')[0].strip()} + {malzemeler[1].split('(')[0].strip()}",
            "category": "Kahvaltı",
            "meal_type": "kahvalti",
            "kalori": round(kalori),
            "protein": protein,
            "karbonhidrat": karb,
            "yag": yag,
            "malzemeler": malzemeler,
            "hazirlamaSuresi": random.randint(10, 20),
            "zorluk": random.choice(["kolay", "kolay", "orta"]),
            "etiketler": ["yüksek protein", "sağlıklı", "yumurta"]
        })
    
    # Yoğurt bazlı
    for i in range(1, 16):
        yogurt_tip = random.choice(["Süzme Yoğurt", "Protein Yoğurt", "Yoğurt"])
        yogurt_miktar = random.randint(150, 250)
        protein = random.randint(18, 28)
        karb = random.randint(30, 50)
        yag = random.randint(5, 15)
        kalori = protein * 4 + karb * 4 + yag * 9
        
        topping = random.choice([
            "Granola (30g)",
            "Yulaf (40g)",
            "Chia Tohumu (15g)",
            "Keten Tohumu (10g)"
        ])
        
        meyve = random.choice([
            "Muz (1 adet)",
            "Çilek (100g)",
            "Yaban Mersini (80g)",
            "Böğürtlen (80g)",
            "Ahududu (70g)"
        ])
        
        nuts = random.choice([
            "Badem (20g)",
            "Ceviz (15g)",
            "Fındık (20g)",
            "Kaju (15g)"
        ])
        
        malzemeler = [f"{yogurt_tip} ({yogurt_miktar}g)", meyve, topping, nuts, "Bal (1 tatlı kaşığı)"]
        
        meals.append({
            "meal_id": f"kahvalti_saglikli_{len(meals)+1:03d}",
            "meal_name": f"Protein Kasesi: {yogurt_tip} + {meyve.split('(')[0].strip()}",
            "category": "Kahvaltı",
            "meal_type": "kahvalti",
            "kalori": round(kalori),
            "protein": protein,
            "karbonhidrat": karb,
            "yag": yag,
            "malzemeler": malzemeler,
            "hazirlamaSuresi": random.randint(5, 10),
            "zorluk": "kolay",
            "etiketler": ["yüksek protein", "probiyotik", "sağlıklı"]
        })
    
    # Lor peyniri bazlı
    for i in range(1, 11):
        protein = random.randint(20, 28)
        karb = random.randint(25, 40)
        yag = random.randint(8, 15)
        kalori = protein * 4 + karb * 4 + yag * 9
        
        ekmek = random.choice([
            "Tam Buğday Ekmeği (2 dilim)",
            "Çavdar Ekmeği (2 dilim)",
            "Yulaf Ekmeği (2 dilim)",
            "Kepekli Ekmek (2 dilim)"
        ])
        
        sebze = random.choice([
            "Roka, Domates (1 adet)",
            "Ispanak (50g), Salatalık (1 adet)",
            "Cherry Domates (5 adet), Roka",
            "Yeşil Biber (1 adet), Domates (1 adet)"
        ])
        
        malzemeler = ["Lor Peyniri (100g)", ekmek, sebze, "Zeytin (8 adet)"]
        
        meals.append({
            "meal_id": f"kahvalti_saglikli_{len(meals)+1:03d}",
            "meal_name": f"Lor Peyniri + {ekmek.split('(')[0].strip()}",
            "category": "Kahvaltı",
            "meal_type": "kahvalti",
            "kalori": round(kalori),
            "protein": protein,
            "karbonhidrat": karb,
            "yag": yag,
            "malzemeler": malzemeler,
            "hazirlamaSuresi": random.randint(5, 10),
            "zorluk": "kolay",
            "etiketler": ["yüksek protein", "düşük yağ", "sağlıklı"]
        })
    
    # ========================================================================
    # KATEGORİ 2: DENGELİ MAKRO KAHVALTILAR (60 adet)
    # ========================================================================
    
    # Yulaf bazlı
    for i in range(1, 21):
        protein = random.randint(14, 20)
        karb = random.randint(40, 55)
        yag = random.randint(10, 16)
        kalori = protein * 4 + karb * 4 + yag * 9
        
        sut_tipi = random.choice([
            "Süt (200ml)",
            "Badem Sütü (200ml)",
            "Yoğurt (150g)",
            "Kefir (200ml)"
        ])
        
        meyve = random.choice([
            "Muz (1 adet)",
            "Elma (1 adet, dilimlenmiş)",
            "Çilek (100g)",
            "Yaban Mersini (80g)"
        ])
        
        nuts = random.choice([
            "Badem (20g)",
            "Ceviz (20g)",
            "Fındık (20g)"
        ])
        
        malzemeler = ["Yulaf (50g)", sut_tipi, meyve, nuts, "Tarçın"]
        
        meals.append({
            "meal_id": f"kahvalti_saglikli_{len(meals)+1:03d}",
            "meal_name": f"Yulaf Kasesi: {meyve.split('(')[0].strip()} + {nuts.split('(')[0].strip()}",
            "category": "Kahvaltı",
            "meal_type": "kahvalti",
            "kalori": round(kalori),
            "protein": protein,
            "karbonhidrat": karb,
            "yag": yag,
            "malzemeler": malzemeler,
            "hazirlamaSuresi": random.randint(8, 12),
            "zorluk": "kolay",
            "etiketler": ["dengeli", "yulaf", "lif açısından zengin"]
        })
    
    # Klasik Türk kahvaltısı
    for i in range(1, 21):
        protein = random.randint(16, 22)
        karb = random.randint(30, 45)
        yag = random.randint(12, 18)
        kalori = protein * 4 + karb * 4 + yag * 9
        
        peynir = random.choice([
            "Beyaz Peynir (50g)",
            "Kaşar Peyniri (40g)",
            "Ezine Peyniri (50g)",
            "Tulum Peyniri (40g)"
        ])
        
        ekmek = random.choice([
            "Tam Buğday Ekmeği (2 dilim)",
            "Çavdar Ekmeği (2 dilim)",
            "Simit (1 adet)",
            "Kepekli Ekmek (2 dilim)"
        ])
        
        ekstra = random.choice([
            "Yumurta (1 adet, haşlanmış)",
            "Reçel (20g)",
            "Bal (1 yemek kaşığı)",
            "Tahin-Pekmez (20g)"
        ])
        
        malzemeler = [peynir, ekmek, "Domates (1 adet)", "Salatalık (1 adet)", ekstra, "Zeytin (10 adet)"]
        
        meals.append({
            "meal_id": f"kahvalti_saglikli_{len(meals)+1:03d}",
            "meal_name": f"Türk Kahvaltısı: {peynir.split('(')[0].strip()} + {ekstra.split('(')[0].strip()}",
            "category": "Kahvaltı",
            "meal_type": "kahvalti",
            "kalori": round(kalori),
            "protein": protein,
            "karbonhidrat": karb,
            "yag": yag,
            "malzemeler": malzemeler,
            "hazirlamaSuresi": random.randint(5, 10),
            "zorluk": "kolay",
            "etiketler": ["dengeli", "geleneksel", "türk mutfağı"]
        })
    
    # Smoothie Bowl & Modern
    for i in range(1, 11):
        protein = random.randint(12, 18)
        karb = random.randint(45, 60)
        yag = random.randint(8, 14)
        kalori = protein * 4 + karb * 4 + yag * 9
        
        base = random.choice([
            "Muz (1 adet), Yaban Mersini (100g)",
            "Açai (100g), Muz (1 adet)",
            "Mango (100g), Çilek (100g)",
            "Ispanak (50g), Muz (1 adet)"
        ])
        
        topping = random.choice([
            "Granola (30g)",
            "Hindistan Cevizi (20g)",
            "Chia Tohumu (15g)",
            "Kinoa Gevreği (30g)"
        ])
        
        malzemeler = ["Smoothie Bowl: " + base, "Protein Tozu (20g)", topping, "Badem (15g)", "Bal (1 tatlı kaşığı)"]
        
        meals.append({
            "meal_id": f"kahvalti_saglikli_{len(meals)+1:03d}",
            "meal_name": f"Smoothie Bowl: "category": "Kahvaltı",
            "meal_type": "kahvalti",
            "kalori": round(kalori),
            "protein": protein,
            "karbonhidrat": karb,
            "yag": yag,
            "malzemeler": malzemeler,
            "hazirlamaSuresi": random.randint(8, 12),
            "zorluk": "kolay",
            "etiketler": ["dengeli", "modern", "smoothie"]
        })
    
    # Vegan/Vejetaryen
    for i in range(1, 11):
        protein = random.randint(14, 20)
        karb = random.randint(35, 50)
        yag = random.randint(12, 18)
        kalori = protein * 4 + karb * 4 + yag * 9
        
        protein_source = random.choice([
            "Tofu Scramble (100g)",
            "Humus (100g)",
            "Badem Ezmesi (30g)",
            "Tahin (30g)",
            "Nohut (60g, haşlanmış)"
        ])
        
        ekmek = random.choice([
            "Tam Buğday Ekmeği (2 dilim)",
            "Çavdar Ekmeği (2 dilim)",
            "Mercimek Ekmeği (2 dilim)"
        ])
        
        malzemeler = [protein_source, ekmek, "Domates (1 adet)", "Avokado (1/4 adet)", "Zeytin (10 adet)"]
        
        meals.append({
            "meal_id": f"kahvalti_saglikli_{len(meals)+1:03d}",
            "meal_name": f"Vegan Kahvaltı: {protein_source.split('(')[0].strip()}",
            "category": "Kahvaltı",
            "meal_type": "kahvalti",
            "kalori": round(kalori),
            "protein": protein,
            "karbonhidrat": karb,
            "yag": yag,
            "malzemeler": malzemeler,
            "hazirlamaSuresi": random.randint(10, 15),
            "zorluk": "orta",
            "etiketler": ["dengeli", "vegan", "bitkisel protein"]
        })
    
    # ========================================================================
    # KATEGORİ 3: DÜŞÜK KALORİLİ KAHVALTILAR (30 adet)
    # ========================================================================
    
    for i in range(1, 31):
        protein = random.randint(12, 20)
        karb = random.randint(15, 30)
        yag = random.randint(3, 10)
        kalori = protein * 4 + karb * 4 + yag * 9
        
        base = random.choice([
            "Yumurta Beyazı (4 adet)",
            "Süzme Yoğurt (150g, %0 yağ)",
            "Lor Peyniri (80g)",
            "Cottage Cheese (100g)",
            "Protein Yoğurt (150g)"
        ])
        
        sebze_meyve = random.choice([
            "Ispanak (50g), Mantar (50g)",
            "Çilek (100g)",
            "Yaban Mersini (80g)",
            "Salatalık (1 adet), Domates (1 adet)",
            "Cherry Domates (10 adet)"
        ])
        
        ekstra = random.choice([
            "Chia Tohumu (5g)",
            "Keten Tohumu (5g)",
            "Badem (10g)",
            "Tam Buğday Ekmeği (1 dilim)"
        ])
        
        malzemeler = [base, sebze_meyve, ekstra]
        
        meals.append({
            "meal_id": f"kahvalti_saglikli_{len(meals)+1:03d}",
            "meal_name": f"Light Kahvaltı: {base.split('(')[0].strip()}",
            "category": "Kahvaltı",
            "meal_type": "kahvalti",
            "kalori": round(kalori),
            "protein": protein,
            "karbonhidrat": karb,
            "yag": yag,
            "malzemeler": malzemeler,
            "hazirlamaSuresi": random.randint(5, 12),
            "zorluk": "kolay",
            "etiketler": ["düşük kalori", "diyet", "sağlıklı"]
        })
    
    # ========================================================================
    # KATEGORİ 4: YÜKSEK KALORİLİ/BULK KAHVALTILAR (20 adet)
    # ========================================================================
    
    for i in range(1, 21):
        protein = random.randint(30, 45)
        karb = random.randint(55, 80)
        yag = random.randint(18, 30)
        kalori = protein * 4 + karb * 4 + yag * 9
        
        protein_source = random.choice([
            "Yumurta (4 adet)",
            "Protein Pancake (yulaf 60g, yumurta 3)",
            "Menemen (3 yumurta)",
            "Protein Waffle (yulaf 60g, yumurta 3)"
        ])
        
        karb_source = random.choice([
            "Tam Buğday Ekmeği (3 dilim)",
            "Yulaf (70g)",
            "Simit (2 adet)",
            "Granola (60g)"
        ])
        
        yag_source = random.choice([
            "Fıstık Ezmesi (30g)",
            "Avokado (1 adet)",
            "Badem Ezmesi (30g)",
            "Ceviz (30g)"
        ])
        
        malzemeler = [protein_source, karb_source, yag_source, "Muz (1 adet)", "Bal (2 yemek kaşığı)"]
        
        meals.append({
            "meal_id": f"kahvalti_saglikli_{len(meals)+1:03d}",
            "meal_name": f"Bulk Kahvaltı: {protein_source.split('(')[0].strip()} + {karb_source.split('(')[0].strip()}",
            "category": "Kahvaltı",
            "meal_type": "kahvalti",
            "kalori": round(kalori),
            "protein": protein,
            "karbonhidrat": karb,
            "yag": yag,
            "malzemeler": malzemeler,
            "hazirlamaSuresi": random.randint(12, 20),
            "zorluk": random.choice(["kolay", "orta"]),
            "etiketler": ["yüksek kalori", "bulk", "kas yapımı"]
        })
    
    return meals

# Ana işlem
if __name__ == "__main__":
    print("🍳 150 Sağlıklı Kahvaltı Oluşturuluyor...")
    
    meals = generate_meals()
    
    # JSON dosyasına kaydet
    output_file = "assets/data/kahvalti_saglikli_150_guncel.json"
    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(meals, f, ensure_ascii=False, indent=2)
    
    # İstatistikler
    total_meals = len(meals)
    avg_kalori = sum(m['kalori'] for m in meals) / total_meals
    avg_protein = sum(m['protein'] for m in meals) / total_meals
    avg_karb = sum(m['karbonhidrat'] for m in meals) / total_meals
    avg_yag = sum(m['yag'] for m in meals) / total_meals
    
    print(f"\n✅ {total_meals} Sağlıklı Kahvaltı Oluşturuldu!")
    print(f"📁 Dosya: {output_file}")
    print(f"\n📊 İSTATİSTİKLER:")
    print(f"   Ort. Kalori: {avg_kalori:.0f} kcal")
    print(f"   Ort. Protein: {avg_protein:.0f}g")
    print(f"   Ort. Karbonhidrat: {avg_karb:.0f}g")
    print(f"   Ort. Yağ: {avg_yag:.0f}g")
    
    # Kategori dağılımı
    etiket_dagilim = {}
    for meal in meals:
        for etiket in meal['etiketler']:
            etiket_dagilim[etiket] = etiket_dagilim.get(etiket, 0) + 1
    
    print(f"\n🏷️ ETİKET DAĞILIMI:")
    for etiket, sayi in sorted(etiket_dagilim.items(), key=lambda x: x[1], reverse=True):
        print(f"   {etiket}: {sayi}")
    
    print(f"\n✨ Tamamlandı!\n")