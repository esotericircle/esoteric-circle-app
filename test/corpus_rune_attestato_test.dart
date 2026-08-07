import 'dart:io';

import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/rituals/rune_lore.g.dart';
import 'package:esoteric_circle/core/rituals/rune_voce.dart';
import 'package:esoteric_circle/core/rituals/runes.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL CORPUS DELLE RUNE E' ATTESTATO, FILTRATO E DETERMINISTICO.
///
/// Le ventiquattro voci portano le strofe dei tre poemi runici con la fonte
/// nominata, oppure dichiarano che la strofa non esiste: mai una strofa senza
/// fonte, mai una fonte senza strofa, mai un'invenzione. Le parole vietate
/// non entrano, neppure quando una fonte le afferma: il filtro vive nel
/// generatore e questa prova lo sorveglia anche qui.
void main() {
  group('le ventiquattro voci, enumerate', () {
    test('ogni runa del catalogo ha la sua voce nel corpus', () {
      for (final r in kElderFuthark) {
        expect(kRuneLore.containsKey(r.name), isTrue,
            reason: '${r.name} non ha una voce nel corpus generato.');
      }
      expect(kRuneLore.length, 24);
    });

    test('mai una strofa senza fonte, mai una fonte senza strofa', () {
      for (final e in kRuneLore.entries) {
        expect(e.value.strofe, isNotEmpty,
            reason: '${e.key} senza nessuna strofa: il poema anglosassone '
                'copre tutte e ventiquattro, quindi manca un dato.');
        for (final s in e.value.strofe) {
          expect(s.fonte.trim(), isNotEmpty,
              reason: '${e.key}: una strofa senza fonte.');
          expect(s.originale.trim(), isNotEmpty,
              reason: '${e.key}: una fonte senza strofa, ${s.fonte}.');
          expect(s.traduzione.trim(), isNotEmpty,
              reason: '${e.key}: la strofa di ${s.fonte} non ha traduzione.');
        }
      }
    });

    test('il conto esatto: quindici col trittico, nove senza strofa norrena',
        () {
      final complete =
          kRuneLore.entries.where((e) => e.value.strofe.length == 3).toList();
      final sole = kRuneLore.entries
          .where((e) => e.value.strofe.length == 1)
          .toList();
      expect(complete.length, 15,
          reason: 'Le rune col trittico completo sono ${complete.length}, '
              'non quindici.');
      expect(sole.length, 9,
          reason: 'Le rune con la sola strofa anglosassone sono '
              '${sole.length}, non nove.');
      // E le nove DICHIARANO perche': il campo non sparisce in silenzio.
      for (final e in sole) {
        expect(e.value.notaNorrena, isNotNull,
            reason: '${e.key} non ha strofa norrena e non dichiara perche\'.');
      }
    });
  });

  group('le parole vietate non entrano', () {
    // Le radici, cosi' prendono singolare, plurale e derivati. La frase
    // vietata composta si controlla per intero.
    const radici = [
      'guarigion', 'salute', 'malatti', 'fertilit', 'longevit',
      'vittori', 'ricchezz', 'tesor', 'protezione dalle armi',
    ];

    test('nel corpus sorgente, dentro le voci delle rune', () {
      final testo =
          File('docs/corpus/rune.md').readAsStringSync().toLowerCase();
      // Si guardano le SEZIONI delle rune, non l'intestazione che elenca le
      // parole vietate per dichiararle.
      final sezioni = testo.split('\n### ');
      final colpe = <String>[];
      for (final sez in sezioni.skip(1)) {
        for (final radice in radici) {
          if (sez.contains(radice)) {
            colpe.add('${sez.split('\n').first}: $radice');
          }
        }
      }
      expect(colpe, isEmpty,
          reason: 'Parole vietate nel corpus: $colpe. Si riformula, non si '
              'filtra a valle.');
    });

    test('nel corpus generato e nel catalogo a video', () {
      // SI GUARDA IL CODICE E NON I COMMENTI: il catalogo porta un commento
      // che ELENCA le parole vietate proprio per dichiarare la regola, e
      // bocciare un file perche' spiega la propria regola guarderebbe la
      // cosa sbagliata, come la prova delle credenziali ha gia' imparato.
      final colpe = <String>[];
      for (final percorso in [
        'lib/core/rituals/rune_lore.g.dart',
        'lib/core/rituals/runes.dart',
      ]) {
        final testo = File(percorso)
            .readAsLinesSync()
            .where((r) => !r.trimLeft().startsWith('//'))
            .join('\n')
            .toLowerCase();
        for (final radice in radici) {
          if (testo.contains(radice)) colpe.add('$percorso: $radice');
        }
      }
      expect(colpe, isEmpty,
          reason: 'Parole vietate arrivate fino al codice: $colpe.');
    });
  });

  group('la Voce della Runa, deterministica sul giorno vero', () {
    final runa = RunaGettata(
      rune: kElderFuthark.first,
      verso: RuneVerso.dritto,
      posizione: gettataOdino.posizioni.first,
    );

    test('stessa persona, stesso giorno, stessa domanda: identica', () {
      final a = RuneVoce.voce(
          runa: runa,
          persona: 'aries',
          giorno: DateTime(2026, 8, 7),
          domanda: 'quale passo fare?');
      final b = RuneVoce.voce(
          runa: runa,
          persona: 'aries',
          giorno: DateTime(2026, 8, 7),
          domanda: 'quale passo fare?');
      expect(a, b,
          reason: 'Due letture con gli stessi dati divergono: c\'e\' un caso '
              'vero dove deve esserci un seme.');
    });

    test('la stessa runa in due giorni diversi parla diversa', () {
      final a = RuneVoce.voce(
          runa: runa,
          persona: 'aries',
          giorno: DateTime(2026, 8, 7),
          domanda: 'quale passo fare?');
      final b = RuneVoce.voce(
          runa: runa,
          persona: 'aries',
          giorno: DateTime(2026, 9, 20),
          domanda: 'quale passo fare?');
      expect(a, isNot(b),
          reason: 'Il giorno e\' cambiato e la voce no: la lettura non sta '
              'dentro il giorno.');
    });

    test('la voce sta dentro il cielo vero del giorno', () {
      // Il 7 agosto 2026 il Sole sta in Leone: la voce lo nomina, perche'
      // l'aggancio e' al cielo calcolato, non a un cielo di scena.
      final a = RuneVoce.voce(
          runa: runa,
          persona: 'aries',
          giorno: DateTime(2026, 8, 7),
          domanda: '');
      expect(a.contains('Leone'), isTrue,
          reason: 'La voce del 7 agosto non nomina il Sole in Leone: '
              'l\'aggancio al cielo vero si e\' staccato.');
      // E la sostanza e' quella del catalogo: il verso della runa c'e'.
      expect(a.contains(kElderFuthark.first.upright), isTrue,
          reason: 'La voce ha perso la sostanza: il verso della runa non '
              'c\'e\' piu\'. Il ventaglio riguarda la dizione, mai la '
              'sostanza.');
    });
  });

  group('il Verso delle Norne', () {
    test('le tre giunture della stessa stesa non coincidono mai', () {
      for (var g = 1; g <= 30; g++) {
        final giunture = RuneVoce.giuntureNorne(DateTime(2026, 8, g));
        expect(giunture.length, 3);
        expect(giunture.toSet().length, 3,
            reason: 'Il giorno 2026-08-$g ha due giunture uguali nella '
                'stessa stesa.');
      }
    });

    test('variano sul giorno E sulla posizione, mai su un asse solo', () {
      final a = RuneVoce.giuntureNorne(DateTime(2026, 8, 7));
      final b = RuneVoce.giuntureNorne(DateTime(2026, 8, 8));
      expect(a, isNot(b),
          reason: 'Due giorni diversi hanno le stesse tre giunture: l\'asse '
              'del giorno non lavora.');
      // La stessa posizione in giorni diversi cambia testo almeno una volta
      // nel mese: se una posizione fosse inchiodata, l'asse della posizione
      // lavorerebbe da solo.
      for (var posizione = 0; posizione < 3; posizione++) {
        final visti = <String>{};
        for (var g = 1; g <= 30; g++) {
          visti.add(RuneVoce.giuntureNorne(DateTime(2026, 8, g))[posizione]);
        }
        expect(visti.length, greaterThan(1),
            reason: 'La posizione $posizione dice sempre la stessa giuntura '
                'per un mese intero: varia su un asse solo.');
      }
    });
  });
}
