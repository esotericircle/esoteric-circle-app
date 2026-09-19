import 'package:esoteric_circle/core/face/punti_del_volto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediapipe_face_mesh/mediapipe_face_mesh.dart';

/// **I PUNTI SONO DAVVERO QUELLE PARTI DEL VISO.** Ordine CR voce 05, seconda
/// stesura, 6 settembre 2026.
///
/// **Parole del fondatore**: *"i punti rilevati dovrebbero corrispondere ai
/// tratti somatici, ma non l'avevo gia' chiesto? Perche' non posso avere cio'
/// che chiedo?"*.
///
/// **AVEVA RAGIONE, E VA SCRITTO.** Quello che esisteva erano indici che
/// DICHIARAVANO di corrispondere ai tratti, e una guardia,
/// `i_punti_del_volto_sono_veri_test.dart`, che verificava quattro cose: che
/// ogni indice stesse sotto 478, che nessun gruppo fosse vuoto, che destra e
/// sinistra non condividessero punti, che dentro un gruppo non ci fossero
/// doppioni. **Tutte e quattro restano verdi anche se i numeri sono
/// completamente sbagliati.** Se l'indice 33 fosse il mento invece dell'occhio
/// destro, nessuna di quelle pretese se ne accorgerebbe. E quei numeri li ho
/// scritti io dichiarandoli canonici, senza niente nel repo che lo dimostrasse.
///
/// **DOVE STA LA VERITA' INDIPENDENTE, e non e' una mia parola.** Il pacchetto
/// porta la TOPOLOGIA della maglia, derivata da `FACEMESH_TESSELATION`: gli 852
/// triangoli che dicono quali punti sono cuciti a quali. Quella topologia non
/// l'ho scritta io e non dipende dai miei gruppi, e da li' si ricava un fatto
/// che nessun elenco sbagliato puo' soddisfare per caso: **le parti del viso
/// sono ANELLI CHIUSI**. Il contorno di un occhio e' un anello, quello di un
/// sopracciglio e' una catena, l'ovale del volto e' l'anello piu' esterno. Un
/// gruppo di indici presi a caso non forma nessun anello.
///
/// **COSA QUESTA GUARDIA NON PROVA, dichiarato.** Prova che ogni gruppo e' una
/// struttura vera e coerente della maglia, e che le strutture stanno nella
/// posizione reciproca giusta. **Non prova che l'anello che chiamiamo occhio
/// sinistro sia l'occhio SINISTRO** e non il destro: per quello servirebbe il
/// modello canonico con le posizioni dei vertici, che questo pacchetto non
/// espone dal lato Dart. La destra e la sinistra restano da verificare a video
/// su un telefono, ed e' scritto qui invece di essere dato per fatto.
void main() {
  /// La topologia vera della maglia, presa dal pacchetto.
  ///
  /// Si costruisce un risultato con punti finti: **i triangoli non dipendono
  /// dalle posizioni**, sono la cucitura fissa del modello, e il pacchetto li
  /// costruisce dalla sua tabella `FACEMESH_TESSELATION`.
  late final List<MpFaceMeshTriangle> triangoli = FaceMeshResult(
    landmarks: [
      for (var i = 0; i < PuntiDelVolto.quantiPunti; i++)
        FaceMeshLandmark(x: 0, y: 0, z: 0),
    ],
    rect: const NormalizedRect(
        xCenter: 0.5, yCenter: 0.5, width: 1, height: 1, rotation: 0),
    score: 1,
    imageWidth: 100,
    imageHeight: 100,
  ).triangles;

  /// Chi e' cucito a chi.
  late final Map<int, Set<int>> vicini = () {
    final m = <int, Set<int>>{};
    void lega(int a, int b) {
      (m[a] ??= <int>{}).add(b);
      (m[b] ??= <int>{}).add(a);
    }

    for (final t in triangoli) {
      lega(t.indices[0], t.indices[1]);
      lega(t.indices[1], t.indices[2]);
      lega(t.indices[2], t.indices[0]);
    }
    return m;
  }();

  test('la topologia del pacchetto e\' quella vera', () {
    // Se questa cade, tutto il resto del file non sta misurando niente.
    expect(triangoli, hasLength(852),
        reason: 'la maglia non ha gli 852 triangoli di FACEMESH_TESSELATION: '
            'la fonte di verita\' di questo file non e\' quella che credo');
    expect(vicini.keys.length, greaterThan(400),
        reason: 'la cucitura tocca troppi pochi punti per essere la maglia');
  });

  group('ogni gruppo e\' una struttura vera della maglia', () {
    for (final e in PuntiDelVolto.gruppi.entries) {
      test('«${e.key}» e\' cucito insieme, non e\' una manciata di numeri', () {
        // **IL FATTO CHE NESSUN ELENCO SBAGLIATO SODDISFA PER CASO.** Dentro
        // il gruppo, ogni punto deve essere cucito ad almeno un altro punto
        // dello stesso gruppo, e il gruppo deve essere tutto d'un pezzo:
        // partendo da un punto qualsiasi si raggiungono tutti gli altri
        // camminando sulla cucitura. Prendendo indici a caso, la
        // probabilita' di ottenere un insieme connesso e' minima.
        final insieme = e.value.toSet();
        final soli = <int>[];
        for (final i in insieme) {
          final quanti = (vicini[i] ?? const <int>{})
              .where(insieme.contains)
              .length;
          if (quanti == 0) soli.add(i);
        }
        expect(soli, isEmpty,
            reason: 'nel gruppo «${e.key}» questi punti non sono cuciti a '
                'nessun altro punto dello stesso gruppo: $soli. Non sono '
                'parte della stessa struttura del viso');

        // Tutto d'un pezzo: si cammina dalla prima e si contano gli arrivi.
        final visti = <int>{insieme.first};
        final coda = <int>[insieme.first];
        while (coda.isNotEmpty) {
          final q = coda.removeLast();
          for (final v in vicini[q] ?? const <int>{}) {
            if (insieme.contains(v) && visti.add(v)) coda.add(v);
          }
        }
        expect(visti.length, insieme.length,
            reason: 'il gruppo «${e.key}» e\' spezzato in piu\' pezzi: dalla '
                'prima si raggiungono ${visti.length} punti su '
                '${insieme.length}. Una parte del viso e\' una cosa sola');
      });
    }
  });

  test('gli occhi sono due anelli chiusi, e ogni punto ha due vicini', () {
    // **UN CONTORNO E' UN ANELLO.** Dentro il gruppo, ogni punto ne tocca
    // esattamente due: quello prima e quello dopo. E' la firma di un
    // contorno chiuso, e un elenco sbagliato non ce l'ha.
    for (final nome in ['occhio sinistro', 'occhio destro']) {
      final insieme = PuntiDelVolto.gruppi[nome]!.toSet();
      final gradi = <int, int>{
        for (final i in insieme)
          i: (vicini[i] ?? const <int>{}).where(insieme.contains).length,
      };
      final storti = gradi.entries.where((x) => x.value != 2).toList();
      expect(storti, isEmpty,
          reason: 'il gruppo «$nome» non e\' un anello: questi punti non '
              'hanno esattamente due vicini dentro il gruppo, '
              '${storti.map((x) => '${x.key} ne ha ${x.value}').join(', ')}');
    }
  });

  test('i due occhi non si toccano', () {
    // Se un gruppo avesse preso punti dell'altro occhio, o del naso in mezzo,
    // i due anelli risulterebbero cuciti fra loro.
    final sx = PuntiDelVolto.gruppi['occhio sinistro']!.toSet();
    final dx = PuntiDelVolto.gruppi['occhio destro']!.toSet();
    final toccano = <String>[];
    for (final i in sx) {
      for (final v in vicini[i] ?? const <int>{}) {
        if (dx.contains(v)) toccano.add('$i-$v');
      }
    }
    expect(toccano, isEmpty,
        reason: 'i due occhi sono cuciti fra loro: $toccano. Due occhi sono '
            'separati dalla radice del naso, e se si toccano uno dei due '
            'non e\' un occhio');
  });

  // **QUANTI PASSI CI VOGLIONO PER ANDARE DA UN GRUPPO ALL'ALTRO.**
  //
  // Misurato sulla maglia vera: **nessun gruppo tocca gli altri**, tranne
  // le due labbra con quattro cuciture. E' giusto cosi': fra un
  // sopracciglio e il suo occhio c'e' della pelle, cioe' altri vertici.
  // Pretendere il contatto diretto era una mia assunzione sbagliata sulla
  // topologia, non un difetto degli indici: le due prove che lo
  // pretendevano cadevano, e sono state rifatte sulla distanza.
  int passiFra(Set<int> da, Set<int> a) {
    final visti = <int>{...da};
    var fronte = <int>[...da];
    var passi = 0;
    while (fronte.isNotEmpty && passi < 30) {
      if (fronte.any(a.contains)) return passi;
      final prossima = <int>[];
      for (final q in fronte) {
        for (final v in vicini[q] ?? const <int>{}) {
          if (visti.add(v)) prossima.add(v);
        }
      }
      fronte = prossima;
      passi++;
    }
    return 99;
  }

  test('ogni sopracciglio sta piu\' vicino al suo occhio che all\'altro',
      () {
    // **LA RELAZIONE CHE DISTINGUE LE DUE COPPIE.** Se un sopracciglio
    // avesse gli indici dell'altro lato, risulterebbe piu' vicino
    // all'occhio sbagliato. E' una relazione fra distanze, quindi non
    // dipende da quanto e' fitta la maglia in quel punto.
    for (final coppia in [
      ('sopracciglio sinistro', 'occhio sinistro', 'occhio destro'),
      ('sopracciglio destro', 'occhio destro', 'occhio sinistro'),
    ]) {
      final soprac = PuntiDelVolto.gruppi[coppia.$1]!.toSet();
      final suo = passiFra(soprac, PuntiDelVolto.gruppi[coppia.$2]!.toSet());
      final altro =
          passiFra(soprac, PuntiDelVolto.gruppi[coppia.$3]!.toSet());
      expect(suo, lessThan(altro),
          reason: '«${coppia.$1}» dista $suo passi da «${coppia.$2}» e '
              '$altro da «${coppia.$3}»: sta piu\' vicino all\'occhio '
              'sbagliato, quindi i due lati sono scambiati');
    }
  });

  test('il ponte del naso sta in mezzo, alla stessa distanza dai due '
      'occhi', () {
    // Il ponte del naso corre lungo la linea di mezzo: se stesse da una
    // parte sola, le due distanze sarebbero diverse.
    final ponte = PuntiDelVolto.ponteDelNaso.toSet();
    final sx = passiFra(ponte, PuntiDelVolto.gruppi['occhio sinistro']!.toSet());
    final dx = passiFra(ponte, PuntiDelVolto.gruppi['occhio destro']!.toSet());
    expect((sx - dx).abs(), lessThanOrEqualTo(1),
          reason: 'il ponte del naso dista $sx passi da un occhio e $dx '
              'dall\'altro: non corre lungo la linea di mezzo del viso');
    expect(sx, lessThan(99),
        reason: 'il ponte del naso non e\' nemmeno collegato agli occhi');
  });

  test('le labbra formano una bocca sola, chiusa', () {
    // Le due labbra insieme sono un anello: se uno dei due elenchi fosse
    // sbagliato, la bocca non si chiuderebbe.
    final bocca = {
      ...PuntiDelVolto.gruppi['labbro superiore']!,
      ...PuntiDelVolto.gruppi['labbro inferiore']!,
    };
    final storti = <String>[];
    for (final i in bocca) {
      final quanti = (vicini[i] ?? const <int>{}).where(bocca.contains).length;
      if (quanti < 2) storti.add('$i ne ha $quanti');
    }
    expect(storti, isEmpty,
        reason: 'le due labbra insieme non chiudono un anello: $storti');
  });

  test('l\'ovale e\' il bordo della maglia', () {
    // **IL FATTO CHE DISTINGUE L'OVALE DA QUALUNQUE ALTRO ANELLO.** I punti
    // sul bordo esterno di una maglia hanno meno triangoli attorno di quelli
    // interni, perche' da un lato non c'e' niente. Si confronta la media dei
    // triangoli attorno all'ovale con quella di tutta la maglia.
    final ovale = PuntiDelVolto.ovale.toSet();
    final quantiTriangoli = <int, int>{};
    for (final t in triangoli) {
      for (final i in t.indices) {
        quantiTriangoli[i] = (quantiTriangoli[i] ?? 0) + 1;
      }
    }
    double media(Iterable<int> punti) {
      var somma = 0;
      var quanti = 0;
      for (final i in punti) {
        somma += quantiTriangoli[i] ?? 0;
        quanti++;
      }
      return quanti == 0 ? 0 : somma / quanti;
    }

    final sulBordo = media(ovale);
    final dentro = media(quantiTriangoli.keys.where((i) => !ovale.contains(i)));
    expect(sulBordo, lessThan(dentro),
        reason: 'i punti che chiamiamo ovale hanno attorno tanti triangoli '
            'quanto quelli interni ($sulBordo contro $dentro): non stanno sul '
            'bordo della maglia, quindi non sono il contorno del volto');
  });


}
