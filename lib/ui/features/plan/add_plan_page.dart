import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:capyfit/providers/app_provider.dart';
import 'package:capyfit/ui/common/theme/app_colors.dart';
import 'package:capyfit/data/models/workout_plan.dart';
import 'package:capyfit/data/models/exercise.dart';
import 'package:capyfit/data/utils/validators.dart';
import 'package:capyfit/ui/common/widgets/hand_drawn_widgets.dart';
import 'package:capyfit/ui/common/widgets/common_widgets.dart';
import 'package:capyfit/ui/features/plan/widgets/exercise_selection_sheet.dart';
import 'package:capyfit/data/services/exercise_db_service.dart';

class AddPlanPage extends StatefulWidget {
  final WorkoutPlan? initialPlan;
  final String? date;
  const AddPlanPage({super.key, this.initialPlan, this.date});

  @override
  State<AddPlanPage> createState() => _AddPlanPageState();
}

class _AddPlanPageState extends State<AddPlanPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _durationController = TextEditingController(text: '30');
  final _caloriesController = TextEditingController(text: '0');

  WorkoutType _type = WorkoutType.strength;
  PlanMode _mode = PlanMode.longTerm;
  Intensity _intensity = Intensity.medium;
  final List<String> _selectedExercises = [];
  final Map<String, ExerciseCategory?> _exerciseCategoryMap = {};
  final _exerciseService = ExerciseDbService();
  int _totalCalories = 0;

  // New recurrence fields
  Set<int> _selectedWeekdays = {};
  bool _isChinaWorkday = false;
  bool _isChinaHoliday = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialPlan != null) {
      final plan = widget.initialPlan!;
      _nameController.text = plan.name;
      _durationController.text = plan.duration.toString();
      _caloriesController.text = plan.calories.toString();
      _type = plan.type;
      _mode = plan.mode;
      _intensity = plan.intensity;
      _selectedExercises.addAll(plan.exercises ?? []);
      _totalCalories = plan.calories;

      // Load recurrence
      if (plan.repeatDays != null) {
        _selectedWeekdays = plan.repeatDays!.toSet();
      }
      _isChinaWorkday = plan.isChinaWorkdayPlan;
      _isChinaHoliday = plan.isChinaHolidayPlan;

      _initializeExerciseCategories();
    } else if (widget.date != null) {
      // If we are adding for a specific date (e.g. from future date in calendar)
      final todayStr = DateTime.now().toString().split(' ')[0];
      if (widget.date!.compareTo(todayStr) > 0) {
        _mode = PlanMode.oneTime; // Force oneTime for future
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  Future<void> _initializeExerciseCategories() async {
    if (_selectedExercises.isEmpty) return;
    final results = await _exerciseService.getExercisesByNames(
      _selectedExercises,
    );
    if (!mounted) return;
    setState(() {
      for (final name in _selectedExercises) {
        _exerciseCategoryMap[name] = results[name]?.category;
      }
      _updateWorkoutType();
    });
  }

  void _updateWorkoutType() {
    if (_selectedExercises.isEmpty) {
      setState(() => _type = WorkoutType.strength);
      return;
    }

    final categories = _selectedExercises
        .map((name) => _exerciseCategoryMap[name])
        .toList();

    // 如果包含自定义动作（null），则判定为综合
    if (categories.contains(null)) {
      setState(() => _type = WorkoutType.other);
      return;
    }

    final distinctCategories = categories.whereType<ExerciseCategory>().toSet();

    // 判断是否全部属于力量组：核心、上肢、下肢、全身
    final isAllStrength = distinctCategories.every(
      (c) =>
          c == ExerciseCategory.core ||
          c == ExerciseCategory.upperBody ||
          c == ExerciseCategory.lowerBody ||
          c == ExerciseCategory.fullBody,
    );

    if (isAllStrength) {
      setState(() => _type = WorkoutType.strength);
      return;
    }

    // 判断是否全部是有氧
    if (distinctCategories.length == 1 &&
        distinctCategories.first == ExerciseCategory.cardio) {
      setState(() => _type = WorkoutType.cardio);
      return;
    }

    // 判断是否全部是形体
    if (distinctCategories.length == 1 &&
        distinctCategories.first == ExerciseCategory.bodySculpting) {
      setState(() => _type = WorkoutType.yoga);
      return;
    }

    // 否则为综合
    setState(() => _type = WorkoutType.other);
  }

  void _addExerciseFromLibrary(Exercise exercise) {
    setState(() {
      _selectedExercises.add(exercise.name);
      _exerciseCategoryMap[exercise.name] = exercise.category;

      // 使用科学算法进行计算
      final int exerciseCals = context
          .read<AppProvider>()
          .calculateExerciseCalories(exercise);
      _totalCalories += (exerciseCals * (exercise.sets ?? 3));
      _caloriesController.text = _totalCalories.toString();

      _updateWorkoutType();
    });
  }

  void _addCustomExercise(String name) {
    if (name.isEmpty) return;
    setState(() {
      _selectedExercises.add(name);
      _exerciseCategoryMap[name] = null; // Custom
      _updateWorkoutType();
    });
  }

  void _showExerciseLibrary() {
    HandDrawnBottomSheet.show(
      context: context,
      builder: (context) {
        return ExerciseSelectionSheet(
          onSelect: (ex) {
            _addExerciseFromLibrary(ex);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _showCustomExerciseDialog() {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    HandDrawnBottomSheet.show(
      context: context,
      builder: (context) => Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '自定义动作',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            HandDrawnTextField(
              controller: controller,
              hintText: '输入动作名称',
              validator: (val) => Validators.required(val, '动作名称'),
              autofocus: true,
            ),
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
                    if (formKey.currentState!.validate()) {
                      _addCustomExercise(controller.text);
                      Navigator.pop(context);
                    }
                  },
                  label: '添加',
                  backgroundColor: AppColors.primary,
                  textColor: Colors.white,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomWeekdaysDialog() {
    Set<int> tempSelected = Set.from(_selectedWeekdays);

    HandDrawnBottomSheet.show(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '选择重复日期',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (int i = 1; i <= 7; i++)
                    GestureDetector(
                      onTap: () {
                        setSheetState(() {
                          if (tempSelected.contains(i)) {
                            tempSelected.remove(i);
                          } else {
                            tempSelected.add(i);
                          }
                        });
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: tempSelected.contains(i)
                              ? AppColors.primary
                              : AppColors.getCardColor(context),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _getWeekdayLabel(i),
                            style: TextStyle(
                              color: tempSelected.contains(i)
                                  ? Colors.white
                                  : AppColors.getTextMainColor(context),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        '取消',
                        style: TextStyle(
                          color: AppColors.getTextMutedColor(context),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: HandDrawnButton(
                      onPressed: () {
                        setState(() {
                          // 如果选择了全部 7 天，自动转换为“每天”（即清空选择项）
                          if (tempSelected.length == 7) {
                            _selectedWeekdays = {};
                          } else {
                            _selectedWeekdays = tempSelected;
                          }

                          if (_selectedWeekdays.isNotEmpty) {
                            _isChinaWorkday = false;
                            _isChinaHoliday = false;
                          }
                        });
                        Navigator.pop(context);
                      },
                      label: '确认',
                      backgroundColor: AppColors.primary,
                      textColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  String _getWeekdayLabel(int day) {
    const labels = ['一', '二', '三', '四', '五', '六', '日'];
    return labels[day - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('${widget.initialPlan == null ? "新增" : "编辑"}训练计划'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            LucideIcons.chevronLeft,
            color: AppColors.getTextMainColor(context),
            size: 28,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Plan Name
                      _buildLabel('计划名称'),
                      HandDrawnTextField(
                        controller: _nameController,
                        hintText: '例如：胸部训练、早起跑步',
                        validator: (val) => Validators.required(val, '计划名称'),
                      ),
                      const SizedBox(height: 24),

                      // Duration & Calories
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('时长 (分钟)'),
                                HandDrawnTextField(
                                  controller: _durationController,
                                  keyboardType: TextInputType.number,
                                  validator: (val) => Validators.compose(val, [
                                    (v) => Validators.required(v, '时长'),
                                    (v) => Validators.number(v, '时长'),
                                    (v) => Validators.range(
                                      v,
                                      min: 1,
                                      max: 600,
                                      fieldName: '时长',
                                      unit: '分钟',
                                    ),
                                  ]),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('预估消耗 (kcal)'),
                                HandDrawnTextField(
                                  controller: _caloriesController,
                                  keyboardType: TextInputType.number,
                                  validator: (val) => Validators.compose(val, [
                                    (v) => Validators.number(v, '预估消耗'),
                                    (v) => Validators.range(
                                      v,
                                      min: 1,
                                      max: 5000,
                                      fieldName: '预估消耗',
                                      unit: 'kcal',
                                    ),
                                  ]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Training Items
                      _buildLabel('训练项目'),
                      HandDrawnContainer(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            if (_selectedExercises.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                                child: Text(
                                  '暂无训练项目',
                                  style: TextStyle(
                                    color: AppColors.getTextMutedColor(context),
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            else
                              ..._selectedExercises.asMap().entries.map(
                                (entry) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        LucideIcons.checkCircle,
                                        size: 16,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          entry.value,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          LucideIcons.x,
                                          color: Colors.redAccent,
                                          size: 18,
                                        ),
                                        onPressed: () => setState(() {
                                          final name =
                                              _selectedExercises[entry.key];
                                          _selectedExercises.removeAt(
                                            entry.key,
                                          );
                                          _exerciseCategoryMap.remove(name);
                                          _updateWorkoutType();
                                        }),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            if (_selectedExercises.isNotEmpty)
                              Divider(
                                height: 24,
                                thickness: 1,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppColors.darkDivider
                                    : AppColors.divider,
                              ),

                            Wrap(
                              spacing: 12,
                              runSpacing: 10,
                              children: [
                                HandDrawnButton(
                                  onPressed: _showExerciseLibrary,
                                  label: '项目库',
                                  icon: LucideIcons.library,
                                  backgroundColor: AppColors.accentMint,
                                  textColor: AppColors.getTextMainColor(
                                    context,
                                  ),
                                  height: 38,
                                  fontSize: 14,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                ),
                                HandDrawnButton(
                                  onPressed: _showCustomExerciseDialog,
                                  label: '自定义',
                                  icon: LucideIcons.plus,
                                  backgroundColor: AppColors.accentPurple,
                                  textColor: AppColors.getTextMainColor(
                                    context,
                                  ),
                                  height: 38,
                                  fontSize: 14,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Plan Mode
                      _buildLabel('类型'),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _buildModeChip(
                            PlanMode.longTerm,
                            '长期计划',
                            AppColors.primary,
                            disabled: _isFutureDateSelected(),
                          ),
                          _buildModeChip(
                            PlanMode.oneTime,
                            '单次计划',
                            AppColors.accentOrange,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      if (_mode == PlanMode.longTerm) ...[
                        _buildLabel('时间'),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _buildRecurrenceChip(
                              '每天',
                              isSelected:
                                  !_isChinaWorkday &&
                                  !_isChinaHoliday &&
                                  _selectedWeekdays.isEmpty,
                              onTap: () => setState(() {
                                _isChinaWorkday = false;
                                _isChinaHoliday = false;
                                _selectedWeekdays.clear();
                              }),
                            ),
                            _buildRecurrenceChip(
                              '工作日',
                              isSelected: _isChinaWorkday,
                              onTap: () => setState(() {
                                _isChinaWorkday = true;
                                _isChinaHoliday = false;
                                _selectedWeekdays.clear();
                              }),
                            ),
                            _buildRecurrenceChip(
                              '节假日',
                              isSelected: _isChinaHoliday,
                              onTap: () => setState(() {
                                _isChinaHoliday = true;
                                _isChinaWorkday = false;
                                _selectedWeekdays.clear();
                              }),
                            ),
                            _buildRecurrenceChip(
                              _selectedWeekdays.isEmpty
                                  ? '自定义'
                                  : '周${_selectedWeekdays.map((e) => _getWeekdayLabel(e)).join('/')}',
                              isSelected: _selectedWeekdays.isNotEmpty,
                              onTap: _showCustomWeekdaysDialog,
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: HandDrawnButton(
                      onPressed: () => context.pop(),
                      label: '返回',
                      icon: LucideIcons.arrowLeft,
                      backgroundColor: AppColors.getCardColor(context),
                      textColor: AppColors.getTextMainColor(context),
                      height: 56,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 2,
                    child: HandDrawnButton(
                      onPressed: _savePlan,
                      label: '保存计划',
                      backgroundColor: AppColors.primary,
                      textColor: Colors.white,
                      height: 56,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: AppColors.getTextMainColor(context),
        ),
      ),
    );
  }

  Widget _buildModeChip(
    PlanMode mode,
    String label,
    Color color, {
    bool disabled = false,
  }) {
    final isSelected = _mode == mode;
    return GestureDetector(
      onTap: disabled ? null : () => setState(() => _mode = mode),
      child: Opacity(
        opacity: disabled ? 0.4 : 1.0,
        child: HandDrawnContainer(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: isSelected ? color : AppColors.getCardColor(context),
          borderRadius: 12,
          borderColor: AppColors.primary,
          borderWidth: 1.5,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : AppColors.getTextMainColor(context),
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  bool _isFutureDateSelected() {
    if (widget.date == null) return false;
    final todayStr = DateTime.now().toString().split(' ')[0];
    return widget.date!.compareTo(todayStr) > 0;
  }

  void _savePlan() {
    if (_formKey.currentState!.validate()) {
      if (_selectedExercises.isEmpty) {
        showHandDrawnSnackBar(context, '请至少添加一个训练项目', type: ToastType.error);
        return;
      }

      final plan =
          widget.initialPlan?.copyWith(
            name: _nameController.text,
            duration: int.tryParse(_durationController.text) ?? 30,
            calories: int.tryParse(_caloriesController.text) ?? 0,
            type: _type,
            intensity: _intensity,
            exercises: _selectedExercises,
            mode: _mode,
            repeatDays: _mode == PlanMode.longTerm
                ? _selectedWeekdays.toList()
                : null,
            isChinaHolidayPlan: _mode == PlanMode.longTerm
                ? _isChinaHoliday
                : false,
            isChinaWorkdayPlan: _mode == PlanMode.longTerm
                ? _isChinaWorkday
                : false,
          ) ??
          WorkoutPlan(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: _nameController.text,
            date: widget.date ?? DateTime.now().toString().split(' ')[0],
            time:
                '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
            duration: int.tryParse(_durationController.text) ?? 30,
            calories: int.tryParse(_caloriesController.text) ?? 0,
            type: _type,
            intensity: _intensity,
            completed: false,
            exercises: _selectedExercises,
            mode: _mode,
            endDate: null,
            isDeleted: false,
            repeatDays: _mode == PlanMode.longTerm
                ? _selectedWeekdays.toList()
                : null,
            isChinaHolidayPlan: _mode == PlanMode.longTerm
                ? _isChinaHoliday
                : false,
            isChinaWorkdayPlan: _mode == PlanMode.longTerm
                ? _isChinaWorkday
                : false,
          );
      context.read<AppProvider>().addPlan(plan);
      context.pop();
    }
  }

  Widget _buildRecurrenceChip(
    String label, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: HandDrawnContainer(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        color: isSelected
            ? AppColors.accentBlue
            : AppColors.getCardColor(context),
        borderRadius: 12,
        borderColor: AppColors.primary,
        borderWidth: 1.5,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : AppColors.getTextMainColor(context),
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
