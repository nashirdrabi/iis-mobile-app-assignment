abstract interface class PlaylistRepository {
  List<String> read();
  Future<void> save(List<String> playlists);
}
