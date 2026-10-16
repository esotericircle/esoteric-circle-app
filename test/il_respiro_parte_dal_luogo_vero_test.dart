import 'dart:convert';

import 'package:esoteric_circle/core/astro/luogo_attuale.dart';
import 'package:esoteric_circle/core/astro/sky_location.dart';
import 'package:esoteric_circle/core/lunario/il_dial_a_moon.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/permissions/avviso_del_permesso.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/respiro_della_luna/il_respiro_della_luna_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **IL RESPIRO PARTE DAL LUOGO VERO.** Ordine FX aggiunta FXA.06, 16 ottobre
/// 2026. Il fondatore: "non servivano tutti i dati, ma i piu' importanti in
/// tempo reale basati sul luogo Reale (GPS)".
///
/// Il difetto di prima: il Respiro leggeva solo la citta' scelta a mano, e
/// senza un luogo salvato chiedeva la foto della NASA per latitudine 0. Qui
/// si guarda con quale latitudine parte ogni calcolo che dipende dal luogo
/// (la foto e il suo emisfero), con la posizione concessa e coi tre ripieghi.
class _PosizioneFinta extends SkyLocation {
  const _PosizioneFinta(this.risposta, {this.nome});

  final RispostaPosizione risposta;
  final String? nome;

  @override
  bool get available => true;

  @override
  Future<SkyPlace?> resolve() async => risposta.luogo;

  @override
  Future<RispostaPosizione> chiedi() async => risposta;

  @override
  Future<SkyPlace?> resolveSeConcesso() async => risposta.luogo;

  @override
  Future<String?> nomeDelLuogo(double latitudine, double longitudine) async =>
      nome;
}

/// Il Dial-A-Moon che registra la latitudine di ogni richiesta, senza rete.
class _DialCheRegistra extends IlDialAMoon {
  _DialCheRegistra();

  final List<double> latitudini = [];

  @override
  Future<FotoDellaLuna> perIstante(DateTime istante,
      {required double latitudine}) async {
    latitudini.add(latitudine);
    return IlDialAMoon.senzaLuogo(istante);
  }
}

void main() {
  Widget host(Widget s) => MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => MaestroController())],
        child: MaterialApp(home: MaestroScope(child: s)),
      );

  Future<String> monta(
      WidgetTester tester, SkyLocation posizione, _DialCheRegistra dial) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(host(IlRespiroDellaLunaScreen(
        now: DateTime(2026, 10, 16, 21),
        dialAMoon: dial,
        posizione: posizione)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    // La scena e' intera e la riga del luogo sta sopra i dati, sotto la
    // scena: si scorre fino a lei come una persona (ordine FY).
    final riga = find.byKey(const Key('respiro_riga_del_luogo'));
    await tester.scrollUntilVisible(riga, 200,
        scrollable: find.byType(Scrollable).first);
    expect(riga, findsOneWidget,
        reason: 'la schermata deve dire dove sono calcolati i dati');
    return tester.widget<Text>(riga).data!;
  }

  const negata = _PosizioneFinta(RispostaPosizione(EsitoPosizione.negata));

  testWidgets(
      'col GPS concesso i dati partono da li\', e la posizione si '
      'salva', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final dial = _DialCheRegistra();
    final riga = await monta(
        tester,
        const _PosizioneFinta(
            RispostaPosizione(EsitoPosizione.concessa,
                SkyPlace(latitude: 45.0526, longitude: 9.693)),
            nome: 'Piacenza'),
        dial);
    expect(riga, 'Calcolata a Piacenza, dalla posizione del telefono');
    expect(dial.latitudini, isNotEmpty);
    expect(dial.latitudini.every((l) => l == 45.0526), isTrue,
        reason: 'ogni calcolo parte dalla posizione vera: ${dial.latitudini}');
    final salvato = await DoveSonoAdesso.ultimoDelDispositivo();
    expect(salvato?.lat, 45.0526);
    expect(salvato?.origine, OrigineDelLuogo.dispositivo);
  });

  testWidgets('senza permesso: prima l\'ultima posizione del telefono',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'luogo.dispositivo': jsonEncode({
        'lat': 41.9028,
        'lon': 12.4964,
        'nome': 'Roma',
        'origine': 'dispositivo'
      }),
      'luogo.attuale': jsonEncode(
          {'lat': 45.4642, 'lon': 9.19, 'nome': 'Milano', 'origine': 'scelto'}),
    });
    final dial = _DialCheRegistra();
    final riga = await monta(tester, negata, dial);
    expect(riga, 'Calcolata a Roma, l\'ultima posizione del telefono');
    expect(dial.latitudini.every((l) => l == 41.9028), isTrue);
  });

  testWidgets(
      'senza permesso e senza posizioni del telefono: la città '
      'scelta a mano', (tester) async {
    SharedPreferences.setMockInitialValues({
      'luogo.attuale': jsonEncode(
          {'lat': 45.4642, 'lon': 9.19, 'nome': 'Milano', 'origine': 'scelto'}),
    });
    final dial = _DialCheRegistra();
    final riga = await monta(tester, negata, dial);
    expect(riga, 'Calcolata a Milano, la città che hai scelto');
    expect(dial.latitudini.every((l) => l == 45.4642), isTrue);
  });

  testWidgets(
      'senza nessun luogo: nessun calcolo, mai la latitudine 0, e '
      'l\'invito a dare la posizione', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final dial = _DialCheRegistra();
    final riga = await monta(tester, negata, dial);
    expect(riga, startsWith('Senza un luogo non si calcolano'));
    expect(dial.latitudini, isEmpty,
        reason: 'senza luogo un calcolo e\' partito lo stesso: '
            '${dial.latitudini}');
    expect(
        find.byWidgetPredicate((w) =>
            w is AvvisoDelPermesso &&
            w.chiave == 'respiro_della_luna_posizione'),
        findsOneWidget,
        reason: 'senza luogo serve l\'invito a dare la posizione');
  });
}
