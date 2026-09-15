import 'dart:convert';
import 'dart:ui' show Offset;

import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_flags.dart';
import 'i_quattro_viaggi.dart';
import 'il_nome_si_puo_dire.dart';
import 'la_domanda_del_viaggio.dart';
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
  DiarioDeiViaggi({DateTime Function()? orologio, this.archivio = true})
      : _orologio = orologio ?? DateTime.now;

  /// **SE IL DIARIO LEGGE E SCRIVE SUL TELEFONO.** Sempre, tranne che nella
  /// build di collaudo del cammino, [collaudoDelCammino]: li' il Viaggio
  /// comincia da un Diario vuoto e non scrive niente, cosi' il cammino a
  /// quattro strati si prova da capo sul telefono di collaudo **senza
  /// toccare il Viaggio che quel telefono ha gia'**. Ordine DQ voce 14.
  final bool archivio;

  /// **LA BUILD DI COLLAUDO DEL CAMMINO**, accesa solo con
  /// `--dart-define=COLLAUDO_DEL_CAMMINO=true`. Nella build che si consegna
  /// e' falsa, e il ramo non esiste.
  static const bool collaudoDelCammino =
      bool.fromEnvironment('COLLAUDO_DEL_CAMMINO');

  /// **IL DIARIO DI COLLAUDO, UNO PER TUTTA LA SESSIONE**: fra una discesa e
  /// l'altra si esce dal Viaggio e si rientra, e il cammino deve restare.
  static final DiarioDeiViaggi diCollaudo = DiarioDeiViaggi(archivio: false);

  Future<SharedPreferences> _prefs() => archivio
      ? SharedPreferences.getInstance()
      : Future.error(StateError('Diario di collaudo, senza archivio'));

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

  /// **DOVE STANNO I SEGNI CHIESTI ALL'ANIMALE.** Ordine DI voce 14. Una
  /// chiave sua, per la stessa ragione dei nutrimenti: un segno non e' una
  /// discesa, e non deve contare per il riconoscimento.
  static const String _chiaveDeiSegni = 'viaggio.segni';

  /// Quanti segni si conservano: cento, e bastano a qualunque settimana.
  static const int quantiSegniTiene = 100;

  /// **DOVE STA LA CENERE GIA' SCOSTATA.** Ordine DI voce 10: *"la superficie
  /// gia' scoperta nelle discese precedenti resta scoperta e si ritrova
  /// riaprendo la funzione"*. Il nome dell'animale, due punti, e gli indici
  /// delle celle separati da virgole.
  static const String _chiaveDelVelo = 'viaggio.velo';

  /// **DOVE STANNO I SOLCHI DEL DITO**, ordine DQ voce 05: il tratto
  /// esatto, in frazioni dell'illustrazione, perche' il velo lo ridipinga
  /// uguale. Le celle restano la contabilita', i solchi il disegno.
  static const String _chiaveDeiSolchi = 'viaggio.velo.solchi';

  /// **QUANTI VIAGGI SI CONSERVANO.**
  ///
  /// Novanta, come la memoria del respiro: bastano a rileggere sei mesi di
  /// domande, e sono pochi chilobyte.
  static const int quantiNeTiene = 90;

  /// **DOVE STA IL CONTO DELLE DISCESE.** Ordine DJ voce 07, 13 settembre
  /// 2026. Un numero suo, e non la lunghezza della lista: vedi
  /// [quanteDiscese].
  static const String _chiaveDelConto = 'viaggio.quante';

  /// **DOVE STA IL CAMMINO IN CORSO**, la domanda e lo strato raggiunto.
  /// Ordine DQ voce 01. Stringa vuota: nessun cammino in corso.
  static const String _chiaveDelCammino = 'viaggio.cammino';

  /// **SE L'ANIMALE E' STATO RICONOSCIUTO**, ordine DQ voce 03. Un numero suo
  /// e non il conto delle discese: cambiare domanda fa ripartire le quattro
  /// apparizioni, e le discese restano.
  static const String _chiaveDelRiconoscimento = 'viaggio.riconosciuto';

  List<UnViaggio> _viaggi = const [];
  int _quante = 0;
  List<DateTime> _nutrimenti = const [];
  List<SegnoRicevuto> _segni = const [];
  Set<int> _celleScoperte = const {};
  String? _animaleDelVelo;
  List<List<Offset>> _solchi = const [];
  String? _animaleDeiSolchi;
  IlCammino? _cammino;
  bool _riconosciuto = false;

  /// **IL CAMMINO IN CORSO**, o nullo: prima della prima discesa, dopo il
  /// riconoscimento, e subito dopo che si e' cambiata la domanda. Ordine DQ
  /// voce 01.
  IlCammino? get cammino => _cammino;

  /// **SE L'ANIMALE E' STATO RICONOSCIUTO.** Ordine DQ voce 03.
  bool get riconosciuto => _riconosciuto;

  /// **LE APPARIZIONI VERSO IL RICONOSCIMENTO.** Ordine DQ voce 03, 15
  /// settembre 2026.
  ///
  /// **Fino all'ordine DQ erano le discese**, tutte: quattro discese, e il
  /// nome si diceva. Adesso l'animale si mostra quattro volte **a chi tiene la
  /// stessa domanda**, e cambiarla fa ripartire il conto dalla prima: le
  /// apparizioni sono lo strato del cammino in corso. Dopo il riconoscimento
  /// valgono le discese, mai sotto quattro, perche' il Passaporto conta anche
  /// quelle che vengono dopo.
  int get apparizioni => _riconosciuto
      ? (_quante > IQuattroViaggi.quanteDiscese
          ? _quante
          : IQuattroViaggi.quanteDiscese)
      : _cammino?.strato ?? 0;

  /// **GLI STRATI DI UN CAMMINO**, dal primo: le discese che ci sono scese.
  /// Ordine DQ voce 02. Un cammino ereditato da un Diario scritto prima
  /// dell'ordine DQ non ha il segno nelle discese: i suoi strati sono le
  /// ultime discese, tante quanto lo strato.
  List<UnViaggio> stratiDi(IlCammino c) {
    final suoi = [
      for (final v in _viaggi)
        if (v.cammino == c.id) v,
    ];
    final strati = suoi.isEmpty && c.ereditato
        ? _viaggi.take(c.strato).toList()
        : suoi;
    return strati.reversed.toList();
  }

  /// **I CAMMINI DEL DIARIO**, dal piu' recente: per ognuno la domanda e i
  /// suoi strati. Ordine DQ voce 02: i quattro strati si leggono di fila.
  List<({String id, String domanda, List<UnViaggio> strati})> get cammini {
    final ordine = <String>[];
    final per = <String, List<UnViaggio>>{};
    for (final v in _viaggi) {
      final id = v.cammino;
      if (id == null) continue;
      if (!per.containsKey(id)) ordine.add(id);
      per.putIfAbsent(id, () => []).add(v);
    }
    return [
      for (final id in ordine)
        (
          id: id,
          domanda: per[id]!.last.domanda,
          strati: per[id]!.reversed.toList(),
        ),
    ];
  }

  /// **LE IMPRONTE DEL CAMMINO IN CORSO**: l'animale seguito a ogni strato.
  List<String> get scelteDelCammino => _cammino == null
      ? const []
      : [for (final v in stratiDi(_cammino!)) v.animaleSeguito];

  /// **SI COMINCIA UN CAMMINO**, alla prima discesa. Ordine DQ voce 01: la
  /// domanda si scrive una volta sola, e resta.
  Future<void> cominciaIlCammino(IlCammino c) async {
    _cammino = c;
    await _scriviIlCammino();
  }

  /// **SI CAMBIA LA DOMANDA, E IL CAMMINO RIPARTE DALLA PRIMA.** Ordine DQ
  /// voce 03. Le discese fatte restano nel Diario con la loro domanda e i
  /// loro strati: non si cancella niente, si ricomincia soltanto il conteggio
  /// delle quattro apparizioni. **E la cenere torna intera**: l'animale si
  /// mostra di nuovo dalla prima volta.
  Future<void> cambiaLaDomanda() async {
    _cammino = null;
    _celleScoperte = const {};
    _animaleDelVelo = null;
    _solchi = const [];
    _animaleDeiSolchi = null;
    IlNomeSiPuoDire.quanteDisceseNote = apparizioni;
    await _scriviIlCammino();
    try {
      final prefs = await _prefs();
      await prefs.remove(_chiaveDelVelo);
      await prefs.remove(_chiaveDeiSolchi);
    } catch (errore) {
      // Si perde il ricordo della cenere scostata, non il gesto.
    }
  }

  Future<void> _scriviIlCammino() async {
    try {
      final prefs = await _prefs();
      await prefs.setString(
          _chiaveDelCammino, _cammino == null ? '' : jsonEncode(_cammino!.toJson()));
      await prefs.setBool(_chiaveDelRiconoscimento, _riconosciuto);
    } catch (errore) {
      // **SI PERDE IL RICORDO, NON IL CAMMINO DI OGGI**: la domanda resta a
      // schermo finche' l'app e' aperta.
    }
  }

  /// **LE CELLE DEL VELO GIA' SCOSTATE SU [animale]**, discesa dopo discesa.
  ///
  /// **Legate al nome, e non per scrupolo.** L'animale lo decide la nascita:
  /// chi corregge la data di nascita dopo due discese ha un altro animale, e
  /// la cenere scostata sul Lupo non deve comparire scostata sull'Aquila. Per
  /// un altro nome il velo e' intero.
  Set<int> celleScoperteDi(String animale) => animale == _animaleDelVelo
      ? Set.unmodifiable(_celleScoperte)
      : const <int>{};

  /// Conserva le celle scoperte su [animale]. Se l'archivio rifiuta, si perde
  /// il ricordo e non il gesto: la cenere scostata oggi resta scostata a
  /// schermo.
  Future<void> segnaCelleScoperte(String animale, Set<int> celle) async {
    _animaleDelVelo = animale;
    _celleScoperte = Set.unmodifiable(celle);
    try {
      final prefs = await _prefs();
      await prefs.setString(
          _chiaveDelVelo, '$animale:${(celle.toList()..sort()).join(',')}');
    } catch (errore) {
      // Si perde solo il ricordo del gesto.
    }
  }

  /// **I SOLCHI GIA' APERTI SU [animale]**, ordine DQ voce 05; per un altro
  /// nome nessuno, come le celle.
  List<List<Offset>> solchiDi(String animale) =>
      animale == _animaleDeiSolchi ? _solchi : const [];

  /// Conserva i solchi di [animale]. Tre decimali bastano: sull'illustrazione
  /// piu' grande sono meno di mezzo punto.
  Future<void> segnaISolchi(String animale, List<List<Offset>> solchi) async {
    _animaleDeiSolchi = animale;
    _solchi = [for (final s in solchi) List.unmodifiable(s)];
    try {
      final prefs = await _prefs();
      final testo = [
        for (final s in solchi)
          [
            for (final p in s)
              '${p.dx.toStringAsFixed(3)},${p.dy.toStringAsFixed(3)}'
          ].join(';'),
      ].join('|');
      await prefs.setString(_chiaveDeiSolchi, '$animale@$testo');
    } catch (errore) {
      // Si perde il disegno del solco, non il gesto: le celle restano.
    }
  }

  /// **I SEGNI CHIESTI**, dal piu' recente.
  List<SegnoRicevuto> get segni => List.unmodifiable(_segni);

  /// Gli istanti dei segni chiesti, per i tetti del piano.
  List<DateTime> get segniChiesti => [for (final s in _segni) s.quando];

  /// **SEGNA UN SEGNO RICEVUTO.** Come per i viaggi, se l'archivio rifiuta la
  /// scrittura si perde solo il ricordo: il segno e' gia' a schermo.
  Future<void> segnaUnSegno(SegnoRicevuto segno) async {
    _segni = List.unmodifiable([segno, ..._segni].take(quantiSegniTiene));
    try {
      final prefs = await _prefs();
      await prefs.setStringList(
          _chiaveDeiSegni, [for (final s in _segni) jsonEncode(s.toJson())]);
    } catch (errore) {
      // Il segno e' gia' stato dato: si perde solo il suo ricordo.
    }
  }

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
    if (archivio) {
      final prefs = await _prefs();
      await prefs.remove(_chiave);
      await prefs.remove(_chiaveDeiNutrimenti);
      await prefs.remove(_chiaveDeiSegni);
      await prefs.remove(_chiaveDelVelo);
      await prefs.remove(_chiaveDeiSolchi);
      await prefs.remove(_chiaveDelConto);
      await prefs.remove(_chiaveDelCammino);
      await prefs.remove(_chiaveDelRiconoscimento);
    }
    _cammino = null;
    _riconosciuto = false;
    _quante = 0;
    _viaggi = const [];
    _nutrimenti = const [];
    _segni = const [];
    _celleScoperte = const {};
    _animaleDelVelo = null;
    _solchi = const [];
    _animaleDeiSolchi = null;
    // **E ANCHE IL CONTO TORNA A ZERO**, o il comando di demo riporterebbe il
    // Viaggio a zero discese lasciando il nome detto in mezza app.
    IlNomeSiPuoDire.quanteDisceseNote = 0;
    return true;
  }

  Future<void> carica() async {
    // **SENZA ARCHIVIO NON C'E' NIENTE DA LEGGERE**, e cio' che la sessione
    // ha gia' fatto resta: rileggere vorrebbe dire azzerarlo.
    if (!archivio) {
      IlNomeSiPuoDire.quanteDisceseNote = apparizioni;
      return;
    }
    try {
      final prefs = await _prefs();
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
      // **IL CONTO, e chi non l'aveva comincia dalla lista.** Ordine DJ voce
      // 07: un Diario scritto prima dell'ordine non ha il conto, e la lista e'
      // tutto cio' che se ne sa. Chi aveva gia' passato le novanta discese
      // riparte da novanta, perche' le discese uscite dalla lista non si
      // possono piu' contare; da li' il conto cresce giusto. **Mai sotto la
      // lista**, anche se il conto fosse stato scritto male.
      final conto = prefs.getInt(_chiaveDelConto) ?? 0;
      _quante = conto > _viaggi.length ? conto : _viaggi.length;
      // **IL CAMMINO E IL RICONOSCIMENTO**, ordine DQ voce 01. **Un Diario
      // scritto prima dell'ordine** non ha nessuno dei due, e si ricava cosi':
      // chi aveva gia' quattro discese ha gia' riconosciuto il suo animale, e
      // lo tiene; chi era a meta' prosegue con la domanda della sua ultima
      // discesa, dallo strato a cui era arrivato. Nessuno perde un passo.
      final riconosciuto = prefs.getBool(_chiaveDelRiconoscimento);
      final cammino = prefs.getString(_chiaveDelCammino);
      if (riconosciuto == null && cammino == null) {
        _riconosciuto = _quante >= IQuattroViaggi.quanteDiscese;
        _cammino = _riconosciuto || _viaggi.isEmpty
            ? null
            : IlCammino.ereditatoDa(_viaggi.first, _quante);
      } else {
        _riconosciuto = riconosciuto ?? false;
        final j = cammino == null || cammino.isEmpty ? null : jsonDecode(cammino);
        _cammino = j is Map<String, dynamic> ? IlCammino.fromJson(j) : null;
      }
      // **QUI NASCE IL CONTO DELLE DISCESE, e da qui lo sa chi non puo'
      // aspettare.** Ordine DG voce 02: il simbolo dell'attesa di una chat si
      // disegna dentro un `build` sincrono, e senza questa riga mostrerebbe
      // il totem a chi non lo ha ancora incontrato.
      IlNomeSiPuoDire.quanteDisceseNote = apparizioni;
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
      // **I SEGNI, ordine DI voce 14**, con la stessa indulgenza.
      final segni = <SegnoRicevuto>[];
      for (final r in prefs.getStringList(_chiaveDeiSegni) ?? const []) {
        final j = jsonDecode(r);
        if (j is Map<String, dynamic>) {
          final s = SegnoRicevuto.fromJson(j);
          if (s != null) segni.add(s);
        }
      }
      segni.sort((a, b) => b.quando.compareTo(a.quando));
      _segni = List.unmodifiable(segni);
      // **LA CENERE SCOSTATA, ordine DI voce 10.**
      final velo = (prefs.getString(_chiaveDelVelo) ?? '').split(':');
      _animaleDelVelo = velo.length == 2 ? velo.first : null;
      _celleScoperte = Set.unmodifiable({
        if (velo.length == 2)
          for (final x in velo.last.split(','))
            if (int.tryParse(x) != null) int.parse(x),
      });
      // **I SOLCHI, ordine DQ voce 05**, con la stessa indulgenza: un punto
      // illeggibile si salta.
      final solchi = (prefs.getString(_chiaveDeiSolchi) ?? '').split('@');
      _animaleDeiSolchi = solchi.length == 2 ? solchi.first : null;
      _solchi = [
        if (solchi.length == 2 && solchi.last.isNotEmpty)
          for (final s in solchi.last.split('|'))
            [
              for (final p in s.split(';'))
                if (p.split(',').length == 2 &&
                    double.tryParse(p.split(',')[0]) != null &&
                    double.tryParse(p.split(',')[1]) != null)
                  Offset(double.parse(p.split(',')[0]),
                      double.parse(p.split(',')[1])),
            ],
      ];
    } catch (errore) {
      // **SI IGNORA, E SI DICE PERCHE'.** Un archivio illeggibile o assente
      // non deve impedire di scendere: **il viaggio di oggi vale piu' del
      // ricordo di quelli vecchi**, e chi ha il telefono pieno non merita di
      // trovare la funzione chiusa.
      _viaggi = const [];
      _nutrimenti = const [];
      _segni = const [];
    }
  }

  /// Segna un viaggio appena concluso.
  Future<void> segna(UnViaggio viaggio) async {
    // **IL CONTO CRESCE A OGNI DISCESA**, anche quando la lista, piena, ne
    // lascia uscire una. Ordine DJ voce 07. Mai sotto la lista, come in
    // [carica].
    final prima = _quante > _viaggi.length ? _quante : _viaggi.length;
    _quante = prima + 1;
    _viaggi =
        List.unmodifiable([viaggio, ..._viaggi].take(quantiNeTiene).toList());
    // **LO STRATO SI SEGNA NEL CAMMINO**, ordine DQ voce 02: la discesa che
    // porta il segno del cammino in corso lo fa salire di uno. Al quarto il
    // cammino e' finito e l'animale riconosciuto.
    final c = _cammino;
    if (c != null && viaggio.cammino == c.id) {
      final strato = viaggio.strato ?? c.strato + 1;
      if (strato >= IQuattroViaggi.quanteDiscese) {
        _riconosciuto = true;
        _cammino = null;
      } else {
        _cammino = c.alloStrato(strato);
      }
    }
    IlNomeSiPuoDire.quanteDisceseNote = apparizioni;
    try {
      final prefs = await _prefs();
      await prefs.setInt(_chiaveDelConto, _quante);
      await prefs.setString(_chiaveDelCammino,
          _cammino == null ? '' : jsonEncode(_cammino!.toJson()));
      await prefs.setBool(_chiaveDelRiconoscimento, _riconosciuto);
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
      final prefs = await _prefs();
      await prefs.setStringList(_chiaveDeiNutrimenti,
          [for (final d in _nutrimenti) d.toIso8601String()]);
    } catch (errore) {
      // Vedi sopra: il gesto e' gia' valso, si perde solo il suo ricordo.
    }
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

  ///
  /// **E UNO AL GIORNO, anche se il tamburo si batte piu' volte.** Ordine DI
  /// voce 13: il nutrimento e' aperto sempre, in tutti i piani, e la regola
  /// dell'ordine DE resta vera per un'altra strada. Prima il tamburo si poteva
  /// battere una volta al giorno, *"senza questo limite il gesto non vale
  /// niente"*; adesso si batte quanto si vuole, e **conta un giorno solo**:
  /// quattro riti di seguito oggi valgono un nutrimento, e tornare continua a
  /// costare tornare.
  int get nutrimentiCheContano {
    final ultima = _viaggi.isEmpty ? null : _viaggi.first.quando;
    final giorni = <String>{};
    for (final d in _nutrimenti) {
      if (ultima != null && !d.isAfter(ultima)) continue;
      giorni.add(_giornoDi(d));
    }
    return giorni.length > quantiNutrimentiContano
        ? quantiNutrimentiContano
        : giorni.length;
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

  /// **QUANTE DISCESE IN TUTTO**, dalla prima. Ordine DJ voce 07.
  ///
  /// **Qui c'era la lunghezza della lista**, e la lista ne conserva novanta:
  /// dalla novantunesima discesa il conto restava fermo a novanta, il
  /// riassunto per i Maestri diceva *"ha fatto 90 discese"* per sempre, e il
  /// numero della discesa smetteva di entrare nel seme della scena. Il difetto
  /// veniva dall'ordine DC, voci 04, 05, 06, 08 e 09. Adesso e' un conto suo,
  /// che cresce a ogni discesa e non dipende da quante se ne conservano.
  int get quanteDiscese => _quante;

  /// **DA QUANTI GIORNI NON SI SCENDE**, o nulla se non si e' mai sceso.
  int? get giorniDallUltima {
    if (_viaggi.isEmpty) return null;
    return _orologio().difference(_viaggi.first.quando).inDays;
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
    // **SENZA PARTICIPIO**, ordine DI voce 05: qui c'era *"e' sceso"*, e il
    // Maestro o il modello che lo riprende direbbe a una donna che e' un uomo.
    final pezzi = <String>['ha fatto $quanteDiscese discese nel Mondo di Sotto'];
    final da = giorniDallUltima;
    if (da != null && da >= 7) pezzi.add('ultima volta $da giorni fa');
    final temi = <String, int>{};
    for (final v in _viaggi) {
      // **NEL DIARIO C'E' L'ID, AL MAESTRO SERVONO LE PAROLE.** Ordine DI
      // voce 01: dal 12 settembre 2026 si salva l'id, `scelta`, e prima si
      // salvava l'etichetta per errore. Si capiscono tutte e due, cosi' i
      // diari scritti prima non perdono niente; la terza via non e' un tema
      // e non si conta.
      final tema = TemaDellaDomanda.daId(v.temaDellaDomanda)?.inLettere ??
          v.temaDellaDomanda;
      if (tema.isEmpty ||
          tema == LaDomandaDelViaggio.idSoloPerIncontrarlo) {
        continue;
      }
      temi.update(tema, (n) => n + 1, ifAbsent: () => 1);
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
    this.titolo,
    this.risposta,
    this.gesto,
    this.oggetto,
    this.fonti = const {},
    this.strato,
    this.cammino,
  });

  final DateTime quando;

  /// **LO STRATO DEL CAMMINO**, da uno a quattro, o nullo per le discese
  /// fuori da un cammino: quelle scritte prima dell'ordine DQ e quelle dopo
  /// il riconoscimento. Ordine DQ voce 02.
  final int? strato;

  /// **IL CAMMINO A CUI APPARTIENE**, per il suo id. Ordine DQ voce 01.
  final String? cammino;

  /// **IL TITOLO CHE LA DISCESA HA MOSTRATO**, e con lui la risposta e
  /// l'azione, cosi' come stanno nei loro elenchi. Ordine DJ voce 02: la voce
  /// sceglie fra cio' che la persona non ha ancora letto, e **la stessa
  /// discesa riaperta mostra lo stesso titolo, perche' il titolo si conserva e
  /// non si ricalcola**. Nulli nelle discese scritte prima dell'ordine DJ.
  final String? titolo;
  final String? risposta;
  final String? gesto;

  /// **L'OGGETTO DELLA DOMANDA**, come l'ha capito il classificatore: *"tua
  /// sorella"*. Ordine DL voce 08. Nullo quando non c'era o non reggeva.
  final String? oggetto;

  /// **DA QUALE VIA E' NATO OGNI PEZZO DEL RESPONSO.** Ordine DL voce 14.
  ///
  /// Per `tema`, `scena`, `titolo`, `risposta` e `gesto`: `modello`, oppure
  /// `riserva` col perche', *"riserva: tempo scaduto"*. **Si scrive sempre**,
  /// non solo col comando di collaudo acceso: la prova della build 2250 ha
  /// chiesto quale via avesse deciso il tema, e la risposta non c'era,
  /// perche' la fonte si calcolava e poi si buttava via.
  final Map<String, String> fonti;

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
        if (titolo != null) 'titolo': titolo,
        if (risposta != null) 'risposta': risposta,
        if (gesto != null) 'gesto': gesto,
        if (oggetto != null) 'oggetto': oggetto,
        if (fonti.isNotEmpty) 'fonti': fonti,
        if (strato != null) 'strato': strato,
        if (cammino != null) 'cammino': cammino,
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
      titolo: j['titolo'] is String ? j['titolo'] as String : null,
      risposta: j['risposta'] is String ? j['risposta'] as String : null,
      gesto: j['gesto'] is String ? j['gesto'] as String : null,
      oggetto: j['oggetto'] is String ? j['oggetto'] as String : null,
      fonti: {
        if (j['fonti'] is Map)
          for (final e in (j['fonti'] as Map).entries)
            if (e.key is String && e.value is String)
              e.key as String: e.value as String,
      },
      strato: j['strato'] is int ? j['strato'] as int : null,
      cammino: j['cammino'] is String ? j['cammino'] as String : null,
    );
  }
}

