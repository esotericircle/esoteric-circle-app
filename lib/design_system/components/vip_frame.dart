import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../theme/maestro_palette.dart';
import '../tokens/typography_tokens.dart';

/// La cornice VIP vera e definitiva, la stessa usata per i ritratti dei VIP.
///
/// L'arte sorgente e' `pilot-references/Cornice-Vip-Test-2.png`, la cornice che
/// `vip.py` compone dietro ogni ritratto (finestra centrale trasparente, cartigli
/// alto e basso vuoti, oro e blu di Medora). Qui e' bundlata come
/// `assets/vip_cornice.webp` per riusarla identica sulla foto dell'utente.
///
/// Le misure sono frazioni della cornice 2:3, ricavate dall'alpha reale del PNG:
/// la finestra e i due cartigli combaciano con i ritratti gia' prodotti.
class VipFrame {
  const VipFrame._();

  static const String asset = 'assets/vip_cornice.webp';

  /// Rapporto larghezza su altezza della cornice, come i ritratti VIP (2:3).
  static const double aspect = 2 / 3;

  /// Finestra centrale trasparente dove entra il ritratto o la foto (LTRB
  /// normalizzati sull'alpha della cornice).
  static const Rect window = Rect.fromLTRB(0.2087, 0.2089, 0.7877, 0.7239);

  // Le due bande blu piatte, misurate dall'alpha e dal colore di
  // `assets/vip_cornice.webp`: sono le zone di blu uniforme fra le estremita'
  // dorate ornate. Il testo dei cartigli vive dentro queste bande, con un
  // margine di sicurezza verso l'interno, cosi' non tocca mai l'oro.
  //
  // Banda piatta misurata: nome x 0.278..0.719 y 0.044..0.100; data x
  // 0.251..0.744 y 0.903..0.960. I rettangoli qui sotto sono gia' rientrati.

  /// Cartiglio alto, per il nome per esteso.
  static const Rect cartiglioNome = Rect.fromLTRB(0.296, 0.050, 0.701, 0.095);

  /// Cartiglio basso, per la data di nascita.
  static const Rect cartiglioData = Rect.fromLTRB(0.271, 0.909, 0.724, 0.954);

  /// Banda blu piatta reale del cartiglio alto (senza margine), confine dell'oro.
  static const Rect flatBandNome = Rect.fromLTRB(0.278, 0.044, 0.719, 0.100);

  /// Banda blu piatta reale del cartiglio basso (senza margine), confine dell'oro.
  static const Rect flatBandData = Rect.fromLTRB(0.251, 0.903, 0.744, 0.960);
}

/// Un ritratto dentro la cornice VIP, col nome nel cartiglio alto e la data nel
/// cartiglio basso, scritti a runtime.
///
/// Tre modi, uno solo per volta: [vipAsset] mostra il ritratto VIP che porta
/// gia' la sua cornice incisa (nessun bordo aggiunto); [photo] mette la foto
/// dell'utente nella finestra e le sovrappone la cornice bundlata, la stessa dei
/// VIP; senza ne' l'uno ne' l'altro resta il segnaposto a costellazione.
class VipFramedPortrait extends StatelessWidget {
  const VipFramedPortrait({
    super.key,
    required this.name,
    required this.date,
    required this.palette,
    this.sign,
    this.vipAsset,
    this.photo,
  });

  final String name;
  final String date;
  final MaestroPalette palette;

  /// Simbolo del segno, per il segnaposto a costellazione.
  final String? sign;

  final String? vipAsset;
  final Uint8List? photo;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: VipFrame.aspect,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          Rect px(Rect r) =>
              Rect.fromLTRB(r.left * w, r.top * h, r.right * w, r.bottom * h);

          final layers = <Widget>[];

