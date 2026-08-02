import 'dart:io';

import 'package:esoteric_circle/core/maestro/consulto_del_cielo.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/components/consulto_del_cielo_view.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// L'attesa e' il Maestro che consulta il tuo cielo.
///
/// Le battute nascono da una funzione PURA, quindi la parte che conta si prova
/// senza montare uno schermo. Cio' che si monta e' solo il comportamento della
/// scena: che con Riduci Movimento non si muova, e che l'informazione resti.
void main() {
  group('Le battute nascono dai dati veri', () {
    test('Con una carta piena, tre battute dal piu\' personale al piu\' generale',
        () {
      const natal = NatalContext(
        sunSign: 'Cancro',
        moonSign: 'Pesci',
        ascendant: 'Vergine',
        moonPhase: 'Luna crescente',
      );
      final battute = ConsultoDelCielo.battutePer(natal);
      expect(battute.length, ConsultoDelCielo.massimoBattute,
          reason: 'mai piu\' di tre: oltre diventa un\'attesa allungata');
      expect(battute.map((b) => b.corpo), ['ascendente', 'luna', 'sole']);
      expect(battute.first.frase, 'il tuo Ascendente in Vergine');
      expect(battute.every((b) => b.eGenerale), isFalse);
    });

    test('Un dato che manca fa SALTARE la battuta, non la fa sostituire', () {
      // Senza ora di nascita non c'e' Ascendente: restano due battute vere, e
      // non tre di cui una inventata.
      const senzaAscendente = NatalContext(sunSign: 'Cancro', moonSign: 'Pesci');
      final battute = ConsultoDelCielo.battutePer(senzaAscendente);
      expect(battute.map((b) => b.corpo), ['luna', 'sole']);
      expect(battute.length, 2,
          reason: 'due battute vere valgono piu\' di tre con una inventata');
      // E nessuna frase nomina l'Ascendente.
      expect(battute.any((b) => b.frase.contains('Ascendente')), isFalse);
    });

    test('Senza carta natale consulta il solo Sole, e LO DICE', () {
      final battute = ConsultoDelCielo.battutePer(NatalContext.none);
      expect(battute.length, 1);
      expect(battute.single.corpo, 'sole');
      expect(battute.single.eGenerale, isTrue,
          reason: 'la battuta deve dichiarare di non essere di questa persona');
      expect(ConsultoDelCielo.eSoloGenerale(NatalContext.none), isTrue);
    });

    test('Con un solo segno, una sola battuta', () {
      const soloSole = NatalContext(sunSign: 'Cancro');
      final battute = ConsultoDelCielo.battutePer(soloSole);
      expect(battute.length, 1);
      expect(battute.single.frase, 'il tuo Sole in Cancro');
      expect(battute.single.eGenerale, isFalse);
    });
  });

  group('La scena a schermo', () {
    Widget _monta(
      NatalContext natal, {
      bool riduciMovimento = false,
      QualityTier qualita = QualityTier.high,
    }) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) => QualityTierController(initial: qualita)),
        ],
        child: MaterialApp(
          home: MaestroScope(
            maestro: Maestro.medora,
            child: Builder(
              builder: (ctx) => MediaQuery(
                data: MediaQuery.of(ctx)
                    .copyWith(disableAnimations: riduciMovimento),
                child: Scaffold(
                  body: ConsultoDelCieloView(
                    natal: natal,
                    durataBattuta: const Duration(milliseconds: 200),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    const piena = NatalContext(
      sunSign: 'Cancro',
      moonSign: 'Pesci',
      ascendant: 'Vergine',
    );

    testWidgets('Le battute si succedono', (tester) async {
      await tester.pumpWidget(_monta(piena));
      await tester.pump();
      expect(find.text('il tuo Ascendente in Vergine'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('la tua Luna in Pesci'), findsOneWidget);
      // Si ferma sull'ultima e non riparte: l'attesa non e' un carosello.
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('il tuo Sole in Cancro'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 900));
      expect(find.text('il tuo Sole in Cancro'), findsOneWidget);
    });

    testWidgets('Con Riduci Movimento non si muove, e l\'informazione resta',
        (tester) async {
      await tester.pumpWidget(_monta(piena, riduciMovimento: true));
      await tester.pump();
      final prima = find.text('il tuo Ascendente in Vergine');
      expect(prima, findsOneWidget);
      // Passa il tempo di due battute: non deve cambiare nulla.
      await tester.pump(const Duration(milliseconds: 900));
      expect(prima, findsOneWidget,
          reason: 'con Riduci Movimento la scena e\' ferma');
      expect(find.text('la tua Luna in Pesci'), findsNothing);
      // Ma la riga che dichiara cosa si sta consultando c\'e' comunque:
      // l'informazione non e' l'animazione.
      expect(find.text('Sto consultando'), findsOneWidget);
    });

    testWidgets('In qualita\' bassa la scena resta ferma', (tester) async {
      await tester.pumpWidget(_monta(piena, qualita: QualityTier.low));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 900));
      expect(find.text('il tuo Ascendente in Vergine'), findsOneWidget);
      expect(find.text('Sto consultando'), findsOneWidget);
    });

    testWidgets('La scena si toglie senza tagliare quando la risposta arriva',
        (tester) async {
      // La scena vive solo mentre si aspetta: chi la ospita la toglie, e
      // togliendola non deve restare nessun timer vivo, altrimenti la prova
      // successiva si appende. E' il modo in cui una dissolvenza si rompe.
      await tester.pumpWidget(_monta(piena));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      await tester.pump(const Duration(seconds: 2));
      expect(find.byKey(const Key('consulto_del_cielo')), findsNothing);
    });
  });

  group('La scena vive in tutte e due le superfici', () {
    test('Chat e Consulta la montano dallo stesso punto', () {
      // Enumerate, non visitate: se domani nascesse una terza superficie che
      // aspetta una risposta, questo elenco dice dove guardare.
      const superficiCheAspettano = {
        'lib/features/maestri/chat/maestro_chat_screen.dart':
            'la chat aspetta la risposta del Maestro',
        'lib/features/maestri/ask/ask_maestri_screen.dart':
            'il Consulta aspetta la lente di ogni Maestro',
      };
      for (final voce in superficiCheAspettano.entries) {
        final sorgente = File(voce.key).readAsStringSync();
        expect(sorgente.contains('ConsultoDelCieloView('), isTrue,
            reason: '${voce.key} non monta la scena del consulto. '
                '${voce.value}.');
      }
    });

    test('Nessuna superficie mostra piu\' uno spinner nudo', () {
      // Era l'unico punto della chat che sembrava un'app qualunque.
      //
      // I COMMENTI SI TOLGONO PRIMA DI MISURARE: la prima stesura di questa
      // prova era rossa per il commento che spiega la rimozione, cioe' contava
      // la documentazione come colpa. E' lo stesso inciampo gia' visto sulla
      // prova dei catch muti, e la correzione e' la stessa.
      final righe =
          File('lib/features/maestri/chat/maestro_chat_screen.dart')
              .readAsLinesSync()
              .where((r) => !r.trimLeft().startsWith('//'));
      final codice = righe.join('\n');
      expect(codice.contains('CircularProgressIndicator'), isFalse,
          reason: 'un indicatore di sistema non appartiene al Cerchio');
    });
  });
}
