import 'package:flutter/services.dart';

Future<void> loadDesignFonts() async {
  final families = <String, List<String>>{
    'Inter': [
      'Inter-400.ttf',
      'Inter-500.ttf',
      'Inter-600.ttf',
      'Inter-700.ttf',
    ],
    'Plus Jakarta Sans': [
      for (final w in [400, 500, 600, 700]) 'PlusJakartaSans-$w.ttf',
    ],
    'Sora': ['Sora-600.ttf'],
    'Playfair Display': ['PlayfairDisplay-600.ttf'],
    'Georgia': [
      'Georgia-Regular.ttf',
      'Georgia-Bold.ttf',
      'Georgia-Italic.ttf',
    ],
    'Roboto': ['Roboto-Regular.ttf', 'Roboto-Bold.ttf'],
    'Share Tech Mono': ['ShareTechMono-Regular.ttf'],
    'Noto Sans Devanagari': ['NotoSansDevanagari-Variable.ttf'],
    'Noto Sans Kannada': ['NotoSansKannada-Variable.ttf'],
  };
  for (final entry in families.entries) {
    final loader = FontLoader(entry.key);
    for (final file in entry.value) {
      loader.addFont(rootBundle.load('assets/fonts/$file'));
    }
    await loader.load();
  }
  await (FontLoader(
    'MaterialIcons',
  )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
}
