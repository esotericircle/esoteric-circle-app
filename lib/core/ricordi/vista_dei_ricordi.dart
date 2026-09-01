/// LA VISTA DEI RICORDI: quattro livelli, la ricerca e i filtri.
/// Ordine CG voci 02, 05 e 07.
///
/// **Perche' un oggetto e non la schermata.** I quattro livelli, la ricerca e
/// le pastiglie sono LOGICA, e una logica dentro un widget si prova solo
/// montando una schermata: la misura "aprire un livello costa zero letture"
/// diventerebbe una misura sul disegno invece che sul conto. Qui si prova il
/// conto, e la schermata mostra cio' che questo oggetto dice.
///
/// **Nessuna chiamata all'AI nasce da qui**, a nessun livello: una prova
/// enumera i punti che costruiscono un riassunto e cade se uno di loro chiama
/// il provider del modello.
library;

import 'package:flutter/foundation.dart';

import 'registro_dei_ricordi.dart';
import 'riassunti_del_tempo.dart';
import 'voce_del_ricordo.dart';

/// A che livello si sta guardando.
enum LivelloDeiRicordi { anno, mese, settimana, giorno }

/// Le pastiglie che filtrano. **Si SOMMANO, non aprono schermate.**
enum FiltroDeiRicordi {
  medora,
  aura,
  caligo,
  conversazioni,
  custoditi,
  arti,
}

class VistaDeiRicordi extends ChangeNotifier {
  VistaDeiRicordi({
    required RegistroDeiRicordi registro,
    Set<String> gestiDeiDoni = const {},
    DateTime Function()? orologio,
  })  : _registro = registro,
        _gestiDeiDoni = gestiDeiDoni,
        _orologio = orologio ?? DateTime.now;

  final RegistroDeiRicordi _registro;
  final Set<String> _gestiDeiDoni;
  final DateTime Function() _orologio;

  LivelloDeiRicordi _livello = LivelloDeiRicordi.anno;
  LivelloDeiRicordi get livello => _livello;

  /// Dove si sta guardando: l'anno, poi il mese, poi la settimana, poi il
  /// giorno. Si tiene UNA data e non quattro chiavi, cosi' scendere e
  /// risalire non puo' perdere il filo.
  late DateTime _dove = _orologio();
  DateTime get dove => _dove;

  String _cercato = '';
  String get cercato => _cercato;

  final Set<FiltroDeiRicordi> _filtri = {};
  Set<FiltroDeiRicordi> get filtri => Set.unmodifiable(_filtri);

  /// **QUANTE VOCI HA LETTO L'ULTIMA COSTRUZIONE**, per le misure.
  int vociLette = 0;

  void scendiA(LivelloDeiRicordi livello, {DateTime? quando}) {
    _livello = livello;
    if (quando != null) _dove = quando;
    notifyListeners();
  }

  void cerca(String cosa) {
    _cercato = cosa.trim();
    notifyListeners();
  }

  void alterna(FiltroDeiRicordi filtro) {
    if (!_filtri.remove(filtro)) _filtri.add(filtro);
    notifyListeners();
  }

  /// **TUTTE LE VOCI, gia' filtrate e gia' cercate.**
  ///
  /// La ricerca lavora SULL'INDICE, cioe' sulle domande della persona e sui
  /// titoli dei responsi, e non dentro il corpo delle risposte: Firestore non
  /// sa cercare dentro un testo, e un motore esterno questo progetto non ce
  /// l'ha. **Si accetta invece di prometterlo**: nessuno cerca una parola in
  /// mezzo alla risposta di un Maestro, si cerca la propria domanda.
  List<VoceDelRicordo> get vociVisibili {
    final tutte = _registro.tutte;
    vociLette = tutte.length;
    final cercato = _cercato.toLowerCase();
    return [
      for (final v in tutte)
        if (_passaIFiltri(v) && (cercato.isEmpty || _combacia(v, cercato))) v,
    ];
  }

  bool _combacia(VoceDelRicordo v, String cercatoMinuscolo) =>
      v.titolo.toLowerCase().contains(cercatoMinuscolo) ||
      v.arte.toLowerCase().contains(cercatoMinuscolo);

  bool _passaIFiltri(VoceDelRicordo v) {
    if (_filtri.isEmpty) return true;
    // **I FILTRI SI SOMMANO PER FAMIGLIA, e si moltiplicano fra famiglie.**
    // Tre Maestri accesi vuol dire "uno qualunque dei tre", non "tutti e
    // tre"; un Maestro piu' i custoditi vuol dire "di quel Maestro E
    // custodito". Senza questa distinzione accendere due Maestri svuoterebbe
    // la schermata, che e' il contrario di quello che il gesto promette.
    final maestri = <String>{
      if (_filtri.contains(FiltroDeiRicordi.medora)) 'medora',
      if (_filtri.contains(FiltroDeiRicordi.aura)) 'aura',
      if (_filtri.contains(FiltroDeiRicordi.caligo)) 'caligo',
    };
    if (maestri.isNotEmpty && !maestri.contains(v.maestro)) return false;

    final tipi = <TipoDelRicordo>{
      if (_filtri.contains(FiltroDeiRicordi.conversazioni))
        TipoDelRicordo.conversazione,
      if (_filtri.contains(FiltroDeiRicordi.custoditi)) TipoDelRicordo.responso,
      if (_filtri.contains(FiltroDeiRicordi.arti)) TipoDelRicordo.gesto,
    };
    if (tipi.isNotEmpty && !tipi.contains(v.tipo)) return false;
    return true;
  }

