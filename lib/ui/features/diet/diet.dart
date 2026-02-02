import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:capyfit/providers/app_provider.dart';
import 'package:capyfit/ui/common/theme/app_colors.dart';
import 'package:capyfit/ui/common/widgets/common_widgets.dart';
import 'package:capyfit/ui/common/widgets/hand_drawn_widgets.dart';
import 'package:capyfit/ui/common/widgets/floating_calendar.dart';
import 'package:capyfit/data/models/diet_entry.dart';
import 'package:capyfit/ui/features/diet/add_food_sheet.dart';

class DietPage extends StatefulWidget {
  const DietPage({super.key});

  @override
  State<DietPage> createState() => _DietPageState();
}

class _DietPageState extends State<DietPage> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _jumpToToday() {
    setState(() {
      _selectedDate = DateTime.now();
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppProvider>();
    final selectedDateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final isToday = selectedDateStr == todayStr;
    final isFuture = selectedDateStr.compareTo(todayStr) > 0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('饮食记录'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!_isSameDay(_selectedDate, DateTime.now()))
            IconButton(
              icon: const Icon(
                LucideIcons.calendarDays,
                color: AppColors.primary,
              ),
              onPressed: _jumpToToday,
              tooltip: '回到今天',
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 65), // Space for collapsed calendar
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nutrition Summary Card
                      _buildNutritionSummaryCard(appState, selectedDateStr),
                      const SizedBox(height: 24),

                      // Meal Sections
                      _buildMealSection(
                        context,
                        appState,
                        MealType.breakfast,
                        '早餐',
                        LucideIcons.coffee,
                        const Color(0xFFFFEFD5),
                        AppColors.primary,
                        selectedDateStr,
                        isToday,
                        isFuture,
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
                        selectedDateStr,
                        isToday,
                        isFuture,
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
                        selectedDateStr,
                        isToday,
                        isFuture,
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
                        selectedDateStr,
                        isToday,
                        isFuture,
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: FloatingCalendar(
              selectedDate: _selectedDate,
              onDateSelected: (date) {
                setState(() => _selectedDate = date);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionSummaryCard(AppProvider state, String dateStr) {
    final calories = state.getTodayCalories(dateStr);
    final protein = state.getTodayProtein(dateStr);
    final carbs = state.getTodayCarbs(dateStr);
    final fat = state.getTodayFat(dateStr);

    final calorieProgress = (calories / state.calorieGoal).clamp(0.0, 1.0);

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
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: calorieProgress),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return CircularProgressIndicator(
                        value: value,
                        strokeWidth: 10,
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.3,
                        ),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                        strokeCap: StrokeCap.round,
                      );
                    },
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$calories',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: AppColors.getTextMainColor(context),
                      ),
                    ),
                    Text(
                      '/ ${state.calorieGoal} kcal',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.getTextMutedColor(context),
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
                  carbs,
                  state.carbGoal,
                  AppColors.accentOrange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMacroProgress(
                  '蛋白质',
                  protein,
                  state.proteinGoal,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMacroProgress(
                  '脂肪',
                  fat,
                  state.fatGoal,
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
          '${current.round()}/${goal.round()}g',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(3),
          ),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: AppColors.getTextMutedColor(context),
                fontSize: 12,
              ),
            ),
          ],
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
    String dateStr,
    bool isToday,
    bool isFuture,
  ) {
    // If future date, records are always empty as requested
    final meals = isFuture
        ? <DietEntry>[]
        : state.dietEntries
              .where((e) => e.meal == type && e.date == dateStr)
              .toList();

    final totalCals = meals.fold(0, (sum, e) => sum + e.calories);

    return HandDrawnCard(
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
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextMainColor(context),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$totalCals kcal',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.getTextMutedColor(context),
                ),
              ),
              const Spacer(),
              if (isToday)
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
            ...meals.map((meal) => _buildMealItem(meal, state, isToday)),
          ] else ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                '还没有记录',
                style: TextStyle(
                  color: AppColors.getTextMutedColor(context),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMealItem(DietEntry entry, AppProvider state, bool isToday) {
    return HandDrawnContainer(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 16,
      color: AppColors.getBackgroundColor(context),
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
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.getTextMutedColor(context),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${entry.calories} kcal',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Theme.of(context).primaryColor,
            ),
          ),
          if (isToday) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => state.deleteDietEntry(entry.id),
              child: Icon(
                LucideIcons.x,
                size: 16,
                color: AppColors.getTextMutedColor(context),
              ),
            ),
          ],
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
      child: HandDrawnContainer(
        padding: const EdgeInsets.all(4),
        borderRadius: 8,
        color: AppColors.getBackgroundColor(context),
        child: Icon(
          LucideIcons.plus,
          size: 18,
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.primaryLight
              : Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
