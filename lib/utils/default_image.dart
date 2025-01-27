import 'package:flutter/material.dart';

class DefaultImage extends StatelessWidget {
  final String? imageUrl; // The image URL, which can be null
  final String placeholderPath; // The placeholder image path
  final double? width; // Image width
  final double? height; // Image height
  final BoxFit fit; // Image fit mode

  const DefaultImage({
    Key? key,
    required this.imageUrl,
    required this.placeholderPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if the URL is null or empty, fallback to placeholder
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Image.asset(
        placeholderPath,
        width: width,
        height: height,
        fit: fit,
      );
    }

    // Return a network image with error and loading handling
    return Image.network(
      imageUrl!,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          placeholderPath,
          width: width,
          height: height,
          fit: fit,
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    (loadingProgress.expectedTotalBytes ?? 1)
                : null,
          ),
        );
      },
    );
  }
}
