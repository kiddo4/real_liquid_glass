import 'package:flutter/cupertino.dart';
import 'package:real_liquid_glass/real_liquid_glass.dart';

const _artwork = 'assets/nocturne_flow.png';

void main() => runApp(const GlassMusicApp());

class GlassMusicApp extends StatelessWidget {
  const GlassMusicApp({super.key});

  @override
  Widget build(BuildContext context) => const CupertinoApp(
    debugShowCheckedModeBanner: false,
    theme: CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: CupertinoColors.systemPink,
    ),
    home: MusicShell(),
  );
}

class MusicShell extends StatefulWidget {
  const MusicShell({super.key});

  @override
  State<MusicShell> createState() => _MusicShellState();
}

class _MusicShellState extends State<MusicShell> {
  static const _tabs = [
    LiquidGlassBarItem(
      icon: CupertinoIcons.house,
      selectedIcon: CupertinoIcons.house_fill,
      sfSymbol: 'house',
      selectedSfSymbol: 'house.fill',
      label: 'Home',
    ),
    LiquidGlassBarItem(
      icon: CupertinoIcons.compass,
      selectedIcon: CupertinoIcons.compass_fill,
      sfSymbol: 'safari',
      selectedSfSymbol: 'safari.fill',
      label: 'Browse',
    ),
    LiquidGlassBarItem(
      icon: CupertinoIcons.music_albums,
      sfSymbol: 'square.stack',
      selectedSfSymbol: 'square.stack.fill',
      label: 'Library',
    ),
    LiquidGlassBarItem(
      icon: CupertinoIcons.music_note_2,
      sfSymbol: 'music.note',
      label: 'Player',
    ),
  ];

  final _pageController = PageController();
  int _index = 0;
  bool _playing = true;
  bool _liked = false;
  double _progress = .38;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _select(int index) {
    if (index == _index) return;
    setState(() => _index = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 340),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        fit: StackFit.expand,
        children: [
          const _MusicBackdrop(),
          PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _index = index),
            children: [
              _HomePage(onOpenPlayer: () => _select(3)),
              const _BrowsePage(),
              const _LibraryPage(),
              _PlayerPage(
                playing: _playing,
                liked: _liked,
                progress: _progress,
                onTogglePlay: () => setState(() => _playing = !_playing),
                onToggleLike: () => setState(() => _liked = !_liked),
                onProgress: (value) => setState(() => _progress = value),
              ),
            ],
          ),
          if (_index != 3)
            Positioned(
              left: 18,
              right: 18,
              bottom: 91,
              child: _MiniPlayer(
                playing: _playing,
                onOpen: () => _select(3),
                onTogglePlay: () => setState(() => _playing = !_playing),
              ),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: LiquidGlassBottomBar(
              items: _tabs,
              currentIndex: _index,
              onTap: _select,
              tint: CupertinoColors.systemPink,
            ),
          ),
        ],
      ),
    );
  }
}

