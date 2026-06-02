import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/book_data.dart';
import '../services/search_index.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/arabic.dart';
import 'ornamental_divider.dart';
import 'sufi_logo.dart';

/// Bottom sheet for full-text search across the whole book (OCR index).
Future<void> showSearchSheet(
  BuildContext context, {
  required ValueChanged<int> onSelectPage,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _SearchSheet(onSelectPage: onSelectPage),
  );
}

class _SearchSheet extends StatefulWidget {
  const _SearchSheet({required this.onSelectPage});
  final ValueChanged<int> onSelectPage;

  @override
  State<_SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<_SearchSheet> {
  String _query = '';
  bool _loading = true;
  List<SearchHit> _results = const [];

  @override
  void initState() {
    super.initState();
    SearchIndex.instance.ensureLoaded().then((_) {
      if (mounted) setState(() => _loading = false);
    });
  }

  void _onChanged(String v) {
    _query = v;
    setState(() {
      _results =
          _loading ? const [] : SearchIndex.instance.search(v);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        margin: const EdgeInsets.all(10),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.82,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.search_rounded, color: AppColors.gold),
                const SizedBox(width: 8),
                const Text(
                  'بحث في الكتاب',
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
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.textMuted),
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
              decoration: InputDecoration(
                hintText: 'اكتب كلمة أو جملة من الكتاب…',
                hintStyle: const TextStyle(
                  fontFamily: AppTheme.fontUi,
                  color: AppColors.textMuted,
                  fontSize: 14,
                ),
                prefixIcon:
                    const Icon(Icons.search_rounded, color: AppColors.gold),
                filled: true,
                fillColor: AppColors.background.withValues(alpha: 0.5),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: AppColors.gold.withValues(alpha: 0.4)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.gold),
                ),
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
            _Hint('جارٍ تجهيز فهرس البحث…'),
          ],
        ),
      );
    }
    if (_query.trim().isEmpty) {
      return const _Hint('اكتب أي كلمة وستظهر كل المواضع التي ذُكرت فيها');
    }
    if (_results.isEmpty) {
      return _Hint('لا توجد نتائج مطابقة لـ "$_query"');
    }
    return ListView.separated(
      shrinkWrap: true,
      itemCount: _results.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final hit = _results[i];
        final section = BookData.sectionForPage(hit.page);
        return Material(
          color: AppColors.background.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              Navigator.pop(context);
              widget.onSelectPage(hit.page);
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'ص ${toArabicNumerals(BookData.toPrinted(hit.page))}',
                          style: const TextStyle(
                            fontFamily: AppTheme.fontUi,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: AppColors.gold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          section.title,
                          overflow: TextOverflow.ellipsis,
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
                    hit.snippet,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontFamily: AppTheme.fontScripture,
                      fontSize: 17,
                      height: 1.7,
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

class _Hint extends StatelessWidget {
  const _Hint(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: AppTheme.fontUi,
            fontSize: 13,
            color: AppColors.textMuted,
          ),
        ),
      );
}

/// Dialog to jump to a specific page number.
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
    // The user types the number printed in the book; convert to the
    // internal page used for rendering.
    final printed = int.tryParse(_controller.text);
    final internal = printed == null ? null : BookData.fromPrinted(printed);
    if (internal != null && internal >= 1 && internal <= BookData.totalPages) {
      Navigator.pop(context);
      widget.onConfirm(internal);
    } else {
      setState(() => _error =
          'الرجاء إدخال رقم صحيح (٢ - ${toArabicNumerals(BookData.printedTotal)})');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.parchment,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.gold, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'الانتقال إلى صفحة',
              style: TextStyle(
                fontFamily: AppTheme.fontUi,
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: AppColors.inkBrown,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'أدخل رقم الصفحة (٢ - ${toArabicNumerals(BookData.printedTotal)})',
              style: const TextStyle(
                fontFamily: AppTheme.fontUi,
                fontSize: 13,
                color: AppColors.inkGold,
              ),
            ),
            const SizedBox(height: 18),
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
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: AppColors.inkBrown,
                ),
                cursorColor: AppColors.goldDeep,
                onSubmitted: (_) => _confirm(),
                decoration: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ).let((b) => InputDecoration(
                      enabledBorder: b.copyWith(
                        borderSide: BorderSide(
                            color: AppColors.inkGold.withValues(alpha: 0.5)),
                      ),
                      focusedBorder: b.copyWith(
                        borderSide:
                            const BorderSide(color: AppColors.goldDeep),
                      ),
                    )),
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  _error!,
                  style: const TextStyle(
                    color: AppColors.danger,
                    fontFamily: AppTheme.fontUi,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'إلغاء',
                      style: TextStyle(
                        fontFamily: AppTheme.fontUi,
                        fontWeight: FontWeight.w700,
                        color: AppColors.inkGold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: _confirm,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.emerald,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'موافق',
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
                          color: AppColors.gold.withValues(alpha: 0.5)),
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
                      backgroundColor:
                          AppColors.danger.withValues(alpha: 0.85),
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

/// Small extension to compose an [OutlineInputBorder] inline.
extension _Let<T> on T {
  R let<R>(R Function(T) f) => f(this);
}
