/// A chapter / section entry in the table of contents.
class TocSection {
  final int id;
  final String title;

  /// The actual 1-based PDF page that contains this section's opening.
  final int page;

  const TocSection({required this.id, required this.title, required this.page});
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
/// du'a they say at that spot) so they can write it once and return to it.
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
