import '../../../core/routing/app_routes.dart';
import '../../../core/theme/layout.dart';
import 'meditation_state.dart';
import '../../../core/state/selection_state.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_state.dart';
import '../meditation_design_system.dart';
import '../../../core/widgets/design_icon.dart';

const _ink = MeditationPalette.ink;
const _slate = Color(0xFF64748B);
const _lightSlate = Color(0xFF94A3B8);

class MeditationApp extends ConsumerStatefulWidget {
  const MeditationApp({super.key, this.initialTab = 0});
  final int initialTab;
  @override
  ConsumerState<MeditationApp> createState() => _MeditationAppState();
}

class _MeditationAppState extends ConsumerState<MeditationApp> {
  (String, String) get selection => ('meditation.tabs', '${widget.initialTab}');
  int get index => int.parse(ref.watch(selectionProvider(selection)));
  void play(String title) =>
      ref.read(playingTrackProvider.notifier).play(title);
  @override
  Widget build(BuildContext context) => Theme(
    data: meditationTheme(),
    child: Scaffold(
      backgroundColor: MeditationPalette.canvas,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppLayout.contentMaxWidth,
          ),
          child: IndexedStack(
            index: index,
            children: [
              MeditationHome(
                onPlay: play,
                onOpenTab: (v) => ref
                    .read(selectionProvider(selection).notifier)
                    .select(v.toString()),
              ),
              AlbumsPage(onPlay: play),
              const PlaylistsPage(),
              const MeditationProfilePage(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppLayout.contentMaxWidth,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MiniPlayer(
                    fallbackTitle: index == 0
                        ? 'Meditation on Twin Hearts'
                        : null,
                  ),
                  const SizedBox(height: 4),
                  _MeditationBottomDock(
                    index: index,
                    onSelected: (v) => ref
                        .read(selectionProvider(selection).notifier)
                        .select(v.toString()),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _MedSurface extends StatelessWidget {
  const _MedSurface({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 24,
    this.border = false,
    this.shadow = true,
    this.color = const Color(0xD9FFFFFF),
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool border, shadow;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: border ? Border.all(color: const Color(0xFFE7E0FA)) : null,
      boxShadow: shadow
          ? const [
              BoxShadow(
                color: Color(0x0D6C5CE7),
                blurRadius: 28,
                offset: Offset(0, 10),
              ),
            ]
          : null,
    ),
    child: child,
  );
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      color: const Color(0xD9FFFFFF),
      shape: BoxShape.circle,
      border: Border.all(color: const Color(0xF2FFFFFF)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x080F172A),
          blurRadius: 3,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 36, height: 36),
      onPressed: onTap,
      icon: DesignIcon(
        icon,
        size: 20,
        color: icon == Icons.history_rounded
            ? MeditationPalette.primary
            : const Color(0xFF475569),
      ),
    ),
  );
}

class MeditationHome extends StatelessWidget {
  const MeditationHome({
    super.key,
    required this.onPlay,
    required this.onOpenTab,
  });
  final ValueChanged<String> onPlay;
  final ValueChanged<int> onOpenTab;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.transparent,
    body: SafeArea(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(.6, -.3),
            radius: 1.5,
            colors: [Color(0xFFF3E8FF), Color(0xFFFDFBF7)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
          children: [
            Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontSize: 28,
                  height: 1.2,
                  letterSpacing: -.7,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
                children: [
                  const TextSpan(text: 'Happy '),
                  TextSpan(
                    text: 'Friday',
                    style: TextStyle(
                      foreground: Paint()
                        ..shader = const LinearGradient(
                          colors: [Color(0xFF9333EA), Color(0xFFDB2777)],
                        ).createShader(const Rect.fromLTWH(85, 0, 100, 34)),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Harmonize the Throat & Crown Chakras\ntoday',
                    style: TextStyle(fontSize: 12, height: 1.4, color: _slate),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFF3E8FF)),
                  ),
                  child: const Row(
                    children: [
                      DesignIcon(
                        Icons.circle,
                        size: 6,
                        color: Color(0xFF10B981),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Live Stream',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: MeditationPalette.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 46,
              padding: const EdgeInsets.only(left: 40, right: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadii.card),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x06000000),
                    blurRadius: 18,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: Text(
                      'Search mantras, Twin Hearts, affirmations',
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: TextStyle(fontSize: 14, color: _lightSlate),
                    ),
                  ),
                  SizedBox(width: 10),
                  DesignIcon(Icons.tune_rounded, size: 18, color: _lightSlate),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _WisdomBanner(onTap: () => onPlay('Daily Arhatic Wisdom')),
            const SizedBox(height: 12),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CarouselDot(active: true),
                SizedBox(width: 6),
                _CarouselDot(),
                SizedBox(width: 6),
                _CarouselDot(),
              ],
            ),
            const SizedBox(height: 24),
            _MedSectionTitle(
              'FEATURED ALBUM',
              'View Liner Notes',
              icon: Icons.album_rounded,
              onTap: () => onOpenTab(1),
            ),
            const SizedBox(height: 12),
            _AlbumFeature(onPlay: onPlay),
            const SizedBox(height: 24),
            Row(
              children: [
                const DesignIcon(
                  Icons.favorite,
                  color: Color(0xFFEC4899),
                  size: 15,
                ),
                const SizedBox(width: 6),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'POPULAR MEDITATIONS',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Most played global collective sessions',
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.5,
                          color: _slate,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => onOpenTab(1),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'See All',
                    style: TextStyle(
                      fontSize: 12,
                      color: MeditationPalette.accent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 250,
              child: ListView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                children: [
                  _MeditationTile('Meditation on Twin Hearts', 0, onPlay),
                  _MeditationTile('शांति एवं प्रकाश के लिए', 1, onPlay),
                  _MeditationTile('Om: Sound of Stillness', 2, onPlay),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _CarouselDot extends StatelessWidget {
  const _CarouselDot({this.active = false});
  final bool active;
  @override
  Widget build(BuildContext context) => Container(
    width: active ? 20 : 6,
    height: 6,
    decoration: BoxDecoration(
      color: active ? null : const Color(0xFFCBD5E1),
      gradient: active
          ? const LinearGradient(colors: [Color(0xFFA855F7), Color(0xFFEC4899)])
          : null,
      borderRadius: BorderRadius.circular(6),
    ),
  );
}

class _WisdomBanner extends StatelessWidget {
  const _WisdomBanner({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Container(
    height: MediaQuery.sizeOf(context).width < 380 ? 220 : 190,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1E1B4B), Color(0xFF11162F), Color(0xFF3B0764)],
      ),
      borderRadius: BorderRadius.circular(AppRadii.large),
      border: Border.all(color: const Color(0x665E58A6)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x33312E81),
          blurRadius: 18,
          offset: Offset(0, 10),
        ),
      ],
    ),
    child: Stack(
      children: [
        const Positioned(
          right: -24,
          top: 20,
          bottom: 8,
          width: 142,
          child: CustomPaint(painter: _SacredGeometry()),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const DesignIcon(
                    Icons.auto_awesome,
                    color: Color(0xFFFACC15),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'DAILY ARHATIC WISDOM',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: .3,
                        color: Color(0xFFE9D5FF),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x337B6A8C),
                      borderRadius: BorderRadius.circular(AppRadii.card),
                    ),
                    child: const Text(
                      'Sutra 108',
                      style: TextStyle(fontSize: 10, color: Color(0xFFD8C7E3)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                '"Arhatic Yoga consists of yogic techniques designed to help us develop spiritually. It is prehistoric in origin."',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.7,
                  color: Color(0xFFE2E8F0),
                ),
              ),
              const Spacer(),
              const Divider(height: 1, color: Color(0x22FFFFFF)),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      '— Master Choa Kok Sui',
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: .2,
                        color: Color(0xFFE9C75D),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: onTap,
                    child: const Text(
                      'Deep Contemplation ↗',
                      style: TextStyle(fontSize: 10, color: Color(0xFFD8B4FE)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SacredGeometry extends CustomPainter {
  const _SacredGeometry();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x26DDD6FE)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(c, size.width * .38, paint);
    final p = Path();
    for (var orientation in [0, math.pi]) {
      for (var i = 0; i < 3; i++) {
        final angle = -math.pi / 2 + orientation + i * 2 * math.pi / 3;
        final pt =
            c + Offset(math.cos(angle), math.sin(angle)) * size.width * .42;
        if (i == 0) {
          p.moveTo(pt.dx, pt.dy);
        } else {
          p.lineTo(pt.dx, pt.dy);
        }
      }
      p.close();
    }
    canvas.drawPath(p, paint);
    final outer = Paint()
      ..color = const Color(0x25DDD6FE)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < 36; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: size.width * .49),
        i * math.pi / 18,
        .08,
        false,
        outer,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MedSectionTitle extends StatelessWidget {
  const _MedSectionTitle(
    this.title,
    this.action, {
    required this.onTap,
    this.icon,
  });
  final String title, action;
  final VoidCallback onTap;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 24,
    child: Row(
      children: [
        if (icon != null) ...[
          DesignIcon(icon, size: 15, color: MeditationPalette.accent),
          const SizedBox(width: 7),
        ],
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              height: 1.3,
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
            ),
          ),
        ),
        InkWell(
          onTap: onTap,
          child: Text(
            action,
            style: const TextStyle(
              fontSize: 12,
              color: MeditationPalette.accent,
            ),
          ),
        ),
      ],
    ),
  );
}

class _AlbumFeature extends StatelessWidget {
  const _AlbumFeature({required this.onPlay});
  final ValueChanged<String> onPlay;
  @override
  Widget build(BuildContext context) => _MedSurface(
    radius: 24,
    shadow: false,
    color: const Color(0xE6FFFFFF),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.card),
          child: Image.asset(
            'assets/images/om_album_cover.png',
            width: 112,
            height: 112,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E8FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Audio • 108 Repetitions',
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 9,
                          height: 1.2,
                          fontWeight: FontWeight.w600,
                          color: MeditationPalette.accent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '432 Hz',
                    style: TextStyle(fontSize: 9, color: _lightSlate),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Mantra OM: The Sound of Stillness',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Master Choa Kok Sui',
                style: TextStyle(fontSize: 12, height: 1.4, color: _slate),
              ),
              const SizedBox(height: 4),
              const Text(
                'Offers a transformative journey through sacred universal...',
                maxLines: 2,
                overflow: TextOverflow.clip,
                style: TextStyle(fontSize: 12, height: 1.5, color: _slate),
              ),
              const SizedBox(height: 20),
              const Divider(height: 1, color: Color(0xFFF1EFF5)),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 6,
                children: [
                  const Text(
                    '32:45',
                    style: TextStyle(fontSize: 10, color: _lightSlate),
                  ),
                  InkWell(
                    onTap: () => onPlay('Mantra OM: The Sound of Stillness'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            MeditationPalette.accent,
                            MeditationPalette.primary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(AppRadii.card),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x254F46E5),
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DesignIcon(
                            Icons.play_arrow,
                            size: 16,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Play Now',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _MeditationTile extends StatelessWidget {
  const _MeditationTile(this.title, this.index, this.onPlay);
  final String title;
  final int index;
  final ValueChanged<String> onPlay;
  @override
  Widget build(BuildContext context) => Container(
    width: 160,
    margin: const EdgeInsets.only(right: 16),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: const Color(0xE6FFFFFF),
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: Color(0x086D28D9),
          blurRadius: 24,
          offset: Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 112,
          width: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: index == 0
                  ? const [
                      Color(0xFF38BDF8),
                      Color(0xFF4F46E5),
                      Color(0xFF0F0A38),
                    ]
                  : index == 1
                  ? const [
                      Color(0xFFC7F8FC),
                      Color(0xFF38BDF8),
                      Color(0xFF4338CA),
                    ]
                  : const [Color(0xFF2D1B69), Color(0xFF0F0928)],
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 9,
                left: 3,
                right: 3,
                child: Text(
                  index == 0
                      ? 'PEACE & ILLUMINATION'
                      : index == 1
                      ? 'मास्टर चोआ कॉक सुई'
                      : 'OM • SACRED PRACTICE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamilyFallback: const ['Noto Sans Devanagari'],
                    fontSize: 7,
                    letterSpacing: .3,
                    color: index == 1 ? const Color(0xFF475569) : Colors.white,
                  ),
                ),
              ),
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0x5522D3EE), Color(0x663733E9)],
                  ),
                  border: Border.all(
                    color: const Color(0xCCFFFFFF),
                    width: 1.4,
                  ),
                ),
                child: Center(
                  child: index == 1
                      ? const Text(
                          'शांति',
                          style: TextStyle(
                            fontFamily: 'Noto Sans Devanagari',
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        )
                      : DesignIcon(
                          index == 0 ? Icons.language : Icons.spa_outlined,
                          size: 27,
                          color: Colors.white,
                        ),
                ),
              ),
              Positioned(
                bottom: 8,
                child: Text(
                  index == 0
                      ? 'Twin Hearts'
                      : index == 1
                      ? 'हृदय ध्यान'
                      : 'Stillness',
                  style: TextStyle(
                    fontFamilyFallback: const ['Noto Sans Devanagari'],
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: index == 0 ? const Color(0xFFFDE68A) : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 9),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            height: 1.4,
            fontWeight: FontWeight.w600,
            fontFamilyFallback: ['Noto Sans Devanagari'],
          ),
        ),
        Text(
          index == 1
              ? 'Hindi Meditation'
              : index == 0
              ? 'Master Choa Kok Sui'
              : 'Universal Meditation',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 10, height: 1.5, color: _slate),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: index == 1
                    ? const Color(0xFFECFDF5)
                    : const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                ['21 min', '24 min', '32 min'][index],
                style: TextStyle(
                  fontSize: 10,
                  color: index == 1
                      ? const Color(0xFF059669)
                      : MeditationPalette.accent,
                ),
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: () => onPlay(title),
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFF0F172A),
                  shape: BoxShape.circle,
                ),
                child: const DesignIcon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
        const Spacer(),
      ],
    ),
  );
}

