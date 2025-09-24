import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theming/app_theme.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/models/appointment.dart';
import '../../../../core/services/logger_service.dart';
import '../../cubit/appointments_cubit.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DependencyInjection.get<AppointmentsCubit>(),
      child: Scaffold(
        backgroundColor: ColorsManager.background,
        appBar: _buildAppBar(),
        body: BlocListener<AppointmentsCubit, AppointmentsState>(
          listener: (context, state) {
            if (state is AppointmentsError) {
              LoggerService.error('Appointments error: ${state.message}');
            }
          },
          child: BlocBuilder<AppointmentsCubit, AppointmentsState>(
            builder: (context, state) {
              LoggerService.debug(
                '🔄 [AppointmentsScreen] BlocBuilder state: ${state.runtimeType}',
              );

              if (state is AppointmentsInitial) {
                LoggerService.debug(
                  '🔄 [AppointmentsScreen] Initial state detected, triggering load...',
                );
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    try {
                      LoggerService.debug(
                        '🔄 [AppointmentsScreen] Calling loadAppointments...',
                      );
                      final cubit = context.read<AppointmentsCubit>();
                      cubit.loadAppointments();
                    } catch (e) {
                      LoggerService.error('Error loading appointments: $e');
                    }
                  }
                });

                return const Center(
                  child: CircularProgressIndicator(
                    color: ColorsManager.primaryBlue,
                  ),
                );
              }

              if (state is AppointmentsLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: ColorsManager.primaryBlue,
                  ),
                );
              }

              if (state is AppointmentsError) {
                return Center(
                  child: AppErrorWidget(
                    title: 'Error Loading Appointments',
                    errorMessage: state.message,
                    onRetry: () {
                      try {
                        context.read<AppointmentsCubit>().loadAppointments();
                      } catch (e) {
                        LoggerService.error(
                          'Error retrying appointments load: $e',
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to retry: $e'),
                            backgroundColor: ColorsManager.error,
                          ),
                        );
                      }
                    },
                  ),
                );
              }

              if (state is AppointmentsLoaded) {
                return _buildAppointmentsContent(state.appointments);
              }

              return const Center(
                child: Text(
                  'No appointments found',
                  style: TextStyle(
                    fontSize: 16,
                    color: ColorsManager.textLight,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        'My Appointments',
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
          color: ColorsManager.textPrimary,
        ),
      ),
      centerTitle: true,
      iconTheme: const IconThemeData(color: ColorsManager.textPrimary),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: ColorsManager.lightGray,
            borderRadius: BorderRadius.circular(16.w),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: ColorsManager.primaryBlue,
              borderRadius: BorderRadius.circular(16.w),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: Colors.white,
            unselectedLabelColor: ColorsManager.textSecondary,
            labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            unselectedLabelStyle: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentsContent(List<Appointment> appointments) {
    final now = DateTime.now();

    final upcomingAppointments = appointments.where((appointment) {
      final isCompleted =
          appointment.status == 'cancelled' ||
          appointment.status == 'completed';
      if (isCompleted) return false;

      return appointment.startTime.isAfter(now);
    }).toList()..sort((a, b) => a.startTime.compareTo(b.startTime));

    final pastAppointments = appointments.where((appointment) {
      final isCompleted =
          appointment.status == 'cancelled' ||
          appointment.status == 'completed';
      if (isCompleted) return true;

      return !appointment.startTime.isAfter(now);
    }).toList()..sort((a, b) => b.startTime.compareTo(a.startTime));

    return TabBarView(
      controller: _tabController,
      children: [
        _buildAppointmentsList(
          upcomingAppointments,
          'upcoming',
          'No upcoming appointments',
          'You don\'t have any upcoming appointments',
        ),

        _buildAppointmentsList(
          pastAppointments,
          'past',
          'No past appointments',
          'You don\'t have any past appointments',
        ),
      ],
    );
  }

  Widget _buildAppointmentsList(
    List<Appointment> appointments,
    String type,
    String emptyTitle,
    String emptyMessage,
  ) {
    if (appointments.isEmpty) {
      return _buildEmptyState(emptyTitle, emptyMessage, type);
    }

    return ListView.builder(
      padding: EdgeInsets.all(12.w),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: _buildModernAppointmentCard(appointment),
        );
      },
    );
  }

  Widget _buildEmptyState(String title, String message, String type) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              color: ColorsManager.lightBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(60.w),
            ),
            child: Icon(
              type == 'upcoming' ? Icons.calendar_today : Icons.history,
              size: 60.w,
              color: ColorsManager.primaryBlue,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: ColorsManager.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 16.sp,
              color: ColorsManager.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildModernAppointmentCard(Appointment appointment) {
    return DecoratedBox(
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
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    color: ColorsManager.lightBlue,
                    borderRadius: BorderRadius.circular(25.w),
                    border: Border.all(
                      color: ColorsManager.primaryBlue.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.schedule,
                    size: 24.w,
                    color: ColorsManager.primaryBlue,
                  ),
                ),

                SizedBox(width: 12.w),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.doctorName.isNotEmpty
                            ? appointment.doctorName
                            : 'Unknown Doctor',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: ColorsManager.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: 2.h),

                      if (appointment.doctorSpecialization != null) ...[
                        Text(
                          appointment.doctorSpecialization!,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: ColorsManager.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6.h),
                      ],

                      Wrap(
                        spacing: 12.w,
                        runSpacing: 6.h,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 12.w,
                                color: ColorsManager.textLight,
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                _formatAppointmentDate(appointment.startTime),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: ColorsManager.textLight,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 12.w,
                                color: ColorsManager.textLight,
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                _formatAppointmentTime(appointment.startTime),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: ColorsManager.textLight,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 8.w),

                _buildStatusBadge(appointment),
              ],
            ),

            if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: ColorsManager.lightBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.w),
                  border: Border.all(
                    color: ColorsManager.primaryBlue.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.note_alt,
                          size: 14.w,
                          color: ColorsManager.primaryBlue,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'Notes',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: ColorsManager.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      appointment.notes!,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: ColorsManager.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 16.h),

            const DecoratedBox(
              decoration: BoxDecoration(color: ColorsManager.lightGray),
              child: SizedBox(height: 1),
            ),

            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(Appointment appointment) {
    final isPast = !appointment.startTime.isAfter(DateTime.now());
    final statusConfig = _getStatusConfig(appointment.status, isPast: isPast);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: statusConfig.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.w),
        border: Border.all(
          color: statusConfig.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusConfig.icon, size: 10.w, color: statusConfig.color),
          SizedBox(width: 2.w),
          Text(
            statusConfig.text,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: statusConfig.color,
            ),
          ),
        ],
      ),
    );
  }

  StatusConfig _getStatusConfig(String status, {bool isPast = false}) {
    final normalizedStatus = status.toLowerCase();

    if (isPast && normalizedStatus == 'pending') {
      return StatusConfig(
        text: 'Finished',
        color: ColorsManager.textSecondary,
        icon: Icons.check,
      );
    }

    switch (normalizedStatus) {
      case 'pending':
        return StatusConfig(
          text: 'Pending',
          color: ColorsManager.warning,
          icon: Icons.schedule,
        );
      case 'confirmed':
        return StatusConfig(
          text: 'Confirmed',
          color: ColorsManager.success,
          icon: Icons.check_circle,
        );
      case 'completed':
        return StatusConfig(
          text: 'Completed',
          color: ColorsManager.primaryBlue,
          icon: Icons.done_all,
        );
      case 'cancelled':
        return StatusConfig(
          text: 'Cancelled',
          color: ColorsManager.error,
          icon: Icons.cancel,
        );
      default:
        return StatusConfig(
          text: 'Unknown',
          color: ColorsManager.textLight,
          icon: Icons.help,
        );
    }
  }

  String _formatAppointmentDate(DateTime date) {
    if (kDebugMode) {
      LoggerService.debug('Formatting appointment date: $date');
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatAppointmentTime(DateTime time) {
    if (kDebugMode) {
      LoggerService.debug('Formatting appointment time: $time');
    }
    final hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12
        ? hour - 12
        : hour == 0
        ? 12
        : hour;
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }
}

class StatusConfig {
  final String text;
  final Color color;
  final IconData icon;

  StatusConfig({required this.text, required this.color, required this.icon});
}
