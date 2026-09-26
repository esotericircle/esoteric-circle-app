// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/tokens/color_tokens.dart';
import 'package:esoteric_circle/features/maestri/live/la_scena_del_live.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LA SCENA DEL LIVE NON SALTA, E LA DOMANDA STA SOPRA LA RISPOSTA.**
/// Ordine EM voci 09 e 10, 25 settembre 2026.
///
/// Il fondatore: *"Quando faccio una domanda l'immagine del maestro
/// s'ingrandisce di botto e poi si riduce di botto quando inizia a
/// rispondere"*, e *"la domanda dovrebbe comparire in grande e in giallo
/// anche nel testo subito sopra la risposta"*. Si monta la stessa
/// composizione che usa la schermata, `LaScenaDelLive`, nei quattro momenti
/// di un turno, e si misura il volto.
void main() {
  const saluto = 'Eccomi. Il cielo di stasera ascolta con me: dimmi cosa ti '
      'porta qui.';
  const domanda = 'Medora, ho pescato la Torre e poi l\'Appeso. Cosa vogliono '
      'dire per me?';
  final risposta = List.filled(
          12, 'La Torre ti chiede di lasciar cadere cio\' che non regge piu\'.')
      .join(' ');

  Future<Size> volto(WidgetTester tester,
      {required String d,
      required String r,
      required String s,
      bool ascolta = false}) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      home: Scaffold(
        body: SafeArea(
          child: LaScenaDelLive(
            volto: const SizedBox.expand(
                key: Key('volto_di_prova'),
                child: ColoredBox(color: Colors.black)),
            domanda: d,
            risposta: r,
            stato: s,
            livello: ascolta ? const ColoredBox(color: Colors.amber) : null,
            tastiera: const SizedBox(height: 72),
          ),
        ),
      ),
    ));
    await tester.pump();
    return tester.getSize(find.byKey(const Key('volto_di_prova')));
  }

  testWidgets('IL VOLTO HA LA STESSA MISURA IN OGNI MOMENTO DEL TURNO',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final misure = <String, Size>{
      'il saluto': await volto(tester, d: '', r: saluto, s: ''),
      'si ascolta': await volto(tester,
          d: '',
          r: saluto,
          s: 'Ti ascolto. Prenditi il tempo che serve.',
          ascolta: true),
      'la domanda': await volto(tester, d: domanda, r: '', s: 'Sto pensando.'),
      'la risposta lunga': await volto(tester, d: domanda, r: risposta, s: ''),
    };
    print(
        'ORDINE EM VOCE 10: il volto ${misure.map((k, v) => MapEntry(k, '${v.width.round()}x${v.height.round()}'))}');
    expect(misure.values.toSet(), hasLength(1),
        reason: 'il volto cambia misura fra un momento e l\'altro: $misure');
  });

  testWidgets('LA DOMANDA STA SOPRA LA RISPOSTA, IN GRANDE E IN ORO',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await volto(tester, d: domanda, r: risposta, s: '');
    final d = tester.widget<Text>(find.byKey(const Key('live_domanda')));
    final r = tester.widget<Text>(find.byKey(const Key('live_sottotitolo')));
    expect(d.data, domanda);
    expect(r.data, risposta, reason: 'la risposta ha cancellato la domanda');
    expect(d.style?.color, ColorTokens.goldLight);
    expect(d.style!.fontSize!, greaterThan(r.style!.fontSize!),
        reason: 'la domanda non e\' piu\' grande della risposta');
    final sopra = tester.getRect(find.byKey(const Key('live_domanda')));
    final sotto = tester.getRect(find.byKey(const Key('live_sottotitolo')));
    expect(sopra.bottom <= sotto.top, isTrue,
        reason: 'la domanda non sta sopra la risposta');
  });

  test('LA SCHERMATA USA QUESTA SCENA, E IL TURNO TIENE LA DOMANDA', () {
    final schermata = File('lib/features/maestri/live/schermata_live.dart')
        .readAsStringSync();
    expect(schermata.contains('child: LaScenaDelLive('), isTrue,
        reason: 'la schermata non usa la scena misurata qui');
    expect(schermata.contains('domanda: _quadro.domanda'), isTrue);
    expect(
        schermata.contains(
            '_quadro = _quadro.con(domanda: testo, sottotitolo: \'\');'),
        isTrue,
        reason: 'la domanda non resta a video durante la risposta');
  });
}
