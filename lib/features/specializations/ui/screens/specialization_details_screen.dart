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
import '../../../../core/services/logger_service.dart';
import '../../../../core/widgets/doctor_image_widget.dart';

class SpecializationDetailsScreen extends StatelessWidget {
  final int specializationId;

  const SpecializationDetailsScreen({
    super.key,
    required this.specializationId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          DependencyInjection.get<SpecializationsCubit>()
            ..loadSpecializationDetails(specializationId),
      child: _SpecializationDetailsContent(specializationId: specializationId),
    );
  }
}

class _SpecializationDetailsContent extends StatelessWidget {
  final int specializationId;

  const _SpecializationDetailsContent({required this.specializationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Specialization Details'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: BlocBuilder<SpecializationsCubit, SpecializationsState>(
        builder: (context, state) {
          LoggerService.debug(
            'SpecializationDetailsScreen state: ${state.runtimeType}',
          );
          LoggerService.debug(
            'SpecializationDetailsScreen specializationId: $specializationId',
          );

          if (state is SpecializationsLoading) {
            return const AppLoadingWidget();
          }

          if (state is SpecializationsError) {
            LoggerService.error(
              'SpecializationDetailsScreen error: ${state.message}',
            );
            return AppErrorWidget(
              errorMessage: state.message,
              onRetry: () => context
                  .read<SpecializationsCubit>()
                  .loadSpecializationDetails(specializationId),
            );
          }

          if (state is SpecializationDetailsLoaded) {
            LoggerService.debug(
              'SpecializationDetailsScreen loaded: ${state.specialization.name}',
            );
            return _buildSpecializationDetails(context, state.specialization);
          }

          LoggerService.debug('SpecializationDetailsScreen no state match');
          return const AppErrorWidget(errorMessage: 'Specialization not found');
        },
      ),
    );
  }

  Widget _buildSpecializationDetails(
    BuildContext context,
    Specialization specialization,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(context, specialization),

          SizedBox(height: 24.h),

          if (specialization.description != null) ...[
            _buildDescriptionSection(context, specialization.description!),
            SizedBox(height: 24.h),
          ],

          _buildDoctorsSection(context, specialization),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(
    BuildContext context,
    Specialization specialization,
  ) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: ColorsManager.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20.w),
              border: Border.all(
                color: ColorsManager.primaryBlue.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: SpecialtyIcon(
              specialtyName: specialization.name,
              size: 40.w,
            ),
          ),

          SizedBox(height: 20.h),

          Text(
            specialization.name,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: ColorsManager.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 12.h),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: ColorsManager.lightBlue,
              borderRadius: BorderRadius.circular(20.w),
            ),
            child: Text(
              '${specialization.doctors?.length ?? 0} doctors available',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: ColorsManager.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context, String description) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: ColorsManager.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.w),
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  size: 18.w,
                  color: ColorsManager.primaryBlue,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'About This Specialty',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: ColorsManager.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            description,
            style: TextStyle(
              fontSize: 14.sp,
              color: ColorsManager.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorsSection(
    BuildContext context,
    Specialization specialization,
  ) {
    if (specialization.doctors == null || specialization.doctors!.isEmpty) {
      return Container(
        padding: EdgeInsets.all(32.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
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

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: ColorsManager.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.w),
                ),
                child: Icon(
                  Icons.people_rounded,
                  size: 18.w,
                  color: ColorsManager.primaryBlue,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Available Doctors',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: ColorsManager.textPrimary,
                ),
              ),
            ],
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
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, dynamic doctor) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: ColorsManager.background,
        borderRadius: BorderRadius.circular(12.w),
        border: Border.all(color: ColorsManager.lightGray, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: ColorsManager.lightBlue,
              borderRadius: BorderRadius.circular(10.w),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.w),
              child: DoctorImageWidget(
                networkImageUrl: doctor.image,
                doctorId: doctor.id,
                width: 50.w,
                height: 50.w,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(10.w),
                errorWidget: Icon(
                  Icons.person,
                  size: 25.w,
                  color: ColorsManager.primaryBlue,
                ),
              ),
            ),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name ?? 'Unknown Doctor',
                  style: TextStyle(
                    fontSize: 15.sp,
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
                      fontSize: 13.sp,
                      color: ColorsManager.textSecondary,
                    ),
                  ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    if (doctor.rating != null)
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 14.w,
                            color: ColorsManager.warning,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            doctor.rating!.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: ColorsManager.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    if (doctor.appointPrice != null) ...[
                      SizedBox(width: 12.w),
                      Text(
                        '\$${doctor.appointPrice!.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 13.sp,
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
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: ColorsManager.primaryBlue,
                borderRadius: BorderRadius.circular(10.w),
              ),
              child: Text(
                'View',
                style: TextStyle(
                  fontSize: 11.sp,
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
