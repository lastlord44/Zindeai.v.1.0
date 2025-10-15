
# 🚀 Backend Entegrasyon Planı - ZindeAI

## 📊 Mevcut Durum Analizi

### ✅ Şu Anki Sistem (Local Storage)
- **Veritabanı**: Hive (local NoSQL database)
- **Veri Saklama**: Cihazda lokal
- **장점 장점 Avantajlar**:
  - ⚡ Çok hızlı (offline çalışır)
  - 🔒 Gizlilik (veriler cihazda)
  - 💰 Maliyetsiz

- **❌ Dezavantajlar**:
  - 📱 Uygulama silinirse veriler kaybolur
  - 🔄 Farklı cihazlar arası senkronizasyon yok
  - 👤 Kullanıcı hesabı yok (multi-device kullanım imkansız)
  - 📊 Analytics ve istatistik toplama zorluğu
  - 🔧 Uzaktan güncelleme/yönetim imkansız

---

## 🎯 Önerilen Çözüm: Hybrid Yaklaşım

### Mimari: Local + Cloud Senkronizasyonu

```
┌─────────────────────────────────────────────────────────┐
│                    ZindeAI Flutter App                  │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────┐            ┌──────────────────────┐  │
│  │  Hive (Local)│◄──────────►│  Sync Service        │  │
│  │  - Offline   │            │  - Auto sync         │  │
│  │  - Cache     │            │  - Conflict resolve  │  │
│  └──────────────┘            └──────────┬───────────┘  │
│                                          │              │
└──────────────────────────────────────────┼──────────────┘
                                           │
                                           ▼
                              ┌────────────────────────┐
                              │   Supabase Cloud       │
                              │ ┌──────────────────┐   │
                              │ │  PostgreSQL DB   │   │
                              │ └──────────────────┘   │
                              │ ┌──────────────────┐   │
                              │ │  Auth (JWT)      │   │
                              │ └──────────────────┘   │
                              │ ┌──────────────────┐   │
                              │ │  Realtime Sync   │   │
                              │ └──────────────────┘   │
                              │ ┌──────────────────┐   │
                              │ │  Storage (Files) │   │
                              │ └──────────────────┘   │
                              └────────────────────────┘
```

---

## 🏗️ Backend Seçimi: Supabase

### Neden Supabase?

#### ✅ Avantajlar:
1. **Open Source & Self-Hosted Opsiyonu**
   - Vendor lock-in riski yok
   - Gelecekte kendi sunucunuza taşıyabilirsiniz

2. **PostgreSQL Based**
   - Güçlü, güvenilir, scalable
   - SQL desteği (complex queries)
   - ACID compliance

3. **Built-in Auth System**
   - Email/Password
   - Google, Apple, Facebook OAuth
   - JWT token based
   - Row Level Security (RLS)

4. **Realtime Capabilities**
   - WebSocket based
   - Automatic data sync
   - Presence tracking

5. **Flutter SDK**
   - Official support
   - Well-documented
   - Active community

6. **Free Tier**
   - 500MB database
   - 1GB file storage
   - 50,000 monthly active users
   - Unlimited API requests

7. **Türkiye'de Kullanım**
   - Yasal olarak uygun
   - GDPR compliant
   - Data residency seçeneği

#### 🆚 Alternatifler (Neden Tercih Edilmedi?)

**Firebase:**
- ✅ Google ekosistemi
- ❌ NoSQL only (Firestore)
- ❌ SQL complex queries yok
- ❌ Vendor lock-in riski yüksek
- ❌ Pricing unpredictable

**AWS Amplify:**
- ✅ Scalable
- ❌ Çok karmaşık setup
- ❌ Pahalı
- ❌ Steep learning curve

**Parse Server:**
- ✅ Open source
- ❌ Deprecated/maintenance mode
- ❌ Community support azaldı

---

## 📋 Veritabanı Şeması (PostgreSQL)

