import 'package:freezed_annotation/freezed_annotation.dart';

part 'employee.freezed.dart';
part 'employee.g.dart';

@freezed
class Employee with _$Employee {
  const factory Employee({
    required String id,
    @JsonKey(name: 'employee_number') required String employeeNumber,
    @JsonKey(name: 'full_name_en') required String fullNameEn,
    @JsonKey(name: 'full_name_ar') required String fullNameAr,
    String? department,
    String? administration,
    String? project,
    @JsonKey(name: 'job_title') String? jobTitle,
    @JsonKey(name: 'employee_status') String? employeeStatus,
    String? supervisor,
    @Default(false) bool fingerprint,
    @JsonKey(name: 'fingerprint_device') String? fingerprintDevice,
    @JsonKey(name: 'employment_date') String? employmentDate,
    String? branch,
    String? notes,
    @JsonKey(name: 'profile_picture') String? profilePicture,
    @JsonKey(name: 'phone_landline') String? phoneLandline,
    String? mobile,
    String? email,
    @JsonKey(name: 'permanent_address') String? permanentAddress,
    @JsonKey(name: 'marital_status') String? maritalStatus,
    @Default(0) int dependents,
    String? religion,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
  }) = _Employee;

  factory Employee.fromJson(Map<String, dynamic> json) =>
      _$EmployeeFromJson(json);
}
