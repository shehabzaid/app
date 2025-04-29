import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:developer' as developer;
import '../../../features/advertisements/models/advertisement.dart';
import '../../../features/advertisements/services/advertisement_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_view.dart';

class AdminAdvertisementsScreen extends StatefulWidget {
  const AdminAdvertisementsScreen({super.key});

  @override
  State<AdminAdvertisementsScreen> createState() =>
      _AdminAdvertisementsScreenState();
}

class _AdminAdvertisementsScreenState extends State<AdminAdvertisementsScreen> {
  final AdvertisementService _adService = AdvertisementService();
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  List<Advertisement> _advertisements = [];

  @override
  void initState() {
    super.initState();
    _loadAdvertisements();
  }

  Future<void> _loadAdvertisements() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // استخدام الدالة الجديدة التي سنضيفها للحصول على جميع الإعلانات (بما في ذلك غير النشطة)
      final ads = await _adService.getAllAdvertisements();

      if (mounted) {
        setState(() {
          _advertisements = ads;
          _isLoading = false;
        });
      }
    } catch (e) {
      developer.log('Error loading advertisements: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'فشل في تحميل الإعلانات: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteAdvertisement(String id) async {
    try {
      await _adService.deleteAdvertisement(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف الإعلان بنجاح')),
      );
      _loadAdvertisements(); // إعادة تحميل القائمة
    } catch (e) {
      developer.log('Error deleting advertisement: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في حذف الإعلان: $e')),
      );
    }
  }

  void _confirmDelete(Advertisement ad) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف الإعلان "${ad.title}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAdvertisement(ad.id);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _navigateToAddEditScreen({Advertisement? advertisement}) {
    Navigator.pushNamed(
      context,
      '/admin/advertisements/edit',
      arguments: advertisement,
    ).then((_) => _loadAdvertisements()); // إعادة تحميل البيانات عند العودة
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الإعلانات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAdvertisements,
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : _hasError
              ? ErrorView(
                  error: _errorMessage,
                  onRetry: _loadAdvertisements,
                )
              : _advertisements.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.campaign_outlined,
                            size: 80,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'لا توجد إعلانات',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'اضغط على زر الإضافة لإنشاء إعلان جديد',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => _navigateToAddEditScreen(),
                            icon: const Icon(Icons.add),
                            label: const Text('إضافة إعلان جديد'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadAdvertisements,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _advertisements.length,
                        itemBuilder: (context, index) {
                          final ad = _advertisements[index];
                          return _buildAdvertisementCard(ad);
                        },
                      ),
                    ),
      floatingActionButton: _advertisements.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => _navigateToAddEditScreen(),
              backgroundColor: AppTheme.primaryGreen,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildAdvertisementCard(Advertisement ad) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: ad.isActive ? Colors.green.shade200 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // صورة الإعلان
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              ad.imageUrl,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 150,
                color: Colors.grey.shade200,
                child: const Center(
                  child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                ),
              ),
            ),
          ),

          // تفاصيل الإعلان
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        ad.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: ad.isActive
                            ? Colors.green.shade100
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        ad.isActive ? 'نشط' : 'غير نشط',
                        style: TextStyle(
                          color: ad.isActive
                              ? Colors.green.shade800
                              : Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                if (ad.description != null && ad.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    ad.description!,
                    style: TextStyle(color: Colors.grey.shade700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      'من: ${_formatDate(ad.startDate)}',
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                    if (ad.endDate != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        'إلى: ${_formatDate(ad.endDate!)}',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // زر التعديل
                    OutlinedButton.icon(
                      onPressed: () =>
                          _navigateToAddEditScreen(advertisement: ad),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('تعديل'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: const BorderSide(color: Colors.blue),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // زر الحذف
                    OutlinedButton.icon(
                      onPressed: () => _confirmDelete(ad),
                      icon: const Icon(Icons.delete, size: 18),
                      label: const Text('حذف'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }
}
