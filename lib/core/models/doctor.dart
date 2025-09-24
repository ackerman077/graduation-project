import 'package:equatable/equatable.dart';
import 'specialization.dart';
import 'city.dart';

class Doctor extends Equatable {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? image;
  final String? bio;
  final String? description;
  final String? degree;
  final String? experience;
  final String? education;
  final String? languages;
  final String? address;
  final String? gender;
  final double? rating;
  final int? reviewCount;
  final double? appointPrice;
  final String? startTime;
  final String? endTime;
  final bool isAvailable;
  final Specialization? specialization;
  final City? city;
  final String? governrate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Doctor({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.image,
    this.bio,
    this.description,
    this.degree,
    this.experience,
    this.education,
    this.languages,
    this.address,
    this.gender,
    this.rating,
    this.reviewCount,
    this.appointPrice,
    this.startTime,
    this.endTime,
    this.isAvailable = true,
    this.specialization,
    this.city,
    this.governrate,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phone,
    image,
    bio,
    description,
    degree,
    experience,
    education,
    languages,
    address,
    gender,
    rating,
    reviewCount,
    appointPrice,
    startTime,
    endTime,
    isAvailable,
    specialization,
    city,
    governrate,
    createdAt,
    updatedAt,
  ];

  factory Doctor.fromJson(Map<String, dynamic> json) {
    try {
      return Doctor(
        id: json['id'] is int
            ? json['id']
            : int.tryParse(json['id'].toString()) ?? 0,
        name: json['name'] is String ? json['name'] : json['name'].toString(),
        email: json['email']?.toString(),
        phone: json['phone']?.toString(),
        image:
            json['image']?.toString() ??
            json['photo']?.toString() ??
            json['picture']?.toString(),
        bio: json['bio']?.toString(),
        description: json['description']?.toString(),
        degree: json['degree']?.toString(),
        experience: json['experience']?.toString(),
        education: json['education']?.toString(),
        languages: json['languages']?.toString(),
        address: json['address']?.toString(),
        gender: json['gender']?.toString(),
        rating: json['rating'] != null
            ? (json['rating'] is double
                  ? json['rating']
                  : double.tryParse(json['rating'].toString()) ?? 0.0)
            : null,
        reviewCount: json['review_count'] ?? json['reviews_count'],
        appointPrice: json['appoint_price'] != null
            ? (json['appoint_price'] is double
                  ? json['appoint_price']
                  : double.tryParse(json['appoint_price'].toString()) ?? 0.0)
            : null,
        startTime: json['start_time']?.toString(),
        endTime: json['end_time']?.toString(),
        isAvailable: json['is_available'] ?? true,
        specialization: json['specialization'] != null
            ? (json['specialization'] is Map<String, dynamic>
                  ? Specialization.fromJson(json['specialization'])
                  : null)
            : null,
        city: json['city'] is Map ? City.fromJson(json['city']) : null,
        governrate: json['governrate'] is Map
            ? json['governrate']['name']?.toString()
            : json['governrate_name']?.toString() ??
                  json['governrate']?.toString(),
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString())
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'].toString())
            : null,
      );
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'image': image,
      'bio': bio,
      'description': description,
      'degree': degree,
      'experience': experience,
      'education': education,
      'languages': languages,
      'address': address,
      'gender': gender,
      'rating': rating,
      'review_count': reviewCount,
      'appoint_price': appointPrice,
      'start_time': startTime,
      'end_time': endTime,
      'is_available': isAvailable,
      'specialization': specialization?.toJson(),
      'city': city?.toJson(),
      'governrate': governrate,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Doctor(id: $id, name: $name, specialization: ${specialization?.name})';
  }
}
