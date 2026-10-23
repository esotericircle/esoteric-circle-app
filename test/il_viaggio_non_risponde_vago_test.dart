// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/viaggio/le_guardie_del_responso.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **IL VIAGGIO PRENDE POSIZIONE NELLA PRIMA FRASE. Ordine ES voce 25, 29 e
/// 30 settembre 2026.**
///
/// Dalla ET.08: *"sì alla riserva che prende posizione, come la propone
/// Code."*, *"Confermo, dobbiamo risolvere tutto."*. La riserva prende
/// posizione; le prime frasi del modello che reggono alle guardie ma restano
/// vaghe tenevano il conto a 14 e 15 su 20. Qui la guardia della prima
/// frase si misura contro i giudizi alla cieca del banco del Viaggio
/// (`docs/collaudo/ET/ciechi/`): sul giro 3, dove e' stata tarata, sul giro
/// 1, che non ha guardato, e sui due fascicoli del 30 settembre.
///
/// **Due misure, dal terzo giro.** Le prime frasi senza una condizione si
/// misurano come prima: quante senza posizione la guardia chiede di nuovo, e
/// quante buone prende per sbaglio. Le prime frasi con una condizione (*"di
/// sì, se..."*) hanno la loro regola, di struttura: passa solo la condizione
/// che nomina un tempo o un'azione che si fa nel mondo. Li' la guardia chiede
/// di nuovo anche frasi che certi giudici accettano, ed e' voluto: le
/// condizioni che sono un modo di sentirsi hanno la posizione una volta si' e
/// una no secondo il giudice, quelle col passo sempre.
void main() {
  final salute = RegExp(
      r'malat|veterinar|salute|operaz|ospedal|sintom|diagnos|visita|esami',
      caseSensitive: false);
  final conLaCondizione = RegExp(
      r'(?:dicono|dice|indicano|indica|mostrano|mostra)(?![a-zàèéìòù])'
      r'.*?(?<![a-zàèéìòù])(?:se|a condizione (?:che|di)|a patto (?:che|di)|'
      r'purché|ma prima|ma non senza|finché)(?![a-zàèéìòù])',
      caseSensitive: false);

  String primaFraseDi(String r) => r.split(RegExp(r'(?<=[.!?])\s')).first;

  /// Le risposte del fascicolo [giro], ognuna col suo giudizio.
  List<({String domanda, String risposta, bool senzaPosizione})> voci(
      String giro) {
    const c = 'docs/collaudo/ET/ciechi/';
    final chiave =
        (jsonDecode(File('${c}chiave_viaggio_$giro.json').readAsStringSync())
                as Map)
            .cast<String, dynamic>();
    final giudizi = <String, dynamic>{};
    for (final p in [1, 2]) {
      giudizi.addAll((jsonDecode(
              File('${c}giudizio_viaggio_${giro}_parte$p.json')
                  .readAsStringSync()) as Map)
          .cast<String, dynamic>());
    }
    return [
      for (final e in chiave.entries)
        // Alle domande di salute la guardia della posizione non vale.
        if (!salute
            .hasMatch((e.value as Map<String, dynamic>)['domanda'] as String))
          (
            domanda: (e.value as Map<String, dynamic>)['domanda'] as String,
            risposta: (e.value as Map<String, dynamic>)['risposta'] as String,
            senzaPosizione: giudizi[e.key]['posizione'] == 'no',
          ),
    ];
  }

  ({int noPrese, int no, int siPrese, int si}) conta(String giro) {
    var noPrese = 0, no = 0, siPrese = 0, si = 0;
    for (final v in voci(giro)) {
      if (conLaCondizione.hasMatch(primaFraseDi(v.risposta))) continue;
      if (LeGuardieDelResponso.chiedeIlGesto(v.domanda)) continue;
      final presa =
          LeGuardieDelResponso.rimandaLaDomanda(v.risposta, domanda: v.domanda);
      if (v.senzaPosizione) {
        no++;
        if (presa) noPrese++;
      } else {
        si++;
        if (presa) siPrese++;
      }
    }
    return (noPrese: noPrese, no: no, siPrese: siPrese, si: si);
  }

  // **LE ALTRE PRIME FRASI**, quelle senza una condizione e a una domanda
  // che non chiede il gesto: qui lavorano le forme (la scelta rimandata, il
  // consiglio astratto). Sono poche: quasi tutte le prime frasi del Viaggio
  // cadono nelle due misure di struttura qui sotto.
  test(
      'senza una condizione e senza una domanda sul come: le forme vaghe si '
      'chiedono di nuovo, e nessuna buona', () {
    var noPrese = 0, no = 0, siPrese = 0, si = 0;
    for (final giro in const ['giro3', 'giro1', 'es1mix', 'es2mix']) {
      final g = conta(giro);
      noPrese += g.noPrese;
      no += g.no;
      siPrese += g.siPrese;
      si += g.si;
    }
    print('ORDINE ES VOCE 25, le altre prime frasi: senza posizione prese '
        '$noPrese su $no, buone prese $siPrese su $si');
    cardinaleMinimo(no + si, 50, cosa: 'prime frasi senza condizione');
    expect(noPrese, greaterThanOrEqualTo(sogliaDelleAltre));
    expect(siPrese, 0);
  });

  test(
      'alla domanda sul come o sul che cosa fare: passa solo la prima frase '
      'che nomina un tempo o un passo', () {
    var colPasso = 0, colPassoConPosizione = 0, colPassoFermate = 0;
    var senzaPasso = 0, senzaPassoPrese = 0, senzaPassoSenzaPosizione = 0;
    for (final giro in const ['giro1', 'giro3', 'es1mix', 'es2mix', 'es3mix']) {
      for (final v in voci(giro)) {
        if (!LeGuardieDelResponso.chiedeIlGesto(v.domanda)) continue;
        final prima = primaFraseDi(v.risposta);
        final presa = LeGuardieDelResponso.rimandaLaDomanda(v.risposta,
            domanda: v.domanda);
        if (LeGuardieDelResponso.nominaUnPasso(prima)) {
          colPasso++;
          if (!v.senzaPosizione) colPassoConPosizione++;
          if (presa) colPassoFermate++;
        } else {
          senzaPasso++;
          if (presa) senzaPassoPrese++;
          if (v.senzaPosizione) senzaPassoSenzaPosizione++;
        }
      }
    }
    print('ORDINE ES VOCE 25, domande sul come: prime frasi col tempo o col '
        'passo $colPasso, con la posizione per i giudici '
        '$colPassoConPosizione, fermate dalla guardia $colPassoFermate; '
        'senza passo $senzaPasso, senza posizione per i giudici '
        '$senzaPassoSenzaPosizione, chieste di nuovo $senzaPassoPrese');
    cardinaleMinimo(colPasso, 30, cosa: 'prime frasi col passo');
    cardinaleMinimo(senzaPasso, 50, cosa: 'prime frasi senza passo');
    expect(colPassoConPosizione * 4, greaterThanOrEqualTo(colPasso * 3),
        reason: 'meno di tre prime frasi col passo su quattro prendono '
            'posizione per i giudici: la regola di struttura non regge');
    expect(senzaPassoSenzaPosizione * 3, greaterThanOrEqualTo(senzaPasso * 2),
        reason: 'le prime frasi senza passo prendono posizione per i '
            'giudici oltre una volta su tre: la regola ferma frasi buone');
    expect(senzaPassoPrese, senzaPasso,
        reason: 'una risposta al come senza un passo non si chiede di nuovo');
  });

  test(
      'con una condizione: passa solo quella che nomina un tempo o un passo, '
      'e quelle i giudici le danno con la posizione', () {
    var colPasso = 0, colPassoSenzaPosizione = 0;
    var senzaPasso = 0, senzaPassoPrese = 0, senzaPassoSenzaPosizione = 0;
    final colPassoFermate = <String>[];
    for (final giro in const ['giro1', 'giro3', 'es1mix', 'es2mix']) {
      for (final v in voci(giro)) {
        final prima = primaFraseDi(v.risposta);
        if (!conLaCondizione.hasMatch(prima)) continue;
        final presa = LeGuardieDelResponso.rimandaLaDomanda(v.risposta,
            domanda: v.domanda);
        if (LeGuardieDelResponso.condizioneSenzaPasso(prima)) {
          senzaPasso++;
          if (presa) senzaPassoPrese++;
          if (v.senzaPosizione) senzaPassoSenzaPosizione++;
        } else {
          colPasso++;
          if (v.senzaPosizione) colPassoSenzaPosizione++;
          if (presa) colPassoFermate.add(prima);
        }
      }
    }
    print('ORDINE ES VOCE 25, con una condizione: col tempo o col passo '
        '$colPasso, senza posizione per i giudici $colPassoSenzaPosizione, '
        'fermate dalla guardia ${colPassoFermate.length}; senza passo '
        '$senzaPasso, senza posizione per i giudici '
        '$senzaPassoSenzaPosizione, chieste di nuovo $senzaPassoPrese');
    cardinaleMinimo(colPasso, 8, cosa: 'condizioni col passo');
    cardinaleMinimo(senzaPasso, 60, cosa: 'condizioni senza passo');
    expect(colPassoSenzaPosizione, lessThanOrEqualTo(1),
        reason: 'le condizioni col passo non prendono posizione per i '
            'giudici: la regola di struttura non regge');
    expect(colPassoFermate.length, lessThanOrEqualTo(1),
        reason: 'la guardia ferma condizioni che nominano un passo: '
            '$colPassoFermate');
    expect(senzaPassoPrese, senzaPasso,
        reason: 'una condizione che e\' un modo di sentirsi e\' passata');
    // E la domanda sul come non prende un si'.
    expect(
        LeGuardieDelResponso.rimandaLaDomanda(
            'I segni del viaggio dicono di sì, se prima di sabato chiami una '
            'amica.',
            domanda: 'Come faccio a sentirmi meno sola la sera?'),
        isTrue);
    expect(
        LeGuardieDelResponso.rimandaLaDomanda(
            'I segni del viaggio dicono di sì, se prima di sabato chiedi a '
            'chi ti ha fatto l\'offerta quanto conta lo stipendio.',
            domanda: 'Accetto l\'offerta di lavoro a Milano?'),
        isFalse);
  });
}

/// Quante prime frasi senza posizione, fra le altre, la guardia chiede di
/// nuovo: riletto dalla misura.
const int sogliaDelleAltre = 8;
