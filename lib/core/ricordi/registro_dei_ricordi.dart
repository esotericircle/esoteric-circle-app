/// L'INDICE LEGGERO DEI RICORDI. Ordine CG voce 03.
///
/// **Il fatto che lo motiva, col numero.** Ogni turno di chat e' gia' un
/// documento Firestore sotto `users/{uid}/maestri/{maestroId}/messages`. Un
/// Adepto che usa meta' del suo tetto fa circa cinquanta voci al giorno, cioe'
/// millecinquecento al mese: leggere un mese di timeline documento per
/// documento costerebbe millecinquecento letture ogni volta che qualcuno apre
/// la schermata. Con l'indice ne costa UNA.
///
/// **Dove vive sul server, e perche' li'.** Un documento per persona e per
/// mese, in `users/{uid}/ricordi/{AAAA-MM}`. Sta sotto l'utente perche' la
/// cancellazione del Cerchio porta via l'albero intero e non deve ricordarsi
/// di passare anche di qua; e' diviso per mese perche' il mese e' l'unita' che
/// la timeline chiede, quindi aprire un mese e' leggere un documento e
/// scorrere dodici mesi e' leggerne dodici.
///
/// **Perche' una MAPPA e non una lista, cioe' i due apparecchi.** Se le righe
/// del mese fossero una lista, il telefono e il tablet che sincronizzano lo
/// stesso mese si cancellerebbero a vicenda: l'ultimo che scrive vince e le
/// righe dell'altro spariscono. Qui il documento e' una mappa da
/// [VoceDelRicordo.chiave] alla riga, si scrive con `merge`, e i due
/// apparecchi si SOMMANO. La chiave e' deterministica, quindi la stessa voce
/// mandata due volte resta una riga sola.
///
/// **Cosa succede se una sincronia salta.** Niente si perde. Il registro non
/// tiene "l'ultimo giorno mandato" ma l'ELENCO DEI MESI SPORCHI, cioe' quelli
/// toccati da quando l'ultima sincronia e' riuscita. Un telefono spento per
/// una settimana, o un errore di rete, lasciano il mese nell'elenco: alla
/// prima sincronia riuscita parte tutto quello che manca, e il costo resta
/// una scrittura per mese sporco invece che una al giorno.
///
/// **La sincronia e' UNA AL GIORNO, e il numero e' il motivo.** Aggiornare il
/// documento del mese a ogni voce sarebbe una scrittura in piu' per voce,
/// cioe' cinquanta al giorno per persona. A 0,09 dollari ogni centomila
/// scritture, un milione di persone farebbero cinquanta milioni di scritture
/// al giorno, cioe' circa 1.350 dollari al mese. Una sincronia al giorno ne fa
/// una per persona, cioe' trenta milioni al mese, cioe' circa 27 dollari.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../tempo/confine_del_giorno.dart';
import 'voce_del_ricordo.dart';

/// Chi porta le righe al server. Iniettabile, cosi' le prove contano le
/// scritture senza toccare la rete.
abstract class PortaDeiRicordi {
  const PortaDeiRicordi();

  /// Manda le righe di UN mese. Torna vero se il server le ha prese.
  Future<bool> manda(String mese, List<VoceDelRicordo> righe);

  /// Rilegge un mese dal server. Vuoto quando non c'e' niente.
  Future<List<VoceDelRicordo>> leggi(String mese);

  /// I MOVIMENTI DEGLI EOS COME LI TIENE IL SERVER, ordine CG voce 10.
  ///
  /// **Perche' non bastano gli otto del telefono.** `RegistroDegliEos` ne
  /// tiene otto, che e' la misura giusta per il borsellino, dove servono gli
  /// ULTIMI movimenti. Nei Ricordi la domanda e' un'altra, cioe' quanti Eos
  /// hai guadagnato in quel mese, e a quella otto righe non rispondono. Il
  /// server li tiene due anni, che e' lo stesso orizzonte dell'indice.
  Future<List<MovimentoDelRicordo>> movimenti() async => const [];
}

/// Un movimento di Eos come arriva dal server: quanti, quando, e perche'.
class MovimentoDelRicordo {
  const MovimentoDelRicordo({
    required this.quanti,
    required this.quando,
    required this.causale,
    required this.motivo,
  });

  final int quanti;
  final DateTime quando;
  final String causale;
  final String motivo;

  static MovimentoDelRicordo? daMappa(Object? grezzo) {
    if (grezzo is! Map) return null;
    final quanti = grezzo['quanti'];
    final quando = DateTime.tryParse('${grezzo['quando']}');
    if (quanti is! int || quando == null) return null;
    return MovimentoDelRicordo(
      quanti: quanti,
      quando: quando,
      causale: '${grezzo['causale'] ?? ''}',
      motivo: '${grezzo['motivo'] ?? ''}',
    );
  }
}

