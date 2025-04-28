import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import '../../employee/services/employee_service.dart';
import '../../employee/models/employee.dart';

class EditEmployeeScreen extends StatefulWidget {
  final Employee employee;

  const EditEmployeeScreen({
    super.key,
    required this.employee,
  });

  @override
  State<EditEmployeeScreen> createState() => _EditEmployeeScreenState();
}

class _EditEmployeeScreenState extends State<EditEmployeeScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _employeeService = EmployeeService();
  bool _isLoading = false;

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final formData = _formKey.currentState!.value;
        final updatedEmployee = Employee(
          id: widget.employee.id,
          employeeNumber: widget.employee.employeeNumber,
          fullNameEn: formData['full_name_en'],
          fullNameAr: formData['full_name_ar'],
          department: formData['department'],
          administration: formData['administration'],
          project: formData['project'],
          jobTitle: formData['job_title'],
          employeeStatus: formData['employee_status'],
          supervisor: formData['supervisor'],
          fingerprint: formData['fingerprint'] ?? false,
          fingerprintDevice: formData['fingerprint_device'],
          employmentDate: formData['employment_date']?.toString(),
          branch: formData['branch'],
          notes: formData['notes'],
          isActive: true,
          phoneLandline: formData['phone_landline'],
          mobile: formData['mobile'],
          email: formData['email'],
          permanentAddress: formData['permanent_address'],
          maritalStatus: formData['marital_status'],
          dependents:
              int.tryParse(formData['dependents']?.toString() ?? '') ?? 0,
          religion: formData['religion'],
          profilePicture: widget.employee.profilePicture,
        );

        await _employeeService.updateEmployee(updatedEmployee);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تحديث بيانات الموظف بنجاح')),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ: ${e.toString()}'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل بيانات الموظف'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: FormBuilder(
              key: _formKey,
              initialValue: {
                'employee_number': widget.employee.employeeNumber,
                'full_name_en': widget.employee.fullNameEn,
                'full_name_ar': widget.employee.fullNameAr,
                'department': widget.employee.department,
                'administration': widget.employee.administration,
                'project': widget.employee.project,
                'job_title': widget.employee.jobTitle,
                'employee_status': widget.employee.employeeStatus,
                'supervisor': widget.employee.supervisor,
                'fingerprint': widget.employee.fingerprint,
                'fingerprint_device': widget.employee.fingerprintDevice,
                'employment_date': widget.employee.employmentDate,
                'branch': widget.employee.branch,
                'notes': widget.employee.notes,
                'phone_landline': widget.employee.phoneLandline,
                'mobile': widget.employee.mobile,
                'email': widget.employee.email,
                'permanent_address': widget.employee.permanentAddress,
                'marital_status': widget.employee.maritalStatus,
                'dependents': widget.employee.dependents.toString(),
                'religion': widget.employee.religion,
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FormBuilderTextField(
                    name: 'employee_number',
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'الرقم الوظيفي',
                      prefixIcon: const Icon(Icons.numbers, color: Colors.red),
                      labelStyle: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                      contentPadding: EdgeInsets.all(16.w),
                      border: const OutlineInputBorder(),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                    ),
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  FormBuilderTextField(
                    name: 'full_name_ar',
                    decoration: const InputDecoration(
                      labelText: 'الاسم الكامل (بالعربية)',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: FormBuilderValidators.required(
                        errorText: 'الرجاء إدخال الاسم بالعربية'),
                  ),
                  SizedBox(height: 16.h),
                  FormBuilderTextField(
                    name: 'full_name_en',
                    decoration: const InputDecoration(
                      labelText: 'الاسم الكامل (بالإنجليزية)',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: FormBuilderValidators.required(
                        errorText: 'الرجاء إدخال الاسم بالإنجليزية'),
                  ),
                  SizedBox(height: 16.h),
                  FormBuilderTextField(
                    name: 'department',
                    decoration: const InputDecoration(
                      labelText: 'القسم',
                      prefixIcon: Icon(Icons.business),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  FormBuilderTextField(
                    name: 'administration',
                    decoration: const InputDecoration(
                      labelText: 'الإدارة',
                      prefixIcon: Icon(Icons.admin_panel_settings),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  FormBuilderTextField(
                    name: 'project',
                    decoration: const InputDecoration(
                      labelText: 'المشروع',
                      prefixIcon: Icon(Icons.work),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  FormBuilderTextField(
                    name: 'job_title',
                    decoration: const InputDecoration(
                      labelText: 'المسمى الوظيفي',
                      prefixIcon: Icon(Icons.work_outline),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  FormBuilderDropdown<String>(
                    name: 'employee_status',
                    decoration: const InputDecoration(
                      labelText: 'حالة الموظف',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'مستمر',
                        child: Text('مستمر'),
                      ),
                      DropdownMenuItem(
                        value: 'منقطع',
                        child: Text('منقطع'),
                      ),
                      DropdownMenuItem(
                        value: 'موقف',
                        child: Text('موقف'),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  FormBuilderTextField(
                    name: 'supervisor',
                    decoration: const InputDecoration(
                      labelText: 'المسؤول المباشر',
                      prefixIcon: Icon(Icons.supervisor_account),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  FormBuilderSwitch(
                    name: 'fingerprint',
                    title: const Text('خاضع للبصمة'),
                  ),
                  SizedBox(height: 16.h),
                  FormBuilderTextField(
                    name: 'fingerprint_device',
                    decoration: const InputDecoration(
                      labelText: 'جهاز البصمة',
                      prefixIcon: Icon(Icons.fingerprint),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  FormBuilderTextField(
                    name: 'employment_date',
                    decoration: const InputDecoration(
                      labelText: 'تاريخ التوظيف',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  FormBuilderTextField(
                    name: 'branch',
                    decoration: const InputDecoration(
                      labelText: 'الفرع',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  FormBuilderTextField(
                    name: 'phone_landline',
                    decoration: const InputDecoration(
                      labelText: 'هاتف المنزل',
                      prefixIcon: Icon(Icons.phone),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  FormBuilderTextField(
                    name: 'mobile',
                    decoration: const InputDecoration(
                      labelText: 'رقم الجوال',
                      prefixIcon: Icon(Icons.phone_android),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  FormBuilderTextField(
                    name: 'email',
                    decoration: const InputDecoration(
                      labelText: 'البريد الإلكتروني',
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: FormBuilderValidators.email(
                      errorText: 'الرجاء إدخال بريد إلكتروني صحيح',
                    ),
                  ),
                  SizedBox(height: 16.h),
                  FormBuilderTextField(
                    name: 'permanent_address',
                    decoration: const InputDecoration(
                      labelText: 'العنوان الدائم',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(height: 16.h),
                  FormBuilderDropdown<String>(
                    name: 'marital_status',
                    decoration: const InputDecoration(
                      labelText: 'الحالة الاجتماعية',
                      prefixIcon: Icon(Icons.family_restroom),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'أعزب',
                        child: Text('أعزب'),
                      ),
                      DropdownMenuItem(
                        value: 'متزوج',
                        child: Text('متزوج'),
                      ),
                      DropdownMenuItem(
                        value: 'مطلق',
                        child: Text('مطلق'),
                      ),
                      DropdownMenuItem(
                        value: 'أرمل',
                        child: Text('أرمل'),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  FormBuilderTextField(
                    name: 'dependents',
                    decoration: const InputDecoration(
                      labelText: 'عدد المعالين',
                      prefixIcon: Icon(Icons.people),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 16.h),
                  FormBuilderTextField(
                    name: 'religion',
                    decoration: const InputDecoration(
                      labelText: 'الديانة',
                      prefixIcon: Icon(Icons.church),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  FormBuilderTextField(
                    name: 'notes',
                    decoration: const InputDecoration(
                      labelText: 'ملاحظات',
                      prefixIcon: Icon(Icons.note),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      backgroundColor: AppTheme.primaryGreen,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'حفظ التغييرات',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
