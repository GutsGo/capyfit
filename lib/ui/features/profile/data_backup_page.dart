import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:capyfit/ui/common/theme/app_colors.dart';
import 'package:capyfit/ui/common/widgets/common_widgets.dart';
import 'package:capyfit/data/services/hive_service.dart';
import 'package:intl/intl.dart';

import 'package:capyfit/data/services/backup_service.dart';
import 'package:provider/provider.dart';
import 'package:capyfit/providers/app_provider.dart';
import 'package:capyfit/ui/features/home/home_vm.dart';
import 'package:capyfit/ui/features/diet/diet_vm.dart';
import 'package:capyfit/ui/features/plan/plan_vm.dart';
import 'package:capyfit/ui/features/exercise/exercise_vm.dart';

class DataBackupPage extends StatefulWidget {
  const DataBackupPage({super.key});

  @override
  State<DataBackupPage> createState() => _DataBackupPageState();
}

class _DataBackupPageState extends State<DataBackupPage> {
  bool _isBackingUp = false;
  bool _isImporting = false;

  void _handleBackup() async {
    if (_isBackingUp) return;
    setState(() => _isBackingUp = true);
    try {
      final message = await BackupService().exportData();
      if (mounted) {
        showHandDrawnSnackBar(context, message);
      }
    } catch (e) {
      if (mounted) {
        showHandDrawnSnackBar(context, e.toString(), type: ToastType.error);
      }
    } finally {
      if (mounted) {
        setState(() => _isBackingUp = false);
      }
    }
  }

  void _handleImport() async {
    if (_isImporting) return;
    setState(() => _isImporting = true);
    try {
      final message = await BackupService().importData();
      if (!mounted) return;

      // 1. 获取所有 Provider 实例 (同步操作，不需要在 await 后检查 mounted)
      final appProvider = context.read<AppProvider>();
      final homeVm = context.read<HomeViewModel>();
      final planVm = context.read<PlanViewModel>();
      final dietVm = context.read<DietViewModel>();
      final exerciseVm = context.read<ExerciseViewModel>();

      // 2. 执行数据刷新
      // 先刷新 AppProvider 以确保全局状态(如 UserProfile)是最新的
      await appProvider.init();

      // 并行刷新其他业务模块
      await Future.wait([
        homeVm.init(),
        planVm.init(),
        dietVm.init(),
        exerciseVm.init(),
      ]);

      // 3. 显示成功提示
      if (!mounted) return;
      showHandDrawnSnackBar(context, message);
    } catch (e) {
      if (mounted) {
        showHandDrawnSnackBar(context, e.toString(), type: ToastType.error);
      }
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('数据备份')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Icon(
                        LucideIcons.cloud,
                        size: 60,
                        color: AppColors.primary,
                      ),
                      if (_isBackingUp || _isImporting)
                        const SizedBox(
                          width: 130,
                          height: 130,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '保障您的数据安全',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextMainColor(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '您可以将训练和饮食记录导出为本地文件\n或者在更换设备时导入。',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.getTextMutedColor(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            _buildSectionTitle('数据操作'),
            HandDrawnCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildActionTile(
                    '立即备份',
                    '导出当前所有数据为 JSON 文件',
                    LucideIcons.download,
                    onTap: _isBackingUp ? null : _handleBackup,
                  ),
                  const Divider(height: 32),
                  _buildActionTile(
                    '导入数据',
                    '选择备份文件并恢复数据',
                    LucideIcons.upload,
                    onTap: _isImporting ? null : _handleImport,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('存储信息'),
            HandDrawnCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '上次备份时间',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.getTextMainColor(context),
                    ),
                  ),
                  Text(
                    _getLastBackupTimeStr(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextMutedColor(context),
                    ),
                  ),
                ],
              ),
            ),
            if (kDebugMode) ...[
              const SizedBox(height: 24),
              _buildSectionTitle('开发者工具 (Debug)'),
              HandDrawnCard(
                padding: const EdgeInsets.all(16),
                child: _buildActionTile(
                  '清空所有数据',
                  '彻底重置 Hive 数据库，此操作不可逆',
                  LucideIcons.trash2,
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('确认清空？'),
                        content: const Text('这将删除所有本地数据并重置应用。'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('取消'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              '确认清除',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      await HiveService().debugClearAllBoxes();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('所有数据已清空，请重启应用')),
                        );
                      }
                    }
                  },
                ),
              ),
            ],
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

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        color: Colors.transparent,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.getBackgroundColor(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
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
            Icon(
              LucideIcons.chevronRight,
              size: 18,
              color: AppColors.getTextMutedColor(context).withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  String _getLastBackupTimeStr() {
    final lastBackup = HiveService().lastBackupTime;
    if (lastBackup == null) {
      return '从未备份';
    }
    return DateFormat('yyyy-MM-dd HH:mm').format(lastBackup);
  }
}
