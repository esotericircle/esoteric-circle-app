/// IL PITTORE DEL CIELO DEL REAL TIME COSMO. Ordine FG parti 2, 4 e 5.
///
/// **Il cielo si dipinge una volta** (voce 2.1, guardia
/// `test/real_time_cosmo_il_cielo_si_dipinge_una_volta_test.dart`): nel
/// cammino per fotogramma, cioe' [PittoreDelCielo.paint], non nasce nessun
/// MaskFilter, nessuno shader, nessuna lista. Le stelle sono UNA chiamata
/// `drawRawAtlas` coi buffer della scena; la Luna, l'alone dei veli, la
/// foschia della profondita' di campo e le scritte sono immagini e testi
/// cotti prima, fuori da qui, e qui si posano soltanto.
library;

import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'il_velo_delle_costellazioni.dart';
import 'la_scena_del_cielo.dart';
import 'l_orizzonte_in_scena.dart';
import 'il_cielo_profondo_in_scena.dart';
import 'l_eclittica_in_scena.dart';
import 'le_meteore_in_scena.dart';
import 'la_via_lattea_in_scena.dart';
import 'le_linee_in_scena.dart';
import 'lo_stile_del_cielo.dart';

/// Il battito del cielo: a ogni fotogramma la schermata lo fa battere e il
/// pittore ridisegna, senza ricostruire i widget.
class BattitoDelCielo extends ChangeNotifier {
  void batti() => notifyListeners();
}

/// LE MISURE DEL REAL TIME COSMO, lette dalle prove e dal rapporto.
abstract final class MisureDelCosmo {
  /// Quanti istanti ha calcolato il ritorno (il tetto della voce 3.3).
  static int istantiCalcolatiNelRitorno = 0;

  /// Quante volte si e' cotta la foschia (voce 5.3: mai per fotogramma).
  static int foschieCotte = 0;

  /// Quante volte si e' cotta la Luna.
  static int luneCotte = 0;
}

/// Un corpo del sistema solare pronto da posare: dove, quanto grande, di che
/// colore. Riscritto a ogni fotogramma, mai rigenerato.
class CorpoDaPosare {
  double x = 0, y = 0, raggio = 0, luce = 0;
  bool visibile = false;
  Color colore = const Color(0xFFFFFFFF);
  TextPainter? nome;
}

/// Una scritta cotta una volta e posata dove serve.
class ScrittaDaPosare {
  ScrittaDaPosare(this.testo);
  final TextPainter testo;
  double x = 0, y = 0, luce = 0;
}

/// Tutto cio' che il pittore posa in un fotogramma, scritto dalla schermata.
class FotogrammaDelCielo {
  final List<CorpoDaPosare> corpi = [
    for (var i = 0; i < 7; i++) CorpoDaPosare()
  ];

  /// Falso mentre il ritorno parla al centro: i nomi dei corpi tacciono.
  bool nomiDeiCorpi = true;

  /// La Luna cotta (vedi `LunaCotta` nella schermata), il suo centro e il
  /// lato a schermo.
  ui.Image? luna;
  double lunaX = 0, lunaY = 0, lunaLato = 0, lunaLuce = 0;

  /// I veli, coi loro spostamenti di parallasse.
  final List<VeloDiCostellazione> veli = [];
  double veloDx = 0, veloDy = 0;
  final Map<VeloDiCostellazione, double> presenza = {};

  /// La foschia della profondita' di campo, in cache, e dove posarla.
  ui.Image? foschia;

  /// Le linee delle figure (ordine FH parte 3), coi loro buffer.
  LineeInScena? linee;

  /// L'orizzonte che si attraversa (ordine FH parte 7).
  OrizzonteInScena? orizzonte;

  /// Quanto si vede la terra: 1, e nella corsa della Macchina del tempo il
  /// venti per cento (voce F4).
  double terraDiScena = 1;

  /// La Via Lattea, sotto tutto (ordine FH parte 9).
  ViaLatteaInScena? viaLattea;

  /// I cinque oggetti del cielo profondo (ordine FH parte 10).
  CieloProfondoInScena? profondo;

  /// Le stelle cadenti (ordine FH parte 12).
  MeteoreInScena? meteore;

