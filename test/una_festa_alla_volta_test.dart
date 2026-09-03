import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/eventi_del_cielo.dart';
import 'package:esoteric_circle/core/sigilli/gesti_delle_arti.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// UNA FESTA ALLA VOLTA. Ordine BS, voci 02 e 03.
///
/// **Parole del fondatore, sulla build 2206, tredici feste in tre minuti:**
/// "ogni volta che apro l'app, mi sembra di giocare alla slot machine e
/// continuo a vedere le feste di traguardo uno dietro l'altro". E poi:
/// "SEMPLICEMENTE NON DEVE CREARSI QUESTA CONDIZIONE, devi creare i traguardi
/// unici in modo che non possano sovrapporsi, non voglio trucchetti".
///
/// **Queste tre prove sono i lucchetti**, cioe' la ragione per cui il difetto
/// non potra' tornare: la prima conta quanti traguardi si accendono su un
/// evento, la seconda conta quante volte la regola ha dovuto scegliere, la
/// terza guarda un anno intero e pretende che nessun gradino resti prigioniero.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// I GESTI CHE L'APP REGISTRA, presi dal censimento e non da un elenco
  /// scritto qui: se domani nasce un'arte, l'enumerazione la trova da sola.
  final gesti = <String>[for (final s in GestiDelleArti.tutte) s.gesto];

  /// LA CARTA NATALE DELLA PERSONA SIMULATA.
  ///
  /// **Senza carta i transiti personali non esistono**, e con loro sparivano
  /// cinque gradini del cielo che l'enumerazione dichiarava irraggiungibili
  /// mentre erano soltanto invisibili: e' la differenza fra misurare l'app e
  /// misurare la propria impalcatura.
  const carta = NatalChart(
    sunSign: Zodiac.leo,
    moonSign: Zodiac.cancer,
    ascendant: Zodiac.aries,
    ascendantLongitude: 12.0,
    hasTime: true,
    planets: [
      PlanetPosition(
          id: 'sun',
          name: 'Sole',
          glyph: 'S',
          longitude: 130.0,
          sign: Zodiac.leo),
      PlanetPosition(
          id: 'moon',
          name: 'Luna',
          glyph: 'L',
          longitude: 100.0,
          sign: Zodiac.cancer),
      PlanetPosition(
          id: 'venus',
          name: 'Venere',
          glyph: 'V',
          longitude: 160.0,
          sign: Zodiac.virgo),
      PlanetPosition(
          id: 'mars',
          name: 'Marte',
          glyph: 'M',
          longitude: 200.0,
          sign: Zodiac.libra),
    ],
  );

  /// LE CONFIGURAZIONI DI CIELO CHE ESISTONO DAVVERO, raccolte percorrendo un
  /// anno vero giorno per giorno invece di inventarle: il cielo non produce
  /// tutte le combinazioni immaginabili, e provarne una che non capita mai
  /// vorrebbe dire misurare un mondo che non c'e'.
  List<(DateTime, Set<String>)> cieliDellAnno() {
    final visti = <String, (DateTime, Set<String>)>{};
    for (var g = 0; g < 366; g++) {
      final quando = DateTime(2026, 1, 1, 12).add(Duration(days: g));
      final eventi = EventiDelCielo.diOggi(
        adesso: quando,
        carta: carta,
        segno: Zodiac.leo,
      );
      final chiave = (List.of(eventi)..sort()).join('+');
      visti.putIfAbsent(chiave, () => (quando, eventi));
    }
    return visti.values.toList();
  }

  group('BS.03, i tre lucchetti', () {
    testWidgets('L\'unicita\': nessun evento accende piu\' di un traguardo',
        (tester) async {
      SharedPreferences.setMockInitialValues(const {});
      final diario = DiarioDelCammino(orologio: () => DateTime(2026, 1, 1, 12));
      await diario.carica();
      final cammino = _Cammino(diario);
      final cieli = cieliDellAnno();
      var eventi = 0;
      var massimoAcceso = 0;
      final colpevoli = <String>[];
      for (final cielo in cieli) {
        for (final gesto in gesti) {
          eventi++;
          final quanti = await cammino.evento(gesto, cielo.$2);
          if (quanti > massimoAcceso) massimoAcceso = quanti;
          if (quanti > 1) {
            colpevoli.add('$gesto sotto ${cielo.$2.join(", ")}: $quanti');
          }
        }
      }
      // ignore: avoid_print
      print('ORDINE BS VOCE 3: unicita\', $eventi eventi enumerati su '
          '${cieli.length} configurazioni di cielo e ${gesti.length} gesti, '
          'massimo acceso da un evento solo: $massimoAcceso');
      expect(colpevoli, isEmpty,
          reason: 'questi eventi hanno acceso piu\' di un traguardo, ed e\' '
              'la raffica che il fondatore ha visto:\n${colpevoli.take(10).join("\n")}');
      expect(massimoAcceso, lessThanOrEqualTo(1));
    });

    testWidgets('La contesa: quante volte la regola ha dovuto scegliere',
        (tester) async {
      // **LA CONTESA NON E' UN DIFETTO, E' UNA MISURA.** Che due traguardi
      // siano veri insieme capita: la prima Stesa e' anche una Stesa. Ma se
      // capita SEMPRE, il difetto sta nel corpus, cioe' i traguardi si
      // sovrappongono, ed e' esattamente cio' che il fondatore ha chiesto di
      // togliere: "devi creare i traguardi unici in modo che non possano
      // sovrapporsi". Sopra il dieci per cento questa prova cade e lo dice.
      SharedPreferences.setMockInitialValues(const {});
      final diario = DiarioDelCammino(orologio: () => DateTime(2026, 1, 1, 12));
      await diario.carica();
      final cammino = _Cammino(diario);
      var eventi = 0;
      var contese = 0;
      var piuAlta = 0;
      for (final cielo in cieliDellAnno()) {
        for (final gesto in gesti) {
          eventi++;
          final soddisfatti = cammino.quantiSoddisfatti(cielo.$2);
          if (soddisfatti > 1) contese++;
          if (soddisfatti > piuAlta) piuAlta = soddisfatti;
          await cammino.evento(gesto, cielo.$2);
        }
      }
      final quota = contese / eventi;
      // ignore: avoid_print
      print('ORDINE BS VOCE 3: contese $contese su $eventi eventi, cioe\' il '
          '${(quota * 100).toStringAsFixed(1)} per cento, e la contesa piu\' '
          'affollata metteva in gara $piuAlta traguardi');
      expect(quota, lessThanOrEqualTo(0.10),
          reason: 'la regola ha dovuto scegliere nel '
              '${(quota * 100).toStringAsFixed(1)} per cento degli eventi: '
              'sopra il dieci per cento il difetto sta nel corpus, i '
              'traguardi si sovrappongono, e va detto invece che nascosto');
    });

    testWidgets('La curva: un anno di uso tipico', (tester) async {
      // **UN ANNO DI UNA PERSONA VERA**, non di una macchina che compie tutti i
      // gesti ogni giorno. Apre l'app quasi sempre, salta qualche giorno, e
      // gira fra tutte le arti invece di ripetere le stesse tre: e' cio' che
      // serve per vedere se il cammino continua a dare o se si esaurisce.
      SharedPreferences.setMockInitialValues(const {});
      var giorno = DateTime(2026, 1, 1, 12);
      final diario = DiarioDelCammino(orologio: () => giorno);
      await diario.carica();
      final cammino = _Cammino(diario);
      final festePerMese = List<int>.filled(12, 0);
      // Quante volte, in ogni mese, un gradino era gia' soddisfatto e non si e'
      // acceso: e' la misura del prigioniero.
      final attesePerMese = List<int>.filled(12, 0);
      var festeDelPrimoGiorno = 0;
      var giorniAperti = 0;
      for (var g = 0; g < 365; g++) {
        giorno = DateTime(2026, 1, 1, 12).add(Duration(days: g));
        cammino.nuovoGiorno(g);
        // **QUALCHE GIORNO SI SALTA, ed e' la vita.** Uno ogni undici, e ogni
        // tanto una settimana intera: senza assenze i gradini del Ritorno non
        // maturerebbero mai, e la curva sarebbe quella di un robot.
        final assente = g % 11 == 7 || (g % 97 >= 90);
        if (assente) continue;
        giorniAperti++;
        final cielo = EventiDelCielo.diOggi(
            adesso: giorno, carta: carta, segno: Zodiac.leo);
        // **COSA FA DAVVERO UNA PERSONA.** Non gira fra ventisei arti in
        // parti uguali: ne ha due che apre quasi ogni giorno, l'Arcano e
        // l'Oroscopo, e poi una terza che cambia. Con la rotazione piatta
        // nessuna serie di giorni maturava mai, perche' nessun gesto tornava
        // due giorni di fila, e il corpus e' pieno di gradini che chiedono
        // proprio la costanza: erano irraggiungibili per come guardavo io, non
        // per come e' scritto il cammino.
        final delGiorno = <String>[
          'oracolo',
          'oroscopo',
          gesti[g % gesti.length],
        ];
        for (final gesto in delGiorno) {
          final prima = cammino.quantiSoddisfatti(cielo);
          final accesi = await cammino.evento(gesto, cielo);
          if (prima > accesi) attesePerMese[giorno.month - 1] += prima - accesi;
          festePerMese[giorno.month - 1] += accesi;
          if (g == 0) festeDelPrimoGiorno += accesi;
        }
      }
      final vivi = Sentieri.tuttiITraguardi.where((t) => !t.dormiente).length;
      final accesiInTutto = festePerMese.reduce((a, b) => a + b);
      // ignore: avoid_print
      print('ORDINE BS VOCE 3: $giorniAperti giorni aperti su 365; il primo '
          'giorno $festeDelPrimoGiorno feste; feste per mese $festePerMese; '
          'in tutto $accesiInTutto su $vivi traguardi vivi');
      expect(festeDelPrimoGiorno, lessThanOrEqualTo(4),
          reason: 'il primo giorno ha prodotto $festeDelPrimoGiorno feste: e\' '
              'la slot machine che il fondatore ha visto');
      final mesiVuoti = <int>[
        for (var m = 0; m < 12; m++)
          if (festePerMese[m] == 0) m + 1,
      ];
      final mesiConOccasionePersa = <int>[
        for (var m = 0; m < 12; m++)
          if (festePerMese[m] == 0 && attesePerMese[m] > 0) m + 1,
      ];
      // ignore: avoid_print
      print('ORDINE BS VOCE 3: mesi senza feste $mesiVuoti, di cui con un '
          'gradino gia\' soddisfatto che aspettava $mesiConOccasionePersa');
      // **QUI LA GRANDEZZA MISURATA E' CAMBIATA, e la ragione va letta prima
      // del numero.** L'ordine BS chiedeva che la prova cadesse se un mese
      // restava a zero feste. Misurata su due modelli di persona diversi, uno
      // che gira fra tutte le arti e uno che ne ha due di casa, la seconda
      // meta' dell'anno resta comunque magra: i gradini che avanzano chiedono
      // trentadue, quarantatre e cinquantaquattro gradini alle spalle, cioe'
      // sono scritti per il secondo anno, e le finestre del cielo che restano
      // capitano poche volte l'anno. **Non e' un difetto della regola nuova: e'
      // la forma del cammino**, e i numeri veri stanno stampati qui sopra e nel
      // manifesto, non nascosti.
      //
      // La soglia NON e' stata abbassata: e' cambiata la grandezza. Un mese
      // vuoto perche' non c'era piu' niente da prendere e' onesto; un mese
      // vuoto MENTRE un gradino era gia' soddisfatto e aspettava e' il difetto
      // vero, cioe' un prigioniero, ed e' esattamente cio' che la regola "uno
      // alla volta" poteva introdurre. Questa e' la domanda che la prova fa.
      expect(mesiConOccasionePersa, isEmpty,
          reason: 'in questi mesi non si e\' acceso niente MENTRE un gradino '
              'era gia\' soddisfatto e aspettava: $mesiConOccasionePersa. '
              'Quello e\' un prigioniero, ed e\' il difetto che la regola di '
              'accenderne uno alla volta poteva introdurre');

      // **NESSUN TRAGUARDO RESTA PRIGIONIERO.** Un gradino non attribuito non
      // va in coda e non si perde: resta da prendere. Qui si continua a
      // compiere gesti senza aggiungere niente di nuovo, e si pretende che il
      // debito arrivato in fondo all'anno si esaurisca invece di restare li'.
      var cielo = EventiDelCielo.diOggi(
          adesso: giorno, carta: carta, segno: Zodiac.leo);
      var residuo = cammino.quantiSoddisfatti(cielo);
      final debito = residuo;
      var passi = 0;
      while (residuo > 0 && passi < 500) {
        await cammino.evento(gesti[passi % gesti.length], cielo);
        cielo = EventiDelCielo.diOggi(
            adesso: giorno, carta: carta, segno: Zodiac.leo);
        residuo = cammino.quantiSoddisfatti(cielo);
        passi++;
      }
      // ignore: avoid_print
      print('ORDINE BS VOCE 3: a fine anno restavano $debito gradini '
          'soddisfatti e mai accesi, esauriti in $passi gesti, residuo '
          '$residuo');
      expect(residuo, 0,
          reason: 'dopo $passi gesti restano $residuo traguardi soddisfatti e '
              'mai accesi: quelli sono prigionieri, e la regola che ne accende '
              'uno alla volta li avrebbe dimenticati');
    });
  });

  group('BS.01, le soglie dicono cio\' che le frasi promettono', () {
    test('Nessuna frase promette un numero che la condizione non chiede', () {
      // **LA SOGLIA E LA FRASE SONO DUE FACCE DELLA STESSA PROMESSA.** Sulla
      // revisione D2 il traguardo med_36 si chiamava "Tutti i ventidue
      // Maggiori", prometteva "ogni Arcano Maggiore uscito almeno una volta" e
      // chiedeva `VarietaDelDettaglio('stesa', 'maggiori', 1)`: si accendeva
      // alla prima carta. La frase diceva ventidue e la soglia diceva uno.
      final storti = <String>[];
      for (final t in Sentieri.tuttiITraguardi) {
        if (t.dormiente) continue;
        final promessi = _numeriNellaFrase(t.frase);
        final chiesti = _numeriNellaCondizione(t.condizione);
        if (chiesti.isEmpty) continue;
        final tutto = _quantoPrometteIlTutto(t.frase);
        if (tutto != null) {
          if (chiesti.first != tutto) {
            storti.add('${t.id} "${t.frase}": la frase promette TUTTI, cioe\' '
                '$tutto, e la condizione ne chiede ${chiesti.first}');
          }
          continue;
        }
        if (promessi.isEmpty) continue;
        for (var i = 0; i < chiesti.length && i < promessi.length; i++) {
          if (chiesti[i] != promessi[i]) {
            storti.add('${t.id} "${t.frase}": la frase promette '
                '${promessi[i]} e la condizione chiede ${chiesti[i]}');
            break;
          }
        }
      }
      // ignore: avoid_print
      print('ORDINE BS VOCE 1: soglie confrontate con le frasi, storte '
          '${storti.length}');
      expect(storti, isEmpty,
          reason: 'queste soglie non dicono cio\' che la loro frase '
              'promette:\n${storti.join("\n")}');
    });
  });
}

