import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SpecialtyIcon extends StatelessWidget {
  final String specialtyName;
  final double? size;

  const SpecialtyIcon({super.key, required this.specialtyName, this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size ?? 24.w,
      height: size ?? 24.w,
      child: Image.asset(
        _getImagePath(specialtyName),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.medical_services,
            size: size ?? 24.w,
            color: Colors.grey,
          );
        },
      ),
    );
  }

  String _getImagePath(String specialtyName) {
    final name = specialtyName.toLowerCase();
    return 'assets/images/Specialization/$name.png';
  }
}
