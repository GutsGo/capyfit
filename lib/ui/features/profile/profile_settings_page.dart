import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:capyfit/providers/app_provider.dart';
import 'package:capyfit/ui/common/theme/app_colors.dart';
import 'package:capyfit/data/models/user_profile.dart';
import 'package:capyfit/ui/common/widgets/common_widgets.dart';
import 'package:capyfit/ui/common/widgets/hand_drawn_widgets.dart';
import 'package:capyfit/data/utils/validators.dart';
import 'package:capyfit/data/utils/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _ageController;

  late TextEditingController _nicknameController;
  late Gender _gender;
  String? _avatarPath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final profile = context.read<AppProvider>().userProfile;
    _heightController = TextEditingController(
      text: profile.height?.toString() ?? '',
    );
    _weightController = TextEditingController(
      text: profile.weight?.toString() ?? '',
    );
    _ageController = TextEditingController(text: profile.age?.toString() ?? '');
    _nicknameController = TextEditingController(text: profile.nickname);
    _gender = profile.gender;
    _avatarPath = profile.avatarPath;

    // Add listeners for real-time updates
    _heightController.addListener(_onInputChanged);
    _weightController.addListener(_onInputChanged);
    _ageController.addListener(_onInputChanged);
  }

  void _onInputChanged() {
    setState(() {
      // Just trigger rebuild
    });
  }

  @override
  void dispose() {
    _heightController.removeListener(_onInputChanged);
    _weightController.removeListener(_onInputChanged);
    _ageController.removeListener(_onInputChanged);
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    // 执行表单校验
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<AppProvider>();
    final newProfile = provider.userProfile.copyWith(
      height: double.tryParse(_heightController.text),
      weight: double.tryParse(_weightController.text),
      gender: _gender,
      age: int.tryParse(_ageController.text),
      nickname: _nicknameController.text,
      avatarPath: _avatarPath,
    );
    provider.updateUserProfile(newProfile);
    Navigator.pop(context);
    showHandDrawnSnackBar(context, '个人资料已更新');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          '个人设置',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.getTextMainColor(context),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatarSection(),
              const SizedBox(height: 24),
              _buildSectionTitle('基本资料'),
              HandDrawnCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInputField(
                      '昵称',
                      _nicknameController,
                      TextInputType.text,
                      Validators.nickname,
                    ),
                    const SizedBox(height: 16),
                    _buildGenderPicker(),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('身体数据'),
              HandDrawnCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInputField(
                      '身高 (cm)',
                      _heightController,
                      TextInputType.number,
                      Validators.height,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      '体重 (kg)',
                      _weightController,
                      TextInputType.number,
                      Validators.weight,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      '年龄',
                      _ageController,
                      TextInputType.number,
                      Validators.age,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const SizedBox(height: 24),
              // 数据隐私说明
              Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.shieldCheck,
                          size: 14,
                          color: AppColors.getTextMutedColor(context),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '隐私保护',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.getTextMutedColor(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '您的所有个人数据均仅存储在本地设备中，\n不会上传至任何云端服务器。',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.getTextMutedColor(context),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: HandDrawnButton(
                  label: '保存设置',
                  onPressed: _saveProfile,
                  backgroundColor: AppColors.primary,
                  textColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
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

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    TextInputType type, [
    String? Function(String?)? validator,
  ]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.getTextMutedColor(context),
          ),
        ),
        const SizedBox(height: 8),
        HandDrawnTextField(
          controller: controller,
          keyboardType: type,
          validator: validator,
          hintText: '请输入...',
        ),
      ],
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.getCardColor(context),
            backgroundImage: _getAvatarImage(),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.camera,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider _getAvatarImage() {
    if (_avatarPath == null) {
      return const AssetImage(GlobalConstants.profileDefaultAvatar);
    }
    if (_avatarPath!.startsWith('assets/')) {
      return AssetImage(_avatarPath!);
    }
    return FileImage(File(_avatarPath!));
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (image != null) {
        final File file = File(image.path);
        final int fileSize = await file.length();
        const int maxFileSize = GlobalConstants.maxAvatarSize;

        if (fileSize > maxFileSize) {
          if (mounted) {
            showHandDrawnSnackBar(
              context,
              '图片大小不能超过 3MB',
              type: ToastType.error,
            );
          }
          return;
        }

        setState(() {
          _avatarPath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        showHandDrawnSnackBar(context, '选择图片失败', type: ToastType.error);
      }
    }
  }

  Widget _buildGenderPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '性别',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.getTextMainColor(context),
          ),
        ),
        Row(
          children: [
            _buildChoiceChip(
              '男',
              _gender == Gender.male,
              () => setState(() => _gender = Gender.male),
            ),
            const SizedBox(width: 8),
            _buildChoiceChip(
              '女',
              _gender == Gender.female,
              () => setState(() => _gender = Gender.female),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChoiceChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: HandDrawnContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        borderRadius: 12,
        color: isSelected
            ? AppColors.primary
            : AppColors.getBackgroundColor(context),
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
}
