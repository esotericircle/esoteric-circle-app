import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_flags.dart';
import 'scena_del_viaggio.dart';
import 'vocabolario_del_viaggio.dart';

/// **IL DIARIO DEI VIAGGI, E LA MEMORIA.** Ordine DC voce 09,
/// 10 settembre 2026.
///
/// *"Ogni viaggio si deposita in un Diario: la scena, la domanda che l'aveva
/// generata, la data. Chi torna dopo sei mesi rilegge le domande che si faceva
/// e le risposte che aveva avuto."*
///
/// **VIVE SUL TELEFONO**, come la traccia del Loto e la memoria del respiro.
/// Le domande che una persona si fa sono la cosa piu' privata che questa app
/// tocchi, e non hanno nessuna ragione di stare su un server.
///
/// **E NON PUO' ZITTIRE NESSUNO.** Ordine DC voce 16: se questo archivio non
/// risponde, chi lo interroga va avanti lo stesso. La regola nasce da un
/// difetto mio dell'ordine DB, dove un'attesa sulla memoria del respiro teneva
/// muti i Maestri, e vale **per ogni sorgente di memoria, presente e futura**,
/// quindi anche per questa che nasce oggi.
class DiarioDeiViaggi {
  DiarioDeiViaggi({DateTime Function()? orologio})
      : _orologio = orologio ?? DateTime.now;

  final DateTime Function() _orologio;

  /// Il prefisso `loto.` non va bene: il Viaggio e' di Caligo. Sta sotto
  /// `viaggio.`, e la dimenticanza dei dati lo porta via con gli altri.
  static const String _chiave = 'viaggio.diario';

  /// **DOVE STANNO I NUTRIMENTI.** Ordine DE voce 12, 11 settembre 2026.
  ///
  /// Una chiave separata dal diario, e non un campo dentro un viaggio: **un
  /// nutrimento non e' un viaggio**. Se vivesse nella stessa lista,
  /// `quanteDiscese` comincerebbe a contarlo, e il riconoscimento si
  /// otterrebbe battendo il tamburo quattro volte.
  static const String _chiaveDeiNutrimenti = 'viaggio.nutrimenti';

  /// **QUANTI VIAGGI SI CONSERVANO.**
  ///
  /// Novanta, come la memoria del respiro: bastano a rileggere sei mesi di
  /// domande, e sono pochi chilobyte.
  static const int quantiNeTiene = 90;

  List<UnViaggio> _viaggi = const [];
  List<DateTime> _nutrimenti = const [];

  /// I viaggi conservati, dal piu' recente.
  List<UnViaggio> get viaggi => List.unmodifiable(_viaggi);

