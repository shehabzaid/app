import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;
import '../../../features/advertisements/models/advertisement.dart';
import '../../../features/advertisements/services/advertisement_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/loading_indicator.dart';

class AddEditAdvertisementScreen extends StatefulWidget {
  final Advertisement? advertisement;

  const AddEditAdvertisementScreen({super.key, this.advertisement});

  @override
  State<AddEditAdvertisementScreen> createState() => _AddEditAdvertisementScreenState();
}

class _AddEditAdvertisementScreenState extends State<AddEditAdvertisementScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final AdvertisementService _adService = AdvertisementService();
  bool _isLoading = false;
  bool _isEditing = false;
  
  @override
  void initState() {
    super.initState();
    _isEditing = widget.advertisement != null;
  }

  Future<void> _saveAdvertisement() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final formValues = _formKey.currentState!.value;
        
        // إنشاء كائن الإعلان من قيم النموذج
        final advertisement = Advertisement(
          id: _isEditing ? widget.advertisement!.id : '',
          title: formValues['title'] as String,
          description: formValues['description'] as String?,
          imageUrl: formValues['image_url'] as String,
          targetUrl: formValues['target_url'] as String?,
          startDate: formValues['start_date'] as DateTime,
          endDate: formValues['end_date'] as DateTime?,
          isActive: formValues['is_active'] as bool,
          createdAt: _isEditing ? widget.advertisement!.createdAt : DateTime.now(),
        );

        if (_isEditing) {
          // تحديث إعلان موجود
          await _adService.updateAdvertisement(advertisement);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم تحديث الإعلان بنجاح')),
            );
          }
        } else {
          // إضافة إعلان جديد
          await _adService.addAdvertisement(advertisement);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم إضافة الإعلان بنجاح')),
            );
          }
        }

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        developer.log('Error saving advertisement: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل في حفظ الإعلان: $e')),
          );
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'تعديل إعلان' : 'إضافة إعلان جديد'),
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: FormBuilder(
                key: _formKey,
                initialValue: _isEditing
                    ? {
                        'title': widget.advertisement!.title,
                        'description': widget.advertisement!.description ?? '',
                        'image_url': widget.advertisement!.imageUrl,
                        'target_url': widget.advertisement!.targetUrl ?? '',
                        'start_date': widget.advertisement!.startDate,
                        'end_date': widget.advertisement!.endDate,
                        'is_active': widget.advertisement!.isActive,
                      }
                    : {
                        'title': '',
                        'description': '',
                        'image_url': '',
                        'target_url': '',
                        'start_date': DateTime.now(),
                        'is_active': true,
                      },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // عنوان الإعلان
                    FormBuilderTextField(
                      name: 'title',
                      decoration: const InputDecoration(
                        labelText: 'عنوان الإعلان *',
                        hintText: 'أدخل عنوان الإعلان',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: 'هذا الحقل مطلوب'),
                        FormBuilderValidators.maxLength(100, errorText: 'الحد الأقصى 100 حرف'),
                      ]),
                    ),
                    const SizedBox(height: 16),

                    // وصف الإعلان
                    FormBuilderTextField(
                      name: 'description',
                      decoration: const InputDecoration(
                        labelText: 'وصف الإعلان',
                        hintText: 'أدخل وصف الإعلان (اختياري)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                      validator: FormBuilderValidators.maxLength(500, errorText: 'الحد الأقصى 500 حرف'),
                    ),
                    const SizedBox(height: 16),

                    // رابط الصورة
                    FormBuilderTextField(
                      name: 'image_url',
                      decoration: const InputDecoration(
                        labelText: 'رابط الصورة *',
                        hintText: 'أدخل رابط صورة الإعلان',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.image),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: 'هذا الحقل مطلوب'),
                        FormBuilderValidators.url(errorText: 'يرجى إدخال رابط صحيح'),
                      ]),
                    ),
                    const SizedBox(height: 16),

                    // معاينة الصورة
                    FormBuilderField(
                      name: 'image_preview',
                      builder: (FormFieldState field) {
                        final imageUrl = _formKey.currentState?.fields['image_url']?.value as String?;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'معاينة الصورة:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (imageUrl != null && imageUrl.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  imageUrl,
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    height: 150,
                                    width: double.infinity,
                                    color: Colors.grey.shade200,
                                    child: const Center(
                                      child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                    ),
                                  ),
                                ),
                              )
                            else
                              Container(
                                height: 150,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: const Center(
                                  child: Text('أدخل رابط الصورة للمعاينة'),
                                ),
                              ),
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: () {
                                final imageUrl = _formKey.currentState?.fields['image_url']?.value as String?;
                                if (imageUrl != null && imageUrl.isNotEmpty) {
                                  field.didChange(imageUrl);
                                }
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('تحديث المعاينة'),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // رابط الهدف
                    FormBuilderTextField(
                      name: 'target_url',
                      decoration: const InputDecoration(
                        labelText: 'رابط الهدف',
                        hintText: 'أدخل الرابط الذي سيتم توجيه المستخدم إليه (اختياري)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.link),
                      ),
                      validator: FormBuilderValidators.url(errorText: 'يرجى إدخال رابط صحيح'),
                    ),
                    const SizedBox(height: 16),

                    // تاريخ البدء
                    FormBuilderDateTimePicker(
                      name: 'start_date',
                      decoration: const InputDecoration(
                        labelText: 'تاريخ البدء *',
                        hintText: 'اختر تاريخ بدء عرض الإعلان',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      inputType: InputType.date,
                      format: DateFormat('yyyy-MM-dd'),
                      validator: FormBuilderValidators.required(errorText: 'هذا الحقل مطلوب'),
                    ),
                    const SizedBox(height: 16),

                    // تاريخ الانتهاء
                    FormBuilderDateTimePicker(
                      name: 'end_date',
                      decoration: const InputDecoration(
                        labelText: 'تاريخ الانتهاء',
                        hintText: 'اختر تاريخ انتهاء عرض الإعلان (اختياري)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.event_busy),
                      ),
                      inputType: InputType.date,
                      format: DateFormat('yyyy-MM-dd'),
                    ),
                    const SizedBox(height: 16),

                    // حالة النشاط
                    FormBuilderSwitch(
                      name: 'is_active',
                      title: const Text(
                        'نشط',
                        style: TextStyle(fontSize: 16),
                      ),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      activeColor: AppTheme.primaryGreen,
                    ),
                    const SizedBox(height: 24),

                    // أزرار الحفظ والإلغاء
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.cancel),
                            label: const Text('إلغاء'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _saveAdvertisement,
                            icon: Icon(_isEditing ? Icons.save : Icons.add),
                            label: Text(_isEditing ? 'حفظ التغييرات' : 'إضافة الإعلان'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