          if (vipAsset != null) {
            // Il ritratto VIP ha gia' la sua cornice: si mostra cosi' com'e'.
            layers.add(Positioned.fill(
              child: Image.asset(
                vipAsset!,
                fit: BoxFit.fill,
                errorBuilder: (_, __, ___) =>
                    _Constellation(palette: palette, sign: sign),
              ),
            ));
          } else {
            // Utente: contenuto nella finestra, poi la cornice bundlata sopra.
            layers.add(Positioned.fromRect(
              rect: px(VipFrame.window),
              child: ClipRect(
                child: photo != null
                    ? GoldenCosmicPhoto(
                        bytes: photo!,
                        gold: palette.gold,
                        blue: palette.primary,
                      )
                    : _Constellation(palette: palette, sign: sign),
              ),
            ));
            layers.add(Positioned.fill(
              child: Image.asset(
                VipFrame.asset,
                fit: BoxFit.fill,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ));
          }

          // I cartigli, scritti a runtime: nome in alto, data in basso. Il testo
          // si adatta alla larghezza del cartiglio, sempre su una riga.
          layers.add(Positioned.fromRect(
            rect: px(VipFrame.cartiglioNome),
            child: CartiglioText(
                text: name, palette: palette, preserveWordGap: true),
          ));
          if (date.isNotEmpty) {
            layers.add(Positioned.fromRect(
              rect: px(VipFrame.cartiglioData),
              child: CartiglioText(text: date, palette: palette),
            ));
          }

          return Stack(fit: StackFit.expand, children: layers);
        },
      ),
    );
  }
}

/// I parametri di adattamento del testo del cartiglio: dimensione del font,
/// spazio tra le lettere, spazio tra le parole, restringimento orizzontale e il
/// pavimento di spazio tra le parole sotto cui il fitter non e' sceso.
class CartiglioFit {
  const CartiglioFit({
    required this.fontSize,
    required this.letterSpacing,
    required this.wordSpacing,
    required this.scaleX,
    required this.wordSpacingFloor,
  });

  final double fontSize;
  final double letterSpacing;
  final double wordSpacing;
  final double scaleX;

  /// Il valore minimo che [wordSpacing] poteva assumere: garanzia che tra due
  /// parole resti uno stacco leggibile.
  final double wordSpacingFloor;
}

/// Limiti della scala progressiva.
const double _lsBase = 1.0; // spazio tra le lettere di partenza
const double _lsMin = -1.0; // fino a circa -1,0
const double _xsMin = 0.80; // restringimento orizzontale minimo
const double _fontFloor = 0.85; // il font puo' calare al massimo del 15 per cento
const double _heightFactor = 0.86; // quanto il font riempie l'altezza del cartiglio

// Pavimento dello spazio tra le parole in modo normale (le date), come frazione
// del font di partenza. Coi nomi il divario e' protetto e non si sottrae mai.
const double _wsFloorNormal = 0.16;

double _measureWidth(String t, TextStyle base, double fs, double ls, double ws) {
  final tp = TextPainter(
    text: TextSpan(
        text: t,
        style: base.copyWith(fontSize: fs, letterSpacing: ls, wordSpacing: ws)),
    textDirection: TextDirection.ltr,
    maxLines: 1,
  )..layout();
  return tp.width;
}

double _measureHeight(String t, TextStyle base, double fs) {
  final tp = TextPainter(
    text: TextSpan(text: t, style: base.copyWith(fontSize: fs)),
    textDirection: TextDirection.ltr,
    maxLines: 1,
  )..layout();
  return tp.height;
}

// Cerca il valore meno compresso (piu' vicino a hi) che fa stare il testo entro
// target. Se nemmeno la compressione piena (lo) basta, ritorna lo e si passa
// allo stadio successivo. La larghezza cresce in modo monotono col parametro.
double _leastCompression(
    double Function(double) widthOf, double target, double lo, double hi) {
  if (widthOf(lo) > target) return lo;
  if (widthOf(hi) <= target) return hi;
  for (var i = 0; i < 30; i++) {
    final mid = (lo + hi) / 2;
    if (widthOf(mid) <= target) {
      lo = mid;
    } else {
      hi = mid;
    }
  }
  return lo;
}

