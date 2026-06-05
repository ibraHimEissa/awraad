/// One poem (قصيدة) of the diwan. Poems are the diwan's natural table of
/// contents: each is known by its opening verse, its ordinal (الأُولى…), and —
/// in the first part — its rhyme name (التّائِيّة…). [page] is the 1-based PDF
/// page that opens it; [bookPage] is the number printed in the book.
class Poem {
  final int id;
  final int part;
  final String ordinal;
  final String? type;
  final String firstVerse;
  final int verseCount;
  final int bookPage;
  final int page; // internal PDF page (1-based)
  final String dateHijri;
  final String dateGregorian;

  const Poem({
    required this.id,
    required this.part,
    required this.ordinal,
    required this.type,
    required this.firstVerse,
    required this.verseCount,
    required this.bookPage,
    required this.page,
    required this.dateHijri,
    required this.dateGregorian,
  });

  /// A short human title: the rhyme name when present, else the ordinal.
  String get title => type ?? 'القصيدة $ordinal';

  /// A fuller one-line label: ordinal plus the rhyme name when present.
  /// e.g. «الأُولَى — التّائِيَّة» or «القصيدة الثَّانِيَة».
  String get label => type != null ? '$ordinal — $type' : 'القصيدة $ordinal';
}

/// A transient "find this verse" hint shown over the reader after the user
/// taps a search result. Because the diwan PDF is image-based we can't paint a
/// highlight onto the page itself, so we surface the exact verse text and its
/// number within the poem in a locator card — the eye finds it in seconds.
class VerseLocator {
  final int page; // PDF page the verse lives on
  final int verseNo; // verse number within its poem
  final String text; // the verse (both hemistichs)
  final String poemLabel; // e.g. «الأُولَى — التّائِيَّة»

  const VerseLocator({
    required this.page,
    required this.verseNo,
    required this.text,
    required this.poemLabel,
  });
}

/// A user bookmark on a given page.
class Bookmark {
  final int page;
  final String sectionTitle;

  const Bookmark({required this.page, required this.sectionTitle});

  String encode() => '$page|$sectionTitle';

  static Bookmark? decode(String raw) {
    final i = raw.indexOf('|');
    if (i <= 0) return null;
    final page = int.tryParse(raw.substring(0, i));
    if (page == null) return null;
    return Bookmark(page: page, sectionTitle: raw.substring(i + 1));
  }
}

/// A free-text note the user attaches to a specific page (e.g. a personal
/// reflection on a verse) so they can write it once and return to it.
class Note {
  final int page;
  final String sectionTitle;
  final String text;

  const Note({
    required this.page,
    required this.sectionTitle,
    required this.text,
  });

  Map<String, dynamic> toJson() => {
    'page': page,
    'section': sectionTitle,
    'text': text,
  };

  static Note? fromJson(Map<String, dynamic> j) {
    final page = j['page'];
    if (page is! int) return null;
    return Note(
      page: page,
      sectionTitle: (j['section'] ?? '') as String,
      text: (j['text'] ?? '') as String,
    );
  }
}
