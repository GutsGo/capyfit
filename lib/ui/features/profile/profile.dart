import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:capyfit/providers/app_provider.dart';
import 'package:capyfit/ui/common/theme/app_colors.dart';
import 'package:capyfit/ui/common/widgets/common_widgets.dart';
import 'package:capyfit/ui/common/widgets/hand_drawn_widgets.dart';
import 'package:capyfit/data/utils/assets.dart';
import 'package:capyfit/data/utils/constants.dart';
import 'package:capyfit/data/utils/utils.dart';
import 'package:capyfit/data/utils/routes.dart';
import 'package:capyfit/data/services/level_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppProvider>();
    final stats = appState.userStats;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(GlobalConstants.profileTitle),
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
            tooltip: GlobalConstants.profileThemeToggle,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
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
                    AnimatedProfileAvatar(
                      avatarPath: appState.userProfile.avatarPath,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appState.userProfile.nickname ??
                                GlobalConstants.profileUserDefaultName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.getTextMainColor(context),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            GlobalUtils.formatJoinedDays(stats.joinedDays),
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.getTextMutedColor(context),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Builder(
                            builder: (context) {
                              final levelInfo = LevelService.getLevelInfo(
                                stats.activeDays,
                              );
                              final realmColor = levelInfo.mainColor;
                              return GestureDetector(
                                onTap: () => context.push(
                                  GlobalRoutes.profileLevelSystem,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: realmColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: realmColor.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        LucideIcons.medal,
                                        size: 14,
                                        color: realmColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        levelInfo.fullDisplayName,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: realmColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
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
                  GlobalConstants.profileAchievements,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextMainColor(context),
                  ),
                ),
              ),
              HandDrawnCard(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildAchievementItem(
                      context,
                      icon: LucideIcons.calendar,
                      value: stats.activeDays.toString(),
                      label: GlobalConstants.profileAchievementActiveDays,
                      color: const Color(0xFFEBE1D8),
                      iconColor: const Color(0xFF8B6F5C),
                    ),
                    _buildAchievementItem(
                      context,
                      icon: LucideIcons.medal,
                      value: stats.totalWorkouts.toString(),
                      label: GlobalConstants.profileAchievementTotalWorkouts,
                      color: const Color(0xFFE3F1EC),
                      iconColor: const Color(0xFF7EB8A2),
                    ),
                    _buildAchievementItem(
                      context,
                      icon: LucideIcons.clock,
                      value: (stats.totalDuration / 60).toStringAsFixed(0),
                      label: GlobalConstants.profileAchievementTotalHours,
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
                  GlobalConstants.profileSettingsHeader,
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
                title: GlobalConstants.profileSettings,
                iconBgColor: const Color(0xFFF5E6D3),
                iconColor: const Color(0xFF8B6F5C),
                onTap: () => context.push(GlobalRoutes.profileSettings),
              ),
              const SizedBox(height: 12),
              _buildSettingsItem(
                context,
                icon: LucideIcons.target,
                title: GlobalConstants.profileGoals,
                iconBgColor: const Color(0xFFFDF0E8),
                iconColor: const Color(0xFFE8A87C),
                onTap: () => context.push(GlobalRoutes.profileGoals),
              ),
              const SizedBox(height: 12),
              _buildSettingsItem(
                context,
                icon: LucideIcons.database,
                title: GlobalConstants.profileBackup,
                iconBgColor: const Color(0xFFF1D7D2),
                iconColor: const Color(0xFFA67C75),
                onTap: () => context.push(GlobalRoutes.profileBackup),
              ),
              const SizedBox(height: 24),

              // About Section
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  GlobalConstants.profileAboutHeader,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextMainColor(context),
                  ),
                ),
              ),
              _buildSettingsItem(
                context,
                icon: LucideIcons.messageSquare,
                title: GlobalConstants.profileFeedback,
                iconBgColor: const Color(0xFFE3F1EC),
                iconColor: const Color(0xFF7EB8A2),
                onTap: () => context.push(GlobalRoutes.profileFeedback),
              ),
              const SizedBox(height: 12),
              _buildSettingsItem(
                context,
                icon: LucideIcons.info,
                title: GlobalConstants.profileAbout,
                iconBgColor: const Color(0xFFE8F0FD),
                iconColor: const Color(0xFF5C7BCF),
                onTap: () => context.push(GlobalRoutes.profileAbout),
              ),
              const SizedBox(height: 48),

              // Footer
              Center(
                child: Column(
                  children: [
                    Text(
                      GlobalConstants.profileVersion,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.getTextMutedColor(context),
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
                ? color.withOpacity(0.2)
                : color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        const SizedBox(height: 8),
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
    return GestureDetector(
      onTap: onTap,
      child: HandDrawnContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? iconBgColor.withOpacity(0.2)
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
      ),
    );
  }

  static ImageProvider getAvatarImage(String? avatarPath) {
    if (avatarPath == null) {
      return const AssetImage(GlobalAssets.capybaraMascot);
    }
    if (avatarPath.startsWith('assets/')) {
      return AssetImage(avatarPath);
    }
    return FileImage(File(avatarPath));
  }
}

class AnimatedProfileAvatar extends StatefulWidget {
  final String? avatarPath;
  final double size;

  const AnimatedProfileAvatar({super.key, this.avatarPath, this.size = 80});

  @override
  State<AnimatedProfileAvatar> createState() => _AnimatedProfileAvatarState();
}

class _AnimatedProfileAvatarState extends State<AnimatedProfileAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 旋转的彩色边框
          RotationTransition(
            turns: _controller,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    Colors.red,
                    Colors.orange,
                    Colors.yellow,
                    Colors.green,
                    Colors.blue,
                    Colors.indigo,
                    Colors.purple,
                    Colors.red,
                  ],
                ),
              ),
            ),
          ),
          // 内部头像 Container
          Container(
            width: widget.size - 6, // 边框宽度
            height: widget.size - 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF5E6D3),
              border: Border.all(color: Colors.white, width: 2),
              image: DecorationImage(
                image: ProfilePage.getAvatarImage(widget.avatarPath),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
