import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theming/app_theme.dart';

class AppErrorWidget extends StatelessWidget {
  final String? errorMessage;
  final int? errorCode;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final String? title;
  final bool showRetryButton;
  final bool showDismissButton;
  final IconData? icon;

  const AppErrorWidget({
    super.key,
    this.errorMessage,
    this.errorCode,
    this.onRetry,
    this.onDismiss,
    this.title,
    this.showRetryButton = true,
    this.showDismissButton = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final userFriendlyMessage = errorMessage ?? 'Something went wrong';
    final isRetryable = onRetry != null;

    return Container(
      padding: EdgeInsets.all(20.w),
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon ?? Icons.error_outline,
              size: 32.w,
              color: Colors.red,
            ),
          ),

          SizedBox(height: 16.h),

          if (title != null) ...[
            Text(title!, style: AppText.h3, textAlign: TextAlign.center),
            SizedBox(height: 8.h),
          ],

          Text(
            userFriendlyMessage,
            style: AppText.bodyMedium.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 20.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showDismissButton && onDismiss != null) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDismiss,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.w),
                      ),
                    ),
                    child: Text(
                      'Dismiss',
                      style: AppText.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
              ],

              if (showRetryButton && onRetry != null && isRetryable)
                Expanded(
                  child: ElevatedButton(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.w),
                      ),
                    ),
                    child: Text('Try Again', style: AppText.button),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class CompactErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final Color? backgroundColor;
  final Color? textColor;

  const CompactErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.w),
        border: Border.all(
          color: textColor ?? Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 16.w, color: textColor ?? Colors.red),
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              message,
              style: TextStyle(fontSize: 12.sp, color: textColor ?? Colors.red),
            ),
          ),
          if (onRetry != null) ...[
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: onRetry,
              child: Icon(
                Icons.refresh,
                size: 16.w,
                color: textColor ?? Colors.red,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class LoadingErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final bool isLoading;

  const LoadingErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading) ...[
            const CircularProgressIndicator(color: AppColors.primaryBlue),
            SizedBox(height: 16.h),
            Text('Loading...', style: AppText.body),
          ] else ...[
            Icon(Icons.error_outline, size: 64.w, color: AppColors.gray),
            SizedBox(height: 16.h),
            Text(message, style: AppText.body, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              SizedBox(height: 16.h),
              ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ],
      ),
    );
  }
}
