import 'package:flutter/foundation.dart';

@immutable
class UserProfile {
  final String id;
  final String email;
  final String? fullName;
  final String? phone;
  final String? gender;
  final DateTime? birthDate;
  final String? profilePicture;
  final String? nationalId;
  final String role; // Patient | Doctor | Admin
  final bool isActive;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.email,
    this.fullName,
    this.phone,
    this.gender,
    this.birthDate,
    this.profilePicture,
    this.nationalId,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['full_name']?.toString(),
      phone: json['phone']?.toString(),
      gender: json['gender']?.toString(),
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'].toString())
          : null,
      profilePicture: json['profile_picture']?.toString(),
      nationalId: json['national_id']?.toString(),
      role: json['role']?.toString() ?? 'Patient',
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'gender': gender,
      'birth_date': birthDate?.toIso8601String(),
      'profile_picture': profilePicture,
      'national_id': nationalId,
      'role': role,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    String? gender,
    DateTime? birthDate,
    String? profilePicture,
    String? nationalId,
    String? role,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      profilePicture: profilePicture ?? this.profilePicture,
      nationalId: nationalId ?? this.nationalId,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          fullName == other.fullName &&
          phone == other.phone &&
          gender == other.gender &&
          birthDate == other.birthDate &&
          profilePicture == other.profilePicture &&
          nationalId == other.nationalId &&
          role == other.role &&
          isActive == other.isActive &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      email.hashCode ^
      fullName.hashCode ^
      phone.hashCode ^
      gender.hashCode ^
      birthDate.hashCode ^
      profilePicture.hashCode ^
      nationalId.hashCode ^
      role.hashCode ^
      isActive.hashCode ^
      createdAt.hashCode;
}
