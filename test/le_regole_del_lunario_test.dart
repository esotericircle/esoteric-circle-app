import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/lunario/il_corpus_del_lunario.g.dart';
import 'package:esoteric_circle/core/lunario/il_giorno_lunare.dart';
import 'package:esoteric_circle/core/lunario/le_attivita_del_lunario.dart';
import 'package:esoteric_circle/core/lunario/le_regole_del_lunario.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **IL MOTORE DELLE REGOLE LUNARI.** Ordine FV voce FV.06, 15 ottobre 2026.
///
/// `LeRegoleDelLunario.valuta` applica il corpus generato
/// (`docs/corpus/lunario/regole.md`) a un giorno e a un'attivita'. Questa
/// prova pretende che:
///
/// 1. ogni [AttivitaDelLunario] abbia almeno una regola con una fonte vera
///    (ripetuto qui perche' e' la guardia che protegge direttamente
///    `LeRegoleDelLunario`, non solo il corpus);
/// 2. la Luna fuori corso spenga l'oro a inizi, amore e viaggi ANCHE con
///    pesi positivi (R8 dell'ordine FV);
/// 3. nessuna regola del corpus generato parli di salute o di soldi;
/// 4. alcuni esiti deterministici, su giorni costruiti a mano, abbiano il
///    grado e il perche' giusti.
GiornoLunare _giorno({
  required bool crescente,
  FaseLunare fase = FaseLunare.crescente,
  Zodiac segno = Zodiac.leo,
  TipoBiodinamico? tipoBiodinamico,
  List<IntervalloFuoriCorso> fuoriCorso = const [],
}) =>
    GiornoLunare(
      giorno: DateTime(2026, 10, 15),
      elongazione: crescente ? 90 : 270,
      illuminazione: 0.5,
      crescente: crescente,
      fase: fase,
      segno: segno,
      cambiDiSegno: const [],
      fuoriCorso: fuoriCorso,
      giornoLunare: 10,
      tipoBiodinamico: tipoBiodinamico,
      lunaNuova: false,
      lunaPiena: false,
    );

