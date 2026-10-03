/// L'ASCOLTATORE DI SCUOTIMENTO, UNO PER TUTTA L'APP.
///
/// **Perche' esiste questo file.** Quattro superfici ascoltavano lo
/// scuotimento ognuna per conto suo: la Stesa col suo `ShakeListener`,
/// l'Estrazione Rune, la Runa del Tramonto e il rito con la rivelazione,
/// tutte con la stessa soglia scritta quattro volte e tutte passando
/// `samplingPeriod` al sensore. Era la stessa porta sbagliata aperta quattro
/// volte: adesso chi vuole lo scuotimento passa da qui, e una prova enumera
/// i punti e cade se qualcuno fa da se'.
///
/// **Perche' NIENTE `samplingPeriod`.** Non e' una dimenticanza, e' la
/// lezione del giroscopio della Stesa, scritta in `stesa_senses.dart`: e'
/// proprio passare quel parametro a far chiamare al plugin il metodo di
/// configurazione, che su un telefono senza sensore fallisce con
/// un'eccezione ASINCRONA che nessun `try` attorno all'ascolto puo'
/// prendere. Senza il parametro la configurazione non parte, il ritmo di
/// serie basta per riconoscere un picco, e il telefono senza sensore resta
/// muto invece di crollare.
///
/// **Il ripiego tattile e' obbligatorio.** Questo ascoltatore non e' mai
/// l'unica strada: ogni superficie che lo usa tiene il suo gesto di tocco, e
/// quando [stato] dice che il sensore non c'e' lo dichiara a schermo.
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Cosa si sa del sensore: niente finche' non parla, vivo al primo evento,
/// assente se il canale nega l'ascolto.
enum StatoScuotimento { ignoto, vivo, assente }

class AscoltatoreScuotimento {
  AscoltatoreScuotimento({
    this.onScuotimento,
    this.soglia = sogliaDiScuotimento,
    DateTime Function()? orologio,
  }) : _orologio = orologio ?? DateTime.now;

  /// LA SOGLIA, E PERCHE' VALE PROPRIO 22 METRI AL SECONDO QUADRO.
  ///
  /// La gravita' pesa gia' 9,8 sul telefono fermo. Il maneggio ordinario,
  /// camminare, alzare il telefono, girarsi nel letto, resta sotto i 15.
  /// Uno scuotimento deliberato supera i 22, cioe' la gravita' piu' un
  /// impulso di oltre 1,2 g: e' il margine che separa il gesto voluto dal
  /// gesto della vita. Il numero non e' nuovo: e' in campo con la Stesa
  /// dalle build consegnate di agosto 2026, provato sul telefono di Mauro,
  /// e da li' non e' arrivata ne' una partenza accidentale ne' una mancata.
  /// Quella e' la misura sul campo che lo giustifica.
  static const double sogliaDiScuotimento = 22;

  /// L'ANTIRIMBALZO: due picchi entro questo tempo sono UN gesto. Uno
  /// scuotimento vero produce una raffica di campioni oltre soglia, e senza
  /// questa finestra ogni raffica sarebbe una raffica di gettate.
  static const Duration antirimbalzo = Duration(milliseconds: 900);

  /// Chi riceve il gesto. Mutabile perche' la superficie che INIETTA un
  /// ascoltatore nelle prove deve poterci agganciare il proprio passo.
  VoidCallback? onScuotimento;
  final double soglia;
  final DateTime Function() _orologio;

  StreamSubscription<AccelerometerEvent>? _sub;
  DateTime? _ultimo;

  /// Cosa si sa del sensore, osservabile: le superfici lo leggono per
  /// dichiarare il ripiego a schermo quando il sensore non c'e'.
  final ValueNotifier<StatoScuotimento> stato =
      ValueNotifier(StatoScuotimento.ignoto);

  /// Vero se l'ascolto e' in piedi.
  bool get attivo => _sub != null;

  void start() {
    if (_sub != null) return;
    try {
      // NIENTE samplingPeriod, e la ragione sta in testa al file.
      _sub = accelerometerEventStream().listen((e) {
        if (stato.value == StatoScuotimento.ignoto) {
          stato.value = StatoScuotimento.vivo;
        }
        provaCampione(e.x, e.y, e.z);
      }, onError: (_) {
        // Il canale nega l'ascolto: sensore assente, si dichiara.
        stato.value = StatoScuotimento.assente;
        _fermati();
      }, cancelOnError: true);
    } catch (errore) {
      // DICHIARATO: l'errore si ignora perche' significa una cosa sola,
      // nessun accelerometro su questo telefono. Il ripiego tattile della
      // superficie resta l'unica strada e lo stato lo dice a schermo.
      stato.value = StatoScuotimento.assente;
    }
  }

  /// Il passo della decisione: soglia piu' antirimbalzo. E' il cuore
  /// dell'ascoltatore, separato dal canale del sensore perche' le prove lo
  /// misurino coi numeri invece di simulare un accelerometro.
  @visibleForTesting
  void provaCampione(double x, double y, double z) {
    final m = math.sqrt(x * x + y * y + z * z);
    if (m < soglia) return;
    final ora = _orologio();
    if (_ultimo != null && ora.difference(_ultimo!) < antirimbalzo) return;
    _ultimo = ora;
    onScuotimento?.call();
  }

  void stop() => _fermati();

  void _fermati() {
    _sub?.cancel();
    _sub = null;
  }

  void dispose() {
    _fermati();
    stato.dispose();
  }
}
