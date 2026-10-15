// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/oracolo_angeli/la_domanda_delicata.dart';
import 'package:esoteric_circle/core/oracolo_angeli/le_domande_dell_oracolo.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LE DOMANDE DELICATE**, ordine FU voce FU.04: "Prova rossa e verde con
/// dieci domande delicate e dieci normali". Il riconoscimento avviene prima
/// sul telefono: una domanda delicata non estrae carte e riceve la risposta
/// di cura; una normale non deve mai cadere qui. Le domande proposte
/// dall'Oracolo stesso sono normali per costruzione, e si controllano tutte.
void main() {
  const delicate = [
    'Voglio farla finita, gli angeli mi aiutano?',
    'Penso al suicidio da giorni',
    'Ho voglia di farmi del male stasera',
    'Non voglio più vivere, cosa faccio?',
    'Mi taglio quando sono triste, è normale?',
    'Mio marito mi picchia, devo restare?',
    'Ho paura che mi uccida se lo lascio',
    'Vorrei morire, a cosa serve tutto questo?',
    'Voglio fargli del male per quello che mi ha fatto',
    'Ho preso troppe pillole, rischio un overdose?',
    // Scritta in fretta, senza l'accento.
    'non voglio piu vivere',
  ];
  const normali = [
    'Devo cambiare lavoro?',
    'Il mio amore tornerà da me?',
    'Come posso fare pace con mia madre?',
    'Che cosa mi frena in questo progetto?',
    'Sono sulla strada giusta?',
    'Come ritrovo la calma in questi giorni?',
    'Questa amicizia è sincera?',
    'Quale passo devo fare adesso?',
    'Mi sento bloccato nella mia città, che cosa mi serve?',
    'Che cosa devo lasciare andare?',
  ];

  test(
      'undici domande delicate, una senza accento: nessuna carta, la risposta di cura',
      () {
    final mancate = [
      for (final d in delicate)
        if (!LaDomandaDelicata.e(d)) d
    ];
    expect(mancate, isEmpty, reason: 'queste non sono state riconosciute');
  });

  test('dieci domande normali e tutte le proposte: si fa oracolo', () {
    final tutte = [
      ...normali,
      for (final t in TemaDellOracolo.values) ...t.domande,
    ];
    final sbagliate = [
      for (final d in tutte)
        if (LaDomandaDelicata.e(d)) d
    ];
    print('FU.04 DOMANDE NORMALI GUARDATE: ${tutte.length}');
    expect(sbagliate, isEmpty, reason: 'queste sono cadute nella cura');
  });

  test('la risposta di cura indica un aiuto vero, in poche righe', () {
    final testo = LaDomandaDelicata.paragrafi.join(' ');
    expect(testo, contains('112'));
    expect(LaDomandaDelicata.paragrafi.length, lessThanOrEqualTo(3));
  });
}
