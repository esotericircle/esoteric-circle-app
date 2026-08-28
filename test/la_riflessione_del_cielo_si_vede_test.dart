import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:esoteric_circle/core/astro/birth_place.dart' as astro;
import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/horoscope/cielo_di_oggi.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/horoscope/riflessione_del_cielo.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:flutter/material.dart';
import 'package:esoteric_circle/core/astro/effemeridi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LA RIFLESSIONE DEL CIELO SI VEDE. Ordine BK, voci 02, 03 e 05.
///
/// **Il difetto, in una riga.** Al tocco le quattro schede montavano subito e
/// `scrivendo` valeva falso per due secondi: con `scrivendo` falso il responso
/// si costruisce INTERO, quindi la pausa esisteva nel codice e non era mai
/// visibile, e la macchina da scrivere partiva su un testo gia' letto. Parole
/// del fondatore: "il risultato dell'oroscopo arriva di botto".
///
/// **La misura che chiude.** Dal tocco fino alla fine della riflessione, il
/// numero di caratteri del responso presenti nell'albero dei widget e' ZERO,
/// su tutte e quattro le schede. Non "trasparenti", non "sotto la piega":
/// assenti.
///
/// Nessun numero e' battuto in questo file: le durate vengono da
/// `RiflessioneDelCielo`, e le soglie dell'ordine sono confrontate con quelle
/// costanti. Se domani qualcuno cambia una durata nel codice, sono queste
/// prove a dire se e' ancora dentro cio' che il fondatore ha chiesto.
void main() {
  final carta = NatalChart(
    sunSign: Zodiac.leo,
    planets: const [
      PlanetPosition(
          id: 'sun',
          name: 'Sole',
          glyph: '☉',
          longitude: 128.4,
          sign: Zodiac.leo),
      PlanetPosition(
          id: 'moon',
          name: 'Luna',
          glyph: '☽',
          longitude: 12.7,
          sign: Zodiac.leo),
      PlanetPosition(
          id: 'venus',
          name: 'Venere',
          glyph: '♀',
          longitude: 150.2,
          sign: Zodiac.leo),
      PlanetPosition(
          id: 'mars',
          name: 'Marte',
          glyph: '♂',
          longitude: 61.9,
          sign: Zodiac.leo),
      PlanetPosition(
          id: 'saturn',
          name: 'Saturno',
          glyph: '♄',
          longitude: 300.5,
          sign: Zodiac.leo),
    ],
    ascendantLongitude: 205.0,
    midheavenLongitude: 115.0,
    houses: [
      for (var n = 1; n <= 12; n++)
        HouseCusp(number: n, longitude: (205.0 + (n - 1) * 30.0) % 360.0),
    ],
    hasTime: true,
  );

  /// Tutto il testo davvero presente nell'albero, dai widget che lo dipingono,
  /// MENO la riga della riflessione.
  ///
  /// **Perche' quella riga va tolta, ed e' una correzione della grandezza
  /// misurata e non della soglia.** Il secondo momento nomina il fatto vero
  /// del giorno, e lo stesso fatto e' materia con cui `CorrenteDelCielo`
  /// scrive i testi del responso: la prima stesura di questa prova contava
  /// 140 caratteri "di responso" a riflessione ancora in corso, ed erano i
  /// caratteri della riflessione stessa. Contarli sarebbe stato accusare la
  /// cura del difetto che ha tolto.
  String testoInAlbero(WidgetTester tester) {
    final riflessione = find.byKey(const Key('oroscopo_riflessione_riga'));
    final daTogliere = <String>{};
    if (riflessione.evaluate().isNotEmpty) {
      for (final t in tester.widgetList<Text>(
          find.descendant(of: riflessione, matching: find.byType(Text)))) {
        if (t.data != null) daTogliere.add(t.data!);
      }
      for (final r in tester.widgetList<RichText>(
          find.descendant(of: riflessione, matching: find.byType(RichText)))) {
        daTogliere.add(r.text.toPlainText());
      }
    }
    final pezzi = <String>[];
    for (final t in tester.widgetList<Text>(find.byType(Text))) {
      if (t.data != null && !daTogliere.contains(t.data)) pezzi.add(t.data!);
    }
    for (final r in tester.widgetList<RichText>(find.byType(RichText))) {
      final testo = r.text.toPlainText();
      if (!daTogliere.contains(testo)) pezzi.add(testo);
    }
    return pezzi.join('\n');
  }

  /// I quattro testi del responso per questo segno e questo giorno.
  List<String> responsiAttesi(DateTime adesso) => [
        for (final d in HoroscopeDomain.values)
          Horoscope.cardFor(
            sign: Zodiac.leo,
            dayOfYear: Horoscope.dayOfYear(adesso),
            year: adesso.year,
            domain: d,
            cielo: CieloDiOggi.perIlGiorno(adesso: adesso, carta: carta),
            profonda: false,
          ).text,
      ];

  /// Quanti caratteri dei quattro responsi sono presenti a video adesso.
  ///
  /// **Si contano per pezzi lunghi e non per singolo carattere**: una parola
  /// corta come "e" comparirebbe per caso in qualunque schermata. Ogni
  /// responso viene tagliato in tratti da venti caratteri, e si conta ogni
  /// tratto che l'albero contiene davvero.
  int caratteriDelResponso(WidgetTester tester, List<String> responsi) {
    final avideo = testoInAlbero(tester);
    var quanti = 0;
    for (final r in responsi) {
      for (var i = 0; i + 20 <= r.length; i += 20) {
        if (avideo.contains(r.substring(i, i + 20))) quanti += 20;
      }
    }
    return quanti;
  }

  Future<void> monta(WidgetTester tester, DateTime adesso,
      {bool riduciMovimento = false}) async {
    tester.view.physicalSize = const Size(360, 797) * 3.0;
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    final nascita = BirthIdentityController();
    nascita.setBirth(
      BirthDetails(
        date: DateTime(1990, 8, 10),
        time: const TimeOfDay(hour: 12, minute: 0),
        place: const astro.BirthPlace(
            label: 'Roma',
            latitude: 41.9,
            longitude: 12.5,
            timezone: 'Europe/Rome'),
      ),
      carta,
    );
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(
            create: (_) => EntitlementService(initial: Tier.tier1)),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider<BirthIdentityController>.value(value: nascita),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx)
              .copyWith(disableAnimations: riduciMovimento),
          child: MaestroScope(child: child!),
        ),
        home: OroscopoScreen(userSign: Zodiac.leo, now: adesso),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  // ------------------------------------------------------------------
  // BK.03, le durate: i numeri dell'ordine contro i numeri del codice.
  // ------------------------------------------------------------------
  group('le durate stanno dentro cio\' che il fondatore ha chiesto', () {
    // **I NUMERI SONO QUELLI DELL'ORDINE BZ VOCE 06, e sostituiscono quelli
    // dell'ordine BK.** Parole del fondatore: "parte una animazione strana che
    // dura una frazione di secondo... mi sembra cmq scarsa". La finestra fra
    // 2,8 e 3,2 secondi era una sua richiesta di prima; questa e' una sua
    // richiesta di adesso, e vince l'ultima. **Le soglie non si abbassano**:
    // qui salgono tutte, compresi i due tetti delle schede, che dalla durata
    // della riflessione dipendono per costruzione.
    test('la riflessione piena dura almeno 4 secondi', () {
      final intera = RiflessioneDelCielo.intera(piena: true);
      // ignore: avoid_print
      print('ORDINE BZ VOCE 6: riflessione piena ${intera.inMilliseconds} '
          'millesimi, breve '
          '${RiflessioneDelCielo.intera(piena: false).inMilliseconds}');
      expect(intera.inMilliseconds, greaterThanOrEqualTo(4000));
      expect(intera.inMilliseconds, lessThanOrEqualTo(5000),
          reason: 'oltre i cinque secondi non e\' piu\' una riflessione, e\' '
              'un\'attesa');
    });

    test('ciascuno dei due momenti resta almeno 1,5 secondi', () {
      expect(RiflessioneDelCielo.momento(piena: true).inMilliseconds,
          greaterThanOrEqualTo(1500),
          reason: 'un momento troppo corto e\' un lampo, non qualcosa da '
              'guardare');
      expect(RiflessioneDelCielo.numeroDeiMomenti, 2,
          reason: 'i momenti sono due, come il fondatore ha chiesto');
    });

    test('anche la riflessione breve dura almeno 3 secondi', () {
      // **ERA QUI IL DIFETTO VISTO DAL FONDATORE**: chi aveva gia'
      // interrogato il cielo quel giorno vedeva due momenti da mezzo secondo.
      final breve = RiflessioneDelCielo.intera(piena: false);
      expect(breve.inMilliseconds, greaterThanOrEqualTo(3000),
          reason: 'la seconda interrogazione del giorno dura '
              '${breve.inMilliseconds} millesimi: e\' la frazione di secondo '
              'che il fondatore ha visto');
      expect(breve.inMilliseconds,
          lessThan(RiflessioneDelCielo.intera(piena: true).inMilliseconds),
          reason: 'la seconda volta resta piu\' svelta della prima');
    });

    test('la prima scheda e\' intera entro 5,0 secondi dal tocco', () {
      expect(
          RiflessioneDelCielo.finoAllaPrimaScheda(piena: true).inMilliseconds,
          lessThanOrEqualTo(5000));
    });

    test('l\'ultima delle quattro e\' intera entro 7,0 secondi dal tocco', () {
      expect(
          RiflessioneDelCielo.finoAllUltimaScheda(HoroscopeDomain.values.length,
                  piena: true)
              .inMilliseconds,
          lessThanOrEqualTo(7000));
    });
  });

  // ------------------------------------------------------------------
  // BZ.06, la durata MISURATA A VIDEO, non quella dichiarata in una costante.
  // ------------------------------------------------------------------
  testWidgets(
      'BZ.06: la riflessione sta in scena per quattro secondi, e la corona '
      'con lei', (tester) async {
    // **LA GRANDEZZA MISURATA E\' IL TEMPO FRA IL PRIMO E L\'ULTIMO FOTOGRAMMA
    // in cui la riflessione e\' in albero**, contato a passi di cento
    // millesimi. Una costante puo\' dire quattromila e la scena sparire dopo
    // cinquecento: quello che il fondatore ha visto e\' lo schermo, non il
    // codice.
    final adesso = DateTime(2026, 8, 20, 9);
    await monta(tester, adesso);
    await tester.tap(find.byKey(const Key('oroscopo_interroga')));
    var fotogrammi = 0;
    var conLaCorona = 0;
    final glifi = <String>[];
    for (var t = 0; t < 12000; t += 100) {
      await tester.pump(const Duration(milliseconds: 100));
      final inScena = find
          .byKey(const Key('oroscopo_riflessione_riga'))
          .evaluate()
          .isNotEmpty;
      if (!inScena) {
        if (fotogrammi > 0) break;
        continue;
      }
      fotogrammi++;
      if (find
          .byKey(const Key('oroscopo_corona_dei_corpi'))
          .evaluate()
          .isNotEmpty) {
        conLaCorona++;
        // I glifi si guardano MENTRE la corona e' in scena: dopo non c'e'
        // piu' niente da guardare, e la prima stesura li contava a scena
        // finita trovandone zero.
        if (glifi.isEmpty) {
          for (final corpo in CorpoCeleste.values) {
            final dove = find.byKey(Key('riflessione_glifo_${corpo.id}'));
            if (dove.evaluate().isEmpty) continue;
            final t = tester.widget<Text>(dove);
            expect(t.data, corpo.glifo,
                reason: 'il corpo ${corpo.nome} non porta il proprio glifo');
            expect(t.style?.fontFamily, 'NotoSansSymbols',
                reason: 'il glifo di ${corpo.nome} e\' scritto col carattere '
                    'del testo, che quei simboli non li ha: a video resta un '
                    'quadrato');
            glifi.add(corpo.glifo);
          }
        }
      }
    }
    final durata = fotogrammi * 100;
    // ignore: avoid_print
    print('ORDINE BZ VOCE 6: la riflessione resta in scena $durata millesimi, '
        'con la corona dei corpi per $conLaCorona fotogrammi su $fotogrammi');
    expect(durata, greaterThanOrEqualTo(3800),
        reason: 'la riflessione resta a video $durata millesimi: e\' la '
            'frazione di secondo che il fondatore ha visto');
    expect(conLaCorona, fotogrammi,
        reason: 'la corona dei corpi sparisce per ${fotogrammi - conLaCorona} '
            'fotogrammi su $fotogrammi: la scena si svuota a meta\' e resta una '
            'riga di testo');
    // **E OGNI CORPO PORTA IL SUO GLIFO, non un cerchio giallo.**
    //
    // Parole del fondatore: "si formano dei piccoli cerchi gialli intorno
    // all'emblema del segno... mi sembra cmq scarsa". Erano dischi dorati
    // nudi, perche' quando la corona nacque il font dei simboli non era un
    // asset di questo repository. Adesso lo e', e i glifi si sono guardati
    // dentro il ciclo qui sopra, mentre la corona era in scena.
    // ignore: avoid_print
    print('ORDINE BZ VOCE 6: i corpi in corona portano i glifi $glifi');
    expect(glifi.length, greaterThanOrEqualTo(7),
        reason: 'in corona ci sono ${glifi.length} corpi col glifo: sotto i '
            'sette il cielo non e\' quello vero');

    // E dopo la riflessione il responso c'e' davvero, o si starebbe misurando
    // una scena che non finisce mai.
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    expect(find.byKey(const Key('oroscopo_riflessione_riga')), findsNothing);
  });

  // ------------------------------------------------------------------
  // BK.02, la misura che chiude: zero caratteri durante la riflessione.
  // ------------------------------------------------------------------
  testWidgets(
      'dal tocco alla fine della riflessione i caratteri del responso sono ZERO',
      (tester) async {
    SharedPreferences.setMockInitialValues(const {});
    final adesso = DateTime.utc(2026, 8, 5, 12);
    await monta(tester, adesso);
    final responsi = responsiAttesi(adesso);

    // Prima del tocco non c'e' responso: e' il gesto che apre il consulto.
    expect(caratteriDelResponso(tester, responsi), 0);

    await tester.tap(find.byKey(const Key('oroscopo_interroga')));

    // IL PRIMO FOTOGRAMMA DOPO IL TOCCO, che e' quello in cui il difetto si
    // vedeva: il testo compariva tutto qui.
    await tester.pump();
    expect(caratteriDelResponso(tester, responsi), 0,
        reason: 'nel primo fotogramma dopo il tocco il responso non deve '
            'esistere: e\' esattamente il difetto che il fondatore ha visto');

    // E per tutta la riflessione, fotogramma per fotogramma.
    final passo = RiflessioneDelCielo.momento(piena: true);
    var trascorso = Duration.zero;
    final intera = RiflessioneDelCielo.intera(piena: true);
    // **L'INTERVALLO E' APERTO A DESTRA, e non e' un cavillo.** La misura
    // dell'ordine dice "dal tocco fino alla FINE della riflessione": all'ultimo
    // millesimo la riflessione e' finita e la prima scheda e' gia' nata, che e'
    // esattamente cio' che deve succedere. Un ciclo che controllasse anche
    // quell'istante accuserebbe la cura del difetto che ha tolto.
    const grana = Duration(milliseconds: 100);
    while (trascorso.inMilliseconds + grana.inMilliseconds <
        intera.inMilliseconds) {
      await tester.pump(grana);
      trascorso += grana;
      expect(caratteriDelResponso(tester, responsi), 0,
          reason: 'a ${trascorso.inMilliseconds} millesimi dal tocco la '
              'riflessione e\' ancora in corso e il responso non deve '
              'essere in albero');
    }

    // Fin qui la riflessione era ancora in corso: la riga dei momenti c'e'.
    expect(find.byKey(const Key('oroscopo_riflessione_riga')), findsOneWidget,
        reason: 'a un decimo dalla fine la riflessione deve essere ancora a '
            'schermo, o non e\' durata quanto dichiara');

    // Passato l'ultimo istante, la riflessione finisce e il responso nasce.
    await tester.pump(grana);
    expect(find.byKey(const Key('oroscopo_riflessione_riga')), findsNothing,
        reason: 'a riflessione finita la riga dei momenti esce di scena');
    await tester.pump(RiflessioneDelCielo.scritturaDiUnaScheda +
        const Duration(milliseconds: 100));
    expect(caratteriDelResponso(tester, responsi), greaterThan(0),
        reason: 'finita la riflessione il responso deve comparire, o la cura '
            'avrebbe tolto il difetto togliendo anche l\'oroscopo');
    expect(passo.inMilliseconds, greaterThan(0));
    // La cascata deve esaurirsi prima che il test finisca.
    await tester.pump(const Duration(seconds: 6));
  });

  // ------------------------------------------------------------------
  // BK.03, i due momenti sono leggibili e nominano il cielo VERO.
  // ------------------------------------------------------------------
  testWidgets('i due momenti si susseguono, e il secondo nomina un fatto vero',
      (tester) async {
    SharedPreferences.setMockInitialValues(const {});
    final adesso = DateTime.utc(2026, 8, 5, 12);
    await monta(tester, adesso);
    final cielo = CieloDiOggi.perIlGiorno(adesso: adesso, carta: carta);
    // La carta e' completa: il cielo vero c'e', quindi il secondo momento
    // deve nominare un transito e non ripiegare.
    expect(cielo.ceCieloVero, isTrue,
        reason: 'questa prova serve a misurare il caso col cielo vero: se la '
            'carta non lo da\', sta misurando altro');

    await tester.tap(find.byKey(const Key('oroscopo_interroga')));
    await tester.pump();

    // PRIMO MOMENTO: il cielo si raccoglie, coi corpi veri attorno.
    expect(find.byKey(const Key('oroscopo_riflessione_raccolta')),
        findsOneWidget);
    expect(find.byKey(const Key('oroscopo_corona_dei_corpi')), findsOneWidget,
        reason: 'il primo momento mostra i corpi veri del giorno');
    expect(find.byKey(const Key('oroscopo_riflessione_nomina')), findsNothing);

    // Poco PRIMA della fine del primo momento e' ancora il primo.
    await tester.pump(RiflessioneDelCielo.momento(piena: true) -
        const Duration(milliseconds: 50));
    expect(find.byKey(const Key('oroscopo_riflessione_raccolta')),
        findsOneWidget,
        reason: 'il primo momento deve restare a schermo per la sua durata '
            'intera, o non sarebbe leggibile');

    // SECONDO MOMENTO.
    await tester.pump(const Duration(milliseconds: 100));
    expect(
        find.byKey(const Key('oroscopo_riflessione_nomina')), findsOneWidget);
    expect(find.byKey(const Key('oroscopo_riflessione_raccolta')), findsNothing);

    // E nomina il fatto VERO, quello che verra' usato: non una frase scritta
    // a mano dentro la schermata.
    final atteso = RiflessioneDelCielo.fattoDaNominare(cielo);
    expect(atteso, isNotNull);
    expect(find.text(atteso!), findsOneWidget,
        reason: 'il secondo momento nomina il fatto del giorno preso da '
            'CorrenteDelCielo, la stessa porta della chiamata del mattino');
    expect(atteso, isNot(RiflessioneDelCielo.senzaCieloVero));
    // **L'ITALIANO DELLA RIGA, ordine BK voce 03.** Il Sole e la Luna hanno
    // l'articolo, gli altri no perche' sono nomi propri: "Oggi Sole forma" e'
    // lo stesso errore di "al tuo Luna di nascita". L'anteprima guardata lo
    // portava a video, e da qui in poi una prova lo sorveglia.
    expect(atteso, isNot(startsWith('Oggi Sole ')),
        reason: 'in italiano si dice "il Sole", e il mattone colSuoArticolo '
            'esiste da prima di questo ordine');
    expect(atteso, isNot(startsWith('Oggi Luna ')),
        reason: 'in italiano si dice "la Luna"');
    // Si lascia finire il rito: un timer ancora in volo a fine prova e' un
    // errore del test, non del codice.
    await tester.pump(const Duration(seconds: 8));
  });

  testWidgets('senza carta natale il secondo momento NON finge un transito',
      (tester) async {
    SharedPreferences.setMockInitialValues(const {});
    final adesso = DateTime.utc(2026, 8, 5, 12);
    tester.view.physicalSize = const Size(360, 797) * 3.0;
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    // Nessuna carta: chi ha dato solo il segno non ha case ne' aspetti.
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(
            create: (_) => EntitlementService(initial: Tier.tier1)),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => BirthIdentityController()),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MaestroScope(child: child!),
        home: OroscopoScreen(userSign: Zodiac.leo, now: adesso),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.byKey(const Key('oroscopo_interroga')));
    await tester.pump();
    await tester.pump(RiflessioneDelCielo.momento(piena: true) +
        const Duration(milliseconds: 50));

    expect(find.text(RiflessioneDelCielo.senzaCieloVero), findsOneWidget,
        reason: 'senza cielo vero il secondo momento dichiara che la lettura '
            'parla al segno: inventare un transito qui sarebbe una promessa '
            'non mantenuta detta proprio mentre la persona guarda');
    await tester.pump(const Duration(seconds: 8));
  });

  // ------------------------------------------------------------------
  // BK.03, Riduci Movimento: i momenti restano, con la stessa durata.
  // ------------------------------------------------------------------
  testWidgets('con Riduci Movimento la riflessione NON si salta',
      (tester) async {
    SharedPreferences.setMockInitialValues(const {});
    final adesso = DateTime.utc(2026, 8, 5, 12);
    await monta(tester, adesso, riduciMovimento: true);
    final responsi = responsiAttesi(adesso);

    await tester.tap(find.byKey(const Key('oroscopo_interroga')));
    await tester.pump();
    // Il primo momento c'e', fermo ma c'e'.
    expect(find.byKey(const Key('oroscopo_riflessione_raccolta')),
        findsOneWidget,
        reason: 'chi ha tolto le animazioni non ha chiesto di saltare il '
            'rito: il ritorno anticipato di prima e\' il comportamento che '
            'l\'ordine BK vieta');
    expect(caratteriDelResponso(tester, responsi), 0);

    // E dura quanto l'altra: a meta' riflessione il responso non c'e' ancora.
    await tester.pump(RiflessioneDelCielo.momento(piena: true) +
        const Duration(milliseconds: 50));
    expect(
        find.byKey(const Key('oroscopo_riflessione_nomina')), findsOneWidget);
    expect(caratteriDelResponso(tester, responsi), 0);

    // Alla fine il responso arriva, tutto insieme e gia' intero.
    await tester.pump(RiflessioneDelCielo.momento(piena: true) +
        const Duration(milliseconds: 100));
    expect(caratteriDelResponso(tester, responsi), greaterThan(0));
    await tester.pump(const Duration(seconds: 8));
  });

  // ------------------------------------------------------------------
  // BK.05, l'attesa piena una volta al giorno.
  // ------------------------------------------------------------------
  group('l\'attesa piena e\' una volta al giorno', () {
    testWidgets('la prima interrogazione del giorno ha la riflessione piena',
        (tester) async {
      SharedPreferences.setMockInitialValues(const {});
      final adesso = DateTime.utc(2026, 8, 5, 12);
      await monta(tester, adesso);
      await tester.tap(find.byKey(const Key('oroscopo_interroga')));
      await tester.pump();
      // Poco prima della fine della riflessione PIENA si sta ancora
      // riflettendo: con quella breve avrebbe gia' finito da un pezzo.
      await tester.pump(RiflessioneDelCielo.intera(piena: false) +
          const Duration(milliseconds: 100));
      expect(find.byKey(const Key('oroscopo_riflessione_riga')), findsOneWidget,
          reason: 'la prima volta del giorno l\'attesa e\' quella piena');
      await tester.pump(RiflessioneDelCielo.intera(piena: true));
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('la seconda dello stesso giorno ha la riflessione breve',
        (tester) async {
      // Il disco dice che l'attesa piena e' gia' stata spesa oggi.
      SharedPreferences.setMockInitialValues({
        MemoriaDellaRiflessione.chiave: '2026-8-5',
      });
      final adesso = DateTime(2026, 8, 5, 12);
      await monta(tester, adesso);
      await tester.tap(find.byKey(const Key('oroscopo_interroga')));
      await tester.pump();
      // Passata la riflessione BREVE, il responso comincia.
      await tester.pump(RiflessioneDelCielo.intera(piena: false) +
          const Duration(milliseconds: 100));
      expect(find.byKey(const Key('oroscopo_riflessione_riga')), findsNothing,
          reason: 'dalla seconda volta del giorno la riflessione e\' breve: '
              'i momenti sono compressi, non saltati');
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('dopo il confine del giorno l\'attesa piena torna',
        (tester) async {
      // Il disco porta IERI: il confine e' stato attraversato.
      SharedPreferences.setMockInitialValues({
        MemoriaDellaRiflessione.chiave: '2026-8-4',
      });
      final adesso = DateTime(2026, 8, 5, 0, 1);
      await monta(tester, adesso);
      await tester.tap(find.byKey(const Key('oroscopo_interroga')));
      await tester.pump();
      await tester.pump(RiflessioneDelCielo.intera(piena: false) +
          const Duration(milliseconds: 100));
      expect(find.byKey(const Key('oroscopo_riflessione_riga')), findsOneWidget,
          reason: 'passata la mezzanotte il conteggio si ripristina, come il '
              'fondatore ha chiesto');
      await tester.pump(RiflessioneDelCielo.intera(piena: true));
      await tester.pump(const Duration(seconds: 4));
    });

    test('il confine del giorno e\' quello dell\'app, non un secondo confine',
        () async {
      SharedPreferences.setMockInitialValues(const {});
      final giorno = DateTime(2026, 8, 5, 23, 59);
      await MemoriaDellaRiflessione.segnaSpesaOggi(giorno);
      expect(await MemoriaDellaRiflessione.giaSpesaOggi(giorno), isTrue);
      // Un minuto dopo e' un altro giorno, e l'attesa piena torna.
      expect(
          await MemoriaDellaRiflessione.giaSpesaOggi(
              DateTime(2026, 8, 6, 0, 0)),
          isFalse);
    });
  });
}
