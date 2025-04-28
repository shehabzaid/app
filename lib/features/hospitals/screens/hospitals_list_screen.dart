import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/hospital.dart';
import '../services/hospital_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';

class HospitalsListScreen extends StatefulWidget {
  const HospitalsListScreen({super.key});

  @override
  State<HospitalsListScreen> createState() => _HospitalsListScreenState();
}

class _HospitalsListScreenState extends State<HospitalsListScreen> {
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

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);

      // جلب قائمة المناطق والمستشفيات
      final regions = await _hospitalService.getRegions();
      final hospitals = await _hospitalService.getAllHospitals();

      setState(() {
        _regions = regions;
        _hospitals = hospitals;
        _filteredHospitals = hospitals;
        _error = '';
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterHospitals() {
    setState(() {
      _filteredHospitals = _hospitals.where((hospital) {
        // تطبيق فلتر البحث
        final searchQuery = _searchController.text.toLowerCase();
        final matchesSearch = searchQuery.isEmpty ||
            hospital.nameArabic.toLowerCase().contains(searchQuery) ||
            (hospital.nameEnglish?.toLowerCase().contains(searchQuery) ??
                false) ||
            hospital.region.toLowerCase().contains(searchQuery);

        // تطبيق فلتر المنطقة
        final matchesRegion = _selectedRegion == null ||
            _selectedRegion == 'كل المناطق' ||
            hospital.region == _selectedRegion;

        // تطبيق فلتر النوع
        final matchesType = _selectedType == null ||
            _selectedType == 'كل الأنواع' ||
            hospital.facilityType == _selectedType;

        return matchesSearch && matchesRegion && matchesType;
      }).toList();

      // إذا لم يتم العثور على نتائج، نعرض كل المستشفيات
      if (_filteredHospitals.isEmpty &&
          (_searchController.text.isNotEmpty ||
              _selectedRegion != null ||
              _selectedType != null)) {
        _filteredHospitals = _hospitals;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('لا توجد نتائج مطابقة للبحث. تم عرض كل المستشفيات.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المستشفيات'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search and Filters
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'ابحث عن مستشفى...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) => _filterHospitals(),
                ),
                SizedBox(height: 16.h),

                // Filters
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedRegion,
                        decoration: InputDecoration(
                          labelText: 'المنطقة',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: 'كل المناطق',
                            child: Text('كل المناطق'),
                          ),
                          ..._regions.map((region) {
                            return DropdownMenuItem(
                              value: region,
                              child: Text(region),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedRegion = value);
                          _filterHospitals();
                        },
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedType,
                        decoration: InputDecoration(
                          labelText: 'النوع',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: 'كل الأنواع',
                            child: Text('كل الأنواع'),
                          ),
                          ..._types.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedType = value);
                          _filterHospitals();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Hospitals List
          Expanded(
            child: _isLoading
                ? const LoadingView()
                : _error.isNotEmpty
                    ? ErrorView(
                        error: _error,
                        onRetry: _loadData,
                      )
                    : _filteredHospitals.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64.sp,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16.h),
                                const Text(
                                  'لا توجد مستشفيات مطابقة لبحثك',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadData,
                            child: ListView.builder(
                              padding: EdgeInsets.all(16.w),
                              itemCount: _filteredHospitals.length,
                              itemBuilder: (context, index) {
                                final hospital = _filteredHospitals[index];
                                return _buildHospitalCard(hospital);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalCard(Hospital hospital) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/hospital-details',
            arguments: hospital.id,
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hospital Image
            if (hospital.imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  hospital.imageUrl!,
                  height: 150.h,
                  fit: BoxFit.cover,
                ),
              ),

            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hospital Name and Type
                  Row(
                    children: [
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
                            if (hospital.nameEnglish != null)
                              Text(
                                hospital.nameEnglish!,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: hospital.facilityType == 'حكومي'
                              ? Colors.green[50]
                              : Colors.blue[50],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          hospital.facilityType,
                          style: TextStyle(
                            color: hospital.facilityType == 'حكومي'
                                ? Colors.green
                                : Colors.blue,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),

                  // Location
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16.sp, color: Colors.grey),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          '${hospital.city} - ${hospital.region}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Departments
                  // Nota: Los departamentos se cargarán dinámicamente en la pantalla de detalles
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'عرض الأقسام',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // View Doctors Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/hospital-details',
                          arguments: hospital.id,
                        );
                      },
                      icon: const Icon(Icons.people),
                      label: const Text('عرض التفاصيل'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
