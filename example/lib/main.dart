import 'package:flutter/cupertino.dart';
import 'package:real_liquid_glass/real_liquid_glass.dart';

void main() => runApp(const GlassDemoApp());

class GlassDemoApp extends StatelessWidget {
  const GlassDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      debugShowCheckedModeBanner: false,
      home: GlassDemoScreen(),
    );
  }
}

class GlassDemoScreen extends StatefulWidget {
  const GlassDemoScreen({super.key});

  @override
  State<GlassDemoScreen> createState() => _GlassDemoScreenState();
}

class _GlassDemoScreenState extends State<GlassDemoScreen> {
  int _tab = 0;
  LiquidGlassStyle _style = LiquidGlassStyle.regular;
  double _intensity = 1.0;
  LiquidGlassCapabilities? _caps;
  Offset _droplet = const Offset(16, 68);

  @override
  void initState() {
    super.initState();
    LiquidGlass.capabilities().then((caps) {
      if (mounted) setState(() => _caps = caps);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          // Busy, colorful backdrop so the glass has something to refract.
          const Positioned.fill(child: _Backdrop()),
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 140),
                children: [
                  LiquidGlassContainer(
                    style: _style,
                    fallbackIntensity: _intensity,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Liquid Glass container',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _caps == null
                              ? 'Checking device capabilities…'
                              : _caps!.nativeGlass
                                  ? 'Native UIGlassEffect is live — drag the '
                                      'list and watch the refraction.'
                                  : 'Flutter fallback material (no native '
                                      'glass on this platform).',
                          style: const TextStyle(fontSize: 15, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  LiquidGlassContainer(
                    style: _style,
                    fallbackIntensity: _intensity,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tune the material',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CupertinoSlidingSegmentedControl<LiquidGlassStyle>(
                          groupValue: _style,
                          onValueChanged: (v) =>
                              setState(() => _style = v ?? _style),
                          children: const {
                            LiquidGlassStyle.regular: Text('Regular'),
                            LiquidGlassStyle.clear: Text('Clear'),
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Text('Fallback intensity',
                                style: TextStyle(fontSize: 15)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CupertinoSlider(
                                value: _intensity,
                                onChanged: (v) =>
                                    setState(() => _intensity = v),
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          'On iOS the system transparency setting governs '
                          'the real glass; this slider drives the fallback.',
                          style: TextStyle(fontSize: 12, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Liquid merging — drag the droplet into the pill',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 200,
                    child: LiquidGlassGroup(
                      spacing: 32,
                      child: Stack(
                        children: [
                          Align(
                            child: LiquidGlassContainer(
                              shape: const LiquidGlassShape.capsule(),
                              style: _style,
                              width: 200,
                              height: 64,
                              child: const Center(child: Text('Drop zone')),
                            ),
                          ),
                          Positioned(
                            left: _droplet.dx,
                            top: _droplet.dy,
                            child: GestureDetector(
                              onPanUpdate: (d) => setState(
                                  () => _droplet += d.delta),
                              child: LiquidGlassContainer(
                                shape: const LiquidGlassShape.capsule(),
                                style: _style,
                                width: 64,
                                height: 64,
                                child: const Icon(CupertinoIcons.drop_fill,
                                    size: 22),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  for (var i = 0; i < 8; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: LiquidGlassContainer(
                        style: _style,
                        fallbackIntensity: _intensity,
                        shape: const LiquidGlassShape.roundedRectangle(16),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            const Icon(CupertinoIcons.music_note_2, size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Scroll item ${i + 1} — content slides '
                                'beneath the bar',
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: LiquidGlassBottomBar(
                style: _style,
                fallbackIntensity: _intensity,
                items: const [
                  LiquidGlassBarItem(
                    icon: CupertinoIcons.house,
                    selectedIcon: CupertinoIcons.house_fill,
                    label: 'Home',
                  ),
                  LiquidGlassBarItem(
                    icon: CupertinoIcons.search,
                    label: 'Search',
                  ),
                  LiquidGlassBarItem(
                    icon: CupertinoIcons.bell,
                    selectedIcon: CupertinoIcons.bell_fill,
                    label: 'Alerts',
                  ),
                  LiquidGlassBarItem(
                    icon: CupertinoIcons.person,
                    selectedIcon: CupertinoIcons.person_fill,
                    label: 'Profile',
                  ),
                ],
                currentIndex: _tab,
                onTap: (i) => setState(() => _tab = i),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Vivid gradient blobs — glass is only convincing over rich content.
class _Backdrop extends StatelessWidget {
  const _Backdrop();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A2980),
            Color(0xFF26D0CE),
            Color(0xFFFF6B9D),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 120,
            left: -60,
            child: _blob(const Color(0xFFFFC371), 220),
          ),
          Positioned(
            top: 380,
            right: -80,
            child: _blob(const Color(0xFF7F00FF), 280),
          ),
          Positioned(
            bottom: 40,
            left: 40,
            child: _blob(const Color(0xFF00FFA3), 180),
          ),
        ],
      ),
    );
  }

  Widget _blob(Color color, double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: 0.85), color.withValues(alpha: 0)],
          ),
        ),
      );
}
