import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../astro/natal_chart.dart';
import '../cammino/cammino_da_custodire.dart';
import '../astro/zodiac.dart';
import '../tempo/confine_del_giorno.dart';
import 'eventi_del_cielo.dart';
import 'sentieri.dart';

/// IL DIARIO DEL CAMMINO: cio' che hai fatto, quando lo hai fatto.
///
/// **Perche' nasce.** Prima dell'ordine O l'app sapeva pochissimo del tempo
/// passato dentro: la continuita' di due riti, i budget del giorno, tre
/// storici sparsi. Due terzi dei traguardi non sarebbero stati verificabili,
/// e un traguardo che non si puo' verificare e' una promessa. Questo e' il
/// registro, in un punto solo: i gesti compiuti, in che giorni, e quante
/// volte sono caduti nell'ora rituale giusta.
///
/// **Non e' una seconda porta dei contatori.** I budget del giorno restano
/// del server, con le loro regole: qui si registra la STORIA, che serve solo
/// a decidere se un Sigillo si accende. Sono due cose diverse, e tenerle
/// separate evita che un traguardo consumi una gettata.
class DiarioDelCammino extends ChangeNotifier {
  DiarioDelCammino({DateTime Function()? orologio})
      : _orologio = orologio ?? DateTime.now;

  final DateTime Function() _orologio;

  static const _kGesti = 'cammino.gesti';
  static const _kGiorni = 'cammino.giorni';
  static const _kOggi = 'cammino.oggi';
  static const _kGiornoDiOggi = 'cammino.giornoDiOggi';
  static const _kOre = 'cammino.ore';
  static const _kPrimoGiorno = 'cammino.primoGiorno';
  static const _kUltimoGiorno = 'cammino.ultimoGiorno';
  static const _kAccesi = 'cammino.accesi';
  /// **QUANDO OGNI SIGILLO SI E' ACCESO, ordine AP voce 01.** Serviva al
  /// Cerchio per custodire il cammino: un Sigillo si accende una volta sola,
  /// e quella data e' un primato che la fusione difende. Prima esisteva solo
  /// l'elenco, senza il quando.
  static const _kQuandoAccesi = 'cammino.accesi.quando';
  static const _kCondivisi = 'cammino.condivisi';
  static const _kSerie = 'cammino.serie';
  static const _kUltimoPerRito = 'cammino.ultimoPerRito';

  /// **CIO' CHE LA SCENA SAPEVA, ordine AR voce 11.** Non basta sapere che una
  /// stesa e' stata fatta: le condizioni nuove del Cammino chiedono la
  /// VARIETA' (tutti e quattro i semi, tutte le ventiquattro rune) e la
  /// COINCIDENZA (la stessa carta in due stese). Sono domande sui dettagli,
  /// e un gesto senza dettagli non potra' mai rispondere.
  static const _kDettagli = 'cammino.dettagli';

  final Map<String, int> _gestiCompiuti = {};
  final Map<String, int> _giorniConGesto = {};
  final Map<String, int> _gestiNellOraGiusta = {};

  /// I dettagli visti, per `gesto.chiave` e poi per valore: quante volte quel
  /// valore e' comparso. Con questa forma si risponde a tutte e due le
  /// domande: quanti valori DIVERSI si sono visti, e quante volte e' tornato
  /// il piu' insistente.
  final Map<String, Map<String, int>> _dettagli = {};

  /// **QUANTO PESA SUL DISCO, dichiarato.** Al massimo questo numero di
  /// valori distinti per chiave: le carte sono settantotto, le rune
  /// ventiquattro, gli argomenti sedici, i semi quattro, quindi centoventotto
  /// tiene tutti i domini veri con margine. Oltre il tetto non si aggiungono
  /// valori NUOVI, e quelli gia' presenti continuano a contare: si perde la
  /// varieta' oltre il tetto, mai una coincidenza gia' cominciata. Non e' uno
  /// storico: non si tengono ne' le date ne' l'ordine, solo quante volte.
  static const int quantiValoriPerChiave = 128;

