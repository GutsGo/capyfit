import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:capyfit/providers/app_provider.dart';
import 'package:capyfit/data/models/diet_entry.dart';
import 'package:capyfit/data/models/food_database.dart';
import 'package:capyfit/data/services/food_db_service.dart';
import 'package:capyfit/ui/common/theme/app_colors.dart';
import 'package:capyfit/data/utils/validators.dart';
import 'package:capyfit/ui/common/widgets/hand_drawn_widgets.dart';

class AddFoodSheet extends StatefulWidget {
  final MealType? mealType;
  final bool onlyAddToList;
  const AddFoodSheet({super.key, this.mealType, this.onlyAddToList = false});

  @override
  State<AddFoodSheet> createState() => _AddFoodSheetState();
}

class _AddFoodSheetState extends State<AddFoodSheet> {
  final _formKey = GlobalKey<FormState>();
  final FoodDbService _foodService = FoodDbService();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  Timer? _debounceTimer;

  FoodDatabaseItem? _selectedDbFood;
  final _weightController = TextEditingController(text: '100');

  bool _isAddingCustom = false;
  bool _isLoading = false;
  List<FoodDatabaseItem> _searchResults = [];

  final _nameController = TextEditingController();
  final _calController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbController = TextEditingController();
  final _fatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.onlyAddToList) {
      _isAddingCustom = true;
    } else {
      _loadInitialFoods();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    _weightController.dispose();
    _nameController.dispose();
    _calController.dispose();
    _proteinController.dispose();
    _carbController.dispose();
    _fatController.dispose();

    super.dispose();
  }

  Future<void> _loadInitialFoods() async {
    setState(() => _isLoading = true);
    final foods = await _foodService.getPopularFoods(limit: 30);
    if (mounted) {
      setState(() {
        _searchResults = foods;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (_searchQuery != query) {
        _searchQuery = query;
        _searchFoods();
      }
    });
  }

  Future<void> _searchFoods() async {
    setState(() => _isLoading = true);
    final foods = await _foodService.search(_searchQuery, limit: 50);
    if (mounted) {
      setState(() {
        _searchResults = foods;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.onlyAddToList
                  ? '新增自定义食物'
                  : (_isAddingCustom ? '自定义食物' : '新增记录'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextMainColor(context),
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
        else if (_selectedDbFood != null)
          _buildWeightInput()
        else
          _buildFoodList(),

        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildFoodList() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: HandDrawnTextField(
                controller: _searchController,
                hintText: '搜索食物...',
                prefixIcon: Icon(
                  LucideIcons.search,
                  size: 20,
                  color: AppColors.getBorderColor(context),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                style: TextStyle(color: AppColors.getTextMainColor(context)),
                onChanged: _onSearchChanged,
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => setState(() => _isAddingCustom = true),
              child: HandDrawnContainer(
                padding: const EdgeInsets.all(12),
                color: AppColors.getCardColor(context),
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
          child: _isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              : _searchResults.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      '未找到相关食物',
                      style: TextStyle(
                        color: AppColors.getTextMutedColor(context),
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final food = _searchResults[index];
                    return ListTile(
                      leading: Text(
                        food.emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(
                        food.foodName,
                        style: TextStyle(
                          color: AppColors.getTextMainColor(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${food.energyKCal} kcal / 100g',
                        style: TextStyle(
                          color: AppColors.getTextMutedColor(context),
                        ),
                      ),
                      onTap: () => setState(() => _selectedDbFood = food),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildWeightInput() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // 食物信息卡片，可点击跳转到详情页
          GestureDetector(
            onTap: () {
              context.push('/diet/food', extra: _selectedDbFood);
            },
            child: HandDrawnContainer(
              color: AppColors.getCardColor(context),
              borderRadius: 16,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Text(
                    _selectedDbFood!.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedDbFood!.foodName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.getTextMainColor(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_selectedDbFood!.energyKCal} kcal · 蛋白质 ${_selectedDbFood!.protein}g · 碳水 ${_selectedDbFood!.cho}g',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.getTextMutedColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    LucideIcons.chevronRight,
                    size: 20,
                    color: AppColors.getTextMutedColor(context),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          HandDrawnTextField(
            controller: _weightController,
            keyboardType: TextInputType.number,
            labelText: '摄入重量 (克)',
            validator: Validators.foodWeight,
            suffixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'g',
                style: TextStyle(color: AppColors.getTextMutedColor(context)),
              ),
            ),
            style: TextStyle(color: AppColors.getTextMainColor(context)),
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
      ),
    );
  }

  Widget _buildCustomForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // 食物名称
          _buildTextField(
            _nameController,
            '食物名称',
            '例如：苹果',
            validator: (v) => Validators.required(v, '食物名称'),
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
                  validator: Validators.calories,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  _proteinController,
                  '蛋白质 (g)',
                  '每100g',
                  isNum: true,
                  validator: (v) => Validators.nutrient(v, '蛋白质'),
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
                  validator: (v) => Validators.nutrient(v, '碳水化合物'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  _fatController,
                  '脂肪 (g)',
                  '每100g',
                  isNum: true,
                  validator: (v) => Validators.nutrient(v, '脂肪'),
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
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    bool isNum = false,
    String? Function(String?)? validator,
  }) {
    return HandDrawnTextField(
      controller: controller,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      labelText: label,
      hintText: hint,
      validator: validator,
      style: TextStyle(color: AppColors.getTextMainColor(context)),
    );
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('提示'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _saveCustomFood() {
    if (!_formKey.currentState!.validate()) return;

    // 检查名称唯一性
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final existingFood = appProvider.foodPresets.any(
      (food) => food.name.toLowerCase() == _nameController.text.toLowerCase(),
    );
    if (existingFood) {
      _showError('已存在名为「${_nameController.text}」的食物，请修改。');
      return;
    }

    // 检查三大营养素总和
    final protein = double.tryParse(_proteinController.text) ?? 0;
    final fat = double.tryParse(_fatController.text) ?? 0;
    final carbs = double.tryParse(_carbController.text) ?? 0;
    if (protein + fat + carbs > 100) {
      _showError('蛋白质+脂肪+碳水化合物总和不能超过100g');
      return;
    }

    final id = DateTime.now().toString();

    // 创建 FoodDatabaseItem
    final dbFood = FoodDatabaseItem(
      foodCode: id,
      foodName: _nameController.text,
      energyKCal: _calController.text.isNotEmpty ? _calController.text : '0',
      protein: _proteinController.text.isNotEmpty
          ? _proteinController.text
          : '0',
      fat: _fatController.text.isNotEmpty ? _fatController.text : '0',
      cho: _carbController.text.isNotEmpty ? _carbController.text : '0',
      remark: '自定义食物',
    );

    // 转换为 FoodItem 并保存
    appProvider.addFoodPreset(dbFood.toFoodItem());

    // 如果是仅添加到列表模式，直接关闭
    if (widget.onlyAddToList) {
      Navigator.pop(context);
      return;
    }

    // 选中新增的食物，跳转到重量输入界面
    setState(() {
      _selectedDbFood = dbFood;
      _isAddingCustom = false;
    });
  }

  void _saveEntry() {
    if (_selectedDbFood == null || widget.mealType == null) return;
    if (!_formKey.currentState!.validate()) return;

    final weight = double.tryParse(_weightController.text) ?? 100;
    final ratio = weight / 100.0;

    final entry = DietEntry(
      id: DateTime.now().toString(),
      meal: widget.mealType!,
      name: _selectedDbFood!.foodName,
      calories: (_selectedDbFood!.calories * ratio).round(),
      protein: _selectedDbFood!.proteinValue * ratio,
      carbs: _selectedDbFood!.carbsValue * ratio,
      fat: _selectedDbFood!.fatValue * ratio,
      time: TimeOfDay.now().format(context),
      date: DateTime.now().toString().split(' ')[0],
      foodId: _selectedDbFood!.foodCode,
      isCustom: _selectedDbFood!.remark == '自定义食物',
      emoji: _selectedDbFood!.emoji,
    );

    Provider.of<AppProvider>(context, listen: false).addDietEntry(entry);
    Navigator.pop(context);
  }
}
