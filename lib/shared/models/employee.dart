import 'package:json_annotation/json_annotation.dart';

part 'employee.g.dart';

@JsonSerializable()
class Employee {
  final int? id;
  final String employeeNumber;
  final String fullNameEn;
  final String fullNameAr;
  final String? department;
  final String? administration;
  final String? project;
  final String? jobTitle;
  final String? employeeStatus;
  final String? supervisor;
  final bool fingerprint;
  final String? fingerprintDevice;
  final DateTime? employmentDate;
  final String? branch;
  final String? notes;
  final String? profilePicture;
  final String? phoneLandline;
  final String? mobile;
  final String? email;
  final String? permanentAddress;
  final String? maritalStatus;
  final int? dependents;
  final String? religion;

  Employee({
    this.id,
    required this.employeeNumber,
    required this.fullNameEn,
    required this.fullNameAr,
    this.department,
    this.administration,
    this.project,
    this.jobTitle,
    this.employeeStatus,
    this.supervisor,
    this.fingerprint = false,
    this.fingerprintDevice,
    this.employmentDate,
    this.branch,
    this.notes,
    this.profilePicture,
    this.phoneLandline,
    this.mobile,
    this.email,
    this.permanentAddress,
    this.maritalStatus,
    this.dependents,
    this.religion,
  });

  factory Employee.fromJson(Map<String, dynamic> json) =>
      _$EmployeeFromJson(json);

  Map<String, dynamic> toJson() => _$EmployeeToJson(this);

  Employee copyWith({
    int? id,
    String? employeeNumber,
    String? fullNameEn,
    String? fullNameAr,
    String? department,
    String? administration,
    String? project,
    String? jobTitle,
    String? employeeStatus,
    String? supervisor,
    bool? fingerprint,
    String? fingerprintDevice,
    DateTime? employmentDate,
    String? branch,
    String? notes,
    String? profilePicture,
    String? phoneLandline,
    String? mobile,
    String? email,
    String? permanentAddress,
    String? maritalStatus,
    int? dependents,
    String? religion,
  }) {
    return Employee(
      id: id ?? this.id,
      employeeNumber: employeeNumber ?? this.employeeNumber,
      fullNameEn: fullNameEn ?? this.fullNameEn,
      fullNameAr: fullNameAr ?? this.fullNameAr,
      department: department ?? this.department,
      administration: administration ?? this.administration,
      project: project ?? this.project,
      jobTitle: jobTitle ?? this.jobTitle,
      employeeStatus: employeeStatus ?? this.employeeStatus,
      supervisor: supervisor ?? this.supervisor,
      fingerprint: fingerprint ?? this.fingerprint,
      fingerprintDevice: fingerprintDevice ?? this.fingerprintDevice,
      employmentDate: employmentDate ?? this.employmentDate,
      branch: branch ?? this.branch,
      notes: notes ?? this.notes,
      profilePicture: profilePicture ?? this.profilePicture,
      phoneLandline: phoneLandline ?? this.phoneLandline,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      permanentAddress: permanentAddress ?? this.permanentAddress,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      dependents: dependents ?? this.dependents,
      religion: religion ?? this.religion,
    );
  }
}
