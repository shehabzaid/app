import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import 'identity_cards_screen.dart';
import 'qualifications_screen.dart';

class EmployeeDashboardScreen extends StatelessWidget {
  final String employeeId;
  final String employeeName;

  const EmployeeDashboardScreen({
    super.key,
    required this.employeeId,
    required this.employeeName,
  });

  @override
  Widget build(BuildContext context) {
    final services = [
      ServiceItem(
        icon: Icons.credit_card_outlined,
        title: 'رفع البطاقة\nالشخصية',
        description: '',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => IdentityCardsScreen(
                employeeId: employeeId,
                employeeName: employeeName,
              ),
            ),
          );
        },
      ),
      ServiceItem(
        icon: Icons.school,
        title: 'المؤهلات',
        description: 'عرض وإدارة المؤهلات العلمية',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QualificationsScreen(
                employeeId: employeeId,
                employeeName: employeeName,
              ),
            ),
          );
        },
      ),
      ServiceItem(
        icon: Icons.person,
        title: 'البيانات الشخصية',
        description: 'عرض وتحديث البيانات الشخصية',
        onTap: () {
          // TODO: Navigate to Personal Info screen
        },
      ),
      ServiceItem(
        icon: Icons.work,
        title: 'الخبرات العملية',
        description: 'عرض وإدارة الخبرات العملية',
        onTap: () {
          // TODO: Navigate to Work Experience screen
        },
      ),
      ServiceItem(
        icon: Icons.card_membership,
        title: 'الدورات التدريبية',
        description: 'عرض وإدارة الدورات التدريبية',
        onTap: () {
          // TODO: Navigate to Training Courses screen
        },
      ),
      ServiceItem(
        icon: Icons.attach_file,
        title: 'المرفقات',
        description: 'عرض وإدارة المستندات المرفقة',
        onTap: () {
          // TODO: Navigate to Attachments screen
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم الموظف'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // قسم الترحيب
              Text(
                'مرحباً ${employeeName}',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30.w,
                        backgroundColor: AppTheme.primaryGreen,
                        child: Text(
                          employeeName[0],
                          style: TextStyle(
                            fontSize: 24.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            employeeName,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'رقم الموظف: EMP-2025-6478-1',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              // قسم الخدمات المتاحة
              Text(
                'الخدمات المتاحة',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16.h),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16.h,
                  crossAxisSpacing: 16.w,
                  childAspectRatio: 1.1,
                ),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  return _buildServiceCard(
                    context,
                    service.icon,
                    service.title,
                    service.description,
                    service.onTap,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32.w,
              color: AppTheme.primaryGreen,
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            if (description.isNotEmpty) ...[
              SizedBox(height: 4.h),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ServiceItem {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  ServiceItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });
}
