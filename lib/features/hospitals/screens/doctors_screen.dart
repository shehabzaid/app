import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/widgets/error_view.dart';
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
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('الأطباء'),
            if (widget.hospital != null)
              Text(
                widget.hospital!.nameArabic,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadDoctors,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return ErrorView(
        error: _error!,
        onRetry: _loadDoctors,
      );
    }

    if (_doctors.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: const Text(
            'لا يوجد أطباء في هذا المستشفى حالياً',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
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

        // Doctors Count
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.r),
          child: Text(
            'عدد الأطباء المتاحين: ${_doctors.length}',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Doctors List
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(8.r),
            itemCount: _doctors.length,
            itemBuilder: (context, index) {
              final doctor = _doctors[index];
              return _buildDoctorCard(doctor);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorCard(Doctor doctor) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4.r, horizontal: 8.r),
      child: Padding(
        padding: EdgeInsets.all(12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF005B96),
                  child: Icon(Icons.person, color: Colors.white, size: 24.r),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.nameArabic,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        doctor.specializationArabic,
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
            if (doctor.specializationArabic.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(
                doctor.specializationArabic,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/book',
                    arguments: doctor.id,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005B96),
                  padding: EdgeInsets.symmetric(vertical: 12.r),
                ),
                child: Text(
                  'حجز موعد',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