  /// I DODICI MESI DELL'ANNO in cui si sta guardando, col loro riassunto.
  List<RiassuntoDelTempo> get iDodiciMesi {
    final visibili = vociVisibili;
    final fuori = <RiassuntoDelTempo>[];
    for (var m = 1; m <= 12; m++) {
      final chiave =
          '${_dove.year.toString().padLeft(4, '0')}-${m.toString().padLeft(2, '0')}';
      final dentro = [
        for (final v in visibili)
          if (v.mese == chiave) v,
      ];
      fuori.add(
          RiassuntiDelTempo.di(chiave, dentro, gestiDeiDoni: _gestiDeiDoni));
    }
    return List.unmodifiable(fuori);
  }

  /// LE SETTIMANE del mese in cui si sta guardando.
  List<RiassuntoDelTempo> get leSettimaneDelMese {
    final visibili = vociVisibili;
    final mese = VoceDelRicordo.chiaveDelMese(_dove);
    final delMese = [
      for (final v in visibili)
        if (v.mese == mese) v,
    ];
    final perSettimana = <String, List<VoceDelRicordo>>{};
    // Le settimane si costruiscono dal calendario e non dai dati: un mese
    // senza gesti deve mostrare le sue settimane vuote, non nessuna
    // settimana, altrimenti sembra un mese che non e' mai esistito.
    var giorno = DateTime(_dove.year, _dove.month, 1);
    while (giorno.month == _dove.month) {
      perSettimana.putIfAbsent(
          RiassuntiDelTempo.chiaveDellaSettimana(giorno), () => []);
      giorno = giorno.add(const Duration(days: 1));
    }
    for (final v in delMese) {
      final chiave = RiassuntiDelTempo.chiaveDellaSettimana(v.quando);
      perSettimana.putIfAbsent(chiave, () => []).add(v);
    }
    final chiavi = perSettimana.keys.toList()..sort();
    return List.unmodifiable([
      for (final c in chiavi)
        RiassuntiDelTempo.di(c, perSettimana[c]!, gestiDeiDoni: _gestiDeiDoni),
    ]);
  }

  /// I SETTE GIORNI della settimana in cui si sta guardando.
  List<RiassuntoDelTempo> get iGiorniDellaSettimana {
    final visibili = vociVisibili;
    final lunedi = RiassuntiDelTempo.lunediDi(_dove);
    return List.unmodifiable([
      for (var i = 0; i < 7; i++)
        () {
          final giorno = lunedi.add(Duration(days: i));
          final chiave = VoceDelRicordo.chiaveDelGiorno(giorno);
          return RiassuntiDelTempo.di(
              chiave,
              [
                for (final v in visibili)
                  if (v.giorno == chiave) v,
              ],
              gestiDeiDoni: _gestiDeiDoni);
        }(),
    ]);
  }

  /// IL RIASSUNTO DEL GIORNO in cui si sta guardando.
  RiassuntoDelTempo get ilGiorno {
    final chiave = VoceDelRicordo.chiaveDelGiorno(_dove);
    return RiassuntiDelTempo.di(
        chiave,
        [
          for (final v in vociVisibili)
            if (v.giorno == chiave) v,
        ],
        gestiDeiDoni: _gestiDeiDoni);
  }

  /// LE VOCI DEL GIORNO, gia' raggruppate come vanno mostrate.
  List<GruppoDelGiorno> get iGruppiDelGiorno {
    final chiave = VoceDelRicordo.chiaveDelGiorno(_dove);
    return RiassuntiDelTempo.gruppiDelGiorno([
      for (final v in vociVisibili)
        if (v.giorno == chiave) v,
    ]);
  }

  /// I RISULTATI DELLA RICERCA, in ordine dal piu' recente.
  ///
  /// **Non dipendono dal livello**: chi cerca vuole trovare, non vuole prima
  /// scendere nel mese giusto. E' la frase del fondatore, "l'utente deve
  /// trovare subito cio' che cerca".
  List<VoceDelRicordo> get risultati {
    if (_cercato.isEmpty) return const [];
    final trovate = vociVisibili.toList()
      ..sort((a, b) => b.quando.compareTo(a.quando));
    return List.unmodifiable(trovate);
  }
}
