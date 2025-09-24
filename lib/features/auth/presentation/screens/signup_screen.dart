import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theming/app_theme.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/routing/routes.dart';
import '../../data/models/register_request.dart';
import '../cubit/auth_cubit.dart';
import '../../../../core/widgets/custom_buttons.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  int _selectedGender = 0;
  bool _isObscurePassword = true;
  bool _isObscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    final authCubit = context.read<AuthCubit>();
    final request = RegisterRequest(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      gender: _selectedGender,
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
    );

    await authCubit.register(request);
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, Routes.loginScreen);
  }

  String _getFieldDisplayName(String fieldName) {
    switch (fieldName.toLowerCase()) {
      case 'name':
        return 'Full Name';
      case 'email':
        return 'Email Address';
      case 'phone':
        return 'Phone Number';
      case 'password':
        return 'Password';
      case 'password_confirmation':
        return 'Confirm Password';
      case 'gender':
        return 'Gender';
      default:
        return fieldName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Navigator.pushReplacementNamed(context, Routes.homeScreen);
          } else if (state is AuthFailure) {
            String errorMessage = state.message;

            if (state.validationErrors != null &&
                state.validationErrors!.isNotEmpty) {
              final firstFieldErrors = state.validationErrors!.values.first;
              if (firstFieldErrors.isNotEmpty) {
                errorMessage = firstFieldErrors.first;
              }
            }

            if (state.code == 422) {
              if (state.validationErrors != null &&
                  state.validationErrors!.isNotEmpty) {
                final fieldErrors = <String>[];
                state.validationErrors!.forEach((field, errors) {
                  if (errors.isNotEmpty) {
                    fieldErrors.add(
                      '${_getFieldDisplayName(field)}: ${errors.first}',
                    );
                  }
                });
                if (fieldErrors.isNotEmpty) {
                  errorMessage = fieldErrors.join('\n');
                }
              }
            } else if (state.code == 409) {
              errorMessage =
                  'This email address is already registered. Please use a different email or try logging in.';
            } else if (state.code == 400) {
              errorMessage =
                  'Invalid input. Please check your information and try again.';
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'OK',
                  textColor: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ),
            );
          }
        },
        child: DecoratedBox(
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
              child: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  return Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 2.h),

                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 40.w,
                                height: 40.w,
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
                                  Icons.person_add_rounded,
                                  size: 20.w,
                                  color: Colors.white,
                                ),
                              ),

                              SizedBox(height: 8.h),

                              Text(
                                'Create Account',
                                style: AppText.h3.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              SizedBox(height: 4.h),

                              Text(
                                'Join us and start your healthcare journey today',
                                style: AppText.body.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w400,
                                  height: 1.2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 16.h),

                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.w),
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
                                'Full Name',
                                style: AppText.body.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              TextFormField(
                                controller: _nameController,
                                decoration:
                                    InputStyles.inputWithHint(
                                      'Enter your full name',
                                    ).copyWith(
                                      prefixIcon: Icon(
                                        Icons.person_outline,
                                        color: AppColors.textLight,
                                        size: 16.w,
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12.w,
                                        vertical: 8.h,
                                      ),
                                    ),
                                style: InputStyles.textFieldStyle,
                                textCapitalization: TextCapitalization.words,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your full name';
                                  }
                                  if (value.length < 2) {
                                    return 'Name must be at least 2 characters';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 12.h),

                              Text(
                                'Email Address',
                                style: AppText.body.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              TextFormField(
                                controller: _emailController,
                                decoration:
                                    InputStyles.inputWithHint(
                                      'Enter your email address',
                                    ).copyWith(
                                      prefixIcon: Icon(
                                        Icons.email_outlined,
                                        color: AppColors.textLight,
                                        size: 16.w,
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12.w,
                                        vertical: 8.h,
                                      ),
                                    ),
                                style: InputStyles.textFieldStyle,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email address';
                                  }
                                  if (value.length < 5) {
                                    return 'Email address is too short';
                                  }
                                  if (value.length > 100) {
                                    return 'Email address is too long';
                                  }
                                  if (!RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  ).hasMatch(value)) {
                                    return 'Please enter a valid email address';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 12.h),

                              Text(
                                'Phone Number',
                                style: AppText.body.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              TextFormField(
                                controller: _phoneController,
                                decoration:
                                    InputStyles.inputWithHint(
                                      'Enter your phone number',
                                    ).copyWith(
                                      prefixIcon: Icon(
                                        Icons.phone_outlined,
                                        color: AppColors.textLight,
                                        size: 16.w,
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12.w,
                                        vertical: 8.h,
                                      ),
                                    ),
                                style: InputStyles.textFieldStyle,
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your phone number';
                                  }
                                  final cleanPhone = value.replaceAll(
                                    RegExp('[^0-9]'),
                                    '',
                                  );
                                  if (cleanPhone.isEmpty) {
                                    return 'Phone number must contain at least 1 digit';
                                  }
                                  if (cleanPhone.length < 7) {
                                    return 'Phone number is too short (minimum 7 digits)';
                                  }
                                  if (cleanPhone.length > 15) {
                                    return 'Phone number is too long (maximum 15 digits)';
                                  }
                                  if (!RegExp(
                                    r'^[0-9]+$',
                                  ).hasMatch(cleanPhone)) {
                                    return 'Phone number must contain only digits';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 12.h),

                              Text(
                                'Gender',
                                style: AppText.body.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedGender =
                                              0;
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(8.w),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 8.h,
                                          horizontal: 8.w,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _selectedGender == 0
                                              ? AppColors.primaryBlue
                                                    .withValues(alpha: 0.1)
                                              : AppColors.inputBackground,
                                          border: Border.all(
                                            color: _selectedGender == 0
                                                ? AppColors.primaryBlue
                                                : AppColors.inputBorder,
                                            width: 2.w,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8.w,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              _selectedGender == 0
                                                  ? Icons.male_rounded
                                                  : Icons.male_outlined,
                                              color: _selectedGender == 0
                                                  ? AppColors.primaryBlue
                                                  : AppColors.textLight,
                                              size: 16.w,
                                            ),
                                            SizedBox(width: 4.w),
                                            Text(
                                              'Male',
                                              style: AppText.bodySmall.copyWith(
                                                color: _selectedGender == 0
                                                    ? ColorsManager.primaryBlue
                                                    : ColorsManager
                                                          .textSecondary,
                                                fontWeight: _selectedGender == 0
                                                    ? FontWeight.w600
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedGender =
                                              1;
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(8.w),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 8.h,
                                          horizontal: 8.w,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _selectedGender == 1
                                              ? AppColors.primaryBlue
                                                    .withValues(alpha: 0.1)
                                              : AppColors.inputBackground,
                                          border: Border.all(
                                            color: _selectedGender == 1
                                                ? AppColors.primaryBlue
                                                : AppColors.inputBorder,
                                            width: 2.w,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8.w,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              _selectedGender == 1
                                                  ? Icons.female_rounded
                                                  : Icons.female_outlined,
                                              color: _selectedGender == 1
                                                  ? AppColors.primaryBlue
                                                  : AppColors.textLight,
                                              size: 16.w,
                                            ),
                                            SizedBox(width: 4.w),
                                            Text(
                                              'Female',
                                              style: AppText.bodySmall.copyWith(
                                                color: _selectedGender == 1
                                                    ? ColorsManager.primaryBlue
                                                    : ColorsManager
                                                          .textSecondary,
                                                fontWeight: _selectedGender == 1
                                                    ? FontWeight.w600
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),

                              Text(
                                'Password',
                                style: AppText.body.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              TextFormField(
                                controller: _passwordController,
                                decoration:
                                    InputStyles.inputWithHint(
                                      'Enter your password',
                                    ).copyWith(
                                      prefixIcon: Icon(
                                        Icons.lock_outline,
                                        color: AppColors.textLight,
                                        size: 16.w,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _isObscurePassword
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color: AppColors.textLight,
                                          size: 16.w,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isObscurePassword =
                                                !_isObscurePassword;
                                          });
                                        },
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12.w,
                                        vertical: 8.h,
                                      ),
                                    ),
                                style: InputStyles.textFieldStyle,
                                obscureText: _isObscurePassword,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters long';
                                  }
                                  if (value.length > 50) {
                                    return 'Password is too long (maximum 50 characters)';
                                  }
                                  if (value.length < 8) {
                                    return 'For better security, use at least 8 characters';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 12.h),

                              Text(
                                'Confirm Password',
                                style: AppText.body.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              TextFormField(
                                controller: _confirmPasswordController,
                                decoration:
                                    InputStyles.inputWithHint(
                                      'Confirm your password',
                                    ).copyWith(
                                      prefixIcon: Icon(
                                        Icons.lock_outline,
                                        color: AppColors.textLight,
                                        size: 16.w,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _isObscureConfirmPassword
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color: AppColors.textLight,
                                          size: 16.w,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isObscureConfirmPassword =
                                                !_isObscureConfirmPassword;
                                          });
                                        },
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12.w,
                                        vertical: 8.h,
                                      ),
                                    ),
                                style: InputStyles.textFieldStyle,
                                obscureText: _isObscureConfirmPassword,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 16.h),

                        BlocBuilder<AuthCubit, AuthState>(
                          builder: (context, state) {
                            return CustomGradientButton(
                              text: 'Create Account',
                              onPressed: state is AuthLoading
                                  ? null
                                  : _handleSignup,
                              icon: Icons.person_add_rounded,
                              isLoading: state is AuthLoading,
                            );
                          },
                        ),

                        SizedBox(height: 16.h),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: AppText.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            CustomTextButton(
                              text: 'Sign In',
                              onPressed: _navigateToLogin,
                            ),
                          ],
                        ),

                        SizedBox(height: 12.h),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
