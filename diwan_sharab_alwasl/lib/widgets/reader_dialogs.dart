import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/book_data.dart';
import '../services/search_index.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/arabic.dart';
import 'ornamental_divider.dart';
import 'sufi_logo.dart';

/// Bottom sheet for searching across all 2,682 verses of the diwan.
/// Tapping a result hands the whole [VerseHit] back so the reader can both
/// jump to the page and raise a locator card for that exact verse.
Future<void> showSearchSheet(
  BuildContext context, {
  required ValueChanged<VerseHit> onSelectVerse,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) => _SearchSheet(onSelectVerse: onSelectVerse),
  );
}

class _SearchSheet extends StatefulWidget {
  const _SearchSheet({required this.onSelectVerse});
  final ValueChanged<VerseHit> onSelectVerse;

  @override
  State<_SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<_SearchSheet> {
  String _query = '';
  bool _loading = true;
  List<VerseHit> _results = const [];

  @override
  void initState() {
    super.initState();
    SearchIndex.instance.ensureLoaded().then((_) {
      if (mounted) {
        setState(() {
          _loading = false;
          if (_query.trim().isNotEmpty) {
            _results = SearchIndex.instance.search(_query);
          }
        });
      }
    });
  }

  void _onChanged(String v) {
    _query = v;
    setState(() {
      _results = _loading ? const [] : SearchIndex.instance.search(v);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.86,
        ),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.search_rounded, color: AppColors.gold),
                const SizedBox(width: 8),
                const Text(
                  'بحث في الأبيات',
                  style: TextStyle(
                    fontFamily: AppTheme.fontUi,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: AppColors.gold,
                  ),
                ),
                const Spacer(),
                if (_query.isNotEmpty && !_loading)
                  Text(
                    '${toArabicNumerals(_results.length)} نتيجة',
                    style: const TextStyle(
                      fontFamily: AppTheme.fontUi,
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              autofocus: true,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              onChanged: _onChanged,
              style: const TextStyle(
                fontFamily: AppTheme.fontUi,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
              cursorColor: AppColors.gold,
              decoration: const InputDecoration(
                hintText: 'اكتب كلمة أو شطرًا من بيت…',
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.gold),
              ),
            ),
            const SizedBox(height: 14),
            Flexible(child: _resultsView()),
          ],
        ),
      ),
    );
  }

  Widget _resultsView() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.goldDeep),
            SizedBox(height: 12),
            _Hint('جارٍ تجهيز فهرس الأبيات…'),
          ],
        ),
      );
    }
    if (_query.trim().isEmpty) {
      return const _Hint('اكتب أي كلمة من بيت لتجد كل المواضع التي وردت فيها');
    }
    if (_results.isEmpty) {
      return _Hint('لا توجد أبيات مطابقة لـ "$_query"');
    }
    return ListView.separated(
      shrinkWrap: true,
      itemCount: _results.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final hit = _results[i];
        final poem = BookData.poemById(hit.poemId);
        return Material(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppTheme.rMd),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTheme.rMd),
            onTap: () {
              Navigator.pop(context);
              widget.onSelectVerse(hit);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _MiniBadge(
                        label:
                            'ص ${toArabicNumerals(BookData.toPrinted(hit.page))}',
                        color: AppColors.gold,
                      ),
                      const SizedBox(width: 6),
                      _MiniBadge(
                        label: 'البيت ${toArabicNumerals(hit.verseNo)}',
                        color: AppColors.greenLight,
                        icon: Icons.format_list_numbered_rtl_rounded,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          poem?.label ?? '',
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            fontFamily: AppTheme.fontUi,
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    hit.text.replaceAll('*', '۞'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontFamily: AppTheme.fontScripture,
                      fontSize: 17,
                      height: 1.8,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({required this.label, required this.color, this.icon});
  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTheme.fontUi,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontFamily: AppTheme.fontUi,
        fontSize: 13,
        height: 1.7,
        color: AppColors.textMuted,
      ),
    ),
  );
}

/// Dialog to jump to a specific (printed) page number.
Future<void> showJumpDialog(
  BuildContext context, {
  required ValueChanged<int> onConfirm,
}) {
  return showDialog(
    context: context,
    builder: (ctx) => _JumpDialog(onConfirm: onConfirm),
  );
}

class _JumpDialog extends StatefulWidget {
  const _JumpDialog({required this.onConfirm});
  final ValueChanged<int> onConfirm;

  @override
  State<_JumpDialog> createState() => _JumpDialogState();
}

class _JumpDialogState extends State<_JumpDialog> {
  final _controller = TextEditingController();
  String? _error;

  void _confirm() {
    // The user types the number printed in the book; convert to the internal
    // PDF page used for rendering.
    final printed = int.tryParse(_controller.text);
    final internal = printed == null ? null : BookData.fromPrinted(printed);
    if (internal != null && internal >= 1 && internal <= BookData.totalPages) {
      Navigator.pop(context);
      widget.onConfirm(internal);
    } else {
      setState(
        () => _error =
            'الرجاء إدخال رقم صحيح (٧ - ${toArabicNumerals(BookData.printedTotal)})',
      );
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
      icon: const Icon(Icons.my_location_rounded, color: AppColors.gold),
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
            'أدخل رقم الصفحة (٧ - ${toArabicNumerals(BookData.printedTotal)})',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppTheme.fontUi,
              fontSize: 13,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 150,
            child: TextField(
              controller: _controller,
              autofocus: true,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 22,
                color: AppColors.gold,
              ),
              cursorColor: AppColors.gold,
              onSubmitted: (_) => _confirm(),
              decoration: const InputDecoration(hintText: '٧'),
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
        FilledButton(onPressed: _confirm, child: const Text('موافق')),
      ],
    );
  }
}

/// Confirmation dialog before leaving the app.
Future<bool> showExitDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.gold.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SufiLogo(size: 54, showGlow: false),
            const SizedBox(height: 14),
            const Text(
              'تأكيد الخروج',
              style: TextStyle(
                fontFamily: AppTheme.fontScripture,
                fontWeight: FontWeight.w700,
                fontSize: 22,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(height: 10),
            const SizedBox(width: 180, child: OrnamentalDivider()),
            const SizedBox(height: 12),
            const Text(
              'هل أنت متأكد أنك تريد الخروج من التطبيق؟',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.fontUi,
                fontSize: 15,
                height: 1.7,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: AppColors.gold.withValues(alpha: 0.5),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'لا، ابقَ',
                      style: TextStyle(
                        fontFamily: AppTheme.fontUi,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.danger.withValues(alpha: 0.85),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'نعم، اخرج',
                      style: TextStyle(
                        fontFamily: AppTheme.fontUi,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}
