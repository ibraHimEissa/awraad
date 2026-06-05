import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../utils/arabic.dart';

/// One matched verse: which poem/verse it is, the page it sits on, and the
/// full (vocalised) verse text to show.
class VerseHit {
  final int page; // internal PDF page (1-based) to jump to
  final int poemId;
  final int verseNo;
  final String text; // display text (with tashkeel, شطران separated by *)

  const VerseHit({
    required this.page,
    required this.poemId,
    required this.verseNo,
    required this.text,
  });
}

class _IndexedVerse {
  final String text;
  final int page;
  final int poemId;
  final int verseNo;
  final String normalized; // normalised, for matching
  _IndexedVerse(
    this.text,
    this.page,
    this.poemId,
    this.verseNo,
    this.normalized,
  );
}

/// Loads the bundled verse index and runs tolerant full-text search over the
/// 2,682 verses of the diwan.
///
/// Both the index and the user's query are passed through [normalizeArabic],
/// so matching ignores tashkeel/tatweel and unifies alef/yaa/taa-marbuta/waw
/// letter forms — search forgives vocalisation and spelling variants.
class SearchIndex {
  SearchIndex._();
  static final SearchIndex instance = SearchIndex._();

  static const _assetPath = 'assets/search/search_index.json';

  final List<_IndexedVerse> _verses = [];
  bool _loaded = false;
  bool get isLoaded => _loaded;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final raw = await rootBundle.loadString(_assetPath);
    final data = jsonDecode(raw) as Map<String, dynamic>;
    for (final v in (data['verses'] as List)) {
      final map = v as Map<String, dynamic>;
      final text = map['t'] as String;
      final page = map['p'] as int;
      final poemId = map['q'] as int;
      final verseNo = map['n'] as int;
      // Re-normalise the bundled search field with the very same function we
      // apply to the query, so both sides are guaranteed consistent.
      final norm = normalizeArabic(map['s'] as String);
      _verses.add(_IndexedVerse(text, page, poemId, verseNo, norm));
    }
    _loaded = true;
  }

  /// Every verse whose normalised text contains the normalised [query].
  List<VerseHit> search(String query, {int limit = 200}) {
    final q = normalizeArabic(query);
    if (q.isEmpty) return const [];
    final hits = <VerseHit>[];
    for (final v in _verses) {
      if (v.normalized.contains(q)) {
        hits.add(
          VerseHit(
            page: v.page,
            poemId: v.poemId,
            verseNo: v.verseNo,
            text: v.text,
          ),
        );
        if (hits.length >= limit) break;
      }
    }
    return hits;
  }
}
