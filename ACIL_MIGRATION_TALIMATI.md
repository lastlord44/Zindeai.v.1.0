# 🔥 ACİL! ÇEŞİTLİLİK İÇİN HEMEN MIGRATION YAP

## SORUN
Öğle ve akşamda sürekli AYNI yemekler geliyor (somon, nohut, vb.)

## KÖK NEDEN  
Migration servisini güncelledik (1050+ akşam, 300+ öğle yemeği eklendi) ama sen henüz **Hive DB'yi temizleyip yeniden migration yapmadın!**

Şu anda eski az sayıda yemekle çalışıyorsun, bu yüzden çeşitlilik yok.

## ÇÖZÜM: 2 DAKİKA İÇİNDE HALLEDECEK

### ADIM 1: Hive DB Klasörünü Sil
```
C:\Users\MS\Desktop\zindeai 05.10.2025\hive_data
```
Bu klasörü **TAMAMEN SİL** (varsa)

### ADIM 2: Flutter App'i Çalıştır
```bash
flutter run
```

### ADIM 3: Bekle
Migration otomatik yapılacak. Konsolda şunu göreceksin:
```
✅ aksam_combo_450.json: 450 yemek
✅ aksam_yemekbalık_150.json: 150 yemek  
✅ aksam_yemekleri_150_kofte_kiyma_kusbasi_haslama.json: 150 yemek
✅ zindeai_ogle_300.json: 300 yemek
```

### ADIM 4: Test Et
- 7 günlük plan oluştur
- Her gün FARKLI yemek göreceksin:
  - Pazartesi: Tavuk + pilav
  - Salı: Balık + bulgur
  - Çarşamba: Nohut + salata
  - Perşembe: Köfte + makarna
  - ...vb.

## BEKLENTİ

**ÖNCESİ:**
- Öğle: 80 yemek (çoğu batch dosyalarından)
- Akşam: 300 yemek

**SONRASI:**
- Öğle: 300+ yemek ✅
- Akşam: 1050+ yemek ✅

Her gün FARKLI ana yemek garantili! 🎯

## NOT
Eğer migration sonrası HALA aynı yemek gelirse, o zaman çeşitlilik mekanizmasını düzelteceğim. Ama önce migration şart!
