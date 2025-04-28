import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class PatientDetailsScreen extends StatefulWidget {
  final String patientId;
  final String? appointmentId;

  const PatientDetailsScreen({
    super.key,
    required this.patientId,
    this.appointmentId,
  });

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  Map<String, dynamic>? _patientInfo;
  Map<String, dynamic>? _currentAppointment;
  List<Map<String, dynamic>> _medicalHistory = [];
  List<Map<String, dynamic>> _previousAppointments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPatientData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPatientData() async {
    // TODO: Implement actual API calls to load patient data
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    
    // Mock data for demonstration
    setState(() {
      _patientInfo = {
        'id': widget.patientId,
        'name': 'أحمد محمد علي',
        'age': 45,
        'gender': 'ذكر',
        'phone': '0501234567',
        'email': 'ahmed@example.com',
        'bloodType': 'A+',
        'height': 175, // سم
        'weight': 80, // كجم
        'chronicDiseases': ['ارتفاع ضغط الدم', 'السكري'],
        'allergies': ['البنسلين'],
      };
      
      if (widget.appointmentId != null) {
        _currentAppointment = {
          'id': widget.appointmentId,
          'date': DateTime.now(),
          'time': '10:00 ص',
          'reason': 'فحص دوري',
          'status': 'قادم',
          'notes': '',
        };
      }
      
      _medicalHistory = [
        {
          'id': '1',
          'date': DateTime.now().subtract(const Duration(days: 30)),
          'doctorName': 'د. محمد أحمد',
          'diagnosis': 'ارتفاع ضغط الدم',
          'treatment': 'أدوية خافضة للضغط',
          'notes': 'يجب متابعة قياس الضغط يومياً',
          'medications': [
            {
              'name': 'أملوديبين',
              'dosage': '5 ملغ',
              'frequency': 'مرة واحدة يومياً',
              'duration': '30 يوم',
            },
          ],
        },
        {
          'id': '2',
          'date': DateTime.now().subtract(const Duration(days: 90)),
          'doctorName': 'د. سارة خالد',
          'diagnosis': 'التهاب الحلق',
          'treatment': 'مضادات حيوية',
          'notes': 'الراحة التامة وشرب السوائل بكثرة',
          'medications': [
            {
              'name': 'أموكسيسيلين',
              'dosage': '500 ملغ',
              'frequency': 'مرتين يومياً',
              'duration': '7 أيام',
            },
            {
              'name': 'باراسيتامول',
              'dosage': '500 ملغ',
              'frequency': 'عند الحاجة',
              'duration': 'حسب الحاجة',
            },
          ],
        },
      ];
      
      _previousAppointments = [
        {
          'id': '1',
          'date': DateTime.now().subtract(const Duration(days: 30)),
          'doctorName': 'د. محمد أحمد',
          'specialty': 'طب القلب',
          'reason': 'فحص دوري',
          'status': 'مكتمل',
        },
        {
          'id': '2',
          'date': DateTime.now().subtract(const Duration(days: 90)),
          'doctorName': 'د. سارة خالد',
          'specialty': 'طب الأطفال',
          'reason': 'التهاب الحلق',
          'status': 'مكتمل',
        },
      ];
      
      _isLoading = false;
    });
  }

  void _navigateToAddMedicalRecord() {
    // TODO: Navigate to add medical record screen
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => AddMedicalRecordScreen(
    //       patientId: widget.patientId,
    //       appointmentId: widget.appointmentId,
    //     ),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_patientInfo?.isNotEmpty == true
            ? 'المريض: ${_patientInfo!['name']}'
            : 'تفاصيل المريض'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'المعلومات الشخصية'),
            Tab(text: 'السجل الطبي'),
            Tab(text: 'المواعيد السابقة'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // المعلومات الشخصية
                SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // معلومات المريض الأساسية
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow('الاسم', _patientInfo!['name']),
                              _buildInfoRow('العمر', '${_patientInfo!['age']} سنة'),
                              _buildInfoRow('الجنس', _patientInfo!['gender']),
                              _buildInfoRow('رقم الهاتف', _patientInfo!['phone']),
                              _buildInfoRow('البريد الإلكتروني', _patientInfo!['email']),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      
                      // المعلومات الطبية
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'المعلومات الطبية',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                              SizedBox(height: 16.h),
                              _buildInfoRow('فصيلة الدم', _patientInfo!['bloodType']),
                              _buildInfoRow('الطول', '${_patientInfo!['height']} سم'),
                              _buildInfoRow('الوزن', '${_patientInfo!['weight']} كجم'),
                              SizedBox(height: 8.h),
                              
                              // الأمراض المزمنة
                              Text(
                                'الأمراض المزمنة:',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              if (_patientInfo!['chronicDiseases'].isEmpty)
                                Text(
                                  'لا توجد أمراض مزمنة',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey[600],
                                  ),
                                )
                              else
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: List.generate(
                                    _patientInfo!['chronicDiseases'].length,
                                    (index) => Padding(
                                      padding: EdgeInsets.only(bottom: 4.h),
                                      child: Row(
                                        children: [
                                          Icon(Icons.circle, size: 8.w, color: Colors.red),
                                          SizedBox(width: 8.w),
                                          Text(
                                            _patientInfo!['chronicDiseases'][index],
                                            style: TextStyle(fontSize: 14.sp),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              SizedBox(height: 8.h),
                              
                              // الحساسية
                              Text(
                                'الحساسية:',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              if (_patientInfo!['allergies'].isEmpty)
                                Text(
                                  'لا توجد حساسية',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey[600],
                                  ),
                                )
                              else
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: List.generate(
                                    _patientInfo!['allergies'].length,
                                    (index) => Padding(
                                      padding: EdgeInsets.only(bottom: 4.h),
                                      child: Row(
                                        children: [
                                          Icon(Icons.circle, size: 8.w, color: Colors.orange),
                                          SizedBox(width: 8.w),
                                          Text(
                                            _patientInfo!['allergies'][index],
                                            style: TextStyle(fontSize: 14.sp),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      
                      // معلومات الموعد الحالي (إذا كان موجوداً)
                      if (_currentAppointment != null) ...[
                        SizedBox(height: 16.h),
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'الموعد الحالي',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryGreen,
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                _buildInfoRow(
                                  'التاريخ',
                                  DateFormat('yyyy/MM/dd', 'ar').format(_currentAppointment!['date']),
                                ),
                                _buildInfoRow('الوقت', _currentAppointment!['time']),
                                _buildInfoRow('سبب الزيارة', _currentAppointment!['reason']),
                                SizedBox(height: 16.h),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _navigateToAddMedicalRecord,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryGreen,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(vertical: 12.h),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      'إضافة سجل طبي',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // السجل الطبي
                _medicalHistory.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.medical_information,
                              size: 60.w,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'لا يوجد سجل طبي',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16.w),
                        itemCount: _medicalHistory.length,
                        itemBuilder: (context, index) {
                          final record = _medicalHistory[index];
                          return _buildMedicalRecordCard(record);
                        },
                      ),
                
                // المواعيد السابقة
                _previousAppointments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 60.w,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'لا توجد مواعيد سابقة',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16.w),
                        itemCount: _previousAppointments.length,
                        itemBuilder: (context, index) {
                          final appointment = _previousAppointments[index];
                          return _buildPreviousAppointmentCard(appointment);
                        },
                      ),
              ],
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalRecordCard(Map<String, dynamic> record) {
    final date = record['date'] as DateTime;
    final dateFormat = DateFormat('yyyy/MM/dd', 'ar');
    final formattedDate = dateFormat.format(date);
    
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.all(16.w),
        childrenPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              record['diagnosis'],
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGreen,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.person, size: 16.w, color: Colors.grey[600]),
                SizedBox(width: 4.w),
                Text(
                  record['doctorName'],
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16.w, color: Colors.grey[600]),
                SizedBox(width: 4.w),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          // العلاج
          if (record['treatment'] != null && record['treatment'].isNotEmpty) ...[
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'العلاج:',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                record['treatment'],
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
            SizedBox(height: 8.h),
          ],
          
          // الملاحظات
          if (record['notes'] != null && record['notes'].isNotEmpty) ...[
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'ملاحظات:',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                record['notes'],
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
            SizedBox(height: 8.h),
          ],
          
          // الأدوية
          if (record['medications'] != null && (record['medications'] as List).isNotEmpty) ...[
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'الأدوية:',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            ...List.generate(
              (record['medications'] as List).length,
              (index) {
                final medication = record['medications'][index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.medication, size: 16.w, color: AppTheme.primaryGreen),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              medication['name'],
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'الجرعة: ${medication['dosage']}',
                              style: TextStyle(fontSize: 12.sp),
                            ),
                            Text(
                              'التكرار: ${medication['frequency']}',
                              style: TextStyle(fontSize: 12.sp),
                            ),
                            Text(
                              'المدة: ${medication['duration']}',
                              style: TextStyle(fontSize: 12.sp),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreviousAppointmentCard(Map<String, dynamic> appointment) {
    final date = appointment['date'] as DateTime;
    final dateFormat = DateFormat('yyyy/MM/dd', 'ar');
    final formattedDate = dateFormat.format(date);
    
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    appointment['status'],
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              'الطبيب: ${appointment['doctorName']}',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'التخصص: ${appointment['specialty']}',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'سبب الزيارة: ${appointment['reason']}',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
