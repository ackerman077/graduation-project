import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theming/app_theme.dart';
import '../../../../core/models/doctor.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/widgets/doctor_image_widget.dart';

class DoctorDetailScreen extends StatefulWidget {
  final Doctor doctor;

  const DoctorDetailScreen({super.key, required this.doctor});

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.background,
      body: CustomScrollView(
        slivers: [
          _buildHeroAppBar(),

          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildDoctorInfoCards(),

                _buildAboutSection(),

                _buildExperienceSection(),

                _buildContactSection(),

                SizedBox(height: 100.h),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildAppointmentButton(),
    );
  }

  Widget _buildHeroAppBar() {
    return SliverAppBar(
      expandedHeight: 280.h,
      floating: false,
      pinned: true,
      backgroundColor: ColorsManager.primaryBlue,
      elevation: 0,
      leading: Container(
        margin: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12.w),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                ColorsManager.primaryBlue,
                ColorsManager.primaryBlue.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 3,
                    ),
                  ),
                  child: ClipOval(
                    child: DoctorImageWidget(
                      networkImageUrl: widget.doctor.image,
                      doctorId: widget.doctor.id,
                      width: 120.w,
                      height: 120.w,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(60.w),
                      errorWidget: Icon(
                        Icons.person,
                        size: 60.w,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                Text(
                  widget.doctor.name,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 8.h),

                if (widget.doctor.specialization?.name != null &&
                    widget.doctor.specialization!.name.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20.w),
                    ),
                    child: Text(
                      widget.doctor.specialization!.name,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorInfoCards() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 24.w),
      child: Row(
        children: [
          Expanded(
            child: _buildInfoCard(
              icon: Icons.location_on,
              title: 'Location',
              value:
                  '${widget.doctor.city?.name ?? ''}, ${widget.doctor.governrate ?? ''}',
              color: ColorsManager.primaryBlue,
            ),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: _buildInfoCard(
              icon: Icons.star,
              title: 'Rating',
              value: widget.doctor.rating?.toStringAsFixed(1) ?? 'N/A',
              color: ColorsManager.warning,
            ),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: _buildInfoCard(
              icon: Icons.attach_money,
              title: 'Consultation',
              value:
                  '\$${widget.doctor.appointPrice?.toStringAsFixed(0) ?? 'N/A'}',
              color: ColorsManager.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
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
      child: Column(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.w),
            ),
            child: Icon(icon, size: 20.w, color: color),
          ),

          SizedBox(height: 8.h),

          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: ColorsManager.textLight,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 4.h),

          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: ColorsManager.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    if (widget.doctor.bio == null || widget.doctor.bio!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
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
                  borderRadius: BorderRadius.circular(10.w),
                ),
                child: Icon(
                  Icons.person_outline,
                  size: 18.w,
                  color: ColorsManager.primaryBlue,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'About Doctor',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: ColorsManager.textPrimary,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          Text(
            widget.doctor.bio!,
            style: TextStyle(
              fontSize: 14.sp,
              color: ColorsManager.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceSection() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 16.w),
      padding: EdgeInsets.all(20.w),
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
                  borderRadius: BorderRadius.circular(10.w),
                ),
                child: Icon(
                  Icons.work_outline,
                  size: 18.w,
                  color: ColorsManager.primaryBlue,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Experience & Qualifications',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: ColorsManager.textPrimary,
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          if (widget.doctor.experience != null &&
              widget.doctor.experience!.isNotEmpty)
            _buildInfoRow(
              icon: Icons.timeline,
              label: 'Experience',
              value: '${widget.doctor.experience} years',
            ),

          if (widget.doctor.degree != null && widget.doctor.degree!.isNotEmpty)
            _buildInfoRow(
              icon: Icons.school,
              label: 'Degree',
              value: widget.doctor.degree!,
            ),

          if (widget.doctor.education != null &&
              widget.doctor.education!.isNotEmpty)
            _buildInfoRow(
              icon: Icons.cast_for_education,
              label: 'Education',
              value: widget.doctor.education!,
            ),

          if (widget.doctor.languages != null &&
              widget.doctor.languages!.isNotEmpty)
            _buildInfoRow(
              icon: Icons.language,
              label: 'Languages',
              value: widget.doctor.languages!,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              color: ColorsManager.lightBlue,
              borderRadius: BorderRadius.circular(8.w),
            ),
            child: Icon(icon, size: 16.w, color: ColorsManager.primaryBlue),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: ColorsManager.textLight,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: ColorsManager.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
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
                  borderRadius: BorderRadius.circular(10.w),
                ),
                child: Icon(
                  Icons.contact_phone,
                  size: 18.w,
                  color: ColorsManager.primaryBlue,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Contact Information',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: ColorsManager.textPrimary,
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          if (widget.doctor.email != null && widget.doctor.email!.isNotEmpty)
            _buildContactRow(
              icon: Icons.email_outlined,
              label: 'Email',
              value: widget.doctor.email!,
              onTap: () {
              },
            ),

          if (widget.doctor.phone != null && widget.doctor.phone!.isNotEmpty)
            _buildContactRow(
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: widget.doctor.phone!,
              onTap: () {
              },
            ),

          if (widget.doctor.address != null &&
              widget.doctor.address!.isNotEmpty)
            _buildContactRow(
              icon: Icons.location_city_outlined,
              label: 'Address',
              value: widget.doctor.address!,
              onTap: null,
            ),
        ],
      ),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              color: ColorsManager.lightBlue,
              borderRadius: BorderRadius.circular(8.w),
            ),
            child: Icon(icon, size: 16.w, color: ColorsManager.primaryBlue),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: ColorsManager.textLight,
                  ),
                ),
                SizedBox(height: 2.h),
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: onTap != null
                          ? ColorsManager.primaryBlue
                          : ColorsManager.textPrimary,
                      decoration: onTap != null
                          ? TextDecoration.underline
                          : TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentButton() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                Routes.bookingScreen,
                arguments: widget.doctor,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsManager.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.w),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today, size: 20.w, color: Colors.white),
                SizedBox(width: 8.w),
                Text(
                  'Book Appointment',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
