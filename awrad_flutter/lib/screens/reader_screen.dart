import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../data/book_data.dart';
import '../onboarding/onboarding_tour.dart';
import '../state/book_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/app_snack.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/islamic_pattern.dart';
import '../widgets/logo_watermark.dart';
import '../widgets/notes_sheet.dart';
import '../widgets/reader_dialogs.dart';
import '../widgets/section_indicator.dart';
import '../widgets/toc_drawer.dart';
import 'book_page_view.dart';

class ReaderScreen extends StatefulWidget {
  const ReaderScreen({super.key});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late final PageController _pageController;
  late final BookController _controller;

  // Anchors for the first-launch guided tour.
  final _kMenu = GlobalKey();
  final _kBookmark = GlobalKey();
  final _kFullscreen = GlobalKey();
  final _kCounter = GlobalKey();
  final _kSection = GlobalKey();
  final _kPager = GlobalKey();
  final _kPrev = GlobalKey();
  final _kNotes = GlobalKey();
  final _kJump = GlobalKey();
  final _kSearch = GlobalKey();
  final _kNext = GlobalKey();

  PdfDocument? _document;
  bool _fullscreen = false;
  bool _zoomed = false;
  bool _multiTouch = false;
  int _activePointers = 0;
  bool _syncingFromController = false;
  bool _showTour = false;
  bool _tourStarted = false;

  @override
  void initState() {
    super.initState();
    _controller = context.read<BookController>();
    _pageController = PageController(initialPage: _controller.currentPage - 1);
    _controller.addListener(_onControllerChanged);
    _loadDocument();
    // Keep the screen awake the whole time the app is open.
    WakelockPlus.enable();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final msg = _controller.resumeMessage;
      if (msg != null && mounted) {
        _controller.clearResumeMessage();
        showAppSnack(context, msg, icon: Icons.auto_stories_rounded);
      }
      _maybeStartTour();
    });
  }

  /// Opens the guided tour once, on the very first launch, after the chrome
  /// has been laid out so the spotlight anchors can be measured.
  void _maybeStartTour() {
    if (_tourStarted || !mounted || !_controller.shouldShowOnboarding) return;
    _tourStarted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _showTour = true);
    });
  }

  void _finishTour() {
    _controller.markOnboardingSeen();
    if (mounted) setState(() => _showTour = false);
  }

  Future<void> _loadDocument() async {
    final doc = await PdfDocument.openAsset('assets/pdf/book.pdf');
    if (mounted) setState(() => _document = doc);
  }

  void _onControllerChanged() {
    // Covers the case where the controller finishes loading after first frame.
    _maybeStartTour();
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

  Future<void> _toggleFullscreen() async {
    setState(() => _fullscreen = !_fullscreen);
    await SystemChrome.setEnabledSystemUIMode(
      _fullscreen ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );
  }

  Future<void> _handleBack() async {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
      return;
    }
    if (_fullscreen) {
      _toggleFullscreen();
      return;
    }
    final shouldExit = await showExitDialog(context);
    if (shouldExit) {
      SystemNavigator.pop();
    }
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
      child: Stack(
        fit: StackFit.expand,
        children: [
          Scaffold(
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
              ),
            ),
            body: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.backgroundGradient,
              ),
              child: Column(
                children: [
                  if (!_fullscreen)
                    Consumer<BookController>(
                      builder: (context, c, _) => AppHeader(
                        currentPage: c.currentPage,
                        isBookmarked: c.isCurrentBookmarked,
                        onMenu: () => _scaffoldKey.currentState?.openDrawer(),
                        onBookmarkToggle: c.toggleBookmark,
                        onFullscreen: _toggleFullscreen,
                        menuKey: _kMenu,
                        bookmarkKey: _kBookmark,
                        fullscreenKey: _kFullscreen,
                        counterKey: _kCounter,
                      ),
                    ),
                  if (!_fullscreen)
                    Consumer<BookController>(
                      builder: (context, c, _) => KeyedSubtree(
                        key: _kSection,
                        child: SectionIndicator(currentPage: c.currentPage),
                      ),
                    ),
                  Expanded(
                    child: KeyedSubtree(key: _kPager, child: _buildPager()),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: _fullscreen
                ? null
                : Consumer<BookController>(
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
                      onSearch: () =>
                          showSearchSheet(context, onSelectPage: c.jumpToPage),
                      prevKey: _kPrev,
                      notesKey: _kNotes,
                      jumpKey: _kJump,
                      searchKey: _kSearch,
                      nextKey: _kNext,
                    ),
                  ),
          ),
          if (_showTour)
            Positioned.fill(
              child: OnboardingTour(
                steps: buildTourSteps(
                  menu: _kMenu,
                  bookmark: _kBookmark,
                  fullscreen: _kFullscreen,
                  counter: _kCounter,
                  section: _kSection,
                  pager: _kPager,
                  prev: _kPrev,
                  notes: _kNotes,
                  jump: _kJump,
                  search: _kSearch,
                  next: _kNext,
                ),
                onFinish: _finishTour,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPager() {
    return IslamicPatternBackground(
      opacity: 0.03,
      tile: 64,
      child: Stack(
        children: [
          // Faint branded watermark that peeks around the page's rounded
          // corners and during page transitions.
          const Positioned.fill(
            child: LogoWatermark(size: 300, opacity: 0.045),
          ),
          Listener(
            onPointerDown: (_) => _updatePointers(1),
            onPointerUp: (_) => _updatePointers(-1),
            onPointerCancel: (_) => _updatePointers(-1),
            child: PageView.builder(
              controller: _pageController,
              // The whole app is force-RTL (see main.dart), so the PageView
              // already advances right-to-left like a real Arabic book.
              // No extra `reverse` — that would double-flip back to LTR.
              reverse: false,
              // Lock page-swiping while zoomed in OR while two fingers are
              // down, so a pinch-to-zoom can begin anywhere (gallery-style).
              physics: (_zoomed || _multiTouch)
                  ? const NeverScrollableScrollPhysics()
                  : const PageScrollPhysics(),
              onPageChanged: _onPageChanged,
              itemCount: BookData.totalPages,
              itemBuilder: (context, index) => BookPageView(
                document: _document,
                pageNumber: index + 1,
                onTap: _toggleFullscreen,
                onZoomChanged: (z) {
                  if (z != _zoomed) setState(() => _zoomed = z);
                },
              ),
            ),
          ),
          if (_fullscreen)
            Positioned(
              bottom: 28,
              left: 0,
              right: 0,
              child: Center(
                child: _ExitFullscreenPill(onTap: _toggleFullscreen),
              ),
            ),
        ],
      ),
    );
  }
}

class _ExitFullscreenPill extends StatelessWidget {
  const _ExitFullscreenPill({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface.withValues(alpha: 0.92),
      shape: const StadiumBorder(
        side: BorderSide(color: AppColors.gold, width: 1),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 22, vertical: 11),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.fullscreen_exit_rounded,
                color: AppColors.gold,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'خروج من ملء الشاشة',
                style: TextStyle(
                  fontFamily: AppTheme.fontUi,
                  fontWeight: FontWeight.w700,
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
