// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Employee _$EmployeeFromJson(Map<String, dynamic> json) => Employee(
      id: (json['id'] as num?)?.toInt(),
      employeeNumber: json['employeeNumber'] as String,
      fullNameEn: json['fullNameEn'] as String,
      fullNameAr: json['fullNameAr'] as String,
      department: json['department'] as String?,
      administration: json['administration'] as String?,
      project: json['project'] as String?,
      jobTitle: json['jobTitle'] as String?,
      employeeStatus: json['employeeStatus'] as String?,
      supervisor: json['supervisor'] as String?,
      fingerprint: json['fingerprint'] as bool? ?? false,
      fingerprintDevice: json['fingerprintDevice'] as String?,
      employmentDate: json['employmentDate'] == null
          ? null
          : DateTime.parse(json['employmentDate'] as String),
      branch: json['branch'] as String?,
      notes: json['notes'] as String?,
      profilePicture: json['profilePicture'] as String?,
      phoneLandline: json['phoneLandline'] as String?,
      mobile: json['mobile'] as String?,
      email: json['email'] as String?,
      permanentAddress: json['permanentAddress'] as String?,
      maritalStatus: json['maritalStatus'] as String?,
      dependents: (json['dependents'] as num?)?.toInt(),
      religion: json['religion'] as String?,
    );

Map<String, dynamic> _$EmployeeToJson(Employee instance) => <String, dynamic>{
      'id': instance.id,
      'employeeNumber': instance.employeeNumber,
      'fullNameEn': instance.fullNameEn,
      'fullNameAr': instance.fullNameAr,
      'department': instance.department,
      'administration': instance.administration,
      'project': instance.project,
      'jobTitle': instance.jobTitle,
      'employeeStatus': instance.employeeStatus,
      'supervisor': instance.supervisor,
      'fingerprint': instance.fingerprint,
      'fingerprintDevice': instance.fingerprintDevice,
      'employmentDate': instance.employmentDate?.toIso8601String(),
      'branch': instance.branch,
      'notes': instance.notes,
      'profilePicture': instance.profilePicture,
      'phoneLandline': instance.phoneLandline,
      'mobile': instance.mobile,
      'email': instance.email,
      'permanentAddress': instance.permanentAddress,
      'maritalStatus': instance.maritalStatus,
      'dependents': instance.dependents,
      'religion': instance.religion,
    };
