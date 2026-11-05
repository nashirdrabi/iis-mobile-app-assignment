import 'package:shared_preferences/shared_preferences.dart';
import '../domain/playlist_repository.dart';

class PreferencesPlaylistRepository implements PlaylistRepository {
  PreferencesPlaylistRepository(this.preferences, {required this.owner});
  final SharedPreferences preferences;
  final String owner;
  String get _key => 'assignment.music.$owner.playlists';
  static const defaults = [
    'Daily Twin Hearts Routine',
    'Evening Aura Cleansing & Chakra Healing',
    'Arhatic Dhyan & Kundalini',
  ];
  @override
  List<String> read() => preferences.getStringList(_key) ?? List.of(defaults);
  @override
  Future<void> save(List<String> playlists) async {
    if (!await preferences.setStringList(_key, playlists)) {
      throw const FormatException(
        'Your playlist could not be saved. Please try again.',
      );
    }
  }
}
