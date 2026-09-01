import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/archetypes/archetype.dart';
import '../../../../core/maestro/maestro.dart';
import '../../../../core/archetypes/archetype_corpus.dart';
import '../../../../core/archetypes/archetype_scoring.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import '../../../synastry/sinastria_share_card.dart' show captureBoundaryPng;
import 'archetype_wheel.dart';
import '../../../../core/condivisione/porta_della_condivisione.dart';
import '../../../../design_system/components/card_a_misura_fissa.dart';

/// La card condivisibile del Test Archetipo, nella cornice verde e oro di Aura.
///
/// In alto la ruota vera del risultato, l'astrolabio del responso coi dodici
/// nomi e il poligono verde, con la fetta del dominante accesa in oro e quella
/// del co-dominante in un tono piu' tenue, e la statua del dominante al centro,
/// dentro il disco interno senza coprire i nomi. Sotto, in colonna: il nome con
/// l'articolo, la percentuale e il co-dominante, il motto, la bolla della Luce
/// col testo dal corpus, la classifica compatta dei primi tre col cerchio della
/// miniatura, e in fondo la firma piu' l'invito. Testo e percentuali vengono
/// tutti dallo stesso profilo mostrato nel responso, quindi la card e'
/// deterministica: stesso profilo, stessa immagine. Si cattura come PNG da un
/// `RepaintBoundary` e si apre col foglio di condivisione. L'altezza si adatta
/// al contenuto, cosi' nessun archetipo, per quanto lunga sia la sua Luce, va in
/// overflow.
class ArchetypeShareCard extends StatelessWidget {
  const ArchetypeShareCard({super.key, required this.profilo});

  final ArchetypeProfile profilo;

  static const double larghezza = 400;

  /// Lato della ruota sulla card. La statua sta al centro, alta abbastanza da
  /// restare dentro il disco interno (l'ottanta per cento del raggio) senza
  /// arrivare all'anello dei nomi.
  static const double _latoRuota = 300;

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.aura));
    final dom = profilo.dominante;
    final ritratto = ArchetypeCorpus.di(dom);
    final secondo = profilo.secondo;
    final primiTre = profilo.graduatoria.take(3).toList();
    // **UNA CARD CHE ESCE DAL TELEFONO SI DISEGNA A MISURA FISSA.**
    // Ordine CN voce 12: la scala del testo di chi la crea non entra
    // nell'immagine, perche' l'immagine la guardano altri.
    return CardAMisuraFissa(
      child: Container(
        key: const Key('archetype_share_card'),
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
              // Provenienza in alto: da dove arriva l'immagine.
              Text('TEST ARCHETIPO',
                  style: TypographyTokens.label(size: 12)
                      .copyWith(color: palette.goldSoft, letterSpacing: 2.0)),
              const SizedBox(height: SpacingTokens.md),
              // La ruota vera del risultato, grande, con la statua al centro. La
              // fetta del dominante e' in oro, quella del co-dominante piu' tenue.
              SizedBox(
                width: _latoRuota,
                height: _latoRuota,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ArchetypeWheel(
                      profilo: profilo,
                      palette: palette,
                      lato: _latoRuota,
                      accendiSecondo: true,
                    ),
                    // La statua sopra il poligono, dentro il disco, dimensionata
                    // per non toccare l'anello dei nomi.
                    Image.asset(dom.artePiena,
                        height: _latoRuota * 0.66,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                            Icons.person_outline_rounded,
                            size: 150,
                            color: palette.goldSoft)),
                  ],
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              Text(dom.conArticolo.toUpperCase(),
                  style: TypographyTokens.cerimoniale()
                      .copyWith(color: palette.goldSoft)),
              const SizedBox(height: 2),
              // La percentuale del dominante e il co-dominante, quando c'e'.
              Text(
                secondo != null
                    ? '${profilo.percentualeDi(dom).round()}% · accanto ${secondo.conArticolo}'
                    : '${profilo.percentualeDi(dom).round()}%',
                style: TypographyTokens.label(size: 12).copyWith(
                    color: palette.textPrimary.withValues(alpha: 0.85),
                    letterSpacing: 0.5),
              ),
              const SizedBox(height: SpacingTokens.xs),
              // Il motto, cioe' l'essenza dal corpus.
              Text(ritratto.essenza,
                  textAlign: TextAlign.center,
                  style: TypographyTokens.corpo().copyWith(
                      color: palette.textPrimary, fontStyle: FontStyle.italic)),
              const SizedBox(height: SpacingTokens.md),
              // La prima bolla del responso, "La sua luce", nello stesso stile.
              _Bolla(
                titolo: 'La sua luce',
                testo: ritratto.luce,
                palette: palette,
              ),
              const SizedBox(height: SpacingTokens.md),
              // La classifica compatta dei primi tre: cerchio, nome, percentuale.
              for (final a in primiTre)
                Padding(
                  padding: const EdgeInsets.only(bottom: SpacingTokens.xs),
                  child: _RigaTre(
                    archetipo: a,
                    percentuale: profilo.percentualeDi(a).round(),
                    dominante: a == dom,
                    palette: palette,
                  ),
                ),
              const SizedBox(height: SpacingTokens.sm),
              Text('Esoteric Circle · Aura',
                  style: TypographyTokens.etichetta().copyWith(
                      color: palette.goldSoft.withValues(alpha: 0.7),
                      letterSpacing: 1.0)),
              const SizedBox(height: 2),
              Text('Scopri il tuo archetipo su Esoteric Circle',
                  style: TypographyTokens.corpo().copyWith(
                      color: palette.textPrimary.withValues(alpha: 0.6),
                      letterSpacing: 0.4)),
            ],
          ),
        ),
      ),
    );
  }
}

