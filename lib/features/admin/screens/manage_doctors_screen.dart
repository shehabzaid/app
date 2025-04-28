import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import '../../hospitals/models/doctor.dart';
import '../../hospitals/models/hospital.dart';
import '../../hospitals/services/hospital_service.dart';

class ManageDoctorsScreen extends StatefulWidget {
  final Hospital? hospital; // إذا تم تمريره، سيتم عرض الأطباء لهذا المستشفى فقط

  const ManageDoctorsScreen({
    super.key,
    this.hospital,
  });

  @override
  State<ManageDoctorsScreen> createState() => _ManageDoctorsScreenState();
}

class _ManageDoctorsScreenState extends State<ManageDoctorsScreen> {
  final _hospitalService = HospitalService();
  final _searchController = TextEditingController();
  
  bool _isLoading = true;
  String _error = '';
  List<Doctor> _doctors = [];
  List<Doctor> _filteredDoctors = [];
  List<Hospital> _hospitals = [];
  
  Hospital? _selectedHospital;
  String? _selectedSpecialization;
  List<String> _specializations = [];

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
      List<Doctor> doctors;
      
      if (_selectedHospital != null) {
        // تحميل الأطباء لمستشفى محدد
        doctors = await _hospitalService.getDoctorsByHospital(_selectedHospital!.id);
      } else {
        // تحميل جميع الأطباء
        doctors = await _hospitalService.getAllDoctors();
        
        // تحميل قائمة المستشفيات للفلترة
        final hospitals = await _hospitalService.getAllHospitals();
        setState(() => _hospitals = hospitals);
      }
      
      // استخراج التخصصات الفريدة
      final specializations = <String>{};
      for (final doctor in doctors) {
        specializations.add(doctor.specializationArabic);
      }
      
      setState(() {
        _doctors = doctors;
        _filteredDoctors = doctors;
        _specializations = specializations.toList()..sort();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterDoctors() {
    final searchText = _searchController.text.toLowerCase();
    
    setState(() {
      _filteredDoctors = _doctors.where((doctor) {
        // تطبيق فلتر البحث
        final matchesSearch = searchText.isEmpty ||
            doctor.nameArabic.toLowerCase().contains(searchText) ||
            (doctor.nameEnglish?.toLowerCase().contains(searchText) ?? false) ||
            doctor.specializationArabic.toLowerCase().contains(searchText) ||
            (doctor.specializationEnglish?.toLowerCase().contains(searchText) ?? false);
        
        // تطبيق فلتر التخصص
        final matchesSpecialization = _selectedSpecialization == null || 
            doctor.specializationArabic == _selectedSpecialization;
        
        return matchesSearch && matchesSpecialization;
      }).toList();
    });
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedSpecialization = null;
      _filteredDoctors = _doctors;
    });
  }

  void _navigateToAddDoctor() {
    // TODO: Navigate to add doctor screen
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => AddDoctorScreen(hospital: _selectedHospital),
    //   ),
    // ).then((added) {
    //   if (added == true) {
    //     _loadData();
    //   }
    // });
  }

  void _navigateToEditDoctor(Doctor doctor) {
    // TODO: Navigate to edit doctor screen
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => EditDoctorScreen(doctor: doctor),
    //   ),
    // ).then((updated) {
    //   if (updated == true) {
    //     _loadData();
    //   }
    // });
  }

  Future<void> _deleteDoctor(Doctor doctor) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف ${doctor.nameArabic}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'حذف',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      setState(() => _isLoading = true);
      
