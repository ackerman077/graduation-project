import 'package:equatable/equatable.dart';

class City extends Equatable {
  final int id;
  final String name;
  final int? governrateId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const City({
    required this.id,
    required this.name,
    this.governrateId,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, name, governrateId, createdAt, updatedAt];

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] is String ? json['name'] : json['name'].toString(),
      governrateId: json['governrate_id'] != null 
          ? (json['governrate_id'] is int 
              ? json['governrate_id'] 
              : int.tryParse(json['governrate_id'].toString()))
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
      'governrate_id': governrateId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'City(id: $id, name: $name)';
  }
}
