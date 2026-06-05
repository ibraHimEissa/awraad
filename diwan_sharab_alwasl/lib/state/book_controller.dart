import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/book_data.dart';
import '../data/models.dart';
import '../services/storage_service.dart';

/// App-wide reading state (current page, bookmarks, notes, resume message).
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

  bool _seenOnboarding = false;
  bool get seenOnboarding => _seenOnboarding;

  /// The verse the reader jumped to from search — shown as a locator card over
  /// the page until dismissed or the user turns to another page.
  VerseLocator? _verseLocator;
  VerseLocator? get verseLocator => _verseLocator;

  Timer? _saveDebounce;

  Future<void> load() async {
    await _storage.init();
    _seenOnboarding = _storage.seenOnboarding;
    _bookmarks = _storage.bookmarks;
    _notes = _storage.notes;
    final saved = _storage.lastPage;
    if (saved >= 1 && saved <= BookData.totalPages && saved != 1) {
      _currentPage = saved;
      resumeMessage = 'استأنفت من صفحة ${_arabic(BookData.toPrinted(saved))}';
    }
    notifyListeners();
  }

  /// The poem that owns the current page.
  Poem get currentPoem => BookData.poemForPage(_currentPage);

  bool get isCurrentBookmarked => _bookmarks.any((b) => b.page == _currentPage);

  bool isBookmarked(int page) => _bookmarks.any((b) => b.page == page);

  void jumpToPage(int page) {
    if (page < 1 || page > BookData.totalPages || page == _currentPage) return;
    // Turning to a different page than the located verse dismisses the card.
    if (_verseLocator != null && _verseLocator!.page != page) {
      _verseLocator = null;
    }
    _currentPage = page;
    notifyListeners();
    _scheduleSave();
  }

  /// Jump to (and locate) a specific verse picked from search.
  void showVerse(VerseLocator locator) {
    _verseLocator = locator;
    if (locator.page != _currentPage) {
      jumpToPage(locator.page); // notifies (and keeps the locator we just set)
    } else {
      notifyListeners();
    }
  }

  void clearVerseLocator() {
    if (_verseLocator == null) return;
    _verseLocator = null;
    notifyListeners();
  }

  void toggleBookmark() {
    if (isCurrentBookmarked) {
      _bookmarks.removeWhere((b) => b.page == _currentPage);
    } else {
      _bookmarks.add(
        Bookmark(page: _currentPage, sectionTitle: currentPoem.label),
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
          sectionTitle: BookData.poemForPage(page).label,
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

  Future<void> markOnboardingSeen() async {
    _seenOnboarding = true;
    await _storage.setSeenOnboarding();
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
