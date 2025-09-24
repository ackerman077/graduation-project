import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../services/logger_service.dart';

class Appointment extends Equatable {
  final int id;
  final int doctorId;
  final String doctorName;
  final String? doctorImage;
  final String? doctorSpecialization;
  final DateTime startTime;
  final String? notes;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Appointment({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    this.doctorImage,
    this.doctorSpecialization,
    required this.startTime,
    this.notes,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    doctorId,
    doctorName,
    doctorImage,
    doctorSpecialization,
    startTime,
    notes,
    status,
    createdAt,
    updatedAt,
  ];

  factory Appointment.fromJson(Map<String, dynamic> json) {
    try {
      if (kDebugMode) {
        LoggerService.debug('Parsing JSON: $json', 'Appointment');
      }

      final doctorId =
          json['doctor']?['id']?.toInt() ?? json['doctor_id']?.toInt() ?? 0;
      final doctorName =
          json['doctor']?['name']?.toString() ??
          json['doctor_name']?.toString() ??
          'Unknown Doctor';
      final doctorImage =
          json['doctor']?['photo']?.toString() ??
          json['doctor']?['image']?.toString() ??
          json['doctor_image']?.toString();

      if (kDebugMode) {
        LoggerService.debug(
          'Extracted: doctorId=$doctorId, doctorName="$doctorName", doctorImage="$doctorImage"',
        );
      }

      return Appointment(
        id: json['id']?.toInt() ?? 0,
        doctorId: doctorId,
        doctorName: doctorName,
        doctorImage: doctorImage,
        doctorSpecialization:
            json['doctor']?['specialization']?['name']?.toString() ??
            json['doctor_specialization']?.toString(),
        startTime: _parseAppointmentTime(
          json['appointment_time'] ??
              json['start_time'] ??
              json['datetime'] ??
              json['appointment_date'] ??
              json['date'] ??
              json['time'],
          json['id']?.toInt() ?? 0,
        ),
        notes: json['notes']?.toString(),
        status: json['status']?.toString() ?? 'pending',
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'].toString())
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'].toString())
            : null,
      );
    } catch (e) {
      if (kDebugMode) {
        LoggerService.error('Error parsing appointment: $e');
      }
      return Appointment(
        id: json['id']?.toInt() ?? 0,
        doctorId:
            json['doctor']?['id']?.toInt() ?? json['doctor_id']?.toInt() ?? 0,
        doctorName: 'Unknown Doctor',
        startTime: DateTime.now(),
        status: 'pending',
      );
    }
  }

  static int _getMonthNumber(String monthName) {
    const months = {
      'January': 1,
      'February': 2,
      'March': 3,
      'April': 4,
      'May': 5,
      'June': 6,
      'July': 7,
      'August': 8,
      'September': 9,
      'October': 10,
      'November': 11,
      'December': 12,
    };
    final result = months[monthName] ?? 1;
    if (kDebugMode) {
      LoggerService.debug('Month "$monthName" -> $result');
    }
    return result;
  }

  static DateTime _parseAppointmentTime(String? timeStr, int appointmentId) {
    if (timeStr == null) {
      if (kDebugMode) {
        LoggerService.error('Appointment time is null, using fallback');
      }
      return DateTime.now();
    }

    if (kDebugMode) {
      LoggerService.debug('Parsing time: $timeStr', 'Appointment');
    }

    try {
      final result = DateTime.parse(timeStr);
      if (kDebugMode) {
        LoggerService.debug('Successfully parsed ISO format: $result');
      }
      return result;
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('ISO format failed, trying custom format: $e');
      }

      try {
        if (kDebugMode) {
          LoggerService.debug('Attempting to parse: "$timeStr"');
        }

        final parts = timeStr.split(', ');
        if (kDebugMode) {
          LoggerService.debug('Split parts: $parts');
        }

        if (parts.length >= 3) {
          final datePart = parts[1].trim();
          final timePart = parts[2].trim();

          if (kDebugMode) {
            LoggerService.debug('Parsing date part: "$datePart"');
            LoggerService.debug('Parsing time part: "$timePart"');
          }

          final dateParts = datePart.split(' ');
          if (dateParts.length >= 2) {
            final month = dateParts[0];
            final day = int.parse(dateParts[1]);

            final timeParts = timePart.split(' ');
            if (timeParts.length >= 3) {
              final year = int.parse(timeParts[0]);
              final timeStr = timeParts[1];
              final period = timeParts[2];

              if (kDebugMode) {
                LoggerService.debug(
                  'Parsed date: year=$year, month=$month, day=$day',
                );
                LoggerService.debug('Month number: ${_getMonthNumber(month)}');
                LoggerService.debug('Parsing time: $timeStr $period');
              }

              final timeComponents = timeStr.split(':');
              if (timeComponents.length >= 2) {
                var hour = int.parse(timeComponents[0]);
                final minute = int.parse(timeComponents[1]);

                if (period == 'PM' && hour != 12) hour += 12;
                if (period == 'AM' && hour == 12) hour = 0;

                if (kDebugMode) {
                  LoggerService.debug(
                    'Parsed time: hour=$hour, minute=$minute, period=$period',
                  );
                }

                final result = DateTime(
                  year,
                  _getMonthNumber(month),
                  day,
                  hour,
                  minute,
                );
                if (kDebugMode) {
                  LoggerService.debug(
                    'Successfully parsed custom format: $result',
                  );
                }
                return result;
              }
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          LoggerService.error('Failed to parse custom time format: $e');
          LoggerService.error('Input string: "$timeStr"');
        }
      }

      try {
        if (timeStr.contains(' ') && timeStr.contains('-')) {
          final result = DateTime.parse(timeStr.replaceAll(' ', 'T'));
          if (kDebugMode) {
            LoggerService.debug('Successfully parsed MySQL format: $result');
          }
          return result;
        }
      } catch (e) {
        if (kDebugMode) {
          LoggerService.debug('MySQL format failed: $e');
        }
      }

      try {
        final dateRegex = RegExp(r'(\d{4})-(\d{1,2})-(\d{1,2})');
        final match = dateRegex.firstMatch(timeStr);
        if (match != null) {
          final year = int.parse(match.group(1)!);
          final month = int.parse(match.group(2)!);
          final day = int.parse(match.group(3)!);
          final result = DateTime(year, month, day);
          if (kDebugMode) {
            LoggerService.debug('Successfully parsed regex pattern: $result');
          }
          return result;
        }
      } catch (e) {
        if (kDebugMode) {
          LoggerService.debug('Regex pattern failed: $e');
        }
      }

      if (kDebugMode) {
        LoggerService.error('All time parsing attempts failed for: "$timeStr"');
        LoggerService.error('Using unique fallback based on appointment ID');
      }

      final fallbackTime = DateTime.now().add(
        Duration(days: appointmentId % 30),
      );
      return fallbackTime;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'doctor_image': doctorImage,
      'doctor_specialization': doctorSpecialization,
      'start_time': startTime.toIso8601String(),
      'notes': notes,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Appointment(id: $id, doctor: $doctorName, time: $startTime, status: $status)';
  }
}
