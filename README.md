# liquid_glass_container

Real Liquid Glass for Flutter — not a shader imitation.

<img src="https://raw.githubusercontent.com/kiddo4/liquid_glass_container/main/doc/demo.png" width="320" alt="Demo: glass cards and a floating glass bottom bar refracting a colorful backdrop" />


On iOS 26+ these widgets host Apple's native `UIGlassEffect` material in a
platform view beneath your Flutter content, so you get **actual refractive
Liquid Glass**: it samples and bends what's behind it, shimmers on touch,
and — because it's the system material — automatically follows every system
appearance setting, including:

- the **iOS 27 transparency slider** (ultra-clear → fully tinted),
- **Reduce Transparency** and **Increase Contrast**,
- iOS 27's refined edges, highlights, and content diffusion.

Elsewhere it degrades gracefully behind the same API: a native system blur
on iOS < 26, and a Flutter-drawn frosted material on Android, web, and
desktop (with high-contrast support and an intensity dial).

## Widgets

### `LiquidGlassContainer`

The primitive. Use it like a `Container` and build whatever you want —
cards, pills, headers, floating panels:

```dart
LiquidGlassContainer(
  shape: const LiquidGlassShape.roundedRectangle(16),
  padding: const EdgeInsets.all(20),
  child: const Text('Now playing'),
)
```

Options: `style` (`LiquidGlassStyle.regular` for legibility, `.clear` over
media), `shape` (`.capsule()` or `.roundedRectangle(r)`), `tint`,
`interactive` (Apple's touch shimmer), and `Container`-style `padding`,
`margin`, `width`, `height`, `alignment`.

### `LiquidGlassBottomBar`

A floating capsule tab bar in the iOS 26/27 idiom, built on the container:

```dart
LiquidGlassBottomBar(
  items: const [
    LiquidGlassBarItem(icon: CupertinoIcons.house, label: 'Home'),
    LiquidGlassBarItem(icon: CupertinoIcons.search, label: 'Search'),
    LiquidGlassBarItem(icon: CupertinoIcons.person, label: 'Profile'),
  ],
  currentIndex: _index,
  onTap: (i) => setState(() => _index = i),
)
```

Place it above your content (e.g. bottom-aligned in a `Stack`) so the glass
has something to refract. A sliding highlight pill marks the selection;
taps give haptic feedback; every destination is labeled for screen readers.

### `LiquidGlass.capabilities()`

Runtime introspection when you need it:

```dart
final caps = await LiquidGlass.capabilities();
if (caps.nativeGlass) { /* real UIGlassEffect (iOS 26+) */ }
if (caps.reduceTransparency) { /* user prefers opaque surfaces */ }
```

## Design notes

- **Glass needs content.** Apple's material only reads as glass over rich,
  scrolling content. Don't stack glass on glass; don't put it on a flat
  background and expect magic.
- **`regular` vs `clear`:** default to `regular` — it keeps text legible.
  Reserve `clear` for controls over photos/video.
- **Tinting:** supported, but Apple's guidance is that glass reads best
  untinted. The bar's selected color is the ambient Cupertino primary.
- **Touch handling:** non-`interactive` glass never intercepts touches;
  your widgets behind and above it keep working.
- The fallback's `fallbackIntensity` (0–1) is the in-app analogue of the
  iOS 27 slider for platforms that don't have one.

## Requirements

- iOS: builds with Xcode 26+ (iOS 26 SDK). Runs on any iOS version the app
  supports — glass on 26+, system blur before that.
- Other platforms: no setup; the Dart fallback is dependency-free.

## Example

`example/` contains a full demo: glass cards over a vivid backdrop, a
style/intensity control panel, and the floating bottom bar.
