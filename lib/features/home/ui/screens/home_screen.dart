import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import '../../../../core/theming/app_theme.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/specialty_icon.dart';
import '../../../../core/widgets/doctor_image_widget.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/services/profile_picture_service.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/routing/routes.dart';
import '../../cubit/home_cubit.dart';
import '../../../../core/models/specialization.dart';
import '../../../../core/models/doctor.dart';
import '../widgets/bottom_navigation.dart';
import '../../../specializations/cubit/specializations_cubit.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  late final ProfilePictureService _profilePictureService;
  File? _currentProfilePicture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _profilePictureService = DependencyInjection.get<ProfilePictureService>();
    _currentProfilePicture = _profilePictureService.profilePicture;
    LoggerService.debug(
      'Home screen - Initial profile picture: ${_currentProfilePicture?.path}',
    );
    LoggerService.debug(
      'Home screen - Profile picture exists: ${_currentProfilePicture?.existsSync()}',
    );
    _profilePictureService.addListener(_onProfilePictureChanged);
    LoggerService.debug(
      'Home screen - Listener added to ProfilePictureService',
    );

    _testProfilePictureService();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeCubit>().loadHomeData();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      setState(() {
        _currentIndex = 0;
      });
      _refreshProfilePicture();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      _currentIndex = 0;
    });

    _refreshProfilePicture();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _refreshProfilePicture();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _profilePictureService.removeListener(_onProfilePictureChanged);
    super.dispose();
  }

  void _onProfilePictureChanged(File? imageFile) {
    LoggerService.debug(
      'Home screen - Profile picture changed: ${imageFile?.path}',
    );
    if (mounted) {
      setState(() {
        _currentProfilePicture = imageFile;
      });
      LoggerService.debug('Home screen - Profile picture updated in state');
    } else {
      LoggerService.debug('Home screen - Widget not mounted, skipping update');
    }
  }

  void _refreshProfilePicture() {
    final currentPicture = _profilePictureService.profilePicture;
    LoggerService.debug(
      'Home screen - Refreshing profile picture: ${currentPicture?.path}',
    );
    LoggerService.debug(
      'Home screen - Current picture exists: ${currentPicture?.existsSync()}',
    );
    if (mounted) {
      setState(() {
        _currentProfilePicture = currentPicture;
      });
    }
  }

  void _testProfilePictureService() {
    LoggerService.debug('Home screen - Testing ProfilePictureService');
    LoggerService.debug(
      'Home screen - Service instance: ${_profilePictureService.hashCode}',
    );
    LoggerService.debug(
      'Home screen - Current picture: ${_profilePictureService.profilePicture?.path}',
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: ColorsManager.primaryBlue.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.person, size: 24.w, color: ColorsManager.primaryBlue),
    );
  }

  void _handleNavigation(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushNamed(context, Routes.doctorsScreen);
        break;
      case 2:
        Navigator.pushNamed(context, Routes.appointmentsScreen);
        break;
      case 3:
        Navigator.pushNamed(context, Routes.profileScreen);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _currentIndex = 0;
        });
      });
    }

    return BlocProvider<SpecializationsCubit>(
      create: (context) => DependencyInjection.get<SpecializationsCubit>(),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.grey[50]!, Colors.grey[100]!],
              stops: const [0.0, 0.4, 1.0],
            ),
          ),
          child: SafeArea(
            child: BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) {
                if (state is HomeLoading) {
                  return _buildLoadingState();
                }

                if (state is HomeError) {
                  return Center(
                    child: AppErrorWidget(
                      title: 'Error Loading Home Data',
                      errorMessage: state.message,
                      onRetry: () => context.read<HomeCubit>().loadHomeData(),
                      showRetryButton: true,
                    ),
                  );
                }

                if (state is HomeOffline) {
                  return RefreshIndicator(
                    onRefresh: () => context.read<HomeCubit>().loadHomeData(),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildOfflineBanner(),
                          _buildHeader(),
                          _buildBlueBannerCard(),
                          _buildDoctorSpecialties(),
                          _buildRecommendedDoctors(),
                        ],
                      ),
                    ),
                  );
                }

                if (state is HomeLoaded) {
                  return RefreshIndicator(
                    onRefresh: () => context.read<HomeCubit>().loadHomeData(),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 16),
                          _buildBlueBannerCard(),
                          const SizedBox(height: 20),
                          _buildDoctorSpecialties(),
                          const SizedBox(height: 20),
                          _buildRecommendedDoctors(),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => context.read<HomeCubit>().loadHomeData(),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 16),
                        _buildBlueBannerCard(),
                        const SizedBox(height: 20),
                        _buildDoctorSpecialties(),
                        const SizedBox(height: 20),
                        _buildRecommendedDoctors(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigation(
          currentIndex: _currentIndex,
          onTap: _handleNavigation,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: ColorsManager.primaryBlue),
          SizedBox(height: 16),
          Text(
            'Loading...',
            style: TextStyle(fontSize: 16, color: ColorsManager.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(8.w),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off, color: Colors.orange.shade700, size: 20.w),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              "You're offline. Check your internet connection.",
              style: TextStyle(
                color: Colors.orange.shade700,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, authState) {
                    String userName = '';
                    if (authState is AuthSuccess) {
                      userName = authState.user.name;
                    }

                    final greeting = userName.isNotEmpty
                        ? 'Hi, $userName 👋'
                        : 'Hi, Welcome 👋';

                    return Text(
                      greeting,
                      style: TextStyles.authTitle.copyWith(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: ColorsManager.textPrimary,
                      ),
                    );
                  },
                ),
                SizedBox(height: 4.h),
                Text(
                  'How are you feeling today?',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: ColorsManager.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, Routes.profileScreen);
            },
            child: Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Colors.grey[50]!],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: ColorsManager.primaryBlue.withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: ColorsManager.primaryBlue.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ClipOval(
                child:
                    _currentProfilePicture != null &&
                        _currentProfilePicture!.existsSync()
                    ? Image.file(
                        _currentProfilePicture!,
                        width: 48.w,
                        height: 48.w,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          LoggerService.error(
                            'Error loading profile picture: $error',
                          );
                          return _buildDefaultAvatar();
                        },
                      )
                    : _buildDefaultAvatar(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlueBannerCard() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, Routes.doctorsScreen);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        height: 220.h,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: double.infinity,
              height: 180.h,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.w),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ColorsManager.primaryBlue,
                    ColorsManager.primaryBlue.withValues(alpha: 0.9),
                    ColorsManager.primaryBlue.withValues(alpha: 0.7),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
                image: const DecorationImage(
                  image: AssetImage('assets/images/home_blue_pattern.png'),
                  fit: BoxFit.cover,
                  opacity: 0.3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ColorsManager.primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Book and\nschedule with\nnearest doctor',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Colors.white, Colors.grey[50]!],
                            ),
                            borderRadius: BorderRadius.circular(25.w),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'Book Now',
                            style: TextStyle(
                              color: ColorsManager.primaryBlue,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 80.w),
                ],
              ),
            ),

            Positioned(
              right: 16.w,
              bottom: 40.h,
              child: Container(
                width: 180.w,
                height: 240.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.w),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.w),
                  child: Image.asset(
                    'assets/images/doctor_banner.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorSpecialties() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Doctor Specialties',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: ColorsManager.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  Routes.specializationsListScreen,
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: ColorsManager.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          BlocBuilder<SpecializationsCubit, SpecializationsState>(
            builder: (context, state) {
              if (state is SpecializationsLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: ColorsManager.primaryBlue,
                  ),
                );
              }

              if (state is SpecializationsError) {
                return Center(
                  child: Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: ColorsManager.error),
                  ),
                );
              }

              if (state is SpecializationsLoaded) {
                final specializations = state.specializations.take(4).toList();
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: 8.w,
                    mainAxisSpacing: 8.h,
                  ),
                  itemCount: specializations.length,
                  itemBuilder: (context, index) {
                    final specialty = specializations[index];
                    return _buildSpecialtyCard(specialty);
                  },
                );
              }

              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.read<SpecializationsCubit>().loadSpecializations();
              });

              return const Center(
                child: CircularProgressIndicator(
                  color: ColorsManager.primaryBlue,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialtyCard(Specialization specialty) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.doctorsBySpecializationScreen,
          arguments: specialty.id,
        );
      },
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: const BoxDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.w),
                border: Border.all(
                  color: ColorsManager.primaryBlue.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ColorsManager.primaryBlue.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: SpecialtyIcon(specialtyName: specialty.name, size: 32.w),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              specialty.name,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: ColorsManager.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedDoctors() {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        List<Doctor> recommendedDoctors = [];

        if (state is HomeLoaded) {
          recommendedDoctors = state.recommendedDoctors;
        } else if (state is HomeOffline) {
          recommendedDoctors = state.recommendedDoctors;
        }

        if (recommendedDoctors.isNotEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Recommended Doctors',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: ColorsManager.textPrimary,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, Routes.doctorsScreen),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          color: ColorsManager.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  height: 220.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: recommendedDoctors.length,
                    itemBuilder: (context, index) {
                      final doctor = recommendedDoctors[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            Routes.doctorDetailScreen,
                            arguments: doctor,
                          );
                        },
                        child: Container(
                          width: 160.w,
                          margin: EdgeInsets.only(right: 12.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.w),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 95.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(12.w),
                                  ),
                                  color: ColorsManager.lightBlue,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(12.w),
                                  ),
                                  child: DoctorImageWidget(
                                    networkImageUrl: doctor.image,
                                    doctorId: doctor.id,
                                    width: double.infinity,
                                    height: 95.h,
                                    fit: BoxFit.cover,
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(12.w),
                                    ),
                                    errorWidget: _buildDefaultDoctorIcon(),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(
                                  10.w,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      doctor.name,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w700,
                                        color: ColorsManager.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (doctor.specialization != null) ...[
                                      SizedBox(height: 3.h),
                                      Text(
                                        doctor.specialization!.name,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: ColorsManager.primaryBlue,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                    SizedBox(height: 4.h),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        if (doctor.rating != null &&
                                            doctor.rating! > 0)
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.star,
                                                size: 12.w,
                                                color: Colors.amber,
                                              ),
                                              SizedBox(width: 4.w),
                                              Text(
                                                doctor.rating!.toStringAsFixed(
                                                  1,
                                                ),
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: ColorsManager
                                                      .textSecondary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),

                                        if (doctor.appointPrice != null)
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8.w,
                                              vertical: 4.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: ColorsManager.primaryBlue
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12.w),
                                              border: Border.all(
                                                color: ColorsManager.primaryBlue
                                                    .withValues(alpha: 0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              '\$${doctor.appointPrice!.toStringAsFixed(0)}',
                                              style: TextStyle(
                                                fontSize: 11.sp,
                                                color:
                                                    ColorsManager.primaryBlue,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }

        if (state is HomeLoading) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommended Doctors',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: ColorsManager.textPrimary,
                  ),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  height: 200.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 160.w,
                        margin: EdgeInsets.only(right: 12.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.w),
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 100.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(12.w),
                                ),
                                color: ColorsManager.lightBlue,
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: ColorsManager.primaryBlue,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(12.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 16.h,
                                      width: 80.w,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(
                                          4.w,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Container(
                                      height: 12.h,
                                      width: 60.w,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(
                                          4.w,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDefaultDoctorIcon() {
    return Center(
      child: Icon(Icons.person, size: 40.w, color: ColorsManager.primaryBlue),
    );
  }
}
