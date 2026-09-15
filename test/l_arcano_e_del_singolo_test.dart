import 'package:esoteric_circle/core/rituals/arcano_del_giorno.dart';
import 'package:esoteric_circle/core/rituals/carta_di_nascita_dei_tarocchi.dart';
import 'package:esoteric_circle/core/rituals/sunset_rune.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **L'ARCANO E' DEL SINGOLO, NON DI UN VENTIDUESIMO DEL MONDO.**
/// Ordine CQ voce 2.05, 3 settembre 2026.
///
/// **Il fatto, parole del fondatore:** l'Arcano del Giorno non e' individuale.
///
/// **La causa, misurata.** Nel seme entrava il solo NUMERO della carta natale,
/// che vale da uno a ventidue. La parte personale del seme aveva dunque
/// ventidue valori in tutto: **due persone con la stessa carta natale vedevano
/// la stessa carta tutti i giorni, per sempre**, anche essendo nate a
/// vent'anni di distanza. Un ventiduesimo del mondo era un blocco solo che si
/// muoveva insieme.
///
/// **Cosa NON e' il difetto, e va detto.** Le carte sono ventidue: in un
/// giorno solo non possono uscirne piu' di ventidue diverse, con qualunque
/// seme. Una guardia che pretendesse "piu' di ventidue carte diverse" sarebbe
/// impossibile da soddisfare, e chi la scrivesse starebbe misurando la cosa
/// sbagliata. **La grandezza giusta e' la CORRELAZIONE fra due persone
/// diverse**: quanti giorni su un anno vedono la stessa carta.
///
/// **PROVENIENZA: ordine CE voce 13**, che ha portato la carta natale dentro
/// il seme per mantenere la promessa del quarto fumetto del tutorial. La cura
/// era giusta nel movente: prima il seme veniva dal solo calendario e la carta
/// era identica per tutto il mondo. Il difetto e' che si e' fermata al numero
/// ridotto invece che alla nascita intera.
void main() {
  // Un anno di giorni, per misurare su un campione che non sia un caso.
  final anno = [
    for (var i = 0; i < 365; i++) DateTime(2026, 1, 1).add(Duration(days: i)),
  ];

  int giorniUguali(DateTime unaNascita, DateTime altraNascita) {
    var uguali = 0;
    for (final giorno in anno) {
      if (ArcanoDelGiorno.di(giorno, nascita: unaNascita).stem ==
          ArcanoDelGiorno.di(giorno, nascita: altraNascita).stem) {
        uguali++;
      }
    }
    return uguali;
  }

  test('due persone con la stessa carta natale non vedono lo stesso Arcano',
      () {
    // Si cercano due nascite DIVERSE che condividano la carta natale: e'
    // esattamente il caso in cui il seme vecchio le rendeva identiche.
    final perNumero = <int, List<DateTime>>{};
    for (var i = 0; i < 4000; i++) {
      final nascita = DateTime(1970, 1, 1).add(Duration(days: i));
      perNumero
          .putIfAbsent(CartaDiNascitaDeiTarocchi.numeroDi(nascita), () => [])
          .add(nascita);
    }
    final coppie = <(DateTime, DateTime)>[];
    for (final gruppo in perNumero.values) {
      if (gruppo.length >= 2) coppie.add((gruppo.first, gruppo[1]));
    }
    cardinaleMinimo(coppie.length, 10,
        cosa: 'coppie di nascite diverse che condividono la carta natale',
        perche: 'Senza coppie la prova non confronterebbe niente, e il caso '
            'che il fondatore ha nominato non sarebbe mai messo alla prova.');
    final misure = <int>[];
    for (final coppia in coppie) {
      misure.add(giorniUguali(coppia.$1, coppia.$2));
    }
    misure.sort();
    final peggiore = misure.last;
    final media = misure.reduce((a, b) => a + b) / misure.length;
    // ignore: avoid_print
    print('ORDINE CQ VOCE 2.05: su ${coppie.length} coppie con la stessa '
        'carta natale, giorni con lo stesso Arcano su 365: peggiore '
        '$peggiore, media ${media.toStringAsFixed(1)}, attesi circa '
        '${(365 / 22).toStringAsFixed(1)}');
    expect(peggiore, lessThan(120),
        reason: 'due persone con la stessa carta natale vedono lo stesso '
            'Arcano $peggiore giorni su 365: il seme personale ha ventidue '
            'valori soli, e un ventiduesimo del mondo si muove insieme');
  });

  test('e chi non ha dato la nascita non perde il Dono', () {
    var quante = 0;
    final uscite = <String>{};
    for (final giorno in anno) {
      quante++;
      uscite.add(ArcanoDelGiorno.di(giorno).stem);
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCE 2.05: senza nascita, su $quante giorni escono '
        '${uscite.length} carte diverse');
    cardinaleMinimo(quante, 365,
        cosa: 'giorni provati senza data di nascita',
        perche: 'Con pochi giorni la varieta non si vedrebbe.');
    expect(uscite.length, greaterThan(15),
        reason: 'senza nascita il Dono e diventato povero: esce sempre lo '
            'stesso pugno di carte');
  });

  test('la Runa del Tramonto e gia del singolo, e si misura uguale', () {
    // **LA VOCE 2.06 DICEVA "STESSO DIFETTO", E LA MISURA DICE DI NO.**
    // Il Tramonto compone la sua chiave con la nascita INTERA, ora e minuti
    // compresi, e non con un numero ridotto. Si misura con lo stesso metro
    // dell'Arcano, cosi' l'affermazione non resta un'opinione.
    final primaNascita = DateTime(1980, 3, 14, 9, 30);
    final altraNascita = DateTime(1993, 11, 2, 21, 5);
    final unaIdentita = SunsetRune.identitaPer(
        nascita: primaNascita, oraNota: true, deviceId: 'a');
    final altraIdentita = SunsetRune.identitaPer(
        nascita: altraNascita, oraNota: true, deviceId: 'a');
    var uguali = 0;
    for (final giorno in anno) {
      final una = SunsetRune.estrai(giorno.add(const Duration(hours: 20)),
          dataNascita: primaNascita, identita: unaIdentita);
      final altra = SunsetRune.estrai(giorno.add(const Duration(hours: 20)),
          dataNascita: altraNascita, identita: altraIdentita);
      if (una.rune.name == altra.rune.name && una.verso == altra.verso) {
        uguali++;
      }
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCE 2.06: due nascite diverse vedono la stessa runa '
        '$uguali giorni su 365, attesi circa ${(365 / 24).toStringAsFixed(1)}');
    expect(uguali, lessThan(80),
        reason: 'due nascite diverse vedono la stessa runa $uguali giorni su '
            '365: allora anche il Tramonto non e del singolo');
  });
}