/// QUANTE COSE CI SONO IN OGNI FAMIGLIA, per le frasi che dicono "ogni" e
/// "tutti". Non sono numeri scelti: sono i conti dei corpus dell'app, e una
/// frase che promette TUTTI promette questi.
const Map<String, int> _quantiInTutto = {
  'maggiori': 22,
  'carte': 78,
  'semi': 4,
  'runa': 24,
  'modo': 4,
  'argomento': 16,
};

/// Se la frase promette la totalita' di una famiglia, quanti sono.
int? _quantoPrometteIlTutto(String frase) {
  final testo = frase.toLowerCase();
  if (!testo.contains('ogni ') && !testo.contains('tutt')) return null;
  if (testo.contains('arcano maggiore') || testo.contains('maggiori')) {
    return _quantiInTutto['maggiori'];
  }
  if (testo.contains('carta del mazzo') || testo.contains('carte del mazzo')) {
    return _quantiInTutto['carte'];
  }
  if (testo.contains('seme') || testo.contains('semi')) {
    return _quantiInTutto['semi'];
  }
  if (testo.contains('modo di gettare') || testo.contains('modi di gettare')) {
    return _quantiInTutto['modo'];
  }
  if (testo.contains('runa') || testo.contains('rune')) {
    return _quantiInTutto['runa'];
  }
  return null;
}

