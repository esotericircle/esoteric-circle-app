import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../astro/natal_chart.dart';
import '../cammino/cammino_da_custodire.dart';
import '../astro/zodiac.dart';
import '../tempo/confine_del_giorno.dart';
import 'eventi_del_cielo.dart';
import 'maestro_del_gesto.dart';
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
  /// **DIMENTICA CHI SE NE VA. Ordine BC voce 02.**
  ///
  /// **Il fatto del fondatore**: "ho provato a cancellare l'account, ma i dati
  /// restano... il borsellino, i traguardi e altri dati attualmente restano
  /// anche dopo la conferma della cancellazione."
  ///
  /// **La causa**: cancellare toglieva le chiavi dal disco e chiudeva la
  /// sessione, ma **i controller vivono per tutta la sessione dell'app** e
  /// nessuno li svuotava. Quello che si vedeva a schermo era la memoria, non
  /// il disco, e alla prima scrittura tornava anche sul disco.
  ///
  /// Non si tocca il server: qui si dimentica soltanto cio' che si ricorda.
  void dimenticaChiSeNeVa() {
    _gestiCompiuti.clear();
    _giorniConGesto.clear();
    _gestiNellOraGiusta.clear();
    _oraDelGesto.clear();
    _ultimoGiornoPerOra.clear();
    _dettagli.clear();
    _dettagliRecenti.clear();
    _seriePerRito.clear();
    _ultimoGiornoPerRito.clear();
    _giorniPerRito.clear();
    _oggiHaFatto.clear();
    _oggiHaFattoNellOra.clear();
    _accesi.clear();
    _daCongedare = null;
    _gestiGiaContatiOggi.clear();
    _quandoAccesi.clear();
    _condivisi.clear();
    notifyListeners();
  }

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
  static const _kDaCongedare = 'cammino.daCongedare';
  static const _kGiaContatiOggi = 'cammino.giaContatiOggi';

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
  static const _kGiorniPerRito = 'cammino.giorniPerRito';

  /// **L'ORA FEDELE, ordine BW voce 07.** Per '$gesto@$ora', in quanti
  /// giorni DIVERSI quel gesto e' caduto in quell'ora dell'orologio. Non
  /// e' l'ora rituale, che dice alba, tramonto o notte: e' l'ora vera,
  /// quella che distingue chi apre l'Oroscopo sempre alle sette da chi lo
  /// apre quando capita.
  static const _kOraDelGesto = 'cammino.oraDelGesto';
  static const _kUltimoGiornoPerOra = 'cammino.ultimoGiornoPerOra';
  static const _kOggiNellOra = 'cammino.oggiNellOra';
  static const _kUltimoPerSentiero = 'cammino.ultimoPerSentiero';
  static const _kDettagliRecenti = 'cammino.dettagliRecenti';

  final Map<String, int> _gestiCompiuti = {};
  final Map<String, int> _giorniConGesto = {};
  final Map<String, int> _gestiNellOraGiusta = {};

  /// Per '$gesto@$ora', quanti giorni diversi. Ordine BW voce 07.
  final Map<String, int> _oraDelGesto = {};

  /// L'ultimo giorno contato per ogni '$gesto@$ora': senza di lui cinque
  /// aperture nello stesso pomeriggio varrebbero cinque giorni.
  final Map<String, String> _ultimoGiornoPerOra = {};

  /// I dettagli visti, per `gesto.chiave` e poi per valore: quante volte quel
  /// valore e' comparso. Con questa forma si risponde a tutte e due le
  /// domande: quanti valori DIVERSI si sono visti, e quante volte e' tornato
  /// il piu' insistente.
  final Map<String, Map<String, int>> _dettagli = {};

  /// **I DETTAGLI CON LA LORO DATA, ordine BX voce 01.** Per
  /// 'gesto.chiave', un elenco di 'valore|giorno'. La mappa qui sopra
  /// conta da sempre e non sa rispondere a "due volte in una
  /// settimana": quella domanda ha bisogno delle date, e sono queste.
  ///
  /// **Quanto pesa e' dichiarato**: al massimo [quantiDettagliRecenti]
  /// voci per chiave, le piu' recenti, che coprono con margine le
  /// finestre che il corpus chiede.
  final Map<String, List<String>> _dettagliRecenti = {};

  /// Quante voci datate si tengono per chiave.
  static const int quantiDettagliRecenti = 60;

  /// **LE FINESTRE CHE IL CORPUS CHIEDE**, e nessun'altra: chiederle
  /// tutte sarebbe un conto per ogni giorno possibile, per rispondere a
  /// domande che nessun traguardo fa.
  static const List<int> finestreDeiDettagli = [7, 30];

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

  /// **I GIORNI RECENTI DI OGNI RITO. Ordine AS voce 12, corpus D.**
  ///
  /// **Perche' nasce.** Il corpus della revisione D cambia ventidue gradini di
  /// costanza: non chiedono piu' giorni CONSECUTIVI ma tanti giorni dentro un
  /// arco piu' largo, "sette in dieci", "quattordici in venti", "trenta in
  /// quarantacinque". La ragione la spiega la misura della voce AR.04: con la
  /// serie consecutiva chi non apre l'app tutti i giorni non completa mai una
  /// serie, e la scala essendo sequenziale si BLOCCA li' per sempre.
  ///
  /// La serie consecutiva non basta a rispondere: dice quanti giorni di fila,
  /// non quanti dentro una finestra. Serve l'elenco dei giorni, e questo e'.
  ///
  /// **Non e' uno storico infinito**: si tengono al massimo
  /// [quantiGiorniPerRito] giorni per rito, che coprono l'arco piu' largo del
  /// corpus con margine.
  final Map<String, List<String>> _giorniPerRito = {};

  /// **QUANTO PESA SUL DISCO, dichiarato.** Ordine CP voce 05: la revisione F
  /// del corpus porta archi fino a trecentoquaranta giorni e giornate chiuse
  /// insieme fino a trecento, e centoquaranta li avrebbe murati in silenzio.
  /// **Un traguardo che nessuno puo' raggiungere non e' difficile, e' un
  /// muro**, ed e' esattamente il difetto che l'ordine AS aveva chiuso per la
  /// serie consecutiva. Quattrocento giorni tengono l'arco piu' largo con
  /// margine: sono undici byte per giorno, cioe' circa quattro chilobyte e
  /// mezzo per rito e sotto i novanta per l'intero cammino.
  static const int quantiGiorniPerRito = 400;
  final Set<String> _oggiHaFatto = {};

  /// **CIO' CHE OGGI E' CADUTO IN UN'ORA RITUALE, ordine BW voce 07.**
  /// Le chiavi sono '$gesto@$ora'. Vive quanto il giorno: si svuota
  /// insieme a [_oggiHaFatto], perche' la domanda che serve e'
  /// "stanotte", non "qualche notte".
  final Set<String> _oggiHaFattoNellOra = {};

  /// L'ultimo giorno in cui si e' cercato un Maestro, per sentiero.
  /// Ordine BW voce 07.
  final Map<String, String> _ultimoGiornoPerSentiero = {};

  /// Quanti giorni erano passati dall'ultima volta, per sentiero.
  /// Si calcola quando il gesto arriva e resta li' per la giornata.
  final Map<String, int> _assenzaDalSentiero = {};
  String _giornoDiOggi = '';
  String? _primoGiorno;
  String? _ultimoGiorno;
  int _giorniDiAssenza = 0;

  /// I traguardi gia' accesi, per id. Un Sigillo acceso non si spegne mai.
  final Set<String> _accesi = {};

  /// **IL GRADINO ACCESO CHE ASPETTA DI ESSERE CONGEDATO.**
  /// Ordine CP voce 01, 3 settembre 2026.
  ///
  /// Decisione del fondatore, parole sue: *"il gradino non matura finche' il
  /// precedente non e' stato congedato."*
  ///
  /// **Nullo vuol dire che la strada e' libera.** Quando un gradino si
  /// accende, il suo id finisce qui e **nessun altro gradino puo' maturare**
  /// finche' la sua festa non e' stata vista e chiusa. Congedare vuol dire
  /// esattamente questo: la festa e' comparsa a schermo e la persona l'ha
  /// lasciata andare.
  ///
  /// **Perche' uno solo e non uno per sentiero.** La prima regola del
  /// fondatore, quella del 17 agosto 2026, dice *"non deve esserci la
  /// possibilita' di raggiungere piu' di un traguardo alla volta"*, e non dice
  /// "piu' di uno per sentiero". Con un posto per sentiero un gesto che tocca
  /// tre arti ne farebbe maturare tre insieme, che e' esattamente cio' che la
  /// regola vieta. Un posto solo, in tutto il Cammino.
  ///
  /// **E si libera anche quando la festa non si e' vista.** Una festa che non
  /// trova dove aprirsi torna in coda, e se il posto restasse occupato il
  /// Cammino si murerebbe per sempre: chi rimette in coda congeda.
  String? _daCongedare;

  /// **I GESTI GIA' CONTATI OGGI, con i loro dettagli.**
  /// Ordine CP voce 02, 3 settembre 2026.
  ///
  /// Il fondatore ha visto otto feste in due funzionalita', quattro delle
  /// quali interrogando l'Oroscopo quattro volte. **Il difetto non era il
  /// contatore**: nel corpus quasi tutti i gradini chiedono una volta sola.
  /// Era che ogni gesto SCARICA UN ARRETRATO DI UNO: `quelliCheSiAccendono`
  /// ne restituisce uno per chiamata, quindi quattro gesti drenano quattro
  /// gradini gia' soddisfatti da prima. **Il premio smetteva di essere un
  /// evento e diventava una consuetudine**, che e' la cosa che il fondatore
  /// ha nominato per prima.
  ///
  /// **La regola: lo stesso gesto con gli stessi dettagli conta una volta
  /// sola nella giornata rituale.** La seconda interrogazione identica non
  /// tocca il Cammino, ne' i contatori ne' la maturazione.
  ///
  /// **E i dettagli fanno parte della chiave, non e' un dettaglio.**
  /// Interrogare il giorno, la settimana e il mese sono TRE gesti diversi, ed
  /// e' giusto che contino tre: e' varieta' vera, ed e' proprio cio' che i
  /// quindici gradini di `VarietaDelDettaglio` premiano. Chiudere sul solo
  /// nome del gesto li avrebbe murati tutti.
  ///
  /// Si azzera al confine del giorno rituale, come tutto cio' che e' di oggi.
  final Set<String> _gestiGiaContatiOggi = {};

  /// La chiave di un gesto con i suoi dettagli, stabile all'ordine.
  static String chiaveDelGesto(String gesto, Map<String, Object?> dettagli) {
    if (dettagli.isEmpty) return gesto;
    final pezzi = <String>[];
    for (final k in dettagli.keys.toList()..sort()) {
      final v = dettagli[k];
      final valori = v is Iterable ? v.map((x) => '$x').toList() : ['$v'];
      valori.sort();
      pezzi.add('$k=${valori.join(",")}');
    }
    return '$gesto|${pezzi.join(";")}';
  }

  /// Vero se questo gesto, con questi dettagli, e' gia' stato contato oggi.
  bool giaContatoOggi(String gesto, Map<String, Object?> dettagli) =>
      _gestiGiaContatiOggi.contains(chiaveDelGesto(gesto, dettagli));
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

  /// L'id del gradino che aspetta di essere congedato, oppure nullo.
  String? get inAttesaDiCongedo => _daCongedare;

  /// Vero quando nessun gradino aspetta: la strada per maturare e' libera.
  bool get laStradaELibera => _daCongedare == null;

  /// **CONGEDA IL GRADINO, e con lui libera il Cammino.** Ordine CP voce 01.
  ///
  /// La chiama chi ha visto la festa chiudersi, e chi ha dovuto rimettere in
  /// coda una festa che non e' riuscita ad aprirsi. Non fa niente se il posto
  /// era gia' libero o se aspettava un altro gradino: congedare il gradino
  /// sbagliato aprirebbe la strada a due maturazioni insieme.
  Future<void> congeda(String id) async {
    if (_daCongedare != id) return;
    _daCongedare = null;
    notifyListeners();
    await _salva();
  }

  /// **SBLOCCA IL CAMMINO SE CHI ASPETTA NON ESISTE PIU'.** Ordine CP voce 01.
  ///
  /// Cintura, non bretella: se il disco tornasse con l'id di un gradino che
  /// il corpus non ha piu', il Cammino resterebbe murato per sempre e nessuno
  /// saprebbe perche'. Si chiama alla lettura del disco.
  Future<void> _liberaSeIlGradinoNonEsiste() async {
    final id = _daCongedare;
    if (id == null) return;
    if (Sentieri.tuttiITraguardi.any((t) => t.id == id)) return;
    _daCongedare = null;
    await _salva();
  }

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
      // **L'ORA FEDELE NON SI SOMMA, si tiene la piu' lunga**: due letture
      // dello stesso giorno non fanno due giorni, la stessa ragione della
      // serie qui sotto.
      _leggiMappa(prefs.getString(_kOraDelGesto), _oraDelGesto,
          tenendoIlMassimo: fondi);
      _leggiTesti(prefs.getString(_kUltimoGiornoPerOra), _ultimoGiornoPerOra);
      _leggiIDettagli(prefs.getString(_kDettagli), sommando: fondi);
      _leggiIDettagliRecenti(prefs.getString(_kDettagliRecenti));
      if (!fondi) _giornoDiOggi = prefs.getString(_kGiornoDiOggi) ?? '';
      _oggiHaFatto.addAll(prefs.getStringList(_kOggi) ?? const []);
      _oggiHaFattoNellOra
          .addAll(prefs.getStringList(_kOggiNellOra) ?? const []);
      _leggiTesti(
          prefs.getString(_kUltimoPerSentiero), _ultimoGiornoPerSentiero);
      // Il primo giorno e' il PIU' VECCHIO dei due, mai quello nato adesso.
      _primoGiorno = prefs.getString(_kPrimoGiorno) ?? _primoGiorno;
      if (!fondi) _ultimoGiorno = prefs.getString(_kUltimoGiorno);
      _accesi.addAll(prefs.getStringList(_kAccesi) ?? const []);
      _daCongedare = prefs.getString(_kDaCongedare) ?? _daCongedare;
      _gestiGiaContatiOggi
          .addAll(prefs.getStringList(_kGiaContatiOggi) ?? const []);
      // Cintura: un id che il corpus non ha piu' murerebbe il Cammino.
      await _liberaSeIlGradinoNonEsiste();
      _leggiTesti(prefs.getString(_kQuandoAccesi), _quandoAccesi);
      _condivisi.addAll(prefs.getStringList(_kCondivisi) ?? const []);
      // La serie di giorni di seguito NON si somma: si tiene la piu' lunga,
      // perche' due conteggi dello stesso giorno non fanno due giorni.
      _leggiMappa(prefs.getString(_kSerie), _seriePerRito,
          tenendoIlMassimo: fondi);
      _leggiTesti(prefs.getString(_kUltimoPerRito), _ultimoGiornoPerRito);
      // **I GIORNI RECENTI SI UNISCONO, non si sommano**: due letture dello
      // stesso giorno non fanno due giorni, ed e' la stessa ragione per cui
      // la serie tiene il massimo invece di sommare. Ordine AS voce 12.
      _leggiIGiorniPerRito(prefs.getString(_kGiorniPerRito));
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

  /// Rilegge dal disco i giorni recenti di ogni rito, unendoli a quelli che
  /// nel frattempo sono nati in memoria. Ordine AS voce 12.
  void _leggiIGiorniPerRito(String? testo) {
    if (testo == null || testo.isEmpty) return;
    try {
      final letto = jsonDecode(testo);
      if (letto is! Map) return;
      for (final voce in letto.entries) {
        final giorni = voce.value;
        if (giorni is! List) continue;
        final miei =
            _giorniPerRito.putIfAbsent(voce.key as String, () => <String>[]);
        for (final g in giorni) {
          if (g is String && !miei.contains(g)) miei.add(g);
        }
        miei.sort();
        if (miei.length > quantiGiorniPerRito) {
          miei.removeRange(0, miei.length - quantiGiorniPerRito);
        }
      }
    } catch (errore) {
      // **SI IGNORA, E SI DICHIARA PERCHE'.** Un elenco di giorni illeggibile
      // vale come elenco vuoto: le costanze larghe ripartono dai giorni nuovi
      // e nessun altro dato ne soffre. Rilanciare qui vorrebbe dire far
      // fallire il caricamento intero del diario per una chiave sola, cioe'
      // spegnere il cammino per un dettaglio.
      assert(() {
        // In sviluppo si vede, in esercizio non disturba nessuno.
        // ignore: avoid_print
        print('cammino.giorniPerRito illeggibile, si riparte vuoto: $errore');
        return true;
      }());
    }
  }

  /// APRE IL GIORNO: se e' cambiato, svuota cio' che si e' fatto oggi e
  /// calcola quanti giorni di silenzio ci sono stati.
  void _apriIlGiorno() {
    final oggi = ConfineDelGiorno.chiaveDi(_orologio());
    if (_giornoDiOggi == oggi) return;
    _giornoDiOggi = oggi;
    _oggiHaFatto.clear();
    _oggiHaFattoNellOra.clear();
    // **E ANCHE I GESTI GIA' CONTATI, ordine CP voce 02**: sono di oggi come
    // gli altri due, e senza questa riga il limite di una volta al giorno
    // diventerebbe un limite di una volta per sempre.
    _gestiGiaContatiOggi.clear();
    // E le scene di oggi, ordine CQ voce 2.13: il tetto e' del giorno.
    _scenePerSentieroOggi.clear();
    // **E IL CONFINE DEL GIORNO CONGEDA CIO' CHE E' RIMASTO APPESO.**
    // Ordine CP voce 01, valvola di sicurezza.
    //
    // **Il congedo e' un evento dell'INTERFACCIA**: succede quando una festa
    // si chiude a schermo. Una regola che si sblocca solo cosi' puo' perdersi
    // per sempre, e il Cammino resterebbe murato senza che nessuno sappia
    // perche': basta chiudere l'app mentre la festa e' aperta, o restare
    // senza un posto dove aprirla.
    //
    // **A dirlo e' stata la simulazione, non un ragionamento.** Con il solo
    // congedo dell'interfaccia, un anno di uso tipico produceva UNA festa in
    // tutto: undici mesi su dodici muti, ognuno con un gradino gia'
    // soddisfatto che aspettava. Un Cammino che si mura non e' un Cammino
    // difficile, e' un Cammino rotto, ed e' la stessa lezione che l'ordine AS
    // aveva imparato sulle serie consecutive.
    //
    // **Un giorno e' il tempo giusto.** La regola del fondatore vieta di
    // vedere piu' premi insieme, non di vederne uno domani: cio' che
    // aspettava da ieri o e' stato visto, o e' andato perduto, e in tutti e
    // due i casi tenere fermo il Cammino costa piu' di quanto protegga.
    _daCongedare = null;
    final ultimo =
        _ultimoGiorno == null ? null : DateTime.tryParse(_ultimoGiorno!);
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
    // **LO STESSO GESTO CON GLI STESSI DETTAGLI CONTA UNA VOLTA AL GIORNO.**
    // Ordine CP voce 02, 3 settembre 2026. La ragione intera sta su
    // `_gestiGiaContatiOggi`. Si esce PRIMA di toccare qualunque contatore:
    // un gesto che non conta non deve lasciare traccia da nessuna parte, o
    // sarebbe contato a meta'.
    if (!_gestiGiaContatiOggi.add(chiaveDelGesto(gesto, dettagli))) return;
    _gestiCompiuti[gesto] = (_gestiCompiuti[gesto] ?? 0) + 1;
    _registraIDettagli(gesto, dettagli);
    if (_oggiHaFatto.add(gesto)) {
      _giorniConGesto[gesto] = (_giorniConGesto[gesto] ?? 0) + 1;
      _aggiornaLaSerie(gesto);
    }
    if (oraRituale != null) {
      final chiave = '$gesto@$oraRituale';
      _gestiNellOraGiusta[chiave] = (_gestiNellOraGiusta[chiave] ?? 0) + 1;
      // **E ANCHE OGGI, ordine BW voce 07**: il conto qui sopra e' di sempre,
      // e "la notte del solstizio" chiede stanotte.
      _oggiHaFattoNellOra.add(chiave);
    }
    // **DA QUANTI GIORNI NON SI CERCAVA QUESTO MAESTRO, ordine BW voce 07.**
    // Il legame fra il gesto e il suo sentiero lo dichiara il corpus, e il
    // generatore lo scrive in `sentieroDelGesto`: qui non si decide niente.
    final suo = sentieroDelGesto[gesto];
    if (suo != null) {
      final oggiChiave = ConfineDelGiorno.chiaveDi(_orologio());
      final ultimo = _ultimoGiornoPerSentiero[suo];
      if (ultimo != null && ultimo != oggiChiave) {
        final prima = _giornoDallaChiave(ultimo);
        final adesso = _giornoDallaChiave(oggiChiave);
        if (prima != null && adesso != null) {
          _assenzaDalSentiero[suo] = adesso.difference(prima).inDays;
        }
      }
      _ultimoGiornoPerSentiero[suo] = oggiChiave;
    }
    final oggi = ConfineDelGiorno.chiaveDi(_orologio());
    // **L'ORA FEDELE, ordine BW voce 07.** Si conta il GIORNO, non il gesto:
    // chi apre l'Oroscopo tre volte alle sette di lunedi' ha un giorno solo
    // alle sette. Cosi' "alla stessa ora per cinque giorni" chiede davvero
    // cinque giorni.
    final oraVera = '$gesto@${_orologio().hour}';
    if (_ultimoGiornoPerOra[oraVera] != oggi) {
      _ultimoGiornoPerOra[oraVera] = oggi;
      _oraDelGesto[oraVera] = (_oraDelGesto[oraVera] ?? 0) + 1;
    }
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
        final mio =
            _dettagli.putIfAbsent(voce.key.toString(), () => <String, int>{});
        for (final v in dentro.entries) {
          final quante = v.value is int ? v.value as int : 0;
          if (quante <= 0) continue;
          final chiave = v.key.toString();
          if (!mio.containsKey(chiave) && mio.length >= quantiValoriPerChiave) {
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
  /// Rilegge i dettagli datati dal disco. Si UNISCONO, non si sommano:
  /// una voce datata e' un fatto, e due letture dello stesso fatto non
  /// ne fanno due.
  void _leggiIDettagliRecenti(String? grezzo) {
    if (grezzo == null) return;
    try {
      final letto = jsonDecode(grezzo);
      if (letto is! Map) return;
      for (final voce in letto.entries) {
        final dentro = voce.value;
        if (dentro is! List) continue;
        final miei =
            _dettagliRecenti.putIfAbsent(voce.key.toString(), () => <String>[]);
        for (final v in dentro) {
          if (v is String && !miei.contains(v)) miei.add(v);
        }
        if (miei.length > quantiDettagliRecenti) {
          miei.removeRange(0, miei.length - quantiDettagliRecenti);
        }
      }
    } catch (errore) {
      // Un elenco illeggibile vale come elenco vuoto, la stessa regola
      // dei giorni per rito: non si spegne il cammino per una chiave.
    }
  }

  /// **LE RIPETIZIONI DENTRO LE FINESTRE CHIESTE DAL CORPUS.**
  /// Ordine BX voce 01.
  Map<String, int> _ripetizioniNellaFinestra() {
    final risposte = <String, int>{};
    final oggi = _giornoDallaChiave(ConfineDelGiorno.chiaveDi(_orologio()));
    if (oggi == null) return const {};
    for (final voce in _dettagliRecenti.entries) {
      for (final finestra in finestreDeiDettagli) {
        final conta = <String, int>{};
        for (final riga in voce.value) {
          final taglio = riga.lastIndexOf('|');
          if (taglio <= 0) continue;
          final quando = _giornoDallaChiave(riga.substring(taglio + 1));
          if (quando == null) continue;
          if (oggi.difference(quando).inDays >= finestra) continue;
          final valore = riga.substring(0, taglio);
          conta[valore] = (conta[valore] ?? 0) + 1;
        }
        if (conta.isEmpty) continue;
        risposte['${voce.key}:$finestra'] =
            conta.values.reduce((a, b) => a > b ? a : b);
      }
    }
    return Map.unmodifiable(risposte);
  }

  /// **QUANTI COMPAGNI DIVERSI HA IL VALORE PIU' ACCOMPAGNATO.**
  /// Ordine BX voce 01: i dettagli composti si scrivono 'x@y', e qui si
  /// guarda, per ogni x, quanti y diversi ha visto.
  Map<String, int> _variePerValore() {
    final risposte = <String, int>{};
    for (final voce in _dettagli.entries) {
      final compagni = <String, Set<String>>{};
      for (final valore in voce.value.keys) {
        final taglio = valore.indexOf('@');
        if (taglio <= 0) continue;
        compagni
            .putIfAbsent(valore.substring(0, taglio), () => <String>{})
            .add(valore.substring(taglio + 1));
      }
      if (compagni.isEmpty) continue;
      risposte[voce.key] =
          compagni.values.map((s) => s.length).reduce((a, b) => a > b ? a : b);
    }
    return Map.unmodifiable(risposte);
  }

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
      // **CON LA DATA, ordine BX voce 01.** Serve alle coincidenze dentro una
      // finestra di tempo: il conto senza date non le sa distinguere.
      final oggi = ConfineDelGiorno.chiaveDi(_orologio());
      final recenti = _dettagliRecenti.putIfAbsent(chiave, () => <String>[]);
      for (final valore in valori) {
        recenti.add('$valore|$oggi');
      }
      if (recenti.length > quantiDettagliRecenti) {
        recenti.removeRange(0, recenti.length - quantiDettagliRecenti);
      }
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
    final ieri = ConfineDelGiorno.chiaveDi(
        _orologio().subtract(const Duration(days: 1)));
    final ultimo = _ultimoGiornoPerRito[gesto];
    if (ultimo == oggi) return;
    _seriePerRito[gesto] = ultimo == ieri ? (_seriePerRito[gesto] ?? 0) + 1 : 1;
    _ultimoGiornoPerRito[gesto] = oggi;
    // E il giorno entra nell'elenco dei giorni recenti, che e' cio' che
    // risponde alle costanze larghe del corpus D.
    final giorni = _giorniPerRito.putIfAbsent(gesto, () => <String>[]);
    if (!giorni.contains(oggi)) {
      giorni.add(oggi);
      if (giorni.length > quantiGiorniPerRito) {
        giorni.removeRange(0, giorni.length - quantiGiorniPerRito);
      }
    }
  }

  /// **QUANTI GIORNI CON QUESTO RITO DENTRO L'ARCO PIU' RECENTE.** Ordine AS
  /// voce 12.
  ///
  /// L'arco si conta all'indietro da OGGI: "sette nell'arco di dieci" vuol
  /// dire sette giorni con quel rito fra oggi e nove giorni fa. Non e' la
  /// finestra migliore possibile dentro tutta la storia, ed e' voluto: un
  /// traguardo di costanza dice "in questi giorni sei tornato", non "una volta
  /// nella vita hai avuto una buona settimana".
  int giorniDelRitoNellArco(String rito, int arco) {
    final giorni = _giorniPerRito[rito];
    if (giorni == null || giorni.isEmpty || arco <= 0) return 0;
    final oggi = _orologio();
    var quanti = 0;
    for (var indietro = 0; indietro < arco; indietro++) {
      final chiave =
          ConfineDelGiorno.chiaveDi(oggi.subtract(Duration(days: indietro)));
      if (giorni.contains(chiave)) quanti++;
    }
    return quanti;
  }

  /// La fotografia delle costanze larghe: per ogni rito e per ogni arco che il
  /// corpus nomina, quanti giorni ci sono dentro.
  ///
  /// **Si calcola sugli archi CHIESTI e non su tutti i numeri possibili**: e'
  /// il corpus a dire quali archi esistono, e chiederglielo evita di
  /// inventarne.
  Map<String, int> costanzeLarghe(Set<({String rito, int arco})> chieste) => {
        for (final c in chieste)
          '${c.rito}:${c.arco}': giorniDelRitoNellArco(c.rito, c.arco),
      };

  /// **IN QUANTI GIORNI UN INSIEME DI GESTI E' CADUTO TUTTO INSIEME.**
  /// Ordine CP voce 05.
  ///
  /// Non serve un magazzino nuovo: [_giorniPerRito] tiene gia' i giorni di
  /// ogni gesto, e i giorni in cui DUE gesti sono caduti insieme sono
  /// l'intersezione dei loro elenchi. Un magazzino in piu' sarebbe stata una
  /// seconda porta sullo stesso dato, e prima o poi le due avrebbero detto
  /// cose diverse.
  int giornateConTuttiIGesti(List<String> gesti) {
    if (gesti.isEmpty) return 0;
    Set<String>? insieme;
    for (final gesto in gesti) {
      final suoi = _giorniPerRito[gesto];
      if (suoi == null || suoi.isEmpty) return 0;
      insieme =
          insieme == null ? suoi.toSet() : (insieme..retainAll(suoi.toSet()));
      if (insieme.isEmpty) return 0;
    }
    return insieme!.length;
  }

  /// La fotografia delle giornate chiuse insieme, sugli insiemi CHIESTI dal
  /// corpus e non su tutte le combinazioni possibili, che sarebbero
  /// centoventisette per sentiero.
  Map<String, int> giornateInsieme(Set<String> chiavi) => {
        for (final chiave in chiavi)
          chiave: giornateConTuttiIGesti(chiave.split('+')),
      };

  /// Gli insiemi che il corpus chiede davvero, letti dai traguardi.
  Set<String> _insiemiChiestiDalCorpus() => {
        for (final t in Sentieri.tuttiITraguardi)
          if (t.condizione is GiornateInsieme)
            (t.condizione as GiornateInsieme).chiave,
      };

  /// Gli archi che il corpus chiede davvero, letti dai traguardi.
  ///
  /// **Si legge il dato invece di elencarli a mano**: il giorno che il corpus
  /// cambia un arco, questo insieme cambia con lui, e nessuno deve ricordarsi
  /// di aggiornare una lista.
  Set<({String rito, int arco})> _archiChiestiDalCorpus() => {
        for (final t in Sentieri.tuttiITraguardi)
          if (t.condizione is GiorniDentroUnArco)
            (
              rito: (t.condizione as GiorniDentroUnArco).rito,
              arco: (t.condizione as GiorniDentroUnArco).arco,
            ),
      };

  /// La continuita' corrente di ogni rito, per la fotografia del cammino.
  Map<String, int> get seriePerRito {
    final oggi = ConfineDelGiorno.chiaveDi(_orologio());
    final ieri = ConfineDelGiorno.chiaveDi(
        _orologio().subtract(const Duration(days: 1)));
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
    // **DA QUI IN POI IL CAMMINO E' FERMO. Ordine CP voce 01.** Questo
    // gradino aspetta di essere congedato, e finche' aspetta nessun altro
    // puo' maturare.
    _daCongedare = id;
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
    _oraDelGesto.clear();
    _ultimoGiornoPerOra.clear();
    _dettagli.clear();
    _dettagliRecenti.clear();
    _ultimoGiornoPerRito.clear();
    _oggiHaFatto.clear();
    _oggiHaFattoNellOra.clear();
    _accesi.clear();
    _daCongedare = null;
    _gestiGiaContatiOggi.clear();
    _quandoAccesi.clear();
    _condivisi.clear();
    _seriePerRito.clear();
    _giorniPerRito.clear();
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
    if (primo != null &&
        (_primoGiorno == null || primo.compareTo(_primoGiorno!) < 0)) {
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
      oggiHaFattoNellOra: Set.unmodifiable(_oggiHaFattoNellOra),
      giorniSaltatiPerRito: _giorniSaltatiPerRito(),
      ripetizioniNellaFinestra: _ripetizioniNellaFinestra(),
      variePerValore: _variePerValore(),
      giorniDiAssenzaDalSentiero: Map.unmodifiable(_assenzaDalSentiero),
      seriePerRito: seriePerRito,
      // **LE COSTANZE LARGHE, ordine AS voce 12.** Gli archi da guardare non
      // si inventano: li DICHIARA il corpus, cioe' i traguardi stessi, e qui
      // si risponde solo a quelli. Chiedere tutti gli archi possibili sarebbe
      // quattrocento conti per rito a ogni fotografia, per rispondere a
      // domande che nessuno fa.
      costanzeLarghe: costanzeLarghe(_archiChiestiDalCorpus()),
      // **LE GIORNATE CHIUSE INSIEME, ordine CP voce 05**, e vale la stessa
      // ragione: gli insiemi li dichiara il corpus. Chiederli tutti sarebbe
      // centoventisette conti per sentiero.
      giornateInsieme: giornateInsieme(_insiemiChiestiDalCorpus()),
      gestiNellOraGiusta: Map.unmodifiable(_gestiNellOraGiusta),
      // **L'ORA FEDELE, ordine BW voce 07**: per ogni gesto, il massimo
      // fra le sue ore, cioe' in quanti giorni e' caduto sempre alla
      // stessa. La fotografia porta un numero solo per gesto, perche' la
      // domanda del cammino e' quella.
      oraFedelePerGesto: _oraFedelePerGesto(),
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

  /// **LA CHIAVE DEL GIORNO NON E' UNA DATA ISO, e va letta a mano.**
  /// `ConfineDelGiorno.chiaveDi` scrive '2026-8-10', senza lo zero davanti:
  /// `DateTime.tryParse` su quella stringa torna nullo, e i due conti dei
  /// giorni saltati rispondevano sempre zero. Lo ha detto la prova.
  static DateTime? _giornoDallaChiave(String chiave) {
    final pezzi = chiave.split('-');
    if (pezzi.length != 3) return null;
    final anno = int.tryParse(pezzi[0]);
    final mese = int.tryParse(pezzi[1]);
    final giorno = int.tryParse(pezzi[2]);
    if (anno == null || mese == null || giorno == null) return null;
    return DateTime(anno, mese, giorno);
  }

  /// **QUANTI INVITI SONO STATI ACCOLTI, e lo dice il server. Ordine BX voce
  /// 02.**
  ///
  /// Tre voci del cammino chiedono che qualcuno accetti il tuo invito ed entri
  /// nel Cerchio, e questo il telefono non lo puo' sapere: lo sa il server,
  /// quando la persona invitata riscatta il codice. Qui il numero entra nel
  /// cammino come un gesto compiuto, `invito`, perche' e' la forma che le
  /// condizioni del Cerchio sanno leggere.
  ///
  /// **Si ALLINEA, non si somma**: il server dice quanti sono in tutto, e
  /// sommarli a ogni apertura li moltiplicherebbe.
  Future<void> allineaGliInviti(int quanti,
      {Map<String, int> perMaestro = const {}}) async {
    if (quanti < 0) return;
    var cambiato = false;
    if ((_gestiCompiuti['invito'] ?? 0) != quanti) {
      _gestiCompiuti['invito'] = quanti;
      cambiato = true;
    }
    // **E UNO PER PORTA**: il corpus ha tre voci, una per Maestro, e senza la
    // porta misurerebbero lo stesso identico fatto.
    for (final maestro in const ['medora', 'aura', 'caligo']) {
      final da = perMaestro[maestro] ?? 0;
      if ((_gestiCompiuti['invito_$maestro'] ?? 0) == da) continue;
      _gestiCompiuti['invito_$maestro'] = da;
      cambiato = true;
    }
    if (!cambiato) return;
    notifyListeners();
    await _salva();
  }

  /// **PER OGNI RITO, QUANTI GIORNI ERANO STATI SALTATI PRIMA DI OGGI.**
  /// Ordine BW voce 07. Si guardano gli ultimi due giorni in cui quel
  /// rito e' stato compiuto: la distanza fra loro, meno uno, e' il buco
  /// che si e' appena chiuso. Con meno di due giorni non c'e' nessun
  /// buco da misurare, e la risposta e' zero invece di un numero
  /// inventato.
  Map<String, int> _giorniSaltatiPerRito() {
    final buchi = <String, int>{};
    for (final voce in _giorniPerRito.entries) {
      final giorni = voce.value;
      if (giorni.length < 2) continue;
      final ultimo = _giornoDallaChiave(giorni.last);
      final prima = _giornoDallaChiave(giorni[giorni.length - 2]);
      if (ultimo == null || prima == null) continue;
      final salto = ultimo.difference(prima).inDays - 1;
      if (salto > 0) buchi[voce.key] = salto;
    }
    return Map.unmodifiable(buchi);
  }

  /// **PER OGNI GESTO, IN QUANTI GIORNI E' CADUTO SEMPRE ALLA STESSA
  /// ORA.** Ordine BW voce 07. Delle sue ore si tiene la migliore: se
  /// qualcuno ha aperto l'Oroscopo alle sette per quattro giorni e alle
  /// otto per uno, la sua fedelta' e' quattro, non cinque.
  Map<String, int> _oraFedelePerGesto() {
    final migliori = <String, int>{};
    for (final voce in _oraDelGesto.entries) {
      final gesto = voce.key.split('@').first;
      final quanti = voce.value;
      if (quanti > (migliori[gesto] ?? 0)) migliori[gesto] = quanti;
    }
    return Map.unmodifiable(migliori);
  }

  /// TUTTI I TRAGUARDI CHE UNO STATO SODDISFA, in ordine di posizione.
  ///
  /// **Non e' cio' che si accende: e' cio' che POTREBBE accendersi.** Serve
  /// alla regola della voce BS.02, che fra questi ne sceglie uno, e serve alla
  /// prova della contesa, che conta quante volte la scelta c'e' stata davvero.
  /// Senza questa porta la prova avrebbe dovuto rifare il giro dei traguardi
  /// per conto suo, cioe' misurare una copia della regola invece della regola.
  @visibleForTesting
  List<Traguardo> quelliSoddisfatti(StatoDelCammino stato) {
    // **SOLO IL PROSSIMO DI OGNI SENTIERO, ordine CP voce 01, letta alla
    // lettera.** Parole del fondatore del 3 settembre 2026: *"il gradino non
    // matura finche' IL PRECEDENTE non e' stato congedato"*.
    //
    // **La prima lettura non bastava, e il numero lo ha detto.** La regola
    // era stata scritta come un posto unico: un gradino acceso occupa il
    // Cammino finche' la sua festa non e' congedata. Quel freno regge contro
    // il gesto ripetuto, e NON regge contro il cielo: misurato su
    // trecentosessantacinque giorni, un utente nuovo che compie tutte le arti
    // nel giorno peggiore dell'anno vedeva **tredici feste**, perche' in un
    // giorno di piu' retrogradi insieme si aprono molte finestre del cielo
    // contemporaneamente e ognuna arma il suo gradino. Erano piu' delle otto
    // che il fondatore ha visto sul telefono.
    //
    // Con la scala il conto e' un altro: da ogni sentiero puo' maturare solo
    // il gradino che chi cammina sta per prendere, quindi al massimo tre
    // insieme, uno per Maestro, per quanto ricco sia il cielo.
    //
    // **Il rischio della scala e' noto e si dichiara**: un gradino
    // irraggiungibile la bloccherebbe per sempre (e' il difetto che l'ordine
    // AS chiuse per le serie consecutive). Nella revisione F non ce ne sono:
    // ogni gesto nominato ha una schermata e ogni evento ha una data, e due
    // guardie lo pretendono su tutti e 165.
    // **E LA SCALA E' USCITA DA QUI. Ordine CQ voce 2.13**, 3 settembre
    // 2026, decisione del fondatore: *il tetto delle feste non deve mai
    // toccare l'accensione del Sigillo ne' l'accredito degli Eos, solo la
    // scena della festa.*
    //
    // **La misura della voce 2.12 ha detto perche'.** Quattrocento giorni di
    // uso onesto con dodici arti al giorno: **centododici traguardi
    // soddisfatti e TREDICI accesi.** I tre sentieri restavano fermi su
    // gradini che chiedono arti che chi fa i Doni del giorno non tocca, e
    // dietro di loro aspettavano novantanove gradini gia' guadagnati. La
    // scala non ritardava: murava.
    //
    // Adesso qui maturano tutti quelli soddisfatti, quindi si accendono tutti
    // e i loro Eos arrivano tutti. **La scala vive nella scena**, cioe' in
    // [meritaLaScena]: e' li' che il fondatore l'aveva voluta, ed e' li' che
    // il conto del giorno peggiore resta quello dell'ordine CP voce 01.
    final soddisfatti = <Traguardo>[];
    for (final traguardo in Sentieri.tuttiITraguardi) {
      if (_accesi.contains(traguardo.id)) continue;
      // **UN DORMIENTE NON ARMA MAI, ordine AR voce 05.** La sua condizione
      // gia' risponde falso a qualunque stato, e questa riga e' la seconda
      // serratura: se un domani qualcuno gli desse per sbaglio una condizione
      // vera senza toglierlo dai dormienti, non si accenderebbe lo stesso, e
      // il difetto si vedrebbe dove va guardato, cioe' nel dato.
      if (traguardo.dormiente) continue;
      if (!traguardo.condizione.raggiunto(stato)) continue;
      soddisfatti.add(traguardo);
    }
    soddisfatti.sort((a, b) => _chiVaPrima(a, b, stato));
    return soddisfatti;
  }

  /// CHI VA PRIMA FRA DUE TRAGUARDI SODDISFATTI DALLO STESSO GESTO.
  ///
  /// **Primo: la posizione piu' bassa.** E' il gradino piu' vicino a chi
  /// cammina, quello che stava per prendere comunque.
  ///
  /// **Secondo, a parita' di posizione: il sentiero che sta piu' indietro.**
  /// Tre sentieri hanno tutti un gradino 11, e senza questa riga vincerebbe
  /// sempre lo stesso, quello col nome alfabeticamente piu' basso: le perle si
  /// accenderebbero tutte sullo stesso ramo. Parole del fondatore: "non mi
  /// piace che i traguardi siano lineari, vorrei che le perle si accendessero
  /// in piu' rami. Vorrei un ordine sparso".
  ///
  /// **Terzo: l'identificativo**, che non e' un criterio ma la garanzia che a
  /// parita' di tutto la risposta sia sempre la stessa. Una scelta che cambia
  /// da un giro all'altro non si puo' provare.
  int _chiVaPrima(Traguardo a, Traguardo b, StatoDelCammino stato) {
    final perPosizione = a.posizione.compareTo(b.posizione);
    if (perPosizione != 0) return perPosizione;
    final dietroA = stato.gradiniAlleSpalle[_sentieroDi(a).name] ?? 0;
    final dietroB = stato.gradiniAlleSpalle[_sentieroDi(b).name] ?? 0;
    final perRamo = dietroA.compareTo(dietroB);
    if (perRamo != 0) return perRamo;
    return a.id.compareTo(b.id);
  }

  Sentiero _sentieroDi(Traguardo traguardo) {
    for (final s in Sentiero.values) {
      if (Sentieri.di(s).any((t) => t.id == traguardo.id)) return s;
    }
    return Sentiero.values.first;
  }

  /// IL TRAGUARDO CHE SI ACCENDE, E NE ACCENDE UNO SOLO. Ordine BS voce 02.
  ///
  /// **Parole del fondatore, sulla build 2206**: "ogni volta che apro l'app, mi
  /// sembra di giocare alla slot machine e continuo a vedere le feste di
  /// traguardo uno dietro l'altro". Tredici feste in tre minuti, quattro delle
  /// quali entrando nei Tarocchi. Nasceva qui: questo metodo accendeva TUTTI i
  /// traguardi che trovava veri, e un gesto solo ne soddisfa spesso quattro o
  /// cinque, perche' la prima volta, la varieta', il conteggio e la finestra
  /// del cielo guardano tutti lo stesso gesto.
  ///
  /// **La regola non ha eccezioni: se ne accende UNO, quello di posizione piu'
  /// bassa.** Gli altri NON si accendono e NON vanno in coda: **restano da
  /// prendere**, e si accenderanno alla prima occasione successiva che li
  /// soddisfa, con la loro festa piena. Un traguardo rimandato non e' un
  /// traguardo perso: e' un traguardo che aspetta il suo momento invece di
  /// essere buttato dentro una raffica insieme ad altri quattro.
  ///
  /// **Tutti e cinquantacinque i gradini di ogni sentiero restano attivi
  /// insieme.** Non si arma un gradino alla volta e non si impone nessun
  /// ordine: il fondatore ha scartato il cammino lineare e vuole le perle
  /// sparse su rami diversi.
  ///
  /// **Nessun timer e nessuna distanza fra le feste**: la festa resta immediata
  /// nell'istante del gesto, come deciso il 23 agosto. Gli Eos e il Sigillo
  /// restano immediati come sempre.
  Future<List<Traguardo>> quelliCheSiAccendono(StatoDelCammino stato) async {
    // **NIENTE MATURA FINCHE' UNO ASPETTA. Ordine CP voce 01**, decisione del
    // fondatore del 3 settembre 2026.
    //
    // Prima questa riga tornava sempre il primo soddisfatto, e bastava
    // ripetere il gesto perche' ne maturasse un altro: e' cosi' che il
    // fondatore ha visto otto feste in due funzionalita', quattro delle quali
    // da quattro interrogazioni dell'Oroscopo. **Il premio smetteva di essere
    // un evento e diventava una consuetudine.**
    //
    // Adesso il Cammino ha un posto solo, e finche' quel posto e' occupato
    // non matura niente. Non si perde niente: le condizioni restano
    // soddisfatte, e il gradino matura appena la festa precedente e' stata
    // congedata.
    // **PRIMA SI GUARDA CHE GIORNO E'. Ordine CP voce 01.** Chiedere cosa
    // matura OGGI presuppone sapere qual e' oggi, e il confine del giorno e'
    // anche il momento in cui si congeda cio' che era rimasto appeso. Senza
    // questa riga la valvola non scatterebbe mai per chi interroga la
    // maturazione senza registrare un gesto, e la simulazione dell'anno lo ha
    // mostrato con un numero: una festa in dodici mesi.
    _apriIlGiorno();
    // **SI ACCENDONO TUTTI. Ordine CQ voce 2.13**, e sostituisce la riga
    // dell'ordine CP voce 01 che ne tornava uno solo dietro il freno della
    // strada libera.
    //
    // Quel freno serviva a non far vedere una raffica di feste, ed era il
    // posto sbagliato: fermava il PREMIO per governare la SCENA. Chi ha
    // guadagnato un Sigillo lo ha guadagnato, e i suoi Eos sono suoi, anche
    // se la sua festa arrivera' domani o non arrivera' affatto.
    //
    // La scena la governa [meritaLaScena], che la scala ce l'ha ancora
    // intera: al massimo tre gradini per volta, uno per Maestro, e uno solo
    // a schermo.
    return quelliSoddisfatti(stato);
  }

  /// **SE QUESTO GRADINO MERITA UNA SCENA, ADESSO.**
  /// Ordine CQ voce 2.13, 3 settembre 2026.
  ///
  /// **Qui vive la scala dell'ordine CP voce 01**, e vive solo qui: e' il
  /// gradino che chi cammina sta per prendere sul suo sentiero, e la strada
  /// dev'essere libera, cioe' nessuna festa deve essere in attesa di essere
  /// congedata.
  ///
  /// **Cio' che non merita la scena non perde niente**: e' gia' acceso, i suoi
  /// Eos sono gia' arrivati, e il suo nome sta nel Journal. Non gli manca il
  /// premio, gli manca il fuoco d'artificio, ed e' esattamente cio' che il
  /// fondatore ha chiesto quando ha visto otto feste in due funzionalita'.
  bool meritaLaScena(Traguardo traguardo) {
    if (!laStradaELibera) return false;
    for (final s in Sentiero.values) {
      if (prossimoDi(s)?.id != traguardo.id) continue;
      // **E UNA SCENA PER SENTIERO AL GIORNO, NON DI PIU'.**
      // Ordine CQ voce 2.13, e conserva il numero dell'ordine CP voce 01.
      //
      // Senza questa riga il giorno peggiore dell'anno tornava a TREDICI
      // feste: la scala da sola non basta, perche' chi congeda una festa
      // libera subito il posto e il gradino dopo dello stesso sentiero
      // diventa a sua volta il prossimo. **Il tetto e' tre al giorno, uno per
      // Maestro**, ed e' il numero che il fondatore ha approvato.
      //
      // Cio' che eccede non perde niente: e' gia' acceso, i suoi Eos sono
      // gia' arrivati, e il suo nome sta nel Journal.
      return !_scenePerSentieroOggi.contains(s.name);
    }
    return false;
  }

  /// I sentieri che oggi hanno gia' avuto la loro scena. Si azzera al confine
  /// del giorno rituale, come tutto cio' che e' di oggi.
  final Set<String> _scenePerSentieroOggi = {};

  /// Segna che questo traguardo ha avuto la sua scena. Lo chiama la regia
  /// nell'istante in cui apre la celebrazione: **non si conta cio' che si
  /// accende, si conta cio' che si vede.**
  void laScenaEStataMostrata(Traguardo traguardo) {
    for (final s in Sentiero.values) {
      if (Sentieri.di(s).any((t) => t.id == traguardo.id)) {
        _scenePerSentieroOggi.add(s.name);
        return;
      }
    }
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
  Traguardo? prossimoDi(Sentiero sentiero,
      {Set<String> escludendo = const {}}) {
    // **LA SCALA SCAVALCA I DORMIENTI, ordine AR voce 05.** Se il prossimo
    // gradino fosse uno che non si puo' raggiungere, la scala si bloccherebbe
    // li' per sempre e il sentiero finirebbe in un vicolo cieco: si arma il
    // successivo, e il Journal mostra il dormiente come in arrivo.
    bool libero(Traguardo t) =>
        !_accesi.contains(t.id) && !escludendo.contains(t.id) && !t.dormiente;
    // **IN ORDINE DI POSIZIONE, mini e grandi INSIEME.** Ordine CP voce 01,
    // 3 settembre 2026. Qui si scorrevano prima tutti e cinquanta i mini e
    // poi i cinque grandi: il gradino grande della prima fascia, che sta in
    // posizione undici e CHIUDE quella fascia, non veniva proposto finche'
    // non erano finiti tutti i mini del sentiero, cioe' quasi mai.
    //
    // Con la revisione F conta ancora di piu': il costo in giorni cresce
    // lungo la posizione, quindi la posizione E' la difficolta'. Scorrere i
    // mini prima dei grandi vorrebbe dire proporre un gradino da
    // trecentoquaranta giorni prima di uno da otto.
    for (final t in Sentieri.di(sentiero)) {
      if (libero(t)) return t;
    }
    return null;
  }

  /// Quanti traguardi accesi su un sentiero.
  int quantiAccesiDi(Sentiero sentiero) =>
      Sentieri.di(sentiero).where((t) => _accesi.contains(t.id)).length;

  /// **IL PROGRESSO DEL CAMMINO, UN CONTO SOLO. Ordine CF voce 01.**
  ///
  /// Torna il numeratore e il denominatore INSIEME, di proposito. La
  /// voce CF.01 chiedeva un anello di riempimento attorno al volto e il
  /// fondatore ha scritto nell\'ordine la ragione per cui questa porta e'
  /// una sola: **due conteggi diversi della stessa cosa sono la famiglia
  /// di difetti piu' numerosa di questo progetto**. Chi disegna l\'anello,
  /// chi scrive il numero accanto al volto e chi domani mostrera' la
  /// stessa progressione altrove leggono questa riga e nessun\'altra.
  ///
  /// **Non e' il livello XP**, che non esiste ancora e questa voce non
  /// lo inventa: e' il numero di Sigilli accesi, che e' l\'unica
  /// grandezza di progressione che il progetto possiede davvero.
  ({int accesi, int quanti}) get progressoDelCammino {
    final possibili = Sentieri.raggiungibili;
    return (
      accesi: possibili.where((t) => _accesi.contains(t.id)).length,
      quanti: possibili.length,
    );
  }

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
      await prefs.setString(_kOraDelGesto, jsonEncode(_oraDelGesto));
      await prefs.setString(
          _kUltimoGiornoPerOra, jsonEncode(_ultimoGiornoPerOra));
      await prefs.setStringList(_kOggi, _oggiHaFatto.toList());
      await prefs.setStringList(_kOggiNellOra, _oggiHaFattoNellOra.toList());
      await prefs.setString(
          _kUltimoPerSentiero, jsonEncode(_ultimoGiornoPerSentiero));
      await prefs.setString(_kGiornoDiOggi, _giornoDiOggi);
      await prefs.setStringList(_kAccesi, _accesi.toList());
      // **IL POSTO OCCUPATO SOPRAVVIVE ALLA CHIUSURA DELL'APP.** Ordine CP
      // voce 01: chi chiude l'app durante una festa la ritrova in coda, e il
      // Cammino deve restare fermo finche' non l'ha vista.
      if (_daCongedare == null) {
        await prefs.remove(_kDaCongedare);
      } else {
        await prefs.setString(_kDaCongedare, _daCongedare!);
      }
      // **I GESTI CONTATI OGGI SOPRAVVIVONO ALLA CHIUSURA DELL'APP.** Ordine
      // CP voce 02: chiudere e riaprire l'app non e' un giorno nuovo, e senza
      // questa riga sarebbe il modo piu' semplice di aggirare il limite.
      await prefs.setStringList(
          _kGiaContatiOggi, _gestiGiaContatiOggi.toList());
      await prefs.setString(_kQuandoAccesi, jsonEncode(_quandoAccesi));
      await prefs.setString(_kDettagli, jsonEncode(_dettagli));
      await prefs.setString(_kDettagliRecenti, jsonEncode(_dettagliRecenti));
      await prefs.setStringList(_kCondivisi, _condivisi.toList());
      if (_primoGiorno != null) {
        await prefs.setString(_kPrimoGiorno, _primoGiorno!);
      }
      if (_ultimoGiorno != null) {
        await prefs.setString(_kUltimoGiorno, _ultimoGiorno!);
      }
      await prefs.setString(_kSerie, jsonEncode(_seriePerRito));
      await prefs.setString(_kGiorniPerRito, jsonEncode(_giorniPerRito));
      await prefs.setString(_kUltimoPerRito, jsonEncode(_ultimoGiornoPerRito));
    } catch (errore) {
      // Si ignora: senza disco il cammino vale per questa sessione. Meglio
      // un Sigillo che vive un giorno di un\'app che cade mentre festeggia.
    }
  }
}
