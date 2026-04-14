import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/neumorphic_card.dart';

class ScanInvoiceScreen extends StatefulWidget {
  const ScanInvoiceScreen({super.key});

  @override
  State<ScanInvoiceScreen> createState() => _ScanInvoiceScreenState();
}

class _ScanInvoiceScreenState extends State<ScanInvoiceScreen> {
  static const double _scannerViewportAspectRatio = 4 / 3;
  static const double _scannerFrameWidthFactor = 0.9;
  static const double _scannerFrameHeightFactor = 0.84;

  final ImagePicker _imagePicker = ImagePicker();
  final DocumentScanner _documentScanner = DocumentScanner(
    options: DocumentScannerOptions(
      documentFormats: {
        DocumentFormat.jpeg,
      },
      mode: ScannerMode.filter,
      pageLimit: 1,
      isGalleryImport: false,
    ),
  );
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );
  XFile? _capturedImage;
  _InvoiceCaptureSummary? _invoiceCaptureSummary;
  bool _isOpeningCamera = false;
  bool _isOpeningGallery = false;
  bool _isProcessingImage = false;
  String? _recognizedText;
  String? _recognitionError;

  bool get _hasRecognizedText =>
      _recognizedText != null &&
      _recognizedText!.isNotEmpty &&
      _recognitionError == null;

  bool get _hasCapturedInvoiceRows =>
      _invoiceCaptureSummary != null && _invoiceCaptureSummary!.entries.isNotEmpty;

  String get _scanStatusDescription {
    if (_isProcessingImage) {
      return 'Reading invoice text from the scanned document.';
    }
    if (_recognitionError != null) {
      return 'The invoice was captured, but OCR could not finish.';
    }
    if (_hasCapturedInvoiceRows) {
      final count = _invoiceCaptureSummary!.entries.length;
      return '$count invoice row${count == 1 ? '' : 's'} ready for review.';
    }
    if (_hasRecognizedText) {
      return 'Invoice text was captured, but no SI rows were matched yet.';
    }
    if (_capturedImage != null) {
      return 'Image selected. OCR will run automatically.';
    }
    return 'Capture or upload one invoice image to begin.';
  }

  Future<void> _setSelectedImage(XFile image) async {
    setState(() {
      _capturedImage = image;
      _invoiceCaptureSummary = null;
      _recognizedText = null;
      _recognitionError = null;
    });

    await _scanInvoiceText(image);
  }

  Future<void> _scanInvoiceText(XFile image) async {
    setState(() {
      _isProcessingImage = true;
    });

    final selectedPath = image.path;

    try {
      if (!Platform.isAndroid && !Platform.isIOS) {
        if (!mounted || _capturedImage?.path != selectedPath) return;

        setState(() {
          _recognitionError =
              'Invoice OCR is only supported on Android and iOS. '
              'Current platform: ${Platform.operatingSystem}.';
        });
        return;
      }

      final imageFile = File(selectedPath);
      if (!await imageFile.exists()) {
        if (!mounted || _capturedImage?.path != selectedPath) return;

        setState(() {
          _recognitionError = 'Selected image file was not found.';
        });
        return;
      }

      final inputImage = InputImage.fromFilePath(selectedPath);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      final extractedText = recognizedText.text.trim();

      if (!mounted || _capturedImage?.path != selectedPath) return;

      if (extractedText.isEmpty) {
        setState(() {
          _recognizedText = null;
          _invoiceCaptureSummary = null;
          _recognitionError = 'No readable invoice text was found.';
        });
        return;
      }

      final invoiceCaptureSummary = _buildInvoiceCaptureSummary(extractedText);

      setState(() {
        _recognizedText = extractedText;
        _invoiceCaptureSummary = invoiceCaptureSummary;
        _recognitionError = null;
      });
    } catch (e) {
      if (!mounted || _capturedImage?.path != selectedPath) return;

      setState(() {
        _invoiceCaptureSummary = null;
        _recognitionError = 'Unable to scan invoice text.\n$e';
      });
    } finally {
      if (!mounted || _capturedImage?.path != selectedPath) return;

      setState(() {
        _isProcessingImage = false;
      });
    }
  }

  _InvoiceCaptureSummary _buildInvoiceCaptureSummary(String rawText) {
    final normalizedText = rawText.replaceAll('\r', '\n');
    final lines =
        normalizedText
            .split('\n')
            .map((line) => line.replaceAll(RegExp(r'\s+'), ' ').trim())
            .where((line) => line.isNotEmpty)
            .toList();
    final entries = <_InvoiceCaptureEntry>[];
    final seenEntries = <String>{};
    final rowPattern = RegExp(
      r'^(?:\d+\s+)?([A-Z0-9]{4,})\s+([0-9]{1,2}(?:[-/][A-Za-z]{3}|[-/][0-9]{1,2})[-/][0-9]{2,4})\s+(.+)$',
      caseSensitive: false,
    );
    final amountTailPattern = RegExp(
      r'\s+[0-9][0-9,]*\.\d{2}(?:\s+[A-Z0-9]{2,6})?\s*$',
      caseSensitive: false,
    );

    for (final rawLine in lines) {
      final line = rawLine.trim();

      if (line.isEmpty) continue;
      if (line.toLowerCase().contains('customer name')) continue;
      if (line.toLowerCase().contains('si date')) continue;
      if (line.toLowerCase().contains('si no')) continue;

      final cleanedLine = line.replaceFirst(amountTailPattern, '').trim();
      final match = rowPattern.firstMatch(cleanedLine);
      if (match == null) continue;

      final siNumber = match.group(1)?.trim();
      final siDate = match.group(2)?.trim();
      final customerName = match.group(3)?.trim();

      if (siNumber == null || siDate == null || customerName == null) continue;
      if (customerName.isEmpty) continue;

      final normalizedCustomerName =
          customerName.replaceAll(RegExp(r'\s+'), ' ').trim();
      final dedupeKey =
          '$siNumber|$siDate|$normalizedCustomerName'.toUpperCase();

      if (!seenEntries.add(dedupeKey)) continue;

      entries.add(
        _InvoiceCaptureEntry(
          siNumber: siNumber,
          siDate: siDate,
          customerName: normalizedCustomerName,
        ),
      );
    }

    return _InvoiceCaptureSummary(entries: entries);
  }

  Future<void> _openCamera() async {
    if (_isOpeningCamera) return;

    setState(() {
      _isOpeningCamera = true;
    });

    try {
      if (Platform.isAndroid) {
        final result = await _documentScanner.scanDocument();
        final scannedImages = result.images;
        if (!mounted || scannedImages == null || scannedImages.isEmpty) return;

        final scannedImagePath = scannedImages.first;
        if (scannedImagePath.isEmpty) return;

        await _setSelectedImage(XFile(scannedImagePath));
      } else {
        final image = await _imagePicker.pickImage(
          source: ImageSource.camera,
        );

        if (!mounted || image == null) return;

        await _setSelectedImage(image);
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Platform.isAndroid
                ? 'Unable to start document scanner.'
                : 'Unable to open camera.',
          ),
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isOpeningCamera = false;
      });
    }
  }

  Future<void> _openGallery() async {
    if (_isOpeningGallery) return;

    setState(() {
      _isOpeningGallery = true;
    });

    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (!mounted || image == null) return;

      await _setSelectedImage(image);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open gallery.'),
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isOpeningGallery = false;
      });
    }
  }

  void _discardScannedImage() {
    setState(() {
      _capturedImage = null;
      _invoiceCaptureSummary = null;
      _recognizedText = null;
      _recognitionError = null;
      _isProcessingImage = false;
    });
  }

  @override
  void dispose() {
    _documentScanner.close();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Invoice'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NeumorphicCard(
              padding: EdgeInsets.zero,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.cardElevated,
                      AppColors.cardDark,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryTeal.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'CAMERA PREVIEW',
                            style: TextStyle(
                              color: AppColors.primaryTeal,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _scanStatusDescription,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 14),
                    AspectRatio(
                      aspectRatio: _scannerViewportAspectRatio,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.backgroundDark,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              _capturedImage != null
                                  ? Image.file(
                                    File(_capturedImage!.path),
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                  : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Place invoice inside frame',
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Keep SI no., SI date, and customer name clear and readable.',
                                        style: TextStyle(
                                          color: AppColors.textPrimary.withValues(
                                            alpha: 0.55,
                                          ),
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                              const _CropFrameOverlay(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_capturedImage != null && _isProcessingImage) ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                        child: const Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primaryTeal,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Scanning invoice text...',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (_capturedImage != null &&
                        !_isProcessingImage &&
                        _recognitionError != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.statusCritical.withValues(
                              alpha: 0.18,
                            ),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.statusCritical.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                LucideIcons.alertTriangle,
                                color: AppColors.statusCritical,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _recognitionError!,
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: _isOpeningCamera ? null : _openCamera,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryTeal,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon:
                        _isOpeningCamera
                            ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                            : const Icon(LucideIcons.scanLine, size: 18),
                    label: Text(
                      _isOpeningCamera ? 'Opening...' : 'Scan',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: _isOpeningGallery ? null : _openGallery,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                        backgroundColor: AppColors.cardDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon:
                          _isOpeningGallery
                              ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.textPrimary,
                                ),
                              )
                              : const Icon(LucideIcons.imagePlus, size: 18),
                      label: Text(
                        _isOpeningGallery ? 'Opening...' : 'Upload Image',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_capturedImage != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: OutlinedButton.icon(
                  onPressed:
                      _isProcessingImage ? null : _discardScannedImage,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: BorderSide(
                      color: Colors.redAccent.withValues(alpha: 0.22),
                    ),
                    backgroundColor: AppColors.cardDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(LucideIcons.trash2, size: 18),
                  label: const Text(
                    'Discard Scanned Image',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            NeumorphicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Best Scan Results',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 12),
                  _GuideRow(
                    icon: LucideIcons.expand,
                    title: 'Capture the full invoice',
                    subtitle: 'Keep all edges visible inside the frame.',
                  ),
                  SizedBox(height: 10),
                  _GuideRow(
                    icon: LucideIcons.sunMedium,
                    title: 'Use bright lighting',
                    subtitle: 'Avoid dark shadows, folds, and glare.',
                  ),
                  SizedBox(height: 10),
                  _GuideRow(
                    icon: LucideIcons.searchCode,
                    title: 'Scan one page only',
                    subtitle: 'Use a clear photo before extracting invoice details.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CropFrameOverlay extends StatelessWidget {
  const _CropFrameOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Center(
            child: FractionallySizedBox(
              widthFactor: _ScanInvoiceScreenState._scannerFrameWidthFactor,
              heightFactor: _ScanInvoiceScreenState._scannerFrameHeightFactor,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.82),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryTeal.withValues(alpha: 0.16),
                          blurRadius: 16,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const Positioned(
                    top: 10,
                    left: 10,
                    child: _CropCorner(top: true, left: true),
                  ),
                  const Positioned(
                    top: 10,
                    right: 10,
                    child: _CropCorner(top: true, right: true),
                  ),
                  const Positioned(
                    bottom: 10,
                    left: 10,
                    child: _CropCorner(bottom: true, left: true),
                  ),
                  const Positioned(
                    bottom: 10,
                    right: 10,
                    child: _CropCorner(bottom: true, right: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _GuideRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.primaryTeal.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryTeal,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InvoiceCaptureSummary {
  final List<_InvoiceCaptureEntry> entries;

  const _InvoiceCaptureSummary({
    required this.entries,
  });
}

class _InvoiceCaptureEntry {
  final String siNumber;
  final String siDate;
  final String customerName;

  const _InvoiceCaptureEntry({
    required this.siNumber,
    required this.siDate,
    required this.customerName,
  });
}

class _CropCorner extends StatelessWidget {
  final bool top;
  final bool right;
  final bool bottom;
  final bool left;

  const _CropCorner({
    this.top = false,
    this.right = false,
    this.bottom = false,
    this.left = false,
  });

  @override
  Widget build(BuildContext context) {
    const accent = BorderSide(
      color: AppColors.primaryTeal,
      width: 3,
    );

    return SizedBox(
      width: 22,
      height: 22,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: top ? accent : BorderSide.none,
            right: right ? accent : BorderSide.none,
            bottom: bottom ? accent : BorderSide.none,
            left: left ? accent : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
