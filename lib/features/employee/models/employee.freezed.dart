// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'employee.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Employee _$EmployeeFromJson(Map<String, dynamic> json) {
  return _Employee.fromJson(json);
}

/// @nodoc
mixin _$Employee {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'employee_number')
  String get employeeNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'full_name_en')
  String get fullNameEn => throw _privateConstructorUsedError;
  @JsonKey(name: 'full_name_ar')
  String get fullNameAr => throw _privateConstructorUsedError;
  String? get department => throw _privateConstructorUsedError;
  String? get administration => throw _privateConstructorUsedError;
  String? get project => throw _privateConstructorUsedError;
  @JsonKey(name: 'job_title')
  String? get jobTitle => throw _privateConstructorUsedError;
  @JsonKey(name: 'employee_status')
  String? get employeeStatus => throw _privateConstructorUsedError;
  String? get supervisor => throw _privateConstructorUsedError;
  bool get fingerprint => throw _privateConstructorUsedError;
  @JsonKey(name: 'fingerprint_device')
  String? get fingerprintDevice => throw _privateConstructorUsedError;
  @JsonKey(name: 'employment_date')
  String? get employmentDate => throw _privateConstructorUsedError;
  String? get branch => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  @JsonKey(name: 'profile_picture')
  String? get profilePicture => throw _privateConstructorUsedError;
  @JsonKey(name: 'phone_landline')
  String? get phoneLandline => throw _privateConstructorUsedError;
  String? get mobile => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'permanent_address')
  String? get permanentAddress => throw _privateConstructorUsedError;
  @JsonKey(name: 'marital_status')
  String? get maritalStatus => throw _privateConstructorUsedError;
  int get dependents => throw _privateConstructorUsedError;
  String? get religion => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EmployeeCopyWith<Employee> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EmployeeCopyWith<$Res> {
  factory $EmployeeCopyWith(Employee value, $Res Function(Employee) then) =
      _$EmployeeCopyWithImpl<$Res, Employee>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'employee_number') String employeeNumber,
      @JsonKey(name: 'full_name_en') String fullNameEn,
      @JsonKey(name: 'full_name_ar') String fullNameAr,
      String? department,
      String? administration,
      String? project,
      @JsonKey(name: 'job_title') String? jobTitle,
      @JsonKey(name: 'employee_status') String? employeeStatus,
      String? supervisor,
      bool fingerprint,
      @JsonKey(name: 'fingerprint_device') String? fingerprintDevice,
      @JsonKey(name: 'employment_date') String? employmentDate,
      String? branch,
      String? notes,
      @JsonKey(name: 'profile_picture') String? profilePicture,
      @JsonKey(name: 'phone_landline') String? phoneLandline,
      String? mobile,
      String? email,
      @JsonKey(name: 'permanent_address') String? permanentAddress,
      @JsonKey(name: 'marital_status') String? maritalStatus,
      int dependents,
      String? religion,
      @JsonKey(name: 'is_active') bool isActive});
}

