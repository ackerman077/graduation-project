import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../cubit/specializations_cubit.dart';
import '../../../../core/widgets/app_loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/specialty_icon.dart';
import '../../../../core/models/specialization.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/theming/app_theme.dart';
import '../../../../core/routing/routes.dart';

class DoctorsBySpecializationScreen extends StatelessWidget {
  final int specializationId;

  const DoctorsBySpecializationScreen({
    super.key,
    required this.specializationId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          DependencyInjection.get<SpecializationsCubit>()
            ..loadSpecializations(),
      child: _DoctorsBySpecializationContent(
        specializationId: specializationId,
      ),
    );
  }
}

class _DoctorsBySpecializationContent extends StatelessWidget {
  final int specializationId;

  const _DoctorsBySpecializationContent({required this.specializationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Doctors by Specialty'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: BlocBuilder<SpecializationsCubit, SpecializationsState>(
        builder: (context, state) {
          if (state is SpecializationsLoading) {
            return const AppLoadingWidget();
          }

          if (state is SpecializationsError) {
            return AppErrorWidget(
              errorMessage: state.message,
              onRetry: () =>
                  context.read<SpecializationsCubit>().loadSpecializations(),
            );
          }

          if (state is SpecializationsLoaded) {
            final specialization = state.specializations.firstWhere(
              (s) => s.id == specializationId,
              orElse: () => throw Exception('Specialization not found'),
            );
            return _buildDoctorsBySpecialization(context, specialization);
          }

          return const AppErrorWidget(errorMessage: 'No specialties available');
        },
      ),
    );
  }

  Widget _buildDoctorsBySpecialization(
    BuildContext context,
    Specialization specialization,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSpecializationHeader(context, specialization),

          SizedBox(height: 24.h),

          _buildDoctorsList(context, specialization),
        ],
      ),
    );
  }

  Widget _buildSpecializationHeader(
    BuildContext context,
    Specialization specialization,
  ) {
    return Center(
      child: Container(
        width: 220.w,
        padding: EdgeInsets.all(20.w),
        decoration: const BoxDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.w),
                border: Border.all(
                  color: ColorsManager.primaryBlue.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ColorsManager.primaryBlue.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: SpecialtyIcon(
                  specialtyName: specialization.name,
                  size: 32.w,
                ),
              ),
            ),

            SizedBox(height: 16.h),

            Text(
              specialization.name,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: ColorsManager.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 8.h),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ColorsManager.primaryBlue.withValues(alpha: 0.1),
                    ColorsManager.primaryBlue.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20.w),
                border: Border.all(
                  color: ColorsManager.primaryBlue.withValues(alpha: 0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ColorsManager.primaryBlue.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '${specialization.doctors?.length ?? 0} doctors available',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: ColorsManager.primaryBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorsList(
    BuildContext context,
    Specialization specialization,
  ) {
    if (specialization.doctors == null || specialization.doctors!.isEmpty) {
      return Container(
        padding: EdgeInsets.all(32.w),
        child: Column(
          children: [
            Icon(
              Icons.medical_services_outlined,
              size: 64.w,
              color: ColorsManager.textLight,
            ),
            SizedBox(height: 16.h),
            Text(
              'No doctors available',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: ColorsManager.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'We\'ll add more doctors in this specialty soon.',
              style: TextStyle(
                fontSize: 14.sp,
                color: ColorsManager.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Doctors',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: ColorsManager.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: specialization.doctors!.length,
          separatorBuilder: (context, index) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            final doctor = specialization.doctors![index];
            return _buildDoctorCard(context, doctor);
          },
        ),
      ],
    );
  }

  Widget _buildDoctorCard(BuildContext context, dynamic doctor) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: ColorsManager.lightBlue,
              borderRadius: BorderRadius.circular(12.w),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.w),
              child: doctor.image != null && doctor.image!.isNotEmpty
                  ? Image.asset(
                      doctor.image!,
                      width: 60.w,
                      height: 60.w,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          size: 30.w,
                          color: ColorsManager.primaryBlue,
                        );
                      },
                    )
                  : Icon(
                      Icons.person,
                      size: 30.w,
                      color: ColorsManager.primaryBlue,
                    ),
            ),
          ),

          SizedBox(width: 16.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name ?? 'Unknown Doctor',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: ColorsManager.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                if (doctor.city != null)
                  Text(
                    doctor.city!.name ?? '',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: ColorsManager.textSecondary,
                    ),
                  ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    if (doctor.rating != null)
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16.w,
                            color: ColorsManager.warning,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            doctor.rating!.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: ColorsManager.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    if (doctor.appointPrice != null) ...[
                      SizedBox(width: 16.w),
                      Text(
                        '\$${doctor.appointPrice!.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: ColorsManager.primaryBlue,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                Routes.doctorDetailScreen,
                arguments: doctor,
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: ColorsManager.primaryBlue,
                borderRadius: BorderRadius.circular(12.w),
              ),
              child: Text(
                'Book',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
