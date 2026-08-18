import 'dart:io';

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/sigilli/celebrazione.dart';
import 'package:esoteric_circle/features/sigilli/direzione_della_festa.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'istante_dichiarato.dart';

/// OGNI MAESTRO HA LA SUA FESTA, E SI VEDE. Ordine AO voce 05.
///
/// **Il difetto, dal collaudo della 2182**: a Mauro arriva sempre la stessa
/// festa. La materia c'e' gia' e non e' in discussione, premessa P5:
/// `FesteDeiMaestri` porta stelle dal centro per Medora, rune dall'alto per
/// Caligo, polline dal basso per Aura, con conteggi diversi. Quello che non
/// funzionava era la SCELTA del Maestro.
///
/// **L'ipotesi dell'ordine, verificata prima di correggere**: la festa
/// prendeva il Maestro da `sentieri.first`, cioe' dal PRIMO traguardo
/// dell'elenco. E l'elenco non e' casuale: nasce scorrendo i traguardi
/// nell'ordine in cui sono dichiarati, dove i Sigilli di Medora vengono
/// prima. In una festa unita, che e' il caso normale e non l'eccezione, il
/// primo era quasi sempre di Medora, e la festa di Medora e' l'unica che si
/// vedeva.
///
/// **La regola nuova, dichiarata**: la festa porta il Maestro del traguardo
/// PIU' IMPORTANTE fra quelli celebrati, cioe' il grande se ce n'e' uno, e a
/// parita' il primo nominato. E' la stessa regola con cui la scena sceglie
/// gia' l'INTENSITA', e tenerne due diverse per due aspetti della stessa
/// scena sarebbe una contraddizione a schermo.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget attorno(Widget scena, DiarioDelCammino diario) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
        ],
        child: MaterialApp(
          builder: (ctx, child) => MaestroScope(child: child!),
          home: scena,
        ),
      );

  /// Quale festa e' a schermo: la chiave del pittore porta il Maestro.
  Maestro? festaDi(WidgetTester tester) {
    for (final maestro in Maestro.values) {
      if (find.byKey(Key('festa_${maestro.id}')).evaluate().isNotEmpty) {
        return maestro;
      }
    }
    return null;
  }

  Future<Maestro?> montaEGuarda(
    WidgetTester tester, {
    required List<Traguardo> traguardi,
    required List<Sentiero> sentieri,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final diario = DiarioDelCammino(orologio: orologioDelleProve);
    await diario.carica();
    await tester.pumpWidget(attorno(
      CelebrazioneAScermoPieno(traguardi: traguardi, sentieri: sentieri),
      diario,
    ));
    await tester.pump(const Duration(milliseconds: 600));
    return festaDi(tester);
  }

  for (final sentiero in Sentiero.values) {
    testWidgets('il sentiero ${sentiero.name} porta la festa del suo Maestro',
        (tester) async {
      final traguardo = Sentieri.di(sentiero).first;
      final quale = await montaEGuarda(tester,
          traguardi: [traguardo], sentieri: [sentiero]);
      // ignore: avoid_print
      print('ORDINE AO VOCE 05: ${sentiero.name} -> festa di '
          '${quale?.id}, materia '
          '${FesteDeiMaestri.di(sentiero.maestro).materia.name}');
      expect(quale, sentiero.maestro,
          reason: 'il sentiero ${sentiero.name} e\' di '
              '${sentiero.maestro.id} e la festa e\' di ${quale?.id}');
    });
  }

  testWidgets('LA MISURA DELL\'IPOTESI: nella festa unita non vince l\'ordine '
      'dell\'elenco, vince il piu\' importante', (tester) async {
    // Si mette per primo un mini di Medora e per secondo un GRANDE di
    // Caligo: se vincesse l'ordine dell'elenco, come faceva prima, si
    // vedrebbe la festa di Medora mentre a schermo si sta celebrando il
    // Sigillo grande di Caligo.
    final miniMedora = Sentieri.di(Sentiero.costellazione)
        .firstWhere((t) => !t.eGrande);
    final grandeCaligo = Sentieri.grandiDi(Sentiero.albero).first;
    final quale = await montaEGuarda(
      tester,
      traguardi: [miniMedora, grandeCaligo],
      sentieri: const [Sentiero.costellazione, Sentiero.albero],
    );
    // ignore: avoid_print
    print('ORDINE AO VOCE 05: festa unita mini-Medora piu\' grande-Caligo '
        '-> festa di ${quale?.id}');
    expect(quale, Sentiero.albero.maestro,
        reason: 'la festa e\' di ${quale?.id}: ha vinto il primo dell\'elenco '
            'invece del traguardo grande che si sta celebrando');
  });

  testWidgets('a parita\' di importanza vince il primo nominato',
      (tester) async {
    final primo = Sentieri.di(Sentiero.loto).firstWhere((t) => !t.eGrande);
    final secondo =
        Sentieri.di(Sentiero.costellazione).firstWhere((t) => !t.eGrande);
    final quale = await montaEGuarda(
      tester,
      traguardi: [primo, secondo],
      sentieri: const [Sentiero.loto, Sentiero.costellazione],
    );
    // ignore: avoid_print
    print('ORDINE AO VOCE 05: due mini, loto per primo -> festa di '
        '${quale?.id}');
    expect(quale, Sentiero.loto.maestro,
        reason: 'a parita\' di importanza doveva vincere il primo nominato');
  });

  test('le tre feste sono TRE, per materia, direzione e quantita\'', () {
    // **L'ENUMERAZIONE della materia, che e' cio' che si vede.** Se due
    // Maestri avessero la stessa terna, la festa dell'uno sarebbe la festa
    // dell'altro ricolorata, e Mauro avrebbe ragione anche a scelta curata.
    final terne = <String>{};
    for (final maestro in Maestro.values) {
      final festa = FesteDeiMaestri.di(maestro);
      final terna = '${festa.materia.name}/${festa.direzione.name}/'
          '${festa.quanteParticelle}';
      // ignore: avoid_print
      print('ORDINE AO VOCE 05: ${maestro.id} -> $terna');
      terne.add(terna);
    }
    expect(terne, hasLength(Maestro.values.length),
        reason: 'due Maestri hanno la stessa festa: $terne');
  });

  test('nessuno sceglie piu\' il Maestro dal primo dell\'elenco', () {
    // L'enumerazione sul sorgente: `sentieri.first.maestro` era la riga che
    // faceva vincere l'ordine di dichiarazione dei traguardi. Se ricompare,
    // il difetto e' tornato.
    final scena = File('lib/features/sigilli/celebrazione.dart')
        .readAsStringSync()
        .split('\n')
        .where((r) => !r.trimLeft().startsWith('//'))
        .join('\n');
    expect(scena.contains('sentieri.first.maestro'), isFalse,
        reason: 'la scena sceglie ancora il Maestro dal primo dell\'elenco');
  });
}