  /// LA CONTINUITA' PER RITO, ordine P voce 35.
  ///
  /// **Prima non esisteva, e nessuno se n'era accorto.** La regia chiamava
  /// `statoDelCammino(seriePerRito: const {})`, cioe' passava sempre una
  /// mappa vuota: TUTTI i traguardi `GiorniDiSeguito` erano irraggiungibili,
  /// dai cinque dell'alba ai cinque del tramonto. E' la stessa famiglia della
  /// stesa scollegata: un dato che nessuno alimentava.
  final Map<String, int> _seriePerRito = {};
  final Map<String, String> _ultimoGiornoPerRito = {};
  final Set<String> _oggiHaFatto = {};
  String _giornoDiOggi = '';
  String? _primoGiorno;
  String? _ultimoGiorno;
  int _giorniDiAssenza = 0;

  /// I traguardi gia' accesi, per id. Un Sigillo acceso non si spegne mai.
  final Set<String> _accesi = {};
  final Map<String, String> _quandoAccesi = {};

  /// I traguardi la cui card e' gia' stata condivisa: serve a sapere se il
  /// bonus in Eos e' ancora in sospeso.
  final Set<String> _condivisi = {};

  Set<String> get accesi => Set.unmodifiable(_accesi);

  /// Quando quel Sigillo si e' acceso, se il diario lo sa. I Sigilli accesi
  /// prima dell'ordine AP non hanno data, e non se ne inventa una.
  DateTime? quandoSiEAcceso(String id) {
    final quando = _quandoAccesi[id];
    return quando == null ? null : DateTime.tryParse(quando);
  }

  /// Il primo e l'ultimo giorno di cammino, per il Cerchio che li custodisce.
  DateTime? get primoGiorno =>
      _primoGiorno == null ? null : DateTime.tryParse(_primoGiorno!);
  DateTime? get ultimoGiorno =>
      _ultimoGiorno == null ? null : DateTime.tryParse(_ultimoGiorno!);
  Set<String> get condivisi => Set.unmodifiable(_condivisi);
  int get giorniDiAssenzaPrimaDiOggi => _giorniDiAssenza;

  bool eAcceso(String id) => _accesi.contains(id);
  bool eStatoCondiviso(String id) => _condivisi.contains(id);

  /// Quanti giorni sono passati dal primo giorno nel Cerchio.
  int get giorniDalPrimoGiorno {
    if (_primoGiorno == null) return 0;
    final primo = DateTime.tryParse(_primoGiorno!);
    if (primo == null) return 0;
    return _orologio().difference(primo).inDays;
  }

  /// QUANDO IL DIARIO E' PRONTO. Ordine AN voce 04.
  ///
  /// Il caricamento e' asincrono e l'app lo lancia col provider
  /// (`DiarioDelCammino()..carica()`), quindi al primo fotogramma il diario
  /// e' ancora VUOTO. Chi decide qualcosa in base a cosa e' acceso, come la
  /// sincronia dei premi persi, senza questa attesa guardava un cammino
  /// vuoto e concludeva che non c'era niente da riprendere: e' il difetto
  /// che Mauro ha visto sulla 2181, dove il saldo e' rimasto a zero fino al
  /// gesto successivo.
  Future<void> get pronto => _pronto.future;
  final Completer<void> _pronto = Completer<void>();

