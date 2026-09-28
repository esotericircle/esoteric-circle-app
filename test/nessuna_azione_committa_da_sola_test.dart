import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'sorgenti_di_lib.dart';

/// NESSUNA AZIONE AUTOMATICA COMMITTA SUL RAMO CANONICO.
///
/// **Il difetto che questa guardia chiude, e ha fatto danni veri.**
/// `chat-screenshot.yml` rigenerava un'anteprima a ogni push e la committava da
/// sola sul ramo canonico col `GITHUB_TOKEN`. Serviva a una cosa buona, far
/// vedere a Mauro lo screenshot dal telefono senza scaricare niente, e ha
/// prodotto DUE conflitti: un commit che nessuno si aspettava, su un ramo dove
/// il lavoro sta in corso, che va riconciliato a mano ogni volta. Ha anche
/// committato per un periodo l'intera cartella delle anteprime, fra cui
/// un'immagine che dipende dall'ora reale, accumulando megabyte di blob sotto un
/// messaggio che parlava d'altro.
///
/// L'azione e' stata disattivata su GitHub e il file e' stato TOLTO dal
/// repository, perche' un file che sta qui prima o poi qualcuno lo riaccende.
/// Questa prova esiste perche' toglierlo non basta: domani se ne scrive un
/// altro con lo stesso buon motivo.
///
/// **Cosa si misura, e cosa resta permesso.** Non si vieta a un'azione di
/// scrivere: si vieta di scrivere NEL REPOSITORY. Un'azione che pubblica un
/// artefatto, apre una pull request o manda una notifica non tocca la
/// cronologia di nessuno. Quel che non si fa e' `git commit` piu' `git push`
/// dentro un workflow, e il permesso `contents: write` che lo consente.
///
/// **L'ECCEZIONE, UNA SOLA, DECISA DAL FONDATORE IL 28 SETTEMBRE 2026.** La
/// build iOS su Codemagic si fermava al primo passo col cancello verde:
/// chiedeva il verdetto all'API di GitHub senza credenziali, sessanta
/// domande all'ora per indirizzo, e i Mac di Codemagic escono da indirizzi
/// condivisi. La cura: il cancello di GitHub, a sbarramento passato, scrive
/// il riferimento `refs/verde/<commit>`, che Codemagic legge con git fuori
/// da quel limite. Alla domanda *"Il segno del verde, con un'eccezione
/// scritta alla regola: GitHub scrive solo quel riferimento, mai sul ramo,
/// e la guardia si stringe a vietare le scritture sui rami"*, il fondatore
/// ha risposto *"1"*, cioe' questa strada. Il segno non tocca la cronologia
/// di nessun ramo, che e' il danno che questa guardia impedisce. **Resta
/// vietato tutto il resto**: `git commit` in ogni workflow, ogni `git push`
/// che non sia esattamente quello del segno, e `contents: write` in ogni
/// file che non sia `verde.yml` col suo segno.
const String spintaDelSegno =
    r'git push origin "${GITHUB_SHA}:refs/verde/${GITHUB_SHA}"';

/// Le scritture vietate in un workflow, col nome del file davanti.
List<String> scrittureVietate(String nome, String testo) {
  final colpevoli = <String>[];
  if (testo.contains('git commit')) colpevoli.add('$nome porta "git commit"');
  final spinte = testo
      .split('\n')
      .map((r) => r.trim())
      .where((r) => r.contains('git push'))
      .toList();
  for (final r in spinte) {
    if (!r.endsWith(spintaDelSegno)) colpevoli.add('$nome porta "$r"');
  }
  final colSegno =
      spinte.isNotEmpty && spinte.every((r) => r.endsWith(spintaDelSegno));
  if (testo.contains('contents: write') && !(nome == 'verde.yml' && colSegno)) {
    colpevoli.add('$nome porta "contents: write"');
  }
  return colpevoli;
}

void main() {
  // **QUI C'ERA UNA CECITA' VIVA, tolta il 1 settembre 2026.** Ogni
  // prova cominciava con `if (!cartella.existsSync()) return;`: il
  // giorno che i flussi di lavoro fossero spariti, o che la prova
  // fosse stata lanciata da un'altra cartella, **queste guardie
  // sarebbero uscite verdi senza aver letto un solo file**, e il
  // divieto di committare da soli sarebbe rimasto scritto senza
  // essere sorvegliato. La porta comune non torna a mani vuote: o
  // trova i flussi, o dice ad alta voce che non ci sono.
  List<File> flussi() =>
      fileScoperti('.github/workflows', minimo: 2, ricorsiva: false);

  test('nessun workflow committa o spinge dentro il repository', () {
    final colpevoli = <String>[];
    for (final voce in flussi()) {
      final nome = voce.uri.pathSegments.last;
      if (!nome.endsWith('.yml') && !nome.endsWith('.yaml')) continue;
      final testo = voce.readAsStringSync().replaceAll('\r\n', '\n');
      colpevoli.addAll(scrittureVietate(nome, testo));
    }
    expect(colpevoli, isEmpty,
        reason:
            'un\'azione automatica puo\' scrivere nella cronologia del ramo '
            'su cui si lavora, ed e\' cosi\' che sono nati due conflitti:\n'
            '${colpevoli.join("\n")}\n'
            'Se serve davvero, si apre una pull request invece di committare.');
  });

  /// L'eccezione non apre la porta: ogni altra scrittura resta presa. Vista
  /// rossa con l'eccezione allargata a ogni `git push`.
  test('l\'eccezione del segno non lascia passare altre scritture', () {
    const segno = '      - name: Il segno del verde\n'
        '        run: $spintaDelSegno\n'
        '    permissions:\n      contents: write\n';
    expect(scrittureVietate('verde.yml', segno), isEmpty,
        reason: 'il segno del verde, deciso dal fondatore, e\' preso come '
            'una scrittura vietata');
    const sulRamo = '        run: git push origin '
        'HEAD:claude/esoteric-circle-master-order-e798aj\n'
        '    permissions:\n      contents: write\n';
    expect(scrittureVietate('verde.yml', sulRamo), hasLength(2),
        reason: 'una spinta sul ramo passa per via dell\'eccezione');
    const dueSpinte = '        run: $spintaDelSegno\n'
        '        run: git push origin HEAD:refs/heads/main\n';
    expect(scrittureVietate('verde.yml', dueSpinte), hasLength(1),
        reason: 'accanto al segno passa un\'altra spinta');
    const altroFile = '        run: $spintaDelSegno\n'
        '    permissions:\n      contents: write\n';
    expect(scrittureVietate('ronda.yml', altroFile), hasLength(1),
        reason: 'il permesso di scrivere passa fuori da verde.yml');
    expect(scrittureVietate('verde.yml', '        run: git commit -m x\n'),
        hasLength(1),
        reason: 'un commit dentro un workflow passa');
  });

  test('il workflow degli screenshot non e\' tornato col suo nome', () {
    // Il nome del file si compone, cosi' questa prova non si accusa da sola.
    const nome = 'chat-' 'screenshot.yml';
    expect(File('.github/workflows/$nome').existsSync(), isFalse,
        reason: 'l\'azione che committava le anteprime da sola e\' tornata nel '
            'repository: era stata tolta il 12 agosto 2026 proprio perche\' '
            'restando qui qualcuno la riaccende');
  });
}
