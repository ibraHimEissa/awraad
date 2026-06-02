import 'models.dart';

/// Static book metadata for كتاب الأوراد البرهانية.
///
/// The bundled PDF (`assets/pdf/book.pdf`) has exactly [totalPages] pages,
/// displayed 1-based. Each [TocSection.page] points at the real PDF page
/// that opens the section.
class BookData {
  BookData._();

  static const int totalPages = 137;

  /// The book's printed folio number is one ahead of the PDF page index
  /// (PDF page 69 shows "٧٠" in the book). These helpers convert between the
  /// internal page (used for rendering + the index) and the number the user
  /// actually sees printed on the page — without touching the index itself.
  static int toPrinted(int page) => page + 1;
  static int fromPrinted(int printed) => printed - 1;
  static int get printedTotal => totalPages + 1;

  static const String bookTitle = 'كِتَابُ الْأَوْرَادِ';
  static const String orderName =
      'الطَّرِيقَةُ الْبُرْهَانِيَّةُ الدَّسُوقِيَّةُ الشَّاذِلِيَّةُ';
  static const String headerTitle = 'أوراد الطريقة البرهانية';

  static const List<TocSection> tableOfContents = [
    TocSection(id: 1, title: 'خاتمة الصلوات', page: 10),
    TocSection(id: 2, title: 'الأساس', page: 13),
    TocSection(id: 3, title: 'التحصين الشريف', page: 14),
    TocSection(id: 4, title: 'الحزب الكبير', page: 18),
    TocSection(id: 5, title: 'الحزب الصغير', page: 29),
    TocSection(id: 6, title: 'الصلاة المحمدية', page: 32),
    TocSection(id: 7, title: 'صلاة ابن بشيش', page: 34),
    TocSection(id: 8, title: 'الحزب السيفي', page: 38),
    TocSection(id: 9, title: 'الحزب المغني', page: 76),
    TocSection(id: 10, title: 'حزب البحر', page: 84),
    TocSection(id: 11, title: 'حزب النصر المبارك', page: 92),
    TocSection(id: 12, title: 'التوسل', page: 100),
    TocSection(id: 13, title: 'توسل السادة البرهانية', page: 107),
    TocSection(id: 14, title: 'سلسلة المشايخ الصغيرة', page: 123),
    TocSection(id: 15, title: 'سلسلة المشايخ الكبيرة', page: 124),
    TocSection(id: 16, title: 'الأوراد المربوطة', page: 126),
  ];

  /// The section that "owns" the given page (the last section whose page
  /// is <= [page]).
  static TocSection sectionForPage(int page) {
    var active = tableOfContents.first;
    for (final section in tableOfContents) {
      if (page >= section.page) active = section;
    }
    return active;
  }

  /// The first page of the section after [section], or [totalPages] + 1.
  static int nextSectionStart(TocSection section) {
    final idx = tableOfContents.indexWhere((s) => s.id == section.id);
    if (idx >= 0 && idx < tableOfContents.length - 1) {
      return tableOfContents[idx + 1].page;
    }
    return totalPages + 1;
  }
}