/// **IL CAMMINO: UNA DOMANDA, QUATTRO DISCESE.** Ordine DQ voce 01, 15
/// settembre 2026.
///
/// **La decisione del fondatore**, dall'esagramma quarto dell'I Ching: al
/// primo oracolo si risponde, all'importuno no. **La domanda e' una sola e
/// accompagna tutte e quattro le discese della rivelazione**, e ogni discesa
/// risale con uno strato piu' profondo della stessa risposta. La regola
/// delle quattro apparizioni di Harner smette di essere un conteggio e
/// diventa il motivo per cui ci vogliono quattro volte.
class IlCammino {
  const IlCammino({
    required this.domanda,
    required this.via,
    required this.tema,
    required this.inizio,
    this.oggetto,
    this.strato = 0,
    this.ereditato = false,
  });

  /// La domanda per esteso; vuota per chi scende soltanto per incontrarlo.
  final String domanda;

  /// `scelta`, `scritta` o `incontro`: la via con cui si e' scesi la prima
  /// volta, e resta.
  final String via;

  /// L'id del tema, o vuoto.
  final String tema;

  /// L'oggetto della domanda, dal classificatore della prima discesa.
  final String? oggetto;

  /// Quando e' cominciato: e' anche il suo id.
  final DateTime inizio;

