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
import 'package:capyfit/data/services/share_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();

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

class _ProfilePageState extends State<ProfilePage> {
  String _version = '';
  final GlobalKey _shareKey = GlobalKey();
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final version = await GlobalUtils.getAppVersion();
    if (mounted) {
      setState(() {
        _version = version;
      });
    }
  }

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
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 2, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Card
              HandDrawnCard(
                padding: const EdgeInsets.all(24).copyWith(right: 16),
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
                          Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.centerRight,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      appState.userProfile.nickname ??
                                          GlobalConstants
                                              .profileUserDefaultName,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.getTextMainColor(
                                          context,
                                        ),
                                        height: 1.2,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  const SizedBox(width: 40), // 预留出按钮的宽度空间
                                ],
                              ),
                              Positioned(
                                right: -12, // 稍微向右偏移，增加右手握持时的点击便利性
                                child: GestureDetector(
                                  onTap: () => _showShareDialog(
                                    context,
                                    stats,
                                    appState,
                                  ),
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    padding: const EdgeInsets.all(
                                      12,
                                    ), // 巨大的点击感应区
                                    color: Colors.transparent,
                                    child: Icon(
                                      LucideIcons.share2,
                                      color: AppColors.getTextMutedColor(
                                        context,
                                      ),
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            GlobalUtils.getRandomProfileMotto(),
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.getTextMutedColor(context),
                              fontStyle: FontStyle.italic,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
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
                                      Flexible(
                                        child: Text(
                                          levelInfo.fullDisplayName,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: realmColor,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
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
              const SizedBox(height: 12),
              _buildSettingsItem(
                context,
                icon: LucideIcons.barChart2,
                title: '数据中心',
                iconBgColor: const Color(0xFFFDF0E8),
                iconColor: const Color(0xFFE8A87C),
                onTap: () => context.push(GlobalRoutes.stats),
              ),
              const SizedBox(height: 12),
              _buildSettingsItem(
                context,
                icon: LucideIcons.gem,
                title: '猛练勋章',
                iconBgColor: const Color(0xFFE8F0FD),
                iconColor: const Color(0xFF5C7BCF),
                onTap: () => context.push(GlobalRoutes.profileMedals),
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
                      '${GlobalConstants.appName} v$_version',
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

  Future<void> _showShareDialog(
    BuildContext context,
    UserStats stats,
    AppProvider appState,
  ) async {
    final levelInfo = LevelService.getLevelInfo(stats.activeDays);
    // 随机选择背景
    final shareImages = [
      'assets/images/shares/share_1.jpg',
      'assets/images/shares/share_2.jpg',
      'assets/images/shares/share_3.jpg',
    ];
    final randomImage =
        shareImages[DateTime.now().millisecond % shareImages.length];

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Stack(
              children: [
                // 遮罩层
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(color: Colors.black.withOpacity(0.7)),
                  ),
                ),
                // 内容层
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: RepaintBoundary(
                          key: _shareKey,
                          child: _SharePreviewContent(
                            stats: stats,
                            levelInfo: levelInfo,
                            nickname:
                                appState.userProfile.nickname ??
                                GlobalConstants.profileUserDefaultName,
                            backgroundImage: randomImage,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: HandDrawnButton(
                          label: _isSharing ? '正在生成...' : '分享海报',
                          onPressed: _isSharing
                              ? () {}
                              : () async {
                                  setDialogState(() => _isSharing = true);
                                  try {
                                    await _captureAndShare();
                                  } finally {
                                    if (context.mounted) {
                                      setDialogState(() => _isSharing = false);
                                    }
                                  }
                                },
                        ),
                      ),
                    ],
                  ),
                ),
                // 关闭按钮
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  right: 20,
                  child: IconButton(
                    icon: const Icon(
                      LucideIcons.x,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _captureAndShare() async {
    try {
      final shareText =
          '我在 Capyfit 已经坚持健身 ${context.read<AppProvider>().userStats.joinedDays} 天啦！快来和我一起努力吧！';
      await ShareService.captureAndShare(_shareKey, text: shareText);
    } catch (e) {
      debugPrint('Capture and share error: $e');
    }
  }
}

class _SharePreviewContent extends StatelessWidget {
  final UserStats stats;
  final dynamic levelInfo;
  final String nickname;
  final String backgroundImage;

  const _SharePreviewContent({
    required this.stats,
    required this.levelInfo,
    required this.nickname,
    required this.backgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 533, // 9:16 aspect ratio
      color: Colors.white,
      child: Stack(
        children: [
          // 背景图 (随机选择)
          Positioned.fill(
            child: Image.asset(backgroundImage, fit: BoxFit.cover),
          ),
          // 强化底部遮罩，确保数据清晰
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.4, 0.65, 1.0],
                  colors: [
                    Colors.black.withOpacity(0.05),
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                    Colors.black.withOpacity(0.95),
                  ],
                ),
              ),
            ),
          ),
          // 数据展示
          Positioned(
            left: 24,
            right: 24,
            bottom: 32,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nickname,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black45,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (levelInfo.mainColor as Color).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    levelInfo.fullDisplayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildShareStatItem(
                      '坚持天数',
                      stats.activeDays.toString(),
                      '天',
                    ),
                    _buildShareStatItem(
                      '训练时间',
                      (stats.totalDuration / 60).toStringAsFixed(1),
                      '小时',
                    ),
                    _buildShareStatItem(
                      '总消耗',
                      stats.totalCalories.toString(),
                      'kcal',
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Logo 或 品牌标识 (带黑色描边)
          Positioned(
            top: 32,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                OutlinedText(
                  'CAPYFIT',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    fontStyle: FontStyle.italic,
                  ),
                  outlineWidth: 3,
                ),
                OutlinedText(
                  'Stay cozy, stay fit',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                  outlineColor: Colors.black54,
                  outlineWidth: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareStatItem(String label, String value, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(width: 2),
            Text(
              unit,
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ],
        ),
      ],
    );
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
