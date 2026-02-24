import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:trackerapp/data/models/initial_reports.dart';
import 'package:trackerapp/providers/get_device_reports_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewReportScreen extends StatefulWidget {
  final ViewReportInitialData reportData;
  final String reportName;

  const ViewReportScreen({
    super.key,
    required this.reportData,
    required this.reportName,
  });

  @override
  State<ViewReportScreen> createState() => _ViewReportScreenState();
}

class _ViewReportScreenState extends State<ViewReportScreen> {
  bool _hasLaunchedBrowser = false;

  @override
  void initState() {
    super.initState();
    context.read<ReportTypeProvider>().generateReport(widget.reportData);
  }
  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
  }
  bool _isImageUrl(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.endsWith('.png') ||
        lowerUrl.endsWith('.jpg') ||
        lowerUrl.endsWith('.jpeg') ||
        lowerUrl.endsWith('.gif');
  }

  bool _isHtmlContent() {
    return widget.reportData.reportType == 43 &&
        widget.reportData.reportFormat.toLowerCase() == 'html';
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 3,
              blurRadius: 5,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 20.sp),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          widget.reportName,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp),
        ),
      ),
      body: Consumer<ReportTypeProvider>(
        builder: (context, provider, _) {
          if (provider.isGeneratingReport) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Generating report...',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ],
              ),
            );
          }
          if (provider.generateReportError != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    provider.generateReportError!,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      provider.clearGeneratedReport();
                      provider.generateReport(widget.reportData);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (provider.generatedReport == null || provider.generatedReport!.url == null) {
            return const Center(child: Text('No report URL available'));
          }
          final url = provider.generatedReport!.url!;
          if (_isHtmlContent()) {
            if (!_hasLaunchedBrowser) {
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                setState(() {
                  _hasLaunchedBrowser = true;
                });
                try {
                  await _launchURL(url);
                  await Future.delayed(const Duration(seconds: 1));
                  if (mounted) {
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to open browser: $e')),
                    );
                    setState(() {
                      _hasLaunchedBrowser = false;
                    });
                  }
                }
              });
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text('Opening map report in browser...'),
                  const SizedBox(height: 16),
                  if (_hasLaunchedBrowser)
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                ],
              ),
            );
          }

          // Handle image URLs
          if (_isImageUrl(url)) {
            return Stack(
              alignment: Alignment.topCenter,
              children: [
                Center(
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Text(
                        'Failed to load image',
                        style: TextStyle(fontSize: 14.sp, color: Colors.red),
                      ),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
                Positioned(
                  top: 3.h,
                  right: 3.w,
                  child: Row(
                    children: [
                      _buildActionButton(
                        icon: Icons.download,
                        color: const Color(0xffFBB117),
                        onTap: () => _launchURL(url),
                      ),
                      SizedBox(width: 3.w),
                      _buildActionButton(
                        icon: Icons.share,
                        color: Colors.green,
                        onTap: () => Share.share(url),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          // Default: PDF viewer
          return Stack(
            alignment: Alignment.topCenter,
            children: [
              SfPdfViewer.network(
                url,
                initialZoomLevel: 0,
                pageSpacing: 0,
                enableDoubleTapZooming: true,
                pageLayoutMode: PdfPageLayoutMode.continuous,
                onDocumentLoadFailed: (details) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to load PDF: ${details.description}'),
                    ),
                  );
                },
              ),
              Positioned(
                top: 3.h,
                right: 3.w,
                child: Row(
                  children: [
                    _buildActionButton(
                      icon: Icons.download,
                      color: const Color(0xffFBB117),
                      onTap: () => _launchURL(url),
                    ),
                    SizedBox(width: 3.w),
                    _buildActionButton(
                      icon: Icons.share,
                      color: Colors.green,
                      onTap: () => Share.share(url),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}