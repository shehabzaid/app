import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';

class RateDoctorScreen extends StatefulWidget {
  final String appointmentId;
  final String doctorName;
  final String hospitalName;
  final String appointmentDate;

  const RateDoctorScreen({
    super.key,
    required this.appointmentId,
    required this.doctorName,
    required this.hospitalName,
    required this.appointmentDate,
  });

  @override
  State<RateDoctorScreen> createState() => _RateDoctorScreenState();
}

class _RateDoctorScreenState extends State<RateDoctorScreen> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار تقييم')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // TODO: Implement API call to submit rating
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إرسال التقييم بنجاح')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقييم الطبيب'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // معلومات الموعد
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    Text(
                      widget.doctorName,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      widget.hospitalName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'تاريخ الموعد: ${widget.appointmentDate}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32.h),
            
            // نص التقييم
            Text(
              'كيف كانت تجربتك مع الطبيب؟',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            
            // نجوم التقييم
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 40.w,
                  ),
                  onPressed: () {
                    setState(() => _rating = index + 1);
                  },
                );
              }),
            ),
            SizedBox(height: 8.h),
            
            // نص وصف التقييم
            Text(
              _getRatingDescription(),
              style: TextStyle(
                fontSize: 16.sp,
                color: _rating > 0 ? AppTheme.primaryGreen : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            
            // حقل التعليق
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'اكتب تعليقك هنا (اختياري)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppTheme.primaryGreen, width: 2),
                ),
              ),
            ),
            SizedBox(height: 32.h),
            
            // زر الإرسال
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRating,
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
                        'إرسال التقييم',
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

  String _getRatingDescription() {
    switch (_rating) {
      case 1:
        return 'سيء';
      case 2:
        return 'مقبول';
      case 3:
        return 'جيد';
      case 4:
        return 'جيد جداً';
      case 5:
        return 'ممتاز';
      default:
        return 'اختر تقييمك';
    }
  }
}
