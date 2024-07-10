import 'package:flutter/material.dart';

/// A widget that displays an image with interactive hotspots.
///
/// This widget allows you to create clickable areas (hotspots) on an image.
/// Each hotspot can have a custom icon, tooltip, and action when tapped.
class ImageHotspot extends StatefulWidget {
  /// The path to the image asset.
  final String imagePath;

  /// A list of [Hotspot] objects representing clickable areas on the image.
  final List<Hotspot> hotspots;

  /// How the image should be inscribed into the space allocated during layout.
  final BoxFit imageFit;

  /// The width of the image. Defaults to [double.infinity].
  final double imageWidth;

  /// The height of the image. Defaults to [double.infinity].
  final double imageHeight;

  /// Whether to show tooltips when a hotspot is tapped. Defaults to true.
  final bool showTooltip;

  /// Creates an [ImageHotspot] widget.
  ///
  /// The [imagePath] and [hotspots] parameters are required.
  const ImageHotspot({
    super.key,
    required this.imagePath,
    required this.hotspots,
    this.imageFit = BoxFit.cover,
    this.imageWidth = double.infinity,
    this.imageHeight = double.infinity,
    this.showTooltip = true,
  });

  @override
  _ImageHotspotState createState() => _ImageHotspotState();
}

class _ImageHotspotState extends State<ImageHotspot> {
  /// The currently active hotspot, if any.
  Hotspot? _activeHotspot;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          widget.imagePath,
          fit: widget.imageFit,
          width: widget.imageWidth,
          height: widget.imageHeight,
        ),
        ...widget.hotspots.map((hotspot) {
          return Positioned(
            left: hotspot.x,
            top: hotspot.y,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _activeHotspot = hotspot;
                });
                hotspot.onTap();
              },
              child: hotspot.icon ?? _defaultHotspotIcon(hotspot),
            ),
          );
        }),
        if (widget.showTooltip && _activeHotspot != null)
          _buildTooltip(context, _activeHotspot!),
      ],
    );
  }

  /// Builds a tooltip for the given [hotspot].
  ///
  /// The tooltip is positioned relative to the hotspot and image size.
  Widget _buildTooltip(BuildContext context, Hotspot hotspot) {
    final tooltipText = hotspot.tooltip ?? 'You tapped here';
    final iconSize = hotspot.size;

    // Calculate tooltip position relative to image size
    final imageSize = Size(widget.imageWidth, widget.imageHeight);
    double tooltipLeft = hotspot.x + iconSize - 8; // 8 is padding
    double tooltipTop = hotspot.y - iconSize - 12; // 8 is padding

    const tooltipWidth = 150.0; // Adjust as needed

    // Adjust tooltip position to stay within image bounds
    if (tooltipLeft + tooltipWidth > imageSize.width) {
      tooltipLeft = imageSize.width - tooltipWidth - 16; // Adjust for padding
    }
    if (tooltipTop < 0) {
      tooltipTop = hotspot.y + iconSize + 8; // Adjust for padding
    }

    return Positioned(
      left: tooltipLeft,
      top: tooltipTop,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          tooltipText,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  /// Creates a default icon for a hotspot if no custom icon is provided.
  Widget _defaultHotspotIcon(Hotspot hotspot) {
    return Container(
      width: hotspot.size,
      height: hotspot.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: hotspot.color.withOpacity(0.5),
        border: Border.all(color: hotspot.color, width: 2),
      ),
    );
  }
}

/// Represents a clickable area on an image.
class Hotspot {
  /// The x-coordinate of the hotspot.
  final double x;

  /// The y-coordinate of the hotspot.
  final double y;

  /// The function to call when the hotspot is tapped.
  final VoidCallback onTap;

  /// The text to display in the tooltip when the hotspot is tapped.
  final String? tooltip;

  /// A custom icon to display for the hotspot.
  final Widget? icon;

  /// The color of the default hotspot icon.
  final Color color;

  /// The size of the hotspot icon.
  final double size;

  /// Creates a [Hotspot].
  ///
  /// The [x], [y], and [onTap] parameters are required.
  Hotspot({
    required this.x,
    required this.y,
    required this.onTap,
    this.tooltip,
    this.icon,
    this.color = Colors.red,
    this.size = 24.0,
  });
}
