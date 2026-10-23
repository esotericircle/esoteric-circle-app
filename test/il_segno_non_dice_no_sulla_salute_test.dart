import 'dart:convert';

import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/core/viaggio/il_segno_dell_animale.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **IL SEGNO NON DICE NO SULLA SALUTE, E NEMMENO IL MODELLO DICE SI' O NO
/// A UNA DOMANDA APERTA.** Simulazione da persona (e) del 20 ottobre 2026 sul
/// Realme 767f596c, build release, modello vero: alla domanda *"Mio padre e'
/// malato, guarira'?"* il Gufo **si allontana**, e il gesto vuol dire *"la
/// risposta e' no, oppure non adesso"*
/// (`docs/collaudo/FZ/simulazioni/catture/e2_q4_b.png`); a *"Quando arrivera'
/// un amore vero?"* si allontana anche li', *"Non e' ancora il momento di
/// trovare l'amore"* (`e2_q2_b.png`). Quattro risposte su quattro col gesto
/// del no.
///
/// **I padri.** Ordine DJ voce 08: l'istruzione al modello elenca i tre
/// gesti e non dice mai quando un si' o un no non si danno. Ordine FZ, la
/// cura del 20 ottobre 2026 (commit `036dffda`): ha messo la regola delle
/// domande aperte nella sola riserva, non nella strada del modello. Sulla
/// salute nessuna regola c'era, in nessuna delle due strade.
///
/// **Cosa misura**: a una domanda aperta o delicata (salute, malattia,
/// guarigione, morte, gravidanza, gioco d'azzardo) il segno e' sempre "si
/// volta", che venga dalla riserva o dal modello: se il modello sceglie un
/// altro gesto la sua risposta si scarta. L'istruzione al modello lo dice.
/// Le domande chiuse e leggere restano libere.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  const delicate = [
    'Mio padre è malato, guarirà?',
    'Il tumore di mia madre andrà via?',
    'Morirà presto il nonno?',
    'Sono incinta?',
    "L'operazione andrà bene?",
    'Dimmi i numeri del lotto di sabato',
    'Vincerò la scommessa?',
  ];
  const aperte = [
    'Quando arriverà un amore vero?',
    'Quali numeri usciranno?',
  ];
  const leggere = [
    'Devo lasciare il mio lavoro?',
    'Mi ama ancora?',
  ];
  final gufo = AnimalCatalog.animals.firstWhere((a) => a.name == 'Gufo');

  Future<String?> modelloCheDiceNo(String istruzione, String richiesta) async =>
      jsonEncode({
        'gesto': 'siAllontana',
        'riga': 'Il Gufo si allontana in volo. Non è questo il momento.',
      });

  test('A UNA DOMANDA DELICATA O APERTA IL MODELLO NON DICE NO', () async {
    final sbagliati = <String>[];
    for (final d in [...delicate, ...aperte]) {
      final s = await GestiDelSegno.chiedi(
        animale: gufo,
        domanda: d,
        giorno: DateTime(2026, 10, 20),
        chiamata: modelloCheDiceNo,
        prendiUnaChiamata: () async => true,
      );
      if (s.gesto != GestoDelSegno.siVolta) {
        sbagliati.add('"$d" ${s.gesto.name}');
      }
    }
    expect(sbagliati, isEmpty,
        reason: 'il modello ha detto no a: ${sbagliati.join('; ')}');
  });

  test('A UNA DOMANDA LEGGERA LA RISPOSTA DEL MODELLO RESTA', () async {
    for (final d in leggere) {
      final s = await GestiDelSegno.chiedi(
        animale: gufo,
        domanda: d,
        giorno: DateTime(2026, 10, 20),
        chiamata: modelloCheDiceNo,
        prendiUnaChiamata: () async => true,
      );
      expect(s.dalModello, isTrue,
          reason: '"$d": la cura ha toccato anche lei');
      expect(s.gesto, GestoDelSegno.siAllontana);
    }
  });

  /// **A LETTERE A CASO NON SI DICE SI'.** La stessa persona (e), chiamata
  /// otto: a *"asdfgh"* il modello vero rispondeva *"Il Gufo si avvicina.
  /// Questo significa che la risposta e' affermativa e puoi proseguire"*
  /// (`e2_q8_b.png`). Chi scrive per sbaglio riceveva un si'. Una riga senza
  /// spazi e senza punto di domanda non e' una domanda: si volta. Una parola
  /// sola col punto di domanda resta una domanda.
  test('A LETTERE A CASO IL SEGNO NON DICE SI\'', () async {
    Future<String?> modelloCheDiceSi(
            String istruzione, String richiesta) async =>
        jsonEncode({
          'gesto': 'siAvvicina',
          'riga': 'Il Gufo ti si avvicina. Puoi andare avanti.',
        });
    for (final d in ['asdfgh', 'lavoro', 'xxxx']) {
      final s = await GestiDelSegno.chiedi(
        animale: gufo,
        domanda: d,
        giorno: DateTime(2026, 10, 20),
        chiamata: modelloCheDiceSi,
        prendiUnaChiamata: () async => true,
      );
      expect(s.gesto, GestoDelSegno.siVolta, reason: '"$d" riceve un si\'');
    }
    final parola = await GestiDelSegno.chiedi(
      animale: gufo,
      domanda: 'Partire?',
      giorno: DateTime(2026, 10, 20),
      chiamata: modelloCheDiceSi,
      prendiUnaChiamata: () async => true,
    );
    expect(parola.gesto, GestoDelSegno.siAvvicina,
        reason: 'una parola sola col punto di domanda e\' una domanda');
  });

  test(
      'LA RISERVA NON DICE NO SULLA SALUTE, per tutti e dodici e trenta giorni',
      () {
    var guardati = 0;
    final sbagliati = <String>[];
    for (final a in AnimalCatalog.animals) {
      for (final d in delicate) {
        for (var g = 0; g < 30; g++) {
          guardati++;
          final s = GestiDelSegno.diRiserva(
              animale: a, domanda: d, giorno: DateTime(2026, 11, 1 + g));
          if (s.gesto != GestoDelSegno.siVolta) {
            sbagliati.add('${a.name} "$d" ${s.gesto.name}');
          }
        }
      }
    }
    expect(guardati, 12 * delicate.length * 30);
    expect(sbagliati, isEmpty,
        reason: 'la riserva risponde si\' o no sulla salute: '
            '${sbagliati.take(5).join('; ')}');
  });

  test("L'ISTRUZIONE AL MODELLO LO DICE", () {
    final i = GestiDelSegno.istruzione(gufo);
    // **LA FRASE DELLA REGOLA**, non le parole sparse: "siVolta" c'e' gia'
    // nell'elenco dei gesti.
    final regola = RegExp(r'Se la domanda chiede quando[^.]*salute[^.]*'
            r'scegli sempre siVolta')
        .hasMatch(i);
    expect(regola, isTrue,
        reason: "l'istruzione non dice che alle domande aperte e a quelle "
            'sulla salute si risponde con siVolta');
  });
}
