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

import 'dart:async';
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

  // **IL DIARIO COSMICO SUL SERVER. Ordine FE voce 22.** L'indice e il
  // contenuto stanno sul server, legati all'account; il telefono ne tiene
  // una copia di comodo. Le porte spente rispondono vuoto.

  /// Il riassunto di un anno: per mese i conteggi per etichetta, per giorno
  /// le stelle. Una lettura.
  Future<Map<String, Object?>?> leggiAnno(String anno) async => null;

  /// Annota un responso o una lettura coi suoi dati, senza gesti (FE.22.6).
  Future<bool> annota({
    required String chiave,
    required DateTime quando,
    required String tipo,
    required String arte,
    required String maestro,
    required String titolo,
    required Map<String, Object?> contenuto,
  }) async =>
      false;

  /// Mette o toglie la stella, con la riga della persona se c'e'.
  Future<bool> stella({
    required String chiave,
    required DateTime quando,
    required bool stella,
    String? nota,
  }) async =>
      false;

  /// Il contenuto di una voce, quando la persona la apre (FE.22.14).
  Future<Map<String, Object?>?> leggiVoce(String chiave) async => null;

  /// Le conversazioni e le voci di prima entrano nel Diario, una volta.
  Future<int> riempi() async => 0;
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
  static const String _kContenuti = 'ricordi.contenuti';

  /// **QUANTI CONTENUTI TIENE LA COPIA DI COMODO. Ordine FE voce 22.13.**
  /// Il contenuto vero sta sul server; il telefono tiene gli ultimi, quanti
  /// servono a ridisegnare la griglia delle carte senza una lettura per
  /// carta a ogni apertura. Un responso pesa sotto il chilobyte
  /// ([RicordoCustodito.pesoMassimo]): ottanta stanno sotto gli ottanta.
  static const int quantiContenutiSulTelefono = 80;

  /// QUANTI MESI SI TENGONO SUL TELEFONO.
  ///
  /// **Dodici, e il numero viene dalla schermata.** La timeline apre sull'anno
  /// e mostra dodici caselle: tenere dodici mesi vuol dire che aprire l'anno
  /// intero non costa NESSUNA lettura, che e' la misura di accettazione
  /// dell'ordine. I mesi piu' vecchi restano sul server e si rileggono uno per
  /// uno quando qualcuno scende indietro, che e' un gesto raro e volontario.
  static const int quantiMesiSulTelefono = 12;

  final Map<String, Map<String, VoceDelRicordo>> _perMese = {};

  /// La copia di comodo dei contenuti, nella forma del server
  /// (`{v, c, nota}`), dalla piu' vecchia alla piu' recente.
  final Map<String, Map<String, Object?>> _contenuti = {};
  final Set<String> _contenutiChiesti = {};
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
      final contenuti = prefs.getString(_kContenuti);
      if (contenuti != null) {
        final letti = jsonDecode(contenuti);
        if (letti is Map) {
          for (final e in letti.entries) {
            if (e.value is Map) {
              _contenuti['${e.key}'] = (e.value as Map).cast<String, Object?>();
            }
          }
        }
      }
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
    if (_mesiDalServer.contains(mese)) return;
    _mesiDalServer.add(mese);
    final righe = await _porta.leggi(mese);
    lettureDalServer++;
    // **UNA RISPOSTA VUOTA NON CANCELLA LA COPIA.** La porta risponde vuoto
    // anche quando la rete manca: sostituire la copia con niente vorrebbe
    // dire perdere il mese a ogni galleria senza campo.
    if (righe.isEmpty) return;
    // Il server e' la fonte: le sue righe vincono. Una voce che il telefono
    // ha e il server non ancora (annotata un attimo fa, con la chiamata in
    // viaggio) resta se e' di meno di un giorno; una piu' vecchia che il
    // server non ha e' stata tolta altrove, e se ne va anche qui.
    final adesso = _orologio();
    final prima = _perMese[mese] ?? const <String, VoceDelRicordo>{};
    _perMese[mese] = {
      for (final v in prima.values)
        if (adesso.difference(v.quando).inHours < 24) v.chiave: v,
      for (final r in righe) r.chiave: r,
    };
    await _salva(mese);
    notifyListeners();
  }

  /// **RILEGGE UN MESE SOLO SE LA COPIA NON BASTA.** Un mese che il
  /// telefono non ha si legge; uno che ha si rilegge solo quando il
  /// riassunto dell'anno, letto all'apertura del Diario, ne conta un numero
  /// diverso di voci (scritte da un altro telefono, o dal server). Con la
  /// copia giusta scendere nei livelli non costa nessuna lettura.
  Future<void> rileggiSeServe(String mese) async {
    if (_mesiDalServer.contains(mese)) return;
    final copia = _perMese[mese];
    if (copia != null && copia.isNotEmpty) {
      if (!haIlRiassunto(mese.substring(0, 4))) return;
      if (contoDelMese(mese, 'tutte') == copia.length) return;
    }
    await ripesca(mese);
  }

  // ---------------------------------------------------------------------
  // **IL DIARIO COSMICO, UNA PORTA SOLA. Ordine FE voce 22.**
  //
  // Prima di quest'ordine questo registro era la fonte: le righe nascevano
  // qui, sul telefono, e salivano al server una volta sola per
  // installazione. Le voci di settembre di Medora c'erano nel menu' della
  // chat, che leggeva i messaggi sul server, e non c'erano nel Diario
  // (catture del fondatore in docs/collaudo/FE/catture_del_fondatore/).
  // Adesso la fonte e' l'indice sul server, scritto dal server: questo
  // registro lo legge, ne tiene una copia di comodo, e il Diario e il
  // menu' della chat leggono da qui (FE.22.16).

  /// I mesi gia' letti dal server in questa sessione.
  final Set<String> _mesiDalServer = {};

  /// I riassunti degli anni: quelli letti dal server, con sopra i conti
  /// delle voci nate in questa sessione.
  final Map<String, Map<String, Object?>> _anni = {};

  /// **GLI ANNI LETTI DAL SERVER, a parte.** Visto sul Realme con la build
  /// 2299, il 6 ottobre 2026: il Diario filtrato su Aura segnava settembre
  /// a 0 mentre il menu' della chat mostrava due conversazioni di Aura del
  /// 26 e del 27 settembre. Una conversazione toccata prima di aprire il
  /// Diario contava nel riassunto (`_contaNelRiassunto`) e cosi' creava
  /// l'anno nella mappa coi soli conti di oggi: aprendo il Diario,
  /// [leggiLAnno] trovava l'anno e non leggeva il server. Padre: il commit
  /// bd64f246 (FE.22, il Diario sul telefono).
  final Set<String> _anniDalServer = {};

  /// **APRE IL DIARIO: due letture.** Il riassunto dell'anno e il mese
  /// corrente, con cento voci come con mille (FE.22.18). Gli altri mesi si
  /// leggono quando la persona li apre ([ripesca]).
  Future<void> apri() async {
    await carica();
    final adesso = _orologio();
    await leggiLAnno('${adesso.year}');
    await ripesca(VoceDelRicordo.chiaveDelMese(adesso));
  }

  /// Legge il riassunto di un anno, una volta per sessione.
  Future<void> leggiLAnno(String anno) async {
    if (_anniDalServer.contains(anno)) return;
    final letto = await _porta.leggiAnno(anno);
    lettureDalServer++;
    _anniDalServer.add(anno);
    // Il riassunto del server conta gia' le voci di questa sessione: le
    // scrive il server stesso, nella transazione della loro riga.
    _anni[anno] = letto ?? const {};
    notifyListeners();
  }

  /// Vero quando il mese `AAAA-MM` e' stato letto dal server.
  bool meseLetto(String mese) => _mesiDalServer.contains(mese);

  /// Vero quando il riassunto di quell'anno e' arrivato dal server.
  bool haIlRiassunto(String anno) =>
      _anniDalServer.contains(anno) &&
      ((_anni[anno]?['mesi'] as Map?)?.isNotEmpty ?? false);

  /// Quante voci con quell'etichetta ha il mese `AAAA-MM`, dal riassunto:
  /// "tutte", un Maestro, "conversazioni", "arti" o "stelle".
  int contoDelMese(String mese, String etichetta) {
    final mesi = _anni[mese.substring(0, 4)]?['mesi'];
    if (mesi is! Map) return 0;
    final conti = mesi[mese.substring(5, 7)];
    if (conti is! Map) return 0;
    final n = conti[etichetta];
    return n is num ? n.toInt() : 0;
  }

  /// **IL GIORNO EREDITA LA STELLA. Ordine FE voce 22.8.** Vero quando il
  /// giorno `AAAA-MM-GG` contiene almeno una voce con la stella.
  bool giornoConStella(String giorno) {
    final mesi = _perMese[giorno.substring(0, 7)];
    if (mesi != null && _mesiDalServer.contains(giorno.substring(0, 7))) {
      return mesi.values.any((v) => v.stella && v.giorno == giorno);
    }
    final stelle = _anni[giorno.substring(0, 4)]?['stelle'];
    if (stelle is! Map) return false;
    final n = stelle[giorno.substring(5)];
    return n is num && n > 0;
  }

  void _contaNelRiassunto(VoceDelRicordo v, List<String> etichette, int d) {
    final anno = '${v.quando.year}';
    final r = Map<String, Object?>.of(_anni[anno] ?? const {});
    final mesi = Map<String, Object?>.of((r['mesi'] as Map?)?.cast() ?? {});
    final mm = v.mese.substring(5, 7);
    final conti = Map<String, Object?>.of((mesi[mm] as Map?)?.cast() ?? {});
    for (final e in etichette) {
      final n = ((conti[e] as num?) ?? 0).toInt() + d;
      if (n <= 0) {
        conti.remove(e);
      } else {
        conti[e] = n;
      }
    }
    mesi[mm] = conti;
    r['mesi'] = mesi;
    if (etichette.contains('stelle')) {
      final stelle =
          Map<String, Object?>.of((r['stelle'] as Map?)?.cast() ?? {});
      final g = v.giorno.substring(5);
      final n = ((stelle[g] as num?) ?? 0).toInt() + d;
      if (n <= 0) {
        stelle.remove(g);
      } else {
        stelle[g] = n;
      }
      r['stelle'] = stelle;
    }
    _anni[anno] = r;
  }

  /// Le etichette di una voce, come le conta il server.
  static List<String> etichetteDi(VoceDelRicordo v) => [
        'tutte',
        switch (v.tipo) {
          TipoDelRicordo.conversazione => 'conversazioni',
          TipoDelRicordo.responso => 'responsi',
          _ => 'letture',
        },
        if (v.maestro.isNotEmpty) v.maestro,
        if (v.stella) 'stelle',
      ];

  /// **LA STELLA. Ordine FE voce 22.7**: un campo solo, dallo stesso posto
  /// sia dal pulsante "Segna nel Diario" sia dal Diario. Si vede subito e
  /// va al server; la riga della persona (FE.22.10) viaggia con lei.
  Future<bool> mettiLaStella(VoceDelRicordo voce, bool stella,
      {String? nota}) async {
    final dentro = _perMese.putIfAbsent(voce.mese, () => {});
    final prima = dentro[voce.chiave] ?? voce;
    if (prima.stella != stella) {
      _contaNelRiassunto(prima, const ['stelle'], stella ? 1 : -1);
    }
    dentro[voce.chiave] = prima.conStella(stella);
    final copia = _contenuti[voce.chiave];
    if (copia != null && nota != null) {
      _conserva(voce.chiave, {...copia, 'nota': nota});
    }
    notifyListeners();
    await _salva(voce.mese);
    scrittureVersoIlServer++;
    return _porta.stella(
        chiave: voce.chiave, quando: voce.quando, stella: stella, nota: nota);
  }

  /// **IL RESPONSO ENTRA NEL DIARIO DA SE'. Ordine FE voce 22.6 e 22.11.**
  /// I dati che lo generano, mai un'immagine; la versione del formato la
  /// scrive il server. Una voce gia' annotata non si annota due volte.
  Future<bool> annotaIlResponso({
    required String chiave,
    required DateTime quando,
    required String arte,
    required String maestro,
    required String titolo,
    required Map<String, Object?> contenuto,
  }) async {
    final voce = VoceDelRicordo(
      quando: quando,
      arte: arte,
      maestro: maestro,
      titolo: titolo,
      tipo: TipoDelRicordo.responso,
      riferimento: chiave,
      chiaveDelDiario: chiave,
    );
    final dentro = _perMese.putIfAbsent(voce.mese, () => {});
    if (dentro.containsKey(chiave)) return false;
    dentro[chiave] = voce;
    _conserva(chiave, {'v': 1, 'c': contenuto});
    _contaNelRiassunto(voce, etichetteDi(voce), 1);
    notifyListeners();
    await _salva(voce.mese);
    scrittureVersoIlServer++;
    return _porta.annota(
      chiave: chiave,
      quando: quando,
      tipo: 'responso',
      arte: arte,
      maestro: maestro,
      titolo: titolo,
      contenuto: contenuto,
    );
  }

  /// La chiave di una conversazione nell'indice, la stessa del server.
  static String chiaveDellaConversazione(String maestro, String? id) {
    final c = (id ?? 'prima').replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '');
    return 'conv.$maestro.${c.isEmpty ? 'prima' : c.toLowerCase()}';
  }

  /// L'id della conversazione da una chiave del Diario: nullo per la prima,
  /// quella dei messaggi senza marcatura.
  static String? idDellaConversazione(String chiave) {
    final punto = chiave.lastIndexOf('.');
    final id = punto < 0 ? chiave : chiave.substring(punto + 1);
    return id == 'prima' ? null : id;
  }

  /// **LA CONVERSAZIONE NEL DIARIO, SUBITO.** La riga vera la scrive il
  /// server col messaggio; qui la si mostra senza aspettare la rilettura.
  void toccaLaConversazione({
    required String maestro,
    required String? conversazione,
    required String tema,
    required DateTime quando,
  }) {
    final chiave = chiaveDellaConversazione(maestro, conversazione);
    final nata =
        conversazione != null && RegExp(r'^c\d{12,}$').hasMatch(conversazione)
            ? DateTime.fromMillisecondsSinceEpoch(
                int.parse(conversazione.substring(1)))
            : quando;
    final mese = VoceDelRicordo.chiaveDelMese(nata);
    final dentro = _perMese.putIfAbsent(mese, () => {});
    if (dentro.containsKey(chiave)) return;
    final voce = VoceDelRicordo(
      quando: nata,
      arte: 'chat',
      maestro: maestro,
      titolo: tema,
      tipo: TipoDelRicordo.conversazione,
      riferimento: chiave,
      chiaveDelDiario: chiave,
    );
    dentro[chiave] = voce;
    _contaNelRiassunto(voce, etichetteDi(voce), 1);
    notifyListeners();
    unawaited(_salva(mese));
  }

  /// **LE CONVERSAZIONI DI UN MAESTRO, per il menu' della chat.** La stessa
  /// fonte del Diario (FE.22.16): le righe dell'indice, dalla piu' recente.
  /// Se i mesi letti non bastano a [quante], si leggono i mesi prima, fino a
  /// dodici indietro.
  Future<List<VoceDelRicordo>> conversazioniDi(String maestro,
      {int quante = 5}) async {
    await carica();
    final adesso = _orologio();
    List<VoceDelRicordo> trovate() => [
          for (final v in tutte.reversed)
            if (v.tipo == TipoDelRicordo.conversazione &&
                v.maestro == maestro &&
                v.chiaveDelDiario != null)
              v,
        ];
    for (var i = 0; i < 12 && trovate().length < quante; i++) {
      final g = DateTime(adesso.year, adesso.month - i, 1);
      await ripesca(VoceDelRicordo.chiaveDelMese(g));
    }
    return trovate().take(quante).toList();
  }

  /// Toglie una voce dal telefono (il cestino: sul server la toglie la
  /// funzione che cancella la conversazione). FE.22.17.
  void togli(String chiave) {
    for (final e in _perMese.entries) {
      final v = e.value.remove(chiave);
      if (v != null) {
        _contaNelRiassunto(v, etichetteDi(v), -1);
        unawaited(_salva(e.key));
        notifyListeners();
        return;
      }
    }
  }

  /// Il contenuto di una voce aperta: dalla copia di comodo se c'e',
  /// altrimenti dal server (anche dall'archivio), e allora entra nella copia.
  Future<Map<String, Object?>?> contenutoDi(String chiave) async {
    final copia = _contenuti[chiave];
    if (copia != null) return copia;
    final letto = await _porta.leggiVoce(chiave);
    lettureDalServer++;
    if (letto != null) {
      _conserva(chiave, letto);
      notifyListeners();
    }
    return letto;
  }

  /// Il contenuto nella copia di comodo, senza toccare la rete.
  Map<String, Object?>? contenutoInCopia(String chiave) => _contenuti[chiave];

  /// **LA CARTA CHE SI MOSTRA SI PRENDE UNA VOLTA.** Chiede il contenuto al
  /// server se la copia non lo ha, una sola volta per sessione; chi ascolta
  /// il registro si ridisegna quando arriva. Non costa niente all'apertura
  /// del Diario: lo chiama solo la griglia delle carte (FE.22.18).
  void portaInCopia(String chiave) {
    if (_contenuti.containsKey(chiave)) return;
    if (!_contenutiChiesti.add(chiave)) return;
    unawaited(contenutoDi(chiave));
  }

  void _conserva(String chiave, Map<String, Object?> contenuto) {
    _contenuti.remove(chiave);
    _contenuti[chiave] = contenuto;
    while (_contenuti.length > quantiContenutiSulTelefono) {
      _contenuti.remove(_contenuti.keys.first);
    }
    unawaited(_salvaIContenuti());
  }

  Future<void> _salvaIContenuti() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kContenuti, jsonEncode(_contenuti));
    } catch (errore) {
      debugPrint('Ricordi: la copia dei contenuti non si salva. $errore');
    }
  }

  /// Le conversazioni e le voci di prima entrano nel Diario, una volta.
  Future<int> riempiIlDiario() => _porta.riempi();

  /// **I RICORDI TORNANO COL TUO ACCOUNT.** Ordine EV: la timeline del Cosmic
  /// Journal non arrivava mai al Cerchio (`sincronizza` non aveva chiamanti) e
  /// su un telefono nuovo non tornava. Dopo il riconoscimento si manda cio'
  /// che il telefono ha e si riprendono i [mesi] dal Cerchio, **unendo**: le
  /// righe del telefono restano, quelle del Cerchio che mancano entrano. Torna
  /// quante righe sono entrate.
  Future<int> riprendiDalCerchio({int mesi = 12}) async {
    await sincronizza(forza: true);
    final adesso = _orologio();
    var entrate = 0;
    for (var i = 0; i < mesi; i++) {
      final g = DateTime(adesso.year, adesso.month - i, 1);
      final mese = '${g.year.toString().padLeft(4, '0')}-'
          '${g.month.toString().padLeft(2, '0')}';
      final righe = await _porta.leggi(mese);
      lettureDalServer++;
      if (righe.isEmpty) continue;
      final dentro = _perMese.putIfAbsent(mese, () => {});
      var qui = 0;
      for (final r in righe) {
        if (dentro.containsKey(r.chiave)) continue;
        dentro[r.chiave] = r;
        qui++;
      }
      if (qui > 0) {
        entrate += qui;
        await _salva(mese);
      }
    }
    if (entrate > 0) notifyListeners();
    return entrate;
  }

  /// Dimentica tutto, per la cancellazione del Cerchio e per le prove.
  void dimentica() {
    _perMese.clear();
    _mesiDalServer.clear();
    _contenuti.clear();
    _contenutiChiesti.clear();
    _anni.clear();
    _anniDalServer.clear();
    _mesiSporchi.clear();
    _ultimaSincronia = '';
    scrittureVersoIlServer = 0;
    lettureDalServer = 0;
    notifyListeners();
  }
}
