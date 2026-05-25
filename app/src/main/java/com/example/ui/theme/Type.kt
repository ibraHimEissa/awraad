package com.example.ui.theme

import androidx.compose.material3.Typography
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.sp

// Set Serif as Amiri substitute (traditional handwritten-look manuscript)
// and SansSerif as Cairo substitute (Cairo semi-bold modern look)
val AmiriFontFamily = FontFamily.Serif
val CairoFontFamily = FontFamily.SansSerif

val Typography = Typography(
    // Used for the sacred Arabic pages text
    bodyLarge = TextStyle(
        fontFamily = AmiriFontFamily,
        fontWeight = FontWeight.Normal,
        fontSize = 24.sp,
        lineHeight = 38.sp,
        textAlign = TextAlign.Center
    ),
    // Used for section headers
    titleLarge = TextStyle(
        fontFamily = CairoFontFamily,
        fontWeight = FontWeight.Bold,
        fontSize = 20.sp,
        lineHeight = 26.sp,
        textAlign = TextAlign.Center
    ),
    // Used for buttons, menu rows, indicators
    labelLarge = TextStyle(
        fontFamily = CairoFontFamily,
        fontWeight = FontWeight.SemiBold,
        fontSize = 15.sp,
        lineHeight = 20.sp
    ),
    labelSmall = TextStyle(
        fontFamily = FontFamily.Monospace, // Gold page numbers feel
        fontWeight = FontWeight.Medium,
        fontSize = 13.sp,
        lineHeight = 16.sp
    )
)
