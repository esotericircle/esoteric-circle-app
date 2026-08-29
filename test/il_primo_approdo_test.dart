import 'dart:io';

import 'package:esoteric_circle/features/onboarding/primo_approdo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL TUTORIAL DI PRIMO APPRODO. Ordine CB voce 02.
///
/// **Cosa difende questa prova**, che e' cio' che l'ordine fissa e non si
/// cambia: cinque fumetti, in quell'ordine, coi bersagli che il fondatore ha
/// elencato; lo skip su tutti e cinque; il minuto di lettura misurato e non
/// promesso; e il tutorial che NON parte da solo, che e' la differenza fra una
/// funzione e un velo addosso a chiunque monti l'app.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('i cinque fumetti', () {
    test('sono cinque, nell\'ordine del fondatore, coi suoi bersagli', () {
      expect(cinqueFumetti, hasLength(5));
      expect(cinqueFumetti[0].titolo, 'IL CERCHIO TI ACCOGLIE');
      expect(cinqueFumetti[0].ancora, isNull,
          reason: 'il benvenuto e la soglia: l\'ordine dice "Nessuna freccia"');
      expect(cinqueFumetti[0].lato, LatoDelFumetto.soglia);

      // L'ordine dei quattro bersagli e' quello elencato dal fondatore:
      // i Maestri, Esplora in basso, i Doni del Giorno, la barra in alto.
      expect(
          cinqueFumetti.sublist(1).map((f) => f.ancora).toList(),
          const [
            BersagliDelPrimoApprodo.trio,
            BersagliDelPrimoApprodo.esplora,
            BersagliDelPrimoApprodo.doni,
            BersagliDelPrimoApprodo.identita,
          ],
          reason: 'i cinque sono stati riordinati, e l\'ordine lo vieta');
    });

    test('ogni bersaglio esiste davvero in una scena', () {
      // **LA FRECCIA PUNTA UNA COSA CHE ESISTE.** Un nome di bersaglio che
      // nessuna scena veste sarebbe una freccia nel vuoto, e nessuno se ne
      // accorgerebbe finche' non lo vede il fondatore.
      const dove = <String, String>{
        'trio': 'lib/features/santuario/santuario_screen.dart',
        'esplora': 'lib/features/shell/barra_del_cerchio.dart',
        'doni': 'lib/features/santuario/santuario_screen.dart',
        'identita': 'lib/features/shell/barra_dell_identita.dart',
      };
      final senzaScena = <String>[];
      for (final voce in dove.entries) {
        final sorgente = File(voce.value).readAsStringSync();
        // Si cerca l'ancora COL SUO NOME accanto, non l'una o l'altro: una
        // scena che monta un'ancora qualunque non dice niente su questo
        // bersaglio.
        if (!sorgente.contains(
            'nome: BersagliDelPrimoApprodo.${voce.key}')) {
          senzaScena.add('${voce.key} in ${voce.value}');
        }
      }
      // ignore: avoid_print
      print('ORDINE CB VOCE 02: bersagli vestiti da una scena '
          '${dove.length - senzaScena.length} su ${dove.length}');
      expect(senzaScena, isEmpty,
          reason: 'questi bersagli non li veste nessuno: $senzaScena');
    });

    test('si leggono in un minuto, e il conto e\' qui', () {
      // **IL MINUTO SI MISURA, non si promette.** Il fondatore ha chiesto
      // cinque fumetti "da leggere in 1 minuto". La lettura silenziosa in
      // italiano sta fra le 200 e le 250 parole al minuto: si prende il
      // numero peggiore, 200, e si tiene il totale sotto quello. Con 250 il
      // margine e' ancora piu' largo.
      var parole = 0;
      for (final f in cinqueFumetti) {
        parole += f.titolo.split(RegExp(r'\s+')).length;
        parole += f.testo.split(RegExp(r'\s+')).length;
      }
      final secondi = (parole / 200 * 60).round();
      // ignore: avoid_print
      print('ORDINE CB VOCE 02: i cinque fumetti sono $parole parole, cioe\' '
          'circa $secondi secondi a 200 parole al minuto');
      expect(parole, lessThanOrEqualTo(200),
          reason: 'i cinque fumetti sono $parole parole: a 200 parole al '
              'minuto non si leggono piu\' in un minuto');
    });

    test('nessun testo porta il trattino lungo', () {
      for (final f in cinqueFumetti) {
        expect(f.titolo.contains('—'), isFalse);
        expect(f.testo.contains('—'), isFalse,
            reason: 'trattino lungo in "${f.titolo}"');
      }
    });
  });

  group('il velo', () {
    Future<void> monta(WidgetTester tester,
        {required bool armato, Size schermo = const Size(360, 800)}) async {
      SharedPreferences.setMockInitialValues(
          armato ? {MemoriaDelPrimoApprodo.chiaveArmata: true} : const {});
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = schermo;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MaterialApp(
        home: PrimoApprodo(
          child: Scaffold(
            body: Center(
              child: AncoraDelPrimoApprodo(
                nome: BersagliDelPrimoApprodo.trio,
                child: SizedBox(width: 200, height: 60),
              ),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('non parte da solo: senza chi lo arma non c\'e\'',
        (tester) async {
      await monta(tester, armato: false);
      expect(find.byKey(const Key('primo_approdo_titolo_0')), findsNothing,
          reason: 'il tutorial nasce acceso, e allora si accende anche sopra '
              'ogni prova e ogni anteprima che monta l\'app');
    });

    testWidgets('armato parte, e mostra il primo fumetto', (tester) async {
      await monta(tester, armato: true);
      expect(find.text('IL CERCHIO TI ACCOGLIE'), findsOneWidget);
      expect(find.text('1 di 5'), findsOneWidget);
    });

    testWidgets('lo skip c\'e\' su tutti e cinque', (tester) async {
      await monta(tester, armato: true);
      for (var i = 0; i < cinqueFumetti.length; i++) {
        expect(find.byKey(const Key('primo_approdo_salta')), findsOneWidget,
            reason: 'al fumetto ${i + 1} non si puo\' chiudere, e l\'ordine '
                'chiede di poterlo fare in ogni momento');
        expect(find.text('${i + 1} di 5'), findsOneWidget);
        if (i < cinqueFumetti.length - 1) {
          await tester.tap(find.byKey(const Key('primo_approdo_avanti')));
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('saltando se ne va, e non torna piu\'', (tester) async {
      await monta(tester, armato: true);
      await tester.tap(find.byKey(const Key('primo_approdo_salta')));
      await tester.pumpAndSettle();
      expect(find.text('IL CERCHIO TI ACCOGLIE'), findsNothing);
      final p = await SharedPreferences.getInstance();
      expect(p.getBool(MemoriaDelPrimoApprodo.chiave), isTrue,
          reason: 'chi ha saltato lo rivedra\' al prossimo avvio');
      expect(p.getBool(MemoriaDelPrimoApprodo.chiaveArmata), isNull,
          reason: 'l\'innesco resta armato, e il tutorial riparte da solo');
    });

    testWidgets('arrivando in fondo se ne va', (tester) async {
      await monta(tester, armato: true);
      for (var i = 0; i < cinqueFumetti.length; i++) {
        await tester.tap(find.byKey(const Key('primo_approdo_avanti')));
        await tester.pumpAndSettle();
      }
      expect(find.byKey(const Key('primo_approdo_conta')), findsNothing);
      final p = await SharedPreferences.getInstance();
      expect(p.getBool(MemoriaDelPrimoApprodo.chiave), isTrue);
    });

    testWidgets('la freccia punta il bersaglio, non il centro dello schermo',
        (tester) async {
      await monta(tester, armato: true);
      // Si passa al secondo fumetto, che e' il primo con una freccia.
      await tester.tap(find.byKey(const Key('primo_approdo_avanti')));
      await tester.pumpAndSettle();
      final bersaglio =
          AncoraDelPrimoApprodo.dove(BersagliDelPrimoApprodo.trio);
      expect(bersaglio, isNotNull,
          reason: 'l\'ancora non sa dire dove sta il suo pezzo di scena');
      final carta = tester.getRect(find.byKey(const Key('primo_approdo_testo_1')));
      // ignore: avoid_print
      print('ORDINE CB VOCE 02: bersaglio a ${bersaglio!.top.round()}, '
          'fumetto a ${carta.top.round()}');
      expect(carta.top, greaterThan(bersaglio.bottom),
          reason: 'il fumetto dei Maestri copre la cosa di cui parla');
    });

    testWidgets('nessuno dei cinque esce dallo schermo a 360 punti',
        (tester) async {
      // **QUESTA PROVA NASCE DA UN\'ANTEPRIMA, non da un sospetto.** Il fumetto
      // dei Maestri, appeso sotto un carosello alto mezzo schermo, usciva dal
      // fondo: il tasto Avanti era fuori, e il tocco non lo trovava. Le prove
      // erano tutte verdi, perche\' nessuna guardava DOVE finiva la carta.
      await monta(tester, armato: true, schermo: const Size(360, 797));
      final schermo = tester.view.physicalSize;
      final fuori = <String>[];
      for (var i = 0; i < cinqueFumetti.length; i++) {
        final carta = tester.getRect(find.byKey(Key(
            'primo_approdo_titolo_$i')));
        final tasto =
            tester.getRect(find.byKey(const Key('primo_approdo_avanti')));
        if (carta.top < 0 || tasto.bottom > schermo.height) {
          fuori.add('${cinqueFumetti[i].titolo}: da ${carta.top.round()} a '
              '${tasto.bottom.round()} su ${schermo.height.round()}');
        }
        if (i < cinqueFumetti.length - 1) {
          await tester.tap(find.byKey(const Key('primo_approdo_avanti')));
          await tester.pumpAndSettle();
        }
      }
      // ignore: avoid_print
      print('ORDINE CB VOCE 02: fumetti fuori dallo schermo a 360x797: '
          '${fuori.length} su ${cinqueFumetti.length}');
      expect(fuori, isEmpty,
          reason: 'questi fumetti escono dallo schermo: $fuori');
    });

    testWidgets('senza il pezzo di scena il fumetto resta, senza freccia',
        (tester) async {
      // **LA SCELTA DICHIARATA PER LE ZONE NON VISIBILI.** Se cio' che il
      // fumetto indica non e' montato in questo momento, il fumetto si mostra
      // lo stesso, al centro e senza freccia: saltarlo lascerebbe un buco nel
      // racconto, e puntare una freccia verso il nulla sarebbe peggio.
      SharedPreferences.setMockInitialValues(
          {MemoriaDelPrimoApprodo.chiaveArmata: true});
      await tester.pumpWidget(const MaterialApp(
        home: PrimoApprodo(child: Scaffold(body: SizedBox.shrink())),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('primo_approdo_avanti')));
      await tester.pumpAndSettle();
      expect(find.text('I TRE MAESTRI'), findsOneWidget,
          reason: 'senza il suo bersaglio il fumetto sparisce, e il racconto '
              'perde un pezzo');
    });
  });

  group('le due chiavi', () {
    test('stanno sotto un prefisso che la cancellazione porta via', () {
      // Il prefisso `avvisi.` e' nell'elenco di CioCheETuo: chi cancella tutto
      // e torna e' una persona nuova, e il tutorial lo rivede.
      for (final chiave in const [
        MemoriaDelPrimoApprodo.chiave,
        MemoriaDelPrimoApprodo.chiaveArmata,
      ]) {
        expect(chiave.startsWith('avvisi.'), isTrue,
            reason: '$chiave sta fuori dai prefissi che la cancellazione '
                'porta via, e sopravvivrebbe a chi se ne va');
      }
    });

    test('il Risveglio arma il primo approdo quando finisce', () {
      // **LA PROVA LEGGE IL CODICE**, perche\' il rito scrive su disco dentro
      // un try muto e da fuori non si distingue "non ha scritto" da "non
      // c\'era disco".
      final rito = File('lib/features/onboarding/risveglio_journey.dart')
          .readAsStringSync();
      expect(rito.contains('MemoriaDelPrimoApprodo.arma()'), isTrue,
          reason: 'il Risveglio non arma piu\' il primo approdo, e allora '
              'nessuno lo vedra\' mai');

      // **E NON LO ARMA IL CONTROLLER, e questa riga vale piu\' della prima.**
      // Messa dentro `OnboardingController.complete()`, l\'arma scattava anche
      // per le prove che chiamano quel metodo solo per portarsi nello stato
      // "dentro il Cerchio": tredici prove sono cadute in un colpo, perche\' il
      // velo si prendeva i tocchi destinati alla scena. `complete()` dice che
      // il rito e\' fatto; arrivare nel Cerchio per la prima volta succede nel
      // rito, e solo li\'.
      final controller = File('lib/core/onboarding/onboarding_controller.dart')
          .readAsStringSync();
      expect(controller.contains('primo_approdo'), isFalse,
          reason: 'l\'arma e\' tornata dentro il controller, e da li\' si accende '
              'in ogni prova che dichiara l\'onboarding fatto');
    });

    test('il menu\' utente lo fa riapparire', () {
      final sorgente =
          File('lib/features/account/account_screen.dart').readAsStringSync();
      for (final pezzo in const [
        "id: 'rivedi_primo_approdo'",
        'MemoriaDelPrimoApprodo.rivedi()',
        'rivediIlPrimoApprodo.value++',
      ]) {
        expect(sorgente.contains(pezzo), isTrue,
            reason: 'il menu\' utente non porta piu\' "$pezzo", e l\'ordine '
                'chiede che si possa far riapparire da li\'');
      }
    });
  });
}
