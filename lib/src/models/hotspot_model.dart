import 'package:flutter/material.dart';

/// The shape type for a [HotspotModel].
enum HotspotShape {
  /// A circular hotspot defined by [HotspotModel.radius].
  circle,

  /// A rectangular hotspot defined by [HotspotModel.width] and
  /// [HotspotModel.height].
  rectangle,

  /// A custom polygon hotspot defined by [HotspotModel.points].
  polygon,
}

/// Represents an interactive hotspot positioned on an image using
/// **relative coordinates** (values between `0.0` and `1.0`).
///
/// A relative coordinate of `(0.0, 0.0)` maps to the top-left corner of
/// the image, and `(1.0, 1.0)` maps to the bottom-right corner.
///
/// Example:
/// ```dart
/// HotspotModel(
///   dx: 0.5,
///   dy: 0.3,
///   tooltip: 'Centre of the image',
///   onTap: () => print('tapped'),
/// )
/// ```
class HotspotModel {
  /// Relative horizontal position in the range `[0.0, 1.0]`.
  ///
  /// `0.0` = left edge, `1.0` = right edge.
  final double dx;

  /// Relative vertical position in the range `[0.0, 1.0]`.
  ///
  /// `0.0` = top edge, `1.0` = bottom edge.
  final double dy;

  /// The visual shape of the hotspot. Defaults to [HotspotShape.circle].
  final HotspotShape shape;

  /// Radius expressed as a fraction of the rendered image **width**.
  ///
  /// Only used when [shape] is [HotspotShape.circle]. Defaults to `0.05`
  /// (5 % of the image width).
  final double radius;

  /// Width expressed as a fraction of the rendered image width.
  ///
  /// Only used when [shape] is [HotspotShape.rectangle]. Defaults to `0.1`.
  final double width;

  /// Height expressed as a fraction of the rendered image height.
  ///
  /// Only used when [shape] is [HotspotShape.rectangle]. Defaults to `0.1`.
  final double height;

  /// Polygon vertices expressed as relative [Offset]s (`dx` / `dy` each
  /// in `[0.0, 1.0]`).
  ///
  /// Only used when [shape] is [HotspotShape.polygon]. Requires at least
  /// three points.
  final List<Offset> points;

  /// Called when the hotspot is tapped.
  final VoidCallback? onTap;

  /// Called when the hotspot is long-pressed.
  final VoidCallback? onLongPress;

  /// Called when the pointer enters or exits the hotspot (web / desktop).
  ///
  /// Receives `true` when the pointer enters and `false` when it exits.
  final ValueChanged<bool>? onHover;

  /// Plain-text tooltip shown when the hotspot is activated.
  ///
  /// Ignored when [tooltipWidget] is provided.
  final String? tooltip;

  /// Custom widget used as a popover when the hotspot is activated.
  ///
  /// When provided, [tooltip] is ignored.
  final Widget? tooltipWidget;

  /// Custom widget rendered as the hotspot icon / marker.
  ///
  /// When provided, the default shape painter is not used.
  final Widget? icon;

  /// Fill / border colour of the default shape painter.
  ///
  /// Has no effect when [icon] is provided.
  final Color color;

  /// Optional identifier, useful for JSON round-trips and editor mode.
  final String? id;

  /// Arbitrary metadata that travels with the hotspot.
  final Map<String, dynamic>? metadata;

  /// Creates a [HotspotModel].
  ///
  /// [dx] and [dy] must be in the range `[0.0, 1.0]`.
  const HotspotModel({
    required this.dx,
    required this.dy,
    this.shape = HotspotShape.circle,
    this.radius = 0.05,
    this.width = 0.1,
    this.height = 0.1,
    this.points = const [],
    this.onTap,
    this.onLongPress,
    this.onHover,
    this.tooltip,
    this.tooltipWidget,
    this.icon,
    this.color = Colors.red,
    this.id,
    this.metadata,
  });

  // ---------------------------------------------------------------------------
  // JSON
  // ---------------------------------------------------------------------------

