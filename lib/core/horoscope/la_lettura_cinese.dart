import '../chat/user_profile.dart';
import 'horoscope.dart';
import 'i_testi_eu.dart';
import 'i_segni_delle_tradizioni.dart';
import 'il_responso_dell_oroscopo.dart';
import 'l_almanacco_cinese.dart';
import 'le_parti_del_responso.dart';
import 'oroscopo_cinese_data.dart';

/// **L'OROSCOPO CINESE DEL GIORNO, ordine ES voce 08.**
///
/// Il fondatore: *"il responso avverrà con la stessa animazione e con la
/// stessa divisione in generica, amore, lavoro e fortuna?"*. Si': le stesse
/// quattro schede della lettura occidentale, scritte dall'almanacco e dal
/// BaZi invece che dal cielo tropicale, tutto sul telefono e senza modello.
///
/// - **Generale**: il rapporto fra l'animale del giorno e quello dell'anno di
///   nascita (Sanming Tonghui), poi il guardiano del giorno (Jian Chu); con
///   l'Approfondita, che cosa conviene e che cosa no col guardiano e la
///   direzione del Dio della Gioia.
/// - **Fortuna, Lavoro, Amore**: il dio che il tronco di oggi e' per il
///   tronco del giorno di nascita (i Dieci Dei, Yuanhai Ziping), letto come
///   lo leggono le tabelle: la Fortuna guarda alla Ricchezza, il Lavoro
///   all'Ufficiale, l'Amore all'Ufficiale per una donna e alla Ricchezza per
///   un uomo, e una serie neutra per chi non ha dichiarato il genere. Con
///   l'Approfondita, che cosa e' quel dio; sulla Fortuna anche la direzione
///   del Dio della Ricchezza.
/// - **Colore e numeri** sono quelli dell'elemento del giorno (Liji, He Tu),
///   e la riga lo dice: non sono colori o numeri portafortuna.
///
/// Le frasi vengono da `docs/corpus/oroscopo_cinese.md` attraverso
/// [OroscopoCineseData]. **La variante segue il ritorno del caso**, non il
/// giorno: vedi [ritorni].
///
/// **LE TRE PARTI DEL RESPONSO**, dal 30 settembre 2026. Il fondatore:
/// *"all'utente non gliene frega un cazzo dei transiti [...] Se vuoi inserire
/// i transiti, li inserisci dopo giusto per motivare da dove arriva la
/// risposta."* Ogni frase del corpus porta il suo testo, in parole di tutti
/// i giorni, e il suo "da dove viene", dove stanno l'animale, il guardiano e
/// il dio ([LePartiDelResponso]). La scheda mette i testi nella lettura e i
/// "da dove viene" nella riga sotto; i titoli, che erano "Il giorno della
/// Capra" e "Le Sette Uccisioni", vengono dal corpus e sono in parole.
/// **La Lunga** aggiunge alla Generale che cosa conviene col guardiano e la
/// direzione del giorno, alle altre schede la seconda lettura dello stesso
/// dio; la spiegazione del dio sta nel "da dove viene".
abstract final class LaLetturaCinese {
  /// Le quattro schede del giorno civile [oggi] per chi e' nato il giorno
  /// civile [nascita] (data del luogo di nascita) nell'anno dell'animale
  /// [animale] (0 Topo ... 11 Maiale). Null fuori dalla tabella dei jie
  /// (1900-2100), dove il guardiano non si sa.
  static List<HoroscopeCard>? schede({
    required DateTime oggi,
    required DateTime nascita,
    required int animale,
    CourtesyForm? forma,
    Map<HoroscopeDomain, bool> approfondite = const {},
    String? vocativo,
    bool diOggi = true,
  }) {
    // Sotto la data di un altro giorno (la Settimana e il Mese) la riga del
    // livello non dice "di oggi" (ordine EU voce 02).
    final quando = diOggi ? 'di oggi' : 'del giorno';
    final guardiano = LAlmanaccoCinese.guardiano(oggi);
    if (guardiano == null) return null;
    final ramo = LAlmanaccoCinese.ramo(oggi);
    final tronco = LAlmanaccoCinese.tronco(oggi);
    final signore = LAlmanaccoCinese.tronco(nascita);
    final rapporto = LAlmanaccoCinese.rapporto(animale, ramo);
    final dio = LAlmanaccoCinese.dio(signore, tronco);
    final elemento = LAlmanaccoCinese.elementoDelTronco(tronco);
    final f = forma ?? LaMarcaDelGenere.formaCorrente;

    final valori = {
      'animale_giorno': conArticolo(ramo),
      'animale_tuo': conArticolo(animale),
      'guardiano': LAlmanaccoCinese.guardiani[guardiano],
      'elemento': elemento.nome,
      'colore': elemento.colore,
      'numeri': elemento.numeri.join(' e '),
      'direzione_gioia': LAlmanaccoCinese.dioDellaGioia[tronco],
      'direzione_ricchezza': LAlmanaccoCinese.dioDellaRicchezza[tronco],
      // La tripla armonia: l'elemento dei tre rami che insieme lo fanno.
      'elemento_terna': LAlmanaccoCinese.elementoDellaTerna(animale).nome,
    };
    final ritorno = ritorni(oggi);
    String frase(List<String> varianti, int volta) => riempi(
        LaMarcaDelGenere.risolvi(varianti[volta % varianti.length], forma: f),
        valori);
    bool approfondita(HoroscopeDomain d) => approfondite[d] ?? false;

    // **I TESTI DELL'ARCHITETTO, EU Aggiunta, 1 ottobre 2026**: il titolo e
    // i paragrafi di ogni scheda vengono dal corpus del Giorno cinese, nella
    // fascia del livello, con la voce scelta contando le fasce gia' tornate
    // per questa persona ([ITestiEu]); le frasi di lettura del corpus di
    // prima non vanno piu' a video. Le righe di "Da dove viene" restano
    // quelle di oggi: si scrivono qui sotto come prima.
    final scarto = ITestiEu.scarto(nascita);
    VoceEu voceDi(HoroscopeDomain d, int livello) {
      final fascia = FasciaEu.di(livello);
      final indice = ITestiEu.indiceDelGiorno(
        chiave: 'cinese|$animale|$signore|${f.name}',
        oggi: oggi,
        d: d,
        fasciaDiOggi: fascia,
        scarto: scarto,
        livelli: (g) => livelliDelGiorno(g, animale, signore, f),
      );
      return ITestiEu.voce(
          TradizioneEu.cinese, PeriodoEu.giorno, d, fascia, indice);
    }

    // GENERALE: il rapporto fra i due animali e il guardiano. Di ogni frase
    // il "da dove viene" va nella riga sotto.
    final chiave = chiaveDelRapporto(rapporto, animale == ramo);
    final (_, rapportoDaDove) = LePartiDelResponso.di(
        frase(OroscopoCineseData.rapporti[chiave]!, ritorno.ramo));
    final (_, guardianoDaDove) = LePartiDelResponso.di(
        frase(OroscopoCineseData.guardiani[guardiano], ritorno.guardiano));
    final (_, gioiaDaDove) = LePartiDelResponso.di(
        frase(OroscopoCineseData.direzioneGioia, ritorno.gioia));
    final lungaGenerale = approfondita(HoroscopeDomain.generale);
    final livelloGenerale = livelloDelRapporto(rapporto);
    final rigaDelLivelloGenerale = 'Il livello viene dal rapporto fra '
        '${conArticolo(ramo)} $quando e ${_iltuo(animale)}: '
        '${rapportoDetto(rapporto, animale == ramo)}.';
    final voceGenerale = voceDi(HoroscopeDomain.generale, livelloGenerale);
    final cieloGenerale = LePartiDelResponso.insieme([
      rapportoDaDove,
      guardianoDaDove,
      if (lungaGenerale) gioiaDaDove,
      rigaDelLivelloGenerale,
    ]);
    // **LA FORMA NUOVA, ordine GA voci GA.03 e GA.04**: il rito della Lunga
    // e' il gesto dell'ufficiale di questo giorno.
    final responsoGenerale = IlResponsoDellOroscopo.componi(
      voce: voceGenerale,
      tradizione: TradizioneEu.cinese,
      periodo: PeriodoEu.giorno,
      dominio: HoroscopeDomain.generale,
      primoGiorno: oggi,
      lunga: lungaGenerale,
      cielo: cieloGenerale,
    );
    final generale = HoroscopeCard(
      domain: HoroscopeDomain.generale,
      title: responsoGenerale.titolo,
      synthesis: responsoGenerale.risposta,
      text: IlResponsoDellOroscopo.testo(responsoGenerale),
      responso: responsoGenerale,
      indicator: livelloGenerale,
      rigaDelLivello: cieloGenerale,
      rigaSoloDelLivello: rigaDelLivelloGenerale,
      // L'apertura dal corpus, con lo stesso indice della Generale.
      opening: vocativo == null
          ? null
          : ITestiEu.apertura(
              TradizioneEu.cinese,
              FasciaEu.di(livelloGenerale),
              ITestiEu.indiceDelGiorno(
                chiave: 'cinese|$animale|$signore|${f.name}',
                oggi: oggi,
                d: HoroscopeDomain.generale,
                fasciaDiOggi: FasciaEu.di(livelloGenerale),
                scarto: scarto,
                livelli: (g) => livelliDelGiorno(g, animale, signore, f),
              ),
              vocativo),
      metodo: OroscopoCineseData.notaGenerale,
    );

    // FORTUNA, LAVORO E AMORE: il dio del giorno.
    // La serie dell'Amore passa dalla porta del genere, come ogni testo che
    // dipende dal genere (il_genere_si_decide_in_un_posto_solo).
    final serieDellAmore = LaMarcaDelGenere.scegli(
        maschile: 'amoreUomo',
        femminile: 'amoreDonna',
        neutro: 'amoreNeutro',
        forma: f);
    HoroscopeCard delDio(HoroscopeDomain d, String serie) {
      final gruppo = OroscopoCineseData.dei[serie]![dio.name]!;
      // Il gruppo del corpus resta nei dati dell\'Architetto; a video va la
      // frase in parole di tutti i giorni ([ilGiornoNelBaZi]).
      LePartiDelResponso.di(frase(gruppo, ritorno.tronco));
      // **UNA RIGA DIVERSA PER SCHEDA.** La spiegazione del dio e' la
      // stessa sulle tre schede; la riga dice anche che cosa fa quel dio al
      // tema della scheda, cosi' tre Lunghe non ripetono la stessa frase
      // una sotto l'altra. Sta nel "da dove viene": e' il simbolo.
      //
      // **ORDINE GA VOCE GA.06, LA SPIEGAZIONE UNA VOLTA SOLA.** Qui la Lunga
      // aggiungeva una seconda presentazione del dio ("Il dio di oggi nel
      // BaZi sono le Sette Uccisioni (七杀): governa il tuo elemento...")
      // subito sotto la riga del corpus che lo aveva gia' spiegato: il
      // lettore cieco ha letto due volte di fila la stessa spiegazione
      // (oroscopo-34 e 36). La riga del corpus basta; la Lunga aggiunge solo
      // cio' che la Breve non ha, il Dio della Ricchezza nella Fortuna.
      final fortuna = d == HoroscopeDomain.fortuna;
      final lunga = approfondita(d);
      final colore =
          frase(OroscopoCineseData.coloreENumeri, ritorno.coppiaDiTronchi);
      final (_, ricchezzaDaDove) = LePartiDelResponso.di(frase(
          OroscopoCineseData.direzioneRicchezza, ritorno.coppiaDiTronchi));
      final livello = livelloDelDio(d, dio, forma: f);
      final voce = voceDi(d, livello);
      // **LA SOSTANZA PRIMA DEL TERMINE** (quarto giro GA.06): la frase del
      // corpus ("ha il tuo stesso elemento con polarita' opposta") lascia il
      // posto a quella che dice che cosa porta la forza del giorno.
      final cielo = LePartiDelResponso.insieme([
        ilGiornoNelBaZi(dio, diOggi: diOggi),
        if (lunga && fortuna) ricchezzaDaDove,
        rigaDelTema(d, dio, forma: f),
      ]);
      final responso = IlResponsoDellOroscopo.componi(
        voce: voce,
        tradizione: TradizioneEu.cinese,
        periodo: PeriodoEu.giorno,
        dominio: d,
        primoGiorno: oggi,
        lunga: lunga,
        cielo: cielo,
      );
      return HoroscopeCard(
        domain: d,
        title: responso.titolo,
        synthesis: responso.risposta,
        text: IlResponsoDellOroscopo.testo(responso),
        responso: responso,
        indicator: livello,
        rigaDelLivello: cielo,
        rigaSoloDelLivello: '${ilGiornoNelBaZi(dio, diOggi: diOggi)} '
            '${rigaDelTema(d, dio, forma: f)}',
        metodo: fortuna
            ? '${OroscopoCineseData.notaDei} ${OroscopoCineseData.notaColore}'
            : OroscopoCineseData.notaDei,
        luckyNumber: fortuna ? elemento.numeri.first : null,
        numeriDelGiorno: fortuna ? elemento.numeri : null,
        dayColor: fortuna ? elemento.colore : null,
        rigaDellaFortuna: fortuna ? colore : null,
      );
    }

    return [
      generale,
      delDio(HoroscopeDomain.amore, serieDellAmore),
      delDio(HoroscopeDomain.carriera, 'lavoro'),
      delDio(HoroscopeDomain.fortuna, 'fortuna'),
    ];
  }

