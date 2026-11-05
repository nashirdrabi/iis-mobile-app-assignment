import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/palette.dart';
import '../../core/widgets/switch_experience_button.dart';
import '../auth/presentation/auth_state.dart';

const _kinInk = Color(0xFF202521);
const _kinMuted = Color(0xFF656D67);
const _kinTile = Color(0xFFF5F3EE);
const _kinPanel = Color(0xFFF0EEE9);
const _kinRust = Color(0xFF6F2A0C);

class KinTreeApp extends StatefulWidget {
  const KinTreeApp({super.key, this.initialTab = 0});
  final int initialTab;
  @override
  State<KinTreeApp> createState() => _KinTreeAppState();
}

class _KinTreeAppState extends State<KinTreeApp> {
  late int index = widget.initialTab;
  @override
  Widget build(BuildContext context) => Theme(
    data: ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: paper,
      colorScheme: ColorScheme.fromSeed(seedColor: forest, surface: paper),
      textTheme: ThemeData.light().textTheme.apply(
        fontFamily: 'Roboto',
        fontFamilyFallback: const ['Noto Sans Kannada', 'Noto Sans Devanagari'],
        bodyColor: _kinInk,
        displayColor: _kinInk,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide.none,
        ),
      ),
      dividerColor: const Color(0xFFECEAE5),
    ),
    child: Scaffold(
      backgroundColor: paper,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 448),
          child: IndexedStack(
            index: index,
            children: [
              KinTreeHome(onTree: () => setState(() => index = 1)),
              const FamilyTreePage(),
              const FamilyChatsPage(),
              const KinTreeProfilePage(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 448),
            child: _KinNavigation(
              index: index,
              onSelected: (v) => setState(() => index = v),
            ),
          ),
        ),
      ),
    ),
  );
}

