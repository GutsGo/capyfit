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
  }

  @override
  Widget build(BuildContext context) {
    // Dynamically get categories from all exercises (for filter sheet)
    // In a real DB we'd have a separate method, here we can use a fixed list or get once
    final dynamicCategories = [
      '胸部',
      '背部',
      '腿部',
      '肩部',
      '手臂',
      '核心',
      '有氧',
      '瑜伽',
      '其他',
    ];

    // Split exercises into two columns for masonry-like adaptive height
    final leftColumnItems = <Exercise>[];
    final rightColumnItems = <Exercise>[];
    for (var i = 0; i < _exercises.length; i++) {
      if (i % 2 == 0) {
        leftColumnItems.add(_exercises[i]);
      } else {
        rightColumnItems.add(_exercises[i]);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '动作库',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.getTextMainColor(context),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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
                  onTap: () => _showFilterSheet(dynamicCategories),
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

          // Exercise List with Adaptive Height
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Column
                            Expanded(
                              child: Column(
                                children: leftColumnItems
                                    .map(
                                      (ex) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: _buildExerciseCard(ex),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Right Column
                            Expanded(
                              child: Column(
                                children: rightColumnItems
                                    .map(
                                      (ex) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: _buildExerciseCard(ex),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                        if (_hasMore)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
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
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(List<String> categories) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return HandDrawnContainer(
              color: AppColors.getBackgroundColor(context),
              borderRadius: 32,
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.getBorderColor(context),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
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
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildExerciseCard(Exercise ex) {
    return GestureDetector(
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
                          fit: BoxFit.cover,
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
                          color: AppColors.primaryLight.withValues(alpha: 0.1),
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
                      _buildTag(
                        _getCategoryLabel(ex.category),
                        AppColors.accentMint,
                      ),
                      const SizedBox(width: 4),
                      _buildTag(
                        _getDifficultyLabel(ex.difficulty),
                        AppColors.accentOrange,
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
    );
  }

  Widget _buildTag(String label, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hsl = HSLColor.fromColor(color);

    // Get a color that is readable on the background
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

  String _getCategoryLabel(ExerciseCategory cat) {
    switch (cat) {
      case ExerciseCategory.chest:
        return '胸部';
      case ExerciseCategory.back:
        return '背部';
      case ExerciseCategory.legs:
        return '腿部';
      case ExerciseCategory.shoulders:
        return '肩部';
      case ExerciseCategory.arms:
        return '手臂';
      case ExerciseCategory.core:
        return '核心';
      case ExerciseCategory.cardio:
        return '有氧';
      case ExerciseCategory.yoga:
        return '瑜伽';
      case ExerciseCategory.other:
        return '其他';
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