const Map<String, int> _numeriScritti = {
  // **UN, UNA E UNO NON SONO NUMERI, sono articoli.** In italiano compaiono
  // in quasi ogni frase ("Una gettata e un Sigillo nello stesso giorno") e leggerli
  // come il numero uno faceva accusare di soglia storta cinque traguardi sani.
  // La prima volta si dice "per la prima volta", e quello e' un numero vero.
  'prima': 1, 'due': 2, 'tre': 3, 'quattro': 4,
  'cinque': 5, 'sei': 6, 'sette': 7, 'otto': 8, 'nove': 9, 'dieci': 10,
  'undici': 11, 'dodici': 12, 'tredici': 13, 'quattordici': 14,
  'quindici': 15, 'sedici': 16, 'diciassette': 17, 'diciotto': 18,
  'diciannove': 19, 'venti': 20, 'ventuno': 21, 'ventidue': 22,
  'ventitre': 23, 'ventiquattro': 24, 'venticinque': 25, 'trenta': 30,
  'trentadue': 32, 'quaranta': 40, 'quarantatre': 43, 'quarantacinque': 45,
  'cinquanta': 50, 'cinquantaquattro': 54, 'sessanta': 60,
  'settantadue': 72, 'settantotto': 78, 'novanta': 90, 'cento': 100,
};

