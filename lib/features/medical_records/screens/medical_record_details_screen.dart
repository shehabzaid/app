import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../models/medical_record.dart';
import '../services/medical_record_service.dart';
import '../../../core/navigation/app_navigator.dart';

class MedicalRecordDetailsScreen extends StatefulWidget {
  final String recordId;

  const MedicalRecordDetailsScreen({
    Key? key,
    required this.recordId,
  }) : super(key: key);

  @override
  State<MedicalRecordDetailsScreen> createState() =>
      _MedicalRecordDetailsScreenState();
}

class _MedicalRecordDetailsScreenState
    extends State<MedicalRecordDetailsScreen> {
  final MedicalRecordService _medicalRecordService = MedicalRecordService();
  bool _isLoading = true;
  MedicalRecord? _medicalRecord;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMedicalRecord();
  }

  Future<void> _loadMedicalRecord() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final record =
          await _medicalRecordService.getMedicalRecordDetails(widget.recordId);
      setState(() {
        _medicalRecord = record;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل في تحميل تفاصيل السجل الطبي: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل السجل الطبي'),
        centerTitle: true,
        actions: [
          if (_medicalRecord != null)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  // TODO: Navigate to edit medical record
                } else if (value == 'delete') {
                  _showDeleteConfirmationDialog();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('تعديل'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('حذف', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _buildBody(),
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
              onPressed: _loadMedicalRecord,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (_medicalRecord == null) {
      return const Center(
        child: Text('لا توجد بيانات'),
      );
    }

    final dateFormat = DateFormat('yyyy/MM/dd', 'ar');
    final formattedDate = dateFormat.format(_medicalRecord!.createdAt);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
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
                        'تاريخ السجل:',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 24.h),
                  Text(
                    'التشخيص:',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    _medicalRecord!.diagnosis,
                    style: TextStyle(
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'خطة العلاج:',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    _medicalRecord!.treatmentPlan,
                    style: TextStyle(
                      fontSize: 16.sp,
                    ),
                  ),
                  if (_medicalRecord!.medications != null &&
                      _medicalRecord!.medications!.isNotEmpty) ...[
                    SizedBox(height: 16.h),
                    Text(
                      'الأدوية:',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      _medicalRecord!.medications!,
                      style: TextStyle(
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_medicalRecord!.attachmentsUrls != null &&
              _medicalRecord!.attachmentsUrls!.isNotEmpty) ...[
            SizedBox(height: 24.h),
            Text(
              'المرفقات:',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            _buildAttachmentsList(),
          ],
        ],
      ),
    );
  }

  Widget _buildAttachmentsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _medicalRecord!.attachmentsUrls!.length,
      itemBuilder: (context, index) {
        final attachmentUrl = _medicalRecord!.attachmentsUrls![index];
        final fileName = attachmentUrl.split('/').last;
        final fileExt = fileName.split('.').last.toLowerCase();

        IconData iconData;
        Color iconColor;

        switch (fileExt) {
          case 'pdf':
            iconData = Icons.picture_as_pdf;
            iconColor = Colors.red;
            break;
          case 'doc':
          case 'docx':
            iconData = Icons.description;
            iconColor = Colors.blue;
            break;
          case 'jpg':
          case 'jpeg':
          case 'png':
            iconData = Icons.image;
            iconColor = Colors.green;
            break;
          default:
            iconData = Icons.insert_drive_file;
            iconColor = Colors.grey;
        }

        return Card(
          margin: EdgeInsets.only(bottom: 8.h),
          child: ListTile(
            leading: Icon(
              iconData,
              color: iconColor,
              size: 32.sp,
            ),
            title: Text(
              fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.download),
              onPressed: () {
                // TODO: Implement download functionality
              },
            ),
            onTap: () {
              // TODO: Open attachment
            },
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا السجل الطبي؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteMedicalRecord();
            },
            child: const Text(
              'حذف',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteMedicalRecord() async {
    try {
      await _medicalRecordService.deleteMedicalRecord(widget.recordId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف السجل الطبي بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في حذف السجل الطبي: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
