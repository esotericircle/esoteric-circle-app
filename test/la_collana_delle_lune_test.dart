import 'package:esoteric_circle/core/lunario/il_listino_del_respiro.dart';
import 'package:esoteric_circle/core/lunario/il_motore_lunare.dart';
import 'package:esoteric_circle/core/lunario/il_respiro_della_luna.dart';
import 'package:esoteric_circle/core/lunario/la_collana_delle_lune.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/respiro_della_luna/la_collana_delle_lune_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **LA COLLANA DELLE LUNE.** Ordine FX voce FX.05, 16 ottobre 2026.
///
/// Prova che il ciclo segue la lunazione vera (ventinove o trenta perle fra
/// due Lune nuove), che le perle si accendono solo sui giorni davvero
/// respirati e restano spente sui giorni passati, che la ricucitura rispetta
/// i suoi limiti, e che la schermata vera mostra la collana e lascia
/// ricucire una perla spenta col tocco.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Il ciclo vero, dalla Luna nuova alla prossima', () {
    test('il numero di perle e\' la differenza in giorni fra due Lune nuove',
        () async {
      SharedPreferences.setMockInitialValues({});
      final respiro = IlRespiroDellaLuna();
      await respiro.leggi();
      final collana = LaCollanaDelleLune(respiro: respiro);

      final oggi = DateTime(2026, 10, 16);
      final ciclo = collana.cicloDi(oggi);
      final n = collana.numeroDiPerle(ciclo.inizio, ciclo.fine);

      expect(n, anyOf(29, 30),
          reason: 'una lunazione vera dura 29 o 30 giorni, non $n');
      expect(collana.perle(oggi).length, n);

      // L'inizio del ciclo e' davvero una Luna nuova vera, non un ripiego:
      // il motore ne trova una entro il giorno di calendario dichiarato
      // (l'istante esatto puo' cadere in un punto qualunque di quel giorno
      // locale).
      final luneVicineAllInizio = IlMotoreLunare.luneNuoveFra(
          ciclo.inizio, ciclo.inizio.add(const Duration(days: 1)));
      expect(luneVicineAllInizio, isNotEmpty,
          reason: 'l\'inizio del ciclo non cade su una Luna nuova vera');
    });

    test('i giorni respirati sono accesi, i passati non respirati spenti',
        () async {
      SharedPreferences.setMockInitialValues({});
      final respiro = IlRespiroDellaLuna();
      await respiro.leggi();
      final collana = LaCollanaDelleLune(respiro: respiro);

      final oggi = DateTime(2026, 10, 16);
      final ciclo = collana.cicloDi(oggi);
      final treGiorniFa = oggi.subtract(const Duration(days: 3));
      await respiro.segnaRespirato(treGiorniFa);

      final perle = collana.perle(oggi);
      final quellaDiTreGiorniFa =
          perle.firstWhere((p) => p.giorno == treGiorniFa);
      expect(quellaDiTreGiorniFa.stato, StatoDellaPerla.accesa);
      expect(quellaDiTreGiorniFa.immagine, isNotNull,
          reason: 'una perla accesa porta la Luna vera di quel giorno');

      final giorniPassatiNonRespirati = perle.where((p) =>
          p.giorno.isBefore(DateTime(oggi.year, oggi.month, oggi.day)) &&
          p.giorno != treGiorniFa);
      // Nel ciclo in corso ci sono almeno alcuni giorni passati non
      // respirati (a meno che oggi sia l'inizio stesso del ciclo).
      if (ciclo.inizio.isBefore(oggi)) {
        expect(giorniPassatiNonRespirati, isNotEmpty);
        for (final p in giorniPassatiNonRespirati) {
          expect(p.stato, StatoDellaPerla.spenta,
              reason: 'il giorno ${p.giorno} non e\' stato respirato, non '
                  'deve essere acceso');
        }
      }

      // Oggi stesso e i giorni futuri del ciclo sono in attesa, non spenti:
      // "nessuna punizione" per un giorno che non e\' nemmeno finito.
      final giorniDaOggiInAvanti =
          perle.where((p) => !p.giorno.isBefore(DateTime(oggi.year, oggi.month, oggi.day)));
      for (final p in giorniDaOggiInAvanti) {
        expect(p.stato, isNot(StatoDellaPerla.spenta),
            reason: 'il giorno ${p.giorno} non e\' ancora passato: non puo\' '
                'essere spento');
      }
    });
  });

  group('La ricucitura', () {
    test('ricuce un giorno spento recente, rispettando i due limiti',
        () async {
      SharedPreferences.setMockInitialValues({});
      final respiro = IlRespiroDellaLuna();
      await respiro.leggi();
      final collana = LaCollanaDelleLune(respiro: respiro);
      final oggi = DateTime(2026, 10, 16);
      final tresGiorniFa = oggi.subtract(const Duration(days: 3));

      expect(collana.giorniRicucibili(oggi), contains(tresGiorniFa));

      final andata =
          await collana.ricuciUnaPerlaLocalmente(tresGiorniFa, now: oggi);
      expect(andata, isTrue);
      expect(respiro.eRespirato(tresGiorniFa), isTrue);
      final perla =
          collana.perle(oggi).firstWhere((p) => p.giorno == tresGiorniFa);
      expect(perla.stato, StatoDellaPerla.accesa);
    });

    test('non ricuce oltre il tetto per ciclo', () async {
      SharedPreferences.setMockInitialValues({});
      final respiro = IlRespiroDellaLuna();
      await respiro.leggi();
      final collana = LaCollanaDelleLune(respiro: respiro);
      final oggi = DateTime(2026, 10, 16);

      var ricucite = 0;
      for (var i = 1; i <= IlListinoDelRespiro.massimePerleRicucitePerCiclo + 2;
          i++) {
        final giorno = oggi.subtract(Duration(days: i));
        if (await collana.ricuciUnaPerlaLocalmente(giorno, now: oggi)) {
          ricucite++;
        }
      }
      expect(ricucite, IlListinoDelRespiro.massimePerleRicucitePerCiclo,
          reason: 'il tetto per ciclo non ha fermato la ricucitura');
    });

    test('non ricuce oltre la finestra dei giorni indietro', () async {
      SharedPreferences.setMockInitialValues({});
      final respiro = IlRespiroDellaLuna();
      await respiro.leggi();
      final collana = LaCollanaDelleLune(respiro: respiro);
      final oggi = DateTime(2026, 10, 16);
      final troppoIndietro = oggi.subtract(
          const Duration(days: IlListinoDelRespiro.massimoGiorniIndietro + 5));

      expect(collana.giorniRicucibili(oggi), isNot(contains(troppoIndietro)));
      final andata =
          await collana.ricuciUnaPerlaLocalmente(troppoIndietro, now: oggi);
      expect(andata, isFalse);
    });
  });

  group('La consegna, alla Luna nuova', () {
    test('non parte se nessun giorno del ciclo chiuso e\' stato respirato',
        () async {
      SharedPreferences.setMockInitialValues({});
      final respiro = IlRespiroDellaLuna();
      await respiro.leggi();
      final collana = LaCollanaDelleLune(respiro: respiro);
      expect(collana.consegnaInAttesa(DateTime(2026, 10, 16)), isFalse);
    });

    test('segnaConsegnata archivia la collana e non la rifa\' partire',
        () async {
      SharedPreferences.setMockInitialValues({});
      final respiro = IlRespiroDellaLuna();
      await respiro.leggi();
      final collana = LaCollanaDelleLune(respiro: respiro);
      final oggi = DateTime(2026, 10, 16);
      final ciclo = collana.cicloDi(oggi);
      // Si simula un ciclo chiuso con un giorno respirato, scrivendo
      // direttamente lo stato persistito come lo troverebbe l'app, cosi'
      // la prova non dipende da quando la Luna nuova vera e' caduta.
      await respiro.segnaRespirato(ciclo.inizio.subtract(const Duration(days: 2)));

      await collana.segnaConsegnata(oggi);
      expect(collana.scrigno, isNotEmpty);
      expect(collana.scrigno.last.perleAccese, greaterThanOrEqualTo(1));
    });
  });

  group('La schermata vera', () {
    Widget host(Widget scena) => MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => MaestroController()),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: MaestroScope(child: scena),
          ),
        );

    testWidgets('mostra la collana e lascia ricucire una perla spenta',
        (tester) async {
      final oggi = DateTime(2026, 10, 16, 9);
      // Nessun giorno respirato ancora: lo scrive la prova stessa col
      // tocco della ricucitura, piu' sotto.
      //
      // **UNA RICUCITURA GIA' COMPRATA, ordine FX, 16 ottobre 2026.** La
      // schermata non promette mai una spesa che non avviene (Linee Guida
      // UX V13 sezione 4): senza un credito vero (`GliEosDelRespiro
      // .perleRicucite`, la stessa chiave del wallet) il tocco mostra solo
      // che la ricucitura arriva col server, non il tasto "Ricuci". Qui si
      // simula un credito gia' comprato, per provare il gesto vero finche'
      // il server non lo pubblica.
      SharedPreferences.setMockInitialValues({'respiro.perleRicucite': 1});
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(host(LaCollanaDelleLuneScreen(now: oggi)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      expect(find.text('La Collana delle Lune'), findsOneWidget);
      expect(find.byKey(const Key('collana_nome_ciclo')), findsOneWidget);

      // Un giorno spento recente diventa un invito a ricucire.
      final tresGiorniFa = oggi.subtract(const Duration(days: 3));
      final chip = find.byKey(
          Key('collana_ricuci_${IlRespiroDellaLuna.data(DateTime(tresGiorniFa.year, tresGiorniFa.month, tresGiorniFa.day))}'));
      expect(chip, findsOneWidget,
          reason: 'un giorno spento recente dovrebbe offrire la ricucitura');

      await tester.tap(chip);
      await tester.pumpAndSettle();
      expect(find.text('Ricuci'), findsOneWidget);
      await tester.tap(find.text('Ricuci'));
      await tester.pumpAndSettle();

      // Ricucita, la stessa perla non offre piu' la ricucitura: e\' accesa.
      expect(chip, findsNothing);
    });
  });
}
