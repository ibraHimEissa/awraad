import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models.dart';

/// Thin wrapper over [SharedPreferences] for persisting reading state.
class StorageService {
  static const _kLastPage = 'last_page';
  static const _kBookmarks = 'bookmarks';
  static const _kNotes = 'notes';
  static const _kOnboardingSeen = 'onboarding_seen';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  int get lastPage => _prefs?.getInt(_kLastPage) ?? 1;

  Future<void> saveLastPage(int page) async {
    await _prefs?.setInt(_kLastPage, page);
  }

  /// Whether the first-launch guided tour has already been shown.
  bool get onboardingSeen => _prefs?.getBool(_kOnboardingSeen) ?? false;

  Future<void> saveOnboardingSeen() async {
    await _prefs?.setBool(_kOnboardingSeen, true);
  }

  List<Bookmark> get bookmarks {
    final raw = _prefs?.getStringList(_kBookmarks) ?? const [];
    return raw.map(Bookmark.decode).whereType<Bookmark>().toList()
      ..sort((a, b) => a.page.compareTo(b.page));
  }

  Future<void> saveBookmarks(List<Bookmark> bookmarks) async {
    await _prefs?.setStringList(
      _kBookmarks,
      bookmarks.map((b) => b.encode()).toList(),
    );
  }

  List<Note> get notes {
    final raw = _prefs?.getString(_kNotes);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      return list.map(Note.fromJson).whereType<Note>().toList()
        ..sort((a, b) => a.page.compareTo(b.page));
    } catch (_) {
      return [];
    }
  }

  Future<void> saveNotes(List<Note> notes) async {
    await _prefs?.setString(
      _kNotes,
      jsonEncode(notes.map((n) => n.toJson()).toList()),
    );
  }
}
