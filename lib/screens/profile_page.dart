import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppProvider>();
    final stats = appState.userStats;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // User Info
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primaryLight,
                child: Text('🐾', style: TextStyle(fontSize: 40)),
              ),
              const SizedBox(height: 12),
              const Text('健身达人', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Text('坚持就是胜利！', style: TextStyle(color: AppColors.textMuted)),
              const SizedBox(height: 24),

              // Overall Stats
              Row(
                children: [
                   Expanded(child: _buildStatItem('累计训练', stats.totalWorkouts.toString(), '次')),
                   const SizedBox(width: 12),
                   Expanded(child: _buildStatItem('累计时长', (stats.totalDuration / 60).toStringAsFixed(1), 'h')),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                   Expanded(child: _buildStatItem('消耗热量', stats.totalCalories.toString(), 'kcal')),
                   const SizedBox(width: 12),
                   Expanded(child: _buildStatItem('加入天数', stats.joinedDays.toString(), '天')),
                ],
              ),
              const SizedBox(height: 24),

              // Settings List
              HandDrawnCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildSettingsTile(LucideIcons.user, '个人资料'),
                    const Divider(height: 1, indent: 50),
                    _buildSettingsTile(LucideIcons.target, '健身目标'),
                    const Divider(height: 1, indent: 50),
                    _buildSettingsTile(LucideIcons.bell, '消息提醒'),
                    const Divider(height: 1, indent: 50),
                    _buildSettingsTile(LucideIcons.shieldCheck, '隐私设置'),
                    const Divider(height: 1, indent: 50),
                    _buildSettingsTile(LucideIcons.info, '关于 Kapi Fit'),
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String unit) {
    return HandDrawnCard(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              Text(unit, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 20),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textMuted),
      onTap: () {},
    );
  }
}
