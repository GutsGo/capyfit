import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:capyfit/providers/app_provider.dart';
import 'package:capyfit/data/models/food_database.dart';
import 'package:capyfit/data/services/food_db_service.dart';
import 'package:capyfit/ui/common/theme/app_colors.dart';
import 'package:capyfit/ui/common/widgets/common_widgets.dart';
import 'package:capyfit/ui/common/widgets/hand_drawn_widgets.dart';

class DietLibraryPage extends StatefulWidget {
  const DietLibraryPage({super.key});

  @override
  State<DietLibraryPage> createState() => _DietLibraryPageState();
}

class _DietLibraryPageState extends State<DietLibraryPage> {
  final FoodDbService _foodService = FoodDbService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<FoodDatabaseItem> _foods = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String _searchQuery = '';
  Timer? _debounceTimer;
  final int _pageSize = 50;

  @override
  void initState() {
    super.initState();
    _loadFoods();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMoreFoods();
    }
  }

  Future<void> _loadFoods() async {
    setState(() {
      _isLoading = true;
      _hasMore = true;
    });

    // 获取数据库食物
    final dbFoods = await _foodService.search(_searchQuery, limit: _pageSize);

    // 获取自定义食物并转换为 FoodDatabaseItem
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final customFoods = appProvider.foodPresets
        .where(
          (food) =>
              _searchQuery.isEmpty ||
              food.name.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .map(
          (food) => FoodDatabaseItem(
            foodCode: food.id,
            foodName: food.name,
            energyKCal: food.caloriesPer100g.toStringAsFixed(0),
            protein: food.proteinPer100g.toStringAsFixed(1),
            fat: food.fatPer100g.toStringAsFixed(1),
            cho: food.carbsPer100g.toStringAsFixed(1),
            remark: '自定义食物',
            emoji: food.emoji ?? '🍴',
          ),
        )
        .toList();

    if (mounted) {
      setState(() {
        // 自定义食物显示在前面
        _foods = [...customFoods, ...dbFoods];
        _isLoading = false;
        if (dbFoods.length < _pageSize) {
          _hasMore = false;
        }
      });
    }
  }

  Future<void> _loadMoreFoods() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);

    // 计算当前数据库食物的偏移量
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final customCount = appProvider.foodPresets
        .where(
          (food) =>
              _searchQuery.isEmpty ||
              food.name.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .length;

    final dbOffset = _foods.length - customCount;

    final moreFoods = await _foodService.search(
      _searchQuery,
      limit: _pageSize,
      offset: dbOffset,
    );

    if (mounted) {
      setState(() {
        if (moreFoods.isEmpty) {
          _hasMore = false;
        } else {
          _foods.addAll(moreFoods);
          if (moreFoods.length < _pageSize) {
            _hasMore = false;
          }
        }
        _isLoadingMore = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (_searchQuery != query) {
        _searchQuery = query;
        _loadFoods();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          '膳食库',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.getTextMainColor(context),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            LucideIcons.chevronLeft,
            color: AppColors.getTextMainColor(context),
            size: 28,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // 搜索栏
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: HandDrawnTextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              hintText: '搜索食物...',
              prefixIcon: Icon(
                LucideIcons.search,
                size: 20,
                color: AppColors.getBorderColor(context),
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        LucideIcons.x,
                        size: 18,
                        color: AppColors.getTextMutedColor(context),
                      ),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              style: TextStyle(color: AppColors.getTextMainColor(context)),
            ),
          ),

          // 食物列表
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _foods.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.searchX,
                          size: 48,
                          color: AppColors.getTextMutedColor(context),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '未找到相关食物',
                          style: TextStyle(
                            color: AppColors.getTextMutedColor(context),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _foods.length + (_hasMore ? 1 : 0),
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index == _foods.length) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: _isLoadingMore
                                ? const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  )
                                : Text(
                                    '滑动加载更多',
                                    style: TextStyle(
                                      color: AppColors.getTextMutedColor(
                                        context,
                                      ),
                                      fontSize: 12,
                                    ),
                                  ),
                          ),
                        );
                      }
                      final food = _foods[index];
                      return _buildFoodCard(food);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodCard(FoodDatabaseItem food) {
    return GestureDetector(
      onTap: () => context.push('/diet/food', extra: food),
      child: HandDrawnCard(
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.accentOrange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(food.emoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.foodName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.getTextMainColor(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '100g 约 ${food.energyKCal} kcal',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.getTextMutedColor(context),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildNutritionInfo('蛋白质', '${food.protein}g'),
                const SizedBox(height: 2),
                _buildNutritionInfo('碳水', '${food.cho}g'),
                const SizedBox(height: 2),
                _buildNutritionInfo('脂肪', '${food.fat}g'),
              ],
            ),
            const SizedBox(width: 8),
            Icon(
              LucideIcons.chevronRight,
              size: 20,
              color: AppColors.getTextMutedColor(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionInfo(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.getTextMutedColor(context),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextMainColor(context),
          ),
        ),
      ],
    );
  }
}
