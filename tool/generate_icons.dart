// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;

class CArcConfig {
  final double cx;
  final double cy;
  final double rx;
  final double ry;
  final double thickness;
  final double openAngleStart; // In radians, start of the opening
  final double openAngleEnd;   // In radians, end of the opening
  final int r;
  final int g;
  final int b;

  CArcConfig({
    required this.cx,
    required this.cy,
    required this.rx,
    required this.ry,
    required this.thickness,
    required this.openAngleStart,
    required this.openAngleEnd,
    required this.r,
    required this.g,
    required this.b,
  });
}

void main() {
  const int size = 1024;
  final master = img.Image(width: size, height: size, numChannels: 4);

  // Clear with completely transparent pixels (no background color at all)
  img.fill(master, color: img.ColorRgba8(0, 0, 0, 0));

  final arcs = [
    // 1. Top C (Wide upper funnel of tornado)
    CArcConfig(
      cx: 512,
      cy: 310,
      rx: 340,
      ry: 185,
      thickness: 80,
      openAngleStart: -0.95, // ~ -54 deg (opening on right)
      openAngleEnd: 0.95,    // ~ +54 deg
      r: 168, g: 224, b: 133, // #A8E085
    ),
    // 2. Middle C (Mid funnel of tornado)
    CArcConfig(
      cx: 500,
      cy: 545,
      rx: 235,
      ry: 135,
      thickness: 68,
      openAngleStart: -0.90,
      openAngleEnd: 0.90,
      r: 147, g: 197, b: 114, // #93C572
    ),
    // 3. Bottom C (Vortex tip of tornado)
    CArcConfig(
      cx: 488,
      cy: 760,
      rx: 135,
      ry: 82,
      thickness: 52,
      openAngleStart: -0.85,
      openAngleEnd: 0.85,
      r: 109, g: 168, b: 82,  // #6DA852
    ),
  ];

  // Render each C with smooth anti-aliasing and rounded endcaps
  for (final arc in arcs) {
    _renderCArc(master, arc);
  }

  // Ensure directories exist
  Directory('assets/icons').createSync(recursive: true);
  Directory('android/app/src/main/res/mipmap-mdpi').createSync(recursive: true);
  Directory('android/app/src/main/res/mipmap-hdpi').createSync(recursive: true);
  Directory('android/app/src/main/res/mipmap-xhdpi').createSync(recursive: true);
  Directory('android/app/src/main/res/mipmap-xxhdpi').createSync(recursive: true);
  Directory('android/app/src/main/res/mipmap-xxxhdpi').createSync(recursive: true);
  Directory('web/icons').createSync(recursive: true);

  // 1. Master asset
  File('assets/icons/tempest_logo.png').writeAsBytesSync(img.encodePng(master));
  print('Generated assets/icons/tempest_logo.png');

  // 2. Android mipmaps
  final mipmaps = {
    'android/app/src/main/res/mipmap-mdpi/ic_launcher.png': 48,
    'android/app/src/main/res/mipmap-hdpi/ic_launcher.png': 72,
    'android/app/src/main/res/mipmap-xhdpi/ic_launcher.png': 96,
    'android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png': 144,
    'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png': 192,
  };
  for (final entry in mipmaps.entries) {
    final resized = img.copyResize(master, width: entry.value, height: entry.value, interpolation: img.Interpolation.cubic);
    File(entry.key).writeAsBytesSync(img.encodePng(resized));
    print('Generated ${entry.key}');
  }

  // 3. Web icons
  final webIcons = {
    'web/favicon.png': 32,
    'web/icons/Icon-192.png': 192,
    'web/icons/Icon-512.png': 512,
    'web/icons/Icon-maskable-192.png': 192,
    'web/icons/Icon-maskable-512.png': 512,
  };
  for (final entry in webIcons.entries) {
    final resized = img.copyResize(master, width: entry.value, height: entry.value, interpolation: img.Interpolation.cubic);
    File(entry.key).writeAsBytesSync(img.encodePng(resized));
    print('Generated ${entry.key}');
  }
}

void _renderCArc(img.Image image, CArcConfig arc) {
  final halfThick = arc.thickness / 2.0;

  // Compute endcap centers
  final cap1X = arc.cx + arc.rx * cos(arc.openAngleStart);
  final cap1Y = arc.cy + arc.ry * sin(arc.openAngleStart);
  final cap2X = arc.cx + arc.rx * cos(arc.openAngleEnd);
  final cap2Y = arc.cy + arc.ry * sin(arc.openAngleEnd);

  // Bounding box for this arc
  final minX = max(0, (arc.cx - arc.rx - arc.thickness - 2).floor());
  final maxX = min(image.width - 1, (arc.cx + arc.rx + arc.thickness + 2).ceil());
  final minY = max(0, (arc.cy - arc.ry - arc.thickness - 2).floor());
  final maxY = min(image.height - 1, (arc.cy + arc.ry + arc.thickness + 2).ceil());

  for (int y = minY; y <= maxY; y++) {
    for (int x = minX; x <= maxX; x++) {
      final dx = x - arc.cx;
      final dy = y - arc.cy;
      final angle = atan2(dy, dx); // -pi to pi

      // Check distance to elliptical ring
      final u = dx / arc.rx;
      final v = dy / arc.ry;
      final rNorm = sqrt(u * u + v * v);

      double minDistance = double.infinity;

      // Is it inside the 'C' body (outside the opening)?
      final inOpening = (angle >= arc.openAngleStart && angle <= arc.openAngleEnd);

      if (!inOpening && rNorm > 0.0001) {
        // Approximate distance to ellipse perimeter
        final closestX = arc.cx + (arc.rx * u / rNorm);
        final closestY = arc.cy + (arc.ry * v / rNorm);
        final distToPerimeter = sqrt((x - closestX) * (x - closestX) + (y - closestY) * (y - closestY));
        minDistance = min(minDistance, distToPerimeter);
      }

      // Check distance to endcaps
      final dCap1 = sqrt((x - cap1X) * (x - cap1X) + (y - cap1Y) * (y - cap1Y));
      final dCap2 = sqrt((x - cap2X) * (x - cap2X) + (y - cap2Y) * (y - cap2Y));
      minDistance = min(minDistance, min(dCap1, dCap2));

      if (minDistance <= halfThick + 1.5) {
        // Anti-aliased alpha
        final alphaFactor = ((halfThick + 1.0 - minDistance) / 1.5).clamp(0.0, 1.0);
        if (alphaFactor > 0) {
          final existingPixel = image.getPixel(x, y);
          final existingA = existingPixel.a / 255.0;
          final newA = alphaFactor;
          final blendedA = (newA + existingA * (1.0 - newA)).clamp(0.0, 1.0);

          if (blendedA > 0) {
            final blendedR = ((arc.r * newA + existingPixel.r * existingA * (1.0 - newA)) / blendedA).round();
            final blendedG = ((arc.g * newA + existingPixel.g * existingA * (1.0 - newA)) / blendedA).round();
            final blendedB = ((arc.b * newA + existingPixel.b * existingA * (1.0 - newA)) / blendedA).round();

            image.setPixelRgba(x, y, blendedR, blendedG, blendedB, (blendedA * 255).round());
          }
        }
      }
    }
  }
}