/// @nodoc
class _$EmployeeCopyWithImpl<$Res, $Val extends Employee>
    implements $EmployeeCopyWith<$Res> {
  _$EmployeeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? employeeNumber = null,
    Object? fullNameEn = null,
    Object? fullNameAr = null,
    Object? department = freezed,
    Object? administration = freezed,
    Object? project = freezed,
    Object? jobTitle = freezed,
    Object? employeeStatus = freezed,
    Object? supervisor = freezed,
    Object? fingerprint = null,
    Object? fingerprintDevice = freezed,
    Object? employmentDate = freezed,
    Object? branch = freezed,
    Object? notes = freezed,
    Object? profilePicture = freezed,
    Object? phoneLandline = freezed,
    Object? mobile = freezed,
    Object? email = freezed,
    Object? permanentAddress = freezed,
    Object? maritalStatus = freezed,
    Object? dependents = null,
    Object? religion = freezed,
    Object? isActive = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      employeeNumber: null == employeeNumber
          ? _value.employeeNumber
          : employeeNumber // ignore: cast_nullable_to_non_nullable
              as String,
      fullNameEn: null == fullNameEn
          ? _value.fullNameEn
          : fullNameEn // ignore: cast_nullable_to_non_nullable
              as String,
      fullNameAr: null == fullNameAr
          ? _value.fullNameAr
          : fullNameAr // ignore: cast_nullable_to_non_nullable
              as String,
      department: freezed == department
          ? _value.department
          : department // ignore: cast_nullable_to_non_nullable
              as String?,
      administration: freezed == administration
          ? _value.administration
          : administration // ignore: cast_nullable_to_non_nullable
              as String?,
      project: freezed == project
          ? _value.project
          : project // ignore: cast_nullable_to_non_nullable
              as String?,
      jobTitle: freezed == jobTitle
          ? _value.jobTitle
          : jobTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      employeeStatus: freezed == employeeStatus
          ? _value.employeeStatus
          : employeeStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      supervisor: freezed == supervisor
          ? _value.supervisor
          : supervisor // ignore: cast_nullable_to_non_nullable
              as String?,
      fingerprint: null == fingerprint
          ? _value.fingerprint
          : fingerprint // ignore: cast_nullable_to_non_nullable
              as bool,
      fingerprintDevice: freezed == fingerprintDevice
          ? _value.fingerprintDevice
          : fingerprintDevice // ignore: cast_nullable_to_non_nullable
              as String?,
      employmentDate: freezed == employmentDate
          ? _value.employmentDate
          : employmentDate // ignore: cast_nullable_to_non_nullable
              as String?,
      branch: freezed == branch
          ? _value.branch
          : branch // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      profilePicture: freezed == profilePicture
          ? _value.profilePicture
          : profilePicture // ignore: cast_nullable_to_non_nullable
              as String?,
      phoneLandline: freezed == phoneLandline
          ? _value.phoneLandline
          : phoneLandline // ignore: cast_nullable_to_non_nullable
              as String?,
      mobile: freezed == mobile
          ? _value.mobile
          : mobile // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      permanentAddress: freezed == permanentAddress
          ? _value.permanentAddress
          : permanentAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      maritalStatus: freezed == maritalStatus
          ? _value.maritalStatus
          : maritalStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      dependents: null == dependents
          ? _value.dependents
          : dependents // ignore: cast_nullable_to_non_nullable
              as int,
      religion: freezed == religion
          ? _value.religion
          : religion // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EmployeeImplCopyWith<$Res>
    implements $EmployeeCopyWith<$Res> {
  factory _$$EmployeeImplCopyWith(
          _$EmployeeImpl value, $Res Function(_$EmployeeImpl) then) =
      __$$EmployeeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'employee_number') String employeeNumber,
      @JsonKey(name: 'full_name_en') String fullNameEn,
      @JsonKey(name: 'full_name_ar') String fullNameAr,
      String? department,
      String? administration,
      String? project,
      @JsonKey(name: 'job_title') String? jobTitle,
      @JsonKey(name: 'employee_status') String? employeeStatus,
      String? supervisor,
      bool fingerprint,
      @JsonKey(name: 'fingerprint_device') String? fingerprintDevice,
      @JsonKey(name: 'employment_date') String? employmentDate,
      String? branch,
      String? notes,
      @JsonKey(name: 'profile_picture') String? profilePicture,
      @JsonKey(name: 'phone_landline') String? phoneLandline,
      String? mobile,
      String? email,
      @JsonKey(name: 'permanent_address') String? permanentAddress,
      @JsonKey(name: 'marital_status') String? maritalStatus,
      int dependents,
      String? religion,
      @JsonKey(name: 'is_active') bool isActive});
}