/// Calcola come far entrare [text] (gia' maiuscolo) nella larghezza [maxWidth],
/// alto quanto [maxHeight], su una sola riga, applicando solo lo stretto
/// necessario.
///
/// Con [preserveWordGap] falso (le date) l'ordine e': spazio tra le parole,
/// spazio tra le lettere, larghezza dei caratteri, poi come estremo il font.
///
/// Con [preserveWordGap] vero (i nomi) l'ordine e' invertito, cosi' il divario
/// tra parole resta sempre percepibile: prima e di piu' lo spazio tra le lettere,
/// poi il restringimento orizzontale, poi lo spazio tra le parole ma solo fino a
/// un pavimento leggibile, e solo come estremo il font. Il pavimento dello spazio
/// tra le parole non viene mai superato.
CartiglioFit resolveCartiglioFit({
  required String text,
  required TextStyle base,
  required double maxWidth,
  required double maxHeight,
  bool preserveWordGap = false,
}) {
  // Font di partenza: riempie l'altezza del cartiglio.
  const probe = 100.0;
  final probeHeight = _measureHeight(text, base, probe);
  final baseFont = probeHeight <= 0
      ? maxHeight
      : probe * (maxHeight * _heightFactor) / probeHeight;

  var fs = baseFont;
  var ls = _lsBase;
  var ws = 0.0;
  var xs = 1.0;
  double wsFloor;

  final hasSpace = text.contains(' ');
  double mw(double f, double l, double w) => _measureWidth(text, base, f, l, w);

  if (preserveWordGap) {
    // Divario tra parole protetto. Lo spazio tra le parole non viene mai
    // sottratto (pavimento a zero): anzi, quando le lettere si stringono
    // (letter-spacing negativo) lo spazio compensa quel negativo, cosi' il vuoto
    // fra due parole resta largo come il suo spazio naturale, mai attaccate.
    double wsFor(double lsv) => lsv < 0 ? -lsv : 0.0;
    wsFloor = 0.0;

    // 1) spazio tra le lettere, per primo e di piu' (lo spazio parole compensa).
    double widthAtLs(double lsv) => mw(fs, lsv, wsFor(lsv));
    if (widthAtLs(_lsBase) > maxWidth) {
      ls = _leastCompression(widthAtLs, maxWidth, _lsMin, _lsBase);
    }
    ws = wsFor(ls);

    // 2) restringimento orizzontale (comprime lettere e spazi insieme, il
    // divario resta proporzionato).
    final w = mw(fs, ls, ws);
    if (w > maxWidth) {
      xs = (maxWidth / w).clamp(_xsMin, 1.0);
    }
    // 3) come estremo, la dimensione del font, al massimo meno 15 per cento.
    if (mw(fs, ls, ws) * xs > maxWidth) {
      fs = _leastCompression(
          (v) => mw(v, ls, ws) * xs, maxWidth, baseFont * _fontFloor, fs);
    }
  } else {
    wsFloor = -_wsFloorNormal * baseFont;
    double widthNow() => mw(fs, ls, ws);

    // 1) spazio tra le parole.
    if (widthNow() > maxWidth && hasSpace) {
      ws = _leastCompression((v) => mw(fs, ls, v), maxWidth, wsFloor, 0.0);
    }
    // 2) spazio tra le lettere.
    if (widthNow() > maxWidth) {
      ls = _leastCompression((v) => mw(fs, v, ws), maxWidth, _lsMin, _lsBase);
    }
    // 3) larghezza dei caratteri.
    final w = widthNow();
    if (w > maxWidth) {
      xs = (maxWidth / w).clamp(_xsMin, 1.0);
    }
    // 4) come estremo, la dimensione del font.
    if (widthNow() * xs > maxWidth) {
      fs = _leastCompression(
          (v) => mw(v, ls, ws) * xs, maxWidth, baseFont * _fontFloor, fs);
    }
  }

  return CartiglioFit(
    fontSize: fs,
    letterSpacing: ls,
    wordSpacing: ws,
    scaleX: xs,
    wordSpacingFloor: wsFloor,
  );
}

/// Testo di un cartiglio VIP: maiuscolo, oro, centrato, sempre su una riga.
///
/// Non tronca mai, non va a capo, non sborda: adatta il testo alla larghezza del
/// cartiglio con la scala progressiva di [resolveCartiglioFit], applicando solo
/// lo stretto necessario. La cornice e il cartiglio restano quelli veri.
class CartiglioText extends StatelessWidget {
  const CartiglioText({
    super.key,
    required this.text,
    required this.palette,
    this.preserveWordGap = false,
  });

