import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'glass_container.dart';
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
/// bottom) so the glass has something to refract. The selected
/// destination is marked by a sliding highlight pill.
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
class LiquidGlassBottomBar extends StatelessWidget {
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

  /// Bar height, excluding [margin].
  final double height;

  /// Spacing around the floating bar. The default keeps it clear of the
  /// home indicator; wrap in [SafeArea] if you need more.
  final EdgeInsetsGeometry margin;

  /// Whether to show labels under the icons.
  final bool showLabels;

  /// Fallback-effect strength on non-iOS platforms; see
  /// [LiquidGlassContainer.fallbackIntensity].
  final double fallbackIntensity;

  static const Color _pillLight = Color(0x14000000);
  static const Color _pillDark = Color(0x2EFFFFFF);

  @override
  Widget build(BuildContext context) {
    final dark =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final selectedColor = tint ?? CupertinoTheme.of(context).primaryColor;
    final unselectedColor = CupertinoColors.secondaryLabel.resolveFrom(context);

    return LiquidGlassContainer(
      shape: const LiquidGlassShape.capsule(),
      style: style,
      height: height,
      margin: margin,
      padding: const EdgeInsets.all(4),
      fallbackIntensity: fallbackIntensity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / items.length;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                left: itemWidth * currentIndex,
                top: 0,
                bottom: 0,
                width: itemWidth,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: dark ? _pillDark : _pillLight,
                    borderRadius:
                        BorderRadius.circular(constraints.maxHeight / 2),
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < items.length; i++)
                    Expanded(
                      child: _BarItem(
                        item: items[i],
                        selected: i == currentIndex,
                        selectedColor: selectedColor,
                        unselectedColor: unselectedColor,
                        showLabel: showLabels,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          onTap(i);
                        },
                      ),
                    ),
                ],
              ),
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
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.w500,
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
