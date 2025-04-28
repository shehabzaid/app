import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import 'package:file_picker/file_picker.dart';

class AddMedicalRecordScreen extends StatefulWidget {
  final String patientId;
  final String? appointmentId;
  final String patientName;

  const AddMedicalRecordScreen({
    super.key,
    required this.patientId,
    this.appointmentId,
    required this.patientName,
  });

  @override
  State<AddMedicalRecordScreen> createState() => _AddMedicalRecordScreenState();
}

class _AddMedicalRecordScreenState extends State<AddMedicalRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _diagnosisController = TextEditingController();
  final _treatmentController = TextEditingController();
  final _notesController = TextEditingController();
  
  bool _isSubmitting = false;
  List<Map<String, dynamic>> _medications = [];
  List<Map<String, dynamic>> _attachments = [];

  @override
  void dispose() {
    _diagnosisController.dispose();
    _treatmentController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        setState(() {
          _attachments.add({
            'name': result.files.single.name,
            'path': result.files.single.path,
            'type': result.files.single.extension,
          });
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: ${e.toString()}')),
        );
      }
    }
  }

  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  void _addMedication() {
    showDialog(
      context: context,
      builder: (context) => _MedicationDialog(
        onSave: (medication) {
          setState(() {
            _medications.add(medication);
          });
        },
      ),
    );
  }

  void _editMedication(int index) {
    showDialog(
      context: context,
      builder: (context) => _MedicationDialog(
        initialMedication: _medications[index],
        onSave: (medication) {
          setState(() {
            _medications[index] = medication;
          });
        },
      ),
    );
  }

  void _removeMedication(int index) {
    setState(() {
      _medications.removeAt(index);
    });
  }

  Future<void> _submitMedicalRecord() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);
      
      try {
        // TODO: Implement actual API call to submit medical record
        await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حفظ السجل الطبي بنجاح')),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('حدث خطأ: ${e.toString()}')),
          );
          setState(() => _isSubmitting = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة سجل طبي'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // معلومات المريض
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
                        'المريض: ${widget.patientName}',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'رقم المريض: ${widget.patientId}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (widget.appointmentId != null) ...[
                        SizedBox(height: 4.h),
                        Text(
                          'رقم الموعد: ${widget.appointmentId}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              
              // التشخيص
              Text(
                'التشخيص *',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _diagnosisController,
                decoration: InputDecoration(
                  hintText: 'أدخل التشخيص',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppTheme.primaryGreen, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال التشخيص';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              
              // العلاج
              Text(
                'العلاج *',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _treatmentController,
                decoration: InputDecoration(
                  hintText: 'أدخل العلاج',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppTheme.primaryGreen, width: 2),
                  ),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال العلاج';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              
              // الملاحظات
              Text(
                'ملاحظات',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  hintText: 'أدخل الملاحظات (اختياري)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppTheme.primaryGreen, width: 2),
                  ),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16.h),
              
              // الأدوية
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الأدوية',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addMedication,
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة دواء'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              _medications.isEmpty
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        child: Text(
                          'لم تتم إضافة أدوية',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _medications.length,
                      itemBuilder: (context, index) {
                        final medication = _medications[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 8.h),
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(12.w),
                            child: Row(
                              children: [
                                Icon(Icons.medication, color: AppTheme.primaryGreen),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        medication['name'],
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        'الجرعة: ${medication['dosage']}',
                                        style: TextStyle(fontSize: 14.sp),
                                      ),
                                      Text(
                                        'التكرار: ${medication['frequency']}',
                                        style: TextStyle(fontSize: 14.sp),
                                      ),
                                      Text(
                                        'المدة: ${medication['duration']}',
                                        style: TextStyle(fontSize: 14.sp),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => _editMedication(index),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _removeMedication(index),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              SizedBox(height: 16.h),
              
              // المرفقات
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'المرفقات',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.attach_file),
                    label: const Text('إضافة مرفق'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              _attachments.isEmpty
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        child: Text(
                          'لم تتم إضافة مرفقات',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _attachments.length,
                      itemBuilder: (context, index) {
                        final attachment = _attachments[index];
                        IconData iconData;
                        switch (attachment['type']) {
                          case 'pdf':
                            iconData = Icons.picture_as_pdf;
                            break;
                          case 'jpg':
                          case 'jpeg':
                          case 'png':
                            iconData = Icons.image;
                            break;
                          default:
                            iconData = Icons.attach_file;
                        }
                        
                        return Card(
                          margin: EdgeInsets.only(bottom: 8.h),
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            leading: Icon(iconData, color: Colors.red),
                            title: Text(attachment['name']),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeAttachment(index),
                            ),
                          ),
                        );
                      },
                    ),
              SizedBox(height: 24.h),
              
              // زر الحفظ
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitMedicalRecord,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'حفظ السجل الطبي',
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
    );
  }
}

class _MedicationDialog extends StatefulWidget {
  final Map<String, dynamic>? initialMedication;
  final Function(Map<String, dynamic>) onSave;

  const _MedicationDialog({
    this.initialMedication,
    required this.onSave,
  });

  @override
  State<_MedicationDialog> createState() => _MedicationDialogState();
}

class _MedicationDialogState extends State<_MedicationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _durationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialMedication != null) {
      _nameController.text = widget.initialMedication!['name'];
      _dosageController.text = widget.initialMedication!['dosage'];
      _frequencyController.text = widget.initialMedication!['frequency'];
      _durationController.text = widget.initialMedication!['duration'];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _saveMedication() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSave({
        'name': _nameController.text,
        'dosage': _dosageController.text,
        'frequency': _frequencyController.text,
        'duration': _durationController.text,
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initialMedication != null ? 'تعديل دواء' : 'إضافة دواء',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم الدواء *',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال اسم الدواء';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _dosageController,
                decoration: const InputDecoration(
                  labelText: 'الجرعة *',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال الجرعة';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _frequencyController,
                decoration: const InputDecoration(
                  labelText: 'التكرار *',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال التكرار';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'المدة *',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال المدة';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _saveMedication,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
          ),
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}
