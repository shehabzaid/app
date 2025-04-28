import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../models/qualification.dart';
import '../services/qualification_service.dart';
import 'pdf_viewer_screen.dart';

class QualificationsScreen extends StatefulWidget {
  final String employeeId;
  final String employeeName;

  const QualificationsScreen({
    super.key,
    required this.employeeId,
    required this.employeeName,
  });

  @override
  State<QualificationsScreen> createState() => _QualificationsScreenState();
}

class _QualificationsScreenState extends State<QualificationsScreen> {
  final _qualificationService = QualificationService();
  List<Qualification> _qualifications = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadQualifications();
  }

  Future<void> _loadQualifications() async {
    setState(() => _isLoading = true);
    try {
      _qualifications =
          await _qualificationService.getQualifications(widget.employeeId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ في تحميل المؤهلات: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showAddEditQualificationDialog(
      [Qualification? qualification]) async {
    String? qualificationName = qualification?.qualificationName;
    String? institution = qualification?.institution;
    DateTime? dateObtained = qualification?.dateObtained;
    String? selectedFilePath;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title:
              Text(qualification == null ? 'إضافة مؤهل جديد' : 'تعديل المؤهل'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'اسم المؤهل'),
                onChanged: (value) => qualificationName = value,
                controller: TextEditingController(text: qualificationName),
              ),
              TextField(
                decoration:
                    const InputDecoration(labelText: 'المؤسسة التعليمية'),
                onChanged: (value) => institution = value,
                controller: TextEditingController(text: institution),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: dateObtained ?? DateTime.now(),
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => dateObtained = date);
                  }
                },
                child: Text(
                  dateObtained != null
                      ? 'تاريخ الحصول: ${dateObtained!.toString().split(' ')[0]}'
                      : 'اختر تاريخ الحصول',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
                  );
                  if (result != null) {
                    setState(() {
                      selectedFilePath = result.files.single.path;
                    });
                  }
                },
                child: Text(selectedFilePath != null
                    ? 'تم اختيار الملف'
                    : 'إرفاق المؤهل'),
              ),
              if (selectedFilePath != null)
                Text(selectedFilePath!.split('/').last),
              if (qualification?.attachmentUrl != null &&
                  selectedFilePath == null)
                Text(
                    'الملف الحالي: ${qualification!.attachmentUrl!.split('/').last}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop({
                  'qualificationName': qualificationName,
                  'institution': institution,
                  'dateObtained': dateObtained,
                  'selectedFilePath': selectedFilePath,
                });
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );

    if (result != null &&
        result['qualificationName']?.isNotEmpty == true &&
        result['institution']?.isNotEmpty == true &&
        result['dateObtained'] != null) {
      setState(() => _isLoading = true);
      try {
        String? fileUrl;
        if (result['selectedFilePath'] != null) {
          fileUrl = await _qualificationService.uploadQualificationFile(
              result['selectedFilePath'], widget.employeeId);
        }

        final newQualification = Qualification(
          id: qualification?.id ?? const Uuid().v4(),
          employeeId: widget.employeeId,
          qualificationName: result['qualificationName']!,
          institution: result['institution']!,
          dateObtained: result['dateObtained'],
          attachmentUrl: fileUrl ?? qualification?.attachmentUrl,
          createdAt: qualification?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );

        if (qualification == null) {
          await _qualificationService.addQualification(newQualification);
        } else {
          await _qualificationService.updateQualification(newQualification);
        }

        await _loadQualifications();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('حدث خطأ: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _deleteQualification(Qualification qualification) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا المؤهل؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        setState(() => _isLoading = true);
        await _qualificationService.deleteQualification(qualification.id);
        _loadQualifications();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ في حذف المؤهل: ${e.toString()}'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Widget _buildQualificationItem(Qualification qualification) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
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
                    qualification.qualificationName,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        color: Colors.blue,
                        onPressed: () =>
                            _showAddEditQualificationDialog(qualification),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: AppTheme.errorColor,
                        onPressed: () => _deleteQualification(qualification),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                'المؤسسة التعليمية: ${qualification.institution}',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.black54,
                ),
              ),
              Text(
                'تاريخ الحصول: ${qualification.dateObtained.toString().split(' ')[0]}',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black54,
                ),
              ),
              if (qualification.attachmentUrl != null) ...[
                SizedBox(height: 16.h),
                if (qualification.attachmentUrl!.toLowerCase().endsWith('.pdf'))
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PDFViewerScreen(
                            pdfUrl: qualification.attachmentUrl!,
                            title: qualification.qualificationName,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: 100.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[100],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.picture_as_pdf,
                              size: 40.w,
                              color: Colors.red,
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'عرض ملف PDF',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    height: 200.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(qualification.attachmentUrl!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('المؤهلات - ${widget.employeeName}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: ElevatedButton.icon(
              onPressed: () => _showAddEditQualificationDialog(),
              icon: const Icon(Icons.add),
              label: const Text('إضافة مؤهل جديد'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 12.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _qualifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.school_outlined,
                              size: 64.w,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'لا توجد مؤهلات',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        itemCount: _qualifications.length,
                        itemBuilder: (context, index) =>
                            _buildQualificationItem(_qualifications[index]),
                      ),
          ),
        ],
      ),
    );
  }
}
