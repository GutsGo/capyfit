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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Card
              HandDrawnCard(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF5E6D3),
                        border: Border.all(color: Colors.white, width: 3),
                        image: const DecorationImage(
                          image: AssetImage(
                            'assets/images/capybara-mascot.png',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '健身达人',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMain,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '加入卡皮健身第 ${stats.joinedDays} 天',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8E8E2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  LucideIcons.lock,
                                  size: 14,
                                  color: Color(0xFFB98471),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '初级会员',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFB98471),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Achievement Section
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  '我的成就',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
              ),
              HandDrawnCard(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildAchievementItem(
                      icon: LucideIcons.calendar,
                      value: stats.joinedDays.toString(),
                      label: '坚持天数',
                      color: const Color(0xFFEBE1D8),
                      iconColor: const Color(0xFF8B6F5C),
                    ),
                    _buildAchievementItem(
                      icon: LucideIcons.medal,
                      value: stats.totalWorkouts.toString(),
                      label: '完成训练',
                      color: const Color(0xFFE3F1EC),
                      iconColor: const Color(0xFF7EB8A2),
                    ),
                    _buildAchievementItem(
                      icon: LucideIcons.clock,
                      value: (stats.totalDuration / 60).toStringAsFixed(0),
                      label: '训练小时',
                      color: const Color(0xFFFDF0E8),
                      iconColor: const Color(0xFFE8A87C),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Settings Section
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  '设置',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
              ),
              _buildSettingsItem(
                icon: LucideIcons.user,
                title: '个人资料',
                iconBgColor: const Color(0xFFF5E6D3),
                iconColor: const Color(0xFF8B6F5C),
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _buildSettingsItem(
                icon: LucideIcons.bell,
                title: '提醒设置',
                iconBgColor: const Color(0xFFE3F1EC),
                iconColor: const Color(0xFF7EB8A2),
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _buildSettingsItem(
                icon: LucideIcons.target,
                title: '目标设置',
                iconBgColor: const Color(0xFFFDF0E8),
                iconColor: const Color(0xFFE8A87C),
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _buildSettingsItem(
                icon: LucideIcons.database,
                title: '数据备份',
                iconBgColor: const Color(0xFFF1D7D2),
                iconColor: const Color(0xFFA67C75),
                onTap: () {},
              ),
              const SizedBox(height: 24),

              // About Section
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  '关于',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
              ),
              _buildSettingsItem(
                icon: LucideIcons.helpCircle,
                title: '使用帮助',
                iconBgColor: const Color(0xFFF1EFEC),
                iconColor: const Color(0xFF8D8D8D),
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _buildSettingsItem(
                icon: LucideIcons.messageSquare,
                title: '意见反馈',
                iconBgColor: const Color(0xFFE3F1EC),
                iconColor: const Color(0xFF7EB8A2),
                onTap: () {},
              ),
              const SizedBox(height: 48),

              // Footer
              Center(
                child: Column(
                  children: [
                    const Text(
                      '卡皮健身 v1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '非商用版本 · 仅供学习交流',
                      style: TextStyle(fontSize: 10, color: Color(0xFFAAAAAA)),
                    ),
                    const SizedBox(height: 16),
                    Opacity(
                      opacity: 0.5,
                      child: Image.asset(
                        'assets/images/capy_running.png',
                        width: 40,
                        height: 40,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required Color iconColor,
  }) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required Color iconBgColor,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return HandDrawnCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textMain,
              ),
            ),
          ),
          const Icon(
            LucideIcons.chevronRight,
            size: 20,
            color: Color(0xFFCCCCCC),
          ),
        ],
      ),
    );
  }
}
