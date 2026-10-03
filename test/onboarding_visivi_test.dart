import 'package:esoteric_circle/core/angels/angel_catalog.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/angels/angelo_ingrandito.dart';
import 'package:esoteric_circle/features/onboarding/anteprima_tono.dart';
import 'package:esoteric_circle/features/onboarding/astrolabio.dart';
import 'package:esoteric_circle/features/onboarding/mondo_grezzo.dart';
import 'package:esoteric_circle/features/onboarding/planisfero.dart';
import 'package:flutter/material.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// I visivi nuovi dell'onboarding, misurati dove si puo' misurare.
void main() {
  group('A4, l\'astrolabio si costruisce prima di girare', () {
    test('Gli anelli si tracciano uno dopo l\'altro, non insieme', () {
      // A un terzo del tempo il primo anello e' avanti, il terzo non e'
      // ancora partito: se partissero insieme non sarebbe una costruzione,
      // sarebbe una comparsa.
      final primo = AstrolabioPainter.avanzamentoAnello(0.33, 0);
      final terzo = AstrolabioPainter.avanzamentoAnello(0.33, 2);
      expect(primo, greaterThan(terzo));
      expect(terzo, 0, reason: 'il terzo anello parte subito come il primo');
    });

    test('Alla fine sono tutti tracciati', () {
      for (var i = 0; i < Astrolabio.anelli; i++) {
        expect(AstrolabioPainter.avanzamentoAnello(1.0, i), 1.0,
            reason: 'l\'anello $i non finisce mai di tracciarsi');
      }
    });

    testWidgets('Con Riduci Movimento c\'e\' gia\', finito', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 200,
            height: 200,
            child:
                Astrolabio(palette: MaestroPalette.neutral, reduceMotion: true),
          ),
        ),
      ));
      await tester.pump();
      final cp = tester.widget<CustomPaint>(find.descendant(
        of: find.byType(Astrolabio),
        matching: find.byType(CustomPaint),
      ));
      final p = cp.painter! as AstrolabioPainter;
      expect(p.costruzione, 1.0,
          reason: 'con Riduci Movimento la costruzione non e\' completa');
      expect(p.giro, 0.0, reason: 'con Riduci Movimento gli anelli girano');
    });
  });

  group('A5, le onde della voce parlano col colore', () {
    test('Ogni genere ha i suoi colori, e sono diversi fra loro', () {
      final lui = OndeDellaVoce.coloriPer(CourtesyForm.masculine);
      final lei = OndeDellaVoce.coloriPer(CourtesyForm.feminine);
      final neutro = OndeDellaVoce.coloriPer(CourtesyForm.neutral);

      expect(lui, isNot(equals(lei)));
      expect(lui, isNot(equals(neutro)));
      expect(lei, isNot(equals(neutro)));
    });

    test('Il maschile tende al blu, il femminile al rosa', () {
      // Il blu ha la componente blu maggiore della rossa, il rosa il
      // contrario: e' la definizione piu' semplice, e regge.
      for (final c in OndeDellaVoce.coloriPer(CourtesyForm.masculine)) {
        expect(c.b, greaterThan(c.r), reason: '$c non e\' un blu');
      }
      for (final c in OndeDellaVoce.coloriPer(CourtesyForm.feminine)) {
        expect(c.r, greaterThan(c.b), reason: '$c non e\' un rosa');
      }
    });

    test('Il neutro e\' un arcobaleno, non una tinta sola', () {
      final n = OndeDellaVoce.coloriPer(CourtesyForm.neutral);
      expect(n.length, greaterThanOrEqualTo(4),
          reason: 'un arcobaleno con ${n.length} colori non e\' un arcobaleno');
      // Copre sia toni caldi sia freddi.
      expect(n.any((c) => c.r > c.b), isTrue);
      expect(n.any((c) => c.b > c.r), isTrue);
    });
  });

  group('A2, i ruoli dei tre Angeli', () {
    test('Sono Fisico, Del cuore e Dell\'intelletto', () {
      // La decisione di Mauro del 28 luglio: ciascuno nasce da un dato
      // diverso, quindi nessuno dei tre si chiama "Custode".
      expect(RuoloAngelo.perIndice(0).titolo, 'Fisico');
      expect(RuoloAngelo.perIndice(1).titolo, 'Del cuore');
      expect(RuoloAngelo.perIndice(2).titolo, "Dell'intelletto");
      for (final r in RuoloAngelo.values) {
        expect(r.titolo.toLowerCase().contains('custode'), isFalse,
            reason: '${r.titolo} chiama ancora custode uno dei tre');
      }
    });

    test('Ogni ruolo dichiara da quale dato nasce', () {
      expect(RuoloAngelo.fisico.origine, contains('Sole'));
      expect(RuoloAngelo.cuore.origine, contains('giorno'));
      expect(RuoloAngelo.intelletto.origine, contains('ora'));
    });

    testWidgets('L\'ingrandimento mostra il corpus e si chiude',
        (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final angelo = AngelCatalog.all.first;
      // Si apre come si apre davvero, col foglio che sale: montarlo nudo
      // dentro uno Scaffold non e' la stessa cosa, e un test che monta una
      // cosa diversa da quella vera non prova niente.
      await tester.pumpWidget(MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => MaestroController()),
          ],
          child: MaterialApp(
            // Col MaestroScope, come nell'app: e' da li' che la palette arriva a
            // chi apre il foglio.
            home: MaestroScope(
                child: Scaffold(
              body: Builder(
                builder: (context) => Center(
                  child: TextButton(
                    onPressed: () => AngeloIngrandito.apri(context,
                        angelo: angelo, ruolo: RuoloAngelo.intelletto),
                    child: const Text('apri'),
                  ),
                ),
              ),
            )),
          )));
      await tester.tap(find.text('apri'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('angelo_ingrandito')), findsOneWidget);
      expect(find.textContaining(angelo.name), findsWidgets);
      expect(find.textContaining('Coro dei'), findsOneWidget);
      // Il titolo del ruolo su una riga sola, mai spezzato a meta' parola.
      final titolo = tester
          .widget<Text>(find.text(RuoloAngelo.intelletto.titolo.toUpperCase()));
      expect(titolo.maxLines, 1);
      expect(titolo.softWrap, isFalse);
    });
  });

  group('A8, l\'Antartide non attraversa piu\' lo schermo', () {
    test('Nessun punto di terra tocca i due bordi alla stessa latitudine', () {
      // La fascia andava da meno 180 a piu' 180, quindi la riga di puntini
      // partiva da un bordo e finiva all'altro. Adesso i bordi restano vuoti
      // sotto il circolo polare.
      final punti = <Offset>[];
      for (var r = 0; r < Planisfero.righe; r++) {
        for (var c = 0; c < Planisfero.colonne; c++) {
          final lon = -180 + (c + 0.5) * 360 / Planisfero.colonne;
          final lat = 90 - (r + 0.5) * 180 / Planisfero.righe;
          if (lat < -60 && MondoGrezzo.eTerra(lat, lon)) {
            punti.add(Offset(lon, lat));
          }
        }
      }
      expect(punti, isNotEmpty, reason: 'l\'Antartide e\' sparita del tutto');
      final piuAOvest = punti.map((p) => p.dx).reduce(minimo);
      final piuAEst = punti.map((p) => p.dx).reduce(massimo);
      expect(piuAOvest, greaterThan(-170),
          reason: 'tocca ancora il bordo di sinistra a $piuAOvest');
      expect(piuAEst, lessThan(170),
          reason: 'tocca ancora il bordo di destra a $piuAEst');
    });
  });
}

double minimo(double a, double b) => a < b ? a : b;
double massimo(double a, double b) => a > b ? a : b;
