import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// I momenti della stesa che hanno un suono e una vibrazione.
///
/// Sono pochi e scelti: la stesa e' un rito, non una macchina da gioco. Ogni
/// momento porta la sua intensita', cosi' il taglio si sente diverso dal flip.
enum MomentoSensoriale {
  /// Il taglio del mazzo: un colpo secco e breve.
  taglio,

  /// Il vortice del mescolamento: un fruscio lungo.
  mescolamento,

  /// La carta che si stacca e vola: un tocco leggero.
  volo,

  /// Il mezzo giro che scopre la carta: un battito netto.
  flip,

  /// L'aura elementale: un respiro, piu' pieno sui Maggiori.
  reveal;

  /// Il nome del file audio che questo momento suonerebbe.
  ///
  /// I file non sono ancora nel bundle: l'aggancio resta pronto e silenzioso,
  /// come l'innesto dei ritratti di Medora. Quando arriveranno bastera'
  /// passare un lettore vero a [SensiDellaStesa].
  String get suono => 'audio/stesa_$name.mp3';
}

/// Chi suona gli effetti della stesa.
///
/// Di suo non fa nulla: e' il posto dove innestare il lettore audio quando i
/// file esisteranno, senza toccare il resto della schermata. Finche' resta
/// questo, la stesa e' muta e non pesa un byte in piu'.
abstract class LettoreEffetti {
  const LettoreEffetti();

  Future<void> suona(MomentoSensoriale momento);
}

/// Il lettore che non suona niente, quello di adesso.
class LettoreSilenzioso extends LettoreEffetti {
  const LettoreSilenzioso();

  @override
  Future<void> suona(MomentoSensoriale momento) async {}
}

/// Suono e vibrazione della stesa, dietro un solo interruttore.
///
/// Il silenzio e' uno solo per tutti e due: chi zittisce l'app non si aspetta
/// di sentirla ancora vibrare in mano. Se il dispositivo non ha motore aptico
/// non succede nulla di male, la chiamata cade nel vuoto senza errore.
///
/// Nota onesta sul silenzioso di sistema: senza un pacchetto dedicato l'app non
/// puo' leggere l'interruttore fisico del telefono. [sistemaSilenzioso] esiste
/// per riceverlo quando ci sara' un modo, e intanto la garanzia per chi legge
/// e' l'interruttore dell'app, che governa tutto.
class SensiDellaStesa {
  SensiDellaStesa({
    this.lettore = const LettoreSilenzioso(),
    this.silenzio = false,
    this.sistemaSilenzioso = false,
  });

  final LettoreEffetti lettore;

  /// L'interruttore dell'app: governa suono e vibrazione insieme.
  bool silenzio;

  /// Il silenzioso del telefono, quando si sapra' leggerlo.
  bool sistemaSilenzioso;

  /// Vero quando non deve uscire nulla, ne' suono ne' vibrazione.
  bool get muto => silenzio || sistemaSilenzioso;

  /// I momenti passati di qui, per i test.
  @visibleForTesting
  final List<MomentoSensoriale> eseguiti = [];

  /// Fa sentire un momento, se non siamo in silenzio.
  Future<void> momento(MomentoSensoriale m, {bool solenne = false}) async {
    if (muto) return;
    eseguiti.add(m);
    _vibra(m, solenne: solenne);
    await lettore.suona(m);
  }

  /// La vibrazione a tema col gesto, discreta.
  void _vibra(MomentoSensoriale m, {required bool solenne}) {
    try {
      switch (m) {
        case MomentoSensoriale.taglio:
          HapticFeedback.mediumImpact();
        case MomentoSensoriale.mescolamento:
          HapticFeedback.lightImpact();
        case MomentoSensoriale.volo:
          HapticFeedback.selectionClick();
        case MomentoSensoriale.flip:
          HapticFeedback.mediumImpact();
        case MomentoSensoriale.reveal:
          // La fioritura dei Maggiori si sente di piu'.
          solenne
              ? HapticFeedback.heavyImpact()
              : HapticFeedback.lightImpact();
      }
    } catch (_) {
      // Nessun motore aptico: il rito continua lo stesso.
    }
  }
}

/// L'inclinazione delle carte posate, letta dal giroscopio.
///
/// Le tre carte gia' scelte fluttuano piano e si inclinano come se fossero
/// sospese davanti a chi guarda. E' un effetto di superficie: non tocca il
/// testo, non tocca il pescaggio, e se il sensore manca o il permesso non c'e'
/// le carte restano ferme e composte, senza un errore e senza insistere.
class TiltListener extends ChangeNotifier {
  TiltListener({this.massimo = 0.06});

  /// L'inclinazione massima, in radianti: appena percepibile.
  final double massimo;

  StreamSubscription<GyroscopeEvent>? _sub;

  double _x = 0;
  double _y = 0;

  /// L'inclinazione corrente sui due assi, gia' limitata.
  double get x => _x;
  double get y => _y;

  /// Vero se il sensore sta davvero mandando dati.
  ///
  /// Falso vuol dire ripiego statico: nessun errore, nessun avviso, le carte
  /// stanno ferme.
  bool get attivo => _sub != null;

  void start() {
    if (_sub != null) return;
    try {
      // Senza `samplingPeriod` il plugin non chiama il metodo di
      // configurazione, che su un dispositivo senza giroscopio fallisce con
      // un'eccezione asincrona che sfuggirebbe a questo try. Il ritmo di
      // default va benissimo per un'inclinazione di superficie.
      _sub = gyroscopeEventStream().listen((e) {
        // Si integra piano e si riporta verso il centro, altrimenti la carta
        // deriverebbe via a ogni movimento.
        _x = ((_x + e.y * 0.012) * 0.92).clamp(-massimo, massimo);
        _y = ((_y - e.x * 0.012) * 0.92).clamp(-massimo, massimo);
        notifyListeners();
      }, onError: (_) {
        // Il permesso di movimento non c'e': si passa al fermo, in silenzio.
        _fermati();
      }, cancelOnError: true);
    } catch (_) {
      // Nessun giroscopio: ripiego statico.
      _fermati();
    }
  }

  void _fermati() {
    _sub?.cancel();
    _sub = null;
    _x = 0;
    _y = 0;
    notifyListeners();
  }

  /// Il galleggiamento lento, che c'e' anche senza sensore quando il moto e'
  /// concesso: le carte respirano appena.
  static double fluttuazioneDi(int indice, double t) =>
      math.sin(t * 2 * math.pi + indice * 1.1) * 2.2;

  @override
  void dispose() {
    _sub?.cancel();
    _sub = null;
    super.dispose();
  }
}