/// @nodoc
class __$$EmployeeImplCopyWithImpl<$Res>
    extends _$EmployeeCopyWithImpl<$Res, _$EmployeeImpl>
    implements _$$EmployeeImplCopyWith<$Res> {
  __$$EmployeeImplCopyWithImpl(
      _$EmployeeImpl _value, $Res Function(_$EmployeeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? employeeNumber = null,
    Object? fullNameEn = null,
    Object? fullNameAr = null,
    Object? department = freezed,
    Object? administration = freezed,
    Object? project = freezed,
    Object? jobTitle = freezed,
    Object? employeeStatus = freezed,
    Object? supervisor = freezed,
    Object? fingerprint = null,
    Object? fingerprintDevice = freezed,
    Object? employmentDate = freezed,
    Object? branch = freezed,
    Object? notes = freezed,
    Object? profilePicture = freezed,
    Object? phoneLandline = freezed,
    Object? mobile = freezed,
    Object? email = freezed,
    Object? permanentAddress = freezed,
    Object? maritalStatus = freezed,
    Object? dependents = null,
    Object? religion = freezed,
    Object? isActive = null,
  }) {
    return _then(_$EmployeeImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      employeeNumber: null == employeeNumber
          ? _value.employeeNumber
          : employeeNumber // ignore: cast_nullable_to_non_nullable
              as String,
      fullNameEn: null == fullNameEn
          ? _value.fullNameEn
          : fullNameEn // ignore: cast_nullable_to_non_nullable
              as String,
      fullNameAr: null == fullNameAr
          ? _value.fullNameAr
          : fullNameAr // ignore: cast_nullable_to_non_nullable
              as String,
      department: freezed == department
          ? _value.department
          : department // ignore: cast_nullable_to_non_nullable
              as String?,
      administration: freezed == administration
          ? _value.administration
          : administration // ignore: cast_nullable_to_non_nullable
              as String?,
      project: freezed == project
          ? _value.project
          : project // ignore: cast_nullable_to_non_nullable
              as String?,
      jobTitle: freezed == jobTitle
          ? _value.jobTitle
          : jobTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      employeeStatus: freezed == employeeStatus
          ? _value.employeeStatus
          : employeeStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      supervisor: freezed == supervisor
          ? _value.supervisor
          : supervisor // ignore: cast_nullable_to_non_nullable
              as String?,
      fingerprint: null == fingerprint
          ? _value.fingerprint
          : fingerprint // ignore: cast_nullable_to_non_nullable
              as bool,
      fingerprintDevice: freezed == fingerprintDevice
          ? _value.fingerprintDevice
          : fingerprintDevice // ignore: cast_nullable_to_non_nullable
              as String?,
      employmentDate: freezed == employmentDate
          ? _value.employmentDate
          : employmentDate // ignore: cast_nullable_to_non_nullable
              as String?,
      branch: freezed == branch
          ? _value.branch
          : branch // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      profilePicture: freezed == profilePicture
          ? _value.profilePicture
          : profilePicture // ignore: cast_nullable_to_non_nullable
              as String?,
      phoneLandline: freezed == phoneLandline
          ? _value.phoneLandline
          : phoneLandline // ignore: cast_nullable_to_non_nullable
              as String?,
      mobile: freezed == mobile
          ? _value.mobile
          : mobile // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      permanentAddress: freezed == permanentAddress
          ? _value.permanentAddress
          : permanentAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      maritalStatus: freezed == maritalStatus
          ? _value.maritalStatus
          : maritalStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      dependents: null == dependents
          ? _value.dependents
          : dependents // ignore: cast_nullable_to_non_nullable
              as int,
      religion: freezed == religion
          ? _value.religion
          : religion // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EmployeeImpl implements _Employee {
  const _$EmployeeImpl(
      {required this.id,
      @JsonKey(name: 'employee_number') required this.employeeNumber,
      @JsonKey(name: 'full_name_en') required this.fullNameEn,
      @JsonKey(name: 'full_name_ar') required this.fullNameAr,
      this.department,
      this.administration,
      this.project,
      @JsonKey(name: 'job_title') this.jobTitle,
      @JsonKey(name: 'employee_status') this.employeeStatus,
      this.supervisor,
      this.fingerprint = false,
      @JsonKey(name: 'fingerprint_device') this.fingerprintDevice,
      @JsonKey(name: 'employment_date') this.employmentDate,
      this.branch,
      this.notes,
      @JsonKey(name: 'profile_picture') this.profilePicture,
      @JsonKey(name: 'phone_landline') this.phoneLandline,
      this.mobile,
      this.email,
      @JsonKey(name: 'permanent_address') this.permanentAddress,
      @JsonKey(name: 'marital_status') this.maritalStatus,
      this.dependents = 0,
      this.religion,
      @JsonKey(name: 'is_active') this.isActive = true});

  factory _$EmployeeImpl.fromJson(Map<String, dynamic> json) =>
      _$$EmployeeImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'employee_number')
  final String employeeNumber;
  @override
  @JsonKey(name: 'full_name_en')
  final String fullNameEn;
  @override
  @JsonKey(name: 'full_name_ar')
  final String fullNameAr;
  @override
  final String? department;
  @override
  final String? administration;
  @override
  final String? project;
  @override
  @JsonKey(name: 'job_title')
  final String? jobTitle;
  @override
  @JsonKey(name: 'employee_status')
  final String? employeeStatus;
  @override
  final String? supervisor;
  @override
  @JsonKey()
  final bool fingerprint;
  @override
  @JsonKey(name: 'fingerprint_device')
  final String? fingerprintDevice;
  @override
  @JsonKey(name: 'employment_date')
  final String? employmentDate;
  @override
  final String? branch;
  @override
  final String? notes;
  @override
  @JsonKey(name: 'profile_picture')
  final String? profilePicture;
  @override
  @JsonKey(name: 'phone_landline')
  final String? phoneLandline;
  @override
  final String? mobile;
  @override
  final String? email;
  @override
  @JsonKey(name: 'permanent_address')
  final String? permanentAddress;
  @override
  @JsonKey(name: 'marital_status')
  final String? maritalStatus;
  @override
  @JsonKey()
  final int dependents;
  @override
  final String? religion;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;

  @override
  String toString() {
    return 'Employee(id: $id, employeeNumber: $employeeNumber, fullNameEn: $fullNameEn, fullNameAr: $fullNameAr, department: $department, administration: $administration, project: $project, jobTitle: $jobTitle, employeeStatus: $employeeStatus, supervisor: $supervisor, fingerprint: $fingerprint, fingerprintDevice: $fingerprintDevice, employmentDate: $employmentDate, branch: $branch, notes: $notes, profilePicture: $profilePicture, phoneLandline: $phoneLandline, mobile: $mobile, email: $email, permanentAddress: $permanentAddress, maritalStatus: $maritalStatus, dependents: $dependents, religion: $religion, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmployeeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.employeeNumber, employeeNumber) ||
                other.employeeNumber == employeeNumber) &&
            (identical(other.fullNameEn, fullNameEn) ||
                other.fullNameEn == fullNameEn) &&
            (identical(other.fullNameAr, fullNameAr) ||
                other.fullNameAr == fullNameAr) &&
            (identical(other.department, department) ||
                other.department == department) &&
            (identical(other.administration, administration) ||
                other.administration == administration) &&
            (identical(other.project, project) || other.project == project) &&
            (identical(other.jobTitle, jobTitle) ||
                other.jobTitle == jobTitle) &&
            (identical(other.employeeStatus, employeeStatus) ||
                other.employeeStatus == employeeStatus) &&
            (identical(other.supervisor, supervisor) ||
                other.supervisor == supervisor) &&
            (identical(other.fingerprint, fingerprint) ||
                other.fingerprint == fingerprint) &&
            (identical(other.fingerprintDevice, fingerprintDevice) ||
                other.fingerprintDevice == fingerprintDevice) &&
            (identical(other.employmentDate, employmentDate) ||
                other.employmentDate == employmentDate) &&
            (identical(other.branch, branch) || other.branch == branch) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.profilePicture, profilePicture) ||
                other.profilePicture == profilePicture) &&
            (identical(other.phoneLandline, phoneLandline) ||
                other.phoneLandline == phoneLandline) &&
            (identical(other.mobile, mobile) || other.mobile == mobile) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.permanentAddress, permanentAddress) ||
                other.permanentAddress == permanentAddress) &&
            (identical(other.maritalStatus, maritalStatus) ||
                other.maritalStatus == maritalStatus) &&
            (identical(other.dependents, dependents) ||
                other.dependents == dependents) &&
            (identical(other.religion, religion) ||
                other.religion == religion) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        employeeNumber,
        fullNameEn,
        fullNameAr,
        department,
        administration,
        project,
        jobTitle,
        employeeStatus,
        supervisor,
        fingerprint,
        fingerprintDevice,
        employmentDate,
        branch,
        notes,
        profilePicture,
        phoneLandline,
        mobile,
        email,
        permanentAddress,
        maritalStatus,
        dependents,
        religion,
        isActive
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EmployeeImplCopyWith<_$EmployeeImpl> get copyWith =>
      __$$EmployeeImplCopyWithImpl<_$EmployeeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EmployeeImplToJson(
      this,
    );
  }
}

