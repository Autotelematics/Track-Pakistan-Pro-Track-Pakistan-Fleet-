import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdfrx/pdfrx.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:share_plus/share_plus.dart';
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
  String? _resolvedUrl;
  bool _isResolvingContent = false;
  String? _contentResolveError;
  bool _resolvedIsPdf = false;
  bool _resolvedIsImage = false;
  bool _resolvedIsHtml = false;
  Uint8List? _resolvedBytes;
  final PdfViewerController _pdfController = PdfViewerController();

  @override
  void initState() {
    super.initState();
    // Initialize pdfrx for Flutter
    pdfrxFlutterInitialize();
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
        lowerUrl.endsWith('.gif') ||
        lowerUrl.endsWith('.webp');
  }

  bool _isHtmlContent() {
    return widget.reportData.reportType == 43 &&
        widget.reportData.reportFormat.toLowerCase() == 'html';
  }

  bool _shouldOpenExternallyByFormat() {
    final format = widget.reportData.reportFormat.toLowerCase().trim();
    return format == 'html' ||
        format == 'xls' ||
        format == 'xlsx' ||
        format == 'csv';
  }

  bool _looksLikePdf(Uint8List bytes) {
    if (bytes.length < 5) return false;
    return bytes[0] == 0x25 && // %
        bytes[1] == 0x50 && // P
        bytes[2] == 0x44 && // D
        bytes[3] == 0x46 && // F
        bytes[4] == 0x2D; // -
  }

  bool _looksLikePng(Uint8List bytes) {
    if (bytes.length < 8) return false;
    return bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A;
  }

  bool _looksLikeJpeg(Uint8List bytes) {
    if (bytes.length < 3) return false;
    return bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF;
  }

  bool _looksLikeGif(Uint8List bytes) {
    if (bytes.length < 6) return false;
    final header = String.fromCharCodes(bytes.sublist(0, 6));
    return header == 'GIF87a' || header == 'GIF89a';
  }

  bool _looksLikeWebp(Uint8List bytes) {
    if (bytes.length < 12) return false;
    final riff = String.fromCharCodes(bytes.sublist(0, 4));
    final webp = String.fromCharCodes(bytes.sublist(8, 12));
    return riff == 'RIFF' && webp == 'WEBP';
  }

  bool _looksLikeHtml(Uint8List bytes) {
    if (bytes.isEmpty) return false;
    final head = String.fromCharCodes(
      bytes.take(bytes.length > 300 ? 300 : bytes.length),
    ).toLowerCase();
    return head.contains('<!doctype html') ||
        head.contains('<html') ||
        head.contains('<body');
  }

  Future<void> _resolveReportContent(String url) async {
    if (_isResolvingContent && _resolvedUrl == url) return;
    setState(() {
      _resolvedUrl = url;
      _isResolvingContent = true;
      _contentResolveError = null;
      _resolvedIsPdf = false;
      _resolvedIsImage = false;
      _resolvedIsHtml = false;
      _resolvedBytes = null;
    });

    try {
      final uri = Uri.parse(url);
      final response = await http.get(uri).timeout(const Duration(seconds: 45));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final bytes = response.bodyBytes;
      final contentType = (response.headers['content-type'] ?? '').toLowerCase();

      final isPdf = contentType.contains('application/pdf') || _looksLikePdf(bytes);
      final isImage = contentType.startsWith('image/') ||
          _looksLikePng(bytes) ||
          _looksLikeJpeg(bytes) ||
          _looksLikeGif(bytes) ||
          _looksLikeWebp(bytes);
      final isHtml = contentType.contains('text/html') || _looksLikeHtml(bytes);

      if (!mounted) return;
      setState(() {
        _resolvedBytes = bytes;
        _resolvedIsPdf = isPdf;
        _resolvedIsImage = isImage;
        _resolvedIsHtml = isHtml;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _contentResolveError = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isResolvingContent = false;
        });
      }
    }
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
              color: Colors.grey.withValues(alpha: 0.2),
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
        actions: [
          // Zoom controls for PDF
          if (_resolvedIsPdf && _resolvedBytes != null)
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.zoom_out, color: Colors.black),
                  onPressed: () {
                    // Zoom out by 0.1
                    final currentZoom = _pdfController.currentZoom;
                    _pdfController.setZoom(
                      _pdfController.centerPosition,
                      currentZoom - 0.1,
                      duration: const Duration(milliseconds: 200),
                    );
                  },
                  tooltip: 'Zoom Out',
                ),
                IconButton(
                  icon: const Icon(Icons.zoom_in, color: Colors.black),
                  onPressed: () {
                    // Zoom in by 0.1
                    final currentZoom = _pdfController.currentZoom;
                    _pdfController.setZoom(
                      _pdfController.centerPosition, // position to zoom around
                      currentZoom + 0.1,
                      duration: const Duration(milliseconds: 200),
                    );
                  },
                  tooltip: 'Zoom In',
                ),
                IconButton(
                  icon: const Icon(Icons.fit_screen, color: Colors.black),
                  onPressed: () {
                    // Fit to page - use goToPage with anchor
                    _pdfController.goToPage(
                      pageNumber: _pdfController.pageNumber ?? 1,
                      anchor: PdfPageAnchor.all,
                      duration: const Duration(milliseconds: 200),
                    );
                  },
                  tooltip: 'Fit to Page',
                ),
              ],
            ),
        ],
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
          if (_shouldOpenExternallyByFormat()) {
            if (!_hasLaunchedBrowser) {
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                if (!mounted) return;
                setState(() => _hasLaunchedBrowser = true);
                try {
                  await _launchURL(url);
                  await Future.delayed(const Duration(milliseconds: 500));
                  if (!mounted) return;
                  Navigator.pop(context);
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to open report: $e')),
                  );
                  setState(() => _hasLaunchedBrowser = false);
                }
              });
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text('Opening report in external app...'),
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
          if (_resolvedUrl != url && !_isHtmlContent()) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              _resolveReportContent(url);
            });
          }
          if (_isHtmlContent()) {
            if (!_hasLaunchedBrowser) {
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                setState(() {
                  _hasLaunchedBrowser = true;
                });
                try {
                  await _launchURL(url);
                  await Future.delayed(const Duration(seconds: 1));
                  if (!mounted) return;
                  Navigator.pop(context);
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to open browser: $e')),
                  );
                  setState(() {
                    _hasLaunchedBrowser = false;
                  });
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
          if (_isResolvingContent) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Loading report...',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ],
              ),
            );
          }

          if (_contentResolveError != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'Failed to load report content',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _contentResolveError!,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12.sp),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _launchURL(url),
                    child: const Text('Open In Browser'),
                  ),
                ],
              ),
            );
          }

          if (_resolvedIsHtml && !_hasLaunchedBrowser) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              if (!mounted) return;
              setState(() => _hasLaunchedBrowser = true);
              await _launchURL(url);
              if (!mounted) return;
              Navigator.pop(context);
            });
          }

          if (_resolvedIsImage || (_isImageUrl(url) && _resolvedBytes == null)) {
            return Stack(
              alignment: Alignment.topCenter,
              children: [
                Center(
                  child: _resolvedBytes != null
                      ? Image.memory(
                    _resolvedBytes!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Text(
                        'Failed to load image',
                        style: TextStyle(fontSize: 14.sp, color: Colors.red),
                      ),
                    ),
                  )
                      : Image.network(
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
                        onTap: () => SharePlus.instance.share(
                          ShareParams(text: url),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          if (!_resolvedIsPdf || _resolvedBytes == null || _resolvedBytes!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.insert_drive_file_outlined,
                      color: Colors.orange, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'Unsupported report format',
                    style:
                    TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Open this report in browser instead.',
                    style: TextStyle(fontSize: 12.sp),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _launchURL(url),
                    child: const Text('Open In Browser'),
                  ),
                ],
              ),
            );
          }

          // PDF viewer using pdfrx - use PdfViewer.data with sourceName
          return Stack(
            alignment: Alignment.topCenter,
            children: [
              PdfViewer.data(
                _resolvedBytes!,
                controller: _pdfController,
                sourceName: 'report.pdf', // Required parameter
                params: const PdfViewerParams(
                  backgroundColor: Colors.white,
                  margin: 0,
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
                      onTap: () => SharePlus.instance.share(
                        ShareParams(text: url),
                      ),
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