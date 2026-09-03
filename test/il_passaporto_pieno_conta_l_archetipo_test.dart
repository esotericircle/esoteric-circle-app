import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/pezzi_dell_identita.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/features/sigilli/regia_del_cammino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL PASSAPORTO PIENO CONTA ANCHE L'ARCHETIPO. Ordine AL voce 03.
///
/// Il gesto 'passaporto' scatta a ogni visita della schermata, quindi da solo
/// dice "ho aperto il documento" e niente di piu': sulla 2179 il traguardo
/// med_27 "Il Passaporto pieno" e' maturato sul telefono di Mauro con
/// l'archetipo ancora da fare. La regola nuova: il pezzo 'passaporto' matura
/// SOLO quando ogni tessera del documento e' viva, e le tessere stanno
/// enumerate in un punto solo, `PezziDellIdentita.tessereDelPassaporto`.
///
/// Il traguardo gia' scattato sul telefono NON si revoca: un Sigillo acceso
/// non si spegne mai per legge del diario, e il caso resta dichiarato nel
/// rapporto.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<DiarioDelCammino> diarioCon(List<String> gesti) async {
    SharedPreferences.setMockInitialValues(const {});
    // L'istante dichiarato, come pretende la sorveglianza delle prove: il
    // giorno non conta per i pezzi, conta che sia sempre lo stesso.
    final diario = DiarioDelCammino(orologio: () => DateTime(2026, 8, 18, 10));
    await diario.carica();
    for (final gesto in gesti) {
      await diario.segna(gesto);
    }
    return diario;
  }

  test("con l'archetipo mancante il pezzo 'passaporto' NON matura", () async {
    final diario = await diarioCon([
      'passaporto',
      for (final tessera in PezziDellIdentita.tessereDelPassaporto)
        if (tessera != 'archetipo') tessera,
    ]);
    final pezzi = RegiaDelCammino.pezziDellIdentitaMaturi(diario, true);
    // ignore: avoid_print
    print('ORDINE AL VOCE 03: pezzi maturi senza archetipo: $pezzi');
    expect(pezzi, isNot(contains('passaporto')),
        reason: 'il Passaporto pieno e\' maturato con l\'archetipo ancora da '
            'fare: e\' il med_27 regalato visto da Mauro sulla 2179');
    // E med_27 stesso, dal suo sentiero, non deve dirsi raggiunto.
    final med27 = Sentieri.tuttiITraguardi.singleWhere((t) => t.id == 'med_27');
    final stato = diario.statoDelCammino(pezziDellIdentita: pezzi);
    expect(med27.condizione.raggiunto(stato), isFalse,
        reason: 'med_27 si dice raggiunto con una tessera del documento morta');
  });

  test('con OGNI tessera viva il pezzo matura e med_27 e\' raggiunto',
      () async {
    final diario = await diarioCon([
      'passaporto',
      ...PezziDellIdentita.tessereDelPassaporto,
    ]);
    final pezzi = RegiaDelCammino.pezziDellIdentitaMaturi(diario, true);
    expect(pezzi, contains('passaporto'),
        reason: 'a documento pieno il pezzo deve maturare, altrimenti il '
            'traguardo diventa irraggiungibile');
    // **LA REGOLA E' CAMBIATA CON L'ORDINE BD VOCE 05, e si dichiara.**
    // Fino a quell'ordine il Sigillo del Cerchio e la Luna natale si
    // DERIVAVANO dal documento pieno, e maturavano in blocco con tutto il
    // resto: era esattamente il difetto dei gradini che maturano insieme.
    // Adesso hanno ciascuno la propria porta, la schermata del Sigillo e il
    // portale del cielo di nascita, e il documento pieno NON li matura piu'.
    final stato = diario.statoDelCammino(pezziDellIdentita: pezzi);
    final suiPezzi = Sentieri.tuttiITraguardi.where((t) {
      final c = t.condizione;
      return c is PezzoDellIdentita &&
          (c.pezzo == 'sigillo_del_cerchio' || c.pezzo == 'luna_natale');
    }).toList();
    // **ZERO GRADINI SU QUEI DUE PEZZI, ordine CP voce 05, ed e' voluto.**
    // Un pezzo dell'identita' costa un giorno solo, e le regole del fondatore
    // ammettono **un solo gradino da un giorno per sentiero**: la revisione F
    // ne mette uno per sentiero, la carta natale, il volto e l'Animale, e il
    // Sigillo del Cerchio e la Luna natale restano porte del Passaporto senza
    // un gradino sopra.
    //
    // **La pretesa qui resta intera** e cambia solo bersaglio: se un giorno
    // un gradino tornera' a poggiare su quei pezzi, non dovra' maturare col
    // solo documento pieno. Il numero si stampa, cosi' chi legge il verde sa
    // su quanti gradini ha guardato.
    // ignore: avoid_print
    print('ORDINE CP VOCE 05: gradini che poggiano sul Sigillo o sulla Luna '
        '${suiPezzi.length}');
    for (final t in suiPezzi) {
      expect(t.condizione.raggiunto(stato), isFalse,
          reason: '${t.id} matura ancora col solo Passaporto pieno: i gradini '
              'tornerebbero a maturare in blocco (ordine BD voce 05)');
    }
    // E con le due porte aperte maturano davvero.
    final diarioConLePorte = await diarioCon([
      'passaporto',
      ...PezziDellIdentita.tessereDelPassaporto,
      'sigillo_del_cerchio',
      'luna_natale',
    ]);
    final statoConLePorte = diarioConLePorte.statoDelCammino(
        pezziDellIdentita:
            RegiaDelCammino.pezziDellIdentitaMaturi(diarioConLePorte, true));
    for (final t in suiPezzi) {
      expect(t.condizione.raggiunto(statoConLePorte), isTrue,
          reason: '${t.id} non matura nemmeno alla sua porta');
    }
  });

  test('la carta natale dal profilo vale come quella dal gesto', () async {
    // Chi ha la carta dal profilo non ha mai compiuto il gesto 'carta_natale':
    // il documento e' pieno lo stesso, e il confronto sui PEZZI lo sa.
    final diario = await diarioCon([
      'passaporto',
      for (final tessera in PezziDellIdentita.tessereDelPassaporto)
        if (tessera != 'carta_natale') tessera,
    ]);
    final pezzi = RegiaDelCammino.pezziDellIdentitaMaturi(diario, true);
    expect(pezzi, contains('passaporto'),
        reason: 'la carta arrivata dal profilo non conta come tessera viva: '
            'il confronto guarda i gesti invece dei pezzi');
  });

  test('le tessere del documento comprendono l\'archetipo e sono pezzi veri',
      () {
    expect(PezziDellIdentita.tessereDelPassaporto, contains('archetipo'),
        reason: 'la voce dell\'ordine e\' nata esattamente da qui');
    for (final tessera in PezziDellIdentita.tessereDelPassaporto) {
      expect(PezziDellIdentita.tutti, contains(tessera),
          reason: 'la tessera $tessera non e\' un pezzo dell\'identita\': '
              'nessun gesto potra\' mai accenderla');
    }
  });
}
