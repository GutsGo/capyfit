import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import '../models/exercise.dart';

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  List<String> selectedCategories = [];
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppProvider>();

    // Dynamically get categories from existing exercises
    final dynamicCategories = appState.exercises
        .map((ex) => _getCategoryLabel(ex.category))
        .toSet()
        .toList();

    final exercises = appState.exercises.where((ex) {
      if (selectedCategories.isNotEmpty &&
          !selectedCategories.contains(_getCategoryLabel(ex.category))) {
        return false;
      }
      if (searchQuery.isNotEmpty &&
          !ex.name.toLowerCase().contains(searchQuery.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();

    // Split exercises into two columns for masonry-like adaptive height
    final leftColumnItems = <Exercise>[];
    final rightColumnItems = <Exercise>[];
    for (var i = 0; i < exercises.length; i++) {
      if (i % 2 == 0) {
        leftColumnItems.add(exercises[i]);
      } else {
        rightColumnItems.add(exercises[i]);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '动作库',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: TextField(
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: InputDecoration(
                hintText: '搜索动作...',
                prefixIcon: const Icon(LucideIcons.search, size: 20),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Exercise List with Adaptive Height
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column
                  Expanded(
                    child: Column(
                      children: leftColumnItems
                          .map(
                            (ex) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
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
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildExerciseCard(ex),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFilterSheet(dynamicCategories),
        shape: const CircleBorder(),
        backgroundColor: AppColors.primary,
        child: const Icon(LucideIcons.filter, color: Colors.white),
      ),
    );
  }

  void _showFilterSheet(List<String> categories) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '筛选分类',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
                          });
                          setModalState(() {});
                        },
                        selectedColor: AppColors.primary,
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textMain,
                        ),
                        backgroundColor: AppColors.background,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
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
                  Text(
                    '${ex.calories} kcal / 组',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontStyle: FontStyle.italic,
                    ),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
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
