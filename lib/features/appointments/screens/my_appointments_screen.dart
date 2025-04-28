import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../models/appointment.dart';
import '../services/appointment_service.dart';
import '../../../features/auth/services/auth_service.dart';
import '../../../core/navigation/app_navigator.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  final AppointmentService _appointmentService = AppointmentService();
  final AuthService _authService = AuthService();
  
  late TabController _tabController;
  bool _isLoading = true;
  List<Appointment> _appointments = [];
  String? _errorMessage;
  String? _userId;

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
      final appointments =
          await _appointmentService.getPatientAppointments(_userId!);
      setState(() {
        _appointments = appointments;
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
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to book appointment screen
        },
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.add),
      ),
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
              onPressed: _loadAppointments,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildAppointmentsList('Pending', 'Confirmed'),
        _buildAppointmentsList('Completed'),
        _buildAppointmentsList('Cancelled'),
      ],
    );
  }

  Widget _buildAppointmentsList(String status, [String? additionalStatus]) {
    final filteredAppointments = _appointments.where((appointment) {
      if (additionalStatus != null) {
        return appointment.status == status ||
            appointment.status == additionalStatus;
      }
      return appointment.status == status;
    }).toList();

    if (filteredAppointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 64.sp,
              color: Colors.grey,
            ),
            SizedBox(height: 16.h),
            Text(
              'لا توجد مواعيد',
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

    switch (appointment.status) {
      case 'Pending':
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
        break;
      case 'Confirmed':
        statusColor = Colors.blue;
        statusIcon = Icons.check_circle;
        break;
      case 'Completed':
        statusColor = Colors.green;
        statusIcon = Icons.done_all;
        break;
      case 'Cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to appointment details
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
                        _getStatusText(appointment.status),
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

  String _getStatusText(String status) {
    switch (status) {
      case 'Pending':
        return 'قيد الانتظار';
      case 'Confirmed':
        return 'مؤكد';
      case 'Completed':
        return 'مكتمل';
      case 'Cancelled':
        return 'ملغي';
      default:
        return status;
    }
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
