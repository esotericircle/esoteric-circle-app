// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/rituals/guide_animal_derivation.dart';
import 'package:esoteric_circle/core/viaggio/il_responso_del_viaggio.dart';
import 'package:esoteric_circle/core/viaggio/la_domanda_del_viaggio.dart';
import 'package:esoteric_circle/core/viaggio/la_scena_dal_modello.dart';
import 'package:esoteric_circle/core/viaggio/le_guardie_del_responso.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LA RISERVA DEL VIAGGIO PRENDE POSIZIONE.** Ordine ET voce 08, 28
/// settembre 2026.
///
/// Il fondatore ha confermato la proposta del rapporto ER: *"una riserva che
/// dica la posizione che il modello aveva scelto sull'oggetto della domanda,
/// anche quando la sua risposta è stata scartata"*. Al giro 8 dell'ordine ER
/// la riserva a Berlino diceva *"Una delle due la stai già facendo, in
/// piccolo, da settimane"*: due strade che la domanda non ha.
void main() {
  final animale = GuideAnimalDerivation.forSign(Zodiac.cancer);
  const neutra = CourtesyForm.neutral;

  IlResponsoDelViaggio responso(String domanda, TestiDelModello scritti,
          {int discesa = 0}) =>
      IlResponsoDelViaggio.componi(
        dalModello: null,
        domanda: domanda,
        giorno: DateTime(2026, 9, 28),
        nitidezza: 1,
        discesa: discesa,
        giaOggi: 0,
        animale: animale,
        tema: TemaDellaDomanda.scelta,
        storia: const [],
        scritti: scritti,
      );

  test(
      'ET.08: con la posizione scelta dal modello la riserva la dice, e non '
      'nomina cio\' che la domanda non ha', () {
    const berlino = 'Mi trasferisco a Berlino per lavoro?';
    final scartata = LeGuardieDelResponso.leggi({
      'posizione': 'sì a una condizione',
      'risposta': 'I segni del viaggio dicono di sì. Berlino sarà la tua '
          'nuova casa.',
    }, domanda: berlino, forma: neutra);
    expect(scartata.risposta, isNull,
        reason: 'la risposta di prova doveva essere scartata');
    expect(scartata.posizione, 'sì a una condizione');
    final viste = <String>{};
    for (var discesa = 0; discesa < 6; discesa++) {
      final r = responso(berlino, scartata, discesa: discesa);
      viste.add(r.paragrafi[0]);
      expect(
          r.paragrafi[0],
          anyOf(startsWith('I segni del viaggio dicono di sì'),
              startsWith('Il viaggio dice di sì')));
      expect(r.paragrafi[0].toLowerCase(), isNot(contains('una delle due')));
      expect(r.fonti['risposta'],
          startsWith('riserva con la posizione sì a una condizione'));
    }
    print('ORDINE ET VOCE 8: frasi diverse della riserva in sei discese '
        '${viste.length}');
    expect(viste.length, greaterThan(1),
        reason: 'la riserva dice sempre la stessa frase');
  });

  test('ET.08: alla domanda aperta la riserva dice il passo', () {
    const collega = 'Cosa pensa di me la mia collega?';
    final scartata = LeGuardieDelResponso.leggi({
      'posizione': 'no',
      'risposta': 'La tua collega ti stima.',
    }, domanda: collega, forma: neutra);
    final r = responso(collega, scartata);
    expect(r.paragrafi[0], isNot(contains('di no')));
    expect(r.paragrafi[0], contains('qui sotto'));
  });

  test('ET.08: senza modello resta la voce di casa, con la sua fonte', () {
    final r = responso('Devo lasciare la banca?', TestiDelModello.nessuno);
    expect(r.fonti['risposta'], 'riserva');
    expect(r.paragrafi[0], isNot(startsWith('I segni del viaggio')));
  });

  test(
      'ET.08: la prima frase buona di una risposta scartata diventa la '
      'risposta', () {
    final s = CioCheSiSa(
      domanda: 'Mi trasferisco a Berlino per lavoro?',
      tema: 'Una scelta da fare',
      animale: animale,
      natale: const NatalContext(sunSign: 'Cancro'),
      memoria: '',
      ultimeScene: const [],
    );
    final letti = LeGuardieDelResponso.leggi({
      'posizione': 'sì a una condizione',
      // LAPIDE, ordine ES voce 25: la frase era "se prima sai che cosa
      // lasci", che adesso non passa perche' la condizione e' un modo di
      // sentirsi; la frase salvata ha una condizione che e' un passo.
      'risposta': 'I segni del viaggio dicono di sì al trasferimento a '
          'Berlino, se prima chiedi quando si comincia. Berlino sarà la tua '
          'nuova casa.',
    }, domanda: s.domanda, forma: neutra);
    expect(letti.risposta, isNull);
    final salvata = LaScenaDalModello.conLaPrimaFrase(letti, s, null);
    print('ORDINE ET VOCE 8: prima frase salvata "${salvata.risposta}"');
    expect(
        salvata.risposta,
        'I segni del viaggio dicono di sì al trasferimento a Berlino, se '
        'prima chiedi quando si comincia.');
    expect(salvata.dallaSeconda, contains('risposta: prima frase'));
  });

  test('ET.08: la condizione annunciata e mai detta non prende posizione', () {
    expect(
        LeGuardieDelResponso.rimandaLaDomanda('I segni del viaggio indicano '
            'che puoi chiamare tuo fratello, a una condizione precisa. '
            'Pensaci.'),
        isTrue);
    expect(
        LeGuardieDelResponso.rimandaLaDomanda('I segni del viaggio dicono di '
            'sì, a una condizione: che la chiamata la fai tu.'),
        isFalse);
  });
}
