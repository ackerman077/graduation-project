import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theming/app_theme.dart';
import '../../../../core/widgets/app_loading_widget.dart';
import '../../../../core/widgets/doctor_image_widget.dart';
import '../../cubit/appointments_cubit.dart';
import '../../../../core/models/doctor.dart';
import '../../../../core/services/logger_service.dart';

class BookingAppointmentScreen extends StatefulWidget {
  final Doctor doctor;

  const BookingAppointmentScreen({super.key, required this.doctor});

  @override
  State<BookingAppointmentScreen> createState() =>
      _BookingAppointmentScreenState();
}

class _BookingAppointmentScreenState extends State<BookingAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _currentStep = 0;
  late DateTime _currentMonth;

  final List<TimeOfDay> _availableTimeSlots = const [
    TimeOfDay(hour: 9, minute: 0),
    TimeOfDay(hour: 10, minute: 0),
    TimeOfDay(hour: 11, minute: 0),
    TimeOfDay(hour: 12, minute: 0),
    TimeOfDay(hour: 13, minute: 0),
    TimeOfDay(hour: 14, minute: 0),
    TimeOfDay(hour: 15, minute: 0),
    TimeOfDay(hour: 16, minute: 0),
    TimeOfDay(hour: 17, minute: 0),
  ];

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: _buildAppBar(),
      body: BlocConsumer<AppointmentsCubit, AppointmentsState>(
        listener: (context, state) {
          if (state is AppointmentBooked) {
            Navigator.of(context).pop();
            _showSuccessDialog();
          } else if (state is AppointmentsError) {
            Navigator.of(context).pop();
            _showErrorDialog(state.message);
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStepIndicator(),
                      SizedBox(height: 20.h),

                      _buildDoctorInfo(),
                      SizedBox(height: 20.h),

                      if (_currentStep == 0) ...[
                        _buildDateSelectionStep(),
                      ] else if (_currentStep == 1) ...[
                        _buildTimeSelectionStep(),
                      ] else if (_currentStep == 2) ...[
                        _buildNotesStep(),
                      ] else if (_currentStep == 3) ...[
                        _buildConfirmationStep(),
                      ],

                      SizedBox(height: 20.h),

                      _buildNavigationButtons(),
                    ],
                  ),
                ),
              ),

              if (state is AppointmentsLoading) const AppLoadingWidget(),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios,
          color: ColorsManager.textPrimary,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Book Appointment',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: ColorsManager.textPrimary,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStepItem(0, 'Date', Icons.calendar_today),
          _buildStepConnector(),
          _buildStepItem(1, 'Time', Icons.access_time),
          _buildStepConnector(),
          _buildStepItem(2, 'Notes', Icons.note),
          _buildStepConnector(),
          _buildStepItem(3, 'Confirm', Icons.check_circle),
        ],
      ),
    );
  }

  Widget _buildStepItem(int step, String label, IconData icon) {
    final isActive = _currentStep == step;
    final isCompleted = _currentStep > step;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: isCompleted
                  ? ColorsManager.success
                  : isActive
                  ? ColorsManager.primaryBlue
                  : ColorsManager.lightGray,
              borderRadius: BorderRadius.circular(20.w),
            ),
            child: Icon(
              icon,
              size: 20.w,
              color: isCompleted || isActive
                  ? Colors.white
                  : ColorsManager.textLight,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive
                  ? ColorsManager.primaryBlue
                  : ColorsManager.textLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector() {
    return Container(
      width: 20.w,
      height: 2.h,
      color: _currentStep > 0 ? ColorsManager.success : ColorsManager.lightGray,
    );
  }

  Widget _buildDoctorInfo() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
              borderRadius: BorderRadius.circular(30.w),
              border: Border.all(
                color: ColorsManager.primaryBlue.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30.w),
              child: DoctorImageWidget(
                networkImageUrl: widget.doctor.image,
                doctorId: widget.doctor.id,
                width: 60.w,
                height: 60.w,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(30.w),
                errorWidget: Icon(
                  Icons.person,
                  size: 30.w,
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
                  widget.doctor.name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: ColorsManager.textPrimary,
                  ),
                ),

                SizedBox(height: 3.h),

                if (widget.doctor.specialization?.name != null) ...[
                  Text(
                    widget.doctor.specialization!.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: ColorsManager.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                ],

                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16.w,
                      color: ColorsManager.textLight,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${widget.doctor.city?.name ?? ''}, ${widget.doctor.governrate ?? ''}',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: ColorsManager.textLight,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8.h),

                if (widget.doctor.appointPrice != null) ...[
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: ColorsManager.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.w),
                    ),
                    child: Text(
                      'Consultation: \$${widget.doctor.appointPrice!.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: ColorsManager.success,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelectionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Appointment Date',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: ColorsManager.textPrimary,
          ),
        ),

        SizedBox(height: 12.h),

        Text(
          'Choose a date for your appointment',
          style: TextStyle(fontSize: 14.sp, color: ColorsManager.textSecondary),
        ),

        SizedBox(height: 16.h),

        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.w),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _currentMonth = DateTime(
                          _currentMonth.year,
                          _currentMonth.month - 1,
                          1,
                        );
                        if (_selectedDate != null &&
                            (_selectedDate!.month != _currentMonth.month ||
                                _selectedDate!.year != _currentMonth.year)) {
                          _selectedDate = null;
                        }
                      });
                    },
                    icon: const Icon(
                      Icons.chevron_left,
                      color: ColorsManager.primaryBlue,
                    ),
                  ),
                  Text(
                    DateFormat('MMMM yyyy').format(_currentMonth),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: ColorsManager.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _currentMonth = DateTime(
                          _currentMonth.year,
                          _currentMonth.month + 1,
                          1,
                        );
                        if (_selectedDate != null &&
                            (_selectedDate!.month != _currentMonth.month ||
                                _selectedDate!.year != _currentMonth.year)) {
                          _selectedDate = null;
                        }
                      });
                    },
                    icon: const Icon(
                      Icons.chevron_right,
                      color: ColorsManager.primaryBlue,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children:
                    const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                        .map(
                          (day) => Expanded(
                            child: Text(
                              day,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: ColorsManager.textLight,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                        .toList(),
              ),

              const SizedBox(height: 12),

              _buildCalendarGrid(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    final daysInMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    ).day;
    final firstWeekday = firstDayOfMonth.weekday;
    final daysToShowBefore = (firstWeekday - 1) % 7;

    final totalItems = daysToShowBefore + daysInMonth;
    final gridRows = ((totalItems - 1) ~/ 7) + 1;
    final totalGridItems = gridRows * 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
      ),
      itemCount: totalGridItems,
      itemBuilder: (context, index) {
        final adjustedIndex = index - daysToShowBefore;
        final day = adjustedIndex + 1;
        final isCurrentMonth = adjustedIndex >= 0 && day <= daysInMonth;
        final isSelected =
            _selectedDate != null &&
            _selectedDate!.day == day &&
            _selectedDate!.month == _currentMonth.month &&
            _selectedDate!.year == _currentMonth.year;
        final isToday =
            day == DateTime.now().day &&
            _currentMonth.month == DateTime.now().month &&
            _currentMonth.year == DateTime.now().year;

        if (!isCurrentMonth) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = DateTime(
                _currentMonth.year,
                _currentMonth.month,
                day,
              );
            });
          },
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isSelected
                  ? ColorsManager.primaryBlue
                  : isToday
                  ? ColorsManager.lightBlue.withValues(alpha: 0.3)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8.w),
              border: isToday
                  ? Border.all(color: ColorsManager.primaryBlue, width: 1)
                  : null,
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : isToday
                      ? ColorsManager.primaryBlue
                      : ColorsManager.textPrimary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeSelectionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Appointment Time',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: ColorsManager.textPrimary,
          ),
        ),

        SizedBox(height: 12.h),

        Text(
          'Choose a convenient time slot',
          style: TextStyle(fontSize: 14.sp, color: ColorsManager.textSecondary),
        ),

        SizedBox(height: 16.h),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2.2,
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 10.h,
          ),
          itemCount: _availableTimeSlots.length,
          itemBuilder: (context, index) {
            final timeSlot = _availableTimeSlots[index];
            final isSelected = _selectedTime == timeSlot;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTime = timeSlot;
                });
              },
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: isSelected ? ColorsManager.primaryBlue : Colors.white,
                  borderRadius: BorderRadius.circular(12.w),
                  border: Border.all(
                    color: isSelected
                        ? ColorsManager.primaryBlue
                        : ColorsManager.inputBorder,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _formatTimeOfDay(timeSlot),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : ColorsManager.textPrimary,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNotesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Notes',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: ColorsManager.textPrimary,
          ),
        ),

        SizedBox(height: 12.h),

        Text(
          'Add any special requirements or notes for your appointment',
          style: TextStyle(fontSize: 14.sp, color: ColorsManager.textSecondary),
        ),

        SizedBox(height: 16.h),

        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.w),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    'Enter any special requirements, symptoms, or notes...',
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: ColorsManager.textLight,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.w),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: EdgeInsets.all(16.w),
              ),
              style: TextStyle(
                fontSize: 14.sp,
                color: ColorsManager.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confirm Appointment',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: ColorsManager.textPrimary,
          ),
        ),

        SizedBox(height: 12.h),

        Text(
          'Review your appointment details before confirming',
          style: TextStyle(fontSize: 14.sp, color: ColorsManager.textSecondary),
        ),

        SizedBox(height: 16.h),

        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.w),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                _buildSummaryRow('Doctor', widget.doctor.name),
                _buildSummaryRow(
                  'Specialty',
                  widget.doctor.specialization?.name ?? 'N/A',
                ),
                _buildSummaryRow(
                  'Date',
                  _selectedDate != null
                      ? DateFormat('EEEE, MMMM d, y').format(_selectedDate!)
                      : 'Not selected',
                ),
                _buildSummaryRow(
                  'Time',
                  _selectedTime != null
                      ? _formatTimeOfDay(_selectedTime!)
                      : 'Not selected',
                ),
                if (widget.doctor.appointPrice != null)
                  _buildSummaryRow(
                    'Fee',
                    '\$${widget.doctor.appointPrice!.toStringAsFixed(0)}',
                  ),
                if (_notesController.text.isNotEmpty)
                  _buildSummaryRow('Notes', _notesController.text),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: ColorsManager.textLight,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: ColorsManager.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        if (_currentStep > 0) ...[
          Expanded(
            child: SizedBox(
              height: 56.h,
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _currentStep--;
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: ColorsManager.primaryBlue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.w),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Back',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: ColorsManager.primaryBlue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
        ],

        Expanded(
          child: SizedBox(
            height: 56.h,
            child: ElevatedButton(
              onPressed: _canProceedToNextStep() ? _handleNextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsManager.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.w),
                ),
              ),
              child: Center(
                child: Text(
                  _currentStep == 3 ? 'Confirm Booking' : 'Next',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _canProceedToNextStep() {
    switch (_currentStep) {
      case 0:
        return _selectedDate != null;
      case 1:
        return _selectedTime != null;
      case 2:
        return true;
      case 3:
        return true;
      default:
        return false;
    }
  }

  void _handleNextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    } else {
      _confirmBooking();
    }
  }

  void _confirmBooking() {
    if (_selectedDate == null || _selectedTime == null) {
      _showErrorDialog('Please select both date and time');
      return;
    }

    final appointmentDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    try {
      LoggerService.debug(
        '🔄 [BookingAppointmentScreen] Attempting to book appointment...',
      );
      LoggerService.debug(
        '🔄 [BookingAppointmentScreen] Doctor ID: ${widget.doctor.id}',
      );
      LoggerService.debug(
        '🔄 [BookingAppointmentScreen] Date: $appointmentDateTime',
      );

      final cubit = context.read<AppointmentsCubit>();
      LoggerService.debug(
        '🔄 [BookingAppointmentScreen] Cubit accessed successfully: ${cubit.runtimeType}',
      );

      try {
        _showLoadingDialog(
          'Booking appointment...\nTrying different data formats...',
        );

        cubit.bookAppointment(
          doctorId: widget.doctor.id,
          startTime: appointmentDateTime,
          notes: _notesController.text.isNotEmpty
              ? _notesController.text
              : null,
        );
      } catch (e) {
        LoggerService.error('Error calling bookAppointment: $e');
        _showErrorDialog('Failed to book appointment. Please try again.');
        return;
      }

      LoggerService.debug(
        '🔄 [BookingAppointmentScreen] Appointment booking initiated',
      );
    } catch (e) {
      LoggerService.error('Error accessing AppointmentsCubit: $e');
      _showErrorDialog('Failed to book appointment. Please try again.');
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.w),
        ),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: ColorsManager.success, size: 24.w),
            SizedBox(width: 12.w),
            Text(
              'Success!',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: ColorsManager.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          'Your appointment has been booked successfully!',
          style: TextStyle(fontSize: 14.sp, color: ColorsManager.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              'OK',
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

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.w),
        ),
        title: Row(
          children: [
            SizedBox(
              width: 24.w,
              height: 24.w,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  ColorsManager.primaryBlue,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'Processing...',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: ColorsManager.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(fontSize: 16.sp, color: ColorsManager.textSecondary),
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.w),
        ),
        title: Row(
          children: [
            Icon(Icons.error, color: ColorsManager.error, size: 24.w),
            SizedBox(width: 12.w),
            Text(
              'Error',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: ColorsManager.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(fontSize: 14.sp, color: ColorsManager.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
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
}
