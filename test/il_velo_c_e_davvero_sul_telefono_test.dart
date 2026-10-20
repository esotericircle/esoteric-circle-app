import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/core/viaggio/la_carta_in_quattro_pezzi.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/il_segno_che_risponde.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/il_velo_che_si_scosta.dart';

/// **LA GUARDIA CHE GUARDA I PIXEL.** Nata con l'ordine DE voce 03 per la
/// lente, riscritta con l'ordine DI voce 10 per il velo che si scosta,
/// riscritta ancora con l'ordine FZ voce FZ.04, 17 ottobre 2026, per la
/// carta intera in quattro pezzi.
///
/// **IL DIFETTO CHE LA FECE NASCERE.** L'11 settembre 2026, sul 767f596c, alla
/// seconda e alla terza discesa l'animale si vedeva **intero**: il velo era
/// costruito, era opaco, e non dipingeva niente, perche' uno `ShaderMask` con
/// `BlendMode.dstIn` sul telefono lo cancellava intero. Due guardie erano
/// verdi, una sulla geometria e una sull'albero.
///
/// **Percio' la grandezza misurata qui sta nei pixel dipinti**, letti dal
/// fotogramma vero: **quanto della carta arriva a schermo** a velo intero
/// (zero), e quanto arriva a schermo, oggi, di cio' che si e' scostato ieri.
/// L'ordine FZ.04 ha tolto la testa protetta fino alla quarta (nessun pezzo
/// cade da solo, ogni pezzo si gratta col dito): la guardia che misurava
/// quella protezione, REGOLA I, non ha piu' una regola da misurare ed e'
/// tolta; resta qui la misura che non dipende dal pezzo, la pittura piena.
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
          somma += ((a[i] + a[i + 1] + a[i + 2]) - (b[i] + b[i + 1] + b[i + 2]))
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
  Future<Uint8List> fotogramma(
      WidgetTester tester, GuideAnimal animale, int quale, Set<int> gia,
      {bool conLAnimale = true}) async {
    // **LA GRANA PRIMA DI TUTTO**: i due fotogrammi di una coppia devono
    // avere la stessa cenere, o la differenza fra loro sarebbe la grana.
    await GranaDellaCenere.prepara();
    // **LA CARTA VERA**, quella che la lente mostra dalla simulazione da
    // persona del 20 ottobre 2026 (ordine FZ voce FZ.04): prima qui c'era
    // l'illustrazione dell'animale, come nella lente sbagliata.
    final immagine = conLAnimale
        ? IlSegnoCheRisponde.posaDi(animale)
        : 'assets/img/animali/nessuno.webp';
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
      await precacheImage(AssetImage(IlSegnoCheRisponde.posaDi(animale)),
          tester.element(find.byType(SizedBox).first));
    }
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(IlVeloCheSiScosta.vitaDellaParticella);
    final foglio = tester
        .renderObject<RenderRepaintBoundary>(find.byKey(const Key('foglio')));
    final quadro = await foglio.toImage();
    final dati = await quadro.toByteData(format: ui.ImageByteFormat.rawRgba);
    return dati!.buffer.asUint8List();
  }

  /// **A VELO INTERO NON SI VEDE NESSUN PIXEL DELLA CARTA.** Ordine FZ voce
  /// FZ.04: la cenere copre la carta intera, non piu' la sola sagoma, quindi
  /// qui il rettangolo misurato e' la carta tutta, non un suo ritaglio.
  testWidgets(
      'a velo intero non si vede nessun pixel della carta, per tutti e dodici',
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
          final d =
              ((a[i] + a[i + 1] + a[i + 2]) - (b[i] + b[i + 1] + b[i + 2]))
                      .abs() /
                  3;
          if (d > 25.5) n++;
        }
      }
      return n;
    }

    expect(AnimalCatalog.animals.length, 12);
    const misura = Size(1080, 1920);
    final visti = <String>[];
    await tester.runAsync(() async {
      for (final animale in AnimalCatalog.animals) {
        final velo = LaCartaInQuattroPezzi(animale.name, 0);
        final r = IlVeloCheSiScosta.doveStaLIllustrazione(scena, misura);
        // **IL CARDINALE DI QUESTO ANIMALE**: senza cenere se ne vedono
        // decine di migliaia, o la prova non guarda niente. **Al quarto
        // pezzo**: dalla simulazione da persona del 20 ottobre 2026 le celle
        // dei pezzi dei giorni dopo non valgono (`LaCartaInQuattroPezzi.
        // valide`), quindi la carta tutta scoperta esiste solo all'ultimo.
        final tutto = visibili(
            await fotogramma(tester, animale, 3, velo.velato),
            await fotogramma(tester, animale, 3, velo.velato,
                conLAnimale: false),
            r);
        expect(tutto, greaterThan(20000),
            reason: '${animale.name}: senza cenere se ne vedono solo $tutto '
                'pixel, e allora la prova non guarda la carta');
        final sotto = visibili(
            await fotogramma(tester, animale, 0, const {}),
            await fotogramma(tester, animale, 0, const {}, conLAnimale: false),
            r);
        if (sotto > 0) visti.add('${animale.name} $sotto su $tutto');
      }
    });
    expect(visti, isEmpty,
        reason:
            'A VELO INTERO SI VEDE UN PEZZO DI CARTA: ${visti.join(', ')}.');
  });

  /// **LA RIVELAZIONE E' CUMULATIVA: cio' che hai scostato ieri resta in
  /// chiaro.** Ordine DI voce 10, confermato dall'ordine FZ voce FZ.04: *"la
  /// superficie gia' scoperta nelle discese precedenti resta scoperta e si
  /// ritrova riaprendo la funzione"*.
  testWidgets(
      'le celle scostate nelle discese di prima sono in chiaro, e senza di '
      'loro sono coperte, per tutti e dodici', (tester) async {
    debugSemanticsDisableAnimations = true;
    addTearDown(() => debugSemanticsDisableAnimations = null);
    await tester.binding.setSurfaceSize(scena);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    expect(AnimalCatalog.animals.length, 12);
    const misura = Size(1080, 1920);
    final peggiore = <String, double>{};
    await tester.runAsync(() async {
      for (final animale in AnimalCatalog.animals) {
        // Il pezzo 0 (il piu' basso), gia' scostato alla discesa di ieri.
        final velo = LaCartaInQuattroPezzi(animale.name, 0);
        final illustrazione =
            IlVeloCheSiScosta.doveStaLIllustrazione(scena, misura);
        final ieri = velo.scostabile;
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
            // Oggi e' il pezzo 1 (il secondo), e ieri (il pezzo 0) resta
            // scostato dal Diario.
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
    print('ORDINE FZ VOCE FZ.04, LA RIVELAZIONE CUMULATIVA: il rapporto '
        'peggiore fra la carta che arriva sotto la cenere e quella delle '
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
    for (var quale = 0; quale < LaCartaInQuattroPezzi.pezzi; quale++) {
      await tester.pumpWidget(MaterialApp(
        home: SizedBox(
          width: scena.width,
          height: scena.height,
          child: IlVeloCheSiScosta(
            key: ValueKey(quale),
            nome: lupo.name,
            immagine: IlSegnoCheRisponde.posaDi(lupo),
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
      for (final vietato in [
        ShaderMask,
        ImageFiltered,
        BackdropFilter,
        Opacity,
        ColorFiltered
      ]) {
        expect(find.descendant(of: velo, matching: find.byType(vietato)),
            findsNothing,
            reason: 'al pezzo attivo $quale nel velo c\'e\' un $vietato: '
                'al banco si vede giusto, sul telefono la lente e\' sparita '
                'intera per uno ShaderMask');
      }
      expect(find.byKey(const Key('viaggio_cenere')), findsOneWidget);
    }
    // **IL CARDINALE**: la prova ha guardato un albero vero.
    expect(guardati, greaterThan(20));
  });
}
