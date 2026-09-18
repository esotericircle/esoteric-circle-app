// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/transizioni/velo_del_cerchio.dart';
import 'package:esoteric_circle/features/maestri/widgets/foglio_delle_fonti.dart';
import 'package:esoteric_circle/features/shell/barra_dell_identita.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'sorgenti_di_lib.dart';

/// **IL TESTO DEI FOGLI NON PASSA SOTTO LE BARRE IN ALTO.** Ordine DY voce 03.
///
/// Il fatto, dal fondatore con due catture Android: il titolo di *Fonti e
/// metodo* dentro la barra di stato, la prima riga sotto la barra
/// dell'identita'. La causa sta in un punto solo, la porta dei fogli
/// `foglioDelCerchio`, da cui passano tutti: un foglio che puo' crescere
/// saliva fino al bordo dello schermo.
///
/// **La scena riproduce il contratto della barra, non una misura inventata.**
/// La barra dell'identita' somma la sua altezza al `padding.top` di chi le sta
/// sotto e si disegna SOPRA il Navigator: qui si fa lo stesso, con la sua
/// altezza vera ([BarraDellIdentita.altezzaChiusa]) e una barra di stato da
/// 24 punti. Schermo piccolo e testo alla scala massima dell'app, perche'
/// e' li' che un testo lungo riempie il foglio fino in cima.
void main() {
  const barraDiStato = 24.0;
  const scala = 1.3;
  const inAlto = barraDiStato + BarraDellIdentita.altezzaChiusa;

  /// I testi dei pannelli informativi che passano da [FoglioDelleFonti], e un
  /// testo piu' lungo di tutti: il foglio deve reggere anche quello.
  final testi = <String, String>{
    'tarocchi': TestiDelleFonti.tarocchi,
    'sinastria': TestiDelleFonti.sinastria,
    'sigillo': TestiDelleFonti.sigillo,
    'oroscopo': TestiDelleFonti.oroscopo,
    'meditazione': TestiDelleFonti.meditazione,
    'cartaDiNascita': TestiDelleFonti.cartaDiNascita,
    'soffio': TestiDelleFonti.soffio,
  };
  final piuLungo = testi.values.reduce((a, b) => a.length >= b.length ? a : b);
  testi['il piu lungo per quattro'] = List.filled(4, piuLungo).join('\n\n');

  Future<void> apri(WidgetTester tester, String testo) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(360, 640);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      builder: (context, navigatore) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: const TextScaler.linear(scala),
            padding: mq.padding.copyWith(top: inAlto),
            viewPadding: mq.viewPadding.copyWith(top: inAlto),
          ),
          child: Stack(
            children: [
              navigatore!,
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: inAlto,
                child: ColoredBox(
                    key: Key('le_barre_in_alto'), color: Color(0xFF000000)),
              ),
            ],
          ),
        );
      },
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => FoglioDelleFonti.apri(context,
                  palette: MaestroPalette.medora,
                  testo: testo,
                  chiave: 'foglio_in_prova'),
              child: const Text('apri'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('apri'));
    await tester.pumpAndSettle();
  }

  test('i testi guardati sono quelli veri, e sono abbastanza lunghi', () {
    cardinaleMinimo(testi.length, 8,
        cosa: 'testi dei pannelli informativi',
        perche: 'Sette testi di TestiDelleFonti piu\' uno sintetico.');
  });

  for (final voce in testi.entries) {
    testWidgets('DY.03: ${voce.key}, il foglio comincia sotto le barre',
        (tester) async {
      await apri(tester, voce.value);
      final foglio = tester.getRect(find.byKey(const Key('foglio_in_prova')));
      final titolo = tester.getRect(find.text('Fonti e metodo'));
      print('DY.03 ${voce.key}: ${voce.value.length} caratteri, foglio da '
          '${foglio.top.toStringAsFixed(1)}, barre fino a $inAlto');
      expect(foglio.top, greaterThanOrEqualTo(inAlto - 0.5),
          reason: 'il foglio sale sotto le barre in alto: la sua parte alta '
              'non si legge, ed e\' il fatto delle due catture');
      expect(titolo.top, greaterThanOrEqualTo(inAlto),
          reason: 'il titolo del foglio sta sotto le barre');
    });
  }

  /// **IL CENSIMENTO DELLA VOCE DY.03**: ogni pannello informativo dell'app
  /// apre un foglio, e ogni foglio passa dalla porta che la voce ha curato.
  test('DY.03: ogni pannello informativo apre un foglio della porta comune',
      () {
    const cosaDicono = [
      "tooltip: 'Fonti e metodo'",
      "tooltip: 'Da dove nasce questo dono'",
      "tooltip: 'Dove sono in questo sentiero'",
    ];
    // **UN PANNELLO SOLO APRE IL SUO FOGLIO DA UN ALTRO FILE**, e si
    // dichiara qui per nome: il sentiero chiama la sua mappa.
    const indiretti = {
      'lib/features/sigilli/sentiero_screen.dart':
          'lib/features/sigilli/la_mappa_del_sentiero.dart',
    };
    final pannelli = <String>[];
    final fuori = <String>[];
    var perLaPortaComune = 0;
    for (final s in righeDiLib()) {
      final codice = senzaCommenti(s.righe.join('\n'));
      perLaPortaComune +=
          RegExp(r'FoglioDelleFonti\.bottone\(').allMatches(codice).length;
      if (!cosaDicono.any(codice.contains)) continue;
      final percorso = s.percorso.substring(s.percorso.indexOf('lib/'));
      pannelli.add(percorso);
      final dove = indiretti[percorso];
      final daGuardare =
          dove == null ? codice : senzaCommenti(File(dove).readAsStringSync());
      if (!daGuardare.contains('foglioDelCerchio') &&
          !daGuardare.contains('FoglioDelleFonti')) {
        fuori.add(percorso);
      }
    }
    print('DY.03: file con un pannello proprio ${pannelli.length}, '
        'chiamate del pannello comune $perLaPortaComune');
    cardinaleMinimo(pannelli.length, 9,
        cosa: 'file con un pannello informativo proprio');
    cardinaleMinimo(perLaPortaComune, 8,
        cosa: 'pannelli che passano da FoglioDelleFonti');
    expect(fuori, isEmpty,
        reason: 'un pannello informativo non apre un foglio della porta '
            'comune: la cura della voce DY.03 non lo raggiunge');

    final porta = File('lib/design_system/transizioni/velo_del_cerchio.dart')
        .readAsStringSync();
    expect(senzaCommenti(porta).contains('useSafeArea: true'), isTrue,
        reason: 'la porta dei fogli non rispetta piu\' le barre in alto');
  });

  test('la porta dei fogli resta l\'unica', () {
    // Senza questa, un foglio aperto col framework salterebbe la cura.
    final fuori = <String>[];
    for (final s in righeDiLib()) {
      if (s.percorso.endsWith('velo_del_cerchio.dart')) continue;
      if (senzaCommenti(s.righe.join('\n')).contains('showModalBottomSheet')) {
        fuori.add(s.percorso);
      }
    }
    expect(fuori, isEmpty);
    expect(foglioDelCerchio, isNotNull);
  });
}
