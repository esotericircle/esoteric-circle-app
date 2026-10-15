import 'package:flutter/material.dart';

import '../../../../core/maestro/maestro.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';

/// Apertura della chat prima del primo messaggio: IL SOLO BENVENUTO.
///
/// ORDINE 2164, VOCI 3 E 4. Qui vivevano due altre porte ai suggerimenti: il
/// pulsante "Tocca per tutte le domande" e la riga orizzontale di tre domande
/// d'assaggio. Parole di Mauro: bolle inutili e ripetitive, e il pulsante e'
/// una ripetizione dell'icona a stelline accanto al campo. Sono state TOLTE,
/// non nascoste: **resta una porta sola ai suggerimenti, l'icona a stelline**,
/// e una prova enumerante conta quella porta e cade se qualcuno ne riapre una
/// seconda.
///
/// **LA FIGURA NON STA PIU' QUI, ordine FW, 15 ottobre 2026.** Fino a
/// quest'ordine la chat vuota portava il busto del Maestro (o la sua scena
/// in video, FW.04) sopra il saluto, dentro un riquadro. Il fondatore, lo
/// stesso giorno: *"E' inaccettabile il riquadro in mezzo alla schermata con
/// il maestro. [...] Il video deve essere a tutto schermo"*. La figura e'
/// salita a sfondo di tutta la schermata (`MaestroChatScreen._SfondoDellaChat`),
/// non piu' un riquadro dentro il contenuto: questa classe mostra solo il
/// saluto, ancorato in basso sopra il compositore, leggibile grazie al velo
/// che lo sfondo porta con se'.
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
          // **LO SCORRIMENTO COPRE TUTTA L'ALTEZZA, NON SOLO IL TESTO.**
          // Ordine FW, 15 ottobre 2026: tolta la figura, il saluto da solo e'
          // corto, e un `SingleChildScrollView` si stringe al suo contenuto.
          // La zona che risponde al gesto "il dito scende, la barra compare"
          // (ordine EJ voce 09) si stringeva con lui, lasciando la meta' alta
          // dello schermo, adesso la scena a tutto schermo, senza risposta al
          // trascinamento: misurato da
          // test/la_barra_e_la_pastiglia_della_chat_test.dart dopo la scena a
          // tutto schermo, la barra non compariva piu' scorrendo. Il
          // `ConstrainedBox` sotto forza lo scorrimento a occupare l'intera
          // altezza disponibile, con il saluto ancorato in basso dentro di
          // lei: stesso aspetto, zona trascinabile intera.
          final altezza = vincoli.maxHeight.isFinite ? vincoli.maxHeight : 0.0;
          return SingleChildScrollView(
            // **SCORRE ANCHE QUANDO CI STA TUTTO. Ordine EJ voce 09**: nella
            // chat la barra del Cerchio parte ritirata e compare col dito, e
            // una pagina che non scorre non manderebbe nessun gesto.
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(SpacingTokens.lg),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: (altezza - SpacingTokens.lg * 2).clamp(0, altezza),
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  greeting,
                  key: const Key('chat_benvenuto'),
                  textAlign: TextAlign.center,
                  // AL PRIMARIO, ordine 2163 voce 9: il benvenuto era grigio
                  // (textSecondary) sul fondale scuro, la prima cosa che si
                  // legge ed era la meno leggibile. Il minimo dichiarato per
                  // il testo d'apertura e' 7 di contrasto, misurato dalla
                  // prova.
                  style: _stileDelSaluto,
                ),
              ),
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
}