  /// **IL CARICAMENTO NON CANCELLA CIO' CHE E' STATO SCRITTO NEL FRATTEMPO.
  /// Ordine AO voce 04.**
  ///
  /// Il difetto stava qui, e il sintomo era lontano: Mauro vedeva che non
  /// tutti i premi dei traguardi arrivavano. Il filo dei premi era intero,
  /// provato passo per passo; a mancare era il TRAGUARDO, che non maturava
  /// perche' il conto dei gesti si azzerava. Chi apriva l'app e faceva
  /// subito qualcosa incontrava questa sequenza: il caricamento partiva e
  /// andava a leggere il disco, che e' lento; `segna` contava il gesto su
  /// mappe ancora VUOTE, portando le stese da tre a uno; salvava quel conto
  /// povero SUL DISCO, cancellando la storia; e infine il caricamento
  /// atterrava e sostituiva tutto con cio' che era appena stato scritto.
  /// Il difetto era gia' stato incontrato una volta, e aggirato dentro una
  /// prova invece che curato qui: il commento della guardia della lampadina
  /// lo descriveva parola per parola.
  ///
  /// **Perche' si fonde invece di aspettare.** La prima cura faceva
  /// attendere ogni scrittura fino a lettura avvenuta, ed era giusta
  /// nell'app ma velenosa nelle prove: un gesto compiuto nel tempo VERO
  /// mentre il caricamento dorme nel tempo FINTO aspetta una risposta che
  /// non arrivera' mai, e la prova resta appesa otto minuti invece di
  /// cadere. Misurato su due guardie. La fusione non aspetta niente e
  /// nessuno: chi scrive scrive subito, e il caricamento, quando atterra,
  /// SOMMA la storia del disco a cio' che nel frattempo e' successo invece
  /// di sostituirla. Per i conteggi la somma e' la semantica giusta, perche'
  /// il gesto in volo ha contato uno partendo da zero; per gli elenchi lo e'
  /// l'unione, perche' nessun Sigillo acceso deve sparire.
  bool _discoLetto = false;
  bool _scrittoPrimaDiLeggere = false;

