import 'dart:developer' as developer;
import '../services/notification_service.dart';
import '../utils/notification_messages.dart';
import '../../../features/appointments/models/appointment.dart';
import '../../../features/hospitals/models/doctor.dart';

import '../../../features/auth/models/user_profile.dart';
import '../../../features/medical_records/models/medical_record.dart';

/// كلاس مساعد لإرسال الإشعارات
class NotificationHelper {
  final NotificationService _notificationService = NotificationService();

  /// إرسال إشعار موعد جديد للطبيب
  Future<void> sendNewAppointmentNotificationToDoctor({
    required String doctorId,
    required String patientName,
    required DateTime appointmentDateTime,
    required String appointmentId,
  }) async {
    try {
      final String appointmentDate =
          NotificationMessages.formatDateArabic(appointmentDateTime);
      final String appointmentTime =
          NotificationMessages.formatTimeArabic(appointmentDateTime);

      await _notificationService.addNotification(
        doctorId,
        NotificationMessages.titleNewAppointment,
        NotificationMessages.newAppointmentForDoctor(
          patientName: patientName,
          appointmentDate: appointmentDate,
          appointmentTime: appointmentTime,
        ),
        type: NotificationMessages.typeAppointment,
        referenceId: appointmentId,
      );

      developer.log('تم إرسال إشعار موعد جديد للطبيب بنجاح');
    } catch (e) {
      developer.log('فشل في إرسال إشعار موعد جديد للطبيب: $e');
    }
  }

  /// إرسال إشعار تأكيد الموعد للمريض
  Future<void> sendAppointmentConfirmationNotificationToPatient({
    required String patientId,
    required String doctorName,
    required DateTime appointmentDateTime,
    required String appointmentId,
  }) async {
    try {
      final String appointmentDate =
          NotificationMessages.formatDateArabic(appointmentDateTime);
      final String appointmentTime =
          NotificationMessages.formatTimeArabic(appointmentDateTime);

      await _notificationService.addNotification(
        patientId,
        NotificationMessages.titleAppointmentConfirmed,
        NotificationMessages.appointmentConfirmedForPatient(
          doctorName: doctorName,
          appointmentDate: appointmentDate,
          appointmentTime: appointmentTime,
        ),
        type: NotificationMessages.typeAppointment,
        referenceId: appointmentId,
      );

      developer.log('تم إرسال إشعار تأكيد الموعد للمريض بنجاح');
    } catch (e) {
      developer.log('فشل في إرسال إشعار تأكيد الموعد للمريض: $e');
    }
  }

  /// إرسال إشعار إلغاء الموعد للمريض
  Future<void> sendAppointmentCancellationNotificationToPatient({
    required String patientId,
    required String doctorName,
    required DateTime appointmentDateTime,
    required String appointmentId,
  }) async {
    try {
      final String appointmentDate =
          NotificationMessages.formatDateArabic(appointmentDateTime);

      await _notificationService.addNotification(
        patientId,
        NotificationMessages.titleAppointmentCancelled,
        NotificationMessages.appointmentCancelledForPatient(
          doctorName: doctorName,
          appointmentDate: appointmentDate,
        ),
        type: NotificationMessages.typeAppointment,
        referenceId: appointmentId,
      );

      developer.log('تم إرسال إشعار إلغاء الموعد للمريض بنجاح');
    } catch (e) {
      developer.log('فشل في إرسال إشعار إلغاء الموعد للمريض: $e');
    }
  }

  /// إرسال إشعار تذكير بالموعد للمريض
  Future<void> sendAppointmentReminderNotificationToPatient({
    required String patientId,
    required String doctorName,
    required DateTime appointmentDateTime,
    required String hospitalName,
    required String appointmentId,
  }) async {
    try {
      final String appointmentDate =
          NotificationMessages.formatDateArabic(appointmentDateTime);
      final String appointmentTime =
          NotificationMessages.formatTimeArabic(appointmentDateTime);

      await _notificationService.addNotification(
        patientId,
        NotificationMessages.titleReminderAppointment,
        NotificationMessages.appointmentReminderForPatient(
          doctorName: doctorName,
          appointmentDate: appointmentDate,
          appointmentTime: appointmentTime,
          hospitalName: hospitalName,
        ),
        type: NotificationMessages.typeAppointment,
        referenceId: appointmentId,
      );

      developer.log('تم إرسال إشعار تذكير بالموعد للمريض بنجاح');
    } catch (e) {
      developer.log('فشل في إرسال إشعار تذكير بالموعد للمريض: $e');
    }
  }

