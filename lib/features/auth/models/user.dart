import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    @JsonKey(name: 'employee_id') String? employeeId,
    @JsonKey(name: 'is_admin') @Default(false) bool isAdmin,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