  /// **QUANTE VOLTE E' GIA' TORNATO IL CASO DI OGGI**, per ogni grandezza
  /// dell'almanacco: la variante di un gruppo e' questo numero modulo le
  /// varianti, cosi' ogni volta che lo stesso caso torna la persona legge
  /// l'altra frase.
  ///
  /// **Prima la variante era il giorno giuliano modulo le varianti**, come
  /// proponeva il corpus, e la Regola A l'ha colta: il ramo del giorno torna
  /// ogni dodici giorni, dodici e' multiplo di tre, e chi e' nato Topo
  /// leggeva la stessa frase dello scontro ogni volta che tornava il Cavallo.
  /// - il ramo torna ogni 12 giorni: la volta e' il blocco di dodici;
  /// - il tronco (il dio del giorno) ogni 10: il blocco di dieci;
  /// - il Dio della Gioia sta nello stesso posto ogni 5 giorni;
  /// - l'elemento e il Dio della Ricchezza valgono per due tronchi di fila,
  ///   e tornano dopo dieci giorni: si contano le coppie e il posto nella
  ///   coppia;
  /// - il guardiano avanza di uno al giorno e resta fermo il giorno del jie:
  ///   la volta e' il blocco di dodici passi, piu' i jie gia' passati, cosi'
  ///   anche il guardiano ripetuto dal jie cambia frase.
  static ({int ramo, int tronco, int gioia, int coppiaDiTronchi, int guardiano})
      ritorni(DateTime oggi) {
    final g = LAlmanaccoCinese.giornoGiuliano(oggi);
    final jie = LAlmanaccoCinese.indiceDelJie(oggi) ?? 0;
    final tronco = LAlmanaccoCinese.tronco(oggi);
    return (
      ramo: (g + 1) ~/ 12,
      tronco: (g + 9) ~/ 10,
      gioia: (g + 9) ~/ 5,
      coppiaDiTronchi: 2 * ((g + 9) ~/ 10) + tronco % 2,
      guardiano: (g - jie) ~/ 12 + jie,
    );
  }

