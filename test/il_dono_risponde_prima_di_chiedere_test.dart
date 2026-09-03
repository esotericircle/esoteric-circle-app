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

    test('in tutti e cinque i Doni la risposta viene PRIMA del gesto', () {
      // **CINQUE DONI, TRE SCHERMATE, UNA REGOLA SOLA.** Alba e Soffio
      // montano la stessa scheda, gli altri tre hanno una schermata loro. La
      // gerarchia però è una: prima la risposta, poi il gesto.
      //
      // **In nessuno dei cinque c'era da inventare la risposta.** L'Arcano
      // aveva già `uprightSummary`, una frase per carta; il Tramonto ha
      // `upright` e `shadow` in runes.dart, quarantotto frasi per
      // ventiquattro rune e due versi; il Sogno ha `posa`, dodici, una per
      // segno lunare. **Erano tutte scritte e nessuna stava in cima**: la
      // prima cosa che si leggeva era un nome, una parola o un'etichetta.
      // Il Risveglio è l'unico che una risposta non ce l'aveva, e per lui è
      // stata composta dal fatto del cielo e dalla lente del Maestro.
      // **E ADESSO IL GESTO NON C'E' PIU' AFFATTO.**
      // Ordine CQ voce 2.03, 3 settembre 2026.
      //
      // CO.17 aveva messo la risposta SOPRA le tre righe del rito, e questa
      // prova misurava proprio quell'ordine. Il fondatore le ha poi fatte
      // togliere del tutto: *l'Arcano annuncia un rito che non esiste*, e la
      // misura della voce 2.00 ha trovato lo stesso compito in tutti e
      // cinque i Doni, non solo li'.
      //
      // **La pretesa cambia di grandezza, non si ammorbidisce**: prima
      // chiedeva che la risposta stesse prima del gesto, adesso chiede che il
      // gesto annunciato non compaia in nessuna delle cinque schermate. E' la
      // stessa legge portata fino in fondo.
      const schermate = <String, String>{
        'lib/features/rituals/day_oracle_screen.dart': 'arcano_sommario',
        'lib/features/rituals/sunset_rune_screen.dart': 'sunset_risposta',
        'lib/features/rituals/dream_rite_screen.dart': 'dream_message_title',
        'lib/features/rituals/ritual_gift_card.dart': 'risposta.titolo',
        'lib/features/rituals/ritual_view.dart': 'rito_ripiego',
      };
      var guardate = 0;
      final conIlRito = <String>[];
      for (final voce in schermate.entries) {
        // **SI LEGGE IL SORGENTE VERO E NON QUELLO SENZA TESTO.** Le chiavi
        // dei widget SONO stringhe, e la porta che toglie il testo le
        // toglierebbe insieme ai commenti.
        final s = File(voce.key).readAsStringSync();
        guardate++;
        expect(s.indexOf(voce.value), greaterThanOrEqualTo(0),
            reason: '${voce.key} non mostra piu ${voce.value}: questa prova '
                'sta guardando una schermata che non esiste piu cosi');
        if (codiceSenzaTesto(s).contains('LeTreRigheDelRito')) {
          conIlRito.add(voce.key);
        }
      }
      // ignore: avoid_print
      print('ORDINE CQ VOCE 2.03: schermate guardate $guardate, che annunciano '
          'ancora un rito ${conIlRito.length}');
      expect(conIlRito, isEmpty,
          reason: 'queste schermate annunciano ancora un rito con le sue tre '
              'righe di istruzioni: ${conIlRito.join(", ")}');
      cardinaleMinimo(guardate, 5,
          cosa: 'schermate dei Doni con una gerarchia da sorvegliare',
          perche: 'Se una schermata sparisse da questo elenco, la sua '
              'gerarchia smetterebbe di essere sorvegliata senza che nessuno '
              'se ne accorga.');
    });

    test('il componente delle tre righe non esiste piu in nessun sorgente',
        () {
      // **CIO' CHE NON DEVE COMPARIRE NON DEVE NEMMENO ESISTERE.** Un
      // componente che nessuno monta e' un invito a rimontarlo, e la prima
      // schermata nuova che ne avesse bisogno lo troverebbe li' pronto,
      // insieme al compito che il fondatore ha fatto togliere.
      final vivo = File('lib/design_system/components/le_tre_righe_del_rito.dart')
          .existsSync();
      // ignore: avoid_print
      print('ORDINE CQ VOCE 2.03: il componente delle tre righe esiste $vivo');
      expect(vivo, isFalse,
          reason: 'il componente delle tre righe del rito e ancora nel '
              'progetto: nessuno lo monta, ma il primo che ne avesse bisogno '
              'lo troverebbe pronto');
    });

    test('a schermo il titolo viene PRIMA del gesto', () {
      final scheda = codiceSenzaTesto(
          File('lib/features/rituals/ritual_gift_card.dart')
              .readAsStringSync());
      final titolo = scheda.indexOf('risposta.titolo');
      final risposta = scheda.indexOf('risposta.risposta');
      final treRighe = scheda.indexOf('LeTreRigheDelRito');
      // **NON C'E' PIU', ordine CQ voce 2.03**: `indexOf` torna meno uno, e
      // una pretesa scritta su quel meno uno direbbe il falso. Si dichiara
      // qui che l'assenza e' voluta, e la sorveglia la prova qui sopra.
      expect(treRighe, -1,
          reason: 'le tre righe del rito sono tornate nella scheda del Dono');
      expect(titolo, greaterThanOrEqualTo(0),
          reason: 'la scheda non mostra più il titolo della risposta');
      expect(risposta, greaterThan(titolo),
          reason: 'nella scheda la risposta viene prima del titolo');
    });
  });
}
