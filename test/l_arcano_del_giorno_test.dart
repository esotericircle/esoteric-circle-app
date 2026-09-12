import 'dart:io';

import 'package:esoteric_circle/core/rituals/arcano_del_giorno.dart';
import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:flutter_test/flutter_test.dart';

/// L'ARCANO DEL GIORNO. Ordine AS voce 08.
///
/// **La decisione di Mauro**: l'Oracolo del Giorno cambia natura e diventa
/// l'estrazione di una carta dei soli Arcani Maggiori, con un responso che sia
/// una risposta per la giornata e non una lezione di tarocchi.
///
/// **Cosa pretendono queste righe.** Che si peschi solo fra i ventidue
/// maggiori; che la carta sia la stessa per tutta la giornata e cambi il giorno
/// dopo; che nell'arco di un anno escano abbastanza carte diverse, perche' un
/// dono che ripete sempre le stesse tre non e' un'estrazione; e che il gesto
/// registrato nel cammino resti `oracolo`, cosi' i traguardi non si spostano.
void main() {
  test('si pesca solo fra i ventidue Arcani Maggiori', () {
    final maggiori = ArcanoDelGiorno.maggiori;
    // ignore: avoid_print
    print('ORDINE AS VOCE 08: Arcani Maggiori nel mazzo ${maggiori.length}');
    expect(maggiori, hasLength(22),
        reason: 'gli Arcani Maggiori sono ${maggiori.length} invece di 22');
    for (final c in maggiori) {
      expect(c.arcana, TarotArcana.maggiore);
      expect(c.seme, isNull,
          reason: '${c.name} ha un seme: non e un Arcano Maggiore');
    }
  });

  test('la carta e la stessa per tutta la giornata', () {
    final mattina = DateTime(2026, 8, 21, 7, 30);
    final sera = DateTime(2026, 8, 21, 23, 15);
    expect(ArcanoDelGiorno.di(mattina).name, ArcanoDelGiorno.di(sera).name,
        reason: 'la carta cambia dentro la stessa giornata: un dono che cambia '
            'a ogni apertura non e un dono');
  });

  test('in un anno escono almeno quindici carte diverse', () {
    // **UN'ESTRAZIONE CHE RIPETE NON E UN'ESTRAZIONE.** Il conto vecchio
    // dell'Oracolo era il giorno dell'anno modulo ventidue: dava un ciclo
    // esatto, riconoscibile, e la stessa carta nello stesso giorno di ogni
    // anno. Qui si guarda quante carte distinte escono davvero.
    final uscite = <String>{};
    for (var g = 0; g < 365; g++) {
      final quando = DateTime(2026, 1, 1).add(Duration(days: g));
      uscite.add(ArcanoDelGiorno.di(quando).name);
    }
    // ignore: avoid_print
    print('ORDINE AS VOCE 08: carte diverse in un anno ${uscite.length} su 22');
    expect(uscite.length, greaterThanOrEqualTo(15),
        reason: 'in un anno escono solo ${uscite.length} carte diverse');
  });

  test('due anni di seguito non danno la stessa carta nello stesso giorno', () {
    var uguali = 0;
    for (var g = 0; g < 365; g++) {
      final a = DateTime(2026, 1, 1).add(Duration(days: g));
      final b = DateTime(2027, 1, 1).add(Duration(days: g));
      if (ArcanoDelGiorno.di(a).name == ArcanoDelGiorno.di(b).name) uguali++;
    }
    // ignore: avoid_print
    print('ORDINE AS VOCE 08: giorni con la stessa carta a un anno di distanza '
        '$uguali su 365');
    expect(uguali, lessThan(120),
        reason: 'in $uguali giorni su 365 la carta si ripete identica un anno '
            'dopo: il conto e ancora legato al giorno dell anno');
  });

  test('il gesto del cammino resta oracolo, e il nome a video e cambiato', () {
    final scena =
        File('lib/features/rituals/day_oracle_screen.dart').readAsStringSync();
    // Il gesto si cerca su una riga sola: come il formattatore spezzi la
    // chiamata non e' cosa che questa guardia debba sapere.
    expect(scena.contains("context, 'oracolo',"), isTrue,
        reason: 'il gesto registrato nel cammino non e piu oracolo: i '
            'traguardi che lo nominano non maturerebbero piu');
    expect(scena.contains("title: 'Arcano del Giorno'"), isTrue,
        reason: 'la schermata non si chiama Arcano del Giorno');
    // E il dono nel registro dei riti porta il nome nuovo.
    final doni =
        File('lib/core/rituals/daily_elements.dart').readAsStringSync();
    expect(doni.contains("title: 'Arcano del Giorno'"), isTrue,
        reason: 'il registro dei doni chiama ancora il dono col nome vecchio');
  });

  test('nessun testo a video nomina piu l Oracolo del Giorno', () {
    // **COMPRESI I SENTIERI, che sono generati.** Il corpus dei traguardi
    // nomina i doni nelle sue frasi, ed e' stato scritto quando il dono si
    // chiamava Oracolo: correggere i file Dart a valle sarebbe inutile, al
    // primo rigenero tornerebbe tutto. La traduzione vive nel generatore, in
    // un elenco dichiarato, e questa riga sorveglia il risultato.
    final colpe = <String>[];
    for (final file in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final testo = file.readAsStringSync();
      for (final riga in testo.split(String.fromCharCode(10))) {
        if (riga.trimLeft().startsWith('//')) continue;
        if (riga.trimLeft().startsWith('///')) continue;
        if (riga.contains('Oracolo del Giorno')) {
          colpe.add('${file.path.replaceAll(String.fromCharCode(92), "/")}: '
              '${riga.trim()}');
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE AS VOCE 08: testi che nominano ancora l Oracolo del Giorno '
        '${colpe.length}');
    expect(colpe, isEmpty, reason: colpe.take(5).join('; '));
  });
}
