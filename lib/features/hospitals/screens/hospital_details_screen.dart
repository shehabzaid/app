import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:developer' as developer;
import '../models/hospital.dart';
import '../models/department.dart';
import '../models/doctor.dart';
import '../services/hospital_service.dart';
import 'package:url_launcher/url_launcher.dart';

class HospitalDetailsScreen extends StatefulWidget {
  final String hospitalId;

  const HospitalDetailsScreen({
    super.key,
    required this.hospitalId,
  });

  @override
  State<HospitalDetailsScreen> createState() => _HospitalDetailsScreenState();
}

class _HospitalDetailsScreenState extends State<HospitalDetailsScreen> {
  final _hospitalService = HospitalService();
  bool _isLoading = true;
  String _error = '';
  Hospital? _hospital;
  List<Department> _departments = [];
  List<Doctor> _doctors = [];

  @override
  void initState() {
    super.initState();
    _loadHospitalDetails();
  }

  Future<void> _loadHospitalDetails() async {
    try {
      setState(() => _isLoading = true);

      developer.log('Loading hospital details for ID: ${widget.hospitalId}');

      final hospital =
          await _hospitalService.getHospitalDetails(widget.hospitalId);
      developer.log('Hospital details loaded: ${hospital.nameArabic}');

      final departments =
          await _hospitalService.getHospitalDepartments(widget.hospitalId);
      developer.log('Departments loaded: ${departments.length}');

      // Load doctors directly from the hospital
      final doctors =
          await _hospitalService.getDoctorsByHospital(widget.hospitalId);
      developer.log('Doctors loaded directly: ${doctors.length}');

      setState(() {
        _hospital = hospital;
        _departments = departments;
        _doctors = doctors;
        _error = '';
      });
    } catch (e, stackTrace) {
      developer.log('Error loading hospital details: $e');
      developer.log('Stack trace: $stackTrace');
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openMap() async {
    if (_hospital?.locationLat != null && _hospital?.locationLong != null) {
      final url = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=${_hospital!.locationLat},${_hospital!.locationLong}');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    }
  }

  Future<void> _makePhoneCall() async {
    if (_hospital?.phone != null) {
      final url = Uri.parse('tel:${_hospital!.phone}');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    }
  }

  Future<void> _sendEmail() async {
    if (_hospital?.email != null) {
      final url = Uri.parse('mailto:${_hospital!.email}');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_hospital?.nameArabic ?? 'تفاصيل المستشفى'),
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
                        onPressed: _loadHospitalDetails,
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
                      // معلومات المستشفى
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _hospital!.nameArabic,
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_hospital!.nameEnglish != null) ...[
                                SizedBox(height: 4.h),
                                Text(
                                  _hospital!.nameEnglish!,
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                              SizedBox(height: 16.h),
                              Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      color: Colors.red),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(_hospital!.addressArabic),
                                  ),
                                  if (_hospital?.locationLat != null)
                                    IconButton(
                                      icon: const Icon(Icons.map),
                                      onPressed: _openMap,
                                    ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                children: [
                                  const Icon(Icons.location_city),
                                  SizedBox(width: 8.w),
                                  Text(
                                      '${_hospital!.city} - ${_hospital!.region}'),
                                ],
                              ),
                              if (_hospital?.phone != null) ...[
                                SizedBox(height: 8.h),
                                Row(
                                  children: [
                                    const Icon(Icons.phone),
                                    SizedBox(width: 8.w),
                                    Text(_hospital!.phone!),
                                    const Spacer(),
                                    TextButton.icon(
                                      icon: const Icon(Icons.call),
                                      label: const Text('اتصال'),
                                      onPressed: _makePhoneCall,
                                    ),
                                  ],
                                ),
                              ],
                              if (_hospital?.email != null) ...[
                                SizedBox(height: 8.h),
                                Row(
                                  children: [
                                    const Icon(Icons.email),
                                    SizedBox(width: 8.w),
                                    Text(_hospital!.email!),
                                    const Spacer(),
                                    TextButton.icon(
                                      icon: const Icon(Icons.send),
                                      label: const Text('مراسلة'),
                                      onPressed: _sendEmail,
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // الأقسام
                      Text(
                        'الأقسام',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      if (_departments.isEmpty)
                        const Center(
                          child: Text('لا توجد أقسام متاحة حالياً'),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _departments.length,
                          itemBuilder: (context, index) {
                            final department = _departments[index];
                            return Card(
                              margin: EdgeInsets.only(bottom: 8.h),
                              child: ListTile(
                                title: Text(
                                  department.nameArabic,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: department.descriptionArabic != null
                                    ? Text(department.descriptionArabic!)
                                    : null,
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  // التنقل إلى صفحة القسم
                                  Navigator.pushNamed(
                                    context,
                                    '/department-details',
                                    arguments: {
                                      'hospitalId': widget.hospitalId,
                                      'departmentId': department.id,
                                    },
                                  );
                                },
                              ),
                            );
                          },
                        ),

                      // الأطباء
                      SizedBox(height: 24.h),
                      Text(
                        'الأطباء',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
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
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            doctor.nameArabic,
                                            style: TextStyle(
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 4.h),
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
                                    IconButton(
                                      icon: const Icon(Icons.arrow_forward_ios),
                                      onPressed: () {
                                        // التنقل إلى صفحة تفاصيل الطبيب
                                        Navigator.pushNamed(
                                          context,
                                          '/doctor-details',
                                          arguments: {
                                            'doctorId': doctor.id,
                                            'hospitalId': widget.hospitalId,
                                          },
                                        );
                                      },
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
