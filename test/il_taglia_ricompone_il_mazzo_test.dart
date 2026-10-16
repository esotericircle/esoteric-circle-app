// ignore_for_file: avoid_print
import 'dart:math' as math;

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/rituals/tavolo_dei_ventidue.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL TAGLIA RICOMPONE IL MAZZO, LO TAGLIA E LO RISTENDE.** Ordine EL voce
/// 02, 24 settembre 2026 sera.
///
/// **Il fondatore, verbatim**: *"nel Arcano dell'alba con il click al tasto
/// "Mischia" le carte si devono ricomporre in un mazzo, il mazzo viene
/// tagliato e poi dal mazzo le carte si ristendono"*, e subito dopo:
/// *"Scusa non Mischia. Ma "taglia". Il pulsante "Mischia" è già ok"*.
///
/// **Cosa faceva prima.** Le due meta' del ventaglio si scostavano a destra
/// e a sinistra e tornavano al loro posto, poi a corsa finita i posti si
/// scambiavano di colpo. Nessun mazzo, nessun taglio da vedere.
///
/// **QUESTA PROVA GUARDA DOVE STANNO LE CARTE**, fotogramma per fotogramma:
/// i ventidue dorsi sono uguali a video, ma ognuno ha la sua chiave e il suo
/// centro si legge. Si misura la sequenza che il fondatore ha detto, nel suo
/// ordine:
///
/// 1. **il mazzo si ricompone**: in un istante tutte e ventidue stanno in un
///    punto solo;
/// 2. **il mazzo viene tagliato**: dopo, le carte sono due pacchetti da
///    undici, ognuno raccolto, uno accanto all'altro e non sovrapposti;
/// 3. **il mazzo si richiude**: dopo il taglio le ventidue tornano in un
///    punto solo, ed e' da li' che si stendono;
/// 4. **le carte si ristendono**: a gesto finito ogni posto del tavolo e' di
///    nuovo occupato, e ogni carta sta dove stava la sua compagna del taglio;
/// 5. **nessuna carta salta**: fra un fotogramma e il successivo nessuna si
///    sposta di piu' di quanto il gesto consenta. Il taglio di prima
///    scambiava i posti a corsa finita, e le carte saltavano di colpo.
///
/// **E con le animazioni di sistema spente il gesto c'e' lo stesso, per
/// intero.** E' il contenuto del pulsante, come il volo dei semi del Soffio
/// (ordine EF): i ventidue dorsi sono uguali, e senza il gesto un tocco su
/// Taglia sul telefono con la scala degli animatori a zero non mostrerebbe
/// niente.
void main() {
  final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));

  /// Monta il solo tavolo, come la prova del tavolo, e aspetta che
  /// l'ingresso sia finito. Appena montato i posti sono in ordine: la carta
  /// numero `i` sta nel posto `i`, quindi il pacchetto di sopra sono le
  /// carte da undici a ventuno.
  Future<void> monta(WidgetTester tester, {bool ridotto = false}) async {
    tester.view.physicalSize = const Size(360, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final rivelazione = AnimationController(
        vsync: tester, duration: const Duration(milliseconds: 1400));
    addTearDown(rivelazione.dispose);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: TavoloDeiVentidue(
            palette: palette,
            onScegli: (_) {},
            rivelazione: rivelazione,
            ridotto: ridotto,
            faccia: (context) => const ColoredBox(color: Colors.amber),
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1600));
  }

  List<Offset> centri(WidgetTester tester) => [
        for (var i = 0; i < 22; i++)
          tester.getRect(find.byKey(Key('arcano_alba_dorso_$i'))).center,
      ];

  Offset medio(Iterable<Offset> punti) =>
      punti.reduce((a, b) => a + b) / punti.length.toDouble();

  /// Quanto e' sparso un gruppo: la distanza piu' grande di una sua carta dal
  /// centro del gruppo. Un mazzo raccolto sta sotto una manciata di punti.
  double sparso(Iterable<Offset> punti) {
    final m = medio(punti);
    return punti.map((p) => (p - m).distance).reduce(math.max);
  }

  const passo = 20;
  const raccolto = 12.0;

  /// Tocca Taglia e registra i ventidue centri ogni venti millesimi, per tre
  /// secondi: il gesto intero e il tavolo fermo dopo. **Il primo fotogramma
  /// e' quello di prima del tocco**: un taglio che scambia i posti subito
  /// salta proprio li'.
  Future<List<List<Offset>>> registraIlTaglio(WidgetTester tester) async {
    final fotogrammi = <List<Offset>>[centri(tester)];
    await tester.tap(find.byKey(const Key('arcano_alba_taglia')));
    await tester.pump();
    fotogrammi.add(centri(tester));
    for (var k = 0; k < 150; k++) {
      await tester.pump(const Duration(milliseconds: passo));
      fotogrammi.add(centri(tester));
    }
    return fotogrammi;
  }

  /// Le cinque grandezze della sequenza, lette sui fotogrammi.
  ({
    int primaRaccolta,
    int taglio,
    int richiuso,
    double sparsoMinimo,
    double distacco,
    double saltoMassimo,
    int fuoriPosto,
  }) misura(List<List<Offset>> fotogrammi, List<Offset> prima,
      double larghezzaCarta) {
    final sopra = [for (var c = 11; c < 22; c++) c];
    final sotto = [for (var c = 0; c < 11; c++) c];
    var sparsoMinimo = double.infinity;
    for (final f in fotogrammi) {
      sparsoMinimo = math.min(sparsoMinimo, sparso(f));
    }
    final primaRaccolta = fotogrammi.indexWhere((f) => sparso(f) < raccolto);

    // Il taglio: due pacchetti raccolti, uno accanto all'altro. Il distacco
    // e' la distanza orizzontale fra i due centri, e deve superare la
    // larghezza di una carta perche' non si sovrappongano.
    var taglio = -1;
    var distacco = 0.0;
    for (var k = math.max(primaRaccolta, 0); k < fotogrammi.length; k++) {
      final f = fotogrammi[k];
      final a = [for (final c in sopra) f[c]];
      final b = [for (final c in sotto) f[c]];
      if (sparso(a) >= raccolto || sparso(b) >= raccolto) continue;
      final d = (medio(a).dx - medio(b).dx).abs();
      distacco = math.max(distacco, d);
      if (taglio < 0 && d > larghezzaCarta) taglio = k;
    }
    final richiuso = taglio < 0
        ? -1
        : fotogrammi.indexWhere((f) => sparso(f) < raccolto, taglio + 1);

    var saltoMassimo = 0.0;
    for (var k = 1; k < fotogrammi.length; k++) {
      for (var c = 0; c < 22; c++) {
        saltoMassimo = math.max(
            saltoMassimo, (fotogrammi[k][c] - fotogrammi[k - 1][c]).distance);
      }
    }

    // A gesto finito la carta `c` sta dove stava la sua compagna del taglio:
    // il mazzo si divide a meta' e il pacchetto di sotto passa sopra.
    final dopo = fotogrammi.last;
    var fuoriPosto = 0;
    for (var c = 0; c < 22; c++) {
      if ((dopo[c] - prima[(c + 11) % 22]).distance > 10) fuoriPosto++;
    }
    return (
      primaRaccolta: primaRaccolta,
      taglio: taglio,
      richiuso: richiuso,
      sparsoMinimo: sparsoMinimo,
      distacco: distacco,
      saltoMassimo: saltoMassimo,
      fuoriPosto: fuoriPosto,
    );
  }

  void pretendiLaSequenza(
      ({
        int primaRaccolta,
        int taglio,
        int richiuso,
        double sparsoMinimo,
        double distacco,
        double saltoMassimo,
        int fuoriPosto,
      }) m,
      double larghezzaCarta) {
    expect(m.primaRaccolta, greaterThan(-1),
        reason: 'le ventidue carte non si raccolgono mai in un mazzo: al '
            'massimo stanno entro ${m.sparsoMinimo.toStringAsFixed(1)} punti '
            'dal loro centro, e un mazzo sta entro $raccolto');
    expect(m.taglio, greaterThan(m.primaRaccolta),
        reason: 'dopo la raccolta il mazzo non si divide in due pacchetti '
            'affiancati: il distacco massimo fra i due e\' '
            '${m.distacco.toStringAsFixed(1)} punti contro una carta larga '
            '${larghezzaCarta.toStringAsFixed(1)}');
    expect(m.richiuso, greaterThan(m.taglio),
        reason: 'dopo il taglio il mazzo non si richiude: le carte si '
            'stendono dai due pacchetti e non dal mazzo');
    expect(m.fuoriPosto, 0,
        reason: '${m.fuoriPosto} carte su ventidue non stanno dove stava la '
            'loro compagna del taglio: il tavolo non e\' tornato steso, o il '
            'taglio non e\' quello del mazzo');
    expect(m.saltoMassimo, lessThan(36),
        reason: 'una carta salta di ${m.saltoMassimo.toStringAsFixed(1)} '
            'punti in venti millesimi: i posti cambiano sotto gli occhi');
  }

  testWidgets(
      'TAGLIA: il mazzo si ricompone, viene tagliato, si richiude e le carte '
      'si ristendono', (tester) async {
    await monta(tester);
    final larghezzaCarta =
        tester.getSize(find.byKey(const Key('arcano_alba_dorso_0'))).width;
    final prima = centri(tester);
    final fotogrammi = await registraIlTaglio(tester);
    final m = misura(fotogrammi, prima, larghezzaCarta);
    print(
        'ORDINE EL VOCE 02: mazzo raccolto a ${(m.primaRaccolta - 1) * passo} ms '
        '(sparso minimo ${m.sparsoMinimo.toStringAsFixed(1)} punti), '
        'taglio a ${(m.taglio - 1) * passo} ms (distacco '
        '${m.distacco.toStringAsFixed(1)} punti, carta larga '
        '${larghezzaCarta.toStringAsFixed(1)}), richiuso a '
        '${(m.richiuso - 1) * passo} ms, salto massimo '
        '${m.saltoMassimo.toStringAsFixed(1)} punti, fuori posto '
        '${m.fuoriPosto}');
    pretendiLaSequenza(m, larghezzaCarta);
  });

  testWidgets(
      'LE CARTE NON SI RICREANO QUANDO CAMBIANO POSTO, ne\' col Taglia ne\' '
      'col Mischia', (tester) async {
    // **Il fatto visto sul Realme**, 24 settembre 2026 alle 22:16, con la
    // build di prova di prima: dopo il tocco su Taglia il tavolo e' rimasto
    // VUOTO per circa un secondo (fotogrammi a 0,60 e 0,64 secondi senza
    // carte, di nuovo carte a 1,61). Con la build nuova non si e' ripetuto in
    // tre registrazioni, e la causa esatta non si e' potuta riprodurre.
    //
    // **Il meccanismo che puo' svuotarlo pero' c'era, e si misura qui.** Le
    // carte stanno nella pila in ordine di posto, e la chiave stava sul
    // dorso, due livelli sotto: a ogni scambio di posti Flutter non poteva
    // spostare le carte, distruggeva e ricreava le ventidue immagini, che
    // devono ritrovare il loro disegno prima di comparire. Con la chiave sul
    // figlio della pila le carte si spostano e ogni immagine resta quella di
    // prima. Qui si pretende che lo stato dell'immagine di ciascuna delle
    // ventidue carte sia LO STESSO oggetto prima e dopo i due gesti, anche
    // col movimento ridotto, dove i posti si scambiano in un colpo.
    for (final ridotto in [false, true]) {
      await monta(tester, ridotto: ridotto);
      List<State> immagini() => [
            for (var i = 0; i < 22; i++)
              tester.state(find.byKey(Key('arcano_alba_dorso_$i'))),
          ];
      final prima = immagini();
      await tester.tap(find.byKey(const Key('arcano_alba_mischia')));
      for (var k = 0; k < 25; k++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.tap(find.byKey(const Key('arcano_alba_taglia')));
      for (var k = 0; k < 25; k++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      final dopo = immagini();
      final ricreate = [
        for (var i = 0; i < 22; i++)
          if (!identical(prima[i], dopo[i])) i
      ];
      print('ORDINE EL VOCE 02, ridotto $ridotto: immagini ricreate '
          '${ricreate.length} su 22');
      expect(ricreate, isEmpty,
          reason: 'col movimento ${ridotto ? 'ridotto' : 'pieno'} queste '
              'carte hanno perso la loro immagine cambiando posto, e sul '
              'telefono restano vuote finche\' non la ritrovano: $ricreate');
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('NESSUN DORSO SI SCEGLIE MENTRE IL MAZZO E\' RACCOLTO',
      (tester) async {
    // Col mazzo chiuso il tocco prenderebbe la carta in cima, e il volo
    // partirebbe dal suo posto sul tavolo, lontano da dove la si vede. Si
    // tocca a meta' raccolta: le carte sono ancora sul tavolo e il dito le
    // prende davvero, cosi' la prova misura il blocco e non un tocco finito
    // nel vuoto.
    final scelti = <int>[];
    tester.view.physicalSize = const Size(360, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final rivelazione = AnimationController(
        vsync: tester, duration: const Duration(milliseconds: 1400));
    addTearDown(rivelazione.dispose);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: TavoloDeiVentidue(
            palette: palette,
            onScegli: scelti.add,
            rivelazione: rivelazione,
            faccia: (context) => const ColoredBox(color: Colors.amber),
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.tap(find.byKey(const Key('arcano_alba_taglia')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.byKey(const Key('arcano_alba_carta_0')),
        warnIfMissed: false);
    await tester.pump();
    expect(scelti, isEmpty,
        reason: 'durante il Taglia il tocco ha scelto $scelti');
    for (var k = 0; k < 25; k++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.tap(find.byKey(const Key('arcano_alba_carta_0')));
    await tester.pump();
    expect(scelti, [0],
        reason: 'a Taglia finito il tocco sul dorso zero ha scelto $scelti');
  });

  testWidgets(
      'CON LE ANIMAZIONI DI SISTEMA SPENTE il taglio si vede lo stesso, e non '
      'si accorcia', (tester) async {
    // Il Realme di collaudo ha le tre scale a zero: Flutter lo legge come
    // `disableAnimations`, l'Arcano come Riduci Movimento, e un controllore
    // `normal` corre venti volte piu' in fretta.
    debugSemanticsDisableAnimations = true;
    addTearDown(() => debugSemanticsDisableAnimations = null);
    await monta(tester, ridotto: true);
    final larghezzaCarta =
        tester.getSize(find.byKey(const Key('arcano_alba_dorso_0'))).width;
    final prima = centri(tester);
    final fotogrammi = await registraIlTaglio(tester);
    final m = misura(fotogrammi, prima, larghezzaCarta);
    print('ORDINE EL VOCE 02, animazioni spente: mazzo raccolto a '
        '${(m.primaRaccolta - 1) * passo} ms, taglio a ${(m.taglio - 1) * passo} ms, '
        'richiuso a ${(m.richiuso - 1) * passo} ms, salto massimo '
        '${m.saltoMassimo.toStringAsFixed(1)} punti, fuori posto '
        '${m.fuoriPosto}');
    pretendiLaSequenza(m, larghezzaCarta);
    expect((m.primaRaccolta - 1) * passo, greaterThanOrEqualTo(300),
        reason: 'il mazzo si e\' chiuso in ${(m.primaRaccolta - 1) * passo} '
            'millesimi: il gesto e\' stato accorciato, e a occhio non si vede');
  });
}
