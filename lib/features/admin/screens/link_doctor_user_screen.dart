import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/models/user_profile.dart';
import '../../hospitals/services/hospital_service.dart';
import '../../hospitals/models/doctor.dart';

class LinkDoctorUserScreen extends StatefulWidget {
  const LinkDoctorUserScreen({super.key});

  @override
  State<LinkDoctorUserScreen> createState() => _LinkDoctorUserScreenState();
}

class _LinkDoctorUserScreenState extends State<LinkDoctorUserScreen> {
  final _hospitalService = HospitalService();
  final _authService = AuthService();

  bool _isLoading = true;
  bool _isProcessing = false;
  String _error = '';

  List<Doctor> _doctors = [];
  List<UserProfile> _users = [];

  Doctor? _selectedDoctor;
  UserProfile? _selectedUser;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      // جلب قائمة الأطباء
      final doctors = await _hospitalService.getAllDoctors();

      // جلب قائمة المستخدمين
      final users = await _authService.getAllUsers();

      setState(() {
        _doctors = doctors;
        _users = users.where((user) => user.role != 'Doctor').toList();
        _isLoading = false;
      });
    } catch (e) {
      developer.log('Error loading data: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _linkDoctorToUser() async {
    if (_selectedDoctor == null || _selectedUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار طبيب ومستخدم'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() {
        _isProcessing = true;
      });

      await _hospitalService.linkDoctorToUser(
        _selectedDoctor!.id,
        _selectedUser!.id,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم ربط الطبيب بالمستخدم بنجاح'),
          backgroundColor: Colors.green,
        ),
      );

      // إعادة تحميل البيانات
      await _loadData();
    } catch (e) {
      developer.log('Error linking doctor to user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في ربط الطبيب بالمستخدم: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _unlinkDoctor(Doctor doctor) async {
    try {
      setState(() {
        _isProcessing = true;
      });

      await _hospitalService.unlinkDoctorFromUser(doctor.id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إلغاء ربط الطبيب بالمستخدم بنجاح'),
          backgroundColor: Colors.green,
        ),
      );

      // إعادة تحميل البيانات
      await _loadData();
    } catch (e) {
      developer.log('Error unlinking doctor from user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في إلغاء ربط الطبيب بالمستخدم: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ربط الأطباء بالمستخدمين'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const LoadingView()
          : _error.isNotEmpty
              ? ErrorView(
                  error: _error,
                  onRetry: _loadData,
                )
              : Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // قسم ربط طبيب بمستخدم
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ربط طبيب بمستخدم',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16.h),

                              // اختيار الطبيب
                              DropdownButtonFormField<Doctor>(
                                decoration: const InputDecoration(
                                  labelText: 'اختر الطبيب',
                                  border: OutlineInputBorder(),
                                ),
                                value: _selectedDoctor,
                                items: _doctors
                                    .where((doctor) => doctor.userId == null)
                                    .map((doctor) => DropdownMenuItem<Doctor>(
                                          value: doctor,
                                          child: Text(doctor.nameArabic),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedDoctor = value;
                                  });
                                },
                              ),
                              SizedBox(height: 16.h),

                              // اختيار المستخدم
                              DropdownButtonFormField<UserProfile>(
                                decoration: const InputDecoration(
                                  labelText: 'اختر المستخدم',
                                  border: OutlineInputBorder(),
                                ),
                                value: _selectedUser,
                                items: _users
                                    .map((user) =>
                                        DropdownMenuItem<UserProfile>(
                                          value: user,
                                          child:
                                              Text(user.fullName ?? user.email),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedUser = value;
                                  });
                                },
                              ),
                              SizedBox(height: 16.h),

                              // زر الربط
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed:
                                      _isProcessing ? null : _linkDoctorToUser,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryGreen,
                                    foregroundColor: Colors.white,
                                    padding:
                                        EdgeInsets.symmetric(vertical: 12.h),
                                  ),
                                  child: _isProcessing
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : const Text('ربط الطبيب بالمستخدم'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // قائمة الأطباء المرتبطين بمستخدمين
                      Text(
                        'الأطباء المرتبطين بمستخدمين',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),

                      Expanded(
                        child: _doctors
                                .where((doctor) => doctor.userId != null)
                                .isEmpty
                            ? const Center(
                                child: Text('لا يوجد أطباء مرتبطين بمستخدمين'),
                              )
                            : ListView.builder(
                                itemCount: _doctors
                                    .where((doctor) => doctor.userId != null)
                                    .length,
                                itemBuilder: (context, index) {
                                  final doctor = _doctors
                                      .where((doctor) => doctor.userId != null)
                                      .toList()[index];

                                  // البحث عن المستخدم المرتبط
                                  final linkedUser = _users.firstWhere(
                                    (user) => user.id == doctor.userId,
                                    orElse: () => UserProfile(
                                      id: '',
                                      email: 'غير معروف',
                                      role: 'Unknown',
                                      isActive: true,
                                      createdAt: DateTime.now(),
                                    ),
                                  );

                                  return Card(
                                    margin: EdgeInsets.only(bottom: 8.h),
                                    child: ListTile(
                                      title: Text(doctor.nameArabic),
                                      subtitle: Text(
                                        'مرتبط بـ: ${linkedUser.fullName ?? linkedUser.email}',
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.link_off),
                                        onPressed: _isProcessing
                                            ? null
                                            : () => _unlinkDoctor(doctor),
                                        tooltip: 'إلغاء الربط',
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
