import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/doctor.dart';
import '../models/hospital.dart';
import '../services/hospital_service.dart';

class DoctorsScreen extends StatefulWidget {
  final Hospital? hospital;

  const DoctorsScreen({Key? key, this.hospital}) : super(key: key);

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  final HospitalService _hospitalService = HospitalService();
  bool _isLoading = true;
  String? _error;
  List<Doctor> _doctors = [];

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      List<Doctor> doctors = [];

      if (widget.hospital != null) {
        // Si se proporciona un hospital específico, cargamos sus médicos
        doctors =
            await _hospitalService.getDoctorsByHospital(widget.hospital!.id);
      } else {
        // Si no se proporciona un hospital, cargamos todos los médicos
        doctors = await _hospitalService.getAllDoctors();
      }

      setState(() {
        _doctors = doctors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'حدث خطأ أثناء تحميل قائمة الأطباء: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF005B96),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الأطباء',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.hospital != null)
              Text(
                widget.hospital!.nameArabic,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.normal,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // يمكن إضافة وظيفة البحث هنا لاحقاً
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // يمكن إضافة وظيفة التصفية هنا لاحقاً
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDoctors,
        color: const Color(0xFF005B96),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFF005B96)),
            SizedBox(height: 16.h),
            Text(
              'جاري تحميل قائمة الأطباء...',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60.r, color: Colors.red[300]),
              SizedBox(height: 16.h),
              Text(
                'حدث خطأ أثناء تحميل البيانات',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '$_error',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              ElevatedButton.icon(
                onPressed: _loadDoctors,
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005B96),
                  foregroundColor: Colors.white,
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_doctors.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off, size: 60.r, color: Colors.grey[400]),
              SizedBox(height: 16.h),
              Text(
                'لا يوجد أطباء متاحين حالياً',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'يرجى المحاولة مرة أخرى لاحقاً أو تغيير معايير البحث',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              ElevatedButton.icon(
                onPressed: _loadDoctors,
                icon: const Icon(Icons.refresh),
                label: const Text('تحديث'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005B96),
                  foregroundColor: Colors.white,
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Hospital Info Card
        if (widget.hospital != null)
          Card(
            margin: EdgeInsets.all(8.r),
            child: Padding(
              padding: EdgeInsets.all(12.r),
              child: Row(
                children: [
                  const Icon(Icons.local_hospital, color: Color(0xFF005B96)),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.hospital!.nameArabic,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${widget.hospital!.city} - ${widget.hospital!.region}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

        // رأس القائمة مع عدد الأطباء
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.people,
                      color: const Color(0xFF005B96), size: 20.r),
                  SizedBox(width: 8.w),
                  Text(
                    'عدد الأطباء المتاحين:',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF005B96),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '${_doctors.length}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                'اضغط على الطبيب للتفاصيل',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),

        // قائمة الأطباء
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(8.r),
            itemCount: _doctors.length,
            itemBuilder: (context, index) {
              final doctor = _doctors[index];
              return GestureDetector(
                onTap: () {
                  // التنقل إلى صفحة تفاصيل الطبيب
                  Navigator.pushNamed(
                    context,
                    '/doctor-details',
                    arguments: {
                      'doctorId': doctor.id,
                      'hospitalId': doctor.facilityId,
                    },
                  );
                },
                child: _buildDoctorCard(doctor),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorCard(Doctor doctor) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.r, horizontal: 8.r),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.white,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // رأس البطاقة مع صورة الطبيب والمعلومات الأساسية
            Container(
              padding: EdgeInsets.all(16.r),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // صورة الطبيب
                  Container(
                    width: 70.r,
                    height: 70.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: doctor.profilePhotoUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(35.r),
                            child: Image.network(
                              doctor.profilePhotoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  CircleAvatar(
                                radius: 35.r,
                                backgroundColor: const Color(0xFF005B96),
                                child: Icon(Icons.person,
                                    color: Colors.white, size: 35.r),
                              ),
                            ),
                          )
                        : CircleAvatar(
                            radius: 35.r,
                            backgroundColor: const Color(0xFF005B96),
                            child: Icon(Icons.person,
                                color: Colors.white, size: 35.r),
                          ),
                  ),
                  SizedBox(width: 16.w),

                  // معلومات الطبيب
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // اسم الطبيب
                        Text(
                          'د. ${doctor.nameArabic}',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF005B96),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),

                        // التخصص
                        Row(
                          children: [
                            Icon(Icons.medical_services,
                                size: 16.r, color: Colors.grey[600]),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                doctor.specializationArabic,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        // المؤهلات إذا كانت متوفرة
                        if (doctor.qualification != null &&
                            doctor.qualification!.isNotEmpty) ...[
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Icon(Icons.school,
                                  size: 16.r, color: Colors.grey[600]),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Text(
                                  doctor.qualification!,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // فاصل
            Divider(
                height: 1, thickness: 1, color: Colors.grey.withOpacity(0.2)),

            // معلومات إضافية
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 12.r),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // البريد الإلكتروني
                  if (doctor.email != null && doctor.email!.isNotEmpty)
                    _buildInfoItem(
                        Icons.email_outlined, 'البريد الإلكتروني متاح'),

                  // رقم الهاتف
                  if (doctor.phone != null && doctor.phone!.isNotEmpty)
                    _buildInfoItem(Icons.phone_outlined, 'الاتصال متاح'),

                  // المستشفى
                  _buildInfoItem(Icons.local_hospital_outlined, 'متاح للحجز'),
                ],
              ),
            ),

            // زر حجز موعد
            Padding(
              padding: EdgeInsets.all(16.r),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/book-appointment',
                      arguments: {
                        'doctorId': doctor.id,
                        'hospitalId': doctor.facilityId,
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005B96),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.r),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_today),
                      SizedBox(width: 8.w),
                      Text(
                        'حجز موعد',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF005B96), size: 20.r),
        SizedBox(height: 4.h),
        Text(
          text,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
