// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qualification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QualificationImpl _$$QualificationImplFromJson(Map<String, dynamic> json) =>
    _$QualificationImpl(
      id: json['id'] as String,
      employeeId: json['employee_id'] as String,
      qualificationName: json['qualification_name'] as String,
      institution: json['institution'] as String,
      dateObtained: DateTime.parse(json['date_obtained'] as String),
      attachmentUrl: json['attachment_url'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$QualificationImplToJson(_$QualificationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employee_id': instance.employeeId,
      'qualification_name': instance.qualificationName,
      'institution': instance.institution,
      'date_obtained': instance.dateObtained.toIso8601String(),
      'attachment_url': instance.attachmentUrl,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
