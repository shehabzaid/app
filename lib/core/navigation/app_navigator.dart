import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/hospitals/models/hospital.dart';
import '../../features/advertisements/models/advertisement.dart';

/// Clase para manejar la navegación en la aplicación
/// Implementa los flujos de usuario para pacientes, médicos y administradores
class AppNavigator {
  // Singleton pattern
  static final AppNavigator _instance = AppNavigator._internal();
  factory AppNavigator() => _instance;
  AppNavigator._internal();

  /// Navega a la pantalla de inicio según el tipo de usuario
  static void navigateToHome(BuildContext context, String userType) {
    switch (userType) {
      case 'patient':
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 'doctor':
        Navigator.pushReplacementNamed(context, '/doctor-home',
            arguments: {'doctorId': ''} // TODO: Obtener el ID real del médico
            );
        break;
      case 'admin':
        Navigator.pushReplacementNamed(context, '/admin-dashboard');
        break;
      default:
        Navigator.pushReplacementNamed(context, '/login');
    }
  }

  /// Maneja la navegación del bottom navigation bar para pacientes
  static void handlePatientBottomNavigation(BuildContext context, int index) {
    switch (index) {
      case 0: // Inicio
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1: // Hospitales
        Navigator.pushNamed(context, '/hospitals');
        break;
      case 2: // Mis citas
        Navigator.pushNamed(context, '/my-appointments');
        break;
      case 3: // Mi perfil
        Navigator.pushNamed(context, '/settings');
        break;
    }
  }

  /// Maneja la navegación del bottom navigation bar para médicos
  static void handleDoctorBottomNavigation(
      BuildContext context, int index, String doctorId) {
    switch (index) {
      case 0: // Inicio
        Navigator.pushReplacementNamed(context, '/doctor-home',
            arguments: {'doctorId': doctorId});
        break;
      case 1: // Citas
        Navigator.pushNamed(context, '/doctor-appointments',
            arguments: {'doctorId': doctorId});
        break;
      case 2: // Registros médicos
        // TODO: Implementar pantalla de registros médicos para médicos
        break;
      case 3: // Perfil
        // TODO: Implementar pantalla de perfil para médicos
        break;
    }
  }

  /// Maneja la navegación del bottom navigation bar para administradores
  static void handleAdminBottomNavigation(BuildContext context, int index) {
    switch (index) {
      case 0: // Dashboard
        Navigator.pushReplacementNamed(context, '/admin-dashboard');
        break;
      case 1: // Instalaciones
        navigateToManageFacilities(context);
        break;
      case 2: // Usuarios
        navigateToManageUsers(context);
        break;
      case 3: // Configuración
        navigateToManageNotifications(context);
        break;
    }
  }

  /// Navega a la pantalla de detalles del hospital
  static void navigateToHospitalDetails(
      BuildContext context, String hospitalId) {
    Navigator.pushNamed(
      context,
      '/hospital-details',
      arguments: hospitalId,
    );
  }

  /// Navega a la pantalla de detalles del departamento
  static void navigateToDepartmentDetails(
      BuildContext context, String hospitalId, String departmentId) {
    Navigator.pushNamed(
      context,
      '/department-details',
      arguments: {
        'hospitalId': hospitalId,
        'departmentId': departmentId,
      },
    );
  }

  /// Navega a la pantalla de detalles del médico
  static void navigateToDoctorDetails(
      BuildContext context, String doctorId, String hospitalId) {
    Navigator.pushNamed(
      context,
      '/doctor-details',
      arguments: {
        'doctorId': doctorId,
        'hospitalId': hospitalId,
      },
    );
  }

  /// Navega a la pantalla de reserva de citas
  static void navigateToBookAppointment(BuildContext context, String hospitalId,
      String departmentId, String doctorId) {
    Navigator.pushNamed(
      context,
      '/book-appointment',
      arguments: {
        'hospitalId': hospitalId,
        'departmentId': departmentId,
        'doctorId': doctorId,
      },
    );
  }

  /// التنقل إلى شاشة تقييم الطبيب
  static void navigateToRateDoctor(
    BuildContext context, {
    required String doctorId,
    required String doctorName,
    String hospitalName = '',
    String? appointmentId,
  }) {
    Navigator.pushNamed(
      context,
      '/rate-doctor',
      arguments: {
        'doctorId': doctorId,
        'doctorName': doctorName,
        'hospitalName': hospitalName,
        'appointmentId': appointmentId,
      },
    );
  }

  /// Navega a la pantalla de detalles del paciente (para médicos)
  static void navigateToPatientDetails(BuildContext context, String patientId,
      {String? appointmentId}) {
    Navigator.pushNamed(
      context,
      '/patient-details',
      arguments: {
        'patientId': patientId,
        'appointmentId': appointmentId,
      },
    );
  }

  /// Navega a la pantalla de detalles de la cita (para pacientes)
  static void navigateToAppointmentDetails(
      BuildContext context, String appointmentId) {
    Navigator.pushNamed(
      context,
      '/appointment-details',
      arguments: appointmentId,
    );
  }

