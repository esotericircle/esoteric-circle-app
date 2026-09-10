import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/core/viaggio/i_quattro_viaggi.dart';
import 'package:esoteric_circle/core/viaggio/l_annuncio_dell_animale.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **L'ONBOARDING ANNUNCIA, E NON CONSUMA.** Ordine DC voce 02,
/// 10 settembre 2026.
///
/// **LA REGOLA GENERALE che questa guardia difende, e vale su tutto**:
/// *"l'onboarding rivela cio' che nessuna funzione rivelera' mai; cio' che una
/// funzione rivelera', l'onboarding lo annuncia e non lo consuma."*
///
/// **Perche' conta piu' dell'Animale.** Un onboarding che rivela tutto lascia
/// una persona senza nessuna ragione per tornare: ha gia' visto. La regola non
/// e' una cortesia narrativa, e' la differenza fra un'app che si apre due
/// volte e una che si apre due mesi.
///
/// **REGOLA H.** Non basta provare che il nome non c'e': si prova anche che
/// **l'annuncio ci sia**, altrimenti togliere la riga soddisferebbe la prima
/// meta' lasciando la persona senza sapere che un animale esiste.
void main() {
  test('L ANNUNCIO NON NOMINA NESSUN ANIMALE', () {
    final riga = LAnnuncioDellAnimale.laRiga.toLowerCase();
    final animali = AnimalCatalog.animals;
    cardinaleMinimo(animali.length, 10,
        cosa: 'animali del catalogo da cercare nell annuncio',
        perche: 'Con pochi animali la guardia direbbe che nessun nome compare '
            'per non averne quasi cercato nessuno.');
    final nominati = <String>[];
    for (final a in animali) {
      if (riga.contains(a.name.toLowerCase())) nominati.add(a.name);
    }
    // ignore: avoid_print
    print('ORDINE DC VOCE 02: animali cercati ${animali.length}, nominati '
        'nell annuncio ${nominati.length}');
    expect(nominati, isEmpty,
        reason: 'l annuncio nomina ${nominati.join(", ")}: allora non e un '
            'annuncio, e la rivelazione che doveva evitare, e il Viaggio non '
            'ha piu niente da rivelare');
  });

  test('REGOLA H: MA L ANNUNCIO C E, e dice dove si scende', () {
    final riga = LAnnuncioDellAnimale.laRiga;
    // ignore: avoid_print
    print('ORDINE DC VOCE 02: Caligo dice "$riga"');
    expect(riga.trim(), isNotEmpty,
        reason: 'senza annuncio la persona non sa nemmeno che un animale '
            'esiste: la casella vuota nel Passaporto diventa un buco invece '
            'che una promessa');
    expect(riga.toLowerCase(), contains('mondo di sotto'),
        reason: 'l annuncio non dice dove si scende');
    expect(riga.toLowerCase(), contains('scendere'),
        reason: 'l annuncio non dice che bisogna andarci');
  });

  test('E NON PROMETTE UN TEMPO CHE IL METODO NON PUO MANTENERE', () {
    // I quattro viaggi cadono in quattro giorni diversi: **nessuno puo
    // sapere quando**, perche dipende da quante volte quella persona torna.
    final riga = LAnnuncioDellAnimale.laRiga.toLowerCase();
    for (final promessa in LAnnuncioDellAnimale.parolePromesse) {
      expect(riga.contains(promessa), isFalse,
          reason: 'l annuncio promette "$promessa": il metodo di Harner '
              'chiede quattro apparizioni in giorni diversi, e nessuno puo '
              'sapere quando arriveranno');
    }
  });

  test('LA CASELLA VUOTA DICE A CHE PUNTO SI E, e non resta muta', () {
    final righe = <String>[];
    for (var d = 0; d <= IQuattroViaggi.quanteDiscese; d++) {
      righe.add(LAnnuncioDellAnimale.sottoLaSagoma(
          d, IQuattroViaggi.quanteDiscese));
    }
    // ignore: avoid_print
    print('ORDINE DC VOCE 02: sotto la sagoma, da zero a quattro discese: '
        '${righe.map((r) => r.isEmpty ? "(niente)" : r).join(" | ")}');
    expect(righe.first.trim(), isNotEmpty,
        reason: 'a zero discese la casella vuota non dice niente: e un buco, '
            'non un motivo per tornare');
    // **A ogni discesa la riga cambia**: e' il modo in cui chi guarda vede
    // che manca poco.
    final distinte = righe.take(IQuattroViaggi.quanteDiscese).toSet();
    expect(distinte.length, IQuattroViaggi.quanteDiscese,
        reason: 'la riga sotto la sagoma non cambia a ogni discesa: chi '
            'guarda non vede nessun avvicinamento');
    // **E a riconoscimento avvenuto tace**, perche' li' la casella e' piena e
    // non c'e' piu' niente da annunciare.
    expect(righe.last, isEmpty,
        reason: 'a riconoscimento avvenuto la casella continua a dire quanto '
            'manca');
  });

  test('E I CONTORNI DELLA SAGOMA SEGUONO LE DISCESE', () {
    // Ordine DC voce 04: *"dopo ogni viaggio non completato, la sagoma
    // guadagna un contorno in piu"*.
    final contorni = [
      for (var d = 0; d <= IQuattroViaggi.quanteDiscese; d++)
        IQuattroViaggi.contorniDellaSagoma(d),
    ];
    expect(contorni, [0, 1, 2, 3, 4],
        reason: 'i contorni non seguono le discese: la sagoma non racconta '
            'nessun avvicinamento');
  });
}
