import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theming/app_theme.dart';

class OnboardingIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const OnboardingIndicator({
    super.key,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          margin: EdgeInsets.symmetric(horizontal: 6.w),
          width: currentPage == index ? 32.w : 12.w,
          height: 12.h,
          decoration: BoxDecoration(
            gradient: currentPage == index
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ColorsManager.primaryBlue,
                      ColorsManager.primaryBlue.withValues(alpha: 0.8),
                    ],
                  )
                : null,
            color: currentPage == index
                ? null
                : ColorsManager.lightGray.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(6.w),
            boxShadow: currentPage == index
                ? [
                    BoxShadow(
                      color: ColorsManager.primaryBlue.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }
}
