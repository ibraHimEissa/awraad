import 'package:flutter/material.dart';

import '../data/book_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/arabic.dart';

/// Bottom chrome: previous / next page arrows plus a central cluster of
/// bookmarks, page-jump and search actions.
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.currentPage,
    required this.hasNote,
    required this.onPrev,
    required this.onNext,
    required this.onNotes,
    required this.onJump,
    required this.onSearch,
  });

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
    final canNext = currentPage < BookData.totalPages;

    return Container(
      padding: EdgeInsets.only(bottom: bottomPad, top: 6, left: 18, right: 18),
      decoration: const BoxDecoration(
        color: AppColors.headerFooter,
        border: Border(top: BorderSide(color: AppColors.goldDeep, width: 0.8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous page — right side
          _ArrowButton(
            icon: Icons.chevron_left_rounded,
            enabled: canPrev,
            onTap: onPrev,
          ),
          // Center cluster
          Row(
            children: [
              _CircleAction(
                icon: hasNote
                    ? Icons.edit_note_rounded
                    : Icons.note_add_outlined,
                background: AppColors.surface,
                iconColor: hasNote ? AppColors.goldBright : AppColors.gold,
                showDot: hasNote,
                onTap: onNotes,
              ),
              const SizedBox(width: 12),
              _PageButton(page: currentPage, onTap: onJump),
              const SizedBox(width: 12),
              _CircleAction(
                icon: Icons.search_rounded,
                background: AppColors.emerald,
                iconColor: Colors.white,
                onTap: onSearch,
              ),
            ],
          ),
          // Next page — left side
          _ArrowButton(
            icon: Icons.chevron_right_rounded,
            enabled: canNext,
            onTap: onNext,
          ),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

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

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.background,
    required this.iconColor,
    required this.onTap,
    this.showDot = false,
  });

  final IconData icon;
  final Color background;
  final Color iconColor;
  final VoidCallback onTap;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: background,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(icon, color: iconColor, size: 20),
            ),
          ),
        ),
        if (showDot)
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: AppColors.goldBright,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.headerFooter, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({required this.page, required this.onTap});

  final int page;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(
        side: BorderSide(color: AppColors.gold, width: 1.5),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Text(
            toArabicNumerals(BookData.toPrinted(page)),
            style: const TextStyle(
              fontFamily: AppTheme.fontUi,
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: AppColors.gold,
            ),
          ),
        ),
      ),
    );
  }
}
