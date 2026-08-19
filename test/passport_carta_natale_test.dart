import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// La carta natale aperta dal Passport ha la sua scaffalatura.
///
/// **Tre sintomi, una causa.** Aprendola dal Passport ogni testo compariva
/// sottolineato in giallo, il fondo era nero invece del cosmo, e la parallasse
/// spariva. Non era una scelta di stile: Flutter disegna quelle righe quando un
/// `Text` non trova un antenato `Material` da cui ereditare lo stile, e il fondo
/// nero e' il secondo sintomo della stessa mancanza.
///
/// La rotta l'avevo scritta io, in un ordine precedente, montando il widget
/// nudo dentro un `MaterialPageRoute` senza alcuno scaffale. La cura non e'
/// togliere la decorazione: e' dare alla schermata l'antenato che le manca.
void main() {
  final sorgente = File('lib/features/passport/cosmic_passport_screen.dart')
      .readAsStringSync();

  test('La rotta della carta natale monta uno scaffale immersivo', () {
    final da = sorgente.indexOf("Key('passport_natal_chart')");
    expect(da, greaterThan(0), reason: 'tessera della carta natale non trovata');
    final blocco = sorgente.substring(da, da + 1600);
    expect(blocco.contains('ImmersiveScaffold'), isTrue,
        reason: 'la carta natale si apre senza scaffale: senza un antenato '
            'Material ogni testo prende la riga gialla e il fondo resta nero');
  });

  test('Il pulsante in fondo riporta al Passport', () {
    final da = sorgente.indexOf("Key('passport_natal_chart')");
    final blocco = sorgente.substring(da, da + 1600);
    expect(blocco.contains('Torna al Passport'), isTrue,
        reason: 'la carta aperta dal Passport invita ancora alla Risonanza, che '
            'e\' gia\' avvenuta');
  });

  test('Nessuna rotta di lib monta un widget nudo senza scaffale', () {
    // La rete: la stessa causa non deve tornare da un\'altra porta.
    //
    // **LA RETE GUARDA IL CODICE E NON PIU' IL NOME, ordine AP voce 09.**
    // Prima una rotta si salvava se il widget montato si chiamava `...Screen`
    // o `...Journey`, e questo aveva due difetti opposti: bocciava una
    // schermata vera col nome italiano, `ScenaDelRitrovamento`, che il suo
    // `Scaffold` ce l'ha eccome; e avrebbe promosso qualunque cosa chiamata
    // `Screen` anche se lo scaffale non l'avesse mai avuto. Adesso la classe
    // montata si CERCA nei sorgenti e si guarda se porta uno scaffale: e' la
    // domanda vera, e la rete e' piu' stretta di prima, non piu' larga.
    final scaffalate = <String>{};
    final pezzoDi = <String, String>{};
    final tuttiIFile = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .toList();
    // **I COMMENTI NON CONTANO, ed e' la riga che ha salvato questa rete.**
    // `CosmosBackground` non ha nessuno scaffale, ma un suo commento nomina
    // "il nero dello Scaffold": tanto e' bastato per promuoverlo, e da lui la
    // proprieta' e' passata a chiunque dipinga il cosmo, cioe' a mezza app.
    // Misurato: col commento la scena passava anche senza scaffale, senza
    // commenti no. Una guardia che legge i commenti misura le intenzioni.
    String soloCodice(String t) => t
        .split('\n')
        .map((r) => r.split('//').first)
        .join('\n');
    for (final f in tuttiIFile) {
      final t = soloCodice(f.readAsStringSync().replaceAll('\r\n', '\n'));
      for (final c in RegExp(r'class (\w+)').allMatches(t)) {
        final nome = c.group(1)!;
        // Il pezzo di file che appartiene a quella classe: da dove comincia
        // fino alla dichiarazione successiva.
        final da = c.start;
        final prossima = t.indexOf(RegExp(r'\nclass \w+'), c.end);
        final pezzo = t.substring(da, prossima > 0 ? prossima : t.length);
        pezzoDi[nome] = pezzo;
        if (!pezzo.contains('Scaffold')) continue;
        scaffalate.add(nome);
        // **LO SCAFFALE DI UNA SCHERMATA CON STATO VIVE NELLO STATO, non
        // nel widget.** Misurato: cercandolo solo nella classe montata, dodici
        // schermate sane risultavano nude, fra cui gli Angeli e l'Oroscopo.
        // `_NomeState` risponde per `Nome`.
        final conStato = RegExp(r'^_(\w+)State$').firstMatch(nome);
        if (conStato != null) scaffalate.add(conStato.group(1)!);
      }
    }
    // **LO SCAFFALE SI EREDITA, e la catena puo' essere lunga.** Misurato:
    // `DayOracleScreen` non nomina nessuno `Scaffold`, lo prende da
    // `RitualView`, che invece ce l'ha. Guardare un livello solo l'avrebbe
    // dichiarata nuda mentre e' vestita. Qui la proprieta' si propaga finche'
    // non smette di propagarsi: chi monta una classe scaffalata e' scaffalato.
    //
    // **E SI EREDITA PER DUE PASSI, non all'infinito: misurato.** Con la
    // propagazione libera la rete diventava verde per saturazione, cioe' per
    // il motivo sbagliato: bastava che una qualunque classetta di supporto
    // avesse uno `Scaffold` perche' la proprieta' risalisse a mezza `lib`, e
    // la prova del rosso non scattava piu' nemmeno togliendo lo scaffale a
    // una schermata vera. Due passi coprono la catena piu' lunga che esiste
    // qui, schermata a stato che monta il guscio del rito, e il rosso torna
    // a scattare.
    for (var giro = 0; giro < 2; giro++) {
      final nuove = <String>[];
      for (final voce in pezzoDi.entries) {
        if (scaffalate.contains(voce.key)) continue;
        final monta = RegExp(r'\b([A-Z]\w+)\(')
            .allMatches(voce.value)
            .map((c) => c.group(1)!)
            .any(scaffalate.contains);
        if (monta) {
          nuove.add(voce.key);
          final conStato = RegExp(r'^_(\w+)State$').firstMatch(voce.key);
          if (conStato != null) nuove.add(conStato.group(1)!);
        }
      }
      scaffalate.addAll(nuove);
    }
    final sospette = <String>[];
    for (final f in tuttiIFile) {
      final t = f.readAsStringSync().replaceAll('\r\n', '\n');
      for (final m in RegExp(
              r'MaterialPageRoute<void>\(\s*(?:fullscreenDialog:[^,]+,\s*)?builder: \([^)]*\) =>\s*([\s\S]{0,220})')
          .allMatches(t)) {
        final blocco = m.group(1)!;
        final haScaffale =
            blocco.contains('Scaffold') || blocco.contains('ImmersiveScaffold');
        // Oppure il blocco monta una classe che il proprio scaffale ce l'ha:
        // e' la stessa garanzia, presa dove vive davvero.
        final montaUnaScaffalata = RegExp(r'\b([A-Z]\w+)\(')
            .allMatches(blocco)
            .map((c) => c.group(1)!)
            .any(scaffalate.contains);
        if (!haScaffale && !montaUnaScaffalata) {
          sospette.add('${f.path}: ${blocco.split('\n').first.trim()}');
        }
      }
    }
    expect(sospette, isEmpty,
        reason: 'queste rotte montano un widget senza scaffale, quindi i loro '
            'testi prenderanno la riga gialla:\n${sospette.join('\n')}');
  });
}
