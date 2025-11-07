// lib/presentation/pages/ai_chatbot_page.dart
// AI Chatbot Sayfası - Supplement Danışmanlığı

import 'package:flutter/material.dart';
import '../../core/services/pollinations_ai_service.dart';
import '../../core/utils/app_logger.dart';
import '../../data/local/hive_service.dart';
import '../../domain/entities/kullanici_profili.dart';
import '../../domain/entities/hedef.dart';

class AIChatbotPage extends StatefulWidget {
  const AIChatbotPage({Key? key}) : super(key: key);

  @override
  State<AIChatbotPage> createState() => _AIChatbotPageState();
}

class _AIChatbotPageState extends State<AIChatbotPage> {
  AICategory _selectedCategory = AICategory.supplement;
  final List<ChatMessage> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  KullaniciProfili? _kullaniciProfili;

  @override
  void initState() {
    super.initState();
    // Kullanıcı profilini yükle
    _loadUserProfile();
    // Hoş geldin mesajı ekle
    _addWelcomeMessage();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profil = await HiveService.kullaniciGetir();
      setState(() {
        _kullaniciProfili = profil;
      });
      AppLogger.info('👤 Kullanıcı profili AI chatbot\'a yüklendi: ${profil?.ad} ${profil?.soyad}');
    } catch (e) {
      AppLogger.error('❌ Kullanıcı profili yükleme hatası', error: e);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    final welcomeText = _getWelcomeText(_selectedCategory);
    setState(() {
      _messages.add(ChatMessage(
        text: welcomeText,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  String _getWelcomeText(AICategory category) {
    switch (category) {
      case AICategory.supplement:
        return '👋 Merhaba! Ben Dr. Ahmet Yılmaz, 30 yıllık deneyime sahip supplement uzmanıyım.\n\n'
            '💊 Whey protein, creatine, BCAA, vitaminler ve tüm supplement konularında size yardımcı olabilirim.\n\n'
            'Bana kilo, boy, yaş bilgilerinizi ve hedefinizi söylerseniz, size özel supplement programı hazırlayabilirim!';
      case AICategory.nutrition:
        return '👋 Merhaba! Ben Uzm. Dyt. Ayşe Demir, 30 yıllık deneyimli diyetisyeniyim.\n\n'
            '🥗 Beslenme planları, makro hesaplama, Türk mutfağına uygun diyet önerileri konularında size yardımcı olabilirim.\n\n'
            'Bana kilo, boy, yaş ve hedefinizi söylerseniz, size özel beslenme planı hazırlayabilirim!';
      case AICategory.training:
        return '👋 Merhaba! Ben Hakan Kaya, 30 yıllık deneyimli fitness antrenörüyüm.\n\n'
            '💪 Antrenman programları, kas geliştirme, yağ yakma ve fitness konularında size yardımcı olabilirim.\n\n'
            'Bana deneyim seviyenizi, hedefinizi ve ekipman durumunuzu söylerseniz, size özel program hazırlayabilirim!';
      case AICategory.general:
        return '👋 Merhaba! Ben Dr. Zeynep Aydın, 30 yıllık genel sağlık uzmanıyım.\n\n'
            '🏥 Sağlıklı yaşam, uyku, stres yönetimi ve genel sağlık konularında size yardımcı olabilirim.\n\n'
            'Sorularınızı bekliyorum!';
      case AICategory.dietician:
        return '👋 Merhaba! Ben Uzm. Dyt. Elif Kaya, 20 yıllık deneyimli profesyonel diyetisyeniyim.\n\n'
            '🍽️ Türk mutfağından günlük ve haftalık beslenme planları hazırlıyorum. SADECE yerli yemeklerle (menemen, köfte, pilav, balık) size özel planlar oluşturabilirim.\n\n'
            'Bana kilo, boy, yaş ve hedefinizi söylerseniz, size Türk mutfağından beslenme planı hazırlayabilirim!';
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    // Kullanıcı mesajını ekle
    setState(() {
      _messages.add(ChatMessage(
        text: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    // Scroll to bottom
    _scrollToBottom();

    try {
      // AI'dan yanıt al (profil bilgilerini de geçir)
      final aiResponse = await PollinationsAIService.getResponse(
        userMessage: userMessage,
        category: _selectedCategory,
        conversationHistory: _getConversationHistory(),
        userProfile: _kullaniciProfili,
      );

      // AI yanıtını ekle
      setState(() {
        _messages.add(ChatMessage(
          text: aiResponse,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });

      // Scroll to bottom
      _scrollToBottom();
    } catch (e) {
      AppLogger.error('AI Chat Error: $e');
      setState(() {
        _messages.add(ChatMessage(
          text: '❌ Üzgünüm, bir hata oluştu. Lütfen tekrar dene.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    }
  }

  List<Map<String, String>> _getConversationHistory() {
    // Son 10 mesajı gönder (performans için)
    final recentMessages = _messages.length > 10
        ? _messages.sublist(_messages.length - 10)
        : _messages;

    return recentMessages
        .where((m) => m.isUser || !m.text.startsWith('👋')) // Hoş geldin mesajını ekleme
        .map((m) => {
              'role': m.isUser ? 'user' : 'assistant',
              'content': m.text,
            })
        .toList();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _changeCategory(AICategory newCategory) {
    setState(() {
      _selectedCategory = newCategory;
      _messages.clear();
      _addWelcomeMessage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          PollinationsAIService.categoryDescriptions[_selectedCategory]!,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: _getCategoryColor(_selectedCategory),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Kategori değiştirme butonu
          PopupMenuButton<AICategory>(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Danışman Değiştir',
            onSelected: _changeCategory,
            itemBuilder: (context) => AICategory.values.map((category) {
              return PopupMenuItem(
                value: category,
                child: Row(
                  children: [
                    Text(
                      PollinationsAIService.categoryEmojis[category]!,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      PollinationsAIService.categoryDescriptions[category]!
                          .substring(3), // Emoji'yi çıkar
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          // Sohbeti temizle
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Sohbeti Temizle',
            onPressed: () {
              setState(() {
                _messages.clear();
                _addWelcomeMessage();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Kullanıcı profil kartı (varsa göster)
          if (_kullaniciProfili != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getCategoryColor(_selectedCategory).withOpacity(0.15),
                    _getCategoryColor(_selectedCategory).withOpacity(0.05),
                  ],
                ),
                border: Border(
                  bottom: BorderSide(
                    color: _getCategoryColor(_selectedCategory).withOpacity(0.3),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(_selectedCategory).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.person,
                      color: _getCategoryColor(_selectedCategory),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_kullaniciProfili!.ad} ${_kullaniciProfili!.soyad}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _getCategoryColor(_selectedCategory),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getProfilOzeti(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Kategori bilgi bandı
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getCategoryColor(_selectedCategory).withOpacity(0.1),
              border: Border(
                bottom: BorderSide(
                  color: _getCategoryColor(_selectedCategory).withOpacity(0.3),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(_selectedCategory),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    PollinationsAIService.categoryEmojis[_selectedCategory]!,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getCategoryName(_selectedCategory),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _getCategoryColor(_selectedCategory),
                        ),
                      ),
                      Text(
                        _getCategoryExpertise(_selectedCategory),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Chat mesajları
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatBubble(
                  message: message,
                  categoryColor: _getCategoryColor(_selectedCategory),
                );
              },
            ),
          ),

          // Loading indicator
          if (_isLoading)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getCategoryColor(_selectedCategory),
                      ),
                    ),
                  ),
        const SizedBox(width: 8),
        Text(
          'Yanıt yazılıyor...',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
                ],
              ),
            ),

          // Mesaj input alanı
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Mesajınızı yazın...',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: _getCategoryColor(_selectedCategory),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _isLoading ? null : _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(AICategory category) {
    switch (category) {
      case AICategory.supplement:
        return Colors.purple;
      case AICategory.nutrition:
        return Colors.green;
      case AICategory.training:
        return Colors.orange;
      case AICategory.general:
        return Colors.blue;
      case AICategory.dietician:
        return Colors.teal;
    }
  }

  String _getCategoryName(AICategory category) {
    switch (category) {
      case AICategory.supplement:
        return 'Dr. Ahmet Yılmaz';
      case AICategory.nutrition:
        return 'Uzm. Dyt. Ayşe Demir';
      case AICategory.training:
        return 'Hakan Kaya';
      case AICategory.general:
        return 'Dr. Zeynep Aydın';
      case AICategory.dietician:
        return 'Uzm. Dyt. Elif Kaya';
    }
  }

  String _getCategoryExpertise(AICategory category) {
    switch (category) {
      case AICategory.supplement:
        return '30 yıllık Supplement Uzmanı';
      case AICategory.nutrition:
        return '30 yıllık Diyetisyen';
      case AICategory.training:
        return '30 yıllık Fitness Antrenörü';
      case AICategory.general:
        return '30 yıllık Genel Sağlık Uzmanı';
      case AICategory.dietician:
        return '20 yıllık Profesyonel Türk Diyetisyeni';
    }
  }

  String _getProfilOzeti() {
    if (_kullaniciProfili == null) return '';
    
    final p = _kullaniciProfili!;
    final hedefText = _getHedefText(p.hedef);
    
    return '${p.yas} yaş • ${p.mevcutKilo.toStringAsFixed(0)}kg • ${p.boy.toStringAsFixed(0)}cm • $hedefText';
  }

  String _getHedefText(Hedef hedef) {
    return hedef.aciklama;
  }
}

// Chat Message Model
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

// Chat Bubble Widget
class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final Color categoryColor;

  const ChatBubble({
    Key? key,
    required this.message,
    required this.categoryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment:
              message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? categoryColor
                    : Colors.white,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomRight: message.isUser ? const Radius.circular(4) : null,
                  bottomLeft: !message.isUser ? const Radius.circular(4) : null,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Şimdi';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} dk önce';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} sa önce';
    } else {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}
