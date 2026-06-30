/// A highly scalable, extensible interactive image engine for Flutter.
///
/// ## Quick start
///
/// ```dart
/// import 'package:image_hotspot/image_hotspot.dart';
///
/// ImageHotspot(
///   imagePath: 'assets/map.jpg',
///   hotspots: [
///     HotspotModel(
///       dx: 0.5,
///       dy: 0.3,
///       tooltip: 'Centre',
///       onTap: () => print('tapped'),
///     ),
///   ],
/// )
/// ```
///
/// See also:
/// * [HotspotModel] — the core data model.
/// * [HotspotShape] — supported hotspot shapes (circle, rectangle, polygon).
/// * [CoordinateEngine] — responsive coordinate mapping utilities.
/// * [HotspotEditor] — interactive editor for adding / moving hotspots.
library image_hotspot;

export 'src/models/hotspot_model.dart';
export 'src/engine/coordinate_engine.dart';
export 'src/widgets/image_hotspot_widget.dart';
export 'src/widgets/hotspot_painter.dart';
export 'src/widgets/hotspot_tooltip.dart';
export 'src/editor/hotspot_editor.dart';

