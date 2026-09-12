import 'package:esoteric_circle/core/maestro/chakra_del_giorno.dart';
import 'package:esoteric_circle/core/maestro/frequenza_del_giorno.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LA FREQUENZA LA ASSEGNA AURA.** Ordine CZ, voci 06 e 07.
///
/// **Parole del fondatore**: *"Un menu' di frequenze davanti a chi non ha
/// criterio per scegliere e' la forma sbagliata: Aura non e' un lettore
/// multimediale, e' una guida, e una guida decide."*
///
/// **REGOLA H.** Non basta provare che la frequenza c'e' e viene dal chakra:
/// si prova anche che **nessuna promessa** entri nelle righe che la
/// accompagnano. E' la funzione dove la tentazione di promettere e' piu' alta,
/// ed e' la stessa famiglia del difetto degli Angeli che ha aperto l'ordine CS.
void main() {
  test('Sette centri, sette frequenze, e la corrispondenza dell\'ordine', () {
    expect(FrequenzaDelGiorno.hertzPerCentro.length,
        ChakraDelGiorno.tutti.length,
        reason: 'i centri sono ${ChakraDelGiorno.tutti.length} e le frequenze '
            '${FrequenzaDelGiorno.hertzPerCentro.length}: la corrispondenza si '
            'legge per posizione, e una lista piu\' corta darebbe la frequenza '
            'sbagliata a un centro senza dirlo');
    // I sette numeri che l'ordine indica per nome, nell'ordine dei chakra.
    expect(FrequenzaDelGiorno.hertzPerCentro,
        const [396.0, 417.0, 528.0, 639.0, 741.0, 852.0, 963.0]);
  });

  test('Ogni giorno della settimana ha la sua, e non si ripetono', () {
    final viste = <double>{};
    for (var g = 0; g < 7; g++) {
      final giorno = DateTime(2026, 9, 7).add(Duration(days: g));
      viste.add(FrequenzaDelGiorno.di(giorno));
    }
    expect(viste.length, 7,
        reason: 'in una settimana le frequenze distinte sono ${viste.length}: '
            'due giorni portano lo stesso numero, e il motivo per tornare '
            'domani si spegne');
  });

  test('La frequenza segue il centro, non un secondo conto', () {
    // **UNA SORGENTE SOLA.** Se la frequenza nascesse da un suo calcolo del
    // giorno, prima o poi direbbe un centro e la frequenza di un altro: e'
    // la famiglia delle due verita' sullo stesso fatto.
    for (var g = 0; g < 366; g++) {
      final giorno = DateTime(2026, 1, 1).add(Duration(days: g));
      final centro = FrequenzaDelGiorno.centroDi(giorno);
      final indice = ChakraDelGiorno.tutti.indexWhere(
          (c) => c.nome == centro.nome);
      expect(FrequenzaDelGiorno.di(giorno),
          FrequenzaDelGiorno.hertzPerCentro[indice],
          reason: 'il ${giorno.toIso8601String().substring(0, 10)} il centro '
              'e\' ${centro.nome} e la frequenza non e\' la sua');
    }
  });

  test('La riga di Aura nomina il centro e il numero', () {
    for (var g = 0; g < 7; g++) {
      final giorno = DateTime(2026, 9, 7).add(Duration(days: g));
      final riga = FrequenzaDelGiorno.perche(giorno);
      final centro = FrequenzaDelGiorno.centroDi(giorno);
      expect(riga, contains(centro.nome),
          reason: 'la riga non nomina il centro: chi legge non sa da dove '
              'viene la scelta');
      expect(riga, contains('${FrequenzaDelGiorno.di(giorno).round()}'),
          reason: 'la riga non porta il numero della frequenza');
      // **DUE FRASI, E LA RAGIONE E' UNA REGOLA DI CASA.** La prima stesura
      // ne faceva una sola e violava il divieto della virgola seguita da "e":
      // *"i 417 hertz, ed e' la frequenza di questa sessione"*. La regola non
      // si deroga, quindi la riga si spezza in due frasi brevi. **Resta un
      // pensiero solo**, che e' cio' che l'ordine chiede quando dice una riga:
      // il centro, cio' su cui apre, il numero.
      expect(riga.split('.').where((f) => f.trim().isNotEmpty).length,
          lessThanOrEqualTo(2),
          reason: 'la riga di Aura e\' fatta di piu\' di due frasi: e\' un '
              'paragrafo, e l\'ordine ne chiede una riga');
    }
  });

  test('Le tre righe prima sono TRE, e dicono le tre cose', () {
    final righe = FrequenzaDelGiorno.lePrimeTreRighe(
        DateTime(2026, 9, 8), const Duration(minutes: 7));
    expect(righe.length, 3,
        reason: 'le righe prima di cominciare sono ${righe.length}: l\'ordine '
            'dice tre e non una in piu\'');
    expect(righe[0], contains('tradizione'),
        reason: 'la prima riga non dice che la corrispondenza e\' della '
            'tradizione: senza quella parola diventa un fatto');
    expect(righe[1], contains('7'),
        reason: 'la seconda riga non dice quanto dura');
    expect(righe[2].toLowerCase(), contains('respiro'),
        reason: 'la terza riga non dice cosa si ha in mano alla fine');
  });

  test('REGOLA H: NESSUNA PROMESSA in nessuna riga', () {
    // **L'ASSENZA, ed e' la meta' che conta.** Le parole vietate sono quelle
    // con cui questa materia promette di solito: guarigione, riparazione del
    // DNA, effetti sul corpo. Una sola di queste, e la riga smette di essere
    // una corrispondenza culturale e diventa una promessa medica.
    const vietate = [
      'guarisc', 'guarigione', 'cura', 'curare', 'terapia', 'terapeutic',
      'DNA', 'ripara', 'riparazione', 'effetto sul corpo', 'sana', 'risana',
      'clinic', 'medic', 'toglie il dolore', 'abbassa la pressione',
    ];
    final daGuardare = <String>[];
    for (var g = 0; g < 7; g++) {
      final giorno = DateTime(2026, 9, 7).add(Duration(days: g));
      daGuardare.add(FrequenzaDelGiorno.perche(giorno));
      daGuardare.addAll(FrequenzaDelGiorno.lePrimeTreRighe(
          giorno, const Duration(minutes: 7)));
    }
    expect(daGuardare.length, 28,
        reason: 'guardate ${daGuardare.length} righe invece di ventotto: '
            'questa prova non ha visto tutta la settimana');
    for (final riga in daGuardare) {
      for (final parola in vietate) {
        expect(riga.toLowerCase().contains(parola.toLowerCase()), isFalse,
            reason: 'la riga "$riga" contiene "$parola": e\' una promessa, e '
                'in questa funzione non se ne fanno');
      }
    }
  });
}