class AlbumsPage extends ConsumerStatefulWidget {
  const AlbumsPage({super.key, required this.onPlay});
  final ValueChanged<String> onPlay;
  @override
  ConsumerState<AlbumsPage> createState() => _AlbumsPageState();
}

class _AlbumsPageState extends ConsumerState<AlbumsPage> {
  String get filter =>
      ref.watch(selectionProvider(('meditation.albums.filter', 'All Albums')));
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.transparent,
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'My Albums',
                  style: TextStyle(
                    fontSize: 24,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -.6,
                    color: Color(0xFF1A1A2A),
                  ),
                ),
              ),
              _RoundAction(icon: Icons.history_rounded, onTap: () {}),
            ],
          ),
          const SizedBox(height: 26),
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xB3FFFFFF),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFE1DCEA)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 2,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              children: [
                DesignIcon(
                  Icons.search_rounded,
                  size: 20,
                  color: Color(0xFF9B87E7),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Search chants, mantras, sutras...',
                    style: TextStyle(fontSize: 14, color: _lightSlate),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final value in [
                  'All Albums',
                  'Downloaded',
                  'Favorites',
                  'Chant',
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => ref
                          .read(
                            selectionProvider((
                              'meditation.albums.filter',
                              'All Albums',
                            )).notifier,
                          )
                          .select(value),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: filter == value
                              ? MeditationPalette.primary
                              : const Color(0xB3FFFFFF),
                          borderRadius: BorderRadius.circular(AppRadii.large),
                          border: Border.all(
                            color: filter == value
                                ? MeditationPalette.primary
                                : const Color(0xFFE5DFEC),
                          ),
                        ),
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.3,
                            color: filter == value
                                ? Colors.white
                                : const Color(0xFF535164),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 36),
          _SanctuaryEmpty(
            onExplore: () => widget.onPlay('Mantra OM: The Sound of Stillness'),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RECOMMENDED FOR YOUR PRACTICE',
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .2,
                        color: Color(0xFF1A1A2A),
                      ),
                    ),
                    Text(
                      'Pranic healing foundational essentials',
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.5,
                        color: Color(0xFF817B8D),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 11,
                    color: MeditationPalette.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _RecommendedAlbum(
            title: 'Meditation on Twin Hearts',
            author: 'Grand Master Choa Kok Sui',
            details: '2 Tracks   •   28 Mins   •   Illumination',
            icon: Icons.favorite_border,
            tint: const Color(0xFFF59E0B),
            onTap: () => widget.onPlay('Meditation on Twin Hearts'),
          ),
          const SizedBox(height: 12),
          _RecommendedAlbum(
            title: 'Meditation on the Soul',
            author: 'Achieving Oneness\nwith Higher Soul',
            details: '3 Tracks   •   45 Mins   •   Chakra Energy',
            icon: Icons.visibility_outlined,
            tint: const Color(0xFF0D9488),
            onTap: () => widget.onPlay('Meditation on the Soul'),
          ),
        ],
      ),
    ),
  );
}

