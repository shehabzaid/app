import 'package:freezed_annotation/freezed_annotation.dart';

part 'qualification.freezed.dart';
part 'qualification.g.dart';

@freezed
class Qualification with _$Qualification {
  const factory Qualification({
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'employee_id') required String employeeId,
    @JsonKey(name: 'qualification_name') required String qualificationName,
    @JsonKey(name: 'institution') required String institution,
    @JsonKey(name: 'date_obtained') required DateTime dateObtained,
    @JsonKey(name: 'attachment_url') String? attachmentUrl,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Qualification;

  factory Qualification.fromJson(Map<String, dynamic> json) =>
      _$QualificationFromJson(json);
}
