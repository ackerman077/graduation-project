class Routes {
  static const String onBoardingScreen = '/onBoardingScreen';
  static const String loginScreen = '/loginScreen';
  static const String signupScreen = '/signupScreen';

  static const String personalInfoScreen = '/personalInfoScreen';
  static const String homeScreen = '/homeScreen';
  static const String profileScreen = '/profileScreen';
  static const String doctorsScreen = '/doctorsScreen';
  static const String doctorDetailScreen = '/doctorDetailScreen';
  static const String specializationsListScreen = '/specializationsListScreen';
  static const String doctorsBySpecializationScreen =
      '/doctorsBySpecializationScreen';

  static const String appointmentsScreen = '/appointmentsScreen';
  static const String bookingScreen = '/bookingScreen';
  static const String aboutScreen = '/aboutScreen';

  static const List<String> authRoutes = [
    onBoardingScreen,
    loginScreen,
    signupScreen,
  ];

  static const List<String> mainAppRoutes = [
    homeScreen,
    profileScreen,
    personalInfoScreen,
    doctorsScreen,
    doctorDetailScreen,
    specializationsListScreen,
    doctorsBySpecializationScreen,
    appointmentsScreen,
    bookingScreen,
    aboutScreen,
  ];
}
