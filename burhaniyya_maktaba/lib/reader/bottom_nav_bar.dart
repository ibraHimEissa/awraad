import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../core/arabic.dart';
import '../model/book.dart';

/// Material 3 bottom bar: page arrows, a notes action, a central page-jump
/// pill, and a prominent search button.
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.book,
    required this.currentPage,
    required this.hasNote,
    required this.onPrev,
    required this.onNext,
    required this.onNotes,
    required this.onJump,
    required this.onSearch,
  });

  final Book book;
  final int currentPage;
  final bool hasNote;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onNotes;
  final VoidCallback onJump;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final canPrev = currentPage > 1;
    final canNext = currentPage < book.totalPages;

    return Material(
      color: AppColors.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.rLg)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          14,
          8,
          14,
          8 + (bottomPad > 0 ? bottomPad : 6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _Arrow(
              icon: Icons.chevron_left_rounded,
              enabled: canPrev,
              onTap: onPrev,
            ),
            Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      onPressed: onNotes,
                      tooltip: 'ملاحظة على الصفحة',
                      isSelected: hasNote,
                      icon: const Icon(Icons.note_add_outlined),
                      selectedIcon: const Icon(Icons.edit_note_rounded),
                      style: ButtonStyle(
                        backgroundColor: const WidgetStatePropertyAll(
                          AppColors.surfaceContainerHighest,
                        ),
                        foregroundColor: WidgetStateProperty.resolveWith(
                          (states) => states.contains(WidgetState.selected)
                              ? AppColors.goldBright
                              : AppColors.gold,
                        ),
                      ),
                    ),
                    if (hasNote)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: AppColors.goldBright,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.surfaceContainer,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 10),
                _PagePill(label: toArabicNumerals(book.toPrinted(currentPage)),
                    onTap: onJump),
                const SizedBox(width: 10),
                FloatingActionButton.small(
                  onPressed: onSearch,
                  heroTag: 'search',
                  elevation: 0,
                  backgroundColor: AppColors.emerald,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.rMd),
                  ),
                  child: const Icon(Icons.search_rounded),
                ),
              ],
            ),
            _Arrow(
              icon: Icons.chevron_right_rounded,
              enabled: canNext,
              onTap: onNext,
            ),
          ],
        ),
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow({required this.icon, required this.enabled, required this.onTap});

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: enabled ? onTap : null,
      iconSize: 30,
      icon: Icon(
        icon,
        color: enabled
            ? AppColors.gold
            : AppColors.textMuted.withValues(alpha: 0.25),
      ),
    );
  }
}

class _PagePill extends StatelessWidget {
  const _PagePill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerHighest,
      shape: StadiumBorder(
        side: BorderSide(color: AppColors.gold.withValues(alpha: 0.55)),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.my_location_rounded,
                  size: 15, color: AppColors.gold),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: AppTheme.fontUi,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
