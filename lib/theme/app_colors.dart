import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF8B6F5C); // --capy-brown
  static const Color primaryLight = Color(0xFFC4A989); // --capy-light
  static const Color primaryDark = Color(0xFF5D4E37); // Darker shade of brown

  static const Color secondary = Color(0xFFC4A989); // --secondary
  static const Color accentMint = Color(0xFF7EB8A2); // --mint-green (Vibrant)
  static const Color accentOrange = Color(
    0xFFE8A87C,
  ); // --warm-orange (Vibrant)
  static const Color accentPink = Color(0xFFFFB7B2); // --soft-pink (Solid)
  static const Color accentPurple = Color(0xFFB39EB5); // --soft-purple (Solid)
  static const Color accentBlue = Color(0xFF6B9ED8); // 蓝色
  static const Color accentYellow = Color(0xFFF5D76E); // 黄色
  static const Color accentGreen = Color(0xFF7EB8A2); // 绿色（同 accentMint）

  // Light Mode Colors
  static const Color background = Color(0xFFFDFBF6); // --cream-background
  static const Color card = Colors.white; // --card
  static const Color inputFill = Colors.white;
  static const Color textMain = Color(0xFF3D3D3D); // --foreground
  static const Color textMuted = Color(0xFF6B6B6B); // --muted-foreground
  static const Color border = Color(0xFF5D4E37); // Dark brown
  static const Color divider = Color(0xFFE5E5E5);

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF1A1614);
  static const Color darkCard = Color(0xFF26211E);
  static const Color darkInputFill = Color(0xFF26211E);
  static const Color darkTextMain = Color(0xFFF5EFE6);
  static const Color darkTextMuted = Color(0xFFA89F96);
  static const Color darkBorder = Color(0xFF8B6F5C);
  static const Color darkDivider = Color(0xFF3D3631);

  static Color getBackgroundColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkBackground
      : background;

  static Color getCardColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkCard : card;

  static Color getTextMainColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTextMain : textMain;

  static Color getTextMutedColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkTextMuted
      : textMuted;

  static Color getBorderColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkBorder : border;
}
