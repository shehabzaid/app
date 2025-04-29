import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;
import 'package:uuid/uuid.dart';
import '../../../core/config/supabase_config.dart';
import '../models/appointment.dart';

class AppointmentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // جلب مواعيد المريض
  Future<List<Appointment>> getPatientAppointments(String patientId) async {
    try {
      developer.log('Fetching appointments for patient: $patientId');

      final response = await _supabase
          .from(SupabaseConfig.appointmentsTable)
          .select()
          .eq('patient_id', patientId)
          .order('appointment_date', ascending: false);

      developer.log('Appointments response received');

      return (response as List)
          .map((json) => Appointment.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      developer.log('Error fetching appointments: $e');
      developer.log('Stack trace: $stackTrace');
      throw Exception('فشل في جلب قائمة المواعيد: $e');
    }
  }

  // جلب مواعيد الطبيب
  Future<List<Appointment>> getDoctorAppointments(String doctorId) async {
    try {
      developer.log('Fetching appointments for doctor: $doctorId');

      final response = await _supabase
          .from(SupabaseConfig.appointmentsTable)
          .select()
          .eq('doctor_id', doctorId)
          .order('appointment_date', ascending: false);

      developer.log('Appointments response received');

      return (response as List)
          .map((json) => Appointment.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      developer.log('Error fetching appointments: $e');
      developer.log('Stack trace: $stackTrace');
      throw Exception('فشل في جلب قائمة المواعيد: $e');
    }
  }

  // جلب مواعيد المنشأة الصحية
  Future<List<Appointment>> getFacilityAppointments(String facilityId) async {
    try {
      developer.log('Fetching appointments for facility: $facilityId');

      final response = await _supabase
          .from(SupabaseConfig.appointmentsTable)
          .select()
          .eq('facility_id', facilityId)
          .order('appointment_date', ascending: false);

      developer.log('Appointments response received');

      return (response as List)
          .map((json) => Appointment.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      developer.log('Error fetching appointments: $e');
      developer.log('Stack trace: $stackTrace');
      throw Exception('فشل في جلب قائمة المواعيد: $e');
    }
  }

  // جلب تفاصيل موعد محدد
  Future<Appointment> getAppointmentDetails(String appointmentId) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.appointmentsTable)
          .select()
          .eq('id', appointmentId)
          .single();

      return Appointment.fromJson(response);
    } catch (e) {
      throw Exception('فشل في جلب تفاصيل الموعد: $e');
    }
  }

  // حجز موعد جديد
  Future<Appointment?> bookAppointment(Appointment appointment) async {
    try {
      // Generate a UUID for the appointment if it doesn't have one
      final appointmentData = appointment.toJson();
      if (appointmentData['id'] == null ||
          appointmentData['id'].toString().isEmpty) {
        // Use the uuid package to generate a proper UUID
        appointmentData['id'] = const Uuid().v4();
        developer
            .log('Generated UUID for appointment: ${appointmentData['id']}');
      }

      await _supabase
          .from(SupabaseConfig.appointmentsTable)
          .insert(appointmentData);

      // Return the appointment with the generated ID
      return Appointment.fromJson(appointmentData);
    } catch (e) {
      developer.log('Error booking appointment: $e');
      throw Exception('فشل في حجز الموعد: $e');
    }
  }

  // تحديث حالة موعد
  Future<void> updateAppointmentStatus(
      String appointmentId, String status) async {
    try {
      await _supabase
          .from(SupabaseConfig.appointmentsTable)
          .update({'status': status}).eq('id', appointmentId);
    } catch (e) {
      throw Exception('فشل في تحديث حالة الموعد: $e');
    }
  }

  // إلغاء موعد
  Future<void> cancelAppointment(String appointmentId) async {
    try {
      await updateAppointmentStatus(appointmentId, 'Cancelled');
    } catch (e) {
      throw Exception('فشل في إلغاء الموعد: $e');
    }
  }

  // تأكيد موعد
  Future<void> confirmAppointment(String appointmentId) async {
    try {
      await updateAppointmentStatus(appointmentId, 'Confirmed');
    } catch (e) {
      throw Exception('فشل في تأكيد الموعد: $e');
    }
  }

  // إكمال موعد
  Future<void> completeAppointment(String appointmentId) async {
    try {
      await updateAppointmentStatus(appointmentId, 'Completed');
    } catch (e) {
      throw Exception('فشل في إكمال الموعد: $e');
    }
  }

  // تحديث موعد
  Future<void> updateAppointment(Appointment appointment) async {
    try {
      await _supabase
          .from(SupabaseConfig.appointmentsTable)
          .update(appointment.toJson())
          .eq('id', appointment.id);
    } catch (e) {
      throw Exception('فشل في تحديث الموعد: $e');
    }
  }

  // حذف موعد
  Future<void> deleteAppointment(String appointmentId) async {
    try {
      await _supabase
          .from(SupabaseConfig.appointmentsTable)
          .delete()
          .eq('id', appointmentId);
    } catch (e) {
      throw Exception('فشل في حذف الموعد: $e');
    }
  }
}
