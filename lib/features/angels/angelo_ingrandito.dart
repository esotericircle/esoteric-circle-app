import 'package:flutter/material.dart';

import '../../core/angels/angel_catalog.dart';
import '../../core/assets/family_image.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// I tre ruoli della triade, come li ha decisi Mauro il 28 luglio 2026.
///
/// Non sono tre sinonimi di "custode": ciascuno nasce da un dato diverso della
/// nascita, quindi ciascuno ha il suo nome. Il primo veniva chiamato "Custode"
/// e contraddiceva perfino il sottotitolo della sua schermata, che chiamava
/// custodi tutti e tre.
enum RuoloAngelo {
  /// Dai gradi del Sole alla nascita.
  fisico('Fisico', 'dai gradi del Sole'),

  /// Dal giorno di nascita.
  cuore('Del cuore', 'dal giorno'),

  /// Dall'ora di nascita.
  intelletto("Dell'intelletto", "dall'ora");

  const RuoloAngelo(this.titolo, this.origine);

  /// Come si chiama a schermo.
  final String titolo;

  /// Da quale dato della nascita viene, detto in tre parole.
  final String origine;

  /// I tre in ordine, per indice nella triade.
  static RuoloAngelo perIndice(int i) => switch (i) {
        0 => fisico,
        1 => cuore,
        _ => intelletto,
      };
}

/// L'ingrandimento di un Angelo: UN solo componente per tutta l'app.
///
/// Si apre dalla schermata del trionfo e dalla tessera della carta natale. Una
/// seconda implementazione sarebbe due verita' che col tempo divergono, quindi
/// qui ce n'e' una, e chi la vuole la chiama.
///
/// Mostra solo cio' che la politica di pubblicazione del corpus consente:
/// nome, coro, arcangelo, arco di gradi col segno, salmo e chiave di lettura.
/// Niente promesse di esito, niente salute.
class AngeloIngrandito extends StatelessWidget {
  const AngeloIngrandito({
    super.key,
    required this.angelo,
    required this.ruolo,
    required this.palette,
  });

  final Angel angelo;
  final RuoloAngelo ruolo;

  /// La palette arriva da fuori e non dallo scope: un foglio modale nasce
  /// sotto il Navigator, non sotto il MaestroScope della schermata che lo
  /// apre, quindi li' dentro il colore del Maestro non ci sarebbe.
  final MaestroPalette palette;

  /// Apre l'ingrandimento come foglio che sale dal basso.
  static Future<void> apri(
    BuildContext context, {
    required Angel angelo,
    required RuoloAngelo ruolo,
  }) {
    // La palette si legge QUI, dove lo scope c'e' ancora, e viaggia col
    // widget: dentro il foglio non ci sarebbe piu' nessuno a darla.
    final palette = context.palette;
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AngeloIngrandito(
          angelo: angelo, ruolo: ruolo, palette: palette),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lore = angelo.lore;

    return DraggableScrollableSheet(
      initialChildSize: 0.86,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      expand: false,
      builder: (context, controller) => Container(
        key: const Key('angelo_ingrandito'),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [palette.surfaceElevated, palette.deepest],
          ),
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(SpacingTokens.radiusLg)),
          border: Border.all(color: palette.gold.withValues(alpha: 0.3)),
        ),
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.all(SpacingTokens.lg),
          children: [
            // La maniglia: dice che si tira e si chiude.
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: palette.gold.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.lg),
            // L'arte grande, intera: proporzione di carta, mai ritagliata.
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 260),
                child: AspectRatio(
                  aspectRatio: 2 / 3,
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(SpacingTokens.radiusLg),
                    child: Image.asset(
                      FamilyImage.full(AssetFamily.angeli, angelo.artStem),
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(Icons.auto_awesome,
                          color: palette.goldSoft, size: 48),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.lg),
            Text(ruolo.titolo.toUpperCase(),
                textAlign: TextAlign.center,
                // Una riga sola: l'etichetta non si spezza dentro una parola.
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.visible,
                style: TypographyTokens.label(size: 11).copyWith(
                    color: palette.goldSoft, letterSpacing: 2)),
            const SizedBox(height: SpacingTokens.xxs),
            Text('${angelo.number}. ${angelo.name}',
                textAlign: TextAlign.center,
                style: TypographyTokens.display(size: 28)),
            const SizedBox(height: SpacingTokens.xs),
            Text(
              'Coro dei ${angelo.choir.name}, retto da '
              '${angelo.choir.archangel}',
              textAlign: TextAlign.center,
              style: TypographyTokens.body(size: 14)
                  .copyWith(color: ColorTokens.textSecondary),
            ),
            const SizedBox(height: SpacingTokens.md),
            _Riga(
              titolo: 'Perché è tuo',
              testo: 'Il tuo angelo ${ruolo.titolo.toLowerCase()}, '
                  '${ruolo.origine} della tua nascita.',
              palette: palette,
            ),
            if (lore != null) ...[
              _Riga(
                titolo: 'Il suo arco',
                testo: '${lore.degrees} dello zodiaco, nel segno ${lore.sign}.',
                palette: palette,
              ),
              if (lore.psalm.isNotEmpty)
                _Riga(titolo: 'Il salmo', testo: lore.psalm, palette: palette),
              if (lore.reading.isNotEmpty)
                _Riga(
                    titolo: 'La chiave di lettura',
                    testo: lore.reading,
                    palette: palette),
            ],
            const SizedBox(height: SpacingTokens.lg),
            Center(
              child: TextButton(
                key: const Key('angelo_ingrandito_chiudi'),
                onPressed: () => Navigator.of(context).maybePop(),
                child: Text('Torna ai tre',
                    style: TypographyTokens.body(size: 15)
                        .copyWith(color: palette.goldSoft)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Riga extends StatelessWidget {
  const _Riga({
    required this.titolo,
    required this.testo,
    required this.palette,
  });

  final String titolo;
  final String testo;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titolo.toUpperCase(),
              style: TypographyTokens.label(size: 11).copyWith(
                  color: palette.goldSoft, letterSpacing: 1.6)),
          const SizedBox(height: SpacingTokens.xxs),
          Text(testo,
              style: TypographyTokens.body(size: 15).copyWith(height: 1.45)),
        ],
      ),
    );
  }
}
