import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// LA GUARDIA DELL'ORDINE CQ.
///
/// **Cosa sorveglia questa e cosa sorveglia l'altra.** La forma del sigillo,
/// uguale per tutti gli ordini, la misura
/// `i_manifesti_sono_sigillati_test.dart`. Qui si sorveglia il contenuto di
/// CQ: le tre premesse verificate, le attribuzioni, e le sei voci aperte
/// nominate una per una.
///
/// **La riga che resta rossa non e' qui**, e' nella guardia di famiglia: la
/// REGOLA F vale per tutti gli ordini insieme, e scritta sei volte
/// diventerebbe sei leggi che possono divergere.
void main() {
  String testo() =>
      File('docs/ordini/ORDINE_CQ_MANIFESTO.md').readAsStringSync();

  test('le premesse dell ordine hanno il loro esito, e non tutte sono vere',
      () {
    final t = testo();
    final vere = 'VERA'.allMatches(t).length;
    final false0 = 'FALSA'.allMatches(t).length;
    final nonConfermate = 'NON CONFERMATA'.allMatches(t).length;
    // ignore: avoid_print
    print('ORDINE CQ: premesse dichiarate vere $vere, false $false0, non '
        'confermate $nonConfermate');
    cardinaleMinimo(vere + false0 + nonConfermate, 3,
        cosa: 'esiti di premessa dichiarati nel manifesto di CQ',
        perche: 'La REGOLA ZERO chiede di verificare ogni affermazione '
            'dell ordine prima di eseguirla.');
    expect(false0 + nonConfermate, greaterThan(0),
        reason: 'nessuna premessa risulta falsa o non confermata: **la '
            'verifica non ha cambiato niente**, ed e il segno che non e stata '
            'fatta. In questo ordine ne sono cadute tre');
  });

  test('ogni difetto trovato porta il suo padre, o dice PROVENIENZA IGNOTA',
      () {
    final t = testo();
    final padri = RegExp(r'[Pp]rovenienza[^.]{0,120}').allMatches(t).length +
        'PROVENIENZA IGNOTA'.allMatches(t).length;
    // ignore: avoid_print
    print('ORDINE CQ: attribuzioni scritte nel manifesto $padri');
    cardinaleMinimo(padri, 6,
        cosa: 'attribuzioni di difetto nel manifesto di CQ',
        perche: 'La REGOLA C dice che ogni difetto ha un padre: un elenco di '
            'difetti senza padri non insegna niente a chi lo legge.');
  });

  test('le sei voci aperte sono nominate una per una', () {
    // **CIO CHE NON E FINITO SI DICHIARA INVECE DI SPARIRE.** Sei voci del
    // pezzo secondo restano aperte, e il manifesto deve dirle col loro nome:
    // un conto senza nomi non si puo riprendere.
    final t = testo();
    final righeAperte = t
        .split(String.fromCharCode(10))
        .where((r) => r.startsWith('- **CQ.') && r.contains('**APERTA'))
        .toList();
    // ignore: avoid_print
    print('ORDINE CQ: voci aperte nominate ${righeAperte.length}');
    expect(righeAperte, hasLength(6),
        reason: 'le righe di voce aperta sono ${righeAperte.length} invece di '
            'sei: o qualcuna e stata chiusa senza aggiornare il marcatore, o '
            'ne e comparsa una nuova senza dirlo');
    for (final r in righeAperte) {
      expect(r.length, greaterThan(40),
          reason: 'questa voce aperta non dice niente di se: "$r"');
    }
  });

  test('il passo che aspetta il PC del fondatore e nominato', () {
    final t = testo();
    expect(t.contains('PASSO 7'), isTrue,
        reason: 'il manifesto non nomina il passo della distribuzione che '
            'aspetta il PC del fondatore: chi legge non sa cosa manca');
    expect(File('docs/ordini/DISTRIBUZIONI_DAL_TUO_PC.md')
        .readAsStringSync()
        .contains('DEMO_APERTA=1'), isTrue,
        reason: 'il foglio delle distribuzioni non porta la chiave della '
            'porta della Demo');
  });
}
