import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../models/identity_card.dart';
import '../services/identity_card_service.dart';

class IdentityCardsScreen extends StatefulWidget {
  final String employeeId;
  final String employeeName;

  const IdentityCardsScreen({
    super.key,
    required this.employeeId,
    required this.employeeName,
  });

  @override
  State<IdentityCardsScreen> createState() => _IdentityCardsScreenState();
}

class _IdentityCardsScreenState extends State<IdentityCardsScreen> {
  final _identityCardService = IdentityCardService();
  List<IdentityCard> _cards = [];
  bool _isLoading = false;
  String? _selectedFilePath;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    setState(() => _isLoading = true);
    try {
      _cards = await _identityCardService.getIdentityCards(widget.employeeId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ في تحميل البطاقات: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showAddEditCardDialog([IdentityCard? card]) async {
    String? cardType = card?.cardType;
    String? issuedBy = card?.issuedBy;
    String? selectedFilePath;
    String? attachment = card?.attachment;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(card == null ? 'إضافة بطاقة جديدة' : 'تعديل البطاقة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'نوع البطاقة'),
                onChanged: (value) => cardType = value,
                controller: TextEditingController(text: cardType),
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'الجهة المصدرة'),
                onChanged: (value) => issuedBy = value,
                controller: TextEditingController(text: issuedBy),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
                  );
                  if (result != null) {
                    setState(() {
                      selectedFilePath = result.files.single.path;
                    });
                  }
                },
                child: Text(selectedFilePath != null
                    ? 'تم اختيار الملف'
                    : 'إرفاق صورة البطاقة'),
              ),
              if (selectedFilePath != null)
                Text(selectedFilePath!.split('/').last),
              if (attachment != null && selectedFilePath == null)
                Text('الملف الحالي: ${attachment.split('/').last}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop({
                  'cardType': cardType,
                  'issuedBy': issuedBy,
                  'selectedFilePath': selectedFilePath,
                });
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );

    if (result != null &&
        result['cardType']?.isNotEmpty == true &&
        result['issuedBy']?.isNotEmpty == true) {
      setState(() => _isLoading = true);
      try {
        String? fileUrl;
        if (result['selectedFilePath'] != null) {
          fileUrl = await _identityCardService
              .uploadCardImage(result['selectedFilePath']);
        }

        final newCard = IdentityCard(
          id: card?.id ?? const Uuid().v4(),
          employeeId: widget.employeeId,
          cardType: result['cardType']!,
          issuedBy: result['issuedBy']!,
          attachment: fileUrl ?? card?.attachment,
          createdAt: card?.createdAt ?? DateTime.now(),
        );

        if (card == null) {
          await _identityCardService.addIdentityCard(newCard);
        } else {
          await _identityCardService.updateIdentityCard(newCard);
        }

        await _loadCards();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('حدث خطأ: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _deleteCard(IdentityCard card) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذه البطاقة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        setState(() => _isLoading = true);
        await _identityCardService.deleteIdentityCard(card.id);
        _loadCards();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ في حذف البطاقة: ${e.toString()}'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Widget _buildCardItem(IdentityCard card) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    card.cardType,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        color: Colors.blue,
                        onPressed: () => _showAddEditCardDialog(card),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: AppTheme.errorColor,
                        onPressed: () => _deleteCard(card),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                'جهة الإصدار: ${card.issuedBy}',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.black54,
                ),
              ),
              if (card.attachment != null) ...[
                SizedBox(height: 16.h),
                Container(
                  height: 200.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(card.attachment!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
              if (card.createdAt != null) ...[
                SizedBox(height: 8.h),
                Text(
                  'تاريخ الإضافة: ${card.createdAt!.toLocal().toString().split('.')[0]}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('البطاقات الشخصية - ${widget.employeeName}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: ElevatedButton.icon(
              onPressed: () => _showAddEditCardDialog(),
              icon: const Icon(Icons.add),
              label: const Text('إضافة بطاقة جديدة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 12.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _cards.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.credit_card_off,
                              size: 64.w,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'لا توجد بطاقات شخصية',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        itemCount: _cards.length,
                        itemBuilder: (context, index) =>
                            _buildCardItem(_cards[index]),
                      ),
          ),
        ],
      ),
    );
  }
}
