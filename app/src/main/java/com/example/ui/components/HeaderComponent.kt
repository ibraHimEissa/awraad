package com.example.ui.components

import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Bookmark
import androidx.compose.material.icons.filled.BookmarkBorder
import androidx.compose.material.icons.filled.Menu
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.ui.theme.CairoFontFamily
import com.example.ui.theme.LocalCustomColors

@Composable
fun HeaderComponent(
    currentPage: Int,
    isBookmarked: Boolean,
    onBookmarkToggle: () -> Unit,
    onDrawerOpen: () -> Unit,
    onThemeToggle: () -> Unit,
    isDark: Boolean,
    toArabic: (Int) -> String
) {
    val customColors = LocalCustomColors.current

    Surface(
        modifier = Modifier
            .fillMaxWidth()
            .drawIslamicPattern(customColors.gold, alpha = 0.08f)
            .drawBehind {
                // Thin gold border line at bottom
                drawLine(
                    color = customColors.gold,
                    start = Offset(0f, size.height),
                    end = Offset(size.width, size.height),
                    strokeWidth = 1.dp.toPx()
                )
            },
        color = customColors.headerFooter
    ) {
        Column(
            modifier = Modifier
                .windowInsetsPadding(WindowInsets.statusBars)
                .padding(horizontal = 8.dp, vertical = 2.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Box(
                modifier = Modifier.fillMaxWidth()
            ) {
                // Actions cluster (bookmark icon, drawer icon) — on the END (left in RTL)
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier
                        .align(Alignment.CenterEnd)
                        .padding(end = 8.dp)
                ) {
                    // Bookmark icon (recolored active gold if bookmarked)
                    IconButton(onClick = onBookmarkToggle) {
                        Icon(
                            imageVector = if (isBookmarked) Icons.Default.Bookmark else Icons.Default.BookmarkBorder,
                            contentDescription = "إشارة مرجعية",
                            tint = if (isBookmarked) customColors.gold else customColors.textMuted
                        )
                    }

                    // Drawer menu (Menu button)
                    IconButton(onClick = onDrawerOpen) {
                        Icon(
                            imageVector = Icons.Default.Menu,
                            contentDescription = "فهرس",
                            tint = customColors.gold
                        )
                    }
                }

                // Center: Logo and title (absolute center)
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    modifier = Modifier.align(Alignment.Center)
                ) {
                    Image(
                        painter = androidx.compose.ui.res.painterResource(id = com.example.R.drawable.app_logo),
                        contentDescription = "Sufi Logo",
                        modifier = Modifier.size(36.dp),
                        contentScale = androidx.compose.ui.layout.ContentScale.Fit
                    )
                    Text(
                        text = "أوراد الطريقة البرهانية",
                        fontFamily = CairoFontFamily,
                        fontWeight = FontWeight.Bold,
                        fontSize = 12.sp,
                        color = androidx.compose.ui.graphics.Color(0xFFC9962A),
                        textAlign = TextAlign.Center
                    )
                }

                // Page numbers — on the START (right in RTL)
                Column(
                    horizontalAlignment = Alignment.Start,
                    modifier = Modifier
                        .align(Alignment.CenterStart)
                        .padding(start = 8.dp)
                ) {
                    Text(
                        text = "${toArabic(currentPage)} / ${toArabic(137)}",
                        fontFamily = FontFamily.Monospace,
                        fontWeight = FontWeight.Bold,
                        fontSize = 14.sp,
                        color = customColors.gold
                    )
                    Text(
                        text = "الْصَّفْحَةُ",
                        fontFamily = CairoFontFamily,
                        fontSize = 10.sp,
                        color = customColors.textMuted
                    )
                }
            }
        }
    }
}
