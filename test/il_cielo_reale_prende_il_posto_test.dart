// IL CIELO REALE PRENDE IL POSTO DI QUELLO DI PRIMA. Richiesta del fondatore
// del 12 ottobre 2026: "nel menu utente c'e' la voce RealTime Cosmo che va
// eliminata, ma le 3 funzioni vanno sostituite a quelle esistenti": il cielo
// di adesso dalla luna della home, con un pulsante sottile "attiva macchina
// del tempo" che porta i selettori della data; il cielo della nascita nel
// Cosmic Passport; la macchina del tempo nell'onboarding, dove si rivela il
// cielo di nascita.
//
// Le anteprime vanno in docs/collaudo/FM/aggiunta_1/ solo con AGGIORNA_ANTEPRIME=1.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:esoteric_circle/core/astro/birth_place.dart' as astro;
import 'package:esoteric_circle/core/astro/sky_location.dart';
import 'package:esoteric_circle/features/real_time_cosmo/cielo_reale_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'le_anteprime_dell_ordine_fg_test.dart' as fg;
import 'le_anteprime_dell_ordine_fh_test.dart' as fh;

Future<void> monta(WidgetTester tester, Widget schermata) {
  tester.view.devicePixelRatio = 3.0;
  tester.view.physicalSize = const Size(1080, 2391);
  return fg.monta(tester, schermata);
}

Future<void> scatta(WidgetTester tester, String nome) async {
  if (!fg.scrivi) return;
  await tester.runAsync(() async {
    final rb =
        fg.radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final img = await rb.toImage(pixelRatio: 3.0);
    final dati = await img.toByteData(format: ui.ImageByteFormat.png);
    final dir = Directory('docs/collaudo/FM/aggiunta_1');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    File('${dir.path}/$nome.png').writeAsBytesSync(dati!.buffer.asUint8List());
    img.dispose();
  });
}

DateTime adesso() => DateTime.utc(2026, 10, 8, 20);

void main() {
  testWidgets(
      'il cielo di adesso ha il pulsante sottile, e al tocco compaiono i '
      'selettori della macchina del tempo', (tester) async {
    await monta(
        tester,
        const CieloRealeScreen(
          modo: ModoDelCielo.adesso,
          orologio: adesso,
          posizione: DisabledSkyLocation(),
        ));
    await fh.caricaEAlleggerisci(tester);
    await fg.passa(tester, 10);
    final pulsante = find.byKey(const Key('cielo_attiva_macchina_del_tempo'));
    expect(pulsante, findsOneWidget,
        reason: 'nel cielo di adesso manca il pulsante della macchina');
    expect(find.text('Attiva macchina del tempo'), findsOneWidget);
    expect(find.byKey(const Key('macchina_giorno_scelto')), findsNothing,
        reason: 'i selettori della data ci sono gia\' prima del pulsante: il '
            'cielo di adesso non e\' senza distrazioni');
    // Sottile: non piu' alto di un pulsante compatto.
    expect(tester.getSize(pulsante).height, lessThanOrEqualTo(44));
    await scatta(tester, 'a1_01_il_cielo_di_adesso');

    await tester.tap(pulsante);
    await fg.passa(tester, 10);
    expect(find.byKey(const Key('macchina_giorno_scelto')), findsOneWidget,
        reason: 'al tocco del pulsante non compaiono i selettori della data');
    expect(find.byKey(const Key('macchina_viaggia_dal_cielo')), findsOneWidget);
    expect(find.text('La macchina del tempo'), findsOneWidget);
    expect(pulsante, findsNothing);
    await scatta(tester, 'a1_02_la_macchina_accesa');

    await tester.tap(find.text('Scegli il giorno'));
    await fg.passa(tester, 8);
    expect(find.byKey(const Key('macchina_pannello')), findsOneWidget);
    await scatta(tester, 'a1_03_i_selettori_della_data');
  });

  testWidgets('la nascita e la macchina del tempo non hanno il pulsante',
      (tester) async {
    for (final modo in [ModoDelCielo.nascita, ModoDelCielo.ritorno]) {
      await monta(
          tester,
          CieloRealeScreen(
            key: ValueKey(modo),
            modo: modo,
            orologio: adesso,
            posizione: const DisabledSkyLocation(),
          ));
      await fh.caricaEAlleggerisci(tester);
      await fg.passa(tester, 6);
      expect(find.byKey(const Key('cielo_attiva_macchina_del_tempo')),
          findsNothing,
          reason: 'il pulsante della macchina compare nel modo ${modo.name}');
    }
  });

  testWidgets(
      'nell\'onboarding la macchina del tempo parte dalla nascita appena '
      'scritta, e porta il pulsante per proseguire', (tester) async {
    var proseguito = false;
    await monta(
        tester,
        CieloRealeScreen(
          modo: ModoDelCielo.ritorno,
          orologio: adesso,
          posizione: const DisabledSkyLocation(),
          nascita: BirthDetails(
            date: DateTime(1985, 3, 3),
            time: const TimeOfDay(hour: 7, minute: 20),
            place: const astro.BirthPlace(
              label: 'Busto Arsizio',
              latitude: 45.61,
              longitude: 8.85,
              timezone: 'Europe/Rome',
            ),
          ),
          etichettaDelSeguito: 'Leggi la tua carta',
          alSeguito: () => proseguito = true,
        ));
    await fh.caricaEAlleggerisci(tester);
    await fg.passa(tester, 10);
    final giorno = tester.widget<Text>(find.descendant(
        of: find.byKey(const Key('macchina_giorno_scelto')),
        matching: find.byType(Text)).first);
    expect(giorno.data, contains('1985'),
        reason: 'la macchina non parte dalla nascita appena scritta, ma dal '
            'profilo: ${giorno.data}');
    expect(find.text('Busto Arsizio'), findsNothing,
        reason: 'la riga del luogo si legge sotto, non come titolo');
    await scatta(tester, 'a1_04_l_onboarding_la_macchina_dalla_nascita');
    await tester.tap(find.byKey(const Key('sky_cta')));
    await tester.pump();
    expect(proseguito, isTrue,
        reason: '"Leggi la tua carta" non porta avanti l\'onboarding');
  });

  test('i quattro ingressi portano al cielo reale, e il menu non ha piu\' la '
      'voce', () {
    String leggi(String p) => File(p).readAsStringSync();
    final attesi = {
      'lib/features/santuario/santuario_screen.dart':
          'CieloRealeScreen.route(ModoDelCielo.adesso)',
      'lib/features/passport/cosmic_passport_screen.dart':
          'CieloRealeScreen.route(ModoDelCielo.nascita)',
      'lib/features/identity/widgets/identity_widgets.dart':
          'CieloRealeScreen.route(ModoDelCielo.nascita, nascita: details)',
      'lib/features/onboarding/risveglio_journey.dart':
          'modo: ModoDelCielo.ritorno,',
    };
    for (final e in attesi.entries) {
      expect(leggi(e.key), contains(e.value),
          reason: '${e.key} non apre il cielo reale (${e.value})');
    }
    expect(leggi('lib/features/account/account_screen.dart'),
        isNot(contains("id: 'real_time_cosmo'")),
        reason: 'la voce Real Time Cosmo e\' ancora nel menu utente');
    expect(File('lib/features/real_time_cosmo/real_time_cosmo_screen.dart')
            .existsSync(),
        isFalse,
        reason: 'il menu temporaneo del Real Time Cosmo esiste ancora');
  });
}
