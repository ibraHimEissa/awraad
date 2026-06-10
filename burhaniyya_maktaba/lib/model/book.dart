import 'package:flutter/material.dart';

/// What kind of content a book holds — drives page-numbering, the outline
/// style (flat sections vs grouped poems) and the search style (OCR lines vs
/// verses with a locator).
enum BookKind { litany, diwan }

/// Pure descriptor of one book in the library. Page-mapping is encapsulated
/// here so the rest of the app only ever deals in internal 1-based PDF pages.
class Book {
  final String id; // 'awrad' | 'diwan' — also the storage namespace
  final String title;
  final String shortTitle;
  final String author;
  final String subtitle; // 'الأوراد اليومية' / '٩٥ قصيدة'
  final String pdfAsset;
  final String searchAsset;
  final int totalPages;
  final BookKind kind;
  final IconData icon;

  const Book({
    required this.id,
    required this.title,
    required this.shortTitle,
    required this.author,
    required this.subtitle,
    required this.pdfAsset,
    required this.searchAsset,
    required this.totalPages,
    required this.kind,
    required this.icon,
  });

  /// Internal PDF page → the number printed in the book.
  int toPrinted(int page) {
    switch (kind) {
      case BookKind.litany:
        return page + 1;
      case BookKind.diwan:
        // pdf = book-6 (book<=245) or book-7 (book>=248); unnumbered
        // separator at PDF 240 (start of part five).
        return page <= 240 ? page + 6 : page + 7;
    }
  }

  /// Printed number → internal PDF page (inverse of [toPrinted]).
  int fromPrinted(int printed) {
    switch (kind) {
      case BookKind.litany:
        return printed - 1;
      case BookKind.diwan:
        return printed <= 246 ? printed - 6 : printed - 7;
    }
  }

  int get printedTotal => toPrinted(totalPages);
  int get printedFirst => toPrinted(1);
}
