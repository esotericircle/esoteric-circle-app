import 'package:esoteric_circle/features/maestri/widgets/foglio_delle_fonti.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LE FONTI DELLA MEDITAZIONE DICONO IL VERO.** Ordine CZ, voce 07.
///
/// **Parole dell'ordine**: *"Nessuna promessa di guarigione, di riparazione
/// del DNA, di effetti sul corpo. Questa e' la funzione dove la tentazione di
/// promettere e' piu' alta, ed e' la stessa famiglia del difetto degli Angeli:
/// qui non si ripete."*
///
/// **LE DUE MATERIE NON HANNO LO STESSO PESO, e il testo deve dirlo.**
/// Le frequenze del solfeggio sono una costruzione della fine del Novecento,
/// attribuita a Guido d'Arezzo senza nessuna fonte documentata prima degli
/// anni Settanta. I battiti binaurali hanno letteratura reale, da Heinrich
/// Wilhelm Dove nel 1839 agli studi recenti, con risultati modesti e non
/// concordi. **Metterle sullo stesso piano sarebbe comodo e falso**, e una
/// guardia che chiedesse solo "c'e' un disclaimer" non se ne accorgerebbe.
///
/// **REGOLA H**: si prova cio' che c'e' e cio' che non deve esserci.
void main() {
  const testo = TestiDelleFonti.meditazione;

  test('Il testo esiste e non e\' un segnaposto', () {
    expect(testo.length, greaterThan(600),
        reason: 'il testo delle fonti e\' lungo ${testo.length} caratteri: '
            'troppo poco per dire tre cose vere su due materie diverse');
  });

  group('LA PRESENZA: quello che deve esserci per nome', () {
    test('Il solfeggio e\' dichiarato NON antico', () {
      expect(testo, contains('NON SONO ANTICHE'),
          reason: 'il testo non dice che le frequenze del solfeggio non sono '
              'antiche, ed e\' la sola cosa che di quella materia si sappia '
              'con certezza');
      expect(testo, contains('Guido d\'Arezzo'),
          reason: 'manca il nome a cui l\'attribuzione viene fatta: senza, '
              'chi legge non sa di quale attribuzione si parla');
      expect(testo, contains('anni Settanta'),
          reason: 'manca la data da cui la corrispondenza esiste davvero');
    });

    test('I binaurali hanno la loro fonte vera', () {
      expect(testo, contains('Heinrich Wilhelm Dove'),
          reason: 'manca chi ha descritto il fenomeno');
      expect(testo, contains('1839'), reason: 'manca l\'anno');
      expect(testo, contains('non concordi'),
          reason: 'il testo non dice che gli studi recenti non concordano: '
              'dire che la letteratura esiste senza dire com\'e\' fatta e\' '
              'la meta\' comoda della verita\'');
    });

    test('E la formula dell\'ordine c\'e\' tutta e tre', () {
      for (final pezzo in const [
        'tradizione moderna',
        'chi la pratica riferisce',
        'non è un effetto clinico dimostrato',
      ]) {
        expect(testo, contains(pezzo),
            reason: 'manca "$pezzo": la formula che l\'ordine detta ha tre '
                'parti, e con due sole diventa una promessa a meta\'');
      }
    });
  });

  test('REGOLA H, L\'ASSENZA: nessuna promessa, nominata una per una', () {
    // Le parole con cui questa materia promette di solito. Una sola, e il
    // testo smette di essere una cornice e diventa una promessa medica.
    const vietate = [
      'guarisce', 'guarigione', 'ripara il dna', 'riparazione del dna',
      'terapia', 'terapeutico', 'effetto sul corpo', 'ti cura', 'risana',
      'abbassa la pressione', 'toglie il dolore', 'scientificamente provato',
      'dimostrato che funziona', 'medicina alternativa',
    ];
    final basso = testo.toLowerCase();
    for (final parola in vietate) {
      expect(basso.contains(parola), isFalse,
          reason: 'il testo delle fonti contiene "$parola": e\' esattamente '
              'la promessa che questa voce vieta, ed e\' la famiglia del '
              'difetto degli Angeli che ha aperto l\'ordine CS');
    }
  });

  test('REGOLA H: e il DNA non compare affatto', () {
    // **Il DNA e' il caso limite di questa materia**: la promessa piu'
    // ripetuta dal solfeggio in rete e' che il 528 lo ripari. Qui non si
    // nomina proprio, nemmeno per smentirlo: nominarlo per negarlo lo
    // metterebbe comunque nella testa di chi legge.
    expect(testo.toUpperCase().contains('DNA'), isFalse,
        reason: 'il testo nomina il DNA: la promessa piu\' diffusa di questa '
            'materia non si smentisce, non si nomina');
  });
}
