import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'capabilities.dart';
import 'glass_container.dart';
import 'glass_group.dart';
import 'glass_style.dart';

/// One destination in a [LiquidGlassBottomBar].
class LiquidGlassBarItem {
  /// Creates a bar destination.
  const LiquidGlassBarItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
  });

  /// Icon shown when the destination is not selected.
  final IconData icon;

  /// Icon shown when selected; falls back to [icon].
  final IconData? selectedIcon;

  /// Short destination name, shown under the icon and used for
  /// accessibility.
  final String label;
}

/// A floating capsule tab bar in the iOS 26/27 Liquid Glass idiom.
///
/// Sits above your content (typically in a [Stack], aligned to the
/// bottom) so the glass has something to refract.
///
/// On iOS/macOS the selected destination is marked by a **liquid glass
/// droplet** riding the bar's top rim: tap another destination and the
/// droplet hops out of the bar, arcs across, and lands again — merging
/// back into the glass like a drop of water (set [liquidSelection] to
/// false for a plain sliding pill instead). On other platforms a sliding
/// highlight pill marks the selection.
///
/// ```dart
/// LiquidGlassBottomBar(
///   items: const [
///     LiquidGlassBarItem(icon: CupertinoIcons.house, label: 'Home'),
///     LiquidGlassBarItem(icon: CupertinoIcons.search, label: 'Search'),
///   ],
///   currentIndex: _index,
///   onTap: (i) => setState(() => _index = i),
/// )
/// ```
class LiquidGlassBottomBar extends StatefulWidget {
  /// Creates the bar. [items] needs at least two destinations.
  const LiquidGlassBottomBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.tint,
    this.style = LiquidGlassStyle.regular,
    this.height = 64,
    this.margin = const EdgeInsets.fromLTRB(24, 8, 24, 16),
    this.showLabels = true,
    this.fallbackIntensity = 1.0,
    this.liquidSelection = true,
    this.dropletSize = 30,
  }) : assert(items.length >= 2, 'Provide at least two destinations');

  /// The destinations to display, in order.
  final List<LiquidGlassBarItem> items;

  /// Index of the selected destination.
  final int currentIndex;

  /// Called with the tapped destination's index.
  final ValueChanged<int> onTap;

  /// Color of the selected icon and label. Defaults to the ambient
  /// Cupertino primary color.
  final Color? tint;

  /// Glass variant for the bar surface.
  final LiquidGlassStyle style;

  /// Bar height, excluding [margin] and the droplet overhang.
  final double height;

  /// Spacing around the floating bar. The default keeps it clear of the
  /// home indicator; wrap in [SafeArea] if you need more.
  final EdgeInsetsGeometry margin;

  /// Whether to show labels under the icons.
  final bool showLabels;

  /// Fallback-effect strength on non-Apple platforms; see
  /// [LiquidGlassContainer.fallbackIntensity].
  final double fallbackIntensity;

  /// Marks the selection with a glass droplet that hops between
  /// destinations and merges into the bar (iOS/macOS only). When false —
  /// and always on fallback platforms — a sliding highlight pill is used.
  final bool liquidSelection;

  /// Diameter of the selection droplet when [liquidSelection] is active.
  final double dropletSize;

  static const Color _pillLight = Color(0x14000000);
  static const Color _pillDark = Color(0x2EFFFFFF);

  @override
  State<LiquidGlassBottomBar> createState() => _LiquidGlassBottomBarState();
}

class _LiquidGlassBottomBarState extends State<LiquidGlassBottomBar> {
  late int _from = widget.currentIndex;

  @override
  void didUpdateWidget(LiquidGlassBottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _from = oldWidget.currentIndex;
    }
  }

  Color _selectedColor(BuildContext context) =>
      widget.tint ?? CupertinoTheme.of(context).primaryColor;

  Color _unselectedColor(BuildContext context) =>
      CupertinoColors.secondaryLabel.resolveFrom(context);

  void _handleTap(int index) {
    HapticFeedback.selectionClick();
    widget.onTap(index);
  }

  Widget _itemRow(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < widget.items.length; i++)
          Expanded(
            child: _BarItem(
              item: widget.items[i],
              selected: i == widget.currentIndex,
              selectedColor: _selectedColor(context),
              unselectedColor: _unselectedColor(context),
              showLabel: widget.showLabels,
              onTap: () => _handleTap(i),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.liquidSelection && LiquidGlass.isNativePlatform) {
      return _buildLiquid(context);
    }
    return _buildClassic(context);
  }

  /// Native path: bar and droplet share a [LiquidGlassGroup], so the
  /// droplet visibly fuses with the bar rim and morphs while it travels.
  Widget _buildLiquid(BuildContext context) {
    // How far the droplet pokes above the bar while resting.
    final overhang = widget.dropletSize * 0.45;
    return Padding(
      padding: widget.margin,
      child: SizedBox(
        height: widget.height + overhang,
        child: LiquidGlassGroup(
          spacing: widget.dropletSize,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth / widget.items.length;
              double centerX(int i) => itemWidth * i + itemWidth / 2;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: overhang,
                    bottom: 0,
                    child: LiquidGlassContainer(
                      shape: const LiquidGlassShape.capsule(),
                      style: widget.style,
                      child: _itemRow(context),
                    ),
                  ),
                  TweenAnimationBuilder<double>(
                    // Restart the hop whenever the selection changes.
                    key: ValueKey<int>(widget.currentIndex),
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 420),
                    curve: Curves.easeInOutCubic,
                    builder: (context, t, child) {
                      final x = lerpDouble(
                          centerX(_from), centerX(widget.currentIndex), t)!;
                      // Rise out of the glass mid-flight, land at the end.
                      final hop =
                          math.sin(math.pi * t) * widget.dropletSize * 0.6;
                      return Positioned(
                        left: x - widget.dropletSize / 2,
                        top: -hop,
                        width: widget.dropletSize,
                        height: widget.dropletSize,
                        child: child!,
                      );
                    },
                    child: IgnorePointer(
                      child: LiquidGlassContainer(
                        shape: const LiquidGlassShape.capsule(),
                        style: widget.style,
                        tint: widget.tint,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// Fallback path: the classic sliding highlight pill.
  Widget _buildClassic(BuildContext context) {
    final dark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    return LiquidGlassContainer(
      shape: const LiquidGlassShape.capsule(),
      style: widget.style,
      height: widget.height,
      margin: widget.margin,
      padding: const EdgeInsets.all(4),
      fallbackIntensity: widget.fallbackIntensity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / widget.items.length;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                left: itemWidth * widget.currentIndex,
                top: 0,
                bottom: 0,
                width: itemWidth,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: dark
                        ? LiquidGlassBottomBar._pillDark
                        : LiquidGlassBottomBar._pillLight,
                    borderRadius:
                        BorderRadius.circular(constraints.maxHeight / 2),
                  ),
                ),
              ),
              _itemRow(context),
            ],
          );
        },
      ),
    );
  }
}

class _BarItem extends StatelessWidget {
  const _BarItem({
    required this.item,
    required this.selected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.showLabel,
    required this.onTap,
  });

  final LiquidGlassBarItem item;
  final bool selected;
  final Color selectedColor;
  final Color unselectedColor;
  final bool showLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? selectedColor : unselectedColor;
    return Semantics(
      container: true,
      selected: selected,
      button: true,
      label: item.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? (item.selectedIcon ?? item.icon) : item.icon,
              size: 24,
              color: color,
            ),
            if (showLabel) ...[
              const SizedBox(height: 2),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.2,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
