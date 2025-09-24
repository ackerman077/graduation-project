import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/constants.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF247CFF);
  static const Color mainBlue = Color(0xFF247CFF);

  static const Color lightBlue = Color(0xFFF4F8FF);
  static const Color darkBlue = Color(0xFF242424);

  static const Color gray = Color(0xFF757575);
  static const Color lightGray = Color(0xFFC2C2C2);
  static const Color lighterGray = Color(0xFFEDEDED);

  static const Color inputBorder = Color(0xFFE0E0E0);
  static const Color inputBackground = Colors.white;

  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);

  static const Color textPrimary = Color(0xFF242424);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFF9E9E9E);

  static const Color background = Colors.white;
  static const Color backgroundLight = Color(0xFFF8F9FA);
}

class ColorsManager {
  static const Color primaryBlue = AppColors.primaryBlue;
  static const Color mainBlue = AppColors.mainBlue;
  static const Color lightBlue = AppColors.lightBlue;
  static const Color darkBlue = AppColors.darkBlue;
  static const Color gray = AppColors.gray;
  static const Color lightGray = AppColors.lightGray;
  static const Color lighterGray = AppColors.lighterGray;
  static const Color inputBorder = AppColors.inputBorder;
  static const Color inputBackground = AppColors.inputBackground;
  static const Color success = AppColors.success;
  static const Color error = AppColors.error;
  static const Color warning = AppColors.warning;
  static const Color info = Color(0xFF2196F3);
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color textLight = AppColors.textLight;
  static const Color background = AppColors.background;
  static const Color backgroundLight = AppColors.backgroundLight;
}

class Fonts {
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
}

class FontWeightHelper {
  static const FontWeight light = Fonts.light;
  static const FontWeight regular = Fonts.regular;
  static const FontWeight medium = Fonts.medium;
  static const FontWeight semiBold = Fonts.semiBold;
  static const FontWeight bold = Fonts.bold;
}

class AppText {
  static TextStyle get h1 => TextStyle(
    fontSize: 24.sp,
    fontWeight: Fonts.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle get h2 => TextStyle(
    fontSize: 20.sp,
    fontWeight: Fonts.semiBold,
    color: AppColors.textPrimary,
  );

  static TextStyle get h3 => TextStyle(
    fontSize: 18.sp,
    fontWeight: Fonts.semiBold,
    color: AppColors.textPrimary,
  );

  static TextStyle get body => TextStyle(
    fontSize: 16.sp,
    fontWeight: Fonts.regular,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyMedium => TextStyle(
    fontSize: 14.sp,
    fontWeight: Fonts.regular,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodySmall => TextStyle(
    fontSize: 12.sp,
    fontWeight: Fonts.regular,
    color: AppColors.textSecondary,
  );

  static TextStyle get button => TextStyle(
    fontSize: 16.sp,
    fontWeight: Fonts.semiBold,
    color: Colors.white,
  );

  static TextStyle get link => TextStyle(
    fontSize: 14.sp,
    fontWeight: Fonts.medium,
    color: AppColors.primaryBlue,
    decoration: TextDecoration.underline,
  );
}

class TextStyles {
  static TextStyle get displayLarge => AppText.h1;
  static TextStyle get displayMedium => AppText.h1;
  static TextStyle get displaySmall => AppText.h2;
  static TextStyle get headingLarge => AppText.h1;
  static TextStyle get headingMedium => AppText.h2;
  static TextStyle get headingSmall => AppText.h3;
  static TextStyle get titleLarge => AppText.h2;
  static TextStyle get titleMedium => AppText.h3;
  static TextStyle get titleSmall => AppText.h3;
  static TextStyle get bodyLarge => AppText.body;
  static TextStyle get bodyMedium => AppText.bodyMedium;
  static TextStyle get bodySmall => AppText.bodySmall;
  static TextStyle get labelLarge => AppText.bodyMedium;
  static TextStyle get labelMedium => AppText.bodySmall;
  static TextStyle get labelSmall => AppText.bodySmall;
  static TextStyle get buttonLarge => AppText.button;
  static TextStyle get buttonMedium => AppText.button;
  static TextStyle get buttonSmall => AppText.button;
  static TextStyle get linkLarge => AppText.link;
  static TextStyle get linkMedium => AppText.link;
  static TextStyle get linkSmall => AppText.link;
  static TextStyle get caption => AppText.bodySmall;
  static TextStyle get overline => AppText.bodySmall;
  static TextStyle get authTitle => AppText.h1;
  static TextStyle get authSubtitle => AppText.bodyMedium;
  static TextStyle get inputLabel => AppText.bodySmall.copyWith(
    fontWeight: Fonts.medium,
    color: AppColors.textPrimary,
  );
  static TextStyle get inputText => AppText.bodyMedium;
  static TextStyle get inputHint =>
      AppText.bodyMedium.copyWith(color: AppColors.textLight);
  static TextStyle get inputError =>
      AppText.bodySmall.copyWith(color: AppColors.error);
}

class ButtonStyles {
  static ButtonStyle get primary => ElevatedButton.styleFrom(
    backgroundColor: ColorsManager.primaryBlue,
    foregroundColor: Colors.white,
    elevation: 0,
    shadowColor: Colors.transparent,
    minimumSize: Size(double.infinity, AppSizes.primaryButtonHeight.h),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.primaryButtonRadius.w),
    ),
    padding: EdgeInsets.symmetric(
      horizontal: AppSizes.spacingL.w,
      vertical: AppSizes.spacingM.h,
    ),
  );

  static ButtonStyle get outlined => OutlinedButton.styleFrom(
    foregroundColor: ColorsManager.primaryBlue,
    side: BorderSide(
      color: ColorsManager.inputBorder,
      width: AppSizes.inputFieldBorderWidth.toDouble(),
    ),
    minimumSize: Size(double.infinity, AppSizes.primaryButtonHeight.h),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.primaryButtonRadius.w),
    ),
    padding: EdgeInsets.symmetric(
      horizontal: AppSizes.spacingL.w,
      vertical: AppSizes.spacingM.h,
    ),
  );

  static ButtonStyle get text => TextButton.styleFrom(
    foregroundColor: ColorsManager.primaryBlue,
    minimumSize: Size(double.infinity, AppSizes.primaryButtonHeight.h),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.primaryButtonRadius.w),
    ),
    padding: EdgeInsets.symmetric(
      horizontal: AppSizes.spacingL.w,
      vertical: AppSizes.spacingM.h,
    ),
  );
}

