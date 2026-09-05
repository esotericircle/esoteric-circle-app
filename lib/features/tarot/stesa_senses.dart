import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../core/sensi/palette_sensoriale.dart';
import '../../core/sensi/catalogo_suoni.dart';

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

  /// Il suono del Cerchio che questo momento richiama, quando ne ha uno.
  ///
  /// Qui viveva un SECONDO catalogo sonoro, con un file per ogni momento della
  /// stesa: cinque suoni tutti suoi, oltre ai cinque del Cerchio. Due cataloghi
  /// vogliono dire due identita' sonore, e il silenzio che rende importante un
  /// suono si perde se ogni gesto ne ha uno.
  ///
  /// Due momenti suonano: la carta che si gira e la carta scoperta.
  ///
  /// **`carta` e' arrivata con l'ordine CN**, e per un giorno e' stata
  /// nel catalogo senza che nessuno la suonasse: il file c'era, era
  /// normalizzato, aveva la sua riga nel registro delle misure, **e non
  /// usciva da nessuna parte**. Un suono che nessuno chiama e' un peso
  /// nell'archivio e un silenzio a schermo.
  ///
  /// Gli altri momenti restano affidati alla sola aptica, che e' il
  /// canale che arriva sempre.
  SuonoDelCerchio? get suono => switch (this) {
        MomentoSensoriale.flip => SuonoDelCerchio.carta,
        MomentoSensoriale.reveal => SuonoDelCerchio.rivelazione,
        _ => null,
      };
}

/// **QUI C'ERA UN'INTERCAPEDINE VUOTA, ed e' il motivo per cui la carta non
/// suonava.** Ordine CO voce 02, 3 settembre 2026.
///
/// C'erano un `LettoreEffetti` astratto e un `LettoreSilenzioso` che
/// implementava il nulla, col commento *"e' il posto dove innestare il lettore
/// audio quando i file esisteranno"*. I file sono arrivati con l'ordine CN, e
/// **nessuno e' passato di qui a innestare niente**: il costruttore continuava
/// a mettere di suo il lettore muto, e nessuno gliene passava mai un altro.
///
/// Il risultato e' la forma piu' silenziosa di difetto che questo progetto
/// abbia incontrato: la mappa che dice quale suono corrisponde alla carta
/// girata **veniva calcolata a ogni giro e buttata via**, un attimo dopo,
/// dentro un metodo che per contratto non fa niente. Tutto verde, tutto
/// leggibile, e muto.
///
/// Adesso non c'e' nessun lettore da innestare: **c'e' la porta unica del
/// Cerchio**, `PaletteSensoriale.suona`, la stessa da cui escono gli altri
/// dodici suoni. Un'intercapedine che aspetta un innesto e' un secondo modo di
/// suonare, e questo progetto ha gia' pagato caro ogni volta che una cosa
/// aveva due porte.

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
    this.silenzio = false,
    this.sistemaSilenzioso = false,
  });

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
  ///
  /// **Il contesto serve, e serve per una ragione sola**: la porta unica del
  /// Cerchio legge da li' l'interruttore del suono, quello che vale per tutta
  /// l'app. L'interruttore locale della stesa, [silenzio], sta sopra e non al
  /// posto suo: chi zittisce la stesa zittisce la stesa, chi zittisce l'app
  /// zittisce anche la stesa.
  /// **[conSuono] esiste per un difetto misurato, ordine CQ voce 6.08.**
  ///
  /// Il lettore degli effetti e' UNO SOLO e li suona uno alla volta: ogni
  /// effetto ferma quello prima. `_pesca` chiamava il flip e subito dopo la
  /// fioritura, che chiama il reveal, **nello stesso fotogramma**: la carta
  /// partiva e la rivelazione la stroncava a zero millesimi su settecento
  /// trenta. Il suono della carta non si e' mai sentito, da quando esiste.
  ///
  /// **La vibrazione resta comunque**: e' l'aptica a distinguere un Maggiore
  /// da un Minore, e quella non si contende niente.
  Future<void> momento(BuildContext context, MomentoSensoriale m,
      {bool solenne = false, bool conSuono = true}) async {
    if (muto) return;
    eseguiti.add(m);
    _vibra(m, solenne: solenne);
    if (!conSuono) return;
    final suono = m.suono;
    if (suono == null) return;
    // Il momento puo' arrivare da un'animazione conclusa dopo che la schermata
    // se ne e' andata: il contesto non si tocca se non c'e' piu'.
    if (!context.mounted) return;
    await PaletteSensoriale.suona(context, suono);
  }

  /// La vibrazione a tema col gesto, discreta.
  void _vibra(MomentoSensoriale m, {required bool solenne}) {
    try {
      // I momenti del rito ricondotti ai QUATTRO schemi della palette. Prima
      // ognuno sceglieva per conto proprio, con cinque intensita' diverse in
      // una schermata sola: il taglio vibrava come una conferma altrove, e il
      // volo come una selezione, senza che le due cose avessero niente in
      // comune. Adesso il vocabolario e' quello del Cerchio.
      switch (m) {
        case MomentoSensoriale.taglio:
          PaletteSensoriale.eseguiSchema(SchemaAptico.conferma);
        case MomentoSensoriale.mescolamento:
        case MomentoSensoriale.volo:
          PaletteSensoriale.eseguiSchema(SchemaAptico.tocco);
        case MomentoSensoriale.flip:
          PaletteSensoriale.eseguiSchema(SchemaAptico.conferma);
        case MomentoSensoriale.reveal:
          // La carta scoperta e' una rivelazione, solenne o no: la differenza
          // fra Maggiori e Minori la porta il suono, non un quinto schema.
          PaletteSensoriale.eseguiSchema(SchemaAptico.rivelazione);
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
