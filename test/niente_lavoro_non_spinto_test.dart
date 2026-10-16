import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// IL LAVORO NON SPINTO NON ESISTE PER NESSUNO TRANNE QUESTA MACCHINA.
///
/// **Perche' questa guardia nasce, e la cifra e' brutta.** Il lavoro di TRE
/// sessioni intere dell'ordine P e' vissuto solo nell'albero di lavoro: il
/// remoto era fermo alla 2176, quaranta voci di lavoro dopo. Un disco che si
/// rompe, una cartella che si cancella, un altro agente che riparte da un
/// worktree: tre sessioni sparite senza che nessuna prova avesse niente da dire.
/// La memoria del progetto porta gia' un caso identico, il recupero della carta
/// natale perso su un ramo divergente, e la lezione non era stata resa una
/// misura.
///
/// **Cosa misura, e cosa non puo' misurare.** Confronta il ramo locale con il
/// suo ramo di monitoraggio, cioe' con l'ULTIMO FETCH: senza rete non si puo'
/// sapere altro, e una prova che pretende la rete cade in aereo per la ragione
/// sbagliata. Se il monitoraggio e' vecchio, il conto dei commit non spinti puo'
/// essere piu' grande del vero, mai piu' piccolo: sbaglia dalla parte che
/// segnala invece di quella che tace.
///
/// **Cade mentre si lavora, ed e' il suo mestiere.** Committare non e'
/// consegnare: la guardia rossa impedisce la consegna, non il commit. Questa
/// riga diventa verde con un push, non con una soglia abbassata.
void main() {
  String? git(List<String> argomenti) {
    try {
      final esito = Process.runSync('git', argomenti,
          workingDirectory: Directory.current.path);
      if (esito.exitCode != 0) return null;
      return (esito.stdout as String).trim();
    } on ProcessException {
      // Senza git non si puo' rispondere, e non si finge di sapere.
      return null;
    }
  }

  /// **SU UNA MACCHINA DI BUILD LA DOMANDA NON HA SENSO.**
  /// Ordine CQ, 4 settembre 2026.
  ///
  /// Questa guardia chiede "il tuo lavoro e' arrivato al remoto?". Su una
  /// macchina di costruzione **il codice E' arrivato dal remoto**: e' cosi'
  /// che la macchina lo ha avuto. La domanda e' gia' risposta di si' per
  /// costruzione, e la sua risposta li' dipende da come quella macchina fa il
  /// checkout: Codemagic e le altre clonano spesso in testa staccata o senza
  /// ramo di monitoraggio, e in quel caso la guardia **fallisce la consegna
  /// per un fatto che non esiste**.
  ///
  /// **Non e' un'esenzione comoda**: sulla macchina di chi sviluppa la guardia
  /// resta intera, ed e' li' che il lavoro puo' davvero restare non spinto. Le
  /// due variabili sono quelle che Codemagic e GitHub Actions dichiarano da
  /// se', e non se le inventa questo file.
  bool suUnaMacchinaDiBuild() =>
      Platform.environment.containsKey('CM_BUILD_ID') ||
      Platform.environment['CI'] == 'true' ||
      Platform.environment.containsKey('GITHUB_ACTIONS');

  test('il ramo locale non ha commit che il remoto non conosce', () {
    if (suUnaMacchinaDiBuild()) {
      // ignore: avoid_print
      print('NIENTE LAVORO NON SPINTO: macchina di build, il codice e '
          'arrivato dal remoto e la domanda e gia risposta');
      return;
    }
    final ramo = git(['rev-parse', '--abbrev-ref', 'HEAD']);
    if (ramo == null || ramo == 'HEAD') {
      // Testa staccata o niente git: la domanda non ha risposta qui, e
      // inventarne una sarebbe peggio che non chiedere.
      return;
    }
    final monitoraggio = git(['rev-parse', '--abbrev-ref', '@{u}']);
    if (monitoraggio == null) {
      // Un ramo senza monitoraggio e' lavoro che il remoto non conosce
      // NEPPURE DI NOME: e' il caso peggiore, non un caso da saltare.
      fail('il ramo "$ramo" non ha un ramo di monitoraggio: nessun remoto '
          'conosce questo lavoro, nemmeno il suo nome. Si spinge con '
          '"git push -u origin $ramo"');
    }
    final nonSpinti = git(['rev-list', '--count', '@{u}..HEAD']);
    expect(nonSpinti, isNotNull,
        reason: 'non si riesce a contare i commit non spinti, quindi non si '
            'puo\' dire che non ce ne siano');
    final quanti = int.parse(nonSpinti!);
    if (quanti > 0) {
      final elenco = git(['log', '--oneline', '@{u}..HEAD']) ?? '';
      fail('ci sono $quanti commit che $monitoraggio non ha. Finche\' non '
          'sono spinti esistono solo su questa macchina:\n$elenco');
    }
  });

  test('l\'albero di lavoro non tiene lavoro che nessun commit contiene', () {
    // **E NEMMENO QUESTA, per la stessa ragione**: su una macchina di
    // build l'albero e' un checkout appena fatto, e cio' che vi compare
    // sporco lo ha scritto la build stessa, non una persona che ha
    // dimenticato di committare.
    if (suUnaMacchinaDiBuild()) return;
    if (git(['rev-parse', '--is-inside-work-tree']) == null) return;
    final sporco = git(['status', '--porcelain']);
    if (sporco == null || sporco.isEmpty) return;
    // **NON tutto conta.** Le anteprime rigenerate cambiano ogni volta che si
    // scatta il corredo e non sono lavoro perduto: il lavoro sta nel codice,
    // nelle prove e nei documenti degli ordini. Si guarda dove il lavoro
    // vive, cosi' la guardia non diventa rumore che si impara a ignorare.
    final righe = sporco
        .split('\n')
        .map((r) => r.length > 3 ? r.substring(3) : r)
        .where((p) =>
            p.startsWith('lib/') ||
            p.startsWith('test/') ||
            p.startsWith('tool/') ||
            p.startsWith('docs/ordini/') ||
            p.startsWith('functions/') ||
            p == 'pubspec.yaml')
        .toList();
    expect(righe, isEmpty,
        reason: 'questi file portano lavoro che nessun commit contiene, quindi '
            'un disco rotto se lo porta via:\n${righe.join("\n")}');
  });
}
