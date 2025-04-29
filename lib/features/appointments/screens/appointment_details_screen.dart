import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../models/appointment.dart';
import '../services/appointment_service.dart';
import '../../../features/hospitals/services/hospital_service.dart';
import '../../../features/hospitals/models/hospital.dart';
import '../../../features/hospitals/models/doctor.dart';
import '../../../core/navigation/app_navigator.dart';

class AppointmentDetailsScreen extends StatefulWidget {
  final String appointmentId;

  const AppointmentDetailsScreen({
    Key? key,
    required this.appointmentId,
  }) : super(key: key);

  @override
  State<AppointmentDetailsScreen> createState() =>
      _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState extends State<AppointmentDetailsScreen> {
  final AppointmentService _appointmentService = AppointmentService();
  final HospitalService _hospitalService = HospitalService();

  bool _isLoading = true;
  Appointment? _appointment;
  Hospital? _hospital;
  Doctor? _doctor;
  String? _errorMessage;

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
      final appointment =
          await _appointmentService.getAppointmentDetails(widget.appointmentId);
      setState(() {
        _appointment = appointment;
      });

      // Cargar detalles del hospital
      if (appointment.facilityId.isNotEmpty) {
        final hospital =
            await _hospitalService.getHospitalDetails(appointment.facilityId);
        setState(() {
          _hospital = hospital;
        });
      }

      // Cargar detalles del médico
      if (appointment.doctorId != null && appointment.doctorId!.isNotEmpty) {
        final doctor =
            await _hospitalService.getDoctorDetails(appointment.doctorId!);
        setState(() {
          _doctor = doctor;
        });
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
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
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.red,
                fontSize: 16.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: _loadAppointmentDetails,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
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
          _buildDetailsCard(formattedDate),
          SizedBox(height: 16.h),
          if (_appointment!.status == 'Pending' ||
              _appointment!.status == 'Confirmed') ...[
            _buildActionButtons(),
            SizedBox(height: 16.h),
          ],
          if (_appointment!.status == 'Completed') ...[
            _buildRateButton(),
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
            Icon(
              statusIcon,
              color: statusColor,
              size: 32.sp,
            ),
            SizedBox(width: 16.w),
            Column(
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
              onTap: _hospital != null
                  ? () {
                      // TODO: Navigate to hospital details
                    }
                  : null,
            ),
            if (_doctor != null) ...[
              SizedBox(height: 12.h),
              _buildDetailRow(
                Icons.person,
                'الطبيب',
                _doctor!.nameArabic,
                onTap: () {
                  // TODO: Navigate to doctor details
                },
              ),
            ],
            if (_appointment!.isVirtual) ...[
              SizedBox(height: 12.h),
              _buildDetailRow(
                Icons.videocam,
                'نوع الموعد',
                'موعد افتراضي (عن بعد)',
              ),
            ],
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

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20.sp,
          color: Colors.grey[600],
        ),
        SizedBox(width: 12.w),
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
        if (onTap != null) ...[
          Icon(
            Icons.arrow_forward_ios,
            size: 16.sp,
            color: Colors.grey[400],
          ),
        ],
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

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _cancelAppointment,
            icon: const Icon(Icons.cancel, color: Colors.white),
            label: const Text('إلغاء الموعد'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ),
        if (_appointment!.isVirtual && _appointment!.status == 'Confirmed') ...[
          SizedBox(width: 16.w),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Join virtual appointment
              },
              icon: const Icon(Icons.videocam, color: Colors.white),
              label: const Text('انضمام للموعد'),
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
      ],
    );
  }

  Widget _buildRateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // التنقل إلى شاشة تقييم الطبيب
          if (_doctor != null) {
            AppNavigator.navigateToRateDoctor(
              context,
              doctorId: _doctor!.id,
              doctorName: _doctor!.nameArabic,
              hospitalName: _hospital?.nameArabic ?? '',
              appointmentId: widget.appointmentId,
            );

            // إضافة مستمع للتنقل للتحقق من العودة من شاشة التقييم
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // إعادة تحميل البيانات بعد العودة من شاشة التقييم
              _loadAppointmentDetails();
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('لا يمكن تقييم الطبيب: بيانات الطبيب غير متوفرة'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        icon: const Icon(Icons.star, color: Colors.white),
        label: const Text('تقييم الطبيب'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryGreen,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),
    );
  }

  Future<void> _cancelAppointment() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الإلغاء'),
        content: const Text('هل أنت متأكد من إلغاء هذا الموعد؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لا'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _appointmentService
                    .cancelAppointment(widget.appointmentId);
                await _loadAppointmentDetails();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم إلغاء الموعد بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('فشل في إلغاء الموعد: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'نعم',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
