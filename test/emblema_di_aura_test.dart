import 'dart:async';
import 'dart:io';

import 'package:esoteric_circle/core/archetypes/archetype.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/maestro/simbolo_dellattesa.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/maestro/tempi_dell_attesa.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/components/consulto_del_cielo_view.dart';
import 'package:esoteric_circle/design_system/components/loto_dorato.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// LA PROVA DELLA VOCE 3: l'emblema di Aura, e il loto per chi non ha il Test.
///
/// **Una prova che conta widget non e' una prova sulle immagini.** Un
/// `Image.asset` sta nell'albero anche quando il file non esiste, anche quando
/// non e' stato decodificato, anche quando a schermo c'e' un quadrato vuoto: la
/// prova passerebbe e la persona vedrebbe il buco. Qui si pretende che il
/// fotogramma sia DECODIFICATO, e il precache si fa prima della verifica.
void main() {
  const natal = NatalContext(sunSign: 'Leone');

  /// **La vista chiede due provider e il MaestroScope.** Senza, non renderizza
  /// affatto: la prima stesura di questa prova montava un MaterialApp nudo e
  /// vedeva zero widget, il che sembrava un difetto del loto e invece era il
  /// montaggio. Non concludere che la misura e' cieca prima di aver guardato
  /// se il caso percorre davvero il ramo.
  Widget scena({Maestro maestro = Maestro.aura, Archetype? archetipo}) =>
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => MaestroController()),
        ],
        child: MaterialApp(
          home: MaestroScope(
            child: Scaffold(
              body: ConsultoDelCieloView(
                maestro: maestro,
                natal: natal,
                archetipo: archetipo,
              ),
            ),
          ),
        ),
      );

  group('L\'emblema di Aura si carica come il segno di Medora', () {
    test('la strada e\' UNA SOLA per tutti e tre i Maestri', () {
      // Se Aura avesse una sua strada, il giorno in cui una delle due cambia
      // l'altra resterebbe indietro senza che nessuno se ne accorga.
      final sorgente =
          File('lib/core/maestro/simbolo_dellattesa.dart').readAsStringSync();
      final porte =
          RegExp(r'static SimboloDellAttesa \w+\(').allMatches(sorgente).length;
      expect(porte, 1, reason: 'il simbolo si decide in piu\' di un punto');

      // E tutti e tre passano dallo stesso `per`.
      for (final m in Maestro.values) {
        expect(
            SimboloDellAttesa.per(m, natal: natal, archetipo: Archetype.mago),
            isA<SimboloDellAttesa>());
      }
    });

    testWidgets('con il Test fatto, Aura mostra l\'emblema DECODIFICATO',
        (tester) async {
      const archetipo = Archetype.mago;
      final simbolo = SimboloDellAttesa.per(Maestro.aura,
          natal: natal, archetipo: archetipo);
      expect(simbolo.asset, isNotNull,
          reason: 'con il Test fatto ci deve essere un emblema vero');
      expect(simbolo.loto, isFalse,
          reason: 'chi ha fatto il Test non deve vedere il loto dell\'attesa');

      await tester.pumpWidget(scena(archetipo: archetipo));
      // IL PRECACHE PRIMA DELLA VERIFICA: in cattura headless nessuno decodifica
      // le immagini da solo, e senza questo la prova misurerebbe un albero, non
      // un fotogramma.
      final element = tester.element(find.byType(MaterialApp));
      await tester.runAsync(() async {
        await precacheImage(AssetImage(simbolo.asset!), element);
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // La verifica vera: l'immagine esiste E il suo fotogramma e' arrivato.
      final immagini = tester.widgetList<Image>(find.byType(Image)).toList();
      expect(immagini, isNotEmpty, reason: 'nessuna immagine nell\'albero');
      final stream = immagini.first.image.resolve(ImageConfiguration.empty);
      var decodificata = false;
      final atteso = Completer<void>();
      final ascoltatore = ImageStreamListener((info, _) {
        decodificata = info.image.width > 0 && info.image.height > 0;
        if (!atteso.isCompleted) atteso.complete();
      }, onError: (e, s) {
        if (!atteso.isCompleted) atteso.complete();
      });
      await tester.runAsync(() async {
        stream.addListener(ascoltatore);
        await atteso.future
            .timeout(const Duration(seconds: 5), onTimeout: () {});
        stream.removeListener(ascoltatore);
      });
      expect(decodificata, isTrue,
          reason: 'l\'emblema e\' nell\'albero ma non e\' stato DECODIFICATO: '
              'a schermo sarebbe un quadrato vuoto');
    });
  });

  group('Chi non ha fatto il Test riceve il loto, mai un vuoto', () {
    test('il modello dice loto piu\' invito, non l\'invito da solo', () {
      final simbolo =
          SimboloDellAttesa.per(Maestro.aura, natal: natal, archetipo: null);
      expect(simbolo.loto, isTrue);
      expect(simbolo.invito, SimboloDellAttesa.invitoAlTest);
      expect(simbolo.asset, isNull,
          reason: 'il loto non e\' un file e non deve fingersi tale');
      expect(simbolo.ceQualcosa, isTrue,
          reason: 'con il loto c\'e\' qualcosa da mostrare');
    });

    testWidgets('il loto e\' a schermo, e non e\' un quadrato vuoto',
        (tester) async {
      await tester.pumpWidget(scena());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(LotoDorato), findsOneWidget,
          reason: 'senza Test non compare nessun loto');
      // **Non basta che ci sia: deve avere dei pixel.** Un CustomPaint di lato
      // zero starebbe nell'albero e a schermo non ci sarebbe niente.
      final riquadro = tester.getSize(find.byType(LotoDorato));
      expect(riquadro.width, greaterThan(40));
      expect(riquadro.height, greaterThan(40));

      // E nessun emblema di archetipo si e' intrufolato: sarebbe la bugia che
      // la regola vieta.
      expect(find.byType(Image), findsNothing,
          reason: 'senza Test non deve comparire nessun emblema');
    });

    testWidgets('l\'invito e\' a corpo 16, non 14', (tester) async {
      await tester.pumpWidget(scena());
      await tester.pump(const Duration(milliseconds: 100));

      final invito =
          tester.widget<Text>(find.byKey(const Key('consulto_invito')));
      expect(invito.data, SimboloDellAttesa.invitoAlTest);
      expect(invito.style?.fontSize, 16,
          reason: 'a 14 in oro all\'85 per cento l\'unica riga che chiede di '
              'fare qualcosa si legge come una nota a pie\' di pagina');
    });

    test('la scena resta aperta piu\' a lungo quando c\'e\' l\'invito', () {
      expect(TempiDellAttesa.durataBattutaConInvito,
          greaterThan(TempiDellAttesa.durataBattuta),
          reason: 'con una riga in piu\' da leggere la battuta deve durare di '
              'piu\', altrimenti la frase cambia mentre si legge l\'invito');
    });

    testWidgets('con il Test fatto NON compare ne loto ne invito',
        (tester) async {
      await tester.pumpWidget(scena(archetipo: Archetype.mago));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(LotoDorato), findsNothing);
      expect(find.byKey(const Key('consulto_invito')), findsNothing,
          reason: 'un invito che compare sempre non e\' un invito');
    });
  });

  group('La regola scritta dice quello che il codice fa', () {
    test('il file non dichiara piu\' che il loto non esiste', () {
      final sorgente =
          File('lib/core/maestro/simbolo_dellattesa.dart').readAsStringSync();
      expect(sorgente.contains('IL FIORE DI LOTO NON ESISTE'), isFalse,
          reason: 'il codice mostra il loto e il commento dice che non esiste: '
              'uno dei due mente');
      expect(sorgente, contains('NON E\' UNO DEI DODICI'),
          reason: 'manca la ragione per cui il loto puo\' stare li\'');
    });

    test('il loto dichiara di essere un ripiego', () {
      final sorgente = File('lib/design_system/components/loto_dorato.dart')
          .readAsStringSync();
      expect(sorgente.toUpperCase(), contains('RIPIEGO'),
          reason: 'un disegno che sostituisce un\'arte che non c\'e\' deve '
              'dire di essere un ripiego');
    });
  });
}
