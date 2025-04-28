import 'package:flutter/foundation.dart';

@immutable
class Appointment {
  final String id;
  final String patientId;
  final String? doctorId;
  final String facilityId;
  final String? departmentId;
  final DateTime appointmentDate;
  final String appointmentTime;
  final bool isVirtual;
  final String status; // Pending | Confirmed | Cancelled | Completed
  final String? notes;
  final DateTime createdAt;

  const Appointment({
    required this.id,
    required this.patientId,
    this.doctorId,
    required this.facilityId,
    this.departmentId,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.isVirtual,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id']?.toString() ?? '',
      patientId: json['patient_id']?.toString() ?? '',
      doctorId: json['doctor_id']?.toString(),
      facilityId: json['facility_id']?.toString() ?? '',
      departmentId: json['department_id']?.toString(),
      appointmentDate: json['appointment_date'] != null
          ? DateTime.parse(json['appointment_date'].toString())
          : DateTime.now(),
      appointmentTime: json['appointment_time']?.toString() ?? '',
      isVirtual: json['is_virtual'] as bool? ?? false,
      status: json['status']?.toString() ?? 'Pending',
      notes: json['notes']?.toString(),
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
      'department_id': departmentId,
      'appointment_date': appointmentDate.toIso8601String().split('T')[0],
      'appointment_time': appointmentTime,
      'is_virtual': isVirtual,
      'status': status,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Appointment copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    String? facilityId,
    String? departmentId,
    DateTime? appointmentDate,
    String? appointmentTime,
    bool? isVirtual,
    String? status,
    String? notes,
    DateTime? createdAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      facilityId: facilityId ?? this.facilityId,
      departmentId: departmentId ?? this.departmentId,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      appointmentTime: appointmentTime ?? this.appointmentTime,
      isVirtual: isVirtual ?? this.isVirtual,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Appointment &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          patientId == other.patientId &&
          doctorId == other.doctorId &&
          facilityId == other.facilityId &&
          departmentId == other.departmentId &&
          appointmentDate == other.appointmentDate &&
          appointmentTime == other.appointmentTime &&
          isVirtual == other.isVirtual &&
          status == other.status &&
          notes == other.notes &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      patientId.hashCode ^
      doctorId.hashCode ^
      facilityId.hashCode ^
      departmentId.hashCode ^
      appointmentDate.hashCode ^
      appointmentTime.hashCode ^
      isVirtual.hashCode ^
      status.hashCode ^
      notes.hashCode ^
      createdAt.hashCode;
}
