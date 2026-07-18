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

  /// Cartiglio alto, per il nome per esteso.
  static const Rect cartiglioNome = Rect.fromLTRB(0.22, 0.048, 0.78, 0.100);

  /// Cartiglio basso, per la data di nascita.
  static const Rect cartiglioData = Rect.fromLTRB(0.26, 0.905, 0.74, 0.958);
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

          // I cartigli, scritti a runtime: nome in alto, data in basso.
          layers.add(_Cartiglio(
              rect: px(VipFrame.cartiglioNome),
              text: name,
              palette: palette));
          if (date.isNotEmpty) {
            layers.add(_Cartiglio(
                rect: px(VipFrame.cartiglioData),
                text: date,
                palette: palette));
          }

          return Stack(fit: StackFit.expand, children: layers);
        },
      ),
    );
  }
}

class _Cartiglio extends StatelessWidget {
  const _Cartiglio(
      {required this.rect, required this.text, required this.palette});

  final Rect rect;
  final String text;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Positioned.fromRect(
      rect: rect,
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text.toUpperCase(),
            maxLines: 1,
            style: TypographyTokens.display(size: 40).copyWith(
              color: palette.goldSoft,
              letterSpacing: 1.0,
              shadows: [
                Shadow(color: palette.deepest, blurRadius: 2),
              ],
            ),
          ),
        ),
      ),
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
