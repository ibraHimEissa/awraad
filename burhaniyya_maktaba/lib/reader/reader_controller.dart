import 'dart:async';
import 'package:flutter/foundation.dart';

import '../books/library_books.dart';
import '../core/arabic.dart';
import '../core/storage.dart';
import '../model/book.dart';
import '../model/models.dart';
import '../model/outline.dart';

/// Per-book reading state (current page, bookmarks, notes, resume + locator).
/// One instance is created per opened book; all state persists under the
/// book's id namespace via [Storage].
class ReaderController extends ChangeNotifier {
  ReaderController(this.module);

  final BookModule module;
  Book get book => module.book;
  BookOutline get outline => module.outline;

  int _currentPage = 1;
  int get currentPage => _currentPage;

  List<Bookmark> _bookmarks = [];
  List<Bookmark> get bookmarks => List.unmodifiable(_bookmarks);

  List<Note> _notes = [];
  List<Note> get notes => List.unmodifiable(_notes);

  String? resumeMessage;

  VerseLocator? _verseLocator;
  VerseLocator? get verseLocator => _verseLocator;

  Timer? _saveDebounce;

  Future<void> load() async {
    await Storage.instance.init();
    final id = book.id;
    _bookmarks = Storage.instance.bookmarks(id);
    _notes = Storage.instance.notes(id);
    final saved = Storage.instance.lastPage(id);
    if (saved >= 1 && saved <= book.totalPages && saved != 1) {
      _currentPage = saved;
      resumeMessage =
          'استأنفت من صفحة ${toArabicNumerals(book.toPrinted(saved))}';
    }
    Storage.instance.setLastBook(id);
    notifyListeners();
  }

  OutlineEntry get currentEntry => outline.entryForPage(_currentPage);

  bool get isCurrentBookmarked => _bookmarks.any((b) => b.page == _currentPage);

  void jumpToPage(int page) {
    if (page < 1 || page > book.totalPages || page == _currentPage) return;
    if (_verseLocator != null && _verseLocator!.page != page) {
      _verseLocator = null;
    }
    _currentPage = page;
    notifyListeners();
    _scheduleSave();
  }

  void showVerse(VerseLocator locator) {
    _verseLocator = locator;
    if (locator.page != _currentPage) {
      jumpToPage(locator.page);
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
      _bookmarks.add(Bookmark(page: _currentPage, label: currentEntry.label));
      _bookmarks.sort((a, b) => a.page.compareTo(b.page));
    }
    notifyListeners();
    Storage.instance.saveBookmarks(book.id, _bookmarks);
  }

  void removeBookmark(int page) {
    _bookmarks.removeWhere((b) => b.page == page);
    notifyListeners();
    Storage.instance.saveBookmarks(book.id, _bookmarks);
  }

  Note? noteForPage(int page) {
    for (final n in _notes) {
      if (n.page == page) return n;
    }
    return null;
  }

  bool hasNote(int page) => noteForPage(page) != null;
  bool get currentHasNote => hasNote(_currentPage);

  void saveNote(int page, String text) {
    final trimmed = text.trim();
    _notes.removeWhere((n) => n.page == page);
    if (trimmed.isNotEmpty) {
      _notes.add(Note(
        page: page,
        label: outline.entryForPage(page).label,
        text: trimmed,
      ));
      _notes.sort((a, b) => a.page.compareTo(b.page));
    }
    notifyListeners();
    Storage.instance.saveNotes(book.id, _notes);
  }

  void deleteNote(int page) {
    _notes.removeWhere((n) => n.page == page);
    notifyListeners();
    Storage.instance.saveNotes(book.id, _notes);
  }

  void clearResumeMessage() => resumeMessage = null;

  void _scheduleSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 500), () {
      Storage.instance.saveLastPage(book.id, _currentPage);
    });
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    super.dispose();
  }
}
