import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_view.dart';
import '../models/appointment.dart';
import '../services/appointment_service.dart';
import '../../../features/auth/services/auth_service.dart';
import '../../../features/hospitals/services/hospital_service.dart';
import '../../../features/hospitals/models/hospital.dart';
import '../../../features/hospitals/models/doctor.dart';
import '../../../features/auth/models/user_profile.dart';
import '../../../features/notifications/utils/notification_helper.dart';

class DoctorAppointmentDetailsScreen extends StatefulWidget {
  final String appointmentId;

  const DoctorAppointmentDetailsScreen({
    Key? key,
    required this.appointmentId,
  }) : super(key: key);

  @override
  State<DoctorAppointmentDetailsScreen> createState() =>
      _DoctorAppointmentDetailsScreenState();
}

class _DoctorAppointmentDetailsScreenState
    extends State<DoctorAppointmentDetailsScreen> {
  final AppointmentService _appointmentService = AppointmentService();
  final HospitalService _hospitalService = HospitalService();
  final AuthService _authService = AuthService();
  final NotificationHelper _notificationHelper = NotificationHelper();

  bool _isLoading = true;
  String? _errorMessage;
  Appointment? _appointment;
  Hospital? _hospital;
  Doctor? _doctor;
  UserProfile? _patient;

  @override
  void initState() {
    super.initState();
    _loadAppointmentDetails();
  }

  Future<void> _loadAppointmentDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // جلب تفاصيل الموعد
      final appointment =
          await _appointmentService.getAppointmentDetails(widget.appointmentId);
      setState(() {
        _appointment = appointment;
      });

      // جلب تفاصيل المنشأة الصحية
      if (appointment.facilityId.isNotEmpty) {
        final hospital =
            await _hospitalService.getHospitalDetails(appointment.facilityId);
        setState(() {
          _hospital = hospital;
        });
      }

      // جلب تفاصيل الطبيب
      if (appointment.doctorId != null && appointment.doctorId!.isNotEmpty) {
        final doctor =
            await _hospitalService.getDoctorDetails(appointment.doctorId!);
        setState(() {
          _doctor = doctor;
        });
      }

      // جلب تفاصيل المريض
      if (appointment.patientId.isNotEmpty) {
        final patient =
            await _authService.getUserProfileById(appointment.patientId);
        setState(() {
          _patient = patient;
        });
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      developer.log('Error loading appointment details: $e');
      setState(() {
        _errorMessage = 'فشل في تحميل تفاصيل الموعد: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الموعد'),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingIndicator();
    }

    if (_errorMessage != null) {
      return ErrorView(
        error: _errorMessage!,
        onRetry: _loadAppointmentDetails,
      );
    }

    if (_appointment == null) {
      return const Center(
        child: Text('لا توجد بيانات'),
      );
    }

    final dateFormat = DateFormat('yyyy/MM/dd', 'ar');
    final formattedDate = dateFormat.format(_appointment!.appointmentDate);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(),
          SizedBox(height: 16.h),
          _buildPatientCard(),
          SizedBox(height: 16.h),
          _buildDetailsCard(formattedDate),
          SizedBox(height: 16.h),
          if (_appointment!.status == 'Pending') ...[
            _buildPendingActionButtons(),
            SizedBox(height: 16.h),
          ],
          if (_appointment!.status == 'Confirmed') ...[
            _buildConfirmedActionButtons(),
            SizedBox(height: 16.h),
          ],
          if (_appointment!.status == 'Completed') ...[
            _buildCompletedActionButtons(),
            SizedBox(height: 16.h),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (_appointment!.status) {
      case 'Pending':
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
        statusText = 'قيد الانتظار';
        break;
      case 'Confirmed':
        statusColor = Colors.blue;
        statusIcon = Icons.check_circle;
        statusText = 'مؤكد';
        break;
      case 'Completed':
        statusColor = Colors.green;
        statusIcon = Icons.done_all;
        statusText = 'مكتمل';
        break;
      case 'Cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'ملغي';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        statusText = _appointment!.status;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                statusIcon,
                color: statusColor,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'حالة الموعد',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'بيانات المريض',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGreen,
              ),
            ),
            SizedBox(height: 16.h),
            _buildDetailRow(
              Icons.person,
              'الاسم',
              _patient?.fullName ?? 'غير متوفر',
            ),
            SizedBox(height: 12.h),
            _buildDetailRow(
              Icons.email,
              'البريد الإلكتروني',
              _patient?.email ?? 'غير متوفر',
            ),
            SizedBox(height: 12.h),
            _buildDetailRow(
              Icons.phone,
              'رقم الهاتف',
              _patient?.phone ?? 'غير متوفر',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(String formattedDate) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تفاصيل الموعد',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGreen,
              ),
            ),
            SizedBox(height: 16.h),
            _buildDetailRow(
              Icons.calendar_today,
              'التاريخ',
              formattedDate,
            ),
            SizedBox(height: 12.h),
            _buildDetailRow(
              Icons.access_time,
              'الوقت',
              _appointment!.appointmentTime,
            ),
            SizedBox(height: 12.h),
            _buildDetailRow(
              Icons.local_hospital,
              'المنشأة الصحية',
              _hospital?.nameArabic ?? 'غير متوفر',
            ),
            SizedBox(height: 12.h),
            _buildDetailRow(
              Icons.videocam,
              'نوع الموعد',
              _appointment!.isVirtual ? 'عن بعد' : 'حضوري',
            ),
            if (_appointment!.notes != null &&
                _appointment!.notes!.isNotEmpty) ...[
              SizedBox(height: 12.h),
              _buildDetailRow(
                Icons.note,
                'ملاحظات',
                _appointment!.notes!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value,
      {VoidCallback? onTap}) {
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20.sp,
          color: AppTheme.primaryGreen,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (onTap != null)
          Icon(
            Icons.arrow_forward_ios,
            size: 16.sp,
            color: Colors.grey,
          ),
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4.h),
          child: content,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: content,
    );
  }

  Widget _buildPendingActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _cancelAppointment,
            icon: const Icon(Icons.cancel, color: Colors.white),
            label: const Text('رفض الموعد'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _confirmAppointment,
            icon: const Icon(Icons.check_circle, color: Colors.white),
            label: const Text('تأكيد الموعد'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmedActionButtons() {
    return ElevatedButton.icon(
      onPressed: _completeAppointment,
      icon: const Icon(Icons.done_all, color: Colors.white),
      label: const Text('إكمال الموعد'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryGreen,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        minimumSize: Size(double.infinity, 48.h),
      ),
    );
  }

  Widget _buildCompletedActionButtons() {
    return ElevatedButton.icon(
      onPressed: _addMedicalRecord,
      icon: const Icon(Icons.medical_services, color: Colors.white),
      label: const Text('إضافة سجل طبي'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        minimumSize: Size(double.infinity, 48.h),
      ),
    );
  }

  Future<void> _cancelAppointment() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تأكيد الرفض'),
        content: const Text('هل أنت متأكد من رفض هذا الموعد؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('لا'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'نعم',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (result != true) return;

    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _appointmentService.cancelAppointment(widget.appointmentId);

      // إرسال إشعار للمريض
      if (_patient != null && _doctor != null) {
        final appointmentDateTime = DateTime(
          _appointment!.appointmentDate.year,
          _appointment!.appointmentDate.month,
          _appointment!.appointmentDate.day,
          int.parse(_appointment!.appointmentTime.split(':')[0]),
          int.parse(_appointment!.appointmentTime.split(':')[1]),
        );

        await _notificationHelper
            .sendAppointmentCancellationNotificationToPatient(
          patientId: _appointment!.patientId,
          doctorName: _doctor!.nameArabic,
          appointmentDateTime: appointmentDateTime,
          appointmentId: _appointment!.id,
        );

        developer.log('تم إرسال إشعار إلغاء الموعد للمريض بنجاح');
      }

      await _loadAppointmentDetails();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم رفض الموعد بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      developer.log('Error cancelling appointment: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'فشل في رفض الموعد: $e';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في رفض الموعد: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmAppointment() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تأكيد الموعد'),
        content: const Text('هل أنت متأكد من تأكيد هذا الموعد؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('لا'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'نعم',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );

    if (result != true) return;

    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _appointmentService.confirmAppointment(widget.appointmentId);

      // إرسال إشعار للمريض
      if (_patient != null && _doctor != null) {
        final appointmentDateTime = DateTime(
          _appointment!.appointmentDate.year,
          _appointment!.appointmentDate.month,
          _appointment!.appointmentDate.day,
          int.parse(_appointment!.appointmentTime.split(':')[0]),
          int.parse(_appointment!.appointmentTime.split(':')[1]),
        );

        await _notificationHelper
            .sendAppointmentConfirmationNotificationToPatient(
          patientId: _appointment!.patientId,
          doctorName: _doctor!.nameArabic,
          appointmentDateTime: appointmentDateTime,
          appointmentId: _appointment!.id,
        );

        developer.log('تم إرسال إشعار تأكيد الموعد للمريض بنجاح');
      }

      await _loadAppointmentDetails();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تأكيد الموعد بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      developer.log('Error confirming appointment: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'فشل في تأكيد الموعد: $e';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في تأكيد الموعد: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _completeAppointment() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('إكمال الموعد'),
        content: const Text(
            'هل أنت متأكد من إكمال هذا الموعد؟ سيتم تغيير حالته إلى "مكتمل".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('لا'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'نعم',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );

    if (result != true) return;

    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _appointmentService.completeAppointment(widget.appointmentId);

      await _loadAppointmentDetails();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إكمال الموعد بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      developer.log('Error completing appointment: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'فشل في إكمال الموعد: $e';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في إكمال الموعد: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addMedicalRecord() {
    if (_patient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يمكن إضافة سجل طبي: معلومات المريض غير متوفرة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/add-medical-record',
      arguments: {
        'patientId': _patient!.id,
        'patientName': _patient!.fullName ?? _patient!.email,
      },
    );
  }
}
