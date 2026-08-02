import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/scorrimento_della_lettura.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/consulto_del_cielo.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/maestro/tempi_dell_attesa.dart';
import 'package:esoteric_circle/core/maestro/voce_del_maestro.dart';
import 'package:esoteric_circle/design_system/components/testo_che_si_scrive.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_controller.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_screen.dart';
import 'package:esoteric_circle/features/maestri/chat/widgets/chat_bubble.dart';
import 'package:esoteric_circle/features/maestri/chat/widgets/chat_composer.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// COME ARRIVA UNA RISPOSTA: la pausa, la scrittura, e dove si ferma la chat.
///
/// **I numeri di questo file sono misurati, non stimati.** Dieci chiamate reali
/// in fila sulla strada viva il 3 agosto 2026 hanno dato rete minima 1,21s,
/// mediana 1,51s, massima 1,83s. Da li' nascono la durata minima della scena e
/// i due tetti, e le prove qui sotto rifanno il conto sul dato invece di
/// ripetere il numero a mano.
void main() {
  const natalPieno = NatalContext(
    sunSign: 'Cancro',
    moonSign: 'Pesci',
    ascendant: 'Vergine',
  );

  group('VOCE 1a. Le frasi della pausa sono del Maestro, non dell\'app', () {
    test('Almeno sei per ciascuno, ed enumerate su Maestro.values', () {
      for (final maestro in Maestro.values) {
        final frasi = VoceDelMaestro.di(maestro).frasiDelConsulto;
        expect(
          frasi.length,
          greaterThanOrEqualTo(VoceDelMaestro.minimeFrasiDelConsulto),
          reason: '${maestro.displayName} ne ha ${frasi.length}: sotto sei la '
              'rotazione si vede, e alla terza domanda si rilegge la prima',
        );
        expect(frasi.toSet().length, frasi.length,
            reason: '${maestro.displayName} ripete una frase dentro il suo '
                'stesso elenco');
      }
    });

    test('Nessun elenco coincide con quello di un altro', () {
      // Enumerata su tutte le coppie, non su una a campione: se due Maestri
      // aspettassero con le stesse parole sarebbero un Maestro solo con due
      // ritratti, ed e' esattamente il difetto che la chiusura generica ha gia'
      // fatto pagare una volta.
      for (final uno in Maestro.values) {
        for (final altro in Maestro.values) {
          if (uno == altro) continue;
          final sue = VoceDelMaestro.di(uno).frasiDelConsulto.toSet();
          final altrui = VoceDelMaestro.di(altro).frasiDelConsulto.toSet();
          expect(sue.intersection(altrui), isEmpty,
              reason: '${uno.displayName} e ${altro.displayName} aspettano '
                  'dicendo la stessa cosa');
        }
      }
    });

    test('Ogni frase porta una parola di FIRMA di chi la dice', () {
      // E' la riga che tiene la pausa dentro la voce giusta. Le parole di firma
      // sono le stesse che reggono il 98,3 per cento di attribuzione cieca:
      // senza questo controllo una frase potrebbe migrare da un Maestro
      // all'altro senza che nessuno se ne accorga.
      for (final maestro in Maestro.values) {
        final voce = VoceDelMaestro.di(maestro);
        for (final frase in voce.frasiDelConsulto) {
          final minuscola = frase.toLowerCase();
          expect(
            voce.lessicoDiFirma.any(minuscola.contains),
            isTrue,
            reason: '${maestro.displayName}, «$frase»: nessuna delle sue parole '
                'di firma (${voce.lessicoDiFirma.join(', ')}) compare, quindi '
                'questa frase potrebbe essere di chiunque',
          );
        }
      }
    });
  });

  group('VOCE 1b. Almeno una riga nomina un dato VERO di questa persona', () {
    test('Con una carta piena, la PRIMA riga e\' un dato suo', () {
      for (final maestro in Maestro.values) {
        final battute =
            ConsultoDelCielo.battutePer(natalPieno, maestro: maestro);
        expect(battute.first.ancoraggio, isNotNull,
            reason: '${maestro.displayName} apre l\'attesa senza guardare '
                'niente di suo');
        expect(battute.first.frase, contains('Vergine'),
            reason: 'il valore vero deve restare LETTERALE nella riga: '
                'e\' quello che distingue "sto guardando la tua Luna in '
                'Cancro" da "sto consultando gli astri"');
        expect(battute.any((b) => b.ancoraggio != null), isTrue);
      }
    });

    test('Senza nessun dato, la riga si SALTA e non si inventa', () {
      // Due righe vere valgono piu' di tre di cui una inventata.
      for (final maestro in Maestro.values) {
        final battute = ConsultoDelCielo.battutePer(
          NatalContext.none,
          maestro: maestro,
        );
        expect(battute.every((b) => b.ancoraggio == null), isTrue,
            reason: 'senza dati non si nomina nessun corpo');
        expect(battute.every((b) => b.eGenerale), isTrue,
            reason: 'una riga che non e\' sua va DICHIARATA tale, non '
                'lasciata credere personale');
        // E le frasi restano sue, non spariscono.
        expect(battute, isNotEmpty);
      }
    });

    test('La rotazione cambia riga fra due attese vicine', () {
      for (final maestro in Maestro.values) {
        final prima = ConsultoDelCielo.battutePer(natalPieno,
                maestro: maestro, rotazione: 0)
            .last
            .frase;
        final dopo = ConsultoDelCielo.battutePer(natalPieno,
                maestro: maestro, rotazione: 1)
            .last
            .frase;
        expect(prima, isNot(dopo),
            reason: '${maestro.displayName} ripete la stessa riga a due '
                'domande di fila');
      }
    });
  });

  group('VOCE 1c. I tempi, e sono un vincolo misurato', () {
    test('Alla prima parola si arriva sotto i quattro secondi', () {
      // Il conto e' un MASSIMO e non una somma: la scena e la rete corrono
      // insieme, non una dopo l'altra.
      final conLaReteMisurata =
          TempiDellAttesa.allaPrimaParola(TempiDellAttesa.reteMassimaMisurataMs);
      expect(conLaReteMisurata,
          lessThan(TempiDellAttesa.tettoAllaPrimaParola),
          reason: 'con la rete peggiore misurata si sfora gia\' da PC');
      // E resta margine per un telefono su rete mobile, che sta piu' in alto
      // del PC su rete fissa da cui viene la misura.
      final margine = TempiDellAttesa.tettoAllaPrimaParola - conLaReteMisurata;
      expect(margine, greaterThan(const Duration(seconds: 1)),
          reason: 'meno di un secondo di margine vuol dire che il primo '
              'telefono lento sfora');
    });

    test('La durata minima sta SOPRA la rete mediana misurata', () {
      // Altrimenti non servirebbe a niente: sarebbe sempre la rete a comandare,
      // e con la rete al minimo la scena tornerebbe a lampeggiare.
      expect(TempiDellAttesa.durataMinima.inMilliseconds, greaterThan(1510),
          reason: 'la mediana misurata e\' 1,51s');
    });

    test('Riduci Movimento accorcia davvero', () {
      expect(
        TempiDellAttesa.allaPrimaParola(0, riduciMovimento: true),
        lessThan(TempiDellAttesa.allaPrimaParola(0)),
      );
    });

    test('Il testo completo sta sotto i dieci secondi, anche il piu\' lungo',
        () {
      // La risposta piu' lunga misurata il 3 agosto e' di 116 parole. In
      // italiano una parola con lo spazio vale circa sei caratteri e mezzo:
      // 116 per 6,5 fa 754, e si arrotonda per eccesso a 800 per stare larghi.
      const caratteriDellaPiuLunga = 800;
      final scrittura = TempiDellAttesa.durataDiScrittura(
        caratteriDellaPiuLunga,
        TempiDellAttesa.perScrivere(TempiDellAttesa.reteMassimaMisurataMs),
      );
      final totale =
          TempiDellAttesa.allaPrimaParola(TempiDellAttesa.reteMassimaMisurataMs) +
              scrittura;
      expect(totale, lessThanOrEqualTo(TempiDellAttesa.tettoAlTestoCompleto),
          reason: 'la risposta piu\' lunga sfora il tetto: a sessanta '
              'caratteri al secondo ci metterebbe tredici secondi da sola, ed '
              'e\' il caso per cui il tetto sulla scrittura esiste');
    });

    test('Una risposta corta NON viene rallentata per riempire il tetto', () {
      // Il tetto e' un tetto, non un bersaglio: chi ci sta sotto va alla sua
      // velocita'. Trecento caratteri a sessanta al secondo sono cinque secondi.
      final corta = TempiDellAttesa.durataDiScrittura(
          300, const Duration(seconds: 30));
      expect(corta.inMilliseconds, 5000);
    });
  });

  group('VOCE 1c. La pausa la governa il turno', () {
    Future<MaestroChatController> conVoce(MaestroAiProvider voce) async {
      final memoria = InMemoryMaestroMemoryRepository();
      await memoria
          .saveProfile(UserProfile(disclaimerAcceptedAt: DateTime(2026, 7, 1)));
      final controller = MaestroChatController(
        maestro: Maestro.medora,
        ai: voce,
        memory: memoria,
        natal: () => natalPieno,
      );
      await controller.init();
      return controller;
    }

    test('Una risposta istantanea aspetta comunque la durata minima', () async {
      final controller = await conVoce(_VoceIstantanea('La tua Luna in Pesci '
          'chiude un ciclo, e il ciclo torna fra sette giorni.'));
      final cronometro = Stopwatch()..start();
      await controller.send('mi sento fermo');
      cronometro.stop();

      expect(controller.messages.last.text, contains('Pesci'));
      expect(
        cronometro.elapsedMilliseconds,
        greaterThanOrEqualTo(TempiDellAttesa.durataMinima.inMilliseconds - 60),
        reason: 'senza questa attesa la scena compare e sparisce, e un lampo '
            'da\' meno credibilita\' di nessuna pausa',
      );
      expect(controller.ultimaAttesaMs, greaterThan(0));
    });

    test('Anche un RIPIEGO aspetta: la scena non sparisce di colpo', () async {
      final controller = await conVoce(_VoceMuta());
      final cronometro = Stopwatch()..start();
      await controller.send('mi sento fermo');
      cronometro.stop();

      expect(controller.messages.last.ripiego, isTrue);
      expect(
        cronometro.elapsedMilliseconds,
        greaterThanOrEqualTo(TempiDellAttesa.durataMinima.inMilliseconds - 60),
        reason: 'una risposta che fallisce deve chiudere la scena al suo '
            'tempo, non farla sparire a scatto',
      );
    });

    test('Con Riduci Movimento la stessa risposta aspetta di meno', () async {
      final controller = await conVoce(_VoceIstantanea('Il tuo Ascendente in '
          'Vergine ordina cio\' che il transito ha mosso.'));
      controller.riduciMovimento = true;
      final cronometro = Stopwatch()..start();
      await controller.send('mi sento fermo');
      cronometro.stop();

      expect(
        cronometro.elapsedMilliseconds,
        lessThan(TempiDellAttesa.durataMinima.inMilliseconds),
        reason: 'chi non vuole movimento non ha chiesto di aspettare di piu\'',
      );
    });
  });

  group('VOCE 2a. Il testo si scrive, e si puo\' sempre saltare', () {
    Widget monta(String testo,
            {bool attiva = true,
            Duration tetto = const Duration(seconds: 30),
            GlobalKey<TestoCheSiScriveState>? chiave}) =>
        MaterialApp(
          home: Scaffold(
            body: TestoCheSiScrive(
              key: chiave,
              testo: testo,
              attiva: attiva,
              durataMassima: tetto,
              stile: const TextStyle(fontSize: 14),
            ),
          ),
        );

    testWidgets('Scrive a circa sessanta caratteri al secondo', (tester) async {
      // Centoventi caratteri a sessanta al secondo sono due secondi: a meta'
      // strada se ne devono leggere circa sessanta.
      final testo = 'a' * 120;
      await tester.pumpWidget(monta(testo));
      await tester.pump(const Duration(seconds: 1));

      final scritti = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data ?? '')
          .where((d) => d.isNotEmpty)
          .map((d) => d.length)
          .toList()
        ..sort();
      // Due Text mentre scrive: quello trasparente che tiene il posto, lungo
      // quanto tutto il testo, e quello scritto finora.
      expect(scritti.first, closeTo(60, 12),
          reason: 'a meta\' del tempo deve esserci meta\' del testo');
      await tester.pumpAndSettle();
    });

    testWidgets('Un tocco completa subito', (tester) async {
      final chiave = GlobalKey<TestoCheSiScriveState>();
      final testo = 'b' * 600;
      await tester.pumpWidget(monta(testo, chiave: chiave));
      await tester.pump(const Duration(milliseconds: 200));
      expect(chiave.currentState!.staScrivendo, isTrue);

      chiave.currentState!.completa();
      await tester.pump();
      expect(chiave.currentState!.staScrivendo, isFalse);
      expect(find.text(testo), findsOneWidget,
          reason: 'completato, il testo torna a essere UN widget solo');
    });

    testWidgets('Ferma, il testo e\' gia\' intero al primo fotogramma',
        (tester) async {
      final testo = 'c' * 600;
      await tester.pumpWidget(monta(testo, attiva: false));
      await tester.pump();
      expect(find.text(testo), findsOneWidget);
    });

    testWidgets('Il tetto accorcia la scrittura di un testo lungo',
        (tester) async {
      final chiave = GlobalKey<TestoCheSiScriveState>();
      // Milleduecento caratteri vorrebbero venti secondi a sessanta al
      // secondo. Col tetto a due, in due deve avere finito.
      await tester.pumpWidget(monta('d' * 1200,
          chiave: chiave, tetto: const Duration(seconds: 2)));
      await tester.pump(const Duration(milliseconds: 2100));
      expect(chiave.currentState!.staScrivendo, isFalse);
    });
  });

  group('VOCE 2b. Lo scorrimento si ferma all\'INIZIO della risposta', () {
    test('Il bersaglio scopre cio\' che sta SOPRA, non sotto', () {
      // La lista della chat e' rovesciata, quindi l'offset cresce verso i
      // messaggi vecchi: e' il segno che si sbaglia a mente.
      // La risposta sta a 500, la lista comincia a 100: va spinta in giu' fino
      // a 100 piu' lo spazio della domanda, cioe' di meno di quanto sta ora.
      expect(
        ScorrimentoDellaLettura.bersaglio(
          offsetAttuale: 1000,
          cimaDellaRisposta: 500,
          cimaDellaLista: 100,
          massimo: 10000,
        ),
        1000 + (100 + ScorrimentoDellaLettura.spazioPerLaDomanda - 500),
      );
      // E quando la risposta sta gia' sopra il punto voluto, l'offset CRESCE,
      // che e' il segno rovesciato: crescere scopre cio' che sta sopra.
      expect(
        ScorrimentoDellaLettura.bersaglio(
          offsetAttuale: 1000,
          cimaDellaRisposta: 100,
          cimaDellaLista: 100,
          massimo: 10000,
        ),
        greaterThan(1000),
      );
    });

    test('Non si scavalca mai il fondo della lista', () {
      expect(
        ScorrimentoDellaLettura.bersaglio(
            offsetAttuale: 990,
            cimaDellaRisposta: 0,
            cimaDellaLista: 100,
            massimo: 1000),
        1000,
      );
      expect(
        ScorrimentoDellaLettura.bersaglio(
            offsetAttuale: 0,
            cimaDellaRisposta: 5000,
            cimaDellaLista: 100,
            massimo: 1000),
        0,
      );
    });

    // LA PROVA PER COORDINATE, alla larghezza reale del telefono del fondatore.
    //
    // Le due prove qui sopra verificano l'aritmetica, che e' dove sta il segno
    // sbagliato facile. Questa verifica la COSA: che a 360 per 797 la prima
    // riga della risposta stia davvero dentro lo schermo. Senza, si potrebbe
    // avere un conto giusto su una lista che si comporta in un altro modo.
    testWidgets('A 360 per 797, la prima riga della risposta e\' a video',
        (tester) async {
      tester.view.devicePixelRatio = 3.0;
      tester.view.physicalSize = const Size(1080, 2392);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // UNA RISPOSTA PIU' ALTA DELLO SCHERMO, che e' l'unico caso in cui la
      // regola conta.
      //
      // La prima stesura di questa prova usava una risposta da ottantacinque
      // parole, e passava: misurata, quella bolla era alta 491 punti su 797,
      // cioe' **ci stava tutta**, quindi non attraversava affatto il ramo che
      // doveva provare. Sarebbe rimasta verde anche togliendo tutta la regola
      // dello scorrimento. Qui la risposta e' lunga come un approfondimento, e
      // sotto c'e' la riga che impedisce alla prova di tornare banale il giorno
      // in cui qualcuno la accorcia.
      const risposta = 'Un velo sottile di Luna nuova sembra avvolgerti, '
          'Sofia. La tua Luna in Pesci si lega alla tua natura di Cancro, '
          'portandoti a sentire ogni cosa due volte. Il timore di sbagliare '
          'è una risonanza del tuo numero, che ti spinge alla comprensione '
          'profonda. Questo transito ti invita a osservare le tue paure, non '
          'a reprimerle, riconoscendole come parte del tuo cammino.\n\n'
          'Il tuo Ascendente in Vergine chiede ordine a ciò che la Luna muove '
          'senza chiedere permesso, e da questa tensione nasce la tua cura '
          'per il dettaglio. Non è un difetto da correggere: è il modo in cui '
          'il tuo cielo ti fa guardare le cose. Chi teme di sbagliare ha di '
          'solito capito quanto pesa una scelta, e questo peso lo senti '
          'perché il tuo Sole in Cancro non prende niente alla leggera.\n\n'
          'Guarda dove il timore torna sempre: quella è la porta. Il ciclo '
          'lunare si chiuderà fra sette giorni, portando con sé una '
          'prospettiva nuova su ciò che oggi ti sembra fermo, e allora la '
          'stessa domanda avrà una risposta diversa.';
      const domanda = 'ho paura di sbagliare';

      final memoria = InMemoryMaestroMemoryRepository();
      await memoria
          .saveProfile(UserProfile(disclaimerAcceptedAt: DateTime(2026, 7, 1)));

      // UNA CRONOLOGIA SOPRA, e non e' un dettaglio della scenografia.
      //
      // Senza, la conversazione e' di due messaggi soli: la lista finisce
      // subito, lo scorrimento va a sbattere contro il proprio massimo, e la
      // domanda resta visibile perche' sopra non c'e' altro, non perche' la
      // regola le abbia lasciato posto. Misurato: `offset` e `maxScrollExtent`
      // coincidevano a 450,67, e infatti azzerare `spazioPerLaDomanda` NON
      // faceva cadere la prova. Con dei turni sopra il massimo non e' piu' il
      // vincolo, e la prova misura la regola invece del bordo della lista.
      for (var i = 0; i < 6; i++) {
        await memoria.appendMessage(
          Maestro.medora,
          ChatMessage(
            role: i.isEven ? ChatRole.user : ChatRole.maestro,
            text: i.isEven
                ? 'una domanda di ieri, la numero $i'
                : 'Il cielo di ieri diceva questo, e il transito si è chiuso '
                    'lasciando aperta una sola strada, la numero $i.',
            at: DateTime(2026, 8, 1, 10, i),
          ),
        );
      }

      final servizi = AppServices(
        ai: _VoceIstantanea(risposta),
        memory: memoria,
        memoryPersistent: false,
        diagnostics: 'prova a coordinate',
      );

      await tester.pumpWidget(MultiProvider(
        providers: [
          Provider<AppServices>.value(value: servizi),
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QuestionAllowance()),
          ChangeNotifierProvider(create: (_) => EntitlementService()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => ProfileController()),
          ChangeNotifierProvider(create: (_) => BirthIdentityController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Navigator(
            // La domanda si scrive nel campo invece di arrivare come
            // iniziale: con una cronologia gia' in memoria l'iniziale non
            // parte, ed e' giusto cosi', non si sovrascrive uno storico.
            onGenerateRoute: (_) => MaestroChatScreen.route(
              maestro: Maestro.medora,
              services: servizi,
            ),
          ),
        ),
      ));
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 400));
      }
      final campo = find.descendant(
        of: find.byType(ChatComposer),
        matching: find.byType(TextField),
      );
      expect(campo, findsOneWidget);
      await tester.enterText(campo, domanda);
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.send);
      // A PASSI FINI, e non e' un dettaglio.
      //
      // Con passi da 400 millisecondi questa prova NON prendeva il difetto di
      // misurare la geometria mentre la scena del consulto sta ancora
      // dissolvendosi: al primo passo utile la dissolvenza, che dura 260, era
      // gia' finita da sola, quindi il caso non attraversava il ramo. A 50 il
      // momento sbagliato esiste davvero.
      for (var i = 0; i < 340; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      final schermo = tester.view.physicalSize.height / tester.view.devicePixelRatio;
      final bolla = find.ancestor(
        of: find.text(risposta),
        matching: find.byType(ChatBubble),
      );
      expect(bolla, findsOneWidget,
          reason: 'senza la bolla a video non si misura niente');
      final cima = tester.getTopLeft(bolla).dy;

      // IL GUARDIANO: la prova deve attraversare il ramo che prova.
      //
      // Se la bolla ci sta dentro la lista, lo scorrimento non ha niente da
      // correggere e questa prova resterebbe verde anche senza la regola.
      final altezzaDellaLista =
          tester.getSize(find.byType(ListView).first).height;
      expect(
        tester.getSize(bolla).height,
        greaterThan(altezzaDellaLista),
        reason: 'la risposta di prova ci sta tutta a schermo, quindi questa '
            'prova non sta misurando niente: serve una risposta piu\' alta '
            'della lista, che e\' il solo caso in cui la regola conta',
      );
      final fondoDellaDomanda = tester.getBottomLeft(find.ancestor(
        of: find.text(domanda),
        matching: find.byType(ChatBubble),
      )).dy;

      // 1. LA RISPOSTA COMINCIA DOVE DICE IL DATO, non solo "da qualche parte
      //    dentro lo schermo".
      //
      //    La prima stesura chiedeva soltanto che la prima riga fosse a video,
      //    e non prendeva due difetti veri: misurare la geometria mentre la
      //    scena del consulto occupa ancora spazio, e misurare la finestra di
      //    scorrimento invece del riquadro della lista. Tutti e due lasciavano
      //    la risposta a 417 punti dall'alto invece che a 96, cioe' mezzo
      //    schermo alla conversazione vecchia: dentro lo schermo si', ma non
      //    all'inizio. Una prova che dice solo "e' visibile" lascia passare
      //    tutto cio' che e' visibile male.
      final cimaDellaLista =
          tester.getTopLeft(find.byType(ListView).first).dy;
      expect(
        cima - cimaDellaLista,
        closeTo(ScorrimentoDellaLettura.spazioPerLaDomanda, 2),
        reason: 'la risposta non comincia dove dice '
            'ScorrimentoDellaLettura.spazioPerLaDomanda',
      );

      // 2. LA PRIMA RIGA E' DENTRO LO SCHERMO. E' la regola dell'ordine E.
      expect(cima, greaterThanOrEqualTo(0.0),
          reason: 'l\'inizio della risposta sta sopra la piega: la persona '
              'arriva a meta\' di una lettura senza averne letto l\'inizio, '
              'ed e\' esattamente il difetto trovato il 2 agosto');
      expect(cima, lessThan(schermo),
          reason: 'l\'inizio della risposta sta sotto lo schermo');

      // 3. E SOPRA RESTA VISIBILE LA DOMANDA CHE L'HA GENERATA.
      expect(fondoDellaDomanda, greaterThan(0.0),
          reason: 'la domanda e\' fuori schermo: una lettura senza la domanda '
              'sopra e\' una risposta senza sapere a cosa');
      expect(fondoDellaDomanda, lessThanOrEqualTo(cima + 1),
          reason: 'la domanda deve stare SOPRA la risposta');
    });
  });
}

