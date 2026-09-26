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

  test('nessuna voce resta aperta, e ogni fermata ha la sua decisione',
      () {
    // **REGOLA G del fondatore, 4 settembre 2026.** Un ordine e\' finito
    // quando il suo manifesto porta VOCI_APERTE 0 e nessuna FERMATA che non
    // poggi su una decisione che il fondatore ha preso per iscritto.
    //
    // **La REGOLA E era stata usata male, e sta scritto.** Diceva che una
    // voce che non converge si mette da parte e ci si torna alla fine, e
    // quella frase e\' servita a consegnare con sei voci aperte.
    final t = testo();
    final righe = t
        .split(String.fromCharCode(10))
        .where((r) => r.startsWith('- **CQ.'))
        .toList();
    final aperte = righe.where((r) => r.contains('**APERTA')).toList();
    final fermate = righe.where((r) => r.contains('**FERMATA')).toList();
    // ignore: avoid_print
    print('ORDINE CQ: voci ${righe.length}, aperte ${aperte.length}, '
        'fermate ${fermate.length}');
    cardinaleMinimo(righe.length, 30,
        cosa: 'righe di voce lette nel manifesto di CQ',
        perche: 'Con poche righe la prova direbbe zero aperte per non '
            'averne lette.');
    expect(aperte, isEmpty,
        reason: 'restano ${aperte.length} voci aperte, e per la REGOLA G '
            'l\'ordine non e\' finito: ${aperte.take(3).join(" | ")}');
    // **OGNI FERMATA NOMINA LA DECISIONE CHE LA FERMA.** Una fermata senza
    // una decisione scritta non e\' una fermata: e\' lavoro con un altro nome.
    final senzaDecisione = fermate
        .where((r) => !r.contains('FERMATA SU DECISIONE DEL FONDATORE'))
        .toList();
    expect(senzaDecisione, isEmpty,
        reason: 'queste fermate non poggiano su una decisione del '
            'fondatore: ${senzaDecisione.join(" | ")}');
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