  /// إرسال إشعار سجل طبي جديد للمريض
  Future<void> sendNewMedicalRecordNotificationToPatient({
    required String patientId,
    required String doctorName,
    required String recordId,
    String? recordTitle,
  }) async {
    try {
      await _notificationService.addNotification(
        patientId,
        NotificationMessages.titleNewMedicalRecord,
        NotificationMessages.newMedicalRecordForPatient(
          doctorName: doctorName,
          recordTitle: recordTitle,
        ),
        type: NotificationMessages.typeMedicalRecord,
        referenceId: recordId,
      );

      developer.log('تم إرسال إشعار سجل طبي جديد للمريض بنجاح');
    } catch (e) {
      developer.log('فشل في إرسال إشعار سجل طبي جديد للمريض: $e');
    }
  }

  /// إرسال إشعار تقييم جديد للطبيب
  Future<void> sendNewRatingNotificationToDoctor({
    required String doctorId,
    required String patientName,
    required double rating,
    required String appointmentId,
  }) async {
    try {
      await _notificationService.addNotification(
        doctorId,
        'تقييم جديد',
        NotificationMessages.newRatingForDoctor(
          patientName: patientName,
          rating: rating,
        ),
        type: NotificationMessages.typeAppointment,
        referenceId: appointmentId,
      );

      developer.log('تم إرسال إشعار تقييم جديد للطبيب بنجاح');
    } catch (e) {
      developer.log('فشل في إرسال إشعار تقييم جديد للطبيب: $e');
    }
  }

  /// إرسال إشعار نظام عام
  Future<void> sendSystemNotification({
    required String userId,
    required String title,
    required String message,
  }) async {
    try {
      await _notificationService.addNotification(
        userId,
        title,
        message,
        type: NotificationMessages.typeSystem,
      );

      developer.log('تم إرسال إشعار نظام عام بنجاح');
    } catch (e) {
      developer.log('فشل في إرسال إشعار نظام عام: $e');
    }
  }

  /// إرسال إشعار موعد جديد من كائن الموعد
  Future<void> sendNotificationsForNewAppointment(
      Appointment appointment, UserProfile patient, Doctor doctor) async {
    // إرسال إشعار للطبيب
    await sendNewAppointmentNotificationToDoctor(
      doctorId: doctor.id,
      patientName: patient.fullName ?? patient.email,
      appointmentDateTime: DateTime(
        appointment.appointmentDate.year,
        appointment.appointmentDate.month,
        appointment.appointmentDate.day,
        int.parse(appointment.appointmentTime.split(':')[0]),
        int.parse(appointment.appointmentTime.split(':')[1]),
      ),
      appointmentId: appointment.id,
    );
  }

  /// إرسال إشعار تأكيد الموعد من كائن الموعد
  Future<void> sendNotificationsForConfirmedAppointment(
      Appointment appointment, UserProfile patient, Doctor doctor) async {
    // إرسال إشعار للمريض
    await sendAppointmentConfirmationNotificationToPatient(
      patientId: patient.id,
      doctorName: doctor.nameArabic,
      appointmentDateTime: DateTime(
        appointment.appointmentDate.year,
        appointment.appointmentDate.month,
        appointment.appointmentDate.day,
        int.parse(appointment.appointmentTime.split(':')[0]),
        int.parse(appointment.appointmentTime.split(':')[1]),
      ),
      appointmentId: appointment.id,
    );
  }

  /// إرسال إشعار سجل طبي جديد من كائن السجل الطبي
  Future<void> sendNotificationsForNewMedicalRecord(
      MedicalRecord record, UserProfile patient, Doctor doctor) async {
    // إرسال إشعار للمريض
    await sendNewMedicalRecordNotificationToPatient(
      patientId: patient.id,
      doctorName: doctor.nameArabic,
      recordId: record.id,
      recordTitle: record.diagnosis, // Using diagnosis as title
    );
  }
}
