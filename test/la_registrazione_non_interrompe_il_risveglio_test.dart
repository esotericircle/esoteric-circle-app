import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA REGISTRAZIONE NON INTERROMPE IL RISVEGLIO. Ordine BJ voce 01.
///
/// Parole del fondatore sulla 2204: "la prima cosa che esce e' la
/// richiesta di registrazione?". Il primo avviso di BE.07 partiva dal
/// Santuario montato sotto l'onboarding e sbucava sopra la prima
/// schermata del rito. La decisione di BI (niente richieste all'avvio)
/// supera BE.07 per chi il rito non lo ha compiuto.
void main() {
  String leggi(String p) => File(p).readAsStringSync();

  test('il Santuario tace finche\' il Risveglio non e\' compiuto', () {
    final s = leggi('lib/features/santuario/santuario_screen.dart');
    final invito = s.substring(s.indexOf('_forseChiediLaCustodia'));
    expect(invito.contains('needsOnboarding) return;'), isTrue,
        reason: 'l\'invito alla custodia non guarda piu\' il Risveglio: '
            'il foglio torna a sbucare sopra la prima schermata del rito');
    // E il cancello sta PRIMA della regola del momento, non dopo.
    expect(
        invito.indexOf('needsOnboarding') <
            invito.indexOf('QuandoChiedereLaCustodia.eIlMomento'),
        isTrue,
        reason: 'il cancello del Risveglio e\' finito dopo la regola: '
            'l\'invito decide prima di sapere se il rito e\' in corso');
  });

  test('il passo della custodia vale come primo invito', () {
    final passo =
        leggi('lib/features/onboarding/custodia_del_cielo_step.dart');
    expect(
        passo.contains('QuandoChiedereLaCustodia.chiaveUltimoInvito'), isTrue,
        reason: 'il Piu\' tardi del rito non segna piu\' la data: il primo '
            'avviso sbucherebbe nel Santuario un attimo dopo il no');
  });

  test('la chiave dell\'invito vive in una casa sola', () {
    var quante = 0;
    for (final f in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      quante += RegExp("'account\\.ultimoInvito'")
          .allMatches(f.readAsStringSync())
          .length;
    }
    expect(quante, 1,
        reason: 'la stringa della chiave compare $quante volte: due copie '
            'sono due inviti "primi"');
  });
}
