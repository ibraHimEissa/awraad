import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/book_data.dart';
import '../data/models.dart';
import '../services/storage_service.dart';

/// App-wide reading state (current page, bookmarks, resume message).
/// Mirrors the original BookViewModel.
class BookController extends ChangeNotifier {
  BookController(this._storage);

  final StorageService _storage;

  int _currentPage = 1;
  int get currentPage => _currentPage;

  List<Bookmark> _bookmarks = [];
  List<Bookmark> get bookmarks => List.unmodifiable(_bookmarks);

  List<Note> _notes = [];
  List<Note> get notes => List.unmodifiable(_notes);

  /// One-shot message shown on launch when resuming a previous page.
  String? resumeMessage;

  /// True until the first-launch guided tour has been completed or skipped.
  bool _shouldShowOnboarding = false;
  bool get shouldShowOnboarding => _shouldShowOnboarding;

  Timer? _saveDebounce;

  Future<void> load() async {
    await _storage.init();
    _shouldShowOnboarding = !_storage.onboardingSeen;
    _bookmarks = _storage.bookmarks;
    _notes = _storage.notes;
    final saved = _storage.lastPage;
    if (saved >= 1 && saved <= BookData.totalPages && saved != 1) {
      _currentPage = saved;
      resumeMessage = 'استأنفت من صفحة ${_arabic(BookData.toPrinted(saved))}';
    }
    notifyListeners();
  }

  TocSection get currentSection => BookData.sectionForPage(_currentPage);

  bool get isCurrentBookmarked => _bookmarks.any((b) => b.page == _currentPage);

  bool isBookmarked(int page) => _bookmarks.any((b) => b.page == page);

  void jumpToPage(int page) {
    if (page < 1 || page > BookData.totalPages || page == _currentPage) return;
    _currentPage = page;
    notifyListeners();
    _scheduleSave();
  }

  void toggleBookmark() {
    if (isCurrentBookmarked) {
      _bookmarks.removeWhere((b) => b.page == _currentPage);
    } else {
      _bookmarks.add(
        Bookmark(page: _currentPage, sectionTitle: currentSection.title),
      );
      _bookmarks.sort((a, b) => a.page.compareTo(b.page));
    }
    notifyListeners();
    _storage.saveBookmarks(_bookmarks);
  }

  void removeBookmark(int page) {
    _bookmarks.removeWhere((b) => b.page == page);
    notifyListeners();
    _storage.saveBookmarks(_bookmarks);
  }

  // ── Notes ─────────────────────────────────────────────────────────────
  Note? noteForPage(int page) {
    for (final n in _notes) {
      if (n.page == page) return n;
    }
    return null;
  }

  bool hasNote(int page) => noteForPage(page) != null;

  bool get currentHasNote => hasNote(_currentPage);

  /// Saves (or updates) the note for [page]. Empty text deletes it.
  void saveNote(int page, String text) {
    final trimmed = text.trim();
    _notes.removeWhere((n) => n.page == page);
    if (trimmed.isNotEmpty) {
      _notes.add(
        Note(
          page: page,
          sectionTitle: BookData.sectionForPage(page).title,
          text: trimmed,
        ),
      );
      _notes.sort((a, b) => a.page.compareTo(b.page));
    }
    notifyListeners();
    _storage.saveNotes(_notes);
  }

  void deleteNote(int page) {
    _notes.removeWhere((n) => n.page == page);
    notifyListeners();
    _storage.saveNotes(_notes);
  }

  void clearResumeMessage() {
    resumeMessage = null;
  }

  /// Marks the guided tour as seen so it never auto-opens again.
  void markOnboardingSeen() {
    if (!_shouldShowOnboarding) return;
    _shouldShowOnboarding = false;
    _storage.saveOnboardingSeen();
  }

  void _scheduleSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 500), () {
      _storage.saveLastPage(_currentPage);
    });
  }

  static String _arabic(int n) {
    const d = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return n.toString().split('').map((c) {
      final code = c.codeUnitAt(0);
      return (code >= 48 && code <= 57) ? d[code - 48] : c;
    }).join();
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    super.dispose();
  }
}
