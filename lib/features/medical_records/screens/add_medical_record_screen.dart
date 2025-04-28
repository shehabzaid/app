import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../../core/theme/app_theme.dart';
import '../models/medical_record.dart';
import '../services/medical_record_service.dart';
import '../../../features/auth/services/auth_service.dart';

class AddMedicalRecordScreen extends StatefulWidget {
  final String patientId;
  final String? patientName;
  final MedicalRecord? recordToEdit;

  const AddMedicalRecordScreen({
    Key? key,
    required this.patientId,
    this.patientName,
    this.recordToEdit,
  }) : super(key: key);

  @override
  State<AddMedicalRecordScreen> createState() => _AddMedicalRecordScreenState();
}

class _AddMedicalRecordScreenState extends State<AddMedicalRecordScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final MedicalRecordService _medicalRecordService = MedicalRecordService();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  List<String> _selectedFiles = [];
  
  @override
  void initState() {
    super.initState();
    _initializeForm();
  }
  
  void _initializeForm() {
    if (widget.recordToEdit != null) {
      // Si estamos editando un registro existente, inicializamos el formulario con sus valores
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _formKey.currentState?.patchValue({
          'diagnosis': widget.recordToEdit!.diagnosis,
          'treatment_plan': widget.recordToEdit!.treatmentPlan,
          'medications': widget.recordToEdit!.medications ?? '',
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.recordToEdit != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'تعديل سجل طبي' : 'إضافة سجل طبي جديد'),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: FormBuilder(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.patientName != null) ...[
              Text(
                'المريض: ${widget.patientName}',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
            ],
            
            Text(
              'التشخيص:',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            FormBuilderTextField(
              name: 'diagnosis',
              decoration: InputDecoration(
                hintText: 'أدخل التشخيص',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
              maxLines: 3,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(errorText: 'هذا الحقل مطلوب'),
              ]),
            ),
            
            SizedBox(height: 16.h),
            Text(
              'خطة العلاج:',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            FormBuilderTextField(
              name: 'treatment_plan',
              decoration: InputDecoration(
                hintText: 'أدخل خطة العلاج',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
              maxLines: 5,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(errorText: 'هذا الحقل مطلوب'),
              ]),
            ),
            
            SizedBox(height: 16.h),
            Text(
              'الأدوية:',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            FormBuilderTextField(
              name: 'medications',
              decoration: InputDecoration(
                hintText: 'أدخل الأدوية الموصوفة',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
              maxLines: 3,
            ),
            
            SizedBox(height: 24.h),
            Text(
              'المرفقات:',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            _buildAttachmentsSection(),
            
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20.h,
                        width: 20.w,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        widget.recordToEdit != null ? 'تحديث' : 'حفظ',
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
    );
  }

  Widget _buildAttachmentsSection() {
    return Column(
      children: [
        if (_selectedFiles.isNotEmpty) ...[
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _selectedFiles.length,
            itemBuilder: (context, index) {
              final fileName = _selectedFiles[index].split('/').last;
              return Card(
                margin: EdgeInsets.only(bottom: 8.h),
                child: ListTile(
                  title: Text(
                    fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _selectedFiles.removeAt(index);
                      });
                    },
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 16.h),
        ],
        
        OutlinedButton.icon(
          onPressed: _selectFiles,
          icon: const Icon(Icons.attach_file),
          label: const Text('إضافة مرفقات'),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
          ),
        ),
      ],
    );
  }

  void _selectFiles() {
    // TODO: Implement file selection
    // This is a placeholder for file selection functionality
    setState(() {
      _selectedFiles.add('document_${DateTime.now().millisecondsSinceEpoch}.pdf');
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final formData = _formKey.currentState!.value;
        final currentUser = await _authService.getCurrentUserProfile();
        
        if (currentUser == null) {
          throw Exception('لم يتم العثور على بيانات المستخدم');
        }

        final isDoctor = currentUser.role == 'Doctor';
        
        if (widget.recordToEdit != null) {
          // Actualizar registro existente
          final updatedRecord = widget.recordToEdit!.copyWith(
            diagnosis: formData['diagnosis'],
            treatmentPlan: formData['treatment_plan'],
            medications: formData['medications'],
          );
          
          await _medicalRecordService.updateMedicalRecord(updatedRecord);
          
          // Subir nuevos archivos adjuntos si hay alguno
          if (_selectedFiles.isNotEmpty) {
            await _medicalRecordService.uploadAttachments(
              updatedRecord.id,
              _selectedFiles,
            );
          }
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم تحديث السجل الطبي بنجاح'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          }
        } else {
          // Crear nuevo registro
          final newRecord = MedicalRecord(
            id: '', // Se generará automáticamente en la base de datos
            patientId: widget.patientId,
            doctorId: isDoctor ? currentUser.id : null,
            facilityId: null, // TODO: Obtener ID de la instalación si está disponible
            diagnosis: formData['diagnosis'],
            treatmentPlan: formData['treatment_plan'],
            medications: formData['medications'],
            attachmentsUrls: [],
            createdAt: DateTime.now(),
          );
          
          await _medicalRecordService.addMedicalRecord(newRecord);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم إضافة السجل الطبي بنجاح'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}
