import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../appointments/models/appointment.dart';
import '../../appointments/services/appointment_service.dart';
import '../../auth/services/auth_service.dart';
import '../../../core/navigation/app_navigator.dart';

class MyAppointmentsScreenNew extends StatefulWidget {
  const MyAppointmentsScreenNew({Key? key}) : super(key: key);

  @override
  State<MyAppointmentsScreenNew> createState() => _MyAppointmentsScreenNewState();
}

class _MyAppointmentsScreenNewState extends State<MyAppointmentsScreenNew>
    with SingleTickerProviderStateMixin {
  final AppointmentService _appointmentService = AppointmentService();
  final AuthService _authService = AuthService();
  
  late TabController _tabController;
  bool _isLoading = true;
  String? _errorMessage;
  String? _userId;
  
  List<Appointment> _appointments = [];
  List<Appointment> _upcomingAppointments = [];
  List<Appointment> _completedAppointments = [];
  List<Appointment> _cancelledAppointments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserAndAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserAndAppointments() async {
    try {
      final currentUser = await _authService.getCurrentUserProfile();
      if (currentUser == null) {
        setState(() {
          _errorMessage = 'لم يتم العثور على بيانات المستخدم';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _userId = currentUser.id;
      });

      await _loadAppointments();
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل في تحميل بيانات المستخدم: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAppointments() async {
    if (_userId == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final appointments = await _appointmentService.getPatientAppointments(_userId!);
      
      // تصنيف المواعيد
      final upcomingAppointments = <Appointment>[];
      final completedAppointments = <Appointment>[];
      final cancelledAppointments = <Appointment>[];
      
      for (final appointment in appointments) {
        if (appointment.status == 'Cancelled') {
          cancelledAppointments.add(appointment);
        } else if (appointment.status == 'Completed') {
          completedAppointments.add(appointment);
        } else {
          // Pending or Confirmed
          upcomingAppointments.add(appointment);
        }
      }
      
      setState(() {
        _appointments = appointments;
        _upcomingAppointments = upcomingAppointments;
        _completedAppointments = completedAppointments;
        _cancelledAppointments = cancelledAppointments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل في تحميل المواعيد: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مواعيدي'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'القادمة'),
            Tab(text: 'المكتملة'),
            Tab(text: 'الملغاة'),
          ],
          labelColor: AppTheme.primaryGreen,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryGreen,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
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
                        onPressed: _loadAppointments,
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // المواعيد القادمة
                    _buildAppointmentsList(_upcomingAppointments, 'Pending', 'Confirmed'),
                    
                    // المواعيد المكتملة
                    _buildAppointmentsList(_completedAppointments, 'Completed'),
                    
                    // المواعيد الملغاة
                    _buildAppointmentsList(_cancelledAppointments, 'Cancelled'),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AppNavigator.navigateToHospitals(context);
        },
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAppointmentsList(List<Appointment> appointments, String status, [String? additionalStatus]) {
    final filteredAppointments = appointments.where((appointment) {
      if (additionalStatus != null) {
        return appointment.status == status ||
            appointment.status == additionalStatus;
      }
      return appointment.status == status;
    }).toList();

    if (filteredAppointments.isEmpty) {
      IconData iconData;
      String message;
      
      if (status == 'Pending' || status == 'Confirmed') {
        iconData = Icons.calendar_today;
        message = 'لا توجد مواعيد قادمة';
      } else if (status == 'Completed') {
        iconData = Icons.history;
        message = 'لا توجد مواعيد مكتملة';
      } else {
        iconData = Icons.cancel;
        message = 'لا توجد مواعيد ملغاة';
      }
      
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              iconData,
              size: 64.sp,
              color: Colors.grey,
            ),
            SizedBox(height: 16.h),
            Text(
              message,
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAppointments,
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: filteredAppointments.length,
        itemBuilder: (context, index) {
          return _buildAppointmentCard(filteredAppointments[index]);
        },
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    final dateFormat = DateFormat('yyyy/MM/dd', 'ar');
    final formattedDate = dateFormat.format(appointment.appointmentDate);

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (appointment.status) {
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
        statusText = appointment.status;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: () {
          AppNavigator.navigateToAppointmentDetails(context, appointment.id);
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        statusIcon,
                        color: statusColor,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16.sp,
                    color: Colors.grey[600],
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    appointment.appointmentTime,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(
                    Icons.local_hospital,
                    size: 16.sp,
                    color: Colors.grey[600],
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'المنشأة الصحية', // TODO: Get facility name
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[800],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (appointment.doctorId != null) ...[
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16.sp,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'الطبيب', // TODO: Get doctor name
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[800],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(
                      Icons.note,
                      size: 16.sp,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        appointment.notes!,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[800],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(height: 12.h),
              if (appointment.status == 'Pending' ||
                  appointment.status == 'Confirmed') ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _cancelAppointment(appointment.id),
                      child: Text(
                        'إلغاء الموعد',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _cancelAppointment(String appointmentId) async {
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
                await _appointmentService.cancelAppointment(appointmentId);
                await _loadAppointments();
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
