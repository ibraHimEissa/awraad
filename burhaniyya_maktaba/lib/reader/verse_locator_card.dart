import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../core/arabic.dart';
import '../model/models.dart';

/// Shown over the reader after tapping a verse search result. The PDF is image
/// based, so instead of a highlight we surface the verse text and its number,
/// so the reader can locate it on the page. Dismissed with ✕ or by turning the
/// page.
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
        color: AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppTheme.rMd),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.55)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.my_location_rounded,
                  color: AppColors.goldBright, size: 18),
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
                  locator.context,
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
                icon: const Icon(Icons.close_rounded,
                    color: AppColors.textMuted, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
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
