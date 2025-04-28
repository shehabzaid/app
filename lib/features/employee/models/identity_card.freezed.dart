// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'identity_card.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

IdentityCard _$IdentityCardFromJson(Map<String, dynamic> json) {
  return _IdentityCard.fromJson(json);
}

/// @nodoc
mixin _$IdentityCard {
  @JsonKey(name: 'id')
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'employee_id')
  String get employeeId => throw _privateConstructorUsedError;
  @JsonKey(name: 'card_type')
  String get cardType => throw _privateConstructorUsedError;
  @JsonKey(name: 'issued_by')
  String get issuedBy => throw _privateConstructorUsedError;
  @JsonKey(name: 'attachment_url')
  String? get attachment => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $IdentityCardCopyWith<IdentityCard> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IdentityCardCopyWith<$Res> {
  factory $IdentityCardCopyWith(
          IdentityCard value, $Res Function(IdentityCard) then) =
      _$IdentityCardCopyWithImpl<$Res, IdentityCard>;
  @useResult
  $Res call(
      {@JsonKey(name: 'id') String id,
      @JsonKey(name: 'employee_id') String employeeId,
      @JsonKey(name: 'card_type') String cardType,
      @JsonKey(name: 'issued_by') String issuedBy,
      @JsonKey(name: 'attachment_url') String? attachment,
      @JsonKey(name: 'created_at') DateTime? createdAt});
}

/// @nodoc
class _$IdentityCardCopyWithImpl<$Res, $Val extends IdentityCard>
    implements $IdentityCardCopyWith<$Res> {
  _$IdentityCardCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? employeeId = null,
    Object? cardType = null,
    Object? issuedBy = null,
    Object? attachment = freezed,
    Object? createdAt = freezed,
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
      cardType: null == cardType
          ? _value.cardType
          : cardType // ignore: cast_nullable_to_non_nullable
              as String,
      issuedBy: null == issuedBy
          ? _value.issuedBy
          : issuedBy // ignore: cast_nullable_to_non_nullable
              as String,
      attachment: freezed == attachment
          ? _value.attachment
          : attachment // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$IdentityCardImplCopyWith<$Res>
    implements $IdentityCardCopyWith<$Res> {
  factory _$$IdentityCardImplCopyWith(
          _$IdentityCardImpl value, $Res Function(_$IdentityCardImpl) then) =
      __$$IdentityCardImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'id') String id,
      @JsonKey(name: 'employee_id') String employeeId,
      @JsonKey(name: 'card_type') String cardType,
      @JsonKey(name: 'issued_by') String issuedBy,
      @JsonKey(name: 'attachment_url') String? attachment,
      @JsonKey(name: 'created_at') DateTime? createdAt});
}

/// @nodoc
class __$$IdentityCardImplCopyWithImpl<$Res>
    extends _$IdentityCardCopyWithImpl<$Res, _$IdentityCardImpl>
    implements _$$IdentityCardImplCopyWith<$Res> {
  __$$IdentityCardImplCopyWithImpl(
      _$IdentityCardImpl _value, $Res Function(_$IdentityCardImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? employeeId = null,
    Object? cardType = null,
    Object? issuedBy = null,
    Object? attachment = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$IdentityCardImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      employeeId: null == employeeId
          ? _value.employeeId
          : employeeId // ignore: cast_nullable_to_non_nullable
              as String,
      cardType: null == cardType
          ? _value.cardType
          : cardType // ignore: cast_nullable_to_non_nullable
              as String,
      issuedBy: null == issuedBy
          ? _value.issuedBy
          : issuedBy // ignore: cast_nullable_to_non_nullable
              as String,
      attachment: freezed == attachment
          ? _value.attachment
          : attachment // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$IdentityCardImpl implements _IdentityCard {
  const _$IdentityCardImpl(
      {@JsonKey(name: 'id') required this.id,
      @JsonKey(name: 'employee_id') required this.employeeId,
      @JsonKey(name: 'card_type') required this.cardType,
      @JsonKey(name: 'issued_by') required this.issuedBy,
      @JsonKey(name: 'attachment_url') this.attachment,
      @JsonKey(name: 'created_at') this.createdAt});

  factory _$IdentityCardImpl.fromJson(Map<String, dynamic> json) =>
      _$$IdentityCardImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final String id;
  @override
  @JsonKey(name: 'employee_id')
  final String employeeId;
  @override
  @JsonKey(name: 'card_type')
  final String cardType;
  @override
  @JsonKey(name: 'issued_by')
  final String issuedBy;
  @override
  @JsonKey(name: 'attachment_url')
  final String? attachment;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @override
  String toString() {
    return 'IdentityCard(id: $id, employeeId: $employeeId, cardType: $cardType, issuedBy: $issuedBy, attachment: $attachment, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IdentityCardImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.employeeId, employeeId) ||
                other.employeeId == employeeId) &&
            (identical(other.cardType, cardType) ||
                other.cardType == cardType) &&
            (identical(other.issuedBy, issuedBy) ||
                other.issuedBy == issuedBy) &&
            (identical(other.attachment, attachment) ||
                other.attachment == attachment) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, employeeId, cardType, issuedBy, attachment, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$IdentityCardImplCopyWith<_$IdentityCardImpl> get copyWith =>
      __$$IdentityCardImplCopyWithImpl<_$IdentityCardImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IdentityCardImplToJson(
      this,
    );
  }
}

abstract class _IdentityCard implements IdentityCard {
  const factory _IdentityCard(
          {@JsonKey(name: 'id') required final String id,
          @JsonKey(name: 'employee_id') required final String employeeId,
          @JsonKey(name: 'card_type') required final String cardType,
          @JsonKey(name: 'issued_by') required final String issuedBy,
          @JsonKey(name: 'attachment_url') final String? attachment,
          @JsonKey(name: 'created_at') final DateTime? createdAt}) =
      _$IdentityCardImpl;

  factory _IdentityCard.fromJson(Map<String, dynamic> json) =
      _$IdentityCardImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  String get id;
  @override
  @JsonKey(name: 'employee_id')
  String get employeeId;
  @override
  @JsonKey(name: 'card_type')
  String get cardType;
  @override
  @JsonKey(name: 'issued_by')
  String get issuedBy;
  @override
  @JsonKey(name: 'attachment_url')
  String? get attachment;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$IdentityCardImplCopyWith<_$IdentityCardImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
