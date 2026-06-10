import 'package:flutter/material.dart';

import '../model/book.dart';
import '../model/outline.dart';
import '../model/search.dart';
import 'awrad/awrad_outline.dart';
import 'awrad/awrad_search.dart';
import 'diwan/diwan_outline.dart';
import 'diwan/diwan_search.dart';

/// A book plus its (lazily-built) outline and search engine.
class BookModule {
  final Book book;
  final BookOutline outline;
  final BookSearch search;
  const BookModule(this.book, this.outline, this.search);
}

/// The library: every book the app ships with. Add a third book by appending
/// one entry here and dropping its assets under `assets/books/<id>/`.
class Library {
  Library._();

  static const Book awrad = Book(
    id: 'awrad',
    title: 'كتاب الأوراد البرهانية',
    shortTitle: 'كتاب الأوراد',
    author: 'الطريقة البرهانية الدسوقية الشاذلية',
    subtitle: 'الأوراد والأحزاب اليومية',
    pdfAsset: 'assets/books/awrad/book.pdf',
    searchAsset: 'assets/books/awrad/search_index.json',
    totalPages: 137,
    kind: BookKind.litany,
    icon: Icons.auto_stories_rounded,
  );

  static const Book diwan = Book(
    id: 'diwan',
    title: 'ديوان شراب الوصل',
    shortTitle: 'ديوان شراب الوصل',
    author: 'الإمام فخر الدين محمد عثمان عبده البرهاني',
    subtitle: '٩٥ قصيدة في خمسة أجزاء',
    pdfAsset: 'assets/books/diwan/book.pdf',
    searchAsset: 'assets/books/diwan/search_index.json',
    totalPages: 268,
    kind: BookKind.diwan,
    icon: Icons.menu_book_rounded,
  );

  static final List<BookModule> modules = [
    BookModule(
      awrad,
      AwradOutline(awrad.toPrinted),
      AwradSearch(awrad.searchAsset),
    ),
    BookModule(
      diwan,
      DiwanOutline(diwan.toPrinted),
      DiwanSearch(diwan.searchAsset),
    ),
  ];

  static BookModule byId(String id) =>
      modules.firstWhere((m) => m.book.id == id, orElse: () => modules.first);
}
