import 'package:flutter/material.dart';

import '../tokens/color_tokens.dart';

/// IL PASSAGGIO DEL CERCHIO: una sola transizione, per ogni schermata.
/// Ordine CC voce 04.
///
/// **Rilievo del fondatore, 29 agosto 2026, verbatim:** "quando entro nella
/// funzionalità dei tarocchi c'è un flash bianco che introduce la schermata,
/// voglio che questo flash sia nero e che ci sia sempre ad ogni cambio
/// schermata. niente deve apparire di botto."
///
/// **Due cose in una: il colore e la copertura.** Il lampo bianco esisteva in
/// un punto solo, la stesa a tre carte, e nasceva dall'intro cinematografica
/// che finisce in bianco pieno: il velo copriva il taglio fra il video e
/// l'app. Il resto delle rotte non aveva nessuna transizione dichiarata e
/// prendeva quella di sistema, che su Android e' una salita dal basso e su iOS
/// uno scorrimento laterale: due comportamenti diversi, nessuno dei due
/// scelto.
///
/// **Perche' vive in un posto solo, e la prova enumera le rotte.** E' la
/// famiglia di difetti piu' numerosa di questo progetto, quella delle due
/// porte: due superfici che fanno la stessa cosa divergono al primo cambio.
/// Una rotta nuova che nasce con `MaterialPageRoute` non e' un errore che si
/// vede, e' una schermata che compare in un altro modo e nessuno se ne accorge
/// finche' non la guarda il fondatore.
///
/// **Rispetta Riduci Movimento**, e non saltando la transizione: chi ha tolto
/// il movimento non ha chiesto che le schermate compaiano di botto, ha chiesto
/// che non si muovano. Resta la dissolvenza, che non e' movimento, e sparisce
/// lo scorrimento.
abstract final class PassaggioDelCerchio {
  /// Quanto dura il passaggio, all'andata.
  ///
  /// **Duecentoventi millesimi**, che e' il tempo in cui l'occhio legge uno
  /// stacco come voluto invece che come un difetto: sotto i centocinquanta si
  /// legge come uno sfarfallio, sopra i trecento si aspetta.
  static const Duration durata = Duration(milliseconds: 220);

  /// Al ritorno si e' piu' rapidi: chi torna indietro sa gia' dove va.
  static const Duration durataIndietro = Duration(milliseconds: 160);

  /// Il nero del passaggio. E' il fondo piu' profondo del Cerchio, non un nero
  /// qualunque: cosi' il buio del passaggio e il buio delle schermate sono lo
  /// stesso colore.
  static const Color nero = ColorTokens.medoraDeepest;

  /// La rotta di una schermata, col passaggio del Cerchio.
  ///
  /// Sostituisce `MaterialPageRoute` in ogni punto dell'app. Chi ha bisogno di
  /// una rotta a schermo intero senza barra di sistema passa [fullscreenDialog]
  /// come faceva prima.
  static Route<T> rotta<T>(
    WidgetBuilder costruttore, {
    bool fullscreenDialog = false,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      fullscreenDialog: fullscreenDialog,
      transitionDuration: durata,
      reverseTransitionDuration: durataIndietro,
      opaque: true,
      barrierColor: nero,
      pageBuilder: (context, entra, esce) => costruttore(context),
      transitionsBuilder: (context, entra, esce, figlio) =>
          _VeloNero(entra: entra, esce: esce, child: figlio),
    );
  }
}

/// Il velo nero fra due schermate: la prima si spegne, la seconda si accende.
class _VeloNero extends StatelessWidget {
  const _VeloNero({
    required this.entra,
    required this.esce,
    required this.child,
  });

  final Animation<double> entra;
  final Animation<double> esce;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // **IL NERO STA SOTTO, SEMPRE.** Senza, nel mezzo del passaggio si vede
    // per un istante la schermata di prima attraverso quella nuova ancora
    // trasparente, ed e' proprio il "di botto" al contrario: due scene
    // sovrapposte.
    final scena = ColoredBox(
      color: PassaggioDelCerchio.nero,
      child: FadeTransition(
        opacity: CurvedAnimation(parent: entra, curve: Curves.easeOut),
        child: child,
      ),
    );
    if (MediaQuery.of(context).disableAnimations) {
      // Niente movimento: resta la dissolvenza, che non muove niente, e non si
      // aggiunge nessuno scorrimento.
      return scena;
    }
    // **UN RESPIRO, NON UNO SCORRIMENTO.** La schermata nuova nasce un
    // pochissimo piu' piccola e arriva alla sua misura: due punti su cento,
    // che si sentono e non si vedono. Uno scorrimento laterale racconterebbe
    // una pila di carte, e questa app non e' una pila di carte.
    return ScaleTransition(
      scale: Tween<double>(begin: 0.98, end: 1.0).animate(
        CurvedAnimation(parent: entra, curve: Curves.easeOutCubic),
      ),
      child: scena,
    );
  }
}
