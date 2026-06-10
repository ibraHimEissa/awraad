import '../../core/arabic.dart';
import '../../model/outline.dart';

/// Table of contents for كتاب الأوراد — 16 flat sections over the 137-page PDF.
/// [toPrinted] maps the internal page to the printed folio for display.
class AwradOutline extends BookOutline {
  AwradOutline(int Function(int) toPrinted) {
    OutlineEntry e(int id, String title, int page) => OutlineEntry(
          id: id,
          page: page,
          title: title,
          label: title,
          pageText: 'ص ${toArabicNumerals(toPrinted(page))}',
        );
    _entries = [
      e(1, 'خاتمة الصلوات', 10),
      e(2, 'الأساس', 13),
      e(3, 'التحصين الشريف', 14),
      e(4, 'الحزب الكبير', 18),
      e(5, 'الحزب الصغير', 29),
      e(6, 'الصلاة المحمدية', 32),
      e(7, 'صلاة ابن بشيش', 34),
      e(8, 'الحزب السيفي', 38),
      e(9, 'الحزب المغني', 76),
      e(10, 'حزب البحر', 84),
      e(11, 'حزب النصر المبارك', 92),
      e(12, 'التوسل', 100),
      e(13, 'توسل السادة البرهانية', 107),
      e(14, 'سلسلة المشايخ الصغيرة', 123),
      e(15, 'سلسلة المشايخ الكبيرة', 124),
      e(16, 'الأوراد المربوطة', 126),
    ];
    _groups = [OutlineGroup(entries: _entries)];
  }

  late final List<OutlineEntry> _entries;
  late final List<OutlineGroup> _groups;

  @override
  List<OutlineGroup> get groups => _groups;

  @override
  List<OutlineEntry> get flat => _entries;

  @override
  String get drawerTitle => 'الفهرس';

  @override
  String get searchFieldHint => 'بحث في الفهرس...';

  @override
  List<OutlineEntry> filter(String q) {
    if (q.isEmpty) return _entries;
    return _entries
        .where((e) => normalizeArabic(e.title).contains(q))
        .toList();
  }

  @override
  String? groupTitleFor(OutlineEntry entry) => null;
}
