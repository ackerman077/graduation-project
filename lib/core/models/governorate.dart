import 'package:equatable/equatable.dart';

class Governorate extends Equatable {
  final int id;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Governorate({
    required this.id,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, name, createdAt, updatedAt];

  factory Governorate.fromJson(Map<String, dynamic> json) {
    return Governorate(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] is String ? json['name'] : json['name'].toString(),
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
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Governorate(id: $id, name: $name)';
  }
}
