import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_colors.dart';
import '../../models/workout_plan.dart';
import '../../models/exercise.dart';
import '../../utils/validators.dart';
import '../../widgets/hand_drawn_widgets.dart';

class AddPlanPage extends StatefulWidget {
  const AddPlanPage({super.key});

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
  final Intensity _intensity = Intensity.medium;
  final List<String> _selectedExercises = [];
  int _totalCalories = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  void _addExerciseFromLibrary(Exercise exercise) {
    setState(() {
      _selectedExercises.add(exercise.name);
      // 使用科学算法进行计算
      final int exerciseCals = context
          .read<AppProvider>()
          .calculateExerciseCalories(exercise);
      _totalCalories += (exerciseCals * (exercise.sets ?? 3));
      _caloriesController.text = _totalCalories.toString();

      // Auto-set type if it's the first exercise
      if (_selectedExercises.length == 1) {
        if (exercise.category == ExerciseCategory.cardio) {
          _type = WorkoutType.cardio;
        } else {
          _type = WorkoutType.strength;
        }
      }
    });
  }

  void _addCustomExercise(String name) {
    if (name.isEmpty) return;
    setState(() {
      _selectedExercises.add(name);
    });
  }

  void _showExerciseLibrary() {
    final allExercises = context.read<AppProvider>().exercises;
    String searchQuery = '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredExercises = allExercises.where((ex) {
              final query = searchQuery.toLowerCase();
              return ex.name.toLowerCase().contains(query) ||
                  ex.targetMuscles.any((m) => m.toLowerCase().contains(query));
            }).toList();

            return HandDrawnContainer(
              color: AppColors.getBackgroundColor(context),
              borderRadius: 32,
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.getBorderColor(context),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '项目库 (${filteredExercises.length})',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.getTextMainColor(context),
                        ),
                      ),
                      if (searchQuery.isNotEmpty)
                        IconButton(
                          icon: const Icon(LucideIcons.xCircle, size: 20),
                          onPressed: () =>
                              setModalState(() => searchQuery = ''),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  HandDrawnTextField(
                    hintText: '搜索动作或部位...',
                    onChanged: (val) => setModalState(() => searchQuery = val),
                    prefixIcon: const Icon(LucideIcons.search, size: 20),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: ListView.builder(
                      itemCount: filteredExercises.length,
                      itemBuilder: (context, index) {
                        final ex = filteredExercises[index];
                        final calPerSet = context
                            .read<AppProvider>()
                            .calculateExerciseCalories(ex);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: HandDrawnContainer(
                            padding: const EdgeInsets.all(4),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  ex.image ?? '',
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 44,
                                      height: 44,
                                      color: AppColors.accentMint.withOpacity(
                                        0.2,
                                      ),
                                      child: const Icon(
                                        LucideIcons.dumbbell,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              title: Text(
                                ex.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '$calPerSet kcal/组 · ${ex.sets ?? 3}组',
                                style: TextStyle(
                                  color: AppColors.getTextMutedColor(context),
                                  fontSize: 13,
                                ),
                              ),
                              trailing: const Icon(
                                LucideIcons.plusCircle,
                                color: AppColors.primary,
                                size: 24,
                              ),
                              onTap: () {
                                _addExerciseFromLibrary(ex);
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCustomExerciseDialog() {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: HandDrawnContainer(
          color: AppColors.getBackgroundColor(context),
          borderRadius: 24,
          padding: const EdgeInsets.all(24),
          child: Form(
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          '新增训练计划',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: 1,
          ),
        ),
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
                                      min: 0,
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
                                        onPressed: () => setState(
                                          () => _selectedExercises.removeAt(
                                            entry.key,
                                          ),
                                        ),
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

                            Row(
                              children: [
                                Expanded(
                                  child: HandDrawnButton(
                                    onPressed: _showExerciseLibrary,
                                    label: '项目库',
                                    icon: LucideIcons.library,
                                    backgroundColor:
                                        AppColors.accentMint, // Mint
                                    textColor: AppColors.getTextMainColor(
                                      context,
                                    ),
                                    height: 48,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: HandDrawnButton(
                                    onPressed: _showCustomExerciseDialog,
                                    label: '自定义',
                                    icon: LucideIcons.plus,
                                    backgroundColor:
                                        AppColors.accentPurple, // Purple
                                    textColor: AppColors.getTextMainColor(
                                      context,
                                    ),
                                    height: 48,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Type/Preference
                      _buildLabel('完成倾向'),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTypeChip(
                              WorkoutType.strength,
                              '力量',
                              AppColors.accentMint,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTypeChip(
                              WorkoutType.cardio,
                              '有氧',
                              AppColors.accentPink,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTypeChip(
                              WorkoutType.yoga,
                              '瑜伽',
                              AppColors.accentPurple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Plan Mode
                      _buildLabel('计划类型'),
                      Row(
                        children: [
                          Expanded(
                            child: _buildModeChip(
                              PlanMode.longTerm,
                              '长期计划',
                              AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildModeChip(
                              PlanMode.oneTime,
                              '单次计划',
                              AppColors.accentOrange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.all(20),
              // decoration: const BoxDecoration(
              //   border: Border(top: BorderSide(color: AppColors.border, width: 1)),
              // ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: HandDrawnButton(
                      onPressed: () => context.pop(),
                      label: '返回',
                      icon: LucideIcons.arrowLeft,
                      backgroundColor: AppColors.accentOrange, // Beige/Orange
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

  Widget _buildTypeChip(WorkoutType type, String label, Color color) {
    final isSelected = _type == type;
    return GestureDetector(
      onTap: () => setState(() => _type = type),
      child: HandDrawnContainer(
        padding: const EdgeInsets.symmetric(vertical: 12),
        color: isSelected ? color : Colors.white,
        borderRadius: 12,
        borderColor: AppColors.primary,
        borderWidth: 1.5,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.getTextMainColor(context),
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeChip(PlanMode mode, String label, Color color) {
    final isSelected = _mode == mode;
    return GestureDetector(
      onTap: () => setState(() => _mode = mode),
      child: HandDrawnContainer(
        padding: const EdgeInsets.symmetric(vertical: 12),
        color: isSelected ? color : Colors.white,
        borderRadius: 12,
        borderColor: AppColors.primary,
        borderWidth: 1.5,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : AppColors.getTextMainColor(context),
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  void _savePlan() {
    if (_formKey.currentState!.validate()) {
      final plan = WorkoutPlan(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        date: DateTime.now().toString().split(' ')[0],
        time:
            '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        duration: int.tryParse(_durationController.text) ?? 30,
        calories: int.tryParse(_caloriesController.text) ?? 0,
        type: _type,
        intensity: _intensity,
        completed: false,
        exercises: _selectedExercises,
        mode: _mode,
      );
      context.read<AppProvider>().addPlan(plan);
      context.pop();
    }
  }
}