class InputStyles {
  static InputDecoration get defaultInput => InputDecoration(
    filled: true,
    fillColor: ColorsManager.inputBackground,
    contentPadding: EdgeInsets.symmetric(
      horizontal: AppSizes.spacingM.w,
      vertical: AppSizes.spacingM.h,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius.w),
      borderSide: BorderSide(
        color: ColorsManager.inputBorder,
        width: AppSizes.inputFieldBorderWidth.toDouble(),
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius.w),
      borderSide: BorderSide(
        color: ColorsManager.inputBorder,
        width: AppSizes.inputFieldBorderWidth.toDouble(),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius.w),
      borderSide: const BorderSide(
        color: ColorsManager.primaryBlue,
        width: AppSizes.inputFieldBorderWidth + 1,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius.w),
      borderSide: BorderSide(
        color: ColorsManager.error,
        width: AppSizes.inputFieldBorderWidth.toDouble(),
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius.w),
      borderSide: const BorderSide(
        color: ColorsManager.error,
        width: AppSizes.inputFieldBorderWidth + 1,
      ),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius.w),
      borderSide: BorderSide(
        color: ColorsManager.lighterGray,
        width: AppSizes.inputFieldBorderWidth.toDouble(),
      ),
    ),
    hintStyle: TextStyles.inputHint,
    errorStyle: TextStyles.inputError,
    labelStyle: TextStyles.inputLabel,
    floatingLabelStyle: TextStyles.inputLabel.copyWith(
      color: ColorsManager.primaryBlue,
    ),
  );

  static InputDecoration inputWithHint(String hint) =>
      defaultInput.copyWith(hintText: hint);

  static TextStyle get textFieldStyle => TextStyles.inputText;
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      fontFamily: 'Poppins',

      primaryColor: ColorsManager.primaryBlue,
      scaffoldBackgroundColor: ColorsManager.background,
      cardColor: ColorsManager.backgroundLight,

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: ColorsManager.textPrimary),
        titleTextStyle: TextStyles.titleMedium.copyWith(
          color: ColorsManager.textPrimary,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(style: ButtonStyles.primary),

      textButtonTheme: TextButtonThemeData(style: ButtonStyles.text),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyles.outlined,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ColorsManager.inputBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ColorsManager.inputBorder,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ColorsManager.inputBorder,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ColorsManager.primaryBlue,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorsManager.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorsManager.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ColorsManager.lighterGray,
            width: 1,
          ),
        ),
        hintStyle: TextStyles.inputHint,
        errorStyle: TextStyles.inputError,
        labelStyle: TextStyles.inputLabel,
        floatingLabelStyle: TextStyles.inputLabel.copyWith(
          color: ColorsManager.primaryBlue,
        ),
      ),

      cardTheme: CardThemeData(
        color: ColorsManager.backgroundLight,
        elevation: 2,
        shadowColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: ColorsManager.backgroundLight,
        selectedItemColor: ColorsManager.primaryBlue,
        unselectedItemColor: ColorsManager.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      dividerTheme: const DividerThemeData(
        color: ColorsManager.lighterGray,
        thickness: 1,
        space: 1,
      ),

      iconTheme: const IconThemeData(
        color: ColorsManager.textPrimary,
        size: 24,
      ),

      textTheme: TextTheme(
        displayLarge: TextStyles.displayLarge,
        displayMedium: TextStyles.displayMedium,
        displaySmall: TextStyles.displaySmall,
        headlineLarge: TextStyles.headingLarge,
        headlineMedium: TextStyles.headingMedium,
        headlineSmall: TextStyles.headingSmall,
        titleLarge: TextStyles.titleLarge,
        titleMedium: TextStyles.titleMedium,
        titleSmall: TextStyles.titleSmall,
        bodyLarge: TextStyles.bodyLarge,
        bodyMedium: TextStyles.bodyMedium,
        bodySmall: TextStyles.bodySmall,
        labelLarge: TextStyles.labelLarge,
        labelMedium: TextStyles.labelMedium,
        labelSmall: TextStyles.labelSmall,
      ),

      colorScheme: const ColorScheme.light(
        primary: ColorsManager.primaryBlue,
        secondary: ColorsManager.lightBlue,
        surface: ColorsManager.backgroundLight,
        surfaceTint: ColorsManager.backgroundLight,
        error: ColorsManager.error,
        onPrimary: Colors.white,
        onSecondary: ColorsManager.textPrimary,
        onSurface: ColorsManager.textPrimary,
        onError: Colors.white,
      ),
    );
  }

  static ThemeData get darkTheme => lightTheme;
}
