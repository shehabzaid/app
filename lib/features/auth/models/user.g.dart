// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      employeeId: json['employee_id'] as String?,
      isAdmin: json['is_admin'] as bool? ?? false,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'employee_id': instance.employeeId,
      'is_admin': instance.isAdmin,
      'created_at': instance.createdAt,
    };
