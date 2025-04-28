// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identity_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$IdentityCardImpl _$$IdentityCardImplFromJson(Map<String, dynamic> json) =>
    _$IdentityCardImpl(
      id: json['id'] as String,
      employeeId: json['employee_id'] as String,
      cardType: json['card_type'] as String,
      issuedBy: json['issued_by'] as String,
      attachment: json['attachment_url'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$IdentityCardImplToJson(_$IdentityCardImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employee_id': instance.employeeId,
      'card_type': instance.cardType,
      'issued_by': instance.issuedBy,
      'attachment_url': instance.attachment,
      'created_at': instance.createdAt?.toIso8601String(),
    };
