package com.example.ui.components

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.BookData
import com.example.ui.theme.CairoFontFamily
import com.example.ui.theme.LocalCustomColors

@Composable
fun SectionIndicatorComponent(
    currentPage: Int,
    toArabic: (Int) -> String
) {
    val customColors = LocalCustomColors.current
    
    val activeSection = remember(currentPage) { BookData.getSectionForPage(currentPage) }
    
    val progressData = remember(currentPage, activeSection) {
        val index = BookData.TABLE_OF_CONTENTS.indexOf(activeSection)
        val nextStartPage = if (index != -1 && index < BookData.TABLE_OF_CONTENTS.lastIndex) {
            BookData.TABLE_OF_CONTENTS[index + 1].bookPage
        } else {
            138 // Total pages + 1
        }
        
        val totalPagesInSection = nextStartPage - activeSection.bookPage
        val pagesRead = currentPage - activeSection.bookPage + 1
        val progress = if (totalPagesInSection > 0) {
            pagesRead.toFloat() / totalPagesInSection.toFloat()
        } else {
            1f
        }
        
        Triple(pagesRead, totalPagesInSection, progress.coerceIn(0f, 1f))
    }
    
    val (pagesRead, totalPagesInSection, progress) = progressData
    val animatedProgress by animateFloatAsState(
        targetValue = progress,
        animationSpec = tween(durationMillis = 300),
        label = "SectionProgressAnimation"
    )

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .background(customColors.headerFooter)
            .padding(horizontal = 16.dp, vertical = 4.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = activeSection.title,
                fontFamily = CairoFontFamily,
                fontWeight = FontWeight.Bold,
                fontSize = 14.sp,
                color = customColors.gold
            )
            
            Text(
                text = "${toArabic(pagesRead)} من ${toArabic(totalPagesInSection)} صفحة",
                fontFamily = CairoFontFamily,
                fontSize = 12.sp,
                color = customColors.textMuted
            )
        }
        
        Spacer(modifier = Modifier.height(8.dp))
        
        LinearProgressIndicator(
            progress = { animatedProgress },
            modifier = Modifier
                .fillMaxWidth()
                .height(2.dp)
                .clip(RoundedCornerShape(1.dp)),
            color = customColors.gold,
            trackColor = customColors.textMuted.copy(alpha = 0.15f)
        )
    }
}
