package com.example.ui.components

import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import com.example.ui.theme.CairoFontFamily
import com.example.ui.theme.LocalCustomColors

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun JumpDialog(
    onDismiss: () -> Unit,
    onConfirm: (Int) -> Unit
) {
    var pageInput by remember { mutableStateOf("") }
    var errorMessage by remember { mutableStateOf<String?>(null) }
    val customColors = LocalCustomColors.current

    Dialog(onDismissRequest = onDismiss) {
        Card(
            modifier = Modifier
                .fillMaxWidth(0.9f)
                .border(1.dp, customColors.gold, RoundedCornerShape(12.dp)),
            shape = RoundedCornerShape(12.dp),
            colors = CardDefaults.cardColors(
                containerColor = customColors.pageBg // Warm parchment background
            )
        ) {
            Column(
                modifier = Modifier
                    .padding(20.dp)
                    .fillMaxWidth(),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                // Title
                Text(
                    text = "الانتقال إلى صفحة",
                    fontFamily = CairoFontFamily,
                    fontWeight = FontWeight.Bold,
                    fontSize = 18.sp,
                    color = Color(0xFF2C1A00), // Dark brown ink color for parchment
                    modifier = Modifier.padding(bottom = 6.dp)
                )

                Text(
                    text = "أدخل رقم الصفحة (١ - ١٣٧)",
                    fontFamily = CairoFontFamily,
                    fontSize = 13.sp,
                    color = Color(0xFF6B4C2A), // Muted warm ink
                    textAlign = TextAlign.Center,
                    modifier = Modifier.padding(bottom = 16.dp)
                )

                // Outlined Input with elegant styling
                OutlinedTextField(
                    value = pageInput,
                    onValueChange = { newVal ->
                        val filtered = newVal.filter { it.isDigit() }
                        if (filtered.length <= 3) {
                            pageInput = filtered
                            errorMessage = null
                        }
                    },
                    modifier = Modifier
                        .fillMaxWidth(0.8f)
                        .padding(horizontal = 8.dp),
                    textStyle = LocalTextStyle.current.copy(
                        textAlign = TextAlign.Center,
                        fontWeight = FontWeight.Bold,
                        fontSize = 22.sp,
                        color = Color(0xFF2C1A00)
                    ),
                    keyboardOptions = KeyboardOptions(
                        keyboardType = KeyboardType.Number,
                        imeAction = ImeAction.Done
                    ),
                    keyboardActions = KeyboardActions(
                        onDone = {
                            val parsed = pageInput.toIntOrNull()
                            if (parsed != null && parsed in 1..137) {
                                onConfirm(parsed)
                            } else {
                                errorMessage = "الرجاء إدخال رقم صحيح (١ - ١٣٧)"
                            }
                        }
                    ),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = customColors.gold,
                        unfocusedBorderColor = Color(0xFF6B4C2A).copy(alpha = 0.5f),
                        cursorColor = customColors.gold,
                        focusedTextColor = Color(0xFF2C1A00),
                        unfocusedTextColor = Color(0xFF2C1A00)
                    ),
                    singleLine = true
                )

                if (errorMessage != null) {
                    Text(
                        text = errorMessage!!,
                        color = Color(0xFFB22222), // Dark red ink for warning
                        fontSize = 12.sp,
                        fontFamily = CairoFontFamily,
                        modifier = Modifier.padding(top = 8.dp),
                        textAlign = TextAlign.Center
                    )
                }

                Spacer(modifier = Modifier.height(20.dp))

                // Action Buttons
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    // Cancel
                    TextButton(
                        onClick = onDismiss,
                        modifier = Modifier.weight(1f)
                    ) {
                        Text(
                            text = "إلغاء",
                            fontFamily = CairoFontFamily,
                            fontWeight = FontWeight.Bold,
                            color = Color(0xFF6B4C2A)
                        )
                    }

                    // Confirm
                    Button(
                        onClick = {
                            val parsed = pageInput.toIntOrNull()
                            if (parsed != null && parsed in 1..137) {
                                onConfirm(parsed)
                            } else {
                                errorMessage = "رقم غير صحيح! (١ - ١٣٧)"
                            }
                        },
                        modifier = Modifier.weight(1f),
                        colors = ButtonDefaults.buttonColors(
                            containerColor = customColors.gold,
                            contentColor = Color.White
                        ),
                        shape = RoundedCornerShape(8.dp)
                    ) {
                        Text(
                            text = "موافق",
                            fontFamily = CairoFontFamily,
                            fontWeight = FontWeight.Bold
                        )
                    }
                }
            }
        }
    }
}
