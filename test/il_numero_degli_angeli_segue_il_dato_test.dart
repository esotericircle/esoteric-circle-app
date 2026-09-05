import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **IL NUMERO DEGLI ANGELI SEGUE IL DATO.** Ordine CQ voce 6.29, 5 settembre
/// 2026.
///
/// **Trovato a video durante il collaudo sul telefono del fondatore.** Al passo
/// degli Angeli del Risveglio la schermata diceva *"Tre nomi dalla tradizione
/// dei settantadue"* e ne mostrava **due**. Non era un difetto del calcolo: il
/// terzo Angelo, quello dell'intelletto, nasce dall'ORA di nascita, e in quel
/// Risveglio l'ora non era stata data. `GuardianAngels.known` restituisce due
/// nomi quando l'ora manca, ed e' giusto cosi'.
///
/// **A mentire era la frase**, che portava il numero scritto a mano.
///
/// **PERCHE' NESSUNA GUARDIA L'AVEVA PRESO.** Il numero stava dentro una
/// stringa costante, e nessuna prova confronta le parole di una schermata col
/// numero di cose che quella schermata monta. E' la famiglia del token che non
/// segue il fatto, la stessa che l'ordine CQ ha gia' incontrato sul registro
/// delle guardie e sul manifesto dell'ordine CM.
///
/// **La grandezza misurata e' il SORGENTE**, e si dichiara perche': il passo
/// degli Angeli si monta dentro il Risveglio, che chiede una carta natale
/// vera e un cammino gia' avviato; montarlo qui misurerebbe l'assenza della
/// carta, non la frase. Qui si pretende che la frase **non porti un numero
/// scritto a mano**, cioe' che non possa piu' mentire, e che il caso dei due
/// nomi sia nominato per esteso.
void main() {
  final schermata = File('lib/features/onboarding/trionfi_screen.dart');

  test('la frase degli Angeli non porta un numero scritto a mano', () {
    expect(schermata.existsSync(), isTrue,
        reason: 'la schermata dei trionfi non esiste piu');
    final testo = schermata.readAsStringSync();

    // Le parole che dicono un numero in lettere, cercate dove la schermata
    // parla degli Angeli.
    const numeriInLettere = ['Un nome', 'Due nomi', 'Tre nomi', 'Quattro nomi'];
    final trovati = <String>[];
    for (final n in numeriInLettere) {
      if (testo.contains("'$n") || testo.contains(' $n')) trovati.add(n);
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.29: numeri in lettere scritti a mano nella frase '
        'degli Angeli ${trovati.length}: ${trovati.join(", ")}');

    // **IL CARDINALE STA SUL FILE.** Se il sorgente si svuotasse, la ricerca
    // non troverebbe nessun numero e la prova sarebbe verde per cecita'.
    cardinaleMinimo(testo.length, 5000,
        cosa: 'caratteri del sorgente dei trionfi riletti',
        perche: 'Su un file vuoto la ricerca non trova nessun numero e la '
            'prova passa senza aver letto niente.');

    expect(trovati, isEmpty,
        reason: 'la frase degli Angeli porta un numero scritto a mano '
            '(${trovati.join(", ")}), e quel numero mente quando gli Angeli '
            'sono due: il terzo nasce dall ora di nascita, e chi non l ha data '
            'vede due carte sotto una frase che ne promette tre. Il numero '
            'deve venire dalla lista, non dalla stringa.');
  });

  test('e il caso dei due nomi e nominato, con la sua ragione', () {
    final testo = schermata.readAsStringSync();
    // Quando il terzo manca non basta contare giusto: va detto PERCHE' manca,
    // altrimenti chi legge crede di aver perso qualcosa.
    final dice = testo.contains("ora di nascita") ||
        testo.contains("l'ora della nascita");
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.29: la schermata nomina l ora di nascita come '
        'ragione del terzo Angelo: $dice');
    expect(dice, isTrue,
        reason: 'quando gli Angeli sono due nessuno dice perche: chi legge '
            'vede due carte dove la tradizione ne conta tre e non sa se ha '
            'perso qualcosa o se manca un dato suo. La ragione si scrive: '
            'nulla e inventato, e nulla resta senza spiegazione');
  });
}
