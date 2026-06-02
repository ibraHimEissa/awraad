/// Converts Western digits in a number to Arabic-Indic digits (٠١٢…).
String toArabicNumerals(int number) {
  const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  return number.toString().split('').map((ch) {
    final code = ch.codeUnitAt(0);
    if (code >= 48 && code <= 57) return arabicDigits[code - 48];
    return ch;
  }).join();
}

/// Normalises Arabic text for tolerant searching: strips tashkeel/diacritics
/// and tatweel, and unifies alef/hamza/yaa/taa-marbuta letter forms. Applied
/// to both the OCR index and the user's query so search is forgiving of
/// vocalisation and minor OCR slips.
String normalizeArabic(String input) {
  final out = StringBuffer();
  for (final r in input.runes) {
    // Drop diacritics: Arabic marks, tashkeel, superscript alef, tatweel.
    if ((r >= 0x0610 && r <= 0x061A) ||
        (r >= 0x064B && r <= 0x065F) ||
        r == 0x0670 ||
        r == 0x0640 ||
        r == 0x0621) {
      continue; // also drops the standalone hamza (ء)
    }
    var c = r;
    if (c == 0x0622 || c == 0x0623 || c == 0x0625 || c == 0x0671) {
      c = 0x0627; // آ أ إ ٱ → ا
    } else if (c == 0x0649) {
      c = 0x064A; // ى → ي
    } else if (c == 0x0629) {
      c = 0x0647; // ة → ه
    } else if (c == 0x0624) {
      c = 0x0648; // ؤ → و
    } else if (c == 0x0626) {
      c = 0x064A; // ئ → ي
    }
    out.writeCharCode(c);
  }
  // Collapse runs of whitespace.
  return out.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
}