      try {
        // TODO: Implement actual API call to delete doctor
        await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم حذف ${doctor.nameArabic} بنجاح')),
          );
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('حدث خطأ: ${e.toString()}')),
          );
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _toggleDoctorStatus(Doctor doctor) {
    // TODO: Implement toggle doctor status
    // setState(() => _isLoading = true);
    // 
    // try {
    //   // TODO: Implement actual API call to toggle doctor status
    //   await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    //   
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text('تم تغيير حالة ${doctor.nameArabic} بنجاح')),
    //     );
    //     _loadData();
    //   }
    // } catch (e) {
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text('حدث خطأ: ${e.toString()}')),
    //     );
    //     setState(() => _isLoading = false);
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedHospital != null
            ? 'أطباء ${_selectedHospital!.nameArabic}'
            : 'إدارة الأطباء'),
        centerTitle: true,
      ),
      body: Column(
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
                      hintText: 'ابحث عن طبيب',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                    ),
                    onChanged: (_) => _filterDoctors(),
                  ),
                  SizedBox(height: 16.h),
                  
                  // فلاتر إضافية
                  Row(
                    children: [
                      // فلتر المستشفى (إذا لم يتم تحديد مستشفى مسبقاً)
                      if (_selectedHospital == null) ...[
                        Expanded(
                          child: DropdownButtonFormField<Hospital>(
                            decoration: InputDecoration(
                              labelText: 'المستشفى',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 12.h,
                              ),
                            ),
                            value: null,
                            items: [
                              const DropdownMenuItem<Hospital>(
                                value: null,
                                child: Text('جميع المستشفيات'),
                              ),
                              ..._hospitals.map((hospital) => DropdownMenuItem<Hospital>(
                                value: hospital,
                                child: Text(hospital.nameArabic),
                              )),
                            ],
                            onChanged: (value) {
                              setState(() => _selectedHospital = value);
                              _loadData();
                            },
                          ),
                        ),
                        SizedBox(width: 16.w),
                      ],
                      
                      // فلتر التخصص
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'التخصص',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
                          ),
                          value: _selectedSpecialization,
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('جميع التخصصات'),
                            ),
                            ..._specializations.map((specialization) => DropdownMenuItem<String>(
                              value: specialization,
                              child: Text(specialization),
                            )),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedSpecialization = value);
                            _filterDoctors();
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  
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
                        onPressed: _navigateToAddDoctor,
                        icon: const Icon(Icons.add),
                        label: const Text('إضافة طبيب'),
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
                  'النتائج: ${_filteredDoctors.length}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // قائمة الأطباء
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 48,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              _error,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 16.h),
                            ElevatedButton(
                              onPressed: _loadData,
                              child: const Text('إعادة المحاولة'),
                            ),
                          ],
                        ),
                      )
                    : _filteredDoctors.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.medical_services,
                                  size: 60.w,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  'لا يوجد أطباء مطابقين للبحث',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(8.w),
                            itemCount: _filteredDoctors.length,
                            itemBuilder: (context, index) {
                              final doctor = _filteredDoctors[index];
                              return _buildDoctorCard(doctor);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(Doctor doctor) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // صورة الطبيب
                CircleAvatar(
                  radius: 40.r,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: doctor.imageUrl != null
                      ? NetworkImage(doctor.imageUrl!)
                      : null,
                  child: doctor.imageUrl == null
                      ? Icon(
                          Icons.person,
                          size: 40.r,
                          color: Colors.grey[400],
                        )
                      : null,
                ),
                SizedBox(width: 16.w),
                
                // معلومات الطبيب
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.nameArabic,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (doctor.nameEnglish != null) ...[
                        SizedBox(height: 4.h),
                        Text(
                          doctor.nameEnglish!,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                      SizedBox(height: 8.h),
                      Text(
                        doctor.specializationArabic,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (doctor.specializationEnglish != null) ...[
                        SizedBox(height: 4.h),
                        Text(
                          doctor.specializationEnglish!,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                      if (doctor.qualification != null) ...[
                        SizedBox(height: 8.h),
                        Text(
                          'المؤهل: ${doctor.qualification}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // حالة الطبيب (نشط/غير نشط)
                Switch(
                  value: doctor.isActive,
                  onChanged: (_) => _toggleDoctorStatus(doctor),
                  activeColor: AppTheme.primaryGreen,
                ),
              ],
            ),
            SizedBox(height: 16.h),
            
            // أزرار الإجراءات
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.edit,
                  label: 'تعديل',
                  color: Colors.blue,
                  onPressed: () => _navigateToEditDoctor(doctor),
                ),
                _buildActionButton(
                  icon: Icons.delete,
                  label: 'حذف',
                  color: Colors.red,
                  onPressed: () => _deleteDoctor(doctor),
                ),
                _buildActionButton(
                  icon: doctor.isActive ? Icons.visibility_off : Icons.visibility,
                  label: doctor.isActive ? 'إخفاء' : 'إظهار',
                  color: doctor.isActive ? Colors.orange : Colors.green,
                  onPressed: () => _toggleDoctorStatus(doctor),
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
      icon: Icon(icon, color: color),
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
