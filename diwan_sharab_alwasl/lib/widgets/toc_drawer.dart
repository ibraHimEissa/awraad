import 'package:flutter/material.dart';

import '../data/book_data.dart';
import '../data/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/arabic.dart';
import 'islamic_pattern.dart';
import 'logo_watermark.dart';
import 'ornamental_divider.dart';
import 'sufi_logo.dart';

/// The navigation drawer: an ornamental header, a local filter, the 95 poems
/// grouped under their five parts (each poem shown by its opening verse), and
/// the reader's saved bookmarks.
class TocDrawer extends StatefulWidget {
  const TocDrawer({
    super.key,
    required this.currentPage,
    required this.bookmarks,
    required this.onSelectPage,
    required this.onRemoveBookmark,
    required this.onClose,
    required this.onShowGuide,
  });

  final int currentPage;
  final List<Bookmark> bookmarks;
  final ValueChanged<int> onSelectPage;
  final ValueChanged<int> onRemoveBookmark;
  final VoidCallback onClose;
  final VoidCallback onShowGuide;

  @override
  State<TocDrawer> createState() => _TocDrawerState();
}

class _TocDrawerState extends State<TocDrawer> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final active = BookData.poemForPage(widget.currentPage);

    final q = normalizeArabic(_query);
    final poems = q.isEmpty
        ? BookData.poems
        : BookData.poems.where((p) {
            return normalizeArabic(p.firstVerse).contains(q) ||
                normalizeArabic(p.ordinal).contains(q) ||
                (p.type != null && normalizeArabic(p.type!).contains(q));
          }).toList();

    // Group the (possibly filtered) poems by their part, preserving order.
    final byPart = <int, List<Poem>>{};
    for (final p in poems) {
      byPart.putIfAbsent(p.part, () => []).add(p);
    }

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.86,
      backgroundColor: AppColors.drawerBg,
      shape: const RoundedRectangleBorder(),
      child: IslamicPatternBackground(
        opacity: 0.035,
        tile: 60,
        child: Stack(
          children: [
            const Positioned.fill(
              child: Center(child: LogoWatermark(size: 300, opacity: 0.05)),
            ),
            Column(
              children: [
                // Ornamental header
                Container(
                  padding: EdgeInsets.fromLTRB(16, topPad + 14, 16, 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.surface.withValues(alpha: 0.9),
                        AppColors.drawerBg.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: widget.onShowGuide,
                            visualDensity: VisualDensity.compact,
                            tooltip: 'كيفية الاستخدام',
                            icon: const Icon(
                              Icons.help_outline_rounded,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: widget.onClose,
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(
                              Icons.close_rounded,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SufiLogo(size: 48, showGlow: false),
                      const SizedBox(height: 8),
                      const Text(
                        'فهرس القصائد',
                        style: TextStyle(
                          fontFamily: AppTheme.fontUi,
                          fontWeight: FontWeight.w700,
                          fontSize: 21,
                          color: AppColors.gold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${toArabicNumerals(BookData.poems.length)} قصيدة',
                        style: const TextStyle(
                          fontFamily: AppTheme.fontUi,
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const OrnamentalDivider(),
                    ],
                  ),
                ),
                // Local search
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
                  child: _SearchField(
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
                // List
                Expanded(
                  child: poems.isEmpty
                      ? const _EmptyFilter()
                      : ListView(
                          padding: const EdgeInsets.only(bottom: 24),
                          children: [
                            for (final part in byPart.keys) ...[
                              _PartHeader(
                                title: BookData.partNames[part] ?? '',
                                count: byPart[part]!.length,
                              ),
                              for (final p in byPart[part]!)
                                _PoemTile(
                                  poem: p,
                                  isActive: p.id == active.id,
                                  onTap: () => widget.onSelectPage(p.page),
                                ),
                            ],
                            if (widget.bookmarks.isNotEmpty) ...[
                              const SizedBox(height: 18),
                              _BookmarkHeader(),
                              for (final b in widget.bookmarks)
                                _BookmarkTile(
                                  bookmark: b,
                                  onTap: () => widget.onSelectPage(b.page),
                                  onDelete: () =>
                                      widget.onRemoveBookmark(b.page),
                                ),
                            ],
                          ],
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      textAlign: TextAlign.right,
      style: const TextStyle(
        fontFamily: AppTheme.fontUi,
        fontSize: 15,
        color: AppColors.textPrimary,
      ),
      cursorColor: AppColors.gold,
      decoration: const InputDecoration(
        hintText: 'ابحث عن قصيدة بمطلعها...',
        prefixIcon: Icon(Icons.search_rounded, color: AppColors.gold),
      ),
    );
  }
}

class _PartHeader extends StatelessWidget {
  const _PartHeader({required this.title, required this.count});
  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 2),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.surface.withValues(alpha: 0.45),
      child: Row(
        children: [
          const Icon(
            Icons.auto_stories_rounded,
            color: AppColors.greenLight,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontFamily: AppTheme.fontUi,
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppColors.greenLight,
            ),
          ),
          const Spacer(),
          Text(
            '${toArabicNumerals(count)} قصيدة',
            style: const TextStyle(
              fontFamily: AppTheme.fontUi,
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _PoemTile extends StatelessWidget {
  const _PoemTile({
    required this.poem,
    required this.isActive,
    required this.onTap,
  });

  final Poem poem;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: isActive
            ? AppColors.gold.withValues(alpha: 0.14)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.rLg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.rLg),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ordinal disc
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? AppColors.gold.withValues(alpha: 0.2)
                        : AppColors.surface,
                    border: Border.all(
                      color: AppColors.gold.withValues(
                        alpha: isActive ? 0.8 : 0.3,
                      ),
                    ),
                  ),
                  child: Text(
                    toArabicNumerals(poem.id),
                    style: TextStyle(
                      fontFamily: AppTheme.fontUi,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: isActive ? AppColors.goldBright : AppColors.gold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // First verse (the poem's recognisable title)
                      Text(
                        poem.firstVerse,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTheme.fontScripture,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          height: 1.5,
                          color: isActive
                              ? AppColors.gold
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            'القصيدة ${poem.ordinal}',
                            style: const TextStyle(
                              fontFamily: AppTheme.fontUi,
                              fontSize: 11.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                          if (poem.type != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.emerald.withValues(
                                  alpha: 0.16,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                poem.type!,
                                style: const TextStyle(
                                  fontFamily: AppTheme.fontUi,
                                  fontSize: 10.5,
                                  color: AppColors.greenLight,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Page badge
                Column(
                  children: [
                    Text(
                      'ص ${toArabicNumerals(poem.bookPage)}',
                      style: const TextStyle(
                        fontFamily: AppTheme.fontUi,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${toArabicNumerals(poem.verseCount)} بيت',
                      style: const TextStyle(
                        fontFamily: AppTheme.fontUi,
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyFilter extends StatelessWidget {
  const _EmptyFilter();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 40, horizontal: 24),
    child: Text(
      'لا توجد قصيدة مطابقة لبحثك',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: AppTheme.fontUi,
        fontSize: 14,
        color: AppColors.textMuted,
      ),
    ),
  );
}

class _BookmarkHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: const [
              Icon(Icons.bookmark_rounded, color: AppColors.gold, size: 18),
              SizedBox(width: 8),
              Text(
                'الإشارات المرجعية',
                style: TextStyle(
                  fontFamily: AppTheme.fontUi,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
        ),
        Container(height: 1, color: AppColors.gold.withValues(alpha: 0.2)),
      ],
    );
  }
}

class _BookmarkTile extends StatelessWidget {
  const _BookmarkTile({
    required this.bookmark,
    required this.onTap,
    required this.onDelete,
  });

  final Bookmark bookmark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 12, 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'صفحة ${toArabicNumerals(BookData.toPrinted(bookmark.page))}',
                    style: const TextStyle(
                      fontFamily: AppTheme.fontUi,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    bookmark.sectionTitle,
                    style: const TextStyle(
                      fontFamily: AppTheme.fontUi,
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onDelete,
              icon: Icon(
                Icons.delete_outline_rounded,
                color: AppColors.danger.withValues(alpha: 0.8),
                size: 20,
              ),
              tooltip: 'حذف',
            ),
          ],
        ),
      ),
    );
  }
}
