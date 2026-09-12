import 'dart:io';

import 'package:esoteric_circle/core/face/cio_che_non_ho_visto.dart';
import 'package:esoteric_circle/core/face/face_classifier.dart';
import 'package:esoteric_circle/core/face/face_trait.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'sorgenti_di_lib.dart';

/// **CIO' CHE NON HO VISTO NON LO DESCRIVO.** Ordine CX voci 01, 03 e 08.
///
/// **Il fatto**: il fondatore si e' scansionato col cappello, con fronte e
/// sopracciglia nascoste, e **il responso gliele ha descritte lo stesso**.
/// MediaPipe posa i punti anche dove non vede, e non dichiara quali abbia
/// dedotto: la distinzione va misurata dall'effetto.
///
/// **I NUMERI SONO VERI**, presi sul dispositivo di collaudo l'8 settembre
/// 2026 con una build che stampava i rapporti misurati. Sei misure: quattro
/// volti scoperti e due degli stessi volti col cappello.
///
/// **REGOLA H.** Non basta provare che una fronte coperta viene riconosciuta:
/// si prova anche che **le quattro scoperte NON vengano accusate**. Un
/// rilevamento che grida "coperto" a tutti toglierebbe la fronte dal responso
/// di chiunque, e sarebbe verde su meta' della prova.
void main() {
  /// I sei rapporti della fronte e delle sopracciglia, dal telefono.
  const scoperti = <String, (double, double)>{
    'volto 1': (0.1804, 0.2434),
    'volto 2': (0.1424, 0.2173),
    'volto 3': (0.1592, 0.2103),
    'volto 4': (0.1761, 0.2100),
  };
  const conIlCappello = <String, (double, double)>{
    'volto 1 col cappello': (0.1297, 0.1884),
    'volto 3 col cappello': (0.1165, 0.1970),
  };

  /// Una lettura finta con i due soli rapporti che contano: qui non serve un
  /// volto intero, serve che le due categorie portino i numeri veri.
  FaceReading lettura(double fronte, double sopracciglia) => FaceReading(
        letture: [
          TraitLettura(
              tratto: FaceTrait.fronteSfuggente,
              marcatezza: 0.5,
              rapporto: fronte),
          TraitLettura(
              tratto: FaceTrait.sopraccigliaDritte,
              marcatezza: 0.5,
              rapporto: sopracciglia),
          const TraitLettura(
              tratto: FaceTrait.nasoCorto, marcatezza: 0.5, rapporto: 0.30),
        ],
      );

  test('IL CAPPELLO SI VEDE, su tutte e due le misure prese', () {
    cardinaleMinimo(conIlCappello.length, 2,
        cosa: 'volti misurati col cappello',
        perche: 'Con un caso solo la soglia sarebbe tarata su un punto, e '
            'questa prova direbbe che funziona per averlo ripetuto zero '
            'volte.');
    for (final voce in conIlCappello.entries) {
      final coperte = CioCheNonHoVisto.quali(
          lettura(voce.value.$1, voce.value.$2));
      // ignore: avoid_print
      print('ORDINE CX: ${voce.key}, fronte ${voce.value.$1}, sopracciglia '
          '${voce.value.$2}, zone coperte riconosciute '
          '${coperte.map((c) => c.name).join(", ")}');
      expect(coperte, contains(FaceCategory.fronte),
          reason: '${voce.key} ha la fronte sotto il cappello e il responso '
              'non se ne accorge: gliela descrivera\' lo stesso, che e\' il '
              'difetto segnalato dal fondatore');
      expect(coperte, contains(FaceCategory.sopracciglia),
          reason: '${voce.key} ha le sopracciglia coperte e il responso non '
              'se ne accorge');
    }
  });

  test('REGOLA H: e i volti scoperti NON vengono accusati', () {
    cardinaleMinimo(scoperti.length, 4,
        cosa: 'volti scoperti misurati',
        perche: 'Senza volti scoperti la prova non puo\' sapere se il '
            'rilevamento grida coperto a chiunque.');
    final accusati = <String>[];
    for (final voce in scoperti.entries) {
      final coperte = CioCheNonHoVisto.quali(
          lettura(voce.value.$1, voce.value.$2));
      // ignore: avoid_print
      print('ORDINE CX: ${voce.key} scoperto, zone coperte riconosciute '
          '${coperte.isEmpty ? "nessuna" : coperte.map((c) => c.name).join(", ")}');
      if (coperte.isNotEmpty) accusati.add(voce.key);
    }
    expect(accusati, isEmpty,
        reason: 'questi volti erano scoperti e il rilevamento li accusa lo '
            'stesso: ${accusati.join(", ")}. Toglierebbe la fronte dal '
            'responso di chi non ha niente in testa');
  });

  test('LA ZONA COPERTA ESCE DAL RESPONSO, non solo si dichiara', () {
    // **La meta' che conta.** Dire "non ho visto la fronte" e poi descriverla
    // due riquadri sotto sarebbe peggio che tacere.
    final piena = lettura(0.1165, 0.1970);
    final coperte = CioCheNonHoVisto.quali(piena);
    final ridotta = CioCheNonHoVisto.senzaLeCoperte(piena, coperte);
    final categorie = ridotta.letture.map((l) => l.tratto.categoria).toSet();
    // ignore: avoid_print
    print('ORDINE CX: dal responso restano ${ridotta.letture.length} letture '
        'su ${piena.letture.length}, categorie '
        '${categorie.map((c) => c.name).join(", ")}');
    expect(categorie, isNot(contains(FaceCategory.fronte)),
        reason: 'la fronte coperta resta nel responso: viene dichiarata non '
            'vista e descritta lo stesso');
    expect(categorie, contains(FaceCategory.naso),
        reason: 'il responso ha perso anche cio\' che si vedeva benissimo');
  });

  test('E LA SCHERMATA LA MOSTRA, prima del responso e non dopo', () {
    // **UNA RIGA CALCOLATA E MAI MONTATA E UNA RIGA CHE NON ESISTE.** Questo
    // progetto ha gia' pagato quella famiglia: la voce CZ.09 e ferma proprio
    // perche' una figura era calcolata, provata e non disegnata.
    //
    // **E LA POSIZIONE E' PARTE DEL FATTO.** Una dichiarazione stampata in
    // fondo arriva quando la persona ha gia' letto come vero tutto quello che
    // sta sopra: qui si pretende che stia PRIMA del volto e dei tratti.
    final sorgente = File(
            'lib/features/maestri/aura/face/face_constellation_screen.dart')
        .readAsStringSync();
    final codice = senzaCommenti(sorgente);
    expect(codice.contains('face_non_ho_visto'), isTrue,
        reason: 'la riga di cio che non si e visto non e montata da nessuna '
            'parte: si calcola e non la legge nessuno');
    final riga = codice.indexOf('face_non_ho_visto');
    final volto = codice.indexOf('IL VOLTO', riga < 0 ? 0 : riga);
    final costellazione = codice.indexOf('costellazione:', riga < 0 ? 0 : riga);
    expect(riga, greaterThanOrEqualTo(0));
    expect(costellazione, greaterThan(riga),
        reason: 'la dichiarazione di cio che non si e visto viene DOPO il '
            'responso: chi legge ha gia creduto a quello che sta sopra');
    expect(volto == -1 || volto > riga, isTrue,
        reason: 'la dichiarazione viene dopo il ritratto del volto');
  });

  test('E LA RIGA LO DICE, senza accusare e senza ordinare', () {
    final riga = CioCheNonHoVisto.laRiga(
        {FaceCategory.fronte, FaceCategory.sopracciglia})!;
    // ignore: avoid_print
    print('ORDINE CX: la riga dice "$riga"');
    expect(riga, contains('fronte'));
    expect(riga, contains('sopracciglia'));
    // **Nessun responso vuoto e nessun vicolo cieco**: si dice come averla
    // intera, non solo che manca.
    expect(riga.toLowerCase(), contains('rifai'),
        reason: 'la riga dice cosa manca e non dice come rimediare: e\' un '
            'vicolo cieco, che questa casa vieta prima di ogni altra cosa');
    // E quando non c'e' niente da dire, non si dice niente.
    expect(CioCheNonHoVisto.laRiga(const {}), isNull,
        reason: 'con nessuna zona coperta compare lo stesso una riga: '
            'chi si e\' scansionato bene leggerebbe una scusa che non serve');
  });
}
