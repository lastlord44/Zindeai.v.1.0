#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Batch 20-24 dosyalarındaki kategori isimlerini düzelt
"""

import os
import re

# Düzeltilecek dosyalar ve değiştirilecek kategori çiftleri
files_to_fix = [
    ('lib/mega_yemek_batch_20_kahvalti_saglikli.dart', 'Kahvaltı', 'kahvalti'),
    ('lib/mega_yemek_batch_21_ogle_saglikli.dart', 'Öğle', 'ogle'),
    ('lib/mega_yemek_batch_22_aksam_saglikli.dart', 'Akşam', 'aksam'),
    ('lib/mega_yemek_batch_23_ara_ogun_1.dart', 'Ara Öğün 1', 'ara_ogun_1'),
    ('lib/mega_yemek_batch_24_29_ara_ogun_2.dart', 'Ara Öğün 2', 'ara_ogun_2'),
]

total_changes = 0

for filepath, old_category, new_category in files_to_fix:
    if not os.path.exists(filepath):
        print(f"⚠️  Dosya bulunamadı: {filepath}")
        continue
    
    # Dosyayı oku
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Kategori değiştirme
    # 'kategori': 'Kahvaltı' -> 'kategori': 'kahvalti'
    pattern = f"'kategori': '{old_category}'"
    replacement = f"'kategori': '{new_category}'"
    
    new_content = content.replace(pattern, replacement)
    
    # Kaç değişiklik yapıldı?
    changes = content.count(pattern)
    
    if changes > 0:
        # Dosyayı yaz
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        
        print(f"✅ {os.path.basename(filepath)}: {changes} kategori düzeltildi")
        total_changes += changes
    else:
        print(f"ℹ️  {os.path.basename(filepath)}: Değişiklik gerekmedi")

print(f"\n{'='*50}")
print(f"🎉 Toplam {total_changes} kategori düzeltildi!")
print(f"{'='*50}")
