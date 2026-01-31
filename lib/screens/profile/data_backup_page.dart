import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';

class DataBackupPage extends StatefulWidget {
  const DataBackupPage({super.key});

  @override
  State<DataBackupPage> createState() => _DataBackupPageState();
}

class _DataBackupPageState extends State<DataBackupPage> {
  bool _isBackingUp = false;

  void _handleBackup() async {
    setState(() => _isBackingUp = true);
    // Simulate backup process
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isBackingUp = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '备份完成！数据已安全存至本地。',
            style: TextStyle(color: AppColors.getTextMainColor(context)),
          ),
          backgroundColor: AppColors.getCardColor(context),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          '数据备份',
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
                      if (_isBackingUp)
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
                    onTap: () {
                      // Implement import logic
                    },
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
                    '2026-01-29 10:30',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextMutedColor(context),
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
}
