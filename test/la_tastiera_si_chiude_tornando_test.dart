// ignore_for_file: avoid_print
import 'package:esoteric_circle/design_system/la_tastiera_si_chiude.dart';
import 'package:esoteric_circle/features/shell/barra_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LA TASTIERA SI CHIUDE TORNANDO.** Ordine EV voce 05, il fondatore: *"A
/// un certo punto, iPhone si è bloccato in home con la testiera aperta e ha
/// dovuto riavviare."*
///
/// Si monta una pila come quella dell'app, con l'osservatore della pila
/// dell'app, e si torna alla prima schermata (la home, senza campi) da tre
/// forme di schermata con un campo a fuoco: una rotta col campo (la chat, il
/// Sigillo), una rotta sopra un'altra rotta col campo, sfilate insieme come
/// fa la barra in basso, e un foglio col campo. Dopo ogni ritorno si guarda
/// l'ultima parola mandata al sistema della tastiera: deve essere
/// "nascondi", e nessun campo deve avere il fuoco.
void main() {
  final colpe = <String>[];
  var ritorni = 0;

  Future<void> monta(WidgetTester tester, GlobalKey<NavigatorState> nav,
      List<String> parole) async {
    tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.textInput, (chiamata) async {
      parole.add(chiamata.method);
      return null;
    });
    await tester.pumpWidget(MaterialApp(
      navigatorKey: nav,
      navigatorObservers: [OsservatoreDellaPila()],
      home: const Scaffold(body: Center(child: Text('home'))),
    ));
  }

  Route<void> conIlCampo() => MaterialPageRoute<void>(
      builder: (_) => const Scaffold(
          body: Center(child: TextField(key: Key('campo'), autofocus: true))));

  Future<void> misura(WidgetTester tester, String nome, List<String> parole,
      {required int chiusurePrima}) async {
    await tester.pumpAndSettle();
    ritorni++;
    // **LA GRANDEZZA CHE CONTA E' LA PAROLA DELL'APP.** Nella prova, come sul
    // Realme, Flutter chiude da se' la tastiera in tutti e tre i ritorni: la
    // prima stesura di questa guardia, che guardava solo l'ultima parola, era
    // verde anche sul codice di prima (Regola A, docs/collaudo/EV). Il blocco
    // del fondatore e' venuto da un iPhone, dove quella sequenza puo' perdere
    // l'ultimo "nascondi": si misura che l'app lo dica da se', a ogni ritorno.
    final dallApp = LaTastieraSiChiude.chiusure - chiusurePrima;
    if (dallApp < 1) colpe.add('$nome: l\'app non chiude la tastiera da se\'');
    final ultima = parole.lastWhere(
        (p) => p == 'TextInput.show' || p == 'TextInput.hide',
        orElse: () => '');
    final fuoco = LaTastieraSiChiude.unCampoHaIlFuoco();
    print('LA TASTIERA SI CHIUDE TORNANDO, $nome: ultima parola "$ultima", '
        'un campo ha il fuoco $fuoco, chiusure dell\'app $dallApp');
    if (ultima != 'TextInput.hide') colpe.add('$nome: la tastiera resta');
    if (fuoco) colpe.add('$nome: un campo ha ancora il fuoco');
  }

  testWidgets('dalla chat, col tasto indietro', (tester) async {
    final nav = GlobalKey<NavigatorState>();
    final parole = <String>[];
    await monta(tester, nav, parole);
    nav.currentState!.push(conIlCampo());
    await tester.pumpAndSettle();
    expect(parole, contains('TextInput.show'));
    final prima = LaTastieraSiChiude.chiusure;
    nav.currentState!.pop();
    await misura(tester, 'una rotta col campo', parole, chiusurePrima: prima);
  });

  testWidgets('due rotte sfilate insieme, come la barra', (tester) async {
    final nav = GlobalKey<NavigatorState>();
    final parole = <String>[];
    await monta(tester, nav, parole);
    nav.currentState!.push(conIlCampo());
    await tester.pumpAndSettle();
    nav.currentState!.push(MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('sopra'))));
    await tester.pumpAndSettle();
    final prima = LaTastieraSiChiude.chiusure;
    nav.currentState!.popUntil((r) => r.isFirst);
    await misura(tester, 'due rotte sfilate', parole, chiusurePrima: prima);
  });

  testWidgets('dal foglio col campo', (tester) async {
    final nav = GlobalKey<NavigatorState>();
    final parole = <String>[];
    await monta(tester, nav, parole);
    showModalBottomSheet<void>(
        context: nav.currentContext!,
        builder: (_) => const Padding(
            padding: EdgeInsets.all(16),
            child: TextField(key: Key('campo'), autofocus: true)));
    await tester.pumpAndSettle();
    expect(parole, contains('TextInput.show'));
    final prima = LaTastieraSiChiude.chiusure;
    nav.currentState!.pop();
    await misura(tester, 'un foglio col campo', parole, chiusurePrima: prima);
  });

  test('i conti', () {
    cardinaleMinimo(ritorni, 3, cosa: 'ritorni guardati');
    print('LA TASTIERA SI CHIUDE TORNANDO: ritorni senza la chiusura dell\'app '
        '${colpe.length} su $ritorni');
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });
}
