package com.example.ui.components

import androidx.compose.animation.core.*
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.blur
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.foundation.Image
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.example.R
import com.example.ui.theme.DarkGold
import com.example.ui.theme.LocalCustomColors

@Composable
fun SufiLogo(
    modifier: Modifier = Modifier,
    size: Dp = 64.dp,
    logoColor: Color = Color(0xFF1B5E20), // Tariqa Green
    goldColor: Color = DarkGold, // Gold central core
    showGlow: Boolean = true
) {
    val infiniteTransition = rememberInfiniteTransition(label = "LogoGlow")
    
    // Smooth breathing glow scale animation
    val glowScale by infiniteTransition.animateFloat(
        initialValue = 0.85f,
        targetValue = 1.15f,
        animationSpec = infiniteRepeatable(
            animation = tween(durationMillis = 2000, easing = LinearOutSlowInEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "GlowScale"
    )

    Box(
        contentAlignment = Alignment.Center,
        modifier = modifier.size(size)
    ) {
        // Soft gold radial glow behind the logo
        if (showGlow) {
            Box(
                modifier = Modifier
                    .size(size * 1.5f)
                    .blur(20.dp)
                    .background(
                        brush = Brush.radialGradient(
                            colors = listOf(
                                goldColor.copy(alpha = 0.22f * glowScale),
                                Color.Transparent
                            )
                        ),
                        shape = CircleShape
                    )
            )
        }

        // Draw the image logo
        Image(
            painter = painterResource(id = R.drawable.app_logo),
            contentDescription = "Sufi Logo",
            modifier = Modifier.size(size)
        )
    }
}
