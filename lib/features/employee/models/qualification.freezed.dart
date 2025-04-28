// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'qualification.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Qualification _$QualificationFromJson(Map<String, dynamic> json) {
  return _Qualification.fromJson(json);
}

/// @nodoc
mixin _$Qualification {
  @JsonKey(name: 'id')
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'employee_id')
  String get employeeId => throw _privateConstructorUsedError;
  @JsonKey(name: 'qualification_name')
  String get qualificationName => throw _privateConstructorUsedError;
  @JsonKey(name: 'institution')
  String get institution => throw _privateConstructorUsedError;
  @JsonKey(name: 'date_obtained')
  DateTime get dateObtained => throw _privateConstructorUsedError;
  @JsonKey(name: 'attachment_url')
  String? get attachmentUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $QualificationCopyWith<Qualification> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QualificationCopyWith<$Res> {
  factory $QualificationCopyWith(
          Qualification value, $Res Function(Qualification) then) =
      _$QualificationCopyWithImpl<$Res, Qualification>;
  @useResult
  $Res call(
      {@JsonKey(name: 'id') String id,
      @JsonKey(name: 'employee_id') String employeeId,
      @JsonKey(name: 'qualification_name') String qualificationName,
      @JsonKey(name: 'institution') String institution,
      @JsonKey(name: 'date_obtained') DateTime dateObtained,
      @JsonKey(name: 'attachment_url') String? attachmentUrl,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$QualificationCopyWithImpl<$Res, $Val extends Qualification>
    implements $QualificationCopyWith<$Res> {
  _$QualificationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? employeeId = null,
    Object? qualificationName = null,
    Object? institution = null,
    Object? dateObtained = null,
    Object? attachmentUrl = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      employeeId: null == employeeId
          ? _value.employeeId
          : employeeId // ignore: cast_nullable_to_non_nullable
              as String,
      qualificationName: null == qualificationName
          ? _value.qualificationName
          : qualificationName // ignore: cast_nullable_to_non_nullable
              as String,
      institution: null == institution
          ? _value.institution
          : institution // ignore: cast_nullable_to_non_nullable
              as String,
      dateObtained: null == dateObtained
          ? _value.dateObtained
          : dateObtained // ignore: cast_nullable_to_non_nullable
              as DateTime,
      attachmentUrl: freezed == attachmentUrl
          ? _value.attachmentUrl
          : attachmentUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QualificationImplCopyWith<$Res>
    implements $QualificationCopyWith<$Res> {
  factory _$$QualificationImplCopyWith(
          _$QualificationImpl value, $Res Function(_$QualificationImpl) then) =
      __$$QualificationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'id') String id,
      @JsonKey(name: 'employee_id') String employeeId,
      @JsonKey(name: 'qualification_name') String qualificationName,
      @JsonKey(name: 'institution') String institution,
      @JsonKey(name: 'date_obtained') DateTime dateObtained,
      @JsonKey(name: 'attachment_url') String? attachmentUrl,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$$QualificationImplCopyWithImpl<$Res>
    extends _$QualificationCopyWithImpl<$Res, _$QualificationImpl>
    implements _$$QualificationImplCopyWith<$Res> {
  __$$QualificationImplCopyWithImpl(
      _$QualificationImpl _value, $Res Function(_$QualificationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? employeeId = null,
    Object? qualificationName = null,
    Object? institution = null,
    Object? dateObtained = null,
    Object? attachmentUrl = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$QualificationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      employeeId: null == employeeId
          ? _value.employeeId
          : employeeId // ignore: cast_nullable_to_non_nullable
              as String,
      qualificationName: null == qualificationName
          ? _value.qualificationName
          : qualificationName // ignore: cast_nullable_to_non_nullable
              as String,
      institution: null == institution
          ? _value.institution
          : institution // ignore: cast_nullable_to_non_nullable
              as String,
      dateObtained: null == dateObtained
          ? _value.dateObtained
          : dateObtained // ignore: cast_nullable_to_non_nullable
              as DateTime,
      attachmentUrl: freezed == attachmentUrl
          ? _value.attachmentUrl
          : attachmentUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$QualificationImpl implements _Qualification {
  const _$QualificationImpl(
      {@JsonKey(name: 'id') required this.id,
      @JsonKey(name: 'employee_id') required this.employeeId,
      @JsonKey(name: 'qualification_name') required this.qualificationName,
      @JsonKey(name: 'institution') required this.institution,
      @JsonKey(name: 'date_obtained') required this.dateObtained,
      @JsonKey(name: 'attachment_url') this.attachmentUrl,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt});

  factory _$QualificationImpl.fromJson(Map<String, dynamic> json) =>
      _$$QualificationImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final String id;
  @override
  @JsonKey(name: 'employee_id')
  final String employeeId;
  @override
  @JsonKey(name: 'qualification_name')
  final String qualificationName;
  @override
  @JsonKey(name: 'institution')
  final String institution;
  @override
  @JsonKey(name: 'date_obtained')
  final DateTime dateObtained;
  @override
  @JsonKey(name: 'attachment_url')
  final String? attachmentUrl;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Qualification(id: $id, employeeId: $employeeId, qualificationName: $qualificationName, institution: $institution, dateObtained: $dateObtained, attachmentUrl: $attachmentUrl, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QualificationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.employeeId, employeeId) ||
                other.employeeId == employeeId) &&
            (identical(other.qualificationName, qualificationName) ||
                other.qualificationName == qualificationName) &&
            (identical(other.institution, institution) ||
                other.institution == institution) &&
            (identical(other.dateObtained, dateObtained) ||
                other.dateObtained == dateObtained) &&
            (identical(other.attachmentUrl, attachmentUrl) ||
                other.attachmentUrl == attachmentUrl) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      employeeId,
      qualificationName,
      institution,
      dateObtained,
      attachmentUrl,
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QualificationImplCopyWith<_$QualificationImpl> get copyWith =>
      __$$QualificationImplCopyWithImpl<_$QualificationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QualificationImplToJson(
      this,
    );
  }
}

abstract class _Qualification implements Qualification {
  const factory _Qualification(
          {@JsonKey(name: 'id') required final String id,
          @JsonKey(name: 'employee_id') required final String employeeId,
          @JsonKey(name: 'qualification_name')
          required final String qualificationName,
          @JsonKey(name: 'institution') required final String institution,
          @JsonKey(name: 'date_obtained') required final DateTime dateObtained,
          @JsonKey(name: 'attachment_url') final String? attachmentUrl,
          @JsonKey(name: 'created_at') final DateTime? createdAt,
          @JsonKey(name: 'updated_at') final DateTime? updatedAt}) =
      _$QualificationImpl;

  factory _Qualification.fromJson(Map<String, dynamic> json) =
      _$QualificationImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  String get id;
  @override
  @JsonKey(name: 'employee_id')
  String get employeeId;
  @override
  @JsonKey(name: 'qualification_name')
  String get qualificationName;
  @override
  @JsonKey(name: 'institution')
  String get institution;
  @override
  @JsonKey(name: 'date_obtained')
  DateTime get dateObtained;
  @override
  @JsonKey(name: 'attachment_url')
  String? get attachmentUrl;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$QualificationImplCopyWith<_$QualificationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
