import 'dart:io';

import 'package:esoteric_circle/core/face/face_classifier.dart';
import 'package:esoteric_circle/core/face/face_trait.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **DUE VOLTI DIVERSI NON RICEVONO LO STESSO RESPONSO.**
/// Ordine CX, 8 settembre 2026.
///
/// **Il fatto che ha aperto questa prova, e sono numeri veri.** Il fondatore
/// ha fatto tre scansioni sul dispositivo di collaudo con una build che
/// stampava i rapporti misurati. **La prima e la terza sono due PERSONE
/// DIVERSE, e il responso e' uscito identico in tutti e undici i tratti**,
/// parola per parola. Parole sue: *"SBAGLIO O TUTTI I RESPONSI DI OGNI TRATTO
/// SONO IDENTICI?"*. Non sbagliava.
///
/// **PERCHE' QUESTA PROVA NON USA UN VOLTO SINTETICO.** Ne esisteva gia' una
/// che generava volti finti e ne misurava la varieta': diceva che il
/// classificatore variava, e sul telefono non variava. **Il modello di volto
/// che avevo costruito non somigliava ai volti veri**, quindi misurava
/// benissimo una cosa che non esiste. Qui entrano **i rapporti veri**, quelli
/// stampati dal telefono, e il giudizio si applica a loro.
///
/// **Cosa sorveglia da qui in avanti.** Che le soglie restino dentro
/// l'intervallo in cui i volti veri cadono. Se qualcuno le riporta a numeri
/// scelti a tavolino, i due volti tornano a ricevere lo stesso responso e
/// questa prova lo dice col nome della categoria.
///
/// **REGOLA H.** Non basta che i due volti si separino: si prova anche che lo
/// **stesso** volto, misurato due volte, non cambi responso a caso. Una soglia
/// posata in mezzo al rumore separerebbe tutto, anche una persona da se
/// stessa, e sarebbe varieta' finta.
void main() {
  /// I rapporti stampati dal dispositivo 767f596c l'8 settembre 2026.
  /// Le chiavi sono i nomi delle categorie come li stampa la schermata.
  const volto1 = <String, double>{
    'formaVolto': 0.7950,
    'fronte': 0.1804,
    'sopracciglia': 0.2434,
    'distanzaOcchi': 2.2756,
    'grandezzaOcchi': 0.0421,
    'naso': 0.3129,
    'labbra': 0.3164,
    'bocca': 0.3684,
    'mento': 0.6405,
    'mascella': 0.9046,
  };

  /// Lo stesso volto col cappello: serve alla Regola H, non alla separazione.
  const volto1ColCappello = <String, double>{
    'formaVolto': 0.9020,
    'fronte': 0.1297,
    'sopracciglia': 0.1884,
    'distanzaOcchi': 2.4035,
    'grandezzaOcchi': 0.0511,
    'naso': 0.3444,
    'labbra': 0.3222,
    'bocca': 0.3502,
    'mento': 0.6003,
    'mascella': 0.8519,
  };

  const volto2 = <String, double>{
    'formaVolto': 0.8645,
    'fronte': 0.1424,
    'sopracciglia': 0.2173,
    'distanzaOcchi': 2.2837,
    'grandezzaOcchi': 0.0547,
    'naso': 0.2971,
    'labbra': 0.3117,
    'bocca': 0.3663,
    'mento': 0.7484,
    'mascella': 0.8863,
  };

  /// **LE SOGLIE, LETTE DAL SORGENTE VERO E NON RICOPIATE QUI.** Una copia
  /// invecchierebbe per conto suo, e questa prova direbbe che tutto va bene
  /// mentre il classificatore usa altri numeri. Si cerca la riga, si prende
  /// il numero.
  final sorgente =
      File('lib/core/face/face_classifier.dart').readAsStringSync();

  double sogliaDi(String frammento) {
    final i = sorgente.indexOf(frammento);
    expect(i, greaterThanOrEqualTo(0),
        reason: 'nel classificatore non si trova piu\' "$frammento": questa '
            'prova non sta leggendo la soglia che crede');
    // Il numero sta poco prima del frammento, dopo un ">=" o un "<".
    final prima = sorgente.substring(i < 90 ? 0 : i - 90, i);
    final numeri = RegExp(r'([0-9]+\.[0-9]+)').allMatches(prima).toList();
    expect(numeri, isNotEmpty,
        reason: 'non si trova nessun numero prima di "$frammento"');
    return double.parse(numeri.last.group(1)!);
  }

  test('LE DUE PERSONE CADONO DA PARTI OPPOSTE, categoria per categoria', () {
    // Ogni voce: il frammento con cui si trova la soglia nel sorgente, e se
    // il confronto e' "maggiore o uguale" (vero) oppure "minore" (falso).
    const dove = <String, String>{
      'fronte': 'FaceTrait.fronteVerticale',
      'distanzaOcchi': 'FaceTrait.occhiRavvicinati',
      'grandezzaOcchi': 'FaceTrait.occhiGrandi',
      'naso': 'FaceTrait.nasoLungo',
      'labbra': 'FaceTrait.labbraPiene',
      'bocca': 'FaceTrait.boccaLarga',
      'mento': 'FaceTrait.mentoAmpio',
      'mascella': 'FaceTrait.mascellaLarga',
    };
    cardinaleMinimo(dove.length, 8,
        cosa: 'categorie di cui si conosce il rapporto sui volti veri',
        perche: 'Con meno categorie questa prova guarderebbe un pezzo del '
            'responso e direbbe che tutto il responso e a posto.');

    final insieme = <String>[];
    final separate = <String>[];
    for (final voce in dove.entries) {
      final soglia = sogliaDi(voce.value);
      final a = volto1[voce.key]!;
      final b = volto2[voce.key]!;
      final stessaParte = (a >= soglia) == (b >= soglia);
      // ignore: avoid_print
      print('ORDINE CX: ${voce.key} soglia $soglia, volto1 $a, volto2 $b, '
          '${stessaParte ? "STESSA RISPOSTA" : "risposte diverse"}');
      (stessaParte ? insieme : separate).add(voce.key);
    }
    // ignore: avoid_print
    print('ORDINE CX: su ${dove.length} categorie i due volti si separano in '
        '${separate.length} e ricevono la stessa risposta in '
        '${insieme.length}');
    // **Non si pretende la separazione su TUTTE**: due persone possono avere
    // davvero il naso della stessa lunghezza, e pretenderlo vorrebbe dire
    // chiedere soglie che separano il rumore. Si pretende che il responso nel
    // suo insieme non sia lo stesso, che e' esattamente cio' che il fondatore
    // ha visto.
    expect(separate.length, greaterThanOrEqualTo(5),
        reason: 'due persone diverse ricevono la stessa risposta in '
            '${insieme.length} categorie su ${dove.length}: '
            '${insieme.join(", ")}. E il difetto che il fondatore ha '
            'segnalato, e vuol dire che le soglie stanno fuori '
            'dall\'intervallo in cui cadono i volti veri');
  });

  test('REGOLA H: e lo stesso volto non si separa da se stesso', () {
    // Il cappello altera fronte e sopracciglia: e' giusto che quelle cambino.
    // Le altre no, e se cambiassero tutte vorrebbe dire che le soglie sono
    // posate dentro il rumore della misura invece che fra le persone.
    const dove = <String, String>{
      'distanzaOcchi': 'FaceTrait.occhiRavvicinati',
      'naso': 'FaceTrait.nasoLungo',
      'labbra': 'FaceTrait.labbraPiene',
      'bocca': 'FaceTrait.boccaLarga',
      'mento': 'FaceTrait.mentoAmpio',
      'mascella': 'FaceTrait.mascellaLarga',
    };
    var cambiate = 0;
    for (final voce in dove.entries) {
      final soglia = sogliaDi(voce.value);
      final a = volto1[voce.key]!;
      final b = volto1ColCappello[voce.key]!;
      if ((a >= soglia) != (b >= soglia)) cambiate++;
    }
    // ignore: avoid_print
    print('ORDINE CX: lo stesso volto col cappello cambia risposta in '
        '$cambiate categorie su ${dove.length}, escluse fronte e sopracciglia '
        'che il cappello copre davvero');
    expect(cambiate, lessThan(dove.length),
        reason: 'lo stesso volto cambia TUTTE le risposte quando si mette un '
            'cappello che non tocca quelle parti: le soglie stanno dentro il '
            'rumore della misura, e la varieta\' che si vede e\' rumore');
  });
}
