import 'package:flutter/material.dart';

import '../data/book_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/arabic.dart';
import 'sufi_logo.dart';

/// Top chrome bar: index button, centered logo + title, page counter,
/// bookmark toggle. Drawn over the emerald background with a gold underline.
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.currentPage,
    required this.isBookmarked,
    required this.onMenu,
    required this.onBookmarkToggle,
    required this.onFullscreen,
    this.menuKey,
    this.bookmarkKey,
    this.fullscreenKey,
    this.counterKey,
  });

  final int currentPage;
  final bool isBookmarked;
  final VoidCallback onMenu;
  final VoidCallback onBookmarkToggle;
  final VoidCallback onFullscreen;

  // Optional anchors used by the first-launch guided tour.
  final GlobalKey? menuKey;
  final GlobalKey? bookmarkKey;
  final GlobalKey? fullscreenKey;
  final GlobalKey? counterKey;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.only(top: topPad, left: 6, right: 6, bottom: 3),
      decoration: const BoxDecoration(
        color: AppColors.headerFooter,
        border: Border(
          bottom: BorderSide(color: AppColors.goldDeep, width: 0.8),
        ),
      ),
      child: Row(
        children: [
          // Leading (right in RTL): index menu + bookmark
          IconButton(
            key: menuKey,
            onPressed: onMenu,
            icon: const Icon(Icons.menu_book_rounded, color: AppColors.gold),
            tooltip: 'الفهرس',
          ),
          IconButton(
            key: bookmarkKey,
            onPressed: onBookmarkToggle,
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: isBookmarked ? AppColors.goldBright : AppColors.textMuted,
            ),
            tooltip: 'إشارة مرجعية',
          ),
          // Center: logo + title
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SufiLogo(size: 26, showGlow: false),
                const SizedBox(height: 1),
                Text(
                  BookData.headerTitle,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontUi,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
          ),
          // Trailing (left in RTL): fullscreen + page counter
          IconButton(
            key: fullscreenKey,
            onPressed: onFullscreen,
            icon: const Icon(Icons.fullscreen, color: AppColors.textMuted),
            tooltip: 'ملء الشاشة',
          ),
          Padding(
            key: counterKey,
            padding: const EdgeInsets.only(left: 6, right: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${toArabicNumerals(BookData.toPrinted(currentPage))}'
                  ' / '
                  '${toArabicNumerals(BookData.printedTotal)}',
                  style: const TextStyle(
                    fontFamily: AppTheme.fontUi,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.gold,
                  ),
                ),
                const Text(
                  'الصفحة',
                  style: TextStyle(
                    fontFamily: AppTheme.fontUi,
                    fontSize: 9,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
