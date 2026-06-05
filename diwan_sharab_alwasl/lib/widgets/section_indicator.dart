import 'package:flutter/material.dart';

import '../data/book_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/arabic.dart';

/// Slim strip under the header showing the active poem (ordinal + rhyme name),
/// its part, and a progress bar through that poem.
class SectionIndicator extends StatelessWidget {
  const SectionIndicator({super.key, required this.currentPage});

  final int currentPage;

  @override
  Widget build(BuildContext context) {
    final poem = BookData.poemForPage(currentPage);
    final nextStart = BookData.nextPoemStart(poem);
    final total = (nextStart - poem.page).clamp(1, BookData.totalPages);
    final read = (currentPage - poem.page + 1).clamp(0, total);
    final progress = (read / total).clamp(0.0, 1.0);
    final part = BookData.partNames[poem.part] ?? '';

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
                  poem.label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontUi,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.gold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  part,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontUi,
                    fontSize: 10.5,
                    color: AppColors.greenLight,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'بيت ${toArabicNumerals(poem.verseCount)}',
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
