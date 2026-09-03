import 'dart:io';

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/rituals/rito_alba.dart';
import 'package:esoteric_circle/core/rituals/rito_alba_corpus.dart';
import 'package:esoteric_circle/core/rituals/risposta_del_dono.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'codice_senza_testo.dart';

/// **IL DONO RISPONDE PRIMA DI CHIEDERE.**
/// Ordine CO voce 17, 3 settembre 2026.
///
/// La gerarchia dettata dal fondatore, per esteso: un titolo diretto che sia
/// già una risposta; la risposta vera; il gesto col suo scopo; la parola del
/// giorno, spiegata; la fonte, breve e in fondo.
///
/// **I punti dal terzo al quinto c'erano già.** Quelli che mancavano sono i
/// primi due, e la loro mancanza aveva una forma precisa: la prima cosa che si
/// leggeva aprendo un Dono era "Cosa fai", cioè un'istruzione. Chi apriva
/// doveva compiere il gesto per scoprire che cosa il giorno gli stesse
/// dicendo. **Un dono che chiede di lavorare prima di rispondere non è un
/// dono, è un compito.**
///
/// Questa guardia sorveglia tre cose diverse, e la terza è quella che le altre
/// due da sole non prenderebbero: che le frasi esistano, che siano scritte
/// come una risposta e non come un sommario, e **che a schermo arrivino nel
/// posto della gerarchia**, cioè prima del gesto.
void main() {
  group('le frasi esistono, per ogni lente e ogni fatto', () {
    test('nessuna coppia di Maestro e fatto del cielo resta senza risposta',
        () {
      var coppie = 0;
      for (final maestro in Maestro.values) {
        for (final fatto in DatoDelCielo.values) {
          final r = RispostaDelDono.perIlRisveglio(
            maestro: maestro,
            fatto: fatto,
            parola: 'Direzione',
            valoreDelFatto: 'Bilancia',
          );
          coppie++;
          expect(r.titolo.trim(), isNotEmpty,
              reason: '$maestro con $fatto non ha titolo');
          expect(r.risposta.trim(), isNotEmpty,
              reason: '$maestro con $fatto non ha risposta');
        }
      }
      cardinaleMinimo(coppie, Maestro.values.length * DatoDelCielo.values.length,
          cosa: 'coppie di lente e fatto del cielo',
          perche: 'Se un Maestro o un fatto sparisse dai loro elenchi, questa '
              'prova girerebbe su meno coppie e resterebbe verde per non aver '
              'guardato la coppia che manca.');
    });

    test('la parola del giorno entra davvero nel titolo', () {
      for (final maestro in Maestro.values) {
        for (final fatto in DatoDelCielo.values) {
          final r = RispostaDelDono.perIlRisveglio(
            maestro: maestro,
            fatto: fatto,
            parola: 'Soglia',
            valoreDelFatto: '6:42',
          );
          expect(r.titolo.toLowerCase(), contains('soglia'),
              reason: 'il titolo di $maestro con $fatto non nomina la parola '
                  'del giorno: senza di lei è una frase che varrebbe per '
                  'qualunque giorno, e un titolo che vale sempre non è una '
                  'risposta');
          expect(r.titolo, isNot(contains('{')),
              reason: 'un segnaposto è rimasto nel titolo di $maestro');
        }
      }
    });

    test('il fatto misurato entra davvero nella risposta', () {
      for (final maestro in Maestro.values) {
        for (final fatto in DatoDelCielo.values) {
          final r = RispostaDelDono.perIlRisveglio(
            maestro: maestro,
            fatto: fatto,
            parola: 'Soglia',
            valoreDelFatto: 'Acquario',
          );
          expect(r.risposta, contains('Acquario'),
              reason: 'la risposta di $maestro con $fatto non nomina il dato '
                  'del cielo: è il solo ingrediente misurato che ha, e senza '
                  'di lui resta una opinione');
          expect(r.risposta, isNot(contains('{')));
        }
      }
    });
  });

  group('sono scritte come una risposta, non come un sommario', () {
    test('nessun titolo fa una domanda o rimanda a ciò che segue', () {
      for (final maestro in Maestro.values) {
        for (final fatto in DatoDelCielo.values) {
          final t = RispostaDelDono.perIlRisveglio(
            maestro: maestro,
            fatto: fatto,
            parola: 'Passo',
            valoreDelFatto: 'Ariete',
          ).titolo;
          expect(t, isNot(contains('?')),
              reason: 'il titolo di $maestro con $fatto fa una domanda: chi '
                  'apre il Dono la domanda la porta già con sé, ed è venuto qui '
                  'per la risposta');
          // **UN TITOLO CHE RIMANDA NON E' UNA RISPOSTA, E' UN SOMMARIO.** Il
          // difetto che questa voce chiude si apriva proprio con "Cosa fai".
          for (final rimando in const [
            'Cosa fai',
            'Cosa ti resta',
            'Ecco',
            'Leggi',
            'Scopri',
            'Qui sotto',
          ]) {
            expect(t.toLowerCase(), isNot(contains(rimando.toLowerCase())),
                reason: 'il titolo di $maestro con $fatto rimanda con '
                    '"$rimando" invece di dire la cosa');
          }
          expect(t.trim().endsWith('.'), isTrue,
              reason: 'il titolo di $maestro con $fatto non è una frase '
                  'chiusa: una risposta finisce, e una etichetta no');
        }
      }
    });

    test('nessuna risposta promette un esito', () {
      // **LA REGOLA E' GIA' DI CASA**, ed è la stessa che governa il `perche`
      // di ogni parola del corpus: si dice che cosa il cielo di oggi indica,
      // mai che cosa succederà. Una risposta che promette è una previsione, e
      // questa app non ne fa.
      const promesse = [
        'otterrai',
        'riceverai',
        'vincerai',
        'guadagnerai',
        'ti porterà',
        'andrà bene',
        'ti aspetta',
        'succederà',
        'incontrerai',
        'troverai',
      ];
      final colpe = <String>[];
      for (final maestro in Maestro.values) {
        for (final fatto in DatoDelCielo.values) {
          final r = RispostaDelDono.perIlRisveglio(
            maestro: maestro,
            fatto: fatto,
            parola: 'Passo',
            valoreDelFatto: 'Ariete',
          );
          final tutto = '${r.titolo} ${r.risposta}'.toLowerCase();
          for (final p in promesse) {
            if (tutto.contains(p)) colpe.add('$maestro con $fatto: "$p"');
          }
        }
      }
      expect(colpe, isEmpty,
          reason: 'queste risposte promettono un esito invece di dire cosa il '
              'cielo indica:\n${colpe.join("\n")}');
    });
  });

  group('arrivano dove la gerarchia le vuole', () {
    test('ogni rito composto porta la sua risposta, per un anno di giorni', () {
      var riti = 0;
      var conRisposta = 0;
      for (var g = 0; g < 365; g++) {
        final giorno = DateTime(2026, 1, 1).add(Duration(days: g));
        for (final maestro in Maestro.values) {
          final rito = RitoAlba.componi(
              giorno, maestro, CieloDiStamattina.per(giorno));
          if (rito == null) continue;
          riti++;
          if (rito.risposta.titolo.trim().isNotEmpty &&
              rito.risposta.risposta.trim().isNotEmpty) {
            conRisposta++;
          }
        }
      }
      cardinaleMinimo(riti, 300,
          cosa: 'riti composti su un anno di giorni',
          perche: 'Se la composizione smettesse di produrre riti, questa prova '
              'non troverebbe nessuna risposta mancante per non aver composto '
              'niente.');
      expect(conRisposta, riti,
          reason: 'su $riti riti composti, solo $conRisposta portano una '
              'risposta: il Dono torna a chiedere prima di rispondere');
    });

    test('a schermo il titolo viene PRIMA del gesto', () {
      final scheda = codiceSenzaTesto(
          File('lib/features/rituals/ritual_gift_card.dart')
              .readAsStringSync());
      final titolo = scheda.indexOf('risposta.titolo');
      final risposta = scheda.indexOf('risposta.risposta');
      final treRighe = scheda.indexOf('LeTreRigheDelRito');
      expect(titolo, greaterThanOrEqualTo(0),
          reason: 'la scheda non mostra più il titolo della risposta');
      expect(risposta, greaterThan(titolo),
          reason: 'la risposta viene prima del suo titolo');
      expect(treRighe, greaterThan(risposta),
          reason: 'IL GESTO VIENE PRIMA DELLA RISPOSTA, ed è esattamente il '
              'difetto che questa voce chiude: chi apre il Dono legge un ordine '
              'e deve eseguirlo per sapere che cosa il giorno gli stia '
              'dicendo');
    });
  });
}
