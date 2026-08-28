import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/synastry/cielo_della_sinastria.dart';
import '../../core/synastry/tempi_della_chiamata.dart';
import '../../core/synastry/vip_catalog.dart';
import '../../design_system/components/natal_wheel.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'dart:async';
import '../sigilli/celebrazione.dart';
import '../sigilli/regia_del_cammino.dart';

/// I MOMENTI DELLA CHIAMATA, nell'ordine in cui accadono.
///
/// **Sono un dato e non una successione di `if`**, perche' il vincolo V2
/// pretende che con Riduci Movimento ogni momento RESTI, fermo e dichiarato,
/// e nessuna fase si salti in silenzio. Un elenco si puo' percorrere tutto
/// anche senza animazioni; una catena di condizioni no.
enum MomentoDellaChiamata {
  /// Il ritratto sale al centro e il resto sprofonda.
  laChiamata,

  /// La sua ruota si disegna, tratto per tratto.
  laSuaRuota,

  /// Dal basso sale la tua.
  laTuaRuota,

  /// Le due si avvicinano e si compenetrano, ruotando in senso opposto.
  laSovrapposizione,

  /// Gli aspetti si accendono, uno alla volta, dal piu' stretto al piu' largo.
  gliAspetti,
}

/// LA CHIAMATA E LA SOVRAPPOSIZIONE. Ordine BO voce 06.
///
/// **E' il cuore immersivo, e insieme la dimostrazione visiva che il calcolo e'
/// vero.** Il fondatore ha aperto la revisione dicendo "questa funzionalita'
/// che dovrebbe essere quella piu' virale non mi convince: prima di tutto per
/// le animazioni che non ci sono". Qui il tocco su un VIP smette di essere un
/// cambio di schermata e diventa una scena: il suo ritratto sale, attorno a lui
/// si disegna la sua ruota natale, dal basso sale la tua, le due si
/// compenetrano ruotando in senso opposto, e **quando due pianeti trovano il
/// loro angolo l'aspetto si accende come un filo di luce fra i due punti, col
/// suo nome**.
///
/// **I fili sono quelli VERI**: arrivano dalla lista che il responso ha gia'
/// calcolato, ordinata dal piu' stretto al piu' largo. Nessun filo puo'
/// comparire senza il suo aspetto, e una prova lo sorveglia: sarebbe la
/// bugia peggiore, un'animazione che dimostra un calcolo che non c'e'.
///
/// **NESSUN VOLTO REALE VIENE ANIMATO**, vincolo V3: il ritratto sale e sta
/// fermo, si muove la LUCE che lo attraversa. E' un vincolo di rispetto e di
/// rischio legale, non una scelta di stile.
class ChiamataDelVip extends StatefulWidget {
  const ChiamataDelVip({
    super.key,
    required this.vip,
    required this.tuo,
    required this.aspetti,
    required this.palette,
    required this.onFinita,
    this.riduciMovimento = false,
    this.primoVip,
    this.nomeTuo,
    this.segnoTuo,
  });

  final Vip vip;
  final CieloDiSinastria tuo;

  /// **CHI STA NELL'ALTRO CERCHIO. Ordine CA voce 03.**
  ///
  /// Parole del fondatore: "quando ci sono 2 VIP dovrebbero comparire le due
  /// carte nei rispettivi cerchi che si fondono tra loro". Prima al centro
  /// saliva UN ritratto solo, quello di [vip], e nel confronto fra due VIP
  /// l'altro non compariva da nessuna parte: si vedevano due ruote e una
  /// faccia. Quando qui c'e' un VIP, la sua carta sta nel cerchio che sale dal
  /// basso; quando e' nullo, in quel cerchio c'e' la carta della persona, col
  /// suo nome e il suo segno.
  final Vip? primoVip;

  /// Il nome e il segno della persona, per la carta dell'altro cerchio quando
  /// il primo posto non e' di un VIP.
  final String? nomeTuo;
  final String? segnoTuo;

  /// Gli aspetti VERI, gia' ordinati dal piu' stretto al piu' largo.
  final List<AspettoDiSinastria> aspetti;

  final MaestroPalette palette;

  /// Si chiama quando la scena e' finita, o quando un tocco la salta.
  final VoidCallback onFinita;

  final bool riduciMovimento;

  /// Quanti fili si accendono per questa lista di aspetti.
  static int filiPer(List<AspettoDiSinastria> aspetti) =>
      aspetti.length < TempiDellaChiamata.aspettiAccesi
          ? aspetti.length
          : TempiDellaChiamata.aspettiAccesi;

  @override
  State<ChiamataDelVip> createState() => ChiamataDelVipState();
}

