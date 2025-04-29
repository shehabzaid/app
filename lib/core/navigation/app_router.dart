import 'package:flutter/material.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/intro_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/admin_login_screen.dart';
import '../../features/hospitals/screens/home_screen.dart';
import '../../features/hospitals/screens/hospitals_screen.dart';
import '../../features/hospitals/screens/hospital_details_screen.dart';
import '../../features/hospitals/screens/department_details_screen.dart';
import '../../features/hospitals/screens/doctors_screen.dart';
import '../../features/hospitals/models/hospital.dart';
import '../../features/patients/screens/doctor_details_screen.dart';
import '../../features/doctors/screens/doctor_home_screen.dart';
import '../../features/doctors/screens/doctor_appointments_screen.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/appointments/screens/my_appointments_screen.dart';
import '../../features/appointments/screens/appointment_details_screen.dart';
import '../../features/appointments/screens/book_appointment_screen.dart';
import '../../features/appointments/screens/doctor_appointment_details_screen.dart';
import '../../features/medical_records/screens/medical_records_screen.dart';
import '../../features/medical_records/screens/medical_record_details_screen.dart';
import '../../features/medical_records/screens/add_medical_record_screen.dart';
import '../../features/reviews/screens/rate_doctor_screen.dart';
import '../../features/auth/screens/settings_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/admin/screens/admin_advertisements_screen.dart';
import '../../features/admin/screens/add_edit_advertisement_screen.dart';
import '../../features/admin/screens/link_doctor_user_screen.dart';
import '../../features/admin/screens/manage_users_screen.dart';
import '../../features/admin/screens/manage_departments_screen.dart';
import '../../features/admin/screens/manage_doctors_screen.dart';
import '../../features/admin/screens/manage_appointments_screen.dart';
import '../../features/admin/screens/manage_notifications_screen.dart';
import '../../features/admin/screens/manage_facilities_screen.dart';
import '../../features/advertisements/models/advertisement.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case '/intro':
        return MaterialPageRoute(builder: (_) => const IntroScreen());

      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case '/admin-login':
        return MaterialPageRoute(builder: (_) => const AdminLoginScreen());

      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case '/hospitals':
        return MaterialPageRoute(builder: (_) => const HospitalsScreen());

      case '/hospital-details':
        final hospitalId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => HospitalDetailsScreen(hospitalId: hospitalId),
        );

      case '/department-details':
        final args = settings.arguments as Map<String, String>;
        return MaterialPageRoute(
          builder: (_) => DepartmentDetailsScreen(
            hospitalId: args['hospitalId']!,
            departmentId: args['departmentId']!,
          ),
        );

      case '/doctors':
        final hospital = settings.arguments as Hospital?;
        return MaterialPageRoute(
          builder: (_) => DoctorsScreen(hospital: hospital),
        );

      case '/doctor-details':
        final args = settings.arguments as Map<String, String>;
        return MaterialPageRoute(
          builder: (_) => DoctorDetailsScreen(
            doctorId: args['doctorId']!,
            hospitalId: args['hospitalId']!,
          ),
        );

      case '/doctor-home':
        final args = settings.arguments as Map<String, String>;
        return MaterialPageRoute(
          builder: (_) => DoctorHomeScreen(doctorId: args['doctorId']!),
        );

      case '/doctor-appointments':
        final args = settings.arguments as Map<String, String>;
        return MaterialPageRoute(
          builder: (_) => DoctorAppointmentsScreen(doctorId: args['doctorId']!),
        );

      case '/admin-dashboard':
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());

      case '/my-appointments':
        return MaterialPageRoute(builder: (_) => const MyAppointmentsScreen());

      case '/appointment-details':
        final appointmentId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) =>
              AppointmentDetailsScreen(appointmentId: appointmentId),
        );

      case '/doctor/appointment-details':
        final appointmentId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) =>
              DoctorAppointmentDetailsScreen(appointmentId: appointmentId),
        );

      case '/book-appointment':
        final args = settings.arguments as Map<String, String?>;
        return MaterialPageRoute(
          builder: (_) => BookAppointmentScreen(
            hospitalId: args['hospitalId'],
            departmentId: args['departmentId'],
            doctorId: args['doctorId'],
          ),
        );

      case '/medical-records':
        final patientId = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => MedicalRecordsScreen(patientId: patientId),
        );

      case '/medical-record-details':
        final recordId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => MedicalRecordDetailsScreen(recordId: recordId),
        );

      case '/add-medical-record':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => AddMedicalRecordScreen(
            patientId: args['patientId'],
            patientName: args['patientName'],
            recordToEdit: args['recordToEdit'],
          ),
        );

      case '/rate-doctor':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => RateDoctorScreen(
            doctorId: args['doctorId'],
            doctorName: args['doctorName'],
            appointmentId: args['appointmentId'],
          ),
        );

      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      case '/notifications':
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());

      case '/admin/advertisements':
        return MaterialPageRoute(
            builder: (_) => const AdminAdvertisementsScreen());

      case '/admin/advertisements/edit':
        final advertisement = settings.arguments as Advertisement?;
        return MaterialPageRoute(
          builder: (_) =>
              AddEditAdvertisementScreen(advertisement: advertisement),
        );

      case '/admin/link-doctor-user':
        return MaterialPageRoute(
          builder: (_) => const LinkDoctorUserScreen(),
        );

      case '/admin/manage-users':
        return MaterialPageRoute(
          builder: (_) => const ManageUsersScreen(),
        );

      case '/admin/manage-departments':
        final hospital = settings.arguments as Hospital?;
        return MaterialPageRoute(
          builder: (_) => ManageDepartmentsScreen(hospital: hospital),
        );

      case '/admin/manage-doctors':
        final hospital = settings.arguments as Hospital?;
        return MaterialPageRoute(
          builder: (_) => ManageDoctorsScreen(hospital: hospital),
        );

      case '/admin/manage-appointments':
        return MaterialPageRoute(
          builder: (_) => const ManageAppointmentsScreen(),
        );

      case '/admin/manage-notifications':
        return MaterialPageRoute(
          builder: (_) => const ManageNotificationsScreen(),
        );

      case '/admin/manage-facilities':
        return MaterialPageRoute(
          builder: (_) => const ManageFacilitiesScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
