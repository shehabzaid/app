import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/hospital.dart';
import '../services/hospital_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/navigation/app_navigator.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HospitalsScreen extends StatefulWidget {
  const HospitalsScreen({Key? key}) : super(key: key);

  @override
  State<HospitalsScreen> createState() => _HospitalsScreenState();
}

class _HospitalsScreenState extends State<HospitalsScreen> {
  final _hospitalService = HospitalService();
  final _searchController = TextEditingController();

  bool _isLoading = true;
  String _error = '';
  List<Hospital> _hospitals = [];
  List<Hospital> _filteredHospitals = [];

  String? _selectedRegion;
  String? _selectedCity;
  String? _selectedType;
  List<String> _regions = [];
  List<String> _cities = [];
  List<String> _types = ['Hospital', 'Clinic', 'Medical Center'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);

      // جلب قائمة المناطق والمدن والمستشفيات
      final regions = await _hospitalService.getRegions();
      final cities = await _hospitalService.getCities();
      final hospitals = await _hospitalService.getAllHospitals();

      setState(() {
        _regions = regions;
        _cities = cities;
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
    final searchText = _searchController.text.toLowerCase();

    setState(() {
      _filteredHospitals = _hospitals.where((hospital) {
        // تطبيق فلتر البحث
        final nameMatches = hospital.nameArabic
                .toLowerCase()
                .contains(searchText) ||
            (hospital.nameEnglish?.toLowerCase().contains(searchText) ?? false);

        // تطبيق فلتر المنطقة
        final regionMatches =
            _selectedRegion == null || hospital.region == _selectedRegion;

        // تطبيق فلتر المدينة
        final cityMatches =
            _selectedCity == null || hospital.city == _selectedCity;

        // تطبيق فلتر النوع
        final typeMatches =
            _selectedType == null || hospital.facilityType == _selectedType;

        return nameMatches && regionMatches && cityMatches && typeMatches;
      }).toList();
    });
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedRegion = null;
      _selectedCity = null;
      _selectedType = null;
      _filteredHospitals = _hospitals;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المنشآت الصحية'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(16.w),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث عن منشأة صحية...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterHospitals();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              onChanged: (value) => _filterHospitals(),
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
                                  'لا توجد منشآت صحية مطابقة لبحثك',
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
          AppNavigator.navigateToHospitalDetails(context, hospital.id);
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
                child: CachedNetworkImage(
                  imageUrl: hospital.imageUrl!,
                  height: 150.h,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.w,
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 150.h,
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.local_hospital,
                      size: 50.sp,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              )
            else
              Container(
                height: 150.h,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Icon(
                  Icons.local_hospital,
                  size: 50.sp,
                  color: Colors.grey[400],
                ),
              ),

            // Hospital Info
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          hospital.facilityType,
                          style: TextStyle(
                            color: AppTheme.primaryGreen,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.location_on,
                        size: 16.sp,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${hospital.city}, ${hospital.region}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
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
                  Text(
                    hospital.addressArabic,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 16.h),

                  // View Details Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        AppNavigator.navigateToHospitalDetails(
                            context, hospital.id);
                      },
                      icon: const Icon(Icons.info_outline),
                      label: const Text('عرض التفاصيل'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('تصفية النتائج'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // المنطقة
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'المنطقة',
                  ),
                  value: _selectedRegion,
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('الكل'),
                    ),
                    ..._regions.map((region) => DropdownMenuItem<String>(
                          value: region,
                          child: Text(region),
                        )),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedRegion = value);
                  },
                ),
                SizedBox(height: 16.h),

                // المدينة
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'المدينة',
                  ),
                  value: _selectedCity,
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('الكل'),
                    ),
                    ..._cities.map((city) => DropdownMenuItem<String>(
                          value: city,
                          child: Text(city),
                        )),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedCity = value);
                  },
                ),
                SizedBox(height: 16.h),

                // النوع
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'النوع',
                  ),
                  value: _selectedType,
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('الكل'),
                    ),
                    ..._types.map((type) => DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        )),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedType = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resetFilters();
              },
              child: const Text('إعادة ضبط'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _filterHospitals();
              },
              child: const Text('تطبيق'),
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