  /// L'eclittica col suo nome (ordine FH parte 13): niente se spenta.
  EclitticaInScena? eclittica;
  TextPainter? scrittaDellEclittica;

  /// Se il nome del filo parla: solo nei secondi dopo che la persona ha
  /// acceso l'eclittica dal menu ([kDurataDelNomeDellEclittica]).
  bool nomeDellEclittica = false;
  double foschiaX = 0, foschiaY = 0, foschiaLuce = 0;

  /// I quattro punti cardinali e le altre scritte.
  final List<ScrittaDaPosare> scritte = [];

  /// L'anello attorno all'oggetto scelto.
  bool anello = false;
  double anelloX = 0, anelloY = 0, anelloR = 0;
}

class PittoreDelCielo extends CustomPainter {
  PittoreDelCielo({
    required this.scena,
    required this.sprite,
    required this.fotogramma,
    required Listenable battito,
  }) : super(repaint: battito);

  final ScenaDelCielo scena;
  final ui.Image sprite;
  final FotogrammaDelCielo fotogramma;

  // I pennelli nascono col pittore e si riusano: a ogni fotogramma cambia
  // solo il loro colore.
  final Paint _fondo = Paint()..color = kFondoDelCielo;
  final Paint _stelle = Paint()..filterQuality = FilterQuality.low;
  final Paint _corpo = Paint()..filterQuality = FilterQuality.low;
  final Paint _immagine = Paint()..filterQuality = FilterQuality.medium;
  final Paint _velo = Paint()
    ..blendMode = BlendMode.screen
    ..filterQuality = FilterQuality.medium;
  final Paint _anello = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2;

  static const Rect _rettangoloDelloSprite =
      Rect.fromLTWH(0, 0, kLatoDelloSprite, kLatoDelloSprite);

  /// Quante chiamate di disegno delle stelle ha fatto l'ultimo fotogramma:
  /// la misura che la voce 2.1 pretende (una).
  static int chiamateDelleStelleAllUltimoFotogramma = 0;

  /// Quante chiamate di disegno delle linee: una (voce 3.2 FH).
  static int chiamateDelleLineeAllUltimoFotogramma = 0;

  final Paint _linee = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final f = fotogramma;
    canvas.drawRect(Offset.zero & size, _fondo);

    // LA VIA LATTEA (ordine FH parte 9): prima delle stelle, come fondo, in
    // composizione luminosa a 0,55. Il colore dei vertici moltiplica la
    // tessitura e spegne il taglio dell'asset a 45 gradi dal piano.
    final via = f.viaLattea;
    if (via != null && via.proiettati > 0) {
      canvas.drawVertices(
        ui.Vertices.raw(
          ui.VertexMode.triangles,
          via.posizioni,
          textureCoordinates: via.tessitura,
          colors: via.colori,
          indices: via.indici,
        ),
        BlendMode.modulate,
        via.pennello,
      );
    }

    // L'ALONE DELL'ARIA (ordine FH voce 11.3): il fondo schiarisce appena
    // verso l'orizzonte, sotto le stelle.
    final aria = f.orizzonte;
    if (aria != null) {
      canvas.drawVertices(
        ui.Vertices.raw(ui.VertexMode.triangles, aria.alonePosizioni,
            colors: aria.aloneColori),
        BlendMode.dst,
        aria.pennelloDellAlone,
      );
    }

    // L'ECLITTICA (ordine FH parte 13): un filo sottile, acceso appena, e il
    // suo nome sopra il punto piu' vicino al centro.
    final eclittica = f.eclittica;
    if (eclittica != null && eclittica.vertici > 0) {
      canvas.drawVertices(
        ui.Vertices.raw(
          ui.VertexMode.triangles,
          Float32List.sublistView(
              eclittica.posizioni, 0, eclittica.vertici * 2),
          colors: Int32List.sublistView(eclittica.colori, 0, eclittica.vertici),
        ),
        BlendMode.dst,
        _linee,
      );
      final nome = f.scrittaDellEclittica;
      if (nome != null && eclittica.scrittaVisibile && f.nomeDellEclittica) {
        nome.paint(
          canvas,
          Offset(eclittica.scrittaX - nome.width / 2,
              eclittica.scrittaY - nome.height - 6),
        );
      }
    }

