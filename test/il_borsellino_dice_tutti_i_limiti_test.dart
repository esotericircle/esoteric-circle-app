import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/design_system/components/borsellino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL BORSELLINO DICE TUTTO, E INVITA. Ordine BB voce 02.
///
/// **Il fondatore ha aperto il borsellino e ha trovato una riga sola**: "Oggi
/// te ne restano 3 su 3 domande ai Maestri". Parole sue: "l'italiano non e' il
/// massimo... ma comunque perche' dare solo questa informazione? E le altre
/// limitate dal piano free? E ci dovrebbe anche essere un invito elegante ad
/// abbonarsi."
///
/// **Aveva ragione al numero: i budget sono QUATTRO**, contati nel codice che
/// li conta. Il foglio ne mostrava uno.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues(const {}));

  test('BB.02: i limiti enumerati sono quattro, e vengono dal codice', () {
    final borsa = QuestionAllowance();
    final righe = PortafoglioDelCerchio.tuttiILimiti(borsa, Tier.free);
    // ignore: avoid_print
    for (final r in righe) {
      // ignore: avoid_print
      print('ORDINE BB VOCE 02: "$r"');
    }
    expect(righe, hasLength(4),
        reason: 'i limiti mostrati sono ${righe.length} invece di quattro: il '
            'foglio mostra meno di quello che il piano limita');

    // **CIASCUNO NOMINA LA PROPRIA COSA**, se no e' un elenco di numeri.
    //
    // **Si cerca la RADICE e non il plurale**: a zero rimanenti la riga usa il
    // singolare, ed e' giusto cosi'. Cercare "approfondimenti" faceva cadere
    // la prova su una frase scritta bene.
    for (final cosa in const [
      'domand',
      'approfondiment',
      'confront',
      'gettat',
    ]) {
      expect(righe.any((r) => r.contains(cosa)), isTrue,
          reason: 'nessuna riga parla di "$cosa"');
    }
  });

  test('BB.02: la lingua e quella che il fondatore ha chiesto', () {
    // **LA COSA PRIMA DEL CONTO, e l'"oggi" in coda.** Prima si leggeva "Oggi
    // te ne restano 3 su 3 domande ai Maestri": il numero arrivava prima
    // della cosa, e chi legge doveva tornare indietro.
    const uno_ = 'domanda';
    const molti_ = 'domande';
    final tre = QuestionAllowance.residuoDiCosa(3, 3,
        uno: uno_, molti: molti_, femminile: true);
    final uno = QuestionAllowance.residuoDiCosa(1, 3,
        uno: uno_, molti: molti_, femminile: true);
    final zero = QuestionAllowance.residuoDiCosa(0, 3,
        uno: uno_, molti: molti_, femminile: true);
    // ignore: avoid_print
    print('ORDINE BB VOCE 02: al plurale "$tre"; al singolare "$uno"; a zero '
        '"$zero"');

    expect(tre, 'Ti restano 3 domande su 3, oggi');
    expect(uno, 'Ti resta 1 domanda su 3, oggi',
        reason: 'uno non e "1 domande": la regola del singolare vale anche '
            'qui, come nel resto dell app');
    expect(zero, 'Non ti resta nessuna domanda, oggi',
        reason: 'a zero non si dice "0 su 3", che e un conto e non una frase');
  });

  test('BB.02: l invito c e per chi e sul gratuito, e porta le tre doti', () {
    final invito = PortafoglioDelCerchio.invitoAdAbbonarsi(Tier.free);
    // ignore: avoid_print
    print('ORDINE BB VOCE 02: l invito dice "$invito"');
    expect(invito, isNotNull,
        reason: 'chi e sul piano gratuito non riceve nessun invito');
    // **LE TRE DOTI, coi numeri del fondatore**, lette dal catalogo dei piani
    // e non scritte a mano nel foglio.
    for (final numero in const ['500', '1.500', '3.000']) {
      expect(invito, contains(numero),
          reason: 'la dote di $numero Eos non compare nell invito');
    }
    for (final nome in const ['Iniziato', 'Adepto', 'Illuminato']) {
      expect(invito, contains(nome), reason: 'il piano $nome non e nominato');
    }
  });

  test('BB.02: a chi ha gia un piano non si vende quello che ha', () {
    // **LA CONTROPROVA.** Un invito ad abbonarsi mostrato a chi e' gia'
    // abbonato e' peggio di nessun invito: dice alla persona che l app non sa
    // chi e'.
    for (final t in const [Tier.tier1, Tier.tier2, Tier.tier3]) {
      // ignore: avoid_print
      print('ORDINE BB VOCE 02: al piano ${t.name} l invito vale '
          '${PortafoglioDelCerchio.invitoAdAbbonarsi(t)}');
      expect(PortafoglioDelCerchio.invitoAdAbbonarsi(t), isNull,
          reason: 'si invita ad abbonarsi chi ha gia il piano ${t.name}');
    }
  });

  test('BB.02: e non si promette nessuna data che il prodotto non mantiene',
      () {
    final invito = PortafoglioDelCerchio.invitoAdAbbonarsi(Tier.free)!;
    for (final promessa in const [
      'subito',
      'immediat',
      'domani',
      'entro',
      'riceverai',
    ]) {
      expect(invito.toLowerCase(), isNot(contains(promessa)),
          reason: 'l invito promette "$promessa": gli abbonamenti non sono '
              'ancora acquistabili, e una data promessa e non mantenuta vale '
              'meno di un silenzio onesto');
    }
  });
}
