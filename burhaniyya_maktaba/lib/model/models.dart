/// A user bookmark on a page within a book.
class Bookmark {
  final int page;
  final String label; // the section/poem that owns the page

  const Bookmark({required this.page, required this.label});

  String encode() => '$page|$label';

  static Bookmark? decode(String raw) {
    final i = raw.indexOf('|');
    if (i <= 0) return null;
    final page = int.tryParse(raw.substring(0, i));
    if (page == null) return null;
    return Bookmark(page: page, label: raw.substring(i + 1));
  }
}

/// A free-text note attached to a specific page within a book.
class Note {
  final int page;
  final String label;
  final String text;

  const Note({required this.page, required this.label, required this.text});

  Map<String, dynamic> toJson() => {'page': page, 'label': label, 'text': text};

  static Note? fromJson(Map<String, dynamic> j) {
    final page = j['page'];
    if (page is! int) return null;
    return Note(
      page: page,
      label: (j['label'] ?? j['section'] ?? '') as String,
      text: (j['text'] ?? '') as String,
    );
  }
}

/// A transient "find this verse" hint shown over the reader after tapping a
/// search result in a verse-based book (the diwan). Because the PDF is image
/// based we can't highlight on the page, so we surface the verse text + its
/// number so the eye finds it.
class VerseLocator {
  final int page;
  final int verseNo;
  final String text;
  final String context; // e.g. poem label

  const VerseLocator({
    required this.page,
    required this.verseNo,
    required this.text,
    required this.context,
  });
}
