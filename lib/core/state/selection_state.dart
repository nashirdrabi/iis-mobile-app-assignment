import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ephemeral selections belong to Riverpod and disappear with their screen.
final selectionProvider = NotifierProvider.autoDispose
    .family<SelectionController, String, (String, String)>(
      SelectionController.new,
    );

class SelectionController extends Notifier<String> {
  SelectionController(this.key);
  final (String, String) key;
  @override
  String build() => key.$2;
  void select(String value) => state = value;
}

final temporaryListProvider = NotifierProvider.autoDispose
    .family<TemporaryListController, List<String>, String>(
      TemporaryListController.new,
    );

class TemporaryListController extends Notifier<List<String>> {
  TemporaryListController(this.key);
  final String key;
  @override
  List<String> build() => key.startsWith('chat:')
      ? [
          'The old family album arrived today.',
          'That is wonderful! I will scan the photos this evening.',
        ]
      : [];
  void add(String value) {
    if (value.trim().isNotEmpty) state = [...state, value.trim()];
  }
}
