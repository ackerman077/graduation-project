class AppSizes {
  static const int screenPaddingHorizontal = 16;
  static const int screenPaddingVertical = 20;
  static const int sectionSpacing = 24;
  static const int spacingS = 8;
  static const int spacingM = 16;
  static const int spacingL = 24;
  static const int spacingXL = 32;

  static const int inputFieldHeight = 52;
  static const int inputFieldRadius = 12;
  static const int inputFieldBorderWidth = 1;
  static const int primaryButtonHeight = 48;
  static const int primaryButtonRadius = 12;

  static const int iconSmall = 16;
  static const int iconMedium = 24;
  static const int iconLarge = 32;
  static const int socialButtonSize = 44;

  static const int avatarSmall = 40;
  static const int avatarMedium = 56;
  static const int avatarLarge = 96;
  static const int otpWidth = 44;
  static const int otpHeight = 56;
  static const int otpRadius = 12;

  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);
  static const Duration splashTime = Duration(milliseconds: 1500);
}

class AppSettings {
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration apiRetryDelay = Duration(seconds: 2);
  static const int passwordMinLength = 8;
  static const int phoneMinLength = 10;
  static const int nameMinLength = 3;

  static const List<String> supportedSocialProviders = [
    'google',
    'facebook',
    'apple',
  ];
}

class AppConstants {
  static int get screenPaddingHorizontal => AppSizes.screenPaddingHorizontal;
  static int get screenPaddingVertical => AppSizes.screenPaddingVertical;
  static int get sectionSpacing => AppSizes.sectionSpacing;
  static int get spacingS => AppSizes.spacingS;
  static int get spacingM => AppSizes.spacingM;
  static int get spacingL => AppSizes.spacingL;
  static int get spacingXL => AppSizes.spacingXL;
  static int get spacingXXL => 48;

  static int get inputFieldHeight => AppSizes.inputFieldHeight;
  static int get inputFieldRadius => AppSizes.inputFieldRadius;
  static int get inputFieldBorderWidth => AppSizes.inputFieldBorderWidth;
  static int get primaryButtonHeight => AppSizes.primaryButtonHeight;
  static int get primaryButtonRadius => AppSizes.primaryButtonRadius;

  static int get iconSizeSmall => AppSizes.iconSmall;
  static int get iconSizeMedium => AppSizes.iconMedium;
  static int get iconSizeLarge => AppSizes.iconLarge;
  static int get socialButtonSize => AppSizes.socialButtonSize;

  static int get avatarSizeSmall => AppSizes.avatarSmall;
  static int get avatarSizeMedium => AppSizes.avatarMedium;
  static int get avatarSizeLarge => AppSizes.avatarLarge;
  static int get otpInputWidth => AppSizes.otpWidth;
  static int get otpInputHeight => AppSizes.otpHeight;
  static int get otpInputRadius => AppSizes.otpRadius;

  static Duration get animationDurationFast => AppSizes.animFast;
  static Duration get animationDurationNormal => AppSizes.animNormal;
  static Duration get animationDurationSlow => AppSizes.animSlow;
  static Duration get splashDuration => AppSizes.splashTime;

  static Duration get apiTimeout => AppSettings.apiTimeout;
  static Duration get apiRetryDelay => AppSettings.apiRetryDelay;
  static int get passwordMinLength => AppSettings.passwordMinLength;
  static int get phoneMinLength => AppSettings.phoneMinLength;
  static int get nameMinLength => AppSettings.nameMinLength;
}
