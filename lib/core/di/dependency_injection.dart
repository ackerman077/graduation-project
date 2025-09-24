import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../networking/api_service_interface.dart';
import '../networking/api_service_impl.dart';
import '../networking/dio_config.dart';
import '../services/profile_picture_service.dart';

import '../../features/doctors/data/repositories/doctors_repository.dart';
import '../../features/specializations/data/repositories/specializations_repository.dart';
import '../../features/appointments/data/repositories/appointments_repository.dart';
import '../../features/home/data/repositories/home_repository.dart';
import '../../features/auth/data/repositories/auth_repository.dart'
    show AuthRepository, AuthRepositoryImpl;
import '../../features/profile/data/repositories/profile_repository.dart';

import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/home/cubit/home_cubit.dart';
import '../../features/doctors/cubit/doctors_cubit.dart';
import '../../features/specializations/cubit/specializations_cubit.dart';
import '../../features/appointments/cubit/appointments_cubit.dart';
import '../../features/onboarding/cubit/onboarding_cubit.dart';
import '../../features/profile/cubit/profile_cubit.dart';

final GetIt getIt = GetIt.instance;

class DependencyInjection {
  static void setup() {
    getIt.registerLazySingleton<Dio>(DioConfig.createDio);

    getIt.registerLazySingleton<ApiServiceInterface>(
      () => ApiServiceImpl(getIt<Dio>()),
    );

    getIt.registerLazySingleton<DoctorsRepository>(
      () => DoctorsRepositoryImpl(getIt<ApiServiceInterface>()),
    );
    getIt.registerLazySingleton<SpecializationsRepository>(
      () => SpecializationsRepositoryImpl(getIt<ApiServiceInterface>()),
    );

    getIt.registerLazySingleton<AppointmentsRepository>(
      () => AppointmentsRepositoryImpl(getIt<ApiServiceInterface>()),
    );
    getIt.registerLazySingleton<HomeRepository>(
      () => HomeRepositoryImpl(getIt<ApiServiceInterface>()),
    );
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(getIt<ApiServiceInterface>()),
    );
    getIt.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(getIt<ApiServiceInterface>()),
    );

    getIt.registerLazySingleton<AuthCubit>(
      () => AuthCubit(getIt<AuthRepository>(), getIt<ProfilePictureService>()),
    );

    getIt.registerLazySingleton<HomeCubit>(
      () => HomeCubit(getIt<HomeRepository>()),
    );

    getIt.registerLazySingleton<DoctorsCubit>(
      () => DoctorsCubit(getIt<DoctorsRepository>()),
    );

    getIt.registerLazySingleton<SpecializationsCubit>(
      () => SpecializationsCubit(getIt<SpecializationsRepository>()),
    );
    getIt.registerFactory<AppointmentsCubit>(
      () => AppointmentsCubit(getIt<AppointmentsRepository>()),
    );

    getIt.registerLazySingleton<ProfileCubit>(
      () => ProfileCubit(getIt<ProfileRepository>(), getIt<AuthCubit>()),
    );

    getIt.registerLazySingleton<ProfilePictureService>(
      ProfilePictureService.new,
    );

    getIt.registerFactory<OnboardingCubit>(OnboardingCubit.new);
  }

  static Future<void> setupAsync() async {}

  static void dispose() {
    getIt.reset();
  }

  static T get<T extends Object>() => getIt<T>();

  static bool isRegistered<T extends Object>() => getIt.isRegistered<T>();
}
