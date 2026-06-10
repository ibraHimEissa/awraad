import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../core/arabic.dart';
import '../model/book.dart';
import '../model/outline.dart';
import '../model/search.dart';

/// Generic full-text search sheet. Works for both line-based (litany) and
/// verse-based (diwan) books; verse hits show a verse-number badge and, on
/// tap, hand the whole hit back so the reader can raise a locator card.
Future<void> showSearchSheet(
  BuildContext context, {
  required Book book,
  required BookOutline outline,
  required BookSearch search,
  required ValueChanged<SearchHit> onSelect,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _SearchSheet(
      book: book,
      outline: outline,
      search: search,
      onSelect: onSelect,
    ),
  );
}

class _SearchSheet extends StatefulWidget {
  const _SearchSheet({
    required this.book,
    required this.outline,
    required this.search,
    required this.onSelect,
  });

  final Book book;
  final BookOutline outline;
  final BookSearch search;
  final ValueChanged<SearchHit> onSelect;

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
    widget.search.ensureLoaded().then((_) {
      if (mounted) {
        setState(() {
          _loading = false;
          if (_query.trim().isNotEmpty) {
            _results = widget.search.search(_query);
          }
        });
      }
    });
  }

  void _onChanged(String v) {
    _query = v;
    setState(() {
      _results = _loading ? const [] : widget.search.search(v);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.82,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.search_rounded, color: AppColors.gold),
                  const SizedBox(width: 8),
                  Text(
                    widget.search.title,
                    style: const TextStyle(
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
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                autofocus: true,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                onChanged: _onChanged,
                cursorColor: AppColors.gold,
                style: const TextStyle(
                  fontFamily: AppTheme.fontUi,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: widget.search.hint,
                  prefixIcon:
                      const Icon(Icons.search_rounded, color: AppColors.gold),
                ),
              ),
              const SizedBox(height: 14),
              Flexible(child: _resultsView()),
            ],
          ),
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
      return const _Hint('اكتب أي كلمة لتجد كل المواضع التي وردت فيها');
    }
    if (_results.isEmpty) {
      return _Hint('لا توجد ${widget.search.emptyWord} مطابقة لـ "$_query"');
    }
    return ListView.separated(
      shrinkWrap: true,
      itemCount: _results.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final hit = _results[i];
        final context0 =
            hit.context ?? widget.outline.entryForPage(hit.page).label;
        return Material(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppTheme.rSm),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTheme.rSm),
            onTap: () {
              Navigator.pop(context);
              widget.onSelect(hit);
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _Badge(
                        label:
                            'ص ${toArabicNumerals(widget.book.toPrinted(hit.page))}',
                        color: AppColors.gold,
                      ),
                      if (hit.verseNo != null) ...[
                        const SizedBox(width: 6),
                        _Badge(
                          label: 'البيت ${toArabicNumerals(hit.verseNo!)}',
                          color: AppColors.greenLight,
                        ),
                      ],
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          context0,
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

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTheme.fontUi,
          fontWeight: FontWeight.w700,
          fontSize: 12,
          color: color,
        ),
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