/// La porta spenta: non manda niente e non legge niente.
class PortaSpentaDeiRicordi extends PortaDeiRicordi {
  const PortaSpentaDeiRicordi();

  @override
  Future<bool> manda(String mese, List<VoceDelRicordo> righe) async => false;

  @override
  Future<List<VoceDelRicordo>> leggi(String mese) async => const [];
}

/// Il registro dei Ricordi sul telefono.
class RegistroDeiRicordi extends ChangeNotifier {
  RegistroDeiRicordi({
    DateTime Function()? orologio,
    PortaDeiRicordi porta = const PortaSpentaDeiRicordi(),
  })  : _orologio = orologio ?? DateTime.now,
        _porta = porta;

  final DateTime Function() _orologio;
  final PortaDeiRicordi _porta;

  /// **IL PREFISSO E' UNO SOLO, `ricordi.`**, ed e' quello che va in
  /// `CioCheETuo`: un dato che la cancellazione non conosce e' un dato che
  /// sopravvive a chi ha chiesto di sparire.
  static const String prefisso = 'ricordi.';
  static String _chiaveDelMese(String mese) => 'ricordi.voci.$mese';
  static const String _kMesiSporchi = 'ricordi.mesiSporchi';
  static const String _kUltimaSincronia = 'ricordi.ultimaSincronia';

  /// QUANTI MESI SI TENGONO SUL TELEFONO.
  ///
  /// **Dodici, e il numero viene dalla schermata.** La timeline apre sull'anno
  /// e mostra dodici caselle: tenere dodici mesi vuol dire che aprire l'anno
  /// intero non costa NESSUNA lettura, che e' la misura di accettazione
  /// dell'ordine. I mesi piu' vecchi restano sul server e si rileggono uno per
  /// uno quando qualcuno scende indietro, che e' un gesto raro e volontario.
  static const int quantiMesiSulTelefono = 12;

  final Map<String, Map<String, VoceDelRicordo>> _perMese = {};
  final Set<String> _mesiSporchi = {};
  String _ultimaSincronia = '';

  bool _caricato = false;
  bool get caricato => _caricato;

  /// QUANTE SCRITTURE VERSO IL SERVER sono partite da questo registro.
  ///
  /// Non e' una statistica: e' la grandezza che la prova del rosso misura. Una
  /// giornata da cinquanta voci deve muovere questo numero di UNO.
  int scrittureVersoIlServer = 0;

  /// QUANTE LETTURE dal server sono partite da questo registro.
  int lettureDalServer = 0;

  List<VoceDelRicordo> vociDelMese(String mese) {
    final dentro = _perMese[mese];
    if (dentro == null) return const [];
    final righe = dentro.values.toList()
      ..sort((a, b) => a.quando.compareTo(b.quando));
    return List.unmodifiable(righe);
  }

  /// I mesi che il telefono conosce, dal piu' recente al piu' vecchio.
  List<String> get mesiConosciuti {
    final chiavi = _perMese.keys.toList()..sort();
    return List.unmodifiable(chiavi.reversed);
  }

  /// Tutte le righe che il telefono conosce, in ordine di tempo.
  List<VoceDelRicordo> get tutte {
    final righe = <VoceDelRicordo>[];
    for (final dentro in _perMese.values) {
      righe.addAll(dentro.values);
    }
    righe.sort((a, b) => a.quando.compareTo(b.quando));
    return List.unmodifiable(righe);
  }

