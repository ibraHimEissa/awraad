import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../core/arabic.dart';
import '../model/book.dart';

/// Material 3 reader app bar: back-to-library, index, the book title, a page
/// chip, and a bookmark toggle. (Fullscreen is a single tap on the page.)
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.book,
    required this.currentPage,
    required this.isBookmarked,
    required this.onBack,
    required this.onMenu,
    required this.onBookmarkToggle,
  });

  final Book book;
  final int currentPage;
  final bool isBookmarked;
  final VoidCallback onBack;
  final VoidCallback onMenu;
  final VoidCallback onBookmarkToggle;

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
              onPressed: onBack,
              icon: const Icon(Icons.arrow_forward_rounded),
              tooltip: 'المكتبة',
              style: IconButton.styleFrom(foregroundColor: AppColors.textMuted),
            ),
            IconButton(
              onPressed: onMenu,
              icon: const Icon(Icons.menu_book_rounded),
              tooltip: 'الفهرس',
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surfaceContainerHighest,
                foregroundColor: AppColors.gold,
              ),
            ),
            Expanded(
              child: Text(
                book.shortTitle,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: AppTheme.fontUi,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                  color: AppColors.gold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppTheme.rSm),
              ),
              child: Text(
                '${toArabicNumerals(book.toPrinted(currentPage))}'
                ' / ${toArabicNumerals(book.printedTotal)}',
                style: const TextStyle(
                  fontFamily: AppTheme.fontUi,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                  color: AppColors.gold,
                ),
              ),
            ),
            IconButton(
              onPressed: onBookmarkToggle,
              isSelected: isBookmarked,
              tooltip: 'إشارة مرجعية',
              icon: const Icon(Icons.bookmark_border_rounded),
              selectedIcon: const Icon(Icons.bookmark_rounded),
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.resolveWith(
                  (s) => s.contains(WidgetState.selected)
                      ? AppColors.goldBright
                      : AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
