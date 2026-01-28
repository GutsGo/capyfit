import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import '../models/diet_entry.dart';
import 'add_food_sheet.dart';

class DietPage extends StatelessWidget {
  const DietPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '饮食记录',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 24),

              // Nutrition Summary Card
              _buildNutritionSummaryCard(appState),
              const SizedBox(height: 24),

              // Meal Sections
              _buildMealSection(
                context,
                appState,
                MealType.breakfast,
                '早餐',
                LucideIcons.coffee,
                const Color(0xFFFFEFD5),
                const Color(0xFFD2691E),
              ),
              const SizedBox(height: 16),
              _buildMealSection(
                context,
                appState,
                MealType.lunch,
                '午餐',
                LucideIcons.sun,
                const Color(0xFFFFF0E0),
                const Color(0xFFE8A87C),
              ),
              const SizedBox(height: 16),
              _buildMealSection(
                context,
                appState,
                MealType.dinner,
                '晚餐',
                LucideIcons.moon,
                const Color(0xFFE0F2F1),
                const Color(0xFF7EB8A2),
              ),
              const SizedBox(height: 16),
              _buildMealSection(
                context,
                appState,
                MealType.snack,
                '加餐',
                Icons.cookie_outlined,
                const Color(0xFFF5F5DC),
                const Color(0xFFC4A989),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionSummaryCard(AppProvider state) {
    final calorieProgress = (state.todayCalories / state.calorieGoal).clamp(
      0.0,
      1.0,
    );

    // Hardcoded macro goals for demonstration, or could be in state
    const proteinGoal = 150.0;
    const carbGoal = 250.0;
    const fatGoal = 70.0;

    return HandDrawnCard(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        children: [
          // Circular Progress
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: calorieProgress,
                    strokeWidth: 10,
                    backgroundColor: AppColors.border.withValues(alpha: 0.5),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${state.todayCalories}',
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    Text(
                      '/ ${state.calorieGoal} kcal',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Macros
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildMacroProgress(
                  '碳水',
                  state.todayCarbs,
                  carbGoal,
                  AppColors.accentOrange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMacroProgress(
                  '蛋白质',
                  state.todayProtein,
                  proteinGoal,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMacroProgress(
                  '脂肪',
                  state.todayFat,
                  fatGoal,
                  AppColors.accentMint,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroProgress(
    String label,
    double current,
    double goal,
    Color color,
  ) {
    final progress = (current / goal).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '${current.round()}g',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.border.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(3),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildMealSection(
    BuildContext context,
    AppProvider state,
    MealType type,
    String title,
    IconData icon,
    Color bgColor,
    Color iconColor,
  ) {
    final meals = state.dietEntries.where((e) => e.meal == type).toList();
    final totalCals = meals.fold(0, (sum, e) => sum + e.calories);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$totalCals kcal',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
              ),
              const Spacer(),
              _AddButton(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => AddFoodSheet(mealType: type),
                  );
                },
              ),
            ],
          ),
          if (meals.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...meals.map((meal) => _buildMealItem(meal, state)),
          ] else ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                '还没有记录',
                style: TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMealItem(DietEntry entry, AppProvider state) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                Text(
                  entry.time,
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
              fontSize: 14,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => state.deleteDietEntry(entry.id),
            child: const Icon(
              LucideIcons.x,
              size: 16,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(LucideIcons.plus, size: 18, color: AppColors.primary),
      ),
    );
  }
}