### 1️⃣ Users Tablosu
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  
  -- Profil bilgileri
  ad TEXT,
  soyad TEXT,
  cinsiyet TEXT CHECK (cinsiyet IN ('erkek', 'kadın')),
  dogum_tarihi DATE,
  boy_cm INTEGER,
  kilo_kg DECIMAL(5,2),
  hedef_kilo_kg DECIMAL(5,2),
  aktivite_seviyesi TEXT,
  
  -- Makro hedefleri
  gunluk_kalori INTEGER,
  gunluk_protein INTEGER,
  gunluk_karbonhidrat INTEGER,
  gunluk_yag INTEGER,
  
  -- Kısıtlamalar ve tercihler (JSON array)
  kisitlamalar JSONB DEFAULT '[]'::jsonb,
  tercihler JSONB DEFAULT '[]'::jsonb,
  
  -- Metadata
  last_sync_at TIMESTAMP
);

-- Row Level Security (RLS)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only access own data"
  ON users FOR ALL
  USING (auth.uid() = id);
```

### 2️⃣ Daily Plans Tablosu
```sql
CREATE TABLE daily_plans (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  tarih DATE NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  
  -- Plan özeti
  toplam_kalori DECIMAL(10,2),
  toplam_protein DECIMAL(10,2),
  toplam_karbonhidrat DECIMAL(10,2),
  toplam_yag DECIMAL(10,2),
  
  -- Tolerans bilgileri
  tum_makrolar_toleransta BOOLEAN DEFAULT true,
  makro_kalite_skoru DECIMAL(5,2),
  tolerans_asan_makrolar JSONB DEFAULT '[]'::jsonb,
  
  -- Metadata
  plan_notu TEXT,
  last_sync_at TIMESTAMP,
  
  UNIQUE(user_id, tarih)
);

-- RLS
ALTER TABLE daily_plans ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only access own plans"
  ON daily_plans FOR ALL
  USING (auth.uid() = user_id);

-- Index for performance
CREATE INDEX idx_daily_plans_user_tarih ON daily_plans(user_id, tarih DESC);
```

### 3️⃣ Meals Tablosu
```sql
CREATE TABLE meals (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  plan_id UUID REFERENCES daily_plans(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  
  -- Yemek bilgileri
  yemek_id TEXT NOT NULL, -- Local Hive yemek ID'si
  ad TEXT NOT NULL,
  ogun_tipi TEXT NOT NULL,
  
  -- Makro değerler
  kalori DECIMAL(10,2),
  protein DECIMAL(10,2),
  karbonhidrat DECIMAL(10,2),
  yag DECIMAL(10,2),
  
  -- Malzemeler
  malzemeler JSONB DEFAULT '[]'::jsonb,
  
  -- Durum bilgisi
  durum TEXT CHECK (durum IN ('bekliyor', 'yedi', 'onaylandi', 'ataldi')),
  yenme_zamani TIMESTAMP,
  
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  last_sync_at TIMESTAMP
);

-- RLS
ALTER TABLE meals ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only access own meals"
  ON meals FOR ALL
  USING (auth.uid() = user_id);

-- Index
CREATE INDEX idx_meals_plan ON meals(plan_id);
CREATE INDEX idx_meals_user ON meals(user_id, created_at DESC);
```

### 4️⃣ Workout History Tablosu
```sql
CREATE TABLE workout_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  tarih DATE NOT NULL,
  program_adi TEXT NOT NULL,
  
  -- Egzersiz detayları (JSON)
  egzersizler JSONB NOT NULL,
  
  -- Özet
  toplam_sure_dk INTEGER,
  yaklasik_kalori INTEGER,
  
  -- Notlar
  kullanici_notu TEXT,
  
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  last_sync_at TIMESTAMP
);

-- RLS
ALTER TABLE workout_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only access own workouts"
  ON workout_history FOR ALL
  USING (auth.uid() = user_id);

-- Index
CREATE INDEX idx_workout_user_tarih ON workout_history(user_id, tarih DESC);
```

### 5️⃣ Sync Queue Tablosu (Offline Sync için)
```sql
CREATE TABLE sync_queue (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  
  -- Sync operation details
  entity_type TEXT NOT NULL, -- 'meal', 'plan', 'profile', etc.
  entity_id TEXT NOT NULL,
  operation TEXT NOT NULL CHECK (operation IN ('create', 'update', 'delete')),
  data JSONB NOT NULL,
  
  -- Metadata
  created_at TIMESTAMP DEFAULT NOW(),
  synced BOOLEAN DEFAULT false,
  synced_at TIMESTAMP,
  retry_count INTEGER DEFAULT 0,
  error_message TEXT
);

