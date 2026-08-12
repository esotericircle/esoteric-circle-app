import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

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
void main() {
  final cartella = Directory('.github/workflows');

  test('nessun workflow committa o spinge dentro il repository', () {
    if (!cartella.existsSync()) return;
    final colpevoli = <String>[];
    for (final voce in cartella.listSync()) {
      if (voce is! File) continue;
      final nome = voce.uri.pathSegments.last;
      if (!nome.endsWith('.yml') && !nome.endsWith('.yaml')) continue;
      final testo = voce.readAsStringSync();
      for (final vietato in const ['git commit', 'git push', 'contents: write']) {
        if (testo.contains(vietato)) {
          colpevoli.add('$nome porta "$vietato"');
        }
      }
    }
    expect(colpevoli, isEmpty,
        reason: 'un\'azione automatica puo\' scrivere nella cronologia del ramo '
            'su cui si lavora, ed e\' cosi\' che sono nati due conflitti:\n'
            '${colpevoli.join("\n")}\n'
            'Se serve davvero, si apre una pull request invece di committare.');
  });

  test('il workflow degli screenshot non e\' tornato col suo nome', () {
    // Il nome del file si compone, cosi' questa prova non si accusa da sola.
    final nome = 'chat-' 'screenshot.yml';
    expect(File('.github/workflows/$nome').existsSync(), isFalse,
        reason: 'l\'azione che committava le anteprime da sola e\' tornata nel '
            'repository: era stata tolta il 12 agosto 2026 proprio perche\' '
            'restando qui qualcuno la riaccende');
  });
}