abstract class _Employee implements Employee {
  const factory _Employee(
      {required final String id,
      @JsonKey(name: 'employee_number') required final String employeeNumber,
      @JsonKey(name: 'full_name_en') required final String fullNameEn,
      @JsonKey(name: 'full_name_ar') required final String fullNameAr,
      final String? department,
      final String? administration,
      final String? project,
      @JsonKey(name: 'job_title') final String? jobTitle,
      @JsonKey(name: 'employee_status') final String? employeeStatus,
      final String? supervisor,
      final bool fingerprint,
      @JsonKey(name: 'fingerprint_device') final String? fingerprintDevice,
      @JsonKey(name: 'employment_date') final String? employmentDate,
      final String? branch,
      final String? notes,
      @JsonKey(name: 'profile_picture') final String? profilePicture,
      @JsonKey(name: 'phone_landline') final String? phoneLandline,
      final String? mobile,
      final String? email,
      @JsonKey(name: 'permanent_address') final String? permanentAddress,
      @JsonKey(name: 'marital_status') final String? maritalStatus,
      final int dependents,
      final String? religion,
      @JsonKey(name: 'is_active') final bool isActive}) = _$EmployeeImpl;

  factory _Employee.fromJson(Map<String, dynamic> json) =
      _$EmployeeImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'employee_number')
  String get employeeNumber;
  @override
  @JsonKey(name: 'full_name_en')
  String get fullNameEn;
  @override
  @JsonKey(name: 'full_name_ar')
  String get fullNameAr;
  @override
  String? get department;
  @override
  String? get administration;
  @override
  String? get project;
  @override
  @JsonKey(name: 'job_title')
  String? get jobTitle;
  @override
  @JsonKey(name: 'employee_status')
  String? get employeeStatus;
  @override
  String? get supervisor;
  @override
  bool get fingerprint;
  @override
  @JsonKey(name: 'fingerprint_device')
  String? get fingerprintDevice;
  @override
  @JsonKey(name: 'employment_date')
  String? get employmentDate;
  @override
  String? get branch;
  @override
  String? get notes;
  @override
  @JsonKey(name: 'profile_picture')
  String? get profilePicture;
  @override
  @JsonKey(name: 'phone_landline')
  String? get phoneLandline;
  @override
  String? get mobile;
  @override
  String? get email;
  @override
  @JsonKey(name: 'permanent_address')
  String? get permanentAddress;
  @override
  @JsonKey(name: 'marital_status')
  String? get maritalStatus;
  @override
  int get dependents;
  @override
  String? get religion;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;
  @override
  @JsonKey(ignore: true)
  _$$EmployeeImplCopyWith<_$EmployeeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
