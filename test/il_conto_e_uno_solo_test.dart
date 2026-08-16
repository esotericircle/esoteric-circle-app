import 'dart:io';

import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/features/sigilli/le_tre_righe_del_sentiero.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL CONTO DEL SENTIERO E' UNO SOLO, E LE TRE RIGHE LO USANO. Ordine S voce 03.
///
/// **Il difetto: a schermo i conti erano due, e stavano per diventare tre.** La
/// lista diceva "50 di 50" con il cinquanta scritto a mano, mentre le posizioni
/// per sentiero sono cinquantacinque; la riga "dove sei" di questa voce avrebbe
/// portato un terzo numero sulla stessa schermata.
///
/// **Il conto e' 55, per decisione di Mauro.** I cinque grandi sono traguardi a
/// tutti gli effetti: valgono Eos, hanno le loro condizioni, e dalla voce S.02
/// sono le cinque stelle principali del disegno. Un totale che li esclude dice
/// alla persona che quelle cinque cose non contano.
void main() {
  group('Il conto e\' uno solo', () {
    test('vale 55 per tutti e tre i sentieri, contato sul dato', () {
      for (final sentiero in Sentiero.values) {
        expect(Sentieri.quantiInTutto(sentiero), 55,
            reason: 'il conto di ${sentiero.name} non e\' 55: cinquanta mini '
                'piu\' cinque grandi');
        expect(Sentieri.quantiInTutto(sentiero),
            Sentieri.miniDi(sentiero).length + Sentieri.grandiDi(sentiero).length,
            reason: 'il totale non e\' la somma dei suoi pezzi');
      }
    });

    test('l\'ordine nel cammino copre 1..55 una volta sola', () {
      // **La posizione NON e' l'ordine**, e questa prova esiste per quello: le
      // posizioni dei mini vanno da 1 a 50 e i grandi stanno a 10, 20, 30, 40 e
      // 50, quindi i due elenchi si sovrappongono. Un grande CHIUDE la sua
      // decina, quindi viene subito dopo il mini che porta il suo numero.
      for (final sentiero in Sentiero.values) {
        final ordini = <int>[];
        for (final t in Sentieri.di(sentiero)) {
          ordini.add(Sentieri.ordineNelCammino(t));
        }
        ordini.sort();
        expect(ordini, List<int>.generate(55, (i) => i + 1),
            reason: 'in ${sentiero.name} l\'ordine nel cammino salta o si '
                'ripete: ${ordini.take(14).join(", ")}');
      }
      // E il grande viene DOPO il mini della stessa decina, non prima.
      final mini10 = Sentieri.miniDi(Sentiero.costellazione)
          .firstWhere((t) => t.posizione == 10);
      final grande10 = Sentieri.grandiDi(Sentiero.costellazione).first;
      expect(Sentieri.ordineNelCammino(grande10),
          Sentieri.ordineNelCammino(mini10) + 1,
          reason: 'il grande non chiude la sua decina: la chiuderebbe il mini');
    });

    test('nessuna schermata scrive un totale a mano', () {
      // SI ENUMERANO I FILE invece di visitarne uno: un totale scritto a mano in
      // una schermata nuova e' il modo in cui i conti tornano a essere due.
      final colpevoli = <String>[];
      for (final voce in Directory('lib/features').listSync(recursive: true)) {
        if (voce is! File || !voce.path.endsWith('.dart')) continue;
        final testo = voce.readAsStringSync();
        for (final forma in const ['di 50', 'su 50', 'di 55', 'su 55']) {
          if (testo.contains("'$forma") || testo.contains(' $forma ')) {
            colpevoli.add('${voce.path.replaceAll("\\", "/")}: "$forma"');
          }
        }
      }
      expect(colpevoli, isEmpty,
          reason: 'questi punti scrivono un totale del sentiero a mano, e un '
              'totale scritto a mano diverge dal dato al primo cambiamento:\n'
              '${colpevoli.join("\n")}');
    });
  });

  group('Le tre righe dicono dove sei, cosa vedi e cosa guadagni', () {
    test('sono TRE, e i numeri vengono dal dato', () {
      for (final sentiero in Sentiero.values) {
        final dove = LeTreRigheDelSentiero.doveSei(sentiero, 17);
        // La riga comincia con la maiuscola, quindi il confronto guarda la
        // stessa cosa che la persona legge, non una sua versione minuscola.
        expect(dove.toLowerCase(), contains('diciassette'),
            reason: 'il numero degli accesi non compare in parole: $dove');
        expect(dove, contains('cinquantacinque'),
            reason: 'il totale della riga non e\' quello del dato: $dove');
        // Nessuna cifra a schermo in questa riga: e' una frase, non un contatore.
        expect(RegExp(r'\d').hasMatch(dove), isFalse,
            reason: 'la riga porta una cifra invece di una parola: $dove');
      }
    });

    test('a zero traguardi la riga esiste e non dice zero', () {
      for (final sentiero in Sentiero.values) {
        final dove = LeTreRigheDelSentiero.doveSei(sentiero, 0);
        expect(dove.toLowerCase(), contains('nessun'),
            reason: 'a cammino vuoto la riga dice "zero", che e\' un contatore '
                'e non una frase: $dove');
        expect(dove, contains('cinquantacinque'));
      }
    });

    test('la riga "cosa vedi" dice cosa E\' la figura, non come funziona', () {
      // **Adesso che il disegno e' buono, spiegarne il meccanismo lo
      // insulterebbe.** Si vietano le parole del tutorial: se una di loro
      // compare, quella riga ha smesso di essere la voce del Maestro.
      const parolePeriTutorial = [
        'tocca', 'scorri', 'premi', 'quando accendi', 'ogni volta che',
        'si illumina', 'si accende una', 'vedrai',
      ];
      for (final sentiero in Sentiero.values) {
        final riga = LeTreRigheDelSentiero.cosaVedi(sentiero).toLowerCase();
        for (final parola in parolePeriTutorial) {
          expect(riga.contains(parola), isFalse,
              reason: 'la riga di ${sentiero.name} spiega il meccanismo con '
                  '"$parola": e\' un tutorial appoggiato sopra un disegno che si '
                  'capisce guardandolo');
        }
        // E' una frase, quindi ha un verbo e finisce col punto.
        expect(riga, endsWith('.'));
        expect(riga.split(' ').length, greaterThan(5));
      }
    });

    test('non si dichiara unico cio\' che unico non e\'', () {
      // **La Costellazione personale puo' dirsi unica, l'Albero della Vita
      // no.** Le dieci Sefirot, i ventidue sentieri e la loro disposizione sono
      // gli stessi per chiunque; il loto e' un simbolo condiviso. Una riga che
      // lasciasse intendere il contrario direbbe il falso, ed e' la stessa
      // famiglia dell'avviso che diceva alla persona che l'app non sapeva chi
      // fosse. Cio' che e' unico sono i frutti maturati e le perle accese: la
      // struttura e' di tutti, il cammino sopra e' suo.
      const rivendicazioni = [
        'nessun altro', 'nessun\'altra', 'solo tuo', 'solo tua', 'unico',
        'unica', 'esiste solo',
      ];
      for (final sentiero in const [Sentiero.albero, Sentiero.loto]) {
        final riga = LeTreRigheDelSentiero.cosaVedi(sentiero).toLowerCase();
        for (final r in rivendicazioni) {
          expect(riga.contains(r), isFalse,
              reason: 'la riga di ${sentiero.name} dichiara unica una struttura '
                  'tradizionale con "$r": l\'Albero della Vita e il loto '
                  'sono di tutti, e cio\' che e\' suo e\' il cammino sopra. '
                  '«$riga»');
        }
        // E la parte che E' sua va nominata: i frutti, le perle. I bersagli
        // del Loto si chiamano PERLE dall'ordine AF, con l'arte nuova.
        final suo = sentiero == Sentiero.albero ? 'tuoi frutti' : 'perle';
        expect(riga, contains(suo),
            reason: 'la riga di ${sentiero.name} non dice quale parte e\' '
                'della persona: la struttura e\' di tutti, ma il cammino sopra '
                'e\' suo, e se non lo si dice la riga descrive un simbolo '
                'qualunque');
      }
      // La Costellazione, invece, e' inventata: la sua rivendicazione e' vera.
      expect(
          LeTreRigheDelSentiero.cosaVedi(Sentiero.costellazione).toLowerCase(),
          contains('nessun altro'),
          reason: 'la Costellazione personale e\' l\'unica delle tre che puo\' '
              'dirsi unica, perche\' e\' inventata: se perde questa riga perde '
              'la cosa che la distingue');
    });

    test('le tre righe restano TRE, e brevi', () {
      for (final sentiero in Sentiero.values) {
        final righe = [
          LeTreRigheDelSentiero.doveSei(sentiero, 25),
          LeTreRigheDelSentiero.cosaVedi(sentiero),
          LeTreRigheDelSentiero.cosaGuadagni,
        ];
        expect(righe, hasLength(3));
        for (final r in righe) {
          expect(r.length, lessThan(95),
              reason: 'questa riga e\' lunga ${r.length} caratteri: non e\' piu\' '
                  'una riga breve, e la voce diventa un pannello di aiuto. «$r»');
        }
      }
    });

    test('i numeri in parole reggono tutto l\'intervallo del cammino', () {
      expect(LeTreRigheDelSentiero.inParole(0), 'zero');
      expect(LeTreRigheDelSentiero.inParole(1), 'uno');
      expect(LeTreRigheDelSentiero.inParole(17), 'diciassette');
      expect(LeTreRigheDelSentiero.inParole(20), 'venti');
      // La vocale cade: ventuno e non ventiuno, ventotto e non ventiotto.
      expect(LeTreRigheDelSentiero.inParole(21), 'ventuno');
      expect(LeTreRigheDelSentiero.inParole(28), 'ventotto');
      expect(LeTreRigheDelSentiero.inParole(31), 'trentuno');
      expect(LeTreRigheDelSentiero.inParole(50), 'cinquanta');
      expect(LeTreRigheDelSentiero.inParole(55), 'cinquantacinque');
      // Ogni numero del cammino ha la sua parola, e nessuna e' una cifra.
      for (var n = 0; n <= 55; n++) {
        expect(RegExp(r'\d').hasMatch(LeTreRigheDelSentiero.inParole(n)), isFalse,
            reason: 'il numero $n non ha una parola');
      }
    });
  });
}
