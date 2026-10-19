import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/viaggio_dello_sciamano_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'la_soglia_si_guarda_prima_di_leggerla_test.dart'
    show DiarioDelloSciamanoDiProva;

/// **LE NOVE OMBRE STANNO TUTTE A SCHERMO, SENZA SCORRERE.** Ordine FZA
/// voce 01, 19 ottobre 2026.
///
/// **Le parole del fondatore, alla lettera**, 19 ottobre 2026, 20:03 e
/// 20:11: *"ma si che base vengono scelte? Non mi piace il fatto che siano
/// cmq riconoscibili e, quindi, pensavo di farli diventare 9 e l'utente può
/// sceglierne solo 1"*; *"Preferisco 9 ombre, anche se riconoscibili,
/// perché con lince, volpe e lupo cmq sarebbero simili e mettono più
/// curiosità."*
///
/// **L'ordine chiede esplicitamente**: le nove ombre stanno tutte nello
/// schermo senza scorrere, a ogni larghezza fra 320 e 430 punti, toccabili
/// una per una con un bersaglio di almeno 44 punti.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> apriLIncontro(WidgetTester tester, Size misura) async {
    tester.view.physicalSize = misura;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
      ],
      child: MaterialApp(
        home: MaestroScope(
          child: ViaggioDelloSciamanoScreen(
            userSign: Zodiac.cancer,
            now: DateTime(2026, 9, 12, 12),
            diario: DiarioDelloSciamanoDiProva(1),
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.ensureVisible(find.text('Una scelta da fare'));
    await tester.tap(find.text('Una scelta da fare'));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('viaggio_scendi')));
    await tester.tap(find.byKey(const Key('viaggio_scendi')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.tap(find.byKey(const Key('viaggio_salta_la_discesa')));
    await tester.pump(const Duration(seconds: 1));
    final nebbia = find.byKey(const Key('viaggio_nebbia'));
    for (var i = 0; i < 80 && nebbia.evaluate().isNotEmpty; i++) {
      await tester.drag(nebbia, const Offset(120, 40));
      await tester.pump(const Duration(milliseconds: 60));
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets(
      'nove ombre, non tre, tutte visibili insieme senza scorrere, con un '
      'bersaglio di almeno 44 punti ciascuna', (tester) async {
    await apriLIncontro(tester, const Size(390, 844));

    final griglia = find.byKey(const Key('viaggio_nove_ombre'));
    expect(griglia, findsOneWidget,
        reason: 'la griglia delle nove ombre non si trova');

    final sagome = find.byKey(const Key('viaggio_ombra_vera'));
    expect(sagome, findsNWidgets(9),
        reason: 'le ombre proposte devono essere nove, non tre');

    // **TUTTE DENTRO LO SCHERMO**: nessuna sagoma scorre fuori dai bordi
    // visibili, cosa che capiterebbe se la griglia non ci stesse tutta.
    final schermo = tester.view.physicalSize / tester.view.devicePixelRatio;
    for (var i = 0; i < 9; i++) {
      final rettangolo = tester.getRect(sagome.at(i));
      expect(rettangolo.top, greaterThanOrEqualTo(-1.0),
          reason: 'la sagoma $i esce dal bordo sopra dello schermo');
      expect(rettangolo.bottom, lessThanOrEqualTo(schermo.height + 1.0),
          reason: 'la sagoma $i esce dal bordo sotto dello schermo: la '
              'griglia scorre invece di starci tutta');
    }

    // **IL BERSAGLIO, non la sagoma**: ogni ombra si tocca su una zona di
    // almeno 44 punti, misurata sul `GestureDetector` che la porta, non
    // sull'immagine che puo' essere piu' piccola dentro il suo riquadro.
    final bersagli = find.byWidgetPredicate(
        (w) => w is GestureDetector && w.onTap != null && w.key is ValueKey);
    final bersagliDelleOmbre = tester
        .widgetList<GestureDetector>(bersagli)
        .where((w) =>
            (w.key as ValueKey).value.toString().startsWith('viaggio_ombra_'))
        .toList();
    expect(bersagliDelleOmbre, hasLength(9));
    for (final b in bersagliDelleOmbre) {
      final rettangolo = tester.getRect(find.byKey(b.key!));
      expect(rettangolo.width, greaterThanOrEqualTo(44.0),
          reason: 'il bersaglio di ${b.key} e\' largo ${rettangolo.width}, '
              'sotto i 44 punti minimi');
      expect(rettangolo.height, greaterThanOrEqualTo(44.0),
          reason: 'il bersaglio di ${b.key} e\' alto ${rettangolo.height}, '
              'sotto i 44 punti minimi');
    }
  });

  for (final larghezza in [320.0, 375.0, 430.0]) {
    testWidgets(
        'a $larghezza punti di larghezza le nove ombre restano tutte '
        'visibili senza scorrere', (tester) async {
      await apriLIncontro(tester, Size(larghezza, 844));
      final sagome = find.byKey(const Key('viaggio_ombra_vera'));
      expect(sagome, findsNWidgets(9),
          reason: 'a $larghezza punti le ombre non sono nove');
      final schermo = tester.view.physicalSize / tester.view.devicePixelRatio;
      for (var i = 0; i < 9; i++) {
        final rettangolo = tester.getRect(sagome.at(i));
        expect(rettangolo.bottom, lessThanOrEqualTo(schermo.height + 1.0),
            reason: 'a $larghezza punti la sagoma $i esce dal bordo sotto');
      }
    });
  }
}
