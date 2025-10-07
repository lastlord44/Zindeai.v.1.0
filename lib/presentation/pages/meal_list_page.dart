import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/meal.dart';
import '../../presentation/providers/meal_provider.dart';

// ============================================================================
// MEAL LIST PAGE
// ============================================================================

class MealListPage extends StatefulWidget {
  final List<String> userRestrictions;
  final MealCategory? filterCategory;

  const MealListPage({
    Key? key,
    this.userRestrictions = const [],
    this.filterCategory,
  }) : super(key: key);

  @override
  State<MealListPage> createState() => _MealListPageState();
}

class _MealListPageState extends State<MealListPage> {
  MealCategory? _selectedCategory;
  GoalTag? _selectedGoal;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.filterCategory;
  }

  String _getCategoryName(MealCategory category) {
    switch (category) {
      case MealCategory.kahvalti:
        return 'Kahvaltı';
      case MealCategory.araOgun1:
        return 'Ara Öğün 1';
      case MealCategory.ogleYemegi:
        return 'Öğle Yemeği';
      case MealCategory.araOgun2:
        return 'Ara Öğün 2';
      case MealCategory.aksamYemegi:
        return 'Akşam Yemeği';
      case MealCategory.geceAtistirmasi:
        return 'Gece Atıştırması';
      case MealCategory.cheatMeal:
        return 'Cheat Meal';
    }
  }

  String _getGoalName(GoalTag goal) {
    switch (goal) {
      case GoalTag.yagKaybi:
        return 'Yağ Kaybı';
      case GoalTag.kasGelisimi:
        return 'Kas Gelişimi';
      case GoalTag.bakim:
        return 'Bakım';
    }
  }

  @override
  Widget build(BuildContext context) {
    final mealProvider = context.watch<MealProvider>();

    if (mealProvider.loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Öğün Listesi'),
          backgroundColor: Colors.purple.shade200,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (mealProvider.error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Öğün Listesi'),
          backgroundColor: Colors.purple.shade200,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Hata: ${mealProvider.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    // Filtreleme
    final filteredMeals = mealProvider.filter(
      category: _selectedCategory,
      goal: _selectedGoal,
      restrictions: widget.userRestrictions.isNotEmpty
          ? widget.userRestrictions
          : null,
    );

    final stats = mealProvider.getStatistics();

    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        title: const Text('Öğün Veritabanı'),
        backgroundColor: Colors.purple.shade200,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showStatistics(context, stats);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtreler
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filtreler',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<MealCategory?>(
                        initialValue: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Kategori',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Tümü'),
                          ),
                          ...MealCategory.values.map((cat) {
                            return DropdownMenuItem(
                              value: cat,
                              child: Text(_getCategoryName(cat)),
                            );
                          }),
                        ],
                        onChanged: (val) {
                          setState(() => _selectedCategory = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<GoalTag?>(
                        initialValue: _selectedGoal,
                        decoration: InputDecoration(
                          labelText: 'Hedef',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Tümü'),
                          ),
                          ...GoalTag.values.map((goal) {
                            return DropdownMenuItem(
                              value: goal,
                              child: Text(_getGoalName(goal)),
                            );
                          }),
                        ],
                        onChanged: (val) {
                          setState(() => _selectedGoal = val);
                        },
                      ),
                    ),
                  ],
                ),
                if (widget.userRestrictions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.filter_alt, color: Colors.amber.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Kısıtlamalarınıza göre filtrelendi',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Öğün sayısı
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredMeals.length} öğün bulundu',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_selectedCategory != null || _selectedGoal != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = null;
                        _selectedGoal = null;
                      });
                    },
                    child: const Text('Filtreleri Temizle'),
                  ),
              ],
            ),
          ),

          // Öğün listesi
          Expanded(
            child: filteredMeals.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Öğün bulunamadı',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredMeals.length,
                    itemBuilder: (context, index) {
                      final meal = filteredMeals[index];
                      return _buildMealCard(context, meal);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(BuildContext context, Meal meal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showMealDetails(context, meal),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      meal.mealName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildGoalBadge(meal.goalTag),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _getCategoryName(meal.category),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildMacroChip(
                    '${meal.calorie} kcal',
                    Colors.orange,
                    Icons.local_fire_department,
                  ),
                  const SizedBox(width: 8),
                  _buildMacroChip(
                    '${meal.proteinG}P',
                    Colors.red,
                    Icons.fitness_center,
                  ),
                  const SizedBox(width: 8),
                  _buildMacroChip(
                    '${meal.carbG}C',
                    Colors.amber,
                    Icons.grain,
                  ),
                  const SizedBox(width: 8),
                  _buildMacroChip(
                    '${meal.fatG}F',
                    Colors.green,
                    Icons.water_drop,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.timer, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '${meal.prepTimeMin} dk',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.restaurant, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    meal.difficulty.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroChip(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalBadge(GoalTag goal) {
    Color color;
    switch (goal) {
      case GoalTag.yagKaybi:
        color = Colors.blue;
        break;
      case GoalTag.kasGelisimi:
        color = Colors.red;
        break;
      case GoalTag.bakim:
        color = Colors.green;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getGoalName(goal),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showMealDetails(BuildContext context, Meal meal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: controller,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                meal.mealName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    _getCategoryName(meal.category),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildGoalBadge(meal.goalTag),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Makrolar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailMacroCard(
                      '${meal.calorie}',
                      'Kalori',
                      Colors.orange,
                      Icons.local_fire_department,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDetailMacroCard(
                      '${meal.proteinG}g',
                      'Protein',
                      Colors.red,
                      Icons.fitness_center,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailMacroCard(
                      '${meal.carbG}g',
                      'Karbonhidrat',
                      Colors.amber,
                      Icons.grain,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDetailMacroCard(
                      '${meal.fatG}g',
                      'Yağ',
                      Colors.green,
                      Icons.water_drop,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'İçindekiler',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...meal.ingredients.map((ingredient) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(Icons.circle,
                            size: 6, color: Colors.purple.shade400),
                        const SizedBox(width: 12),
                        Expanded(child: Text(ingredient)),
                      ],
                    ),
                  )),
              if (meal.allergens.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  'Alerjenler',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: meal.allergens
                      .map((allergen) => Chip(
                            label: Text(allergen),
                            backgroundColor: Colors.red.shade100,
                            avatar: const Icon(Icons.warning, size: 16),
                          ))
                      .toList(),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      'Hazırlama',
                      '${meal.prepTimeMin} dk',
                      Icons.timer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoCard(
                      'Zorluk',
                      meal.difficulty.name.toUpperCase(),
                      Icons.restaurant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailMacroCard(
      String value, String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.purple),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.purple,
            ),
          ),
        ],
      ),
    );
  }

  void _showStatistics(BuildContext context, Map<String, int> stats) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Veritabanı İstatistikleri'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Toplam Öğün: ${stats['totalMeals']}'),
            const Divider(),
            Text('Kahvaltı: ${stats['kahvalti']}'),
            Text('Ara Öğün 1: ${stats['araOgun1']}'),
            Text('Öğle Yemeği: ${stats['ogleYemegi']}'),
            Text('Ara Öğün 2: ${stats['araOgun2']}'),
            Text('Akşam Yemeği: ${stats['aksamYemegi']}'),
            Text('Gece Atıştırması: ${stats['geceAtistirmasi']}'),
            Text('Cheat Meal: ${stats['cheatMeal']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }
}
