import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_state.dart';
import '../data/preferences_playlist_repository.dart';
import '../domain/playlist_repository.dart';

final playlistRepositoryProvider = Provider<PlaylistRepository>(
  (ref) => PreferencesPlaylistRepository(
    ref.watch(preferencesProvider),
    owner: ref.watch(authProvider).value?.id ?? 'guest',
  ),
  dependencies: [preferencesProvider, authProvider],
);
final playlistsProvider = NotifierProvider<PlaylistsController, List<String>>(
  PlaylistsController.new,
  dependencies: [playlistRepositoryProvider],
);

class PlaylistsController extends Notifier<List<String>> {
  @override
  List<String> build() => ref.watch(playlistRepositoryProvider).read();
  Future<void> add(String value) async {
    final name = value.trim();
    if (name.isEmpty) return;
    final next = [name, ...state];
    await ref.read(playlistRepositoryProvider).save(next);
    state = next;
  }
}

final playingTrackProvider = NotifierProvider<PlayingTrackController, String?>(
  PlayingTrackController.new,
);

class PlayingTrackController extends Notifier<String?> {
  @override
  String? build() => null;
  void play(String track) => state = track;
  void stop() => state = null;
}
