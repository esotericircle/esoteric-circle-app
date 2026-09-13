import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/core/viaggio/dove_sta_la_testa.dart';
import 'package:esoteric_circle/core/viaggio/il_velo_dell_animale.dart';
import 'package:esoteric_circle/core/viaggio/le_sagome_in_celle.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/il_velo_che_si_scosta.dart';

/// **LA GUARDIA CHE GUARDA I PIXEL.** Nata con l'ordine DE voce 03 per la
/// lente, riscritta con l'ordine DI voce 10 per il velo che si scosta,
/// 13 settembre 2026.
///
/// **IL DIFETTO CHE LA FECE NASCERE.** L'11 settembre 2026, sul 767f596c, alla
/// seconda e alla terza discesa l'animale si vedeva **intero, testa
/// compresa**: il velo della lente era costruito, era opaco, e non dipingeva
/// niente, perche' uno `ShaderMask` con `BlendMode.dstIn` sul telefono lo
/// cancellava intero. Due guardie erano verdi, una sulla geometria e una
/// sull'albero.
///
/// **Percio' la grandezza misurata qui sta nei pixel dipinti**, letti dal
/// fotogramma vero: **quanto dell'animale arriva a schermo** nel rettangolo
/// della testa, per tutti e dodici, nelle tre discese in cui deve restare
/// coperto **anche con tutto il resto gia' scostato**, e alla quarta in cui
/// deve vedersi. E quanto arriva a schermo, oggi, di cio' che si e' scostato
/// ieri.
///
/// **QUANTO DELL'ANIMALE ARRIVA A SCHERMO, e non quanto e' nitido.** La prima
/// stesura di questa guardia per il velo misurava la nitidezza, come per la
/// lente, e sul Cervo dava 0,404 con la testa coperta: il suo rettangolo della
/// testa e' largo e quasi tutto vuoto, e cio' che era nitido era **il bordo
/// della cenere contro il fondo**, cioe' la cenere stessa, non l'animale.
/// Adesso lo stesso fotogramma si dipinge due volte, con l'illustrazione e
/// senza: la differenza fra i due e' esattamente l'animale che passa.
///
/// **LA SOGLIA E' DELLA GRANDEZZA NUOVA, e la si dichiara.** Con la lente il
/// fantasma sfocato doveva vedersi, e la nitidezza velata poteva arrivare a
/// quattro decimi di quella scoperta. Sotto la cenere non deve passare
/// niente: misurato lo 0,2 per cento sulla testa del Cervo, che e' il caso
/// peggiore, e lo 0,1 per cento sulle celle coperte. La soglia e' **un
/// decimo**: una cenere al novanta per cento di opacita' la passerebbe appena,
/// una a meta' no.
///
/// **IL METRO E' L'ANIMALE TUTTO SCOSTATO, non il velo caduto.** La prima
/// stesura misurava il metro alla quarta discesa a velo caduto, ma la foto si
/// scatta dentro `runAsync`, dove il timer della caduta corre in tempo vero e
/// i `pump` non lo spingono: la foto coglieva la caduta a meta', piu' o meno
/// secondo la macchina, e il metro ballava fra 4,6 e 9. Che il velo cada alla
/// quarta lo prova, a tempo finto, `la_testa_non_si_vede_prima_della_quarta`.
///
/// **E la forma del velo**: nessuna maschera di fusione, nessuna sfocatura,
/// nessuna opacita' fra la cenere e lo schermo. La cenere e' pittura piena.
void main() {
  const scena = Size(390, 844);

  /// **QUANTO DIFFERISCONO DUE FOTOGRAMMI** dentro un insieme di rettangoli:
  /// la media della differenza di luce, pixel per pixel.
  double quantoDifferiscono(
      Uint8List a, Uint8List b, int larga, Iterable<Rect> dove) {
    var somma = 0.0;
    var quanti = 0;
    for (final r in dove) {
      for (var y = r.top.toInt(); y < r.bottom.toInt(); y++) {
        for (var x = r.left.toInt(); x < r.right.toInt(); x++) {
          final i = (y * larga + x) * 4;
          if (i < 0 || i + 2 >= a.length) continue;
          somma += ((a[i] + a[i + 1] + a[i + 2]) -
                      (b[i] + b[i + 1] + b[i + 2]))
                  .abs() /
              3;
          quanti++;
        }
      }
    }
    return quanti == 0 ? 0 : somma / quanti;
  }

  /// Un rettangolo in frazioni dell'illustrazione, in punti della scena.
  Rect inPunti(Rect illustrazione, Rect f) => Rect.fromLTRB(
        illustrazione.left + illustrazione.width * f.left,
        illustrazione.top + illustrazione.height * f.top,
        illustrazione.left + illustrazione.width * f.right,
        illustrazione.top + illustrazione.height * f.bottom,
      );

  /// Il fotogramma del velo di [animale]; **senza l'illustrazione** quando
  /// [conLAnimale] e' falso, cioe' la sola cenere nella stessa posizione.
  Future<Uint8List> fotogramma(WidgetTester tester, GuideAnimal animale,
      int quale, Set<int> gia, {bool conLAnimale = true}) async {
    // **LA GRANA PRIMA DI TUTTO**: i due fotogrammi di una coppia devono
    // avere la stessa cenere, o la differenza fra loro sarebbe la grana.
    await GranaDellaCenere.prepara();
    final immagine =
        conLAnimale ? animale.fullPath : 'assets/img/animali/nessuno.webp';
    await tester.pumpWidget(MaterialApp(
      home: RepaintBoundary(
        key: const Key('foglio'),
        child: SizedBox(
          width: scena.width,
          height: scena.height,
          child: IlVeloCheSiScosta(
            key: ValueKey('${animale.name}$quale${gia.length}$conLAnimale'),
            nome: animale.name,
            immagine: immagine,
            quale: quale,
            giaScoperte: gia,
            quandoCambia: (_) {},
            palette: MaestroPalette.caligo,
          ),
        ),
      ),
    ));
    if (conLAnimale) {
      await precacheImage(AssetImage(animale.fullPath),
          tester.element(find.byType(SizedBox).first));
    }
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(IlVeloCheSiScosta.quantoDuraLaCaduta);
    await tester.pump(IlVeloCheSiScosta.vitaDellaParticella);
    final foglio = tester
        .renderObject<RenderRepaintBoundary>(find.byKey(const Key('foglio')));
    final quadro = await foglio.toImage();
    final dati = await quadro.toByteData(format: ui.ImageByteFormat.rawRgba);
    return dati!.buffer.asUint8List();
  }

  testWidgets(
      'REGOLA I: nelle prime tre discese la testa non e mai nitida, nemmeno '
      'con tutto il resto gia scostato, e alla quarta lo diventa, per tutti e '
      'dodici', (tester) async {
    debugSemanticsDisableAnimations = true;
    addTearDown(() => debugSemanticsDisableAnimations = null);
    await tester.binding.setSurfaceSize(scena);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    // **IL CARDINALE MINIMO.**
    expect(AnimalCatalog.animals.length, 12);
    expect(DoveStaLaTesta.nomi.length, 12);

    final rapporti = <String, double>{};
    var quanti = 0;
    await tester.runAsync(() async {
      for (final animale in AnimalCatalog.animals) {
        final velo = IlVeloDellAnimale(animale.name);
        final illustrazione = IlVeloCheSiScosta.doveStaLIllustrazione(
            scena, LeSagome.misure[animale.name]!);
        final testa =
            inPunti(illustrazione, DoveStaLaTesta.di(animale.name)!);

        // **IL METRO DI QUESTO ANIMALE: quanto della sua testa arriva a
        // schermo quando non c'e' nessuna cenere**, cioe' con ogni cella
        // velata, il cumulo della testa compreso, gia' in chiaro.
        final scoperta = quantoDifferiscono(
            await fotogramma(tester, animale, 0, velo.velato),
            await fotogramma(tester, animale, 0, velo.velato,
                conLAnimale: false),
            scena.width.toInt(),
            [testa]);
        expect(scoperta, greaterThan(5),
            reason: '${animale.name}: della testa non arriva niente nemmeno '
                'senza cenere, e allora questa prova non starebbe misurando '
                'niente');

        // **IL CASO PEGGIORE**: tutto il corpo fuori dalla testa gia'
        // scostato, cioe' la cenere rimasta e' soltanto quella della testa.
        for (var quale = 0;
            quale < IlVeloDellAnimale.discesePrimaDellaTesta;
            quale++) {
          final velata = quantoDifferiscono(
              await fotogramma(tester, animale, quale, velo.scostabile),
              await fotogramma(tester, animale, quale, velo.scostabile,
                  conLAnimale: false),
              scena.width.toInt(),
              [testa]);
          quanti++;
          final rapporto = velata / scoperta;
          if (rapporto >= (rapporti[animale.name] ?? 0)) {
            rapporti[animale.name] = rapporto;
          }
          expect(rapporto, lessThan(0.1),
              reason: 'la testa di ${animale.name} alla discesa ${quale + 1} '
                  'arriva a schermo quasi quanto quella scoperta '
                  '(${velata.toStringAsFixed(2)} contro '
                  '${scoperta.toStringAsFixed(2)}): la cenere non la copre');
        }
      }
    });

    final peggiore =
        rapporti.entries.reduce((a, b) => a.value > b.value ? a : b);
    // ignore: avoid_print
    print('ORDINE DI VOCE 10, LA TESTA A SCHERMO: $quanti discese col corpo '
        'tutto scostato, la parte peggiore di testa che arriva sotto la '
        'cenere e ${peggiore.value.toStringAsFixed(3)} (${peggiore.key}); '
        'zero vuol dire niente');
  });

  /// **A VELO INTERO NON SI VEDE NESSUN PIXEL DELL'ANIMALE, nemmeno delle
  /// parti sottili.** Ordine DI voce 10, 13 settembre 2026.
  ///
  /// **Il difetto che la fa nascere, trovato prima del telefono.** La prima
  /// stesura delle sagome prendeva per corpo le celle piene per un terzo, e
  /// le parti sottili cadevano fuori dalla cenere: con quelle sagome, alla
  /// prima discesa, del Cervo si vedevano **152 pixel**, le punte dei palchi,
  /// e 44 del Serpente. Sono la firma della specie. La media della guardia
  /// qui sopra non li vede, perche' pesano poco in area: qui si contano uno
  /// per uno, su tutta l'illustrazione, e il numero preteso e' **zero**.
  ///
  /// Un pixel dell'animale si vede quando il fotogramma con l'illustrazione e
  /// quello senza differiscono di piu' di un decimo della luce. Con le sagome
  /// di adesso sono zero su dodici animali.
  testWidgets(
      'a velo intero non si vede nessun pixel dell animale, per tutti e dodici',
      (tester) async {
    debugSemanticsDisableAnimations = true;
    addTearDown(() => debugSemanticsDisableAnimations = null);
    await tester.binding.setSurfaceSize(scena);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    int visibili(Uint8List a, Uint8List b, Rect r) {
      var n = 0;
      for (var y = r.top.toInt(); y < r.bottom.toInt(); y++) {
        for (var x = r.left.toInt(); x < r.right.toInt(); x++) {
          final i = (y * scena.width.toInt() + x) * 4;
          final d = ((a[i] + a[i + 1] + a[i + 2]) -
                      (b[i] + b[i + 1] + b[i + 2]))
                  .abs() /
              3;
          if (d > 25.5) n++;
        }
      }
      return n;
    }

    expect(AnimalCatalog.animals.length, 12);
    final visti = <String>[];
    await tester.runAsync(() async {
      for (final animale in AnimalCatalog.animals) {
        final velo = IlVeloDellAnimale(animale.name);
        final r = IlVeloCheSiScosta.doveStaLIllustrazione(
            scena, LeSagome.misure[animale.name]!);
        // **IL CARDINALE DI QUESTO ANIMALE**: senza cenere se ne vedono
        // decine di migliaia, o la prova non guarda niente.
        final tutto = visibili(
            await fotogramma(tester, animale, 0, velo.velato),
            await fotogramma(tester, animale, 0, velo.velato,
                conLAnimale: false),
            r);
        expect(tutto, greaterThan(20000),
            reason: '${animale.name}: senza cenere se ne vedono solo $tutto '
                'pixel, e allora la prova non guarda l\'animale');
        final sotto = visibili(await fotogramma(tester, animale, 0, const {}),
            await fotogramma(tester, animale, 0, const {}, conLAnimale: false),
            r);
        if (sotto > 0) visti.add('${animale.name} $sotto su $tutto');
      }
    });
    expect(visti, isEmpty,
        reason: 'A VELO INTERO SI VEDE UN PEZZO DI ANIMALE: ${visti.join(', ')}. '
            'Sono le parti sottili, palchi, becchi, lingue, code, che la '
            'sagoma non ha preso per corpo: la firma della specie alla prima '
            'discesa.');
  });

  /// **LA RIVELAZIONE E' CUMULATIVA: cio' che hai scostato ieri resta in
  /// chiaro.** Ordine DI voce 10: *"la superficie gia' scoperta nelle discese
  /// precedenti resta scoperta e si ritrova riaprendo la funzione"*.
  ///
  /// La grandezza e' la stessa, quanto dell'animale arriva a schermo, sulle
  /// celle di un quarto del corpo dal basso, con e senza quelle celle fra le
  /// gia' scostate. Si misura il cuore di ogni cella, perche' i granelli delle
  /// vicine ancora coperte sbordano un poco sul bordo, ed e' voluto.
  testWidgets(
      'le celle scostate nelle discese di prima sono in chiaro, e senza di '
      'loro sono coperte, per tutti e dodici', (tester) async {
    debugSemanticsDisableAnimations = true;
    addTearDown(() => debugSemanticsDisableAnimations = null);
    await tester.binding.setSurfaceSize(scena);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    expect(AnimalCatalog.animals.length, 12);
    final peggiore = <String, double>{};
    await tester.runAsync(() async {
      for (final animale in AnimalCatalog.animals) {
        final velo = IlVeloDellAnimale(animale.name);
        final illustrazione = IlVeloCheSiScosta.doveStaLIllustrazione(
            scena, LeSagome.misure[animale.name]!);
        final dalBasso = velo.scostabile.toList()
          ..sort((a, b) => b.compareTo(a));
        final ieri = dalBasso.take(velo.perDiscesa).toSet();
        final cuori = [
          for (final i in ieri)
            inPunti(illustrazione, velo.cella(i).deflate(0.25 / velo.colonne)),
        ];

        final velata = quantoDifferiscono(
            await fotogramma(tester, animale, 0, {}),
            await fotogramma(tester, animale, 0, {}, conLAnimale: false),
            scena.width.toInt(),
            cuori);
        final inChiaro = quantoDifferiscono(
            await fotogramma(tester, animale, 1, ieri),
            await fotogramma(tester, animale, 1, ieri, conLAnimale: false),
            scena.width.toInt(),
            cuori);
        expect(inChiaro, greaterThan(5),
            reason: '${animale.name}: delle celle scostate ieri oggi non '
                'arriva niente, e allora questa prova non misura niente');
        final rapporto = velata / inChiaro;
        peggiore[animale.name] = rapporto;
        expect(rapporto, lessThan(0.1),
            reason: '${animale.name}: dalle stesse celle arriva tanto '
                'animale coperte quanto scostate (${velata.toStringAsFixed(2)} contro '
                '${inChiaro.toStringAsFixed(2)}). O la cenere non copre, o '
                'cio che hai scostato ieri non resta scostato oggi.');
      }
    });
    final p = peggiore.entries.reduce((a, b) => a.value > b.value ? a : b);
    // ignore: avoid_print
    print('ORDINE DI VOCE 10, LA RIVELAZIONE CUMULATIVA: il rapporto '
        'peggiore fra l animale che arriva sotto la cenere e quello delle '
        'celle gia scostate e ${p.value.toStringAsFixed(3)} '
        '(${p.key})');
  });

  /// **LA CENERE E' PITTURA PIENA.** Il difetto della lente sul 767f596c
  /// stava in uno `ShaderMask` fra il velo e lo schermo, e prima ancora un
  /// `Opacity` sotto una sfocatura aveva reso nitido il fantasma. **Qui non
  /// ce ne sono**: una guardia sulla forma, perche' al banco tutte e due le
  /// forme si vedono giuste e sul telefono no.
  testWidgets(
      'nel velo non c e nessuna maschera di fusione, nessuna sfocatura e '
      'nessuna opacita', (tester) async {
    await tester.binding.setSurfaceSize(scena);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final lupo = AnimalCatalog.animals.firstWhere((a) => a.name == 'Lupo');
    var guardati = 0;
    for (var quale = 0;
        quale <= IlVeloDellAnimale.discesePrimaDellaTesta;
        quale++) {
      await tester.pumpWidget(MaterialApp(
        home: SizedBox(
          width: scena.width,
          height: scena.height,
          child: IlVeloCheSiScosta(
            key: ValueKey(quale),
            nome: lupo.name,
            immagine: lupo.fullPath,
            quale: quale,
            giaScoperte: const {},
            quandoCambia: (_) {},
            palette: MaestroPalette.caligo,
          ),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));
      final velo = find.byKey(const Key('viaggio_velo_che_si_scosta'));
      expect(velo, findsOneWidget);
      guardati += find
          .descendant(of: velo, matching: find.byWidgetPredicate((_) => true))
          .evaluate()
          .length;
      for (final vietato in [ShaderMask, ImageFiltered, BackdropFilter,
          Opacity, ColorFiltered]) {
        expect(find.descendant(of: velo, matching: find.byType(vietato)),
            findsNothing,
            reason: 'alla discesa ${quale + 1} nel velo c\'e\' un $vietato: '
                'al banco si vede giusto, sul telefono la lente e\' sparita '
                'intera per uno ShaderMask');
      }
      expect(find.byKey(const Key('viaggio_cenere')), findsOneWidget);
    }
    // **IL CARDINALE**: la prova ha guardato un albero vero.
    expect(guardati, greaterThan(20));
  });
}
