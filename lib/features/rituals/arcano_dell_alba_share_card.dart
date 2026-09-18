import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/brand/brand.dart';
import '../../core/condivisione/porta_della_condivisione.dart';
import '../../core/rituals/arcano_dell_alba/responso_dell_alba.dart';
import '../../design_system/components/brand_mark.dart';
import '../../design_system/components/card_a_misura_fissa.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../synastry/sinastria_share_card.dart' show captureBoundaryPng;
import '../tarot/tarot_card_art.dart';

/// **LA CARD DELL'ARCANO DELL'ALBA, da mandare.** Ordine DW voce 02, 18
/// settembre 2026.
///
/// Il fondatore, sul telefono: *"ti sei dimenticato di aggiungere i pulsanti
/// per la condivisione che inserisci sempre e quindi non crea nemmeno la card
/// di condivisione"*. L'Arcano era l'unico dono senza card: l'ordine DT voce
/// 02 gli aveva tolto ogni comando.
///
/// Porta cio' che la persona ha ricevuto, nell'ordine della schermata: la
/// carta col suo verso, la parola di oggi, il gesto col suo perche', la
/// chiusura di Medora. **Il filo con ieri non ci sta**: parla della persona e
/// di una carta che chi riceve non ha visto.
class ArcanoDellAlbaShareCard extends StatelessWidget {
  const ArcanoDellAlbaShareCard({
    super.key,
    required this.responso,
    required this.palette,
    this.width = 380,
  });

  final ResponsoDellAlba responso;
  final MaestroPalette palette;
  final double width;

  /// Il nome della carta col verso, con la maiuscola: *"La Giustizia
  /// dritta"*.
  static String titoloDi(ResponsoDellAlba r) {
    final nome = ResponsoDellAlba.cartaColVerso(r.stato);
    return nome.isEmpty ? nome : nome[0].toUpperCase() + nome.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final parola = responso.parola;
    final perche = responso.perche.trim();
    // **UNA CARD CHE ESCE DAL TELEFONO SI DISEGNA A MISURA FISSA**, come la
    // Stesa: la scala del testo di chi la crea non entra nell'immagine.
    return CardAMisuraFissa(
      child: Container(
        key: const Key('arcano_alba_card_da_condividere'),
        width: width,
        padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.lg,
            SpacingTokens.lg, SpacingTokens.lg),
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
            Text('ARCANO DELL\'ALBA',
                textAlign: TextAlign.center,
                style: TypographyTokens.etichetta()
                    .copyWith(color: palette.goldSoft, letterSpacing: 3.0)),
            const SizedBox(height: SpacingTokens.md),
            Center(
              child: SizedBox(
                width: 190,
                child: AspectRatio(
                  aspectRatio: TarotFrame.aspect,
                  child: TarotCardArt(
                    card: responso.carta,
                    palette: palette,
                    reversed: responso.stato.rovescio,
                    borderRadius: 8,
                  ),
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.sm),
            Text(titoloDi(responso),
                key: const Key('arcano_card_carta'),
                textAlign: TextAlign.center,
                style: TypographyTokens.titoloScheda()
                    .copyWith(color: ColorTokens.textPrimary, height: 1.2)),
            if (parola != null) ...[
              const SizedBox(height: SpacingTokens.md),
              Text('LA PAROLA DI OGGI',
                  textAlign: TextAlign.center,
                  style: TypographyTokens.etichetta()
                      .copyWith(color: palette.goldSoft, letterSpacing: 1.6)),
              const SizedBox(height: 2),
              Text(parola.toUpperCase(),
                  key: const Key('arcano_card_parola'),
                  textAlign: TextAlign.center,
                  style: TypographyTokens.cerimoniale()
                      .copyWith(color: palette.goldSoft, letterSpacing: 1.5)),
            ],
            const SizedBox(height: SpacingTokens.md),
            // Il gesto nel suo riquadro, come nella schermata.
            Container(
              padding: const EdgeInsets.all(SpacingTokens.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
                color: palette.deepest.withValues(alpha: 0.55),
                border:
                    Border.all(color: palette.goldSoft.withValues(alpha: 0.45)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('IL GESTO DI OGGI',
                      style: TypographyTokens.etichetta().copyWith(
                          color: palette.goldSoft, letterSpacing: 1.4)),
                  const SizedBox(height: 4),
                  Text(responso.secondo,
                      key: const Key('arcano_card_gesto'),
                      style: TypographyTokens.corpo().copyWith(
                          color: ColorTokens.textPrimary, height: 1.4)),
                  if (perche.isNotEmpty) ...[
                    const SizedBox(height: SpacingTokens.sm),
                    Text('PERCHÉ',
                        style: TypographyTokens.etichetta().copyWith(
                            color: palette.goldSoft, letterSpacing: 1.4)),
                    const SizedBox(height: 4),
                    Text(perche,
                        key: const Key('arcano_card_perche'),
                        style: TypographyTokens.corpo().copyWith(
                            color: ColorTokens.textPrimary, height: 1.4)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            Text(responso.lettura.medora,
                textAlign: TextAlign.center,
                style: TypographyTokens.corpo().copyWith(
                    color: ColorTokens.textSecondary,
                    height: 1.35,
                    fontStyle: FontStyle.italic)),
            const SizedBox(height: SpacingTokens.md),
            const Center(child: BrandLogo(size: 40)),
            const SizedBox(height: 4),
            Text(BrandMark.wordmark,
                textAlign: TextAlign.center,
                style: TypographyTokens.etichetta()
                    .copyWith(color: palette.goldSoft, letterSpacing: 2.4)),
            Text(Brand.domain,
                key: const Key('arcano_card_dominio'),
                textAlign: TextAlign.center,
                style: TypographyTokens.etichetta().copyWith(
                    color: ColorTokens.textSecondary, letterSpacing: 0.6)),
          ],
        ),
      ),
    );
  }
}

/// Il testo che accompagna la card: dice a chi la riceve che cosa sta
/// guardando e dove trovarlo, invece di parlargli come se l'avesse girata lui.
String testoDellArcanoCondiviso(ResponsoDellAlba r) {
  final parola = r.parola;
  final laParola = parola == null ? '' : ' La mia parola: $parola.';
  return 'Il mio Arcano dell\'Alba di oggi: '
      '${ResponsoDellAlba.cartaColVerso(r.stato)}.$laParola '
      'Gira il tuo su ${Brand.url}';
}

/// Genera la card come immagine dal boundary e apre il foglio di condivisione.
/// Il PNG va in un file temporaneo del dispositivo, non su un server.
Future<bool> shareArcanoDellAlbaCard({
  required GlobalKey boundaryKey,
  required String text,
}) async {
  final png = await captureBoundaryPng(boundaryKey);
  if (png == null) return false;
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/arcano_dell_alba.png');
  await file.writeAsBytes(png, flush: true);
  // L'esito VERO della porta risale al chiamante, che a condivisione
  // avvenuta paga il premio dichiarato sul pulsante.
  return PortaDellaCondivisione.daFile(file.path, testo: text);
}
