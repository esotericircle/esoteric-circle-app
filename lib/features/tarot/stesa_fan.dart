import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/tarot/tarot_card.dart';
import '../../core/tarot/tarot_spread.dart';
import '../../design_system/theme/maestro_palette.dart';
import 'stesa_choreography.dart';
import 'tarot_card_art.dart';

/// L'arco delle carte coperte, sfogliabile su tutto il mazzo.
///
/// Resta un ARCO curvo, non diventa mai una striscia piatta e non ha barre di
/// scorrimento da lista: quelle romperebbero l'incantesimo. Si sfoglia
/// trascinando in orizzontale e si scorre lungo la curva fino a coprire tutte
/// e settantotto le carte, coi dorsi sovrapposti.
///
/// Solo le carte davvero in vista vengono costruite: il resto dell'arco esiste
/// come posizione, non come widget, altrimenti settantotto carte insieme
/// farebbero cadere i fotogrammi.
///
/// Quale carta esce non dipende da quale dorso si tocca: il pescaggio resta
/// quello deterministico del seme, e il dorso e' identico su tutte.
class StesaFan extends StatefulWidget {
  const StesaFan({
    super.key,
    required this.palette,
    required this.taken,
    required this.onPick,
    required this.scene,
    required this.ingresso,
    required this.respiro,
    required this.taglio,
    required this.mescolamento,
    required this.taglioIndice,
    this.reduceMotion = false,
    this.carte = 78,
  });

  final MaestroPalette palette;

  /// Gli indici gia' pescati, che restano al loro posto smorzati.
  final Set<int> taken;

  final ValueChanged<int> onPick;

  final StesaScene scene;

  /// Le quattro fasi della coreografia, ognuna da 0 a 1.
  final double ingresso;
  final double respiro;
  final double taglio;
  final double mescolamento;

  /// Dove il mazzo e' stato tagliato.
  final int taglioIndice;

  final bool reduceMotion;

  /// Quante carte compongono l'arco: tutto il mazzo, settantotto.
  final int carte;

  /// Quante carte si vedono per volta nella finestra dell'arco.
  ///
  /// L'arco ne mostra una manciata alla volta, sovrapposte: sfogliando si
  /// scorre lungo la curva fino a passarle tutte.
  static const int inVista = 11;

  /// Di quanti indici extra si costruisce oltre la finestra, per non far
  /// comparire le carte di colpo ai bordi.
  static const int margine = 2;

  /// La curva dell'arco: quanto si alza la carta a distanza [scarto] dal
  /// centro, da -1 a 1.
  static double arcoDi(double scarto) => -math.pow(scarto, 2).toDouble() * 30;

  /// L'inclinazione della carta a distanza [scarto] dal centro.
  static double inclinazioneDi(double scarto) => scarto * 0.30;

  /// Quali indici costruire, dato il centro corrente della finestra.
  ///
  /// Ritorna solo la fetta in vista piu' un margine: e' questo che tiene il
  /// costo costante anche con settantotto carte.
  static List<int> indiciVisibili(double centro, int totale) {
    const meta = inVista ~/ 2 + margine;
    final da = math.max(0, centro.round() - meta);
    final a = math.min(totale - 1, centro.round() + meta);
    return [for (var i = da; i <= a; i++) i];
  }

  @override
  State<StesaFan> createState() => _StesaFanState();
}

class _StesaFanState extends State<StesaFan> {
  /// Il centro della finestra, in indici di carta. Si muove trascinando.
  late double _centro = (widget.carte - 1) / 2;

  double _dragStart = 0;
  double _centroStart = 0;

  /// QUANDO IL TAGLIO COMINCIA, L'ARCO GUARDA DOVE SI TAGLIA.
  ///
  /// **Senza questo la divisione poteva restare fuori schermo.** L'arco monta
  /// una finestra di carte attorno al suo centro, e il centro lo muove il dito:
  /// chi aveva sfogliato fino al fondo e poi tagliava vedeva tutte le carte
  /// montate dalla stessa parte del taglio, quindi un blocco unico che si
  /// spostava invece di due meta' che si separano. Il punto del taglio sta
  /// vicino alla meta' del mazzo, e all'inizio del gesto l'arco ci torna.
  @override
  void didUpdateWidget(StesaFan vecchio) {
    super.didUpdateWidget(vecchio);
    if (vecchio.taglio == 0 && widget.taglio > 0) {
      _centro = widget.taglioIndice.clamp(0, widget.carte - 1).toDouble();
    }
  }

  /// Quanto scorre l'arco per ogni punto trascinato.
  static const double _sensibilita = 0.028;

  void _onDragStart(DragStartDetails d) {
    _dragStart = d.globalPosition.dx;
    _centroStart = _centro;
  }

