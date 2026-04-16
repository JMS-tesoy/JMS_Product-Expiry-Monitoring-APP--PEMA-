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
    final imageUrl = product.thumbnailUrl;
    final fallbackIcon = Icon(
      LucideIcons.package,
      size: iconSize,
      color: fallbackColor,
    );

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: fallbackColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: imageUrl == null
          ? fallbackIcon
          : ColoredBox(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => fallbackIcon,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return fallbackIcon;
                  },
                ),
              ),
            ),
    );
  }
}
