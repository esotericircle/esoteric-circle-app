import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/maestro_scope.dart';
import '../tokens/color_tokens.dart';
import 'borsellino.dart';
import 'icona_degli_eos.dart';
import '../../core/sensi/catalogo_suoni.dart';
import '../../core/sensi/palette_sensoriale.dart';

/// GLI EOS VOLANO DALLA CELEBRAZIONE AL BORSELLINO. Ordine S voce 07.
///
/// **Perche' non e' un vezzo.** E' il momento in cui la persona capisce che quel
/// premio e' finito da qualche parte, e che quel qualche parte le appartiene.
/// Senza il volo, "+10 Eos" e' una scritta che appare al centro dello schermo e
/// sparisce: nessuno collega quella scritta al numero in barra, e il numero in
/// barra cambia senza che nessuno lo veda cambiare.
///
/// **DOVE ARRIVANO NON SI INDOVINA.** Il segno del borsellino dichiara la
/// propria posizione, e il volo la CHIEDE: scrivere qui l'angolo in alto a
/// destra vorrebbe dire tenere d'accordo per sempre due punti che nessuno
/// confronta, e al primo cambio della barra gli Eos volerebbero in un posto
/// vuoto. Se nessun borsellino e' montato, e succede nelle superfici immersive,
/// il volo non parte affatto: meglio niente che un volo verso il nulla.
class VoloDegliEos {
  const VoloDegliEos._();

  /// QUANTO DURA, ed e' la stessa durata con cui il numero in barra sale
  /// contando: i due si vedono insieme, quindi sono lo stesso tempo, dichiarato
  /// in un punto solo.
  static const Duration durata = Duration(milliseconds: 900);

  /// **DOVE ARRIVANO LE MONETE QUANDO NESSUN BORSELLINO E' MISURABILE**,
  /// contato dal bordo destro e dall'alto. E' il posto in cui il segno del
  /// borsellino vive nella barra: non e' una seconda verita' sulla sua
  /// posizione, e' il ripiego per l'istante in cui la barra non e' ancora
  /// montata.
  static const Offset angoloDelBorsellino = Offset(48, 40);

  /// QUANTE SCINTILLE PARTONO, al massimo.
  ///
  /// Non una per Eos: un traguardo grande ne porta trenta, e trenta scintille
  /// sono una nuvola. Sei si contano a occhio e restano leggibili.
  static const int quanteAlMassimo = 6;

  /// Fa volare [quanti] Eos dal centro dello schermo al borsellino.
  ///
  /// Torna vero se il volo e' partito. Non attende la fine: la festa e il resto
  /// del cammino non devono mai aspettare un'animazione.
  static bool lancia(BuildContext context, {required int quanti}) {
    if (quanti <= 0) return false;
    // **L'ANNUNCIO PRIMA DI TUTTO, e prima di ogni ripiego.** E' il numero che
    // sale contando, cioe' la notizia; il volo e' il modo in cui si vede
    // arrivare. Con Riduci Movimento non vola niente e la notizia resta, che e'
    // esattamente cio' che l'ordine chiede.
    ArrivoDegliEos.annuncia(quanti);
    // **IL SUONO DELLE MONETE ESCE DA QUI, e da nessun altro posto.**
    // Ordine CO voce 19, 3 settembre 2026.
    //
    // Prima lo emetteva la celebrazione, alla chiusura della scena, e il volo
    // partiva da un'altra riga, in un altro file, sotto un'altra condizione:
    // **il suono usciva anche quando non volava nessuna moneta**, cioe' un
    // tintinnio senza niente da accompagnare. Due decisioni sulla stessa cosa
    // in due posti sono la famiglia di difetti piu' numerosa di questo
    // progetto, e qui aveva la forma piu' facile da sentire.
    //
    // **Sta sopra il ripiego di Riduci Movimento, e insieme all'annuncio.**
    // Chi ha chiesto di ridurre il movimento ha chiesto che non si muova
    // niente, non che non si senta niente: il numero che sale e il suono
    // restano, ed e' la stessa regola gia' scritta per l'annuncio due righe
    // sopra. Il suono e' la notizia, il volo e' il modo di vederla arrivare.
    unawaited(PaletteSensoriale.suona(context, SuonoDelCerchio.eos));
    if (MediaQuery.maybeOf(context)?.disableAnimations == true) return false;
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return false;
    // **UN VOLO SENZA BORSELLINO A SCHERMO NON SI FERMA PIU'.**
    // Ordine CQ, rilancio del 3 settembre 2026.
    //
    // **Il fatto, parole del fondatore:** *"manca l'animazione dei coins che
    // vanno verso il borsellino."*
    //
    // Qui c'era scritto **meglio niente che un volo verso il nulla**, e per
    // la scena immersiva era giusto. Ma il caso vero non e' quello: e' la
    // festa che si chiude, la barra che sta tornando, e il borsellino che in
    // quell'istante non ha ancora un riquadro misurabile. **Il suono usciva
    // e le monete no**, cioe' esattamente il difetto che l'ordine CO voce 19
    // aveva chiuso nel verso opposto, tornato dall'altro lato.
    //
    // Il ripiego non e' "il nulla": e' **l'angolo in alto a destra**, che e'
    // dove il borsellino vive in ogni schermata che ce l'ha. Le monete
    // arrivano dove la persona guardera' fra un istante, invece di non
    // partire affatto.
    final scatola = DoveStaIlBorsellino.scatola();
    // **LA PARTENZA E' IL CENTRO DELLA SUPERFICIE SU CUI SI VOLA, e non quello
    // che dice MediaQuery.** Sono due cose diverse: l'Overlay ha le sue
    // coordinate, e la misura dello schermo puo' anche essere vuota, come in una
    // prova che avvolge l'albero in un MediaQuery suo. Con la misura a zero le
    // scintille partivano dall'angolo in alto a sinistra, e la prova che
    // controlla la partenza lo ha visto: cinquecento punti fuori posto.
    final tela = overlay.context.findRenderObject();
    final schermo = tela is RenderBox && tela.hasSize
        ? tela.size
        : MediaQuery.sizeOf(context);
    if (schermo.isEmpty) return false;
    final partenza = Offset(schermo.width / 2, schermo.height / 2);
    final arrivo = scatola?.center ??
        Offset(schermo.width - angoloDelBorsellino.dx, angoloDelBorsellino.dy);

    late OverlayEntry voce;
    voce = OverlayEntry(
      builder: (_) => _ScintilleInVolo(
        quanti: math.min(quanti, quanteAlMassimo),
        partenza: partenza,
        arrivo: arrivo,
        // **LA PALETTE SI CHIEDE DALLA PORTA TOLLERANTE.** Ordine CQ,
        // rilancio del 3 settembre 2026. Finche' il volo si fermava dove il
        // borsellino non era montato, qui ci si arrivava solo dentro una
        // schermata vestita. Adesso il volo parte anche col ripiego, e ci si
        // arriva anche da una sovrimpressione senza scope: un assert dentro
        // il rito di qualcun altro farebbe cadere la schermata sotto per una
        // moneta.
        colore: MaestroScope.forse(context)?.goldSoft ?? ColorTokens.gold,
        finito: () {
          if (voce.mounted) voce.remove();
        },
      ),
    );
    overlay.insert(voce);
    return true;
  }
}

