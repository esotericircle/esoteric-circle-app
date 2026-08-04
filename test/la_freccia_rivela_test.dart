import 'dart:io';

import 'package:esoteric_circle/core/maestro/due_strati_della_lettura.dart';
import 'package:esoteric_circle/core/maestro/misura_della_risposta.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA FRECCIA RIVELA, NON RIGENERA.
///
/// **Cosa faceva, e cosa costava.** "Vai piu' a fondo" buttava via la risposta
/// appena letta e ne chiedeva un'altra al Maestro, con tutta l'attesa da capo.
/// La freccia in giu' prometteva "qui sotto c'e' altro testo": vera come
/// intenzione, falsa come funzionamento, perche' sotto non c'era ancora
/// niente, e il secondo testo poteva contraddire il primo.
///
/// **Il conto, misurato il 3 agosto 2026 su dieci risposte vere.** Ingresso
/// 1807 token mediani, uscita 116. Due chiamate costavano 1807+116 e poi
/// 1807+350, una sola costa 1807+350: l'ingresso e' il 94 per cento della
/// spesa.
void main() {
  const lungo =
      'Il tuo Sole in Cancro chiede casa prima di chiedere strada. '
      'Quello che senti come confusione e\' un confine che si sposta. '
      'Guarda dove ti fermi a respirare: quella e\' la direzione. '
      'Sotto la superficie c\'e\' un secondo movimento, piu\' lento, che '
      'lavora da mesi senza chiedere il tuo permesso. Non e\' la scelta a '
      'spaventarti, e\' quello che la scelta rende definitivo. La Luna in '
      'Pesci ti dice che il tempo qui non e\' nemico: aspetta la prossima '
      'luna nuova e riguarda queste stesse parole. Il cielo inclina, e la '
      'mano che sceglie resta la tua, sempre, anche quando pesa.';

  group('I due strati, e il breve e\' dentro il lungo', () {
    test('Lo strato breve e\' un PREFISSO del lungo, non un altro testo', () {
      final breve = DueStratiDellaLettura.breve(lungo);
      expect(breve, isNotEmpty);
      // **LA FORMA E' LA GARANZIA.** Un estratto che sia letteralmente
      // l'inizio dell'intero non puo' dire niente che l'intero non dica: e'
      // l'unica costruzione in cui "estratto vero" non e' una speranza.
      expect(lungo.trim().startsWith(breve), isTrue,
          reason: 'lo strato breve non e\' l\'inizio del lungo:\n$breve');
      expect(breve.length, lessThan(lungo.trim().length),
          reason: 'lo strato breve e\' tutto il testo: non c\'e\' niente da '
              'rivelare, e la freccia prometterebbe a vuoto');
    });

    test('Si taglia a fine frase, mai a meta\'', () {
      for (final testo in [lungo, 'Una frase sola e basta.', 'Senza punto']) {
        final breve = DueStratiDellaLettura.breve(testo);
        if (breve.length >= testo.trim().length) continue;
        expect(DueStratiDellaLettura.fineDiFrase.contains(breve[breve.length - 1]),
            isTrue,
            reason: 'lo strato si chiude su "${breve[breve.length - 1]}", cioe\' '
                'a meta\' frase: un testo spezzato non e\' uno strato, e\' un '
                'guasto');
      }
    });

    test('Breve piu\' resto fanno esattamente l\'intero', () {
      final breve = DueStratiDellaLettura.breve(lungo);
      final resto = DueStratiDellaLettura.resto(lungo);
      expect('$breve $resto'.replaceAll(RegExp(r'\s+'), ' ').trim(),
          lungo.replaceAll(RegExp(r'\s+'), ' ').trim(),
          reason: 'rivelando si perde o si aggiunge del testo');
    });

    test('Senza secondo strato la freccia NON ha niente da promettere', () {
      const corto = 'Il tuo Sole in Cancro chiede casa prima di strada.';
      expect(DueStratiDellaLettura.ceUnSecondoStrato(corto), isFalse,
          reason: 'una freccia che rivela mezza riga promette e non mantiene');
      expect(DueStratiDellaLettura.daMostrare(corto, rivelato: false), corto,
          reason: 'senza secondo strato si mostra tutto subito');
      expect(DueStratiDellaLettura.ceUnSecondoStrato(lungo), isTrue);
    });

    test('Rivelato mostra l\'intero, non rivelato mostra il breve', () {
      expect(DueStratiDellaLettura.daMostrare(lungo, rivelato: true),
          lungo.trim());
      expect(DueStratiDellaLettura.daMostrare(lungo, rivelato: false),
          DueStratiDellaLettura.breve(lungo));
    });
  });

  group('Una generazione sola, e il conto', () {
    test('Non esiste piu\' una misura dell\'approfondimento', () {
      // Il nome non c'e' piu' nell'enumerazione: se tornasse, tornerebbe con
      // se' la seconda chiamata.
      final nomi =
          MisuraDellaRisposta.values.map((m) => m.name).toList(growable: false);
      expect(nomi, isNot(contains('approfondimento')),
          reason: 'e\' tornata la misura della seconda chiamata');
      expect(nomi, isNot(contains('primaRisposta')),
          reason: 'e\' tornata la misura che aveva senso solo accanto alla '
              'seconda chiamata');
    });

    test('Le due misure della chat sono quelle dichiarate', () {
      // I NUMERI SONO LETTERALI, non presi dal codice sotto esame.
      expect(MisuraDellaRisposta.letturaDellaChat.parole, 180,
          reason: 'centottanta parole valgono circa 350 token in uscita, che '
              'e\' il numero su cui e\' fatto il conto della voce');
      expect(MisuraDellaRisposta.letturaBreve.parole, 50);
      expect(MisuraDellaRisposta.perChat(aDueStrati: true),
          MisuraDellaRisposta.letturaDellaChat);
      expect(MisuraDellaRisposta.perChat(aDueStrati: false),
          MisuraDellaRisposta.letturaBreve,
          reason: 'a chi non puo\' rivelare si chiede la lettura breve: '
              'generare parole che nessuno leggera\' e\' spendere per niente');
    });

    test('Nessun punto del progetto chiede una SECONDA lettura', () {
      // ENUMERA `lib`: la seconda chiamata non deve poter tornare da nessuna
      // parte, nemmeno da un ramo che oggi nessuno percorre.
      final colpe = <String>[];
      for (final voce in Directory('lib').listSync(recursive: true)) {
        if (voce is! File || !voce.path.endsWith('.dart')) continue;
        final percorso = voce.path.replaceAll(Platform.pathSeparator, '/');
        final righe = voce.readAsLinesSync();
        for (var i = 0; i < righe.length; i++) {
          final riga = righe[i];
          if (riga.trimLeft().startsWith('//') ||
              riga.trimLeft().startsWith('///')) {
            continue;
          }
          if (riga.contains('approfondisci:') ||
              riga.contains('regolaDellApprofondimento')) {
            colpe.add('$percorso riga ${i + 1}: ${riga.trim()}');
          }
        }
      }
      expect(colpe, isEmpty,
          reason: 'qualcuno chiede di nuovo la stessa risposta al '
              'Maestro:\n${colpe.join("\n")}');
    });
  });
}
