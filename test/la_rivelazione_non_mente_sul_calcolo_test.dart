import 'package:esoteric_circle/core/rituals/carta_di_nascita_dei_tarocchi.dart';
import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:esoteric_circle/features/onboarding/rivelazione_carta_di_nascita.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LA RIVELAZIONE NON MENTE SUL CALCOLO.** Ordine DC voce 14,
/// 10 settembre 2026.
///
/// **IL VINCOLO CHE VALE PIU' DELL'ANIMAZIONE**, e l'ordine lo scrive cosi':
/// *"il calcolo mostrato a schermo deve essere ESATTAMENTE quello che
/// CartaDiNascitaDeiTarocchi gia' esegue, letto da li' e non riscritto. Se le
/// cifre si sommassero a schermo in un modo e la carta uscisse da un altro
/// calcolo, avremmo costruito una bugia visiva sopra un dato giusto, che e'
/// peggio di non avere l'animazione."*
///
/// **E LA CARTA NON E' CASUALE.** Un'animazione che raccontasse un'estrazione
/// racconterebbe una bugia sul metodo: la Carta di Nascita si calcola dalla
/// data, e la rivelazione mostra quel calcolo.
///
/// **REGOLA H.** Non basta che i numeri coincidano: si prova anche che
/// **date diverse diano rivelazioni diverse**, altrimenti una funzione che
/// tornasse sempre lo stesso numero soddisferebbe la prima meta' senza dire
/// niente.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Un campione di date, non una sola: **il difetto che questa guardia cerca
  /// si vede su una data e non su un'altra**, e una prova su un solo caso
  /// sarebbe verde per fortuna.
  final campione = <DateTime>[
    DateTime(1979, 3, 24),
    DateTime(1990, 12, 31),
    DateTime(2000, 1, 1),
    DateTime(1966, 7, 7),
    DateTime(1985, 11, 19),
    DateTime(2004, 2, 29),
    DateTime(1971, 9, 9),
    DateTime(1958, 6, 15),
  ];

  test('I NUMERI A SCHERMO SONO QUELLI DEL CALCOLO, passo per passo', () {
    cardinaleMinimo(campione.length, 6,
        cosa: 'date di nascita nel campione',
        perche: 'Su poche date una divergenza rara passerebbe inosservata, e '
            'la guardia sarebbe verde per fortuna invece che per merito.');
    var passiGuardati = 0;
    for (final data in campione) {
      final passi = CartaDiNascitaDeiTarocchi.passiDi(data);
      final carta = CartaDiNascitaDeiTarocchi.cartaDi(data);
      final pittore = RegiaDellaRivelazione(passi: passi, carta: carta, t: 0);
      // **Si scorre il tempo dell'animazione e si legge il numero al centro
      // a ogni istante**, e ogni numero letto deve stare fra quelli che il
      // calcolo produce: le somme parziali, le riduzioni, il totale.
      final ammessi = <int>{
        ...passi.sommeParziali,
        ...passi.riduzioni,
        passi.numero,
      };
      for (var i = 0; i <= 100; i++) {
        final t = i / 100;
        final quello = RegiaDellaRivelazione(passi: passi, carta: carta, t: t)
            .numeroAlCentro();
        if (quello == null) continue;
        passiGuardati++;
        expect(ammessi.contains(quello), isTrue,
            reason: 'per ${data.day}/${data.month}/${data.year} a schermo '
                'compare $quello, che NON e nessuno dei numeri del calcolo '
                '${ammessi.toList()..sort()}: e una bugia visiva sopra un '
                'dato giusto');
      }
      // **E l'ultimo numero mostrato e' quello che la funzione restituisce.**
      final finale = RegiaDellaRivelazione(passi: passi, carta: carta, t: 1)
          .numeroAlCentro();
      expect(finale, passi.numero,
          reason: 'per ${data.day}/${data.month}/${data.year} l animazione '
              'finisce su $finale e la funzione dice ${passi.numero}');
      expect(passi.numero, CartaDiNascitaDeiTarocchi.numeroDi(data),
          reason: 'i passi e il numero vengono da due calcoli diversi');
      // **E la carta che si ferma nel mazzo e' la sua**, ordine DP voce 01:
      // il cerchio delle ventidue e' diventato tutto il mazzo.
      expect(pittore.indiceDellaSua, TarotDeck.cards.indexOf(carta),
          reason: 'la carta che si ferma nel mazzo non e quella del numero');
    }
    // ignore: avoid_print
    print('ORDINE DC VOCE 14: date guardate ${campione.length}, istanti '
        'confrontati col calcolo $passiGuardati');
  });

  test('REGOLA H: DATE DIVERSE DANNO RIVELAZIONI DIVERSE', () {
    final numeri = <int>{};
    for (final data in campione) {
      numeri.add(CartaDiNascitaDeiTarocchi.passiDi(data).numero);
    }
    // ignore: avoid_print
    print('ORDINE DC VOCE 14: ${campione.length} date danno ${numeri.length} '
        'numeri distinti');
    expect(numeri.length, greaterThan(2),
        reason: 'otto date danno solo ${numeri.length} numeri: il calcolo '
            'non guarda la data, e la prova qui sopra sarebbe verde su una '
            'costante');
  });

  test('LE SOMME CRESCONO, e non saltano', () {
    // Il calcolo si racconta a schermo come una somma: **se le parziali non
    // crescessero, cio' che si vede non sarebbe una somma.**
    for (final data in campione) {
      final passi = CartaDiNascitaDeiTarocchi.passiDi(data);
      expect(passi.cifre.length, passi.sommeParziali.length,
          reason: 'le cifre e le somme parziali non si corrispondono');
      var precedente = 0;
      for (var i = 0; i < passi.sommeParziali.length; i++) {
        expect(passi.sommeParziali[i], precedente + passi.cifre[i],
            reason: 'la somma parziale $i non e la precedente piu la cifra: '
                'a schermo il numero salterebbe');
        precedente = passi.sommeParziali[i];
      }
      expect(passi.totale, precedente);
    }
  });

  // **LA REGOLA I, LA CARTA FINALE AL SETTANTA PER CENTO**, si misura
  // adesso sulla carta vera montata nella scena, ordine DP voce 01: vedi
  // `la_carta_di_nascita_e_una_carta_vera_test.dart`. Qui si misuravano i
  // pixel di un rettangolo dipinto in codice, che non c'e' piu'.

  test('CON RIDUCI MOVIMENTO IL METODO RESTA LEGGIBILE', () {
    // Ordine DC voce 14: il cerchio non ruota, le cifre non volano, la carta
    // non zooma. **Ma il numero e la carta ci sono lo stesso**: se sparissero,
    // chi ha chiesto meno movimento non vedrebbe piu' il metodo, e la
    // rivelazione tornerebbe a essere una carta che compare dal nulla.
    final data = campione.first;
    final passi = CartaDiNascitaDeiTarocchi.passiDi(data);
    final fermo = RegiaDellaRivelazione(
      passi: passi,
      carta: CartaDiNascitaDeiTarocchi.cartaDi(data),
      t: 1.0,
      senzaMoto: true,
    );
    expect(fermo.numeroAlCentro(), passi.numero,
        reason: 'con Riduci Movimento il numero del calcolo non si vede piu');
    expect(fermo.indiceDellaSua,
        TarotDeck.cards.indexOf(CartaDiNascitaDeiTarocchi.cartaDi(data)));
  });

  testWidgets('LA RIVELAZIONE DURA MENO DI OTTO SECONDI', (tester) async {
    // Ordine DC voce 14: **mai di piu' perche' e' onboarding**.
    const durata = RivelazioneCartaDiNascita.quantoDura;
    // ignore: avoid_print
    print('ORDINE DC VOCE 14: la rivelazione dura '
        '${durata.inMilliseconds / 1000} secondi');
    expect(durata.inMilliseconds, lessThanOrEqualTo(8000),
        reason: 'la rivelazione dura ${durata.inSeconds} secondi: in '
            'onboarding e troppo');
    expect(durata.inMilliseconds, greaterThanOrEqualTo(6000),
        reason: 'la rivelazione dura ${durata.inSeconds} secondi: il calcolo '
            'non si legge');
  });
}
