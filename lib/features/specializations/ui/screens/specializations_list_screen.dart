import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../cubit/specializations_cubit.dart';

import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/specialty_icon.dart';
import '../../../../core/models/specialization.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/theming/app_theme.dart';

class SpecializationsListScreen extends StatelessWidget {
  const SpecializationsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          DependencyInjection.get<SpecializationsCubit>()
            ..loadSpecializations(),
      child: const _SpecializationsListContent(),
    );
  }
}

class _SpecializationsListContent extends StatelessWidget {
  const _SpecializationsListContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Specialties'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: ColorsManager.textPrimary,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: BlocBuilder<SpecializationsCubit, SpecializationsState>(
            builder: (context, state) {
              if (state is SpecializationsLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: ColorsManager.primaryBlue,
                  ),
                );
              }

              if (state is SpecializationsError) {
                return AppErrorWidget(
                  errorMessage: state.message,
                  onRetry: () => context
                      .read<SpecializationsCubit>()
                      .loadSpecializations(),
                );
              }

              if (state is SpecializationsLoaded) {
                return _buildSpecialtiesGrid(context, state.specializations);
              }

              return const Center(
                child: CircularProgressIndicator(
                  color: ColorsManager.primaryBlue,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialtiesGrid(
    BuildContext context,
    List<Specialization> specializations,
  ) {
    if (specializations.isEmpty) {
      return const Center(
        child: Text(
          'No specialties available',
          style: TextStyle(fontSize: 16, color: ColorsManager.textLight),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
      itemCount: specializations.length,
      itemBuilder: (context, index) {
        final specialty = specializations[index];
        return _buildSpecialtyCard(context, specialty);
      },
    );
  }

  Widget _buildSpecialtyCard(BuildContext context, Specialization specialty) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.doctorsBySpecializationScreen,
          arguments: specialty.id,
        );
      },
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: const BoxDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
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
                child: SpecialtyIcon(specialtyName: specialty.name, size: 32.w),
              ),
            ),

            SizedBox(height: 10.h),

            Text(
              specialty.name,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: ColorsManager.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
