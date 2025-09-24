import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theming/app_theme.dart';
import '../services/logger_service.dart';

class DoctorImageWidget extends StatelessWidget {
  final String? networkImageUrl;
  final int doctorId;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const DoctorImageWidget({
    super.key,
    this.networkImageUrl,
    required this.doctorId,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final localImagePath = _getLocalDoctorImage(doctorId);

    if (networkImageUrl == null || networkImageUrl!.isEmpty) {
      return _buildLocalImage(localImagePath);
    }

    LoggerService.debug(
      'Trying API image for doctor $doctorId: $networkImageUrl',
    );

    return CachedNetworkImage(
      imageUrl: networkImageUrl!,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder ?? _buildPlaceholder(),
      errorWidget: (context, url, error) {
        LoggerService.debug(
          'API image failed for doctor $doctorId: $error. Using local fallback: $localImagePath',
        );

        return _buildLocalImage(localImagePath);
      },
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 100),
    );
  }

  Widget _buildLocalImage(String localPath) {
    return Image.asset(
      localPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        LoggerService.debug(
          'Local image also failed for doctor $doctorId: $error. Using default icon.',
        );
        return errorWidget ?? _buildDefaultIcon();
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.lightBlue,
        borderRadius: borderRadius,
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryBlue,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildDefaultIcon() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.lightBlue,
        borderRadius: borderRadius,
      ),
      child: Icon(
        Icons.person,
        size: (width ?? 50.w) * 0.5,
        color: AppColors.primaryBlue,
      ),
    );
  }

  static String _getLocalDoctorImage(int doctorId) {
    int validId = doctorId;
    if (validId < 1) validId = 1;
    if (validId > 60) validId = 60;
    return 'assets/images/doctors/pdoctor_$validId.png';
  }
}