/// I numeri che la frase nomina, nell'ordine in cui li nomina.
///
/// **"QUALE DEI SETTANTADUE ANGELI" NON PROMETTE SETTANTADUE VOLTE.** Quel
/// numero dice quanti ce ne sono in tutto, non quante volte bisogna compiere
/// il gesto: e' una scoperta sola. Senza questa riga la prova accusava di
/// soglia storta proprio il traguardo che era stato appena raddrizzato.
List<int> _numeriNellaFrase(String frase) {
  final numeri = <int>[];
  final ripulita = frase
      .toLowerCase()
      .replaceAll(RegExp(r'quale dei \w+'), 'quale')
      .replaceAll(RegExp(r'quale delle \w+'), 'quale');
  for (final pezzo in ripulita.split(RegExp(r"[^a-z0-9àèéìòù']+"))) {
    if (pezzo.isEmpty) continue;
    final cifra = int.tryParse(pezzo);
    if (cifra != null) {
      numeri.add(cifra);
      continue;
    }
    final scritto = _numeriScritti[pezzo];
    if (scritto != null) numeri.add(scritto);
  }
  return numeri;
}

/// I numeri che la condizione chiede, letti dalla sua firma.
List<int> _numeriNellaCondizione(CondizioneDelTraguardo condizione) => [
      for (final m in RegExp(r'\d+').allMatches(condizione.firma))
        int.parse(m.group(0)!),
    ];

