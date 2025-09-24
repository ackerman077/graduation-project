import 'package:equatable/equatable.dart';
import 'doctor.dart';

class Specialization extends Equatable {
  final int id;
  final String name;
  final String? description;
  final String? image;
  final List<Doctor>? doctors;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Specialization({
    required this.id,
    required this.name,
    this.description,
    this.image,
    this.doctors,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    image,
    doctors,
    createdAt,
    updatedAt,
  ];

  factory Specialization.fromJson(Map<String, dynamic> json) {
    return Specialization(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] is String ? json['name'] : json['name'].toString(),
      description: json['description']?.toString(),
      image: json['image']?.toString(),
      doctors: json['doctors'] != null
          ? (json['doctors'] as List)
                .map((doctorJson) => Doctor.fromJson(doctorJson))
                .toList()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Specialization(id: $id, name: $name, description: $description)';
  }
}
