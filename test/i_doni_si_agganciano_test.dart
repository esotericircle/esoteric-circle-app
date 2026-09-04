import 'dart:io';

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/rituals/daily_elements.dart';
import 'package:esoteric_circle/core/rituals/filo_del_giorno.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/rituals/day_oracle_screen.dart';
import 'package:esoteric_circle/features/rituals/ritual_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// I DONI DEL GIORNO, ordine P voci 16, 17 e 18.
///
/// La legge che governa la sezione: **un dono che si esaurisce quando lo apri
/// non produce ritorni. Un dono che apre qualcosa che si chiude piu' tardi,
/// si'.** Le tre voci sono tre modi di applicarla, e queste prove le misurano
/// una per una.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzia() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (call) async => null);
    for (final nome in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      m.setMockStreamHandler(
          EventChannel(nome), MockStreamHandler.inline(onListen: (a, e) {}));
    }
  }

  Widget attorno(Widget scena) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: MaestroScope(child: scena),
        ),
      );

  group('P.16 l\'Oracolo del Giorno', () {
    test('il gesto dell\'inclinazione esiste come valore, non come promessa',
        () {
      // **LA PREMESSA VERIFICATA.** L'Oracolo dichiarava, nel commento e a
      // schermo, che si rivela inclinando il telefono. Prima di questa voce
      // `RitualGesture` aveva quattro valori e nessuno leggeva il giroscopio:
      // la promessa stava in due punti e il codice in nessuno.
      expect(RitualGesture.values, contains(RitualGesture.tilt));
    });

    test('l\'Oracolo dichiara il gesto dell\'inclinazione', () {
      final sorgente = File('lib/features/rituals/day_oracle_screen.dart')
          .readAsStringSync();
      expect(sorgente, contains('gesture: RitualGesture.tilt'),
          reason: 'l\'Oracolo e\' tornato a un gesto che non e\' quello che '
              'dichiara alla persona');
      // E la vista legge davvero il sensore.
      final vista =
          File('lib/features/rituals/ritual_view.dart').readAsStringSync();
      expect(vista, contains('TiltListener'),
          reason: 'nessuno legge il giroscopio: il gesto e\' un valore vuoto');
      expect(vista, contains('RitualGesture.tilt'),
          reason: 'il gesto dell\'inclinazione non e\' collegato a niente');
    });

    testWidgets('dice cosa stai per ricevere PRIMA del gesto', (tester) async {
      silenzia();
      await tester.pumpWidget(
          attorno(DayOracleScreen(now: DateTime(2026, 8, 12, 13, 0))));
      await tester.pump();
      final riga = find.byKey(const Key('rito_cosa_ricevi'));
      expect(riga, findsOneWidget,
          reason: 'nessuno compie un gesto senza sapere cosa ne esce');
      final testo = tester.widget<Text>(riga).data!;
      expect(testo.length, greaterThan(30));
      expect(testo, isNot(contains('—')));
      // E il responso non c'e' ancora.
      expect(find.byKey(const Key('ritual_content')), findsNothing);
    });

    testWidgets('il ripiego tattile resta obbligatorio', (tester) async {
      silenzia();
      await tester.pumpWidget(
          attorno(DayOracleScreen(now: DateTime(2026, 8, 12, 13, 0))));
      await tester.pump();
      // Nessun sensore in prova: il tocco deve bastare da solo.
      await tester.tap(find.byKey(const Key('ritual_gesture')));
      await tester.pump();
      expect(find.byKey(const Key('ritual_content')), findsOneWidget,
          reason: 'senza giroscopio l\'Oracolo resta chiuso: il ripiego '
              'tattile non e\' un di piu\', e\' obbligatorio');
      expect(find.byKey(const Key('rito_cosa_ricevi')), findsNothing);
    });

    testWidgets('nessuno stato senza uscita: il ripiego porta il Riprova',
        (tester) async {
      silenzia();
      var riprovato = 0;
      await tester.pumpWidget(attorno(RitualView(
        title: 'Prova',
        palette: MaestroPalette.forKey(const ThemeKey.of(Maestro.medora)),
        gesture: RitualGesture.tilt,
        prompt: 'Inclina',
        cosaRicevi:
            'Una riga del cielo di oggi, la stessa per tutta la giornata.',
        sensorHint: 'Oppure tocca.',
        ripiego: (
          etichetta: 'Il cielo di oggi non si e\' lasciato leggere.',
          riprova: () => riprovato++,
        ),
        visualBuilder: (_, __, ___, ____) => const SizedBox.shrink(),
        revealed: const Text('non si deve vedere'),
      )));
      await tester.pump();
      await tester.tap(find.byKey(const Key('ritual_gesture')));
      await tester.pump();
      expect(find.byKey(const Key('rito_ripiego')), findsOneWidget);
      expect(find.byKey(const Key('ritual_content')), findsNothing,
          reason: 'col ripiego in scena il responso vuoto non si mostra');
      await tester.tap(find.byKey(const Key('rito_riprova')));
      await tester.pump();
      expect(riprovato, 1, reason: 'il Riprova non riprova niente');
    });
  });

  group('P.17 ogni rito dichiara cosa fa, perche\', e cosa resta', () {
    test('tutti e cinque i doni dichiarano le tre righe', () {
      // SI ENUMERA, non si elencano a mano i riti che ci si ricorda.
      for (final rito in DailyElement.values) {
        for (final riga in [
          (nome: 'cosa fai', testo: rito.cosaFai),
          (nome: 'perche', testo: rito.perche),
          (nome: 'cosa ti resta', testo: rito.cosaTiResta),
        ]) {
          expect(riga.testo.length, greaterThan(40),
              reason: '${rito.name} non dichiara "${riga.nome}"');
          expect(riga.testo, isNot(contains('—')),
              reason: 'trattino lungo in ${rito.name}, ${riga.nome}');
        }
        // Le tre righe dicono tre cose diverse, e nessuna ripete la
        // descrizione: tre etichette sopra lo stesso testo non sono tre righe.
        final tre = {rito.cosaFai, rito.perche, rito.cosaTiResta};
        expect(tre, hasLength(3), reason: '${rito.name} ripete se stesso');
        expect(tre, isNot(contains(rito.description)),
            reason: '${rito.name} riusa la descrizione della striscia');
      }
    });

    test('la terza riga nomina sempre qualcosa che RESTA', () {
      // E' la sola delle tre che produce ritorno, quindi e' l'unica su cui
      // vale la pena avere una misura invece di una buona intenzione.
      const segni = [
        'resta',
        'domani',
        'stasera',
        'fra poche ore',
        'porta',
        'nominer',
        'richiam',
        'condividere',
      ];
      final mute = <String>[];
      for (final rito in DailyElement.values) {
        final testo = rito.cosaTiResta.toLowerCase();
        if (!segni.any(testo.contains)) mute.add(rito.name);
      }
      expect(mute, isEmpty,
          reason: 'questi riti dicono cosa ti resta senza nominare niente che '
              'rimanga o che torni: ${mute.join(", ")}');
    });

    test('nessuna schermata di rito annuncia piu un rito', () {
      // **LA LEGGE SI E' ROVESCIATA. Ordine CQ voce 2.03**, 3 settembre 2026.
      //
      // L'ordine P voce 17 aveva chiesto che ogni rito dichiarasse cosa fai,
      // perche' e cosa ti resta, e la ragione era buona: i riti dicevano il
      // nome e mostravano un gesto, e chi apriva non sapeva cosa ne avrebbe
      // portato via.
      //
      // **Il fondatore ha misurato l'effetto e non l'intenzione**: l'Arcano
      // *"annuncia un rito che non esiste"*, e la prima cosa che si legge
      // aprendo un Dono e' un compito. La voce 2.00 lo ha trovato in tutti e
      // cinque, non solo li'. Cio' che resta al posto delle tre righe e' la
      // risposta, che l'ordine CO voce 17 aveva gia' scritto e messo sopra.
      //
      // **Le tre righe non sono state cancellate dal dato**: vivono ancora su
      // `DailyElement` e descrivono il Dono nel menu' degli avvisi, dove una
      // descrizione serve davvero. Cio' che esce e' la loro comparsa in cima
      // al responso.
      const schermate = [
        'lib/features/rituals/ritual_gift_card.dart', // Alba e Soffio
        'lib/features/rituals/ritual_view.dart', // Oracolo
        'lib/features/rituals/sunset_rune_screen.dart', // Tramonto
        'lib/features/rituals/dream_rite_screen.dart', // Sogno
      ];
      final conIlRito = <String>[];
      var guardate = 0;
      for (final file in schermate) {
        guardate++;
        if (File(file).readAsStringSync().contains('LeTreRigheDelRito(')) {
          conIlRito.add(file);
        }
      }
      // ignore: avoid_print
      print('ORDINE CQ VOCE 2.03: schermate di rito guardate $guardate, che '
          'annunciano ancora un rito ${conIlRito.length}');
      expect(guardate, 4,
          reason: 'l elenco delle schermate si e svuotato: questa prova '
              'sarebbe verde senza aver guardato niente');
      expect(conIlRito, isEmpty,
          reason: 'queste schermate annunciano ancora un rito con le sue tre '
              'righe di istruzioni:\n${conIlRito.join("\n")}');
    });

    test('il respiro contato non e\' piu\' un testo da leggere', () {
      // La frase "tre dentro e tre fuori, sei giri, corti come i tratti"
      // spariva come istruzione e diventava un respiro guidato: se tornasse
      // dentro il testo composto, tornerebbe il compito.
      final dono = File('lib/core/rituals/dawn_gift.dart').readAsStringSync();
      expect(dono.contains(r'${rito.respiro}'), isFalse,
          reason: 'il respiro contato e\' tornato dentro il testo del dono: '
              'una istruzione criptica scritta e\' un compito, un respiro '
              'guidato e\' un\'esperienza');
      final scheda =
          File('lib/features/rituals/ritual_gift_card.dart').readAsStringSync();
      // **LA STORIA DI QUESTA RIGA HA TRE CAPITOLI, e l'ultimo comanda.**
      // P.17 chiedeva che la scheda guidasse il respiro; S.13 lo porto' nel
      // Soffio lasciando nella scheda un ponte di una riga; e la voce 07
      // dell'ordine BB ha tolto anche il ponte, per decisione del fondatore:
      // ogni dono ha la sua ora e il suo posto, e chi arriva all'Alba non va
      // mandato altrove. Questa prova pretendeva ancora il ponte del secondo
      // capitolo, cioe' l'esatto contrario della decisione in vigore,
      // sorvegliata da `il_respiro_vive_nel_soffio_test`. Ordine BD voce 02.
      expect(scheda, isNot(contains('ponte_verso_il_soffio')),
          reason: 'il ponte verso il Soffio e\' tornato nella scheda del '
              'dono: la voce BB 07 lo ha tolto per decisione del fondatore');
      // E il respiro guidato e' UNO SOLO in tutto il progetto.
      final quanti = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .where((f) => f.readAsStringSync().contains('class GuidaDelRespiro'))
          .length;
      expect(quanti, 1,
          reason: 'esistono $quanti respiri guidati: due respiri nello stesso '
              'progetto sono un\'altra occorrenza della famiglia delle due '
              'porte');
    });
  });

  group('P.18 i doni si agganciano fra loro', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('la parola del mattino torna la sera, e solo quella di oggi',
        () async {
      final mattina = DateTime(2026, 8, 12, 7, 10);
      await FiloDelGiorno.segnaLaParola('Soglia', mattina);
      final sera = DateTime(2026, 8, 12, 22, 40);
      expect(await FiloDelGiorno.parolaDiStamattina(sera), 'Soglia');
      // Domani sera quella parola non e' piu' "stamattina".
      final domani = DateTime(2026, 8, 13, 22, 40);
      expect(await FiloDelGiorno.parolaDiStamattina(domani), isNull,
          reason: '"Stamattina la tua parola era X" con la parola di ieri e\' '
              'una bugia, e per giunta una che la persona riconosce');
    });

    test('il giorno rituale non finisce a mezzanotte', () async {
      // Chi apre il Sigillo del Sogno all'una di notte sta chiudendo il giorno
      // prima: se il filo si rompesse li', si romperebbe proprio nel momento
      // in cui deve tenere.
      final mattina = DateTime(2026, 8, 12, 7, 0);
      await FiloDelGiorno.segnaLaParola('Traccia', mattina);
      final notteFonda = DateTime(2026, 8, 13, 1, 20);
      expect(await FiloDelGiorno.parolaDiStamattina(notteFonda), 'Traccia');
      // Ma dopo l'alba del giorno rituale successivo, no.
      final mattinaDopo = DateTime(2026, 8, 13, 7, 30);
      expect(await FiloDelGiorno.parolaDiStamattina(mattinaDopo), isNull);
    });

    test('la domanda di Medora torna il mattino DOPO, non lo stesso giorno',
        () async {
      final stesa = DateTime(2026, 8, 12, 21, 0);
      await FiloDelGiorno.segnaLaDomanda(
          'Cosa sei disposto a lasciare andare?', stesa);
      // Lo stesso giorno non torna: sarebbe la stessa schermata che si ripete.
      expect(await FiloDelGiorno.domandaDiIeri(stesa), isNull);
      final domani = DateTime(2026, 8, 13, 7, 5);
      expect(await FiloDelGiorno.domandaDiIeri(domani),
          'Cosa sei disposto a lasciare andare?');
      // E dopo due giorni non e' piu' la domanda che ti era stata lasciata.
      final dopodomani = DateTime(2026, 8, 14, 7, 5);
      expect(await FiloDelGiorno.domandaDiIeri(dopodomani), isNull);
    });

    test('le due formule sono quelle dell\'ordine', () {
      // **LA FORMULA E' CRESCIUTA, e la legge no.** Ordine CQ voce 2.09, 3
      // settembre 2026: la riga diceva che parola era e finiva li', cioe'
      // portava un fatto e non una risposta. Adesso dice anche che cosa ne e'
      // stato. Quello che l'ordine P voce 18 pretende, cioe' che il richiamo
      // NOMINI la parola del mattino, resta intero, ed e' quello che si
      // misura: la frase esatta era una copia del testo, e una copia si rompe
      // ogni volta che il testo migliora.
      expect(FiloDelGiorno.richiamoDellaParola('Soglia'),
          startsWith('Stamattina la tua parola era Soglia'));
      expect(FiloDelGiorno.richiamoDellaDomanda('E adesso?'),
          startsWith('Ieri Medora ti ha lasciato questa domanda.'));
    });

    test('il filo non apre una seconda porta per la runa del tramonto', () {
      // La runa entra gia' nel Sogno dalla cerniera di `SunsetRuneMemory`. Due
      // porte per la stessa cosa e' la famiglia di difetti piu' frequente di
      // questo progetto, quindi il filo del giorno non ne apre una seconda.
      final filo =
          File('lib/core/rituals/filo_del_giorno.dart').readAsStringSync();
      expect(filo.contains('rune'), isFalse,
          reason: 'il filo del giorno ha cominciato a tenere anche la runa: '
              'quella cerniera esiste gia\' in SunsetRuneMemory');
      final sogno = File('lib/features/rituals/dream_rite_screen.dart')
          .readAsStringSync();
      expect(sogno, contains('ultimaPerCerniera'),
          reason: 'il Sogno non nomina piu\' la runa del tramonto');
      expect(sogno, contains('parolaDiStamattina'),
          reason: 'il Sogno non richiama piu\' la parola del mattino');
    });
  });
}
