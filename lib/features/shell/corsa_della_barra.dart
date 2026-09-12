import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// QUANTO LA BARRA E' SCESA, per chi le sta appoggiato sopra.
///
/// **Il fatto che l'ha fatta nascere**, ordine CI voce 03. Quando la barra si
/// ritira, il campo di scrittura della chat resta dov'era e sotto di lui si
/// apre una fascia vuota alta quanto la barra: a schermo il campo sembra
/// sospeso a mezz'aria. Il fondatore lo ha visto e lo ha segnalato.
///
/// **Perche' quella fascia esiste, ed era voluta.** Regola del 6 agosto 2026:
/// lo spazio riservato al contenuto e' COSTANTE e non segue il movimento della
/// barra. Prima commutava fra zero e l'altezza piena a meta' corsa, e
/// commutare uno spazio vuol dire RILAYARE cio' che ci sta dentro: misurato
/// sull'app montata, la carta del Maestro centrale cresceva di 66,42 punti e
/// saliva di 80,36 in un fotogramma solo, e in chat il campo di scrittura
/// saltava di 123. Il compromesso fu dichiarato allora, con le parole "se non
/// piacera' si decidera' guardandola": il fondatore adesso l'ha guardata.
///
/// **La via d'uscita non e' tornare indietro.** Lo spazio riservato resta
/// costante, quindi nessun rilayout e nessuno scatto. Cambia solo DOVE si
/// dipinge il campo: segue la barra con la stessa traslazione, che avviene in
/// fase di disegno e non tocca la disposizione di niente. Cosi' valgono tutte
/// e due le cose che l'ordine chiede: il campo sta in fondo alla schermata, e
/// l'apertura o la chiusura della barra non sposta nulla di cio' che sta
/// sotto, perche' sotto non c'e' piu' niente da spostare.
///
/// **Il valore e' la corsa BERSAGLIO, non quella dipinta**, ed e' voluto: chi
/// ascolta anima con la stessa durata e la stessa curva della barra, cosi' i
/// due si muovono insieme invece di inseguirsi.
@immutable
class CorsaDellaBarra extends InheritedNotifier<ValueNotifier<CorsaBersaglio>> {
  const CorsaDellaBarra({
    super.key,
    required ValueNotifier<CorsaBersaglio> super.notifier,
    required super.child,
  });

  /// La corsa da ascoltare. Quando sopra non c'e' nessuna barra, per esempio
  /// nelle prove che montano una schermata da sola, torna una corsa ferma a
  /// zero: chi ascolta non deve sapere se la barra c'e'.
  static ValueListenable<CorsaBersaglio> di(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CorsaDellaBarra>()?.notifier ??
      _ferma;

  static final ValueNotifier<CorsaBersaglio> _ferma =
      ValueNotifier<CorsaBersaglio>(const CorsaBersaglio());
}

/// Dove sta andando la barra, e se ci sta andando per un tocco.
@immutable
class CorsaBersaglio {
  const CorsaBersaglio({this.discesa = 0, this.perUnTocco = false});

  /// Quanti punti la barra e' scesa. Zero quando e' in vista.
  final double discesa;

  /// Vero quando il movimento nasce da un tocco e va animato, falso quando
  /// segue il dito e deve essere immediato.
  final bool perUnTocco;

  @override
  bool operator ==(Object other) =>
      other is CorsaBersaglio &&
      other.discesa == discesa &&
      other.perUnTocco == perUnTocco;

  @override
  int get hashCode => Object.hash(discesa, perUnTocco);
}
