import 'package:esoteric_circle/core/angels/angel_catalog.dart';
import 'package:esoteric_circle/core/angels/guardian_angels.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/onboarding/scheda_della_scelta.dart';
import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/core/rituals/guide_animal_derivation.dart';
import 'package:esoteric_circle/design_system/theme/accento_del_maestro.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/onboarding/riquadro_della_scelta.dart';
import 'package:esoteric_circle/features/onboarding/trionfi_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL RIQUADRO DELLA SCELTA, sotto l'animale guida e sotto i tre angeli.
/// Ordine 2163, voce 12.
///
/// Il contenuto nasce nel GENERATORE (core/onboarding/scheda_della_scelta),
/// non nella schermata: caratteristiche dai corpus con tradizione nominata,
/// ragione che nomina l'elemento della carta che ha eletto, filtro delle
/// promesse vietate nel generatore. La forma e' UN componente usato due volte.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.caligo));

  AngelTriad triade({int? minutoDelGiorno}) => AngelTriad(
        guardian: AngelCatalog.byNumber(3),
        heart: AngelCatalog.byNumber(31),
        intellect: minutoDelGiorno == null
            ? null
            : GuardianAngels.intellectFor(
                minutoDelGiorno ~/ 60, minutoDelGiorno % 60),
        sunLongitude: 134.6,
        dayOfYear: 219,
        minuteOfDay: minutoDelGiorno,
      );

  Widget attorno(Widget figlio) => MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(360, 797),
            disableAnimations: true,
          ),
          child: Scaffold(
            backgroundColor: const Color(0xFF05060A),
            body: figlio,
          ),
        ),
      );

  group('il contenuto viene dal generatore, col filtro', () {
    test(
        'nessuna scheda contiene una promessa vietata, sui dodici animali '
        'veri', () {
      for (final animale in AnimalCatalog.animals) {
        final scheda = GeneratoreDellaScheda.perAnimale(animale);
        expect(scheda.caratteristiche, isNotEmpty,
            reason: 'Per ${animale.name} il filtro ha svuotato la scheda: '
                'serve almeno una caratteristica ammessa.');
        for (final riga in scheda.caratteristiche) {
          expect(GeneratoreDellaScheda.ammessa(riga.testo), isTrue,
              reason: 'La scheda di ${animale.name} porta una promessa '
                  'vietata: "${riga.testo}"');
        }
      }
    });

    test(
        'IL ROSSO DEL FILTRO vive nel dato vero: il dono dell\'Orso '
        'parla di guarire, e il generatore lo scarta', () {
      // Non e' un rosso simulato: nel corpus il dono dell'Orso contiene
      // davvero "guarisce". Se il filtro morisse, questa riga entrerebbe
      // nella scheda e la prova cadrebbe. Eseguito col filtro spento a mano:
      // la scheda mostrava "Il suo dono" e questa expect cadeva.
      final orso = GuideAnimalDerivation.forSign(Zodiac.taurus);
      expect(orso.name, 'Orso');
      final scheda = GeneratoreDellaScheda.perAnimale(orso);
      expect(scheda.caratteristiche.map((r) => r.titolo),
          isNot(contains('Il suo dono')),
          reason: 'Il dono dell\'Orso promette guarigione e deve restare '
              'fuori dalla scheda.');
      for (final radice in GeneratoreDellaScheda.radiciVietate) {
        expect(GeneratoreDellaScheda.ammessa('una $radice promessa'), isFalse,
            reason: 'Il filtro non riconosce la radice "$radice".');
      }
    });

    test('la ragione degli angeli nomina solo i dati che ci sono', () {
      final conOra = GeneratoreDellaScheda.perAngeli(
          triade(minutoDelGiorno: 10 * 60 + 30));
      expect(conOra.ragione, contains('Intelletto'));
      expect(conOra.ragione, contains('10:30'));

      final senzaOra = GeneratoreDellaScheda.perAngeli(triade());
      expect(senzaOra.ragione, isNot(contains('Intelletto')),
          reason: 'Senza ora di nascita la ragione non deve aspettare '
              'l\'Intelletto: la parte sparisce.');
      expect(senzaOra.ragione, contains('gradi del tuo Sole'));
      expect(senzaOra.ragione, contains('giorno dell\'anno'));
    });

    test(
        'la ragione dell\'animale nomina il segno che lo elegge, e la '
        'chiave dichiara la curatela', () {
      final scheda = GeneratoreDellaScheda.perAnimale(
          GuideAnimalDerivation.forSign(Zodiac.leo));
      expect(scheda.ragione, contains('Sole in Leone'));
      expect(scheda.ragione, contains('Aquila'));
      expect(scheda.chiave.toLowerCase(), contains('curatela'),
          reason: 'Cio\' che scriviamo noi si dichiara chiave di lettura, '
              'non tradizione.');
    });
  });

  group('la riga che sparisce, senza segnaposto', () {
    testWidgets(
        'con la ragione nulla la riga non esiste, e non c\'e\' '
        'nessun segnaposto', (tester) async {
      const scheda = SchedaDellaScelta(
        caratteristiche: [RigaDellaScheda(titolo: 'Prova', testo: 'Un testo.')],
        ragione: null,
        chiave: 'Una chiave.',
      );
      await tester.pumpWidget(attorno(Center(
          child: RiquadroDellaScelta(scheda: scheda, palette: palette))));
      await tester.pump();
      expect(find.byKey(const Key('riquadro_scelta')), findsOneWidget);
      expect(find.byKey(const Key('riquadro_ragione')), findsNothing,
          reason: 'La riga della ragione deve SPARIRE, non svuotarsi.');
      for (final segnaposto in const ['—', 'N/D', 'n.d.', '...']) {
        expect(find.textContaining(segnaposto), findsNothing,
            reason: 'Al posto della ragione c\'e\' un segnaposto.');
      }
    });

    testWidgets('senza caratteristiche il riquadro intero non esiste',
        (tester) async {
      const scheda = SchedaDellaScelta(
          caratteristiche: [], ragione: 'Una ragione.', chiave: 'Chiave.');
      await tester.pumpWidget(attorno(Center(
          child: RiquadroDellaScelta(scheda: scheda, palette: palette))));
      await tester.pump();
      expect(find.byKey(const Key('riquadro_scelta')), findsNothing,
          reason: 'Un riquadro con la sola cornice e\' un segnaposto.');
    });
  });

  group('il riquadro sta nei due trionfi, e lo spazio vuoto ha una soglia', () {
    // LA SOGLIA DICHIARATA: fra il fondo del riquadro e la cima del pulsante
    // restano al piu' questi punti. ROSSO ESEGUITO DAVVERO: tolto il
    // riquadro dai due trionfi, tutte e due le prove cadono sul riquadro
    // assente. E la misura ha gia' morso in verde: la prima stesura del
    // generatore usava i campi interi del corpus e la colonna sbordava di
    // diciotto punti sotto l'animale e di otto sotto gli angeli, da cui la
    // regola della prima frase ammessa.
    const vuotoMassimo = 96.0;

    testWidgets('sotto l\'animale guida', (tester) async {
      tester.view.physicalSize = const Size(1080, 2391);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFF05060A),
          body: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: TrionfoAnimale(
              animale: GuideAnimalDerivation.forSign(Zodiac.taurus),
              palette: palette,
              reduceMotion: true,
              onContinue: () {},
            ),
          ),
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      final riquadro = find.byKey(const Key('riquadro_scelta'));
      expect(riquadro, findsOneWidget,
          reason: 'Sotto l\'animale guida il riquadro non c\'e\'.');
      final rRiquadro = tester.getRect(riquadro);
      final rBottone =
          tester.getRect(find.byKey(const Key('trionfo_animale_avanti')));
      final vuoto = rBottone.top - rRiquadro.bottom;
      // ignore: avoid_print
      print('TRIONFO ANIMALE: vuoto sotto il riquadro = '
          '${vuoto.toStringAsFixed(1)} punti (massimo $vuotoMassimo)');
      expect(vuoto, lessThanOrEqualTo(vuotoMassimo));
      expect(vuoto, greaterThanOrEqualTo(0),
          reason: 'Il riquadro finisce SOTTO il pulsante: si sovrappongono.');
    });

    testWidgets('sotto i tre angeli, con la stessa forma', (tester) async {
      tester.view.physicalSize = const Size(1080, 2391);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFF05060A),
          body: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: TrionfoAngeli(
              triade: triade(minutoDelGiorno: 10 * 60 + 30),
              palette: palette,
              reduceMotion: true,
              onContinue: () {},
            ),
          ),
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      final riquadro = find.byKey(const Key('riquadro_scelta'));
      expect(riquadro, findsOneWidget,
          reason: 'Sotto i tre angeli il riquadro non c\'e\'.');
      final rRiquadro = tester.getRect(riquadro);
      final rBottone =
          tester.getRect(find.byKey(const Key('trionfo_angeli_avanti')));
      final vuoto = rBottone.top - rRiquadro.bottom;
      // ignore: avoid_print
      print('TRIONFO ANGELI: vuoto sotto il riquadro = '
          '${vuoto.toStringAsFixed(1)} punti (massimo $vuotoMassimo)');
      expect(vuoto, lessThanOrEqualTo(vuotoMassimo));
      expect(vuoto, greaterThanOrEqualTo(0));

      // La ragione c'e' e si legge sul riquadro: il contrasto si misura
      // sulla superficie vera, composta come la compone il widget.
      expect(find.byKey(const Key('riquadro_ragione')), findsOneWidget);
    });

    test('la scritta della ragione si legge sulla superficie del riquadro', () {
      final superficie = Color.alphaBlend(
          palette.surfaceElevated.withValues(alpha: 0.5), palette.deepest);
      final contrasto =
          AccentoDelMaestro.contrastoFra(palette.goldSoft, superficie);
      expect(contrasto, greaterThanOrEqualTo(4.5),
          reason: 'La ragione si legge a ${contrasto.toStringAsFixed(2)} '
              'di contrasto: sotto il 4,5 che serve.');
    });
  });
}
