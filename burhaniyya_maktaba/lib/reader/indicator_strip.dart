import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../core/arabic.dart';
import '../model/book.dart';
import '../model/outline.dart';

/// Slim strip under the app bar: the active entry (section / poem), an optional
/// rhyme badge + part label, and a progress bar through that entry.
class IndicatorStrip extends StatelessWidget {
  const IndicatorStrip({
    super.key,
    required this.book,
    required this.outline,
    required this.currentPage,
  });

  final Book book;
  final BookOutline outline;
  final int currentPage;

  @override
  Widget build(BuildContext context) {
    final entry = outline.entryForPage(currentPage);
    final nextStart = outline.nextStart(entry, book.totalPages);
    final total = (nextStart - entry.page).clamp(1, book.totalPages);
    final read = (currentPage - entry.page + 1).clamp(0, total);
    final progress = (read / total).clamp(0.0, 1.0);
    final group = outline.groupTitleFor(entry);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainer,
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  entry.label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontUi,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.gold,
                  ),
                ),
              ),
              if (group != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    group,
                    style: const TextStyle(
                      fontFamily: AppTheme.fontUi,
                      fontSize: 10.5,
                      color: AppColors.greenLight,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Text(
                entry.meta ??
                    '${toArabicNumerals(read)} / ${toArabicNumerals(total)}',
                style: const TextStyle(
                  fontFamily: AppTheme.fontUi,
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 300),
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 2.5,
                backgroundColor: AppColors.textMuted.withValues(alpha: 0.15),
                valueColor: const AlwaysStoppedAnimation(AppColors.gold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
