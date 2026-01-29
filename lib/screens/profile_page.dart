import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          '个人中心',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.getTextMainColor(context),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              appState.themeMode == ThemeMode.system
                  ? LucideIcons.monitor
                  : appState.themeMode == ThemeMode.light
                  ? LucideIcons.sun
                  : LucideIcons.moon,
              color: AppColors.getTextMainColor(context),
            ),
            onPressed: appState.toggleThemeMode,
            tooltip: '切换主题模式',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false, // AppBar is already there
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 2, 20, 16),
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
                            'assets/images/capybara-mascot.webp',
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
                          Text(
                            '健身达人',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.getTextMainColor(context),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '加入卡皮健身第 ${stats.joinedDays} 天',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.getTextMutedColor(context),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? const Color(
                                      0xFFF8E8E2,
                                    ).withValues(alpha: 0.1)
                                  : const Color(0xFFF8E8E2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.lock,
                                  size: 14,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color(0xFFD4A594)
                                      : const Color(0xFFB98471),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '初级会员',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? const Color(0xFFD4A594)
                                        : const Color(0xFFB98471),
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
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  '我的成就',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextMainColor(context),
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
                      context,
                      icon: LucideIcons.calendar,
                      value: stats.joinedDays.toString(),
                      label: '坚持天数',
                      color: const Color(0xFFEBE1D8),
                      iconColor: const Color(0xFF8B6F5C),
                    ),
                    _buildAchievementItem(
                      context,
                      icon: LucideIcons.medal,
                      value: stats.totalWorkouts.toString(),
                      label: '完成训练',
                      color: const Color(0xFFE3F1EC),
                      iconColor: const Color(0xFF7EB8A2),
                    ),
                    _buildAchievementItem(
                      context,
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
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  '设置',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextMainColor(context),
                  ),
                ),
              ),
              _buildSettingsItem(
                context,
                icon: LucideIcons.user,
                title: '个人资料',
                iconBgColor: const Color(0xFFF5E6D3),
                iconColor: const Color(0xFF8B6F5C),
                onTap: () {
                  context.push('/profile/settings');
                },
              ),
              const SizedBox(height: 12),
              _buildSettingsItem(
                context,
                icon: LucideIcons.bell,
                title: '提醒设置',
                iconBgColor: const Color(0xFFE3F1EC),
                iconColor: const Color(0xFF7EB8A2),
                onTap: () {
                  context.push('/profile/reminders');
                },
              ),
              const SizedBox(height: 12),
              _buildSettingsItem(
                context,
                icon: LucideIcons.target,
                title: '目标设置',
                iconBgColor: const Color(0xFFFDF0E8),
                iconColor: const Color(0xFFE8A87C),
                onTap: () {
                  context.push('/profile/goals');
                },
              ),
              const SizedBox(height: 12),
              _buildSettingsItem(
                context,
                icon: LucideIcons.database,
                title: '数据备份',
                iconBgColor: const Color(0xFFF1D7D2),
                iconColor: const Color(0xFFA67C75),
                onTap: () {
                  context.push('/profile/backup');
                },
              ),
              const SizedBox(height: 24),

              // About Section
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  '关于',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextMainColor(context),
                  ),
                ),
              ),
              _buildSettingsItem(
                context,
                icon: LucideIcons.helpCircle,
                title: '使用帮助',
                iconBgColor: const Color(0xFFF1EFEC),
                iconColor: const Color(0xFF8D8D8D),
                onTap: () {
                  context.push('/profile/help');
                },
              ),
              const SizedBox(height: 12),
              _buildSettingsItem(
                context,
                icon: LucideIcons.messageSquare,
                title: '意见反馈',
                iconBgColor: const Color(0xFFE3F1EC),
                iconColor: const Color(0xFF7EB8A2),
                onTap: () {
                  context.push('/profile/feedback');
                },
              ),
              const SizedBox(height: 48),

              // Footer
              Center(
                child: Column(
                  children: [
                    Text(
                      '卡皮健身 v1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.getTextMutedColor(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '非商用版本 · 仅供学习交流',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.getTextMutedColor(
                          context,
                        ).withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Opacity(
                      opacity: 0.5,
                      child: Image.asset(
                        'assets/images/capy_running.webp',
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

  Widget _buildAchievementItem(
    BuildContext context, {
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
            color: Theme.of(context).brightness == Brightness.dark
                ? color.withValues(alpha: 0.2)
                : color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: iconColor, size: 28),
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
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
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
              color: Theme.of(context).brightness == Brightness.dark
                  ? iconBgColor.withValues(alpha: 0.2)
                  : iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Color.lerp(iconColor, Colors.white, 0.3)
                  : iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.getTextMainColor(context),
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
