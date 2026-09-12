import 'package:esoteric_circle/core/entitlement/budget_del_giorno.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/design_system/components/riga_del_residuo.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/design_system/tokens/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **I DUE CONTEGGI DELLA CHAT STANNO STRETTI.** Ordine DD voce 10,
/// 10 settembre 2026.
///
/// **Il fatto del fondatore**: le due righe di conteggio in cima alla chat
/// hanno troppa aria, fra loro e attorno, e quello spazio serve alla
/// conversazione. E' lo stesso principio dell'ordine CT: *"bisogna guadagnare
/// spazio al centro quindi ridurre al massimo le parti occupate sopra e
/// sotto"*.
///
/// **PERCHE' LA PROVA NON MONTA LA CHAT INTERA.** Ci ho provato, e la prova
/// sarebbe stata **verde senza misurare niente**: sotto le prove la borsa non
/// ha sentito il server, quindi `RigaDelResiduo` per legge tace e disegna una
/// `SizedBox.shrink()`. Le due chiavi ci sono, i due riquadri sono **alti
/// zero**, e qualunque pretesa sull'aria fra loro sarebbe passata. Qui la
/// borsa parla, le righe hanno il loro testo, e si misura l'aria vera.
///
/// **L'ANCORA E' UN NUMERO DICHIARATO, non una misura copiata dallo schermo.**
/// Il blocco dei due conteggi non deve essere piu' alto delle **due righe di
/// testo** che contiene piu' [ariaAmmessa] punti in tutto. Cosi' il giorno che
/// il carattere cambia misura la pretesa lo segue da sola, e nessuno puo'
/// allargare l'aria senza far cadere questa prova.
void main() {
  /// **QUANTA ARIA E' AMMESSA IN TUTTO IL BLOCCO**, dichiarata qui e non
  /// nascosta dentro un confronto. Sono quattro punti sopra e quattro sotto
  /// per ciascuna delle due righe: **sedici punti**. Prima erano otto sopra e
  /// otto sotto per ciascuna, cioe' trentadue.
  const ariaAmmessa = 16.0;

  Future<void> monta(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) =>
                MaestroController(initial: const ThemeKey.of(Maestro.medora))),
        ChangeNotifierProvider(
            create: (_) => EntitlementService(initial: Tier.free)),
        ChangeNotifierProvider(
            create: (_) => QuestionAllowance()..ilServerHaParlato()),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MaestroScope(child: child!),
        home: const Scaffold(
          // La stessa composizione della chat: le due righe una sopra
          // l'altra, dentro il margine orizzontale della schermata.
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RigaDelResiduo(
                    key: Key('chat_residuo_domande'),
                    budget: BudgetDelGiorno.domande),
                RigaDelResiduo(
                    key: Key('chat_residuo_approfondimenti'),
                    budget: BudgetDelGiorno.approfondimenti),
              ],
            ),
          ),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('IL BLOCCO DEI DUE CONTEGGI NON HA PIU ARIA DEL DOVUTO',
      (tester) async {
    await monta(tester);

    final domande = find.byKey(const Key('chat_residuo_domande'));
    final approfondimenti =
        find.byKey(const Key('chat_residuo_approfondimenti'));
    final r1 = tester.getRect(domande);
    final r2 = tester.getRect(approfondimenti);

    // **SE LE RIGHE SONO ALTE ZERO QUESTA PROVA NON MISURA NIENTE**, ed e'
    // esattamente cio' che succedeva montando la chat intera. Meglio cadere
    // dicendolo che passare tacendo.
    expect(r1.height, greaterThan(0),
        reason: 'la riga delle domande e alta zero: il conto non si vede '
            'affatto e questa prova non sta misurando nessuna aria');
    expect(r2.height, greaterThan(0),
        reason: 'la riga degli approfondimenti e alta zero');

    final testi = find.descendant(of: domande, matching: find.byType(Text));
    final unaRiga = tester.getRect(testi.first).height;
    final blocco = r2.bottom - r1.top;
    final aria = blocco - unaRiga * 2;
    // ignore: avoid_print
    print('ORDINE DD VOCE 10: una riga di testo e alta '
        '${unaRiga.toStringAsFixed(1)}, il blocco dei due conteggi e alto '
        '${blocco.toStringAsFixed(1)}, quindi l aria e '
        '${aria.toStringAsFixed(1)} punti su ${ariaAmmessa.toStringAsFixed(0)} '
        'ammessi');
    expect(aria, lessThanOrEqualTo(ariaAmmessa + 0.5),
        reason: 'i due conteggi portano ${aria.toStringAsFixed(1)} punti di '
            'aria attorno a ${(unaRiga * 2).toStringAsFixed(1)} punti di '
            'testo, contro i ${ariaAmmessa.toStringAsFixed(0)} ammessi: '
            'quello spazio serve alla conversazione');
  });

  testWidgets('REGOLA H: I DUE CONTEGGI RESTANO LEGGIBILI E DISTINTI',
      (tester) async {
    // **La meta che prova il contrario.** Stringere fino a zero farebbe
    // passare la prima meta e renderebbe le due righe una massa unica. Qui si
    // pretende che ci sia ancora dell aria fra loro e che nessuna delle due
    // si mangi il testo dell altra.
    await monta(tester);
    final r1 = tester.getRect(find.byKey(const Key('chat_residuo_domande')));
    final r2 =
        tester.getRect(find.byKey(const Key('chat_residuo_approfondimenti')));
    final t1 = tester.getRect(find.descendant(
        of: find.byKey(const Key('chat_residuo_domande')),
        matching: find.byType(Text)));
    final t2 = tester.getRect(find.descendant(
        of: find.byKey(const Key('chat_residuo_approfondimenti')),
        matching: find.byType(Text)));

    final respiro = t2.top - t1.bottom;
    // ignore: avoid_print
    print('ORDINE DD VOCE 10: fra il testo di una riga e quello dell altra '
        'restano ${respiro.toStringAsFixed(1)} punti');
    expect(respiro, greaterThanOrEqualTo(2.0),
        reason: 'fra i due conteggi restano ${respiro.toStringAsFixed(1)} '
            'punti: sono attaccati e si leggono come una riga sola');
    expect(r1.bottom, lessThanOrEqualTo(r2.top + 0.5),
        reason: 'i due riquadri dei conteggi si sovrappongono');
    expect(t1.height, greaterThan(0), reason: 'il primo conto non ha testo');
    expect(t2.height, greaterThan(0), reason: 'il secondo conto non ha testo');
  });
}
