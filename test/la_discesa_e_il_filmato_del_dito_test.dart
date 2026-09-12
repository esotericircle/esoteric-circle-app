import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/sensi/catalogo_suoni.dart';
import 'package:esoteric_circle/core/sensi/palette_sensoriale.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/il_tunnel_che_scende.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/la_discesa_in_video.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/viaggio_dello_sciamano_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';
import 'la_soglia_si_guarda_prima_di_leggerla_test.dart'
    show DiarioDelloSciamanoDiProva;

/// **LA DISCESA E' IL FILMATO, E LO GOVERNA IL DITO.** Ordine DI voce 09,
/// 12 settembre 2026.
///
/// **Il fondatore, sul tunnel disegnato:** *"una persona normale, vedendo solo
/// quella specie di animazione, capisce che sta entrando in un tunnel o fosso
/// o quello che dovrebbe essere?"*. L'ordine risponde col filmato girato
/// apposta e detta come deve rispondere al dito, voce per voce. Questa guardia
/// pretende ognuna di quelle voci **sulla strada vera**, cioe' dentro la
/// schermata del Viaggio che si tocca, e non su un widget montato da solo:
/// e' la lezione della schermata finita che nessuno monta.
///
/// **IL LETTORE E' UNA FINTA, e deve esserlo.** In una prova headless nessuna
/// piattaforma decodifica un filmato: col lettore vero questa guardia
/// misurerebbe soltanto il tunnel di riserva. La finta sta dietro la stessa
/// porta del lettore vero, `LettoreDellaDiscesa`, e **registra ogni comando
/// che riceve**: e' cosi' che la rampa, la pausa e l'assenza di salti si
/// possono contare.
///
/// **Il lettore vero resta sorvegliato altrove**, e per la parte che conta: la
/// sua strada di riserva la percorre ogni prova che scende nel Viaggio, e il
/// suo sorgente lo legge l'ultima prova di questo file.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(() {
    PaletteSensoriale.spiaDelTamburo = null;
    PaletteSensoriale.tamburoPresenteNelleProve = null;
  });

  group('la rampa del dito, gradino per gradino', () {
    test('sale da un decimo a uno, e scende a zero in dieci gradini', () {
      final r = RampaDelDito();
      // **IL TOCCO E' IL PRIMO GRADINO**: il lettore non accetta lo zero, e un
      // filmato che aspetta cinquanta millisecondi prima di muoversi e' un
      // dito che non risponde.
      expect(r.premi(), isTrue, reason: 'da fermi il tocco deve far partire');
      expect(r.velocita, closeTo(0.1, 1e-9));
      final salita = <double>[r.velocita];
      for (var i = 0; i < 9; i++) {
        expect(r.passo(), PassoDellaRampa.velocita);
        salita.add(r.velocita);
      }
      expect(r.velocita, closeTo(1.0, 1e-9),
          reason: 'dopo nove gradini da cinquanta millisecondi, cioe in '
              'quattrocentocinquanta, la velocita deve essere piena');
      expect(r.passo(), PassoDellaRampa.niente,
          reason: 'arrivata a uno la rampa si ferma');

      r.alza();
      final discesa = <double>[];
      PassoDellaRampa? ultimo;
      var gradini = 0;
      while (ultimo != PassoDellaRampa.ferma && gradini < 50) {
        ultimo = r.passo();
        discesa.add(r.velocita);
        gradini++;
      }
      expect(gradini, DiscesaInVideo.gradini,
          reason: 'DAL DITO ALZATO ALLA PAUSA CI SONO $gradini GRADINI, e '
              'l ordine vuole mezzo secondo, cioe dieci da cinquanta '
              'millisecondi: "nessun blocco secco"');
      expect(r.velocita, 0);
      // **NESSUN SALTO**: ogni gradino cambia la velocita di un decimo
      // esatto, in salita e in discesa.
      final tutti = [...salita, ...discesa];
      for (var i = 1; i < tutti.length; i++) {
        expect((tutti[i] - tutti[i - 1]).abs(), closeTo(0.1, 1e-9),
            reason: 'fra il gradino $i e il precedente la velocita salta da '
                '${tutti[i - 1]} a ${tutti[i]}: e un blocco secco');
      }
      // ignore: avoid_print
      print('ORDINE DI VOCE 09: la rampa sale ${salita.join(" ")} e scende '
          '${discesa.join(" ")}');
    });

    test('il dito che torna a meta rampa riprende da dove si era', () {
      final r = RampaDelDito()..premi();
      for (var i = 0; i < 9; i++) {
        r.passo();
      }
      r.alza();
      r.passo();
      r.passo();
      r.passo();
      expect(r.velocita, closeTo(0.7, 1e-9));
      expect(r.premi(), isFalse,
          reason: 'il filmato sta ancora andando: ripartire da capo sarebbe '
              'un salto all indietro della velocita');
      expect(r.passo(), PassoDellaRampa.velocita);
      expect(r.velocita, closeTo(0.8, 1e-9));
    });
  });

  group('la discesa nella schermata vera', () {
    const schermo = Size(390, 844);

    Future<FintaDellaDiscesa> scendi(
      WidgetTester tester, {
      int discese = 0,
      bool riesce = true,
      Color fotogramma = const Color(0xFF000000),
      SettingsController? impostazioni,
    }) async {
      tester.view.physicalSize = schermo;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final finta = FintaDellaDiscesa(riesce: riesce, colore: fotogramma);
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => MaestroController()),
            ChangeNotifierProvider(create: (_) => QualityTierController()),
            if (impostazioni != null)
              ChangeNotifierProvider<SettingsController>.value(
                  value: impostazioni),
          ],
          child: RepaintBoundary(
            key: const Key('foglio'),
            child: MaterialApp(
              home: MaestroScope(
                child: ViaggioDelloSciamanoScreen(
                  key: ValueKey('$discese $riesce'),
                  userSign: Zodiac.gemini,
                  now: DateTime(2026, 9, 12, 12),
                  diario: DiarioDelloSciamanoDiProva(discese),
                  fabbricaDellaDiscesa: () => finta,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Solo incontro'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.ensureVisible(find.byKey(const Key('viaggio_scendi')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('viaggio_scendi')));
      await tester.pump();
      expect(find.byKey(const Key('viaggio_dito')), findsOneWidget,
          reason: 'NON SI E ENTRATI NELLA DISCESA');
      return finta;
    }

    /// La luminosita' di ogni pixel della finestra, fotografata davvero.
    Future<Uint8List> fotografa(WidgetTester tester) async {
      late Uint8List grigi;
      await tester.runAsync(() async {
        await precacheImage(const AssetImage(DiscesaInVideo.primoFotogramma),
            tester.element(find.byType(LaDiscesa)));
      });
      await tester.pump();
      await tester.runAsync(() async {
        final foglio = tester
            .renderObject<RenderRepaintBoundary>(find.byKey(const Key('foglio')));
        final img = await foglio.toImage();
        final dati = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
        final b = dati!.buffer.asUint8List();
        grigi = Uint8List(b.length ~/ 4);
        for (var i = 0; i < grigi.length; i++) {
          grigi[i] =
              (0.299 * b[i * 4] + 0.587 * b[i * 4 + 1] + 0.114 * b[i * 4 + 2])
                  .round();
        }
      });
      return grigi;
    }

    testWidgets(
        'PRIMA DEL PRIMO TOCCO SI VEDE IL PRIMO FOTOGRAMMA, MAI UNO SCHERMO '
        'NERO', (tester) async {
      // **La finta disegna NERO**, come una texture appena nata che non ha
      // ancora ricevuto il primo fotogramma: e' esattamente lo schermo nero
      // che l'ordine vieta, e se la discesa la mostrasse prima del tempo
      // questa prova lo vedrebbe.
      await scendi(tester);
      expect(find.byKey(const Key('viaggio_discesa_filmato')), findsNothing,
          reason: 'il filmato e a schermo prima di aver mostrato un '
              'fotogramma: una texture appena nata puo essere nera');
      final grigi = await fotografa(tester);
      cardinaleMinimo(grigi.length, 300000,
          cosa: 'pixel della finestra fotografata',
          perche: 'Su una fotografia vuota la quota di nero sarebbe zero e la '
              'prova verde senza aver guardato niente.');
      var neri = 0;
      var somma = 0.0;
      for (final g in grigi) {
        if (g < 8) neri++;
        somma += g;
      }
      final media = somma / grigi.length;
      // **LA GRANA SI MISURA DENTRO LA SCENA, lontano dalle scritte.** Al
      // primo giro questa prova misurava la varianza sulla finestra intera, e
      // col primo fotogramma tolto restava verde: la barra in cima e la
      // scritta in fondo bastavano a fare varianza da sole. Si guarda la
      // fascia dal quindici al settanta per cento dell'altezza della
      // discesa, dove ci sono solo il bosco e le radici.
      final scena = tester.getRect(find.byType(LaDiscesa));
      final larghezza = schermo.width.toInt();
      final daRiga = (scena.top + scena.height * 0.15).round();
      final aRiga = (scena.top + scena.height * 0.70).round();
      var nellaFascia = 0;
      var sommaFascia = 0.0;
      for (var y = daRiga; y < aRiga; y++) {
        for (var x = 0; x < larghezza; x++) {
          sommaFascia += grigi[y * larghezza + x];
          nellaFascia++;
        }
      }
      final mediaFascia = sommaFascia / nellaFascia;
      var scarti = 0.0;
      for (var y = daRiga; y < aRiga; y++) {
        for (var x = 0; x < larghezza; x++) {
          final g = grigi[y * larghezza + x] - mediaFascia;
          scarti += g * g;
        }
      }
      final grana = scarti / nellaFascia;
      final quotaNera = neri / grigi.length;
      // ignore: avoid_print
      print('ORDINE DI VOCE 09: prima del tocco il nero e il '
          '${(quotaNera * 100).toStringAsFixed(1)} per cento della finestra, '
          'la luminosita media ${media.toStringAsFixed(1)}, la varianza '
          '${grana.toStringAsFixed(0)}');
      expect(quotaNera, lessThan(0.20),
          reason: 'PRIMA DEL PRIMO TOCCO IL '
              '${(quotaNera * 100).toStringAsFixed(0)} PER CENTO DELLO '
              'SCHERMO E NERO: l ordine dice "mai uno schermo nero"');
      // **E NON BASTA IL COLORE DEL FONDO**: sotto l'immagine c'e' un colore
      // pieno apposta, e un colore pieno ha varianza zero. Il bosco e le
      // radici no.
      expect(grana, greaterThan(100),
          reason: 'la finestra e un colore piatto (varianza '
              '${grana.toStringAsFixed(0)}): il primo fotogramma non e '
              'dipinto, si vede solo il fondo');
    });

    testWidgets(
        'IL DITO GOVERNA IL FILMATO: parte al tocco, rallenta in mezzo secondo '
        'e si ferma, mai un salto', (tester) async {
      final finta = await scendi(tester);
      expect(finta.comandi, isEmpty,
          reason: 'il filmato e partito prima del tocco: l ordine vuole il '
              'primo fotogramma fermo finche la persona non preme');
      final gesto =
          await tester.startGesture(tester.getCenter(find.byType(LaDiscesa)));
      await tester.pump();
      expect(finta.comandi, ['velocita 0.1', 'avvia'],
          reason: 'al tocco il filmato deve partire subito, a un decimo');
      for (var i = 0; i < 9; i++) {
        await tester.pump(DiscesaInVideo.passoDellaRampa);
      }
      expect(finta.comandi.last, 'velocita 1.0',
          reason: 'in mezzo secondo la velocita deve essere piena');
      final primaDiFermarsi = finta.comandi.length;
      await tester.pump(const Duration(milliseconds: 400));
      expect(finta.comandi.length, primaDiFermarsi,
          reason: 'a velocita piena la rampa continua a mandare comandi');

      // **IL FILMATO VA OLTRE IL PRIMO FOTOGRAMMA**: da qui si mostra.
      finta.mostraIlSecondoFotogramma();
      await tester.pump();
      expect(find.byKey(const Key('viaggio_discesa_filmato')), findsOneWidget,
          reason: 'il filmato e andato avanti e non e a schermo');

      await gesto.up();
      await tester.pump();
      final daQui = finta.comandi.length;
      for (var i = 0; i < DiscesaInVideo.gradini - 1; i++) {
        await tester.pump(DiscesaInVideo.passoDellaRampa);
        expect(finta.comandi, isNot(contains('sospendi')),
            reason: 'IL FILMATO SI FERMA DOPO ${(i + 1) * 50} MILLISECONDI, '
                'prima del mezzo secondo: e il blocco secco che l ordine '
                'vieta');
      }
      await tester.pump(DiscesaInVideo.passoDellaRampa);
      final rallentando = finta.comandi.sublist(daQui);
      // ignore: avoid_print
      print('ORDINE DI VOCE 09: dal dito alzato il filmato riceve '
          '${rallentando.join(", ")}');
      expect(rallentando.last, 'sospendi',
          reason: 'dopo mezzo secondo il filmato deve mettersi in pausa');
      expect(rallentando.length, DiscesaInVideo.gradini,
          reason: 'fra il dito alzato e la pausa ci sono '
              '${rallentando.length} comandi invece di dieci gradini');

      // **E RIPARTE DA DOV'E'**, senza tornare indietro.
      final ancora =
          await tester.startGesture(tester.getCenter(find.byType(LaDiscesa)));
      await tester.pump();
      expect(finta.comandi.sublist(finta.comandi.length - 2),
          ['velocita 0.1', 'avvia']);
      await ancora.up();
      await tester.pump(const Duration(seconds: 1));
      expect(finta.comandi.where((c) => c.startsWith('salta')), isEmpty,
          reason: 'la discesa ha chiesto un salto al filmato');
    });

    testWidgets(
        'L ALONE STA SOTTO IL POLPASTRELLO dal primo fotogramma, e se ne va '
        'col dito', (tester) async {
      await scendi(tester);
      expect(find.byKey(const Key('viaggio_alone_del_dito')), findsNothing);
      final dove = tester.getCenter(find.byType(LaDiscesa)) +
          const Offset(-60, 120);
      final gesto = await tester.startGesture(dove);
      await tester.pump();
      final alone = find.byKey(const Key('viaggio_alone_del_dito'));
      expect(alone, findsOneWidget,
          reason: 'al tocco l alone non c e: nel primo mezzo secondo nessuno '
              'dice alla persona che il controllo e suo');
      final centro = tester.getCenter(alone);
      expect((centro - dove).distance, lessThan(1.0),
          reason: 'l alone sta a ${(centro - dove).distance} punti dal dito');
      await gesto.moveBy(const Offset(30, -40));
      await tester.pump();
      expect((tester.getCenter(alone) - (dove + const Offset(30, -40))).distance,
          lessThan(1.0),
          reason: 'il dito si e mosso e l alone e rimasto indietro');
      await gesto.up();
      await tester.pump();
      expect(alone, findsNothing, reason: 'il dito si e alzato e l alone resta');
    });

    test('l alone pulsa a quattro battiti e mezzo al secondo, dal tocco', () {
      expect(AloneDelPolpastrello.battito(Duration.zero), closeTo(1.0, 1e-9),
          reason: 'il primo battito deve cadere sul tocco, non dopo');
      var colpi = 0;
      var prima = AloneDelPolpastrello.faseAl(Duration.zero);
      for (var ms = 1; ms <= 10000; ms++) {
        final ora = AloneDelPolpastrello.faseAl(Duration(milliseconds: ms));
        if (ora < prima) colpi++;
        prima = ora;
      }
      // ignore: avoid_print
      print('ORDINE DI VOCE 09: in dieci secondi l alone batte $colpi volte');
      expect(colpi,
          (IlTamburoDellaDiscesa.battitiAlSecondo * 10).round(),
          reason: 'l alone batte $colpi volte in dieci secondi, e il tamburo '
              '${IlTamburoDellaDiscesa.battitiAlSecondo * 10}');
      expect(IlTamburoDellaDiscesa.battitiAlSecondo, 4.5,
          reason: 'l ordine dice circa quattro battiti e mezzo al secondo');
    });

    testWidgets(
        'l app che se ne va ferma il filmato subito, e al ritorno non riparte '
        'senza dito', (tester) async {
      // **L'ha chiesto la guardia delle sorgenti accese in sottofondo**, e il
      // difetto che c'era dietro non era il suono: `video_player` riprende da
      // solo, al ritorno, il filmato che stava andando.
      final finta = await scendi(tester);
      final gesto =
          await tester.startGesture(tester.getCenter(find.byType(LaDiscesa)));
      for (var i = 0; i < 10; i++) {
        await tester.pump(DiscesaInVideo.passoDellaRampa);
      }
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      expect(finta.comandi.last, 'sospendi',
          reason: 'l app se ne va col dito premuto e il filmato continua');
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump(const Duration(seconds: 1));
      final dopo = finta.comandi.sublist(finta.comandi.lastIndexOf('sospendi'));
      // ignore: avoid_print
      print('ORDINE DI VOCE 09: uscendo e tornando il filmato riceve $dopo');
      expect(dopo, ['sospendi'],
          reason: 'tornando nell app la discesa e ripartita da sola: $dopo');
      await gesto.up();
      expect(find.byKey(const Key('viaggio_alone_del_dito')), findsNothing);
    });

    testWidgets('alla prima discesa non si salta', (tester) async {
      await scendi(tester);
      await tester.pump(const Duration(seconds: 3));
      expect(find.byKey(const Key('viaggio_salta_la_discesa')), findsNothing,
          reason: 'l ordine: "alla prima discesa non compare"');
    });

    testWidgets(
        'dalla seconda discesa "Salta la discesa" compare dopo un secondo e '
        'mezzo, e porta alla nebbia senza far scendere', (tester) async {
      final finta = await scendi(tester, discese: 1);
      final salta = find.byKey(const Key('viaggio_salta_la_discesa'));
      await tester.pump(const Duration(milliseconds: 1400));
      expect(salta, findsNothing,
          reason: 'compare prima del secondo e mezzo');
      await tester.pump(const Duration(milliseconds: 200));
      expect(salta, findsOneWidget,
          reason: 'dopo un secondo e mezzo non compare');
      expect(find.text('Salta la discesa'), findsOneWidget);
      await tester.tap(salta);
      await tester.pump();
      expect(finta.comandi, isNot(contains('avvia')),
          reason: 'toccare Salta ha fatto partire il filmato: il pulsante sta '
              'dentro la zona che risponde al dito');
      expect(find.byKey(const Key('viaggio_nebbia')), findsOneWidget,
          reason: 'saltare non porta alla nebbia');
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets(
        'alla fine del filmato la nebbia entra in mezzo secondo, sopra il suo '
        'ultimo fotogramma', (tester) async {
      final finta = await scendi(tester, fotogramma: const Color(0xFFE8C98A));
      final gesto =
          await tester.startGesture(tester.getCenter(find.byType(LaDiscesa)));
      await tester.pump();
      finta.mostraIlSecondoFotogramma();
      await tester.pump(const Duration(milliseconds: 500));
      finta.arrivaInFondo();
      await tester.pump();
      await gesto.up();
      expect(find.byKey(const Key('viaggio_nebbia')), findsOneWidget,
          reason: 'il filmato e finito e la nebbia non arriva');
      const chiave = Key('viaggio_dissolvenza_della_nebbia');
      expect(
          find.descendant(
              of: find.byKey(chiave),
              matching: find.byKey(const Key('finta_fotogramma'))),
          findsOneWidget,
          reason: 'sopra la nebbia svanisce qualcosa che non e l ultimo '
              'fotogramma del filmato: la persona vedrebbe uno stacco');
      final allInizio = tester.widget<Opacity>(find.byKey(chiave)).opacity;
      await tester.pump(DiscesaInVideo.dissolvenzaVersoLaNebbia ~/ 2);
      final aMeta = tester.widget<Opacity>(find.byKey(chiave)).opacity;
      await tester.pump(DiscesaInVideo.dissolvenzaVersoLaNebbia);
      // ignore: avoid_print
      print('ORDINE DI VOCE 09: l ultimo fotogramma parte da '
          '${allInizio.toStringAsFixed(2)}, a meta vale '
          '${aMeta.toStringAsFixed(2)}, e dopo mezzo secondo non c e piu');
      expect(allInizio, greaterThan(0.9));
      expect(aMeta, inInclusiveRange(0.3, 0.7),
          reason: 'a meta del mezzo secondo l opacita vale $aMeta');
      expect(find.byKey(chiave), findsNothing,
          reason: 'dopo mezzo secondo l ultimo fotogramma e ancora li');
      expect(finta.chiusa, isTrue,
          reason: 'a dissolvenza finita il decodificatore resta acceso');
      expect(DiscesaInVideo.dissolvenzaVersoLaNebbia,
          const Duration(milliseconds: 500));
    });

    testWidgets('se il filmato non si prepara, si scende nel tunnel di riserva',
        (tester) async {
      await scendi(tester, riesce: false);
      await tester.pump();
      expect(find.byType(TunnelCheScende), findsOneWidget,
          reason: 'il filmato non c e e non c e nemmeno il tunnel: la '
              'discesa e un vicolo cieco');
      expect(find.byKey(const Key('viaggio_discesa_primo_fotogramma')),
          findsNothing);
      final gesto =
          await tester.startGesture(tester.getCenter(find.byType(LaDiscesa)));
      var passati = 0;
      while (find.byKey(const Key('viaggio_dito')).evaluate().isNotEmpty &&
          passati < 400) {
        await tester.pump(const Duration(milliseconds: 50));
        passati++;
      }
      await gesto.up();
      expect(find.byKey(const Key('viaggio_nebbia')), findsOneWidget,
          reason: 'nel tunnel di riserva non si arriva in fondo');
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets(
        'il tamburo comincia con la discesa, continua a dito alzato e si ferma '
        'alla fine', (tester) async {
      final battiti = <bool>[];
      PaletteSensoriale.spiaDelTamburo = battiti.add;
      PaletteSensoriale.tamburoPresenteNelleProve = true;
      final finta = await scendi(tester,
          impostazioni: SettingsController(suonoEVibrazione: true));
      await tester.pump();
      await tester.pump();
      expect(battiti, [true],
          reason: 'entrando nella discesa il tamburo non batte');
      final gesto =
          await tester.startGesture(tester.getCenter(find.byType(LaDiscesa)));
      await tester.pump(const Duration(milliseconds: 300));
      await gesto.up();
      await tester.pump(const Duration(seconds: 1));
      expect(battiti, [true],
          reason: 'il dito si e alzato e il tamburo si e fermato: l ordine '
              'vuole che continui, perche si e fermata la persona e non il '
              'Mondo di Sotto');
      finta.arrivaInFondo();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(battiti, [true, false],
          reason: 'la discesa e finita e il tamburo batte ancora');
    });

    testWidgets('senza il file del tamburo la discesa resta muta, e scende',
        (tester) async {
      final battiti = <bool>[];
      PaletteSensoriale.spiaDelTamburo = battiti.add;
      PaletteSensoriale.tamburoPresenteNelleProve = false;
      await scendi(tester,
          impostazioni: SettingsController(suonoEVibrazione: true));
      await tester.pump();
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump();
      expect(battiti, isEmpty,
          reason: 'il tamburo e stato chiesto senza file: la musica si '
              'abbasserebbe sotto un silenzio');
    });
  });

  test('il lettore vero non salta mai e non mostra barre', () {
    // **L'ORDINE VIETA DUE COSE PER NOME**: *"non si usa seekTo per far
    // avanzare il filmato"* e *"nessuna barra di avanzamento"*. Si leggono
    // nel sorgente della discesa, righe di commento escluse.
    final righe = File(
            'lib/features/maestri/caligo/viaggio/la_discesa_in_video.dart')
        .readAsLinesSync();
    cardinaleMinimo(righe.length, 200,
        cosa: 'righe del sorgente della discesa',
        perche: 'Su un file vuoto nessun divieto sarebbe violato.');
    final colpevoli = <String>[];
    for (var i = 0; i < righe.length; i++) {
      final r = righe[i].trimLeft();
      if (r.startsWith('//')) continue;
      for (final vietato in const [
        'seekTo(',
        'VideoProgressIndicator',
        'LinearProgressIndicator',
        'CircularProgressIndicator',
      ]) {
        if (r.contains(vietato)) colpevoli.add('riga ${i + 1}: $vietato');
      }
    }
    expect(colpevoli, isEmpty,
        reason: 'la discesa usa cio che l ordine vieta:\n'
            '${colpevoli.join("\n")}');
  });
}

/// **LA FINTA DEL LETTORE**, che registra ogni comando ricevuto.
class FintaDellaDiscesa implements LettoreDellaDiscesa {
  FintaDellaDiscesa({this.riesce = true, this.colore = const Color(0xFF000000)});

  final bool riesce;

  /// Il colore del fotogramma che disegna.
  final Color colore;

  final List<String> comandi = [];
  bool chiusa = false;
  bool _pronto = false;
  bool _fallito = false;
  bool _cominciato = false;
  bool _finito = false;
  VoidCallback? _quandoCambia;

  @override
  Future<void> apri() async {
    if (riesce) {
      _pronto = true;
    } else {
      _fallito = true;
    }
    _quandoCambia?.call();
  }

  @override
  bool get pronto => _pronto;

  @override
  bool get fallito => _fallito;

  @override
  bool get cominciato => _cominciato;

  @override
  bool get finito => _finito;

  @override
  void ascolta(VoidCallback? quandoCambia) => _quandoCambia = quandoCambia;

  @override
  Future<void> avvia() async => comandi.add('avvia');

  @override
  Future<void> sospendi() async => comandi.add('sospendi');

  @override
  Future<void> velocita(double quanto) async =>
      comandi.add('velocita ${quanto.toStringAsFixed(1)}');

  @override
  Widget disegna() =>
      ColoredBox(key: const Key('finta_fotogramma'), color: colore);

  @override
  void chiudi() {
    chiusa = true;
    comandi.add('chiudi');
  }

  void mostraIlSecondoFotogramma() {
    _cominciato = true;
    _quandoCambia?.call();
  }

  void arrivaInFondo() {
    _finito = true;
    _quandoCambia?.call();
  }
}
