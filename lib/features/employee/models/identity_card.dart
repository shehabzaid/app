import 'package:freezed_annotation/freezed_annotation.dart';

part 'identity_card.freezed.dart';
part 'identity_card.g.dart';

@freezed
class IdentityCard with _$IdentityCard {
  const factory IdentityCard({
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'employee_id') required String employeeId,
    @JsonKey(name: 'card_type') required String cardType,
    @JsonKey(name: 'issued_by') required String issuedBy,
    @JsonKey(name: 'attachment_url') String? attachment,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _IdentityCard;

  factory IdentityCard.fromJson(Map<String, dynamic> json) =>
      _$IdentityCardFromJson(json);
}
