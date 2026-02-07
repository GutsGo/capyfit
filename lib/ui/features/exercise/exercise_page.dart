import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:capyfit/providers/app_provider.dart';
import 'package:capyfit/ui/common/theme/app_colors.dart';
import 'package:capyfit/ui/common/widgets/common_widgets.dart';
import 'package:capyfit/ui/common/widgets/hand_drawn_widgets.dart';
import 'package:capyfit/data/models/exercise.dart';
import 'package:capyfit/data/services/exercise_db_service.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  final ExerciseDbService _exerciseService = ExerciseDbService();
  final ScrollController _scrollController = ScrollController();

  List<Exercise> _exercises = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _showBackToTop = false;
  List<String> selectedCategories = [];
  String searchQuery = '';
  Timer? _debounceTimer;
  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadExercises();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (searchQuery != query) {
        searchQuery = query;
        _loadExercises();
      }
    });
  }

  Future<void> _loadExercises() async {
    setState(() {
      _isLoading = true;
      _hasMore = true;
    });

    final results = await _exerciseService.search(
      searchQuery,
      categories: selectedCategories,
      limit: _pageSize,
      offset: 0,
    );

    if (mounted) {
      setState(() {
        _exercises = results;
        _isLoading = false;
        if (results.length < _pageSize) {
          _hasMore = false;
        }
      });
    }
  }

  Future<void> _loadMoreExercises() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);

    final results = await _exerciseService.search(
      searchQuery,
      categories: selectedCategories,
      limit: _pageSize,
      offset: _exercises.length,
    );

    if (mounted) {
      setState(() {
        if (results.isEmpty) {
          _hasMore = false;
        } else {
          _exercises.addAll(results);
          if (results.length < _pageSize) {
            _hasMore = false;
          }
        }
        _isLoadingMore = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMoreExercises();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('动作库')),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: HandDrawnTextField(
                    onChanged: _onSearchChanged,
                    hintText: '搜索动作...',
                    prefixIcon: Icon(
                      LucideIcons.search,
                      size: 20,
                      color: AppColors.getBorderColor(context),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    style: TextStyle(
                      color: AppColors.getTextMainColor(context),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () =>
                      _showFilterSheet(['核心', '上肢', '下肢', '全身', '有氧', '形体']),
                  child: HandDrawnContainer(
                    padding: const EdgeInsets.all(12),
                    color: AppColors.getCardColor(context),
                    borderRadius: 12,
                    child: Icon(
                      LucideIcons.filter,
                      size: 20,
                      color: AppColors.getTextMainColor(context),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Exercise List with Virtualization (MasonryGridView)
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : MasonryGridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                        ),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    itemCount: _exercises.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= _exercises.length) {
                        return _buildLoadMoreIndicator();
                      }
                      return _ExerciseCard(ex: _exercises[index]);
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
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

  void _showFilterSheet(List<String> categories) {
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
                      '筛选分类',
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
                          _loadExercises();
                        });
                        setModalState(() {});
                      },
                      selectedColor: AppColors.primary,
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppColors.getTextMainColor(context),
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
              ],
            );
          },
        );
      },
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final Exercise ex;

  const _ExerciseCard({required this.ex});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
          context.push('/exercise/detail', extra: ex);
        },
        child: HandDrawnCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              SizedBox(
                height: 120,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Hero(
                    tag: 'exercise_img_${ex.id}',
                    child: ex.image != null
                        ? Image.asset(
                            ex.image!,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppColors.primaryLight.withValues(
                                  alpha: 0.1,
                                ),
                                child: const Center(
                                  child: Icon(
                                    LucideIcons.imageOff,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: AppColors.primaryLight.withValues(
                              alpha: 0.1,
                            ),
                            child: const Center(
                              child: Icon(
                                LucideIcons.image,
                                color: AppColors.primaryLight,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ex.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.getTextMainColor(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _ExerciseTag(
                          label: _getCategoryLabel(ex.category),
                          color: AppColors.accentMint,
                        ),
                        const SizedBox(width: 4),
                        _ExerciseTag(
                          label: _getDifficultyLabel(ex.difficulty),
                          color: AppColors.accentOrange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Builder(
                      builder: (context) {
                        final cals = context
                            .read<AppProvider>()
                            .calculateExerciseCalories(ex);
                        return Text(
                          '$cals kcal / 组',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.getTextMutedColor(context),
                            fontStyle: FontStyle.italic,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryLabel(ExerciseCategory cat) {
    switch (cat) {
      case ExerciseCategory.core:
        return '核心';
      case ExerciseCategory.upperBody:
        return '上肢';
      case ExerciseCategory.lowerBody:
        return '下肢';
      case ExerciseCategory.fullBody:
        return '全身';
      case ExerciseCategory.cardio:
        return '有氧';
      case ExerciseCategory.bodySculpting:
        return '形体';
    }
  }

  String _getDifficultyLabel(Difficulty diff) {
    switch (diff) {
      case Difficulty.beginner:
        return '入门';
      case Difficulty.intermediate:
        return '进阶';
      case Difficulty.advanced:
        return '挑战';
    }
  }
}

class _ExerciseTag extends StatelessWidget {
  final String label;
  final Color color;

  const _ExerciseTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hsl = HSLColor.fromColor(color);

    final textColor = isDark
        ? hsl
              .withLightness((hsl.lightness + 0.2).clamp(0.0, 1.0))
              .withSaturation((hsl.saturation + 0.1).clamp(0.0, 1.0))
              .toColor()
        : hsl
              .withLightness((hsl.lightness - 0.45).clamp(0.0, 1.0))
              .withSaturation((hsl.saturation + 0.1).clamp(0.0, 1.0))
              .toColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.25 : 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
