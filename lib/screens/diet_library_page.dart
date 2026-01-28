import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import '../widgets/hand_drawn_widgets.dart';
import '../models/food_item.dart';
import 'add_food_sheet.dart';

class DietLibraryPage extends StatefulWidget {
  const DietLibraryPage({super.key});

  @override
  State<DietLibraryPage> createState() => _DietLibraryPageState();
}

class _DietLibraryPageState extends State<DietLibraryPage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppProvider>();
    final allFoods = appState.foodPresets;

    final filteredFoods = allFoods.where((food) {
      if (searchQuery.isNotEmpty &&
          !food.name.toLowerCase().contains(searchQuery.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          '膳食库',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.textMain,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            LucideIcons.chevronLeft,
            color: AppColors.textMain,
            size: 28,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: HandDrawnContainer(
              color: Colors.white,
              borderRadius: 16,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: TextField(
                onChanged: (val) => setState(() => searchQuery = val),
                decoration: const InputDecoration(
                  hintText: '搜索食物...',
                  prefixIcon: Icon(LucideIcons.search, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // Food List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filteredFoods.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final food = filteredFoods[index];
                return _buildFoodCard(food);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: HandDrawnFAB(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddFoodSheet(onlyAddToList: true),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
    );
  }

  Widget _buildFoodCard(FoodItem food) {
    return HandDrawnCard(
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
              child: food.emoji != null
                  ? Text(food.emoji!, style: const TextStyle(fontSize: 28))
                  : const Icon(
                      LucideIcons.utensils,
                      color: AppColors.accentOrange,
                      size: 24,
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textMain,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '100g 约 ${food.caloriesPer100g} kcal',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildNutritionInfo('蛋白质', '${food.proteinPer100g}g'),
              const SizedBox(height: 2),
              _buildNutritionInfo('碳水', '${food.carbsPer100g}g'),
              const SizedBox(height: 2),
              _buildNutritionInfo('脂肪', '${food.fatPer100g}g'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionInfo(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
        ),
      ],
    );
  }
}
