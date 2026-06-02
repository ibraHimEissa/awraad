import 'package:flutter/material.dart';

/// Brand identity colours derived from the order's logo:
///  - Deep forest green   #207A46
///  - Bright emerald green #009746
///  - Golden yellow core   #FEED00
///
/// For comfortable long-form reading the palette is intentionally *calmed*:
/// the greens are muted and desaturated (no neon emerald), contrast is gentle,
/// and the gold is a soft warm tone rather than a bright yellow.
class AppColors {
  AppColors._();

  // ── Brand anchors (kept for reference / the logo itself) ──────────────
  static const Color emeraldRaw = Color(0xFF009746);
  static const Color forest = Color(0xFF207A46);
  static const Color logoYellow = Color(0xFFFEED00);

  // ── Backgrounds (soft, muted deep green — restful, not black) ─────────
  static const Color background = Color(0xFF15271D); // calm deep green
  static const Color backgroundElevated = Color(0xFF1A2E23);
  static const Color surface = Color(0xFF1F3528); // muted green card
  static const Color surfaceHigh = Color(0xFF294035); // raised surface
  static const Color headerFooter = Color(0xFF18291F); // gentle chrome
  static const Color drawerBg = Color(0xFF14241B);

  // ── Accent green (muted sage-emerald, easy on the eye) ────────────────
  static const Color emerald = Color(0xFF4E9C77); // calmed accent
  static const Color greenLight = Color(0xFF6FB593);
  static const Color greenMuted = Color(0xFF3E5C4B);

  // ── Gold accents (soft warm gold, not bright yellow) ──────────────────
  static const Color gold = Color(0xFFD6BE80); // primary soft gold
  static const Color goldBright = Color(0xFFE4D199); // gentle highlight
  static const Color goldDeep = Color(0xFFB29A5C); // engraved gold

  // ── Text ──────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFECE5D3); // warm cream
  static const Color textSecondary = Color(0xFFC6CFC4); // soft green-white
  static const Color textMuted = Color(0xFF8C9A8C); // muted sage

  // ── The manuscript page (kept warm parchment for the PDF) ─────────────
  static const Color parchment = Color(0xFFFAF6EE);
  static const Color inkBrown = Color(0xFF2C1A00);
  static const Color inkGold = Color(0xFF8A6B1F);

  // ── Misc ──────────────────────────────────────────────────────────────
  static const Color danger = Color(0xFFB05656);

  // Gradients ------------------------------------------------------------
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A2E23), Color(0xFF15271D), Color(0xFF101F17)],
  );

  static const LinearGradient goldSweep = LinearGradient(
    colors: [goldDeep, goldBright, goldDeep],
  );

  static const RadialGradient emeraldGlow = RadialGradient(
    colors: [Color(0x224E9C77), Color(0x004E9C77)],
  );
}
