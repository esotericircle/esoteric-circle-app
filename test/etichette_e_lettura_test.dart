import 'dart:io';

import 'package:esoteric_circle/design_system/tokens/typography_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL MAIUSCOLETTO E' UN'ETICHETTA, E UNA LETTURA PASSA DALLA PORTA UNICA.
///
/// Due regole dell'ordine H, tutte e due ENUMERATE sul sorgente e non visitate
/// schermata per schermata, cosi' valgono anche per le schermate che nessun
/// test monta.
///
/// PRIMA REGOLA: un'etichetta sta su UNA riga. Il maiuscoletto spaziato e' un
/// segnale, non un testo: quando va a capo smette di segnalare e diventa un
/// muro di lettere larghe. Ogni stringa costante resa col ruolo `etichetta` si
/// misura col TextPainter alla larghezza di riferimento, e se supera una riga
/// la prova cade col file e la frase. Le stringhe che arrivano da variabili
/// non si possono misurare qui e restano fuori, DICHIARATO: sono una
/// sorveglianza in meno, non una garanzia.
///
/// SECONDA REGOLA: il testo narrato si monta con `ParagrafiDiLettura`, mai con
/// un `Text` diretto nel ruolo `lettura`. Due schermate che spezzano il testo
/// con due regole diverse sono la famiglia delle due porte. Le eccezioni
/// ammesse sono il punto comune stesso e l'Oroscopo, che scrive a macchina e
/// usa `spezzaInParagrafi` direttamente.
void main() {
  /// Le coppie (file, stringa) rese con etichetta, raccolte dal sorgente.
  List<({String file, int riga, String testo})> etichetteCostanti() {
    final trovate = <({String file, int riga, String testo})>[];
    // Text('...'), con la stringa costante, seguito entro poche righe dallo
    // stile etichetta: e' la forma con cui l'app scrive le etichette.
    final pat = RegExp(
        r"Text\(\s*'((?:[^'\\]|\\.)+)'(?:[^;]{0,300}?)TypographyTokens\.etichetta\(",
        dotAll: true);
    for (final f in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final s = f.readAsStringSync();
      final percorso = f.path.replaceAll(r'\', '/');
      for (final m in pat.allMatches(s)) {
        trovate.add((
          file: percorso,
          riga: s.substring(0, m.start).split('\n').length,
          testo: m.group(1)!.replaceAll(r"\'", "'"),
        ));
      }
    }
    return trovate;
  }

  testWidgets('Nessuna etichetta supera una riga', (tester) async {
    final etichette = etichetteCostanti();
    expect(etichette.length, greaterThan(30),
        reason: 'trovate solo ${etichette.length} etichette costanti: la '
            'ricerca non sta enumerando, e una prova cieca e\' peggio di '
            'nessuna prova');

    // La larghezza di riferimento: una scheda sul telefono da 360 punti, cioe'
    // 360 meno due margini di lista e due riempimenti di scheda. E' la
    // larghezza piu' stretta in cui un'etichetta vive davvero.
    const larghezza = 360.0 - 24 * 2 - 16 * 2;
    final colpe = <String>[];
    for (final e in etichette) {
      // LE INTERPOLAZIONI SI MISURANO COL LORO VALORE PLAUSIBILE, non col
      // sorgente: "sconto \${price.yearlyDiscountPercent}%" rende "sconto 25%"
      // e misurare i trentotto caratteri del sorgente lo accuserebbe di un
      // capo che a video non esiste. Il segnaposto e' un nome tipico
      // dell'app, sei lettere.
      final reso = e.testo
          .replaceAll(RegExp(r'\$\{[^}]+\}'), 'Medora')
          .replaceAll(RegExp(r'\$[A-Za-z_][\w]*'), 'Medora');
      final tp = TextPainter(
        text: TextSpan(text: reso, style: TypographyTokens.etichetta()),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: larghezza);
      if (tp.computeLineMetrics().length > 1) {
        colpe.add('${e.file}:${e.riga} "$reso" '
            '(${tp.computeLineMetrics().length} righe)');
      }
    }
    expect(colpe, isEmpty,
        reason: 'queste etichette in maiuscoletto superano una riga: il '
            'maiuscoletto e\' un segnale, non un testo, e quando va a capo '
            'diventa un muro di lettere larghe. Passale a corpo o a '
            'lettura.\n${colpe.join('\n')}');
    // ROSSO ESEGUITO: riportando a etichetta la riga "Scopri il tuo archetipo
    // su Esoteric Circle" della card dell'archetipo, la prova e' caduta
    // nominando il file e la frase su due righe.
  });

  test('Il testo narrato passa da ParagrafiDiLettura', () {
    // Un Text diretto nel ruolo lettura e' una seconda porta: la regola dei
    // paragrafi non lo raggiunge e il muro di testo torna da li'.
    //
    // SI BILANCIANO LE PARENTESI del Text invece di cercare "entro una
    // finestra di caratteri": in una lista di children non ci sono punti e
    // virgola, e la finestra cieca accusava il Text del titolo per il
    // ParagrafiDiLettura che gli stava accanto. Falso positivo preso al primo
    // giro, sulla scheda Fonti e metodo della Runa del Tramonto.
    int? chiusaDi(String s, int aperta) {
      var profondita = 0;
      String? inStringa;
      for (var j = aperta; j < s.length; j++) {
        final c = s[j];
        if (inStringa != null) {
          if (c == r'\') {
            j++;
          } else if (c == inStringa) {
            inStringa = null;
          }
        } else if (c == '/' &&
            j + 1 < s.length &&
            s[j + 1] == '/') {
          // I COMMENTI SI SALTANO: un apostrofo dentro un commento ("e'
          // sempre") apriva una stringa fittizia e il bilanciatore inghiottiva
          // il widget successivo, accusando un Text per il ParagrafiDiLettura
          // del vicino. Preso al primo giro sulla scheda della runa.
          final fine = s.indexOf('\n', j);
          if (fine == -1) return null;
          j = fine;
        } else if (c == "'" || c == '"') {
          inStringa = c;
        } else if (c == '(') {
          profondita++;
        } else if (c == ')') {
          profondita--;
          if (profondita == 0) return j;
        }
      }
      return null;
    }

    const ammessi = {
      // Il punto comune: e' LUI la porta.
      'lib/design_system/typography/paragrafi_di_lettura.dart',
      // L'Oroscopo scrive a macchina: usa spezzaInParagrafi direttamente, e
      // la sua prova dedicata gia' verifica blocchi e oro.
      'lib/features/horoscope/oroscopo_screen.dart',
    };
    final colpe = <String>[];
    for (final f in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final percorso = f.path.replaceAll(r'\', '/');
      if (ammessi.contains(percorso)) continue;
      final s = f.readAsStringSync();
      for (final m in RegExp(r'\bText\(').allMatches(s)) {
        final chiusa = chiusaDi(s, m.end - 1);
        if (chiusa == null) continue;
        final corpo = s.substring(m.end, chiusa);
        if (!corpo.contains('TypographyTokens.lettura(')) continue;
        colpe.add('$percorso:${s.substring(0, m.start).split('\n').length}');
      }
    }
    expect(colpe, isEmpty,
        reason: 'questi punti montano un Text diretto nel ruolo lettura '
            'invece di ParagrafiDiLettura: e\' la famiglia delle due porte, e '
            'da li\' il muro di testo torna.\n${colpe.join('\n')}');
    // ROSSO ESEGUITO: rimettendo il Text diretto con lettura() sulla nota
    // delle fonti della Runa del Tramonto, la prova e' caduta col file e la
    // riga.
  });
}
