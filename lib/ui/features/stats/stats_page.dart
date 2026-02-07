import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:capyfit/ui/common/theme/app_colors.dart';
import 'package:capyfit/ui/common/widgets/hand_drawn_widgets.dart';
import 'package:capyfit/ui/common/widgets/hand_drawn_charts.dart';
import 'package:capyfit/ui/features/stats/stats_vm.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatsViewModel>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('数据洞察')),
      body: Consumer<StatsViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 时间范围选择
                _buildTimeSelector(vm),
                const SizedBox(height: 24),

                // 核心指标卡片
                _buildOverviewCards(vm),
                const SizedBox(height: 24),

                // 运动时长趋势
                _buildSectionTitle('运动时间 (分钟)', LucideIcons.clock),
                const SizedBox(height: 12),
                HandDrawnContainer(
                  padding: const EdgeInsets.all(16),
                  child: _buildDurationChart(vm),
                ),
                const SizedBox(height: 24),

                // 热量消耗趋势
                _buildSectionTitle('热量消耗 (kcal)', LucideIcons.flame),
                const SizedBox(height: 12),
                HandDrawnContainer(
                  padding: const EdgeInsets.all(16),
                  child: _buildCaloriesChart(vm),
                ),
                const SizedBox(height: 24),

                // 饮食成分分析
                _buildSectionTitle('饮食成分', LucideIcons.apple),
                const SizedBox(height: 12),
                HandDrawnContainer(
                  padding: const EdgeInsets.all(24),
                  child: _buildDietPieChart(vm),
                ),
                const SizedBox(height: 20),

                // 步数趋势
                _buildSectionTitle('步数统计', LucideIcons.footprints),
                const SizedBox(height: 12),
                HandDrawnContainer(
                  padding: const EdgeInsets.all(16),
                  child: _buildStepsChart(vm),
                ),
                const SizedBox(height: 48),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeSelector(StatsViewModel vm) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTimeChip('最近 7 天', 7, vm),
        const SizedBox(width: 12),
        _buildTimeChip('最近 30 天', 30, vm),
      ],
    );
  }

  Widget _buildTimeChip(String label, int days, StatsViewModel vm) {
    final isSelected = vm.selectedDays == days;
    return GestureDetector(
      onTap: () => vm.setSelectedDays(days),
      child: HandDrawnContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: isSelected ? AppColors.primary : AppColors.getCardColor(context),
        borderColor: isSelected
            ? AppColors.primary
            : AppColors.getBorderColor(context),
        borderRadius: 20,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : AppColors.getTextMainColor(context),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCards(StatsViewModel vm) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            '累计时长',
            '${(vm.totalDurationInSelectedPeriod / 60).toStringAsFixed(1)} h',
            LucideIcons.timer,
            const Color(0xFFFDF0E8),
            const Color(0xFFE8A87C),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatItem(
            '消耗热量',
            '${vm.totalCaloriesBurnInSelectedPeriod.toInt()} kcal',
            LucideIcons.flame,
            const Color(0xFFFDE8E8),
            const Color(0xFFE87C7C),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color bgColor,
    Color iconColor,
  ) {
    return HandDrawnContainer(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextMainColor(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.getTextMutedColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.getTextMainColor(context)),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextMainColor(context),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationChart(StatsViewModel vm) {
    final trend = vm.getDurationTrend();
    if (trend.isEmpty) {
      return const SizedBox(height: 150, child: Center(child: Text('暂无数据')));
    }

    final data = trend.values.toList();
    final labels = trend.keys.toList();
    final maxVal = data.fold(0.0, (m, v) => v > m ? v : m);

    return HandDrawnBarChart(
      data: data,
      labels: labels,
      maxValue: maxVal > 60 ? maxVal : 60,
      barColor: const Color(0xFF8B6F5C),
    );
  }

  Widget _buildCaloriesChart(StatsViewModel vm) {
    final trend = vm.getCaloriesBurnTrend();
    if (trend.isEmpty) {
      return const SizedBox(height: 150, child: Center(child: Text('暂无数据')));
    }

    final data = trend.values.toList();
    final labels = trend.keys.toList();
    final maxVal = data.fold(0.0, (m, v) => v > m ? v : m);

    return HandDrawnLineChart(
      data: data,
      labels: labels,
      maxValue: maxVal > 500 ? maxVal : 500,
      lineColor: const Color(0xFFE87C7C),
    );
  }

  Widget _buildDietPieChart(StatsViewModel vm) {
    final macros = vm.getMacroNutrientStats();

    return Row(
      children: [
        Expanded(
          child: HandDrawnPieChart(
            data: macros,
            colors: const [
              Color(0xFF7EB8A2), // 蛋白
              Color(0xFFE8A87C), // 碳水
              Color(0xFFE87C7C), // 脂肪
            ],
            size: 130,
          ),
        ),
        const SizedBox(width: 20),
        _buildDietLegend(macros),
      ],
    );
  }

  Widget _buildDietLegend(List<double> values) {
    final labels = ['蛋白质', '碳水', '脂肪'];
    final colors = [
      const Color(0xFF7EB8A2),
      const Color(0xFFE8A87C),
      const Color(0xFFE87C7C),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(labels.length, (i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildLegendItem(labels[i], colors[i], values[i]),
        );
      }),
    );
  }

  Widget _buildLegendItem(String label, Color color, double value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.getTextMainColor(context),
              ),
            ),
            Text(
              '${value.toInt()}g',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.getTextMutedColor(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepsChart(StatsViewModel vm) {
    final trend = vm.getStepsTrend();
    if (trend.isEmpty) {
      return const SizedBox(height: 150, child: Center(child: Text('暂无数据')));
    }

    final data = trend.values.toList();
    final labels = trend.keys.toList();
    final maxVal = data.fold(0.0, (m, v) => v > m ? v : m);

    return HandDrawnBarChart(
      data: data,
      labels: labels,
      maxValue: maxVal > 10000 ? maxVal : 10000,
      barColor: AppColors.primary,
    );
  }
}
