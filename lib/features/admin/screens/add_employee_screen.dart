import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import '../../employee/services/employee_service.dart';
import '../../employee/models/employee.dart';
import 'package:uuid/uuid.dart';

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _employeeService = EmployeeService();
  bool _isLoading = false;
  String? _employeeNumber;
  List<Employee> _employees = [];
  bool _isLoadingEmployees = false;

  @override
  void initState() {
    super.initState();
    _generateEmployeeNumber();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() => _isLoadingEmployees = true);
    try {
      final employees = await _employeeService.getAllEmployees();
      if (mounted) {
        setState(() {
          _employees = employees;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ في تحميل قائمة الموظفين: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingEmployees = false);
      }
    }
  }

  Future<void> _generateEmployeeNumber() async {
    setState(() => _isLoading = true);
    try {
      final number = await _employeeService.generateEmployeeNumber();
      if (mounted) {
        setState(() {
          _employeeNumber = number;
        });
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

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final formData = _formKey.currentState!.value;
        final employee = Employee(
          id: const Uuid().v4(),
          employeeNumber: formData['employee_number'],
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
          profilePicture: null,
        );

        await _employeeService.createEmployee(employee);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إضافة الموظف بنجاح')),
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

  Widget _buildEmployeeCard(Employee employee) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // صورة الموظف
                CircleAvatar(
                  radius: 30.w,
                  backgroundColor: AppTheme.primaryGreen,
                  backgroundImage: employee.profilePicture != null
                      ? NetworkImage(employee.profilePicture!)
                      : null,
                  child: employee.profilePicture == null
                      ? Text(
                          employee.fullNameAr[0],
                          style: TextStyle(
                            fontSize: 24.sp,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
                SizedBox(width: 16.w),
                // معلومات الموظف
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.fullNameAr,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'الرقم الوظيفي: ${employee.employeeNumber}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (employee.jobTitle != null) ...[
                        SizedBox(height: 4.h),
                        Text(
                          employee.jobTitle!,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ],
                      if (employee.employeeStatus != null) ...[
                        SizedBox(height: 4.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: employee.employeeStatus == 'مستمر'
                                ? Colors.green[100]
                                : employee.employeeStatus == 'منقطع'
                                    ? Colors.red[100]
                                    : Colors.orange[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            employee.employeeStatus!,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: employee.employeeStatus == 'مستمر'
                                  ? Colors.green[800]
                                  : employee.employeeStatus == 'منقطع'
                                      ? Colors.red[800]
                                      : Colors.orange[800],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // زر التعديل
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // TODO: Implement edit functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('سيتم إضافة خاصية التعديل قريباً'),
                      ),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 8.h),
            // معلومات إضافية
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (employee.department != null)
                  _buildInfoChip(Icons.business, employee.department!),
                if (employee.mobile != null)
                  _buildInfoChip(Icons.phone_android, employee.mobile!),
                if (employee.email != null)
                  _buildInfoChip(Icons.email, employee.email!),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16.w, color: Colors.grey[600]),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة موظف جديد'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: FormBuilder(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_employeeNumber == null)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    FormBuilderTextField(
                      name: 'employee_number',
                      enabled: false,
                      initialValue: _employeeNumber,
                      decoration: InputDecoration(
                        labelText: 'الرقم الوظيفي',
                        prefixIcon:
                            const Icon(Icons.numbers, color: Colors.red),
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
                    initialValue: false,
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
                  FormBuilderDateTimePicker(
                    name: 'employment_date',
                    inputType: InputType.date,
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
                    name: 'notes',
                    decoration: const InputDecoration(
                      labelText: 'ملاحظات',
                      prefixIcon: Icon(Icons.note),
                    ),
                    maxLines: 3,
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
                            'إضافة الموظف',
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
