import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:capyfit/providers/app_provider.dart';
import 'package:capyfit/ui/common/theme/app_colors.dart';
import 'package:capyfit/ui/common/widgets/common_widgets.dart';
import 'package:capyfit/ui/common/widgets/hand_drawn_widgets.dart';
import 'package:capyfit/data/models/workout_plan.dart';
import 'package:capyfit/data/utils/routes.dart';
import 'package:capyfit/data/services/exercise_db_service.dart';
import 'package:capyfit/data/models/exercise.dart';

class PlanDetailPage extends StatefulWidget {
  final WorkoutPlan plan;
  final String? date;

  const PlanDetailPage({super.key, required this.plan, this.date});

  @override
  State<PlanDetailPage> createState() => _PlanDetailPageState();
}

class _PlanDetailPageState extends State<PlanDetailPage> {
  // Cache for resolved exercises (name -> Exercise)
  Map<String, Exercise> _resolvedExercises = {};
  final Set<String> _checkedExercises = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _resolveExercises(widget.plan.exercises);
  }

  Future<void> _resolveExercises([List<String>? exercises]) async {
    final targetExercises = exercises ?? widget.plan.exercises ?? [];
    if (targetExercises.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    // Filter out already checked exercises to avoid redundant lookups
    final newNames = targetExercises
        .where((name) => !_checkedExercises.contains(name))
        .toList();

    if (newNames.isEmpty) {
      if (mounted && _isLoading) setState(() => _isLoading = false);
      return;
    }

    // Mark as checked immediately to prevent duplicate triggers
    _checkedExercises.addAll(newNames);

    // 2. Local lookup first (Custom exercises)
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final localExercises = appProvider.exercises;
    final Map<String, Exercise> newMap = {};

    for (final name in newNames) {
      try {
        final match = localExercises.firstWhere((e) => e.name == name);
        newMap[name] = match;
      } catch (_) {
        // Not found locally
      }
    }

    // 3. Database lookup for missing ones
    final missingNames = newNames
        .where((name) => !newMap.containsKey(name))
        .toList();

    if (missingNames.isNotEmpty) {
      final dbMatches = await ExerciseDbService().getExercisesByNames(
        missingNames,
      );
      newMap.addAll(dbMatches);
    }

    if (mounted) {
      setState(() {
        _resolvedExercises.addAll(newMap);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppProvider>();
    // Get the latest version of the plan from provider to show updates after editing
    final currentPlan = appState.plans.firstWhere(
      (p) => p.id == widget.plan.id,
      orElse: () => widget.plan,
    );

    final todayStr = DateTime.now().toString().split(' ')[0];
    final viewDateStr = widget.date ?? todayStr;
    final isToday = viewDateStr == todayStr;
    final isCompleted = currentPlan.isCompletedOn(viewDateStr);

    // Check for new exercises that need resolving
    final currentExercises = currentPlan.exercises ?? [];
    final hasUnchecked = currentExercises.any(
      (e) => !_checkedExercises.contains(e),
    );
    if (hasUnchecked) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _resolveExercises(currentExercises);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('计划详情'),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => context.pop(),
        ),
        actions: isToday
            ? [
                IconButton(
                  icon: const Icon(LucideIcons.edit3, size: 20),
                  onPressed: () =>
                      context.push(GlobalRoutes.planAdd, extra: currentPlan),
                ),
                IconButton(
                  icon: const Icon(
                    LucideIcons.trash2,
                    size: 20,
                    color: Colors.redAccent,
                  ),
                  onPressed: () =>
                      _confirmDelete(context, appState, currentPlan),
                ),
              ]
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24).copyWith(top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, currentPlan, isCompleted, appState),
                  const SizedBox(height: 24),
                  _buildStats(context, currentPlan),
                  const SizedBox(height: 32),
                  _buildExerciseList(context, appState, currentPlan),
                  const SizedBox(height: 100), // Space for bottom buttons
                ],
              ),
            ),
      bottomSheet: isToday
          ? _buildBottomActions(context, appState, isCompleted, currentPlan)
          : null,
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WorkoutPlan plan,
    bool isCompleted,
    AppProvider appState,
  ) {
    // Attempt to find completion time for the current date view

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                plan.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (isCompleted)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentMint.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.accentMint, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '已完成',
                      style: const TextStyle(
                        color: AppColors.accentMint,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildTag(
              plan.type == WorkoutType.strength ? '力量训练' : '有氧运动',
              plan.type == WorkoutType.strength
                  ? AppColors.accentOrange
                  : AppColors.accentMint,
            ),
            const SizedBox(width: 8),
            _buildTag(
              plan.mode == PlanMode.longTerm ? '长期计划' : '单次计划',
              AppColors.accentPurple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStats(BuildContext context, WorkoutPlan plan) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _buildStatItem(
            context,
            LucideIcons.clock,
            '${plan.duration}分钟',
            '预计时长',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatItem(
            context,
            LucideIcons.flame,
            '${plan.calories}kcal',
            '预计消耗',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatItem(
            context,
            LucideIcons.zap,
            _getIntensityLabel(plan.intensity),
            '训练强度',
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return HandDrawnCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: AppColors.getTextMutedColor(context),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseList(
    BuildContext context,
    AppProvider appState,
    WorkoutPlan plan,
  ) {
    final exercises = plan.exercises ?? [];
    if (exercises.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '训练项目',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...exercises.map((exerciseName) {
          // Look up in resolved map
          final libraryExercise = _resolvedExercises[exerciseName];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: HandDrawnCard(
              padding: EdgeInsets.zero,
              onTap: libraryExercise != null
                  ? () => context.push(
                      GlobalRoutes.exerciseDetail,
                      extra: {
                        'exercise': libraryExercise,
                        'showCreatePlanButton': false,
                      },
                    )
                  : null,
              child: Row(
                children: [
                  // Exercise Image Preview
                  if (libraryExercise != null)
                    Hero(
                      tag: 'exercise_img_${libraryExercise.id}',
                      child: Container(
                        width: 60,
                        height: 60,
                        margin: const EdgeInsets.only(
                          left: 12,
                          top: 12,
                          bottom: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: libraryExercise.image != null
                            ? Image.asset(
                                libraryExercise.image!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, _, __) => Container(
                                  color: AppColors.primary.withOpacity(0.05),
                                  child: const Icon(
                                    LucideIcons.image,
                                    size: 20,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : Container(
                                color: AppColors.primary.withOpacity(0.05),
                                child: const Icon(
                                  LucideIcons.image,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                    )
                  else
                    Container(
                      width: 60,
                      height: 60,
                      margin: const EdgeInsets.only(
                        left: 12,
                        top: 12,
                        bottom: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        LucideIcons.dumbbell,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),

                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            exerciseName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (libraryExercise != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              '${libraryExercise.targetMuscles.take(2).join(' · ')} · ${libraryExercise.met} MET',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.getTextMutedColor(context),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  if (libraryExercise != null)
                    const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(
                        LucideIcons.chevronRight,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBottomActions(
    BuildContext context,
    AppProvider appState,
    bool isCompleted,
    WorkoutPlan plan,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.getBackgroundColor(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: HandDrawnButton(
              onPressed: () {
                final targetDate =
                    widget.date ?? DateTime.now().toString().split(' ')[0];
                appState.togglePlanComplete(plan.id, forDate: targetDate);
                // Do not pop, just show snackbar. State updates automatically via Provider.
                showHandDrawnSnackBar(
                  context,
                  isCompleted ? '已取消完成' : '计划已完成！✨',
                );
              },
              label: isCompleted ? '标记未完成' : '立即完成',
              backgroundColor: isCompleted ? Colors.grey : AppColors.accentMint,
              textColor: Colors.white,
              height: 56,
            ),
          ),
          if (!isCompleted) ...[
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: HandDrawnButton(
                onPressed: () =>
                    context.push(GlobalRoutes.planTimer, extra: plan),
                label: '开启专注模式',
                backgroundColor: AppColors.primary,
                textColor: Colors.white,
                height: 56,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getIntensityLabel(Intensity intensity) {
    switch (intensity) {
      case Intensity.high:
        return '高强度';
      case Intensity.medium:
        return '中等强度';
      case Intensity.low:
        return '低强度';
    }
  }

  void _confirmDelete(
    BuildContext context,
    AppProvider appState,
    WorkoutPlan plan,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: HandDrawnContainer(
          color: AppColors.getBackgroundColor(context),
          borderRadius: 24,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '确认删除',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text('确定要删除 "${plan.name}" 吗？'),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      '取消',
                      style: TextStyle(
                        color: AppColors.getTextMutedColor(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  HandDrawnButton(
                    onPressed: () {
                      appState.deletePlan(plan.id);
                      Navigator.pop(context); // Close dialog
                      context.pop(); // Go back to list
                      showHandDrawnSnackBar(context, '计划已删除');
                    },
                    label: '删除',
                    backgroundColor: Colors.redAccent,
                    textColor: Colors.white,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    // Logic from ExerciseDetailPage
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
}
