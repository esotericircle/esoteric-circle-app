// ignore_for_file: avoid_print
import 'dart:math';

import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/responsi/la_forma_del_responso.dart';
import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread_type.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/core/tarot/voce_della_stesa.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'ga06_campioni_per_i_lettori_ciechi_test.dart' as campioni;

/// **QUANTO E' LUNGO IL CONSIGLIO DOPO L'ORDINE DF.**
///
/// **Perche' questa prova esiste.** Il fondatore, nell'ordine DF: *"la
/// lunghezza dei testi e la divisione dei paragrafi va bene attualmente"*. Un
/// compositore nuovo che scrive piu' varieta' scrive anche piu' caratteri, e
/// oltre il tetto la bolla **viene troncata**: la varieta' si pagherebbe con
/// una frase mozza, che e' il peggiore dei due mali.
///
/// **RIFATTA DALL'ORDINE GA, voci GA.03, GA.05 e GA.07, 20 ottobre 2026.**
/// Il fondatore, 19 ottobre 2026: *"tutte le risposte composte da paragrafi
/// ognuno con tra 40 a 50 parole ognuno"*. La grandezza misurata sono le
/// parole di ogni paragrafo (`LaFormaDelResponso.parole`), fra 40 e 50 in
/// ogni composizione.
///
/// **RIFATTA DI NUOVO DALL'ORDINE GA voce GA.06, 21 ottobre 2026.** LAPIDE:
/// "ogni forma sta nella fascia dichiarata" e "la somma delle fasce sta fra 40
/// e 50". Garantivano la misura sommando le fasce di otto forme per fessura;
/// la voce nuova non ha piu' fessure a forme fisse: la risposta poggia sulla
/// carta chiave (`LaCartaNellaRisposta`) e sulla domanda (`LaDomandaLetta`),
/// e i posti di un paragrafo si scelgono fra quelli che stanno nella misura.
/// **Il "in ogni composizione" si prova enumerando**: ogni carta-verso come
/// carta chiave, in ognuna delle quattro stese, con ognuna delle domande del
/// campione dei lettori ciechi e senza domanda, con ogni forma di cortesia.
void main() {
  test('OGNI CARTA CHIAVE, OGNI STESA, OGNI DOMANDA: fra 40 e 50 parole', () {
    final caso = Random(1406);
    final domande = <String?>[null, ...campioni.domande.map((d) => d.$1)];
    var quante = 0;
    final fuori = <String>[];
    var rMin = 1 << 30, rMax = 0, fMin = 1 << 30, fMax = 0;
    final prima = LaMarcaDelGenere.formaCorrente;
    try {
      for (final c in TarotDeck.cards) {
        for (final rovesciata in [false, true]) {
          for (final tipo in TarotSpreadType.values) {
            for (final domanda in domande) {
              LaMarcaDelGenere.formaCorrente =
                  CourtesyForm.values[caso.nextInt(CourtesyForm.values.length)];
              final altre = TarotDeck.cards.where((x) => x != c).toList()
                ..shuffle(caso);
              var a = 0;
              final carte = [
                for (var i = 0; i < tipo.posizioni.length; i++)
                  DrawnCard(
                      card: i == 0 ? c : altre[a++],
                      position: tipo.posizioni[i],
                      reversed: i == 0 ? rovesciata : caso.nextDouble() < 0.3),
              ];
              final s = TarotSpread(carte);
              final r = VoceDellaStesa.responsoDiCasa(
                  s, TarotTopic.values[caso.nextInt(16)],
                  domandaScritta: domanda, chiave: carte.first);
              quante++;
              final pr = LaFormaDelResponso.parole(r.risposta);
              final pf = LaFormaDelResponso.parole(r.cosaFare);
              rMin = min(rMin, pr);
              rMax = max(rMax, pr);
              fMin = min(fMin, pf);
              fMax = max(fMax, pf);
              final difetti = ResponsoInterpretato(
                arte: ArteInterpretata.tarocchi,
                titolo: r.titolo,
                risposta: r.risposta,
                cosaFare: r.cosaFare,
              ).difetti(conLaFonte: false);
              if (difetti.isNotEmpty) {
                fuori.add('${c.name} ${rovesciata ? 'rovesciata' : ''} '
                    '${tipo.name}, "$domanda": ${difetti.join('; ')}');
              }
            }
          }
        }
      }
    } finally {
      LaMarcaDelGenere.formaCorrente = prima;
    }
    print('ORDINE GA VOCE 06: composizioni $quante, risposta da $rMin a $rMax '
        'parole, cosa fare da $fMin a $fMax, fuori misura ${fuori.length}');
    cardinaleMinimo(quante, 156 * 4 * 36,
        cosa: 'composizioni della lettura di casa',
        perche: 'Con meno composizioni la prova direbbe "in ogni '
            'composizione" guardandone poche.');
    expect(fuori, isEmpty, reason: fuori.take(8).join('\n'));
  });

  test('LE STESE ESTRATTE DAVVERO, con la loro carta chiave e il cielo', () {
    // Qui la carta chiave la sceglie la lettura (`TarotReading.chiaveDi`), e
    // il cielo porta figure, cosi' la scelta senza ripetere salta davvero.
    const cielo = 'Oggi Marte forma una quadratura con il Sole di nascita, '
        'che si sta sciogliendo.';
    var quante = 0;
    final fuori = <String>[];
    for (final tipo in TarotSpreadType.values) {
      for (final t in TarotTopic.values) {
        for (var seme = 0; seme < 30; seme++) {
          final s = TarotSpread.draw(
              seed: seme * 31 + t.index, posizioni: tipo.posizioni);
          for (final c in [null, cielo]) {
            for (final domanda in [null, 'Che cosa devo fare adesso?']) {
              final r = VoceDellaStesa.responsoDiCasa(s, t,
                  domandaScritta: domanda, fattoDelCielo: c);
              quante++;
              for (final p in [r.risposta, r.cosaFare]) {
                if (!LaFormaDelResponso.aMisura(p)) {
                  fuori.add('${tipo.name} ${t.name} seme $seme: '
                      '${LaFormaDelResponso.parole(p)} parole, "$p"');
                }
              }
            }
          }
        }
      }
    }
    cardinaleMinimo(quante, 4 * 16 * 30 * 4,
        cosa: 'composizioni delle stese estratte');
    expect(fuori, isEmpty, reason: fuori.take(6).join('\n'));
  });
}
