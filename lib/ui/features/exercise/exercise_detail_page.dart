import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:capyfit/data/models/exercise.dart';
import 'package:capyfit/data/models/workout_plan.dart';
import 'package:capyfit/providers/app_provider.dart';
import 'package:capyfit/ui/common/theme/app_colors.dart';
import 'package:capyfit/ui/common/widgets/common_widgets.dart';
import 'package:capyfit/ui/common/widgets/hand_drawn_widgets.dart';

import 'package:capyfit/data/services/ai_coach_service.dart';
import 'package:flutter/services.dart';

class ExerciseDetailPage extends StatefulWidget {
  final Exercise exercise;
  final bool showCreatePlanButton;

  const ExerciseDetailPage({
    super.key,
    required this.exercise,
    this.showCreatePlanButton = true,
  });

  @override
  State<ExerciseDetailPage> createState() => _ExerciseDetailPageState();
}

class _ExerciseDetailPageState extends State<ExerciseDetailPage> {
  final AICoachService _aiCoachService = AICoachService();
  bool _isAiLoading = false;
  String? _cachedInterpretation;

  void _getAiInterpretation() async {
    if (_isAiLoading) return;

    // 如果已有缓存内容，直接返回，不触发 RateLimit 也不请求 API
    if (_cachedInterpretation != null) {
      _showAiInterpretationResult(_cachedInterpretation!);
      return;
    }

    if (!_aiCoachService.checkInterpretationRateLimit()) {
      showHandDrawnSnackBar(context, '卡皮巴拉还在思考中，请稍后再试');
      return;
    }

    setState(() {
      _isAiLoading = true;
    });

    // 震动反馈
    HapticFeedback.lightImpact();

    try {
      final interpretation = await _aiCoachService.getExerciseInterpretation(
        widget.exercise,
      );

      _cachedInterpretation = interpretation;

      if (mounted) {
        _showAiInterpretationResult(interpretation);
      }
    } catch (e) {
      if (mounted) {
        showHandDrawnSnackBar(context, 'AI 解读暂时不可用，请稍后再试');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAiLoading = false;
        });
      }
    }
  }

  void _showAiInterpretationResult(String content) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'AI Interpretation',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: ScaleTransition(
              scale: animation,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                padding: const EdgeInsets.all(4),
                child: HandDrawnCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            LucideIcons.sparkles,
                            color: AppColors.accentPurple,
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'AI 助教深度解读',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.getTextMainColor(context),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(LucideIcons.x, size: 20),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Flexible(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Text(
                            content,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.6,
                              color: AppColors.getTextMainColor(context),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '—— 你的卡皮巴拉教练',
                          style: TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: AppColors.getTextMutedColor(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text(widget.exercise.name)),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: 120,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero Image Card
                HandDrawnCard(
                  width: double.infinity,
                  padding: EdgeInsets.zero,
                  color: _getCategoryColor(
                    widget.exercise.category,
                  ).withValues(alpha: 0.1),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Hero(
                      tag: 'exercise_img_${widget.exercise.id}',
                      child: widget.exercise.image != null
                          ? Image.asset(
                              widget.exercise.image!,
                              width: double.infinity,
                              height: 150,
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
                    Builder(
                      builder: (context) {
                        final cals = context
                            .read<AppProvider>()
                            .calculateExerciseCalories(widget.exercise);
                        return Text(
                          '$cals kcal / 组',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.getTextMainColor(context),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Description
                Text(
                  '动作精讲',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextMainColor(context),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.exercise.description ?? '暂无详细讲解',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.getTextMainColor(context),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),

                // Steps
                if (widget.exercise.steps != null &&
                    widget.exercise.steps!.isNotEmpty) ...[
                  Text(
                    '训练步骤',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextMainColor(context),
                    ),
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
                                  color: AppColors.primary.withValues(
                                    alpha: 0.3,
                                  ),
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
                              style: TextStyle(
                                fontSize: 15,
                                color: AppColors.getTextMainColor(context),
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
                        Row(
                          children: [
                            const Icon(
                              LucideIcons.lightbulb,
                              size: 20,
                              color: AppColors.accentOrange,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '贴心贴士',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.getTextMainColor(context),
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
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: CircleAvatar(
                                    radius: 3,
                                    backgroundColor:
                                        AppColors.getTextMutedColor(context),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    tip,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.getTextMutedColor(
                                        context,
                                      ),
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
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),

          // AI Floating Button - Side Sticky
          Positioned(
            right: -10,
            top: MediaQuery.of(context).size.height * 0.4,
            child: GestureDetector(
              onTap: _getAiInterpretation,
              child: CustomPaint(
                painter: _OctagonSidePainter(
                  color: AppColors.accentPurple,
                  borderColor: AppColors.accentPurple.withValues(alpha: 0.5),
                  isDark: Theme.of(context).brightness == Brightness.dark,
                ),
                child: Container(
                  padding: const EdgeInsets.only(
                    left: 18,
                    right: 25,
                    top: 12,
                    bottom: 12,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isAiLoading)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      else
                        const Icon(
                          LucideIcons.sparkles,
                          color: Colors.white,
                          size: 18,
                        ),
                      const SizedBox(width: 8),
                      const Text(
                        'AI 解读',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          if (widget.showCreatePlanButton)
            Positioned(
              left: 0,
              right: 0,
              bottom: 30,
              child: Center(
                child: HandDrawnButton(
                  onPressed: _createOneClickPlan,
                  label: '一键创建训练计划',
                  icon: LucideIcons.zap,
                  backgroundColor: AppColors.primary,
                  textColor: Colors.white,
                  height: 56,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _createOneClickPlan() {
    final now = DateTime.now();
    final dateStr = now.toString().split(' ')[0];
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    // Map exercise category to workout type
    WorkoutType type;
    switch (widget.exercise.category) {
      case ExerciseCategory.cardio:
        type = WorkoutType.cardio;
        break;
      case ExerciseCategory.bodySculpting:
        type = WorkoutType.yoga;
        break;
      default:
        type = WorkoutType.strength;
    }

    final sets = widget.exercise.sets ?? 3;
    final calPerSet = context.read<AppProvider>().calculateExerciseCalories(
      widget.exercise,
    );
    final calories = calPerSet * sets;

    final plan = WorkoutPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: widget.exercise.name,
      date: dateStr,
      time: timeStr,
      duration: 30, // Default duration
      calories: calories,
      type: type,
      intensity: Intensity.medium,
      completed: false,
      exercises: [widget.exercise.name],
      mode: PlanMode.oneTime,
    );

    context.read<AppProvider>().addPlan(plan);

    showHandDrawnSnackBar(context, '已成功创建今天 ($dateStr) 的训练计划！');
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.25 : 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.4 : 0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getCategoryColor(ExerciseCategory cat) {
    switch (cat) {
      case ExerciseCategory.cardio:
        return AppColors.accentMint;
      case ExerciseCategory.bodySculpting:
        return AppColors.accentPurple;
      case ExerciseCategory.core:
      case ExerciseCategory.upperBody:
      case ExerciseCategory.lowerBody:
      case ExerciseCategory.fullBody:
        return AppColors.primary;
    }
  }

  String _getCategoryLabel(ExerciseCategory cat) {
    switch (cat) {
      case ExerciseCategory.core:
        return '核心';
      case ExerciseCategory.upperBody:
        return '上肢';
      case ExerciseCategory.lowerBody:
        return '下肢';
      case ExerciseCategory.fullBody:
        return '全身';
      case ExerciseCategory.cardio:
        return '有氧';
      case ExerciseCategory.bodySculpting:
        return '形体';
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

class _OctagonSidePainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  final bool isDark;

  _OctagonSidePainter({
    required this.color,
    required this.borderColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final random = Random(42); // 固定种子保证抖动感一致
    final path = Path();
    final double cut = 12.0;
    final double w = size.width;
    final double h = size.height;

    Offset wobble(double x, double y) {
      return Offset(
        x + (random.nextDouble() - 0.5) * 2.0,
        y + (random.nextDouble() - 0.5) * 2.0,
      );
    }

    // 构建左侧切角的八边形路径 (右侧平直贴边)
    path.moveTo(w, 0); // 右上
    path.lineTo(cut, 0); // 左上横边起点
    path.lineTo(0, cut); // 左侧斜切
    path.lineTo(0, h - cut); // 左侧竖边
    path.lineTo(cut, h); // 左下斜切
    path.lineTo(w, h); // 右下
    path.close();

    // 绘制阴影层 (手绘风格通常带点偏移阴影)
    canvas.drawPath(
      path.shift(const Offset(-2, 2)),
      Paint()..color = Colors.black.withValues(alpha: 0.1),
    );

    // 绘制填充
    canvas.drawPath(path, paint);

    // 绘制手绘质感的边框 (多画两次模拟笔触)
    void drawHandDrawnLine(Offset s, Offset e) {
      final linePath = Path();
      linePath.moveTo(s.dx, s.dy);
      final mid = Offset((s.dx + e.dx) / 2, (s.dy + e.dy) / 2);
      final wMid = wobble(mid.dx, mid.dy);
      linePath.quadraticBezierTo(wMid.dx, wMid.dy, e.dx, e.dy);
      canvas.drawPath(linePath, borderPaint);
    }

    final p1 = wobble(w, 0);
    final p2 = wobble(cut, 0);
    final p3 = wobble(0, cut);
    final p4 = wobble(0, h - cut);
    final p5 = wobble(cut, h);
    final p6 = wobble(w, h);

    drawHandDrawnLine(p1, p2);
    drawHandDrawnLine(p2, p3);
    drawHandDrawnLine(p3, p4);
    drawHandDrawnLine(p4, p5);
    drawHandDrawnLine(p5, p6);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
