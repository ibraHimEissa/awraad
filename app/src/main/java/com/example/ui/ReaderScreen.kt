package com.example.ui

import android.content.Context
import android.graphics.Bitmap
import androidx.compose.animation.*
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.BookData
import com.example.ui.components.*
import com.example.ui.theme.AmiriFontFamily
import com.example.ui.theme.CairoFontFamily
import com.example.ui.theme.LocalCustomColors
import com.example.ui.theme.OradTheme
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.input.pointer.pointerInput
import androidx.activity.compose.BackHandler
import androidx.compose.ui.window.Dialog
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.gestures.detectTransformGestures
import androidx.compose.foundation.gestures.awaitEachGesture
import androidx.compose.foundation.gestures.awaitFirstDown
import androidx.compose.foundation.gestures.calculateCentroid
import androidx.compose.foundation.gestures.calculatePan
import androidx.compose.foundation.gestures.calculateZoom
import androidx.compose.ui.geometry.Offset
import com.example.ui.viewmodel.BookViewModel
import com.example.utils.PdfPageRenderer
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

enum class AppScreen {
    SPLASH,
    READER
}

@OptIn(ExperimentalAnimationApi::class, ExperimentalMaterial3Api::class)
@Composable
fun ReaderScreen(
    viewModel: BookViewModel,
    context: Context
) {
    val isDarkTheme by viewModel.isDarkMode.collectAsState()
    val activeScreen = remember { mutableStateOf(AppScreen.SPLASH) }

    // Navigation and layout parameters
    val scope = rememberCoroutineScope()
    val customColors = LocalCustomColors.current

    // Observe Toast message from Viewmodel
    val toastMessage by viewModel.toastMessage.collectAsState()
    val snackbarHostState = remember { SnackbarHostState() }

    // Load PDF Presence in state
    var isPdfPresentState by remember { mutableStateOf(false) }

    LaunchedEffect(toastMessage) {
        toastMessage?.let { msg ->
            scope.launch {
                snackbarHostState.showSnackbar(
                    message = msg,
                    duration = SnackbarDuration.Short
                )
                viewModel.clearToast()
            }
        }
    }

    LaunchedEffect(Unit) {
        // Evaluate PDF state and delay for Splash Transition
        isPdfPresentState = PdfPageRenderer.isPdfPresent(context)
        delay(1500)
        activeScreen.value = AppScreen.READER
    }

    OradTheme(darkTheme = isDarkTheme) {
        val themeColors = LocalCustomColors.current

        // Force RTL layout direction regardless of system language
        CompositionLocalProvider(
            androidx.compose.ui.platform.LocalLayoutDirection provides
                    androidx.compose.ui.unit.LayoutDirection.Rtl
        ) {
            Surface(
                modifier = Modifier.fillMaxSize(),
                color = themeColors.background
            ) {
                AnimatedContent(
                    targetState = activeScreen.value,
                    transitionSpec = {
                        fadeIn(animationSpec = tween(600)) with fadeOut(animationSpec = tween(600))
                    },
                    label = "ScreenTransition"
                ) { screen ->
                    when (screen) {
                        AppScreen.SPLASH -> {
                            SplashScreenLayout()
                        }
                        AppScreen.READER -> {
                            MainReaderLayout(
                                viewModel = viewModel,
                                isPdfPresent = isPdfPresentState,
                                context = context,
                                snackbarHostState = snackbarHostState
                            )
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun SplashScreenLayout() {
    val customColors = LocalCustomColors.current
    Box(
        modifier = Modifier
            .fillMaxSize()
            .drawIslamicPattern(customColors.gold, alpha = 0.08f)
            .background(
                Brush.verticalGradient(
                    colors = listOf(
                        customColors.background,
                        customColors.drawerBg
                    )
                )
            ),
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            modifier = Modifier.padding(24.dp)
        ) {
            SufiLogo(size = 180.dp)
            Spacer(modifier = Modifier.height(30.dp))
            
            Text(
                text = "كِتَابُ الْأَوْرَادِ",
                fontFamily = AmiriFontFamily,
                fontWeight = FontWeight.Bold,
                fontSize = 32.sp,
                color = customColors.gold,
                textAlign = TextAlign.Center
            )
            Spacer(modifier = Modifier.height(8.dp))
            
            Text(
                text = "الطَّرِيقَةُ الْبُرْهَانِيَّةُ الدَّسُوقِيَّةُ الشَّاذِلِيَّةُ",
                fontFamily = CairoFontFamily,
                fontSize = 14.sp,
                color = customColors.textMuted,
                textAlign = TextAlign.Center
            )
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MainReaderLayout(
    viewModel: BookViewModel,
    isPdfPresent: Boolean,
    context: Context,
    snackbarHostState: SnackbarHostState
) {
    val customColors = LocalCustomColors.current
    val currentPage by viewModel.currentPage.collectAsState()
    val isBookmarked by viewModel.isCurrentPageBookmarked.collectAsState()
    val bookmarks by viewModel.bookmarks.collectAsState()
    val searchResults by viewModel.searchResults.collectAsState()
    val searchQuery by viewModel.searchQuery.collectAsState()
    
    val isJumpDialogVisible by viewModel.isJumpDialogVisible.collectAsState()
    val isSearchVisible by viewModel.isSearchDialogVisible.collectAsState()

    var pagerScrollEnabled by remember { mutableStateOf(true) }

    val scope = rememberCoroutineScope()
    val configuration = LocalConfiguration.current
    val isLandscape = configuration.orientation == android.content.res.Configuration.ORIENTATION_LANDSCAPE
    var isFullScreen by remember { mutableStateOf(false) }
    var showExitDialog by remember { mutableStateOf(false) }

    val view = LocalView.current
    val window = (view.context as? android.app.Activity)?.window
    LaunchedEffect(isFullScreen) {
        if (window != null) {
            val windowInsetsController = androidx.core.view.WindowCompat.getInsetsController(window, view)
            if (isFullScreen) {
                windowInsetsController.hide(androidx.core.view.WindowInsetsCompat.Type.systemBars())
                windowInsetsController.systemBarsBehavior = androidx.core.view.WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
            } else {
                windowInsetsController.show(androidx.core.view.WindowInsetsCompat.Type.systemBars())
            }
        }
    }

    // Local Drawer State
    val drawerState = rememberDrawerState(initialValue = DrawerValue.Closed)

    BackHandler(enabled = true) {
        if (drawerState.isOpen) {
            scope.launch { drawerState.close() }
        } else if (isFullScreen) {
            isFullScreen = false
        } else if (isSearchVisible) {
            viewModel.isSearchDialogVisible.value = false
        } else if (isJumpDialogVisible) {
            viewModel.isJumpDialogVisible.value = false
        } else {
            showExitDialog = true
        }
    }

    if (showExitDialog) {
        val activity = view.context as? android.app.Activity
        Dialog(
            onDismissRequest = { showExitDialog = false }
        ) {
            Card(
                modifier = Modifier
                    .fillMaxWidth(0.92f)
                    .border(
                        width = 1.5.dp,
                        brush = Brush.linearGradient(
                            colors = listOf(
                                customColors.gold.copy(alpha = 0.7f),
                                customColors.gold.copy(alpha = 0.2f),
                                customColors.gold.copy(alpha = 0.7f)
                            )
                        ),
                        shape = RoundedCornerShape(20.dp)
                    ),
                shape = RoundedCornerShape(20.dp),
                colors = CardDefaults.cardColors(
                    containerColor = customColors.surface
                ),
                elevation = CardDefaults.cardElevation(defaultElevation = 12.dp)
            ) {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .background(
                            Brush.verticalGradient(
                                colors = listOf(
                                    customColors.gold.copy(alpha = 0.06f),
                                    Color.Transparent,
                                    customColors.gold.copy(alpha = 0.03f)
                                )
                            )
                        )
                        .padding(24.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    // Decorative Islamic ornament
                    SufiLogo(size = 56.dp, showGlow = false)

                    Spacer(modifier = Modifier.height(16.dp))

                    // Title
                    Text(
                        text = "تأكيد الخروج",
                        fontFamily = AmiriFontFamily,
                        fontWeight = FontWeight.Bold,
                        fontSize = 22.sp,
                        color = customColors.gold,
                        textAlign = TextAlign.Center
                    )

                    Spacer(modifier = Modifier.height(8.dp))

                    // Decorative separator ─ ۞ ─
                    Text(
                        text = "─── ۞ ───",
                        fontSize = 14.sp,
                        color = customColors.gold.copy(alpha = 0.5f),
                        textAlign = TextAlign.Center,
                        fontFamily = AmiriFontFamily
                    )

                    Spacer(modifier = Modifier.height(12.dp))

                    // Message
                    Text(
                        text = "هل أنت متأكد أنك تريد الخروج\nمن التطبيق؟",
                        fontFamily = CairoFontFamily,
                        fontSize = 16.sp,
                        color = customColors.textPrimary,
                        textAlign = TextAlign.Center,
                        lineHeight = 28.sp
                    )

                    Spacer(modifier = Modifier.height(24.dp))

                    // Buttons Row
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        // "لا، ابقَ" button — stay
                        OutlinedButton(
                            onClick = { showExitDialog = false },
                            modifier = Modifier
                                .weight(1f)
                                .height(48.dp),
                            shape = RoundedCornerShape(12.dp),
                            border = androidx.compose.foundation.BorderStroke(
                                1.dp, customColors.gold.copy(alpha = 0.5f)
                            )
                        ) {
                            Text(
                                text = "لا، ابقَ",
                                fontFamily = CairoFontFamily,
                                fontWeight = FontWeight.Bold,
                                fontSize = 15.sp,
                                color = customColors.gold
                            )
                        }

                        // "نعم، اخرج" button — exit
                        Button(
                            onClick = {
                                showExitDialog = false
                                activity?.finishAffinity()
                            },
                            modifier = Modifier
                                .weight(1f)
                                .height(48.dp),
                            shape = RoundedCornerShape(12.dp),
                            colors = ButtonDefaults.buttonColors(
                                containerColor = Color(0xFFB71C1C).copy(alpha = 0.85f)
                            )
                        ) {
                            Text(
                                text = "نعم، اخرج",
                                fontFamily = CairoFontFamily,
                                fontWeight = FontWeight.Bold,
                                fontSize = 15.sp,
                                color = Color.White
                            )
                        }
                    }
                }
            }
        }
    }

    // Sync isTOCDrawerVisible with our actual Modal drawer state
    val isTOCDrawerVisible by viewModel.isTOCDrawerVisible.collectAsState()
    LaunchedEffect(isTOCDrawerVisible) {
        if (isTOCDrawerVisible) {
            drawerState.open()
        } else {
            drawerState.close()
        }
    }
    LaunchedEffect(drawerState.currentValue) {
        if (drawerState.isClosed) {
            viewModel.isTOCDrawerVisible.value = false
        }
    }

    // Horizontal Pager for buttery page turns
    val pagerState = rememberPagerState(
        initialPage = (currentPage - 1).coerceIn(0, 136),
        pageCount = { 137 }
    )

    // Sync VM currentPage state changes to Pager
    LaunchedEffect(currentPage) {
        val targetPage = currentPage - 1
        pagerScrollEnabled = true
        if (pagerState.currentPage != targetPage) {
            pagerState.animateScrollToPage(targetPage)
        }
    }

    // Sync Swiping page flips back to VM
    LaunchedEffect(pagerState) {
        snapshotFlow { pagerState.currentPage to pagerState.isScrollInProgress }.collect { (pageIdx, inProgress) ->
            if (!inProgress) {
                val targetPage = pageIdx + 1
                if (currentPage != targetPage) {
                    viewModel.jumpToPage(targetPage)
                }
            }
        }
    }

    // Modal Drawer for right RTL Drawer Slide
    ModalNavigationDrawer(
        drawerState = drawerState,
        drawerContent = {
            ModalDrawerSheet(
                drawerContainerColor = Color.Transparent,
                modifier = Modifier.width(320.dp)
            ) {
                TOCDrawerContent(
                    currentPage = currentPage,
                    bookmarks = bookmarks,
                    onSectionClick = { page ->
                        viewModel.jumpToPage(page)
                        scope.launch { drawerState.close() }
                    },
                    onBookmarkClick = { page ->
                        viewModel.jumpToPage(page)
                        scope.launch { drawerState.close() }
                    },
                    onBookmarkLongClick = { page ->
                        viewModel.removeBookmark(page)
                    },
                    onCloseClick = {
                        scope.launch { drawerState.close() }
                    },
                    toArabic = { viewModel.toArabicNumerals(it) }
                )
            }
        },
        gesturesEnabled = true
    ) {
        Scaffold(
            snackbarHost = { SnackbarHost(snackbarHostState) },
            topBar = {
                AnimatedVisibility(
                    visible = !isFullScreen,
                    enter = slideInVertically(initialOffsetY = { -it }),
                    exit = slideOutVertically(targetOffsetY = { -it })
                ) {
                    Column {
                        // Main Header
                        HeaderComponent(
                            currentPage = currentPage,
                            isBookmarked = isBookmarked,
                            onBookmarkToggle = { viewModel.toggleBookmark() },
                            onDrawerOpen = {
                                scope.launch { drawerState.open() }
                            },
                            onThemeToggle = { viewModel.toggleTheme() },
                            isDark = viewModel.isDarkMode.value,
                            toArabic = { viewModel.toArabicNumerals(it) }
                        )
                        // Section progress indicator (Bug #9)
                        SectionIndicatorComponent(
                            currentPage = currentPage,
                            toArabic = { viewModel.toArabicNumerals(it) }
                        )
                    }
                }
            },
            bottomBar = {
                AnimatedVisibility(
                    visible = !isFullScreen && !isLandscape,
                    enter = slideInVertically(initialOffsetY = { it }),
                    exit = slideOutVertically(targetOffsetY = { it })
                ) {
                    BottomNavBarComponent(
                        currentPage = currentPage,
                        onPrevPage = { viewModel.jumpToPage(currentPage - 1) },
                        onNextPage = { viewModel.jumpToPage(currentPage + 1) },
                        onSearchClick = { viewModel.isSearchDialogVisible.value = true },
                        onPageJumpClick = { viewModel.isJumpDialogVisible.value = true },
                        onBookmarksClick = {
                            scope.launch { drawerState.open() }
                        }
                    )
                }
            },
            containerColor = customColors.background
        ) { innerPadding ->
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(innerPadding)
                    .drawIslamicPattern(customColors.gold, alpha = 0.04f)
            ) {
                // Dynamic page view wrapper
                HorizontalPager(
                    state = pagerState,
                    modifier = Modifier.fillMaxSize(),
                    contentPadding = PaddingValues(horizontal = 8.dp, vertical = 4.dp),
                    pageSpacing = 8.dp,
                    reverseLayout = true,
                    userScrollEnabled = pagerScrollEnabled
                ) { index ->
                    val pageNum = index + 1
                    BookPageLayout(
                        pageNum = pageNum,
                        isPdfPresent = isPdfPresent,
                        context = context,
                        isLandscape = isLandscape,
                        toArabic = { viewModel.toArabicNumerals(it) },
                        onToggleFullScreen = { isFullScreen = !isFullScreen },
                        onZoomChanged = { zoomed ->
                            if (pageNum == currentPage) {
                                pagerScrollEnabled = !zoomed
                            }
                        }
                    )
                }

                if (isLandscape && !isFullScreen) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .align(Alignment.BottomCenter)
                            .padding(24.dp),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        FloatingActionButton(
                            onClick = { viewModel.jumpToPage(currentPage + 1) },
                            containerColor = customColors.gold.copy(alpha = 0.85f),
                            contentColor = Color.White,
                            modifier = Modifier.size(46.dp),
                            shape = CircleShape
                        ) {
                            Icon(Icons.Default.ArrowBack, "التالي")
                        }

                        FloatingActionButton(
                            onClick = { viewModel.isJumpDialogVisible.value = true },
                            containerColor = customColors.drawerBg,
                            contentColor = customColors.gold,
                            modifier = Modifier.size(46.dp)
                        ) {
                            Icon(Icons.Default.FindInPage, "رقم")
                        }

                        FloatingActionButton(
                            onClick = { viewModel.jumpToPage(currentPage - 1) },
                            containerColor = customColors.gold.copy(alpha = 0.85f),
                            contentColor = Color.White,
                            modifier = Modifier.size(46.dp),
                            shape = CircleShape
                        ) {
                            Icon(Icons.Default.ArrowForward, "السابق")
                        }
                    }
                }

                // If full screen, show floating pill button
                AnimatedVisibility(
                    visible = isFullScreen,
                    enter = fadeIn() + slideInVertically(initialOffsetY = { it }),
                    exit = fadeOut() + slideOutVertically(targetOffsetY = { it }),
                    modifier = Modifier.align(Alignment.BottomCenter).padding(bottom = 32.dp)
                ) {
                    Surface(
                        shape = CircleShape,
                        color = customColors.surface.copy(alpha = 0.9f),
                        shadowElevation = 4.dp,
                        modifier = Modifier.clickable { isFullScreen = false }
                    ) {
                        Row(
                            modifier = Modifier.padding(horizontal = 24.dp, vertical = 12.dp),
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            Icon(Icons.Default.FullscreenExit, contentDescription = "خروج", tint = customColors.gold)
                            Text("خروج", color = customColors.gold, fontWeight = FontWeight.Bold, fontFamily = CairoFontFamily)
                        }
                    }
                }
            }
        }
    }

    // Jump Dialog Popup
    if (isJumpDialogVisible) {
        JumpDialog(
            onDismiss = { viewModel.isJumpDialogVisible.value = false },
            onConfirm = { page ->
                viewModel.jumpToPage(page)
                viewModel.isJumpDialogVisible.value = false
            }
        )
    }

    // Search Dialog Popup
    if (isSearchVisible) {
        SearchDialog(
            query = searchQuery,
            onQueryChange = { viewModel.updateSearchQuery(it) },
            results = searchResults,
            onResultClick = { page ->
                viewModel.jumpToPage(page)
                viewModel.isSearchDialogVisible.value = false
            },
            onDismiss = { viewModel.isSearchDialogVisible.value = false },
            toArabic = { viewModel.toArabicNumerals(it) }
        )
    }
}

@Composable
fun BookPageLayout(
    pageNum: Int,
    isPdfPresent: Boolean,
    context: Context,
    isLandscape: Boolean,
    toArabic: (Int) -> String,
    onToggleFullScreen: () -> Unit,
    onZoomChanged: (Boolean) -> Unit = {}
) {
    val customColors = LocalCustomColors.current
    var pageBitmap by remember { mutableStateOf<Bitmap?>(null) }
    var isLoading by remember { mutableStateOf(true) }

    var scale by remember { mutableStateOf(1f) }
    var offset by remember { mutableStateOf(androidx.compose.ui.geometry.Offset.Zero) }

    // Load PDF page asynchronously on task dispatchers
    // pdfPageIndex: bookPage - 1 converts book page to 1-indexed PDF page
    // e.g. bookPage 30 -> pdfPageIndex 29 -> renderPage opens zeroIndex 28
    val pdfPageIndex = pageNum - 1

    LaunchedEffect(pageNum, isPdfPresent) {
        scale = 1f
        offset = androidx.compose.ui.geometry.Offset.Zero
        onZoomChanged(false)
        if (isPdfPresent) {
            isLoading = true
            val bitmap = if (pdfPageIndex >= 1) {
                PdfPageRenderer.renderPage(context, pdfPageIndex)
            } else null
            pageBitmap = bitmap
            isLoading = false
        } else {
            isLoading = false
        }
    }

    // Card page resembling warm scroll manuscript
    Card(
        modifier = Modifier
            .fillMaxSize()
            .shadow(6.dp, RoundedCornerShape(12.dp))
            .border(
                if (isPdfPresent) 0.dp else 1.5.dp,
                customColors.gold.copy(alpha = 0.3f),
                RoundedCornerShape(12.dp)
            ),
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(
            // Page bg is warm parchment #FAF6EE under dark/light themes
            containerColor = Color(0xFFFAF6EE)
        )
    ) {
        BoxWithConstraints(
            modifier = Modifier
                .fillMaxSize()
                .padding(if (isLandscape) 4.dp else 4.dp),
            contentAlignment = Alignment.Center
        ) {
            val width = constraints.maxWidth.toFloat()
            val height = constraints.maxHeight.toFloat()

            if (isPdfPresent && pageBitmap != null) {
                // Raw PDF Page Render
                Image(
                    bitmap = pageBitmap!!.asImageBitmap(),
                    contentDescription = "الصفحة ${toArabic(pageNum)}",
                    modifier = Modifier
                        .fillMaxSize()
                        .pointerInput(Unit) {
                            awaitEachGesture {
                                var pastTouchSlop = false
                                val touchSlop = viewConfiguration.touchSlop
                                var zoom = 1f
                                var pan = Offset.Zero

                                awaitFirstDown(requireUnconsumed = false)
                                do {
                                    val event = awaitPointerEvent()
                                    val canceled = event.changes.any { it.isConsumed }
                                    if (!canceled) {
                                        val zoomChange = event.calculateZoom()
                                        val panChange = event.calculatePan()

                                        val fingersCount = event.changes.count { it.pressed }

                                        if (!pastTouchSlop) {
                                            zoom *= zoomChange
                                            pan += panChange

                                            val panMotion = pan.getDistance()

                                            if (panMotion > touchSlop || fingersCount > 1 || scale > 1.05f) {
                                                pastTouchSlop = true
                                            }
                                        }

                                        if (pastTouchSlop) {
                                            val centroid = event.calculateCentroid(useCurrent = true)
                                            if (centroid != Offset.Unspecified && (zoomChange != 1f || panChange != Offset.Zero)) {
                                                val oldScale = scale
                                                val newScale = (scale * zoomChange).coerceIn(1f, 3f)
                                                
                                                val maxOffsetX = (width * (newScale - 1f)) / 2f
                                                val maxOffsetY = (height * (newScale - 1f)) / 2f
                                                
                                                val centroidFromCenter = centroid - Offset(width / 2f, height / 2f)
                                                val zoomShift = centroidFromCenter * (newScale / oldScale - 1f)
                                                
                                                val targetOffset = offset + panChange - zoomShift
                                                
                                                scale = newScale
                                                offset = Offset(
                                                    x = targetOffset.x.coerceIn(-maxOffsetX, maxOffsetX),
                                                    y = targetOffset.y.coerceIn(-maxOffsetY, maxOffsetY)
                                                )
                                                onZoomChanged(scale > 1.05f)
                                            }
                                            
                                            if (scale > 1.05f || fingersCount > 1) {
                                                event.changes.forEach { change ->
                                                    change.consume()
                                                }
                                            }
                                        }
                                    }
                                } while (!canceled && event.changes.any { it.pressed })
                            }
                        }
                        .pointerInput(Unit) {
                            detectTapGestures(
                                onDoubleTap = { tapOffset ->
                                    if (scale > 1f) {
                                        scale = 1f
                                        offset = Offset.Zero
                                    } else {
                                        val targetScale = 2f
                                        val maxOffsetX = (width * (targetScale - 1f)) / 2f
                                        val maxOffsetY = (height * (targetScale - 1f)) / 2f
                                        
                                        val tapFromCenter = tapOffset - Offset(width / 2f, height / 2f)
                                        val zoomShift = tapFromCenter * (targetScale - 1f)
                                        
                                        scale = targetScale
                                        offset = Offset(
                                            x = (-zoomShift.x).coerceIn(-maxOffsetX, maxOffsetX),
                                            y = (-zoomShift.y).coerceIn(-maxOffsetY, maxOffsetY)
                                        )
                                    }
                                    onZoomChanged(scale > 1.05f)
                                },
                                onTap = {
                                    onToggleFullScreen()
                                }
                            )
                        }
                        .graphicsLayer(
                            scaleX = scale,
                            scaleY = scale,
                            translationX = offset.x,
                            translationY = offset.y
                        )
                )
            } else if (isLoading) {
                CircularProgressIndicator(color = customColors.gold)
            } else {
                // Elegant vector calligraphic type layout if raw PDF is absent
                Box(modifier = Modifier.fillMaxSize().pointerInput(Unit) {
                    detectTapGestures(onTap = { onToggleFullScreen() })
                }) {
                    DigitalCalligraphyPage(pageNum = pageNum, toArabic = toArabic)
                }
            }
        }
    }
}

@Composable
fun DigitalCalligraphyPage(
    pageNum: Int,
    toArabic: (Int) -> String
) {
    // Read corresponding text from helper
    val activeSection = BookData.getSectionForPage(pageNum)
    val textToShow = BookData.DIGITAL_PRAYERS[activeSection.bookPage] ?: "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ"

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState()),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        // Heptagonal Rosette gold icon to decorate digital book section header
        SufiLogo(size = 42.dp, showGlow = false)
        
        Spacer(modifier = Modifier.height(10.dp))
        
        Text(
            text = activeSection.title,
            fontFamily = CairoFontFamily,
            fontWeight = FontWeight.Bold,
            fontSize = 18.sp,
            color = Color(0xFF9A6B1F), // Gold ink
            textAlign = TextAlign.Center
        )

        Spacer(modifier = Modifier.height(16.dp))

        // Large beautiful text of Al-Urud/Al-Wird
        Text(
            text = textToShow,
            fontFamily = AmiriFontFamily,
            fontWeight = FontWeight.Normal,
            fontSize = 22.sp,
            lineHeight = 36.sp,
            color = Color(0xFF2C1A00), // Rich brown ink
            textAlign = TextAlign.Center,
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 8.dp)
        )

        Spacer(modifier = Modifier.height(30.dp))

        Text(
            text = "۞  ${toArabic(pageNum)}  ۞",
            fontFamily = AmiriFontFamily,
            fontSize = 16.sp,
            color = Color(0xFF9A6B1F),
            fontWeight = FontWeight.Bold
        )
    }
}