  void _onDragUpdate(DragUpdateDetails d) {
    final delta = d.globalPosition.dx - _dragStart;
    setState(() {
      _centro = (_centroStart - delta * _sensibilita * StesaFan.inVista)
          .clamp(0.0, (widget.carte - 1).toDouble());
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final cardW = math.min(78.0, w / 4.6);
        final cardH = cardW / TarotFrame.aspect;
        // Il passo fra due dorsi: si sovrappongono lungo la curva.
        final passo = (w - cardW) / (StesaFan.inVista - 1);
        final altezza = cardH + 34;

        final indici = StesaFan.indiciVisibili(_centro, widget.carte);

        return GestureDetector(
          onHorizontalDragStart:
              widget.scene.accettaGesti ? _onDragStart : null,
          onHorizontalDragUpdate:
              widget.scene.accettaGesti ? _onDragUpdate : null,
          behavior: HitTestBehavior.opaque,
          child: Column(
            key: const Key('stesa_fan'),
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: altezza,
                child: ClipRect(
                  child: Stack(
                    clipBehavior: Clip.none,
                    // L'ORDINE DI DISEGNO NON E' SEMPRE QUELLO DEL MAZZO.
                    //
                    // Ordine P voce 05: quando le due meta' si ricompongono, la
                    // meta' di sotto deve passare SOPRA, altrimenti il gesto si
                    // vede ma non si capisce che ha cambiato l'ordine. Chi sta
                    // davanti lo dice `TaglioPose.quotaDi`, e fuori dal taglio
                    // la quota e' pari per tutti, quindi l'ordine resta quello
                    // naturale del ventaglio.
                    children: _inOrdineDiQuota(indici)
                        .map((i) => _carta(
                              indice: i,
                              w: w,
                              cardW: cardW,
                              passo: passo,
                            ))
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // L'accenno di posizione: discreto e a tema, non una barra di
              // scorrimento da lista.
              _SegnoDiPosizione(
                centro: _centro,
                totale: widget.carte,
                palette: widget.palette,
              ),
            ],
          ),
        );
      },
    );
  }

  /// Gli indici riordinati per quota: quota bassa prima, cioe' sotto.
  ///
  /// Ordinamento STABILE, cosi' a quota pari l'ordine resta quello del mazzo e
  /// il ventaglio a riposo non cambia aspetto.
  List<int> _inOrdineDiQuota(List<int> indici) {
    final quota = <int, double>{
      for (final i in indici)
        i: TaglioPose.quotaDi(
            index: i, taglioA: widget.taglioIndice, t: widget.taglio),
    };
    if (quota.values.toSet().length <= 1) return indici;
    final ordinati = List<int>.of(indici);
    ordinati.sort((a, b) {
      final scarto = quota[a]!.compareTo(quota[b]!);
      return scarto != 0 ? scarto : a.compareTo(b);
    });
    return ordinati;
  }

  Widget _carta({
    required int indice,
    required double w,
    required double cardW,
    required double passo,
  }) {
    // La distanza dal centro della finestra, in carte.
    final delta = indice - _centro;
    final scarto = (delta / (StesaFan.inVista / 2)).clamp(-1.6, 1.6);

    var offset = Offset(
      w / 2 - cardW / 2 + delta * passo,
      StesaFan.arcoDi(scarto) + 26,
    );
    var scala = 1.0 - scarto.abs() * 0.06;
    var opacita = (1.2 - scarto.abs() * 0.55).clamp(0.0, 1.0);
    var angolo = StesaFan.inclinazioneDi(scarto);

    if (!widget.reduceMotion) {
      // L'ingresso a spirale, il respiro, il taglio e il vortice valgono tutti
      // sull'arco sfogliabile, esattamente come prima.
      if (widget.ingresso < 1) {
        final posa = SpiralPose.of(
          index: indice % TarotSpread.fanSize,
          count: TarotSpread.fanSize,
          t: widget.ingresso,
          centro: const Offset(0, -180),
        );
        offset += posa.offset;
        scala *= posa.scale;
        opacita *= posa.opacity;
        angolo += posa.angle;
      } else {
        final battito = math.sin(widget.respiro * 2 * math.pi);
        scala *= 1 + 0.012 * battito;
        opacita *= 0.94 + 0.06 * ((battito + 1) / 2);
      }
      // LA SCENA RACCONTA IL GESTO, ordine H voce 5: il ventaglio si
      // ricompone in mazzo, il mazzo si mescola (o si taglia in due e si
      // ricompone), le carte si ristendono. Le pose sono ASSOLUTE: per
      // chiudere il ventaglio bisogna annullare lo sventagliamento, quindi
      // decidono loro dove sta la carta, non un ritocco sopra la sede.
    }

    // IL TAGLIO E IL MESCOLAMENTO VALGONO ANCHE CON RIDUCI MOVIMENTO.
    //
    // **Ordine P voce 05.** Prima stavano dentro il ramo del moto concesso,
    // quindi con Riduci Movimento le quattro fasi del taglio non erano quattro
    // stati in dissolvenza: erano zero, il gesto sparivo del tutto. Riduci
    // Movimento toglie il moto, non il contenuto. Le due pose restano le stesse:
    // cambia chi muove il tempo, che con Riduci Movimento avanza a scatti sui
    // quattro centri di fase invece di scorrere.
    //
    // Il mazzo si compone DENTRO l'arco del ventaglio, non sotto: a +44 le
    // carte raccolte uscivano dal ritaglio della fascia e il taglio si
    // vedeva come un ventaglio vuoto. Visto sull'anteprima, non dedotto.
    final mazzo = Offset(w / 2 - cardW / 2, StesaFan.arcoDi(0) - 8);
    if (widget.taglio > 0 && widget.taglio < 1) {
      final posa = TaglioPose.of(
        sede: offset,
        mazzo: mazzo,
        index: indice,
        count: widget.carte,
        taglioA: widget.taglioIndice,
        t: widget.taglio,
        angoloSede: angolo,
      );
      offset = posa.offset;
      angolo = posa.angolo;
    }
    if (widget.mescolamento > 0 && widget.mescolamento < 1) {
      final posa = MischiaPose.of(
        sede: offset,
        mazzo: mazzo,
        index: indice,
        count: widget.carte,
        t: widget.mescolamento,
        angoloSede: angolo,
      );
      offset = posa.offset;
      angolo = posa.angolo;
    }

    return Positioned(
      left: offset.dx,
      top: offset.dy,
      width: cardW,
      child: Opacity(
        opacity: opacita,
        child: Transform.rotate(
          angle: angolo,
          child: Transform.scale(
            scale: scala,
            child: _FanCard(
              key: Key('stesa_fan_$indice'),
              palette: widget.palette,
              taken: widget.taken.contains(indice),
              attivo: widget.scene.accettaGesti,
              onTap: () => widget.onPick(indice),
            ),
          ),
        ),
      ),
    );
  }
}

/// Dove siamo lungo il mazzo: tre stelle che scorrono, non una barra.
class _SegnoDiPosizione extends StatelessWidget {
  const _SegnoDiPosizione({
    required this.centro,
    required this.totale,
    required this.palette,
  });

