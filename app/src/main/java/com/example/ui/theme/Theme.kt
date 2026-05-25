package com.example.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.Immutable
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.graphics.Color

@Immutable
data class CustomThemeColors(
    val background: Color,
    val surface: Color,
    val headerFooter: Color,
    val gold: Color,
    val textPrimary: Color,
    val textMuted: Color,
    val pageBg: Color,
    val drawerBg: Color
)

val LocalCustomColors = staticCompositionLocalOf {
    CustomThemeColors(
        background = Color.Unspecified,
        surface = Color.Unspecified,
        headerFooter = Color.Unspecified,
        gold = Color.Unspecified,
        textPrimary = Color.Unspecified,
        textMuted = Color.Unspecified,
        pageBg = Color.Unspecified,
        drawerBg = Color.Unspecified
    )
}

private val DarkCustomColors = CustomThemeColors(
    background = DarkBackground,
    surface = DarkSurface,
    headerFooter = DarkHeaderFooter,
    gold = DarkGold,
    textPrimary = DarkTextPrimary,
    textMuted = DarkTextMuted,
    pageBg = DarkPageBg,
    drawerBg = DarkDrawerBg
)

private val LightCustomColors = CustomThemeColors(
    background = LightBackground,
    surface = LightSurface,
    headerFooter = LightHeaderFooter,
    gold = LightGold,
    textPrimary = LightTextPrimary,
    textMuted = LightTextMuted,
    pageBg = LightPageBg,
    drawerBg = LightDrawerBg
)

private val DarkColorScheme = darkColorScheme(
    primary = DarkGold,
    secondary = DarkSurface,
    background = DarkBackground,
    surface = DarkSurface,
    onBackground = DarkTextPrimary,
    onSurface = DarkTextPrimary
)

private val LightColorScheme = lightColorScheme(
    primary = LightGold,
    secondary = LightSurface,
    background = LightBackground,
    surface = LightSurface,
    onBackground = LightTextPrimary,
    onSurface = LightTextPrimary
)

@Composable
fun OradTheme(
    darkTheme: Boolean = true,
    content: @Composable () -> Unit
) {
    // Force dark colors always, removing light theme entirely
    val colors = DarkCustomColors
    val colorScheme = DarkColorScheme

    CompositionLocalProvider(LocalCustomColors provides colors) {
        MaterialTheme(
            colorScheme = colorScheme,
            typography = Typography,
            content = content
        )
    }
}
