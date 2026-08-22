import 'package:esoteric_circle/core/identity/account_del_cerchio.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/account/custodia_del_cielo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// LA PORTA SI RIAPRE ANCHE DOPO UN GUAIO. Ordine AX voce 01.
///
/// **L'ordine chiede di cercare uno stato appeso** che impedisca al tentativo
/// successivo di partire: un flag di "accesso in corso", un provider gia'
/// consumato, un Future mai chiuso. **Ne sono stati trovati due.**
///
/// Il primo, il piu' grave, e' il client di Google che restava con l'account
/// in mano, ed e' misurato in `test/chi_torna_riesce_a_entrare_test.dart`.
///
/// **Il secondo e' qui, e vive nella scheda.** `_inCorso` spegne tutti i
/// pulsanti mentre si aspetta la risposta, e veniva rimesso a nulla solo lungo
/// la via buona. Le porte dell'identita' catturano tutto, ma `rileggi()` sopra
/// di loro no: **una sola eccezione da li' lasciava la scheda bloccata per
/// sempre**, e la persona doveva chiudere e riaprire l'app. E' esattamente il
/// racconto del fondatore: "da quel momento non funziona piu' nemmeno la
/// registrazione".
///
/// **Non si conta un campo privato, si tocca il pulsante.** Un flag rimesso a
/// posto che lasciasse comunque il pulsante spento non sarebbe una cura.
void main() {
  Future<void> montaLaPorta(WidgetTester tester, AccountDelCerchio account,
      {required bool perChiTorna}) async {
    await tester.pumpWidget(ChangeNotifierProvider<AccountDelCerchio>.value(
      value: account,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        // Il Maestro avvolge TUTTO, foglio compreso: la scheda si apre come
        // route e legge la palette dal contesto, non da chi la chiama.
        builder: (ctx, child) =>
            MaestroScope(maestro: Maestro.medora, child: child!),
        home: Builder(
          builder: (ctx) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => perChiTorna
                    ? mostraLaPortaPerChiTorna(ctx)
                    : mostraInvitoACustodire(ctx, momenti: 3),
                child: const Text('apri'),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('apri'));
    await tester.pumpAndSettle();
  }

  /// **SI GUARDA IL PULSANTE VERO**, cioe' il `FilledButton` che porta la
  /// chiave: un pulsante spento ha `onPressed` nullo, e quello e' l'unico
  /// segno che la persona sente sotto il dito.
  bool pulsanteVivo(WidgetTester tester) {
    final pulsante = tester.widget<ButtonStyleButton>(
        find.byKey(const Key('custodia_google')));
    return pulsante.onPressed != null;
  }

  for (final perChiTorna in const [true, false]) {
    final chi = perChiTorna ? 'chi torna' : 'chi custodisce';
    testWidgets('dopo un guaio che LANCIA, $chi puo riprovare subito',
        (tester) async {
      final account = AccountDelCerchio(porta: _PortaCheEsplode());
      await montaLaPorta(tester, account, perChiTorna: perChiTorna);

      final primaDelTocco = pulsanteVivo(tester);
      await tester.tap(find.byKey(const Key('custodia_google')));
      await tester.pumpAndSettle();
      final dopoIlGuaio = pulsanteVivo(tester);
      // ignore: avoid_print
      print('ORDINE AX VOCE 01: per $chi il pulsante era vivo $primaDelTocco, '
          'dopo un guaio che lancia e vivo $dopoIlGuaio');

      expect(primaDelTocco, isTrue,
          reason: 'il pulsante era gia spento prima di toccarlo: la prova non '
              'sta misurando quello che crede');
      expect(dopoIlGuaio, isTrue,
          reason: 'dopo un guaio la via di Google resta spenta: la porta si e '
              'chiusa alle spalle, e per riaprirla bisogna chiudere l app');

      // **E LA PERSONA SA PERCHE'**: nessun ramo muto, terza garanzia.
      expect(find.text(frasePerEsito(EsitoDellaCustodia.nonRiuscita)!),
          findsOneWidget,
          reason: 'la scheda non dice niente: il guaio e muto');
    });
  }
}

/// Una porta che LANCIA invece di rispondere con un esito: e' il caso che il
/// `try` non copriva, cioe' un guaio che nasce sopra le porte dell'identita'.
class _PortaCheEsplode implements PortaDellIdentita {
  @override
  String? get uid => 'anonimo';

  @override
  bool get anonimo => true;

  @override
  String? get email => null;

  @override
  List<String> get fornitori => const [];

  @override
  IdentitaRiconosciuta? get riconosciuta => null;

  @override
  Future<String?> assicuraUnAccount() async => 'anonimo';

  @override
  Future<void> ricarica() async {}

  @override
  Future<EsitoDellaCustodia> eleva(ViaDellaCustodia via,
          {String? email, String? parola}) async =>
      throw StateError('il guaio che nessuno cattura');

  @override
  Future<EsitoDellaCustodia> entraDirettamente(ViaDellaCustodia via,
          {String? email, String? parola}) async =>
      throw StateError('il guaio che nessuno cattura');

  @override
  Future<EsitoDellaCustodia> entraComeRiconosciuto() async =>
      throw StateError('il guaio che nessuno cattura');

  @override
  Future<String?> nomeGiaProposto() async => null;
}