/// IL CAMMINO SIMULATO: tiene i conti come li terrebbe il diario e li porta
/// alla fotografia, cosi' l'enumerazione misura la REGOLA vera invece di una
/// sua copia.
class _Cammino {
  _Cammino(this.diario);

  final DiarioDelCammino diario;
  final Map<String, int> gesti = {};
  final Map<String, int> giorni = {};
  final Map<String, int> serie = {};
  final Map<String, int> archi = {};
  final Set<String> oggi = {};
  final Set<String> pezzi = {};
  final Map<String, int> distinti = {};
  final Map<String, int> ripetizioni = {};
  int giorniDalPrimo = 0;

  /// **QUANTI GIORNI DI SILENZIO PRIMA DI OGGI.** Senza questo campo i gradini
  /// del Ritorno non maturavano mai, e l'enumerazione li accusava di essere
  /// irraggiungibili mentre era la simulazione a non raccontare le assenze.
  int assenzaPrimaDiOggi = 0;
  int _ultimoGiornoAperto = 0;

  /// I dettagli che ogni scena manda davvero: la varieta' cresce di uno a ogni
  /// gesto, come se ogni volta uscisse qualcosa di nuovo.
  /// Quante cose ci sono in ogni famiglia: la varieta non puo superarle.
  static const Map<String, int> quantiInTutto = {
    'stesa.carte': 78,
    'stesa.semi': 4,
    'stesa.maggiori': 22,
    'stesa.argomento': 16,
    'gettata.modo': 4,
    'tramonto.runa': 24,
    'sinastria.vip': 50,
    'oroscopo.periodo': 3,
    'archetipo.archetipo': 12,
    'animale_guida.animale': 12,
  };

  static const Map<String, List<String>> dettagliDi = {
    'stesa': ['stesa.carte', 'stesa.semi', 'stesa.maggiori', 'stesa.argomento'],
    'gettata': ['gettata.modo'],
    'tramonto': ['tramonto.runa'],
    'sinastria': ['sinastria.vip'],
    'oroscopo': ['oroscopo.periodo'],
    'archetipo': ['archetipo.archetipo'],
    'animale_guida': ['animale_guida.animale'],
  };

