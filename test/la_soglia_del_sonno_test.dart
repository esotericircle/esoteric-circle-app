// ignore_for_file: avoid_print
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:esoteric_circle/core/arts/art_catalog.dart';
import 'package:esoteric_circle/core/arts/gli_sfondi_delle_schede.dart';
import 'package:esoteric_circle/core/arts/l_ordine_dei_domini.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/art_navigation.dart';
import 'package:esoteric_circle/features/santuario/le_righe_della_casa.dart';
import 'package:esoteric_circle/features/schede/la_scheda_dell_arte.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// **LA SOGLIA DEL SONNO.** Ordine FF aggiunta 1, voci A5-A10, 8 ottobre
/// 2026. Il fondatore: *"serve mini ordine aggiuntivo per code per
/// aggiungerlo alla home e al dominio di Aura"*, *"può essere inserita nelle
/// funzionalità di fase 3"*. Solo la scheda e il suo posto: e' un'arte in
/// arrivo come le altre (la clessidra dorata, al tocco si gira e dice la
/// fase, nessuna pagina si apre).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const id = 'soglia_del_sonno';

  /// I tre webp del fondatore, sha256 contati l'8 ottobre 2026 sulla
  /// cartella principale e sulla copia nel ramo, uguali al byte.
  const sha256DelFondatore = {
    'Vert': '928c6b4bb5ff52d0fc1105df8dcd174762c18679d79774913a7274247a579964',
    'Square':
        '4d13375103b1e9ac602bc0b5c80838fe0c81bd490870251fb8b1dc394cce3066',
    'Oriz': 'e051404458c30f8ac63eac390320acaa0762217549ca4a875569b73391fd9913',
  };

  ArtEntry soglia() => ArtCatalog.all.firstWhere((a) => a.id == id);

  test('FF.A10 f) il nome scritto e\' esattamente La Soglia del Sonno', () {
    expect(soglia().title, 'La Soglia del Sonno');
    expect(soglia().teaser, contains('yoga nidra'));
  });

  test('FF.A10 a) la scheda e\' in home, nella riga La tua serenità', () {
    final riga =
        LeRigheDellaCasa.righe.firstWhere((r) => r.chiave == 'la_tua_serenita');
    expect(riga.titolo, 'La tua serenità');
    expect(riga.arti, contains(id));
    expect(LeRigheDellaCasa.artiDi(riga.arti).map((a) => a.id), contains(id),
        reason: 'nella riga ma non visibile');
  });

  test('FF.A10 b) la scheda e\' nel dominio di Aura, nella sezione Energia',
      () {
    final energia = LOrdineDeiDomini.di(Maestro.aura)
        .firstWhere((s) => s.titolo == 'Energia');
    expect(energia.arti, contains(id));
    expect(LOrdineDeiDomini.artiDi(energia).map((a) => a.id), contains(id));
    expect(
        ArtCatalog.forMaestro(Maestro.aura)
            .expand((s) => s.arts)
            .map((a) => a.id),
        contains(id));
    // Non finisce nella riga "In arrivo" di chi non ha una sezione.
    expect(LOrdineDeiDomini.inArrivo(Maestro.aura).map((a) => a.id),
        isNot(contains(id)));
  });

  test('FF.A10 e) i tre sfondi esistono, sono del fondatore e dell\'arte', () {
    var uguali = 0;
    for (final f in FormatoDellaScheda.values) {
      final percorso = GliSfondiDelleSchede.perArte(id, f);
      expect(percorso, 'assets/schede/Soglia-Sonno-${f.nelNome}-1.webp');
      final sha = sha256.convert(File(percorso!).readAsBytesSync()).toString();
      if (sha == sha256DelFondatore[f.nelNome]) uguali++;
    }
    print('ORDINE FF AGGIUNTA 1: sfondi della Soglia uguali a quelli del '
        'fondatore $uguali su 3');
    expect(uguali, 3);
  });

  testWidgets(
      'FF.A10 c) e d) la scheda e\' in arrivo, porta la clessidra, al tocco '
      'non apre niente', (tester) async {
    expect(soglia().state, ArtState.inArrivo);
    expect(soglia().phase, ArtPhase.fase3);
    expect(artRouteFor(id), isNull, reason: 'una rotta aprirebbe una pagina');
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1170, 2532);
    addTearDown(tester.view.reset);
    final aperte = <String>[];
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (ctx, child) => MaestroScope(child: child!),
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: LaSchedaDellArte(
              art: soglia(),
              maestro: Maestro.aura,
              formato: FormatoDellaScheda.verticale,
              larghezza:
                  LaSchedaDellArte.larghezzaPer(FormatoDellaScheda.verticale),
              onApri: (_) async => aperte.add(id),
            ),
          ),
        ),
      ),
    ));
    await tester.pump();
    expect(find.byKey(const Key('scheda_clessidra_$id')), findsOneWidget);
    await tester.tap(find.byKey(const Key('scheda_tocco_$id')));
    await tester.pumpAndSettle();
    expect(aperte, isEmpty, reason: 'si e\' aperta una pagina');
    expect(tester.widget<Text>(find.byKey(const Key('scheda_fase_$id'))).data,
        'In arrivo, Fase 3');
  });
}