    // LE LINEE DELLE FIGURE: una chiamata sola, sotto le stelle.
    final linee = f.linee;
    chiamateDelleLineeAllUltimoFotogramma = 0;
    if (linee != null && linee.vertici > 0) {
      canvas.drawVertices(
        ui.Vertices.raw(
          ui.VertexMode.triangles,
          Float32List.sublistView(linee.posizioni, 0, linee.vertici * 2),
          colors: Int32List.sublistView(linee.colori, 0, linee.vertici),
        ),
        BlendMode.dst,
        _linee,
      );
      chiamateDelleLineeAllUltimoFotogramma = 1;
    }

    // IL CIELO PROFONDO (ordine FH parte 10): cinque immagini in
    // composizione luminosa a 0,85, alla loro larghezza vera.
    final profondo = f.profondo;
    if (profondo != null) {
      for (var i = 0; i < profondo.immagini.length; i++) {
        if (profondo.visibile[i] == 0) continue;
        final img = profondo.immagini[i];
        canvas.drawImageRect(
          img,
          Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
          Rect.fromCenter(
            center: Offset(profondo.x[i], profondo.y[i]),
            width: profondo.lato[i],
            height: profondo.lato[i],
          ),
          profondo.pennello,
        );
      }
    }

    // LE STELLE: una chiamata sola.
    final n = scena.quante;
    chiamateDelleStelleAllUltimoFotogramma = 0;
    if (n > 0) {
      canvas.drawRawAtlas(
        sprite,
        Float32List.sublistView(scena.trasformazioni, 0, n * 4),
        Float32List.sublistView(scena.rettangoli, 0, n * 4),
        Int32List.sublistView(scena.colori, 0, n),
        BlendMode.modulate,
        null,
        _stelle,
      );
      chiamateDelleStelleAllUltimoFotogramma = 1;
    }

    // LA PROFONDITA' DI CAMPO: la foschia cotta, che si sposta col cielo.
    final foschia = f.foschia;
    if (foschia != null && f.foschiaLuce > 0) {
      _immagine.color = Color.fromRGBO(255, 255, 255, f.foschiaLuce);
      canvas.drawImage(foschia, Offset(f.foschiaX, f.foschiaY), _immagine);
    }

    // I CORPI: Sole e pianeti con lo stesso sprite, colorato.
    for (final c in f.corpi) {
      if (!c.visibile || c.luce <= 0) continue;
      _corpo.colorFilter = null;
      _corpo.color = c.colore.withValues(alpha: c.luce);
      canvas.drawImageRect(
        sprite,
        _rettangoloDelloSprite,
        Rect.fromCircle(center: Offset(c.x, c.y), radius: c.raggio),
        _corpo,
      );
      if (f.nomiDeiCorpi) {
        c.nome?.paint(
            canvas, Offset(c.x - c.nome!.width / 2, c.y + c.raggio * 0.6 + 4));
      }
    }

    // I VELI: l'alone al 40 per cento, poi l'immagine, in modalita' luminosa.
    for (final v in f.veli) {
      final posa = v.posa;
      if (posa == null || v.luce <= 0) continue;
      final presenza = f.presenza[v] ?? 1.0;
      final centro = posa.centro.translate(f.veloDx, f.veloDy);
      final w = v.immagine.width * posa.scala;
      final h = v.immagine.height * posa.scala;
      final alone = v.alone;
      if (alone != null) {
        final m = v.margineDellAlone * posa.scala;
        _velo.color = Color.fromRGBO(
            255, 255, 255, (kMisturaDellAlone * v.luce * presenza).clamp(0, 1));
        canvas.drawImageRect(
          alone,
          Rect.fromLTWH(0, 0, alone.width.toDouble(), alone.height.toDouble()),
          Rect.fromCenter(center: centro, width: w + 2 * m, height: h + 2 * m),
          _velo,
        );
      }
      _velo.color =
          Color.fromRGBO(255, 255, 255, (v.luce * presenza).clamp(0, 1));
      canvas.drawImageRect(
        v.immagine,
        Rect.fromLTWH(
            0, 0, v.immagine.width.toDouble(), v.immagine.height.toDouble()),
        Rect.fromCenter(center: centro, width: w, height: h),
        _velo,
      );
    }

