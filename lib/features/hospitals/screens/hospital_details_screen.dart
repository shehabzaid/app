import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/hospital.dart';
import '../models/department.dart';
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

  @override
  void initState() {
    super.initState();
    _loadHospitalDetails();
  }

  Future<void> _loadHospitalDetails() async {
    try {
      setState(() => _isLoading = true);

      final hospital =
          await _hospitalService.getHospitalDetails(widget.hospitalId);
      final departments =
          await _hospitalService.getHospitalDepartments(widget.hospitalId);

      setState(() {
        _hospital = hospital;
        _departments = departments;
        _error = '';
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openMap() async {
    if (_hospital?.locationLat != null && _hospital?.locationLong != null) {
      final url =
          'https://www.google.com/maps/search/?api=1&query=${_hospital!.locationLat},${_hospital!.locationLong}';
      if (await canLaunch(url)) {
        await launch(url);
      }
    }
  }

  Future<void> _makePhoneCall() async {
    if (_hospital?.phone != null) {
      final url = 'tel:${_hospital!.phone}';
      if (await canLaunch(url)) {
        await launch(url);
      }
    }
  }

  Future<void> _sendEmail() async {
    if (_hospital?.email != null) {
      final url = 'mailto:${_hospital!.email}';
      if (await canLaunch(url)) {
        await launch(url);
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
                    ],
                  ),
                ),
    );
  }
}
