import 'dart:async';
import 'package:capyfit/data/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
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
  bool _showBackToTop = false;
  List<String> selectedCategories = [];
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

    // 显示/隐藏回到顶部按钮
    final showBtn =
        _scrollController.offset > MediaQuery.of(context).size.height;
    if (showBtn != _showBackToTop) {
      setState(() {
        _showBackToTop = showBtn;
      });
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _loadFoods() async {
    setState(() {
      _isLoading = true;
      _hasMore = true;
    });

    // 获取数据库食物
    final dbFoods = await _foodService.search(
      _searchQuery,
      categories: selectedCategories,
      limit: _pageSize,
    );

    if (mounted) {
      setState(() {
        _foods = dbFoods;
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
    final dbOffset = _foods.length;

    final moreFoods = await _foodService.search(
      _searchQuery,
      categories: selectedCategories,
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
      appBar: AppBar(title: Text(GlobalConstants.homeDietLibrary)),
      body: Column(
        children: [
          // 搜索栏
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
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
                    style: TextStyle(
                      color: AppColors.getTextMainColor(context),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _showFilterSheet(),
                  child: HandDrawnContainer(
                    padding: const EdgeInsets.all(12),
                    color: AppColors.getCardColor(context),
                    borderRadius: 12,
                    child: Icon(
                      LucideIcons.filter,
                      size: 20,
                      color: selectedCategories.isNotEmpty
                          ? AppColors.primary
                          : AppColors.getTextMainColor(context),
                    ),
                  ),
                ),
              ],
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
                        return _buildLoadMoreIndicator();
                      }
                      return _FoodCard(food: _foods[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: _showBackToTop
          ? HandDrawnFAB(
              onPressed: _scrollToTop,
              backgroundColor: AppColors.primary,
              size: 44,
              child: const Icon(
                LucideIcons.chevronUp,
                color: Colors.white,
                size: 18,
              ),
            )
          : null,
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: _isLoadingMore
            ? const CircularProgressIndicator(strokeWidth: 2)
            : Text(
                '滑动加载更多',
                style: TextStyle(
                  color: AppColors.getTextMutedColor(context),
                  fontSize: 12,
                ),
              ),
      ),
    );
  }

  void _showFilterSheet() {
    final categories = ['谷薯类', '蔬菜类', '水果类', '蛋奶豆类', '肉禽水产类', '油脂类', '调味品类'];

    HandDrawnBottomSheet.show(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '食物分类',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.getTextMainColor(context),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories.map((cat) {
                    final isSelected = selectedCategories.contains(cat);
                    return FilterChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (val) {
                        setState(() {
                          if (val) {
                            selectedCategories.add(cat);
                          } else {
                            selectedCategories.remove(cat);
                          }
                          _loadFoods();
                        });
                        setModalState(() {});
                      },
                      selectedColor: AppColors.primary,
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppColors.getTextMainColor(context),
                        fontSize: 13,
                      ),
                      backgroundColor: AppColors.getCardColor(context),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.getBorderColor(context),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32), // 底部留白
              ],
            );
          },
        );
      },
    );
  }
}

class _FoodCard extends StatelessWidget {
  final FoodDatabaseItem food;

  const _FoodCard({required this.food});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: () => context.push('/diet/food', extra: food),
        child: HandDrawnCard(
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.accentOrange.withValues(alpha: 0.15),
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
                      '${food.energyKCal} kcal / 100g',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.getTextMutedColor(context),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _CategoryTag(category: food.category),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _NutritionInfo(label: '蛋白质', value: '${food.protein}g'),
                  const SizedBox(height: 2),
                  _NutritionInfo(label: '碳水', value: '${food.cho}g'),
                  const SizedBox(height: 2),
                  _NutritionInfo(label: '脂肪', value: '${food.fat}g'),
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
      ),
    );
  }
}

class _NutritionInfo extends StatelessWidget {
  final String label;
  final String value;

  const _NutritionInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
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

class _CategoryTag extends StatelessWidget {
  final String category;

  const _CategoryTag({required this.category});

  @override
  Widget build(BuildContext context) {
    Color color = AppColors.primary;
    switch (category) {
      case '谷薯类':
        color = Colors.orange;
        break;
      case '蔬菜类':
        color = Colors.green;
        break;
      case '水果类':
        color = Colors.redAccent;
        break;
      case '蛋奶豆类':
        color = Colors.blue;
        break;
      case '肉禽水产类':
        color = Colors.brown;
        break;
      case '油脂类':
        color = Colors.amber;
        break;
      case '调味品类':
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Text(
        category,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
