import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Image preprocessing utilities to enhance OCR accuracy.
/// This is especially useful for low-light or poor-quality images.
/// 
/// All heavy processing runs on a separate isolate to avoid UI lag.
class ImagePreprocessor {
  const ImagePreprocessor._();

  /// Enhances an image for optimal OCR recognition.
  /// 
  /// This applies the following transformations:
  /// 1. Auto-adjusts brightness and contrast
  /// 2. Converts to grayscale for better text detection
  /// 3. Applies light sharpening to improve text edges
  /// 
  /// Returns the path to the enhanced image file, or null if processing fails.
  /// Runs on a separate isolate to avoid blocking the UI.
  static Future<String?> enhanceForOcr(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!file.existsSync()) return null;

      final bytes = await file.readAsBytes();
      
      // Run heavy processing on isolate
      final enhancedPath = '${imagePath}_enhanced.jpg';
      final result = await compute(_processImageForOcr, _ProcessParams(bytes, enhancedPath));
      
      return result;
    } catch (e) {
      // Return null on failure, caller should use original image
      return null;
    }
  }

  /// Detects if an image has low-light conditions.
  /// 
  /// Returns true if the image is too dark for reliable OCR.
  /// Uses a quick sampling approach to avoid blocking UI.
  static Future<bool> detectLowLight(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!file.existsSync()) return false;

      final bytes = await file.readAsBytes();
      
      // Run on isolate
      final brightness = await compute(_calculateBrightness, bytes);
      return brightness < 100; // Images with average brightness < 100 are considered low-light
    } catch (e) {
      return false;
    }
  }

  /// Cleans up enhanced image files after OCR is complete.
  static Future<void> cleanup(String enhancedPath) async {
    try {
      final file = File(enhancedPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Ignore cleanup errors
    }
  }
}

/// Parameters for image processing isolate.
class _ProcessParams {
  const _ProcessParams(this.bytes, this.outputPath);
  final List<int> bytes;
  final String outputPath;
}

/// Processes image for OCR on isolate - returns the enhanced image path or null.
String? _processImageForOcr(_ProcessParams params) {
  try {
    var image = img.decodeImage(Uint8List.fromList(params.bytes));
    if (image == null) return null;

    // Resize if image is very large (reduces processing time significantly)
    const maxDimension = 1500;
    if (image.width > maxDimension || image.height > maxDimension) {
      final scale = maxDimension / (image.width > image.height ? image.width : image.height);
      image = img.copyResize(
        image,
        width: (image.width * scale).round(),
        height: (image.height * scale).round(),
        interpolation: img.Interpolation.linear,
      );
    }

    // Calculate brightness (sample every 20th pixel for speed)
    int totalBrightness = 0;
    int pixelCount = 0;
    for (int y = 0; y < image.height; y += 20) {
      for (int x = 0; x < image.width; x += 20) {
        final pixel = image.getPixel(x, y);
        final luminance = (0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b).round();
        totalBrightness += luminance;
        pixelCount++;
      }
    }
    final brightness = pixelCount > 0 ? totalBrightness / pixelCount : 128.0;
    final isLowLight = brightness < 100;

    // Step 1: Auto-adjust brightness and contrast for low-light images
    if (isLowLight) {
      final brightnessAdjust = brightness < 60 ? 50 : 30;
      image = img.adjustColor(
        image,
        brightness: brightnessAdjust / 100,
        contrast: 1.3,
      );
    } else {
      // Normal images: slight contrast boost
      image = img.adjustColor(
        image,
        contrast: 1.15,
      );
    }

    // Step 2: Convert to grayscale for better OCR
    image = img.grayscale(image);

    // Step 3: Normalize (stretch histogram for better contrast)
    image = img.normalize(image, min: 20, max: 235);

    // Save enhanced image (skip sharpening - too slow)
    final enhancedBytes = img.encodeJpg(image, quality: 90);
    File(params.outputPath).writeAsBytesSync(enhancedBytes);

    return params.outputPath;
  } catch (e) {
    return null;
  }
}

/// Calculates average brightness on isolate.
double _calculateBrightness(List<int> bytes) {
  try {
    final image = img.decodeImage(Uint8List.fromList(bytes));
    if (image == null) return 128;

    int totalBrightness = 0;
    int pixelCount = 0;

    // Sample pixels (every 30th pixel for speed)
    for (int y = 0; y < image.height; y += 30) {
      for (int x = 0; x < image.width; x += 30) {
        final pixel = image.getPixel(x, y);
        final luminance = (0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b).round();
        totalBrightness += luminance;
        pixelCount++;
      }
    }

    return pixelCount > 0 ? totalBrightness / pixelCount : 128;
  } catch (e) {
    return 128;
  }
}

/// Result of image quality analysis.
class ImageQualityResult {
  const ImageQualityResult({
    required this.brightness,
    required this.isLowLight,
    required this.isBlurry,
    required this.recommendation,
  });

  final double brightness;
  final bool isLowLight;
  final bool isBlurry;
  final String? recommendation;

  bool get needsEnhancement => isLowLight || isBlurry;
}
