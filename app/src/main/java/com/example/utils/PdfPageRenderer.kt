package com.example.utils

import android.content.Context
import android.graphics.Bitmap
import android.graphics.pdf.PdfRenderer
import android.graphics.pdf.PdfDocument
import android.graphics.Paint
import android.graphics.Path
import android.graphics.PointF
import android.graphics.Color
import android.graphics.Typeface
import android.text.TextPaint
import android.text.StaticLayout
import android.text.Layout
import android.os.ParcelFileDescriptor
import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.withContext
import java.io.File
import java.io.FileOutputStream

object PdfPageRenderer {
    private const val TAG = "PdfPageRenderer"
    private const val PDF_NAME = "book.pdf"
    
    private var pdfRenderer: PdfRenderer? = null
    private var fileDescriptor: ParcelFileDescriptor? = null
    private var localFile: File? = null
    private val renderLock = Mutex()

    // Initialize or retrieve the local file from assets
    private suspend fun getLocalPdfFile(context: Context): File? = withContext(Dispatchers.IO) {
        val file = File(context.cacheDir, PDF_NAME)
        
        // 1. Try to inspect if asset of book.pdf is valid and copy it
        var assetInput: java.io.InputStream? = null
        try {
            // Check direct root asset
            assetInput = context.assets.open(PDF_NAME)
            Log.d(TAG, "Successfully opened book.pdf from assets root.")
        } catch (e1: Exception) {
            try {
                // Check sub-folder assets/book.pdf
                assetInput = context.assets.open("assets/$PDF_NAME")
                Log.d(TAG, "Successfully opened assets/book.pdf from assets subdirectory.")
            } catch (e2: Exception) {
                Log.w(TAG, "No book.pdf asset found in root or assets subdirectory.")
            }
        }

        if (assetInput != null) {
            try {
                val assetSize = assetInput.available().toLong()
                if (assetSize > 10) {
                    // Copy asset to cache if cache is missing or size differs
                    if (!file.exists() || file.length() != assetSize) {
                        Log.d(TAG, "Copying book.pdf asset of size $assetSize to cache.")
                        FileOutputStream(file).use { output ->
                            assetInput.copyTo(output)
                        }
                    } else {
                        Log.d(TAG, "Cache file exists and matches asset size: $assetSize")
                    }
                    localFile = file
                    return@withContext file
                } else {
                    Log.w(TAG, "book.pdf asset is empty or too small ($assetSize bytes).")
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error copying book.pdf asset: ${e.message}")
            } finally {
                try {
                    assetInput.close()
                } catch (e: Exception) {}
            }
        }

        // 2. Fallback - if no valid asset found, check if cached file exists and is valid
        if (file.exists() && file.length() > 500) {
            Log.d(TAG, "Using existing valid cached/generated PDF of size ${file.length()}")
            localFile = file
            return@withContext file
        }

        // 3. Last resort - Generate fallback dynamic high-quality PDF in cache
        try {
            Log.d(TAG, "Generating high-quality fallback book.pdf since no valid asset or cache exists.")
            generatePdf(context, file)
            localFile = file
            file
        } catch (e: Exception) {
            Log.e(TAG, "Error generating fallback PDF: ${e.message}")
            null
        }
    }

    private fun generatePdf(context: Context, file: File) {
        val pdfDocument = PdfDocument()
        
        try {
            // Book has exactly 137 pages
            for (pageNumber in 1..137) {
                // Page width = 595, height = 842 (A4 standard)
                val pageInfo = PdfDocument.PageInfo.Builder(595, 842, pageNumber).create()
                val page = pdfDocument.startPage(pageInfo)
                val canvas = page.canvas
                
                // Draw visuals on canvas
                drawPageOnCanvas(canvas, pageNumber)
                
                pdfDocument.finishPage(page)
            }
            
            FileOutputStream(file).use { out ->
                pdfDocument.writeTo(out)
            }
            Log.d(TAG, "Successfully generated standard book.pdf with 137 pages")
        } catch (e: Exception) {
            Log.e(TAG, "Error generating program pdf: ${e.message}")
        } finally {
            pdfDocument.close()
        }
    }

    private fun drawPageOnCanvas(canvas: android.graphics.Canvas, pageNumber: Int) {
        val width = 595f
        val height = 842f
        
        val paint = Paint(Paint.ANTI_ALIAS_FLAG)
        
        if (pageNumber == 1) {
            // COVER PAGE
            // 1. Yellow background: #FFF5CD
            canvas.drawColor(Color.parseColor("#FFF5CD"))
            
            // 2. Draw outer border
            paint.style = Paint.Style.STROKE
            paint.color = Color.parseColor("#9A6B1F")
            paint.strokeWidth = 3f
            canvas.drawRect(20f, 20f, width - 20f, height - 20f, paint)
            
            paint.strokeWidth = 1f
            canvas.drawRect(26f, 26f, width - 26f, height - 26f, paint)
            
            // 3. Draw Green & Gold Sufi Logo (center cx = width / 2, cy = 260)
            val cx = width / 2f
            val cy = 260f
            drawSufiLogoOnCanvas(canvas, cx, cy, 100f, paint)
            
            // 4. Large Elegant Calligraphy: كِتَابُ الْأَوْرَادِ
            paint.style = Paint.Style.FILL
            paint.color = Color.parseColor("#805B15")
            paint.typeface = Typeface.create(Typeface.SERIF, Typeface.BOLD)
            paint.textSize = 36f
            paint.textAlign = Paint.Align.CENTER
            canvas.drawText("كِتَابُ الْأَوْرَادِ", cx, 440f, paint)
            
            paint.color = Color.parseColor("#1B5E20") // Green for sub
            paint.textSize = 20f
            canvas.drawText("الْأَوْرَادُ الْبُرْهَانِيَّةُ الْمُبَارَكَةُ", cx, 490f, paint)
            
            // Subtitle: الطَّرِيقَةُ الْبُرْهَانِيَّةُ الدَّسُوقِيَّةُ الشَّاذِلِيَّةُ
            paint.color = Color.parseColor("#2C1A00")
            paint.typeface = Typeface.create(Typeface.SANS_SERIF, Typeface.NORMAL)
            paint.textSize = 14f
            canvas.drawText("طَرِيقَةُ السَّادَةِ الْبُرْهَانِيَّةِ الدَّسُوقِيَّةِ الشَّاذِلِيَّةِ", cx, 550f, paint)
            
            paint.textSize = 12f
            paint.color = Color.parseColor("#909090")
            canvas.drawText("صَاحِبُ الشَّرِيعَةِ وَالْحَقِيقَةِ الشَّيْخِ مُحَمَّد عُثْمَان عَبْدُهُ الْبُرْهَانِيِّ", cx, 600f, paint)
            
            // Small rosette at the bottom
            drawMiniSufiLogo(canvas, cx, 720f, 25f, paint)
            
        } else {
            // BOOK PAGES (2..137)
            // 1. Parchment Background: #FAF6EE
            canvas.drawColor(Color.parseColor("#FAF6EE"))
            
            // 2. Twin Border
            paint.style = Paint.Style.STROKE
            paint.color = Color.parseColor("#9A6B1F")
            paint.strokeWidth = 1.5f
            canvas.drawRect(20f, 20f, width - 20f, height - 20f, paint)
            paint.strokeWidth = 0.5f
            canvas.drawRect(24f, 24f, width - 24f, height - 24f, paint)
            
            // 3. Mini Sufi Logo at top
            val cx = width / 2f
            drawMiniSufiLogo(canvas, cx, 65f, 20f, paint)
            
            // 4. Section Header
            val activeSection = com.example.data.BookData.getSectionForPage(pageNumber)
            paint.style = Paint.Style.FILL
            paint.color = Color.parseColor("#9A6B1F")
            paint.typeface = Typeface.create(Typeface.SANS_SERIF, Typeface.BOLD)
            paint.textSize = 16f
            paint.textAlign = Paint.Align.CENTER
            canvas.drawText(activeSection.title, cx, 115f, paint)
            
            // 5. Rich Calligraphy Text Content
            val baseText = com.example.data.BookData.DIGITAL_PRAYERS[activeSection.bookPage] ?: "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ"
            
            // Split paragraph helper to distribute text across the pages of a section nicely
            val paragraphs = baseText.split("\n\n")
            val offsetPages = pageNumber - activeSection.bookPage
            val paraIndex = offsetPages % paragraphs.size
            val textToDraw = paragraphs[paraIndex]
            
            // Draw using StaticLayout for perfect centering and word-wrapping!
            val textPaint = TextPaint(Paint.ANTI_ALIAS_FLAG).apply {
                color = Color.parseColor("#2C1A00") // Rich brown ink
                textSize = 18f
                typeface = Typeface.create(Typeface.SERIF, Typeface.NORMAL)
            }
            
            val textWidth = (width - 80f).toInt()
            val alignment = Layout.Alignment.ALIGN_CENTER
            
            // Build StaticLayout
            val staticLayout = StaticLayout(
                textToDraw, 
                textPaint, 
                textWidth, 
                alignment, 
                1.3f, 
                0f, 
                false
            )
            
            // Center the layout vertically on coordinates (150f to 700f)
            val textHeight = staticLayout.height
            val startY = 160f + (530f - textHeight) / 2f
            val finalStartY = if (startY < 160f) 160f else startY
            
            canvas.save()
            canvas.translate(40f, finalStartY)
            staticLayout.draw(canvas)
            canvas.restore()
            
            // 6. Beautiful Page Number indicator inside custom rosette frame at bottom
            val footerY = 750f
            paint.style = Paint.Style.STROKE
            paint.color = Color.parseColor("#9A6B1F")
            paint.strokeWidth = 1f
            canvas.drawCircle(cx, footerY, 22f, paint)
            canvas.drawCircle(cx, footerY, 19f, paint)
            
            // Inside text page number
            paint.style = Paint.Style.FILL
            paint.textSize = 12f
            paint.typeface = Typeface.create(Typeface.SERIF, Typeface.BOLD)
            
            val arabicNumStr = toConvertArabicNumerals(pageNumber)
            canvas.drawText("۞  $arabicNumStr  ۞", cx, footerY + 4f, paint)
        }
    }

    private fun toConvertArabicNumerals(number: Int): String {
        val arabicChars = charArrayOf('٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩')
        val builder = java.lang.StringBuilder()
        val numStr = number.toString()
        for (i in 0 until numStr.length) {
            val d = numStr[i] - '0'
            if (d in 0..9) {
                builder.append(arabicChars[d])
            } else {
                builder.append(numStr[i])
            }
        }
        return builder.toString()
    }

    private fun drawSufiLogoOnCanvas(
        canvas: android.graphics.Canvas,
        cx: Float,
        cy: Float,
        radius: Float,
        paint: Paint
    ) {
        val greenColor = Color.parseColor("#1B5E20")
        val goldColor = Color.parseColor("#9A6B1F")
        
        // 1. Draw outer Heptagon green boundary
        paint.reset()
        paint.isAntiAlias = true
        paint.color = greenColor
        paint.style = Paint.Style.STROKE
        paint.strokeWidth = 4f
        
        val heptagonPath = Path()
        for (i in 0 until 7) {
            val angle = (i * 360f / 7f - 90f) * Math.PI / 180f
            val px = cx + (radius * 0.95f) * Math.cos(angle).toFloat()
            val py = cy + (radius * 0.95f) * Math.sin(angle).toFloat()
            if (i == 0) heptagonPath.moveTo(px, py) else heptagonPath.lineTo(px, py)
        }
        heptagonPath.close()
        canvas.drawPath(heptagonPath, paint)
        
        // Secondary outer heptagon
        paint.color = Color.argb(80, 27, 94, 32)
        paint.strokeWidth = 1.5f
        canvas.drawPath(heptagonPath, paint)
        
        // 2. Draw inner gold 7-pointed Star Heptagram
        paint.color = goldColor
        paint.strokeWidth = 3f
        val starPath = Path()
        val step = 2
        val vertices = Array(7) { PointF(0f, 0f) }
        for (i in 0 until 7) {
            val angle = (i * 360f / 7f - 90f) * Math.PI / 180f
            vertices[i] = PointF(
                cx + (radius * 0.7f) * Math.cos(angle).toFloat(),
                cy + (radius * 0.7f) * Math.sin(angle).toFloat()
            )
        }
        
        var currIndex = 0
        starPath.moveTo(vertices[currIndex].x, vertices[currIndex].y)
        for (i in 0 until 7) {
            currIndex = (currIndex + step) % 7
            starPath.lineTo(vertices[currIndex].x, vertices[currIndex].y)
        }
        starPath.close()
        canvas.drawPath(starPath, paint)
        
        // 3. Central Heptagon circular golden core
        val centerRadius = radius * 0.35f
        paint.style = Paint.Style.FILL
        paint.color = Color.argb(40, 154, 107, 31)
        canvas.drawCircle(cx, cy, centerRadius, paint)
        
        paint.style = Paint.Style.STROKE
        paint.color = goldColor
        paint.strokeWidth = 2f
        canvas.drawCircle(cx, cy, centerRadius, paint)
        
        // Custom simple Allah calligraphy lines in center
        paint.color = goldColor
        paint.strokeWidth = 2.5f
        val sPath = Path()
        sPath.moveTo(cx - centerRadius * 0.4f, cy + centerRadius * 0.3f)
        sPath.quadTo(
            cx - centerRadius * 0.3f, cy - centerRadius * 0.4f,
            cx - centerRadius * 0.1f, cy - centerRadius * 0.4f
        )
        sPath.quadTo(
            cx, cy + centerRadius * 0.3f,
            cx + centerRadius * 0.2f, cy - centerRadius * 0.4f
        )
        sPath.quadTo(
            cx + centerRadius * 0.4f, cy - centerRadius * 0.4f,
            cx + centerRadius * 0.4f, cy + centerRadius * 0.1f
        )
        sPath.cubicTo(
            cx + centerRadius * 0.2f, cy + centerRadius * 0.5f,
            cx - centerRadius * 0.2f, cy + centerRadius * 0.5f,
            cx - centerRadius * 0.3f, cy + centerRadius * 0.2f
        )
        canvas.drawPath(sPath, paint)
    }

    private fun drawMiniSufiLogo(
        canvas: android.graphics.Canvas,
        cx: Float,
        cy: Float,
        radius: Float,
        paint: Paint
    ) {
        val greenColor = Color.parseColor("#1B5E20")
        val goldColor = Color.parseColor("#9A6B1F")
        
        // Heptagon
        paint.reset()
        paint.isAntiAlias = true
        paint.color = greenColor
        paint.style = Paint.Style.STROKE
        paint.strokeWidth = 1.5f
        
        val heptagonPath = Path()
        for (i in 0 until 7) {
            val angle = (i * 360f / 7f - 90f) * Math.PI / 180f
            val px = cx + (radius * 0.95f) * Math.cos(angle).toFloat()
            val py = cy + (radius * 0.95f) * Math.sin(angle).toFloat()
            if (i == 0) heptagonPath.moveTo(px, py) else heptagonPath.lineTo(px, py)
        }
        heptagonPath.close()
        canvas.drawPath(heptagonPath, paint)
        
        // Inner star heptagram
        paint.color = goldColor
        paint.strokeWidth = 1f
        val starPath = Path()
        val step = 2
        val vertices = Array(7) { PointF(0f, 0f) }
        for (i in 0 until 7) {
            val angle = (i * 360f / 7f - 90f) * Math.PI / 180f
            vertices[i] = PointF(
                cx + (radius * 0.7f) * Math.cos(angle).toFloat(),
                cy + (radius * 0.7f) * Math.sin(angle).toFloat()
            )
        }
        var currIndex = 0
        starPath.moveTo(vertices[currIndex].x, vertices[currIndex].y)
        for (i in 0 until 7) {
            currIndex = (currIndex + step) % 7
            starPath.lineTo(vertices[currIndex].x, vertices[currIndex].y)
        }
        starPath.close()
        canvas.drawPath(starPath, paint)
    }

    private suspend fun getRenderer(context: Context): PdfRenderer? {
        if (pdfRenderer != null) return pdfRenderer

        val file = getLocalPdfFile(context) ?: return null
        try {
            val fd = ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY)
            fileDescriptor = fd
            val renderer = PdfRenderer(fd)
            pdfRenderer = renderer
            return renderer
        } catch (e: Exception) {
            Log.e(TAG, "Failed to create PdfRenderer: ${e.message}")
            closeAllInternal()
            return null
        }
    }

