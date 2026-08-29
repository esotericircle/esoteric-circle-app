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
/// **QUATTRO SU CINQUE SONO SUOI, dopo le decisioni del 29 agosto 2026.** Il
/// secondo e il quinto aspettavano una sua parola e l'hanno avuta: il secondo
/// perche' i domini che nominava non erano quelli dell'app, il quinto perche'
/// prometteva di comprare arti che gli Eos non comprano. Il quarto resta
/// quello di prima, e non per indecisione: il fondatore tiene la sua frase e
/// nel prossimo ordine si costruisce l'incrocio nei doni che oggi non ce
/// l'hanno. Questa prova custodisce anche quello, cosi' nessuno lo tocca
/// mentre aspetta il lavoro.
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
      'Tre voci, tre mondi. Medora: Astrologia, Cartomanzia, Destino. '
          'Caligo: Rune, Rituali, Numerologia. Aura: Chakra, Energia, '
          'Archetipi. Tocca un volto e gli parli: risponde a te, con la tua '
          'data e la tua ora.'
    ),
    2: (
      'IL CERCHIO A UN CLICK',
      'Raggiungi immediatamente, ovunque tu sia, il dominio e le arti di ogni '
          'maestro con un tap del dito.'
    ),
  };

  /// **IL QUINTO, deciso il 29 agosto 2026.** Cade la parola "arti", che il
  /// listino del server ha dimostrato falsa, e restano i maiuscoli suoi.
  const quinto = (
    'IL CAMMINO E GLI EOS',
    'Qui in alto: il tuo profilo, gli eventi cosmici speciali e IL TUO '
        'BORSELLINO: guadagna e spendi EOS ogni giorno per acquistare nuove '
        'esperienze.'
  );

  /// **L'UNICO IN ATTESA**, col testo che resta a video finche' i doni non
  /// nascono davvero dall'incrocio. E' quello dell'ordine CB, gia' misurato
  /// vero.
  const inAttesa = <int, (String, String)>{
    3: (
      'I Doni del Giorno',
      'Il Cerchio ti lascia qualcosa ogni giorno, a ore diverse. Non si '
          'cercano: si ricevono e chi torna li trova.'
    ),
  };

  test('i quattro testi del fondatore sono a video, carattere per carattere',
      () {
    for (final voce in {...suoi, 4: quinto}.entries) {
      final f = cinqueFumetti[voce.key];
      expect(f.titolo, voce.value.$1,
          reason: 'il titolo del fumetto ${voce.key + 1} non e\' piu\' quello '
              'che ha scritto il fondatore');
      expect(f.testo, voce.value.$2,
          reason: 'il testo del fumetto ${voce.key + 1} e\' stato riscritto: '
              'queste parole sono del fondatore e si usano come sono');
    }
    // ignore: avoid_print
    print('ORDINE CC VOCE 01: testi del fondatore a video '
        '${suoi.length + 1} su 5');
  });

  test('quello in attesa non e\' stato sostituito di nascosto', () {
    for (final voce in inAttesa.entries) {
      final f = cinqueFumetti[voce.key];
      expect(f.titolo, voce.value.$1);
      expect(f.testo, voce.value.$2,
          reason: 'il fumetto ${voce.key + 1} e\' stato cambiato mentre '
              'aspettava la decisione del fondatore');
    }
    // ignore: avoid_print
    print('ORDINE CC VOCE 01: testi che aspettano il lavoro sui doni '
        '${inAttesa.length} su 5');
  });

  test('i cinque restano cinque, nell\'ordine del fondatore', () {
    expect(cinqueFumetti, hasLength(5));
    expect(suoi.length + 1 + inAttesa.length, 5,
        reason: 'la prova custodisce meno di cinque testi: uno e\' scoperto');
  });
}
