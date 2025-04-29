import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:developer' as developer;
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../hospitals/models/department.dart';
import '../../hospitals/models/hospital.dart';
import '../../hospitals/services/hospital_service.dart';

class ManageDepartmentsScreen extends StatefulWidget {
  final Hospital? hospital; // إذا تم تمريره، سيتم عرض الأقسام لهذا المستشفى فقط

  const ManageDepartmentsScreen({
    super.key,
    this.hospital,
  });

  @override
  State<ManageDepartmentsScreen> createState() => _ManageDepartmentsScreenState();
}

class _ManageDepartmentsScreenState extends State<ManageDepartmentsScreen> {
  final _hospitalService = HospitalService();
  bool _isLoading = true;
  String _error = '';
  List<Department> _departments = [];
  List<Department> _filteredDepartments = [];
  List<Hospital> _hospitals = [];
  
  // فلترة
  final _searchController = TextEditingController();
  Hospital? _selectedHospital;
  
  @override
  void initState() {
    super.initState();
    _selectedHospital = widget.hospital;
    _loadData();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    
    try {
      if (_selectedHospital != null) {
        // تحميل الأقسام لمستشفى محدد
        final departments = await _hospitalService.getHospitalDepartments(_selectedHospital!.id);
        setState(() {
          _departments = departments;
          _filteredDepartments = departments;
        });
      } else {
        // تحميل جميع المستشفيات للفلترة
        final hospitals = await _hospitalService.getAllHospitals();
        setState(() => _hospitals = hospitals);
        
        // تحميل جميع الأقسام (هذا قد يكون بطيئًا إذا كان هناك الكثير من الأقسام)
        final allDepartments = <Department>[];
        for (final hospital in hospitals) {
          final departments = await _hospitalService.getHospitalDepartments(hospital.id);
          allDepartments.addAll(departments);
        }
        
        setState(() {
          _departments = allDepartments;
          _filteredDepartments = allDepartments;
        });
      }
      
      setState(() => _isLoading = false);
    } catch (e) {
      developer.log('Error loading departments: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  
  void _filterDepartments() {
    final searchQuery = _searchController.text.toLowerCase();
    
    setState(() {
      _filteredDepartments = _departments.where((department) {
        // تطبيق فلتر البحث
        final matchesSearch = 
            department.nameArabic.toLowerCase().contains(searchQuery) ||
            (department.nameEnglish?.toLowerCase().contains(searchQuery) ?? false) ||
            (department.descriptionArabic?.toLowerCase().contains(searchQuery) ?? false);
        
        // تطبيق فلتر المستشفى
        final matchesHospital = _selectedHospital == null || 
            department.hospitalId == _selectedHospital!.id;
        
        return matchesSearch && matchesHospital;
      }).toList();
    });
  }
  
  void _resetFilters() {
    setState(() {
      _searchController.clear();
      if (widget.hospital == null) {
        _selectedHospital = null;
      }
      _filterDepartments();
    });
  }
  
  void _showAddDepartmentDialog() {
    final formKey = GlobalKey<FormState>();
    final nameArController = TextEditingController();
    final nameEnController = TextEditingController();
    final descArController = TextEditingController();
    final descEnController = TextEditingController();
    Hospital? selectedHospital = _selectedHospital;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة قسم جديد'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_selectedHospital == null) ...[
                  DropdownButtonFormField<Hospital>(
                    decoration: const InputDecoration(
                      labelText: 'المنشأة الصحية *',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedHospital,
                    items: _hospitals
                        .map((hospital) => DropdownMenuItem(
                              value: hospital,
                              child: Text(hospital.nameArabic),
                            ))
                        .toList(),
                    onChanged: (value) {
                      selectedHospital = value;
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'يرجى اختيار المنشأة الصحية';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: nameArController,
                  decoration: const InputDecoration(
                    labelText: 'اسم القسم (عربي) *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال اسم القسم بالعربية';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameEnController,
                  decoration: const InputDecoration(
                    labelText: 'اسم القسم (إنجليزي)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descArController,
                  decoration: const InputDecoration(
                    labelText: 'وصف القسم (عربي)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descEnController,
                  decoration: const InputDecoration(
                    labelText: 'وصف القسم (إنجليزي)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
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
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                if (selectedHospital == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('يرجى اختيار المنشأة الصحية'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                
                final newDepartment = Department(
                  id: const Uuid().v4(),
                  hospitalId: selectedHospital!.id,
                  nameArabic: nameArController.text,
                  nameEnglish: nameEnController.text.isNotEmpty ? nameEnController.text : null,
                  descriptionArabic: descArController.text.isNotEmpty ? descArController.text : null,
                  descriptionEnglish: descEnController.text.isNotEmpty ? descEnController.text : null,
                  isActive: true,
                  createdAt: DateTime.now(),
                );
                
                Navigator.pop(context);
                
                setState(() => _isLoading = true);
                try {
                  await _hospitalService.addDepartment(newDepartment);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم إضافة القسم بنجاح')),
                  );
                  
                  _loadData();
                } catch (e) {
                  setState(() => _isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('فشل في إضافة القسم: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
  
  void _showEditDepartmentDialog(Department department) {
    final formKey = GlobalKey<FormState>();
    final nameArController = TextEditingController(text: department.nameArabic);
    final nameEnController = TextEditingController(text: department.nameEnglish ?? '');
    final descArController = TextEditingController(text: department.descriptionArabic ?? '');
    final descEnController = TextEditingController(text: department.descriptionEnglish ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل القسم'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameArController,
                  decoration: const InputDecoration(
                    labelText: 'اسم القسم (عربي) *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال اسم القسم بالعربية';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameEnController,
                  decoration: const InputDecoration(
                    labelText: 'اسم القسم (إنجليزي)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descArController,
                  decoration: const InputDecoration(
                    labelText: 'وصف القسم (عربي)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descEnController,
                  decoration: const InputDecoration(
                    labelText: 'وصف القسم (إنجليزي)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
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
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                final updatedDepartment = Department(
                  id: department.id,
                  hospitalId: department.hospitalId,
                  nameArabic: nameArController.text,
                  nameEnglish: nameEnController.text.isNotEmpty ? nameEnController.text : null,
                  descriptionArabic: descArController.text.isNotEmpty ? descArController.text : null,
                  descriptionEnglish: descEnController.text.isNotEmpty ? descEnController.text : null,
                  isActive: department.isActive,
                  createdAt: department.createdAt,
                );
                
                Navigator.pop(context);
                
                setState(() => _isLoading = true);
                try {
                  await _hospitalService.updateDepartment(updatedDepartment);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم تحديث القسم بنجاح')),
                  );
                  
                  _loadData();
                } catch (e) {
                  setState(() => _isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('فشل في تحديث القسم: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('حفظ التغييرات'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _toggleDepartmentStatus(Department department) async {
    final newStatus = !department.isActive;
    final statusText = newStatus ? 'تفعيل' : 'تعطيل';
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد $statusText القسم'),
        content: Text('هل أنت متأكد من $statusText قسم ${department.nameArabic}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(statusText),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      setState(() => _isLoading = true);
      
      try {
        final updatedDepartment = Department(
          id: department.id,
          hospitalId: department.hospitalId,
          nameArabic: department.nameArabic,
          nameEnglish: department.nameEnglish,
          descriptionArabic: department.descriptionArabic,
          descriptionEnglish: department.descriptionEnglish,
          isActive: newStatus,
          createdAt: department.createdAt,
        );
        
        await _hospitalService.updateDepartment(updatedDepartment);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم $statusText القسم بنجاح')),
        );
        
        _loadData();
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في $statusText القسم: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _deleteDepartment(Department department) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف قسم ${department.nameArabic}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      setState(() => _isLoading = true);
      
      try {
        await _hospitalService.deleteDepartment(department.id);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف القسم بنجاح')),
        );
        
        _loadData();
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في حذف القسم: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedHospital != null 
            ? 'أقسام ${_selectedHospital!.nameArabic}' 
            : 'إدارة الأقسام'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : _error.isNotEmpty
              ? ErrorView(
                  error: _error,
                  onRetry: _loadData,
                )
              : Column(
                  children: [
                    // أدوات البحث والفلترة
                    Card(
                      margin: EdgeInsets.all(8.w),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          children: [
                            // حقل البحث
                            TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'ابحث عن قسم',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                ),
                              ),
                              onChanged: (_) => _filterDepartments(),
                            ),
                            SizedBox(height: 16.h),
                            
                            // فلاتر إضافية
                            if (_selectedHospital == null && _hospitals.isNotEmpty) ...[
                              DropdownButtonFormField<Hospital?>(
                                decoration: InputDecoration(
                                  labelText: 'المنشأة الصحية',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 12.h,
                                  ),
                                ),
                                value: _selectedHospital,
                                items: [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text('جميع المنشآت'),
                                  ),
                                  ..._hospitals.map((hospital) => DropdownMenuItem(
                                        value: hospital,
                                        child: Text(hospital.nameArabic),
                                      )),
                                ],
                                onChanged: (value) {
                                  setState(() => _selectedHospital = value);
                                  _filterDepartments();
                                },
                              ),
                              SizedBox(height: 16.h),
                            ],
                            
                            // أزرار إعادة الضبط والإضافة
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton.icon(
                                  onPressed: _resetFilters,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('إعادة ضبط الفلاتر'),
                                ),
                                ElevatedButton.icon(
                                  onPressed: _showAddDepartmentDialog,
                                  icon: const Icon(Icons.add),
                                  label: const Text('إضافة قسم'),
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
                          ],
                        ),
                      ),
                    ),
                    
                    // عدد النتائج
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      child: Row(
                        children: [
                          Text(
                            'النتائج: ${_filteredDepartments.length}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // قائمة الأقسام
                    Expanded(
                      child: _filteredDepartments.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.category,
                                    size: 60.w,
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    'لا توجد أقسام مطابقة للبحث',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: 16.h),
                                  ElevatedButton.icon(
                                    onPressed: _showAddDepartmentDialog,
                                    icon: const Icon(Icons.add),
                                    label: const Text('إضافة قسم جديد'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryGreen,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.all(8.w),
                              itemCount: _filteredDepartments.length,
                              itemBuilder: (context, index) {
                                final department = _filteredDepartments[index];
                                return _buildDepartmentCard(department);
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
  
  Widget _buildDepartmentCard(Department department) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: department.isActive ? Colors.green.shade200 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // أيقونة القسم
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.category,
                    size: 30.w,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                SizedBox(width: 16.w),
                
                // معلومات القسم
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        department.nameArabic,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (department.nameEnglish != null) ...[
                        SizedBox(height: 4.h),
                        Text(
                          department.nameEnglish!,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                      SizedBox(height: 8.h),
                      if (_selectedHospital == null) ...[
                        FutureBuilder<Hospital>(
                          future: _hospitalService.getHospitalDetails(department.hospitalId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Text('جاري تحميل بيانات المنشأة...');
                            }
                            if (snapshot.hasError || !snapshot.hasData) {
                              return const Text('غير متوفر');
                            }
                            return Row(
                              children: [
                                Icon(Icons.local_hospital, size: 16.w, color: Colors.grey[600]),
                                SizedBox(width: 4.w),
                                Text(
                                  snapshot.data!.nameArabic,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        SizedBox(height: 4.h),
                      ],
                      Row(
                        children: [
                          Icon(Icons.circle, size: 12.w, 
                            color: department.isActive ? Colors.green : Colors.red),
                          SizedBox(width: 4.w),
                          Text(
                            department.isActive ? 'نشط' : 'غير نشط',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: department.isActive ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            if (department.descriptionArabic != null) ...[
              SizedBox(height: 16.h),
              Text(
                'الوصف:',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                department.descriptionArabic!,
                style: TextStyle(
                  fontSize: 14.sp,
                ),
              ),
            ],
            
            SizedBox(height: 16.h),
            
            // أزرار الإجراءات
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionButton(
                  icon: Icons.edit,
                  label: 'تعديل',
                  color: Colors.blue,
                  onPressed: () => _showEditDepartmentDialog(department),
                ),
                SizedBox(width: 8.w),
                _buildActionButton(
                  icon: department.isActive ? Icons.visibility_off : Icons.visibility,
                  label: department.isActive ? 'تعطيل' : 'تفعيل',
                  color: department.isActive ? Colors.orange : Colors.green,
                  onPressed: () => _toggleDepartmentStatus(department),
                ),
                SizedBox(width: 8.w),
                _buildActionButton(
                  icon: Icons.delete,
                  label: 'حذف',
                  color: Colors.red,
                  onPressed: () => _deleteDepartment(department),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: color, size: 18.w),
      label: Text(
        label,
        style: TextStyle(color: color),
      ),
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 8.h,
        ),
      ),
    );
  }
}
