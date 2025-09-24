import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theming/app_theme.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/widgets/custom_buttons.dart';
import '../../../../core/services/logger_service.dart';
import '../cubit/auth_cubit.dart';
import '../../data/models/login_request.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authCubit = context.read<AuthCubit>();
    await authCubit.login(
      LoginRequest(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  void _navigateToSignup() {
    Navigator.pushNamed(context, Routes.signupScreen);
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
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primaryBlue.withValues(alpha: 0.05),
                AppColors.background,
                AppColors.backgroundLight,
              ],
              stops: const [0.0, 0.3, 1.0],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.screenPaddingHorizontal.w,
                vertical: AppConstants.screenPaddingVertical.h,
              ),
              child: BlocListener<AuthCubit, AuthState>(
                listener: (context, state) {
                  if (state is AuthSuccess) {
                    Navigator.pushReplacementNamed(context, Routes.homeScreen);
                  } else if (state is AuthFailure ||
                      state is AuthUnauthorized) {
                    String errorMessage;
                    int? errorCode;

                    if (state is AuthUnauthorized) {
                      errorMessage = state.message;
                      errorCode = 401;
                    } else if (state is AuthFailure) {
                      errorMessage = state.message;
                      errorCode = state.code;
                    } else {
                      errorMessage = 'An error occurred';
                      errorCode = null;
                    }

                    LoggerService.logAuth('Login Error Displayed', {
                      'errorCode': errorCode,
                      'errorMessage': errorMessage,
                      'stateType': state.runtimeType.toString(),
                    });

                    if (state is AuthUnauthorized) {
                      errorMessage =
                          'Invalid email or password. Please check your credentials.';
                    }
                    else if (errorMessage.isEmpty ||
                        errorMessage.contains('Network error')) {
                      if (errorCode == 401) {
                        errorMessage =
                            'Invalid email or password. Please check your credentials.';
                      } else if (errorCode == 422) {
                        errorMessage =
                            'Invalid input. Please check your information and try again.';
                      } else if (errorCode == 500) {
                        errorMessage = 'Server error. Please try again later.';
                      }
                    }

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            errorMessage,
                            style: AppText.body.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          backgroundColor: AppColors.error,
                          duration: const Duration(seconds: 4),
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.all(16.w),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.w),
                          ),
                          action: SnackBarAction(
                            label: 'OK',
                            textColor: Colors.white,
                            onPressed: () {
                              ScaffoldMessenger.of(
                                context,
                              ).hideCurrentSnackBar();
                            },
                          ),
                        ),
                      );
                    }
                  }
                },
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 20.h),

                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 60.w,
                              height: 60.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.primaryBlue,
                                    AppColors.primaryBlue.withValues(
                                      alpha: 0.8,
                                    ),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryBlue.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.medical_services_rounded,
                                size: 30.w,
                                color: Colors.white,
                              ),
                            ),

                            SizedBox(height: 16.h),

                            Text(
                              'Welcome Back',
                              style: AppText.h2.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: 8.h),

                            Text(
                              'We\'re excited to have you back, can\'t wait to see what you\'ve been up to since you last logged in.',
                              style: AppText.body.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w400,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 32.h),

                      Container(
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.w),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email Address',
                              style: AppText.body.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            TextFormField(
                              controller: _emailController,
                              decoration:
                                  InputStyles.inputWithHint(
                                    'Enter your email',
                                  ).copyWith(
                                    prefixIcon: Icon(
                                      Icons.email_outlined,
                                      color: AppColors.textLight,
                                      size: 20.w,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 14.h,
                                    ),
                                  ),
                              style: InputStyles.textFieldStyle,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                ).hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20.h),

                            Text(
                              'Password',
                              style: AppText.body.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            TextFormField(
                              controller: _passwordController,
                              decoration:
                                  InputStyles.inputWithHint(
                                    'Enter your password',
                                  ).copyWith(
                                    prefixIcon: Icon(
                                      Icons.lock_outline,
                                      color: AppColors.textLight,
                                      size: 20.w,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isObscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: AppColors.textLight,
                                        size: 20.w,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isObscurePassword =
                                              !_isObscurePassword;
                                        });
                                      },
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 14.h,
                                    ),
                                  ),
                              style: InputStyles.textFieldStyle,
                              obscureText: _isObscurePassword,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16.h),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _rememberMe,
                                      onChanged: (value) {
                                        setState(() {
                                          _rememberMe = value ?? false;
                                        });
                                      },
                                      activeColor: AppColors.primaryBlue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          4.w,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Remember me',
                                      style: AppText.body.copyWith(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24.h),

                      BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          return CustomGradientButton(
                            text: 'Sign In',
                            onPressed: state is AuthLoading
                                ? null
                                : _handleLogin,
                            icon: Icons.login_rounded,
                            isLoading: state is AuthLoading,
                          );
                        },
                      ),

                      SizedBox(height: 24.h),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Don\'t have an account? ',
                            style: AppText.body.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          CustomTextButton(
                            text: 'Sign Up',
                            onPressed: _navigateToSignup,
                          ),
                        ],
                      ),

                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