-- RLS
ALTER TABLE sync_queue ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only access own sync queue"
  ON sync_queue FOR ALL
  USING (auth.uid() = user_id);

-- Index
CREATE INDEX idx_sync_queue_unsynced ON sync_queue(user_id, synced, created_at)
  WHERE synced = false;
```

---

## 🔧 Flutter Entegrasyonu

### 1️⃣ Supabase Setup

#### pubspec.yaml
```yaml
dependencies:
  supabase_flutter: ^2.0.0
  # Mevcut dependencies...
  hive: ^2.2.3
  hive_flutter: ^1.1.0
```

#### lib/core/services/supabase_service.dart
```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  SupabaseService._();

  late final SupabaseClient client;
  
  Future<void> init() async {
    await Supabase.initialize(
      url: 'YOUR_SUPABASE_URL',
      anonKey: 'YOUR_SUPABASE_ANON_KEY',
    );
    
    client = Supabase.instance.client;
  }
  
  // Auth helpers
  User? get currentUser => client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
}
```

### 2️⃣ Auth Implementation

#### lib/core/services/auth_service.dart
```dart
class AuthService {
  final _supabase = SupabaseService.instance.client;
  
  // Email/Password signup
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
    );
  }
  
  // Email/Password login
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
  
  // Google OAuth
  Future<bool> signInWithGoogle() async {
    return await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.zindeai://callback',
    );
  }
  
  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
  
  // Password reset
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }
}
```

### 3️⃣ Sync Service (Hybrid Approach)

#### lib/core/services/sync_service.dart
```dart
class SyncService {
  final _supabase = SupabaseService.instance.client;
  final _hiveService = HiveService();
  
  // Auto-sync when online
  Future<void> syncAll() async {
    if (!await _isOnline()) return;
    
    await Future.wait([
      _syncProfile(),
      _syncDailyPlans(),
      _syncMeals(),
      _syncWorkouts(),
    ]);
  }
  
  // Profil senkronizasyonu
  Future<void> _syncProfile() async {
    final userId = SupabaseService.instance.currentUser?.id;
    if (userId == null) return;
    
    // Local profil al
    final localProfile = await _hiveService.getProfile();
    if (localProfile == null) return;
    
    // Cloud'a gönder (upsert)
    await _supabase.from('users').upsert({
      'id': userId,
      'ad': localProfile.ad,
      'soyad': localProfile.soyad,
      'cinsiyet': localProfile.cinsiyet,
      'boy_cm': localProfile.boyCm,
      'kilo_kg': localProfile.kiloKg,
      'hedef_kilo_kg': localProfile.hedefKiloKg,
      'gunluk_kalori': localProfile.makroHedefleri.gunlukKalori,
      'gunluk_protein': localProfile.makroHedefleri.gunlukProtein,
      'gunluk_karbonhidrat': localProfile.makroHedefleri.gunlukKarbonhidrat,
      'gunluk_yag': localProfile.makroHedefleri.gunlukYag,
      'kisitlamalar': localProfile.kisitlamalar,
      'tercihler': localProfile.tercihler,
      'last_sync_at': DateTime.now().toIso8601String(),
    });
  }
  
  // Günlük plan senkronizasyonu
  Future<void> _syncDailyPlans() async {
    final userId = SupabaseService.instance.currentUser?.id;
    if (userId == null) return;
    
    // Son 30 günlük planları sync et
    final plans = await _hiveService.getPlansLastNDays(30);
    
    for (final plan in plans) {
      await _supabase.from('daily_plans').upsert({
        'user_id': userId,
        'tarih': plan.tarih.toIso8601String().split('T')[0],
        'toplam_kalori': plan.toplamKalori,
        'toplam_protein': plan.toplamProtein,
        'toplam_karbonhidrat': plan.toplamKarbonhidrat,
        'toplam_yag': plan.toplamYag,
        'tum_makrolar_toleransta': plan.tumMakrolarToleranstaMi,
        'makro_kalite_skoru': plan.makroKaliteSkoru,
        'tolerans_asan_makrolar': plan.toleransAsanMakrolar,
        'last_sync_at': DateTime.now().toIso8601String(),
      });
    }
  }
  
