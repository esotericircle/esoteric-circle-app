// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/horoscope/horoscope_data.dart';
import 'package:esoteric_circle/core/responsi/confine_del_responso.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL DOMINIO FORTUNA PARLA DI OCCASIONI, NON DI RELAZIONI. Ordine GB
/// voce 09, 22 ottobre 2026.** Il rapporto dell'ordine GA, punto 12: *"il
/// dominio 'Fortuna' dell'Oroscopo parla di relazioni e occasioni"*. Le
/// relazioni stanno nell'Amore (dominio 1); la Fortuna (dominio 3) resta su
/// occasioni, intuito, alleanze d'affari e colpi di sorte. Nessun consiglio
/// su denaro, ordine S voce 17: la stessa lista di
/// [ConfineDelResponso.temiDelicati] vale anche qui.
///
/// I testi sono un corpus statico (`lib/core/horoscope/horoscope_data.dart`,
/// generato da `tool/_gen_oroscopo.py` a partire da
/// `docs/corpus/oroscopo.md`): nessuna chiamata al modello, R2 dell'ordine
/// GB. Chi tocca di nuovo il dominio Fortuna vede questa prova rossa prima
/// di cambiare il corpus (Regola B).
void main() {
  // Le parole di una relazione romantica: non appartengono alla Fortuna.
  // "coppia" da sola e' ambigua (una coppia di soci, di numeri): si cerca
  // la forma piu' stretta che l'ordine GA.14 ha trovato nel difetto vero,
  // "in coppia", e le altre voci che non hanno letture oneste diverse.
  const paroleDiRelazione = [
    'in coppia',
    'innamorat',
    'fidanzat',
    'romantic',
    'sentimental',
    'partner',
    'amore',
    'amant',
  ];

  List<String> tuttiITestiDellaFortuna() {
    const dominioFortuna = 3;
    return [
      for (final triade in HoroscopeData.titoliDelGiorno[dominioFortuna]!)
        for (final titolo in triade) titolo,
      for (final triade in HoroscopeData.primeDelGiorno[dominioFortuna]!)
        for (final prima in triade) prima,
    ];
  }

  test('nessun testo della Fortuna parla di una relazione romantica', () {
    final testi = tuttiITestiDellaFortuna();
    final trovate = <String>[];
    for (final testo in testi) {
      final minuscolo = testo.toLowerCase();
      for (final parola in paroleDiRelazione) {
        if (minuscolo.contains(parola)) {
          trovate.add('"$parola" in: $testo');
        }
      }
    }
    print('GB.09 MISURA: testi della Fortuna letti ${testi.length}, con '
        'parole di relazione ${trovate.length}');
    expect(trovate, isEmpty,
        reason: 'la Fortuna parla di relazioni, che stanno nell\'Amore: '
            '${trovate.join(' | ')}');
  });

  test('nessun testo della Fortuna da\' consigli su denaro (ordine S '
      'voce 17)', () {
    final testi = tuttiITestiDellaFortuna();
    final trovate = <String>[];
    for (final testo in testi) {
      final minuscolo = testo.toLowerCase();
      for (final tema in ConfineDelResponso.temiDelicati) {
        if (minuscolo.contains(tema)) {
          trovate.add('"$tema" in: $testo');
        }
      }
    }
    print('GB.09 MISURA: testi della Fortuna con temi delicati '
        '${trovate.length}');
    expect(trovate, isEmpty, reason: trovate.join(' | '));
  });
}
