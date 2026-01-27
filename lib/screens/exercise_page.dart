import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  String selectedCategory = '全部';
  String searchQuery = '';

  final List<String> categories = [
    '全部',
    '胸部',
    '背部',
    '腿部',
    '肩部',
    '手臂',
    '核心',
    '有氧',
  ];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppProvider>();
    final exercises = appState.exercises.where((ex) {
      if (selectedCategory != '全部' &&
          _getCategoryLabel(ex.category) != selectedCategory) {
        return false;
      }
      if (searchQuery.isNotEmpty &&
          !ex.name.toLowerCase().contains(searchQuery.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('动作库', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

          // Category Filter
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (val) => setState(() => selectedCategory = cat),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textMain,
                      fontSize: 13,
                    ),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              },
            ),
          ),

          // Exercise List
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final ex = exercises[index];
                return _buildExerciseCard(ex);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(Exercise ex) {
    return HandDrawnCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Placeholder for image
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: const Center(
              child: Icon(LucideIcons.image, color: AppColors.primaryLight),
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
              ],
            ),
          ),
        ],
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
