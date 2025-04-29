import 'package:flutter/foundation.dart';

@immutable
class Doctor {
  final String id;
  final String facilityId;

  // Para mantener compatibilidad con el código existente
  String get hospitalId => facilityId;
  final String? departmentId;
  final String nameArabic;
  final String? nameEnglish;
  final String specializationArabic;
  final String? specializationEnglish;
  final String? qualification;
  final String? phone;
  final String? email;
  final String? profilePhotoUrl;
  final String? userId; // ID del usuario asociado para inicio de sesión

  // Para mantener compatibilidad con el código existente
  String? get imageUrl => profilePhotoUrl;
  final bool isActive;
  final DateTime createdAt;

  const Doctor({
    required this.id,
    required this.facilityId,
    this.departmentId,
    required this.nameArabic,
    this.nameEnglish,
    required this.specializationArabic,
    this.specializationEnglish,
    this.qualification,
    this.phone,
    this.email,
    this.profilePhotoUrl,
    this.userId,
    required this.isActive,
    required this.createdAt,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id']?.toString() ?? '',
      facilityId: json['facility_id']?.toString() ?? '',
      departmentId: json['department_id']?.toString(),
      nameArabic: json['name_arabic']?.toString() ?? '',
      nameEnglish: json['name_english']?.toString(),
      specializationArabic: json['specialization_arabic']?.toString() ?? '',
      specializationEnglish: json['specialization_english']?.toString(),
      qualification: json['qualification']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      profilePhotoUrl: json['profile_photo_url']?.toString(),
      userId: json['user_id']?.toString(),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'facility_id': facilityId,
      'department_id': departmentId,
      'name_arabic': nameArabic,
      'name_english': nameEnglish,
      'specialization_arabic': specializationArabic,
      'specialization_english': specializationEnglish,
      'qualification': qualification,
      'phone': phone,
      'email': email,
      'profile_photo_url': profilePhotoUrl,
      'user_id': userId,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Doctor copyWith({
    String? id,
    String? facilityId,
    String? departmentId,
    String? nameArabic,
    String? nameEnglish,
    String? specializationArabic,
    String? specializationEnglish,
    String? qualification,
    String? phone,
    String? email,
    String? profilePhotoUrl,
    String? userId,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Doctor(
      id: id ?? this.id,
      facilityId: facilityId ?? this.facilityId,
      departmentId: departmentId ?? this.departmentId,
      nameArabic: nameArabic ?? this.nameArabic,
      nameEnglish: nameEnglish ?? this.nameEnglish,
      specializationArabic: specializationArabic ?? this.specializationArabic,
      specializationEnglish:
          specializationEnglish ?? this.specializationEnglish,
      qualification: qualification ?? this.qualification,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      userId: userId ?? this.userId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Doctor &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          facilityId == other.facilityId &&
          departmentId == other.departmentId &&
          nameArabic == other.nameArabic &&
          nameEnglish == other.nameEnglish &&
          specializationArabic == other.specializationArabic &&
          specializationEnglish == other.specializationEnglish &&
          qualification == other.qualification &&
          phone == other.phone &&
          email == other.email &&
          profilePhotoUrl == other.profilePhotoUrl &&
          userId == other.userId &&
          isActive == other.isActive &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      facilityId.hashCode ^
      departmentId.hashCode ^
      nameArabic.hashCode ^
      nameEnglish.hashCode ^
      specializationArabic.hashCode ^
      specializationEnglish.hashCode ^
      qualification.hashCode ^
      phone.hashCode ^
      email.hashCode ^
      profilePhotoUrl.hashCode ^
      userId.hashCode ^
      isActive.hashCode ^
      createdAt.hashCode;
}
