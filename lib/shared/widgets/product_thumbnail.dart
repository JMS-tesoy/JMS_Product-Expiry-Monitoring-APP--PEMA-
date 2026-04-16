import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../data/product_images.dart';
import '../models/product_model.dart';

class ProductThumbnail extends StatelessWidget {
  final ProductModel product;
  final double size;
  final double borderRadius;
  final Color fallbackColor;
  final double iconSize;

  const ProductThumbnail({
    super.key,
    required this.product,
    required this.fallbackColor,
    this.size = 42,
    this.borderRadius = 14,
    this.iconSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: fallbackColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ColoredBox(
        color: Colors.white,
        child: _PrecachedThumbnailImage(
          product: product,
          fallbackColor: fallbackColor,
          iconSize: iconSize,
          padding: const EdgeInsets.all(3),
        ),
      ),
    );
  }
}

class ProductThumbnailPanel extends StatelessWidget {
  final ProductModel product;
  final double borderRadius;
  final Color fallbackColor;
  final double iconSize;

  const ProductThumbnailPanel({
    super.key,
    required this.product,
    required this.fallbackColor,
    this.borderRadius = 14,
    this.iconSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: _PrecachedThumbnailImage(
        product: product,
        fallbackColor: fallbackColor,
        iconSize: iconSize,
      ),
    );
  }
}

class _PrecachedThumbnailImage extends StatefulWidget {
  final ProductModel product;
  final Color fallbackColor;
  final double iconSize;
  final EdgeInsetsGeometry padding;

  const _PrecachedThumbnailImage({
    required this.product,
    required this.fallbackColor,
    required this.iconSize,
    this.padding = EdgeInsets.zero,
  });

  @override
  State<_PrecachedThumbnailImage> createState() =>
      _PrecachedThumbnailImageState();
}

class _PrecachedThumbnailImageState extends State<_PrecachedThumbnailImage> {
  String? _imageUrl;
  NetworkImage? _imageProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncImageProvider();
  }

  @override
  void didUpdateWidget(covariant _PrecachedThumbnailImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product.name != widget.product.name) {
      _syncImageProvider();
    }
  }

  void _syncImageProvider() {
    final nextImageUrl = widget.product.thumbnailUrl;
    if (nextImageUrl == _imageUrl) return;

    _imageUrl = nextImageUrl;
    _imageProvider = nextImageUrl == null ? null : NetworkImage(nextImageUrl);

    final imageProvider = _imageProvider;
    if (imageProvider != null) {
      precacheImage(imageProvider, context).catchError((_) {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final fallbackIcon = Center(
      child: Icon(
        LucideIcons.package,
        size: widget.iconSize,
        color: widget.fallbackColor,
      ),
    );
    final imageProvider = _imageProvider;

    if (imageProvider == null) return fallbackIcon;

    return Padding(
      padding: widget.padding,
      child: Image(
        image: imageProvider,
        fit: BoxFit.contain,
        gaplessPlayback: true,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) return child;
          return fallbackIcon;
        },
        errorBuilder: (context, error, stackTrace) => fallbackIcon,
      ),
    );
  }
}