  /// Navega a la pantalla de detalles de la cita (para médicos)
  static void navigateToDoctorAppointmentDetails(
      BuildContext context, String appointmentId) {
    Navigator.pushNamed(
      context,
      '/doctor/appointment-details',
      arguments: appointmentId,
    );
  }

  /// Navega a la pantalla de agregar registro médico (para médicos)
  static void navigateToAddMedicalRecord(
      BuildContext context, String patientId, String patientName,
      {String? appointmentId}) {
    Navigator.pushNamed(
      context,
      '/add-medical-record',
      arguments: {
        'patientId': patientId,
        'patientName': patientName,
        'appointmentId': appointmentId,
      },
    );
  }

  /// Navega a la pantalla de doctores
  static void navigateToDoctors(BuildContext context, Hospital? hospital) {
    Navigator.pushNamed(
      context,
      '/doctors',
      arguments: hospital,
    );
  }

  /// Navega a la pantalla de hospitales
  static void navigateToHospitals(BuildContext context) {
    Navigator.pushNamed(context, '/hospitals');
  }

  /// Navega a la pantalla de notificaciones
  static void navigateToNotifications(BuildContext context) {
    Navigator.pushNamed(context, '/notifications');
  }

  /// Navega a la pantalla de registros médicos
  static void navigateToMedicalRecords(BuildContext context,
      {String? patientId}) {
    // الحصول على معرف المستخدم الحالي إذا لم يتم تمرير معرف
    final currentUser = Supabase.instance.client.auth.currentUser;
    final userId = patientId ?? currentUser?.id ?? '';

    if (userId.isEmpty) {
      // إذا لم يكن هناك مستخدم مسجل، توجيه المستخدم إلى صفحة تسجيل الدخول
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى تسجيل الدخول أولاً لعرض السجلات الطبية'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      return;
    }

    // التنقل إلى صفحة السجلات الطبية مع تمرير معرف المستخدم
    Navigator.pushNamed(
      context,
      '/medical-records',
      arguments: userId,
    );
  }

  /// Navega a la pantalla de detalles del registro médico
  static void navigateToMedicalRecordDetails(
      BuildContext context, String recordId) {
    Navigator.pushNamed(
      context,
      '/medical-record-details',
      arguments: recordId,
    );
  }

  /// Navega a la pantalla de configuración
  static void navigateToSettings(BuildContext context) {
    Navigator.pushNamed(context, '/settings');
  }

  /// التنقل إلى شاشة إدارة الإعلانات
  static void navigateToAdvertisements(BuildContext context) {
    Navigator.pushNamed(context, '/admin/advertisements');
  }

  /// التنقل إلى شاشة إضافة/تعديل إعلان
  static void navigateToAddEditAdvertisement(BuildContext context,
      {Advertisement? advertisement}) {
    Navigator.pushNamed(
      context,
      '/admin/advertisements/edit',
      arguments: advertisement,
    );
  }

  /// التنقل إلى شاشة ربط الأطباء بالمستخدمين
  static void navigateToLinkDoctorUser(BuildContext context) {
    Navigator.pushNamed(context, '/admin/link-doctor-user');
  }

  /// التنقل إلى شاشة إدارة المستخدمين
  static void navigateToManageUsers(BuildContext context) {
    Navigator.pushNamed(context, '/admin/manage-users');
  }

  /// التنقل إلى شاشة إدارة الأقسام
  static void navigateToManageDepartments(BuildContext context,
      {Hospital? hospital}) {
    Navigator.pushNamed(
      context,
      '/admin/manage-departments',
      arguments: hospital,
    );
  }

  /// التنقل إلى شاشة إدارة الأطباء
  static void navigateToManageDoctors(BuildContext context,
      {Hospital? hospital}) {
    Navigator.pushNamed(
      context,
      '/admin/manage-doctors',
      arguments: hospital,
    );
  }

  /// التنقل إلى شاشة إدارة المواعيد
  static void navigateToManageAppointments(BuildContext context) {
    Navigator.pushNamed(context, '/admin/manage-appointments');
  }

  /// التنقل إلى شاشة إدارة الإشعارات
  static void navigateToManageNotifications(BuildContext context) {
    Navigator.pushNamed(context, '/admin/manage-notifications');
  }

  /// التنقل إلى شاشة إدارة المنشآت الصحية
  static void navigateToManageFacilities(BuildContext context) {
    Navigator.pushNamed(context, '/admin/manage-facilities');
  }

  /// Cierra sesión y navega a la pantalla de inicio de sesión
  static Future<void> logout(BuildContext context) async {
    try {
      // تنفيذ تسجيل الخروج
      await Supabase.instance.client.auth.signOut();

      // عرض رسالة نجاح
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تسجيل الخروج بنجاح'),
            backgroundColor: Colors.green,
          ),
        );

        // التنقل إلى صفحة تسجيل الدخول
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      // عرض رسالة خطأ
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء تسجيل الخروج: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
