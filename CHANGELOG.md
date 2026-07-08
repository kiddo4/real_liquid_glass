# Changelog

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
- `LiquidGlassBottomBar`: floating capsule tab bar with a liquid glass
  droplet selection indicator that hops between destinations and merges
  into the bar (sliding pill on fallback platforms), haptics, and
  screen-reader semantics.
- `LiquidGlass.capabilities()`: native-glass and Reduce Transparency
  introspection.
- Automatic adaptation to the iOS 27 transparency slider and accessibility
  settings via the system material.
