import 'package:esoteric_circle/features/onboarding/primo_approdo.dart';
import 'package:flutter_test/flutter_test.dart';

/// I CINQUE TESTI DEL TUTORIAL SONO DEL FONDATORE. Ordine CC voce 01.
///
/// **Perche' una prova carattere per carattere, che sembra eccessiva.** Questi
/// testi non sono contenuto dell'app: sono le parole di una persona, riscritte
/// di suo pugno il 29 agosto 2026 dopo aver letto la prima stesura
/// dell'Architetto. Una riformulazione ben intenzionata, un sinonimo piu'
/// scorrevole, una virgola tolta per far stare la riga, e quelle parole non
/// sono piu' le sue. La prova non giudica il testo: pretende che sia IDENTICO.
///
/// **I due che aspettano una decisione sono dichiarati qui, non nascosti.** Il
/// quarto e il quinto testo nuovo promettono cose che il codice non fa, e
/// l'ordine vieta di riscriverli: restano quelli di prima, e questa prova
/// custodisce anche quelli, cosi' nessuno li tocca mentre aspettano.
void main() {
  /// **I TESTI DEL FONDATORE, copiati dall'ordine CC voce 01.** Chi cambia una
  /// parola qui deve avere in mano un messaggio del fondatore che la cambia.
  const suoi = <int, (String, String)>{
    0: (
      'IL CERCHIO TI ACCOGLIE',
      'Qui trovi le risposte alle domande che non fai a nessuno. Universo, '
          'Oracoli, Simboli, Energia e Spiritualità con un solo click. Nulla '
          'di inventato: solo arti, pratiche e tradizioni accreditate.'
    ),
    1: (
      'I TRE MAESTRI',
      'Tre voci, tre mondi. Medora: Astrologia, Cartomanzia, Divinazione. '
          'Caligo: Runologia, Simbologia, Ritualistica. Aura: Energia, '
          'Meditazione, Equilibrio. Tocca un volto e gli parli: risponde a te, '
          'con la tua data e la tua ora.'
    ),
    2: (
      'IL CERCHIO A UN CLICK',
      'Raggiungi immediatamente, ovunque tu sia, il dominio e le arti di ogni '
          'maestro con un tap del dito.'
    ),
  };

  /// **I DUE IN ATTESA**, col testo che resta a video finche' il fondatore non
  /// decide. Sono quelli dell'ordine CB, gia' misurati veri.
  const inAttesa = <int, (String, String)>{
    3: (
      'I Doni del Giorno',
      'Il Cerchio ti lascia qualcosa ogni giorno, a ore diverse. Non si '
          'cercano: si ricevono e chi torna li trova.'
    ),
    4: (
      'Eos, la moneta del Cerchio',
      'Qui in alto stanno il tuo profilo, il cielo che si muove sopra di te e '
          'il tuo borsellino. Gli Eos ti arrivano ogni giorno, dai traguardi '
          'del tuo cammino e dai primi responsi che condividi. Si spendono per '
          'una domanda in più o per una lettura che il giorno non ti dava.'
    ),
  };

  test('i tre testi del fondatore sono a video, carattere per carattere', () {
    for (final voce in suoi.entries) {
      final f = cinqueFumetti[voce.key];
      expect(f.titolo, voce.value.$1,
          reason: 'il titolo del fumetto ${voce.key + 1} non e\' piu\' quello '
              'che ha scritto il fondatore');
      expect(f.testo, voce.value.$2,
          reason: 'il testo del fumetto ${voce.key + 1} e\' stato riscritto: '
              'queste parole sono del fondatore e si usano come sono');
    }
    // ignore: avoid_print
    print('ORDINE CC VOCE 01: testi del fondatore a video ${suoi.length} su 5');
  });

  test('i due in attesa non sono stati sostituiti di nascosto', () {
    for (final voce in inAttesa.entries) {
      final f = cinqueFumetti[voce.key];
      expect(f.titolo, voce.value.$1);
      expect(f.testo, voce.value.$2,
          reason: 'il fumetto ${voce.key + 1} e\' stato cambiato mentre '
              'aspettava la decisione del fondatore');
    }
    // ignore: avoid_print
    print('ORDINE CC VOCE 01: testi in attesa di decisione '
        '${inAttesa.length} su 5');
  });

  test('i cinque restano cinque, nell\'ordine del fondatore', () {
    expect(cinqueFumetti, hasLength(5));
    expect(suoi.length + inAttesa.length, 5,
        reason: 'la prova custodisce meno di cinque testi: uno e\' scoperto');
  });
}
