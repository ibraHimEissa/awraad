import 'package:flutter/material.dart';

import '../data/book_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/arabic.dart';

/// Slim strip under the header showing the active section title and a
/// progress bar through that section.
class SectionIndicator extends StatelessWidget {
  const SectionIndicator({super.key, required this.currentPage});

  final int currentPage;

  @override
  Widget build(BuildContext context) {
    final section = BookData.sectionForPage(currentPage);
    final nextStart = BookData.nextSectionStart(section);
    final total = (nextStart - section.page).clamp(1, BookData.totalPages);
    final read = (currentPage - section.page + 1).clamp(0, total);
    final progress = (read / total).clamp(0.0, 1.0);

    return Container(
      color: AppColors.headerFooter,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                section.title,
                style: const TextStyle(
                  fontFamily: AppTheme.fontUi,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.gold,
                ),
              ),
              Text(
                '${toArabicNumerals(read)} من ${toArabicNumerals(total)} صفحة',
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
