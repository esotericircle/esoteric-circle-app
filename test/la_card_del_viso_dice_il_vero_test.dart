import 'package:esoteric_circle/core/face/face_classifier.dart';
import 'package:esoteric_circle/core/face/face_trait.dart';
import 'package:esoteric_circle/core/face/quanto_e_tua.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LA CARD DEL VISO DICE IL VERO, E DICE PERCHE' VALE MANDARLA.**
/// Ordine CX voci 05 e 06, 8 settembre 2026.
///
/// **Le richieste del fondatore**: *"la card generata per la condivisione
/// dovrebbe ovviamente riportare la foto del Viso e informazioni accurate
/// oltre che un titolo accattivante"*, e le due domande che sono la misura
/// della voce: *"perche' l'utente dovrebbe condividere e perche' un amico
/// dovrebbe sentirsi spinto a scaricare l'app per avere la stessa
/// esperienza?"*
///
/// **La risposta e' un numero, e un numero si conta.** Le combinazioni che il
/// catalogo distingue sono il prodotto delle varianti per categoria: si
/// leggono dal catalogo vero, quindi la riga resta vera quando domani nasce
/// un tratto nuovo. **Scriverla a mano vorrebbe dire una seconda verita'
/// accanto al catalogo**, e diventerebbe falsa alla prima variante aggiunta.
///
/// **REGOLA H.** Non basta provare che il numero compaia: si prova anche che
/// **cambi quando il catalogo cambia**. Una costante travestita da conteggio
/// passerebbe qualunque prova sulla presenza.
void main() {
  test('IL CONTO DELLE COMBINAZIONI VIENE DAL CATALOGO, non da una costante',
      () {
    final quante = QuantoETua.quanteNeEsistono();
    // ignore: avoid_print
    print('ORDINE CX: il catalogo distingue $quante costellazioni, cioe\' '
        '"${QuantoETua.laRiga()}"');
    cardinaleMinimo(FaceCategory.values.length, 11,
        cosa: 'categorie del responso',
        perche: 'Con meno categorie il prodotto sarebbe piccolo e questa '
            'prova direbbe che va bene lo stesso.');

    // **IL CONTO SI RIFA' A MANO, dalla stessa sorgente.** Se il metodo
    // restituisse una costante, questo prodotto non coinciderebbe.
    var atteso = 1;
    for (final c in FaceCategory.values) {
      final v = FaceTrait.perCategoria(c).length;
      if (v > 0) atteso *= v;
    }
    expect(quante, atteso,
        reason: 'il numero delle combinazioni non e\' il prodotto delle '
            'varianti del catalogo: e\' una costante scritta a mano, e '
            'diventera\' falsa alla prima variante aggiunta');
    // E deve essere un numero che vale la pena dire.
    expect(quante, greaterThan(1000),
        reason: 'il catalogo distingue solo $quante costellazioni: dirlo su '
            'una card non spingerebbe nessuno a volere la sua');
  });

  test('REGOLA H: il conto CAMBIA se il catalogo cambia', () {
    // **L'altra meta'.** Una costante passerebbe la prova di sopra se
    // qualcuno la scrivesse uguale al prodotto di oggi. Qui si guarda che il
    // conto dipenda davvero dalle categorie: togliendone una il prodotto
    // deve scendere.
    final intero = QuantoETua.quanteNeEsistono();
    var senzaUna = 1;
    var saltata = false;
    for (final c in FaceCategory.values) {
      final v = FaceTrait.perCategoria(c).length;
      if (!saltata && v > 1) {
        saltata = true;
        continue;
      }
      if (v > 0) senzaUna *= v;
    }
    expect(saltata, isTrue,
        reason: 'nessuna categoria ha piu\' di una variante: il catalogo non '
            'distingue niente');
    // ignore: avoid_print
    print('ORDINE CX: col catalogo intero $intero, togliendo una categoria '
        '$senzaUna');
    expect(senzaUna, lessThan(intero),
        reason: 'togliendo una categoria il conto non scende: non e\' un '
            'conteggio, e\' un numero fisso');
  });

  test('IL NUMERO SI LEGGE, coi punti delle migliaia', () {
    expect(QuantoETua.colPunto(104976), '104.976');
    expect(QuantoETua.colPunto(999), '999');
    expect(QuantoETua.colPunto(1000), '1.000');
    final riga = QuantoETua.laRiga();
    // ignore: avoid_print
    print('ORDINE CX: la riga della card dice "$riga"');
    // **Nessuna promessa e nessun superlativo.** Dire "unico al mondo"
    // sarebbe falso, e su questa funzione una parola di troppo e' proprio
    // cio' che l'ordine CS ha insegnato a non fare.
    for (final vietata in const [
      'unico', 'unica', 'irripetibile', 'nessun altro', 'al mondo',
      'esclusiv',
    ]) {
      expect(riga.toLowerCase().contains(vietata), isFalse,
          reason: 'la riga della card promette con "$vietata": e\' un vanto '
              'che non si puo\' dimostrare, e questa card la leggono estranei');
    }
  });

  test('E DICE QUANTI TRATTI HA LETTO DAVVERO, quando ne mancano', () {
    // **L'onesta' che serve dopo la voce 08.** Se una zona era coperta il
    // responso ne perde una: una card che vanta undici letture avendone
    // fatte nove mente a chi la riceve, e chi la riceve le righe le conta.
    const intera = FaceReading(letture: [
      TraitLettura(tratto: FaceTrait.voltoTondo, marcatezza: 0.5),
      TraitLettura(tratto: FaceTrait.fronteSfuggente, marcatezza: 0.5),
      TraitLettura(tratto: FaceTrait.nasoCorto, marcatezza: 0.5),
    ]);
    final righeIntera = QuantoETua.quantiTratti(intera);
    // ignore: avoid_print
    print('ORDINE CX: con tre letture su ${FaceCategory.values.length} la '
        'card dice "$righeIntera"');
    expect(righeIntera, contains('3'),
        reason: 'la card non dice quante letture ha davvero');
    expect(righeIntera, contains('${FaceCategory.values.length}'),
        reason: 'la card non dice su quante avrebbe potuto: senza il '
            'denominatore il numero non significa niente');
  });

  test('LA CARD SI DISEGNA ANCHE SENZA UNA CATEGORIA, non solleva', () {
    // **UNO SCHIANTO CHE HO RESO POSSIBILE IO.** Ordine CX voce 08: da quando
    // una zona coperta esce dal responso, `letturaDi` puo' non trovare cio'
    // che le si chiede, e `firstWhere` in quel caso solleva. Chi si scansiona
    // col cappello si troverebbe un errore al posto del responso.
    const senzaForma = FaceReading(letture: [
      TraitLettura(tratto: FaceTrait.nasoCorto, marcatezza: 0.5),
    ]);
    expect(senzaForma.forse(FaceCategory.formaVolto), isNull,
        reason: 'la porta sicura non restituisce nulla quando la categoria '
            'manca: allora non e\' sicura');
    expect(() => senzaForma.letturaDi(FaceCategory.formaVolto), throwsA(anything),
        reason: 'la porta vecchia non solleva piu\': questa prova crede di '
            'sorvegliare un rischio che non c\'e\' piu\', e la sua ragione '
            'va riscritta invece di lasciarla verde per caso');
    // E il conto dei tratti regge lo stesso.
    expect(QuantoETua.quantiTratti(senzaForma), contains('1'));
  });
}