  /// Deserialises a [HotspotModel] from [json].
  ///
  /// Required keys: `dx`, `dy`.
  ///
  /// Optional keys: `shape`, `radius`, `width`, `height`, `points`,
  /// `tooltip`, `color` (ARGB int), `id`, `metadata`.
  factory HotspotModel.fromJson(Map<String, dynamic> json) {
    final shapeStr = json['shape'] as String? ?? 'circle';
    final shape = HotspotShape.values.firstWhere(
      (s) => s.name == shapeStr,
      orElse: () => HotspotShape.circle,
    );

    final rawPoints = json['points'];
    final List<Offset> points = rawPoints is List
        ? rawPoints.map((p) {
            final map = p as Map<String, dynamic>;
            return Offset(
              (map['x'] as num).toDouble(),
              (map['y'] as num).toDouble(),
            );
          }).toList()
        : const [];

    Color color = Colors.red;
    if (json['color'] is int) {
      color = Color(json['color'] as int);
    }

    return HotspotModel(
      dx: (json['dx'] as num).toDouble(),
      dy: (json['dy'] as num).toDouble(),
      shape: shape,
      radius: (json['radius'] as num?)?.toDouble() ?? 0.05,
      width: (json['width'] as num?)?.toDouble() ?? 0.1,
      height: (json['height'] as num?)?.toDouble() ?? 0.1,
      points: points,
      tooltip: json['tooltip'] as String?,
      color: color,
      id: json['id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Serialises this [HotspotModel] to a JSON-compatible [Map].
  ///
  /// Note: widget callbacks ([onTap], [onLongPress], [onHover], [icon],
  /// [tooltipWidget]) are not serialised.
  Map<String, dynamic> toJson() => {
        'dx': dx,
        'dy': dy,
        'shape': shape.name,
        'radius': radius,
        'width': width,
        'height': height,
        'points': points.map((p) => {'x': p.dx, 'y': p.dy}).toList(),
        if (tooltip != null) 'tooltip': tooltip,
        'color': color.value,
        if (id != null) 'id': id,
        if (metadata != null) 'metadata': metadata,
      };

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  /// Returns a copy of this [HotspotModel] with the given fields replaced.
  HotspotModel copyWith({
    double? dx,
    double? dy,
    HotspotShape? shape,
    double? radius,
    double? width,
    double? height,
    List<Offset>? points,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    ValueChanged<bool>? onHover,
    String? tooltip,
    Widget? tooltipWidget,
    Widget? icon,
    Color? color,
    String? id,
    Map<String, dynamic>? metadata,
  }) {
    return HotspotModel(
      dx: dx ?? this.dx,
      dy: dy ?? this.dy,
      shape: shape ?? this.shape,
      radius: radius ?? this.radius,
      width: width ?? this.width,
      height: height ?? this.height,
      points: points ?? this.points,
      onTap: onTap ?? this.onTap,
      onLongPress: onLongPress ?? this.onLongPress,
      onHover: onHover ?? this.onHover,
      tooltip: tooltip ?? this.tooltip,
      tooltipWidget: tooltipWidget ?? this.tooltipWidget,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      id: id ?? this.id,
      metadata: metadata ?? this.metadata,
    );
  }

  // ---------------------------------------------------------------------------
  // Hit testing
  // ---------------------------------------------------------------------------

  /// Returns `true` if screen point [hit] lies within this hotspot given the
  /// rendered [imageRect].
  bool hitTest(Offset hit, Rect imageRect) {
    final center = Offset(
      imageRect.left + dx * imageRect.width,
      imageRect.top + dy * imageRect.height,
    );

    switch (shape) {
      case HotspotShape.circle:
        final r = radius * imageRect.width;
        return (hit - center).distance <= r;

      case HotspotShape.rectangle:
        final w = width * imageRect.width;
        final h = height * imageRect.height;
        return Rect.fromCenter(center: center, width: w, height: h)
            .contains(hit);

      case HotspotShape.polygon:
        if (points.length < 3) return false;
        final screenPts = points
            .map((p) => Offset(
                  imageRect.left + p.dx * imageRect.width,
                  imageRect.top + p.dy * imageRect.height,
                ))
            .toList();
        return _pointInPolygon(hit, screenPts);
    }
  }

  /// Ray-casting algorithm for point-in-polygon test.
  bool _pointInPolygon(Offset point, List<Offset> polygon) {
    bool inside = false;
    int j = polygon.length - 1;
    for (int i = 0; i < polygon.length; j = i++) {
      if (((polygon[i].dy > point.dy) != (polygon[j].dy > point.dy)) &&
          (point.dx <
              (polygon[j].dx - polygon[i].dx) *
                      (point.dy - polygon[i].dy) /
                      (polygon[j].dy - polygon[i].dy) +
                  polygon[i].dx)) {
        inside = !inside;
      }
    }
    return inside;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HotspotModel &&
          runtimeType == other.runtimeType &&
          dx == other.dx &&
          dy == other.dy &&
          shape == other.shape &&
          id == other.id;

  @override
  int get hashCode => Object.hash(dx, dy, shape, id);
}

// ---------------------------------------------------------------------------
// Legacy compatibility shim
// ---------------------------------------------------------------------------

/// Legacy hotspot class retained for source-level compatibility.
///
/// **Deprecated** — migrate to [HotspotModel], which uses relative
/// coordinates (`dx` / `dy` in the range `0.0` – `1.0`) instead of
/// absolute pixel values.
///
/// Migration example — if your image is 300 × 200 px and a hotspot is at
/// pixel position (90, 60), replace:
/// ```dart
/// // old
/// Hotspot(x: 90, y: 60, onTap: cb)
/// // new
/// HotspotModel(dx: 0.3, dy: 0.3, onTap: cb)
/// ```
@Deprecated('Use HotspotModel with relative coordinates (0.0–1.0).')
class Hotspot extends HotspotModel {
  /// Absolute pixel x-coordinate (deprecated).
  ///
  /// Stored as-is; the rendering engine no longer uses raw pixel positions.
  final double x;

  /// Absolute pixel y-coordinate (deprecated).
  final double y;

  /// The size of the default hotspot icon in logical pixels (deprecated).
  ///
  /// Use [HotspotModel.radius] with a relative value instead.
  final double size;

  /// Creates a legacy [Hotspot].
  ///
  /// [x] and [y] are **absolute pixel coordinates** and are stored for
  /// reference only.  The [HotspotModel] superclass receives `dx` / `dy`
  /// values of `0.0` as placeholders; update your code to use [HotspotModel]
  /// with proper relative coordinates.
  @Deprecated('Use HotspotModel with relative coordinates (0.0–1.0).')
  Hotspot({
    required this.x,
    required this.y,
    VoidCallback? onTap,
    String? tooltip,
    Widget? icon,
    Color color = Colors.red,
    this.size = 24.0,
  })  : assert(x >= 0, 'x must be non-negative'),
        assert(y >= 0, 'y must be non-negative'),
        super(
          // Absolute pixels are passed as-is; callers should migrate to
          // HotspotModel with relative coordinates.
          dx: x,
          dy: y,
          onTap: onTap,
          tooltip: tooltip,
          icon: icon,
          color: color,
          radius: size / 2,
        );
}
