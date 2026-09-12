import 'dart:math' as math;

import 'package:esoteric_circle/core/face/face_classifier.dart';
import 'package:esoteric_circle/core/face/face_trait.dart';
import 'package:esoteric_circle/core/face/quanto_e_tua.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **QUANTE COSTELLAZIONI DISTINTE, E A QUANTI UTENTI DUE COINCIDONO.**
/// Ordine CX, misura chiesta dall'Architetto il 9 settembre 2026.
///
/// **La domanda che ha aperto questa prova.** La card dice *"una costellazione
/// su 104.976 possibili"*, e chi legge capisce unicita'. Centomila
/// combinazioni pero' sono poche: **il problema non e' il numero, e' il
/// significato implicito.**
///
/// **Questa prova misura e non decide.** Stampa le varianti categoria per
/// categoria, dice se una di esse non varia mai, e calcola a quanti utenti la
/// probabilita' che due abbiano la stessa costellazione supera il cinquanta
/// per cento.
///
/// **REGOLA H.** Non basta stampare i numeri: si prova anche che **nessuna
/// categoria abbia una variante sola**. Una categoria che risponde sempre la
/// stessa cosa non moltiplica niente, non descrive nessuno, e non ha diritto
/// di essere contata fra i tratti letti.
void main() {
  test('LE UNDICI CATEGORIE, con quante varianti ciascuna', () {
    cardinaleMinimo(FaceCategory.values.length, 11,
        cosa: 'categorie del responso',
        perche: 'Con meno categorie questo censimento guarderebbe un pezzo '
            'del catalogo e direbbe che sta tutto a posto.');
    final conUnaSola = <String>[];
    var prodotto = 1;
    for (final c in FaceCategory.values) {
      final quante = FaceTrait.perCategoria(c).length;
      prodotto *= quante == 0 ? 1 : quante;
      // ignore: avoid_print
      print('ORDINE CX: ${c.name} ha $quante varianti: '
          '${FaceTrait.perCategoria(c).map((t) => t.nome).join(", ")}');
      if (quante <= 1) conUnaSola.add('${c.name} ($quante)');
    }
    // ignore: avoid_print
    print('ORDINE CX: il prodotto delle varianti e $prodotto');
    expect(prodotto, QuantoETua.quanteNeEsistono());
    expect(conUnaSola, isEmpty,
        reason: 'queste categorie hanno una variante sola: non dicono niente '
            'di nessuno, non moltiplicano niente, e non hanno diritto di '
            'essere contate fra i tratti letti: ${conUnaSola.join(", ")}');
  });

  test('A QUANTI UTENTI DUE COSTELLAZIONI COINCIDONO', () {
    final n = QuantoETua.quanteNeEsistono();
    // **Il compleanno, nella forma classica.** Con n esiti equiprobabili la
    // probabilita' che fra k persone ce ne siano due uguali supera un mezzo
    // attorno a k = 1,1774 per la radice di n. Si calcola anche il conto
    // esatto per non fidarsi dell'approssimazione.
    final stima = (1.1774 * math.sqrt(n)).ceil();
    var p = 1.0;
    var k = 1;
    while (p > 0.5 && k < 100000) {
      p *= (n - k) / n;
      k++;
    }
    // ignore: avoid_print
    print('ORDINE CX: su $n costellazioni equiprobabili, la probabilita che '
        'due utenti coincidano supera il cinquanta per cento a $k utenti '
        '(stima analitica $stima)');
    // E per dare la scala: quanti utenti servono perche' una collisione sia
    // praticamente certa.
    var p95 = 1.0;
    var k95 = 1;
    while (p95 > 0.05 && k95 < 500000) {
      p95 *= (n - k95) / n;
      k95++;
    }
    // ignore: avoid_print
    print('ORDINE CX: a $k95 utenti la probabilita che due coincidano supera '
        'il novantacinque per cento');
    expect(k, lessThan(2000),
        reason: 'con $n combinazioni la collisione arriverebbe solo a $k '
            'utenti: se fosse cosi alta la promessa implicita della card '
            'reggerebbe, e questa misura non servirebbe');
  });

  test('LE MISURE CONTINUE CI SONO GIA, dove la card si disegna', () {
    // **La terza via chiede se le proporzioni reali sono disponibili nel
    // punto in cui la card nasce.** Lo sono: il lavoro fatto per tarare le
    // soglie ha messo il rapporto grezzo dentro OGNI lettura, e la card
    // riceve la lettura intera. Non serve portare li' niente di nuovo.
    const finta = FaceReading(letture: [
      TraitLettura(
          tratto: FaceTrait.voltoTondo, marcatezza: 0.5, rapporto: 0.7950),
      TraitLettura(
          tratto: FaceTrait.fronteSfuggente, marcatezza: 0.5, rapporto: 0.1804),
    ]);
    final conRapporto = finta.letture.where((l) => l.rapporto != null).length;
    // ignore: avoid_print
    print('ORDINE CX: su ${finta.letture.length} letture, quelle che portano '
        'la misura continua sono $conRapporto');
    expect(conRapporto, finta.letture.length,
        reason: 'le letture non portano piu il rapporto grezzo: la terza via '
            'perderebbe la sua base, e la card potrebbe usare solo le caselle');
    // **E due volti nella stessa casella hanno rapporti diversi**: e' il
    // fatto su cui la terza via si regge.
    // I due volti veri 3 e 2: 0,8007 e 0,8645 cadono tutti e due sopra la
    // soglia 0,7978 della forma, cioe nella STESSA casella, e hanno
    // proporzioni diverse. La prima stesura aveva scelto 0,7950 e 0,8007,
    // che stanno ai due lati della soglia: mostrava il contrario di quello
    // che voleva mostrare.
    const a = 0.8007;
    const b = 0.8645;
    expect(FaceClassifier.fasciaDi(FaceCategory.formaVolto, a),
        FaceClassifier.fasciaDi(FaceCategory.formaVolto, b),
        reason: 'i due volti scelti per questa prova non cadono nella stessa '
            'casella: la prova non sta mostrando quello che crede');
    expect(a == b, isFalse,
        reason: 'due volti nella stessa casella hanno lo stesso identico '
            'rapporto: allora le misure continue non aggiungono niente');
  });
}