class _MusicBackdrop extends StatelessWidget {
  const _MusicBackdrop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(_artwork, fit: BoxFit.cover),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xB30A0730), Color(0xF2080718)],
            ),
          ),
        ),
      ],
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage({required this.onOpenPlayer});

  final VoidCallback onOpenPlayer;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 205),
        children: [
          const _PageHeader(eyebrow: 'FRIDAY EVENING', title: 'Listen now'),
          const SizedBox(height: 22),
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: AspectRatio(
              aspectRatio: 1.15,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(_artwork, fit: BoxFit.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x00101020), Color(0xD9100A24)],
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 22,
                    right: 22,
                    bottom: 22,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NOCTURNE FLOW',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Midnight Frequencies',
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          LiquidGlassContainer(
            shape: const LiquidGlassShape.roundedRectangle(24),
            padding: const EdgeInsets.all(18),
            onTap: onOpenPlayer,
            child: const Row(
              children: [
                Icon(
                  CupertinoIcons.sparkles,
                  color: CupertinoColors.systemPink,
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Made for your night',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'A native glass mix that shifts with your mood.',
                        style: TextStyle(color: CupertinoColors.systemGrey2),
                      ),
                    ],
                  ),
                ),
                Icon(CupertinoIcons.chevron_forward, size: 18),
              ],
            ),
          ),
          const SizedBox(height: 26),
          const _SectionTitle('Recently played'),
          const SizedBox(height: 14),
          const Row(
            children: [
              Expanded(
                child: _AlbumTile(title: 'Velvet Sky', tint: Color(0xFFFF5B8C)),
              ),
              SizedBox(width: 14),
              Expanded(
                child: _AlbumTile(title: 'Blue Hour', tint: Color(0xFF39C6FF)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BrowsePage extends StatelessWidget {
  const _BrowsePage();

  @override
  Widget build(BuildContext context) {
    const moods = [
      ('Focus', CupertinoIcons.lightbulb_fill, Color(0xFF55D7FF)),
      ('Energy', CupertinoIcons.bolt_fill, Color(0xFFFF5F7E)),
      ('Chill', CupertinoIcons.moon_fill, Color(0xFFAB83FF)),
      ('Acoustic', CupertinoIcons.guitars, Color(0xFFFFB85C)),
    ];
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 205),
        children: [
          const _PageHeader(eyebrow: 'DISCOVER', title: 'Browse'),
          const SizedBox(height: 22),
          LiquidGlassContainer(
            height: 52,
            shape: const LiquidGlassShape.capsule(),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: const Row(
              children: [
                Icon(CupertinoIcons.search, color: CupertinoColors.systemGrey),
                SizedBox(width: 10),
                Text(
                  'Artists, songs, lyrics',
                  style: TextStyle(color: CupertinoColors.systemGrey2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const _SectionTitle('Find your mood'),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: moods.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.35,
            ),
            itemBuilder: (context, index) {
              final mood = moods[index];
              return LiquidGlassContainer(
                shape: const LiquidGlassShape.roundedRectangle(22),
                tint: mood.$3.withValues(alpha: .22),
                padding: const EdgeInsets.all(17),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(mood.$2, color: mood.$3, size: 25),
                    Text(
                      mood.$1,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 28),
          const _SectionTitle('Editor’s station'),
          const SizedBox(height: 14),
          const _StationCard(),
        ],
      ),
    );
  }
}

class _LibraryPage extends StatelessWidget {
  const _LibraryPage();

  @override
  Widget build(BuildContext context) {
    const rows = [
      (CupertinoIcons.music_note_list, 'Playlists', '12 collections'),
      (CupertinoIcons.person_2_fill, 'Artists', '34 followed'),
      (CupertinoIcons.music_albums_fill, 'Albums', '48 saved'),
      (CupertinoIcons.arrow_down_circle_fill, 'Downloaded', '6.2 GB'),
    ];
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 205),
        children: [
          const _PageHeader(eyebrow: 'YOUR MUSIC', title: 'Library'),
          const SizedBox(height: 24),
          LiquidGlassContainer(
            shape: const LiquidGlassShape.roundedRectangle(26),
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Column(
              children: [
                for (var index = 0; index < rows.length; index++) ...[
                  _LibraryRow(data: rows[index]),
                  if (index != rows.length - 1)
                    const Padding(
                      padding: EdgeInsets.only(left: 64),
                      child: SizedBox(
                        height: 1,
                        child: ColoredBox(color: Color(0x26FFFFFF)),
                      ),
                    ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 28),
          const _SectionTitle('Pinned collection'),
          const SizedBox(height: 14),
          const _StationCard(),
        ],
      ),
    );
  }
}

class _PlayerPage extends StatelessWidget {
  const _PlayerPage({
    required this.playing,
    required this.liked,
    required this.progress,
    required this.onTogglePlay,
    required this.onToggleLike,
    required this.onProgress,
  });

  final bool playing;
  final bool liked;
  final double progress;
  final VoidCallback onTogglePlay;
  final VoidCallback onToggleLike;
  final ValueChanged<double> onProgress;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(26, 20, 26, 112),
        children: [
          const Center(
            child: Text(
              'NOW PLAYING',
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 26),
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.asset(_artwork, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 26),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Midnight Frequencies',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Nocturne Flow',
                      style: TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.systemGrey2,
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onToggleLike,
                child: Icon(
                  liked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                  color: liked
                      ? CupertinoColors.systemPink
                      : CupertinoColors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CupertinoSlider(value: progress, onChanged: onProgress),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('1:24'), Text('-2:16')],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 82,
            child: LiquidGlassGroup(
              spacing: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _GlassControl(
                    icon: CupertinoIcons.backward_fill,
                    onTap: () {},
                  ),
                  const SizedBox(width: 14),
                  _GlassControl(
                    icon: playing
                        ? CupertinoIcons.pause_fill
                        : CupertinoIcons.play_fill,
                    size: 76,
                    iconSize: 32,
                    onTap: onTogglePlay,
                  ),
                  const SizedBox(width: 14),
                  _GlassControl(
                    icon: CupertinoIcons.forward_fill,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const LiquidGlassContainer(
            shape: LiquidGlassShape.roundedRectangle(22),
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            child: Row(
              children: [
                Icon(CupertinoIcons.antenna_radiowaves_left_right, size: 20),
                SizedBox(width: 12),
                Expanded(child: Text('iPhone')),
                Icon(CupertinoIcons.speaker_2_fill, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniPlayer extends StatelessWidget {
  const _MiniPlayer({
    required this.playing,
    required this.onOpen,
    required this.onTogglePlay,
  });

  final bool playing;
  final VoidCallback onOpen;
  final VoidCallback onTogglePlay;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassContainer(
      height: 70,
      shape: const LiquidGlassShape.roundedRectangle(22),
      padding: const EdgeInsets.all(9),
      child: Row(
        children: [
          GestureDetector(
            onTap: onOpen,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                _artwork,
                width: 52,
                height: 52,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: onOpen,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Midnight Frequencies',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Nocturne Flow',
                    style: TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.systemGrey2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          CupertinoButton(
            padding: const EdgeInsets.all(10),
            onPressed: onTogglePlay,
            child: Icon(
              playing ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
              color: CupertinoColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassControl extends StatelessWidget {
  const _GlassControl({
    required this.icon,
    required this.onTap,
    this.size = 62,
    this.iconSize = 24,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassContainer(
      width: size,
      height: size,
      shape: const LiquidGlassShape.capsule(),
      alignment: Alignment.center,
      onTap: onTap,
      child: Icon(icon, size: iconSize),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.eyebrow, required this.title});

  final String eyebrow;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            fontSize: 12,
            letterSpacing: 1.4,
            color: CupertinoColors.systemPink,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
  );
}

class _AlbumTile extends StatelessWidget {
  const _AlbumTile({required this.title, required this.tint});

  final String title;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(tint, BlendMode.softLight),
              child: Image.asset(_artwork, fit: BoxFit.cover),
            ),
          ),
        ),
        const SizedBox(height: 9),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const Text(
          'Nocturne Radio',
          style: TextStyle(fontSize: 13, color: CupertinoColors.systemGrey2),
        ),
      ],
    );
  }
}

class _StationCard extends StatelessWidget {
  const _StationCard();

  @override
  Widget build(BuildContext context) {
    return LiquidGlassContainer(
      height: 118,
      shape: const LiquidGlassShape.roundedRectangle(24),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(17),
            child: Image.asset(
              _artwork,
              width: 88,
              height: 88,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'After Dark Radio',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 6),
                Text(
                  'Ambient • Electronic • Soul',
                  style: TextStyle(
                    fontSize: 13,
                    color: CupertinoColors.systemGrey2,
                  ),
                ),
              ],
            ),
          ),
          Icon(CupertinoIcons.play_circle_fill, size: 34),
        ],
      ),
    );
  }
}

class _LibraryRow extends StatelessWidget {
  const _LibraryRow({required this.data});

  final (IconData, String, String) data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 14),
      child: Row(
        children: [
          Icon(data.$1, color: CupertinoColors.systemPink),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.$2,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(
                  data.$3,
                  style: const TextStyle(
                    fontSize: 13,
                    color: CupertinoColors.systemGrey2,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            CupertinoIcons.chevron_forward,
            size: 17,
            color: CupertinoColors.systemGrey2,
          ),
        ],
      ),
    );
  }
}
