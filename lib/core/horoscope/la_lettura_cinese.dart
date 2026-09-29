import '../chat/user_profile.dart';
import 'horoscope.dart';
import 'i_segni_delle_tradizioni.dart';
import 'l_almanacco_cinese.dart';
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
    String? apertura,
  }) {
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

    // GENERALE: il rapporto fra i due animali e il guardiano.
    final delRapporto = frase(
        OroscopoCineseData
            .rapporti[chiaveDelRapporto(rapporto, animale == ramo)]!,
        ritorno.ramo);
    final delGuardiano =
        frase(OroscopoCineseData.guardiani[guardiano], ritorno.guardiano);
    final (adatto, evitare) =
        OroscopoCineseData.consigliDelGuardiano[guardiano];
    final generale = HoroscopeCard(
      domain: HoroscopeDomain.generale,
      title: 'Il giorno ${_preposizione('di', conArticolo(ramo))}',
      synthesis: primaFrase(delRapporto),
      text: [
        delRapporto,
        delGuardiano,
        if (approfondita(HoroscopeDomain.generale)) ...[
          'Adatto a: $adatto. Meglio evitare: $evitare.',
          frase(OroscopoCineseData.direzioneGioia, ritorno.gioia),
        ],
      ].join(' '),
      indicator: livelloDelRapporto(rapporto),
      rigaDelLivello: 'Dal rapporto fra ${conArticolo(ramo)} di oggi e '
          '${_iltuo(animale)}: ${nomeDelRapporto(rapporto, animale == ramo)}.',
      opening: apertura,
      metodo: OroscopoCineseData.notaGenerale,
    );

    // FORTUNA, LAVORO E AMORE: il dio del giorno.
    final serieDellAmore = switch (f) {
      CourtesyForm.feminine => 'amoreDonna',
      CourtesyForm.masculine => 'amoreUomo',
      _ => 'amoreNeutro',
    };
    HoroscopeCard delDio(HoroscopeDomain d, String serie) {
      final base =
          frase(OroscopoCineseData.dei[serie]![dio.name]!, ritorno.tronco);
      // Le Sette Uccisioni sono un plurale.
      final e = dio == DioDelGiorno.setteUccisioni ? 'sono' : 'è';
      // **UNA RIGA DIVERSA PER SCHEDA.** La spiegazione del dio e' la
      // stessa sulle tre schede; la riga dice anche che cosa fa quel dio al
      // tema della scheda, cosi' tre Approfondite non ripetono la stessa
      // frase una sotto l'altra.
      final presentazione = 'Il dio di oggi nel BaZi $e ${dio.nome} '
          '(${_caratteri[dio.index]}): '
          '${OroscopoCineseData.spiegazioni[dio.name]!.replaceFirst(': ', ', cioè ')}. '
          '${_perIlTema[d]} ${relazioneDelDio(d, dio, forma: f)}.';
      final fortuna = d == HoroscopeDomain.fortuna;
      final colore =
          frase(OroscopoCineseData.coloreENumeri, ritorno.coppiaDiTronchi);
      return HoroscopeCard(
        domain: d,
        title: maiuscola(dio.nome),
        synthesis: primaFrase(base),
        text: [
          base,
          if (approfondita(d)) ...[
            presentazione,
            if (fortuna)
              frase(OroscopoCineseData.direzioneRicchezza,
                  ritorno.coppiaDiTronchi),
          ],
        ].join(' '),
        indicator: livelloDelDio(d, dio, forma: f),
        rigaDelLivello: 'Dal dio di oggi nel BaZi, ${dio.nome}: '
            '${relazioneDelDio(d, dio, forma: f)}.',
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
        'Con ${_iltuo(animale)}: ${nomeDelRapporto(r, animale == ramo)}.';
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

  static const Map<HoroscopeDomain, String> _perIlTema = {
    HoroscopeDomain.generale: 'Per il giorno',
    HoroscopeDomain.amore: 'Per il legame',
    HoroscopeDomain.carriera: 'Per il lavoro',
    HoroscopeDomain.fortuna: 'Per il denaro',
  };

  /// I nomi cinesi dei Dieci Dei, nell'ordine di [DioDelGiorno].
  static const List<String> _caratteri = [
    '比肩', '劫财', '食神', '伤官', '偏财', //
    '正财', '七杀', '正官', '偏印', '正印',
  ];

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
  static String nomeDelRapporto(RapportoFraAnimali r, bool stesso) =>
      switch (r) {
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
      return switch (forma) {
        CourtesyForm.feminine => _versoLUfficiale[dio.index],
        CourtesyForm.masculine => _versoLaRicchezza[dio.index],
        _ => ((_versoLUfficiale[dio.index] + _versoLaRicchezza[dio.index]) / 2)
            .round(),
      };
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

  static const List<String> _allaRicchezza = [
    'divide la Ricchezza, in forma leggera',
    'contende la Ricchezza',
    'genera la Ricchezza',
    'genera la Ricchezza, con impeto',
    'la Ricchezza è di turno',
    'la Ricchezza è di turno',
    'la Ricchezza va verso obblighi e pressioni',
    'la Ricchezza va verso posizione e doveri',
    'non tocca la Ricchezza',
    'non tocca la Ricchezza',
  ];
  static const List<String> _allUfficiale = [
    'il tema è la rete dei pari',
    'il tema è la concorrenza fra pari',
    'doma l\'Ufficiale',
    'ferisce l\'Ufficiale',
    'nutre l\'Ufficiale',
    'nutre l\'Ufficiale',
    'l\'Ufficiale è di turno, come pressione',
    'l\'Ufficiale è di turno',
    'trasforma l\'Ufficiale in sostegno',
    'trasforma l\'Ufficiale in sostegno',
  ];

  static String relazioneDelDio(HoroscopeDomain d, DioDelGiorno dio,
      {CourtesyForm forma = CourtesyForm.unknown}) {
    if (d == HoroscopeDomain.amore) {
      return switch (forma) {
        CourtesyForm.feminine =>
          '${_allUfficiale[dio.index]}; per una donna l\'Ufficiale è il legame',
        CourtesyForm.masculine =>
          '${_allaRicchezza[dio.index]}; per un uomo la Ricchezza è il legame',
        // Chi non ha dichiarato il genere: le due letture insieme.
        _ => '${_allUfficiale[dio.index]} e ${_allaRicchezza[dio.index]}',
      };
    }
    return d == HoroscopeDomain.carriera
        ? _allUfficiale[dio.index]
        : _allaRicchezza[dio.index];
  }
}
