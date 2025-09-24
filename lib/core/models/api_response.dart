import 'package:equatable/equatable.dart';

class ApiResponse<T> extends Equatable {
  final String? message;
  final T? data;
  final bool status;
  final int code;

  const ApiResponse({
    this.message,
    this.data,
    required this.status,
    required this.code,
  });

  @override
  List<Object?> get props => [message, data, status, code];

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    return ApiResponse<T>(
      message: json['message'],
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
    );
  }

  factory ApiResponse.success(T data, {String? message, int code = 200}) {
    return ApiResponse<T>(
      message: message ?? 'Success',
      data: data,
      status: true,
      code: code,
    );
  }

  factory ApiResponse.error(String? message, {int code = 400, T? data}) {
    return ApiResponse<T>(
      message: message,
      data: data,
      status: false,
      code: code,
    );
  }

  bool get isSuccess => status;
  bool get isError => !status;
}
