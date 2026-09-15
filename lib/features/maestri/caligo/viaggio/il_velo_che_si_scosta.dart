import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/viaggio/il_velo_dell_animale.dart';
import '../../../../core/viaggio/le_sagome_in_celle.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';

/// **IL GESTO CHE SCOSTA LA CENERE.** Ordine DI voce 10, 12 settembre 2026;
/// rifatto con l'ordine DQ voce 05, 15 settembre 2026.
///
/// **Il fondatore, sul velo dell'ordine DI:** *"fa veramente cagare, non
/// sembra proprio cenere ed e' tutta pixellata"*. **La causa, misurata**: il
/// velo scostava celle intere di una griglia a quaranta colonne, e il dito
/// non apriva un solco, faceva sparire quadrati.
///
/// **LA SEPARAZIONE CHE RISOLVE TUTTO, con le parole dell'ordine**: la
/// griglia resta come contabilita' e smette di essere disegno. Le celle di
/// `IlVeloDellAnimale` misurano ancora quanta area e' scoperta, impongono il
/// quarto di corpo per discesa e proteggono la testa, e non si vedono. **Il
/// disegno e' continuo**: il dito dipinge una maschera alla risoluzione dello
/// schermo col pennello morbido di `IlVeloDellAnimale.raggioDelPennello`, in
/// punti; le celle scoperte si ricavano campionando quella maschera, e i
/// solchi si conservano nel Diario com'erano, per ridipingerli uguali.
///
/// **LA MATERIA**, e non un colore piatto: la grana a piu' ottave calcolata
/// alla risoluzione dello schermo, [GranaDellaCenere.allaScena]; sotto, le
/// braci della Via Rossa del Sigillo, che si intravedono dove il dito passa e
/// si spengono, [LeBraciDellaViaRossa]; il bordo del solco sfrangiato, la
/// cenere spostata che si accumula ai lati, il velo piu' sottile vicino ai
/// solchi; pochi granelli che si sollevano e ricadono.
///
/// **Col `Timer` e non col controller**, per la ragione di sempre: sul
/// 767f596c le scale di animazione valgono zero.
class IlVeloCheSiScosta extends StatefulWidget {
  const IlVeloCheSiScosta({
    super.key,
    required this.nome,
    required this.immagine,
    required this.quale,
    required this.giaScoperte,
    required this.quandoCambia,
    required this.palette,
    this.giaSolchi = const [],
    this.quandoSolca,
    this.piede,
  });

  final String nome;
  final String immagine;

  /// Quante apparizioni c'erano prima di questa: da 0 a 2 si scosta, a 3 il
  /// velo cade da solo.
  final int quale;

  /// Le celle gia' scostate nelle discese di prima, dal Diario: la
  /// contabilita'.
  final Set<int> giaScoperte;

  /// **I SOLCHI GIA' APERTI**, dal Diario, in frazioni dell'illustrazione: il
  /// disegno. Ordine DQ voce 05. Un Diario di prima ha solo le celle, e il
  /// velo le apre come solchi di un punto.
  final List<List<Offset>> giaSolchi;

  /// Riceve tutte le celle scoperte, a ogni gesto finito: da conservare.
  final ValueChanged<Set<int>> quandoCambia;

  /// Riceve tutti i solchi, a ogni gesto finito: da conservare.
  final ValueChanged<List<List<Offset>>>? quandoSolca;

  final MaestroPalette palette;

  /// Cio' che sta sotto l'istruzione, cioe' il pulsante per risalire.
  final Widget? piede;

  /// **QUANTO DURA LA CADUTA DEL VELO**, alla quarta.
  static const Duration quantoDuraLaCaduta = Duration(milliseconds: 900);

  /// **QUANTO VIVE UN GRANELLO SOLLEVATO.**
  static const Duration vitaDellaParticella = Duration(milliseconds: 900);

  /// **QUANTO RESTA ACCESA UNA BRACE** sotto il dito: un istante, poi si
  /// spegne e resta l'animale.
  static const Duration vitaDellaBrace = Duration(milliseconds: 650);

  /// **DOVE STA L'ILLUSTRAZIONE NELLA SCENA**: intera, con le sue proporzioni
  /// vere, nei tre quarti alti della scena, perche' sotto ci sono l'istruzione
  /// e il pulsante. Pubblico perche' una guardia misuri esattamente questo
  /// rettangolo e non uno suo.
  static Rect doveStaLIllustrazione(Size scena, Size misura) {
    final spazio = Size(scena.width, scena.height * 0.78);
    final k =
        math.min(spazio.width / misura.width, spazio.height / misura.height);
    return Rect.fromLTWH(
      (scena.width - misura.width * k) / 2,
      (spazio.height - misura.height * k) / 2,
      misura.width * k,
      misura.height * k,
    );
  }

  @override
  State<IlVeloCheSiScosta> createState() => _IlVeloCheSiScostaState();
}

class _IlVeloCheSiScostaState extends State<IlVeloCheSiScosta> {
  late final IlVeloDellAnimale _velo = IlVeloDellAnimale(widget.nome);
  late final Set<int> _scoperte = {...widget.giaScoperte};
  final Set<int> _oggi = {};
  late final List<List<Offset>> _solchi = [
    for (final s in widget.giaSolchi) [...s],
  ];
  List<Offset>? _corrente;
  final List<_Particella> _particelle = [];
  final List<UnaBrace> _braci = [];
  Timer? _battito;
  Duration _adesso = Duration.zero;
  static const Duration _passo = Duration(milliseconds: 16);
  final math.Random _caso = math.Random(20260915);
  double _percorso = 0;

