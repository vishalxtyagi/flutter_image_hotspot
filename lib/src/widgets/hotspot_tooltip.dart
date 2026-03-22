import 'package:flutter/material.dart';
import '../models/hotspot_model.dart';

/// A smart popover / tooltip widget for [HotspotModel].
///
/// Positions itself above, below, or beside the hotspot while staying
/// within the [boundary] rect.  Renders the hotspot's [HotspotModel.tooltipWidget]
/// when available, falling back to a styled text bubble using
/// [HotspotModel.tooltip].
class HotspotTooltip extends StatefulWidget {
  /// The hotspot whose tooltip should be displayed.
  final HotspotModel hotspot;

  /// Screen-space centre of the hotspot (used for positioning).
  final Offset hotspotCenter;

  /// Approximate radius / half-size of the hotspot indicator in pixels
  /// (used to offset the tooltip from the centre).
  final double hotspotRadius;

  /// The bounding [Rect] that the tooltip must stay within.
  final Rect boundary;

  /// Called when the tooltip is dismissed by tapping outside it.
  final VoidCallback? onDismiss;

  /// Creates a [HotspotTooltip].
  const HotspotTooltip({
    super.key,
    required this.hotspot,
    required this.hotspotCenter,
    required this.hotspotRadius,
    required this.boundary,
    this.onDismiss,
  });

  @override
  State<HotspotTooltip> createState() => _HotspotTooltipState();
}

class _HotspotTooltipState extends State<HotspotTooltip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Layout
  // ---------------------------------------------------------------------------

  /// Maximum tooltip width in logical pixels.
  static const double _maxWidth = 200.0;

  /// Padding around the tooltip content.
  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 8,
  );

  /// Preferred gap between the hotspot edge and the tooltip.
  static const double _gap = 8.0;

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: _SmartPositionedTooltip(
        center: widget.hotspotCenter,
        hotspotRadius: widget.hotspotRadius,
        boundary: widget.boundary,
        maxWidth: _maxWidth,
        gap: _gap,
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final content = widget.hotspot.tooltipWidget ??
        Padding(
          padding: _padding,
          child: Text(
            widget.hotspot.tooltip ?? '',
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        );

    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: content,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Internal smart-positioning layout widget
// ---------------------------------------------------------------------------

class _SmartPositionedTooltip extends SingleChildRenderObjectWidget {
  final Offset center;
  final double hotspotRadius;
  final Rect boundary;
  final double maxWidth;
  final double gap;

  const _SmartPositionedTooltip({
    required this.center,
    required this.hotspotRadius,
    required this.boundary,
    required this.maxWidth,
    required this.gap,
    required Widget child,
  }) : super(child: child);

  @override
  _SmartPositionRenderBox createRenderObject(BuildContext context) =>
      _SmartPositionRenderBox(
        center: center,
        hotspotRadius: hotspotRadius,
        boundary: boundary,
        gap: gap,
      );

  @override
  void updateRenderObject(
      BuildContext context, _SmartPositionRenderBox renderObject) {
    renderObject
      ..center = center
      ..hotspotRadius = hotspotRadius
      ..boundary = boundary
      ..gap = gap;
  }
}

class _SmartPositionRenderBox extends RenderShiftedBox {
  Offset center;
  double hotspotRadius;
  Rect boundary;
  double gap;

  _SmartPositionRenderBox({
    required this.center,
    required this.hotspotRadius,
    required this.boundary,
    required this.gap,
  }) : super(null);

  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      size = Size.zero;
      return;
    }

    child.layout(
      BoxConstraints(maxWidth: _HotspotTooltipState._maxWidth),
      parentUsesSize: true,
    );

    final cs = child.size;
    size = constraints.biggest;

    // Try positions in priority order: above, below, right, left.
    final candidates = [
      Offset(center.dx - cs.width / 2,
          center.dy - hotspotRadius - gap - cs.height), // above
      Offset(center.dx - cs.width / 2,
          center.dy + hotspotRadius + gap), // below
      Offset(center.dx + hotspotRadius + gap,
          center.dy - cs.height / 2), // right
      Offset(center.dx - hotspotRadius - gap - cs.width,
          center.dy - cs.height / 2), // left
    ];

    Offset best = candidates.first;
    for (final candidate in candidates) {
      final tooltipRect = candidate & cs;
      if (boundary.containsRect(tooltipRect)) {
        best = candidate;
        break;
      }
    }

    // Clamp to boundary as a last resort.
    double left = best.dx.clamp(boundary.left, boundary.right - cs.width);
    double top = best.dy.clamp(boundary.top, boundary.bottom - cs.height);

    (child.parentData as BoxParentData).offset = Offset(left, top);
  }
}

extension on Rect {
  bool containsRect(Rect other) =>
      contains(other.topLeft) && contains(other.bottomRight);
}