class _SanctuaryEmpty extends StatelessWidget {
  const _SanctuaryEmpty({required this.onExplore});
  final VoidCallback onExplore;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (bounds) => const RadialGradient(
          colors: [Colors.white, Colors.white, Colors.transparent],
          stops: [0, .93, 1],
        ).createShader(bounds),
        child: Image.asset(
          'assets/images/sanctuary_lotus.png',
          width: 160,
          height: 160,
          fit: BoxFit.contain,
        ),
      ),
      const SizedBox(height: 18),
      const Text(
        'Your Sanctuary is Empty',
        style: TextStyle(
          fontFamily: 'Playfair Display',
          fontSize: 20,
          height: 1.4,
          letterSpacing: -.5,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A2A),
        ),
      ),
      const SizedBox(height: 6),
      const Text(
        "You haven't added any Master Choa Kok Sui\nmeditation albums to your sacred library yet.",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, height: 1.6, color: Color(0xFF625C6D)),
      ),
      const SizedBox(height: 15),
      InkWell(
        onTap: onExplore,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF5145CD), Color(0xFF7C3AED), Color(0xFFA58DF8)],
            ),
            borderRadius: BorderRadius.circular(AppRadii.large),
            boxShadow: const [
              BoxShadow(
                color: Color(0x334F46E5),
                blurRadius: 5,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'EXPLORE DISCOGRAPHY',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.3,
                  fontWeight: FontWeight.w500,
                  letterSpacing: .3,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 8),
              DesignIcon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class _RecommendedAlbum extends StatelessWidget {
  const _RecommendedAlbum({
    required this.title,
    required this.author,
    required this.details,
    required this.icon,
    required this.tint,
    required this.onTap,
  });
  final String title, author, details;
  final IconData icon;
  final Color tint;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => _MedSurface(
    radius: 16,
    border: true,
    padding: const EdgeInsets.all(12),
    shadow: false,
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            gradient: RadialGradient(
              center: const Alignment(-1, 1),
              radius: 1.1,
              colors: [tint.withValues(alpha: .16), Colors.white],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 3,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: DesignIcon(icon, size: 26, color: tint),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1A1A2A),
                      ),
                    ),
                  ),
                  if (title.contains('Twin'))
                    const Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: DesignIcon(
                        Icons.circle,
                        color: Color(0xFF14B8A6),
                        size: 6,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                author,
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.4,
                  color: Color(0xFF625C6D),
                ),
              ),
              const SizedBox(height: 4),
              Text.rich(
                TextSpan(
                  children: [
                    const WidgetSpan(
                      child: DesignIcon(
                        Icons.music_note,
                        size: 11,
                        color: MeditationPalette.primary,
                      ),
                    ),
                    TextSpan(text: ' $details'),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: const TextStyle(
                  fontSize: 9,
                  height: 1.5,
                  color: MeditationPalette.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        InkWell(
          onTap: onTap,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF2EEFF),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE3DEF0)),
            ),
            child: const DesignIcon(
              Icons.add,
              color: MeditationPalette.primary,
              size: 23,
            ),
          ),
        ),
      ],
    ),
  );
}