class ChiamataDelVipState extends State<ChiamataDelVip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scena;
  late final int _fili = ChiamataDelVip.filiPer(widget.aspetti);
  late final Duration _durata = widget.riduciMovimento
      ? TempiDellaChiamata.interaFerma(quantiAspetti: _fili)
      : TempiDellaChiamata.intera(quantiAspetti: _fili);
  bool _saltata = false;

  @override
  void initState() {
    super.initState();
    // **LA FESTA ASPETTA CHE LA CHIAMATA FINISCA, ordine BU voce 03.** E' la
    // riflessione della Sinastria: finche' i fili si accendono, nessuna festa
    // ci si dipinge sopra. La domanda che la tiene viva e' la scena stessa.
    RiflessioniInCorso.entra(
        () => mounted && !_saltata && _scena.status == AnimationStatus.forward);
    _scena = AnimationController(vsync: this, duration: _durata)
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed && !_saltata) {
          widget.onFinita();
          _laScenaELibera();
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _scena.dispose();
    super.dispose();
  }

  /// **IL TOCCO SALTA TUTTO E PORTA AL RISULTATO**, vincolo V1. Chi guarda la
  /// prima volta resta a bocca aperta, chi ne fa dieci di seguito non viene
  /// punito.
  void salta() {
    if (_saltata) return;
    _saltata = true;
    _scena.stop();
    widget.onFinita();
    _laScenaELibera();
  }

  /// La festa che ha aspettato la chiamata riparte adesso.
  void _laScenaELibera() {
    if (!mounted) return;
    unawaited(RegiaDelCammino.svuotaLaCoda(context, appenaChiusaUna: true));
  }

  /// I confini dei momenti, in frazione della scena intera.
  Map<MomentoDellaChiamata, ({double da, double a})> get _confini {
    final passi = widget.riduciMovimento
        ? [
            TempiDellaChiamata.passoFermo,
            TempiDellaChiamata.passoFermo,
            TempiDellaChiamata.passoFermo,
            TempiDellaChiamata.passoFermo,
            TempiDellaChiamata.passoFermo * _fili,
          ]
        : [
            TempiDellaChiamata.laChiamata,
            TempiDellaChiamata.laSuaRuota,
            TempiDellaChiamata.laTuaRuota,
            TempiDellaChiamata.laSovrapposizione,
            TempiDellaChiamata.unAspetto * _fili,
          ];
    final tutto = _durata.inMilliseconds.toDouble();
    final mappa = <MomentoDellaChiamata, ({double da, double a})>{};
    var scorso = 0.0;
    for (var i = 0; i < MomentoDellaChiamata.values.length; i++) {
      final quanto = passi[i].inMilliseconds / (tutto == 0 ? 1 : tutto);
      mappa[MomentoDellaChiamata.values[i]] =
          (da: scorso, a: scorso + quanto);
      scorso += quanto;
    }
    return mappa;
  }

  /// Quanto e' avanzato un momento, da 0 a 1.
  double _quanto(MomentoDellaChiamata m, double t) {
    final c = _confini[m]!;
    if (t <= c.da) return 0;
    if (t >= c.a) return 1;
    return (t - c.da) / (c.a - c.da);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('sinastria_chiamata'),
      behavior: HitTestBehavior.opaque,
      onTap: salta,
      child: AnimatedBuilder(
        animation: _scena,
        builder: (context, _) {
          final t = _scena.value;
          return LayoutBuilder(
            builder: (context, vincoli) => _scenaA(t, vincoli.biggest),
          );
        },
      ),
    );
  }

  Widget _scenaA(double t, Size spazio) {
    final palette = widget.palette;
    final larga = math.min(spazio.width, spazio.height) * 0.62;
    final centro = Offset(spazio.width / 2, spazio.height * 0.44);

    final chiamata = _quanto(MomentoDellaChiamata.laChiamata, t);
    final suaRuota = _quanto(MomentoDellaChiamata.laSuaRuota, t);
    final tuaRuota = _quanto(MomentoDellaChiamata.laTuaRuota, t);
    final sovrapposizione = _quanto(MomentoDellaChiamata.laSovrapposizione, t);
    final aspetti = _quanto(MomentoDellaChiamata.gliAspetti, t);

    // **LE DUE RUOTE RUOTANO IN SENSO OPPOSTO** mentre si compenetrano: e' il
    // gesto che dice che sono due cieli distinti che si stanno cercando, non
    // una figura sola che gira.
    final giro = widget.riduciMovimento ? 0.0 : sovrapposizione * 0.18;
    // La tua sale dal basso e arriva a sovrapporsi.
    final salita = (1 - tuaRuota) * spazio.height * 0.30;
    final avvicinamento = (1 - sovrapposizione) * larga * 0.34;

    return Stack(
      alignment: Alignment.center,
      children: [
        // LA SUA RUOTA, che si disegna attorno al ritratto.
        if (suaRuota > 0)
          Positioned(
            left: centro.dx - larga / 2,
            top: centro.dy - larga / 2 - avvicinamento * 0.5,
            child: Transform.rotate(
              angle: -giro,
              child: SizedBox(
                key: const Key('sinastria_ruota_vip'),
                width: larga,
                height: larga,
                child: NatalWheel(
                  chart: CieloDiSinastria.perVip(widget.vip).comeCarta,
                  size: larga,
                  avanzamento: suaRuota,
                ),
              ),
            ),
          ),
        // LA TUA, che sale dal basso e si compenetra.
        if (tuaRuota > 0)
          Positioned(
            left: centro.dx - larga / 2,
            top: centro.dy - larga / 2 + salita + avvicinamento * 0.5,
            child: Transform.rotate(
              angle: giro,
              child: SizedBox(
                key: const Key('sinastria_ruota_tua'),
                width: larga,
                height: larga,
                child: NatalWheel(
                  chart: widget.tuo.comeCarta,
                  size: larga,
                  avanzamento: tuaRuota,
                ),
              ),
            ),
          ),
        // **DUE CARTE, UNA PER CERCHIO. Ordine CA voce 03.**
        //
        // La sua sta nel cerchio di sopra, che e' il suo; l'altra nel cerchio
        // che sale dal basso. Seguono i due cerchi mentre si avvicinano,
        // perche' e' questo che il fondatore ha chiesto: "le due carte nei
        // rispettivi cerchi che si fondono tra loro". Prima ne saliva una
        // sola, al centro, e nel confronto fra due VIP l'altro non c'era.
        Positioned(
          left: centro.dx - larga * 0.20,
          top: centro.dy -
              larga * 0.26 -
              chiamata * 8 -
              avvicinamento * 0.5 -
              larga * 0.12,
          child: Opacity(
            opacity: chiamata,
            child: _RitrattoNellaLuce(
              chiave: const Key('sinastria_ritratto_chiamato'),
              vip: widget.vip,
              lato: larga * 0.40,
              palette: palette,
              luce: widget.riduciMovimento ? 0.5 : t,
            ),
          ),
        ),
        if (tuaRuota > 0)
          Positioned(
            left: centro.dx - larga * 0.20,
            top: centro.dy -
                larga * 0.26 +
                salita +
                avvicinamento * 0.5 +
                larga * 0.12,
            child: Opacity(
              opacity: tuaRuota,
              child: _RitrattoNellaLuce(
                chiave: const Key('sinastria_ritratto_tuo'),
                vip: widget.primoVip,
                nome: widget.nomeTuo,
                segno: widget.segnoTuo,
                lato: larga * 0.40,
                palette: palette,
                luce: widget.riduciMovimento ? 0.5 : t,
              ),
            ),
          ),
        // I FILI DEGLI ASPETTI, uno alla volta, col loro nome.
        if (aspetti > 0 && _fili > 0)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                key: const Key('sinastria_fili'),
                painter: FiliDegliAspetti(
                  aspetti: widget.aspetti.take(_fili).toList(),
                  avanzamento: aspetti,
                  centro: centro,
                  raggio: larga * 0.42,
                  colore: palette.goldSoft,
                ),
              ),
            ),
          ),
        // **E SE DI ASPETTI NON CE N'E' NESSUNO, non si nomina niente.**
        // Trovato allungando i tempi (ordine CA voce 03): con zero fili il
        // momento degli aspetti dura zero, quindi all'ultimo fotogramma
        // risultava compiuto, e `clamp(0, -1)` faceva cadere la scena con un
        // ArgumentError. Due cieli che non si toccano in nessun punto sono un
        // caso vero, non un errore.
        if (aspetti > 0 && _fili > 0) _nomeDellAspetto(aspetti, palette),
      ],
    );
  }

  /// Il nome dell'aspetto acceso in questo istante, in fondo alla scena.
  Widget _nomeDellAspetto(double avanzamento, MaestroPalette palette) {
    final quale = (avanzamento * _fili).floor().clamp(0, _fili - 1);
    final a = widget.aspetti[quale];
    return Positioned(
      bottom: SpacingTokens.xxl,
      left: SpacingTokens.lg,
      right: SpacingTokens.lg,
      child: Text(
        a.titolo,
        key: const Key('sinastria_nome_aspetto'),
        textAlign: TextAlign.center,
        style: TypographyTokens.etichetta()
            .copyWith(color: palette.goldSoft, letterSpacing: 1.6),
      ),
    );
  }
}