void main() {
  test('ogni attivita\' ha almeno una regola con una fonte vera', () {
    final conFonteVera = <String>{};
    for (final regola in regoleDelLunario) {
      if (regola.fonti.any((f) => f != 'chiave_di_medora')) {
        for (final a in regola.attivita) {
          conFonteVera.add(a.name);
        }
      }
    }
    cardinaleMinimo(conFonteVera.length, 27,
        cosa: 'attivita\' con una regola con fonte vera',
        perche: 'il contratto AttivitaDelLunario ne dichiara 27');
    final senza = [
      for (final a in AttivitaDelLunario.values)
        if (!conFonteVera.contains(a.name)) a.name,
    ];
    expect(senza, isEmpty, reason: 'attivita\' senza fonte vera: $senza');
  });

  group('il fuori corso toglie l\'oro anche con pesi positivi', () {
    final fuoriCorso = [
      IntervalloFuoriCorso(
          inizio: DateTime(2026, 10, 15, 3, 10),
          fine: DateTime(2026, 10, 15, 5, 40)),
    ];

    test('inizi', () {
      final giorno = _giorno(crescente: true, fuoriCorso: fuoriCorso);
      final esito = LeRegoleDelLunario.valuta(AttivitaDelLunario.inizi, giorno);
      expect(esito.grado, isNot(GradoDelGiorno.oro),
          reason: 'la somma dei pesi e\' positiva (Luna crescente) ma il '
              'fuori corso deve impedire l\'oro');
      expect(esito.perche, contains('Luna crescente'));
      expect(esito.perche.any((r) => r.startsWith('Fuori corso dalle 3:10')),
          isTrue,
          reason: 'perche\': ${esito.perche}');
    });

    test('viaggi', () {
      final giorno = _giorno(
          crescente: true, segno: Zodiac.gemini, fuoriCorso: fuoriCorso);
      final esito =
          LeRegoleDelLunario.valuta(AttivitaDelLunario.viaggi, giorno);
      expect(esito.grado, isNot(GradoDelGiorno.oro));
      expect(
          esito.perche, containsAll(['Luna crescente', 'in un segno mobile']));
    });

    test('amore (nozze)', () {
      final giorno = _giorno(
          crescente: true, segno: Zodiac.cancer, fuoriCorso: fuoriCorso);
      final esito = LeRegoleDelLunario.valuta(AttivitaDelLunario.nozze, giorno);
      expect(esito.grado, isNot(GradoDelGiorno.oro));
      expect(
          esito.perche,
          containsAll(
              ['Luna crescente', 'in un segno legato a Venere o alla Luna']));
    });
  });

  test('nessuna regola del corpus generato parla di salute o di soldi', () {
    final vietate = RegExp(
        r'(?<![A-Za-zÀ-ÿ])(salute|malat\w*|guari\w*|farmac\w*|medic\w*|'
        r'dentist\w*|diet\w*|digiun\w*|soldi|denar\w*|investiment\w*|'
        r'garantit\w*|fertil\w*|fecond\w*|nasa)(?![A-Za-zÀ-ÿ])',
        caseSensitive: false);
    cardinaleMinimo(regoleDelLunario.length, 27, cosa: 'regole generate');
    final trovate = <String>[];
    for (final r in regoleDelLunario) {
      final m = vietate.firstMatch(r.detto);
      if (m != null) trovate.add('${r.id}: "${m.group(0)}"');
    }
    expect(trovate, isEmpty, reason: 'parole vietate: $trovate');
  });

  group('esiti deterministici', () {
    test('capelli: Luna crescente accende il taglio per farli crescere', () {
      final giorno = _giorno(crescente: true);
      final esito = LeRegoleDelLunario.valuta(
          AttivitaDelLunario.tagliPerCrescere, giorno);
      expect(esito.grado, GradoDelGiorno.oro);
      expect(esito.perche, ['Luna crescente']);
      expect(esito.fonti, ['barbanera_capelli']);
    });

    test(
        'capelli: la stessa Luna crescente non accende il taglio per '
        'rinforzarli (vuole la Luna calante)', () {
      final giorno = _giorno(crescente: true);
      final esito = LeRegoleDelLunario.valuta(
          AttivitaDelLunario.tagliPerRinforzare, giorno);
      expect(esito.grado, GradoDelGiorno.neutro);
      expect(esito.perche, isEmpty);
    });

    test('orto: giorno frutto accende la semina, nel metodo di Maria Thun', () {
      final giorno =
          _giorno(crescente: true, tipoBiodinamico: TipoBiodinamico.frutto);
      final esito =
          LeRegoleDelLunario.valuta(AttivitaDelLunario.semina, giorno);
      expect(esito.grado, GradoDelGiorno.oro);
      expect(esito.perche, contains('giorno frutto, nel metodo di Maria Thun'));
      expect(esito.fonti, contains('thun_biodinamico'));
    });

    test(
        'orto: senza un tipo biodinamico documentato (l\'Ofiuco) la semina '
        'resta neutra, non evitare', () {
      final giorno = _giorno(crescente: false, tipoBiodinamico: null);
      final esito =
          LeRegoleDelLunario.valuta(AttivitaDelLunario.semina, giorno);
      expect(esito.grado, GradoDelGiorno.neutro);
    });

    test(
        'viaggi: Luna calante in un segno fisso spegne il giorno '
        '(evitare)', () {
      final giorno = _giorno(crescente: false, segno: Zodiac.taurus);
      final esito =
          LeRegoleDelLunario.valuta(AttivitaDelLunario.viaggi, giorno);
      expect(esito.grado, GradoDelGiorno.evitare);
      expect(esito.perche, ['Luna calante in un segno fisso']);
      expect(esito.fonti, ['elettiva_segni_viaggio']);
    });

    test('nozze: Luna calante sconsigliata, da sola, spegne il giorno', () {
      final giorno = _giorno(crescente: false, segno: Zodiac.leo);
      final esito = LeRegoleDelLunario.valuta(AttivitaDelLunario.nozze, giorno);
      expect(esito.grado, GradoDelGiorno.evitare);
      expect(esito.fonti, ['pitre_nozze_calante']);
    });

    test('delMese applica valuta a ogni giorno della lista', () {
      final giorni = [
        _giorno(crescente: true),
        _giorno(crescente: false),
      ];
      final esiti = LeRegoleDelLunario.delMese(
          AttivitaDelLunario.tagliPerCrescere, giorni);
      expect(esiti.length, 2);
      expect(esiti[0].grado, GradoDelGiorno.oro);
      expect(esiti[1].grado, GradoDelGiorno.neutro);
    });
  });
}
