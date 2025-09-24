import 'package:appointly/core/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../di/dependency_injection.dart';
import '../../features/home/cubit/home_cubit.dart';

import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';

import '../../features/home/ui/screens/home_screen.dart';
import '../../features/profile/ui/screens/profile_screen.dart';
import '../../features/profile/ui/screens/personal_info_screen.dart';
import '../../features/profile/ui/screens/about_screen.dart';
import '../../features/doctors/ui/screens/doctors_screen.dart';
import '../../features/doctors/ui/screens/doctor_detail_screen.dart';

import '../../features/appointments/ui/screens/appointments_screen.dart';
import '../../features/appointments/ui/screens/booking_appointment_screen.dart';
import '../../features/appointments/cubit/appointments_cubit.dart';

import '../models/doctor.dart';

import '../../features/specializations/cubit/specializations_cubit.dart';

import '../../features/specializations/ui/screens/specializations_list_screen.dart';
import '../../features/specializations/ui/screens/doctors_by_specialization_screen.dart';

class AppRouter {
  Route generateRoute(RouteSettings settings) {

    switch (settings.name) {
      case Routes.onBoardingScreen:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case Routes.loginScreen:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case Routes.signupScreen:
        return MaterialPageRoute(builder: (_) => const SignupScreen());

      case Routes.homeScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<HomeCubit>(
            create: (context) => DependencyInjection.get<HomeCubit>(),
            child: const HomeScreen(),
          ),
        );
      case Routes.profileScreen:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case Routes.personalInfoScreen:
        return MaterialPageRoute(builder: (_) => const PersonalInfoScreen());
      case Routes.doctorsScreen:
        return MaterialPageRoute(builder: (_) => const DoctorsScreen());
      case Routes.specializationsListScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<SpecializationsCubit>(
            create: (context) =>
                DependencyInjection.get<SpecializationsCubit>(),
            child: const SpecializationsListScreen(),
          ),
        );
      case Routes.doctorsBySpecializationScreen:
        final specializationId = settings.arguments as int?;
        if (specializationId == null) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(
                child: Text('Specialization information not available'),
              ),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) =>
              DoctorsBySpecializationScreen(specializationId: specializationId),
        );
      case Routes.doctorDetailScreen:
        final doctor = settings.arguments as Doctor?;
        if (doctor == null) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Doctor information not available')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => DoctorDetailScreen(doctor: doctor),
        );

      case Routes.appointmentsScreen:
        return MaterialPageRoute(builder: (_) => const AppointmentsScreen());
      case Routes.aboutScreen:
        return MaterialPageRoute(builder: (_) => const AboutScreen());
      case Routes.bookingScreen:
        final doctor = settings.arguments as Doctor?;
        if (doctor == null) {
          return MaterialPageRoute(
            builder: (context) => const Scaffold(
              body: Center(child: Text('Doctor information not found')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (context) => BlocProvider<AppointmentsCubit>(
            create: (context) => DependencyInjection.get<AppointmentsCubit>(),
            child: BookingAppointmentScreen(doctor: doctor),
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
