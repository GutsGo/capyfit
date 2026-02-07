import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:capyfit/data/models/food_database.dart';
import 'package:capyfit/ui/common/theme/app_colors.dart';
import 'package:capyfit/ui/common/widgets/common_widgets.dart';

/// 食物详情页
class FoodDetailPage extends StatelessWidget {
  final FoodDatabaseItem food;

  const FoodDetailPage({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('食物详情')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头部信息卡片
            _buildHeaderCard(context),
            const SizedBox(height: 16),

            // 主要营养素
            _buildSectionTitle(context, '主要营养素'),
            const SizedBox(height: 8),
            _buildMacroNutrients(context),
            const SizedBox(height: 16),

            // 维生素
            _buildSectionTitle(context, '维生素'),
            const SizedBox(height: 8),
            _buildVitamins(context),
            const SizedBox(height: 16),

            // 矿物质
            _buildSectionTitle(context, '矿物质'),
            const SizedBox(height: 8),
            _buildMinerals(context),
            const SizedBox(height: 16),

            // 其他信息
            if (food.remark.isNotEmpty && food.remark != '—') ...[
              _buildSectionTitle(context, '备注'),
              const SizedBox(height: 8),
              _buildRemarkCard(context),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return HandDrawnCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.accentOrange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(food.emoji, style: const TextStyle(fontSize: 36)),
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
                        fontSize: 20,
                        color: AppColors.getTextMainColor(context),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildCategoryTag(context, food.category),
                    const SizedBox(height: 6),
                    Text(
                      '食物代码: ${food.foodCode}',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.getTextMutedColor(context),
                      ),
                    ),
                    if (food.edible != '—' && food.edible.isNotEmpty)
                      Text(
                        '可食部: ${food.edible}%',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.getTextMutedColor(context),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCalorieInfo(
                  '热量',
                  '${food.energyKCal} kcal',
                  AppColors.accentOrange,
                ),
                _buildCalorieInfo(
                  '能量',
                  '${food.energyKJ} kJ',
                  AppColors.accentBlue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieInfo(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.getTextMainColor(context),
      ),
    );
  }

  Widget _buildMacroNutrients(BuildContext context) {
    return HandDrawnCard(
      child: Column(
        children: [
          _buildNutrientRow(
            context,
            '蛋白质',
            food.protein,
            'g',
            AppColors.accentPink,
          ),
          _buildDivider(context),
          _buildNutrientRow(
            context,
            '脂肪',
            food.fat,
            'g',
            AppColors.accentYellow,
          ),
          _buildDivider(context),
          _buildNutrientRow(
            context,
            '碳水化合物',
            food.cho,
            'g',
            AppColors.accentBlue,
          ),
          _buildDivider(context),
          _buildNutrientRow(
            context,
            '膳食纤维',
            food.dietaryFiber,
            'g',
            AppColors.accentGreen,
          ),
          _buildDivider(context),
          _buildNutrientRow(
            context,
            '水分',
            food.water,
            'g',
            AppColors.accentBlue,
          ),
          _buildDivider(context),
          _buildNutrientRow(
            context,
            '胆固醇',
            food.cholesterol,
            'mg',
            AppColors.accentOrange,
          ),
          _buildDivider(context),
          _buildNutrientRow(context, '灰分', food.ash, 'g', Colors.grey),
        ],
      ),
    );
  }

  Widget _buildVitamins(BuildContext context) {
    return HandDrawnCard(
      child: Column(
        children: [
          _buildNutrientRow(
            context,
            '维生素A',
            food.vitaminA,
            'μgRE',
            AppColors.accentOrange,
          ),
          _buildDivider(context),
          _buildNutrientRow(
            context,
            '胡萝卜素',
            food.carotene,
            'μg',
            AppColors.accentOrange,
          ),
          _buildDivider(context),
          _buildNutrientRow(
            context,
            '视黄醇',
            food.retinol,
            'μg',
            AppColors.accentOrange,
          ),
          _buildDivider(context),
          _buildNutrientRow(
            context,
            '硫胺素(B1)',
            food.thiamin,
            'mg',
            AppColors.accentYellow,
          ),
          _buildDivider(context),
          _buildNutrientRow(
            context,
            '核黄素(B2)',
            food.riboflavin,
            'mg',
            AppColors.accentYellow,
          ),
          _buildDivider(context),
          _buildNutrientRow(
            context,
            '烟酸',
            food.niacin,
            'mg',
            AppColors.accentYellow,
          ),
          _buildDivider(context),
          _buildNutrientRow(
            context,
            '维生素C',
            food.vitaminC,
            'mg',
            AppColors.accentGreen,
          ),
          _buildDivider(context),
          _buildNutrientRow(
            context,
            '维生素E(总量)',
            food.vitaminETotal,
            'mg',
            AppColors.accentPink,
          ),
        ],
      ),
    );
  }

  Widget _buildMinerals(BuildContext context) {
    return HandDrawnCard(
      child: Column(
        children: [
          _buildNutrientRow(
            context,
            '钙(Ca)',
            food.ca,
            'mg',
            AppColors.accentBlue,
          ),
          _buildDivider(context),
          _buildNutrientRow(
            context,
            '磷(P)',
            food.p,
            'mg',
            AppColors.accentBlue,
          ),
          _buildDivider(context),
          _buildNutrientRow(
            context,
            '钾(K)',
            food.k,
            'mg',
            AppColors.accentGreen,
          ),
          _buildDivider(context),
          _buildNutrientRow(
            context,
            '钠(Na)',
            food.na,
            'mg',
            AppColors.accentYellow,
          ),
          _buildDivider(context),
          _buildNutrientRow(
            context,
            '镁(Mg)',
            food.mg,
            'mg',
            AppColors.accentPink,
          ),
          _buildDivider(context),
          _buildNutrientRow(
            context,
            '铁(Fe)',
            food.fe,
            'mg',
            AppColors.accentOrange,
          ),
          _buildDivider(context),
          _buildNutrientRow(context, '锌(Zn)', food.zn, 'mg', Colors.grey),
          _buildDivider(context),
          _buildNutrientRow(context, '硒(Se)', food.se, 'μg', Colors.grey),
          _buildDivider(context),
          _buildNutrientRow(
            context,
            '铜(Cu)',
            food.cu,
            'mg',
            AppColors.accentOrange,
          ),
          _buildDivider(context),
          _buildNutrientRow(context, '锰(Mn)', food.mn, 'mg', Colors.grey),
        ],
      ),
    );
  }

  Widget _buildNutrientRow(
    BuildContext context,
    String label,
    String value,
    String unit,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.getTextMainColor(context),
                ),
              ),
            ],
          ),
          Text(
            value == '—' || value == 'Tr' ? value : '$value $unit',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: value == '—' || value == 'Tr'
                  ? AppColors.getTextMutedColor(context)
                  : AppColors.getTextMainColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      color: AppColors.getBorderColor(context).withOpacity(0.3),
    );
  }

  Widget _buildRemarkCard(BuildContext context) {
    return HandDrawnCard(
      child: Row(
        children: [
          Icon(
            LucideIcons.info,
            size: 20,
            color: AppColors.getTextMutedColor(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              food.remark,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.getTextMutedColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTag(BuildContext context, String category) {
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.5), width: 0.5),
      ),
      child: Text(
        category,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
