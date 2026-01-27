import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import '../models/diet_entry.dart';

class DietPage extends StatelessWidget {
  const DietPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppProvider>();
    final entries = appState.dietEntries;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '饮食记录',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nutrition Summary
            _buildNutritionSummary(appState),
            const SizedBox(height: 24),

            // Diet List Section
            const Text(
              '今日餐食',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...entries.map((entry) => _buildDietItem(entry, appState)),

            if (entries.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text(
                    '今天还没有饮食记录哦~',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              ),

            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, // Add logic
        backgroundColor: AppColors.primary,
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
    );
  }

  Widget _buildNutritionSummary(AppProvider state) {
    final progress = (state.todayCalories / state.calorieGoal).clamp(0.0, 1.0);

    return HandDrawnCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '今日摄入',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  ),
                  Text(
                    '${state.todayCalories} / ${state.calorieGoal} kcal',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              CircularProgressIndicator(
                value: progress,
                backgroundColor: AppColors.border,
                color: AppColors.primary,
                strokeWidth: 8,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMacroItem(
                '蛋白质',
                '${state.todayProtein.round()}g',
                AppColors.accentOrange,
              ),
              _buildMacroItem(
                '碳水',
                '${state.todayCarbs.round()}g',
                AppColors.accentMint,
              ),
              _buildMacroItem(
                '脂肪',
                '${state.todayFat.round()}g',
                AppColors.primaryLight,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroItem(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildDietItem(DietEntry entry, AppProvider state) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: HandDrawnCard(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('🍱', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${_getMealLabel(entry.meal)} · ${entry.time}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${entry.calories} kcal',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(
                LucideIcons.trash2,
                size: 18,
                color: Colors.redAccent,
              ),
              onPressed: () => state.deleteDietEntry(entry.id),
            ),
          ],
        ),
      ),
    );
  }

  String _getMealLabel(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return '早餐';
      case MealType.lunch:
        return '午餐';
      case MealType.dinner:
        return '晚餐';
      case MealType.snack:
        return '加餐';
    }
  }
}