  final double centro;
  final int totale;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    final t = totale <= 1 ? 0.0 : (centro / (totale - 1)).clamp(0.0, 1.0);
    return SizedBox(
      key: const Key('stesa_fan_posizione'),
      height: 8,
      width: 90,
      child: CustomPaint(
        painter: _PosizionePainter(t: t, palette: palette),
      ),
    );
  }
}

class _PosizionePainter extends CustomPainter {
  _PosizionePainter({required this.t, required this.palette});

  final double t;
  final MaestroPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    // Il filo che rappresenta il mazzo, appena accennato.
    canvas.drawLine(
      Offset(0, y),
      Offset(size.width, y),
      Paint()
        ..color = palette.gold.withValues(alpha: 0.18)
        ..strokeWidth = 1,
    );
    // La stella che dice dove siamo.
    final x = size.width * t;
    canvas.drawCircle(
      Offset(x, y),
      2.6,
      Paint()..color = palette.goldSoft.withValues(alpha: 0.9),
    );
    canvas.drawCircle(
      Offset(x, y),
      5.5,
      Paint()
        ..color = palette.goldSoft.withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
  }

  @override
  bool shouldRepaint(_PosizionePainter old) => old.t != t;
}

/// Una carta coperta dell'arco, col dorso di Medora.
class _FanCard extends StatelessWidget {
  const _FanCard({
    super.key,
    required this.palette,
    required this.taken,
    required this.attivo,
    required this.onTap,
  });

  final MaestroPalette palette;
  final bool taken;

  /// Fuori dalla scena di riposo l'arco non risponde al tocco.
  final bool attivo;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: taken || !attivo ? null : onTap,
      child: AnimatedOpacity(
        opacity: taken ? 0.2 : 1.0,
        duration: const Duration(milliseconds: 250),
        child: AspectRatio(
          aspectRatio: TarotFrame.aspect,
          child: CardBack(palette: palette),
        ),
      ),
    );
  }
}

/// Il dorso di Medora, identico dritto e capovolto: dal dorso non si capisce
/// mai in che verso uscira' la carta.
class CardBack extends StatelessWidget {
  const CardBack({super.key, required this.palette});

  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: palette.gold.withValues(alpha: 0.55)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Image.asset(
          TarotDeck.dorsoFull,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _DorsoDipinto(palette: palette),
        ),
      ),
    );
  }
}

/// Ripiego dipinto se il dorso mancasse: mai una carta vuota.
class _DorsoDipinto extends StatelessWidget {
  const _DorsoDipinto({required this.palette});

  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _DorsoPainter(palette: palette));
  }
}

class _DorsoPainter extends CustomPainter {
  _DorsoPainter({required this.palette});

  final MaestroPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(r, Paint()..color = palette.surfaceElevated);
    final oro = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = palette.gold.withValues(alpha: 0.5);
    canvas.drawRect(r.deflate(4), oro);
    canvas.drawCircle(r.center, size.shortestSide * 0.22, oro);
  }

  @override
  bool shouldRepaint(_DorsoPainter old) => old.palette != palette;
}