  /// **I LIVELLI DI UN GIORNO CIVILE** nei quattro domini, con le stesse
  /// regole delle schede: il rapporto fra gli animali per la Generale, il
  /// dio del giorno per le altre. Servono a contare le fasce dei giorni
  /// passati (EU Aggiunta).
  static List<int> livelliDelGiorno(
      DateTime giorno, int animale, int signore, CourtesyForm forma) {
    final rapporto =
        LAlmanaccoCinese.rapporto(animale, LAlmanaccoCinese.ramo(giorno));
    final dio = LAlmanaccoCinese.dio(signore, LAlmanaccoCinese.tronco(giorno));
    return [
      livelloDelRapporto(rapporto),
      for (final d in HoroscopeDomain.values.skip(1))
        livelloDelDio(d, dio, forma: forma),
    ];
  }

  /// La riga di domani, ordine ES voce 34 letta nella tradizione cinese:
  /// l'animale e il guardiano di domani, e il rapporto col tuo animale.
  static String? domani(DateTime oggi, int animale) {
    final d = DateTime(oggi.year, oggi.month, oggi.day + 1);
    final g = LAlmanaccoCinese.guardiano(d);
    if (g == null) return null;
    final ramo = LAlmanaccoCinese.ramo(d);
    final r = LAlmanaccoCinese.rapporto(animale, ramo);
    return 'Domani è il giorno ${_preposizione('di', conArticolo(ramo))}, '
        'col guardiano ${LAlmanaccoCinese.guardiani[g]}. '
        'Con ${_iltuo(animale)}: ${rapportoDetto(r, animale == ramo)}.';
  }