class _ScintilleInVolo extends StatefulWidget {
  const _ScintilleInVolo({
    required this.quanti,
    required this.partenza,
    required this.arrivo,
    required this.colore,
    required this.finito,
  });

  final int quanti;
  final Offset partenza;
  final Offset arrivo;
  final Color colore;
  final VoidCallback finito;

  @override
  State<_ScintilleInVolo> createState() => _ScintilleInVoloState();
}

class _ScintilleInVoloState extends State<_ScintilleInVolo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _corsa = AnimationController(
    vsync: this,
    duration: VoloDegliEos.durata,
  );

  @override
  void initState() {
    super.initState();
    _corsa.addStatusListener((stato) {
      if (stato == AnimationStatus.completed) widget.finito();
    });
    _corsa.forward();
  }

  @override
  void dispose() {
    _corsa.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _corsa,
        builder: (context, _) {
          return Stack(
            children: [
              for (var i = 0; i < widget.quanti; i++) _scintilla(i),
            ],
          );
        },
      ),
    );
  }

  Widget _scintilla(int i) {
    // A SCAGLIONI: partono una dopo l'altra, altrimenti sono un solo punto che
    // si muove e non si capisce che sono piu' Eos.
    final ritardo = i / (widget.quanti * 2);
    final t = ((_corsa.value - ritardo) / (1 - ritardo)).clamp(0.0, 1.0);
    final avanti = Curves.easeInOutCubic.transform(t);
    // **L'ARCO, e non la retta.** Sei punti sulla stessa retta si sovrappongono
    // e sembrano uno: ognuno prende una curva un po' diversa, e insieme fanno
    // un movimento che si legge come "stanno andando la'".
    final scarto = (i.isEven ? 1 : -1) * (18.0 + i * 10);
    final dritto = Offset.lerp(widget.partenza, widget.arrivo, avanti)!;
    final curva = math.sin(avanti * math.pi) * scarto;
    final dove = dritto + Offset(curva, -curva.abs() * 0.6);
    // Si spengono arrivando: l'ultimo fotogramma non deve lasciare una
    // scintilla ferma sopra il numero.
    final opacita = t >= 1 ? 0.0 : (1 - math.pow(t, 3)).toDouble();
    final misura = 18.0 - 6 * avanti;
    return Positioned(
      key: Key('eos_in_volo_$i'),
      left: dove.dx - misura / 2,
      top: dove.dy - misura / 2,
      child: Opacity(
        opacity: opacita.clamp(0.0, 1.0),
        child: IconaDegliEos(misura: misura, colore: widget.colore),
      ),
    );
  }
}
