import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/exercise.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';

class ExerciseDetailPage extends StatefulWidget {
  final Exercise exercise;

  const ExerciseDetailPage({super.key, required this.exercise});

  @override
  State<ExerciseDetailPage> createState() => _ExerciseDetailPageState();
}

class _ExerciseDetailPageState extends State<ExerciseDetailPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.exercise.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Image Card
            Hero(
              tag: 'exercise_img_${widget.exercise.id}',
              child: HandDrawnCard(
                width: double.infinity,
                padding: EdgeInsets.zero,
                color: Color(0xFFF8F8F2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: widget.exercise.image != null
                      ? Image.asset(
                          widget.exercise.image!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildImagePlaceholder(),
                        )
                      : _buildImagePlaceholder(),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Category & Difficulty Tags
            Row(
              children: [
                _buildTag(
                  _getCategoryLabel(widget.exercise.category),
                  AppColors.accentMint,
                ),
                const SizedBox(width: 8),
                _buildTag(
                  _getDifficultyLabel(widget.exercise.difficulty),
                  AppColors.accentOrange,
                ),
                const Spacer(),
                Text(
                  '${widget.exercise.calories} kcal / 组',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Description
            const Text(
              '动作精讲',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              widget.exercise.description ?? '暂无详细讲解',
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textMain,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),

            // Steps
            if (widget.exercise.steps != null &&
                widget.exercise.steps!.isNotEmpty) ...[
              const Text(
                '训练步骤',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.exercise.steps!.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              offset: const Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.exercise.steps![index],
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textMain,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),
            ],

            // Tips
            if (widget.exercise.tips != null &&
                widget.exercise.tips!.isNotEmpty) ...[
              HandDrawnCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          LucideIcons.lightbulb,
                          size: 20,
                          color: AppColors.accentOrange,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '贴心贴士',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...widget.exercise.tips!.map(
                      (tip) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 6),
                              child: CircleAvatar(
                                radius: 3,
                                backgroundColor: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                tip,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textMuted,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 200,
      color: AppColors.primaryLight.withValues(alpha: 0.1),
      child: const Center(
        child: Icon(LucideIcons.image, size: 48, color: AppColors.primaryLight),
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
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
