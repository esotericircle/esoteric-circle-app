// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/features/maestri/live/il_selettore_delle_voci.dart';
import 'package:esoteric_circle/services/live/porta_del_live.dart';
import 'package:esoteric_circle/services/voce/l_orecchio_del_live.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:record/record.dart';

/// **IL SELETTORE SCORRE, E DOPO IL MICROFONO RIPARTE.** Ordine EM voci 07 e
/// 08, 25 settembre 2026.
///
/// Il fondatore: *"Non posso scorrere le voci, lo scorrimento non funziona."*
/// e *"Quando torno indietro dal selettore, il microfono non funziona più."*
void main() {
  /// Le trentadue candidate di Calìgo come le da' il server dell'ordine EM:
  /// sedici voci di Gemini e le stesse sedici in Chirp 3 HD.
  const maschili = [
    'Puck',
    'Charon',
    'Fenrir',
    'Orus',
    'Enceladus',
    'Iapetus',
    'Umbriel',
    'Algieba',
    'Algenib',
    'Rasalgethi',
    'Alnilam',
    'Schedar',
    'Achird',
    'Zubenelgenubi',
    'Sadachbia',
    'Sadaltager',
  ];

  testWidgets(
      'L\'ELENCO DELLE VOCI SCORRE FINO ALL\'ULTIMA, E L\'ULTIMA SI '
      'SCEGLIE', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final chiamate = <String>[];
    final prima = PortaDelLive.chiama;
    addTearDown(() => PortaDelLive.chiama = prima);
    PortaDelLive.chiama = (porta, dati) async {
      chiamate.add('$porta ${dati['voce'] ?? ''}');
      if (porta == 'leVociDelMaestro') {
        return {
          'candidate': [
            for (final v in maschili)
              {'voce': v, 'nome': v, 'famiglia': 'Gemini', 'descrizione': 'x'},
            for (final v in maschili)
              {
                'voce': 'Chirp3-HD-$v',
                'nome': v,
                'famiglia': 'Chirp 3 HD',
                'descrizione': 'x',
              },
          ],
          'scelta': 'Algenib',
          'frase': 'Sono Calìgo. Le rune tacciono finché non parli tu.',
        };
      }
      return {'maestro': 'caligo', 'voce': dati['voce']};
    };
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: TextButton(
              key: const Key('apri'),
              onPressed: () =>
                  IlSelettoreDelleVoci.apri(context, Maestro.caligo),
              child: const Text('apri'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.byKey(const Key('apri')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('voce_Puck')), findsOneWidget);
    final ultima = find.byKey(const Key('scegli_Chirp3-HD-Sadaltager'));
    await tester.scrollUntilVisible(
      ultima,
      300,
      scrollable: find.descendant(
          of: find.byKey(const Key('voci_elenco')),
          matching: find.byType(Scrollable)),
    );
    await tester.pumpAndSettle();
    await tester.tap(ultima);
    await tester.pumpAndSettle();
    print('ORDINE EM VOCE 07: chiamate $chiamate');
    expect(chiamate, contains('scegliLaVoce Chirp3-HD-Sadaltager'),
        reason: 'l\'ultima voce dell\'elenco non si e\' potuta scegliere');
    // E la famiglia si legge sotto il nome.
    expect(find.textContaining('Chirp 3 HD'), findsWidgets);
  });

  test(
      'IL MICROFONO DEL LIVE NON SI FERMA QUANDO UN ALTRO SUONO PRENDE '
      'L\'AUDIO, e usa la sorgente delle chiamate', () {
    const c = LOrecchioDelLive.configurazione;
    expect(c.audioInterruption, AudioInterruptionMode.none,
        reason: 'col modo di serie il registratore si ferma alla prima '
            'anteprima delle voci, e non riparte piu\'');
    expect(c.androidConfig.audioSource, AndroidAudioSource.voiceCommunication);
    expect(c.noiseSuppress, isTrue);
    expect(c.echoCancel, isTrue);
    expect(c.sampleRate, LOrecchioDelLive.tasso);
    final orecchio =
        File('lib/services/voce/l_orecchio_del_live.dart').readAsStringSync();
    expect(orecchio.contains('startStream(configurazione)'), isTrue,
        reason: 'il microfono non si apre con la configurazione dichiarata');
  });

  test('IL SELETTORE CHIUDE IL MICROFONO E LO RIAPRE ALLA CHIUSURA', () {
    final schermata = File('lib/features/maestri/live/schermata_live.dart')
        .readAsStringSync();
    String corpoDi(String firma) {
      final inizio = schermata.indexOf(firma);
      expect(inizio, greaterThanOrEqualTo(0),
          reason: '$firma non c\'e\' piu\'');
      final fine = schermata.indexOf('\n  }\n', inizio);
      return schermata.substring(inizio, fine);
    }

    final apri = corpoDi('Future<void> _apriIlSelettore()');
    final ferma = apri.indexOf('_orecchio.ferma()');
    final selettore = apri.indexOf('IlSelettoreDelleVoci.apri(');
    final riprende = apri.indexOf('_ascoltaLaPersona()');
    expect(ferma >= 0 && ferma < selettore, isTrue,
        reason: 'il microfono resta aperto mentre suonano le anteprime');
    expect(riprende > selettore, isTrue,
        reason: 'chiuso il selettore, il microfono non riparte');
    expect(apri.substring(selettore, riprende).contains('finally'), isTrue,
        reason: 'se il selettore cade, il microfono resta spento');
    expect(schermata.contains('onPressed: () => unawaited(_apriIlSelettore())'),
        isTrue,
        reason: 'il pulsante del timbro non passa di qui');
    expect(
        corpoDi('Future<void> _ascoltaLaPersona()').contains('_nelSelettore'),
        isTrue,
        reason: 'col selettore aperto il microfono si riapre da solo');
    expect(corpoDi('void _batti()').contains('nelSelettore: _nelSelettore'),
        isTrue,
        reason: 'mentre si sceglie la voce il LIVE si chiude per '
            'silenzio');
  });
}