  /// **QUANTI STRATI SONO GIA' RISALITI**, da zero a tre: al quarto il
  /// cammino e' finito.
  final int strato;

  /// **VIENE DA UN DIARIO SCRITTO PRIMA DELL'ORDINE DQ**: le sue discese non
  /// portano il segno del cammino.
  final bool ereditato;

  String get id => inizio.toIso8601String();

  /// Se si scende con una domanda, o soltanto per incontrarlo.
  bool get conDomanda => via != 'incontro';

  IlCammino alloStrato(int s) => IlCammino(
        domanda: domanda,
        via: via,
        tema: tema,
        inizio: inizio,
        oggetto: oggetto,
        strato: s,
        ereditato: ereditato,
      );

  /// **IL CAMMINO DI CHI ERA A META'** il giorno che l'ordine DQ e' arrivato:
  /// la domanda della sua ultima discesa, e lo strato delle discese fatte.
  factory IlCammino.ereditatoDa(UnViaggio ultimo, int discese) {
    final incontro =
        ultimo.temaDellaDomanda == LaDomandaDelViaggio.idSoloPerIncontrarlo ||
            ultimo.domanda == LaDomandaDelViaggio.soloPerIncontrarlo;
    final scritta = LaDomandaDelViaggio.gliaScritte
        .any((d) => d.testo == ultimo.domanda);
    return IlCammino(
      domanda: incontro ? '' : ultimo.domanda,
      via: incontro
          ? 'incontro'
          : scritta
              ? 'scelta'
              : 'scritta',
      tema: incontro ? '' : ultimo.temaDellaDomanda,
      oggetto: ultimo.oggetto,
      inizio: DateTime.utc(2026, 9, 15),
      strato: discese < IQuattroViaggi.quanteDiscese
          ? discese
          : IQuattroViaggi.quanteDiscese - 1,
      ereditato: true,
    );
  }