  final String text;
  final MaestroPalette palette;

  /// Se vero (il cartiglio del nome) protegge il divario tra parole: comprime
  /// prima lettere e larghezza, e lo spazio tra parole solo fino a un pavimento
  /// leggibile, cosi' due parole non si attaccano mai.
  final bool preserveWordGap;

  @override
  Widget build(BuildContext context) {
    final upper = text.toUpperCase();
    // **QUARANTA NON E' UN RUOLO, E' IL PUNTO DI PARTENZA DI UN CALCOLO.**
    // Ordine CE voce 11: qui sotto `resolveCartiglioFit` restringe il
    // nome finche' non riempie il cartiglio, e la misura vera la decide
    // la larghezza disponibile, non questa riga. Un ruolo non puo'
    // saperlo in anticipo, quindi qui la misura resta scritta.
    final base = TypographyTokens.display(size: 40).copyWith(
      color: palette.goldSoft,
      letterSpacing: _lsBase,
      shadows: [Shadow(color: palette.deepest, blurRadius: 2)],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final fit = resolveCartiglioFit(
          text: upper,
          base: base,
          maxWidth: constraints.maxWidth,
          maxHeight: constraints.maxHeight,
          preserveWordGap: preserveWordGap,
        );

        Widget label = Text(
          upper,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.visible,
          textAlign: TextAlign.center,
          style: base.copyWith(
            fontSize: fit.fontSize,
            letterSpacing: fit.letterSpacing,
            wordSpacing: fit.wordSpacing,
          ),
        );
        if (fit.scaleX < 0.999) {
          label = Transform.scale(
            scaleX: fit.scaleX,
            scaleY: 1.0,
            alignment: Alignment.center,
            child: label,
          );
        }
        // OverflowBox: il testo puo' essere piu' largo del vincolo interno, tanto
        // lo comprimiamo noi con lo scaleX; cosi' non va mai a capo ne tronca.
        return Center(
          child: OverflowBox(
            minWidth: 0,
            maxWidth: double.infinity,
            alignment: Alignment.center,
            child: label,
          ),
        );
      },
    );
  }
}

/// Segnaposto a costellazione dentro la finestra: cielo profondo col simbolo del
/// segno e una scintilla, mai un vuoto piatto.
class _Constellation extends StatelessWidget {
  const _Constellation({required this.palette, this.sign});

  final MaestroPalette palette;
  final String? sign;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            palette.primary.withValues(alpha: 0.7),
            palette.deepest,
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (sign != null)
            Text(sign!,
                style: TextStyle(
                    fontSize: 54,
                    color: palette.goldSoft.withValues(alpha: 0.45))),
          Icon(Icons.auto_awesome,
              color: palette.goldSoft.withValues(alpha: 0.9), size: 30),
        ],
      ),
    );
  }
}

/// La foto dell'utente armonizzata coi ritratti VIP illustrati: un filtro caldo
/// e leggermente desaturato piu' un velo dorato e cosmico. La foto resta in
/// memoria, non lascia il dispositivo.
class GoldenCosmicPhoto extends StatelessWidget {
  const GoldenCosmicPhoto({
    super.key,
    required this.bytes,
    required this.gold,
    required this.blue,
  });

  final Uint8List bytes;
  final Color gold;
  final Color blue;

  // Matrice calda e leggera: alza il rosso, tiene il verde, abbassa un poco il
  // blu, con una lieve desaturazione, cosi' il volto vira all'oro senza
  // diventare seppia pieno.
  static const List<double> _warmMatrix = <double>[
    0.92, 0.10, 0.04, 0, 6, //
    0.05, 0.90, 0.05, 0, 3, //
    0.03, 0.08, 0.80, 0, 0, //
    0, 0, 0, 1, 0, //
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      foregroundDecoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gold.withValues(alpha: 0.30),
            Colors.transparent,
            blue.withValues(alpha: 0.34),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        backgroundBlendMode: BlendMode.softLight,
      ),
      child: ColorFiltered(
        colorFilter: const ColorFilter.matrix(_warmMatrix),
        child: Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          gaplessPlayback: true,
        ),
      ),
    );
  }
}
