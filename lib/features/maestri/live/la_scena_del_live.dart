import 'package:flutter/material.dart';

import '../../../design_system/tokens/color_tokens.dart';
import '../../../design_system/tokens/spacing_tokens.dart';
import '../../../design_system/tokens/typography_tokens.dart';

/// **LA SCENA DEL LIVE: IL VOLTO, LA DOMANDA, LA RISPOSTA.** Ordine EM voci
/// 09 e 10, 25 settembre 2026.
///
/// Il fondatore: *"Quando faccio una domanda l'immagine del maestro
/// s'ingrandisce di botto e poi si riduce di botto quando inizia a
/// rispondere"*, e *"Quando faccio una domanda, la domanda dovrebbe comparire
/// in grande e in giallo anche nel testo subito sopra la risposta, invece
/// adesso compare solo la risposta."*
///
/// **La causa, tutte e due le volte, era lo stesso testo.** Il volto stava in
/// un `Expanded`, e sotto c'era il sottotitolo, alto quanto il suo testo fino
/// al venti per cento dello schermo. Facendo una domanda la risposta lunga di
/// prima diventava la domanda corta, il sottotitolo si accorciava e il volto
/// si allargava; poi arrivava la risposta, il testo si allungava e il volto si
/// stringeva. E siccome domanda e risposta erano lo stesso testo, la risposta
/// cancellava la domanda. Anche la barra dell'ascolto compariva e spariva, e
/// muoveva il volto di sette punti. Padre: ordine EG voce 05, che ha fatto il
/// sottotitolo alto quanto il suo testo.
///
/// **Adesso la zona del testo ha un'altezza fissa**, [parteDelTesto] dello
/// spazio, qualunque cosa ci sia scritto: la domanda in grande e in oro, e
/// sotto la risposta, che scorre dentro la sua zona. La riga dello stato e
/// il posto della barra ci sono sempre, anche vuoti. Il volto non cambia mai
/// misura. **Sta qui, fuori dalla schermata**, perche' una prova la monti e la
/// misuri: e' la stessa composizione che la schermata usa.
class LaScenaDelLive extends StatelessWidget {
  const LaScenaDelLive({
    super.key,
    required this.volto,
    required this.domanda,
    required this.risposta,
    required this.stato,
    this.livello,
    this.tastiera,
  });

  /// Il volto del Maestro, o cio' che sta al suo posto.
  final Widget volto;

  /// L'ultima domanda della persona, vuota se non ce n'e'.
  final String domanda;

  /// L'ultima cosa detta dal Maestro.
  final String risposta;

  /// La riga dello stato, vuota quando non c'e' niente da dire.
  final String stato;

  /// La barra del livello del microfono, o null quando non si ascolta: il
  /// suo posto resta.
  final Widget? livello;

  /// La tastiera, quando si puo' scrivere.
  final Widget? tastiera;

  /// **Quanta parte dello spazio ha la zona del testo, sempre la stessa.**
  /// Poco piu' di un quarto: tre righe di domanda in grande e quattro di
  /// risposta, su un telefono da 844 punti.
  static const double parteDelTesto = 0.27;

  /// Il posto della barra dell'ascolto: largo e alto sempre uguale.
  static const Size postoDellaBarra = Size(120, 3);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, spazio) {
      final zona = spazio.maxHeight * parteDelTesto;
      return Column(
        children: [
          Expanded(child: volto),
          SizedBox(
            key: const Key('live_zona_del_testo'),
            height: zona,
            child: _LaZonaDelTesto(domanda: domanda, risposta: risposta),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
            child: Column(
              children: [
                Text(
                  key: const Key('live_stato'),
                  stato,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TypographyTokens.didascalia()
                      .copyWith(color: ColorTokens.textSecondary),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: SpacingTokens.xs),
                  child: SizedBox.fromSize(
                    key: const Key('live_posto_della_barra'),
                    size: postoDellaBarra,
                    child: livello,
                  ),
                ),
              ],
            ),
          ),
          if (tastiera != null) tastiera!,
        ],
      );
    });
  }
}

class _LaZonaDelTesto extends StatelessWidget {
  const _LaZonaDelTesto({required this.domanda, required this.risposta});

  final String domanda;
  final String risposta;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (domanda.isNotEmpty) ...[
            Text(
              key: const Key('live_domanda'),
              domanda,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TypographyTokens.titoloSezione()
                  .copyWith(color: ColorTokens.goldLight),
            ),
            const SizedBox(height: SpacingTokens.sm),
          ],
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                key: const Key('live_sottotitolo'),
                risposta,
                style: TypographyTokens.corpo(),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