  // Öğün senkronizasyonu
  Future<void> _syncMeals() async {
    final userId = SupabaseService.instance.currentUser?.id;
    if (userId == null) return;
    
    // Sync edilmemiş öğünleri al
    final unsyncedMeals = await _hiveService.getUnsyncedMeals();
    
    for (final meal in unsyncedMeals) {
      await _supabase.from('meals').upsert({
        'user_id': userId,
        'plan_id': meal.planId,
        'yemek_id': meal.id,
        'ad': meal.ad,
        'ogun_tipi': meal.ogun.name,
        'kalori': meal.kalori,
        'protein': meal.protein,
        'karbonhidrat': meal.karbonhidrat,
        'yag': meal.yag,
        'malzemeler': meal.malzemeler,
        'durum': meal.durum.name,
        'yenme_zamani': meal.yenmeZamani?.toIso8601String(),
        'last_sync_at': DateTime.now().toIso8601String(),
      });
      
      // Local olarak synced olarak işaretle
      await _hiveService.markMealAsSynced(meal.id);
    }
  }
  
  // Internet bağlantı kontrolü
  Future<bool> _isOnline() async {
    try {
      final result = await InternetAddress.lookup('supabase.co');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
```

### 4️⃣ Offline-First Strategy

#### lib/core/services/offline_first_repository.dart
```dart
class OfflineFirstRepository {
  final _hiveService = HiveService();
  final _syncService = SyncService();
  
  // Meal kaydet (local-first)
  Future<void> saveMeal(Yemek yemek) async {
    // 1. Önce local'e kaydet
    await _hiveService.saveMeal(yemek);
    
    // 2. Sync queue'ya ekle
    await _hiveService.addToSyncQueue(
      entityType: 'meal',
      entityId: yemek.id,
      operation: 'create',
      data: yemek.toJson(),
    );
    
    // 3. Online ise hemen sync et
    if (await _isOnline()) {
      await _syncService.syncAll();
    }
  }
  
  // Meal getir (cache-first)
  Future<Yemek?> getMeal(String id) async {
    // Önce local cache'den dene
    final localMeal = await _hiveService.getMeal(id);
    if (localMeal != null) return localMeal;
    
    // Local'de yoksa cloud'dan çek
    if (await _isOnline()) {
      final cloudMeal = await _fetchFromCloud(id);
      if (cloudMeal != null) {
        // Cache'e kaydet
        await _hiveService.saveMeal(cloudMeal);
        return cloudMeal;
      }
    }
    
    return null;
  }
}
```

---

## 🎨 UI Değişiklikleri

### 1️⃣ Login/Signup Sayfaları

#### lib/presentation/pages/auth/login_page.dart
```dart
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Icon(Icons.restaurant_menu, size: 100, color: Colors.purple),
              SizedBox(height: 24),
              Text(
                'ZindeAI',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 48),
              
              // Email field
              TextField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              
              // Password field
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Şifre',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 24),
              
              // Login button
              ElevatedButton(
                onPressed: () async {
                  // Login logic
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('Giriş Yap'),
              ),
              SizedBox(height: 16),
              
              // Google login
              OutlinedButton.icon(
                onPressed: () async {
                  // Google login
                },
                icon: Icon(Icons.g_mobiledata),
                label: Text('Google ile Giriş'),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              SizedBox(height: 16),
              
              // Signup link
              TextButton(
                onPressed: () {
                  // Navigate to signup
                },
                child: Text('Hesabın yok mu? Kayıt Ol'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 2️⃣ Sync Status Widget

#### lib/presentation/widgets/sync_status_widget.dart
```dart
class SyncStatusWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SyncStatus>(
      stream: SyncService.instance.syncStatusStream,
      builder: (context, snapshot) {
        final status = snapshot.data ?? SyncStatus.idle;
        
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(status),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_getStatusIcon(status), size: 16, color: Colors.white),
              SizedBox(width: 6),
              Text(
                _getStatusText(status),
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Color _getStatusColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.syncing:
        return Colors.blue;
      case SyncStatus.synced:
        return Colors.green;
      case SyncStatus.offline:
        return Colors.orange;
      case SyncStatus.error:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
```

---

## 📱 Implementasyon Aşamaları

### Faz 1: Supabase Setup (1-2 gün)
- [ ] Supabase projesi oluştur
- [ ] Database şemasını deploy et
- [ ] Row Level Security (RLS) policies ekle
- [ ] API keys al ve .env dosyasına ekle

### Faz 2: Auth Implementation (2-3 gün)
- [ ] AuthService sınıfı oluştur
- [ ] Login/Signup UI sayfaları
- [ ] Google OAuth entegrasyonu
- [ ] Password reset flow
- [ ] Auth state management (Bloc)

### Faz 3: Sync Service (3-4 gün)
- [ ] SyncService temel altyapısı
- [ ] Offline-first repository pattern
- [ ] Sync queue mekanizması
- [ ] Conflict resolution stratejisi
- [ ] Background sync (WorkManager)

### Faz 4: UI Updates (2-3 gün)
- [ ] Sync status indicator
- [ ] Settings page (hesap yönetimi)
- [ ] Data migration (local → cloud)
- [ ] Loading states & error handling

### Faz 5: Testing & Optimization (2-3 gün)
- [ ] Unit tests
- [ ] Integration tests
- [ ] Performance optimization
- [ ] Network resilience tests
- [ ] Multi-device sync testi

**Toplam Süre**: ~10-15 gün

---

## 💰 Maliyet Analizi

### Supabase Free Tier (İlk Kullanıcılar için Yeterli)
- ✅ 500MB database
- ✅ 1GB file storage
- ✅ 50,000 monthly active users
- ✅ Unlimited API requests
- ✅ 2GB egress bandwidth

### Paid Tier ($25/ay - Pro Plan)
- 8GB database
- 100GB file storage
- 100,000 monthly active users
- 250GB egress bandwidth

### Maliyet Projeksiyonu
| Kullanıcı Sayısı | Plan | Aylık Maliyet |
|------------------|------|---------------|
| 0 - 50,000 | Free | $0 |
| 50,000 - 100,000 | Pro | $25 |
| 100,000+ | Enterprise | Custom |

---

## 🔐 Güvenlik Önlemleri

### 1. Row Level Security (RLS)
- Her tablo için kullanıcı bazlı erişim kontrolü
- Kullanıcılar sadece kendi verilerine erişebilir

### 2. API Key Management
- Anon key: Public (frontend)
- Service key: Private (backend only)
- Environment variables ile yönetim

### 3. Data Encryption
- At rest: PostgreSQL native encryption
- In transit: TLS/SSL
- Passwords: bcrypt hashing

### 4. Rate Limiting
- API abuse önleme
- DDoS koruması
- Brute force prevention

---

## 📊 Monitoring & Analytics

### Supabase Dashboard
- Real-time database stats
- API usage metrics
- Auth events
- Error logs

### Sentry Integration (Hata Takibi)
```yaml
dependencies:
  sentry_flutter: ^7.0.0
```

### Firebase Analytics (Opsiyonel)
```yaml
dependencies:
  firebase_analytics: ^10.0.0
```

---

## 🚀 Deployment Checklist

### Backend (Supabase)
- [ ] Production database oluştur
- [ ] RLS policies test et
- [ ] API keys rotate et
- [ ] Backup stratejisi ayarla
- [ ] Monitoring kur

### Frontend (Flutter App)
- [ ] Environment variables (.env)
- [ ] Build release APK/IPA
- [ ] Google Play Store setup
- [ ] App Store setup
- [ ] Privacy Policy & Terms

---

## 📚 Kaynaklar

### Dokümantasyon
- [Supabase Docs](https://supabase.com/docs)
- [Supabase Flutter SDK](https://supabase.com/docs/reference/dart/introduction)
- [PostgreSQL Docs](https://www.postgresql.org/docs/)

### Örnekler
- [Supabase Flutter Examples](https://github.com/supabase/examples)
- [Offline-First Flutter App](https://github.com/supabase-community/flutter-offline-first)

---

## 🎯 Sonuç

Bu plan sayesinde:
- ✅ Kullanıcı hesapları ve auth sistemi
- ✅ Cihazlar arası senkronizasyon
- ✅ Offline-first deneyim (hızlı + güvenilir)
- ✅ Veri yedeği (cloud backup)
- ✅ Scalable altyapı (100k+ kullanıcı)
- ✅ Analytics ve monitoring
- ✅ Maliyetli başlangıç (Free tier)

**İlk Adım**: Supabase projesi oluştur ve database şemasını deploy <line_count>918</line_count>

Harika! Tüm UI geliştirmeleri tamamlandı. Şimdi "Backend entegrasyon planı oluştur" görevine geçelim.

İşte projeniz için detaylı bir backend entegrasyon planı:

## 🚀 Backend Entegrasyon Planı: Hibrit Yaklaşım (Hive + Cloud)

Mevcut durumda uygulamanız lokal veri depolama için Hive kullanıyor. Kullanıcı deneyimini artırmak ve uygulamanın ölçeklenebilirliğini sağlamak için hibrit bir yaklaşım öneriyorum: **Hive (lokal) + Supabase/Firebase (bulut)**.

### 🎯 Genel Hedefler:
1.  **Kullanıcı Yönetimi**: Güvenli kullanıcı kaydı, girişi ve oturum yönetimi.
2.  **Veri Senkronizasyonu**: Kullanıcı verilerinin (beslenme planları, makro hedefleri, tamamlanan öğünler vb.) cihazlar arası senkronizasyonu ve yedeklenmesi.
3.  **Offline Destek**: İnternet bağlantısı olmadığında uygulamanın temel işlevselliğini sürdürmesi.
4.  **Ölçeklenebilirlik**: Gelecekteki özellikler (topluluk, gelişmiş raporlama vb.) için sağlam bir altyapı.

### 🛠️ Önerilen Teknoloji Yığını:
*   **Lokal Veritabanı**: Hive (Mevcut)
*   **Bulut Backend**: Supabase (Önerilir) veya Firebase
    *   **Supabase Avantajları**: PostgreSQL (ilişkisel veri), Oturum Yönetimi (Auth), Gerçek Zamanlı Veri (Realtime), Depolama (Storage), Fonksiyonlar (Edge Functions). Flutter ile entegrasyonu kolaydır.
    *   **Firebase Avantajları**: Google ekosistemi ile entegrasyon, NoSQL (Firestore), Oturum Yönetimi (Auth), Depolama (Storage), Bulut Fonksiyonları (Cloud Functions).

### 📝 Entegrasyon Adımları ve Modüller:

#### 1. Kullanıcı Yönetimi (Authentication)
*   **Modül**: `auth_repository.dart`, `auth_service.dart`
*   **Fonksiyonlar**:
    *   `register(email, password)`: Yeni kullanıcı kaydı.
    *   `login(email, password)`: Mevcut kullanıcı girişi.
    *   `logout()`: Kullanıcı çıkışı.
    *   `resetPassword(email)`: Şifre sıfırlama.
    *   `getCurrentUser()`: Oturum açmış kullanıcı bilgilerini getir.
*   **Entegrasyon**:
    *   Supabase Auth veya Firebase Auth kullanılacak.
    *   Kullanıcı giriş yaptığında, `userId` bilgisi lokal Hive veritabanında saklanacak ve tüm kullanıcıya özel veriler bu `userId` ile ilişkilendirilecek.

#### 2. Veri Modelleri ve API Tasarımı
*   **Modül**: `cloud_data_source.dart`, `cloud_repository.dart`
*   **Veri Modelleri**: Mevcut `Yemek`, `GunlukPlan`, `MakroHedefleri`, `KullaniciProfili` gibi entity'ler bulut veritabanına uygun hale getirilecek (örn. `toJson`, `fromJson` metotları güncellenecek).
*   **API Endpoints (Örnek Supabase için)**:
    *   `/profiles`: Kullanıcı profili CRUD işlemleri.
    *   `/meal_plans`: Günlük/haftalık beslenme planları CRUD işlemleri.
    *   `/completed_meals`: Tamamlanan öğünlerin kaydedilmesi.
    *   `/macro_targets`: Kullanıcı makro hedefleri CRUD işlemleri.
*   **Entegrasyon**:
    *   Supabase için PostgreSQL tabloları oluşturulacak ve RLS (Row Level Security) ile kullanıcı bazlı veri erişimi sağlanacak.
    *   Firebase için Firestore koleksiyonları oluşturulacak ve güvenlik kuralları (Security Rules) ile erişim kontrolü yapılacak.

#### 3. Veri Senkronizasyonu Stratejisi
*   **Modül**: `sync_service.dart`
*   **Strateji**: "Last Write Wins" (Son yazan kazanır) veya "Conflict Resolution" (Çatışma çözümü)
    *   **Uygulama Başlangıcında**: Lokal Hive verileri ile bulut verileri karşılaştırılır ve en güncel olanlar senkronize edilir.
    *   **Periyodik Senkronizasyon**: Uygulama arka planda belirli aralıklarla veya önemli bir değişiklik olduğunda (örn. öğün tamamlandığında, plan oluşturulduğunda) otomatik senkronizasyon yapar.
    *   **Manuel Senkronizasyon**: Kullanıcıya "Şimdi Senkronize Et" butonu sunulabilir.
*   **Entegrasyon**:
    *   `HomeBloc` veya ilgili BLoC'lar, veri değişikliklerini hem Hive'a hem de buluta yazacak şekilde güncellenecek.
    *   `Connectivity` paketi ile internet bağlantısı kontrol edilecek. Bağlantı yoksa, değişiklikler lokalde tutulacak ve bağlantı geldiğinde senkronize edilecek (Queue/Buffer mekanizması).

#### 4. Offline Destek
*   **Modül**: `local_data_source.dart` (Mevcut Hive)
*   **Strateji**:
    *   Uygulama, internet bağlantısı olmasa bile en son senkronize edilmiş verileri Hive'dan okuyarak çalışmaya devam edecek.
    *   Kullanıcı lokalde yaptığı değişiklikler (örn. öğün tamamlama) bir "bekleyen senkronizasyon" kuyruğuna alınacak.
    *   İnternet bağlantısı geri geldiğinde, bu bekleyen değişiklikler buluta gönderilecek.

#### 5. Hata Yönetimi ve Kullanıcı Geri Bildirimi
*   **Modül**: `error_handler.dart`, `notification_service.dart`
*   **Hata Tipleri**: Ağ hataları, kimlik doğrulama hataları, veri tutarsızlığı hataları.
*   **Geri Bildirim**:
    *   Kullanıcıya `SnackBar` veya `AlertDialog` ile anlaşılır hata mesajları gösterilecek.
    *   Senkronizasyon durumunu gösteren küçük bir ikon veya metin (örn. "Senkronize Ediliyor...", "Offline Mod") eklenebilir.
*   **Logging**: Hatalar, uygulamanın debug modunda konsola, üretimde ise bir hata izleme servisine (örn. Sentry, Crashlytics) gönderilecek.

### 💡 Ek Notlar:
*   **Güvenlik**: API anahtarları ve hassas bilgiler `.env` dosyalarında veya Flutter'ın `flutter_dotenv` paketi ile yönetilmeli. Asla doğrudan koda yazılmamalı.
*   **Performans**: Büyük veri setleri için sayfalama (pagination) ve lazy loading teknikleri uygulanabilir.
*   **Test**: Backend entegrasyonu için unit ve integration testleri yazılmalı.

Bu plan, uygulamanızın gelecekteki büyümesi için sağlam bir temel oluşturacaktır.

<attempt_completion>
<result>
Tüm UI geliştirmeleri (shimmer effect, öğün kartı animasyonları, Hero transitions, FAB, pull-to-refresh feedback, empty states, makro özet progress ring) tamamlandı ve backend entegrasyon planı detaylı bir şekilde oluşturuldu.
</result>
</attempt_completion>