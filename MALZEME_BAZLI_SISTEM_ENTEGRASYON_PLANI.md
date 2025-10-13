# 🚀 MALZEME BAZLI SİSTEM ENTEGRASYON PLANI

## 📁 DOSYA KOPYALAMA HARİTASI

### 1. Domain Entity Dosyaları
**Kaynak:** `C:\Users\MS\Desktop\gptmeal\zindeai_e2e\lib\domain\entities\`
**Hedef:** `c:\Users\MS\Desktop\zindeai 05.10.2025\lib\domain\entities\`

Kopyalanacak dosyalar:
- ✅ `besin_malzeme.dart` → Besin malzemesi entity
- ✅ `chromosome.dart` → Genetik algoritma kromozom
- ✅ `malzeme_miktar.dart` → Malzeme miktar entity
- ✅ `ogun_sablonu.dart` → Öğün şablon entity

### 2. Domain Usecases
**Kaynak:** `C:\Users\MS\Desktop\gptmeal\zindeai_e2e\lib\domain\usecases\`
**Hedef:** `c:\Users\MS\Desktop\zindeai 05.10.2025\lib\domain\usecases\`

Kopyalanacak dosyalar:
- ✅ `malzeme_tabanli_genetik_algoritma.dart` → Yeni genetik algoritma

### 3. Domain Rules & Utils
**Kaynak:** `C:\Users\MS\Desktop\gptmeal\zindeai_e2e\lib\domain\`
**Hedef:** `c:\Users\MS\Desktop\zindeai 05.10.2025\lib\domain\`

Kopyalanacak dosyalar:
- ✅ `rules/validators.dart` → Validasyon kuralları
- ✅ `utils/meal_splitter.dart` → Öğün bölücü utility

### 4. Data Layer
**Kaynak:** `C:\Users\MS\Desktop\gptmeal\zindeai_e2e\lib\data\local\`
**Hedef:** `c:\Users\MS\Desktop\zindeai 05.10.2025\lib\data\local\`

Kopyalanacak dosyalar:
- ✅ `besin_malzeme_hive_service.dart` → Besin malzeme Hive servisi

### 5. Application Services
**Kaynak:** `C:\Users\MS\Desktop\gptmeal\zindeai_e2e\lib\application\services\`
**Hedef:** `c:\Users\MS\Desktop\zindeai 05.10.2025\lib\application\services\`

Kopyalanacak dosyalar:
- ✅ `ogun_optimizer_service.dart` → Öğün optimizer servisi

### 6. Assets Data
**Kaynak:** `C:\Users\MS\Desktop\gptmeal\zindeai_e2e\assets\data\`
**Hedef:** `c:\Users\MS\Desktop\zindeai 05.10.2025\assets\data\`

Kopyalanacak dosyalar:
- ✅ `besin_malzemeleri_200.json` → İlk 200 besin malzemesi
- ✅ `ogun_sablonlari.json` → Öğün şablonları

### 7. Assets Manifest
**Kaynak:** `C:\Users\MS\Desktop\gptmeal\zindeai_e2e\assets\manifest\`
**Hedef:** `c:\Users\MS\Desktop\zindeai 05.10.2025\assets\manifest\`

Kopyalanacak dosyalar:
- ✅ `batch_manifest.json` → Batch yönetimi için manifest

### 8. Test Dosyaları
**Kaynak:** `C:\Users\MS\Desktop\gptmeal\zindeai_e2e\test\`
**Hedef:** `c:\Users\MS\Desktop\zindeai 05.10.2025\test\`

Kopyalanacak dosyalar:
- ✅ `test_malzeme_tabanli_sistem.dart` → Sistem testi
- ✅ `test_e2e_tolerance.dart` → Tolerans testi

---

## 🎯 SONRAKI ADIMLAR

1. **Dosyaları Kopyala** → Yukarıdaki harita ile
2. **Batch ZIP'leri Extract Et** → 20 batch × 200 besin = 4000 besin
3. **Migration Script Oluştur** → Tüm besinleri Hive DB'ye yükle
4. **Test Et** → %1-2 tolerans hedefi doğrula

---

## ⚡ HIZLI KOPYALAMA KOMUTLARI

```powershell
# Entity dosyaları
xcopy "C:\Users\MS\Desktop\gptmeal\zindeai_e2e\lib\domain\entities\*.*" "c:\Users\MS\Desktop\zindeai 05.10.2025\lib\domain\entities\" /Y

# Usecases
xcopy "C:\Users\MS\Desktop\gptmeal\zindeai_e2e\lib\domain\usecases\*.*" "c:\Users\MS\Desktop\zindeai 05.10.2025\lib\domain\usecases\" /Y

# Rules
mkdir "c:\Users\MS\Desktop\zindeai 05.10.2025\lib\domain\rules"
xcopy "C:\Users\MS\Desktop\gptmeal\zindeai_e2e\lib\domain\rules\*.*" "c:\Users\MS\Desktop\zindeai 05.10.2025\lib\domain\rules\" /Y

# Utils
mkdir "c:\Users\MS\Desktop\zindeai 05.10.2025\lib\domain\utils"
xcopy "C:\Users\MS\Desktop\gptmeal\zindeai_e2e\lib\domain\utils\*.*" "c:\Users\MS\Desktop\zindeai 05.10.2025\lib\domain\utils\" /Y

# Data layer
xcopy "C:\Users\MS\Desktop\gptmeal\zindeai_e2e\lib\data\local\besin_malzeme_hive_service.dart" "c:\Users\MS\Desktop\zindeai 05.10.2025\lib\data\local\" /Y

# Application services
mkdir "c:\Users\MS\Desktop\zindeai 05.10.2025\lib\application"
mkdir "c:\Users\MS\Desktop\zindeai 05.10.2025\lib\application\services"
xcopy "C:\Users\MS\Desktop\gptmeal\zindeai_e2e\lib\application\services\*.*" "c:\Users\MS\Desktop\zindeai 05.10.2025\lib\application\services\" /Y

# Assets data
xcopy "C:\Users\MS\Desktop\gptmeal\zindeai_e2e\assets\data\*.*" "c:\Users\MS\Desktop\zindeai 05.10.2025\assets\data\" /Y

# Assets manifest
mkdir "c:\Users\MS\Desktop\zindeai 05.10.2025\assets\manifest"
xcopy "C:\Users\MS\Desktop\gptmeal\zindeai_e2e\assets\manifest\*.*" "c:\Users\MS\Desktop\zindeai 05.10.2025\assets\manifest\" /Y

# Test dosyaları
xcopy "C:\Users\MS\Desktop\gptmeal\zindeai_e2e\test\test_*.dart" "c:\Users\MS\Desktop\zindeai 05.10.2025\test\" /Y
```

Bu komutları tek tek çalıştırarak tüm dosyaları kopyalayabiliriz!
