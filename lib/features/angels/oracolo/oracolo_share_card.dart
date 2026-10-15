import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/brand/brand.dart';
import '../../../core/condivisione/porta_della_condivisione.dart';
import '../../../core/oracolo_angeli/i_ruoli_e_l_estrazione.dart';
import '../../../core/oracolo_angeli/le_domande_dell_oracolo.dart';
import '../../../design_system/components/brand_mark.dart';
import '../../../design_system/components/card_a_misura_fissa.dart';
import '../../../design_system/theme/maestro_palette.dart';
import '../../../design_system/tokens/color_tokens.dart';
import '../../../design_system/tokens/spacing_tokens.dart';
import '../../../design_system/tokens/typography_tokens.dart';
import '../../synastry/sinastria_share_card.dart' show captureBoundaryPng;
import 'la_geometria_dell_altare.dart';
import 'oracolo_degli_angeli_screen.dart' show LaCartaDellAngelo;

/// **LA CARD DELL'ORACOLO DEGLI ANGELI, nel formato unico.** Ordine FU voce
/// FU.09, 15 ottobre 2026: *"La card condivisibile nel formato unico (Linee
/// Guida sezione 3): le tre carte e il titolo. Mai la domanda stampata, mai
/// dati di nascita."*
///
/// **Cosa c'e'**: il nome della funzione, le tre carte estratte con la loro
/// posizione (Cosa fare, Cosa sentire, Cosa capire) e il nome dell'angelo,
/// il titolo che e' la risposta, il marchio e il dominio. La carta coperta o
/// chiusa dal piano resta un dorso, senza nome.
///
/// **Cosa NON c'e', e non e' una dimenticanza**:
/// - la domanda: questa immagine esce dal telefono e la guardano altri, e
///   chi condivide una lettura non sta condividendo cosa ha chiesto (la
///   stessa regola della card della Stesa, ordine CQ voce 6.10). Se il
///   titolo ripetesse la domanda parola per parola, al suo posto va il
///   titolo del tema ([titoloPerLaCard]);
/// - i tre angeli della persona che portano le carte: il Custode viene dal
///   grado del Sole, il Cuore dal giorno dell'anno e l'Intelletto dall'ora di
///   nascita, quindi i loro nomi direbbero la nascita a chi guarda;
/// - nessuna data, nessuna ora, nessun luogo.
class OracoloShareCard extends StatelessWidget {
  const OracoloShareCard({
    super.key,
    required this.carte,
    required this.titolo,
    required this.palette,
    this.scoperte,
    this.width = 380,
  });

  final List<CartaDellOracolo> carte;

  /// Il titolo che e' la risposta, gia' passato da [titoloPerLaCard].
  final String titolo;
  final MaestroPalette palette;

  /// Quali carte si mostrano scoperte: nullo, tutte quelle non coperte. Al
  /// Viandante l'assaggio scopre solo il Custode (ordine FU voce FU.10).
  final Set<RuoloDellAngelo>? scoperte;
  final double width;

  bool _scoperta(CartaDellOracolo c) =>
      !c.coperta && (scoperte == null || scoperte!.contains(c.ruolo));

  /// **IL TITOLO SULLA CARD NON RIPETE LA DOMANDA.** Se il titolo contiene la
  /// domanda (o la domanda contiene il titolo), letti senza maiuscole, segni
  /// e spazi doppi, sulla card va il titolo del tema riconosciuto, che non la
  /// dice.
  static String titoloPerLaCard(String titolo, String domanda) {
    String pulito(String s) => s
        .toLowerCase()
        .replaceAll(RegExp(r'[^\p{L}\p{N} ]', unicode: true), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final t = pulito(titolo);
    final d = pulito(domanda);
    final ripete = d.isNotEmpty && (t.contains(d) || (t.isNotEmpty && d == t));
    if (!ripete) return titolo;
    return TemaDellOracolo.di(domanda)?.titoloDiRipiego ??
        TemaDellOracolo.titoloSenzaTema;
  }

  @override
  Widget build(BuildContext context) {
    return CardAMisuraFissa(
      child: Container(
        width: width,
        padding: const EdgeInsets.fromLTRB(SpacingTokens.md, SpacingTokens.lg,
            SpacingTokens.md, SpacingTokens.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              palette.deepest,
              Color.lerp(palette.deepest, palette.primary, 0.55)!,
              palette.deepest,
            ],
          ),
          border:
              Border.all(color: palette.gold.withValues(alpha: 0.8), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('ORACOLO DEGLI ANGELI',
                textAlign: TextAlign.center,
                style: TypographyTokens.etichetta()
                    .copyWith(color: palette.goldSoft, letterSpacing: 3.0)),
            const SizedBox(height: SpacingTokens.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < carte.length; i++) ...[
                  Expanded(
                    child: Column(
                      children: [
                        AspectRatio(
                          aspectRatio: 1 / 1.5,
                          child: _scoperta(carte[i])
                              ? LaCartaDellAngelo(
                                  key: Key(
                                      'card_oracolo_carta_${carte[i].ruolo.name}'),
                                  angelo: carte[i].angelo,
                                  palette: palette)
                              : Image.asset(GeometriaDellAltare.dorso,
                                  key: Key(
                                      'card_oracolo_dorso_${carte[i].ruolo.name}'),
                                  fit: BoxFit.fill),
                        ),
                        const SizedBox(height: SpacingTokens.xs),
                        Text(carte[i].ruolo.posizione.toUpperCase(),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            softWrap: false,
                            style: TypographyTokens.etichetta().copyWith(
                                color: palette.goldSoft, letterSpacing: 0.8)),
                        Text(
                            _scoperta(carte[i])
                                ? carte[i].angelo.name
                                : 'Carta coperta',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            style: TypographyTokens.didascalia()
                                .copyWith(color: ColorTokens.textPrimary)),
                      ],
                    ),
                  ),
                  if (i < carte.length - 1) const SizedBox(width: 6),
                ],
              ],
            ),
            const SizedBox(height: SpacingTokens.md),
            Container(
              padding: const EdgeInsets.all(SpacingTokens.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
                color: palette.primary.withValues(alpha: 0.4),
                border: Border.all(color: palette.gold.withValues(alpha: 0.3)),
              ),
              child: Text(titolo,
                  key: const Key('card_oracolo_titolo'),
                  textAlign: TextAlign.center,
                  style: TypographyTokens.titoloScheda()
                      .copyWith(color: palette.goldSoft, height: 1.25)),
            ),
            const SizedBox(height: SpacingTokens.md),
            const Center(child: BrandLogo(size: 40)),
            const SizedBox(height: SpacingTokens.xxs),
            Text(BrandMark.wordmark,
                textAlign: TextAlign.center,
                style: TypographyTokens.etichetta()
                    .copyWith(color: palette.goldSoft, letterSpacing: 2.4)),
            Text(Brand.domain,
                textAlign: TextAlign.center,
                style: TypographyTokens.etichetta().copyWith(
                    color: ColorTokens.textSecondary, letterSpacing: 0.6)),
          ],
        ),
      ),
    );
  }
}

/// Genera la card come immagine dal boundary e apre il foglio di
/// condivisione. Il PNG va in un file temporaneo del dispositivo, non su un
/// server. L'esito vero risale al chiamante, che paga il premio dichiarato.
Future<bool> shareOracoloCard({
  required GlobalKey boundaryKey,
  required String text,
}) async {
  final png = await captureBoundaryPng(boundaryKey);
  if (png == null) return false;
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/oracolo_degli_angeli.png');
  await file.writeAsBytes(png, flush: true);
  return PortaDellaCondivisione.daFile(file.path, testo: text);
}