/// Il ritratto che sale, con la luce che gli passa sopra.
///
/// **Il volto non si muove**, vincolo V3: nessuna rotazione, nessuna
/// deformazione, nessuna espressione. Si muove il riflesso, con lo stesso 2.5D
/// dei Maestri.
class _RitrattoNellaLuce extends StatelessWidget {
  const _RitrattoNellaLuce({
    required this.chiave,
    required this.vip,
    required this.lato,
    required this.palette,
    required this.luce,
    this.nome,
    this.segno,
  });

  final Key chiave;

  /// Il volto, quando da questa parte c'e' un VIP. Nullo quando c'e' la
  /// persona: al suo posto si disegnano il segno e il nome, che e' cio' che
  /// l'app sa di lei senza chiederle una foto.
  final Vip? vip;
  final String? nome;
  final String? segno;
  final double lato;
  final MaestroPalette palette;
  final double luce;

  @override
  Widget build(BuildContext context) {
    final v = vip;
    return SizedBox(
      key: chiave,
      width: lato,
      height: lato / 0.78,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (v != null && v.hasImage)
              Image.asset(v.fullPath!,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      Icon(Icons.auto_awesome, color: palette.goldSoft))
            else
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(segno ?? v?.sign.symbol ?? '',
                        style: TypographyTokens.cerimonialeGrande()
                            .copyWith(color: palette.goldSoft)),
                    if ((nome ?? v?.name) != null)
                      Text((nome ?? v!.name).toUpperCase(),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TypographyTokens.etichetta()
                              .copyWith(color: palette.goldSoft)),
                  ],
                ),
              ),
            // LA LUCE che scorre: e' l'unica cosa che si muove sul ritratto.
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(-1 + luce * 2, -1),
                    end: Alignment(luce * 2, 1),
                    colors: [
                      Colors.transparent,
                      palette.goldSoft.withValues(alpha: 0.22),
                      Colors.transparent,
                    ],
                    stops: const [0.35, 0.5, 0.65],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// I FILI DI LUCE FRA I DUE CIELI. Ordine BO voce 06.
