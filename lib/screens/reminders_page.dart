import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import '../widgets/hand_drawn_widgets.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  bool _workoutReminder = true;
  bool _dietReminder = true;
  bool _waterReminder = false;
  TimeOfDay _workoutTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _dietTime = const TimeOfDay(hour: 12, minute: 0);

  Future<void> _selectTime(BuildContext context, bool isWorkout) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isWorkout ? _workoutTime : _dietTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.getTextMainColor(context),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isWorkout) {
          _workoutTime = picked;
        } else {
          _dietTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          '提醒设置',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.getTextMainColor(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('每日提醒'),
            HandDrawnCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildReminderTile(
                    '训练提醒',
                    '每天按时进行身体锻炼',
                    LucideIcons.dumbbell,
                    _workoutReminder,
                    (val) => setState(() => _workoutReminder = val),
                    time: _workoutTime,
                    onTimeTap: () => _selectTime(context, true),
                  ),
                  const Divider(height: 32),
                  _buildReminderTile(
                    '饮食打卡',
                    '记录每一天的健康饮食',
                    LucideIcons.utensils,
                    _dietReminder,
                    (val) => setState(() => _dietReminder = val),
                    time: _dietTime,
                    onTimeTap: () => _selectTime(context, false),
                  ),
                  const Divider(height: 32),
                  _buildReminderTile(
                    '喝水提醒',
                    '保持身体水分充足',
                    LucideIcons.droplets,
                    _waterReminder,
                    (val) => setState(() => _waterReminder = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('通知偏好'),
            HandDrawnCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildPreferenceTile('声音', true),
                  const Divider(height: 32),
                  _buildPreferenceTile('震动', true),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: HandDrawnButton(
                label: '保存设置',
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '提醒设置已保存',
                        style: TextStyle(
                          color: AppColors.getTextMainColor(context),
                        ),
                      ),
                      backgroundColor: AppColors.getCardColor(context),
                    ),
                  );
                },
                backgroundColor: AppColors.primary,
                textColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.getTextMainColor(context),
        ),
      ),
    );
  }

  Widget _buildReminderTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged, {
    TimeOfDay? time,
    VoidCallback? onTimeTap,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.getTextMainColor(context),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.getTextMutedColor(context),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary,
            ),
          ],
        ),
        if (value && time != null) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onTimeTap,
            child: HandDrawnContainer(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: AppColors.getBackgroundColor(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.clock,
                    size: 14,
                    color: AppColors.getTextMutedColor(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '提醒时间: ${time.format(context)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.getTextMainColor(context),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    LucideIcons.chevronDown,
                    size: 14,
                    color: AppColors.getTextMutedColor(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPreferenceTile(String title, bool initialValue) {
    bool value = initialValue;
    return StatefulBuilder(
      builder: (context, setState) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: AppColors.getTextMainColor(context),
              ),
            ),
            Switch(
              value: value,
              onChanged: (val) => setState(() => value = val),
              activeColor: AppColors.primary,
            ),
          ],
        );
      },
    );
  }
}
