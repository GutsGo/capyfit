import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_provider.dart';
import '../models/diet_entry.dart';
import '../models/food_item.dart';
import '../theme/app_colors.dart';

class AddFoodSheet extends StatefulWidget {
  final MealType mealType;
  const AddFoodSheet({super.key, required this.mealType});

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

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppProvider>();
    final presets = appState.foodPresets
        .where((f) => f.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 24,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isAddingCustom ? '自定义食物' : '新增记录',
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

          const SizedBox(height: 32),
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
              child: TextField(
                decoration: InputDecoration(
                  hintText: '搜索食物...',
                  prefixIcon: const Icon(LucideIcons.search, size: 20),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => setState(() => _isAddingCustom = true),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
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
        TextField(
          controller: _weightController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: '摄入重量 (克)',
            suffixText: 'g',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saveEntry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              '保存',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomForm() {
    return Column(
      children: [
        _buildTextField(_nameController, '食物名称', '例如：苹果'),
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
          child: ElevatedButton(
            onPressed: _saveCustomFood,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              '保存并选择',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
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
    return TextField(
      controller: controller,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
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
    );

    Provider.of<AppProvider>(context, listen: false).addFoodPreset(food);
    setState(() {
      _selectedFood = food;
      _isAddingCustom = false;
    });
  }

  void _saveEntry() {
    if (_selectedFood == null) return;
    final weight = double.tryParse(_weightController.text) ?? 100;
    final ratio = weight / 100.0;

    final entry = DietEntry(
      id: DateTime.now().toString(),
      meal: widget.mealType,
      name: _selectedFood!.name,
      calories: (_selectedFood!.caloriesPer100g * ratio).round(),
      protein: _selectedFood!.proteinPer100g * ratio,
      carbs: _selectedFood!.carbsPer100g * ratio,
      fat: _selectedFood!.fatPer100g * ratio,
      time: TimeOfDay.now().format(context),
    );

    Provider.of<AppProvider>(context, listen: false).addDietEntry(entry);
    Navigator.pop(context);
  }
}
