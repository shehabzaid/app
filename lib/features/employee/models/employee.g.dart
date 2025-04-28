// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EmployeeImpl _$$EmployeeImplFromJson(Map<String, dynamic> json) =>
    _$EmployeeImpl(
      id: json['id'] as String,
      employeeNumber: json['employee_number'] as String,
      fullNameEn: json['full_name_en'] as String,
      fullNameAr: json['full_name_ar'] as String,
      department: json['department'] as String?,
      administration: json['administration'] as String?,
      project: json['project'] as String?,
      jobTitle: json['job_title'] as String?,
      employeeStatus: json['employee_status'] as String?,
      supervisor: json['supervisor'] as String?,
      fingerprint: json['fingerprint'] as bool? ?? false,
      fingerprintDevice: json['fingerprint_device'] as String?,
      employmentDate: json['employment_date'] as String?,
      branch: json['branch'] as String?,
      notes: json['notes'] as String?,
      profilePicture: json['profile_picture'] as String?,
      phoneLandline: json['phone_landline'] as String?,
      mobile: json['mobile'] as String?,
      email: json['email'] as String?,
      permanentAddress: json['permanent_address'] as String?,
      maritalStatus: json['marital_status'] as String?,
      dependents: (json['dependents'] as num?)?.toInt() ?? 0,
      religion: json['religion'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );

Map<String, dynamic> _$$EmployeeImplToJson(_$EmployeeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employee_number': instance.employeeNumber,
      'full_name_en': instance.fullNameEn,
      'full_name_ar': instance.fullNameAr,
      'department': instance.department,
      'administration': instance.administration,
      'project': instance.project,
      'job_title': instance.jobTitle,
      'employee_status': instance.employeeStatus,
      'supervisor': instance.supervisor,
      'fingerprint': instance.fingerprint,
      'fingerprint_device': instance.fingerprintDevice,
      'employment_date': instance.employmentDate,
      'branch': instance.branch,
      'notes': instance.notes,
      'profile_picture': instance.profilePicture,
      'phone_landline': instance.phoneLandline,
      'mobile': instance.mobile,
      'email': instance.email,
      'permanent_address': instance.permanentAddress,
      'marital_status': instance.maritalStatus,
      'dependents': instance.dependents,
      'religion': instance.religion,
      'is_active': instance.isActive,
    };
