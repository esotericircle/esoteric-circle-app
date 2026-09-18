import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/brand/brand.dart';
import '../../core/condivisione/porta_della_condivisione.dart';
import '../../core/sigilli/traguardo.dart';
import '../../design_system/components/brand_mark.dart';
import '../../design_system/components/card_a_misura_fissa.dart';
import '../../design_system/components/loto_dorato.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../synastry/sinastria_share_card.dart' show captureBoundaryPng;

/// **LA CARD DI UN SIGILLO ACCESO, da mandare.** Ordine DW voce 04, 18
/// settembre 2026.
///
/// Il fatto, da uno screenshot dell'iPhone di un fondatore: dalla festa di un
/// traguardo partiva un testo solo. Adesso parte anche l'immagine: il loto
/// d'oro della festa, il nome del Sigillo e il marchio. **La frase del
/// traguardo non ci sta**: e' scritta per chi l'ha acceso (*"tu eri qui"*), e
/// sull'immagine la leggerebbe chi la riceve.
class CardDelSigilloDaMandare extends StatelessWidget {
  const CardDelSigilloDaMandare({
    super.key,
    required this.traguardo,
    required this.palette,
    this.width = 380,
  });

  final Traguardo traguardo;
  final MaestroPalette palette;
  final double width;

  @override
  Widget build(BuildContext context) {
    return CardAMisuraFissa(
      child: Container(
        key: const Key('sigillo_card_da_mandare'),
        width: width,
        padding: const EdgeInsets.all(SpacingTokens.lg),
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
            Text('UN SIGILLO ACCESO NEL CERCHIO',
                textAlign: TextAlign.center,
                style: TypographyTokens.etichetta()
                    .copyWith(color: palette.goldSoft, letterSpacing: 2.4)),
            const SizedBox(height: SpacingTokens.lg),
            Center(child: LotoDorato(lato: 96, colore: palette.goldSoft)),
            const SizedBox(height: SpacingTokens.lg),
            Text(traguardo.nome,
                key: const Key('sigillo_card_nome'),
                textAlign: TextAlign.center,
                style: TypographyTokens.cerimoniale()
                    .copyWith(color: palette.goldSoft, height: 1.2)),
            const SizedBox(height: SpacingTokens.lg),
            const Center(child: BrandLogo(size: 36)),
            const SizedBox(height: 4),
            Text(BrandMark.wordmark,
                textAlign: TextAlign.center,
                style: TypographyTokens.etichetta()
                    .copyWith(color: palette.goldSoft, letterSpacing: 2.4)),
            Text(Brand.domain,
                key: const Key('sigillo_card_dominio'),
                textAlign: TextAlign.center,
                style: TypographyTokens.etichetta().copyWith(
                    color: ColorTokens.textSecondary, letterSpacing: 0.6)),
          ],
        ),
      ),
    );
  }
}

/// **DISEGNA UNA CARD FUORI CAMPO, la fotografa e la manda.** Ordine DW voce
/// 04.
///
/// Le schermate col responso disegnano la loro card in uno Stack fuori campo;
/// la festa di un traguardo condivide da una funzione, senza uno Stack suo.
/// Qui la card si posa per un istante nell'overlay, a sinistra dello schermo,
/// si fotografa e si toglie. Se la foto non riesce parte il testo solo:
/// meglio un messaggio senza immagine di nessun messaggio.
Future<bool> mandaUnaCardFuoriCampo(
  BuildContext context, {
  required Widget card,
  required String testo,
  required String nomeDelFile,
}) async {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return PortaDellaCondivisione.testo(testo);
  final chiave = GlobalKey();
  final voce = OverlayEntry(
    builder: (_) => Positioned(
      left: -3000,
      top: 0,
      child: RepaintBoundary(key: chiave, child: card),
    ),
  );
  overlay.insert(voce);
  String? percorso;
  try {
    await WidgetsBinding.instance.endOfFrame;
    await Future<void>.delayed(const Duration(milliseconds: 120));
    // Un tetto alla foto: una foto che non torna non deve lasciare la
    // persona davanti a un pulsante che non fa niente.
    final png = await captureBoundaryPng(chiave)
        .timeout(const Duration(milliseconds: 1500));
    if (png != null) {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$nomeDelFile');
      await file.writeAsBytes(png, flush: true);
      percorso = file.path;
    }
  } catch (fotoMancata) {
    // Nessun disco o nessuna foto: si manda il testo col link, e il perche'
    // resta scritto nel registro invece di sparire.
    debugPrint('La card del Sigillo non si e\' fotografata: $fotoMancata');
    percorso = null;
  } finally {
    voce.remove();
  }
  if (percorso == null) return PortaDellaCondivisione.testo(testo);
  return PortaDellaCondivisione.daFile(percorso, testo: testo);
}
