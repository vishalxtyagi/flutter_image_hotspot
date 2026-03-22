import 'package:flutter/material.dart';

import '../engine/coordinate_engine.dart';
import '../models/hotspot_model.dart';
import '../widgets/hotspot_painter.dart';

// ---------------------------------------------------------------------------
// HotspotEditor
// ---------------------------------------------------------------------------

/// An interactive editor that lets users add, drag, and delete [HotspotModel]s
/// on an image at runtime.
///
/// ## Usage
///
/// ```dart
/// HotspotEditor(
///   imagePath: 'assets/map.jpg',
///   initialHotspots: [],
///   onHotspotsChanged: (hotspots) {
///     // Persist updated list.
///     setState(() => _hotspots = hotspots);
///   },
/// )
/// ```
///
/// ## Behaviour
///
/// * **Tap on empty area** → adds a new [HotspotModel] at that position.
/// * **Drag a hotspot** → repositions it.
/// * **Tap a hotspot** → shows a delete button.
/// * Use [defaultShape], [defaultColor], and [defaultRadius] to control the
///   appearance of newly-created hotspots.
class HotspotEditor extends StatefulWidget {
  /// Path to the image asset.
  final String? imagePath;

  /// Custom [ImageProvider] (e.g. [NetworkImage]).  When set, [imagePath] is
  /// ignored.
  final ImageProvider? imageProvider;

  /// Initial list of hotspots displayed when the editor first builds.
  final List<HotspotModel> initialHotspots;

  /// How the image is fitted inside its container.
  final BoxFit imageFit;

  /// Aspect ratio of the source image for accurate coordinate mapping.
  final double? imageAspectRatio;

  /// Shape assigned to newly created hotspots.
  final HotspotShape defaultShape;

  /// Colour assigned to newly created hotspots.
  final Color defaultColor;

  /// Radius (relative, `0.0` – `1.0`) assigned to newly created circle
  /// hotspots.
  final double defaultRadius;

  /// Called whenever the list of hotspots changes (add / move / delete).
  final ValueChanged<List<HotspotModel>>? onHotspotsChanged;

  /// Optional builder for the properties panel shown when a hotspot is
  /// selected.  Receives the selected hotspot and a callback to update it.
  final Widget Function(
    BuildContext context,
    HotspotModel hotspot,
    ValueChanged<HotspotModel> onUpdate,
  )? propertiesPanelBuilder;

  /// Creates a [HotspotEditor].
  const HotspotEditor({
    super.key,
    this.imagePath,
    this.imageProvider,
    this.initialHotspots = const [],
    this.imageFit = BoxFit.cover,
    this.imageAspectRatio,
    this.defaultShape = HotspotShape.circle,
    this.defaultColor = Colors.blue,
    this.defaultRadius = 0.05,
    this.onHotspotsChanged,
    this.propertiesPanelBuilder,
  }) : assert(
          imagePath != null || imageProvider != null,
          'Provide either imagePath or imageProvider.',
        );

  @override
  State<HotspotEditor> createState() => _HotspotEditorState();
}

class _HotspotEditorState extends State<HotspotEditor> {
  late List<HotspotModel> _hotspots;
  HotspotModel? _selected;

  // Drag state
  HotspotModel? _dragging;
  Offset? _dragStart;
  double _dragStartDx = 0;
  double _dragStartDy = 0;

  Size _containerSize = Size.zero;
  late CoordinateEngine _engine;

  @override
  void initState() {
    super.initState();
    _hotspots = List.of(widget.initialHotspots);
    _engine = CoordinateEngine(
      fit: widget.imageFit,
      imageAspectRatio: widget.imageAspectRatio,
    );
  }

  @override
  void didUpdateWidget(HotspotEditor old) {
    super.didUpdateWidget(old);
    if (old.imageFit != widget.imageFit ||
        old.imageAspectRatio != widget.imageAspectRatio) {
      _engine = CoordinateEngine(
        fit: widget.imageFit,
        imageAspectRatio: widget.imageAspectRatio,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Mutation helpers
  // ---------------------------------------------------------------------------

  void _replaceHotspot(HotspotModel old, HotspotModel updated) {
    setState(() {
      final idx = _hotspots.indexOf(old);
      if (idx != -1) _hotspots[idx] = updated;
      if (_selected == old) _selected = updated;
      if (_dragging == old) _dragging = updated;
    });
    widget.onHotspotsChanged?.call(List.unmodifiable(_hotspots));
  }

  void _addHotspot(Offset relPos) {
    final h = HotspotModel(
      dx: relPos.dx.clamp(0.0, 1.0),
      dy: relPos.dy.clamp(0.0, 1.0),
      shape: widget.defaultShape,
      color: widget.defaultColor,
      radius: widget.defaultRadius,
      id: 'hotspot_${DateTime.now().millisecondsSinceEpoch}',
    );
    setState(() => _hotspots.add(h));
    widget.onHotspotsChanged?.call(List.unmodifiable(_hotspots));
  }

  void _deleteHotspot(HotspotModel h) {
    setState(() {
      _hotspots.remove(h);
      if (_selected == h) _selected = null;
    });
    widget.onHotspotsChanged?.call(List.unmodifiable(_hotspots));
  }

  // ---------------------------------------------------------------------------
  // Gesture handlers
  // ---------------------------------------------------------------------------

  HotspotModel? _hotspotAt(Offset screenPos) {
    final imageRect = _engine.imageRect(_containerSize);
    // Iterate in reverse so topmost hotspot wins.
    for (final h in _hotspots.reversed) {
      if (h.hitTest(screenPos, imageRect)) return h;
    }
    return null;
  }

  void _onTapDown(TapDownDetails details) {
    final pos = details.localPosition;
    final hit = _hotspotAt(pos);
    if (hit != null) {
      setState(() => _selected = _selected == hit ? null : hit);
    } else {
      // Add a new hotspot.
      setState(() => _selected = null);
      final rel = _engine.toRelativeOffset(
        screenOffset: pos,
        containerSize: _containerSize,
      );
      _addHotspot(rel);
    }
  }

  void _onPanStart(DragStartDetails details) {
    final pos = details.localPosition;
    final hit = _hotspotAt(pos);
    if (hit != null) {
      _dragging = hit;
      _dragStart = pos;
      _dragStartDx = hit.dx;
      _dragStartDy = hit.dy;
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_dragging == null || _dragStart == null) return;
    final imageRect = _engine.imageRect(_containerSize);
    if (imageRect.isEmpty) return;

    final delta = details.localPosition - _dragStart!;
    final newDx =
        (_dragStartDx + delta.dx / imageRect.width).clamp(0.0, 1.0);
    final newDy =
        (_dragStartDy + delta.dy / imageRect.height).clamp(0.0, 1.0);

    _replaceHotspot(_dragging!, _dragging!.copyWith(dx: newDx, dy: newDy));
  }

  void _onPanEnd(DragEndDetails _) {
    _dragging = null;
    _dragStart = null;
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _buildCanvas()),
        if (_selected != null && widget.propertiesPanelBuilder != null)
          widget.propertiesPanelBuilder!(
            context,
            _selected!,
            (updated) => _replaceHotspot(_selected!, updated),
          ),
      ],
    );
  }

