import '../../core/arabic.dart';
import '../../model/outline.dart';
import 'diwan_poems.g.dart';

/// Table of contents for ديوان شراب الوصل — 95 poems grouped under five parts.
class DiwanOutline extends BookOutline {
  DiwanOutline(int Function(int) toPrinted) {
    String labelOf(DiwanPoem p) =>
        p.type != null ? '${p.ordinal} — ${p.type}' : 'القصيدة ${p.ordinal}';

    OutlineEntry entry(DiwanPoem p) => OutlineEntry(
          id: p.id,
          page: p.page,
          title: p.firstVerse,
          badge: p.type,
          label: labelOf(p),
          number: p.id,
          pageText: 'ص ${toArabicNumerals(p.bookPage)}',
          meta: '${toArabicNumerals(p.verseCount)} بيت',
        );

    _flat = kDiwanPoems.map(entry).toList();
    _entryPart = {for (final p in kDiwanPoems) p.id: p.part};

    final byPart = <int, List<OutlineEntry>>{};
    for (final p in kDiwanPoems) {
      byPart.putIfAbsent(p.part, () => []).add(entry(p));
    }
    _groups = [
      for (final part in byPart.keys)
        OutlineGroup(title: kDiwanParts[part], entries: byPart[part]!),
    ];
  }

  late final List<OutlineEntry> _flat;
  late final List<OutlineGroup> _groups;
  late final Map<int, int> _entryPart;

  @override
  List<OutlineGroup> get groups => _groups;

  @override
  List<OutlineEntry> get flat => _flat;

  @override
  String get drawerTitle => 'فهرس القصائد';

  @override
  String get searchFieldHint => 'ابحث عن قصيدة بمطلعها...';

  @override
  List<OutlineEntry> filter(String q) {
    if (q.isEmpty) return _flat;
    return _flat.where((e) {
      return normalizeArabic(e.title).contains(q) ||
          normalizeArabic(e.label).contains(q) ||
          (e.badge != null && normalizeArabic(e.badge!).contains(q));
    }).toList();
  }

  @override
  String? groupTitleFor(OutlineEntry entry) => kDiwanParts[_entryPart[entry.id]];
}
