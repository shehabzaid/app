import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class MedicalRecordsScreen extends StatefulWidget {
  const MedicalRecordsScreen({super.key});

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _medicalRecords = [];

  @override
  void initState() {
    super.initState();
    _loadMedicalRecords();
  }

  Future<void> _loadMedicalRecords() async {
    // TODO: Implement actual API call to load medical records
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    
    // Mock data for demonstration
    setState(() {
      _medicalRecords = [
        {
          'id': '1',
          'doctorName': 'د. محمد أحمد',
          'doctorSpecialty': 'طب القلب',
          'hospitalName': 'مستشفى الملك فهد',
          'date': DateTime.now().subtract(const Duration(days: 30)),
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
          'attachments': [
            {
              'name': 'تقرير فحص القلب',
              'type': 'pdf',
              'url': 'https://example.com/report1.pdf',
            },
          ],
        },
        {
          'id': '2',
          'doctorName': 'د. سارة خالد',
          'doctorSpecialty': 'طب الأطفال',
          'hospitalName': 'مستشفى الأمل',
          'date': DateTime.now().subtract(const Duration(days: 60)),
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
          'attachments': [],
        },
      ];
      
      _isLoading = false;
    });
  }

  void _viewAttachment(Map<String, dynamic> attachment) {
    // TODO: Implement view attachment functionality
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => PDFViewerScreen(
    //       pdfUrl: attachment['url'],
    //       title: attachment['name'],
    //     ),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجلاتي الطبية'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _medicalRecords.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.medical_information,
                        size: 80.w,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'لا توجد سجلات طبية',
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: _medicalRecords.length,
                  itemBuilder: (context, index) {
                    final record = _medicalRecords[index];
                    return _buildMedicalRecordCard(record);
                  },
                ),
    );
  }

  Widget _buildMedicalRecordCard(Map<String, dynamic> record) {
    final dateFormat = DateFormat('yyyy/MM/dd', 'ar');
    final date = record['date'] as DateTime;
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
                  '${record['doctorName']} (${record['doctorSpecialty']})',
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
                Icon(Icons.local_hospital, size: 16.w, color: Colors.grey[600]),
                SizedBox(width: 4.w),
                Text(
                  record['hospitalName'],
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
            SizedBox(height: 8.h),
          ],
          
          // المرفقات
          if (record['attachments'] != null && (record['attachments'] as List).isNotEmpty) ...[
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'المرفقات:',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            ...List.generate(
              (record['attachments'] as List).length,
              (index) {
                final attachment = record['attachments'][index];
                IconData iconData;
                switch (attachment['type']) {
                  case 'pdf':
                    iconData = Icons.picture_as_pdf;
                    break;
                  case 'image':
                    iconData = Icons.image;
                    break;
                  default:
                    iconData = Icons.attach_file;
                }
                
                return InkWell(
                  onTap: () => _viewAttachment(attachment),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      children: [
                        Icon(iconData, size: 20.w, color: Colors.red),
                        SizedBox(width: 8.w),
                        Text(
                          attachment['name'],
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
