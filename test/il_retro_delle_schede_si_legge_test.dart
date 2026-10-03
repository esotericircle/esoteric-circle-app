// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/arts/art_catalog.dart';
import 'package:esoteric_circle/core/arts/gli_sfondi_delle_schede.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/santuario/le_righe_della_casa.dart';
import 'package:esoteric_circle/features/schede/la_scheda_dell_arte.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// **IL TESTO DEL RETRO DELLE SCHEDE SI LEGGE.** Ordine ET voce 09, 28
/// settembre 2026.
///
/// Il fondatore: *"i testi nel rovescio delle schede sono minuscoli, quasi
/// illeggibili"*. Il retro metteva il testo in un `FittedBox` che lo
/// rimpiccioliva finche' entrava nella scheda: nei domini, a 184 e 288 punti,
/// restava alla sua misura; in home, a 128 e 137 punti (ordine ER voce 09),
/// scendeva di un terzo e oltre. Nessuna prova misurava il testo del retro.
///
/// Qui, per ogni arte della home e per ogni formato in cui compare, la scheda
/// si gira con la "i" come fa la persona, e si misura in punti veri la
/// didascalia del retro: la sua grandezza nel carattere per la scala a cui il
/// telefono la dipinge. Nei domini la stessa misura, alla larghezza dei
/// domini. La prova pretende che in home il testo sia alla misura dei
/// domini, cioe' che nessuna scheda lo rimpicciolisca.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final tutte = {for (final a in ArtCatalog.all) a.id: a};

  // Le coppie arte e formato della home: le righe, e l'Oroscopo nella riga
  // delle preferite.
  final coppie = <(String, FormatoDellaScheda)>{
    for (final r in LeRigheDellaCasa.righe)
      for (final id in r.arti) (id, r.formato),
    ('horoscope', LeRigheDellaCasa.formatoDellePreferite),
  }.where((c) => tutte.containsKey(c.$1)).toList();

  Widget conIlCerchio(Widget figlio) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          builder: (ctx, child) => MaestroScope(child: child!),
          home: Scaffold(backgroundColor: Colors.black, body: figlio),
        ),
      );

  double scalaX(RenderBox b) {
    final m = b.getTransformTo(null);
    final a = MatrixUtils.transformPoint(m, Offset.zero);
    final c = MatrixUtils.transformPoint(m, const Offset(100, 0));
    return (c - a).distance / 100;
  }

  /// **LE ARTI COL RETRO SOTTOLINEATO IN GIALLO.** Sul Realme, alla prima
  /// prova della ET.09, il retro grande della home aveva il testo sottolineato
  /// due volte in giallo: e' lo stile di ripiego di Flutter per il testo che
  /// non ha sopra di se' uno stile, perche' il retro grande sta nell'Overlay
  /// della radice, fuori dalla Material della schermata. Questa prova
  /// misurava la grandezza del testo e non il suo stile.
  final sottolineate = <String>{};

  /// La grandezza in punti della didascalia del retro, girata con la "i".
  Future<double> puntiDelRetro(WidgetTester tester, String id,
      FormatoDellaScheda formato, bool inCasa) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(conIlCerchio(
      Center(
        child: LaSchedaDellArte(
          key: ValueKey('$id$formato$inCasa'),
          art: tutte[id]!,
          maestro: Maestro.caligo,
          formato: formato,
          inCasa: inCasa,
          larghezza: LaSchedaDellArte.larghezzaPer(formato, inCasa: inCasa),
          onApri: (_) async {},
        ),
      ),
    ));
    await tester.pump();
    await tester.tap(find.byKey(Key('scheda_i_$id')));
    await tester.pumpAndSettle();
    final testo = find.byKey(Key('scheda_informazioni_$id'));
    expect(testo, findsOneWidget, reason: '$id: il retro non si vede');
    final stile = tester.widget<Text>(testo).style!;
    final paragrafo = tester.renderObject<RenderParagraph>(
        find.descendant(of: testo, matching: find.byType(RichText)));
    final decorazione = paragrafo.text.style?.decoration;
    if (decorazione != null && decorazione != TextDecoration.none) {
      sottolineate
          .add('$id ${formato.name} ${inCasa ? 'in home' : 'nei domini'}');
    }
    return stile.fontSize! * scalaX(paragrafo);
  }

  // **A 360 E A 402 PUNTI, ordine ES voce 26**: la voce ET.09 era misurata
  // solo alla larghezza del Realme, 360 punti; i telefoni grandi stanno a
  // 402. Stessa prova, due larghezze.
  for (final larghezza in const [360.0, 402.0]) {
    testWidgets(
        'ET.09: in home il testo del retro e\' alla misura dei domini, in ogni '
        'formato e per ogni arte, a ${larghezza.toStringAsFixed(0)} punti',
        (tester) async {
      tester.view.devicePixelRatio = 1080 / larghezza;
      tester.view.physicalSize = const Size(1080, 2400);
      addTearDown(tester.view.reset);

      final rimpicciolite = <String>{};
      final righe = <String>[];
      final perFormato = <FormatoDellaScheda, List<double>>{};
      double? neiDomini;
      for (final (id, formato) in coppie) {
        final casa = await puntiDelRetro(tester, id, formato, true);
        final dominio = await puntiDelRetro(tester, id, formato, false);
        neiDomini ??= dominio;
        perFormato.putIfAbsent(formato, () => []).add(casa);
        if (casa < dominio - 0.05) rimpicciolite.add(id);
        righe.add('${id.padRight(26)} ${formato.name.padRight(11)} in home '
            '${casa.toStringAsFixed(1)} punti, nei domini '
            '${dominio.toStringAsFixed(1)}');
      }
      final arti = coppie.map((c) => c.$1).toSet();
      String piccolo(List<double> v) =>
          (v.reduce((a, b) => a < b ? a : b)).toStringAsFixed(1);
      final sintesi = 'ORDINE ET VOCE 9, a ${larghezza.toStringAsFixed(0)} '
          'punti: arti della home ${arti.length}, coppie '
          'arte e formato ${coppie.length}; testo del retro nei domini '
          '${neiDomini!.toStringAsFixed(1)} punti; il piu\' piccolo in home: '
          '${perFormato.entries.map((e) => '${e.key.name} ${piccolo(e.value)}').join(', ')}; '
          'arti col testo del retro rimpicciolito in home '
          '${rimpicciolite.length} su ${arti.length}';
      print(sintesi);
      if (Platform.environment['SCRIVI_LA_PROVA'] == '1' && larghezza == 360) {
        File('docs/collaudo/ET/retro_delle_schede.txt')
          ..createSync(recursive: true)
          ..writeAsStringSync('$sintesi\n\n${righe.join('\n')}\n');
      }
      // Il cardinale: le arti della home sono 67 (ordine ER voci 08 e 20).
      expect(arti.length, greaterThanOrEqualTo(67),
          reason: 'la prova non ha trovato le arti della home');
      expect(rimpicciolite, isEmpty,
          reason: 'in home il testo del retro e\' piu\' piccolo che nei '
              'domini: ${rimpicciolite.take(6).join(', ')}');
      print('ORDINE ET VOCE 9: retri col testo sottolineato '
          '${sottolineate.length}');
      expect(sottolineate, isEmpty,
          reason: 'il testo del retro porta la sottolineatura di ripiego: '
              '${sottolineate.take(6).join(', ')}');
    });
  }
}
