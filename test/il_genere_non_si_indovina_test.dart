import 'dart:io';

import 'package:esoteric_circle/core/cammino/cammino_da_custodire.dart';
import 'package:esoteric_circle/core/cammino/ritrovamento.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/onboarding/scena_del_ritrovamento.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL GENERE NON SI INDOVINA. Ordine CF voce 05.
///
/// **Il fatto del fondatore, verbatim**: "ho reinserito l'email gia'
/// registrata e dopo avermi dato il benvenuto (anzi, mi ha detto BENTORNATA
/// Mauro al femminile)".
///
/// **La causa, misurata e non dedotta.** `ProfileController` nasceva con un
/// profilo d'esempio che dichiarava `CourtesyForm.feminine`, e quel profilo
/// non e' solo quello della Demo: e' lo stato INIZIALE del controller in
/// tutta l'app, perche' `app.dart` lo costruisce senza argomenti e poi chiama
/// `load()`. Su un telefono appena reinstallato non c'e' niente da caricare,
/// quindi la forma restava femminile, e il riconoscimento rimetteva il nome
/// vero senza toccarla.
///
/// **Le due prove guardano due cose diverse, di proposito.** La prima e' il
/// caso vero del fondatore; la seconda ENUMERA le stringhe che dichiarano un
/// genere rivolgendosi alla persona e pretende che vivano solo dentro le
/// porte del genere, cosi' vale anche per quelle che nasceranno domani.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a chi rientra senza profilo il Cerchio non attribuisce un '
      'genere', (tester) async {
    SharedPreferences.setMockInitialValues(const {});
    // **IL PROFILO E' QUELLO VERO, appena costruito e mai caricato**, cioe'
    // esattamente lo stato di un telefono appena reinstallato. Passarne uno
    // finto qui vorrebbe dire provare un'altra cosa.
    final profilo = ProfileController();
    final ritrovamento = Ritrovamento.da(
      CamminoDaCustodire(
        identita: IdentitaDaCustodire(
          nome: 'Mauro',
          giorno: DateTime(1972, 5, 20),
          ora: '09:00',
          luogo: 'Roma',
        ),
        sigilli: const {},
      ),
      saldoEos: 250,
    );
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider<ProfileController>.value(value: profilo),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MaestroScope(child: child!),
        home: ScenaDelRitrovamento(
          ritrovamento: ritrovamento,
          onProsegui: () {},
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 600));

    final scritte = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
    final saluto = scritte.firstWhere(
        (s) => s.contains('Cerchio') && s.contains('Mauro'),
        orElse: () => scritte.isEmpty ? '' : scritte.first);
    // ignore: avoid_print
    print('ORDINE CF VOCE 05: a chi rientra senza profilo il saluto dice '
        '"$saluto"');
    for (final forma in const ['Bentornata', 'Bentornato']) {
      expect(saluto.contains(forma), isFalse,
          reason: 'il saluto dice "$saluto": il Cerchio ha attribuito un '
              'genere a una persona di cui non sa niente, e sul telefono del '
              'fondatore quel genere era sbagliato');
    }
    expect(saluto.contains('Mauro'), isTrue,
        reason: 'il nome custodito non arriva nel saluto: la prova sopra '
            'passerebbe anche con la scena vuota');
  });

  /// **LE PORTE DEL GENERE, dichiarate per nome.** Un file di questo elenco
  /// SCEGLIE la forma guardando la persona, quindi porta per costruzione
  /// tutte e due le declinazioni. Ogni altro file non ne porta nessuna.
  const porte = <String>{
    'lib/core/chat/user_profile.dart',
    'lib/core/identity/identity_controller.dart',
    'lib/features/onboarding/anteprima_tono.dart',
    'lib/features/onboarding/scena_del_ritrovamento.dart',
  };

  /// Le forme che DICHIARANO un genere rivolgendosi alla persona, a coppie.
  const coppie = <List<String>>[
    ['Benvenuto', 'Benvenuta'],
    ['Bentornato', 'Bentornata'],
  ];

  List<String> stringheDi(String sorgente) {
    final fuori = <String>[];
    for (final riga in sorgente.split('\n')) {
      if (riga.trimLeft().startsWith('//')) continue;
      for (final m in RegExp("'([^']{2,400})'").allMatches(riga)) {
        fuori.add(m.group(1)!);
      }
    }
    return fuori;
  }

  test('nessuna stringa dichiara un genere fuori dalle porte del genere', () {
    final colpe = <String>[];
    var quante = 0;
    for (final f in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final percorso = f.path.replaceAll(r'\', '/');
      final stringhe = stringheDi(f.readAsStringSync());
      for (final s in stringhe) {
        for (final coppia in coppie) {
          for (final forma in coppia) {
            if (!s.contains(forma)) continue;
            quante++;
            if (!porte.contains(percorso)) {
              colpe.add('$percorso: "$s"');
            }
          }
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE CF VOCE 05: stringhe che dichiarano un genere $quante, '
        'porte dichiarate ${porte.length}, fuori dalle porte ${colpe.length}');
    expect(colpe, isEmpty,
        reason: 'queste stringhe dichiarano un genere fuori dalle porte del '
            'genere, quindi lo affermano sempre e per tutti: $colpe. Falle '
            'passare da una porta, oppure scrivile in forma neutra');
  });

  test('ogni porta del genere porta ancora tutte e due le declinazioni', () {
    // **SENZA QUESTA PROVA la prima si potrebbe far passare cancellando meta'
    // di una coppia**, e allora il Cerchio smetterebbe di parlare a chi ha
    // scelto quella forma invece di indovinare.
    final colpe = <String>[];
    for (final percorso in porte) {
      final f = File(percorso);
      expect(f.existsSync(), isTrue,
          reason: 'la porta del genere $percorso non esiste piu\': '
              'l\'elenco qui sopra insegue un file che non c\'e\'');
      final stringhe = stringheDi(f.readAsStringSync()).join('\n');
      for (final coppia in coppie) {
        final presenti =
            coppia.where((forma) => stringhe.contains(forma)).toList();
        if (presenti.length == 1) {
          colpe.add('$percorso porta "${presenti.single}" e non l\'altra '
              'meta\' della coppia $coppia');
        }
      }
    }
    expect(colpe, isEmpty, reason: 'porte del genere a meta\': $colpe');
  });
}
