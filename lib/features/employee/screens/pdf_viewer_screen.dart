import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class PDFViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PDFViewerScreen({
    super.key,
    required this.pdfUrl,
    required this.title,
  });

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  String? localPath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPDF();
  }

  Future<void> _loadPDF() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse(widget.pdfUrl));
      final bytes = response.bodyBytes;
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/temp.pdf');
      await file.writeAsBytes(bytes);

      if (mounted) {
        setState(() {
          localPath = file.path;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ في تحميل الملف: ${e.toString()}')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('جاري تحميل الملف...'),
                ],
              ),
            )
          : PDFView(
              filePath: localPath!,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: true,
              pageFling: true,
              onError: (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('حدث خطأ: $error')),
                );
                Navigator.pop(context);
              },
            ),
    );
  }
}