class PlaylistsPage extends ConsumerStatefulWidget {
  const PlaylistsPage({super.key});
  @override
  ConsumerState<PlaylistsPage> createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends ConsumerState<PlaylistsPage> {
  int get filter => int.parse(
    ref.watch(selectionProvider(('meditation.playlists.filter', '0'))),
  );
  @override
  Widget build(BuildContext context) {
    final playlists = ref.watch(playlistsProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Playlists',
                    style: TextStyle(
                      fontSize: 24,
                      height: 1.25,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -.6,
                      color: Color(0xFF1A1A2A),
                    ),
                  ),
                ),
                _RoundAction(icon: Icons.search_rounded, onTap: () {}),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                for (var i = 0; i < 4; i++)
                  Expanded(
                    flex: [10, 11, 14, 11][i],
                    child: Padding(
                      padding: EdgeInsets.only(right: i == 3 ? 0 : 8),
                      child: InkWell(
                        onTap: () => ref
                            .read(
                              selectionProvider((
                                'meditation.playlists.filter',
                                '0',
                              )).notifier,
                            )
                            .select(i.toString()),
                        child: Container(
                          height: i == 3 ? 44 : 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: filter == i
                                ? const Color(0xFF0F172A)
                                : const Color(0x99FFFFFF),
                            borderRadius: BorderRadius.circular(AppRadii.large),
                          ),
                          child: Text(
                            [
                              'Recent',
                              'Created',
                              'Most Played',
                              'Sacred\nOM',
                            ][i],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              height: 1.4,
                              color: filter == i ? Colors.white : _slate,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () => _newPlaylist(context, ref),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFE8DEFC),
                      Color(0xFFFFE8E0),
                      Color(0xFFF3DFF4),
                    ],
                  ),
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(AppRadii.large),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x126C5CE7),
                      blurRadius: 28,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xCCFFFFFF),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white),
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0x99FFFFFF),
                          border: Border.all(color: const Color(0xFFE9C8FF)),
                        ),
                        child: const DesignIcon(
                          Icons.add,
                          color: Color(0xFF9333EA),
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create Sacred Playlist',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Curate your daily sadhana, Twin Hearts, or meditation sessions.',
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              color: _slate,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const DesignIcon(
                      Icons.auto_awesome,
                      size: 20,
                      color: Color(0xFFC084FC),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            for (var i = 0; i < playlists.length; i++) ...[
              _PlaylistCard(
                title: playlists[i],
                index: i,
                onTap: () =>
                    ref.read(playingTrackProvider.notifier).play(playlists[i]),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  const _PlaylistCard({
    required this.title,
    required this.index,
    required this.onTap,
  });
  final String title;
  final int index;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final i = index % 3;
    final tint = const [
      Color(0xFFF59E0B),
      Color(0xFF6366F1),
      Color(0xFFF43F5E),
    ][i];
    final bg = const [
      Color(0xFFFFEDD5),
      Color(0xFFEDE9FE),
      Color(0xFFFCE7F3),
    ][i];
    return _MedSurface(
      radius: 24,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              children: [
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: i == 0
                          ? const Color(0xFFEDE9FE)
                          : i == 1
                          ? const Color(0xFFCFFAFE)
                          : const Color(0xFFFFEDD5),
                      borderRadius: BorderRadius.circular(AppRadii.card),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 5,
                  child: Container(
                    width: 54,
                    height: 54,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [const Color(0xFFF3E8FF), bg],
                      ),
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(AppRadii.card),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x08000000),
                          blurRadius: 3,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DesignIcon(
                          [
                            Icons.wb_twilight_rounded,
                            Icons.nightlight_round,
                            Icons.spa_outlined,
                          ][i],
                          size: 17,
                          color: tint,
                        ),
                        Text(
                          ['TH-01', 'AURA', 'YOGA'][i],
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: bg.withValues(alpha: .5),
                        border: Border.all(color: tint.withValues(alpha: .25)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        ['Morning', 'Dusk', 'Advanced'][i],
                        style: TextStyle(
                          fontSize: 9,
                          height: 1.2,
                          fontWeight: FontWeight.w600,
                          color: tint,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        [
                          '• 42 mins',
                          '• 5 tracks • 1h 10m',
                          '• 4 tracks • 55 mins',
                        ][i],
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: const TextStyle(
                          fontSize: 10,
                          height: 1.2,
                          color: _lightSlate,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  [
                    'Physical Exercises, Meditation & Breathwork',
                    '108 OM Chants with Tibetan Singing Bowls',
                    'Spiritual Cord Affirmation & Blue Pearl',
                  ][i],
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color: _slate,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onTap,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFFAF4FF),
                shape: BoxShape.circle,
              ),
              child: DesignIcon(
                i == 1 ? Icons.shuffle_rounded : Icons.play_arrow_rounded,
                size: 24,
                color: const Color(0xFF852BD1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _newPlaylist(BuildContext context, WidgetRef ref) async {
  final controller = TextEditingController();
  final value = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('New playlist'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Playlist name'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: const Text('Create'),
        ),
      ],
    ),
  );
  controller.dispose();
  if (value != null && value.trim().isNotEmpty) {
    try {
      await ref.read(playlistsProvider.notifier).add(value.trim());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Playlist saved on this device')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }
}

class MeditationProfilePage extends ConsumerWidget {
  const MeditationProfilePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    backgroundColor: Colors.transparent,
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'My Profile',
                  style: TextStyle(
                    fontSize: 24,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -.6,
                  ),
                ),
              ),
              _RoundAction(
                icon: Icons.menu_rounded,
                onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SamyuAvatar(size: 80, badge: true),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Samyuktha J',
                            style: TextStyle(
                              fontSize: 20,
                              height: 1.3,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -.3,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2EBF9),
                            border: Border.all(color: const Color(0xFFEEE5F6)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'India',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF70419A),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'samyu@indosakura.com',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: _slate,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xCCFFFFFF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFF1E9FA)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x08000000),
                            blurRadius: 3,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          DesignIcon(
                            Icons.circle,
                            size: 7,
                            color: Color(0xFF8B5CF6),
                          ),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'ARHATIC PRACTITIONER • LEVEL 1',
                              maxLines: 1,
                              style: TextStyle(
                                fontFamily: 'Playfair Display',
                                fontSize: 10,
                                letterSpacing: .1,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF673389),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          const Row(
            children: [
              Expanded(
                child: _Stat(
                  '128',
                  'Hours Meditated',
                  icon: Icons.schedule,
                  color: Color(0xFF9333EA),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _Stat(
                  '45',
                  'Day Streak',
                  icon: Icons.local_fire_department,
                  color: Color(0xFFF43F5E),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _Stat(
                  '24',
                  'Sacred Tracks',
                  icon: Icons.favorite,
                  color: Color(0xFF6366F1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const _ProfileAudioTabs(),
          const SizedBox(height: 14),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'RECENT MEDITATIONS',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 12,
                    height: 1.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .6,
                    color: _lightSlate,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F0FC),
                  borderRadius: BorderRadius.circular(AppRadii.card),
                ),
                child: const Text(
                  '3 Spiritual Sessions',
                  style: TextStyle(fontSize: 10, color: Color(0xFF7E3CB5)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < 3; i++) ...[
            _TrackRow(
              index: i,
              onPlay: (v) => ref.read(playingTrackProvider.notifier).play(v),
            ),
            const SizedBox(height: 12),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F2FC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEEE5FA)),
            ),
            child: const Row(
              children: [
                DesignIcon(
                  Icons.auto_awesome_outlined,
                  size: 16,
                  color: Color(0xFF8890A2),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '"When you do Meditation on Twin Hearts, divine energy flows into you, blessing the entire earth."',
                    style: TextStyle(
                      fontSize: 10,
                      height: 1.6,
                      color: Color(0xFF633C7C),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _Stat extends StatelessWidget {
  const _Stat(
    this.value,
    this.label, {
    required this.icon,
    required this.color,
  });
  final String value, label;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => _MedSurface(
    radius: 18,
    padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
    color: const Color(0xCCFFFFFF),
    child: Column(
      children: [
        DesignIcon(icon, size: 16, color: color),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            height: 1.5,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            height: 1.5,
            color: Color(0xFF70419A),
          ),
        ),
      ],
    ),
  );
}

class _ProfileAudioTabs extends StatelessWidget {
  const _ProfileAudioTabs();
  @override
  Widget build(BuildContext context) => _MedSurface(
    radius: 20,
    padding: const EdgeInsets.all(4),
    shadow: false,
    border: true,
    child: Row(
      children: [
        for (var i = 0; i < 3; i++)
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: i == 0 ? const Color(0xE6FFFFFF) : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadii.card),
                boxShadow: i == 0
                    ? const [
                        BoxShadow(
                          color: Color(0x06000000),
                          blurRadius: 3,
                          offset: Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (i == 0) ...[
                    const DesignIcon(
                      Icons.circle,
                      size: 5,
                      color: Color(0xFF8B4EB5),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Flexible(
                    child: Text(
                      ['Recently\nPlayed', 'Favorites', 'Downloads'][i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.4,
                        fontWeight: i == 0 ? FontWeight.w500 : FontWeight.w400,
                        color: i == 0 ? const Color(0xFF60317C) : _slate,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}

class _TrackRow extends StatelessWidget {
  const _TrackRow({required this.index, required this.onPlay});
  final int index;
  final ValueChanged<String> onPlay;
  @override
  Widget build(BuildContext context) {
    final title = [
      'Meditation on Twin Hearts',
      'Om Namah Shivaya Chanting',
      'Aura Cleansing Affirmation',
    ][index];
    return _MedSurface(
      radius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      shadow: false,
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const [
                        Color(0xFFA576E5),
                        Color(0xFFFFB531),
                        Color(0xFF24D2DF),
                      ][index],
                      const [
                        Color(0xFF9057CE),
                        Color(0xFFFF7F81),
                        Color(0xFFB68CDF),
                      ][index],
                    ],
                  ),
                ),
                child: DesignIcon(
                  [
                    Icons.radio_button_checked,
                    Icons.spa_outlined,
                    Icons.star_border,
                  ][index],
                  size: 26,
                  color: Colors.white,
                ),
              ),
              if (index == 0)
                const Positioned(
                  right: -4,
                  top: -4,
                  child: DesignIcon(
                    Icons.circle,
                    color: Color(0xFFF43F5E),
                    size: 12,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: const TextStyle(
                    fontFamily: 'Share Tech Mono',
                    fontSize: 13,
                    height: 1.5,
                    letterSpacing: .5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    'Master Choa Kok Sui',
                    'Sacred Resonance Mantra',
                    'Chakra Balance Guidance',
                  ][index],
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: _slate,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  [
                    'Played 21m ago   •   24 mins',
                    'Yesterday   •   18 mins',
                    '3 days ago   •   15 mins',
                  ][index],
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color: index == 0 ? const Color(0xFF9451C5) : _lightSlate,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: () => onPlay(title),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: index == 0
                    ? const Color(0xFF924EC0)
                    : const Color(0xFFF0F4F8),
                shape: BoxShape.circle,
                boxShadow: index == 0
                    ? const [
                        BoxShadow(
                          color: Color(0x20924EC0),
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: DesignIcon(
                Icons.play_arrow,
                size: 24,
                color: index == 0 ? Colors.white : const Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MusicSettingsPage extends ConsumerWidget {
  const MusicSettingsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Theme(
    data: meditationTheme().copyWith(
      textTheme: meditationTheme().textTheme.apply(
        fontFamily: 'Plus Jakarta Sans',
      ),
    ),
    child: Scaffold(
      backgroundColor: MeditationPalette.canvas,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppLayout.contentMaxWidth,
            ),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 42,
                        height: 42,
                        child: _RoundAction(
                          icon: Icons.arrow_back_rounded,
                          onTap: () => Navigator.pop(context),
                        ),
                      ),
                      const Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Settings & Practice',
                              style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 17,
                                height: 1.5,
                                letterSpacing: -.43,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              'PRANIC HEALING SANCTUARY',
                              style: TextStyle(
                                fontSize: 11,
                                height: 1.5,
                                color: Color(0xFF9B86F8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        tooltip: 'More options',
                        onSelected: (_) => Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst),
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'switch',
                            child: Text('Switch app'),
                          ),
                        ],
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Image.asset(
                            'assets/images/settings_emblem.png',
                            width: 26,
                            height: 26,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const _SettingsAccount(),
                const SizedBox(height: 20),
                const _SettingHead('PRACTICE & AUDIO'),
                const _SettingGroup(
                  rows: [
                    _SettingRow(
                      'Audio Quality & Binaural Beats',
                      'Hi-Res Lossless • 432 Hz',
                      Icons.volume_up_outlined,
                      tint: Color(0xFF745CF2),
                      tile: Color(0xFFF0ECFF),
                    ),
                    _SettingRow(
                      'Offline Sanctuary & Downloads',
                      '6 guided meditations available',
                      Icons.download_rounded,
                      tint: Color(0xFF9148E8),
                      tile: Color(0xFFF5E9FF),
                    ),
                    _SettingRow(
                      'Daily Sadhana Reminders',
                      'Twin Hearts • 6:30 AM Daily',
                      Icons.notifications_none_rounded,
                      tint: Color(0xFFE59100),
                      tile: Color(0xFFFFF3D1),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const _SettingHead('ACCOUNT & PREFERENCES'),
                const _SettingGroup(
                  rows: [
                    _SettingRow(
                      'Wishlist & Sacred Bookmarks',
                      '',
                      Icons.favorite_border_rounded,
                      tint: Color(0xFFEB4A98),
                      tile: Color(0xFFFFEAF4),
                      badge: '12 saved',
                    ),
                    _SettingRow(
                      'Language / भाषा',
                      '',
                      Icons.translate_rounded,
                      tint: Color(0xFF198BC5),
                      tile: Color(0xFFE5F4FF),
                      badge: 'English',
                    ),
                    _SettingRow(
                      'Security & Password',
                      '',
                      Icons.lock_outline_rounded,
                      tint: Color(0xFF6359EF),
                      tile: Color(0xFFE9EBFF),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const _SettingHead('PRANIC HEALING TRUST & INFO'),
                const _SettingGroup(
                  rows: [
                    _SettingRow(
                      'About Master Choa Kok Sui & Teachings',
                      '',
                      Icons.menu_book_outlined,
                      tint: Color(0xFF159E91),
                      tile: Color(0xFFDDF8F3),
                    ),
                    _SettingRow(
                      'Global Meditation Centers',
                      '',
                      Icons.public_rounded,
                      tint: Color(0xFF19A980),
                      tile: Color(0xFFE1FAEF),
                    ),
                    _SettingRow(
                      'Terms & Privacy Policy',
                      '',
                      Icons.description_outlined,
                      tint: Color(0xFF56647B),
                      tile: Color(0xFFF0F3F8),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete account?'),
                      content: const Text(
                        'Account deletion requires confirmation and a recent sign-in.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  ),
                  child: const _SettingsAction(
                    icon: Icons.delete_outline_rounded,
                    title: 'Delete Account & Data',
                    trailing: Icons.chevron_right_rounded,
                    isDestructive: true,
                  ),
                ),
                const SizedBox(height: 28),
                InkWell(
                  onTap: () async {
                    await ref.read(authProvider.notifier).signOut();
                    if (context.mounted) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  },
                  child: const _SettingsAction(
                    icon: Icons.logout_rounded,
                    title: 'LOGOUT',
                    detail: 'End Session',
                    trailing: Icons.arrow_forward_rounded,
                  ),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Column(
                    children: [
                      Text(
                        'Pranic Healing Sounds • v3.4.2 (2026)',
                        style: TextStyle(
                          color: Color(0xFF9BAAC1),
                          fontSize: 11,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Atma Namaste • Light and Love',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          color: Color(0xFFAD9CEB),
                          fontStyle: FontStyle.italic,
                          fontSize: 11,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _SettingsAccount extends ConsumerWidget {
  const _SettingsAccount();
  @override
  Widget build(BuildContext context, WidgetRef ref) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    decoration: BoxDecoration(
      gradient: const RadialGradient(
        center: Alignment.topRight,
        radius: 1.3,
        colors: [Color(0xFFFCE5F3), Color(0xE6FFFFFF)],
      ),
      borderRadius: BorderRadius.circular(AppRadii.card),
      border: Border.all(color: const Color(0xE6FFFFFF)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x146C5CE7),
          offset: Offset(0, 8),
          blurRadius: 32,
        ),
      ],
    ),
    child: Row(
      children: [
        const _SamyuAvatar(size: 54, circle: true, online: true),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Samyuktha J',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 17,
                  letterSpacing: -.4,
                  fontWeight: FontWeight.w600,
                  color: _ink,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'samyu@indosakura.com',
                style: TextStyle(color: Color(0xFF718097), fontSize: 12),
              ),
            ],
          ),
        ),
        Container(
          width: 64,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Color(0xFFE9D5FF)),
          ),
          child: const Text(
            'Edit  ›',
            style: TextStyle(
              fontSize: 12,
              color: MeditationPalette.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

class _SamyuAvatar extends StatelessWidget {
  const _SamyuAvatar({
    required this.size,
    this.badge = false,
    this.circle = false,
    this.online = false,
  });
  final double size;
  final bool badge;
  final bool circle, online;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(circle ? size / 2 : size * .18),
          child: SizedBox(
            width: size,
            height: size,
            child: Image.asset(
              'assets/images/samyu_profile.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (badge || online)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: size * (online ? .24 : .23),
              height: size * (online ? .24 : .23),
              decoration: BoxDecoration(
                color: online
                    ? const Color(0xFF2BD29F)
                    : MeditationPalette.accent,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: online
                  ? null
                  : const DesignIcon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 12,
                    ),
            ),
          ),
      ],
    ),
  );
}

class _SettingHead extends StatelessWidget {
  const _SettingHead(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 12, bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 11.5,
        height: 1.5,
        color: Color(0xFF64748B),
        fontWeight: FontWeight.w700,
        letterSpacing: .3,
      ),
    ),
  );
}

class _SettingGroup extends StatelessWidget {
  const _SettingGroup({required this.rows});
  final List<_SettingRow> rows;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(AppRadii.card),
      boxShadow: const [
        BoxShadow(
          color: Color(0x146C5CE7),
          offset: Offset(0, 8),
          blurRadius: 32,
        ),
      ],
      border: Border.all(color: const Color(0xD9FFFFFF)),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: ColoredBox(
        color: const Color(0xC7FFFFFF),
        child: Column(
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              rows[i],
              if (i < rows.length - 1)
                const Divider(
                  height: .5,
                  thickness: .5,
                  color: Color(0xFFF1EFF5),
                ),
            ],
          ],
        ),
      ),
    ),
  );
}

class _SettingRow extends StatelessWidget {
  const _SettingRow(
    this.title,
    this.detail,
    this.icon, {
    this.tint = MeditationPalette.primary,
    this.tile = const Color(0xFFF0ECFF),
    this.badge = '',
  });
  final String title, detail, badge;
  final IconData icon;
  final Color tint, tile;
  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(minHeight: detail.isEmpty ? 65.1667 : 66.5),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: tile,
              borderRadius: BorderRadius.circular(13),
            ),
            child: DesignIcon(icon, color: tint, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                    color: _ink,
                  ),
                ),
                if (detail.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      detail,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        height: 1.5,
                        color: Color(0xFF77869D),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (badge.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: badge == '12 saved'
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF5FF),
                        border: Border.all(color: const Color(0xFFEEDFFF)),
                        borderRadius: BorderRadius.circular(AppRadii.card),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF8B5CF6),
                        ),
                      ),
                    )
                  : Text(
                      badge,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF78849A),
                      ),
                    ),
            ),
          const SizedBox(width: 4),
          const DesignIcon(
            Icons.chevron_right_rounded,
            size: 18,
            color: Color(0xFF91A1B8),
          ),
        ],
      ),
    ),
  );
}

class _SettingsAction extends StatelessWidget {
  const _SettingsAction({
    required this.icon,
    required this.title,
    required this.trailing,
    this.detail = '',
    this.isDestructive = false,
  });
  final IconData icon, trailing;
  final String title, detail;
  final bool isDestructive;
  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? const Color(0xFFFF545D) : _ink;
    return Container(
      height: isDestructive ? 66 : 62,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(
          color: isDestructive ? const Color(0xFFFFE1E2) : Colors.white,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080C1020),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDestructive
                  ? const Color(0xFFFFF0F1)
                  : const Color(0xFFF0ECFF),
              borderRadius: BorderRadius.circular(AppRadii.input),
            ),
            child: DesignIcon(
              icon,
              size: 18,
              color: isDestructive ? color : MeditationPalette.primary,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: isDestructive ? 13.5 : 15,
                fontWeight: isDestructive ? FontWeight.w500 : FontWeight.w600,
                letterSpacing: isDestructive ? 0 : .5,
              ),
            ),
          ),
          if (detail.isNotEmpty)
            Text(
              detail,
              style: const TextStyle(color: Color(0xFF91A1B8), fontSize: 14),
            ),
          const SizedBox(width: 9),
          DesignIcon(
            trailing,
            color: isDestructive ? color : const Color(0xFF91A1B8),
          ),
        ],
      ),
    );
  }
}

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key, this.fallbackTitle});
  final String? fallbackTitle;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = ref.watch(playingTrackProvider) ?? fallbackTitle;
    if (title == null) return const SizedBox.shrink();
    return InkWell(
      onTap: () => showModalBottomSheet<void>(
        context: context,
        builder: (_) => _PlayerSheet(title: title),
      ),
      child: Container(
        height: 66,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xE60F172A),
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: const Color(0x33FFFFFF)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x59000000),
              blurRadius: 32,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6D28D9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const DesignIcon(
                      Icons.graphic_eq,
                      color: Color(0xFFC4B5FD),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            height: 1.4,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Text(
                          'Master Choa Kok Sui',
                          style: TextStyle(
                            fontSize: 9,
                            height: 1.4,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const DesignIcon(
                    Icons.favorite,
                    size: 17,
                    color: Color(0xFFEC4899),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () => ref.read(playingTrackProvider.notifier).stop(),
                    child: const DesignIcon(
                      Icons.pause_circle_filled,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const DesignIcon(
                    Icons.skip_next,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: const LinearProgressIndicator(
                value: .35,
                minHeight: 2,
                color: Color(0xFFA855F7),
                backgroundColor: Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerSheet extends StatelessWidget {
  const _PlayerSheet({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const DesignIcon(
            Icons.spa_rounded,
            size: 72,
            color: MeditationPalette.accent,
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text('Master Choa Kok Sui'),
          const SizedBox(height: 24),
          const LinearProgressIndicator(
            value: .35,
            color: MeditationPalette.primary,
          ),
          const SizedBox(height: 24),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DesignIcon(Icons.skip_previous, size: 32),
              SizedBox(width: 24),
              DesignIcon(
                Icons.pause_circle_filled,
                size: 52,
                color: MeditationPalette.primary,
              ),
              SizedBox(width: 24),
              DesignIcon(Icons.skip_next, size: 32),
            ],
          ),
        ],
      ),
    ),
  );
}

class _MeditationBottomDock extends StatelessWidget {
  const _MeditationBottomDock({required this.index, required this.onSelected});
  final int index;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final active = index == 3
        ? const Color(0xFF8B4BBC)
        : index == 2
        ? const Color(0xFF7E22CE)
        : MeditationPalette.primary;
    final inactive = index == 1 ? const Color(0xFF4B4859) : _lightSlate;
    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(
        horizontal: index == 0 ? 24 : 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xD9FFFFFF),
        borderRadius: BorderRadius.circular(index == 0 ? 24 : 32),
        border: Border.all(
          color: index == 1 ? const Color(0xFFECE7FF) : const Color(0xCCFFFFFF),
        ),
        boxShadow: [
          BoxShadow(
            color: index >= 2
                ? const Color(0x24000000)
                : const Color(0x1F4F46E5),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          for (var i = 0; i < 4; i++)
            Expanded(
              child: InkWell(
                onTap: () => onSelected(i),
                borderRadius: BorderRadius.circular(28),
                child: Center(
                  child: Container(
                    width: index == 2 ? 70 : null,
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    decoration: BoxDecoration(
                      color: index == 2 && i == 2
                          ? const Color(0xFFF1E7FC)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 5,
                          child: index == i && i == 3
                              ? Container(
                                  width: 24,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: active,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                )
                              : index == i && i == 2
                              ? DesignIcon(Icons.circle, size: 5, color: active)
                              : null,
                        ),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              decoration: index == 3 && i == 3
                                  ? const BoxDecoration(
                                      color: Color(0xFFF4ECFB),
                                      shape: BoxShape.circle,
                                    )
                                  : null,
                              child: DesignIcon(
                                [
                                  Icons.home_outlined,
                                  index == 3
                                      ? Icons.image_outlined
                                      : index == 2
                                      ? Icons.music_note_outlined
                                      : Icons.album_outlined,
                                  index == 3
                                      ? Icons.music_note_outlined
                                      : Icons.queue_music_rounded,
                                  index == i
                                      ? Icons.person
                                      : Icons.person_outline,
                                ][i],
                                size: 20,
                                color: index == i ? active : inactive,
                              ),
                            ),
                            if (index == i && i == 1)
                              Positioned(
                                right: -3,
                                top: -2,
                                child: DesignIcon(
                                  Icons.circle,
                                  size: 6,
                                  color: active,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          i == 1 && index == 3
                              ? 'Albums'
                              : i == 2 && index == 2
                              ? 'PlayLists'
                              : [
                                  'Home',
                                  'My Albums',
                                  'Playlists',
                                  'Profile',
                                ][i],
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: index == 1 ? 11 : 10,
                            height: 1.2,
                            letterSpacing: index == 3 && i == 3 ? 1.4 : 0,
                            fontWeight: index == i && index != 3
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: index == i ? active : inactive,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
