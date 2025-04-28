import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../models/medical_record.dart';
import '../services/medical_record_service.dart';
import '../../../core/navigation/app_navigator.dart';

class MedicalRecordsScreen extends StatefulWidget {
  final String patientId;

  const MedicalRecordsScreen({
    Key? key,
    required this.patientId,
  }) : super(key: key);

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  final MedicalRecordService _medicalRecordService = MedicalRecordService();
  bool _isLoading = true;
  List<MedicalRecord> _medicalRecords = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMedicalRecords();
  }

  Future<void> _loadMedicalRecords() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final records = await _medicalRecordService.getPatientMedicalRecords(widget.patientId);
      setState(() {
        _medicalRecords = records;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل في تحميل السجلات الطبية: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('السجلات الطبية'),
        centerTitle: true,
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add medical record screen
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
              onPressed: _loadMedicalRecords,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (_medicalRecords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_information,
              size: 64.sp,
              color: Colors.grey,
            ),
            SizedBox(height: 16.h),
            Text(
              'لا توجد سجلات طبية',
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
      onRefresh: _loadMedicalRecords,
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: _medicalRecords.length,
        itemBuilder: (context, index) {
          return _buildMedicalRecordCard(_medicalRecords[index]);
        },
      ),
    );
  }

  Widget _buildMedicalRecordCard(MedicalRecord record) {
    final dateFormat = DateFormat('yyyy/MM/dd', 'ar');
    final formattedDate = dateFormat.format(record.createdAt);

    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to medical record details
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
                  Expanded(
                    child: Text(
                      record.diagnosis,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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
              SizedBox(height: 8.h),
              Text(
                'خطة العلاج:',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                record.treatmentPlan,
                style: TextStyle(
                  fontSize: 14.sp,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (record.medications != null && record.medications!.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Text(
                  'الأدوية:',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  record.medications!,
                  style: TextStyle(
                    fontSize: 14.sp,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (record.attachmentsUrls != null && record.attachmentsUrls!.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(
                      Icons.attach_file,
                      size: 16.sp,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'المرفقات: ${record.attachmentsUrls!.length}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
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
}
