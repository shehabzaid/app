import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../../core/theme/app_theme.dart';
import '../models/review.dart';
import '../services/review_service.dart';
import '../../../features/auth/services/auth_service.dart';

class RateDoctorScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String? appointmentId;

  const RateDoctorScreen({
    Key? key,
    required this.doctorId,
    required this.doctorName,
    this.appointmentId,
  }) : super(key: key);

  @override
  State<RateDoctorScreen> createState() => _RateDoctorScreenState();
}

class _RateDoctorScreenState extends State<RateDoctorScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final ReviewService _reviewService = ReviewService();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  int _rating = 0;
  String? _userId;
  bool _hasExistingReview = false;

  @override
  void initState() {
    super.initState();
    _checkExistingReview();
  }

  Future<void> _checkExistingReview() async {
    try {
      final currentUser = await _authService.getCurrentUserProfile();
      if (currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('لم يتم العثور على بيانات المستخدم'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pop(context);
        }
        return;
      }

      setState(() {
        _userId = currentUser.id;
      });

      final hasReview = await _reviewService.hasPatientReviewedDoctor(
        currentUser.id,
        widget.doctorId,
      );

      setState(() {
        _hasExistingReview = hasReview;
      });

      if (hasReview && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لقد قمت بتقييم هذا الطبيب مسبقاً'),
            backgroundColor: Colors.orange,
          ),
        );
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقييم الطبيب'),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'تقييم الدكتور ${widget.doctorName}',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            Text(
              'كيف كانت تجربتك مع الطبيب؟',
              style: TextStyle(
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 16.h),
            _buildRatingStars(),
            SizedBox(height: 24.h),
            Text(
              'أضف تعليقاً (اختياري)',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            FormBuilderTextField(
              name: 'comment',
              decoration: InputDecoration(
                hintText: 'اكتب تعليقك هنا...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_isLoading || _rating == 0 || _hasExistingReview)
                    ? null
                    : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  disabledBackgroundColor: _hasExistingReview
                      ? Colors.grey
                      : AppTheme.primaryGreen.withOpacity(0.5),
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
                        _hasExistingReview ? 'تم التقييم مسبقاً' : 'إرسال التقييم',
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

  Widget _buildRatingStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < _rating ? Icons.star : Icons.star_border,
            color: index < _rating ? Colors.amber : Colors.grey,
            size: 36.sp,
          ),
          onPressed: _hasExistingReview
              ? null
              : () {
                  setState(() {
                    _rating = index + 1;
                  });
                },
        );
      }),
    );
  }

  Future<void> _submitReview() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (_userId == null) {
          throw Exception('لم يتم العثور على بيانات المستخدم');
        }

        final formData = _formKey.currentState!.value;
        final comment = formData['comment'] as String?;

        final review = Review(
          id: '', // Se generará automáticamente en la base de datos
          patientId: _userId!,
          doctorId: widget.doctorId,
          rating: _rating,
          comment: comment,
          createdAt: DateTime.now(),
        );

        await _reviewService.addReview(review);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إرسال التقييم بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
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
