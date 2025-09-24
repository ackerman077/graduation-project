import 'package:json_annotation/json_annotation.dart';

part 'login_response.g.dart';

@JsonSerializable()
class LoginResponse {
  @JsonKey(name: 'status')
  final bool status;

  @JsonKey(name: 'message')
  final String? message;

  @JsonKey(name: 'code')
  final int code;

  @JsonKey(name: 'data')
  final LoginData? data;

  const LoginResponse({
    required this.status,
    this.message,
    required this.code,
    this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);

  bool get isSuccess => status;
  bool get isError => !status;

  String? get username => data?.username;
  String? get token => data?.token;
}

@JsonSerializable()
class LoginData {
  @JsonKey(name: 'username')
  final String username;

  @JsonKey(name: 'token')
  final String token;

  const LoginData({required this.username, required this.token});

  factory LoginData.fromJson(Map<String, dynamic> json) =>
      _$LoginDataFromJson(json);

  Map<String, dynamic> toJson() => _$LoginDataToJson(this);
}
