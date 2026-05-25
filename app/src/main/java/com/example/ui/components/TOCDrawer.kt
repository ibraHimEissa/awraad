package com.example.ui.components

import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Bookmark
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextDirection
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.BookData
import com.example.data.TocSection
import com.example.data.model.Bookmark
import com.example.ui.theme.CairoFontFamily
import com.example.ui.theme.LocalCustomColors

@OptIn(ExperimentalMaterial3Api::class, ExperimentalFoundationApi::class)
@Composable
fun TOCDrawerContent(
    currentPage: Int,
    bookmarks: List<Bookmark>,
    onSectionClick: (Int) -> Unit,
    onBookmarkClick: (Int) -> Unit,
    onBookmarkLongClick: (Int) -> Unit,
    onCloseClick: () -> Unit,
    toArabic: (Int) -> String
) {
    val customColors = LocalCustomColors.current
    var searchQuery by remember { mutableStateOf("") }
    
    // Filter sections dynamically based on local query
    val filteredList = remember(searchQuery) {
        if (searchQuery.isBlank()) {
            BookData.TABLE_OF_CONTENTS
        } else {
            BookData.TABLE_OF_CONTENTS.filter {
                it.title.contains(searchQuery, ignoreCase = true)
            }
        }
    }

    Column(
        modifier = Modifier
            .fillMaxHeight()
            .fillMaxWidth(0.85f)
            .background(customColors.drawerBg)
            .windowInsetsPadding(WindowInsets.statusBars)
    ) {
        // Drawer Header
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Text(
                text = "الفهرس الشَّرِيفُ",
                fontFamily = CairoFontFamily,
                fontWeight = FontWeight.Bold,
                fontSize = 20.sp,
                color = customColors.gold
            )
            
            IconButton(onClick = onCloseClick) {
                Icon(
                    imageVector = Icons.Default.Close,
                    contentDescription = "قفل",
                    tint = customColors.textMuted
                )
            }
        }

        // Thin Gold Border Divider
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(1.dp)
                .background(customColors.gold.copy(alpha = 0.4f))
        )

        // Local TOC Search Bar
        androidx.compose.runtime.CompositionLocalProvider(androidx.compose.ui.platform.LocalLayoutDirection provides androidx.compose.ui.unit.LayoutDirection.Rtl) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(14.dp)
                    .height(52.dp)
                    .background(
                        color = customColors.surface,
                        shape = RoundedCornerShape(8.dp)
                    )
                    .border(
                        width = 1.dp,
                        color = customColors.gold.copy(alpha = 0.5f),
                        shape = RoundedCornerShape(8.dp)
                    )
                    .padding(horizontal = 16.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    imageVector = Icons.Default.Search,
                    contentDescription = "بحث",
                    tint = customColors.gold,
                    modifier = Modifier.size(24.dp)
                )
                Spacer(modifier = Modifier.width(12.dp))
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .fillMaxHeight(),
                    contentAlignment = Alignment.CenterStart
                ) {
                    if (searchQuery.isEmpty()) {
                        Text(
                            text = "بحث في الفهرس...",
                            fontFamily = CairoFontFamily,
                            color = customColors.textMuted.copy(alpha = 0.8f),
                            fontSize = 18.sp,
                            textAlign = TextAlign.Right
                        )
                    }
                    androidx.compose.foundation.text.BasicTextField(
                        value = searchQuery,
                        onValueChange = { searchQuery = it },
                        textStyle = androidx.compose.ui.text.TextStyle(
                            fontFamily = CairoFontFamily,
                            fontSize = 18.sp,
                            color = customColors.textPrimary,
                            textAlign = TextAlign.Right,
                            textDirection = TextDirection.Rtl
                        ),
                        singleLine = true,
                        modifier = Modifier.fillMaxWidth(),
                        cursorBrush = androidx.compose.ui.graphics.SolidColor(customColors.gold),
                        decorationBox = { innerTextField ->
                            Box(
                                modifier = Modifier.fillMaxWidth(),
                                contentAlignment = Alignment.CenterStart
                            ) {
                                innerTextField()
                            }
                        }
                    )
                }
            }
        }

        // Contents Scroll area
        LazyColumn(
            modifier = Modifier
                .weight(1f)
                .fillMaxWidth(),
            contentPadding = PaddingValues(bottom = 16.dp)
        ) {
            // Main Sections
            items(filteredList) { section ->
                val activeSection = BookData.getSectionForPage(currentPage)
                val isSelected = section.id == activeSection.id
                
                // Calculate progress inside this section
                // Fetch next section's page
                val index = BookData.TABLE_OF_CONTENTS.indexOf(section)
                val nextStartPage = if (index < BookData.TABLE_OF_CONTENTS.lastIndex) {
                    BookData.TABLE_OF_CONTENTS[index + 1].bookPage
                } else {
                    138 // Total + 1
                }
                
                val progress = remember(currentPage) {
                    when {
                        currentPage < section.bookPage -> 0f
                        currentPage >= nextStartPage -> 1f
                        else -> {
                            val range = nextStartPage - section.bookPage
                            val done = currentPage - section.bookPage
                            done.toFloat() / range.toFloat()
                        }
                    }
                }

                // Section row
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .background(
                            if (isSelected) customColors.gold.copy(alpha = 0.12f)
                            else Color.Transparent
                        )
                        .clickable { onSectionClick(section.bookPage) }
                        .padding(horizontal = 16.dp, vertical = 12.dp)
                ) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            text = section.title,
                            fontFamily = CairoFontFamily,
                            fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal,
                            fontSize = 15.sp,
                            color = if (isSelected) customColors.gold else customColors.textPrimary
                        )
                        
                        Text(
                            text = "ص ${toArabic(section.bookPage)}",
                            fontFamily = CairoFontFamily,
                            fontSize = 13.sp,
                            color = customColors.textMuted,
                            fontWeight = FontWeight.SemiBold
                        )
                    }
                    
                    Spacer(modifier = Modifier.height(6.dp))
                    
                    // Simple Section progress bar
                    LinearProgressIndicator(
                        progress = progress,
                        color = customColors.gold,
                        trackColor = customColors.textMuted.copy(alpha = 0.15f),
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(3.dp)
                            .clip(RoundedCornerShape(2.dp))
                    )
                }

                Divider(color = customColors.textMuted.copy(alpha = 0.08f), thickness = 0.5.dp)
            }

            // Bookmarks Title heading if we have bookmarks
            if (bookmarks.isNotEmpty()) {
                item {
                    Spacer(modifier = Modifier.height(16.dp))
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 16.dp, vertical = 8.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(
                            imageVector = Icons.Default.Bookmark,
                            contentDescription = null,
                            tint = customColors.gold,
                            modifier = Modifier.size(16.dp)
                        )
                        Spacer(modifier = Modifier.width(6.dp))
                        Text(
                            text = "الإِشَارَاتُ الْمَرْجِعِيَّةُ",
                            fontFamily = CairoFontFamily,
                            fontWeight = FontWeight.Bold,
                            fontSize = 14.sp,
                            color = customColors.gold
                        )
                    }
                    Divider(color = customColors.gold.copy(alpha = 0.2f), thickness = 1.dp)
                }

                // List of Bookmarks
                items(bookmarks) { bookmark ->
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .combinedClickable(
                                onClick = { onBookmarkClick(bookmark.page) },
                                onLongClick = { onBookmarkLongClick(bookmark.page) }
                            )
                            .padding(horizontal = 24.dp, vertical = 10.dp),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Column {
                            Text(
                                text = "صفحة ${toArabic(bookmark.page)}",
                                fontFamily = CairoFontFamily,
                                fontWeight = FontWeight.SemiBold,
                                fontSize = 14.sp,
                                color = customColors.textPrimary
                            )
                            Text(
                                text = bookmark.sectionTitle,
                                fontFamily = CairoFontFamily,
                                fontSize = 12.sp,
                                color = customColors.textMuted
                            )
                        }
                        
                        Text(
                            text = "اضغط مطولاً للحذف",
                            fontFamily = CairoFontFamily,
                            fontSize = 11.sp,
                            color = customColors.textMuted.copy(alpha = 0.7f)
                        )
                    }
                    Divider(color = customColors.textMuted.copy(alpha = 0.05f), thickness = 0.5.dp)
                }
            }
        }
    }
}
