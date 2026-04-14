import 'dart:io';

import 'package:flutter/material.dart';
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
  final ImagePicker _imagePicker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );
  XFile? _capturedImage;
  String? _selectedImageSource;
  bool _isOpeningCamera = false;
  bool _isOpeningGallery = false;
  bool _isProcessingImage = false;
  String? _recognizedText;
  String? _recognitionError;

  String _getImageName(XFile image) {
    final directName = image.name.trim();
    if (directName.isNotEmpty) return directName;

    final pathParts = image.path.split(RegExp(r'[\\/]'));
    final fallbackName = pathParts.isNotEmpty ? pathParts.last.trim() : '';
    return fallbackName.isNotEmpty ? fallbackName : 'selected_image';
  }

  String _getImageExtension(XFile image) {
    final fileName = _getImageName(image);
    return fileName.contains('.')
        ? fileName.split('.').last.toUpperCase()
        : 'FILE';
  }

  Future<void> _setSelectedImage(XFile image, String sourceLabel) async {
    setState(() {
      _capturedImage = image;
      _selectedImageSource = sourceLabel;
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

      setState(() {
        _recognizedText =
            extractedText.isEmpty ? 'No readable text found.' : extractedText;
      });
    } catch (e) {
      if (!mounted || _capturedImage?.path != selectedPath) return;

      setState(() {
        _recognitionError = 'Unable to scan invoice text.\n$e';
      });
    } finally {
      if (!mounted || _capturedImage?.path != selectedPath) return;

      setState(() {
        _isProcessingImage = false;
      });
    }
  }

  Future<void> _openCamera() async {
    if (_isOpeningCamera) return;

    setState(() {
      _isOpeningCamera = true;
    });

    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
      );

      if (!mounted || image == null) return;

      await _setSelectedImage(image, 'Camera');
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open camera.'),
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

      await _setSelectedImage(image, 'Gallery');
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

  @override
  void dispose() {
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
            const Text(
              'Capture or upload an invoice image to begin scanning.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
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
                    const SizedBox(height: 14),
                    AspectRatio(
                      aspectRatio: 16 / 9,
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
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryTeal.withValues(
                                            alpha: 0.12,
                                          ),
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                        child: const Icon(
                                          LucideIcons.camera,
                                          color: AppColors.primaryTeal,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Camera preview area',
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Tap Scan to capture an invoice image.',
                                        style: TextStyle(
                                          color: AppColors.textPrimary.withValues(
                                            alpha: 0.55,
                                          ),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                              const _CropFrameOverlay(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_capturedImage != null) ...[
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Selected Image',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getImageName(_capturedImage!),
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
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
            if (_capturedImage != null && _isProcessingImage) ...[
              const SizedBox(height: 16),
              const Row(
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
            ],
            if (_capturedImage != null &&
                !_isProcessingImage &&
                _recognitionError != null) ...[
              const SizedBox(height: 16),
              Text(
                _recognitionError!,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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
              widthFactor: 0.82,
              heightFactor: 0.72,
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
          Positioned(
            left: 0,
            right: 0,
            bottom: 12,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Align invoice inside frame',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
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
