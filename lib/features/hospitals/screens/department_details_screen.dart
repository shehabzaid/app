import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/department.dart';
import '../models/doctor.dart';
import '../services/hospital_service.dart';

class DepartmentDetailsScreen extends StatefulWidget {
  final String hospitalId;
  final String departmentId;

  const DepartmentDetailsScreen({
    super.key,
    required this.hospitalId,
    required this.departmentId,
  });

  @override
  State<DepartmentDetailsScreen> createState() =>
      _DepartmentDetailsScreenState();
}

class _DepartmentDetailsScreenState extends State<DepartmentDetailsScreen> {
  final _hospitalService = HospitalService();
  bool _isLoading = true;
  String _error = '';
  Department? _department;
  List<Doctor> _doctors = [];

  @override
  void initState() {
    super.initState();
    _loadDepartmentDetails();
  }

  Future<void> _loadDepartmentDetails() async {
    try {
      setState(() => _isLoading = true);

      final department =
          await _hospitalService.getDepartmentDetails(widget.departmentId);
      final doctors =
          await _hospitalService.getDepartmentDoctors(widget.departmentId);

      setState(() {
        _department = department;
        _doctors = doctors;
        _error = '';
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_department?.nameArabic ?? 'تفاصيل القسم'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        _error,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: _loadDepartmentDetails,
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // معلومات القسم
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _department!.nameArabic,
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_department!.nameEnglish != null) ...[
                                SizedBox(height: 4.h),
                                Text(
                                  _department!.nameEnglish!,
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                              if (_department!.descriptionArabic != null) ...[
                                SizedBox(height: 16.h),
                                Text(
                                  _department!.descriptionArabic!,
                                  style: TextStyle(fontSize: 16.sp),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // قائمة الأطباء
                      Row(
                        children: [
                          Text(
                            'الأطباء',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            icon: const Icon(Icons.calendar_month),
                            label: const Text('حجز موعد'),
                            onPressed: () {
                              // التنقل إلى صفحة حجز المواعيد
                              Navigator.pushNamed(
                                context,
                                '/book-appointment',
                                arguments: {
                                  'hospitalId': widget.hospitalId,
                                  'departmentId': widget.departmentId,
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      if (_doctors.isEmpty)
                        const Center(
                          child: Text('لا يوجد أطباء متاحين حالياً'),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _doctors.length,
                          itemBuilder: (context, index) {
                            final doctor = _doctors[index];
                            return Card(
                              margin: EdgeInsets.only(bottom: 16.h),
                              child: Padding(
                                padding: EdgeInsets.all(16.w),
                                child: Row(
                                  children: [
                                    // صورة الطبيب
                                    if (doctor.imageUrl != null)
                                      Container(
                                        width: 80.w,
                                        height: 80.w,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            image:
                                                NetworkImage(doctor.imageUrl!),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                    else
                                      Container(
                                        width: 80.w,
                                        height: 80.w,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.grey,
                                        ),
                                        child: Icon(
                                          Icons.person,
                                          size: 40.w,
                                          color: Colors.white,
                                        ),
                                      ),
                                    SizedBox(width: 16.w),

                                    // معلومات الطبيب
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            doctor.nameArabic,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (doctor.nameEnglish != null)
                                            Text(
                                              doctor.nameEnglish!,
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          SizedBox(height: 8.h),
                                          Text(doctor.specializationArabic),
                                          if (doctor.qualification != null)
                                            Text(
                                              doctor.qualification!,
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12.sp,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),

                                    // زر الحجز
                                    Column(
                                      children: [
                                        IconButton(
                                          icon:
                                              const Icon(Icons.calendar_month),
                                          onPressed: () {
                                            // التنقل إلى صفحة حجز موعد مع الطبيب
                                            Navigator.pushNamed(
                                              context,
                                              '/book-appointment',
                                              arguments: {
                                                'hospitalId': widget.hospitalId,
                                                'departmentId':
                                                    widget.departmentId,
                                                'doctorId': doctor.id,
                                              },
                                            );
                                          },
                                        ),
                                        Text(
                                          'حجز موعد',
                                          style: TextStyle(fontSize: 12.sp),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
    );
  }
}
