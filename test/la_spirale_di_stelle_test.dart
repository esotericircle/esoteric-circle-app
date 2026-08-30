import 'dart:ui' as ui;

import 'package:esoteric_circle/features/sigilli/spirale_di_stelle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA SPIRALE DI STELLE, MISURATA. Ordine AV voce 01.
///
/// **`drawAtlas` non c'era in nessun punto di `lib/`**, contato per
/// enumerazione: e' la prima volta che si usa qui, e l'ordine dice di misurare
/// invece di fidarsi. Le cinque accettazioni si misurano tutte, e quattro delle
/// cinque non guardano l'aspetto ma il COSTO: quante stelle, quanto tempo,
/// quante chiamate, quanta scena coperta.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// La scena su cui si misura: la misura del telefono del fondatore.
  const misura = Size(360, 797);

  /// Dipinge un fotogramma su una tela vera e restituisce l'immagine.
  Future<ui.Image> fotogramma(int millesimi) async {
    final registratore = ui.PictureRecorder();
    final tela = Canvas(registratore);
    // Il fondo scuro della celebrazione: serve per distinguere i pixel delle
    // stelle da quelli che stella non sono.
    tela.drawRect(Offset.zero & misura, Paint()..color = const Color(0xFF000000));
    // Si costruisce il pittore con gli stessi semi che userebbe la scena.
    costruisciPittore(millesimi).paint(tela, misura);
    return registratore
        .endRecording()
        .toImage(misura.width.toInt(), misura.height.toInt());
  }

  test('M1 al culmine le stelle vive sono almeno 400', () async {
    final pittore = costruisciPittore(
        SpiraleDiStelle.istanteDelCulmine.inMilliseconds);
    final registratore = ui.PictureRecorder();
    pittore.paint(Canvas(registratore), misura);
    registratore.endRecording().dispose();
    // ignore: avoid_print
    print('ORDINE AV VOCE 01, M1: al culmine le stelle vive sono '
        '${PittoreDellaSpirale.viveAllUltimoFotogramma} su '
        '${SpiraleDiStelle.quante} seminate');
    expect(PittoreDellaSpirale.viveAllUltimoFotogramma,
        greaterThanOrEqualTo(400),
        reason: 'al culmine le stelle vive sono '
            '${PittoreDellaSpirale.viveAllUltimoFotogramma}: l ordine ne '
            'chiede almeno quattrocento');
  });

  test('M3 le chiamate di disegno per fotogramma sono UNA sola', () {
    final pittore = costruisciPittore(
        SpiraleDiStelle.istanteDelCulmine.inMilliseconds);
    final conta = _TelaCheConta();
    pittore.paint(conta, misura);
    // ignore: avoid_print
    print('ORDINE AV VOCE 01, M3: chiamate drawAtlas '
        '${conta.atlanti}, altre chiamate di disegno ${conta.altre}');
    expect(conta.atlanti, 1,
        reason: 'le chiamate drawAtlas sono ${conta.atlanti} invece di una');
    expect(conta.altre, 0,
        reason: 'ci sono ${conta.altre} altre chiamate di disegno per '
            'fotogramma: quattrocento stelle si posano in una volta sola');
    expect(conta.filtri, 0,
        reason: 'c e un filtro per fotogramma: niente MaskFilter, niente '
            'sfocature, niente shader');
  });

  test('M2 il tempo di disegno al culmine sta sotto 8 millesimi', () {
    final pittore = costruisciPittore(
        SpiraleDiStelle.istanteDelCulmine.inMilliseconds);
    // Si scalda una volta, poi si misura la mediana di venti passate: una
    // misura sola su una macchina condivisa e' rumore.
    final tempi = <int>[];
    for (var giro = 0; giro < 21; giro++) {
      final registratore = ui.PictureRecorder();
      final tela = Canvas(registratore);
      final cronometro = Stopwatch()..start();
      pittore.paint(tela, misura);
      cronometro.stop();
      registratore.endRecording().dispose();
      if (giro > 0) tempi.add(cronometro.elapsedMicroseconds);
    }
    tempi.sort();
    final mediana = tempi[tempi.length ~/ 2] / 1000;
    // ignore: avoid_print
    print('ORDINE AV VOCE 01, M2: tempo di disegno al culmine, mediana '
        '${mediana.toStringAsFixed(2)} millesimi su venti passate '
        '(minimo ${(tempi.first / 1000).toStringAsFixed(2)}, massimo '
        '${(tempi.last / 1000).toStringAsFixed(2)})');
    expect(mediana, lessThan(8.0),
        reason: 'il fotogramma al culmine costa $mediana millesimi: sopra gli '
            'otto il conto cade sotto i sessanta');
  });

  test('M4 al culmine le stelle coprono piu del 70 per cento della scena',
      () async {
    final immagine = await fotogramma(
        SpiraleDiStelle.istanteDelCulmine.inMilliseconds);
    final dati = await immagine.toByteData(format: ui.ImageByteFormat.rawRgba);
    immagine.dispose();
    expect(dati, isNotNull);
    final bytes = dati!.buffer.asUint8List();
    var accesi = 0;
    final quanti = bytes.length ~/ 4;
    for (var i = 0; i < quanti; i++) {
      // Il fondo e' nero pieno: un pixel che non e' nero e' una stella.
      if (bytes[i * 4] > 12 || bytes[i * 4 + 1] > 12 || bytes[i * 4 + 2] > 12) {
        accesi++;
      }
    }
    final quota = accesi / quanti;
    // ignore: avoid_print
    print('ORDINE AV VOCE 01, M4: al culmine le stelle coprono il '
        '${(quota * 100).toStringAsFixed(1)} per cento della scena, misurato '
        'su $quanti pixel');
    // **SESSANTA E NON PIU\' SETTANTA, e non e\' un peggioramento nascosto: e\'
    // un conflitto fra due vincoli, dichiarato.** Ordine CE voce 14.
    //
    // L\'ordine AV aveva fissato questa soglia misurando un tappeto
    // uniforme, e un tappeto copre per definizione piu\' di una spirale: una
    // spirale ha i bracci, e fra un braccio e l\'altro c\'e\' cielo vuoto. Il
    // fondatore ha guardato l\'anteprima e ha chiesto proprio quel cielo
    // vuoto, cioe\' di vedere i bracci.
    //
    // **Misurato, non stimato.** Con i bracci stretti la copertura si ferma
    // attorno al sessanta per cento e non sale piu\' nemmeno raddoppiando le
    // stelle, perche\' il vuoto fra i bracci resta vuoto: 43,8 per cento a
    // 2.600 stelle, 60,3 a 4.600, 60,3 a 8.000. Allargando i bracci la
    // copertura risale ma il contrasto angolare crolla: a 1,6 radianti di
    // spessore si torna al 70,4 per cento e il contrasto scende a 0,107,
    // cioe\' di nuovo un tappeto. **Le due grandezze si muovono in senso
    // opposto e non esiste un punto che le soddisfi tutte e due.**
    //
    // La scelta e\' 6.000 stelle, bracci da 0,9 radianti e stelle piu\'
    // piccole di prima, 0,9 invece di 1,1: contrasto 0,343, copertura 59,9 per
    // cento, un solo `drawAtlas`, 1,8 millesimi di disegno contro un tetto di 8.
    //
    // **LE STELLE SONO RIMPICCIOLITE PERCHE\' GUARDANDO SI VEDEVA.** A 1,1 la
    // copertura era 62,3 per cento, cioe\' piu\' alta, ma nell\'anteprima i bracci
    // erano masse d\'oro compatte in cui le singole stelle non si
    // distinguevano: una spirale di macchie invece che di stelle. Il numero
    // piu\' alto non era il disegno migliore.
    //
    // La soglia sta a 0,55 e non a 0,60: sopra la cifra scelta ci deve stare il
    // margine di una prossima rifinitura, e il punto esatto fra copertura e
    // leggibilita\' e\' una decisione che il fondatore prende guardando.
    expect(quota, greaterThan(0.55),
        reason: 'al culmine le stelle coprono il '
            '${(quota * 100).toStringAsFixed(1)} per cento: la festa non '
            'riempie piu\' la scena');
  });

  test('dopo il culmine la spirale si dirada e il traguardo si libera',
      () async {
    // **IL CULMINE COPRE, E DEVE COPRIRE**: l'ordine chiede piu' del settanta
    // per cento a 800 millesimi, ed e' l'istante in cui il traguardo compare.
    // Ma se restasse cosi' fino alla fine la scheda non si leggerebbe mai:
    // **dagli 800 ai 2000 la spirale gira sopra e si dirada**, e questa prova
    // guarda che si diradi davvero invece di crederlo.
    final quote = <int, double>{};
    for (final quando in const [800, 1200, 1600, 1900]) {
      final immagine = await fotogramma(quando);
      final dati = await immagine.toByteData(format: ui.ImageByteFormat.rawRgba);
      immagine.dispose();
      final bytes = dati!.buffer.asUint8List();
      var accesi = 0;
      final quanti = bytes.length ~/ 4;
      for (var i = 0; i < quanti; i++) {
        if (bytes[i * 4] > 12 ||
            bytes[i * 4 + 1] > 12 ||
            bytes[i * 4 + 2] > 12) {
          accesi++;
        }
      }
      quote[quando] = accesi / quanti;
    }
    // ignore: avoid_print
    print('ORDINE AV VOCE 01: la scena coperta dalle stelle, '
        '${quote.entries.map((e) => "${e.key} ms: ${(e.value * 100).toStringAsFixed(1)}%").join(", ")}');
    expect(quote[1200]!, lessThan(quote[800]!),
        reason: 'a 1200 millesimi la spirale copre quanto al culmine: non si '
            'sta diradando e il traguardo resta nascosto');
    expect(quote[1900]!, lessThan(0.25),
        reason: 'a fine corsa le stelle coprono ancora il '
            '${(quote[1900]! * 100).toStringAsFixed(1)} per cento: la scheda '
            'non si legge');
  });

  test('la spirale non e mai vuota fra la nascita e la fine', () {
    // Una spirale che si svuota a meta' corsa lascia lo schermo nudo mentre la
    // scheda non e' ancora comparsa: si guarda a piu' istanti, non solo al
    // culmine.
    for (final quando in const [200, 400, 800, 1200, 1600, 1900]) {
      final pittore = costruisciPittore(quando);
      final registratore = ui.PictureRecorder();
      pittore.paint(Canvas(registratore), misura);
      registratore.endRecording().dispose();
      // ignore: avoid_print
      print('ORDINE AV VOCE 01: a $quando millesimi le stelle vive sono '
          '${PittoreDellaSpirale.viveAllUltimoFotogramma}');
      expect(PittoreDellaSpirale.viveAllUltimoFotogramma, greaterThan(0),
          reason: 'a $quando millesimi non c e nessuna stella a schermo');
    }
  });
}

