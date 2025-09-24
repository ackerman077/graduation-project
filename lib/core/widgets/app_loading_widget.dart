import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theming/app_theme.dart';

class AppLoadingWidget extends StatelessWidget {
  final double? height;
  final double? width;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const AppLoadingWidget({
    super.key,
    this.height,
    this.width,
    this.borderRadius = 8,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.lighterGray,
      highlightColor: AppColors.lighterGray,
      child: Container(
        height: height,
        width: width,
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class AppListLoadingWidget extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final double itemSpacing;
  final EdgeInsetsGeometry? padding;

  const AppListLoadingWidget({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.itemSpacing = 12,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      itemCount: itemCount,
      separatorBuilder: (context, index) => SizedBox(height: itemSpacing),
      itemBuilder: (context, index) =>
          const AppLoadingWidget(height: 80, borderRadius: 12),
    );
  }
}

class AppCardLoadingWidget extends StatelessWidget {
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? padding;

  const AppCardLoadingWidget({
    super.key,
    this.height,
    this.width,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppLoadingWidget(height: 20, width: double.infinity, borderRadius: 4),
          SizedBox(height: 12),
          AppLoadingWidget(height: 16, width: 150, borderRadius: 4),
          SizedBox(height: 8),
          AppLoadingWidget(height: 16, width: 100, borderRadius: 4),
        ],
      ),
    );
  }
}
