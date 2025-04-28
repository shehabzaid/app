import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import '../../hospitals/models/hospital.dart';
import '../../hospitals/services/hospital_service.dart';

class ManageFacilitiesScreen extends StatefulWidget {
  const ManageFacilitiesScreen({super.key});

  @override
  State<ManageFacilitiesScreen> createState() => _ManageFacilitiesScreenState();
}

class _ManageFacilitiesScreenState extends State<ManageFacilitiesScreen> {
  final _hospitalService = HospitalService();
  final _searchController = TextEditingController();

  bool _isLoading = true;
  String _error = '';
  List<Hospital> _hospitals = [];
  List<Hospital> _filteredHospitals = [];

  String? _selectedRegion;
  String? _selectedType;
  List<String> _regions = [];
  List<String> _types = ['حكومي', 'خاص'];

  @override
  void initState() {
    super.initState();
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
      final hospitals = await _hospitalService.getAllHospitals();

      // استخراج المناطق الفريدة
      final regions = <String>{};
      for (final hospital in hospitals) {
        regions.add(hospital.region);
      }

      setState(() {
        _hospitals = hospitals;
        _filteredHospitals = hospitals;
        _regions = regions.toList()..sort();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterHospitals() {
    final searchText = _searchController.text.toLowerCase();

    setState(() {
      _filteredHospitals = _hospitals.where((hospital) {
        // تطبيق فلتر البحث
        final matchesSearch = searchText.isEmpty ||
            hospital.nameArabic.toLowerCase().contains(searchText) ||
            (hospital.nameEnglish?.toLowerCase().contains(searchText) ??
                false) ||
            hospital.city.toLowerCase().contains(searchText) ||
            hospital.region.toLowerCase().contains(searchText);

        // تطبيق فلتر المنطقة
        final matchesRegion =
            _selectedRegion == null || hospital.region == _selectedRegion;

        // تطبيق فلتر النوع
        final matchesType =
            _selectedType == null || hospital.facilityType == _selectedType;

        return matchesSearch && matchesRegion && matchesType;
      }).toList();
    });
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedRegion = null;
      _selectedType = null;
      _filteredHospitals = _hospitals;
    });
  }

  void _navigateToAddHospital() {
    // TODO: Navigate to add hospital screen
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => AddHospitalScreen(),
    //   ),
    // ).then((added) {
    //   if (added == true) {
    //     _loadData();
    //   }
    // });
  }

  void _navigateToEditHospital(Hospital hospital) {
    // TODO: Navigate to edit hospital screen
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => EditHospitalScreen(hospital: hospital),
    //   ),
    // ).then((updated) {
    //   if (updated == true) {
    //     _loadData();
    //   }
    // });
  }

  Future<void> _deleteHospital(Hospital hospital) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف ${hospital.nameArabic}؟'),
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
        // TODO: Implement actual API call to delete hospital
        await Future.delayed(
            const Duration(seconds: 1)); // Simulate network delay

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم حذف ${hospital.nameArabic} بنجاح')),
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

  void _navigateToManageDepartments(Hospital hospital) {
    // TODO: Navigate to manage departments screen
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => ManageDepartmentsScreen(hospital: hospital),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المنشآت'),
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
                      hintText: 'ابحث عن مستشفى أو عيادة',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                    ),
                    onChanged: (_) => _filterHospitals(),
                  ),
                  SizedBox(height: 16.h),

                  // فلاتر إضافية
                  Row(
                    children: [
                      // فلتر المنطقة
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'المنطقة',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
                          ),
                          value: _selectedRegion,
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('جميع المناطق'),
                            ),
                            ..._regions
                                .map((region) => DropdownMenuItem<String>(
                                      value: region,
                                      child: Text(region),
                                    )),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedRegion = value);
                            _filterHospitals();
                          },
                        ),
                      ),
                      SizedBox(width: 16.w),

                      // فلتر النوع
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'النوع',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
                          ),
                          value: _selectedType,
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('جميع الأنواع'),
                            ),
                            ..._types.map((type) => DropdownMenuItem<String>(
                                  value: type,
                                  child: Text(type),
                                )),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedType = value);
                            _filterHospitals();
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
                        onPressed: _navigateToAddHospital,
                        icon: const Icon(Icons.add),
                        label: const Text('إضافة منشأة'),
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
                  'النتائج: ${_filteredHospitals.length}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // قائمة المستشفيات
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
                    : _filteredHospitals.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.local_hospital,
                                  size: 60.w,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  'لا توجد منشآت مطابقة للبحث',
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
                            itemCount: _filteredHospitals.length,
                            itemBuilder: (context, index) {
                              final hospital = _filteredHospitals[index];
                              return _buildHospitalCard(hospital);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalCard(Hospital hospital) {
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
                // صورة المستشفى
                Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    image: hospital.imageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(hospital.imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: hospital.imageUrl == null
                      ? Icon(
                          Icons.local_hospital,
                          size: 40.w,
                          color: Colors.grey[400],
                        )
                      : null,
                ),
                SizedBox(width: 16.w),

                // معلومات المستشفى
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hospital.nameArabic,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (hospital.nameEnglish != null) ...[
                        SizedBox(height: 4.h),
                        Text(
                          hospital.nameEnglish!,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 16.w, color: Colors.grey[600]),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              '${hospital.city}، ${hospital.region}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(Icons.category,
                              size: 16.w, color: Colors.grey[600]),
                          SizedBox(width: 4.w),
                          Text(
                            hospital.facilityType,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
                  onPressed: () => _navigateToEditHospital(hospital),
                ),
                _buildActionButton(
                  icon: Icons.delete,
                  label: 'حذف',
                  color: Colors.red,
                  onPressed: () => _deleteHospital(hospital),
                ),
                _buildActionButton(
                  icon: Icons.category,
                  label: 'الأقسام',
                  color: Colors.green,
                  onPressed: () => _navigateToManageDepartments(hospital),
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
