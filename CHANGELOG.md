# Changelog

## 0.2.0

- `LiquidGlassBottomBar` selection now matches the native iOS 26 tab bar:
  the capsule is real glass on iOS/macOS, slides with a liquid stretch on
  tap, pops the landing icon, and can be dragged along the bar with a
  finger (replaces the 0.1.0 droplet indicator; `liquidSelection` and
  `dropletSize` parameters removed).

## 0.1.0

- Initial release.
- `LiquidGlassContainer`: native `UIGlassEffect` Liquid Glass on iOS 26+
  and `NSGlassEffectView` on macOS 26+ (regular/clear styles, capsule and
  rounded-rectangle shapes, tint, interactive touch shimmer), system blur
  material on older Apple OS versions, and a Flutter-drawn frosted
  fallback on other platforms.
- `LiquidGlassGroup`: true liquid merging — containers in a group fuse
  like droplets when within `spacing` of each other, driven natively by
  `UIGlassContainerEffect` / `NSGlassEffectContainerView`; N grouped
  containers share a single platform view.
- `LiquidGlassBottomBar`: floating capsule tab bar with haptics and
  screen-reader semantics.
- `LiquidGlass.capabilities()`: native-glass and Reduce Transparency
  introspection.
- Automatic adaptation to the iOS 27 transparency slider and accessibility
  settings via the system material.
