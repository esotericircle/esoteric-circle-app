import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/rituals/rito_alba.dart';
import 'package:esoteric_circle/core/rituals/tempi_del_respiro.dart';
import 'package:esoteric_circle/design_system/components/guida_del_respiro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL RESPIRO SI GUIDA, NON SI LEGGE.
///
/// Il rito dichiara una cadenza, per esempio "sei tempi dentro e sei fuori, tre
/// volte", e fino a ieri quella cadenza viveva solo dentro una frase: la
/// persona contava a mente davanti a un simbolo fermo, e i numeri del corpus
/// venivano usati per comporre una coda in cifre e poi buttati.
void main() {
  group('I tempi, come numeri', () {
    const t = TempiDelRespiro(tempi: 6, giri: 3);

    test('la cadenza si traduce in durate', () {
      expect(t.fase, const Duration(seconds: 6));
      expect(t.giro, const Duration(seconds: 12));
      expect(t.intero, const Duration(seconds: 36));
    });

    test('si entra, si esce, e i giri si contano da uno', () {
      final inizio = t.momento(Duration.zero)!;
      expect(inizio.entra, isTrue);
      expect(inizio.giro, 1);

      final aMetaGiro = t.momento(const Duration(seconds: 6))!;
      expect(aMetaGiro.entra, isFalse, reason: 'a meta giro l aria esce');
      expect(aMetaGiro.giro, 1, reason: 'il giro cambia a giro finito, non a meta');

      final secondoGiro = t.momento(const Duration(seconds: 12))!;
      expect(secondoGiro.giro, 2);
      expect(secondoGiro.entra, isTrue);

      final ultimo = t.momento(const Duration(seconds: 35))!;
      expect(ultimo.giro, 3, reason: 'i giri sono tre, non quattro');
    });

    test('a respiro finito non c e piu un momento', () {
      expect(t.momento(const Duration(seconds: 36)), isNull,
          reason: 'il respiro continua a girare invece di finire, e chi guarda '
              'non sa piu quando fermarsi');
      expect(t.momento(const Duration(seconds: 40)), isNull);
    });

    test('la figura non sparisce mai del tutto', () {
      // Un simbolo che si azzera sparisce, e un rito in cui la figura sparisce
      // a ogni espirazione si legge come un guasto.
      for (var ms = 0; ms < t.intero.inMilliseconds; ms += 250) {
        final m = t.momento(Duration(milliseconds: ms))!;
        expect(m.misura, greaterThanOrEqualTo(0.55),
            reason: 'a $ms millisecondi la figura scende a ${m.misura}');
        expect(m.misura, lessThanOrEqualTo(1.0));
      }
      // E l'escursione c'e' davvero: fra il minimo e il massimo si vede.
      final minimo = t.momento(Duration.zero)!.misura;
      final massimo = t.momento(const Duration(seconds: 6) - const Duration(milliseconds: 1))!.misura;
      expect(massimo - minimo, greaterThan(0.3),
          reason: 'l escursione e di ${massimo - minimo}: il respiro non si '
              'vede nemmeno con la coda dell occhio');
    });

    test('una cadenza che non regge si dichiara invece di fingere', () {
      expect(const TempiDelRespiro(tempi: 0, giri: 3).reggono, isFalse);
      expect(const TempiDelRespiro(tempi: 6, giri: 0).reggono, isFalse);
      expect(const TempiDelRespiro(tempi: 0, giri: 0).momento(Duration.zero),
          isNull);
    });
  });

  group('I numeri arrivano fino allo schermo', () {
    test('ogni rito composto porta la sua cadenza, non solo la frase', () {
      // ENUMERA i tre Maestri per trenta giorni: il seme cambia forma e
      // variante, e una data sola proverebbe una cadenza su decine.
      var visti = 0;
      for (final m in Maestro.values) {
        for (var g = 1; g <= 30; g++) {
          final rito = RitoAlba.componi(
            DateTime(2026, 8, g),
            m,
            CieloDiStamattina(
              faseLunare: 'Luna piena',
              segnoLunare: Zodiac.leo,
              oraDellAlba: DateTime(2026, 8, g, 6, 12),
            ),
          );
          if (rito == null) continue;
          visti++;
          expect(rito.tempi, greaterThan(0),
              reason: 'il rito di ${m.id} del $g agosto dichiara una cadenza a '
                  'parole e porta ${rito.tempi} tempi: la guida non saprebbe '
                  'cosa fare');
          expect(rito.giri, greaterThan(0));
        }
      }
      expect(visti, greaterThan(50),
          reason: 'ho guardato solo $visti riti: la prova non copre abbastanza '
              'varianti per dire qualcosa');
    });
  });

  group('La guida a schermo', () {
    // ORDINE 2163 VOCE 11: il respiro parte col tocco e dopo il conto alla
    // rovescia, mai da solo. Il no-tocco e il conto hanno le loro prove in
    // il_respiro_parte_quando_decidi_tu_test.dart: qui si attraversano.
    Future<void> comincia(WidgetTester tester) async {
      await tester.tap(find.byKey(const Key('respiro_tocca')));
      await tester.pump();
      await tester.pump(ParoleDelRespiro.durataDelConto);
      await tester.pump(const Duration(milliseconds: 50));
    }

    Widget host({bool riduciMovimento = false}) => MaterialApp(
          home: Builder(
            builder: (ctx) => MediaQuery(
              data: MediaQuery.of(ctx)
                  .copyWith(disableAnimations: riduciMovimento),
              child: const Scaffold(
                body: Center(
                  child: GuidaDelRespiro(
                    tempi: TempiDelRespiro(tempi: 4, giri: 2),
                    colore: Color(0xFFD9B65C),
                  ),
                ),
              ),
            ),
          ),
        );

    testWidgets('il conteggio dice dove si e, e avanza', (tester) async {
      // **QUESTA PROVA E' STATA RISCRITTA, non allentata.** Il comportamento
      // che verificava non esiste piu': la riga diceva "Dentro / giro 1 di 2",
      // cioe' metteva sulla stessa riga il gesto e il conto. Per ordine di
      // Mauro del 6 agosto 2026 il gesto sta in una parola GRANDE al centro,
      // "Inspira" ed "Espira", e il giro resta sotto come riga di servizio.
      await tester.pumpWidget(host());
      await tester.pump();
      // ORDINE 2163 VOCE 11: il rito parte col tocco, poi il conto di quattro
      // secondi. Il vecchio timer automatico non esiste piu'.
      await comincia(tester);
      await tester.pump(const Duration(milliseconds: 300));

      String conteggio() => tester
          .widget<Text>(find.byKey(const Key('respiro_conteggio')))
          .data!;
      bool ceLaParola(String p) => find.text(p).evaluate().isNotEmpty;

      expect(conteggio(), ParoleDelRespiro.giro(1, 2));
      expect(ceLaParola(ParoleDelRespiro.inspira), isTrue);
      await tester.pump(const Duration(seconds: 4));
      expect(ceLaParola(ParoleDelRespiro.espira), isTrue);
      await tester.pump(const Duration(seconds: 4));
      expect(conteggio(), ParoleDelRespiro.giro(2, 2));
      await tester.pump(const Duration(seconds: 8));
      expect(ceLaParola(ParoleDelRespiro.compiuto), isTrue,
          reason: 'finito il respiro la guida continua a contare');
    });

    testWidgets('la figura si espande e si contrae davvero', (tester) async {
      await tester.pumpWidget(host());
      await tester.pump();

      // LA FIGURA SI LEGGE DALLA SUA CHIAVE, e la scala dal PRIMO ELEMENTO
      // della matrice.
      //
      // Due errori miei, uno dopo l altro, e valgono di piu della prova.
      // Prima leggevo il primo Transform che capitava, e l albero ne contiene
      // altri messi da Material. Poi, corretto quello, usavo
      // getMaxScaleOnAxis, che torna il MASSIMO fra i tre assi: la scala qui
      // vale 0,55 su x e y e resta 1 su z, quindi quella funzione rispondeva
      // 1 mentre la matrice diceva 0,55. Una misura che guarda la cosa
      // sbagliata e una misura che non c e sono lo stesso difetto.
      double scala() => tester
          .widget<Transform>(find.byKey(const Key('respiro_figura')))
          .transform
          .storage[0];

      // Il motore parte dopo il tocco e il conto: prima la figura sta ferma,
      // ed e' giusto, perche' il rito non e' ancora cominciato.
      await comincia(tester);
      await tester.pump(const Duration(milliseconds: 100));
      final inizio = scala();
      await tester.pump(const Duration(milliseconds: 3900));
      final culmine = scala();
      expect(culmine, greaterThan(inizio + 0.3),
          reason: 'la figura non si espande: da $inizio a $culmine');
      await tester.pump(const Duration(milliseconds: 3900));
      final fondo = scala();
      expect(fondo, lessThan(culmine - 0.3),
          reason: 'la figura non si contrae: da $culmine a $fondo');
      await tester.pump(const Duration(seconds: 10));
    });

    testWidgets('Riduci Movimento toglie il moto e NON lascia un vuoto',
        (tester) async {
      await tester.pumpWidget(host(riduciMovimento: true));
      await tester.pump();

      // LA FIGURA SI LEGGE DALLA SUA CHIAVE, e la scala dal PRIMO ELEMENTO
      // della matrice.
      //
      // Due errori miei, uno dopo l altro, e valgono di piu della prova.
      // Prima leggevo il primo Transform che capitava, e l albero ne contiene
      // altri messi da Material. Poi, corretto quello, usavo
      // getMaxScaleOnAxis, che torna il MASSIMO fra i tre assi: la scala qui
      // vale 0,55 su x e y e resta 1 su z, quindi quella funzione rispondeva
      // 1 mentre la matrice diceva 0,55. Una misura che guarda la cosa
      // sbagliata e una misura che non c e sono lo stesso difetto.
      double scala() => tester
          .widget<Transform>(find.byKey(const Key('respiro_figura')))
          .transform
          .storage[0];

      await comincia(tester);
      await tester.pump(const Duration(milliseconds: 100));
      expect(scala(), closeTo(1.0, 0.001));
      await tester.pump(const Duration(milliseconds: 3900));
      expect(scala(), closeTo(1.0, 0.001),
          reason: 'con Riduci Movimento la figura respira lo stesso');

      // E IL CONTEGGIO C'E' E AVANZA: e' l'unica cosa che resta al posto
      // dell'animazione, quindi non puo' dipendere dall'animazione.
      expect(find.text(ParoleDelRespiro.espira).evaluate(), isNotEmpty,
          reason: 'con Riduci Movimento la parola del gesto sparisce: resta '
              'un vuoto');
      expect(
          tester
              .widget<Text>(find.byKey(const Key('respiro_conteggio')))
              .data,
          ParoleDelRespiro.giro(1, 2));
      await tester.pump(const Duration(seconds: 10));
    });
  });
}
