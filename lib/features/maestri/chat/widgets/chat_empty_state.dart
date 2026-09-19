import 'package:flutter/material.dart';

import '../../../../core/maestro/maestro.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import '../../widgets/busto_del_maestro.dart';

/// Apertura della chat prima del primo messaggio: IL MAESTRO E IL SUO
/// BENVENUTO, e nient'altro.
///
/// ORDINE 2164, VOCI 3 E 4. Qui vivevano due altre porte ai suggerimenti: il
/// pulsante "Tocca per tutte le domande" e la riga orizzontale di tre domande
/// d'assaggio. Parole di Mauro: bolle inutili e ripetitive, e il pulsante e'
/// una ripetizione dell'icona a stelline accanto al campo. Sono state TOLTE,
/// non nascoste: **resta una porta sola ai suggerimenti, l'icona a stelline**,
/// e una prova enumerante conta quella porta e cade se qualcuno ne riapre una
/// seconda.
class ChatEmptyState extends StatelessWidget {
  const ChatEmptyState({
    super.key,
    required this.maestro,
    required this.greeting,
    this.spazioInFondo = 0,
  });

  final Maestro maestro;
  final String greeting;

  /// IL FONDO PORTA IL COMPOSITORE E LA BARRA, come nella lista dei
  /// messaggi: la misura arriva dalla schermata, che e' l'unica a conoscere
  /// l'altezza vera del suo compositore.
  final double spazioInFondo;

  @override
  Widget build(BuildContext context) {
    // **LO SPAZIO DEL COMPOSITORE SI TOGLIE DALLA VIEWPORT, NON DAL
    // CONTENUTO.** Ordine CI voce 01, e la misura che lo ha trovato: col
    // corpo del testo al massimo consentito dal sistema, cioe' 1,3, il
    // benvenuto va a tre righe e finisce a 599 mentre il compositore comincia
    // a 571. **Ventotto punti di testo dietro i pulsanti**, uguali su tutti e
    // tre i Maestri.
    //
    // La ragione, e non e' quella che sembra. Lo spazio del compositore c'era
    // gia', ma stava come RIEMPIMENTO IN FONDO AL CONTENUTO: serve solo
    // quando il contenuto e' piu' alto della viewport e va scorso, perche'
    // allora tiene l'ultima riga sopra i pulsanti. **Quando invece il
    // contenuto ci sta**, come qui, la colonna si appoggia in cima, quel
    // riempimento diventa vuoto sotto di lei, e la coda del testo cade
    // esattamente dove ci sono i pulsanti. Il riempimento non spinge niente
    // verso l'alto: e' spazio dentro, non spazio tolto.
    //
    // Adesso si toglie PRIMA, cioe' dall'altezza in cui la vista puo'
    // disporsi: quello che resta e' area libera davvero, e cio' che ci sta
    // dentro non puo' finire sotto niente. Lo scorrimento resta per gli
    // schermi in cui nemmeno cosi' ci sta.
    return Padding(
      padding: EdgeInsets.only(bottom: spazioInFondo),
      child: LayoutBuilder(
        builder: (context, vincoli) {
          // **A CEDERE E' IL BUSTO, NON IL TESTO.** Seconda meta' della voce
          // CI.01: tolto il compositore dalla viewport la sovrapposizione
          // spariva, ma alla scala massima il benvenuto usciva TAGLIATO, e
          // l'ordine chiede che ogni testo si legga per intero.
          //
          // Il busto ha un'altezza canonica di 300 punti, che e' giusta
          // quando c'e' posto. Quando non c'e', la scelta e' fra
          // rimpicciolire una figura e nascondere una frase: si rimpicciolisce
          // la figura, perche' la frase e' la prima cosa che il Maestro dice
          // e la figura si vede comunque.
          //
          // Il saluto si MISURA con lo stesso stile e lo stesso scaler con
          // cui verra' dipinto: chiedere l'altezza a un numero scritto a mano
          // vorrebbe dire indovinarla, e la scala di sistema la cambia.
          final larghezza = vincoli.maxWidth - SpacingTokens.lg * 2;
          final pittore = TextPainter(
            text: TextSpan(text: greeting, style: _stileDelSaluto),
            textDirection: Directionality.of(context),
            textAlign: TextAlign.center,
            textScaler: MediaQuery.textScalerOf(context),
          )..layout(maxWidth: larghezza > 0 ? larghezza : 1);
          final libero = vincoli.maxHeight -
              SpacingTokens.lg * 2 -
              SpacingTokens.md -
              pittore.height;
          final altezzaBusto = libero.clamp(
              altezzaMinimaDelBusto, BustoDelMaestro.altezzaCanonica);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(SpacingTokens.lg),
            child: Column(
              children: [
                // IL BUSTO DALLA PORTA UNICA, ordine I voce 1, alla grandezza
                // canonica della Stesa: la figura intera in alto non esiste piu'.
                // La misura 220 del 2164 apparteneva alla figura intera; il busto
                // canonico e' piu' alto ma ritagliato, e il benvenuto resta il
                // primo testo sotto di lui.
                BustoDelMaestro(maestro: maestro, height: altezzaBusto),
                const SizedBox(height: SpacingTokens.md),
                Text(
                  greeting,
                  key: const Key('chat_benvenuto'),
                  textAlign: TextAlign.center,
                  // AL PRIMARIO, ordine 2163 voce 9: il benvenuto era grigio
                  // (textSecondary) sul fondale scuro, la prima cosa che si legge
                  // ed era la meno leggibile. Il minimo dichiarato per il testo
                  // d'apertura e' 7 di contrasto, misurato dalla prova.
                  style: _stileDelSaluto,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// **LO STILE DEL SALUTO, IN UN PUNTO SOLO.**
  ///
  /// Serve due volte: per misurare quanto sara' alto e per dipingerlo. Due
  /// copie dello stesso stile sono due stili che un giorno divergono, e in
  /// quel giorno la misura direbbe un'altezza che il testo non ha.
  ///
  /// AL PRIMARIO, ordine 2163 voce 9: il benvenuto era grigio
  /// (textSecondary) sul fondale scuro, la prima cosa che si legge ed era la
  /// meno leggibile. Il minimo dichiarato per il testo d'apertura e' 7 di
  /// contrasto, misurato dalla prova.
  static TextStyle get _stileDelSaluto => TypographyTokens.body(size: 18)
      .copyWith(color: ColorTokens.textPrimary, height: 1.5);

  /// **QUANTO PICCOLO PUO' DIVENTARE IL BUSTO**, dichiarato invece che
  /// lasciato al caso. Sotto questa misura non e' piu' un ritratto, e' una
  /// macchia: meglio far scorrere la vista, che e' quello che succede quando
  /// nemmeno cosi' ci sta.
  static const double altezzaMinimaDelBusto = 160;
}
