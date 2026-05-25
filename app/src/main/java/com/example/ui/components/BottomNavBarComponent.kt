package com.example.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.ArrowForward
import androidx.compose.material.icons.filled.Bookmark
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.ui.theme.LocalCustomColors

@Composable
fun BottomNavBarComponent(
    currentPage: Int,
    onPrevPage: () -> Unit,
    onNextPage: () -> Unit,
    onSearchClick: () -> Unit,
    onPageJumpClick: () -> Unit,
    onBookmarksClick: () -> Unit
) {
    val customColors = LocalCustomColors.current

    Surface(
        modifier = Modifier
            .fillMaxWidth()
            .drawBehind {
                // Fine gold line at top of bottom bar
                drawLine(
                    color = customColors.gold,
                    start = Offset(0f, 0f),
                    end = Offset(size.width, 0f),
                    strokeWidth = 1.dp.toPx()
                )
            },
        color = customColors.headerFooter
    ) {
        Row(
            modifier = Modifier
                .windowInsetsPadding(WindowInsets.navigationBars)
                .fillMaxWidth()
                .padding(horizontal = 24.dp, vertical = 4.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            // 1. Prev Page Button (Right Arrow) — appears on the RIGHT in RTL
            IconButton(
                onClick = onPrevPage,
                enabled = currentPage > 1,
                modifier = Modifier.size(44.dp)
            ) {
                Icon(
                    imageVector = Icons.Default.ArrowForward, // Right Arrow
                    contentDescription = "السابق",
                    tint = if (currentPage > 1) customColors.gold else customColors.textMuted.copy(alpha = 0.25f),
                    modifier = Modifier.size(24.dp)
                )
            }

            // 2. Central Action Cluster
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                // Bookmarks quick button (circular, dark surface)
                IconButton(
                    onClick = onBookmarksClick,
                    modifier = Modifier
                        .size(40.dp)
                        .background(customColors.background, CircleShape)
                        .clip(CircleShape)
                ) {
                    Icon(
                        imageVector = Icons.Default.Bookmark,
                        contentDescription = "الإشارات المرجعية",
                        tint = customColors.gold,
                        modifier = Modifier.size(18.dp)
                    )
                }

                // Page Number Button (circular, gold border) opens Jump Dialog
                Box(
                    modifier = Modifier
                        .size(44.dp)
                        .border(1.5.dp, customColors.gold, CircleShape)
                        .background(customColors.surface, CircleShape)
                        .clip(CircleShape)
                        .clickable { onPageJumpClick() },
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = currentPage.toString(),
                        fontFamily = FontFamily.Monospace,
                        fontWeight = FontWeight.Bold,
                        fontSize = 14.sp,
                        color = customColors.gold
                    )
                }

                // Search circle icon in blue (#1A56DB)
                IconButton(
                    onClick = onSearchClick,
                    modifier = Modifier
                        .size(40.dp)
                        .background(Color(0xFF1A56DB), CircleShape)
                        .clip(CircleShape)
                ) {
                    Icon(
                        imageVector = Icons.Default.Search,
                        contentDescription = "بحث",
                        tint = Color.White,
                        modifier = Modifier.size(18.dp)
                    )
                }
            }

            // 3. Next Page Button (Left Arrow) — appears on the LEFT in RTL
            IconButton(
                onClick = onNextPage,
                enabled = currentPage < 137,
                modifier = Modifier.size(44.dp)
            ) {
                Icon(
                    imageVector = Icons.Default.ArrowBack, // Left Arrow
                    contentDescription = "التالي",
                    tint = if (currentPage < 137) customColors.gold else customColors.textMuted.copy(alpha = 0.25f),
                    modifier = Modifier.size(24.dp)
                )
            }
        }
    }
}
