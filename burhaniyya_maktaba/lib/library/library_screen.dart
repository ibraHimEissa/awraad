import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfrx/pdfrx.dart';

import '../books/library_books.dart';
import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../core/arabic.dart';
import '../core/storage.dart';
import '../model/book.dart';
import '../reader/reader_screen.dart';
import '../widgets/islamic_pattern.dart';
import '../widgets/logo_watermark.dart';
import '../widgets/ornamental_divider.dart';
import '../widgets/sufi_logo.dart';

/// The home of the app: a small shelf of the order's books. Tap a book to open
/// its reader; each remembers its own place.
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  Future<void> _open(BookModule module) async {
    await Navigator.of(context).push(_openRoute(module));
    if (mounted) setState(() {}); // refresh "continue" state on return
  }

  Route _openRoute(BookModule module) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 420),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, _, _) => ReaderScreen(module: module),
      transitionsBuilder: (_, anim, _, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween(begin: 0.96, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final exit = await _confirmExit();
        if (exit) SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Container(
          decoration:
              const BoxDecoration(gradient: AppColors.backgroundGradient),
          child: IslamicPatternBackground(
            opacity: 0.04,
            tile: 70,
            child: Stack(
              children: [
                const Positioned(
                  top: 60,
                  left: 0,
                  right: 0,
                  child: Center(child: LogoWatermark(size: 300, opacity: 0.04)),
                ),
                SafeArea(
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: _Header(topPad: topPad),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                        sliver: SliverList.separated(
                          itemCount: Library.modules.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 14),
                          itemBuilder: (context, i) {
                            final m = Library.modules[i];
                            return _BookCard(
                              book: m.book,
                              lastPage: Storage.instance.lastPage(m.book.id),
                              hasProgress:
                                  Storage.instance.hasProgress(m.book.id),
                              onTap: () => _open(m),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmExit() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SufiLogo(size: 48, showGlow: false),
            SizedBox(height: 12),
            Text(
              'الخروج من التطبيق؟',
              style: TextStyle(
                fontFamily: AppTheme.fontUi,
                fontWeight: FontWeight.w700,
                fontSize: 17,
                color: AppColors.gold,
              ),
            ),
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
}

class _Header extends StatelessWidget {
  const _Header({required this.topPad});
  final double topPad;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, topPad + 22, 20, 10),
      child: Column(
        children: [
          const SufiLogo(size: 96),
          const SizedBox(height: 14),
          const Text(
            'مكتبة الطريقة البرهانية',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.fontScripture,
              fontWeight: FontWeight.w700,
              fontSize: 26,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'الدسوقية الشاذلية',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.fontUi,
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          const SizedBox(width: 220, child: OrnamentalDivider()),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'الكتب',
              style: TextStyle(
                fontFamily: AppTheme.fontUi,
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  const _BookCard({
    required this.book,
    required this.lastPage,
    required this.hasProgress,
    required this.onTap,
  });

  final Book book;
  final int lastPage;
  final bool hasProgress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(AppTheme.rLg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PdfCover(book: book),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontScripture,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        height: 1.4,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      book.subtitle,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontUi,
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      book.author,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontUi,
                        fontSize: 11.5,
                        height: 1.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _StatusChip(
                      book: book,
                      lastPage: lastPage,
                      hasProgress: hasProgress,
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 30),
                child: Icon(Icons.chevron_left_rounded,
                    color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The book's real cover: the first page of its PDF, in a gold-bordered frame.
/// While the document loads it shows a stylised placeholder, so the shelf never
/// looks empty.
class _PdfCover extends StatefulWidget {
  const _PdfCover({required this.book});
  final Book book;

  static const double w = 92;
  static const double h = 124;

  @override
  State<_PdfCover> createState() => _PdfCoverState();
}

class _PdfCoverState extends State<_PdfCover> {
  PdfDocument? _doc;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final doc = await PdfDocument.openAsset(widget.book.pdfAsset);
      if (mounted) {
        setState(() => _doc = doc);
      } else {
        doc.dispose();
      }
    } catch (_) {/* keep the placeholder */}
  }

  @override
  void dispose() {
    _doc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _PdfCover.w,
      height: _PdfCover.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.rMd),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: _doc == null
          ? _Placeholder(book: widget.book)
          : PdfPageView(
              document: _doc,
              pageNumber: 1,
              alignment: Alignment.center,
              backgroundColor: AppColors.parchment,
            ),
    );
  }
}

/// Stylised fallback shown until the first PDF page is ready.
class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.book});
  final Book book;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.surfaceContainerHighest, AppColors.surface],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: IslamicPatternBackground(
              opacity: 0.10,
              tile: 30,
              child: const SizedBox.expand(),
            ),
          ),
          Center(child: Icon(book.icon, size: 34, color: AppColors.gold)),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.book,
    required this.lastPage,
    required this.hasProgress,
  });

  final Book book;
  final int lastPage;
  final bool hasProgress;

  @override
  Widget build(BuildContext context) {
    final label = hasProgress
        ? 'تابع · صفحة ${toArabicNumerals(book.toPrinted(lastPage))}'
        : 'ابدأ القراءة';
    final icon = hasProgress ? Icons.play_arrow_rounded : Icons.auto_stories_rounded;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.emerald.withValues(alpha: hasProgress ? 0.9 : 0.16),
        borderRadius: BorderRadius.circular(AppTheme.rSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 16,
              color: hasProgress ? Colors.white : AppColors.greenLight),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTheme.fontUi,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
              color: hasProgress ? Colors.white : AppColors.greenLight,
            ),
          ),
        ],
      ),
    );
  }
}
