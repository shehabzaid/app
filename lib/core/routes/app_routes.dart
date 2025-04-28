import 'package:flutter/material.dart';
import '../../features/hospitals/screens/hospitals_list_screen.dart';
import '../../features/hospitals/screens/doctors_screen.dart';
import '../../features/hospitals/models/hospital.dart';

class AppRoutes {
  static const String hospitals = '/hospitals';
  static const String doctors = '/doctors';

  static Map<String, WidgetBuilder> get routes => {
        hospitals: (context) => const HospitalsListScreen(),
        doctors: (context) {
          final hospital =
              ModalRoute.of(context)!.settings.arguments as Hospital;
          return DoctorsScreen(hospital: hospital);
        },
      };
}
