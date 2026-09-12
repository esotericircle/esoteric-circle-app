import 'package:flutter/material.dart';

import '../theme/maestro_palette.dart';
import '../tokens/color_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';
import 'card_a_misura_fissa.dart';

/// **LA CARD CHE UNO MANDA DAVVERO.** Ordine CQ voce 6.26, 4 settembre 2026.
///
/// **La domanda del fondatore**: *"ogni responso deve diventare virale e
/// l'utente deve essere spinto emotivamente a condividere, quindi secondo te:
/// perche' l'utente dovrebbe condividere il contenuto? e a proposito della
/// card, cosa dovrebbe esserci d'impatto?"*
///
/// **La risposta, e da qui discende ogni riga di questo file.** Le persone non
/// condividono informazioni: condividono **identita'**. Un responso si manda
/// quando chi lo legge pensa *questo sono io* e vuole che gli altri lo
/// sappiano. Tre conseguenze, e sono tre vincoli di disegno.
///
/// **UNA. La frase e' una sola, e sta al centro.** Nessuno manda tre paragrafi:
/// manda una riga che potrebbe scriversi addosso. Per questo qui c'e' [frase]
/// e non un testo lungo, ed e' la stessa frase che nella schermata fa da
/// titolo. Se il titolo e' gia' la risposta, la card e' gia' scritta.
///
/// **DUE. Il simbolo e' il suo, non un logo.** Una card con un marchio al
/// centro pubblicizza l'app; una card con la SUA runa, la SUA carta, la SUA
/// fase lunare parla di lui, e fa nascere nell'amico l'unica domanda che porta
/// dentro qualcuno: *e la mia qual e'?* Per questo [simbolo] non ha un
/// ripiego: una card senza simbolo non si costruisce.
///
/// **TRE. Il testo di servizio sta ai bordi e in piccolo.** La card compete
/// con foto e video nelle storie: ogni riga che non e' la frase o il simbolo
/// toglie forza a quelle due. Qui restano una riga in cima, che dice di quale
/// arte si tratta, e due righe in fondo.
///
/// **PERCHE' UN COMPONENTE SOLO PER SETTE ARTI.** Sette card scritte a mano
/// sono sette identita' visive che divergono alla prima modifica, ed e' la
/// famiglia di difetti che questo progetto insegue da sempre. Qui la
/// proporzione, l'aria, la misura della frase e la riga d'invito stanno in un
/// posto solo.
class CardDaMandare extends StatelessWidget {
  const CardDaMandare({
    super.key,
    required this.palette,
    required this.arte,
    required this.frase,
    required this.simbolo,
    this.parola,
    this.invito = 'Il tuo responso di oggi ti aspetta',
    this.width = 360,
  });

  final MaestroPalette palette;

  /// Il nome dell'arte, in cima e in piccolo: dice di cosa si tratta senza
  /// contendere l'occhio alla frase.
  final String arte;

  /// **LA FRASE, ed e' il cuore della card.** Una sola, corta, che chi manda
  /// riconosce come propria. Viene dal titolo del responso, che per la legge
  /// del mood e' gia' la risposta.
  final String frase;

  /// **L'ARTE AL CENTRO**: la runa, l'arcano, la fase lunare, la
  /// costellazione. Non un logo, non un'icona di sistema: la cosa che e'
  /// uscita a lui.
  final Widget simbolo;

  /// La parola chiave sotto il simbolo, quando l'arte ne ha una.
  final String? parola;

  /// La riga d'invito in fondo. **Promette una cosa personale e non un'app**:
  /// chi legge deve pensare "anche io ho un responso oggi", non "devo
  /// scaricare qualcosa".
  final String invito;

  final double width;

  @override
  Widget build(BuildContext context) {
    // **A MISURA FISSA, ordine CN voce 12.** La scala del testo di chi la
    // crea non entra nell'immagine, perche' l'immagine la guardano altri.
    return CardAMisuraFissa(
      child: Container(
        key: const Key('card_da_mandare'),
        width: width,
        // **NOVE SEDICESIMI**, che e' la proporzione delle storie: una card
        // quadrata dentro una storia lascia due fasce vuote, e in quelle due
        // fasce l'occhio va altrove.
        height: width * 16 / 9,
        padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.lg, vertical: SpacingTokens.xl),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              palette.deepest,
              ColorTokens.neutralDeep,
              palette.deepest,
            ],
          ),
          border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
        ),
        child: Column(
          children: [
            Text(arte.toUpperCase(),
                key: const Key('card_arte'),
                textAlign: TextAlign.center,
                style: TypographyTokens.etichetta().copyWith(
                    color: palette.goldSoft.withValues(alpha: 0.9),
                    letterSpacing: 2.4)),
            // **IL CENTRO PRENDE TUTTO LO SPAZIO CHE AVANZA**, e non e' un
            // dettaglio di layout: e' la dichiarazione che la frase e il
            // simbolo vengono prima di tutto il resto.
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  simbolo,
                  const SizedBox(height: SpacingTokens.lg),
                  Text(frase,
                      key: const Key('card_frase'),
                      textAlign: TextAlign.center,
                      // **CERIMONIALE, ventotto punti.** E' il ruolo piu'
                      // grande dopo il titolo d'apertura: una frase che si
                      // legge in una storia, scorrendo, senza fermarsi.
                      style: TypographyTokens.cerimoniale(weight: 500)
                          .copyWith(color: ColorTokens.textPrimary,
                              height: 1.12)),
                  if (parola != null) ...[
                    const SizedBox(height: SpacingTokens.md),
                    // **L'ORO PIENO NON REGGE UNA PAROLA IN PICCOLO, e
                    // il numero l'ha detto il censimento del contrasto.
                    // `gold` sotto il ruolo etichetta misura 5.42 sul vetro
                    // sopra Aura, 5.65 sulla casa di Aura, 6.42 e 6.69 su
                    // quelle di Caligo, contro la soglia di sette che il
                    // testo piccolo deve rispettare. `goldSoft`, che e
                    // `goldLight`, la passa ovunque **e per giunta si vede
                    // meglio**: la parola chiave e' il secondo fuoco della
                    // card dopo la frase, e doveva essere la piu' chiara
                    // delle due, non la piu' scura.
                    Text(parola!.toUpperCase(),
                        key: const Key('card_parola'),
                        textAlign: TextAlign.center,
                        style: TypographyTokens.etichetta().copyWith(
                            color: palette.goldSoft, letterSpacing: 3.2)),
                  ],
                ],
              ),
            ),
            Text('Esoteric Circle',
                key: const Key('card_marchio'),
                style: TypographyTokens.etichetta().copyWith(
                    color: palette.goldSoft.withValues(alpha: 0.75),
                    letterSpacing: 2.6)),
            const SizedBox(height: SpacingTokens.xxs),
            Text(invito,
                key: const Key('card_invito'),
                textAlign: TextAlign.center,
                style: TypographyTokens.etichetta().copyWith(
                    color: ColorTokens.textSecondary, letterSpacing: 0.4)),
          ],
        ),
      ),
    );
  }
}
