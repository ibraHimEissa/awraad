import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../../model/search.dart';

class _Line {
  final String original;
  final String normalized;
  _Line(this.original, this.normalized);
}

class _Page {
  final int page;
  final List<_Line> lines;
  _Page(this.page, this.lines);
}

/// Line-based OCR search for كتاب الأوراد. Diacritic-insensitive and tolerant
/// of letter variants; returns a focused snippet around each match.
///
/// Uses a private 1:1 normaliser (no whitespace collapsing) so the snippet
/// offset map stays aligned with the original text.
class AwradSearch implements BookSearch {
  AwradSearch(this.assetPath);
  final String assetPath;

  final List<_Page> _pages = [];
  bool _loaded = false;

  @override
  bool get isLoaded => _loaded;

  @override
  String get title => 'بحث في الكتاب';
  @override
  String get hint => 'اكتب كلمة أو جملة من الكتاب…';
  @override
  String get emptyWord => 'مواضع';
  @override
  bool get usesLocator => false;

  @override
  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final raw = await rootBundle.loadString(assetPath);
    final data = jsonDecode(raw) as Map<String, dynamic>;
    for (final p in (data['pages'] as List)) {
      final map = p as Map<String, dynamic>;
      final page = map['p'] as int;
      final lines = <_Line>[];
      for (final line in (map['lines'] as List).cast<String>()) {
        lines.add(_Line(line, _normalize(line)));
      }
      _pages.add(_Page(page, lines));
    }
    _loaded = true;
  }

  @override
  List<SearchHit> search(String query, {int limit = 120}) {
    final q = _normalize(query).trim();
    if (q.isEmpty) return const [];
    final hits = <SearchHit>[];
    for (final p in _pages) {
      for (final line in p.lines) {
        if (line.normalized.contains(q)) {
          hits.add(SearchHit(page: p.page, text: _snippet(line.original, q)));
          if (hits.length >= limit) return hits;
        }
      }
    }
    return hits;
  }

  // ── 1:1 normalisation (kept private; no whitespace collapse) ─────────────
  static bool _isDropped(int r) =>
      (r >= 0x0610 && r <= 0x061A) ||
      (r >= 0x064B && r <= 0x065F) ||
      r == 0x0670 ||
      r == 0x0640 ||
      r == 0x0621;

  static int _mapChar(int c) {
    if (c == 0x0622 || c == 0x0623 || c == 0x0625 || c == 0x0671) return 0x0627;
    if (c == 0x0649) return 0x064A;
    if (c == 0x0629) return 0x0647;
    if (c == 0x0624) return 0x0648;
    if (c == 0x0626) return 0x064A;
    return c;
  }

  static String _normalize(String input) {
    final out = StringBuffer();
    for (final r in input.runes) {
      if (_isDropped(r)) continue;
      out.writeCharCode(_mapChar(r));
    }
    return out.toString();
  }

  static String _snippet(String original, String nq, {int pad = 45}) {
    final norm = StringBuffer();
    final map = <int>[];
    var origPos = 0;
    for (final r in original.runes) {
      final charLen = String.fromCharCode(r).length;
      if (!_isDropped(r)) {
        norm.writeCharCode(_mapChar(r));
        map.add(origPos);
      }
      origPos += charLen;
    }
    final normStr = norm.toString();
    final at = normStr.indexOf(nq);
    if (at < 0 || map.isEmpty) {
      return original.length <= 90 ? original : '${original.substring(0, 90)}…';
    }
    final origStart = map[at];
    final endIdx = (at + nq.length - 1).clamp(0, map.length - 1);
    final origEnd = map[endIdx] + 1;

    var s = (origStart - pad).clamp(0, original.length);
    var e = (origEnd + pad).clamp(0, original.length);
    final sp = original.indexOf(' ', s);
    if (sp != -1 && sp < origStart) s = sp + 1;
    final ep = original.lastIndexOf(' ', e);
    if (ep != -1 && ep > origEnd) e = ep;

    var snippet = original.substring(s, e).trim();
    if (s > 0) snippet = '…$snippet';
    if (e < original.length) snippet = '$snippet…';
    return snippet;
  }
}
