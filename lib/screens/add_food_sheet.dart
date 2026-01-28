import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_provider.dart';
import '../models/diet_entry.dart';
import '../models/food_item.dart';
import '../theme/app_colors.dart';
import '../widgets/hand_drawn_widgets.dart';

class AddFoodSheet extends StatefulWidget {
  final MealType? mealType;
  final bool onlyAddToList;
  const AddFoodSheet({super.key, this.mealType, this.onlyAddToList = false});

  @override
  State<AddFoodSheet> createState() => _AddFoodSheetState();
}

class _AddFoodSheetState extends State<AddFoodSheet> {
  String _searchQuery = '';
  FoodItem? _selectedFood;
  final _weightController = TextEditingController(text: '100');

  bool _isAddingCustom = false;
  final _nameController = TextEditingController();
  final _calController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbController = TextEditingController();
  final _fatController = TextEditingController();
  final _emojiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.onlyAddToList) {
      _isAddingCustom = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppProvider>();
    final presets = appState.foodPresets
        .where((f) => f.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return HandDrawnContainer(
      color: AppColors.background,
      borderRadius: 32,
      margin: const EdgeInsets.all(12),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 12,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.onlyAddToList
                    ? '新增自定义食物'
                    : (_isAddingCustom ? '自定义食物' : '新增记录'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(LucideIcons.x),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_isAddingCustom)
            _buildCustomForm()
          else if (_selectedFood != null)
            _buildWeightInput()
          else
            _buildFoodList(presets),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildFoodList(List<FoodItem> presets) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: HandDrawnContainer(
                color: Colors.white,
                borderRadius: 16,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: '搜索食物...',
                    prefixIcon: Icon(LucideIcons.search, size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => setState(() => _isAddingCustom = true),
              child: HandDrawnContainer(
                padding: const EdgeInsets.all(12),
                color: Colors.white,
                borderRadius: 16,
                child: const Icon(
                  LucideIcons.plus,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          constraints: const BoxConstraints(maxHeight: 300),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: presets.length,
            itemBuilder: (context, index) {
              final food = presets[index];
              return ListTile(
                leading: food.emoji != null
                    ? Text(food.emoji!, style: const TextStyle(fontSize: 24))
                    : const Icon(LucideIcons.utensils, size: 20),
                title: Text(food.name),
                subtitle: Text('${food.caloriesPer100g.round()} kcal / 100g'),
                onTap: () => setState(() => _selectedFood = food),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeightInput() {
    return Column(
      children: [
        Text(
          _selectedFood!.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '营养成分 (100g): ${_selectedFood!.caloriesPer100g.round()}kcal, 蛋白${_selectedFood!.proteinPer100g}g',
          style: const TextStyle(color: AppColors.textMuted),
        ),
        const SizedBox(height: 24),
        HandDrawnContainer(
          color: Colors.white,
          borderRadius: 16,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: TextField(
            controller: _weightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '摄入重量 (克)',
              suffixText: 'g',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: HandDrawnButton(
            onPressed: _saveEntry,
            label: '保存',
            backgroundColor: AppColors.primary,
            textColor: Colors.white,
            height: 56,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomForm() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _buildTextField(_nameController, '食物名称', '例如：苹果'),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: _buildTextField(_emojiController, 'Emoji', '🍎'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                _calController,
                '热量 (kcal)',
                '每100g',
                isNum: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                _proteinController,
                '蛋白 (g)',
                '每100g',
                isNum: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                _carbController,
                '碳水 (g)',
                '每100g',
                isNum: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                _fatController,
                '脂肪 (g)',
                '每100g',
                isNum: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: HandDrawnButton(
            onPressed: _saveCustomFood,
            label: widget.onlyAddToList ? '保存食物' : '保存并选择',
            backgroundColor: AppColors.primary,
            textColor: Colors.white,
            height: 56,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    bool isNum = false,
  }) {
    return HandDrawnContainer(
      color: Colors.white,
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextField(
        controller: controller,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
        ),
      ),
    );
  }

  void _saveCustomFood() {
    if (_nameController.text.isEmpty) return;

    final food = FoodItem(
      id: DateTime.now().toString(),
      name: _nameController.text,
      caloriesPer100g: double.tryParse(_calController.text) ?? 0,
      proteinPer100g: double.tryParse(_proteinController.text) ?? 0,
      carbsPer100g: double.tryParse(_carbController.text) ?? 0,
      fatPer100g: double.tryParse(_fatController.text) ?? 0,
      emoji: _emojiController.text.isNotEmpty ? _emojiController.text : null,
    );

    Provider.of<AppProvider>(context, listen: false).addFoodPreset(food);

    if (widget.onlyAddToList) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      _selectedFood = food;
      _isAddingCustom = false;
    });
  }

  void _saveEntry() {
    if (_selectedFood == null || widget.mealType == null) return;
    final weight = double.tryParse(_weightController.text) ?? 100;
    final ratio = weight / 100.0;

    final entry = DietEntry(
      id: DateTime.now().toString(),
      meal: widget.mealType!,
      name: _selectedFood!.name,
      calories: (_selectedFood!.caloriesPer100g * ratio).round(),
      protein: _selectedFood!.proteinPer100g * ratio,
      carbs: _selectedFood!.carbsPer100g * ratio,
      fat: _selectedFood!.fatPer100g * ratio,
      time: TimeOfDay.now().format(context),
      date: DateTime.now().toString().split(' ')[0],
    );

    Provider.of<AppProvider>(context, listen: false).addDietEntry(entry);
    Navigator.pop(context);
  }
}
