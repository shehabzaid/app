/// كلاس يحتوي على قوالب ثابتة للإشعارات
class NotificationMessages {
  // أنواع الإشعارات
  static const String typeAppointment = 'appointment';
  static const String typeMedicalRecord = 'medical_record';
  static const String typeSystem = 'system';
  
  // عناوين الإشعارات
  static const String titleNewAppointment = 'موعد جديد';
  static const String titleAppointmentConfirmed = 'تم تأكيد موعدك';
  static const String titleAppointmentCancelled = 'تم إلغاء موعدك';
  static const String titleNewMedicalRecord = 'سجل طبي جديد';
  static const String titleReminderAppointment = 'تذكير بموعدك';
  
  /// إشعار موعد جديد للطبيب
  static String newAppointmentForDoctor({
    required String patientName,
    required String appointmentDate,
    required String appointmentTime,
  }) {
    return 'لديك موعد جديد مع المريض $patientName بتاريخ $appointmentDate في الساعة $appointmentTime.';
  }
  
  /// إشعار تأكيد الموعد للمريض
  static String appointmentConfirmedForPatient({
    required String doctorName,
    required String appointmentDate,
    required String appointmentTime,
  }) {
    return 'تم تأكيد موعدك مع الدكتور $doctorName بتاريخ $appointmentDate في الساعة $appointmentTime. نتمنى لك الصحة والعافية.';
  }
  
  /// إشعار إلغاء الموعد للمريض
  static String appointmentCancelledForPatient({
    required String doctorName,
    required String appointmentDate,
  }) {
    return 'نأسف لإبلاغك بأن موعدك مع الدكتور $doctorName بتاريخ $appointmentDate قد تم إلغاؤه. يرجى حجز موعد جديد.';
  }
  
  /// إشعار تذكير بالموعد للمريض
  static String appointmentReminderForPatient({
    required String doctorName,
    required String appointmentDate,
    required String appointmentTime,
    required String hospitalName,
  }) {
    return 'تذكير بموعدك غداً مع الدكتور $doctorName في $hospitalName بتاريخ $appointmentDate في الساعة $appointmentTime.';
  }
  
  /// إشعار سجل طبي جديد للمريض
  static String newMedicalRecordForPatient({
    required String doctorName,
    String? recordTitle,
  }) {
    if (recordTitle != null && recordTitle.isNotEmpty) {
      return 'قام الدكتور $doctorName بإضافة سجل طبي جديد "$recordTitle" لملفك الطبي.';
    }
    return 'قام الدكتور $doctorName بإضافة سجل طبي جديد لملفك الطبي.';
  }
  
  /// إشعار تغيير حالة الموعد للمريض
  static String appointmentStatusChangedForPatient({
    required String doctorName,
    required String appointmentDate,
    required String newStatus,
  }) {
    return 'تم تغيير حالة موعدك مع الدكتور $doctorName بتاريخ $appointmentDate إلى "$newStatus".';
  }
  
  /// إشعار تغيير حالة الموعد للطبيب
  static String appointmentStatusChangedForDoctor({
    required String patientName,
    required String appointmentDate,
    required String newStatus,
  }) {
    return 'تم تغيير حالة موعد المريض $patientName بتاريخ $appointmentDate إلى "$newStatus".';
  }
  
  /// إشعار تقييم جديد للطبيب
  static String newRatingForDoctor({
    required String patientName,
    required double rating,
  }) {
    return 'قام المريض $patientName بتقييمك بـ $rating نجوم.';
  }
  
  /// إشعار نظام عام
  static String systemNotification({
    required String message,
  }) {
    return message;
  }
  
  /// تنسيق التاريخ بالعربية
  static String formatDateArabic(DateTime date) {
    final List<String> arabicMonths = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    
    final String day = date.day.toString();
    final String month = arabicMonths[date.month - 1];
    final String year = date.year.toString();
    
    return '$day $month $year';
  }
  
  /// تنسيق الوقت بالعربية
  static String formatTimeArabic(DateTime time) {
    final int hour = time.hour;
    final String minute = time.minute.toString().padLeft(2, '0');
    final String period = hour < 12 ? 'صباحاً' : 'مساءً';
    final int hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    
    return '$hour12:$minute $period';
  }
}
