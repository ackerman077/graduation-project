import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/routing/app_router.dart';
import 'core/theming/app_theme.dart';

import 'core/di/dependency_injection.dart';
import 'core/config/environment_config.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/data_storage_service.dart';
import 'core/routing/routes.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/home/cubit/home_cubit.dart';
import 'features/doctors/cubit/doctors_cubit.dart';
import 'features/specializations/cubit/specializations_cubit.dart';
import 'features/profile/cubit/profile_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  DependencyInjection.setup();

  await DependencyInjection.setupAsync();

  await ConnectivityService().initialize();

  await DataStorageService.clearAllData();

  runApp(const AppointlyApp());
}

class AppointlyApp extends StatelessWidget {
  const AppointlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => DependencyInjection.get<AuthCubit>(),
        ),
        BlocProvider<HomeCubit>(
          create: (context) => DependencyInjection.get<HomeCubit>(),
        ),
        BlocProvider<DoctorsCubit>(
          create: (context) => DependencyInjection.get<DoctorsCubit>(),
        ),
        BlocProvider<SpecializationsCubit>(
          create: (context) => DependencyInjection.get<SpecializationsCubit>(),
        ),
        BlocProvider<ProfileCubit>(
          create: (context) => DependencyInjection.get<ProfileCubit>(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: false,
        builder: (context, child) {
          return MaterialApp(
            title: EnvironmentConfig.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            onGenerateRoute: AppRouter().generateRoute,
            home: const AuthCheckScreen(),
            color: Colors.white,
          );
        },
      ),
    );
  }
}

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    if (mounted) {
      final authCubit = context.read<AuthCubit>();
      await authCubit.checkAuthStatus();
    }

    if (mounted) {
      // Small delay helps keep background white during transition
      await Future.delayed(const Duration(milliseconds: 200));
      _navigateToNextScreen();
    }
  }

  void _navigateToNextScreen() {
    final authCubit = context.read<AuthCubit>();
    final currentState = authCubit.state;

    if (currentState is AuthSuccess) {
      Navigator.pushReplacementNamed(context, Routes.homeScreen);
    } else {
      Navigator.pushReplacementNamed(context, Routes.onBoardingScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keep white to avoid a black flash between splash and first screen
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.shrink(),
    );
  }
}
