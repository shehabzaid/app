import 'package:flutter/foundation.dart';

@immutable
class MedicalRecord {
  final String id;
  final String patientId;
  final String? doctorId;
  final String? facilityId;
  final String diagnosis;
  final String treatmentPlan;
  final String? medications;
  final List<String>? attachmentsUrls;
  final DateTime createdAt;

  const MedicalRecord({
    required this.id,
    required this.patientId,
    this.doctorId,
    this.facilityId,
    required this.diagnosis,
    required this.treatmentPlan,
    this.medications,
    this.attachmentsUrls,
    required this.createdAt,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    List<String> attachments = [];
    if (json['attachments_urls'] != null) {
      if (json['attachments_urls'] is List) {
        attachments = (json['attachments_urls'] as List)
            .map((e) => e.toString())
            .toList();
      }
    }

    return MedicalRecord(
      id: json['id']?.toString() ?? '',
      patientId: json['patient_id']?.toString() ?? '',
      doctorId: json['doctor_id']?.toString(),
      facilityId: json['facility_id']?.toString(),
      diagnosis: json['diagnosis']?.toString() ?? '',
      treatmentPlan: json['treatment_plan']?.toString() ?? '',
      medications: json['medications']?.toString(),
      attachmentsUrls: attachments,
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
      'facility_id': facilityId,
      'diagnosis': diagnosis,
      'treatment_plan': treatmentPlan,
      'medications': medications,
      'attachments_urls': attachmentsUrls,
      'created_at': createdAt.toIso8601String(),
    };
  }

  MedicalRecord copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    String? facilityId,
    String? diagnosis,
    String? treatmentPlan,
    String? medications,
    List<String>? attachmentsUrls,
    DateTime? createdAt,
  }) {
    return MedicalRecord(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      facilityId: facilityId ?? this.facilityId,
      diagnosis: diagnosis ?? this.diagnosis,
      treatmentPlan: treatmentPlan ?? this.treatmentPlan,
      medications: medications ?? this.medications,
      attachmentsUrls: attachmentsUrls ?? this.attachmentsUrls,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicalRecord &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          patientId == other.patientId &&
          doctorId == other.doctorId &&
          facilityId == other.facilityId &&
          diagnosis == other.diagnosis &&
          treatmentPlan == other.treatmentPlan &&
          medications == other.medications &&
          attachmentsUrls == other.attachmentsUrls &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      patientId.hashCode ^
      doctorId.hashCode ^
      facilityId.hashCode ^
      diagnosis.hashCode ^
      treatmentPlan.hashCode ^
      medications.hashCode ^
      attachmentsUrls.hashCode ^
      createdAt.hashCode;
}
