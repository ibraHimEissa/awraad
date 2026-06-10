import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../books/library_books.dart';
import '../core/app_colors.dart';
import '../model/models.dart';
import '../onboarding/onboarding_screen.dart';
import '../widgets/app_snack.dart';
import '../widgets/islamic_pattern.dart';
import '../widgets/logo_watermark.dart';
import 'app_header.dart';
import 'book_page_view.dart';
import 'bottom_nav_bar.dart';
import 'dialogs.dart';
import 'indicator_strip.dart';
import 'notes_sheet.dart';
import 'outline_drawer.dart';
import 'reader_controller.dart';
import 'search_sheet.dart';
import 'verse_locator_card.dart';

/// The reader for one book. Pushed from the library; pops back to it.
class ReaderScreen extends StatelessWidget {
  const ReaderScreen({super.key, required this.module});
  final BookModule module;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReaderController(module)..load(),
      child: _ReaderView(module: module),
    );
  }
}

class _ReaderView extends StatefulWidget {
  const _ReaderView({required this.module});
  final BookModule module;

  @override
  State<_ReaderView> createState() => _ReaderViewState();
}

class _ReaderViewState extends State<_ReaderView> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late final PageController _pageController;
  late final ReaderController _controller;

  PdfDocument? _document;
  bool _immersive = false;
  bool _zoomed = false;
  bool _multiTouch = false;
  int _activePointers = 0;
  bool _syncingFromController = false;

  BookModule get module => widget.module;

  @override
  void initState() {
    super.initState();
    _controller = context.read<ReaderController>();
    _pageController = PageController(initialPage: _controller.currentPage - 1);
    _controller.addListener(_onControllerChanged);
    _loadDocument();
    WakelockPlus.enable();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final msg = _controller.resumeMessage;
      if (msg != null && mounted) {
        _controller.clearResumeMessage();
        showAppSnack(context, msg, icon: Icons.auto_stories_rounded);
      }
    });
  }

  Future<void> _loadDocument() async {
    final doc = await PdfDocument.openAsset(module.book.pdfAsset);
    if (mounted) setState(() => _document = doc);
  }

  void _onControllerChanged() {
    final target = _controller.currentPage - 1;
    final current = _pageController.hasClients
        ? (_pageController.page ?? _pageController.initialPage.toDouble())
              .round()
        : _pageController.initialPage;
    if (current != target && _pageController.hasClients) {
      _syncingFromController = true;
      _pageController
          .animateToPage(
            target,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
          )
          .then((_) => _syncingFromController = false);
    }
  }

  void _onPageChanged(int index) {
    if (_syncingFromController) return;
    _controller.jumpToPage(index + 1);
  }

  void _updatePointers(int delta) {
    _activePointers = (_activePointers + delta).clamp(0, 10);
    final multi = _activePointers >= 2;
    if (multi != _multiTouch) setState(() => _multiTouch = multi);
  }

  Future<void> _toggleImmersive() async {
    setState(() => _immersive = !_immersive);
    await SystemChrome.setEnabledSystemUIMode(
      _immersive ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );
  }

  Future<void> _exitImmersiveIfNeeded() async {
    if (_immersive) await _toggleImmersive();
  }

  void _handleBack() async {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
      return;
    }
    if (_immersive) {
      _toggleImmersive();
      return;
    }
    Navigator.pop(context); // back to the library
  }

  void _openSearch(ReaderController c) {
    showSearchSheet(
      context,
      book: module.book,
      outline: module.outline,
      search: module.search,
      onSelect: (hit) {
        if (module.search.usesLocator && hit.verseNo != null) {
          c.showVerse(VerseLocator(
            page: hit.page,
            verseNo: hit.verseNo!,
            text: hit.text,
            context: hit.context ?? '',
          ));
        } else {
          c.jumpToPage(hit.page);
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _pageController.dispose();
    _document?.dispose();
    WakelockPlus.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final book = module.book;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.background,
        drawerEnableOpenDragGesture: !_zoomed,
        drawer: Consumer<ReaderController>(
          builder: (context, c, _) => OutlineDrawer(
            book: book,
            outline: module.outline,
            currentPage: c.currentPage,
            bookmarks: c.bookmarks,
            onSelectPage: (page) {
              Navigator.pop(context);
              c.jumpToPage(page);
            },
            onRemoveBookmark: c.removeBookmark,
            onClose: () => Navigator.pop(context),
            onShowGuide: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const OnboardingScreen(asGuide: true),
              ));
            },
          ),
        ),
        body: Container(
          decoration:
              const BoxDecoration(gradient: AppColors.backgroundGradient),
          child: Column(
            children: [
              _Collapse(
                visible: !_immersive,
                child: Consumer<ReaderController>(
                  builder: (context, c, _) => AppHeader(
                    book: book,
                    currentPage: c.currentPage,
                    isBookmarked: c.isCurrentBookmarked,
                    onBack: () async {
                      await _exitImmersiveIfNeeded();
                      if (context.mounted) Navigator.pop(context);
                    },
                    onMenu: () => _scaffoldKey.currentState?.openDrawer(),
                    onBookmarkToggle: c.toggleBookmark,
                  ),
                ),
              ),
              _Collapse(
                visible: !_immersive,
                child: Consumer<ReaderController>(
                  builder: (context, c, _) => IndicatorStrip(
                    book: book,
                    outline: module.outline,
                    currentPage: c.currentPage,
                  ),
                ),
              ),
              Expanded(child: _buildPager()),
              _Collapse(
                visible: !_immersive,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Consumer<ReaderController>(
                      builder: (context, c, _) {
                        final loc = c.verseLocator;
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 260),
                          switchInCurve: Curves.easeOutCubic,
                          transitionBuilder: (child, anim) => SizeTransition(
                            sizeFactor: anim,
                            axisAlignment: -1,
                            child: FadeTransition(opacity: anim, child: child),
                          ),
                          child: loc == null
                              ? const SizedBox(width: double.infinity)
                              : VerseLocatorCard(
                                  key: ValueKey('${loc.page}-${loc.verseNo}'),
                                  locator: loc,
                                  onClose: c.clearVerseLocator,
                                ),
                        );
                      },
                    ),
                    Consumer<ReaderController>(
                      builder: (context, c, _) => BottomNavBar(
                        book: book,
                        currentPage: c.currentPage,
                        hasNote: c.currentHasNote,
                        onPrev: () => c.jumpToPage(c.currentPage - 1),
                        onNext: () => c.jumpToPage(c.currentPage + 1),
                        onNotes: () => showNotesSheet(context,
                            page: c.currentPage, onSelectPage: c.jumpToPage),
                        onJump: () => showJumpDialog(context,
                            book: book, onConfirm: c.jumpToPage),
                        onSearch: () => _openSearch(c),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPager() {
    return IslamicPatternBackground(
      opacity: 0.03,
      tile: 64,
      child: Stack(
        children: [
          const Positioned.fill(
            child: LogoWatermark(size: 300, opacity: 0.045),
          ),
          Listener(
            onPointerDown: (_) => _updatePointers(1),
            onPointerUp: (_) => _updatePointers(-1),
            onPointerCancel: (_) => _updatePointers(-1),
            child: PageView.builder(
              controller: _pageController,
              reverse: false,
              physics: (_zoomed || _multiTouch)
                  ? const NeverScrollableScrollPhysics()
                  : const PageScrollPhysics(),
              onPageChanged: _onPageChanged,
              itemCount: module.book.totalPages,
              itemBuilder: (context, index) => BookPageView(
                document: _document,
                pageNumber: index + 1,
                onTap: _toggleImmersive,
                onZoomChanged: (z) {
                  if (z != _zoomed) setState(() => _zoomed = z);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Collapses chrome to zero height (with a fade) instead of removing it, so the
/// Expanded pager keeps a stable index and the PageController never resets.
class _Collapse extends StatelessWidget {
  const _Collapse({required this.visible, required this.child});
  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: visible ? 1 : 0,
        child:
            visible ? child : const SizedBox(width: double.infinity, height: 0),
      ),
    );
  }
}
