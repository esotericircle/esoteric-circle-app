import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// OGNI ROTTA PASSA DAL NERO. Ordine CC voce 04.
///
/// **Rilievo del fondatore, 29 agosto 2026, verbatim:** "quando entro nella
/// funzionalita' dei tarocchi c'e' un flash bianco che introduce la schermata,
/// voglio che questo flash sia nero e che ci sia sempre ad ogni cambio
/// schermata. niente deve apparire di botto."
///
/// **Questa prova ENUMERA, non visita.** E' la regola che questo progetto ha
/// pagato piu' volte: una prova che apre una schermata e guarda come entra
/// dice qualcosa su quella schermata e niente su tutte le altre. Qui si legge
/// ogni file di `lib/` e si pretende che nessuno costruisca una rotta per
/// conto suo. Il giorno che nasce una schermata nuova con
/// `MaterialPageRoute`, questa riga diventa rossa da sola.
void main() {
  final dentroLib = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  /// **LE DUE ROTTE CHE NON SONO CAMBI DI SCHERMATA, dichiarate col perche'.**
  ///
  /// Non sono esenzioni di comodo: sono veli TRASPARENTI che si posano sopra
  /// la scena che resta a video sotto di loro. Farle passare dal nero
  /// spegnerebbe la schermata che stanno decorando, cioe' l'opposto di quello
  /// che fanno. Si riconoscono da `opaque: false`, e la prova lo verifica
  /// invece di crederci.
  const veli = <String, String>{
    'lib/features/account/festa_della_registrazione.dart':
        'la festa del benvenuto si posa sopra la schermata dell\'account, che '
            'resta visibile dietro il velo',
    'lib/features/sigilli/celebrazione.dart':
        'la celebrazione di un traguardo si posa sopra il rito che l\'ha '
            'appena acceso, e quel rito deve restare a video',
  };

  test('nessuna schermata costruisce una rotta per conto suo', () {
    final fuoriLegge = <String>[];
    for (final f in dentroLib) {
      final p = f.path.replaceAll(r'\', '/');
      if (p.endsWith('passaggio_del_cerchio.dart')) continue;
      final testo = f.readAsStringSync();
      if (testo.contains('MaterialPageRoute')) {
        fuoriLegge.add('$p usa MaterialPageRoute');
      }
      if (testo.contains('PageRouteBuilder') &&
          !veli.keys.any((v) => p.endsWith(v.split('/').last))) {
        fuoriLegge.add('$p costruisce una rotta a mano');
      }
    }
    // ignore: avoid_print
    print('ORDINE CC VOCE 04: file dart in lib ${dentroLib.length}, rotte '
        'fuori dalla legge ${fuoriLegge.length}');
    expect(fuoriLegge, isEmpty,
        reason: 'queste schermate entrano in un modo tutto loro: $fuoriLegge');
  });

  test('i due veli dichiarati sono davvero veli, e non schermate', () {
    for (final velo in veli.entries) {
      final f = File(velo.key);
      expect(f.existsSync(), isTrue, reason: '${velo.key} non esiste piu\'');
      expect(f.readAsStringSync().contains('opaque: false'), isTrue,
          reason: '${velo.key} e\' dichiarato velo ma adesso e\' una '
              'schermata opaca: allora deve passare dal nero come le altre');
    }
    // ignore: avoid_print
    print('ORDINE CC VOCE 04: veli dichiarati ${veli.length}, e tutti e due '
        'sono ancora trasparenti');
  });

  test('quante rotte passano dalla legge unica', () {
    var quante = 0;
    for (final f in dentroLib) {
      quante += RegExp(r'PassaggioDelCerchio\.rotta')
          .allMatches(f.readAsStringSync())
          .length;
    }
    // ignore: avoid_print
    print('ORDINE CC VOCE 04: rotte sotto la legge unica $quante');
    expect(quante, greaterThanOrEqualTo(42),
        reason: 'le rotte sotto la legge unica sono $quante: ne mancano '
            'rispetto alle 42 censite dall\'ordine CC');
  });

  test('il passaggio e\' nero, dura poco e rispetta Riduci Movimento', () {
    final sorgente =
        File('lib/design_system/transizioni/passaggio_del_cerchio.dart')
            .readAsStringSync();
    expect(sorgente.contains('ColorTokens.medoraDeepest'), isTrue,
        reason: 'il passaggio non usa piu\' il nero piu\' profondo del Cerchio');
    expect(sorgente.contains('disableAnimations'), isTrue,
        reason: 'il passaggio non guarda piu\' Riduci Movimento');
    // La dissolvenza resta anche senza movimento: chi ha tolto le animazioni
    // non ha chiesto che le schermate compaiano di botto.
    final senzaMovimento =
        sorgente.substring(sorgente.indexOf('disableAnimations'));
    expect(senzaMovimento.contains('return scena;'), isTrue,
        reason: 'con Riduci Movimento la transizione sparisce del tutto, e '
            'allora le schermate tornano a comparire di botto');
  });

  test('il lampo dei Tarocchi non e\' piu\' bianco', () {
    final velo =
        File('lib/features/tarot/stesa_handoff.dart').readAsStringSync();
    expect(velo.contains('Colors.white'), isFalse,
        reason: 'e\' tornato il flash bianco che il fondatore ha visto');
    expect(velo.contains('PassaggioDelCerchio.nero'), isTrue,
        reason: 'il velo della stesa non usa il nero del Passaggio');
  });
}