  Map<String, dynamic> toJson() => {
        'domanda': domanda,
        'via': via,
        'tema': tema,
        if (oggetto != null) 'oggetto': oggetto,
        'inizio': inizio.toIso8601String(),
        'strato': strato,
        if (ereditato) 'ereditato': true,
      };

  static IlCammino? fromJson(Map<String, dynamic> j) {
    final inizio = DateTime.tryParse('${j['inizio']}');
    if (inizio == null) return null;
    return IlCammino(
      domanda: '${j['domanda'] ?? ''}',
      via: '${j['via'] ?? 'scritta'}',
      tema: '${j['tema'] ?? ''}',
      oggetto: j['oggetto'] is String ? j['oggetto'] as String : null,
      inizio: inizio,
      strato: j['strato'] is int ? j['strato'] as int : 0,
      ereditato: j['ereditato'] == true,
    );
  }
}

/// **UN SEGNO RICEVUTO DALL'ANIMALE**, come si conserva. Ordine DI voce 14.
///
/// Si conserva il gesto per nome e la riga cosi' come e' stata letta: rileggere
/// un segno sei mesi dopo deve dare le stesse parole, non una riga nuova.
class SegnoRicevuto {
  const SegnoRicevuto({
    required this.quando,
    required this.domanda,
    required this.gesto,
    required this.riga,
  });

  final DateTime quando;
  final String domanda;

  /// Il nome del gesto nel repertorio chiuso, `GestoDelSegno.name`. **Dai
  /// segni scritti prima dell'ordine DJ voce 08 puo' essere uno dei tre gesti
  /// tolti**, e resta una riga da rileggere: il nome e la riga sono testo,
  /// e nessuno li riporta al repertorio. Il campo della cosa portata e' uscito
  /// col gesto che la portava.
  final String gesto;
  final String riga;

  Map<String, dynamic> toJson() => {
        'quando': quando.toIso8601String(),
        'domanda': domanda,
        'gesto': gesto,
        'riga': riga,
      };

  static SegnoRicevuto? fromJson(Map<String, dynamic> j) {
    final quando = DateTime.tryParse('${j['quando']}');
    final gesto = j['gesto'];
    final riga = j['riga'];
    if (quando == null || gesto is! String || riga is! String) return null;
    return SegnoRicevuto(
      quando: quando,
      domanda: '${j['domanda'] ?? ''}',
      gesto: gesto,
      riga: riga,
    );
  }
}
