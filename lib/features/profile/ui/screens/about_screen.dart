import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theming/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppHeader(),
            SizedBox(height: 20.h),
            _buildAppInfo(),
            SizedBox(height: 16.h),
            _buildAboutSection(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios,
          color: ColorsManager.textPrimary,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'About Appointly',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: ColorsManager.textPrimary,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildAppHeader() {
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  color: ColorsManager.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.w),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.w),
                  child: Image.asset(
                    'assets/images/splash_android12_logo.png',
                    width: 100.w,
                    height: 100.w,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Appointly',
                style: TextStyles.displayLarge.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Your Health, Our Priority',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: ColorsManager.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppInfo() {
    final infoItems = [
      {'title': 'App Version', 'value': '1.0.0', 'icon': Icons.info_outline},
      {
        'title': 'Developer',
        'value': 'YOUSEF ZAHRAN',
        'icon': Icons.person_outline,
      },
      {
        'title': 'Build Date',
        'value': 'August 2025',
        'icon': Icons.calendar_today,
      },
    ];

    return Column(
      children: infoItems.map((item) {
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
                color: ColorsManager.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.w),
              ),
              child: Icon(
                item['icon'] as IconData,
                size: 18.w,
                color: ColorsManager.primaryBlue,
              ),
            ),
            title: Text(
              item['title'] as String,
              style: TextStyle(
                fontSize: 13.sp,
                color: ColorsManager.textSecondary,
              ),
            ),
            subtitle: Text(
              item['value'] as String,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: ColorsManager.textPrimary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAboutSection() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About Appointly',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: ColorsManager.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'A doctor appointment booking app built by ZAHRAN.',
              style: TextStyle(
                fontSize: 14.sp,
                color: ColorsManager.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