  /// **SI RICOMINCIA DA CAPO, e solo in Demo.** Ordine DG voce 08,
  /// 11 settembre 2026.
  ///
  /// **Porta via le due chiavi del Viaggio e nient'altro**: `viaggio.diario` e
  /// `viaggio.nutrimenti`, nominate una per una. Non l'account, non il
  /// cammino, non i sigilli. Un azzeramento che prendesse tutto sarebbe la
  /// cancellazione dei dati travestita da comando di prova.
  ///
  /// **Perche' solo in Demo.** Perche' il riconoscimento costa quattro giorni:
  /// un comando che lo annulla, a portata di dito di chiunque, toglierebbe
  /// alle quattro discese la cosa che le rende quattro.
  Future<bool> ricomincia({bool demo = AppFlags.isDemo}) async {
    if (!demo) return false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chiave);
    await prefs.remove(_chiaveDeiNutrimenti);
    _viaggi = const [];
    _nutrimenti = const [];
    return true;
  }

  Future<void> carica() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final righe = prefs.getStringList(_chiave) ?? const [];
      final letti = <UnViaggio>[];
      for (final r in righe) {
        final j = jsonDecode(r);
        if (j is Map<String, dynamic>) {
          final v = UnViaggio.fromJson(j);
          if (v != null) letti.add(v);
        }
      }
      letti.sort((a, b) => b.quando.compareTo(a.quando));
      _viaggi = List.unmodifiable(letti);
      // **I NUTRIMENTI, ordine DE voce 12.** Stessa indulgenza del diario: un
      // elenco illeggibile vale un elenco vuoto, e chi torna trova comunque
      // il tamburo.
      final battiti = <DateTime>[];
      for (final r in prefs.getStringList(_chiaveDeiNutrimenti) ?? const []) {
        final d = DateTime.tryParse(r);
        if (d != null) battiti.add(d);
      }
      battiti.sort((a, b) => b.compareTo(a));
      _nutrimenti = List.unmodifiable(battiti);
    } catch (errore) {
      // **SI IGNORA, E SI DICE PERCHE'.** Un archivio illeggibile o assente
      // non deve impedire di scendere: **il viaggio di oggi vale piu' del
      // ricordo di quelli vecchi**, e chi ha il telefono pieno non merita di
      // trovare la funzione chiusa.
      _viaggi = const [];
      _nutrimenti = const [];
    }
  }

  /// Segna un viaggio appena concluso.
  Future<void> segna(UnViaggio viaggio) async {
    _viaggi =
        List.unmodifiable([viaggio, ..._viaggi].take(quantiNeTiene).toList());
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
          _chiave, [for (final v in _viaggi) jsonEncode(v.toJson())]);
    } catch (errore) {
      // **SI IGNORA, E SI DICE PERCHE'.** Il viaggio e' gia' finito e la scena
      // e' gia' a schermo: se l'archivio rifiuta la scrittura, l'unica cosa
      // persa e' il ricordo di questa discesa. Sollevare qui farebbe fallire
      // un rito compiuto, che e' un danno piu' grande.
    }
  }

  /// **IL TAMBURO: UN GESTO SOLO, E L'ANIMALE SI RIAVVICINA.**
  /// Ordine DE voce 12, 11 settembre 2026.
  ///
  /// *"Accanto all'avviso c'e' sempre la via del ritorno: un gesto solo,
  /// breve, che lo richiama, e la nitidezza migliora subito di un passo."*
  ///
  /// **Fino a oggi quel passo non esisteva.** La costante
  /// `quantiGiorniValeUnNutrimento` era scritta dall'ordine DC voce 08 e
  /// **nessuna schermata la spendeva**: la nitidezza poteva solo scendere. Una
  /// misura che peggiora e non risale non e' una distanza, e' una condanna.
  ///
  /// **Torna vero anche se l'archivio rifiuta.** Il battito si conta subito in
  /// memoria e la scena si riavvicina comunque: l'unica cosa che si perde e'
  /// il ricordo del gesto, ed e' la stessa scelta che il diario fa per i
  /// viaggi gia' compiuti.
  Future<void> nutri() async {
    final adesso = _orologio();
    _nutrimenti = List.unmodifiable([adesso, ..._nutrimenti].take(60).toList());
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_chiaveDeiNutrimenti,
          [for (final d in _nutrimenti) d.toIso8601String()]);
    } catch (errore) {
      // Vedi sopra: il gesto e' gia' valso, si perde solo il suo ricordo.
    }
  }

  /// **SE IL TAMBURO SI PUO' BATTERE OGGI.** Uno al giorno.
  ///
  /// **Senza questo limite il gesto non vale niente**: quattro colpi di
  /// seguito riporterebbero la nitidezza da zero a uno in quattro secondi, e
  /// una distanza che si annulla con quattro tocchi non e' una distanza. Uno
  /// al giorno vuol dire che **tornare costa tornare**, e che chi e' a
  /// ventotto giorni ci mette tre giorni a rientrare, non tre secondi.
  bool siPuoNutrireOggi() {
    if (_nutrimenti.isEmpty) return true;
    return _giornoDi(_nutrimenti.first) != _giornoDi(_orologio());
  }

  /// **QUANTI NUTRIMENTI CONTANO ADESSO.**
  ///
  /// Solo quelli **dopo l'ultima discesa**: scendere azzera il conto, perche'
  /// la nitidezza e' gia' tornata piena da sola e i battiti vecchi
  /// diventerebbero credito accumulato. **Al massimo tre**, cioe' ventun
  /// giorni, che e' esattamente l'arco fra la settimana e il mese: piu' di
  /// cosi' non servirebbe a niente, e un tetto scritto e' meglio di un tetto
  /// che nasce per caso da una sottrazione.
  static const int quantiNutrimentiContano = 3;

  int get nutrimentiCheContano {
    final ultima = _viaggi.isEmpty ? null : _viaggi.first.quando;
    var quanti = 0;
    for (final d in _nutrimenti) {
      if (ultima != null && !d.isAfter(ultima)) continue;
      quanti++;
    }
    return quanti > quantiNutrimentiContano ? quantiNutrimentiContano : quanti;
  }

  /// **DA QUANTI GIORNI L'ANIMALE E' LONTANO**, tolti i nutrimenti.
  ///
  /// **E' questo il numero che la nitidezza deve leggere**, non
  /// [giorniDallUltima]: quello dice da quanto non si scende, questo dice
  /// **quanto e' lontano**, e le due cose smettono di coincidere nel momento
  /// in cui esiste un gesto che lo richiama.
  int? get giorniDiDistanza {
    final da = giorniDallUltima;
    if (da == null) return null;
    final tolti =
        nutrimentiCheContano * NitidezzaDellaScena.quantiGiorniValeUnNutrimento;
    final resta = da - tolti;
    return resta < 0 ? 0 : resta;
  }

  // --- CIO' CHE IL DIARIO SA, e che nessun singolo viaggio dice ---

  /// Quante discese in tutto.
  int get quanteDiscese => _viaggi.length;

  /// **DA QUANTI GIORNI NON SI SCENDE**, o nulla se non si e' mai sceso.
  int? get giorniDallUltima {
    if (_viaggi.isEmpty) return null;
    return _orologio().difference(_viaggi.first.quando).inDays;
  }

  /// **SE SI PUO' SCENDERE OGGI.** Ordine DC voce 04: i quattro viaggi del
  /// riconoscimento cadono in **quattro giorni diversi**.
  ///
  /// **Vale solo finche' l'animale non e' riconosciuto**: dopo, si scende
  /// quando si vuole, perche' l'attesa era il metodo del riconoscimento e non
  /// una trattenuta.
  bool siPuoScendereOggi({required bool giaRiconosciuto}) {
    if (giaRiconosciuto) return true;
    if (_viaggi.isEmpty) return true;
    return _giornoDi(_viaggi.first.quando) != _giornoDi(_orologio());
  }

  /// **QUANTE DISCESE OGGI.** Ordine DE voce 14.
  ///
  /// **Non e' la stessa cosa di [siPuoScendereOggi], ed e' il motivo per cui
  /// nasce.** Quel metodo risponde si o no a una regola sola, cioe' una
  /// discesa al giorno. Dopo la rivelazione il tetto **non e' piu' uno**: e'
  /// quello del piano, e per confrontarlo con un tetto serve un numero, non
  /// un booleano.
  ///
  /// **Il giorno e' quello dell'orologio iniettato**, lo stesso con cui i
  /// viaggi sono stati segnati: confrontare date scritte da un orologio e
  /// lette da un altro e' il modo piu' rapido di contare male.
  int get quanteOggi {
    final oggi = _giornoDi(_orologio());
    var quante = 0;
    for (final v in _viaggi) {
      if (_giornoDi(v.quando) == oggi) quante++;
    }
    return quante;
  }

  /// Le scelte fatte a ogni discesa, in ordine di tempo.
  List<String> get scelteInOrdine =>
      [for (final v in _viaggi.reversed) v.animaleSeguito];

  /// **GLI ELEMENTI CHE TORNANO NELLE SUE SCENE.** Ordine DC voce 09.
  ///
  /// Nulla sotto tre viaggi: **due ripetizioni sono il caso**, e chiamare
  /// ricorrenza il caso e' la bugia piu' facile che un'app di questo genere
  /// possa dire.
  List<String> get cheTorna {
    if (_viaggi.length < 3) return const [];
    final conto = <String, int>{};
    for (final v in _viaggi) {
      for (final id in v.pezzi) {
        conto.update(id, (n) => n + 1, ifAbsent: () => 1);
      }
    }
    final tornati = [
      for (final e in conto.entries)
        if (e.value >= 3) e.key,
    ];
    return tornati;
  }

  /// **IL RIASSUNTO CHE ENTRA NEL CONTESTO DEI MAESTRI.** Ordine DC voce 09.
  ///
  /// Non il dato grezzo di ogni discesa: **una riga breve**. E nessun Maestro
  /// dichiara mai alla persona che la sta osservando: **deve sapere, non deve
  /// dirlo.**
  String get riassuntoPerIMaestri {
    if (_viaggi.isEmpty) return '';
    final pezzi = <String>['è sceso nel Mondo di Sotto $quanteDiscese volte'];
    final da = giorniDallUltima;
    if (da != null && da >= 7) pezzi.add('ultima volta $da giorni fa');
    final temi = <String, int>{};
    for (final v in _viaggi) {
      if (v.temaDellaDomanda.isEmpty) continue;
      temi.update(v.temaDellaDomanda, (n) => n + 1, ifAbsent: () => 1);
    }
    if (temi.isNotEmpty) {
      final ordinati = temi.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      if (ordinati.first.value >= 2) {
        pezzi.add('torna spesso sul tema "${ordinati.first.key}"');
      }
    }
    final ricorrenti = cheTorna;
    if (ricorrenti.isNotEmpty) {
      final nomi = [
        for (final id in ricorrenti.take(2))
          VocabolarioDelViaggio.di(id)?.nome ?? id,
      ];
      pezzi.add('nelle sue scene torna ${nomi.join(" e ")}');
    }
    return pezzi.join('; ');
  }

  static String _giornoDi(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

/// Un viaggio, come il Diario lo conserva.
class UnViaggio {
  const UnViaggio({
    required this.quando,
    required this.domanda,
    required this.temaDellaDomanda,
    required this.pezzi,
    required this.animaleSeguito,
    required this.nitidezza,
  });

  final DateTime quando;

  /// La domanda con cui si e' sceso, per esteso.
  final String domanda;

  /// Il tema, quando la domanda veniva dalle sei scritte: serve a sapere su
  /// cosa quella persona torna, senza rileggere le sue parole.
  final String temaDellaDomanda;

  /// Gli id dei pezzi della scena.
  final List<String> pezzi;

  /// Il nome dell'animale seguito in questa discesa.
  final String animaleSeguito;

  final double nitidezza;

  /// La scena rimessa insieme dai suoi id, o nulla se il vocabolario e'
  /// cambiato sotto: **un Diario che mostra un pezzo che non esiste piu' e'
  /// peggio di un Diario che salta quella riga**.
  ScenaDelViaggio? get scena {
    if (pezzi.length < 4) return null;
    final luogo = VocabolarioDelViaggio.di(pezzi[0]);
    final cosa = VocabolarioDelViaggio.di(pezzi[1]);
    final gesto = VocabolarioDelViaggio.di(pezzi[2]);
    final momento = VocabolarioDelViaggio.di(pezzi[3]);
    if (luogo == null || cosa == null || gesto == null || momento == null) {
      return null;
    }
    return ScenaDelViaggio(
      luogo: luogo,
      cosa: cosa,
      gesto: gesto,
      momento: momento,
      nitidezza: nitidezza,
    );
  }

  Map<String, dynamic> toJson() => {
        'quando': quando.toIso8601String(),
        'domanda': domanda,
        'tema': temaDellaDomanda,
        'pezzi': pezzi,
        'animale': animaleSeguito,
        'nitidezza': nitidezza,
      };

  static UnViaggio? fromJson(Map<String, dynamic> j) {
    final quando = DateTime.tryParse(j['quando'] as String? ?? '');
    if (quando == null) return null;
    return UnViaggio(
      quando: quando,
      domanda: j['domanda'] as String? ?? '',
      temaDellaDomanda: j['tema'] as String? ?? '',
      pezzi: [
        for (final p in (j['pezzi'] as List? ?? const []))
          if (p is String) p,
      ],
      animaleSeguito: j['animale'] as String? ?? '',
      nitidezza: (j['nitidezza'] as num?)?.toDouble() ?? 1.0,
    );
  }
}
