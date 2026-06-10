import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../core/arabic.dart';
import '../model/book.dart';
import '../widgets/ornamental_divider.dart';
import '../widgets/sufi_logo.dart';

/// Jump to a printed page number within [book].
Future<void> showJumpDialog(
  BuildContext context, {
  required Book book,
  required ValueChanged<int> onConfirm,
}) {
  return showDialog(
    context: context,
    builder: (_) => _JumpDialog(book: book, onConfirm: onConfirm),
  );
}

class _JumpDialog extends StatefulWidget {
  const _JumpDialog({required this.book, required this.onConfirm});
  final Book book;
  final ValueChanged<int> onConfirm;

  @override
  State<_JumpDialog> createState() => _JumpDialogState();
}

class _JumpDialogState extends State<_JumpDialog> {
  final _controller = TextEditingController();
  String? _error;

  void _confirm() {
    final printed = int.tryParse(_controller.text);
    final internal = printed == null ? null : widget.book.fromPrinted(printed);
    if (internal != null &&
        internal >= 1 &&
        internal <= widget.book.totalPages) {
      Navigator.pop(context);
      widget.onConfirm(internal);
    } else {
      setState(() => _error =
          'الرجاء إدخال رقم بين ${toArabicNumerals(widget.book.printedFirst)} و ${toArabicNumerals(widget.book.printedTotal)}');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'الانتقال إلى صفحة',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: AppTheme.fontUi,
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: AppColors.gold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'بين ${toArabicNumerals(widget.book.printedFirst)} و ${toArabicNumerals(widget.book.printedTotal)}',
            style: const TextStyle(
              fontFamily: AppTheme.fontUi,
              fontSize: 13,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 140,
            child: TextField(
              controller: _controller,
              autofocus: true,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
              cursorColor: AppColors.gold,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 22,
                color: AppColors.textPrimary,
              ),
              onSubmitted: (_) => _confirm(),
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.danger,
                  fontFamily: AppTheme.fontUi,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        FilledButton(onPressed: _confirm, child: const Text('انتقال')),
      ],
    );
  }
}

/// Confirm before leaving the book back to the library / exiting.
Future<bool> showExitDialog(BuildContext context, {required String message}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SufiLogo(size: 50, showGlow: false),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppTheme.fontUi,
              fontWeight: FontWeight.w700,
              fontSize: 17,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 8),
          const SizedBox(width: 160, child: OrnamentalDivider()),
        ],
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context, false),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.gold,
            side: BorderSide(color: AppColors.gold.withValues(alpha: 0.5)),
          ),
          child: const Text('لا'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.danger.withValues(alpha: 0.85),
          ),
          child: const Text('نعم'),
        ),
      ],
    ),
  );
  return result ?? false;
}
