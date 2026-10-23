import 'dart:io';

import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:esoteric_circle/core/astro/sky_location.dart';
import 'package:esoteric_circle/core/astro/birth_place.dart';
import 'package:esoteric_circle/features/real_time_cosmo/alza_il_telefono_al_cielo.dart';
import 'package:esoteric_circle/features/real_time_cosmo/cielo_reale_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'le_anteprime_dell_ordine_fg_test.dart' as fg;
import 'sorgenti_di_lib.dart';

/// **"ALZA IL TELEFONO AL CIELO", TRE SECONDI E POI IN DISSOLVENZA.** Ordine
/// GD voce GD.25, 23 ottobre 2026. Il fondatore: *"quando si accede al cielo
/// in tempo reale deve comparire una scritta che scompare dopo 3 secondi in
/// disoolvenza «Alza il telefono al Cielo», questo anche nell'onboarding"*.
///
/// La misura e' l'opacita' della scritta a mezzo secondo, a due secondi, a
/// tre secondi e mezzo e a quattro secondi dall'ingresso, nelle due
/// schermate: il cielo di adesso e il cielo dell'onboarding (la stessa
/// `CieloRealeScreen` che `RisveglioJourney` monta nella fase `heaven`, con
/// la nascita appena scritta). Piena a 0,5 e a 2 secondi, intermedia a 3,5
/// (la dissolvenza c'e'), sparita a 4.

const String _testo = 'Alza il telefono al Cielo';

/// La nascita dell'onboarding, come la passa `RisveglioJourney`.
final BirthDetails _nascita = BirthDetails(
  date: DateTime(1988, 5, 14),
  time: const TimeOfDay(hour: 8, minute: 40),
  place: const BirthPlace(
    label: 'Napoli',
    province: 'NA',
    latitude: 40.85,
    longitude: 14.27,
    timezone: 'Europe/Rome',
  ),
);

double? _opacita(WidgetTester tester) {
  final f = find.byKey(const Key('alza_il_telefono_al_cielo'));
  if (f.evaluate().isEmpty) return null;
  return tester.widget<Opacity>(f).opacity;
}

/// Monta [schermata] e misura la scritta ai quattro istanti dall'ingresso.
Future<Map<String, double?>> _misura(
    WidgetTester tester, Widget schermata) async {
  await fg.monta(tester, schermata);
  // Il fotogramma dell'ingresso: da qui parte il tempo della scritta.
  await tester.pump();
  final misure = <String, double?>{};
  await tester.pump(const Duration(milliseconds: 500));
  misure['0,5 s'] = _opacita(tester);
  expect(find.text(_testo), findsOneWidget,
      reason: 'a mezzo secondo la scritta non c\'e\'');
  await tester.pump(const Duration(milliseconds: 1500));
  misure['2 s'] = _opacita(tester);
  await tester.pump(const Duration(milliseconds: 1500));
  misure['3,5 s'] = _opacita(tester);
  await tester.pump(const Duration(milliseconds: 500));
  misure['4 s'] = _opacita(tester) ?? 0;
  // ignore: avoid_print
  print('GD.25, la misura: $misure');
  return misure;
}

void _pretendi(Map<String, double?> m, String dove) {
  expect(m['0,5 s'], 1.0, reason: '$dove: a mezzo secondo non e\' piena: $m');
  expect(m['2 s'], 1.0, reason: '$dove: a due secondi non e\' piena: $m');
  expect(m['3,5 s'], allOf(greaterThan(0.05), lessThan(0.95)),
      reason: '$dove: fra tre e quattro secondi non c\'e\' dissolvenza: $m');
  expect(m['4 s'], 0.0, reason: '$dove: a quattro secondi c\'e\' ancora: $m');
}

void main() {
  testWidgets('nel cielo in tempo reale: piena tre secondi, poi sfuma',
      (tester) async {
    final m = await _misura(
        tester,
        CieloRealeScreen(
          modo: ModoDelCielo.adesso,
          orologio: () => fg.adesso,
          posizione: const DisabledSkyLocation(),
        ));
    _pretendi(m, 'cielo in tempo reale');
    // Un fotogramma dopo la fine della dissolvenza la scritta esce
    // dall'albero: non resta un testo invisibile sopra il cielo.
    await tester.pump(const Duration(milliseconds: 16));
    expect(find.text(_testo), findsNothing);
  });

  testWidgets('nel cielo dell\'onboarding: piena tre secondi, poi sfuma',
      (tester) async {
    final m = await _misura(
        tester,
        CieloRealeScreen(
          modo: ModoDelCielo.ritorno,
          nascita: _nascita,
          etichettaDelSeguito: 'Leggi la tua carta',
          alSeguito: () {},
          orologio: () => fg.adesso,
          posizione: const DisabledSkyLocation(),
        ));
    _pretendi(m, 'onboarding');
  });

  testWidgets(
      'nel cielo di nascita, che parte col dito, la scritta non compare',
      (tester) async {
    await fg.monta(
        tester,
        CieloRealeScreen(
          modo: ModoDelCielo.nascita,
          orologio: () => fg.adesso,
          posizione: const DisabledSkyLocation(),
        ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text(_testo), findsNothing);
  });

  test(
      'un punto solo: la scritta vive in un file, la monta il cielo, e '
      'l\'onboarding passa dal cielo', () {
    final dove = <String>[];
    var guardati = 0;
    for (final f in sorgentiDiLib()) {
      guardati++;
      if (f.readAsStringSync().contains("'$_testo'")) {
        dove.add(f.path.replaceAll(Platform.pathSeparator, '/'));
      }
    }
    cardinaleMinimo(guardati, 100,
        cosa: 'sorgenti di lib',
        perche: 'Senza sorgenti la ricerca del testo non trova doppioni '
            'perche\' non ha guardato niente.');
    expect(
        dove, ['lib/features/real_time_cosmo/alza_il_telefono_al_cielo.dart'],
        reason: 'la scritta e\' scritta in piu\' punti: $dove');
    expect(AlzaIlTelefonoAlCielo.testo, _testo);

    final cielo = File('lib/features/real_time_cosmo/cielo_reale_screen.dart')
        .readAsStringSync();
    expect(cielo.contains('const AlzaIlTelefonoAlCielo()'), isTrue,
        reason: 'il cielo in tempo reale non monta la scritta');
    final onboarding = File('lib/features/onboarding/risveglio_journey.dart')
        .readAsStringSync();
    final heaven = onboarding.substring(
        onboarding.indexOf('case _Phase.heaven:'),
        onboarding.indexOf('case _Phase.chart:'));
    expect(heaven.contains('CieloRealeScreen('), isTrue,
        reason: 'il passaggio dell\'onboarding non mostra piu\' il cielo con '
            'CieloRealeScreen: la scritta non lo raggiunge');
    expect(heaven.contains('nascita: widget.details'), isTrue,
        reason: 'il cielo dell\'onboarding non riceve la nascita: la scritta '
            'compare solo quando la nascita arriva da fuori');
  });
}
