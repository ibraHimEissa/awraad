import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../data/book_data.dart';
import '../data/models.dart';
import '../state/book_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/app_header.dart';
import '../widgets/app_snack.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/islamic_pattern.dart';
import '../widgets/logo_watermark.dart';
import '../widgets/notes_sheet.dart';
import '../widgets/reader_dialogs.dart';
import '../widgets/section_indicator.dart';
import '../widgets/toc_drawer.dart';
import '../widgets/verse_locator_card.dart';
import 'book_page_view.dart';
import 'onboarding_screen.dart';

class ReaderScreen extends StatefulWidget {
  const ReaderScreen({super.key});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late final PageController _pageController;
  late final BookController _controller;

  PdfDocument? _document;

  /// Immersive = chrome (app bar + bottom bar) collapsed and system UI hidden,
  /// so only the page shows. The pager stays mounted the whole time, so the
  /// current page never resets when toggling.
  bool _immersive = false;
  bool _zoomed = false;
  bool _multiTouch = false;
  int _activePointers = 0;
  bool _syncingFromController = false;

  @override
  void initState() {
    super.initState();
    _controller = context.read<BookController>();
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
    final doc = await PdfDocument.openAsset('assets/pdf/book.pdf');
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

  Future<void> _handleBack() async {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
      return;
    }
    if (_immersive) {
      _toggleImmersive();
      return;
    }
    final shouldExit = await showExitDialog(context);
    if (shouldExit) {
      SystemNavigator.pop();
    }
  }

  void _openSearch(BookController c) {
    showSearchSheet(
      context,
      onSelectVerse: (hit) {
        final poem = BookData.poemById(hit.poemId);
        c.showVerse(
          VerseLocator(
            page: hit.page,
            verseNo: hit.verseNo,
            text: hit.text,
            poemLabel: poem?.label ?? '',
          ),
        );
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.background,
        drawerEnableOpenDragGesture: !_zoomed,
        drawer: Consumer<BookController>(
          builder: (context, c, _) => TocDrawer(
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
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const OnboardingScreen(asGuide: true),
                ),
              );
            },
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.backgroundGradient,
          ),
          // Four stable children — the Expanded pager never changes index, so
          // the PageController position is preserved across immersive toggles.
          child: Column(
            children: [
              // ① App bar
              _Collapse(
                visible: !_immersive,
                child: Consumer<BookController>(
                  builder: (context, c, _) => AppHeader(
                    currentPage: c.currentPage,
                    isBookmarked: c.isCurrentBookmarked,
                    onMenu: () => _scaffoldKey.currentState?.openDrawer(),
                    onBookmarkToggle: c.toggleBookmark,
                    onFullscreen: _toggleImmersive,
                  ),
                ),
              ),
              // ② Poem indicator strip
              _Collapse(
                visible: !_immersive,
                child: Consumer<BookController>(
                  builder: (context, c, _) =>
                      SectionIndicator(currentPage: c.currentPage),
                ),
              ),
              // ③ The pager (always mounted)
              Expanded(child: _buildPager()),
              // ④ Verse locator card + bottom bar
              _Collapse(
                visible: !_immersive,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Consumer<BookController>(
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
                    Consumer<BookController>(
                      builder: (context, c, _) => BottomNavBar(
                        currentPage: c.currentPage,
                        hasNote: c.currentHasNote,
                        onPrev: () => c.jumpToPage(c.currentPage - 1),
                        onNext: () => c.jumpToPage(c.currentPage + 1),
                        onNotes: () => showNotesSheet(
                          context,
                          page: c.currentPage,
                          onSelectPage: c.jumpToPage,
                        ),
                        onJump: () =>
                            showJumpDialog(context, onConfirm: c.jumpToPage),
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
              itemCount: BookData.totalPages,
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

/// Collapses its child to zero height (with a fade) when [visible] is false,
/// instead of removing it from the tree — keeping sibling indices stable so
/// the pager's PageController is never rebuilt. This is what makes immersive
/// mode preserve the current page.
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
        child: visible
            ? child
            : const SizedBox(width: double.infinity, height: 0),
      ),
    );
  }
}