    // LE STELLE CADENTI (ordine FH parte 12): nastri di triangoli, la
    // stessa chiamata delle linee, nessuna sfocatura; sotto la Luna, che resta
    // l'ultima (voce F5 dell'aggiunta).
    final meteore = f.meteore;
    if (meteore != null && meteore.vertici > 0) {
      canvas.drawVertices(
        ui.Vertices.raw(
          ui.VertexMode.triangles,
          Float32List.sublistView(meteore.posizioni, 0, meteore.vertici * 2),
          colors: Int32List.sublistView(meteore.colori, 0, meteore.vertici),
        ),
        BlendMode.dst,
        _linee,
      );
    }

    // LA LUNA, cotta da LunaReale, PER ULTIMA fra gli oggetti del cielo
    // (aggiunta della Macchina del tempo, voce F5): sopra le stelle, le
    // linee, il cielo profondo, i pianeti e i veli.
    final luna = f.luna;
    if (luna != null && f.lunaLuce > 0) {
      _immagine.color = Color.fromRGBO(255, 255, 255, f.lunaLuce);
      canvas.drawImageRect(
        luna,
        Rect.fromLTWH(0, 0, luna.width.toDouble(), luna.height.toDouble()),
        Rect.fromCenter(
            center: Offset(f.lunaX, f.lunaY),
            width: f.lunaLato,
            height: f.lunaLato),
        _immagine,
      );
    }

    // IL TERRENO (ordine FH parte 7): la calotta nera e la sagoma, sopra
    // tutto il cielo, col velo che si apre guardando in basso. Nella corsa
    // della Macchina del tempo e' al venti per cento (voce F4).
    final terra = f.orizzonte;
    if (terra != null && terra.opacita > 0) {
      terra.pennelloDellaCalotta.color =
          Color.fromRGBO(0, 0, 0, f.terraDiScena);
      canvas.drawVertices(
        ui.Vertices.raw(ui.VertexMode.triangles, terra.calottaPosizioni,
            colors: terra.calottaColori),
        BlendMode.dst,
        terra.pennelloDellaCalotta,
      );
      terra.pennelloDellaSagoma.color =
          Color.fromRGBO(255, 255, 255, terra.opacita * f.terraDiScena);
      canvas.drawVertices(
        ui.Vertices.raw(ui.VertexMode.triangles, terra.fasciaPosizioni,
            textureCoordinates: terra.fasciaTessitura),
        BlendMode.srcOver,
        terra.pennelloDellaSagoma,
      );
    }

    // L'ANELLO dell'oggetto scelto.
    if (f.anello) {
      _anello.color = const Color(0xCCF0D77B);
      canvas.drawCircle(Offset(f.anelloX, f.anelloY), f.anelloR, _anello);
    }

    // LE SCRITTE, cotte una volta.
    for (final s in f.scritte) {
      if (s.luce <= 0) continue;
      s.testo.paint(
          canvas, Offset(s.x - s.testo.width / 2, s.y - s.testo.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant PittoreDelCielo old) =>
      old.scena != scena || old.sprite != sprite;
}

/// Lo sprite della stella, preparato UNA volta: un nucleo bianco con
/// l'alone dentro la texture (voce 2.1), che il colore di ogni stella tinge
/// per moltiplicazione. Il gradiente nasce qui, fuori dal fotogramma.
ui.Image preparaLoSpriteDellaStella() {
  final registratore = ui.PictureRecorder();
  final tela = Canvas(registratore);
  const centro = Offset(kLatoDelloSprite / 2, kLatoDelloSprite / 2);
  final alone = Paint()
    ..shader = ui.Gradient.radial(
      centro,
      kLatoDelloSprite / 2,
      const [
        Color(0xFFFFFFFF),
        Color(0xF0FFFFFF),
        Color(0x55FFFFFF),
        Color(0x14FFFFFF),
        Color(0x00FFFFFF),
      ],
      const [0.0, 0.07, 0.16, 0.42, 1.0],
    );
  tela.drawCircle(centro, kLatoDelloSprite / 2, alone);
  return registratore
      .endRecording()
      .toImageSync(kLatoDelloSprite.toInt(), kLatoDelloSprite.toInt());
}
