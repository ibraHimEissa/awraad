import 'package:flutter/material.dart';

import '../data/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/arabic.dart';

/// Shown over the reader after the user taps a search result. The diwan PDF is
/// image-based, so we can't paint a highlight onto the page; instead this card
/// surfaces the exact verse text and its number within the poem, so the reader
/// can locate it on the page at a glance. Dismissed with the ✕, or
/// automatically when the user turns to another page.
class VerseLocatorCard extends StatelessWidget {
  const VerseLocatorCard({
    super.key,
    required this.locator,
    required this.onClose,
  });

  final VerseLocator locator;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final hemistichs = locator.text.split('*').map((s) => s.trim()).toList();

    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.my_location_rounded,
                color: AppColors.goldBright,
                size: 18,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'البيت ${toArabicNumerals(locator.verseNo)}',
                  style: const TextStyle(
                    fontFamily: AppTheme.fontUi,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.gold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  locator.poemLabel,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontUi,
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              IconButton(
                onPressed: onClose,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppColors.textMuted,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // The verse — two hemistichs, centred, manuscript font.
          for (final h in hemistichs)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Text(
                h,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppTheme.fontScripture,
                  fontSize: 18,
                  height: 1.7,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          const SizedBox(height: 6),
          const Text(
            'ابحث عن هذا البيت في الصفحة',
            textAlign: TextAlign.center,
            style: TextStyle(
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
