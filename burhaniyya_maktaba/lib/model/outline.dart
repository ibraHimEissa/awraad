/// One navigable entry in a book's table of contents — a section (litany) or
/// a poem (diwan). Optional fields let one generic drawer/indicator render
/// both styles.
class OutlineEntry {
  final int id;
  final int page; // internal PDF page that opens it
  final String title; // section name, or a poem's opening verse
  final String? badge; // e.g. rhyme name «التّائِيّة»
  final String label; // one-line label used for bookmarks/indicator
  final int? number; // leading number shown in a disc (poem id)
  final String pageText; // pre-formatted, e.g. «ص ٤٢»
  final String? meta; // small trailing meta, e.g. «٤٢٣ بيت»

  const OutlineEntry({
    required this.id,
    required this.page,
    required this.title,
    required this.label,
    required this.pageText,
    this.badge,
    this.number,
    this.meta,
  });
}

/// A group of entries (a part of the diwan); litany books use a single
/// untitled group.
class OutlineGroup {
  final String? title;
  final List<OutlineEntry> entries;
  const OutlineGroup({this.title, required this.entries});
}

/// The table of contents for a book, plus the helpers the reader needs to
/// know "which entry owns this page" and how far through it we are.
abstract class BookOutline {
  List<OutlineGroup> get groups;
  List<OutlineEntry> get flat;

  String get drawerTitle; // «الفهرس» / «فهرس القصائد»
  String get searchFieldHint; // drawer's local filter hint

  /// Filter entries by a normalised query (for the drawer's search box).
  List<OutlineEntry> filter(String normalizedQuery);

  /// The entry that owns [page] (last entry whose page <= [page]).
  OutlineEntry entryForPage(int page) {
    var active = flat.first;
    for (final e in flat) {
      if (page >= e.page) active = e;
    }
    return active;
  }

  /// First page of the entry after [entry], or totalPages + 1.
  int nextStart(OutlineEntry entry, int totalPages) {
    final i = flat.indexWhere((e) => e.id == entry.id);
    if (i >= 0 && i < flat.length - 1) return flat[i + 1].page;
    return totalPages + 1;
  }

  /// The group title that contains [entry] (null for flat books).
  String? groupTitleFor(OutlineEntry entry);
}