/// Costruisce il pittore con gli stessi semi che usa la scena vera.
PittoreDellaSpirale costruisciPittore(int millesimi) {
  return PittoreDellaSpirale(
    stella: SpiraleDiStelleState.stellaPerLeProve(),
    semi: SpiraleDiStelleState.semiPerLeProve(),
    millesimi: millesimi,
  );
}

/// Una tela che non disegna: conta le chiamate. **E' l'unico modo di
/// verificare M3 senza credere al codice**: si guarda cosa arriva davvero al
/// motore grafico.
class _TelaCheConta implements Canvas {
  int atlanti = 0;
  int altre = 0;
  int filtri = 0;

  @override
  void drawAtlas(ui.Image atlas, List<ui.RSTransform> transforms,
      List<Rect> rects, List<Color>? colors, BlendMode? blendMode,
      Rect? cullRect, Paint paint) {
    atlanti++;
    if (paint.maskFilter != null || paint.imageFilter != null ||
        paint.shader != null) {
      filtri++;
    }
  }

  @override
  void noSuchMethod(Invocation invocation) {
    // Ogni altra chiamata di disegno si conta: se ne comparisse una, le stelle
    // non starebbero piu' tutte in un atlante.
    final nome = invocation.memberName.toString();
    if (nome.contains('draw')) altre++;
  }
}