/// Una voce che risponde all'istante: serve a provare che la pausa NON viene
/// dalla rete ma dal turno.
class _VoceIstantanea implements MaestroAiProvider {
  _VoceIstantanea(this.testo);
  final String testo;

  @override
  bool get isReady => true;

  @override
  Future<String> reply({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory memory,
    required List<ChatMessage> history,
    required String userMessage,
    NatalContext natal = NatalContext.none,
    bool insistiSullAncoraggio = false,
    bool approfondisci = false,
  }) async =>
      testo;

  @override
  Future<MaestroReply> consult({
    required Maestro maestro,
    required String theme,
    required UserProfile profile,
    MaestroMemory memory = MaestroMemory.empty,
    NatalContext? natal,
    ConsultDepth depth = ConsultDepth.breve,
  }) async =>
      throw const MaestroAiUnavailable();

  @override
  Future<String> synthesize({
    required String theme,
    required List<MaestroLens> lenses,
    NatalContext? natal,
  }) async =>
      throw const MaestroAiUnavailable();

  @override
  Future<MemoryDigest?> distill({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory previous,
    required List<ChatMessage> history,
  }) async =>
      null;
}

/// Una voce che tace all'istante, per il ramo del ripiego.
class _VoceMuta extends _VoceIstantanea {
  _VoceMuta() : super('');

  @override
  Future<String> reply({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory memory,
    required List<ChatMessage> history,
    required String userMessage,
    NatalContext natal = NatalContext.none,
    bool insistiSullAncoraggio = false,
    bool approfondisci = false,
  }) async =>
      throw const MaestroAiUnavailable('la voce tace');
}
