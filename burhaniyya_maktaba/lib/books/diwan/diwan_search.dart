import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../../core/arabic.dart';
import '../../model/search.dart';
import 'diwan_poems.g.dart';

class _Verse {
  final String text;
  final int page;
  final int verseNo;
  final String normalized;
  final String context;
  _Verse(this.text, this.page, this.verseNo, this.normalized, this.context);
}

/// Verse-based search over the 2,682 verses of the diwan. Tolerant Arabic
/// matching; results carry the verse number so the reader can raise a locator.
class DiwanSearch implements BookSearch {
  DiwanSearch(this.assetPath);
  final String assetPath;

  final List<_Verse> _verses = [];
  bool _loaded = false;

  @override
  bool get isLoaded => _loaded;

  @override
  String get title => 'بحث في الأبيات';
  @override
  String get hint => 'اكتب كلمة أو شطرًا من بيت…';
  @override
  String get emptyWord => 'أبيات';
  @override
  bool get usesLocator => true;

  @override
  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final labels = <int, String>{
      for (final p in kDiwanPoems)
        p.id: p.type != null ? '${p.ordinal} — ${p.type}' : 'القصيدة ${p.ordinal}',
    };
    final raw = await rootBundle.loadString(assetPath);
    final data = jsonDecode(raw) as Map<String, dynamic>;
    for (final v in (data['verses'] as List)) {
      final m = v as Map<String, dynamic>;
      _verses.add(_Verse(
        m['t'] as String,
        m['p'] as int,
        m['n'] as int,
        normalizeArabic(m['s'] as String),
        labels[m['q'] as int] ?? '',
      ));
    }
    _loaded = true;
  }

  @override
  List<SearchHit> search(String query, {int limit = 200}) {
    final q = normalizeArabic(query);
    if (q.isEmpty) return const [];
    final hits = <SearchHit>[];
    for (final v in _verses) {
      if (v.normalized.contains(q)) {
        hits.add(SearchHit(
          page: v.page,
          text: v.text,
          context: v.context,
          verseNo: v.verseNo,
        ));
        if (hits.length >= limit) break;
      }
    }
    return hits;
  }
}
