/// Layer 1: primitivi di spaziatura e raggi, su scala 4pt.
///
/// Una sola scala per tutta l'app, cosi' i ritmi verticali e orizzontali
/// restano coerenti tra le schermate.
class SpacingTokens {
  SpacingTokens._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;

  // Raggi di arrotondamento.
  static const double radiusSm = 10;
  static const double radiusMd = 18;
  static const double radiusLg = 26;
  static const double radiusXl = 36;
  static const double radiusPill = 999;
}
