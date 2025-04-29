import 'package:flutter/foundation.dart';

@immutable
class Review {
  final String id;
  final String patientId;
  final String doctorId;
  final String? appointmentId; // معرف الموعد المرتبط بالتقييم
  final int rating; // 1-5
  final String? comment;
  final bool isApproved; // هل تم اعتماد التقييم للعرض
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Review({
    required this.id,
    required this.patientId,
    required this.doctorId,
    this.appointmentId,
    required this.rating,
    this.comment,
    this.isApproved = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id']?.toString() ?? '',
      patientId: json['patient_id']?.toString() ?? '',
      doctorId: json['doctor_id']?.toString() ?? '',
      appointmentId: json['appointment_id']?.toString(),
      rating: json['rating'] as int? ?? 0,
      comment: json['comment']?.toString(),
      isApproved: json['is_approved'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'rating': rating,
      'is_approved': isApproved,
      'created_at': createdAt.toIso8601String(),
    };

    // إضافة التعليق إذا كان موجودًا
    if (comment != null && comment!.isNotEmpty) {
      data['comment'] = comment;
    }

    // إضافة معرف الموعد إذا كان موجودًا
    if (appointmentId != null && appointmentId!.isNotEmpty) {
      data['appointment_id'] = appointmentId;
    }

    // إضافة تاريخ التحديث إذا كان موجودًا
    if (updatedAt != null) {
      data['updated_at'] = updatedAt!.toIso8601String();
    }

    return data;
  }

  Review copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    String? appointmentId,
    int? rating,
    String? comment,
    bool? isApproved,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Review(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      appointmentId: appointmentId ?? this.appointmentId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Review &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          patientId == other.patientId &&
          doctorId == other.doctorId &&
          appointmentId == other.appointmentId &&
          rating == other.rating &&
          comment == other.comment &&
          isApproved == other.isApproved &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      patientId.hashCode ^
      doctorId.hashCode ^
      appointmentId.hashCode ^
      rating.hashCode ^
      comment.hashCode ^
      isApproved.hashCode ^
      createdAt.hashCode ^
      (updatedAt?.hashCode ?? 0);
}
