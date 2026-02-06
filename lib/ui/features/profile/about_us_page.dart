import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:capyfit/ui/common/theme/app_colors.dart';
import 'package:capyfit/ui/common/widgets/hand_drawn_widgets.dart';
import 'package:capyfit/ui/common/widgets/update_dialog.dart';
import 'package:capyfit/data/utils/constants.dart';
import 'package:capyfit/data/utils/routes.dart';
import 'package:capyfit/data/services/app_update_service.dart';
import 'package:capyfit/data/utils/assets.dart';
import 'package:capyfit/data/utils/utils.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  String _version = '';

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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          GlobalConstants.profileAbout,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.getTextMainColor(context),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                HandDrawnContainer(
                  padding: const EdgeInsets.all(16),
                  child: Image.asset(
                    GlobalAssets.logoMac,
                    width: 80,
                    height: 80,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  GlobalConstants.appName,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  'v$_version',
                  style: TextStyle(color: AppColors.getTextMutedColor(context)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          _buildMenuItem(
            context,
            icon: LucideIcons.helpCircle,
            title: GlobalConstants.profileHelp,
            onTap: () => context.push(GlobalRoutes.profileHelp),
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            context,
            icon: LucideIcons.medal,
            title: GlobalConstants.profileLevelSystem,
            onTap: () => context.push(GlobalRoutes.profileLevelSystem),
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            context,
            icon: LucideIcons.fileText,
            title: GlobalConstants.profileTerms,
            onTap: () => context.push(GlobalRoutes.terms),
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            context,
            icon: LucideIcons.shieldCheck,
            title: GlobalConstants.profilePrivacy,
            onTap: () => context.push(GlobalRoutes.privacy),
          ),
          if (!Platform.isIOS) ...[
            const SizedBox(height: 12),
            _buildMenuItem(
              context,
              icon: LucideIcons.refreshCw,
              title: GlobalConstants.profileUpdate,
              onTap: () => _handleCheckUpdate(context),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: HandDrawnContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
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

  Future<void> _handleCheckUpdate(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: HandDrawnContainer(
          color: AppColors.getBackgroundColor(context),
          borderRadius: 24,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                strokeWidth: 3,
              ),
              const SizedBox(height: 24),
              Text(
                '正在检查更新...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.getTextMainColor(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final updateService = AppUpdateService();
      final updateInfo = await updateService.checkUpdate();

      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      if (updateInfo.hasUpdate) {
        UpdateDialog.show(context, updateInfo);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('当前已是最新版本'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      _showErrorDialog(context, '检查更新失败', e.toString());
    }
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      useRootNavigator: true,
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
              Row(
                children: [
                  const Icon(LucideIcons.alertCircle, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: TextStyle(color: AppColors.getTextMainColor(context)),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: HandDrawnButton(
                  onPressed: () =>
                      Navigator.of(context, rootNavigator: true).pop(),
                  label: '确定',
                  backgroundColor: AppColors.primary,
                  textColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