/// La bolla della Luce sulla card, nello stesso linguaggio della bolla del
/// responso: etichetta oro e testo lungo, su una superficie elevata col filo
/// d'oro. Costruita a mano, senza `DepthCard`, perche' la card si cattura da
/// sola, fuori da MaestroScope e senza il controller della qualita'.
class _Bolla extends StatelessWidget {
  const _Bolla({
    required this.titolo,
    required this.testo,
    required this.palette,
  });

  final String titolo;
  final String testo;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            palette.surfaceElevated.withValues(alpha: 0.92),
            palette.surface.withValues(alpha: 0.78),
          ],
        ),
        border: Border.all(color: palette.gold.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titolo,
              style: TypographyTokens.label(size: 12)
                  .copyWith(color: palette.goldSoft, letterSpacing: 0.6)),
          const SizedBox(height: SpacingTokens.xs),
          Text(testo,
              style: TypographyTokens.corpo()
                  .copyWith(color: palette.textPrimary, height: 1.55)),
        ],
      ),
    );
  }
}

/// Una riga della classifica compatta sulla card: cerchio con la miniatura,
/// nome e percentuale. Il dominante e' acceso in oro.
class _RigaTre extends StatelessWidget {
  const _RigaTre({
    required this.archetipo,
    required this.percentuale,
    required this.dominante,
    required this.palette,
  });

  final Archetype archetipo;
  final int percentuale;
  final bool dominante;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: palette.surface.withValues(alpha: 0.6),
            border: Border.all(
              color: dominante
                  ? palette.goldSoft
                  : palette.gold.withValues(alpha: 0.3),
              width: dominante ? 1.5 : 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            archetipo.arteThumb,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Icon(Icons.person_outline_rounded,
                size: 16, color: palette.goldSoft),
          ),
        ),
        const SizedBox(width: SpacingTokens.sm),
        Expanded(
          child: Text(archetipo.nome,
              style: TypographyTokens.corpo().copyWith(
                  color: dominante ? palette.goldSoft : palette.textPrimary,
                  fontWeight: dominante ? FontWeight.w700 : FontWeight.w400)),
        ),
        Text('$percentuale%',
            style: TypographyTokens.label(size: 12).copyWith(
                color: dominante
                    ? palette.goldSoft
                    : palette.textPrimary.withValues(alpha: 0.7),
                letterSpacing: 0.5)),
      ],
    );
  }
}

/// Genera la card come PNG dal boundary e apre il foglio di condivisione.
/// Il deep link porta all'arte del Test Archetipo nel dominio di Aura.
Future<bool> shareArchetypeCard({
  required GlobalKey boundaryKey,
  required Archetype dominante,
}) async {
  final png = await captureBoundaryPng(boundaryKey);
  if (png == null) return false;
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/archetipo_${dominante.name}.png');
  await file.writeAsBytes(png, flush: true);
  // Ordine BG voce 04: l'esito VERO della porta risale al chiamante,
  // che a condivisione avvenuta paga il premio dichiarato sul pulsante.
  return PortaDellaCondivisione.daFile(file.path,
      testo: 'Il mio archetipo è ${dominante.conArticolo}. '
          'Scopri il tuo con Aura, su Esoteric Circle. '
          'https://esotericircle.app/aura/archetype_test');
}
