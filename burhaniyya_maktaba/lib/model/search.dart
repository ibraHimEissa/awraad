/// One search match within a book.
class SearchHit {
  final int page; // internal PDF page to jump to
  final String text; // the line/verse to show
  final String? context; // section title / poem label
  final int? verseNo; // set for verse books → enables the locator card

  const SearchHit({
    required this.page,
    required this.text,
    this.context,
    this.verseNo,
  });
}

/// Full-text search over a book. Each book loads its own bundled index and
/// matches with the shared Arabic normaliser.
abstract class BookSearch {
  Future<void> ensureLoaded();
  bool get isLoaded;

  List<SearchHit> search(String query, {int limit});

  String get title; // sheet title, e.g. «بحث في الأبيات»
  String get hint; // text-field hint
  String get emptyWord; // noun for "no results": «أبيات» / «مواضع»

  /// Verse books surface a locator card on tap; line books just jump.
  bool get usesLocator;
}
