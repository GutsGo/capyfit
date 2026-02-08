import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:capyfit/providers/app_provider.dart';
import 'package:capyfit/data/models/diet_entry.dart';
import 'package:capyfit/data/models/food_database.dart';
import 'package:capyfit/data/services/food_db_service.dart';
import 'package:capyfit/data/services/diet_estimation_service.dart';
import 'package:capyfit/ui/common/theme/app_colors.dart';
import 'package:capyfit/data/utils/validators.dart';
import 'package:capyfit/ui/common/widgets/hand_drawn_widgets.dart';
import 'package:capyfit/data/utils/logger.dart';

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

  final DietEstimationService _estimationService = DietEstimationService();
  final TextEditingController _quickInputController = TextEditingController();
  List<EstimatedDietItem> _estimatedItems = [];
  bool _showManualSearch = true;
  bool _isAILoading = false;

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
    _quickInputController.dispose();
    _debounceTimer?.cancel();
    _weightController.dispose();
    _nameController.dispose();
    _calController.dispose();
    _proteinController.dispose();
    _carbController.dispose();
    _fatController.dispose();

    super.dispose();
  }

  void _onQuickInputChanged(String value) {
    // 不再根据输入清空结果，保留上一次识别的内容直到用户手动操作或下一次解析成功
  }

  Future<void> _runAIEstimate() async {
    final value = _quickInputController.text.trim();
    if (value.isEmpty || _isAILoading) return;

    setState(() => _isAILoading = true);

    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final items = await _estimationService.aiEstimate(
        input: value,
        profile: appProvider.userProfile,
      );

      if (mounted) {
        setState(() {
          // 只有当获取到有效结果时才更新
          if (items.isNotEmpty) {
            _estimatedItems = items;
          }
          _isAILoading = false;
        });
      }
    } catch (e) {
      Log.e('AI Estimate Error', e);
      if (mounted) {
        setState(() => _isAILoading = false);
        _showError('AI 解析失败，请检查网络或稍后重试');
      }
    }
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

  void _editEstimatedItemWeight(int index) {
    final item = _estimatedItems[index];
    final controller = TextEditingController(
      text: item.estimatedWeight.round().toString(),
    );

    showDialog(
      context: context,
      builder: (context) => HandDrawnDialog(
        title: '修改估算重量',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            HandDrawnTextField(
              controller: controller,
              keyboardType: TextInputType.number,
              labelText: '重量 (g)',
              autofocus: true,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('取消'),
                ),
                const SizedBox(width: 8),
                HandDrawnButton(
                  onPressed: () {
                    final weight =
                        double.tryParse(controller.text) ??
                        item.estimatedWeight;
                    setState(() {
                      _estimatedItems[index] = EstimatedDietItem(
                        food: item.food,
                        estimatedWeight: weight,
                        source: item.source,
                      );
                    });
                    context.pop();
                  },
                  label: '确定',
                  backgroundColor: AppColors.primary,
                  textColor: Colors.white,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _replaceEstimatedItem(int index) {
    final controller = TextEditingController();
    bool isSearching = false;
    List<FoodDatabaseItem> results = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return HandDrawnContainer(
            height: MediaQuery.of(context).size.height * 0.6,
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: const EdgeInsets.all(20),
            borderRadius: 20,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '替换食物',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(LucideIcons.x),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                HandDrawnTextField(
                  controller: controller,
                  hintText: '搜索要替换的食物...',
                  autofocus: true,
                  onChanged: (val) async {
                    if (val.length < 2) return;
                    setModalState(() => isSearching = true);
                    final foods = await _foodService.search(val, limit: 20);
                    setModalState(() {
                      results = foods;
                      isSearching = false;
                    });
                  },
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: isSearching
                      ? const Center(child: CircularProgressIndicator())
                      : results.isEmpty
                      ? Center(
                          child: Text(
                            '输入名称搜索',
                            style: TextStyle(
                              color: AppColors.getTextMutedColor(context),
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: results.length,
                          itemBuilder: (context, i) {
                            final f = results[i];
                            return ListTile(
                              leading: Text(
                                f.emoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                              title: Text(f.foodName),
                              subtitle: Text('${f.energyKCal} kcal/100g'),
                              onTap: () {
                                setState(() {
                                  _estimatedItems[index] = EstimatedDietItem(
                                    food: f,
                                    estimatedWeight:
                                        _estimatedItems[index].estimatedWeight,
                                    source: _estimatedItems[index].source,
                                  );
                                });
                                context.pop();
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _saveQuickEntries() {
    if (_estimatedItems.isEmpty) return;
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    for (final item in _estimatedItems) {
      final entry = DietEntry(
        id: DateTime.now()
            .add(Duration(milliseconds: _estimatedItems.indexOf(item)))
            .toString(),
        meal: widget.mealType ?? MealType.lunch,
        name: item.food.foodName,
        calories: item.calories.round(),
        protein: item.protein,
        carbs: item.carbs,
        fat: item.fat,
        time: TimeOfDay.now().format(context),
        date: DateTime.now().toString().split(' ')[0],
        foodId: item.food.foodCode,
        isCustom: item.food.remark == '自定义食物',
        emoji: item.food.emoji,
      );
      appProvider.addDietEntry(entry);
    }
    context.pop();
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
            Row(
              children: [
                if (!widget.onlyAddToList &&
                    !_isAddingCustom &&
                    _selectedDbFood == null)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _showManualSearch = !_showManualSearch;
                      });
                    },
                    icon: Icon(
                      _showManualSearch ? LucideIcons.zap : LucideIcons.search,
                      size: 16,
                    ),
                    label: Text(
                      _showManualSearch ? '智能模式' : '手动搜索',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(LucideIcons.x),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (!widget.onlyAddToList &&
            !_isAddingCustom &&
            _selectedDbFood == null &&
            !_showManualSearch)
          _buildQuickInputArea(),

        if (_isAddingCustom)
          _buildCustomForm()
        else if (_selectedDbFood != null)
          _buildWeightInput()
        else if (_showManualSearch)
          _buildFoodList(),

        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildQuickInputArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: HandDrawnTextField(
                controller: _quickInputController,
                hintText: '例：米饭2碗 + 青椒炒肉丝',
                prefixIcon: const Icon(
                  LucideIcons.sparkles,
                  size: 20,
                  color: AppColors.primary,
                ),
                onChanged: _onQuickInputChanged,
                style: TextStyle(color: AppColors.getTextMainColor(context)),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _runAIEstimate,
              child: HandDrawnContainer(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                color: AppColors.primary,
                borderRadius: 16,
                child: _isAILoading
                    ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            LucideIcons.sparkles,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      )
                    : const Row(
                        children: [
                          Icon(LucideIcons.zap, color: Colors.white, size: 18),
                          SizedBox(width: 4),
                          Text(
                            '智能识别',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
        if (_estimatedItems.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _estimatedItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return HandDrawnContainer(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: 20,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 替换图标 - 加大点击区域
                    GestureDetector(
                      onTap: () => _replaceEstimatedItem(index),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.food.emoji,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              item.food.foodName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              LucideIcons.refreshCcw,
                              size: 14,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 16,
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                    // 重量编辑 - 加大点击区域
                    GestureDetector(
                      onTap: () => _editEstimatedItemWeight(index),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${item.estimatedWeight.round()}g',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              LucideIcons.edit2,
                              size: 14,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 16,
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                    // 删除按钮 - 独立且足够大
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _estimatedItems.removeAt(index);
                        });
                      },
                      behavior: HitTestBehavior.opaque,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        child: Icon(
                          LucideIcons.trash2,
                          size: 16,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: HandDrawnButton(
              onPressed: _isAILoading ? () {} : _saveQuickEntries,
              label: '一键记录这 ${_estimatedItems.length} 项',
              backgroundColor: _isAILoading ? Colors.grey : AppColors.primary,
              textColor: Colors.white,
              height: 48,
            ),
          ),
        ] else if (_quickInputController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12, left: 4),
            child: Row(
              children: [
                Icon(
                  LucideIcons.helpCircle,
                  size: 14,
                  color: AppColors.getTextMutedColor(context),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '未能准确识别食材，请尝试简化描述或切换手动搜索',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.getTextMutedColor(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
          TextButton(onPressed: () => context.pop(), child: const Text('确定')),
        ],
      ),
    );
  }

  void _saveEntry() {
    if (_formKey.currentState!.validate()) {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final weight = double.tryParse(_weightController.text) ?? 100.0;
      final factor = weight / 100.0;

      final entry = DietEntry(
        id: DateTime.now().toString(),
        meal: widget.mealType ?? MealType.lunch,
        name: _selectedDbFood!.foodName,
        calories: (_selectedDbFood!.calories * factor).round(),
        protein: _selectedDbFood!.proteinValue * factor,
        fat: _selectedDbFood!.fatValue * factor,
        carbs: _selectedDbFood!.carbsValue * factor,
        time: TimeOfDay.now().format(context),
        date: DateTime.now().toString().split(' ')[0],
        foodId: _selectedDbFood!.foodCode,
        isCustom: _selectedDbFood!.remark == '自定义食物',
        emoji: _selectedDbFood!.emoji,
      );

      appProvider.addDietEntry(entry);
      context.pop();
    }
  }

  void _saveCustomFood() async {
    if (_formKey.currentState!.validate()) {
      final appProvider = Provider.of<AppProvider>(context, listen: false);

      final energyKCal = int.tryParse(_calController.text) ?? 0;
      final protein = double.tryParse(_proteinController.text) ?? 0.0;
      final fat = double.tryParse(_fatController.text) ?? 0.0;
      final cho = double.tryParse(_carbController.text) ?? 0.0;

      final entry = DietEntry(
        id: DateTime.now().toString(),
        meal: widget.mealType ?? MealType.lunch,
        name: _nameController.text,
        calories: energyKCal,
        protein: protein,
        fat: fat,
        carbs: cho,
        time: TimeOfDay.now().format(context),
        date: DateTime.now().toString().split(' ')[0],
        foodId: 'CUSTOM_${DateTime.now().millisecondsSinceEpoch}',
        isCustom: true,
        emoji: '🍱',
      );

      appProvider.addDietEntry(entry);

      if (mounted) {
        context.pop();
      }
    }
  }
}