  /// Da 1, velo intero, a 0, velo caduto. Scende solo alla quarta.
  double _caduta = 1;
  Duration _dallaCaduta = Duration.zero;

  /// Dove stava l'illustrazione all'ultimo disegno: serve alla caduta, che
  /// solleva la cenere senza che nessun dito le dica dove.
  Rect? _illustrazione;
  bool _sollevataLaCaduta = false;

  bool get _cadeDaSolo =>
      widget.quale >= IlVeloDellAnimale.discesePrimaDellaTesta;

  /// **NON RESTA NIENTE DA SCOSTARE**: tutto il corpo fuori dalla testa e'
  /// gia' in chiaro. Succede alla terza discesa del Gufo e della Volpe.
  bool get _restaSoloIlVolto => _velo.scostabile.every(_scoperte.contains);

  bool get _quotaFinita =>
      _oggi.length >= _velo.perDiscesa || _restaSoloIlVolto;

  @override
  void initState() {
    super.initState();
    if (_cadeDaSolo) _accendi();
    // **LA GRANA DI RISERVA SI PREPARA UNA VOLTA SOLA**, per tutta l'app:
    // serve per i primi fotogrammi, finche' quella alla risoluzione dello
    // schermo non e' pronta.
    if (GranaDellaCenere.pronta == null) {
      unawaited(GranaDellaCenere.prepara().then((_) {
        if (mounted) setState(() {});
      }));
    }
    if (LeBraciDellaViaRossa.pronte == null) {
      unawaited(LeBraciDellaViaRossa.prepara().then((_) {
        if (mounted) setState(() {});
      }));
    }
  }

  @override
  void dispose() {
    _battito?.cancel();
    super.dispose();
  }

  void _accendi() {
    _battito ??= Timer.periodic(_passo, (t) {
      if (!mounted) return t.cancel();
      // **UN TEMPO CHE NON RIPARTE DA ZERO**: il battito si spegne quando
      // non c'e' niente in aria, e alla ripresa i granelli e le braci nati
      // prima devono avere l'eta' giusta.
      _adesso += _passo;
      setState(() {
        // **ALLA QUARTA LA CENERE SI SOLLEVA**: pochi granelli, e la coltre
        // sparisce sotto di loro.
        final dove = _illustrazione;
        if (_cadeDaSolo && !_sollevataLaCaduta && dove != null) {
          _sollevataLaCaduta = true;
          for (final i in _velo.velato.difference(_scoperte)) {
            if (i % 9 == 0) _sollevaDallaCella(i, dove);
          }
        }
        if (_cadeDaSolo && _caduta > 0) {
          _dallaCaduta += _passo;
          _caduta = (1 -
                  _dallaCaduta.inMilliseconds /
                      IlVeloCheSiScosta.quantoDuraLaCaduta.inMilliseconds)
              .clamp(0.0, 1.0);
        }
        _particelle.removeWhere((p) =>
            _adesso - p.nata > IlVeloCheSiScosta.vitaDellaParticella);
        _braci.removeWhere(
            (b) => _adesso - b.nata > IlVeloCheSiScosta.vitaDellaBrace);
      });
      if ((_caduta <= 0 || !_cadeDaSolo) &&
          _particelle.isEmpty &&
          _braci.isEmpty) {
        t.cancel();
        _battito = null;
      }
    });
  }

  /// **IL DITO DIPINGE.** Il punto entra nel solco, e le celle che la
  /// maschera scopre abbastanza si contano, dalla piu' vicina, finche' la
  /// quantita' di oggi non e' finita. **Finita la quantita', il dito non
  /// dipinge piu'**: il solco si ferma dove si e' fermata la contabilita'.
  void _passa(Offset dito, Rect illustrazione, {bool inizio = false}) {
    if (_cadeDaSolo || illustrazione.isEmpty || _quotaFinita) return;
    final punto = Offset(
      (dito.dx - illustrazione.left) / illustrazione.width,
      (dito.dy - illustrazione.top) / illustrazione.height,
    );
    final solco = _corrente;
    if (inizio || solco == null) {
      _corrente = [punto];
      _solchi.add(_corrente!);
      _conta(punto, punto, illustrazione);
      return;
    }
    final ultimo = solco.last;
    final inPunti = Offset((punto.dx - ultimo.dx) * illustrazione.width,
        (punto.dy - ultimo.dy) * illustrazione.height);
    // **UN PUNTO OGNI TRE PUNTI DI STRADA**: il solco resta liscio, e il
    // Diario non si riempie di punti uguali.
    if (inPunti.distance < 3) return;
    solco.add(punto);
    _conta(ultimo, punto, illustrazione);
    _percorso += inPunti.distance;
    // **UNA BRACE PER OGNI TRATTO**, che si accende e si spegne.
    _braci.add(UnaBrace(da: ultimo, a: punto, nata: _adesso));
    // **POCHI GRANELLI**: uno ogni sedici punti di strada, e mai piu' di
    // trenta in aria. Una nuvola sarebbe un effetto: qui serve una materia.
    while (_percorso > 16) {
      _percorso -= 16;
      if (_particelle.length < 30) {
        _sollevaDa(
            Offset(illustrazione.left + punto.dx * illustrazione.width,
                illustrazione.top + punto.dy * illustrazione.height),
            inPunti);
      }
    }
    _accendi();
    setState(() {});
  }

  /// **LA CONTABILITA'**: le celle che il tratto scopre, dalla piu' vicina,
  /// finche' la quantita' di oggi non e' finita.
  void _conta(Offset da, Offset a, Rect illustrazione) {
    for (final i in _velo.scoperteDa(da, a, illustrazione.size)) {
      if (_quotaFinita) break;
      if (_scoperte.add(i)) _oggi.add(i);
    }
  }

