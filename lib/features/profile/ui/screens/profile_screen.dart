import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import '../../../../core/theming/app_theme.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/services/profile_picture_service.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfilePictureService _profilePictureService;
  File? _currentProfilePicture;

  @override
  void initState() {
    super.initState();
    _profilePictureService = DependencyInjection.get<ProfilePictureService>();
    _currentProfilePicture = _profilePictureService.profilePicture;

    _profilePictureService.addListener(_onProfilePictureChanged);
  }

  @override
  void dispose() {
    _profilePictureService.removeListener(_onProfilePictureChanged);
    super.dispose();
  }

  void _onProfilePictureChanged(File? imageFile) {
    if (mounted) {
      setState(() {
        _currentProfilePicture = imageFile;
      });
    }
  }

  void _refreshProfilePicture() {
    final currentPicture = _profilePictureService.profilePicture;
    if (mounted) {
      setState(() {
        _currentProfilePicture = currentPicture;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshProfilePicture();
    });

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.loginScreen,
            (route) => false,
          );
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: ColorsManager.background,
            appBar: _buildAppBar(),
            body: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  _buildProfileHeader(context, state),
                  SizedBox(height: 20.h),

                  _buildProfileOptions(context),

                  if (state is AuthLoading)
                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        children: [
                          const CircularProgressIndicator(
                            color: ColorsManager.primaryBlue,
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'Logging out...',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: ColorsManager.textSecondary,
                            ),
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
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        'Profile',
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
          color: ColorsManager.textPrimary,
        ),
      ),
      centerTitle: true,
      iconTheme: const IconThemeData(color: ColorsManager.textPrimary),
    );
  }

  Widget _buildProfileHeader(BuildContext context, AuthState state) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.w),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.primaryBlue.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              margin: EdgeInsets.only(
                left: 8.w,
              ),
              decoration: BoxDecoration(
                color: ColorsManager.lightBlue,
                shape: BoxShape.circle,
                border: Border.all(
                  color: ColorsManager.primaryBlue.withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ColorsManager.primaryBlue.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
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
                        width: 80.w,
                        height: 80.w,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            size: 40.w,
                            color: ColorsManager.primaryBlue,
                          );
                        },
                      )
                    : Icon(
                        Icons.person,
                        size: 40.w,
                        color: ColorsManager.primaryBlue,
                      ),
              ),
            ),
            SizedBox(height: 12.h),

            Text(
              _getUserName(state),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: ColorsManager.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),

            Text(
              _getUserEmail(state),
              style: TextStyle(
                fontSize: 13.sp,
                color: ColorsManager.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),

            Container(
              width: double.maxFinite,
              height: 52.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26.w),
                boxShadow: [
                  BoxShadow(
                    color: ColorsManager.primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, Routes.personalInfoScreen);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsManager.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26.w),
                  ),
                  elevation: 0,
                  padding: EdgeInsets.only(top: 4.h, bottom: 8.h),
                ),
                child: Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOptions(BuildContext context) {
    final options = [
      {
        'icon': Icons.settings,
        'title': 'Settings',
        'subtitle': 'App preferences and configuration',
        'color': ColorsManager.primaryBlue,
        'onTap': () {
        },
      },
      {
        'icon': Icons.info_outline,
        'title': 'About',
        'subtitle': 'App version and information',
        'color': ColorsManager.primaryBlue,
        'onTap': () {
          Navigator.pushNamed(context, Routes.aboutScreen);
        },
      },
      {
        'icon': Icons.logout,
        'title': 'Logout',
        'subtitle': 'Sign out of your account',
        'color': ColorsManager.error,
        'onTap': () => _showLogoutDialog(context),
      },
    ];

    return Column(
      children: options.map((option) {
        return Container(
          margin: EdgeInsets.only(bottom: 8.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.w),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 8.h,
            ),
            leading: Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: (option['color'] as Color).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.w),
              ),
              child: Icon(
                option['icon'] as IconData,
                size: 18.w,
                color: option['color'] as Color,
              ),
            ),
            title: Text(
              option['title'] as String,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: ColorsManager.textPrimary,
              ),
            ),
            subtitle: Text(
              option['subtitle'] as String,
              style: TextStyle(
                fontSize: 12.sp,
                color: ColorsManager.textSecondary,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 14.w,
              color: ColorsManager.textLight,
            ),
            onTap: option['onTap'] as VoidCallback,
          ),
        );
      }).toList(),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.w),
          ),
          title: Text(
            'Logout',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: ColorsManager.textPrimary,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              fontSize: 14.sp,
              color: ColorsManager.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: ColorsManager.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                context.read<AuthCubit>().logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsManager.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.w),
                ),
              ),
              child: Text(
                'Logout',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getUserName(AuthState state) {
    if (state is AuthSuccess) {
      return state.user.name.isNotEmpty ? state.user.name : 'User Name';
    }
    return 'User Name';
  }

  String _getUserEmail(AuthState state) {
    if (state is AuthSuccess) {
      return state.user.email.isNotEmpty
          ? state.user.email
          : 'user@example.com';
    }
    return 'user@example.com';
  }
}
