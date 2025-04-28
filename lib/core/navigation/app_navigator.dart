import 'package:flutter/material.dart';
import '../../features/hospitals/models/hospital.dart';

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
        Navigator.pushNamed(context, '/admin/manage-facilities');
        break;
      case 2: // Usuarios
        Navigator.pushNamed(context, '/admin/manage-doctors');
        break;
      case 3: // Configuración
        // TODO: Implementar pantalla de configuración para administradores
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

  /// Navega a la pantalla de calificación del médico
  static void navigateToRateDoctor(BuildContext context, String appointmentId,
      String doctorName, String hospitalName, String appointmentDate) {
    Navigator.pushNamed(
      context,
      '/rate-doctor',
      arguments: {
        'appointmentId': appointmentId,
        'doctorName': doctorName,
        'hospitalName': hospitalName,
        'appointmentDate': appointmentDate,
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

  /// Navega a la pantalla de detalles de la cita
  static void navigateToAppointmentDetails(
      BuildContext context, String appointmentId) {
    Navigator.pushNamed(
      context,
      '/appointment-details',
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
    Navigator.pushNamed(
      context,
      '/medical-records',
      arguments: patientId,
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

  /// Cierra sesión y navega a la pantalla de inicio de sesión
  static void logout(BuildContext context) {
    // TODO: Implementar lógica de cierre de sesión
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }
}
