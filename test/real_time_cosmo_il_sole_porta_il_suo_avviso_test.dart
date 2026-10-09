// GUARDIA 15.8 DELL'ORDINE FH: IL SOLE PORTA IL SUO AVVISO.
//
// E' una regola di sicurezza, non di stile (voce 5.7): quando il bersaglio
// dell'indicatore e' il Sole e il Sole e' sopra l'orizzonte, la riga
// dell'indicatore dice di non guardarlo direttamente PRIMA di dire la
// direzione. La prova monta la schermata vera alle 10 UTC dell'8 ottobre
// 2026 (Sole alto su Napoli), sceglie il Sole dal menu a due livelli come lo
// sceglierebbe la persona, e cade se l'avviso manca o se non sta sopra il
// nome e la direzione.

import 'package:esoteric_circle/core/astro/sky_location.dart';
import 'package:esoteric_circle/features/real_time_cosmo/cielo_reale_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'le_anteprime_dell_ordine_fg_test.dart' as fg;

Future<void> scegliIlSole(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('real_time_cosmo_guida')));
  await fg.passa(tester, 6);
  await tester.tap(find.byKey(const Key('real_time_cosmo_categoria_lunaESole')));
  await fg.passa(tester, 4);
  await tester.tap(find.byKey(const Key('real_time_cosmo_bersaglio_sole')));
  await fg.passa(tester, 8);
}

void main() {
  testWidgets('col Sole alto, l\'indicatore lo dice prima della direzione',
      (tester) async {
    await fg.monta(
        tester,
        CieloRealeScreen(
          modo: ModoDelCielo.adesso,
          orologio: () => DateTime.utc(2026, 10, 8, 10),
          posizione: const DisabledSkyLocation(),
        ));
    await fg.carica(tester);
    await fg.passa(tester, 10);
    await scegliIlSole(tester);
    final avviso = find.byKey(const Key('real_time_cosmo_avviso_del_sole'));
    expect(avviso, findsOneWidget,
        reason: 'il Sole e\' sopra l\'orizzonte e l\'avviso non c\'e\'');
    expect((tester.widget(avviso) as Text).data, kAvvisoDelSole);
    final nome = find.byKey(const Key('real_time_cosmo_guida_nome'));
    expect(nome, findsOneWidget);
    expect(tester.getTopLeft(avviso).dy, lessThan(tester.getTopLeft(nome).dy),
        reason: 'l\'avviso deve venire prima della direzione');
  });
}
