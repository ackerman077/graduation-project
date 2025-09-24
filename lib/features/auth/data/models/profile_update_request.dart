import 'package:json_annotation/json_annotation.dart';

part 'profile_update_request.g.dart';

@JsonSerializable()
class ProfileUpdateRequest {
  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'email')
  final String email;

  @JsonKey(name: 'phone')
  final String phone;

  @JsonKey(name: 'gender')
  final int gender;

  const ProfileUpdateRequest({
    required this.name,
    required this.email,
    required this.phone,
    required this.gender,
  });

  factory ProfileUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$ProfileUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileUpdateRequestToJson(this);

  Map<String, dynamic> toFormData() {
    return {'name': name, 'email': email, 'phone': phone, 'gender': gender};
  }

  static Map<String, dynamic> getNamePhoneUpdate({
    required String newName,
    required String newPhone,
    required int currentGender,
    required String currentEmail,
    required int
    userId,
  }) {
    return {
      'id': userId,
      'name': newName,
      'phone': newPhone,
      'gender': currentGender,
      'email': currentEmail,
    };
  }

  static Map<String, dynamic> getNameUpdate({
    required String newName,
    required String currentPhone,
    required int currentGender,
    required String currentEmail,
    required int
    userId,
  }) {
    return {
      'id': userId,
      'name': newName,
      'phone': currentPhone,
      'gender': currentGender,
      'email': currentEmail,
    };
  }

  static Map<String, dynamic> getPhoneUpdate({
    required String currentName,
    required String newPhone,
    required int currentGender,
    required String currentEmail,
    required int
    userId,
  }) {
    return {
      'id': userId,
      'name': currentName,
      'phone': newPhone,
      'gender': currentGender,
      'email': currentEmail,
    };
  }

  static Map<String, dynamic> getChangedFields({
    required String currentName,
    required String currentEmail,
    required String currentPhone,
    required int currentGender,
    required String newName,
    required String newEmail,
    required String newPhone,
    required int newGender,
  }) {
    final Map<String, dynamic> updates = <String, dynamic>{};

    if (newName != currentName) {
      updates['name'] = newName;
    }
    if (newEmail != currentEmail) {
      updates['email'] = newEmail;
    }
    if (newPhone != currentPhone) {
      updates['phone'] = newPhone;
    }
    if (newGender != currentGender) {
      updates['gender'] = newGender;
    }

    return updates;
  }

  @override
  String toString() {
    return 'ProfileUpdateRequest{name: $name, email: $email, phone: $phone, gender: $gender}';
  }
}
