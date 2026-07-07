# Changelog

## 0.1.0

- Initial release.
- `LiquidGlassContainer`: native `UIGlassEffect` Liquid Glass on iOS 26+
  (regular/clear styles, capsule and rounded-rectangle shapes, tint,
  interactive touch shimmer), `UIBlurEffect` material on older iOS, and a
  Flutter-drawn frosted fallback on other platforms.
- `LiquidGlassBottomBar`: floating capsule tab bar with animated selection
  pill, haptics, and screen-reader semantics.
- `LiquidGlass.capabilities()`: native-glass and Reduce Transparency
  introspection.
- Automatic adaptation to the iOS 27 transparency slider and accessibility
  settings via the system material.
