import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/models.dart';

/// Persists reading state. Per-book state (last page, bookmarks, notes) is
/// namespaced by the book id, so each book in the library remembers its own
/// place independently. App-wide flags (onboarding) are global.
class Storage {
  Storage._();
  static final Storage instance = Storage._();

  static const _kSeenOnboarding = 'seen_onboarding';
  static const _kLastBook = 'last_book';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ── App-wide ────────────────────────────────────────────────────────────
  bool get seenOnboarding => _prefs?.getBool(_kSeenOnboarding) ?? false;
  Future<void> setSeenOnboarding() async =>
      _prefs?.setBool(_kSeenOnboarding, true);

  String? get lastBook => _prefs?.getString(_kLastBook);
  Future<void> setLastBook(String id) async => _prefs?.setString(_kLastBook, id);

  // ── Per-book ──────────────────────────────────────────────────────────────
  int lastPage(String bookId) => _prefs?.getInt('$bookId.last_page') ?? 1;
  Future<void> saveLastPage(String bookId, int page) async =>
      _prefs?.setInt('$bookId.last_page', page);

  List<Bookmark> bookmarks(String bookId) {
    final raw = _prefs?.getStringList('$bookId.bookmarks') ?? const [];
    return raw.map(Bookmark.decode).whereType<Bookmark>().toList()
      ..sort((a, b) => a.page.compareTo(b.page));
  }

  Future<void> saveBookmarks(String bookId, List<Bookmark> b) async =>
      _prefs?.setStringList(
        '$bookId.bookmarks',
        b.map((e) => e.encode()).toList(),
      );

  List<Note> notes(String bookId) {
    final raw = _prefs?.getString('$bookId.notes');
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      return list.map(Note.fromJson).whereType<Note>().toList()
        ..sort((a, b) => a.page.compareTo(b.page));
    } catch (_) {
      return [];
    }
  }

  Future<void> saveNotes(String bookId, List<Note> notes) async =>
      _prefs?.setString(
        '$bookId.notes',
        jsonEncode(notes.map((n) => n.toJson()).toList()),
      );

  bool hasProgress(String bookId) => (_prefs?.getInt('$bookId.last_page') ?? 1) > 1;
}
