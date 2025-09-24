import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

@JsonSerializable()
class UserProfile {
  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'email')
  final String email;

  @JsonKey(name: 'phone')
  final String phone;

  @JsonKey(name: 'gender')
  final String gender;

  @JsonKey(name: 'image')
  final String? image;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.gender,
    this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);

  UserProfile copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? gender,
    String? image,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      image: image ?? this.image,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  int get genderAsInt {
    final genderStr = gender.toLowerCase();
    return genderStr == 'male' ? 0 : 1;
  }

  String get genderAsString {
    return gender.substring(0, 1).toUpperCase() + gender.substring(1).toLowerCase();
  }

  static String genderToBackend(String gender) {
    return gender.toLowerCase();
  }

  @override
  String toString() {
    return 'UserProfile{id: $id, name: $name, email: $email, phone: $phone, gender: $gender}';
  }
}
