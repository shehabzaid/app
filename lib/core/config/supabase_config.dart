import 'environment_config.dart';

class SupabaseConfig {
  // استخدام الإعدادات من ملف environment_config.dart
  static String get url => EnvironmentConfig.supabaseUrl;
  static String get anonKey => EnvironmentConfig.supabaseKey;

  // للاتصال من خلال سيرفر MCP
  static String get mcpServerUrl => EnvironmentConfig.mcpServerUrl;

  // Table names
  static const String employeesTable = 'employees';
  static const String trainingCoursesTable = 'training_courses';
  static const String workExperienceTable = 'work_experience';
  static const String qualificationsTable = 'qualifications';
  static const String attachmentsTable = 'attachments';
  static const String employeeActionsTable = 'employee_actions';
  static const String guarantorsTable = 'guarantors';
  static const String identityCardsTable = 'identity_cards';
  static const String incidentsTable = 'incidents';

  // Healthcare tables
  static const String healthcareFacilitiesTable = 'healthcare_facilities';
  static const String departmentsTable = 'departments';
  static const String doctorsTable = 'doctors';
  static const String usersTable = 'users';
  static const String appointmentsTable = 'appointments';
  static const String medicalRecordsTable = 'medical_records';
  static const String reviewsTable = 'reviews';

  // Storage bucket names
  static const String profilePicturesBucket = 'profile_pictures';
  static const String documentsBucket = 'documents';
  static const String certificatesBucket = 'certificates';
}
