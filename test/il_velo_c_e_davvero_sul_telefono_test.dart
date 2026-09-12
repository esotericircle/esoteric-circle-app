import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/core/viaggio/dove_sta_la_testa.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/la_lente_che_scopre.dart';

/// **LA GUARDIA CHE GUARDA I PIXEL, ordine DE voce 03.**
///
/// **IL DIFETTO CHE LA FA NASCERE.** L'11 settembre 2026, sul 767f596c, alla
/// **seconda** e alla **terza** discesa l'animale si vedeva **intero, testa
/// compresa**, mentre a schermo c'era scritto *"Passa il dito: la lente scopre
/// solo dove puo', oggi"*. Il velo non era sottile: era **assente**.
///
/// **E DUE GUARDIE ERANO VERDI, tutte e due a ragione.**
///
/// - `la_testa_non_si_vede_prima_della_quarta_test` misura la **geometria**:
///   che il cerchio della lente non tocchi mai il rettangolo della testa. Non
///   lo toccava, e infatti quella prova non aveva niente da dire.
/// - La prima stesura di **questa** guardia misurava **l'albero**: che il velo
///   fosse costruito e opaco. Lo era, anche con le animazioni spente come sul
///   dispositivo.
///
/// **Il velo era costruito, era opaco, e non dipingeva niente.** Fra l'albero
/// e i pixel c'era uno `ShaderMask` con `BlendMode.dstIn`, e quella maschera
/// sul telefono cancellava il velo intero invece del suo cerchio.
///
/// **Percio' la grandezza misurata qui sta nei pixel dipinti**, letti dal
/// fotogramma vero: **quanto e' nitido** il rettangolo della testa, per tutti
/// e dodici gli animali, nelle tre discese in cui deve restare coperto e alla
/// quarta in cui deve vedersi. E' la Regola I applicata a una scena: pixel
/// dipinti, finestra vera.
///
/// **E non la luce media, che qui mente**: sotto il velo il fantasma sfocato
/// si vede, ed e' voluto. Vedi la nota su `quantoENitido`.
void main() {
  /// La scena di prova: un telefono vero, non gli ottocento per seicento di
  /// fabbrica.
  const scena = Size(390, 844);

  /// **DOVE SI METTE LA LENTE**, in frazioni dell'area concessa: il bordo
  /// alto, che e' il lato piu' vicino alla testa e quindi l'unico dove un
  /// difetto si vedrebbe. Il centro dell'area non proverebbe niente.
  const partenze = [Offset(0, 0), Offset(1, 0), Offset(0.5, 0)];

  /// **QUANTO E' NITIDO un rettangolo del fotogramma**, cioe' quanto cambiano
  /// i pixel da un vicino all'altro.
  ///
  /// **E non la luce media, che qui mente.** Sotto il velo il fantasma sfocato
  /// c'e' e si vede, percio' la luce sulla testa del Lupo faceva 57,3 velata
  /// contro 86,0 scoperta: due numeri vicini. Sul Cervo faceva 15,4 velata e
  /// 14,9 scoperta, cioe' **il contrario**, perche' il suo rettangolo della
  /// testa e' largo e in gran parte sfondo trasparente. La nitidezza invece
  /// separa: 4,85 contro 35,63 sul Lupo, 2,03 contro 9,72 sul Cervo.
  double quantoENitido(Uint8List b, int larga, Rect r) {
    double luce(int x, int y) {
      final i = (y * larga + x) * 4;
      if (i < 0 || i + 2 >= b.length) return 0;
      return (b[i] + b[i + 1] + b[i + 2]) / 3;
    }

    var somma = 0.0;
    var quanti = 0;
    for (var y = r.top.toInt(); y < r.bottom.toInt() - 1; y++) {
      for (var x = r.left.toInt(); x < r.right.toInt() - 1; x++) {
        somma += (luce(x + 1, y) - luce(x, y)).abs() +
            (luce(x, y + 1) - luce(x, y)).abs();
        quanti++;
      }
    }
    return quanti == 0 ? 0 : somma / quanti;
  }

  /// La misura vera del file, che serve a sapere dove `BoxFit.contain` mette
  /// l'immagine: i dodici **non hanno la stessa forma**, il gufo e' alto e la
  /// volpe e' larga.
  Future<Size> misuraDi(String percorso) async {
    final dati = await rootBundle.load(percorso);
    final codec = await ui.instantiateImageCodec(dati.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return Size(frame.image.width.toDouble(), frame.image.height.toDouble());
  }

  Rect dentroLaScena(Size sorgente) {
    final k = (scena.width / sorgente.width) < (scena.height / sorgente.height)
        ? scena.width / sorgente.width
        : scena.height / sorgente.height;
    final larga = sorgente.width * k;
    final alta = sorgente.height * k;
    return Rect.fromLTWH((scena.width - larga) / 2, (scena.height - alta) / 2,
        larga, alta);
  }

  Future<Uint8List> fotogramma(
      WidgetTester tester, GuideAnimal animale, int discesa,
      Offset parte) async {
    await tester.pumpWidget(MaterialApp(
      home: RepaintBoundary(
        key: const Key('foglio'),
        child: SizedBox(
          width: scena.width,
          height: scena.height,
          child: LenteCheScopre(
            nome: animale.name,
            immagine: animale.fullPath,
            discesa: discesa,
            doveParte: parte,
          ),
        ),
      ),
    ));
    await precacheImage(
        AssetImage(animale.fullPath), tester.element(find.byType(SizedBox).first));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 1200));
    final foglio = tester
        .renderObject<RenderRepaintBoundary>(find.byKey(const Key('foglio')));
    final immagine = await foglio.toImage();
    final dati = await immagine.toByteData(format: ui.ImageByteFormat.rawRgba);
    return dati!.buffer.asUint8List();
  }

  testWidgets(
      'REGOLA I: nelle prime tre discese la testa non e mai nitida, e alla '
      'quarta lo diventa, per tutti e dodici e con le animazioni spente',
      (tester) async {
    debugSemanticsDisableAnimations = true;
    addTearDown(() => debugSemanticsDisableAnimations = null);
    await tester.binding.setSurfaceSize(scena);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    // **IL CARDINALE MINIMO.**
    expect(AnimalCatalog.animals.length, 12);
    expect(DoveStaLaTesta.quantiSono, 12);

    final rapporti = <String, double>{};
    var quanti = 0;
    await tester.runAsync(() async {
      for (final animale in AnimalCatalog.animals) {
        final sorgente = await misuraDi(animale.fullPath);
        final immagine = dentroLaScena(sorgente);
        final testa = DoveStaLaTesta.di(animale.name)!;
        final testaInPunti = Rect.fromLTRB(
          immagine.left + immagine.width * testa.left,
          immagine.top + immagine.height * testa.top,
          immagine.left + immagine.width * testa.right,
          immagine.top + immagine.height * testa.bottom,
        );

        // **IL METRO DI QUESTO ANIMALE: la sua testa a velo caduto**, che e'
        // lo stato della card della rivelazione. Ogni animale porta il
        // proprio, e cosi' la prova non ha dentro nessun numero assoluto.
        //
        // **Si misura alla discesa 4 e non piu' alla 3.** Dal 12 settembre
        // 2026 **la discesa 3 e' la discesa della testa**, cioe' quella in cui
        // la lente la scopre: misurare li' vorrebbe dire prendere per metro
        // una testa mezza velata.
        final scoperta = quantoENitido(
            await fotogramma(tester, animale, 4, const Offset(0.5, 0.5)),
            scena.width.toInt(),
            testaInPunti);
        expect(scoperta, greaterThan(5),
            reason: '${animale.name}: alla quarta discesa la testa non e '
                'nitida nemmeno col velo caduto, e allora questa prova non '
                'starebbe misurando niente');

        for (var discesa = 0; discesa < 3; discesa++) {
          for (final parte in partenze) {
            final velata = quantoENitido(
                await fotogramma(tester, animale, discesa, parte),
                scena.width.toInt(),
                testaInPunti);
            quanti++;
            final rapporto = velata / scoperta;
            final dove = '${animale.name} d$discesa da $parte';
            if (rapporto > (rapporti[animale.name] ?? 0)) {
              rapporti[animale.name] = rapporto;
            }
            expect(rapporto, lessThan(0.4),
                reason: 'la testa di $dove e nitida quanto quella scoperta '
                    '(${velata.toStringAsFixed(2)} contro '
                    '${scoperta.toStringAsFixed(2)}): il velo non sta '
                    'coprendo, ed e esattamente cio che si e visto sul '
                    'telefono l 11 settembre 2026');
          }
        }
      }
    });

    final peggiore = rapporti.entries
        .reduce((a, b) => a.value > b.value ? a : b);
    // ignore: avoid_print
    print('ORDINE DE VOCE 03, LA NITIDEZZA DELLA TESTA: $quanti fotogrammi, '
        'il rapporto peggiore fra velata e scoperta e '
        '${peggiore.value.toStringAsFixed(3)} (${peggiore.key}); '
        'zero vorrebbe dire coperta del tutto, uno vorrebbe dire scoperta');
  });

  /// **LA RIVELAZIONE E' CUMULATIVA: cio' che hai scoperto ieri resta in
  /// chiaro.** Ordine DG, 12 settembre 2026.
  ///
  /// **Parole del fondatore:** *"il secondo giorno dovrei vedere in chiaro
  /// quello che ho scoperto con la lente il giorno prima e cosi' via"*.
  ///
  /// **La grandezza misurata e' la stessa nitidezza di sopra**, sulla **fascia
  /// di mezzo** dei tre sotto la testa, e in due fotogrammi in cui **la lente
  /// non ci passa sopra**: alla prima discesa la lente sta nella fascia bassa
  /// e quella di mezzo e' ancora velata; alla terza sta nella fascia alta e
  /// quella di mezzo e' gia' stata scoperta il giorno prima.
  ///
  /// **Percio' la differenza non puo' venire dalla lente**: viene dal velo che
  /// si e' ritirato, che e' cio' che si vuole provare.
  ///
  /// **VISTA ROSSA** riportando `finDoveArrivaIlVelo` a tornare sempre 1, cioe'
  /// il velo su tutto a ogni discesa: la prova ha nominato gli animali e i due
  /// numeri.
  testWidgets(
      'la fascia di mezzo e velata alla prima discesa e in chiaro alla terza, '
      'per tutti e dodici',
      (tester) async {
    debugSemanticsDisableAnimations = true;
    addTearDown(() => debugSemanticsDisableAnimations = null);
    await tester.binding.setSurfaceSize(scena);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    expect(AnimalCatalog.animals.length, 12);

    var quanti = 0;
    final peggiore = <String, double>{};
    await tester.runAsync(() async {
      for (final animale in AnimalCatalog.animals) {
        final sorgente = await misuraDi(animale.fullPath);
        final immagine = dentroLaScena(sorgente);
        // La fascia di mezzo, in punti veri dentro la scena.
        final mezzo = DoveStaLaTesta.areaDellaDiscesa(animale.name, 1);
        final mezzoInPunti = Rect.fromLTRB(
          immagine.left + immagine.width * mezzo.left,
          immagine.top + immagine.height * mezzo.top,
          immagine.left + immagine.width * mezzo.right,
          immagine.top + immagine.height * mezzo.bottom,
        );

        // Alla prima discesa la lente sta in fondo alla fascia bassa, cioe'
        // il piu' lontano possibile da quella di mezzo.
        final velata = quantoENitido(
            await fotogramma(tester, animale, 0, const Offset(0.5, 1)),
            scena.width.toInt(),
            mezzoInPunti);
        // Alla terza sta in cima alla fascia alta, cioe' di nuovo lontana.
        final inChiaro = quantoENitido(
            await fotogramma(tester, animale, 2, const Offset(0.5, 0)),
            scena.width.toInt(),
            mezzoInPunti);
        quanti += 2;

        expect(inChiaro, greaterThan(1),
            reason: '${animale.name}: alla terza discesa la fascia di mezzo '
                'non e nitida nemmeno dovendo essere gia scoperta, e allora '
                'questa prova non sta misurando niente');
        final rapporto = velata / inChiaro;
        peggiore[animale.name] = rapporto;
        expect(rapporto, lessThan(0.6),
            reason: '${animale.name}: la fascia di mezzo e nitida alla prima '
                'discesa quanto alla terza '
                '(${velata.toStringAsFixed(2)} contro '
                '${inChiaro.toStringAsFixed(2)}). O il velo non copre alla '
                'prima, o non si ritira alla terza: in tutti e due i casi '
                'cio che hai scoperto ieri non resta scoperto oggi.');
      }
    });

    final p = peggiore.entries.reduce((a, b) => a.value > b.value ? a : b);
    // ignore: avoid_print
    print('ORDINE DG, LA RIVELAZIONE CUMULATIVA: $quanti fotogrammi, il '
        'rapporto peggiore fra fascia velata e fascia in chiaro e '
        '${p.value.toStringAsFixed(3)} (${p.key})');
  });

  /// **IL VELO STRINGE ALLA PRIMA DISCESA E ALLENTA VERSO LA TERZA.**
  /// Ordine DG, 12 settembre 2026.
  ///
  /// **Parole del fondatore:** *"l'animale sfocato con la lente si capisce
  /// benissimo cos'e', e' ancora troppo evidente"*.
  ///
  /// **La grandezza misurata e' sempre la nitidezza**, sulla **testa**, che e'
  /// il pezzo velato in tutte e tre le discese e quindi l'unico confrontabile.
  /// Alla prima deve essere piu' bassa che alla terza: la sfocatura, il buio e
  /// il fantasma cambiano tutti e tre con la discesa.
  ///
  /// **PERCHE' NON SI GUARDANO I NUMERI DELLA TARATURA.** Perche' leggere
  /// `sfocaturaAlla(0) > sfocaturaAlla(2)` proverebbe che due costanti sono
  /// ordinate, non che il velo copre di piu': la guardia che legge il token
  /// invece del fatto e' gia' costata tre cadute nell'ordine CO.
  ///
  /// **VISTA ROSSA** riportando la sfocatura e il buio a costanti: il rapporto
  /// fra prima e terza e passato da 0,71 a 1,00 e la prova ha nominato tutti
  /// e dodici gli animali.
  testWidgets(
      'la testa velata e meno nitida alla prima discesa che alla terza, '
      'per tutti e dodici',
      (tester) async {
    debugSemanticsDisableAnimations = true;
    addTearDown(() => debugSemanticsDisableAnimations = null);
    await tester.binding.setSurfaceSize(scena);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    expect(AnimalCatalog.animals.length, 12);

    final rapporti = <String, double>{};
    await tester.runAsync(() async {
      for (final animale in AnimalCatalog.animals) {
        final sorgente = await misuraDi(animale.fullPath);
        final immagine = dentroLaScena(sorgente);
        final testa = DoveStaLaTesta.di(animale.name)!;
        final testaInPunti = Rect.fromLTRB(
          immagine.left + immagine.width * testa.left,
          immagine.top + immagine.height * testa.top,
          immagine.left + immagine.width * testa.right,
          immagine.top + immagine.height * testa.bottom,
        );
        // La lente parte dal centro della sua fascia in tutti e due i casi:
        // quello che cambia e solo il velo.
        final alla1 = quantoENitido(
            await fotogramma(tester, animale, 0, const Offset(0.5, 0.5)),
            scena.width.toInt(),
            testaInPunti);
        final alla3 = quantoENitido(
            await fotogramma(tester, animale, 2, const Offset(0.5, 0.5)),
            scena.width.toInt(),
            testaInPunti);
        final rapporto = alla3 == 0 ? 1.0 : alla1 / alla3;
        rapporti[animale.name] = rapporto;
        expect(rapporto, lessThan(0.95),
            reason: '${animale.name}: la testa e nitida uguale alla prima '
                'discesa e alla terza '
                '(${alla1.toStringAsFixed(2)} contro '
                '${alla3.toStringAsFixed(2)}). Il velo deve stringere quando '
                'non si deve riconoscere niente e allentare quando si e gia '
                'visto due terzi del corpo.');
      }
    });

    final p = rapporti.entries.reduce((a, b) => a.value > b.value ? a : b);
    // ignore: avoid_print
    print('ORDINE DG, IL VELO PIU FITTO ALLA PRIMA: rapporto peggiore fra '
        'prima e terza ${p.value.toStringAsFixed(3)} (${p.key}); sotto uno '
        'vuol dire che alla prima si riconosce meno');
  });

  /// **FRA LA SFOCATURA DEL VELO E L'IMMAGINE NON C'E' NESSUNO STRATO.**
  /// Ordine DG, collaudo a video della 2249, 12 settembre 2026.
  ///
  /// **QUESTA GUARDIA DICHIARA CIO' CHE NON PUO' MISURARE.** Le tre qui sopra
  /// guardano i pixel, e sono verdi anche col difetto dentro: al banco si
  /// dipinge col motore di prova, e li' la sfocatura funziona **in tutte e due
  /// le forme**. Sul 767f596c no. Il difetto e' stato visto a video tre
  /// volte, sulla 2247, sulla 2248 e sulla 2249, e le prime due volte e'
  /// stato attribuito a cause sbagliate.
  ///
  /// **LA CAUSA VIENE DA UN CONFRONTO SULLO STESSO TELEFONO E CON LA STESSA
  /// BUILD, non da una deduzione.** L'ombra dell'incontro e' `ImageFiltered`
  /// sopra `Image`, ed e' sfocata a video. Il velo della lente era
  /// `ImageFiltered` sopra `Opacity` sopra `Image`, ed era nitido: la testa
  /// della volpe a video aveva il 52 per cento della luce dell'originale, che
  /// e' esattamente il conto di un fantasma NON sfocato.
  ///
  /// **Quindi qui si misura la forma**, perche' e' l'unica cosa del difetto
  /// che il banco sa vedere: nessun `Opacity` fra una sfocatura del velo e la
  /// sua immagine, in nessuna delle quattro discese. La prova vera e' la
  /// cattura sul telefono, e sta in `docs/catture/dg/`.
  ///
  /// **VISTA ROSSA** rimettendo l'`Opacity` attorno al fantasma: la prova ha
  /// nominato le quattro discese.
  testWidgets(
      'nessun Opacity fra la sfocatura del velo e la sua immagine, a nessuna '
      'discesa', (tester) async {
    await tester.binding.setSurfaceSize(scena);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final lupo = AnimalCatalog.animals.firstWhere((a) => a.name == 'Lupo');
    final colpevoli = <String>[];
    var sfocature = 0;
    for (var discesa = 0; discesa <= DoveStaLaTesta.quanteFasce; discesa++) {
      await tester.pumpWidget(MaterialApp(
        home: SizedBox(
          width: scena.width,
          height: scena.height,
          child: LenteCheScopre(
            nome: lupo.name,
            immagine: lupo.fullPath,
            discesa: discesa,
          ),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));
      final sfocate = find.byKey(const Key('viaggio_velo_sfocato'));
      sfocature += sfocate.evaluate().length;
      for (final e in sfocate.evaluate()) {
        final dentro = find.descendant(
            of: find.byWidget(e.widget), matching: find.byType(Opacity));
        if (dentro.evaluate().isNotEmpty) {
          colpevoli.add('discesa ${discesa + 1}: '
              '${dentro.evaluate().length} Opacity sotto la sfocatura');
        }
      }
    }
    // **IL CARDINALE**: una sfocatura per discesa, o la prova ha guardato un
    // albero senza velo e sarebbe verde su niente.
    expect(sfocature, greaterThanOrEqualTo(DoveStaLaTesta.quanteFasce + 1),
        reason: 'NON SI TROVANO LE SFOCATURE DEL VELO: la chiave '
            'viaggio_velo_sfocato non c\'e\' piu\', e questa guardia sta '
            'guardando un albero che non e\' quello del velo.');
    expect(colpevoli, isEmpty,
        reason: 'FRA LA SFOCATURA DEL VELO E LA SUA IMMAGINE C\'E\' UN '
            'Opacity:\n${colpevoli.join('\n')}\n\n'
            'Al banco si vede sfocato lo stesso, sul 767f596c no: il '
            'fantasma arriva a schermo nitido e la volpe si riconosce intera, '
            'testa compresa. Visto a video sulla 2247, sulla 2248 e sulla '
            '2249. L\'opacita\' del fantasma la porta l\'immagine, col suo '
            'parametro opacity.');
  });
}
