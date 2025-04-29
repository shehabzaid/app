import 'package:flutter/foundation.dart';

@immutable
class Department {
  final String id;
  final String hospitalId;
  final String nameArabic;
  final String? nameEnglish;
  final String? descriptionArabic;
  final String? descriptionEnglish;
  final bool isActive;
  final DateTime createdAt;

  const Department({
    required this.id,
    required this.hospitalId,
    required this.nameArabic,
    this.nameEnglish,
    this.descriptionArabic,
    this.descriptionEnglish,
    required this.isActive,
    required this.createdAt,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'] as String,
      hospitalId:
          json['facility_id'] as String, // تغيير من hospital_id إلى facility_id
      nameArabic: json['name_arabic'] as String,
      nameEnglish: json['name_english'] as String?,
      descriptionArabic: json['description_arabic'] as String?,
      descriptionEnglish: json['description_english'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'facility_id': hospitalId, // تغيير من hospital_id إلى facility_id
      'name_arabic': nameArabic,
      'name_english': nameEnglish,
      'description_arabic': descriptionArabic,
      'description_english': descriptionEnglish,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