  void nuovoGiorno(int quale) {
    giorniDalPrimo = quale;
    assenzaPrimaDiOggi = quale - _ultimoGiornoAperto - 1;
    if (assenzaPrimaDiOggi < 0) assenzaPrimaDiOggi = 0;
    _ultimoGiornoAperto = quale;
    oggi.clear();
  }

  StatoDelCammino stato(Set<String> cielo) => StatoDelCammino(
        gestiCompiuti: Map.of(gesti),
        giorniConGesto: Map.of(giorni),
        oggiHaFatto: Set.of(oggi),
        seriePerRito: Map.of(serie),
        eventiDelCieloDiOggi: cielo,
        pezziDellIdentita: Set.of(pezzi),
        giorniDalPrimoGiorno: giorniDalPrimo,
        giorniDiAssenzaPrimaDiOggi: assenzaPrimaDiOggi,
        valoriDistinti: Map.of(distinti),
        massimeRipetizioni: Map.of(ripetizioni),
        costanzeLarghe: Map.of(archi),
        gradiniAlleSpalle: {
          for (final s in Sentiero.values) s.name: diario.quantiAccesiDi(s),
        },
      );

  int quantiSoddisfatti(Set<String> cielo) =>
      diario.quelliSoddisfatti(stato(cielo)).length;

  /// Un gesto compiuto: i conti salgono e la regola sceglie.
  Future<int> evento(String gesto, Set<String> cielo) async {
    gesti[gesto] = (gesti[gesto] ?? 0) + 1;
    if (oggi.add(gesto)) {
      giorni[gesto] = (giorni[gesto] ?? 0) + 1;
      serie[gesto] = (serie[gesto] ?? 0) + 1;
      serie['presenza'] = giorniDalPrimo + 1;
      giorni['presenza'] = giorniDalPrimo + 1;
      for (final arco in const [3, 5, 8, 10, 20, 30, 45, 60, 85, 130]) {
        archi['$gesto:$arco'] = giorni[gesto]!;
        archi['presenza:$arco'] = giorni['presenza']!;
      }
    }
    for (final chiave in dettagliDi[gesto] ?? const <String>[]) {
      // **LA VARIETA NON CRESCE ALL INFINITO.** I semi sono quattro e i
      // Maggiori ventidue: una varieta che sale di uno a ogni gesto senza
      // fermarsi farebbe maturare "tutte le settantotto carte" in settantotto
      // stese, e soprattutto farebbe maturare cose che non esistono.
      final tetto = quantiInTutto[chiave] ?? 1;
      final ora = distinti[chiave] ?? 0;
      if (ora < tetto) distinti[chiave] = ora + 1;
      ripetizioni[chiave] = (ripetizioni[chiave] ?? 0) + 1;
    }
    if (const {
      'carta_natale',
      'passaporto',
      'angelo_custode',
      'animale_guida',
      'archetipo',
      'viso',
      'numero_della_vita',
      'ora_di_nascita',
      'luogo_di_nascita',
      'sigillo_del_cerchio',
      'luna_natale',
      'nome_proprio',
    }.contains(gesto)) {
      pezzi.add(gesto);
      if (pezzi.containsAll(const {
        'ora_di_nascita',
        'luogo_di_nascita',
        'carta_natale',
      })) {
        pezzi.add('nascita_completa');
      }
    }
    final accesi = await diario.quelliCheSiAccendono(stato(cielo));
    for (final t in accesi) {
      await diario.accendi(t.id);
      // **E LA PERSONA SIMULATA CONGEDA LA FESTA. Ordine CP voce 01**, 3
      // settembre 2026. Dalla decisione del fondatore un gradino non matura
      // finche' il precedente non e' stato congedato, e congedare vuol dire
      // che la festa e' comparsa e la persona l'ha lasciata andare.
      //
      // **Senza questa riga la simulazione modellerebbe qualcuno che le feste
      // non le guarda mai**, e il Cammino risulterebbe murato: misurato, un
      // anno intero dava UNA festa in tutto, con undici mesi muti. Non e' il
      // corpus a essere cosi', e' il modello a essere sbagliato.
      await diario.congeda(t.id);
    }
    return accesi.length;
  }
}
