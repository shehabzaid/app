import 'package:flutter/foundation.dart';

@immutable
class Review {
  final String id;
  final String patientId;
  final String doctorId;
  final int rating; // 1-5
  final String? comment;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id']?.toString() ?? '',
      patientId: json['patient_id']?.toString() ?? '',
      doctorId: json['doctor_id']?.toString() ?? '',
      rating: json['rating'] as int? ?? 0,
      comment: json['comment']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Review copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    int? rating,
    String? comment,
    DateTime? createdAt,
  }) {
    return Review(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
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
          rating == other.rating &&
          comment == other.comment &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      patientId.hashCode ^
      doctorId.hashCode ^
      rating.hashCode ^
      comment.hashCode ^
      createdAt.hashCode;
}
