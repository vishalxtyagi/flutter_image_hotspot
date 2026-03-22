import 'package:flutter/material.dart';
import '../models/hotspot_model.dart';

/// [CustomPainter] that draws the default visual indicator for hotspots that
/// do not supply a custom [HotspotModel.icon].
///
/// Supports [HotspotShape.circle], [HotspotShape.rectangle], and
/// [HotspotShape.polygon].
class HotspotPainter extends CustomPainter {
  /// The hotspot to paint.
  final HotspotModel hotspot;

  /// Whether the hotspot is currently active (tapped / hovered).
  final bool isActive;

  /// The rendered image rect within the canvas.
  final Rect imageRect;

  /// Creates a [HotspotPainter].
  const HotspotPainter({
    required this.hotspot,
    required this.imageRect,
    this.isActive = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (hotspot.icon != null) return; // icon hotspots use widget overlays

    final center = Offset(
      imageRect.left + hotspot.dx * imageRect.width,
      imageRect.top + hotspot.dy * imageRect.height,
    );

    final fillColor = isActive
        ? hotspot.color.withValues(alpha: 0.75)
        : hotspot.color.withValues(alpha: 0.45);

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = hotspot.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    switch (hotspot.shape) {
      case HotspotShape.circle:
        final radius = hotspot.radius * imageRect.width;
        canvas.drawCircle(center, radius, fillPaint);
        canvas.drawCircle(center, radius, borderPaint);

      case HotspotShape.rectangle:
        final w = hotspot.width * imageRect.width;
        final h = hotspot.height * imageRect.height;
        final rect = Rect.fromCenter(center: center, width: w, height: h);
        final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));
        canvas.drawRRect(rrect, fillPaint);
        canvas.drawRRect(rrect, borderPaint);

      case HotspotShape.polygon:
        if (hotspot.points.length < 3) break;
        final screenPts = hotspot.points
            .map((p) => Offset(
                  imageRect.left + p.dx * imageRect.width,
                  imageRect.top + p.dy * imageRect.height,
                ))
            .toList();
        final path = Path()
          ..moveTo(screenPts.first.dx, screenPts.first.dy);
        for (final p in screenPts.skip(1)) {
          path.lineTo(p.dx, p.dy);
        }
        path.close();
        canvas.drawPath(path, fillPaint);
        canvas.drawPath(path, borderPaint);
    }
  }

  @override
  bool shouldRepaint(HotspotPainter oldDelegate) =>
      oldDelegate.hotspot != hotspot ||
      oldDelegate.isActive != isActive ||
      oldDelegate.imageRect != imageRect;

  /// Returns a [Path] representing this hotspot's shape in screen coordinates.
  ///
  /// Used for custom clip regions.
  Path buildPath() {
    final center = Offset(
      imageRect.left + hotspot.dx * imageRect.width,
      imageRect.top + hotspot.dy * imageRect.height,
    );

    switch (hotspot.shape) {
      case HotspotShape.circle:
        final radius = hotspot.radius * imageRect.width;
        return Path()..addOval(Rect.fromCircle(center: center, radius: radius));

      case HotspotShape.rectangle:
        final w = hotspot.width * imageRect.width;
        final h = hotspot.height * imageRect.height;
        return Path()
          ..addRRect(RRect.fromRectAndRadius(
            Rect.fromCenter(center: center, width: w, height: h),
            const Radius.circular(4),
          ));

      case HotspotShape.polygon:
        if (hotspot.points.length < 3) return Path();
        final screenPts = hotspot.points
            .map((p) => Offset(
                  imageRect.left + p.dx * imageRect.width,
                  imageRect.top + p.dy * imageRect.height,
                ))
            .toList();
        final path = Path()
          ..moveTo(screenPts.first.dx, screenPts.first.dy);
        for (final p in screenPts.skip(1)) {
          path.lineTo(p.dx, p.dy);
        }
        return path..close();
    }
  }
}
