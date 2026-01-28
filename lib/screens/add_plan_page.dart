import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_provider.dart';
import '../theme/app_colors.dart';
import '../models/workout_plan.dart';
import '../models/exercise.dart';

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
      _totalCalories += (exercise.calories * (exercise.sets ?? 3));
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
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '选择动作库项目',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: allExercises.length,
                  itemBuilder: (context, index) {
                    final ex = allExercises[index];
                    return ListTile(
                      title: Text(ex.name),
                      subtitle: Text(
                        '${ex.calories} kcal/组 · ${ex.sets ?? 3}组',
                      ),
                      trailing: const Icon(
                        LucideIcons.plusCircle,
                        color: AppColors.primary,
                      ),
                      onTap: () {
                        _addExerciseFromLibrary(ex);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCustomExerciseDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('自定义动作'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '输入动作名称'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              _addCustomExercise(controller.text);
              Navigator.pop(context);
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '新增训练计划',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: AppColors.textMain),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '计划名称',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: '例如：胸部训练、早起跑步',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (val) =>
                            (val == null || val.isEmpty) ? '请输入名称' : null,
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '时长 (分钟)',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _durationController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '预估消耗 (kcal)',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _caloriesController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        '训练项目',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            if (_selectedExercises.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  '暂无训练项目',
                                  style: TextStyle(color: AppColors.textMuted),
                                ),
                              ),
                            ..._selectedExercises.asMap().entries.map(
                              (entry) => ListTile(
                                title: Text(entry.value),
                                trailing: IconButton(
                                  icon: const Icon(
                                    LucideIcons.minusCircle,
                                    color: Colors.redAccent,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(
                                    () =>
                                        _selectedExercises.removeAt(entry.key),
                                  ),
                                ),
                              ),
                            ),
                            const Divider(height: 1),
                            Row(
                              children: [
                                Expanded(
                                  child: TextButton.icon(
                                    onPressed: _showExerciseLibrary,
                                    icon: const Icon(
                                      LucideIcons.library,
                                      size: 18,
                                    ),
                                    label: const Text('动作库选择'),
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 24,
                                  color: AppColors.border,
                                ),
                                Expanded(
                                  child: TextButton.icon(
                                    onPressed: _showCustomExerciseDialog,
                                    icon: const Icon(
                                      LucideIcons.plus,
                                      size: 18,
                                    ),
                                    label: const Text('自定义动作'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        '完成倾向',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildTypeChip(WorkoutType.strength, '力量'),
                          const SizedBox(width: 8),
                          _buildTypeChip(WorkoutType.cardio, '有氧'),
                          const SizedBox(width: 8),
                          _buildTypeChip(WorkoutType.yoga, '瑜伽'),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          '返回',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _savePlan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          '保存计划',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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

  Widget _buildTypeChip(WorkoutType type, String label) {
    final isSelected = _type == type;
    return GestureDetector(
      onTap: () => setState(() => _type = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textMain,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
      );
      context.read<AppProvider>().addPlan(plan);
      context.pop();
    }
  }
}