class _KinNavigation extends StatelessWidget {
  const _KinNavigation({required this.index, required this.onSelected});
  final int index;
  final ValueChanged<int> onSelected;
  @override
  Widget build(BuildContext context) => Container(
    height: 88,
    padding: const EdgeInsets.fromLTRB(8, 11, 8, 26),
    decoration: const BoxDecoration(
      color: paper,
      boxShadow: [
        BoxShadow(
          color: Color(0x04000000),
          blurRadius: 18,
          offset: Offset(0, -8),
        ),
      ],
    ),
    child: Row(
      children: [
        for (var i = 0; i < 4; i++)
          Expanded(
            child: InkWell(
              onTap: () => onSelected(i),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        [
                          Icons.home_outlined,
                          Icons.account_tree_outlined,
                          Icons.chat_bubble_outline,
                          Icons.person_outline,
                        ][i],
                        size: 22,
                        color: index == i ? forest : const Color(0xFF4D5651),
                      ),
                      if (i == 2)
                        Positioned(
                          right: -7,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: _kinRust,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: const Text(
                              '3',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                height: 1,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    ['Home', 'Tree', 'Chat', 'Profile'][i],
                    style: TextStyle(
                      fontSize: 10,
                      height: 1.2,
                      fontWeight: index == i
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: index == i ? forest : const Color(0xFF4D5651),
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

class _KinHeader extends StatelessWidget {
  const _KinHeader(this.title);
  final String title;
  @override
  Widget build(BuildContext context) => Container(
    height: 64,
    decoration: const BoxDecoration(
      color: paper,
      boxShadow: [
        BoxShadow(
          color: Color(0x03000000),
          blurRadius: 8,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: LayoutBuilder(
      builder: (context, c) => Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: EdgeInsets.zero,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'KinTree',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: c.maxWidth < 360 ? 18 : 20,
                      color: forest,
                    ),
                  ),
                  TextSpan(
                    text: title,
                    style: TextStyle(
                      fontSize: c.maxWidth < 360 ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      color: _kinInk,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 20,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {},
                  constraints: const BoxConstraints.tightFor(
                    width: 36,
                    height: 40,
                  ),
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: Color(0xFF4D5651),
                    size: 21,
                  ),
                ),
                const SizedBox(width: 14),
                PopupMenuButton<String>(
                  tooltip: 'Profile and app options',
                  padding: EdgeInsets.zero,
                  onSelected: (_) =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'switch', child: Text('Switch app')),
                  ],
                  child: const _KinAvatar('kintree_header', size: 32),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _KinAvatar extends StatelessWidget {
  const _KinAvatar(this.asset, {this.size = 36});
  final String asset;
  final double size;
  @override
  Widget build(BuildContext context) => ClipOval(
    child: Image.asset(
      'assets/images/$asset.png',
      width: size,
      height: size,
      fit: BoxFit.cover,
    ),
  );
}

class _KinCard extends StatelessWidget {
  const _KinCard({
    required this.child,
    this.color = Colors.white,
    this.radius = 20,
    this.padding = const EdgeInsets.all(16),
    this.minHeight = 0,
  });
  final Widget child;
  final Color color;
  final double radius, minHeight;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(minHeight: minHeight),
    child: Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    ),
  );
}

class KinTreeHome extends StatelessWidget {
  const KinTreeHome({super.key, required this.onTree});
  final VoidCallback onTree;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: paper,
    body: SafeArea(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const _KinHeader('Home'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: _kinPanel,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, size: 8, color: forest),
                          SizedBox(width: 6),
                          Text(
                            'Sharma Heritage',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                            '(32)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _kinMuted,
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: _kinMuted,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Stack(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: _kinPanel,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_none_rounded,
                            size: 22,
                            color: _kinMuted,
                          ),
                        ),
                        const Positioned(
                          right: 5,
                          top: 4,
                          child: Icon(
                            Icons.circle,
                            size: 10,
                            color: Color(0xFFFFB69D),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Good Morning, Murphy',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 25,
                    height: 1.2,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Text(
                  'Stay connected with the Sharma Family sanctuary',
                  style: TextStyle(fontSize: 14, height: 1.4, color: _kinMuted),
                ),
                const SizedBox(height: 22),
                _LineageHero(onTree: onTree),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _KinAction(
                          Icons.add_photo_alternate_outlined,
                          'Add Memory',
                          'Artifacts & photos',
                          badge: 'New',
                          width: 144,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _KinAction(
                          Icons.mic_none_rounded,
                          'Record Story',
                          'Voice archives',
                          voice: true,
                          width: 128,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: onTree,
                        child: const _KinAction(
                          Icons.account_tree_outlined,
                          'View Tree',
                          'Branches & kin',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: _KinAction(
                        Icons.group_add_outlined,
                        'Invite Family',
                        'Grow your space',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const _ArchiveAssistant(),
                const SizedBox(height: 20),
                const _KinSectionHeading(
                  'From Your Family',
                  action: 'View All',
                  dot: true,
                ),
                const SizedBox(height: 20),
                const _FamilyStory(),
                const SizedBox(height: 16),
                const _FamilyStory(voice: true),
                const SizedBox(height: 24),
                const _KinSectionHeading(
                  'Upcoming Milestones',
                  action: 'Calendar',
                  icon: Icons.event_outlined,
                ),
                const SizedBox(height: 12),
                const _MilestoneCard(),
                const SizedBox(height: 12),
                const _MilestoneCard(anniversary: true),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _LineageHero extends StatelessWidget {
  const _LineageHero({required this.onTree});
  final VoidCallback onTree;
  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 196),
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: forest,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: Color(0x18000000),
          blurRadius: 6,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Stack(
      children: [
        const Positioned(
          right: -36,
          bottom: -58,
          child: Icon(Icons.auto_awesome, size: 210, color: Color(0x0CFFFFFF)),
        ),
        const Positioned(
          right: 24,
          top: 28,
          child: Icon(
            Icons.workspace_premium_outlined,
            size: 26,
            color: Color(0xFFFFAF94),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              const Text(
                'ANCESTRAL TREE',
                style: TextStyle(
                  fontSize: 11,
                  height: 1.4,
                  letterSpacing: .8,
                  color: Color(0xFF94B4A3),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'The Sharma Lineage',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 22,
                  height: 1.2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                '32 cherished members across 4 generations',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.3,
                  color: Color(0xFF95B19F),
                ),
              ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, c) {
                  final artWidth = math.min(164.0, c.maxWidth * .51);
                  return Row(
                    children: [
                      SizedBox(
                        width: artWidth,
                        height: 40,
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            for (var i = 0; i < 5; i++)
                              Positioned(
                                left: i * (artWidth - 36) / 5,
                                child: _KinAvatar(
                                  [
                                    'ancestor',
                                    'dadi',
                                    'father',
                                    'mother',
                                    'priya',
                                  ][i],
                                  size: 36,
                                ),
                              ),
                            Positioned(
                              right: 0,
                              child: Container(
                                width: 36,
                                height: 36,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEAEFE7),
                                  shape: BoxShape.circle,
                                ),
                                child: const Text(
                                  '+27',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: forest,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: onTree,
                        borderRadius: BorderRadius.circular(32),
                        child: Container(
                          width: math.min(128, c.maxWidth - artWidth),
                          height: 56,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: const Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Explore\nTree',
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.15,
                                    color: forest,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 20,
                                color: forest,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _KinAction extends StatelessWidget {
  const _KinAction(
    this.icon,
    this.title,
    this.subtitle, {
    this.badge,
    this.voice = false,
    this.width,
  });
  final IconData icon;
  final String title, subtitle;
  final String? badge;
  final bool voice;
  final double? width;
  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: 124,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _kinTile,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: voice ? _kinRust : const Color(0xFFDAE5DB),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 22, color: voice ? Colors.white : forest),
            ),
            const Spacer(),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFDBCF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    fontSize: 10,
                    color: _kinRust,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            if (voice)
              const Text(
                '••',
                style: TextStyle(
                  fontSize: 20,
                  color: _kinRust,
                  letterSpacing: 3,
                ),
              ),
          ],
        ),
        const Spacer(),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            height: 1.3,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          maxLines: 1,
          style: const TextStyle(fontSize: 13, color: _kinMuted, height: 1.25),
        ),
      ],
    ),
  );
}

class _ArchiveAssistant extends StatelessWidget {
  const _ArchiveAssistant();
  @override
  Widget build(BuildContext context) => _KinCard(
    color: _kinPanel,
    minHeight: 212,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: forest,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Family Archive\nAssistant',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Container(
              width: 84,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE4E2DD),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Text(
                '142\nRecords',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.1,
                  fontWeight: FontWeight.w600,
                  color: _kinMuted,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Ask questions directly from verified ancestral chronicles, letters, and voice capsules.',
          style: TextStyle(fontSize: 14, height: 1.35, color: _kinMuted),
        ),
        const SizedBox(height: 12),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, size: 18, color: _kinMuted),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "Try: 'Where did Dadi grow up in 1952?'",
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: TextStyle(fontSize: 13, color: _kinMuted),
                ),
              ),
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: forest,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send_outlined,
                  size: 17,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Row(
          children: [
            Icon(Icons.verified_outlined, size: 14, color: forest),
            SizedBox(width: 5),
            Expanded(
              child: Text(
                'Citing 3 authenticated voice diaries & land records',
                style: TextStyle(
                  fontSize: 11,
                  height: 1.3,
                  color: _kinMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _KinSectionHeading extends StatelessWidget {
  const _KinSectionHeading(
    this.title, {
    this.action,
    this.dot = false,
    this.icon,
  });
  final String title;
  final String? action;
  final bool dot;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 28,
    child: Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: forest),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 21,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
              if (dot) ...[
                const SizedBox(width: 8),
                const Icon(Icons.circle, size: 8, color: _kinRust),
              ],
            ],
          ),
        ),
        if (action != null) ...[
          const SizedBox(width: 10),
          Text(
            action!,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: forest,
            ),
          ),
        ],
      ],
    ),
  );
}

class _FamilyStory extends StatelessWidget {
  const _FamilyStory({this.voice = false});
  final bool voice;
  @override
  Widget build(BuildContext context) => _KinCard(
    minHeight: voice ? 276 : 445,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _KinAvatar(voice ? 'rajesh' : 'priya', size: 36),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: voice ? 'Rajesh Uncle' : 'Priya Sharma',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text: voice ? '  (Uncle)' : '  (Cousin)',
                          style: const TextStyle(
                            fontSize: 11,
                            color: _kinMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    voice ? 'Yesterday' : '2 hours ago',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _kinMuted,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: voice ? const Color(0xFFFFDBCF) : _kinPanel,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                voice ? '♩ Voice Capsule' : 'My Family',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: voice ? _kinRust : _kinMuted,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (!voice) ...[
          const Text(
            "Restored Grandmother's heirloom silver wedding paan-daan from 1958. Hearing her tell the story of bringing it on the train brought tears to our eyes.",
            style: TextStyle(fontSize: 14.5, height: 1.6),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              'assets/images/heirloom_reference.png',
              height: 208,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Reaction(Icons.favorite, '14', color: _kinRust),
              const SizedBox(width: 8),
              const _Reaction(Icons.chat_bubble_outline, '6'),
              const Spacer(),
              const Icon(Icons.bookmark_border, size: 20, color: _kinMuted),
            ],
          ),
        ] else ...[
          const Text(
            'Life in Old Bangalore during the\nmonsoon of 1968',
            style: TextStyle(fontFamily: 'Georgia', fontSize: 19, height: 1.1),
          ),
          const SizedBox(height: 6),
          const Text(
            '"...the tram bells were ringing past South End Circle, and we could smell roasted corn from miles down...',
            maxLines: 2,
            overflow: TextOverflow.clip,
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 13,
              height: 1.3,
              color: _kinMuted,
            ),
          ),
          const SizedBox(height: 12),
          const _VoicePlayer(),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Archived to: Bangalore Memories',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _kinMuted,
                  ),
                ),
              ),
              Text(
                'Read Transcript ↗',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: forest,
                ),
              ),
            ],
          ),
        ],
      ],
    ),
  );
}

class _Reaction extends StatelessWidget {
  const _Reaction(this.icon, this.value, {this.color = _kinMuted});
  final IconData icon;
  final String value;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    height: 32,
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      color: _kinTile,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        Icon(icon, size: 17, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

class _VoicePlayer extends StatelessWidget {
  const _VoicePlayer();
  @override
  Widget build(BuildContext context) => Container(
    height: 60,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: _kinPanel,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: forest,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.play_arrow_outlined,
            color: Colors.white,
            size: 23,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < 14; i++)
                Container(
                  width: 3,
                  height: const [
                    12.0,
                    20.0,
                    16.0,
                    26.0,
                    14.0,
                    22.0,
                    18.0,
                  ][i % 7],
                  decoration: BoxDecoration(
                    color: i < 5 ? forest : const Color(0xFFBFC8C1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        const Text(
          '3:42',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

class _MilestoneCard extends StatelessWidget {
  const _MilestoneCard({this.anniversary = false});
  final bool anniversary;
  @override
  Widget build(BuildContext context) => _KinCard(
    color: _kinTile,
    minHeight: anniversary ? 96 : 118,
    child: Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: anniversary
                ? const Color(0xFFDAE5DB)
                : const Color(0xFFFFDBCF),
            shape: BoxShape.circle,
          ),
          child: Icon(
            anniversary ? Icons.favorite_border : Icons.cake_outlined,
            color: anniversary ? forest : _kinRust,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      anniversary
                          ? 'Golden Anniversary'
                          : "Dadi's 84th\nBirthday",
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: anniversary ? 8 : 9,
                      vertical: anniversary ? 5 : 8,
                    ),
                    decoration: BoxDecoration(
                      color: anniversary ? _kinPanel : _kinRust,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Text(
                      anniversary ? 'Oct 14' : 'In 3\ndays',
                      style: TextStyle(
                        fontSize: 10,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                        color: anniversary ? _kinMuted : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                anniversary
                    ? 'Mohan & Sunita • 50 Years of Union'
                    : 'Oct 9 • Celebrating at Bangalore Residence',
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.3,
                  color: _kinMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        anniversary
            ? Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_comment_outlined,
                  size: 19,
                  color: _kinMuted,
                ),
              )
            : Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  'Send Note',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: forest,
                  ),
                ),
              ),
      ],
    ),
  );
}

class FamilyTreePage extends StatefulWidget {
  const FamilyTreePage({super.key});
  @override
  State<FamilyTreePage> createState() => _FamilyTreePageState();
}

class _FamilyTreePageState extends State<FamilyTreePage> {
  String branch = 'All Branches';
  final added = <String>[];
  Future<void> addMember() async {
    final name = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add family member'),
        content: TextField(
          controller: name,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, name.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    name.dispose();
    if (result != null && result.isNotEmpty) setState(() => added.add(result));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: paper,
    bottomSheet: const _SelectedFamilyMember(),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 180),
        children: [
          const _KinHeader('Family Tree'),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAE8E3),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.park, size: 20, color: forest),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Sharma Lineage\n(Direct)',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.2,
                                  fontWeight: FontWeight.w600,
                                  color: forest,
                                ),
                              ),
                            ),
                            Icon(Icons.keyboard_arrow_down, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    _TreeTool(Icons.search, onTap: () {}),
                    const SizedBox(width: 6),
                    _TreeTool(Icons.tune_rounded, onTap: () {}),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: addMember,
                      child: Container(
                        height: 30,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A3023),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.add, size: 16, color: Colors.white),
                            Text(
                              'Add',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 30,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAE8E3),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            for (final label in [
                              'All Branches',
                              'Maternal',
                              'Paternal',
                            ])
                              Expanded(
                                flex: label == 'All Branches' ? 14 : 11,
                                child: GestureDetector(
                                  onTap: () => setState(() => branch = label),
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: branch == label
                                          ? const Color(0xFF0A3023)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Text(
                                      label,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: branch == label
                                            ? Colors.white
                                            : _kinInk,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAE8E3),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add, size: 17),
                          SizedBox(width: 12),
                          Icon(Icons.remove, size: 17),
                          SizedBox(width: 12),
                          Icon(Icons.fullscreen, size: 17),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: 330,
                    child: ClipRect(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: 550,
                          height: 830,
                          child: Stack(
                            children: [
                              const Positioned.fill(
                                child: CustomPaint(
                                  painter: _FamilyConnections(),
                                ),
                              ),
                              const Positioned(
                                left: 180,
                                top: 0,
                                child: _GenerationLabel(
                                  'GENERATION I • ANCESTORS',
                                ),
                              ),
                              const Positioned(
                                left: 100,
                                top: 28,
                                child: _TreePerson(
                                  'Harishchandra S.',
                                  '1928–2010',
                                  'Pat. Grandfather',
                                  'ancestor',
                                  width: 160,
                                ),
                              ),
                              const Positioned(
                                left: 279,
                                top: 70,
                                child: _Marriage('m. 1952'),
                              ),
                              const Positioned(
                                left: 192,
                                top: 204,
                                child: _GenerationLabel(
                                  'GENERATION II • PARENTS',
                                ),
                              ),
                              const Positioned(
                                left: 44,
                                top: 232,
                                child: _TreePerson(
                                  'Mohan Sharma',
                                  'b. 1958',
                                  'Father',
                                  'father',
                                ),
                              ),
                              const Positioned(
                                left: 246,
                                top: 232,
                                child: _TreePerson(
                                  'Sunita Sharma',
                                  'b. 1960',
                                  'Mother',
                                  'mother',
                                ),
                              ),
                              const Positioned(
                                left: 193,
                                top: 278,
                                child: _Marriage('m. 1989'),
                              ),
                              const Positioned(
                                left: 168,
                                top: 406,
                                child: _GenerationLabel(
                                  'GENERATION III • PRESENT',
                                  present: true,
                                ),
                              ),
                              const Positioned(
                                left: 40,
                                top: 430,
                                child: _TreePerson(
                                  'Murphy Sharma',
                                  'b. 1993',
                                  'Tree Steward',
                                  'murphy_tree',
                                  selected: true,
                                  width: 152,
                                ),
                              ),
                              const Positioned(
                                left: 246,
                                top: 442,
                                child: _TreePerson(
                                  'Ananya Sharma',
                                  'b. 1995',
                                  'Spouse',
                                  'spouse',
                                ),
                              ),
                              const Positioned(
                                left: 192,
                                top: 480,
                                child: _Marriage('m. 2020'),
                              ),
                              const Positioned(
                                left: 180,
                                top: 628,
                                child: _GenerationLabel(
                                  'GENERATION IV • THE CHILDREN',
                                ),
                              ),
                              const Positioned(
                                left: 96,
                                top: 656,
                                child: _TreePerson(
                                  'Mira Sharma',
                                  'b. 2022',
                                  'Daughter',
                                  'daughter',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                for (final member in added)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _KinCard(child: Text('$member • Family member')),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _TreeTool extends StatelessWidget {
  const _TreeTool(this.icon, {required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(color: _kinPanel, shape: BoxShape.circle),
      child: Icon(icon, size: 20, color: _kinMuted),
    ),
  );
}

class _GenerationLabel extends StatelessWidget {
  const _GenerationLabel(this.label, {this.present = false});
  final String label;
  final bool present;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: present ? const Color(0xFFD7EEE2) : _kinPanel,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 10,
        height: 1,
        letterSpacing: .8,
        color: present ? forest : const Color(0xFF4D5651),
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _TreePerson extends StatelessWidget {
  const _TreePerson(
    this.name,
    this.birth,
    this.role,
    this.asset, {
    this.selected = false,
    this.width = 144,
  });
  final String name, birth, role, asset;
  final bool selected;
  final double width;
  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: selected ? 164 : 138,
    padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: selected ? const Color(0xFFB5E0C9) : const Color(0xFFF1EFEB),
        width: selected ? 2 : 1,
      ),
      boxShadow: selected
          ? const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 14,
                offset: Offset(0, 5),
              ),
            ]
          : null,
    ),
    child: Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            _KinAvatar(asset, size: selected ? 60 : 48),
            if (selected)
              Positioned(
                right: -5,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A3023),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'YOU',
                    style: TextStyle(
                      fontSize: 9,
                      letterSpacing: .8,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.clip,
          style: TextStyle(
            fontSize: 14,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          birth,
          style: const TextStyle(
            fontSize: 13,
            height: 1.2,
            color: Color(0xFF4D5651),
          ),
        ),
        const Spacer(),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: selected ? 10 : 7,
            vertical: selected ? 6 : 4,
          ),
          decoration: BoxDecoration(
            color: selected
                ? forest
                : role == 'Daughter'
                ? const Color(0xFFFFDBCF)
                : role == 'Father'
                ? const Color(0xFFBDE9D5)
                : _kinPanel,
            borderRadius: BorderRadius.circular(selected ? 18 : 4),
          ),
          child: Text(
            role,
            style: TextStyle(
              fontSize: 10,
              color: selected ? const Color(0xFFAAC2B5) : _kinInk,
            ),
          ),
        ),
      ],
    ),
  );
}

class _Marriage extends StatelessWidget {
  const _Marriage(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: Color(0xFFEAE8E3),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.favorite, size: 16, color: _kinRust),
      ),
      const SizedBox(height: 7),
      Text(
        label,
        style: const TextStyle(fontSize: 9, color: Color(0xFF4D5651)),
      ),
    ],
  );
}

class _FamilyConnections extends CustomPainter {
  const _FamilyConnections();
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFFC4CDC7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(310, 166)
      ..lineTo(310, 182)
      ..lineTo(220, 182)
      ..lineTo(220, 200)
      ..moveTo(220, 370)
      ..lineTo(220, 385)
      ..lineTo(164, 385)
      ..lineTo(164, 404)
      ..moveTo(310, 370)
      ..lineTo(310, 385)
      ..lineTo(220, 385);
    canvas.drawPath(path, p);
    final dark = Paint()
      ..color = forest
      ..strokeWidth = 2;
    canvas.drawLine(const Offset(164, 385), const Offset(164, 404), dark);
    canvas.drawLine(const Offset(205, 606), const Offset(205, 638), dark);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SelectedFamilyMember extends StatelessWidget {
  const _SelectedFamilyMember();
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      boxShadow: [
        BoxShadow(
          color: Color(0x08000000),
          blurRadius: 18,
          offset: Offset(0, -5),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFBFC8C1),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const _KinAvatar('tree_selected', size: 36),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Murphy Sharma',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Color(0xFFBFE9D7),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 4,
                                ),
                                child: Text(
                                  'You',
                                  style: TextStyle(
                                    fontSize: 10,
                                    height: 1,
                                    color: forest,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '32 yrs • Direct Heir • 18 Memories',
                    style: TextStyle(fontSize: 12, color: _kinMuted),
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: _kinPanel,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.more_vert, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            for (var i = 0; i < 4; i++)
              Expanded(
                child: Container(
                  height: 60,
                  margin: EdgeInsets.only(right: i == 3 ? 0 : 8),
                  padding: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: i == 3 ? _kinRust : _kinPanel,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: i == 3
                                  ? const Color(0xFF945C42)
                                  : Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              [
                                Icons.badge_outlined,
                                Icons.menu_book_outlined,
                                Icons.child_care,
                                Icons.mic_none_rounded,
                              ][i],
                              size: 18,
                              color: i == 3 ? Colors.white : forest,
                            ),
                          ),
                          if (i == 1)
                            Positioned(
                              right: -4,
                              top: -4,
                              child: Container(
                                width: 18,
                                height: 22,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: _kinRust,
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: const Text(
                                  '18',
                                  style: TextStyle(
                                    fontSize: 8,
                                    height: 1,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        [
                          'View Profile',
                          'Memories',
                          'Add Child',
                          'Voice Story',
                        ][i],
                        style: TextStyle(
                          fontSize: 9,
                          color: i == 3 ? Colors.white : _kinInk,
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
  );
}

class FamilyChatsPage extends StatefulWidget {
  const FamilyChatsPage({super.key});
  @override
  State<FamilyChatsPage> createState() => _FamilyChatsPageState();
}

class _FamilyChatsPageState extends State<FamilyChatsPage> {
  bool groups = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: paper,
    body: SafeArea(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const _KinHeader('Family Chat'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: _kinPanel,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.search, size: 18, color: _kinMuted),
                            SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                'Search family memories, chats & audio',
                                maxLines: 1,
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF919892),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _kinPanel,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.edit_square,
                        size: 20,
                        color: forest,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  height: 40,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _kinPanel,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      for (final entry in [
                        (false, 'Direct Messages', '3'),
                        (true, 'Family Groups', '2'),
                      ])
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => groups = entry.$1),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: groups == entry.$1
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      entry.$2,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: groups == entry.$1
                                            ? forest
                                            : _kinMuted,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: groups == entry.$1
                                          ? forest
                                          : const Color(0xFFE5E3DE),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      entry.$3,
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: groups == entry.$1
                                            ? Colors.white
                                            : _kinMuted,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 75,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFE6DC), _kinPanel, _kinPanel],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: _kinRust,
                        child: Icon(
                          Icons.mic_none_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'HEIRLOOM AUDIO •',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _kinRust,
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Dadi Savitri',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  TextSpan(text: ' recorded a voice note in '),
                                  TextSpan(
                                    text: 'The Sharma Circle',
                                    style: TextStyle(
                                      fontFamily: 'Georgia',
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                              style: TextStyle(fontSize: 12, height: 1.2),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward, size: 17, color: _kinMuted),
                    ],
                  ),
                ),
                const SizedBox(height: 13),
                LayoutBuilder(
                  builder: (context, c) {
                    final scale = c.maxWidth / 350;
                    return SizedBox(
                      height: 2174 * scale,
                      child: ClipRect(
                        child: OverflowBox(
                          alignment: Alignment.topLeft,
                          minWidth: 378 * scale,
                          maxWidth: 378 * scale,
                          minHeight: 2174 * scale,
                          maxHeight: 2174 * scale,
                          child: Image.asset(
                            'assets/images/chat_family_group.png',
                            width: 378 * scale,
                            height: 2174 * scale,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                for (var i = 0; i < 4; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _FamilyChatRow(index: i),
                  ),
                const SizedBox(height: 18),
                const Row(
                  children: [
                    Expanded(child: Divider(color: Color(0xFFEAE8E3))),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(
                        Icons.family_restroom,
                        size: 14,
                        color: Color(0xFF9BA49D),
                      ),
                    ),
                    Expanded(child: Divider(color: Color(0xFFEAE8E3))),
                  ],
                ),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: forest,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x18000000),
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_comment_outlined,
                          size: 17,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Start Conversation',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _FamilyChatRow extends StatelessWidget {
  const _FamilyChatRow({required this.index});
  final int index;
  @override
  Widget build(BuildContext context) {
    final names = [
      'Savitri Devi (Dadi)',
      'Mom (Sunita)',
      'Rahul Sharma (Brother)',
      'Sharma Heritage Archive',
    ];
    final subtitles = [
      'Voice capsule (0:48): Blessings for the family',
      'Did you check the recipe book update?',
      'I added Dad\'s college yearbook scans',
      "Murphy approved: Story ‘The 1970s’",
    ];
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ChatDetail(name: names[index])),
      ),
      child: _KinCard(
        radius: 12,
        minHeight: 76,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            if (index < 3)
              _KinAvatar(['dadi', 'sunita', 'rahul'][index], size: 48)
            else
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFDAE5DB),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.lock_outline, color: forest, size: 26),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    names[index],
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitles[index],
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: const TextStyle(fontSize: 11, color: _kinMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 7),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  ['Yesterday', '2d ago', 'Oct 1', 'Oct 2'][index],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: index == 0 ? _kinRust : _kinMuted,
                  ),
                ),
                const SizedBox(height: 7),
                if (index == 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFDBCF),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'AUDIO',
                      style: TextStyle(
                        fontSize: 8,
                        color: _kinRust,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else if (index == 3)
                  const Text(
                    'Curated',
                    style: TextStyle(fontSize: 8, color: _kinMuted),
                  )
                else
                  const Icon(Icons.done_all, size: 13, color: _kinMuted),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ChatDetail extends StatefulWidget {
  const ChatDetail({super.key, required this.name});
  final String name;
  @override
  State<ChatDetail> createState() => _ChatDetailState();
}

class _ChatDetailState extends State<ChatDetail> {
  final input = TextEditingController();
  final messages = <String>[
    'The old family album arrived today.',
    'That is wonderful! I will scan the photos this evening.',
  ];
  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.name),
      actions: const [SwitchExperienceButton(color: forest)],
    ),
    body: Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (var i = 0; i < messages.length; i++)
                Align(
                  alignment: i.isEven
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: i.isEven ? Colors.white : const Color(0xFFE5EEE8),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(messages[i]),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: input,
                  decoration: const InputDecoration(
                    hintText: 'Message',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  if (input.text.trim().isNotEmpty) {
                    setState(() {
                      messages.add(input.text.trim());
                      input.clear();
                    });
                  }
                },
                icon: const Icon(Icons.send, color: forest),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class KinTreeProfilePage extends ConsumerWidget {
  const KinTreeProfilePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;
    return Scaffold(
      backgroundColor: paper,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const _KinHeader('Profile'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 0),
                  Center(
                    child: Image.asset(
                      'assets/images/murphy_profile.jpg',
                      width: 118,
                      height: 125,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      user?.name ?? 'Murphy Sharma',
                      style: const TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 25,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const Center(
                    child: Text(
                      '+1 (555) •••-8392',
                      style: TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Container(
                      height: 22,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: forest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shield,
                            size: 12,
                            color: Color(0xFFFFB69D),
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Space Owner & Custodian',
                            style: TextStyle(
                              fontSize: 11,
                              letterSpacing: .3,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: InkWell(
                      onTap: () => _editName(
                        context,
                        ref,
                        user?.name ?? 'Murphy Sharma',
                      ),
                      child: Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAE8E3),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit_outlined, size: 17),
                            SizedBox(width: 6),
                            Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Row(
                    children: [
                      Text(
                        'My Family Spaces',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Spacer(),
                      Text(
                        '2 Active',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4D5651),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const _FamilySpaceCard(),
                  const SizedBox(height: 12),
                  const _FamilySpaceCard(other: true),
                  const SizedBox(height: 12),
                  Container(
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _kinTile,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_circle_outline, size: 19, color: forest),
                        SizedBox(width: 7),
                        Text(
                          'Create or Join Family Space',
                          style: TextStyle(
                            fontSize: 14,
                            color: forest,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const _FamilyVault(),
                  const SizedBox(height: 24),
                  const Text(
                    'Account & Privacy',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: ColoredBox(
                      color: Colors.white,
                      child: Column(
                        children: [
                          for (var i = 0; i < _privacyRows.length; i++) ...[
                            if (i > 0)
                              const Divider(
                                height: 1,
                                thickness: 1,
                                color: Color(0xFFF1F0ED),
                              ),
                            _PrivacyRow(_privacyRows[i]),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: TextButton.icon(
                      onPressed: () async {
                        await ref.read(authProvider.notifier).signOut();
                        if (context.mounted) {
                          Navigator.of(context).popUntil((r) => r.isFirst);
                        }
                      },
                      icon: const Icon(Icons.logout, size: 18, color: _kinRust),
                      label: const Text(
                        'Sign Out of KinTree',
                        style: TextStyle(fontSize: 15, color: _kinRust),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'KinTree Heritage v2.4 (Encrypted & Private)',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: .3,
                        color: _kinMuted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 70),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editName(
    BuildContext context,
    WidgetRef ref,
    String value,
  ) async {
    final controller = TextEditingController(text: value);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit profile'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Display name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name != null && name.trim().isNotEmpty) {
      await ref.read(authProvider.notifier).updateName(name);
    }
  }
}

class _FamilySpaceCard extends StatelessWidget {
  const _FamilySpaceCard({this.other = false});
  final bool other;
  @override
  Widget build(BuildContext context) => _KinCard(
    radius: 14,
    minHeight: other ? 110 : 136,
    color: other ? _kinTile : Colors.white,
    child: Column(
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 44,
              decoration: BoxDecoration(
                color: other
                    ? const Color(0xFFEAE8E3)
                    : const Color(0xFFDAE5DB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                other ? Icons.account_tree_outlined : Icons.groups,
                color: forest,
                size: 25,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    other ? 'Rao Ancestral\nLineage' : 'Sharma Heritage Space',
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    other
                        ? '18 members • Role:\nMember'
                        : '32 members • 142 memories\npreserved',
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: Color(0xFF4D5651),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (other) ...[
              const Text(
                'Switch\nspace',
                style: TextStyle(fontSize: 12, height: 1.35, color: forest),
              ),
              const SizedBox(width: 24),
              const Icon(Icons.arrow_forward, size: 18, color: forest),
            ] else
              const Align(
                alignment: Alignment.topCenter,
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: forest,
                  child: Icon(Icons.check, size: 16, color: Colors.white),
                ),
              ),
          ],
        ),
        if (!other) ...[
          const SizedBox(height: 12),
          Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: _kinTile,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Text(
                  'LINEAGE ROLE',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: .6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
                Text(
                  'Owner • Primary Vault',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: forest,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    ),
  );
}

class _FamilyVault extends StatelessWidget {
  const _FamilyVault();
  @override
  Widget build(BuildContext context) => _KinCard(
    color: _kinPanel,
    radius: 14,
    minHeight: 240,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.inventory_2_outlined, size: 20, color: forest),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Family Heritage Vault',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFDAE5DB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Pro Archival',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: .5,
                  color: Color(0xFF4D5651),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Row(
          children: [
            Expanded(
              child: Text(
                '14.8 GB of 50 GB used',
                style: TextStyle(fontSize: 13, color: Color(0xFF4D5651)),
              ),
            ),
            Text(
              '30% capacity',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: .3,
                fontWeight: FontWeight.w600,
                color: forest,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: const LinearProgressIndicator(
            value: .3,
            minHeight: 8,
            color: forest,
            backgroundColor: Color(0xFFE4E2DD),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Photos, 4K scans, High-fidelity voice capsules',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 12,
            color: _kinMuted,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          height: 64,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _kinTile,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            children: [
              Icon(Icons.auto_awesome, size: 20, color: _kinRust),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'AI Archival Assistant',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Active • Unlimited verified queries',
                      style: TextStyle(fontSize: 10, color: Color(0xFF4D5651)),
                    ),
                  ],
                ),
              ),
              Icon(Icons.circle, size: 8, color: Color(0xFFA9D1BB)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Manage Vault Plan ›',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: forest,
            ),
          ),
        ),
      ],
    ),
  );
}

const _privacyRows = [
  (Icons.badge_outlined, 'Personal Information & Pedigree', ''),
  (
    Icons.group_outlined,
    'Family Membership & Roles',
    'Admin, Member, Custodian',
  ),
  (
    Icons.lock_outline,
    'Privacy & Permissions',
    '“Only Me” vs “My Family” defaults',
  ),
  (
    Icons.translate,
    'Elder Storytelling & Transcription',
    'English / ಕನ್ನಡ (Kannada)',
  ),
  (Icons.notifications_active_outlined, 'Notifications & Memory Reminders', ''),
  (Icons.fingerprint, 'Security & Biometric FaceID', 'Enabled'),
  (Icons.menu_book_outlined, 'Help & Archival Guidance', ''),
];

class _PrivacyRow extends StatelessWidget {
  const _PrivacyRow(this.item);
  final (IconData, String, String) item;
  @override
  Widget build(BuildContext context) => Container(
    constraints: BoxConstraints(
      minHeight: item.$3.isEmpty || item.$3 == 'Enabled' ? 50 : 72,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    child: Row(
      children: [
        Icon(item.$1, size: 20, color: const Color(0xFF4D5651)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.$2, style: const TextStyle(fontSize: 14, height: 1.3)),
              if (item.$3.isNotEmpty && item.$3 != 'Enabled') ...[
                const SizedBox(height: 4),
                Text(
                  item.$3,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.35,
                    color: item.$1 == Icons.translate ? forest : _kinMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (item.$3 == 'Enabled')
          Container(
            margin: const EdgeInsets.only(left: 5),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFDAE5DB),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text('Enabled', style: TextStyle(fontSize: 10)),
          ),
        const SizedBox(width: 8),
        const Icon(Icons.chevron_right, size: 18, color: _kinMuted),
      ],
    ),
  );
}
