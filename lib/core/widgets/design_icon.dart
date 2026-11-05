import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Outline artwork uses the same 24px line icon proportions as the Figma UI.
class DesignIcon extends StatelessWidget {
  const DesignIcon(this.icon, {super.key, this.size, this.color});
  final IconData? icon;
  final double? size;
  final Color? color;
  static final _assets = <IconData, String>{
    Icons.home_outlined: 'house',
    Icons.history_rounded: 'clock',
    Icons.album_outlined: 'disc-3',
    Icons.image_outlined: 'image',
    Icons.person_outline: 'user-round',
    Icons.person_outline_rounded: 'user-round',
    Icons.arrow_back_rounded: 'chevron-left',
    Icons.chevron_right_rounded: 'chevron-right',
    Icons.search_rounded: 'search',
    Icons.volume_up_outlined: 'volume-2',
    Icons.download_rounded: 'download',
    Icons.notifications_none_rounded: 'bell',
    Icons.favorite_border_rounded: 'heart',
    Icons.favorite_border: 'heart',
    Icons.translate_rounded: 'languages',
    Icons.lock_outline_rounded: 'lock-keyhole',
    Icons.menu_book_outlined: 'book-open',
    Icons.public_rounded: 'globe',
    Icons.description_outlined: 'clipboard-list',
    Icons.delete_outline_rounded: 'trash-2',
    Icons.logout_rounded: 'log-out',
    Icons.arrow_forward_rounded: 'arrow-right',
    Icons.add: 'plus',
    Icons.menu_rounded: 'menu',
    Icons.tune_rounded: 'sliders-horizontal',
    Icons.star_border: 'star',
    Icons.schedule: 'clock',
    Icons.shuffle_rounded: 'shuffle',
  };
  @override
  Widget build(BuildContext context) {
    final asset = _assets[icon];
    final theme = IconTheme.of(context);
    if (asset == null) return Icon(icon, size: size, color: color);
    final dimension = size ?? theme.size ?? 24;
    return Center(
      widthFactor: 1,
      heightFactor: 1,
      child: SvgPicture.asset(
        'assets/icons/$asset.svg',
        width: dimension,
        height: dimension,
        colorFilter: ColorFilter.mode(
          color ?? theme.color ?? Colors.black,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