  /// La riga del secondo momento della riflessione: il fatto dell'almanacco
  /// che la lettura sta per usare.
  static String? fattoDelGiorno(DateTime oggi) {
    final g = LAlmanaccoCinese.guardiano(oggi);
    if (g == null) return null;
    final ramo = LAlmanaccoCinese.ramo(oggi);
    return 'Oggi è il giorno ${_preposizione('di', conArticolo(ramo))}, '
        'col guardiano ${LAlmanaccoCinese.guardiani[g]}.';
  }

  static String _maiuscola(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  /// L'animale con l'articolo: "il Cavallo", "la Capra".
  static String conArticolo(int i) {
    final (nome, articolo) = ISegniDelleTradizioni.animali[i];
    return '$articolo $nome';
  }

  static String _iltuo(int i) {
    final (nome, articolo) = ISegniDelleTradizioni.animali[i];
    return '$articolo ${articolo == 'la' ? 'tua' : 'tuo'} $nome';
  }

  static const List<String> _articoli = [
    'il ',
    'la ',
    'lo ',
    'i ',
    'le ',
    'l\''
  ];
  static const Map<String, List<String>> _preposizioniArticolate = {
    'di': ['del ', 'della ', 'dello ', 'dei ', 'delle ', 'dell\''],
    'a': ['al ', 'alla ', 'allo ', 'ai ', 'alle ', 'all\''],
  };

  /// "di" e "a" davanti a un nome con l'articolo si fondono: del, della,
  /// dell', al, alla, all'. Senza articolo ("a nord-est") restano come sono.
  static String _preposizione(String prep, String conArticolo) {
    for (var i = 0; i < _articoli.length; i++) {
      if (conArticolo.startsWith(_articoli[i])) {
        return '${_preposizioniArticolate[prep]![i]}'
            '${conArticolo.substring(_articoli[i].length)}';
      }
    }
    return '$prep $conArticolo';
  }

  static final RegExp _segnaposto = RegExp(r'(\b(?:[Dd]i|[Aa]) )?\{(\w+)\}');

  /// Riempie i segnaposti del corpus. "di {elemento}" diventa "del legno",
  /// "a {elemento_terna}" diventa "all'acqua", e una frase che comincia con
  /// un segnaposto comincia con la maiuscola. Un segnaposto che il corpus
  /// usa e l'app non conosce ferma tutto: una graffa a video e' peggio.
  static String riempi(String testo, Map<String, String> valori) {
    final pieno = testo.replaceAllMapped(_segnaposto, (m) {
      final valore = valori[m.group(2)];
      if (valore == null) {
        throw StateError('segnaposto sconosciuto {${m.group(2)}} in "$testo"');
      }
      final prep = m.group(1);
      if (prep == null) return valore;
      final fuso = _preposizione(prep.trim().toLowerCase(), valore);
      return prep.startsWith(RegExp('[DA]')) ? maiuscola(fuso) : fuso;
    });
    // La maiuscola a inizio di frase.
    return pieno.replaceAllMapped(RegExp(r'(^|[.!?] )([a-zàèéìòù])'),
        (m) => '${m[1]}${m[2]!.toUpperCase()}');
  }

  static String maiuscola(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  /// La prima frase di un testo, per la sintesi della scheda.
  static String primaFrase(String testo) {
    final m = RegExp(r'^.+?[.!?](?= |$)').firstMatch(testo);
    return m == null ? testo : m.group(0)!;
  }

  /// Il gruppo di frasi del corpus. La punizione dello stesso animale ha
  /// il suo: e' la punizione di se'.
  static String chiaveDelRapporto(RapportoFraAnimali r, bool stesso) =>
      switch (r) {
        RapportoFraAnimali.armonia => 'armonia',
        RapportoFraAnimali.triplaArmonia => 'triplaArmonia',
        RapportoFraAnimali.scontro => 'scontro',
        RapportoFraAnimali.punizione => stesso ? 'punizioneDiSe' : 'punizione',
        RapportoFraAnimali.danno => 'danno',
        RapportoFraAnimali.armoniaChePunisce => 'armoniaChePunisce',
        RapportoFraAnimali.stessoAnimale => 'stessoAnimale',
        RapportoFraAnimali.nessuno => 'nessuno',
      };

  /// Il nome del rapporto. La punizione dello stesso animale (Drago, Cavallo,
  /// Gallo, Maiale) ha frasi sue: e' la punizione di se'.
  static String rapportoDetto(RapportoFraAnimali r, bool stesso) => switch (r) {
        RapportoFraAnimali.armonia => 'armonia, una delle sei coppie',
        RapportoFraAnimali.triplaArmonia => 'tripla armonia',
        RapportoFraAnimali.scontro => 'scontro, i due animali sono opposti',
        RapportoFraAnimali.punizione =>
          stesso ? 'punizione di sé' : 'punizione',
        RapportoFraAnimali.danno => 'danno',
        RapportoFraAnimali.armoniaChePunisce => 'armonia che punisce',
        RapportoFraAnimali.stessoAnimale => 'lo stesso animale',
        RapportoFraAnimali.nessuno => 'nessun rapporto nelle tabelle',
      };

  /// **IL LIVELLO DELLA GENERALE, ordine ES voce 28 nella tradizione cinese**:
  /// dal rapporto fra i due animali. L'armonia delle sei coppie e' l'accordo
  /// piu' stretto, la tripla armonia viene dopo; scontro, punizione e danno
  /// sono i rapporti avversi; l'armonia che punisce e lo stesso animale
  /// hanno due facce. Il guardiano non da' voto: le fonti non concordano sul
  /// peso di ognuno (specifiche, paragrafo 2).
  static int livelloDelRapporto(RapportoFraAnimali r) => switch (r) {
        RapportoFraAnimali.armonia => 5,
        RapportoFraAnimali.triplaArmonia => 4,
        RapportoFraAnimali.stessoAnimale ||
        RapportoFraAnimali.nessuno ||
        RapportoFraAnimali.armoniaChePunisce =>
          3,
        RapportoFraAnimali.scontro ||
        RapportoFraAnimali.punizione ||
        RapportoFraAnimali.danno =>
          2,
      };

  /// Che cosa fa il dio di oggi alla stella del dominio: alla Ricchezza per
  /// la Fortuna, all'Ufficiale per il Lavoro (specifiche, paragrafo 4).
  static int livelloDelDio(HoroscopeDomain d, DioDelGiorno dio,
      {CourtesyForm forma = CourtesyForm.unknown}) {
    if (d == HoroscopeDomain.amore) {
      // Per una donna l'Ufficiale, per un uomo la Ricchezza, per chi non
      // l'ha dichiarato la media: la scelta passa dalla porta del genere.
      final uff = _versoLUfficiale[dio.index];
      final ric = _versoLaRicchezza[dio.index];
      return int.parse(LaMarcaDelGenere.scegli(
          maschile: '$ric',
          femminile: '$uff',
          neutro: '${((uff + ric) / 2).round()}',
          forma: forma));
    }
    return d == HoroscopeDomain.carriera
        ? _versoLUfficiale[dio.index]
        : _versoLaRicchezza[dio.index];
  }

  // Nell'ordine di [DioDelGiorno]: Compagno, Rivale, Nutrimento, Ufficiale
  // Ferito, Ricchezza indiretta, Ricchezza diretta, Sette Uccisioni,
  // Ufficiale diretto, Sigillo indiretto, Sigillo diretto.
  static const List<int> _versoLaRicchezza = [3, 2, 4, 4, 4, 5, 2, 3, 3, 3];
  static const List<int> _versoLUfficiale = [3, 2, 3, 2, 4, 4, 3, 5, 4, 4];

  // **CHE COSA FA IL DIO DI OGGI ALLA STELLA DEL DOMINIO, DETTO COL LIVELLO.**
  // Ordine GA voce GA.06. Il primo lettore cieco ha trovato righe come "Per il
  // lavoro: doma l'Ufficiale." (oroscopo-35); il secondo, sulla riscrittura,
  // "oggi è tenuta a bada dal tuo talento" (35), "nutrita dall'impegno
  // concreto ... ciò che arriva dal lavoro fatto" detto dell'amore (38) e una
  // giornata d'amore calma con sotto due volte "pressione e sfida" (34). La
  // riga adesso dice il giudizio che il livello gia' contiene (le tabelle
  // [_versoLaRicchezza] e [_versoLUfficiale], specifiche paragrafo 4): cosi'
  // non puo' dire il contrario della risposta. Nel lavoro e nella fortuna
  // aggiunge il perche' in parole di tutti; nell'amore no, perche' le due
  // stelle si leggono come la figura dell'altro e il perche' del lavoro o del
  // denaro non c'entra.
  static String _giudizio(int livello, {bool plurale = false}) =>
      switch (livello) {
        >= 5 => plurale ? 'molto favorite' : 'molto favorita',
        4 => plurale ? 'favorite' : 'favorita',
        3 => plurale
            ? 'neutre, né favorite né contrastate'
            : 'neutra, né favorita né contrastata',
        _ => plurale ? 'contrastate' : 'contrastata',
      };

  /// **LE DIECI FORZE DEL GIORNO IN PAROLE DI TUTTI I GIORNI** (ordine GA
  /// voce GA.06, quarto giro). Il BaZi chiama "dei" le dieci forze che il
  /// giorno porta al carattere di chi nasce; la spiegazione del corpus
  /// ("governa il tuo elemento con polarita' opposta") non diceva niente a
  /// chi non sa che cosa sia un elemento o una polarita'. Nell'ordine di
  /// [DioDelGiorno].
  static const List<String> _laForzaDelGiorno = [
    'una forza alla pari con te, che porta le persone che ti somigliano',
    'una forza che contende ciò che hai e porta concorrenza',
    'la forza di ciò che produci con calma, con le tue mani e le tue idee',
    'la forza dell\'espressione che rompe le regole: idee brillanti e poca '
        'pazienza',
    'una forza che porta guadagni e occasioni di lato, impreviste',
    'la forza del guadagno regolare, di ciò che hai seminato',
    'una forza di pressione e di sfida',
    'la forza della regola, della responsabilità e del riconoscimento',
    'una forza di sostegno insolito e di intuizione',
    'la forza della protezione, dello studio e della cura',
  ];

  /// **IL GIORNO NEL BAZI**, la prima frase del "Da dove viene" delle tre
  /// schede del dio: la sostanza prima del nome, e il nome una volta.
  static String ilGiornoNelBaZi(DioDelGiorno dio, {bool diOggi = true}) =>
      'Nel BaZi, la lettura cinese del tuo carattere di nascita, '
      '${diOggi ? 'oggi' : 'quel giorno'} '
      '${dio == DioDelGiorno.setteUccisioni ? 'pesano' : 'pesa'} '
      '${dio.nome}: ${_laForzaDelGiorno[dio.index]}.';

  static const List<String> _percheDellUfficiale = [
    'conta il lavoro alla pari con gli altri',
    'c\'è concorrenza fra pari',
    'conta più quello che sai fare del posto che occupi',
    'è facile l\'attrito con chi ha autorità',
    'le occasioni sostengono il ruolo',
    'l\'impegno concreto sostiene il ruolo',
    'il ruolo chiede di reggere una pressione',
    'regole e riconoscimento sono dalla tua parte',
    'studio e formazione sostengono il ruolo',
    'chi ti protegge sostiene il ruolo',
  ];
  static const List<String> _percheDellaRicchezza = [
    'le occasioni si dividono con altri',
    'le occasioni tendono a uscire più che a entrare',
    'il tuo talento crea occasioni',
    'le idee fuori dagli schemi creano occasioni',
    'le occasioni arrivano di lato, impreviste',
    'arriva ciò che hai seminato',
    'le occasioni si consumano in obblighi',
    'le occasioni passano da doveri e regole',
    'conta più il sostegno dell\'occasione',
    'conta più la protezione dell\'occasione',
  ];

  /// Che cosa fa il dio di oggi alle due figure dell'altro, nell'ordine di
  /// [DioDelGiorno]; il giudizio va d'accordo con [_versoLUfficiale] e
  /// [_versoLaRicchezza].
  static const List<String> _amoreNeutro = [
    'oggi la forza del giorno non tocca né l\'una né l\'altra: in amore '
        'pesano più le persone che hai intorno',
    'oggi la forza del giorno contende la Ricchezza e lascia in ombra '
        'l\'Ufficiale: in amore entrano confronti e gelosie',
    'oggi la forza del giorno nutre la Ricchezza e lascia l\'Ufficiale '
        'com\'è: in amore conta la dolcezza dei gesti',
    'oggi la forza del giorno nutre la Ricchezza ma urta l\'Ufficiale: in '
        'amore il fascino c\'è, la pazienza meno',
    'oggi pesa la Ricchezza che arriva di lato e nutre l\'Ufficiale: in '
        'amore sono favoriti gli incontri',
    'oggi pesa la Ricchezza regolare e nutre l\'Ufficiale: in amore è '
        'favorito ciò che si costruisce',
    'oggi pesa l\'Ufficiale nella sua forma più dura e consuma la '
        'Ricchezza: in amore c\'è intensità, fra attrazione e attrito',
    'oggi pesa l\'Ufficiale nella sua forma regolare: in amore sono '
        'favoriti l\'impegno e la parola data',
    'oggi pesa la protezione, che sostiene l\'Ufficiale e lascia in '
        'disparte la Ricchezza: in amore serve spazio per pensare',
    'oggi pesa la protezione, che custodisce l\'Ufficiale e lascia in '
        'disparte la Ricchezza: in amore conta la cura',
  ];

  /// **LA RIGA DEL TEMA** nel "Da dove viene" delle schede del dio: quale
  /// stella del BaZi la tradizione guarda per il dominio [d] e il giudizio
  /// che il dio di oggi le da', lo stesso del livello della scheda.
  /// Nell'Amore la stella dipende dal genere dichiarato e passa dalla porta
  /// del genere; chi non l'ha dichiarato legge le due stelle, e il livello e'
  /// la loro media.
  static String rigaDelTema(HoroscopeDomain d, DioDelGiorno dio,
      {CourtesyForm forma = CourtesyForm.unknown}) {
    final r = _giudizio(_versoLaRicchezza[dio.index]);
    final u = _giudizio(_versoLUfficiale[dio.index]);
    return switch (d) {
      HoroscopeDomain.carriera => 'Per il lavoro la tradizione cinese guarda '
          'la forza dell\'Ufficiale, quella del ruolo e delle responsabilità: '
          'oggi è $u, perché ${_percheDellUfficiale[dio.index]}.',
      HoroscopeDomain.amore => LaMarcaDelGenere.scegli(
          maschile: 'Per l\'amore i testi classici, negli oroscopi maschili, '
              'guardano la forza della Ricchezza, che rappresenta l\'altra '
              'persona nel legame: oggi è $r.',
          femminile: 'Per l\'amore i testi classici, negli oroscopi '
              'femminili, guardano la forza dell\'Ufficiale, che rappresenta '
              'l\'altra persona nel legame: oggi è $u.',
          // Quarto giro GA.06: "le due figure dell'altro" e "il dio" erano
          // gergo del BaZi. Adesso: due forze che rappresentano l'altra
          // persona, e che cosa fa quella di oggi.
          neutro: 'Per l\'amore la tradizione cinese guarda due forze, '
              'l\'Ufficiale e la Ricchezza, che rappresentano l\'altra persona '
              'nel legame; il livello della giornata è la media delle due. '
              '${_maiuscola(_amoreNeutro[dio.index])}.',
          forma: forma),
      _ => 'Per la fortuna la tradizione cinese guarda la forza della '
          'Ricchezza, quella delle occasioni: oggi è $r, perché '
          '${_percheDellaRicchezza[dio.index]}.',
    };
  }
}