  /// **UN GRANELLO SI SOLLEVA E RICADE**, spinto dal verso del dito.
  void _sollevaDa(Offset dove, Offset verso) {
    final lato = verso.distance == 0 ? const Offset(0, 0) : verso / verso.distance;
    _particelle.add(_Particella(
      da: dove + Offset((_caso.nextDouble() - 0.5) * 8, 0),
      verso: Offset(lato.dx * 30 + (_caso.nextDouble() - 0.5) * 40,
          -60 - _caso.nextDouble() * 50),
      grande: 0.6 + _caso.nextDouble() * 1.2,
      chiara: _caso.nextDouble() < 0.4,
      nata: _adesso,
    ));
  }

  void _sollevaDallaCella(int i, Rect illustrazione) {
    final c = _velo.centro(i);
    _sollevaDa(
        Offset(illustrazione.left + c.dx * illustrazione.width,
            illustrazione.top + c.dy * illustrazione.height),
        Offset.zero);
  }

  void _fine() {
    _corrente = null;
    widget.quandoCambia(Set.of(_scoperte));
    widget.quandoSolca?.call([for (final s in _solchi) List.of(s)]);
  }

  @override
  Widget build(BuildContext context) {
    final misura = LeSagome.misure[widget.nome] ?? const Size(1, 1);
    final palette = widget.palette;
    final dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 1;
    return LayoutBuilder(builder: (context, vincoli) {
      final scena = Size(vincoli.maxWidth, vincoli.maxHeight);
      final illustrazione =
          IlVeloCheSiScosta.doveStaLIllustrazione(scena, misura);
      _illustrazione = illustrazione;
      // **LA GRANA ALLA RISOLUZIONE DELLO SCHERMO**, una volta per misura.
      final grana = GranaDellaCenere.allaScena(
          illustrazione.size, dpr, () {
        if (mounted) setState(() {});
      });
      final coperte = _cadeDaSolo && _caduta <= 0
          ? <int>{}
          : _velo.velato.difference(_scoperte);
      return GestureDetector(
        key: const Key('viaggio_velo_che_si_scosta'),
        behavior: HitTestBehavior.opaque,
        onPanStart: (d) => _passa(d.localPosition, illustrazione, inizio: true),
        onPanUpdate: (d) => _passa(d.localPosition, illustrazione),
        onPanEnd: (_) => _fine(),
        onPanCancel: _fine,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fromRect(
              rect: illustrazione,
              child: Image.asset(
                widget.immagine,
                key: const Key('viaggio_animale_vero'),
                fit: BoxFit.fill,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
            // **LE BRACI, SOTTO LA CENERE**: si vedono solo dove il dito
            // l'ha appena tolta.
            Positioned.fromRect(
              rect: illustrazione,
              child: IgnorePointer(
                child: CustomPaint(
                  size: Size.infinite,
                  painter: PittoreDelleBraci(
                    braci: List.of(_braci),
                    adesso: _adesso,
                    materia: LeBraciDellaViaRossa.pronte,
                  ),
                ),
              ),
            ),
            Positioned.fromRect(
              rect: illustrazione,
              child: IgnorePointer(
                child: CustomPaint(
                  key: const Key('viaggio_cenere'),
                  size: Size.infinite,
                  painter: PittoreDellaCenere(
                    velo: _velo,
                    coperte: coperte,
                    quanta: _caduta,
                    grana: grana ?? GranaDellaCenere.pronta,
                    granaAllaScena: grana != null,
                    dpr: dpr,
                    solchi: [for (final s in _solchi) List.of(s)],
                    scoperte: Set.of(_scoperte),
                  ),
                ),
              ),
            ),
            IgnorePointer(
              child: CustomPaint(
                size: Size.infinite,
                painter: _PittoreDeiGranelli(
                  particelle: List.of(_particelle),
                  adesso: _adesso,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(SpacingTokens.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _cadeDaSolo
                          ? 'Oggi il velo cade da solo.'
                          : _restaSoloIlVolto
                              ? 'Resta velato soltanto il volto.'
                              : _quotaFinita
                                  ? 'Per oggi hai scostato abbastanza.'
                                  // **La frase del fondatore**, ordine DJ
                                  // voce 04: il gesto e la materia.
                                  : 'Scosta la cenere con il dito.',
                      key: const Key('viaggio_istruzione_lente'),
                      textAlign: TextAlign.center,
                      style: TypographyTokens.etichetta().copyWith(
                          color: palette.goldSoft, letterSpacing: 1.2),
                    ),
                    if (widget.piede != null) ...[
                      const SizedBox(height: SpacingTokens.md),
                      widget.piede!,
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _Particella {
  const _Particella({
    required this.da,
    required this.verso,
    required this.grande,
    required this.chiara,
    required this.nata,
  });

  final Offset da;

  /// Punti al secondo.
  final Offset verso;
  final double grande;

  /// Una scaglia chiara o un grumo scuro: la cenere vera ha tutti e due.
  final bool chiara;
  final Duration nata;
}

/// Un tratto del dito appena passato, dove la brace si vede.
class UnaBrace {
  const UnaBrace({required this.da, required this.a, required this.nata});
  final Offset da;
  final Offset a;
  final Duration nata;
}

/// **LA GRANA DELLA CENERE.**
///
/// **Due grane, e la seconda e' quella vera.** [allaScena] la calcola **alla
/// risoluzione dello schermo**, un pixel di grana per un pixel vero, a piu'
/// ottave, una volta per misura e fuori dal filo del disegno. E' cio' che
/// l'ordine DQ voce 05 chiede: *"grana fine generata a piu' ottave, non una
/// texture ripetuta a bassa risoluzione, che tornerebbe a ripixellare"*.
/// Finche' non e' pronta, per i primi fotogrammi, vale la piastrella di
/// riserva di [prepara], che e' quella dell'ordine DI.
///
/// **Opaca in ogni pixel**, perche' la copertura del velo non dipende da lei:
/// la cenere copre col suo tracciato, la grana ne decide solo il colore.
abstract final class GranaDellaCenere {
  /// Il lato della piastrella di riserva, in pixel.
  static const int lato = 256;

  /// **QUANTO E' FINE LA PIASTRELLA DI RISERVA**: un pixel e' mezzo punto.
  static const double scala = 0.5;

  /// **QUANTO E' FITTA LA GRANA ALLA SCENA**: le scaglie chiare e i pori scuri
  /// per pixel. **E' il numero da abbassare se i fotogrammi del velo scendono
  /// sotto i cinquanta al secondo**, ordine DQ voce 05, e non la risoluzione
  /// della maschera.
  static double densita = 1;

  static ui.Image? _pronta;
  static Future<ui.Image>? _inCorso;

  /// La piastrella di riserva, o nulla finche' non e' pronta.
  static ui.Image? get pronta => _pronta;

  static Future<ui.Image> prepara() => _inCorso ??= () {
        final fatto = Completer<ui.Image>();
        ui.decodeImageFromPixels(
            pixel(), lato, lato, ui.PixelFormat.rgba8888, (img) {
          _pronta = img;
          fatto.complete(img);
        });
        return fatto.future;
      }();

  /// I pixel della piastrella di riserva, RGBA. Pura e sempre la stessa.
  static Uint8List pixel() => pixelAllaScena(
      (larga: lato, alta: lato, seme: 20260913, densita: 1, periodica: true));

  static ui.Image? _allaScena;
  static String? _misuraDellaScena;
  static String? _inPreparazione;

  /// **SE LA GRANA ALLA SCENA SI PREPARA.** Accesa nell'app; **spenta sotto
  /// `flutter test`**, dove le guardie dei pixel confrontano due fotogrammi
  /// che devono avere la stessa cenere, e una grana che arrivasse fra i due
  /// sarebbe misurata come animale. **Si riaccende**: la guardia della grana
  /// la accende e la guarda.
  static bool accesa = !Platform.environment.containsKey('FLUTTER_TEST');

  /// **LA GRANA DELLA SCENA**, di [misura] punti a [dpr] pixel per punto: la
  /// restituisce quando e' pronta, e la prepara la prima volta, fuori dal
  /// filo del disegno; [quandoPronta] viene chiamato allora.
  static ui.Image? allaScena(Size misura, double dpr, VoidCallback quandoPronta) {
    if (!accesa) return null;
    final larga = (misura.width * dpr).round();
    final alta = (misura.height * dpr).round();
    if (larga <= 0 || alta <= 0) return null;
    final chiave = '${larga}x$alta/$densita';
    if (_misuraDellaScena == chiave) return _allaScena;
    if (_inPreparazione != chiave) {
      _inPreparazione = chiave;
      final d = densita;
      unawaited(compute(pixelAllaScena,
              (larga: larga, alta: alta, seme: 20260915, densita: d, periodica: false))
          .then((pixel) {
        ui.decodeImageFromPixels(pixel, larga, alta, ui.PixelFormat.rgba8888,
            (img) {
          if (_inPreparazione != chiave) return;
          _allaScena = img;
          _misuraDellaScena = chiave;
          quandoPronta();
        });
      }));
    }
    return null;
  }

  /// **I PIXEL DELLA GRANA**, RGBA, a piu' ottave. Pura: una guardia la puo'
  /// leggere. Le ottave vanno da un blocco di cento pixel, i toni che si
  /// addensano e si diradano come in un mucchio vero, a uno di quattro, la
  /// polvere; sopra, un grano per pixel, **rare scaglie chiare e pori
  /// scuri**. [periodica] richiude i reticoli su se' stessi, per la
  /// piastrella di riserva che si ripete.
  static Uint8List pixelAllaScena(
      ({int larga, int alta, int seme, double densita, bool periodica}) p) {
    final caso = math.Random(p.seme);
    // Per la piastrella il primo numero e' quanti blocchi stanno in un lato,
    // e il reticolo si richiude; per la grana alla scena e' il lato di un
    // blocco in pixel veri.
    final ottave = p.periodica
        ? const [(6, 0.52), (15, 0.30), (38, 0.18)]
        : const [(104, 0.34), (40, 0.30), (14, 0.22), (4, 0.14)];
    double morbido(double t) => t * t * (3 - 2 * t);
    final campo = Float64List(p.larga * p.alta);
    for (final (n, peso) in ottave) {
      final gx = p.periodica ? n : p.larga ~/ n + 2;
      final gy = p.periodica ? n : p.alta ~/ n + 2;
      final v = Float64List(gx * gy);
      for (var k = 0; k < v.length; k++) {
        v[k] = caso.nextDouble();
      }
      // Le tabelle di una riga e di una colonna: dove cade il pixel nel
      // reticolo, e quanto pesa il vicino. Cosi' il cuore del giro e' fatto
      // di somme, senza nessuna funzione per pixel.
      final x0 = Int32List(p.larga), x1 = Int32List(p.larga);
      final tx = Float64List(p.larga);
      for (var x = 0; x < p.larga; x++) {
        final f = p.periodica ? x / p.larga * gx : x / n;
        final i = f.floor();
        x0[x] = i % gx;
        x1[x] = (i + 1) % gx;
        tx[x] = morbido(f - i);
      }
      for (var y = 0; y < p.alta; y++) {
        final f = p.periodica ? y / p.alta * gy : y / n;
        final j = f.floor();
        final r0 = (j % gy) * gx;
        final r1 = ((j + 1) % gy) * gx;
        final ty = morbido(f - j);
        final riga = y * p.larga;
        for (var x = 0; x < p.larga; x++) {
          final a = v[r0 + x0[x]];
          final b = v[r0 + x1[x]];
          final c = v[r1 + x0[x]];
          final d = v[r1 + x1[x]];
          final alto = a + (b - a) * tx[x];
          final basso = c + (d - c) * tx[x];
          campo[riga + x] += (alto + (basso - alto) * ty) * peso;
        }
      }
    }
    const scuro = [0x17, 0x14, 0x11];
    const chiaro = [0x5A, 0x51, 0x48];
    const scaglia = [0xA3, 0x98, 0x8A];
    const poro = [0x08, 0x07, 0x06];
    final scaglie = 0.004 * p.densita;
    final pori = 1 - 0.022 * p.densita;
    final out = Uint8List(p.larga * p.alta * 4);
    for (var k = 0; k < campo.length; k++) {
      final t = (campo[k] + (caso.nextDouble() - 0.5) * 0.24).clamp(0.0, 1.0);
      final q = caso.nextDouble();
      final o = k * 4;
      for (var c = 0; c < 3; c++) {
        var v = scuro[c] + (chiaro[c] - scuro[c]) * t;
        if (q < scaglie) v = v + (scaglia[c] - v) * 0.65;
        if (q > pori) v = v + (poro[c] - v) * 0.8;
        out[o + c] = v.round().clamp(0, 255);
      }
      out[o + 3] = 255;
    }
    return out;
  }
}

/// **LE BRACI DELLA VIA ROSSA**, sotto la cenere. Ordine DQ voce 05: *"e' la
/// stessa materia del fondo della Via Rossa del Sigillo, quindi l'app parla
/// una lingua sola"*.
///
/// Dal fondo si prende il muro di carboni a sinistra, dove le crepe sono
/// arancio, e non il logo in basso: un ritaglio che si ripete a specchio.
abstract final class LeBraciDellaViaRossa {
  static const String fondo = 'assets/img/sigillo/fondi/fondo_via_rossa_v1.webp';

  /// **IL RITAGLIO**, in frazioni del fondo di 1440 per 3200: il muro di
  /// carboni a sinistra, dove le crepe sono arancio.
  static const Rect ritaglio = Rect.fromLTRB(0, 0.52, 0.30, 0.84);

  static ui.Image? _pronte;
  static Future<void>? _inCorso;
  static ui.Image? get pronte => _pronte;

  static Future<void> prepara() => _inCorso ??= () async {
        try {
          final dati = await rootBundle.load(fondo);
          final codec = await ui.instantiateImageCodec(dati.buffer.asUint8List());
          final intero = (await codec.getNextFrame()).image;
          final w = intero.width.toDouble();
          final h = intero.height.toDouble();
          final src = Rect.fromLTRB(ritaglio.left * w, ritaglio.top * h,
              ritaglio.right * w, ritaglio.bottom * h);
          final registro = ui.PictureRecorder();
          Canvas(registro).drawImageRect(intero, src,
              Rect.fromLTWH(0, 0, src.width, src.height), Paint());
          _pronte = registro
              .endRecording()
              .toImageSync(src.width.round(), src.height.round());
        } catch (errore) {
          // **SENZA IL FONDO LA BRACE E' UN CALORE ROSSO**, dipinto: il gesto
          // non si ferma per un file.
        }
      }();
}

/// **IL PITTORE DELLE BRACI**: dove il dito e' appena passato si vede per un
/// istante il calore rosso, che si spegne subito. Pubblico perche' una
/// guardia lo dipinga.
class PittoreDelleBraci extends CustomPainter {
  PittoreDelleBraci({
    required this.braci,
    required this.adesso,
    required this.materia,
  });

  final List<UnaBrace> braci;
  final Duration adesso;
  final ui.Image? materia;

  static const Color calore = Color(0xFFFF5A1F);

  @override
  void paint(Canvas canvas, Size size) {
    if (braci.isEmpty) return;
    const r = IlVeloDellAnimale.raggioDelPennello;
    final m = materia;
    final shader = m == null
        ? null
        : ImageShader(m, TileMode.mirror, TileMode.mirror,
            Matrix4.diagonal3Values(0.55, 0.55, 1).storage);
    for (final b in braci) {
      final vita = (adesso - b.nata).inMilliseconds /
          IlVeloCheSiScosta.vitaDellaBrace.inMilliseconds;
      if (vita < 0 || vita >= 1) continue;
      final quanto = math.pow(1 - vita, 1.6).toDouble();
      final da = Offset(b.da.dx * size.width, b.da.dy * size.height);
      final a = Offset(b.a.dx * size.width, b.a.dy * size.height);
      // Il calore, largo e morbido.
      canvas.drawLine(
          da,
          a,
          Paint()
            ..color = calore.withValues(alpha: 0.55 * quanto)
            ..strokeWidth = r * 1.9
            ..strokeCap = StrokeCap.round
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, r * 0.45));
      // E la brace vera, dalla Via Rossa.
      final brace = Paint()
        ..strokeWidth = r * 1.5
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, r * 0.2);
      if (shader != null) {
        brace
          ..shader = shader
          ..colorFilter = ColorFilter.mode(
              Colors.white.withValues(alpha: quanto), BlendMode.modulate);
      } else {
        brace.color = const Color(0xFFB8340C).withValues(alpha: 0.8 * quanto);
      }
      canvas.drawLine(da, a, brace);
    }
  }

  @override
  bool shouldRepaint(PittoreDelleBraci vecchio) => true;
}

/// **IL PITTORE DELLA CENERE**, pubblico perche' una guardia lo possa
/// dipingere e contare.
///
/// **LA COLTRE**, [forma]: ogni cella velata vi entra come un cerchio che la
/// contiene tutta, e i cerchi vicini si fondono; il contorno verso il vuoto e'
/// fatto di curve e di scaglie, non di scalini. Sopra il cumulo della testa.
/// La coltre si dipinge una volta per misura in un'immagine, con la grana.
///
/// **I SOLCHI**, dal Diario e dal dito, si scavano sopra, dentro un livello:
/// prima il velo si assottiglia attorno al solco, poi la cenere spostata si
/// accumula ai lati, poi il solco, col bordo morbido del pennello e qualche
/// morso sfrangiato. Infine **la testa si ridipinge sopra**, col bordo
/// sfumato: il pennello non la tocca, e dove si avvicina si ferma morbido.
class PittoreDellaCenere extends CustomPainter {
  PittoreDellaCenere({
    required this.velo,
    required this.coperte,
    required this.quanta,
    this.grana,
    this.granaAllaScena = false,
    this.dpr = 1,
    this.solchi = const [],
    Set<int>? scoperte,
  }) : scoperte = scoperte ?? velo.velato.difference(coperte);

  final IlVeloDellAnimale velo;

  /// Le celle ancora coperte: la contabilita', per chi guarda.
  final Set<int> coperte;

  /// Le celle scoperte: si aprono anche senza il loro solco, per i Diari
  /// scritti prima dell'ordine DQ.
  final Set<int> scoperte;

  /// Da 1, cenere piena, a 0: la caduta della quarta discesa.
  final double quanta;

  /// La grana: quella della scena, o la piastrella di riserva.
  final ui.Image? grana;
  final bool granaAllaScena;
  final double dpr;

  /// I solchi, in frazioni dell'illustrazione.
  final List<List<Offset>> solchi;

  /// **IL COLORE DELLA CENERE** quando la grana non e' ancora pronta.
  static const Color cenere = Color(0xFF2E2822);

  /// **IL COLORE DEI GRANELLI CHE SI SOLLEVANO**: scaglie chiare e grumi.
  static const Color granaChiara = Color(0xFFA69B8C);
  static const Color granaScura = Color(0xFF1A1612);

  /// **LA CENERE SPOSTATA**, che si accumula ai lati del solco.
  static const Color accumulo = Color(0xFF7A7066);

  /// **IL PEZZO DI CENERE DI UNA CELLA**: il suo rettangolo, allargato di
  /// sei decimi di punto. Il cerchio della coltre lo contiene tutto.
  static Rect pezzo(IlVeloDellAnimale velo, int i, Size size) {
    final cw = size.width / velo.colonne;
    final ch = size.height / velo.righe;
    return Rect.fromLTWH(
            (i % velo.colonne) * cw, (i ~/ velo.colonne) * ch, cw, ch)
        .inflate(0.6);
  }

  /// **LA FORMA DELLA COLTRE** per [coperte], in una cenere grande [size].
  /// Pubblica perche' una guardia verifichi che contiene ogni cella coperta.
  static Path forma(IlVeloDellAnimale velo, Set<int> coperte, Size size) {
    final cw = size.width / velo.colonne;
    final ch = size.height / velo.righe;
    final lato = math.min(cw, ch);
    // **UN CERCHIO CHE CONTIENE TUTTO IL PEZZO**: il raggio e' la
    // semidiagonale del pezzo, piu' un quarto di cella per fondersi coi
    // vicini senza fili.
    final minimo =
        math.sqrt(math.pow(cw / 2 + 0.6, 2) + math.pow(ch / 2 + 0.6, 2));
    final p = _ilCumulo(velo, coperte, size);
    for (final i in coperte) {
      final r = i ~/ velo.colonne;
      final c = i % velo.colonne;
      final centro = Offset((c + 0.5) * cw, (r + 0.5) * ch);
      // **OGNI CERCHIO HA LA SUA MISURA**, sempre piu' grande del pezzo:
      // cerchi tutti uguali sul contorno facevano una fila di perle.
      final raggio =
          minimo + lato * (0.12 + math.Random(i * 7 + 3).nextDouble() * 0.5);
      p.addOval(Rect.fromCircle(center: centro, radius: raggio));
      // Le scaglie sui lati esposti, perche' il contorno sia polvere.
      const lati = [(0, -1), (1, 0), (0, 1), (-1, 0)];
      for (var l = 0; l < 4; l++) {
        final (dc, dr) = lati[l];
        final vc = c + dc;
        final vr = r + dr;
        final dentro =
            vc >= 0 && vc < velo.colonne && vr >= 0 && vr < velo.righe;
        if (dentro && coperte.contains(vr * velo.colonne + vc)) continue;
        final seme = math.Random(i * 4 + l);
        for (var k = 0; k < 2; k++) {
          final angolo = math.atan2(dr.toDouble(), dc.toDouble()) +
              (seme.nextDouble() - 0.5) * 1.4;
          final fuori = raggio * (0.85 + seme.nextDouble() * 0.35);
          p.addOval(Rect.fromCircle(
              center: centro + Offset(math.cos(angolo), math.sin(angolo)) * fuori,
              radius: lato * (0.08 + seme.nextDouble() * 0.16)));
        }
      }
    }
    return p;
  }

  /// **IL CUMULO SULLA TESTA**, finche' la testa e' coperta: l'ellisse del
  /// velo, con nove gobbe sul contorno e una corona di scaglie, perche' sia
  /// una nube di cenere e non un ovale disegnato col compasso.
  static Path _ilCumulo(IlVeloDellAnimale velo, Set<int> coperte, Size size) {
    final p = Path();
    final n = velo.cumulo;
    if (n == null || !coperte.any(velo.testa.contains)) return p;
    final lato = math.min(size.width / velo.colonne, size.height / velo.righe);
    final c = Offset(n.centro.dx * size.width, n.centro.dy * size.height);
    final a = n.a * size.width;
    final b = n.b * size.height;
    p.addOval(Rect.fromCenter(center: c, width: a * 2, height: b * 2));
    final seme = math.Random(velo.nome.hashCode & 0x7fffffff);
    final corto = math.min(a, b);
    for (var k = 0; k < 9; k++) {
      final angolo = (k + seme.nextDouble() * 0.6) / 9 * 2 * math.pi;
      final dove = c + Offset(math.cos(angolo) * a, math.sin(angolo) * b) * 0.86;
      p.addOval(Rect.fromCircle(
          center: dove, radius: corto * (0.16 + seme.nextDouble() * 0.14)));
    }
    for (var k = 0; k < 90; k++) {
      final angolo = seme.nextDouble() * 2 * math.pi;
      final fuori = 0.97 + seme.nextDouble() * 0.12;
      final dove = c + Offset(math.cos(angolo) * a, math.sin(angolo) * b) * fuori;
      p.addOval(Rect.fromCircle(
          center: dove, radius: lato * (0.12 + seme.nextDouble() * 0.3)));
    }
    return p;
  }

  /// **LE IMMAGINI GIA' DIPINTE**, una per animale, misura e grana: la coltre
  /// e il cumulo, che non cambiano mentre il dito passa.
  static final Map<String, (ui.Image, ui.Image)> _dipinte = {};

  Paint _pittura(double alfa) {
    final colore = Paint()..color = cenere.withValues(alpha: alfa);
    final g = grana;
    if (g != null) {
      final k = granaAllaScena ? 1 / dpr : GranaDellaCenere.scala;
      colore.shader = ImageShader(g, TileMode.repeated, TileMode.repeated,
          Matrix4.diagonal3Values(k, k, 1).storage);
    }
    return colore;
  }

  (ui.Image, ui.Image) _coltreECumulo(Size size) {
    final chiave = '${velo.nome}/${size.width.round()}x${size.height.round()}'
        '/$dpr/${grana?.width}x${grana?.height}/$granaAllaScena';
    final gia = _dipinte[chiave];
    if (gia != null) return gia;
    // **UN MARGINE ATTORNO ALL'ILLUSTRAZIONE**: il cumulo della testa e le
    // scaglie del contorno ne escono, e un'immagine grande quanto lei li
    // tagliava dritti. Vedi [margine].
    final m = margine(size);
    final larga = math.max(1, ((size.width + 2 * m) * dpr).ceil());
    final alta = math.max(1, ((size.height + 2 * m) * dpr).ceil());
    ui.Image dipingi(void Function(Canvas) cosa) {
      final registro = ui.PictureRecorder();
      final c = Canvas(registro)
        ..scale(dpr)
        ..translate(m, m);
      cosa(c);
      return registro.endRecording().toImageSync(larga, alta);
    }

    final coltre =
        dipingi((c) => c.drawPath(forma(velo, velo.velato, size), _pittura(1)));
    // **IL CUMULO CON IL BORDO SFUMATO**: il cuore pieno, e sopra lo stesso
    // cumulo col bordo morbido, della stessa grana. Il cuore contiene tutto
    // il rettangolo della testa.
    final cumulo = dipingi((c) {
      final forma = _ilCumulo(velo, velo.velato, size);
      c.drawPath(forma, _pittura(1));
      c.drawPath(
          forma,
          _pittura(1)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal,
                IlVeloDellAnimale.raggioDelPennello * 0.35));
    });
    if (_dipinte.length > 6) _dipinte.clear();
    return _dipinte[chiave] = (coltre, cumulo);
  }

  /// **IL MARGINE DELLE IMMAGINI DELLA COLTRE**, in punti: un terzo del
  /// lato piu' lungo, abbastanza per l'ellisse del cumulo, che passa per gli
  /// angoli del rettangolo della testa allargato.
  static double margine(Size size) =>
      math.max(size.width, size.height) / 3;

  /// Il tracciato dei solchi, in punti: un segmento per coppia di punti, un
  /// cerchio per il solco di un punto solo.
  static Path _tracciato(List<List<Offset>> solchi, Size size) {
    final p = Path();
    for (final s in solchi) {
      if (s.isEmpty) continue;
      final primo = Offset(s.first.dx * size.width, s.first.dy * size.height);
      p.moveTo(primo.dx, primo.dy);
      if (s.length == 1) {
        p.lineTo(primo.dx + 0.01, primo.dy);
        continue;
      }
      for (final q in s.skip(1)) {
        p.lineTo(q.dx * size.width, q.dy * size.height);
      }
    }
    return p;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (quanta <= 0) return;
    const r = IlVeloDellAnimale.raggioDelPennello;
    final (coltre, cumulo) = _coltreECumulo(size);
    final tutta = (Offset.zero & size).inflate(margine(size));
    canvas.saveLayer(tutta,
        Paint()..color = Colors.white.withValues(alpha: quanta));
    canvas.drawImageRect(
        coltre,
        Rect.fromLTWH(0, 0, coltre.width.toDouble(), coltre.height.toDouble()),
        tutta,
        Paint()..filterQuality = FilterQuality.none);
    final solco = _tracciato(solchi, size);
    Paint pennello(double largo, Color colore, BlendMode modo, double morbido) =>
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = largo
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = colore
          ..blendMode = modo
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, morbido);
    if (solchi.isNotEmpty) {
      // 1. **IL VELO SI ASSOTTIGLIA VICINO AI SOLCHI**: e' piu' spesso dove
      //    nessuno ha toccato.
      canvas.drawPath(
          solco,
          pennello(r * 3.2, Colors.black.withValues(alpha: 0.2),
              BlendMode.dstOut, r * 0.6));
      // 2. **LA CENERE SPOSTATA SI ACCUMULA AI LATI**: una cresta piu'
      //    chiara, solo dove la cenere c'e'.
      canvas.drawPath(
          solco,
          pennello(r * 2.55, accumulo.withValues(alpha: 0.8),
              BlendMode.srcATop, r * 0.12));
      // 3. **IL SOLCO**, col bordo morbido del pennello.
      canvas.drawPath(solco,
          pennello(r * 2, Colors.black, BlendMode.dstOut, r * 0.22));
      // 4. **IL BORDO SFRANGIATO**: morsi piccoli fuori dal solco e grumi
      //    dentro, a caso ma sempre gli stessi per quel punto.
      final morso = Paint()
        ..color = Colors.black
        ..blendMode = BlendMode.dstOut
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.8);
      final grumo = _pittura(0.9)..blendMode = BlendMode.srcOver;
      for (final s in solchi) {
        for (var k = 0; k < s.length; k++) {
          final seme = math.Random(
              (s[k].dx * 10007).round() * 31 + (s[k].dy * 10009).round());
          final centro = Offset(s[k].dx * size.width, s[k].dy * size.height);
          for (var j = 0; j < 2; j++) {
            final angolo = seme.nextDouble() * 2 * math.pi;
            final dove = centro +
                Offset(math.cos(angolo), math.sin(angolo)) *
                    (r * (0.95 + seme.nextDouble() * 0.3));
            canvas.drawCircle(dove, 1 + seme.nextDouble() * 2.2, morso);
          }
          if (seme.nextDouble() < 0.35) {
            final angolo = seme.nextDouble() * 2 * math.pi;
            final dove = centro +
                Offset(math.cos(angolo), math.sin(angolo)) *
                    (r * (0.7 + seme.nextDouble() * 0.2));
            canvas.drawCircle(dove, 0.8 + seme.nextDouble() * 1.4, grumo);
          }
        }
      }
    }
    // 5. **LE CELLE SCOPERTE SENZA IL LORO SOLCO**, da un Diario di prima:
    //    si aprono come solchi di un punto, un cerchio morbido per cella.
    if (scoperte.isNotEmpty) {
      final cw = size.width / velo.colonne;
      final ch = size.height / velo.righe;
      final raggio = math.sqrt(cw * cw + ch * ch) * 0.62;
      final buchi = Path();
      for (final i in scoperte) {
        buchi.addOval(Rect.fromCircle(
            center: Offset((i % velo.colonne + 0.5) * cw,
                (i ~/ velo.colonne + 0.5) * ch),
            radius: raggio));
      }
      canvas.drawPath(
          buchi,
          Paint()
            ..color = Colors.black
            ..blendMode = BlendMode.dstOut
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, raggio * 0.18));
    }
    // 6. **LA TESTA SI RIDIPINGE SOPRA**, finche' e' coperta: il pennello non
    //    la tocca, e dove le si avvicina si ferma col bordo sfumato.
    if (coperte.any(velo.testa.contains)) {
      canvas.drawImageRect(
          cumulo,
          Rect.fromLTWH(0, 0, cumulo.width.toDouble(), cumulo.height.toDouble()),
          tutta,
          Paint()..filterQuality = FilterQuality.none);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(PittoreDellaCenere vecchio) =>
      vecchio.quanta != quanta ||
      vecchio.coperte.length != coperte.length ||
      vecchio.scoperte.length != scoperte.length ||
      vecchio.grana != grana ||
      vecchio.solchi.length != solchi.length ||
      vecchio.solchi.fold<int>(0, (s, x) => s + x.length) !=
          solchi.fold<int>(0, (s, x) => s + x.length);
}

class _PittoreDeiGranelli extends CustomPainter {
  _PittoreDeiGranelli({required this.particelle, required this.adesso});

  final List<_Particella> particelle;
  final Duration adesso;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particelle) {
      final t = (adesso - p.nata).inMilliseconds / 1000;
      final vita =
          t / (IlVeloCheSiScosta.vitaDellaParticella.inMilliseconds / 1000);
      if (vita >= 1 || vita < 0) continue;
      // **SALE E RICADE**: la gravita' vince in mezzo secondo.
      final dove = p.da + p.verso * t + Offset(0, 240 * t * t);
      canvas.drawCircle(
        dove,
        p.grande * (1 - 0.3 * vita),
        Paint()
          ..color = (p.chiara
                  ? PittoreDellaCenere.granaChiara
                  : PittoreDellaCenere.granaScura)
              .withValues(alpha: 0.85 * (1 - vita)),
      );
    }
  }

  @override
  bool shouldRepaint(_PittoreDeiGranelli vecchio) => true;
}
