import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import '../../hospitals/models/doctor.dart';
import '../../hospitals/services/hospital_service.dart';
import '../../hospitals/screens/book_appointment_screen.dart';

class DoctorDetailsScreen extends StatefulWidget {
  final String doctorId;
  final String hospitalId;

  const DoctorDetailsScreen({
    super.key,
    required this.doctorId,
    required this.hospitalId,
  });

  @override
  State<DoctorDetailsScreen> createState() => _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends State<DoctorDetailsScreen> {
  final _hospitalService = HospitalService();
  bool _isLoading = true;
  String _error = '';
  Doctor? _doctor;
  List<Map<String, dynamic>> _reviews = [];
  double _averageRating = 0.0;

  @override
  void initState() {
    super.initState();
    _loadDoctorDetails();
  }

  Future<void> _loadDoctorDetails() async {
    try {
      setState(() => _isLoading = true);

      // Load doctor details
      final doctor = await _hospitalService.getDoctorDetails(widget.doctorId);
      
      // TODO: Load doctor reviews from API
      // Mock data for demonstration
      final reviews = [
        {
          'id': '1',
          'patientName': 'أحمد محمد',
          'rating': 5.0,
          'comment': 'طبيب ممتاز ومتعاون، شرح لي حالتي بالتفصيل وأعطاني العلاج المناسب.',
          'date': DateTime.now().subtract(const Duration(days: 5)),
        },
        {
          'id': '2',
          'patientName': 'سارة علي',
          'rating': 4.0,
          'comment': 'دكتور جيد، لكن وقت الانتظار كان طويلاً.',
          'date': DateTime.now().subtract(const Duration(days: 15)),
        },
        {
          'id': '3',
          'patientName': 'خالد عبدالله',
          'rating': 5.0,
          'comment': 'تجربة ممتازة، الدكتور متمكن ولديه خبرة كبيرة.',
          'date': DateTime.now().subtract(const Duration(days: 30)),
        },
      ];
      
      // Calculate average rating
      double totalRating = 0;
      for (final review in reviews) {
        totalRating += review['rating'] as double;
      }
      final averageRating = reviews.isNotEmpty ? totalRating / reviews.length : 0.0;

      setState(() {
        _doctor = doctor;
        _reviews = reviews;
        _averageRating = averageRating;
        _error = '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _navigateToBookAppointment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookAppointmentScreen(
          hospitalId: widget.hospitalId,
          departmentId: '', // TODO: Get department ID
          doctorId: widget.doctorId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_doctor?.nameArabic ?? 'تفاصيل الطبيب'),
        centerTitle: true,
      ),
      body: _isLoading
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
                        onPressed: _loadDoctorDetails,
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // معلومات الطبيب
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // صورة الطبيب
                              CircleAvatar(
                                radius: 60.r,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: _doctor?.imageUrl != null
                                    ? NetworkImage(_doctor!.imageUrl!)
                                    : null,
                                child: _doctor?.imageUrl == null
                                    ? Icon(
                                        Icons.person,
                                        size: 60.r,
                                        color: Colors.grey[400],
                                      )
                                    : null,
                              ),
                              SizedBox(height: 16.h),
                              
                              // اسم الطبيب
                              Text(
                                _doctor!.nameArabic,
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (_doctor!.nameEnglish != null) ...[
                                SizedBox(height: 4.h),
                                Text(
                                  _doctor!.nameEnglish!,
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                              SizedBox(height: 8.h),
                              
                              // التخصص
                              Text(
                                _doctor!.specializationArabic,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  color: AppTheme.primaryGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (_doctor!.specializationEnglish != null) ...[
                                SizedBox(height: 4.h),
                                Text(
                                  _doctor!.specializationEnglish!,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                              SizedBox(height: 16.h),
                              
                              // التقييم
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ...List.generate(5, (index) {
                                    return Icon(
                                      index < _averageRating.floor()
                                          ? Icons.star
                                          : index < _averageRating
                                              ? Icons.star_half
                                              : Icons.star_border,
                                      color: Colors.amber,
                                      size: 24.w,
                                    );
                                  }),
                                  SizedBox(width: 8.w),
                                  Text(
                                    _averageRating.toStringAsFixed(1),
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '(${_reviews.length} تقييم)',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.h),
                              
                              // المؤهلات
                              if (_doctor!.qualification != null) ...[
                                Text(
                                  'المؤهلات:',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  _doctor!.qualification!,
                                  style: TextStyle(fontSize: 14.sp),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 16.h),
                              ],
                              
                              // زر حجز موعد
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _navigateToBookAppointment,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryGreen,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: 12.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'حجز موعد',
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
                      SizedBox(height: 24.h),
                      
                      // التقييمات
                      Text(
                        'التقييمات',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      
                      _reviews.isEmpty
                          ? Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 24.h),
                                child: Text(
                                  'لا توجد تقييمات حتى الآن',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _reviews.length,
                              itemBuilder: (context, index) {
                                final review = _reviews[index];
                                return _buildReviewCard(review);
                              },
                            ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  review['patientName'],
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    ...List.generate(5, (index) {
                      return Icon(
                        index < (review['rating'] as double).floor()
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 16.w,
                      );
                    }),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              review['comment'],
              style: TextStyle(fontSize: 14.sp),
            ),
            SizedBox(height: 4.h),
            Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                _formatDate(review['date']),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final difference = DateTime.now().difference(date);
    
    if (difference.inDays == 0) {
      return 'اليوم';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 30) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'منذ $months شهر';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'منذ $years سنة';
    }
  }
}