    suspend fun renderPage(context: Context, pageIndex: Int): Bitmap? = renderLock.withLock {
        withContext(Dispatchers.IO) {
            // PageIndex is 1-indexed in UI (1 to 137). PdfRenderer is 0-indexed (0 to 136).
            val zeroIndex = pageIndex - 1
            if (zeroIndex < 0) return@withContext null

            val renderer = getRenderer(context) ?: return@withContext null
            if (zeroIndex >= renderer.pageCount) return@withContext null

            try {
                renderer.openPage(zeroIndex).use { page ->
                    // Create highly detailed bitmap matching screen densities (e.g. 1200 wide)
                    // Maintain aspect ratio: standard book is roughly 1:1.414
                    val width = 1200
                    val height = (width * 1.414).toInt()
                    val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
                    
                    // Clear to white parchment bg before rendering
                    bitmap.eraseColor(android.graphics.Color.WHITE)
                    
                    page.render(bitmap, null, null, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY)
                    bitmap
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error rendering page $zeroIndex: ${e.message}")
                null
            }
        }
    }

    // Helper to check if a valid PDF is actually present in assets
    suspend fun isPdfPresent(context: Context): Boolean {
        return getLocalPdfFile(context) != null
    }

    private fun closeAllInternal() {
        try {
            pdfRenderer?.close()
        } catch (e: Exception) {
            // silent close
        }
        pdfRenderer = null

        try {
            fileDescriptor?.close()
        } catch (e: Exception) {
            // silent close
        }
        fileDescriptor = null
        localFile = null
    }

    fun closeAll() {
        synchronized(this) {
            closeAllInternal()
        }
    }
}