  Future<void> carica() async {
    if (_caricato) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _ultimaSincronia = prefs.getString(_kUltimaSincronia) ?? '';
      final sporchi = prefs.getStringList(_kMesiSporchi) ?? const [];
      _mesiSporchi.addAll(sporchi);
      for (final chiave in prefs.getKeys()) {
        if (!chiave.startsWith('ricordi.voci.')) continue;
        final mese = chiave.substring('ricordi.voci.'.length);
        _leggiIlMese(mese, prefs.getString(chiave));
      }
    } catch (errore) {
      // Un indice illeggibile vale come indice vuoto, che e' la regola di casa
      // sulle chiavi del telefono: non si spegne una schermata per una chiave.
      debugPrint('Ricordi: indice illeggibile, si riparte vuoti. $errore');
    }
    _caricato = true;
    notifyListeners();
  }

  void _leggiIlMese(String mese, String? grezzo) {
    if (grezzo == null) return;
    try {
      final letto = jsonDecode(grezzo);
      if (letto is! Map) return;
      final dentro = _perMese.putIfAbsent(mese, () => {});
      for (final voce in letto.entries) {
        final riga = VoceDelRicordo.daMappa(voce.value);
        if (riga != null) dentro[voce.key.toString()] = riga;
      }
    } catch (errore) {
      debugPrint('Ricordi: il mese $mese non si legge. $errore');
    }
  }

  /// SEGNA UNA VOCE. E' l'unica porta di scrittura.
  ///
  /// **Non manda niente al server**: scrive sul telefono e marca il mese come
  /// sporco. La rete la tocca solo [sincronizza].
  Future<void> segna(VoceDelRicordo voce) async {
    final mese = voce.mese;
    final dentro = _perMese.putIfAbsent(mese, () => {});
    dentro[voce.chiave] = voce;
    _mesiSporchi.add(mese);
    _potaIMesiVecchi();
    notifyListeners();
    await _salva(mese);
  }

  void _potaIMesiVecchi() {
    if (_perMese.length <= quantiMesiSulTelefono) return;
    final chiavi = _perMese.keys.toList()..sort();
    // **NON SI POTA UN MESE SPORCO.** Buttare via un mese che non e' ancora
    // arrivato al server vorrebbe dire perderlo per sempre: la potatura serve
    // a non far crescere il telefono, non a cancellare cio' che non e' salvo.
    while (_perMese.length > quantiMesiSulTelefono && chiavi.isNotEmpty) {
      final piuVecchio = chiavi.removeAt(0);
      if (_mesiSporchi.contains(piuVecchio)) continue;
      _perMese.remove(piuVecchio);
    }
  }

  Future<void> _salva(String mese) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dentro = _perMese[mese] ?? const {};
      await prefs.setString(
        _chiaveDelMese(mese),
        jsonEncode({for (final e in dentro.entries) e.key: e.value.aMappa()}),
      );
      await prefs.setStringList(_kMesiSporchi, _mesiSporchi.toList());
    } catch (errore) {
      debugPrint('Ricordi: il mese $mese non si salva. $errore');
    }
  }

  /// VERO SE OGGI LA SINCRONIA E' GIA' STATA FATTA.
  bool get giaSincronizzatoOggi =>
      _ultimaSincronia == ConfineDelGiorno.chiaveDi(_orologio());

  /// LA SINCRONIA, UNA AL GIORNO.
  ///
  /// Torna quante scritture ha fatto. Zero quando non c'era niente da mandare
  /// o quando oggi era gia' stata fatta.
  Future<int> sincronizza({bool forza = false}) async {
    if (!forza && giaSincronizzatoOggi) return 0;
    if (_mesiSporchi.isEmpty) {
      await _segnaLaSincronia();
      return 0;
    }
    var fatte = 0;
    // Copia, perche' una sincronia riuscita toglie dal vivo.
    for (final mese in _mesiSporchi.toList()) {
      final righe = vociDelMese(mese);
      if (righe.isEmpty) {
        _mesiSporchi.remove(mese);
        continue;
      }
      final preso = await _porta.manda(mese, righe);
      scrittureVersoIlServer++;
      fatte++;
      // **UN MESE ESCE DALLO SPORCO SOLO SE IL SERVER LO HA PRESO.** Toglierlo
      // comunque vorrebbe dire perdere quel mese al primo errore di rete.
      if (preso) _mesiSporchi.remove(mese);
    }
    await _segnaLaSincronia();
    return fatte;
  }

  Future<void> _segnaLaSincronia() async {
    _ultimaSincronia = ConfineDelGiorno.chiaveDi(_orologio());
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kUltimaSincronia, _ultimaSincronia);
      await prefs.setStringList(_kMesiSporchi, _mesiSporchi.toList());
    } catch (errore) {
      debugPrint('Ricordi: la sincronia non si segna. $errore');
    }
  }

  /// RIPESCA UN MESE VECCHIO DAL SERVER, e conta la lettura.
  ///
  /// Si chiama solo quando qualcuno scende indietro oltre i dodici mesi che il
  /// telefono tiene. Un mese gia' conosciuto NON si rilegge: sarebbe una
  /// lettura pagata per un dato che c'e' gia'.
  Future<void> ripesca(String mese) async {
    if (_perMese.containsKey(mese)) return;
    final righe = await _porta.leggi(mese);
    lettureDalServer++;
    if (righe.isEmpty) {
      // Si segna comunque il mese, vuoto, cosi' non lo si rilegge ogni volta
      // che l'occhio ci passa sopra.
      _perMese[mese] = {};
      notifyListeners();
      return;
    }
    _perMese[mese] = {for (final r in righe) r.chiave: r};
    notifyListeners();
  }

  /// Dimentica tutto, per la cancellazione del Cerchio e per le prove.
  void dimentica() {
    _perMese.clear();
    _mesiSporchi.clear();
    _ultimaSincronia = '';
    scrittureVersoIlServer = 0;
    lettureDalServer = 0;
    notifyListeners();
  }
}
