
part of 'profile_update_request.dart';


ProfileUpdateRequest _$ProfileUpdateRequestFromJson(
  Map<String, dynamic> json,
) => ProfileUpdateRequest(
  name: json['name'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String,
  gender: (json['gender'] as num).toInt(),
);

Map<String, dynamic> _$ProfileUpdateRequestToJson(
  ProfileUpdateRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'email': instance.email,
  'phone': instance.phone,
  'gender': instance.gender,
};
