import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/rituals/arcano_dell_alba/attribuzioni_degli_arcani.dart';
import 'package:esoteric_circle/core/rituals/arcano_del_giorno.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LE VENTIDUE ATTRIBUZIONI DELLA GOLDEN DAWN.** Ordine DT voci 06 e 10.
///
/// Tre madri agli elementi, sette doppie ai pianeti, dodici semplici ai segni:
/// ogni arcano maggiore del mazzo ha UNA attribuzione, e nessuna attribuzione
/// resta senza carta. Le relazioni che autorizzano il filo con ieri si provano
/// su coppie di cui la tradizione dice la risposta.
void main() {
  AttribuzioneDellArcano a(String nome) => AttribuzioneDellArcano.di(nome)!;

  test('tre piu sette piu dodici fa ventidue', () {
    const tutte = AttribuzioneDellArcano.tutte;
    int conta(FamigliaDellArcano f) =>
        tutte.where((x) => x.famiglia == f).length;
    expect(tutte, hasLength(22));
    expect([
      conta(FamigliaDellArcano.elementale),
      conta(FamigliaDellArcano.planetaria),
      conta(FamigliaDellArcano.zodiacale),
    ], [
      3,
      7,
      12
    ]);
  });

  test('ogni arcano maggiore del mazzo ha esattamente una attribuzione', () {
    final maggiori = ArcanoDelGiorno.maggiori;
    expect(maggiori, hasLength(22));
    for (final carta in maggiori) {
      final quante = AttribuzioneDellArcano.tutte
          .where((x) => x.nomeDellaCarta == carta.name)
          .length;
      expect(quante, 1, reason: '${carta.name} ha $quante attribuzioni');
    }
    final nomi = maggiori.map((c) => c.name).toSet();
    for (final x in AttribuzioneDellArcano.tutte) {
      expect(nomi, contains(x.nomeDellaCarta),
          reason: '${x.nomeDellaCarta} non e una carta del mazzo');
    }
  });

  test('ogni pianeta e ogni segno compare una volta sola', () {
    final pianeti = AttribuzioneDellArcano.tutte
        .map((x) => x.pianeta)
        .whereType<PianetaDellArcano>()
        .toList();
    final segni = AttribuzioneDellArcano.tutte
        .map((x) => x.segno)
        .whereType<Zodiac>()
        .toList();
    expect(pianeti.toSet(), PianetaDellArcano.values.toSet());
    expect(pianeti, hasLength(7));
    expect(segni.toSet(), Zodiac.values.toSet());
    expect(segni, hasLength(12));
  });

  test('le attribuzioni che l\'ordine nomina, carta per carta', () {
    const attese = {
      'Il Matto': 'Aria',
      'L\'Appeso': 'Acqua',
      'Il Giudizio': 'Fuoco',
      'Il Mago': 'Mercurio',
      'La Papessa': 'Luna',
      'L\'Imperatrice': 'Venere',
      'La Ruota della Fortuna': 'Giove',
      'La Torre': 'Marte',
      'Il Sole': 'Sole',
      'Il Mondo': 'Saturno',
      'L\'Imperatore': 'Ariete',
      'Il Papa': 'Toro',
      'Gli Amanti': 'Gemelli',
      'Il Carro': 'Cancro',
      'La Forza': 'Leone',
      'L\'Eremita': 'Vergine',
      'La Giustizia': 'Bilancia',
      'La Morte': 'Scorpione',
      'La Temperanza': 'Sagittario',
      'Il Diavolo': 'Capricorno',
      'La Stella': 'Acquario',
      'La Luna': 'Pesci',
    };
    expect(attese, hasLength(22));
    attese.forEach((carta, nome) => expect(a(carta).nome, nome, reason: carta));
  });

  group('le relazioni documentate', () {
    List<RelazioneFraArcani> fra(String oggi, String ieri) =>
        RelazioniFraArcani.fra(a(oggi), a(ieri));

    test(
        'stesso elemento: il Giudizio e il Carro no, il Giudizio e la Forza si',
        () {
      expect(fra('Il Giudizio', 'La Forza'),
          contains(RelazioneFraArcani.stessoElemento));
      expect(fra('Il Giudizio', 'Il Carro'),
          isNot(contains(RelazioneFraArcani.stessoElemento)));
    });

    test('il pianeta governa il segno, nei due sensi', () {
      expect(fra('La Torre', 'L\'Imperatore'),
          contains(RelazioneFraArcani.governo));
      expect(fra('La Morte', 'La Torre'), contains(RelazioneFraArcani.governo));
      expect(fra('Il Sole', 'Il Carro'),
          isNot(contains(RelazioneFraArcani.governo)));
    });

    test('opposizione e quadratura fra i segni', () {
      expect(fra('L\'Imperatore', 'La Giustizia'),
          contains(RelazioneFraArcani.opposizione));
      expect(fra('L\'Imperatore', 'Il Carro'),
          contains(RelazioneFraArcani.quadratura));
      expect(fra('Il Diavolo', 'L\'Imperatore'),
          contains(RelazioneFraArcani.quadratura));
      expect(
          fra('L\'Imperatore', 'Il Papa'),
          isNot(anyOf(contains(RelazioneFraArcani.opposizione),
              contains(RelazioneFraArcani.quadratura))),
          reason: 'Ariete e Toro sono contigui: ne opposti ne in quadratura');
      expect(fra('Il Mago', 'L\'Imperatore'), isEmpty,
          reason: 'Mercurio non governa l\'Ariete e le famiglie sono due');
    });

    test('stessa famiglia, ma una carta non e in relazione con se stessa', () {
      expect(fra('Il Mago', 'Il Mondo'),
          contains(RelazioneFraArcani.stessaFamiglia));
      expect(fra('Il Mago', 'Il Mago'), isEmpty);
    });
  });
}
