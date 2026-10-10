import 'package:esoteric_circle/core/astro/moon_phase.dart';
import 'package:esoteric_circle/core/entitlement/plan_catalog.dart';
import 'package:esoteric_circle/core/rituals/sunset_rune_corpus.dart';
import 'package:esoteric_circle/core/viaggio/la_domanda_del_viaggio.dart';
import 'package:flutter_test/flutter_test.dart';

/// **UN'ETICHETTA PER PERSONE NON FA DA CHIAVE, in nessuno dei tre posti in cui
/// lo faceva.** Ordine DI voce 01, 12 settembre 2026.
///
/// **LA FAMIGLIA DEL DIFETTO CAPITALE.** Nel Viaggio il tema della domanda si
/// scriveva con l'etichetta (*"Una scelta da fare"*) e si cercava con
/// l'identificatore (`scelta`): non combaciavano mai, e ogni discesa cadeva sul
/// ramo di chi non ha chiesto niente. **Un difetto cosi' non da' errori di
/// compilazione**, quindi l'ordine chiede di censire tutta l'app e di riparare
/// allo stesso modo ovunque. Il censimento ne ha trovati altri due:
///
/// - **la matrice dei piani**, le cui righe si cercavano col testo della
///   tabella: ritoccare una parola bastava a far ripiegare in silenzio la
///   memoria dei Maestri su *gratis per tutti*, i limiti giornalieri su
///   *illimitato*, la Profonda su *tolta a chi l'ha pagata*;
/// - **il registro lunare delle rune del tramonto**, una mappa indicizzata col
///   nome italiano della fase: un nome cambiato e il registro cadeva su quello
///   neutro senza dirlo.
///
/// **I primi due sono curati col tipo**, e questa prova tiene fermo che ogni
/// chiave esista una volta sola. **Il terzo con una guardia**, perche' nel
/// modulo lunare il nome e' l'identita' stessa della fase, e passarlo a un tipo
/// vorrebbe dire rifare il motore astronomico: qui si pretende che le chiavi
/// del registro siano **esattamente** i nomi che la fase sa produrre.
///
/// **VISTA ROSSA tre volte, una per posto**: tolta la chiave alla riga della
/// memoria, la prova ha detto *"memoria: 0 righe"*; cambiata una chiave del
/// registro in *"Luna Piena"*, ha nominato la fase rimasta senza frase,
/// *"Luna piena"*; la terza meta' non si puo' rompere col testo, perche' l'id delle
/// domande nasce dall'enum, e la prova tiene fermo che le sei domande coprano
/// i sei temi una volta ciascuno.
void main() {
  test('ogni riga che il codice legge sta nella matrice una volta sola', () {
    final sbagliate = <String>[];
    for (final chiave in RigaDelPiano.values) {
      final quante =
          PlanCatalog.matrix.where((r) => r.chiave == chiave).length;
      if (quante != 1) sbagliate.add('${chiave.name}: $quante righe');
    }
    // ignore: avoid_print
    print('ORDINE DI VOCE 01: chiavi della matrice ${RigaDelPiano.values.length}, '
        'sbagliate ${sbagliate.length}');
    expect(sbagliate, isEmpty,
        reason: 'QUESTE RIGHE DELLA MATRICE NON SI TROVANO UNA VOLTA SOLA: '
            '$sbagliate.\nOgni ricerca per una riga assente ripiega in '
            'silenzio: la memoria diventa gratis per tutti, un limite '
            'giornaliero diventa illimitato, la Profonda sparisce a chi l\'ha '
            'pagata. Prima dell\'ordine DI bastava ritoccare una parola della '
            'tabella per arrivarci.');
  });

  test('le chiavi del registro lunare sono esattamente le fasi possibili', () {
    // Le fasi che il modulo lunare sa nominare, lette dal modulo stesso su
    // tutto il ciclo: nessun elenco scritto qui a mano.
    final possibili = <String>{
      for (var i = 0; i <= 4000; i++) MoonPhase.nomeItaliano(i / 4000),
    };
    final registrate = SunsetRuneCorpus.registri.keys.toSet();
    final senzaRegistro = possibili.difference(registrate);
    final orfane = registrate.difference(possibili);
    // ignore: avoid_print
    print('ORDINE DI VOCE 01: fasi possibili ${possibili.length}, chiavi del '
        'registro ${registrate.length}');
    expect(possibili.length, greaterThanOrEqualTo(8),
        reason: 'il modulo lunare nomina meno di otto fasi: o e\' cambiato, o '
            'questa prova non lo sta interrogando');
    expect(senzaRegistro, isEmpty,
        reason: 'QUESTE FASI NON HANNO UNA FRASE NEL REGISTRO DEL TRAMONTO: '
            '$senzaRegistro. Il registro e\' indicizzato col nome italiano '
            'della fase, e una fase senza chiave cade sulla frase neutra '
            'senza che nessuno se ne accorga.');
    expect(orfane, isEmpty,
        reason: 'QUESTE CHIAVI DEL REGISTRO NON SONO NESSUNA FASE: $orfane. '
            'La loro frase non si leggera\' mai.');
  });

  test('le sei domande del Viaggio coprono i sei temi, una volta ciascuno', () {
    final chiavi = [for (final d in LaDomandaDelViaggio.gliaScritte) d.chiave];
    expect(chiavi.toSet(), TemaDellaDomanda.values.toSet(),
        reason: 'le domande scritte non coprono esattamente i sei temi');
    expect(chiavi.length, TemaDellaDomanda.values.length,
        reason: 'due domande scritte portano lo stesso tema');
    // E l'unica porta da una stringa al tipo accetta solo gli id: con
    // un'etichetta restituisce nullo, e non un tema a caso.
    for (final d in LaDomandaDelViaggio.gliaScritte) {
      expect(TemaDellaDomanda.daId(d.id), d.chiave);
      expect(TemaDellaDomanda.daId(d.tema), isNull,
          reason: 'l\'etichetta "${d.tema}" viene accettata come tema: e\' '
              'esattamente la porta da cui era entrato il difetto capitale');
    }
  });
}