  Widget _buildCanvas() {
    return LayoutBuilder(builder: (context, constraints) {
      _containerSize = Size(constraints.maxWidth, constraints.maxHeight);
      final imageRect = _engine.imageRect(_containerSize);

      return GestureDetector(
        onTapDown: _onTapDown,
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // ── Image ───────────────────────────────────────────────────────
            RepaintBoundary(child: SizedBox.expand(child: _buildImage())),

            // ── Shape hotspots ───────────────────────────────────────────────
            RepaintBoundary(
              child: CustomPaint(
                size: _containerSize,
                painter: _EditorHotspotPainter(
                  hotspots: _hotspots,
                  imageRect: imageRect,
                  selected: _selected,
                  dragging: _dragging,
                ),
              ),
            ),

            // ── Icon hotspots ────────────────────────────────────────────────
            ..._hotspots.where((h) => h.icon != null).map(
                  (h) => _buildIconOverlay(h, imageRect),
                ),

            // ── Delete button for selected hotspot ───────────────────────────
            if (_selected != null) _buildDeleteButton(_selected!, imageRect),

            // ── Instructions overlay ────────────────────────────────────────
            const Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: _EditorHint(),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildImage() {
    final provider =
        widget.imageProvider ?? AssetImage(widget.imagePath!) as ImageProvider;
    return Image(image: provider, fit: widget.imageFit);
  }

  Widget _buildIconOverlay(HotspotModel hotspot, Rect imageRect) {
    final center = Offset(
      imageRect.left + hotspot.dx * imageRect.width,
      imageRect.top + hotspot.dy * imageRect.height,
    );
    return Positioned(
      left: center.dx,
      top: center.dy,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: hotspot.icon!,
      ),
    );
  }

  Widget _buildDeleteButton(HotspotModel hotspot, Rect imageRect) {
    final center = Offset(
      imageRect.left + hotspot.dx * imageRect.width,
      imageRect.top + hotspot.dy * imageRect.height,
    );
    final radius = hotspot.radius * imageRect.width;

    return Positioned(
      left: center.dx + radius,
      top: center.dy - radius - 20,
      child: GestureDetector(
        onTap: () => _deleteHotspot(hotspot),
        child: Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.close, color: Colors.white, size: 16),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Editor CustomPainter
// ---------------------------------------------------------------------------

class _EditorHotspotPainter extends CustomPainter {
  final List<HotspotModel> hotspots;
  final Rect imageRect;
  final HotspotModel? selected;
  final HotspotModel? dragging;

  const _EditorHotspotPainter({
    required this.hotspots,
    required this.imageRect,
    this.selected,
    this.dragging,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final h in hotspots) {
      if (h.icon != null) continue;
      final isActive = h == selected || h == dragging;
      HotspotPainter(hotspot: h, imageRect: imageRect, isActive: isActive)
          .paint(canvas, size);

      if (isActive) {
        _paintSelectionRing(canvas, h);
      }
    }
  }

  void _paintSelectionRing(Canvas canvas, HotspotModel h) {
    final center = Offset(
      imageRect.left + h.dx * imageRect.width,
      imageRect.top + h.dy * imageRect.height,
    );
    final ringPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final r = h.radius * imageRect.width + 6;
    canvas.drawCircle(center, r, ringPaint);
  }

  @override
  bool shouldRepaint(_EditorHotspotPainter old) =>
      old.hotspots != hotspots ||
      old.imageRect != imageRect ||
      old.selected != selected ||
      old.dragging != dragging;
}

// ---------------------------------------------------------------------------
// Editor hint widget
// ---------------------------------------------------------------------------

class _EditorHint extends StatelessWidget {
  const _EditorHint();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Tap to add  •  Drag to move  •  Tap to select  •  ✕ to delete',
          style: TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ),
    );
  }
}
