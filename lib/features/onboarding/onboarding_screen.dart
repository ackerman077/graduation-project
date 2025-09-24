import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theming/app_theme.dart';
import '../../core/routing/routes.dart';
import '../../core/constants/constants.dart';
import 'cubit/onboarding_cubit.dart';
import 'widgets/onboarding_page.dart';
import 'widgets/onboarding_indicator.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingCubit(),
      child: const _OnboardingScreenContent(),
    );
  }
}

class _OnboardingScreenContent extends StatefulWidget {
  const _OnboardingScreenContent();

  @override
  State<_OnboardingScreenContent> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<_OnboardingScreenContent> {
  final PageController _pageController = PageController();

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Find Your Doctor',
      'subtitle': 'Browse Top Specialists',
      'description':
          'Discover the best doctors in your area and book appointments with ease. Find specialists for any health concern.',
    },
    {
      'title': 'Easy Booking',
      'subtitle': 'Book in Seconds',
      'description':
          'Book appointments with just a few taps. No more waiting on hold or long phone calls. Quick and convenient.',
    },
    {
      'title': 'Get Started',
      'subtitle': 'Your Health Journey Begins',
      'description':
          'Join thousands of patients who trust us with their healthcare needs. Start your wellness journey today.',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    context.read<OnboardingCubit>().updateCurrentPage(page);
  }

  void _nextPage() {
    final cubit = context.read<OnboardingCubit>();
    if (cubit.state.currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppSizes.animNormal,
        curve: Curves.easeInOut,
      );
    } else {
      _showAuthChooser();
    }
  }

  void _showAuthChooser() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.w),
            topRight: Radius.circular(24.w),
          ),
        ),
        padding: EdgeInsets.only(
          left: AppSizes.spacingL.w,
          right: AppSizes.spacingL.w,
          bottom: AppSizes.spacingL.w,
          top: 16.h,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.lighterGray,
                  borderRadius: BorderRadius.circular(2.w),
                ),
              ),
              SizedBox(height: 24.h),

              Text(
                'Get Started',
                style: AppText.h1.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 12.h),

              Text(
                'Choose how you want to start your journey',
                style: AppText.body.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),

              Container(
                width: double.infinity,
                height: 56.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryBlue,
                      AppColors.primaryBlue.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.w),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(
                        context,
                        Routes.loginScreen,
                      );
                    },
                    borderRadius: BorderRadius.circular(16.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login, color: Colors.white, size: 20.w),
                        SizedBox(width: 8.w),
                        Text(
                          'Sign In',
                          style: AppText.button.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              Container(
                width: double.infinity,
                height: 56.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.w),
                  border: Border.all(
                    color: AppColors.primaryBlue.withValues(alpha: 0.2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(
                        context,
                        Routes.signupScreen,
                      );
                    },
                    borderRadius: BorderRadius.circular(16.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_add,
                          color: AppColors.primaryBlue,
                          size: 20.w,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Sign Up',
                          style: AppText.button.copyWith(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: MediaQuery.of(context).padding.bottom + 16.h),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App'),
            content: const Text('Are you sure you want to exit the app?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Exit'),
              ),
            ],
          ),
        );

        if (shouldExit ?? false) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(
                  left: AppSizes.spacingL.w,
                  right: AppSizes.spacingL.w,
                  top: AppSizes.spacingL.w,
                  bottom: 8.h,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _showAuthChooser,
                        borderRadius: BorderRadius.circular(8.w),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                          child: Text(
                            'Skip',
                            style: AppText.body.copyWith(
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return OnboardingPage(
                      title: page['title'] ?? '',
                      subtitle: page['subtitle'] ?? '',
                      description: page['description'] ?? '',
                      color: AppColors.primaryBlue,
                    );
                  },
                ),
              ),

              Container(
                padding: EdgeInsets.only(
                  left: AppSizes.spacingL.w,
                  right: AppSizes.spacingL.w,
                  bottom: AppSizes.spacingL.w,
                  top: 8.h,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BlocBuilder<OnboardingCubit, OnboardingState>(
                      builder: (context, state) {
                        return OnboardingIndicator(
                          currentPage: state.currentPage,
                          totalPages: _pages.length,
                        );
                      },
                    ),

                    SizedBox(height: AppSizes.spacingL.h),
                    BlocBuilder<OnboardingCubit, OnboardingState>(
                      builder: (context, state) {
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _nextPage,
                            borderRadius: BorderRadius.circular(16.w),
                            child: Container(
                              width: double.infinity,
                              height: 56.h,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primaryBlue,
                                    AppColors.primaryBlue.withValues(
                                      alpha: 0.8,
                                    ),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16.w),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryBlue.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  state.currentPage == _pages.length - 1
                                      ? 'Get Started'
                                      : 'Next',
                                  style: AppText.button.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
