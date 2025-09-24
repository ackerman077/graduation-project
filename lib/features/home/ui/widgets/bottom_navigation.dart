import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theming/app_theme.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: ColorsManager.primaryBlue,
        unselectedItemColor: ColorsManager.textLight,
        selectedLabelStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
        ),
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/home.png',
              width: 24.w,
              height: 24.w,
              color: ColorsManager.textLight,
            ),
            activeIcon: Image.asset(
              'assets/images/home.png',
              width: 24.w,
              height: 24.w,
              color: ColorsManager.primaryBlue,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/doctors.png',
              width: 24.w,
              height: 24.w,
              color: ColorsManager.textLight,
            ),
            activeIcon: Image.asset(
              'assets/images/doctors.png',
              width: 24.w,
              height: 24.w,
              color: ColorsManager.primaryBlue,
            ),
            label: 'Doctors',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/appointments.png',
              width: 24.w,
              height: 24.w,
              color: ColorsManager.textLight,
            ),
            activeIcon: Image.asset(
              'assets/images/appointments.png',
              width: 24.w,
              height: 24.w,
              color: ColorsManager.primaryBlue,
            ),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/profile.png',
              width: 24.w,
              height: 24.w,
              color: ColorsManager.textLight,
            ),
            activeIcon: Image.asset(
              'assets/images/profile.png',
              width: 24.w,
              height: 24.w,
              color: ColorsManager.primaryBlue,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
