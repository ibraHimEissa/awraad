import 'package:flutter/material.dart';

import '../data/book_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/arabic.dart';
import 'sufi_logo.dart';

/// Material 3 top app bar: a tonal surface bar with the index button, a
/// centred logo + title, a page-count chip, and bookmark / fullscreen actions.
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.currentPage,
    required this.isBookmarked,
    required this.onMenu,
    required this.onBookmarkToggle,
    required this.onFullscreen,
  });

  final int currentPage;
  final bool isBookmarked;
  final VoidCallback onMenu;
  final VoidCallback onBookmarkToggle;
  final VoidCallback onFullscreen;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Material(
      color: AppColors.surfaceContainer,
      child: Padding(
        padding: EdgeInsets.only(top: topPad + 4, left: 4, right: 4, bottom: 6),
        child: Row(
          children: [
            IconButton(
              onPressed: onMenu,
              icon: const Icon(Icons.menu_book_rounded),
              tooltip: 'فهرس القصائد',
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surfaceContainerHighest,
                foregroundColor: AppColors.gold,
              ),
            ),
            const SizedBox(width: 2),
            // Bookmark as an M3 toggle (filled-tonal when active).
            IconButton(
              onPressed: onBookmarkToggle,
              isSelected: isBookmarked,
              tooltip: 'إشارة مرجعية',
              icon: const Icon(Icons.bookmark_border_rounded),
              selectedIcon: const Icon(Icons.bookmark_rounded),
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? AppColors.goldBright
                      : AppColors.textMuted,
                ),
              ),
            ),
            // Center: logo + title
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SufiLogo(size: 28, showGlow: false),
                  const SizedBox(height: 2),
                  Text(
                    BookData.headerTitle,
                    style: const TextStyle(
                      fontFamily: AppTheme.fontUi,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
            ),
            // Page chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppTheme.rSm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.menu_book_outlined,
                    size: 13,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${toArabicNumerals(BookData.toPrinted(currentPage))}'
                    ' / ${toArabicNumerals(BookData.printedTotal)}',
                    style: const TextStyle(
                      fontFamily: AppTheme.fontUi,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onFullscreen,
              icon: const Icon(Icons.fullscreen_rounded),
              tooltip: 'وضع ملء الشاشة',
              style: IconButton.styleFrom(foregroundColor: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
