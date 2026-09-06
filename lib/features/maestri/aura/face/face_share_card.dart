import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/face/face_classifier.dart';
import '../../../../core/face/face_corpus.dart';
import '../../../../core/face/face_trait.dart';
import '../../../../core/maestro/maestro.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import '../../../synastry/sinastria_share_card.dart' show captureBoundaryPng;
import 'face_constellation.dart';
import 'face_constellation_painter.dart';
import 'face_silhouette.dart';
import '../../../../core/brand/brand.dart';
import '../../../../core/condivisione/porta_della_condivisione.dart';
import '../../../../core/face/mian_xiang.dart';
import '../../../../design_system/components/card_a_misura_fissa.dart';

/// La card condivisibile della Costellazione del Viso, nella cornice verde e oro
/// di Aura, coerente con la card del Test Archetipo.
///
/// Il volto sta sotto, molto sbiadito, e la COSTELLAZIONE sopra e' molto
/// visibile, con contrasto e luminosita' alzati: e' lei la protagonista. In alto
/// la provenienza, poi il titolo evocativo, la sintesi breve, i tratti
/// principali, in fondo la firma e l'invito. L'altezza si adatta al contenuto.
class FaceShareCard extends StatelessWidget {
  const FaceShareCard({
    super.key,
    required this.reading,
    required this.costellazione,
    this.fotoPath,
  });

  final FaceReading reading;
  final FaceConstellation costellazione;
  final String? fotoPath;

  static const double larghezza = 400;
  static const double _latoVolto = 300;

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.aura));
    final dom = reading.dominante;
    // **L'ELEMENTO ARRIVA A CHI GUARDA. Ordine CR voce 10.** Il Mian
    // Xiang stava in `lib/core/face/mian_xiang.dart` con le sue guardie e
    // **nessun file di `lib` lo chiamava**: prodotto, non agganciato. La
    // forma del volto e' una misura vera, e da quella nasce l'elemento.
    final elemento = MianXiang.elementoDa(
        reading.letturaDi(FaceCategory.formaVolto).tratto);
    // **UNA CARD CHE ESCE DAL TELEFONO SI DISEGNA A MISURA FISSA.**
    // Ordine CN voce 12: la scala del testo di chi la crea non entra
    // nell'immagine, perche' l'immagine la guardano altri.
    return CardAMisuraFissa(
      child: Container(
        key: const Key('face_share_card'),
        width: larghezza,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [palette.surfaceElevated, palette.deepest],
          ),
          border:
              Border.all(color: palette.gold.withValues(alpha: 0.75), width: 3),
        ),
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('COSTELLAZIONE DEL VISO',
                  style: TypographyTokens.label(size: 12)
                      .copyWith(color: palette.goldSoft, letterSpacing: 2.0)),
              const SizedBox(height: SpacingTokens.md),
              // Il volto sbiadito con la costellazione molto accesa sopra.
              SizedBox(
                width: _latoVolto,
                height: _latoVolto,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(SpacingTokens.radiusXl),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Opacity(
                        opacity: fotoPath != null ? 0.35 : 0.6,
                        child: fotoPath != null
                            ? Image.file(File(fotoPath!),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _Sagoma(palette: palette))
                            : _Sagoma(palette: palette),
                      ),
                      CustomPaint(
                        painter: FaceConstellationPainter(
                          costellazione: costellazione,
                          palette: palette,
                          pulsazione: 1.0,
                          risalto: 1.7,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              Text(dom.titoloEvocativo,
                  textAlign: TextAlign.center,
                  style: TypographyTokens.titoloSezione()
                      .copyWith(color: palette.goldSoft)),
              const SizedBox(height: 2),
              Text(dom.nome,
                  style: TypographyTokens.label(size: 12).copyWith(
                      color: palette.textPrimary.withValues(alpha: 0.85),
                      letterSpacing: 0.5)),
              const SizedBox(height: SpacingTokens.xs),
              // La sintesi breve: la frase del tratto dominante.
              Text(FaceCorpus.frase(dom),
                  textAlign: TextAlign.center,
                  style: TypographyTokens.corpo().copyWith(
                      color: palette.textPrimary, fontStyle: FontStyle.italic)),
              const SizedBox(height: SpacingTokens.md),
              // **L'ELEMENTO AL POSTO DELL'ELENCO.** Ordine CR voce 10: sulla
              // card sta *"la costellazione composta, protagonista; il volto
              // molto sbiadito sotto; il titolo che e' gia' la risposta;
              // l'elemento dominante; una riga sola di essenza"*. Un elenco
              // di quattro tratti non e' in quella lista, e su una card che
              // gira ogni riga in piu' toglie forza a quella che conta.
              if (elemento != null)
                Container(
                  key: const Key('face_card_elemento'),
                  padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.md,
                      vertical: SpacingTokens.xs),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(SpacingTokens.radiusXl),
                    border: Border.all(
                        color: palette.gold.withValues(alpha: 0.55)),
                  ),
                  child: Text('Elemento ${elemento.nome}',
                      style: TypographyTokens.etichetta().copyWith(
                          color: palette.goldSoft, letterSpacing: 1.2)),
                ),
              const SizedBox(height: SpacingTokens.sm),
              Text('Esoteric Circle · Aura',
                  style: TypographyTokens.etichetta().copyWith(
                      color: palette.goldSoft.withValues(alpha: 0.7),
                      letterSpacing: 1.0)),
              const SizedBox(height: 2),
              // **UNA CARD CHE GIRA DEVE DIRE DOVE SI VA.** Ordine CR voce
              // 10: prima qui c'era "Scopri la tua costellazione su Esoteric
              // Circle", che e' un NOME. Chi guarda una fotografia non puo'
              // toccare un nome: puo' digitare un dominio, e per questo si
              // stampa il dominio e non l'URL intero.
              Text(Brand.domain,
                  key: const Key('face_card_indirizzo'),
                  style: TypographyTokens.corpo().copyWith(
                      color: palette.goldSoft.withValues(alpha: 0.9),
                      letterSpacing: 0.8)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Sagoma extends StatelessWidget {
  const _Sagoma({required this.palette});

  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(colors: [
          palette.surfaceElevated.withValues(alpha: 0.6),
          palette.deepest.withValues(alpha: 0.9),
        ]),
      ),
      child: CustomPaint(painter: FaceSilhouettePainter(palette: palette)),
    );
  }
}

/// Genera la card come PNG dal boundary e apre il foglio di condivisione.
Future<bool> shareFaceCard({
  required GlobalKey boundaryKey,
  required FaceTrait dominante,
}) async {
  final png = await captureBoundaryPng(boundaryKey);
  if (png == null) return false;
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/costellazione_viso_${dominante.name}.png');
  await file.writeAsBytes(png, flush: true);
  // Ordine BG voce 04: l'esito VERO della porta risale al chiamante,
  // che a condivisione avvenuta paga il premio dichiarato sul pulsante.
  return PortaDellaCondivisione.daFile(file.path,
      testo: testoDaCondividere(dominante: dominante));
}

/// **IL TESTO CHE PARTE DAVVERO, come funzione pura.**
///
/// Sta fuori da [shareFaceCard] perche' quella vuole una fotocamera, un
/// file e un foglio di sistema: tre cose che in prova non esistono. Cosi'
/// una guardia puo' leggere ESATTAMENTE cio' che uscirebbe dal telefono.
String testoDaCondividere({required FaceTrait dominante}) {
  return 'La mia Costellazione del Viso dice "${dominante.titoloEvocativo}". '
      'Scopri la tua con Aura, su Esoteric Circle. ${Brand.url}';
}
