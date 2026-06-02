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

/// The right-side navigation drawer: an ornamental header, a local filter,
/// the table of contents with per-section progress, and saved bookmarks.
class TocDrawer extends StatefulWidget {
  const TocDrawer({
    super.key,
    required this.currentPage,
    required this.bookmarks,
    required this.onSelectPage,
    required this.onRemoveBookmark,
    required this.onClose,
  });

  final int currentPage;
  final List<Bookmark> bookmarks;
  final ValueChanged<int> onSelectPage;
  final ValueChanged<int> onRemoveBookmark;
  final VoidCallback onClose;

  @override
  State<TocDrawer> createState() => _TocDrawerState();
}

class _TocDrawerState extends State<TocDrawer> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final active = BookData.sectionForPage(widget.currentPage);
    final sections = _query.isEmpty
        ? BookData.tableOfContents
        : BookData.tableOfContents
              .where((s) => s.title.contains(_query))
              .toList();

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
              child: Center(
                child: LogoWatermark(size: 300, opacity: 0.05),
              ),
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
                      // Close button pinned to the top-left corner
                      SizedBox(
                        width: double.infinity,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: widget.onClose,
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(
                              Icons.close_rounded,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                      const SufiLogo(size: 48, showGlow: false),
                      const SizedBox(height: 8),
                      const Text(
                        'الفهرس',
                        style: TextStyle(
                          fontFamily: AppTheme.fontUi,
                          fontWeight: FontWeight.w700,
                          fontSize: 21,
                          color: AppColors.gold,
                          letterSpacing: 0.5,
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
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      for (final s in sections)
                        _SectionTile(
                          section: s,
                          isActive: s.id == active.id,
                          currentPage: widget.currentPage,
                          onTap: () => widget.onSelectPage(s.page),
                        ),
                      if (widget.bookmarks.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        _BookmarkHeader(),
                        for (final b in widget.bookmarks)
                          _BookmarkTile(
                            bookmark: b,
                            onTap: () => widget.onSelectPage(b.page),
                            onDelete: () => widget.onRemoveBookmark(b.page),
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
      decoration: InputDecoration(
        hintText: 'بحث في الفهرس...',
        hintStyle: const TextStyle(
          fontFamily: AppTheme.fontUi,
          color: AppColors.textMuted,
          fontSize: 14,
        ),
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.gold),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.gold.withValues(alpha: 0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.gold),
        ),
      ),
    );
  }
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({
    required this.section,
    required this.isActive,
    required this.currentPage,
    required this.onTap,
  });

  final TocSection section;
  final bool isActive;
  final int currentPage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final nextStart = BookData.nextSectionStart(section);
    double progress;
    if (currentPage < section.page) {
      progress = 0;
    } else if (currentPage >= nextStart) {
      progress = 1;
    } else {
      final range = (nextStart - section.page).clamp(1, BookData.totalPages);
      progress = (currentPage - section.page) / range;
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.gold.withValues(alpha: 0.12)
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: AppColors.textMuted.withValues(alpha: 0.08),
            ),
            right: BorderSide(
              color: isActive ? AppColors.gold : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    section.title,
                    style: TextStyle(
                      fontFamily: AppTheme.fontUi,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                      fontSize: 15,
                      color: isActive ? AppColors.gold : AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  'ص ${toArabicNumerals(BookData.toPrinted(section.page))}',
                  style: const TextStyle(
                    fontFamily: AppTheme.fontUi,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 3,
                backgroundColor: AppColors.textMuted.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation(
                  isActive ? AppColors.gold : AppColors.greenMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