  Future<void> carica() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // **SI FONDE SE QUALCUNO HA SCRITTO MENTRE LEGGEVAMO**, e si sostituisce
      // se il disco e' l'unica verita' esistente. Vedi la spiegazione sopra:
      // e' la cura del conto dei gesti che si azzerava.
      final fondi = _scrittoPrimaDiLeggere;
      _leggiMappa(prefs.getString(_kGesti), _gestiCompiuti, sommando: fondi);
      _leggiMappa(prefs.getString(_kGiorni), _giorniConGesto, sommando: fondi);
      _leggiMappa(prefs.getString(_kOre), _gestiNellOraGiusta, sommando: fondi);
      _leggiIDettagli(prefs.getString(_kDettagli), sommando: fondi);
      if (!fondi) _giornoDiOggi = prefs.getString(_kGiornoDiOggi) ?? '';
      _oggiHaFatto.addAll(prefs.getStringList(_kOggi) ?? const []);
      // Il primo giorno e' il PIU' VECCHIO dei due, mai quello nato adesso.
      _primoGiorno = prefs.getString(_kPrimoGiorno) ?? _primoGiorno;
      if (!fondi) _ultimoGiorno = prefs.getString(_kUltimoGiorno);
      _accesi.addAll(prefs.getStringList(_kAccesi) ?? const []);
      _leggiTesti(prefs.getString(_kQuandoAccesi), _quandoAccesi);
      _condivisi.addAll(prefs.getStringList(_kCondivisi) ?? const []);
      // La serie di giorni di seguito NON si somma: si tiene la piu' lunga,
      // perche' due conteggi dello stesso giorno non fanno due giorni.
      _leggiMappa(prefs.getString(_kSerie), _seriePerRito,
          tenendoIlMassimo: fondi);
      _leggiTesti(prefs.getString(_kUltimoPerRito), _ultimoGiornoPerRito);
      _discoLetto = true;
      _apriIlGiorno();
      notifyListeners();
      // Cio' che si e' fuso vive solo in memoria finche' non si riscrive.
      if (fondi) await _salva();
    } catch (errore) {
      // Si ignora: un diario illeggibile vale come diario vuoto. Il cammino
      // riparte, e i Sigilli gia' accesi che il server conosce torneranno
      // quando la sincronia col Cerchio li riportera'.
    } finally {
      _discoLetto = true;
      // PRONTO ANCHE SE LA LETTURA E' FALLITA: chi aspetta deve ripartire
      // comunque, altrimenti un disco illeggibile bloccherebbe per sempre
      // chi sta in attesa.
      if (!_pronto.isCompleted) _pronto.complete();
    }
  }

  /// APRE IL GIORNO: se e' cambiato, svuota cio' che si e' fatto oggi e
  /// calcola quanti giorni di silenzio ci sono stati.
  void _apriIlGiorno() {
    final oggi = ConfineDelGiorno.chiaveDi(_orologio());
    if (_giornoDiOggi == oggi) return;
    _giornoDiOggi = oggi;
    _oggiHaFatto.clear();
    final ultimo = _ultimoGiorno == null ? null : DateTime.tryParse(_ultimoGiorno!);
    _giorniDiAssenza =
        ultimo == null ? 0 : _orologio().difference(ultimo).inDays - 1;
    if (_giorniDiAssenza < 0) _giorniDiAssenza = 0;
  }

  /// REGISTRA UN GESTO. E' l'unico modo di scrivere nel diario, e le schermate
  /// lo chiamano dal punto in cui il gesto e' davvero compiuto: non
  /// all'apertura di una scena, che si apre anche per sbaglio.
  Future<void> segna(
    String gesto, {
    String? oraRituale,
    Map<String, Object?> dettagli = const {},
  }) async {
    _scrittoPrimaDiLeggere = !_discoLetto;
    _apriIlGiorno();
    _gestiCompiuti[gesto] = (_gestiCompiuti[gesto] ?? 0) + 1;
    _registraIDettagli(gesto, dettagli);
    if (_oggiHaFatto.add(gesto)) {
      _giorniConGesto[gesto] = (_giorniConGesto[gesto] ?? 0) + 1;
      _aggiornaLaSerie(gesto);
    }
    if (oraRituale != null) {
      final chiave = '$gesto@$oraRituale';
      _gestiNellOraGiusta[chiave] = (_gestiNellOraGiusta[chiave] ?? 0) + 1;
    }
    final oggi = ConfineDelGiorno.chiaveDi(_orologio());
    _primoGiorno ??= _orologio().toIso8601String();
    _ultimoGiorno = _orologio().toIso8601String();
    _giornoDiOggi = oggi;
    notifyListeners();
    await _salva();
  }

  /// Rilegge i dettagli dal disco. Somma quando il caricamento sta fondendo,
  /// per la stessa ragione dei conteggi (ordine AO voce 04): un dettaglio
  /// registrato mentre il disco veniva letto non deve sparire.
  void _leggiIDettagli(String? grezzo, {required bool sommando}) {
    if (grezzo == null) return;
    try {
      final letto = jsonDecode(grezzo);
      if (letto is! Map) return;
      for (final voce in letto.entries) {
        final dentro = voce.value;
        if (dentro is! Map) continue;
        final mio = _dettagli.putIfAbsent(
            voce.key.toString(), () => <String, int>{});
        for (final v in dentro.entries) {
          final quante = v.value is int ? v.value as int : 0;
          if (quante <= 0) continue;
          final chiave = v.key.toString();
          if (!mio.containsKey(chiave) &&
              mio.length >= quantiValoriPerChiave) {
            continue;
          }
          mio[chiave] = sommando ? (mio[chiave] ?? 0) + quante : quante;
        }
      }
    } catch (errore) {
      // Una voce illeggibile vale zero, e il cammino continua.
    }
  }

  /// **COSA SI TIENE DI UN DETTAGLIO, e cosa no.** Si tengono i valori come
  /// stringhe e quante volte sono comparsi. Non si tiene quando, non si
  /// tiene in che ordine, e non si tiene niente che la scena non abbia gia'
  /// in mano: dove un dato utile non c'e', non si inventa.
  void _registraIDettagli(String gesto, Map<String, Object?> dettagli) {
    for (final voce in dettagli.entries) {
      final valori = <String>[];
      final v = voce.value;
      if (v == null) continue;
      if (v is Iterable) {
        valori.addAll(v.map((e) => e.toString()).where((s) => s.isNotEmpty));
      } else {
        final s = v.toString();
        if (s.isNotEmpty) valori.add(s);
      }
      if (valori.isEmpty) continue;
      final chiave = '$gesto.${voce.key}';
      final dentro = _dettagli.putIfAbsent(chiave, () => <String, int>{});
      for (final valore in valori) {
        if (!dentro.containsKey(valore) &&
            dentro.length >= quantiValoriPerChiave) {
          continue;
        }
        dentro[valore] = (dentro[valore] ?? 0) + 1;
      }
    }
  }

  /// Quanti valori DIVERSI si sono visti per quel dettaglio: la varieta'.
  /// "Tutti e quattro i semi" e' questo numero uguale a quattro.
  int quantiValoriDistinti(String gesto, String chiave) =>
      _dettagli['$gesto.$chiave']?.length ?? 0;

  /// Quante volte e' tornato il valore piu' insistente: la coincidenza.
  /// "La stessa carta in due stese" e' questo numero maggiore o uguale a due.
  int massimaRipetizione(String gesto, String chiave) {
    final dentro = _dettagli['$gesto.$chiave'];
    if (dentro == null || dentro.isEmpty) return 0;
    return dentro.values.reduce((a, b) => a > b ? a : b);
  }

  /// Quante volte si e' visto proprio quel valore.
  int quanteVolteIlValore(String gesto, String chiave, String valore) =>
      _dettagli['$gesto.$chiave']?[valore] ?? 0;

  /// LA SERIE DI UN RITO: quanti giorni di seguito, senza buchi.
  ///
  /// Un giorno saltato la azzera, ed e' il punto: una continuita' che
  /// perdona non e' una continuita', e i traguardi di ritorno esistono
  /// proprio perche' non si possono affrettare.
  void _aggiornaLaSerie(String gesto) {
    final oggi = ConfineDelGiorno.chiaveDi(_orologio());
    final ieri =
        ConfineDelGiorno.chiaveDi(_orologio().subtract(const Duration(days: 1)));
    final ultimo = _ultimoGiornoPerRito[gesto];
    if (ultimo == oggi) return;
    _seriePerRito[gesto] = ultimo == ieri ? (_seriePerRito[gesto] ?? 0) + 1 : 1;
    _ultimoGiornoPerRito[gesto] = oggi;
  }

  /// La continuita' corrente di ogni rito, per la fotografia del cammino.
  Map<String, int> get seriePerRito {
    final oggi = ConfineDelGiorno.chiaveDi(_orologio());
    final ieri =
        ConfineDelGiorno.chiaveDi(_orologio().subtract(const Duration(days: 1)));
    // Una serie vale solo se l'ultimo giorno e' oggi o ieri: altrimenti e'
    // gia' rotta, e leggerla intera direbbe il falso fino al gesto seguente.
    return {
      for (final voce in _seriePerRito.entries)
        if (_ultimoGiornoPerRito[voce.key] == oggi ||
            _ultimoGiornoPerRito[voce.key] == ieri)
          voce.key: voce.value,
    };
  }

  /// Se un gesto e' stato compiuto almeno una volta, da sempre.
  bool haFatto(String gesto) => (_gestiCompiuti[gesto] ?? 0) > 0;

  /// Accende un Sigillo. Torna vero se si e' acceso adesso, cosi' chi chiama
  /// sa se deve celebrare: accendere due volte lo stesso Sigillo non
  /// celebrerebbe niente, festeggerebbe un ricordo.
  Future<bool> accendi(String id) async {
    _scrittoPrimaDiLeggere = !_discoLetto;
    if (!_accesi.add(id)) return false;
    _quandoAccesi[id] = _orologio().toIso8601String();
    notifyListeners();
    await _salva();
    return true;
  }

  /// ADOTTA IL CAMMINO CHE IL CERCHIO HA RESTITUITO. Ordine AP voci 02 e 03.
  ///
  /// **Non e' una sostituzione cieca, e non lo e' per costruzione**: cio' che
  /// arriva e' GIA' la fusione fra questo telefono e il Cerchio, fatta dal
  /// server, dove per ogni contatore ha vinto il piu' alto e i Sigilli si
  /// sono uniti. Adottarla non puo' quindi togliere niente a nessuno.
  ///
  /// **E si difende comunque**, perche' una risposta puo' arrivare da un
  /// server piu' vecchio o da una rete che ha rotto qualcosa: si prende il
  /// massimo fra cio' che c'e' e cio' che arriva, esattamente come fa la
  /// fusione, e i Sigilli si uniscono invece di sostituirsi. E' la lezione
  /// della voce AO.04: una scrittura non deve mai poter distruggere.
  /// **IL CAMMINO RIPARTE DA ZERO, ordine AR voce 06.** Svuota cio' che sta
  /// in MEMORIA, non solo sul disco: cancellare le chiavi e basta lascerebbe
  /// i conti vivi dentro questo oggetto, e il primo salvataggio successivo li
  /// riscriverebbe tali e quali. Il saldo Eos non abita qui e non viene
  /// toccato da nessuna di queste righe.
  Future<void> azzeraPerLaRinascita() async {
    _gestiCompiuti.clear();
    _giorniConGesto.clear();
    _gestiNellOraGiusta.clear();
    _dettagli.clear();
    _ultimoGiornoPerRito.clear();
    _oggiHaFatto.clear();
    _accesi.clear();
    _quandoAccesi.clear();
    _condivisi.clear();
    _seriePerRito.clear();
    _primoGiorno = null;
    _ultimoGiorno = null;
    _giornoDiOggi = '';
    await _salva();
    notifyListeners();
  }

  Future<void> adottaIlCammino(CamminoDaCustodire cammino) async {
    void massimo(Map<String, int> dentro, Map<String, int> arrivati) {
      for (final voce in arrivati.entries) {
        final gia = dentro[voce.key] ?? 0;
        if (voce.value > gia) dentro[voce.key] = voce.value;
      }
    }

    massimo(_gestiCompiuti, cammino.gesti);
    massimo(_giorniConGesto, cammino.giorni);
    massimo(_gestiNellOraGiusta, cammino.oreGiuste);
    massimo(_seriePerRito, cammino.serie);
    for (final voce in cammino.sigilli.entries) {
      _accesi.add(voce.key);
      final gia = _quandoAccesi[voce.key];
      final arrivato = voce.value.toIso8601String();
      // La data piu' vecchia vince: un Sigillo si accende una volta sola.
      if (gia == null || arrivato.compareTo(gia) < 0) {
        _quandoAccesi[voce.key] = arrivato;
      }
    }
    final primo = cammino.primoGiorno?.toIso8601String();
    if (primo != null && (_primoGiorno == null || primo.compareTo(_primoGiorno!) < 0)) {
      _primoGiorno = primo;
    }
    notifyListeners();
    await _salva();
  }

  Future<void> segnaCondiviso(String id) async {
    _scrittoPrimaDiLeggere = !_discoLetto;
    if (!_condivisi.add(id)) return;
    notifyListeners();
    await _salva();
  }

  /// LA FOTOGRAFIA su cui si misurano i traguardi.
  StatoDelCammino statoDelCammino({
    NatalChart? carta,
    Zodiac? segno,
    Map<String, int> seriePerRito = const {},
    Set<String> pezziDellIdentita = const {},
    Map<String, int> memoria = const {},
  }) {
    _apriIlGiorno();
    return StatoDelCammino(
      gestiCompiuti: Map.unmodifiable(_gestiCompiuti),
      giorniConGesto: Map.unmodifiable(_giorniConGesto),
      oggiHaFatto: Set.unmodifiable(_oggiHaFatto),
      seriePerRito: seriePerRito,
      gestiNellOraGiusta: Map.unmodifiable(_gestiNellOraGiusta),
      eventiDelCieloDiOggi: EventiDelCielo.diOggi(
        adesso: _orologio(),
        carta: carta,
        segno: segno,
      ),
      pezziDellIdentita: pezziDellIdentita,
      memoria: memoria,
      giorniDiAssenzaPrimaDiOggi: _giorniDiAssenza,
      giorniDalPrimoGiorno: giorniDalPrimoGiorno,
      // **I DETTAGLI ENTRANO NELLA FOTOGRAFIA, ordine AR voce 11.** Da qui
      // le condizioni di varieta' e coincidenza possono guardarli senza
      // conoscere il diario: la fotografia resta l'unica porta.
      valoriDistinti: {
        for (final voce in _dettagli.entries) voce.key: voce.value.length,
      },
      massimeRipetizioni: {
        for (final voce in _dettagli.entries)
          if (voce.value.isNotEmpty)
            voce.key: voce.value.values.reduce((a, b) => a > b ? a : b),
      },
      // **I GRADINI ALLE SPALLE, per la famiglia Dedizione.** Si contano i
      // Sigilli accesi di quel sentiero: e' un conto di TRAGUARDI, non di
      // gesti, ed e' l'unico posto dove il conteggio sopravvive.
      gradiniAlleSpalle: {
        for (final s in Sentiero.values) s.name: quantiAccesiDi(s),
      },
    );
  }

  /// I TRAGUARDI CHE SI SONO APPENA ACCESI, in ordine di posizione.
  ///
  /// Si guarda tutto in un colpo solo dopo un gesto: valutare un traguardo
  /// alla volta, ognuno col suo controllo sparso, sarebbe il modo sicuro di
  /// dimenticarne qualcuno.
  Future<List<Traguardo>> quelliCheSiAccendono(StatoDelCammino stato) async {
    final nuovi = <Traguardo>[];
    for (final traguardo in Sentieri.tuttiITraguardi) {
      if (_accesi.contains(traguardo.id)) continue;
      // **UN DORMIENTE NON ARMA MAI, ordine AR voce 05.** La sua condizione
      // gia' risponde falso a qualunque stato, e questa riga e' la seconda
      // serratura: se un domani qualcuno gli desse per sbaglio una condizione
      // vera senza toglierlo dai dormienti, non si accenderebbe lo stesso, e
      // il difetto si vedrebbe dove va guardato, cioe' nel dato.
      if (traguardo.dormiente) continue;
      if (!traguardo.condizione.raggiunto(stato)) continue;
      nuovi.add(traguardo);
    }
    nuovi.sort((a, b) => a.posizione.compareTo(b.posizione));
    return nuovi;
  }

  /// Il prossimo traguardo di un sentiero, cioe' il primo non ancora acceso.
  /// Serve alla celebrazione, che non finisce mai col punto.
  /// **CIO' CHE SI STA CELEBRANDO NON E' IL PROSSIMO, ordine AR voce 07.**
  /// La festa si apre nell'istante in cui un traguardo matura, e se quel
  /// traguardo non e' ancora segnato acceso questa ricerca lo trova per primo
  /// e lo annuncia come il prossimo: e' il difetto visto nell'anteprima
  /// dell'ordine AQ, dove in fondo alla festa si leggeva il nome appena
  /// festeggiato. Chi celebra passa gli id in `escludendo` e la risposta non
  /// dipende piu' dall'ordine con cui arrivano l'accensione e la scena.
  Traguardo? prossimoDi(Sentiero sentiero, {Set<String> escludendo = const {}}) {
    // **LA SCALA SCAVALCA I DORMIENTI, ordine AR voce 05.** Se il prossimo
    // gradino fosse uno che non si puo' raggiungere, la scala si bloccherebbe
    // li' per sempre e il sentiero finirebbe in un vicolo cieco: si arma il
    // successivo, e il Journal mostra il dormiente come in arrivo.
    bool libero(Traguardo t) =>
        !_accesi.contains(t.id) &&
        !escludendo.contains(t.id) &&
        !t.dormiente;
    for (final t in Sentieri.miniDi(sentiero)) {
      if (libero(t)) return t;
    }
    for (final t in Sentieri.grandiDi(sentiero)) {
      if (libero(t)) return t;
    }
    return null;
  }

  /// Quanti traguardi accesi su un sentiero.
  int quantiAccesiDi(Sentiero sentiero) =>
      Sentieri.di(sentiero).where((t) => _accesi.contains(t.id)).length;

  void _leggiTesti(String? grezzo, Map<String, String> dentro) {
    if (grezzo == null) return;
    try {
      final letto = jsonDecode(grezzo);
      if (letto is! Map) return;
      dentro.clear();
      for (final voce in letto.entries) {
        if (voce.value is String) dentro['${voce.key}'] = voce.value as String;
      }
    } catch (errore) {
      // Un dato illeggibile vale come dato assente.
    }
  }

  /// Legge una mappa di conteggi dal disco.
  ///
  /// **Tre modi, e ognuno ha il suo caso.** Di regola SOSTITUISCE, perche' il
  /// disco e' la verita' e in memoria non c'e' niente. Se qualcuno ha scritto
  /// mentre leggevamo, ordine AO voce 04, allora SOMMA, perche' il gesto in
  /// volo ha contato uno partendo da zero e la storia del disco va davanti a
  /// lui. Per le serie di giorni di seguito si tiene il MASSIMO: due
  /// conteggi dello stesso giorno non fanno due giorni.
  void _leggiMappa(String? testo, Map<String, int> dentro,
      {bool sommando = false, bool tenendoIlMassimo = false}) {
    final fondi = sommando || tenendoIlMassimo;
    if (!fondi) dentro.clear();
    if (testo == null || testo.isEmpty) return;
    try {
      final letto = jsonDecode(testo);
      if (letto is! Map) return;
      for (final voce in letto.entries) {
        final valore = voce.value;
        if (valore is! num) continue;
        final chiave = '${voce.key}';
        final daDisco = valore.toInt();
        final inMemoria = dentro[chiave] ?? 0;
        dentro[chiave] = tenendoIlMassimo
            ? (daDisco > inMemoria ? daDisco : inMemoria)
            : (sommando ? inMemoria + daDisco : daDisco);
      }
    } catch (errore) {
      // Si ignora: una voce illeggibile vale zero, e il cammino continua.
    }
  }

  Future<void> _salva() async {
    // **NON SI SCRIVE PRIMA DI AVER LETTO. Ordine AO voce 04.** Scrivere ora
    // vorrebbe dire cancellare dal disco la storia che il caricamento sta
    // ancora leggendo, e la fusione, quando atterra, troverebbe un disco gia'
    // povero: le stese tornavano due invece di quattro, misurato. Non e'
    // un'attesa, e' un rinvio: il caricamento salva lui appena ha fuso, e
    // sono i millisecondi di una lettura da disco.
    if (!_discoLetto) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kGesti, jsonEncode(_gestiCompiuti));
      await prefs.setString(_kGiorni, jsonEncode(_giorniConGesto));
      await prefs.setString(_kOre, jsonEncode(_gestiNellOraGiusta));
      await prefs.setStringList(_kOggi, _oggiHaFatto.toList());
      await prefs.setString(_kGiornoDiOggi, _giornoDiOggi);
      await prefs.setStringList(_kAccesi, _accesi.toList());
      await prefs.setString(_kQuandoAccesi, jsonEncode(_quandoAccesi));
      await prefs.setString(_kDettagli, jsonEncode(_dettagli));
      await prefs.setStringList(_kCondivisi, _condivisi.toList());
      if (_primoGiorno != null) {
        await prefs.setString(_kPrimoGiorno, _primoGiorno!);
      }
      if (_ultimoGiorno != null) {
        await prefs.setString(_kUltimoGiorno, _ultimoGiorno!);
      }
      await prefs.setString(_kSerie, jsonEncode(_seriePerRito));
      await prefs.setString(
          _kUltimoPerRito, jsonEncode(_ultimoGiornoPerRito));
    } catch (errore) {
      // Si ignora: senza disco il cammino vale per questa sessione. Meglio
      // un Sigillo che vive un giorno di un\'app che cade mentre festeggia.
    }
  }
}