///
/// **Un filo per aspetto VERO, e nessuno di piu'.** Il disegno e' un solo
/// tracciato con una sola penna, come il filo fra le carte della stesa: e' la
/// scelta che tiene il costo per fotogramma sotto il budget.
class FiliDegliAspetti extends CustomPainter {
  const FiliDegliAspetti({
    required this.aspetti,
    required this.avanzamento,
    required this.centro,
    required this.raggio,
    required this.colore,
  });

  final List<AspettoDiSinastria> aspetti;

  /// Da 0 a 1 sull'intera sequenza dei fili: ogni filo prende la sua fetta.
  final double avanzamento;

  final Offset centro;
  final double raggio;
  final Color colore;

  /// Dove cade un punto del cielo sul cerchio, per la sua longitudine.
  static Offset puntoDi(double longitudine, Offset centro, double raggio) {
    final a = (180.0 - longitudine) * math.pi / 180;
    return centro + Offset(math.cos(a) * raggio, -math.sin(a) * raggio);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (aspetti.isEmpty) return;
    final penna = Paint()
      ..color = colore
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final tracciato = Path();
    final fetta = 1 / aspetti.length;
    for (var i = 0; i < aspetti.length; i++) {
      final quanto = ((avanzamento - i * fetta) / fetta).clamp(0.0, 1.0);
      if (quanto <= 0) continue;
      final a = aspetti[i];
      // I due punti stanno su due cerchi concentrici, uno per cielo: il tuo
      // dentro, il suo fuori, cosi' il filo attraversa lo spazio fra le due
      // ruote invece di correre lungo un bordo.
      final da = puntoDi(_gradiDi(a.suo, i), centro, raggio);
      final aPunto = puntoDi(_gradiDi(a.tuo, i + 3), centro, raggio * 0.62);
      tracciato.moveTo(da.dx, da.dy);
      tracciato.lineTo(da.dx + (aPunto.dx - da.dx) * quanto,
          da.dy + (aPunto.dy - da.dy) * quanto);
    }
    canvas.drawPath(tracciato, penna);
  }

  /// L'angolo su cui posare il punto. **Non e' la longitudine vera perche' qui
  /// non si sta disegnando una carta**, si sta mostrando un legame: quello che
  /// deve leggersi e' QUANTI fili ci sono e fra quali punti, e i punti sono
  /// distinti fra loro. La carta vera, con le longitudini al grado, e' la
  /// ruota sotto.
  static double _gradiDi(PuntoDelCielo p, int giro) =>
      p.index * 60.0 + giro * 17.0;

  @override
  bool shouldRepaint(FiliDegliAspetti vecchio) =>
      vecchio.avanzamento != avanzamento ||
      vecchio.aspetti.length != aspetti.length;
}
