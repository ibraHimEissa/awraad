import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../core/arabic.dart';
import '../model/book.dart';
import '../model/models.dart';
import '../model/outline.dart';
import '../widgets/islamic_pattern.dart';
import '../widgets/logo_watermark.dart';
import '../widgets/ornamental_divider.dart';
import '../widgets/sufi_logo.dart';

/// Generic Material 3 index drawer. Renders an outline's groups and entries —
/// flat sections (litany) or numbered poems with badges (diwan) — plus the
/// reader's bookmarks and a "how to use" entry.
class OutlineDrawer extends StatefulWidget {
  const OutlineDrawer({
    super.key,
    required this.book,
    required this.outline,
    required this.currentPage,
    required this.bookmarks,
    required this.onSelectPage,
    required this.onRemoveBookmark,
    required this.onClose,
    required this.onShowGuide,
  });

  final Book book;
  final BookOutline outline;
  final int currentPage;
  final List<Bookmark> bookmarks;
  final ValueChanged<int> onSelectPage;
  final ValueChanged<int> onRemoveBookmark;
  final VoidCallback onClose;
  final VoidCallback onShowGuide;

  @override
  State<OutlineDrawer> createState() => _OutlineDrawerState();
}

class _OutlineDrawerState extends State<OutlineDrawer> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final active = widget.outline.entryForPage(widget.currentPage);
    final q = normalizeArabic(_query);
    final visible = widget.outline.filter(q).map((e) => e.id).toSet();

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
                _Header(
                  title: widget.outline.drawerTitle,
                  subtitle:
                      '${toArabicNumerals(widget.outline.flat.length)} '
                      '${widget.book.kind == BookKind.diwan ? 'قصيدة' : 'بابًا'}',
                  topPad: topPad,
                  onClose: widget.onClose,
                  onGuide: widget.onShowGuide,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
                  child: TextField(
                    onChanged: (v) => setState(() => _query = v),
                    textAlign: TextAlign.right,
                    cursorColor: AppColors.gold,
                    decoration: InputDecoration(
                      hintText: widget.outline.searchFieldHint,
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: AppColors.gold),
                    ),
                  ),
                ),
                Expanded(
                  child: visible.isEmpty
                      ? const _Empty()
                      : ListView(
                          padding: const EdgeInsets.only(bottom: 24),
                          children: [
                            for (final group in widget.outline.groups)
                              ..._buildGroup(group, visible, active.id),
                            if (widget.bookmarks.isNotEmpty) ...[
                              const SizedBox(height: 18),
                              const _BookmarkHeader(),
                              for (final b in widget.bookmarks)
                                _BookmarkTile(
                                  book: widget.book,
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

  List<Widget> _buildGroup(
      OutlineGroup group, Set<int> visible, int activeId) {
    final entries = group.entries.where((e) => visible.contains(e.id)).toList();
    if (entries.isEmpty) return const [];
    return [
      if (group.title != null)
        _GroupHeader(title: group.title!, count: entries.length),
      for (final e in entries)
        _EntryTile(
          entry: e,
          isActive: e.id == activeId,
          onTap: () => widget.onSelectPage(e.page),
        ),
    ];
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.subtitle,
    required this.topPad,
    required this.onClose,
    required this.onGuide,
  });

  final String title;
  final String subtitle;
  final double topPad;
  final VoidCallback onClose;
  final VoidCallback onGuide;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, topPad + 8, 16, 14),
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
                onPressed: onGuide,
                tooltip: 'كيفية الاستخدام',
                icon: const Icon(Icons.help_outline_rounded,
                    color: AppColors.textMuted),
              ),
              const Spacer(),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded,
                    color: AppColors.textMuted),
              ),
            ],
          ),
          const SufiLogo(size: 44, showGlow: false),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontFamily: AppTheme.fontUi,
              fontWeight: FontWeight.w700,
              fontSize: 21,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
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
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.title, required this.count});
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
          const Icon(Icons.auto_stories_rounded,
              color: AppColors.greenLight, size: 16),
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
            toArabicNumerals(count),
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

class _EntryTile extends StatelessWidget {
  const _EntryTile({
    required this.entry,
    required this.isActive,
    required this.onTap,
  });

  final OutlineEntry entry;
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (entry.number != null)
                  _NumberDisc(number: entry.number!, isActive: isActive)
                else
                  Icon(Icons.bookmark_border_rounded,
                      size: 20,
                      color: isActive ? AppColors.gold : AppColors.textMuted),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: entry.number != null
                              ? AppTheme.fontScripture
                              : AppTheme.fontUi,
                          fontWeight: FontWeight.w700,
                          fontSize: entry.number != null ? 16 : 15,
                          height: 1.4,
                          color:
                              isActive ? AppColors.gold : AppColors.textPrimary,
                        ),
                      ),
                      if (entry.number != null || entry.badge != null) ...[
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Text(
                              entry.label,
                              style: const TextStyle(
                                fontFamily: AppTheme.fontUi,
                                fontSize: 11.5,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    Text(
                      entry.pageText,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontUi,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    if (entry.meta != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        entry.meta!,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontUi,
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
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

class _NumberDisc extends StatelessWidget {
  const _NumberDisc({required this.number, required this.isActive});
  final int number;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive
            ? AppColors.gold.withValues(alpha: 0.2)
            : AppColors.surface,
        border: Border.all(
          color: AppColors.gold.withValues(alpha: isActive ? 0.8 : 0.3),
        ),
      ),
      child: Text(
        toArabicNumerals(number),
        style: TextStyle(
          fontFamily: AppTheme.fontUi,
          fontWeight: FontWeight.w700,
          fontSize: 12,
          color: isActive ? AppColors.goldBright : AppColors.gold,
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        child: Text(
          'لا توجد نتيجة مطابقة لبحثك',
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
  const _BookmarkHeader();
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
    required this.book,
    required this.bookmark,
    required this.onTap,
    required this.onDelete,
  });

  final Book book;
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
                    'صفحة ${toArabicNumerals(book.toPrinted(bookmark.page))}',
                    style: const TextStyle(
                      fontFamily: AppTheme.fontUi,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    bookmark.label,
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
              icon: Icon(Icons.delete_outline_rounded,
                  color: AppColors.danger.withValues(alpha: 0.8), size: 20),
              tooltip: 'حذف',
            ),
          ],
        ),
      ),
    );
  }
}
