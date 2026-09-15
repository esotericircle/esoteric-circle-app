import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/rituals/carta_di_nascita_dei_tarocchi.dart';
import '../../core/tarot/tarot_card.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/typography/paragrafi_di_lettura.dart';
import '../tarot/tarot_card_art.dart';

/// **LA RIVELAZIONE DELLA CARTA DI NASCITA, CON LE CARTE VERE.** Ordine DP
/// voce 01, 15 settembre 2026.
///
/// **Qui c'era un rettangolo disegnato in codice**, ordine DC voce 14: un
/// cerchio di ventidue rettangoli blu, e alla fine un rettangolo col numero
/// romano e il nome scritti a mano. Parole del fondatore sulla build 2261:
/// *"la carta rivelata NON E' UNA CARTA CHE HO CREATO IO"*, *"non si vede il
/// dorso dei nostri tarocchi"*, manca *"la complessita' ed eleganza e
/// fluidita' di 78 carte che girano"*. Le settantotto arti c'erano tutte, e il
/// dorso pure: la schermata non ne apriva nessuna.
///
/// **Adesso tutto il mazzo passa davanti e uno solo si ferma.** Le
/// settantotto girano coperte, col dorso vero, in un anello che si vede di
/// scorcio e le sovrappone in profondita'. Intanto la data si somma e si
/// riduce, e l'anello rallenta finche' davanti non resta la carta che il
/// calcolo ha trovato: quella viene avanti e si gira, ed e' il suo artwork
/// vero a piena risoluzione.
///
/// **IL PRINCIPIO DELL'ORDINE DC RESTA.** La carta non e' estratta a caso:
/// **la carta che si ferma e' quella del calcolo**, e i numeri a schermo sono
/// letti da `CartaDiNascitaDeiTarocchi.passiDi`, non ricalcolati qui. Il
/// mazzo che gira non racconta un'estrazione: racconta che le possibilita'
/// erano tutte, e che la data ne ha scelta una.
class RivelazioneCartaDiNascita extends StatefulWidget {
  const RivelazioneCartaDiNascita({
    super.key,
    required this.nascita,
    this.senzaMoto = false,
    this.onFinita,
    this.azione,
    this.visibiliInsieme = RegiaDellaRivelazione.quanteNelMazzo,
  });

  final DateTime nascita;

  /// Con Riduci Movimento il mazzo non gira e la carta non vola: si mostra
  /// l'ultimo momento, col calcolo scritto e la carta gia' girata. **Il metodo
  /// resta leggibile**, che e' cio' che l'ordine DC pretende.
  final bool senzaMoto;

  final VoidCallback? onFinita;

  /// Il pulsante che porta avanti, dentro la colonna come nelle altre
  /// schermate del risveglio. Si accende a rivelazione finita.
  final Widget? azione;

  /// **QUANTE CARTE SI DISEGNANO INSIEME**, e passano sempre tutte e
  /// settantotto. Voce DP.01.3: *"se scende sotto i cinquanta fotogrammi al
  /// secondo, si riduce il numero delle carte visibili contemporaneamente e
  /// non il numero delle carte che passano"*. Si tolgono quelle piu' in
  /// fondo all'anello, che sono le piu' piccole e le piu' coperte.
  final int visibiliInsieme;

  /// **QUANTO DURA IN TUTTO.** Fra i sei e gli otto secondi, ordine DC voce
  /// 14: **mai di piu' perche' e' onboarding**.
  static const Duration quantoDura = Duration(milliseconds: 7500);

  /// **LA RIGA CHE SPIEGA I NUMERI.** Voce DP.01.4: *"Il difetto non e' che
  /// ci siano: e' che nessuno dice cosa sono"*.
  static const String laRiga =
      'La tua data si somma e si riduce. Il numero che resta è la tua carta.';

  /// I sei momenti, con la quota di tempo in cui ognuno finisce.
  static const List<double> fineDelMomento = [
    0.12, // il mazzo gira da solo
    0.22, // le cifre della data compaiono
    0.52, // le cifre si sommano
    0.66, // il totale si riduce
    0.80, // il mazzo rallenta e si ferma sulla sua carta
    1.00, // la carta viene avanti e si gira
  ];

  /// A quale momento si e' alla quota [t] del tempo.
  static int momentoA(double t) {
    for (var i = 0; i < fineDelMomento.length; i++) {
      if (t <= fineDelMomento[i]) return i;
    }
    return fineDelMomento.length - 1;
  }

  @override
  State<RivelazioneCartaDiNascita> createState() =>
      _RivelazioneCartaDiNascitaState();
}

class _RivelazioneCartaDiNascitaState extends State<RivelazioneCartaDiNascita>
    with SingleTickerProviderStateMixin {
  /// **`preserve`, e la ragione.** Col comportamento normale Flutter
  /// accorcia l'animazione quando il sistema chiede meno movimento; qui chi
  /// chiede meno movimento ha gia' la sua strada, [senzaMoto], e l'animazione
  /// che parte e' quella di chi il movimento lo vuole, alla sua durata.
  late final AnimationController _tempo = AnimationController(
    vsync: this,
    duration: RivelazioneCartaDiNascita.quantoDura,
    animationBehavior: AnimationBehavior.preserve,
  );

  late final PassiDellaCarta _passi =
      CartaDiNascitaDeiTarocchi.passiDi(widget.nascita);
  late final TarotCard _carta =
      CartaDiNascitaDeiTarocchi.cartaDi(widget.nascita);
  bool _preparata = false;

  /// **CIO' CHE CAMBIA DI RADO SI RICOSTRUISCE DI RADO.** Ordine DP voce
  /// 01.3: il numero, la riga e il pulsante cambiano poche volte in sette
  /// secondi e mezzo, e ricostruirli a ogni fotogramma costava al telefono
  /// il tempo che l'anello non aveva. Si ricostruiscono quando la chiave
  /// cambia, e la chiave e' un record: si confronta per valore.
  late final ValueNotifier<Object> _chiave = ValueNotifier(_chiaveAdesso());

  Object _chiaveAdesso() {
    final r = _regia();
    return (
      r.numeroAlCentro(),
      r.cifreSommate(),
      r.momento,
      r.quantaRiga(),
      _tempo.value >= 1.0,
    );
  }

  @override
  void initState() {
    super.initState();
    _tempo.addListener(() {
      final adesso = _chiaveAdesso();
      if (adesso != _chiave.value) _chiave.value = adesso;
    });
    _tempo.addStatusListener((s) {
      if (s == AnimationStatus.completed) widget.onFinita?.call();
    });
    if (widget.senzaMoto) {
      _tempo.value = 1.0;
      WidgetsBinding.instance
          .addPostFrameCallback((_) => widget.onFinita?.call());
    } else {
      _tempo.forward();
    }
  }

  /// **LE DUE IMMAGINI SI DECODIFICANO PRIMA DI SERVIRE**: il dorso, che
  /// si disegna settantotto volte dalla stessa decodifica, e l'arte piena
  /// della carta, che altrimenti comparirebbe a meta' del giro della carta.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_preparata) return;
    _preparata = true;
    precacheImage(AssetImage(TarotDeck.dorsoThumb), context);
    precacheImage(AssetImage(_carta.fullPath), context);
  }

  @override
  void dispose() {
    _tempo.dispose();
    _chiave.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xl),
      child: Column(
        children: [
          const SizedBox(height: SpacingTokens.xl),
          Text('La tua Carta di Nascita',
              key: const Key('carta_di_nascita_titolo'),
              textAlign: TextAlign.center,
              style: TypographyTokens.etichetta()
                  .copyWith(color: palette.goldSoft, letterSpacing: 3)),
          const SizedBox(height: SpacingTokens.md),
          ValueListenableBuilder<Object>(
            valueListenable: _chiave,
            builder: (context, _, __) => _IlCalcolo(
              regia: _regia(),
              colore: palette.gold,
              tenue: palette.goldSoft,
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          ValueListenableBuilder<Object>(
            valueListenable: _chiave,
            builder: (context, _, child) => Opacity(
              opacity: _regia().quantaRiga(),
              child: child,
            ),
            child: ParagrafiDiLettura(
              testo: RivelazioneCartaDiNascita.laRiga,
              key: const Key('carta_di_nascita_la_riga'),
              textAlign: TextAlign.center,
              stile: TypographyTokens.lettura()
                  .copyWith(color: palette.goldSoft, height: 1.45),
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          Expanded(
            child: LayoutBuilder(
              builder: (context, vincoli) => _LaScena(
                key: const Key('rivelazione_carta_di_nascita'),
                tempo: _tempo,
                regiaDi: _regia,
                carta: _carta,
                palette: palette,
                misura: vincoli.biggest,
                visibiliInsieme: widget.visibiliInsieme,
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          if (widget.azione != null)
            ValueListenableBuilder<Object>(
              valueListenable: _chiave,
              builder: (context, _, child) {
                final finita = _tempo.value >= 1.0;
                return IgnorePointer(
                  ignoring: !finita,
                  child: AnimatedOpacity(
                    opacity: finita ? 1 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: child,
                  ),
                );
              },
              child: widget.azione,
            ),
          const SizedBox(height: SpacingTokens.lg),
        ],
      ),
    );
  }

  RegiaDellaRivelazione _regia() => RegiaDellaRivelazione(
        passi: _passi,
        carta: _carta,
        t: _tempo.value,
        senzaMoto: widget.senzaMoto,
      );
}

/// **LA REGIA, PURA.** Dove sta ogni carta a ogni istante, quale numero si
/// legge, quando la carta si gira. **Pubblica e senza widget**, cosi' la
/// guardia la interroga istante per istante invece di fidarsi dei pixel.
class RegiaDellaRivelazione {
  RegiaDellaRivelazione({
    required this.passi,
    required this.carta,
    required this.t,
    this.senzaMoto = false,
  });

  /// **I PASSI, LETTI DAL CALCOLO VERO.** Ordine DC voce 14.
  final PassiDellaCarta passi;

  /// La carta che il calcolo restituisce.
  final TarotCard carta;

  /// Il tempo, da 0 a 1.
  final double t;

  final bool senzaMoto;

  /// **TUTTO IL MAZZO**, voce DP.01.2: *"Non un sottoinsieme, non una
  /// dozzina ripetuta"*. Una costante perche' fa da valore di partenza, e la
  /// guardia pretende che sia la lunghezza del mazzo vero.
  static const int quanteNelMazzo = 78;

  /// **QUANTI GIRI FA L'ANELLO PRIMA DI FERMARSI.** Tre: ogni carta passa
  /// davanti tre volte, e l'occhio vede tutto il mazzo scorrere.
  static const double giri = 3;

  /// Dove l'anello si ferma: alla fine del quinto momento.
  static double get fineDelGiro => RivelazioneCartaDiNascita.fineDelMomento[4];

  /// **QUALE CARTA DEL MAZZO E' LA SUA.** Viene dal calcolo, non da una
  /// posizione scelta: e' il pezzo che lega la scena al dato.
  int get indiceDellaSua => TarotDeck.cards.indexOf(carta);

  int get momento => RivelazioneCartaDiNascita.momentoA(t);

  /// Quanto si e' avanti dentro il momento [quale], da 0 a 1.
  double dentroIlMomento(int quale) {
    final da =
        quale == 0 ? 0.0 : RivelazioneCartaDiNascita.fineDelMomento[quale - 1];
    final a = RivelazioneCartaDiNascita.fineDelMomento[quale];
    if (a <= da) return 1;
    return ((t - da) / (a - da)).clamp(0.0, 1.0);
  }

  /// **IL NUMERO CHE SI LEGGE ADESSO**, o nulla quando non ce n'e' ancora
  /// uno. E' la funzione che la guardia interroga: quello che torna di qui e'
  /// esattamente quello che la schermata scrive.
  int? numeroAlCentro() {
    if (senzaMoto) return passi.numero;
    if (momento < 2) return null;
    if (momento == 2) {
      return passi.sommeParziali[cifreSommate() - 1];
    }
    if (momento == 3) {
      if (passi.riduzioni.isEmpty) return passi.totale;
      final quante = (dentroIlMomento(3) * (passi.riduzioni.length + 1))
          .floor()
          .clamp(0, passi.riduzioni.length);
      return quante == 0 ? passi.totale : passi.riduzioni[quante - 1];
    }
    return passi.numero;
  }

  /// Quante cifre della data sono gia' entrate nella somma: da una a tutte
  /// nel terzo momento, tutte dopo, nessuna prima.
  int cifreSommate() {
    if (senzaMoto || momento > 2) return passi.cifre.length;
    if (momento < 2) return 0;
    return (1 + dentroIlMomento(2) * passi.cifre.length)
        .floor()
        .clamp(1, passi.cifre.length);
  }

  /// Quanto si vede la riga che spiega, da 0 a 1: entra con le cifre.
  double quantaRiga() => senzaMoto ? 1.0 : (momento >= 1 ? 1.0 : 0.0);

  /// **L'ANGOLO DELL'ANELLO.** Gira veloce all'inizio e rallenta con una
  /// curva cubica fino a fermarsi, alla fine del quinto momento, con la sua
  /// carta esattamente davanti. Nessuno scatto: la velocita' scende a zero
  /// in modo continuo.
  double angoloDelMazzo() {
    const passo = 2 * math.pi / quanteNelMazzo;
    final fermo = math.pi / 2 - indiceDellaSua * passo;
    if (senzaMoto) return fermo;
    final u = (t / fineDelGiro).clamp(0.0, 1.0);
    final resto = math.pow(1 - u, 3).toDouble();
    return fermo - giri * 2 * math.pi * resto;
  }

  /// L'angolo della carta [i] sull'anello: davanti e' pi greco mezzi.
  double angoloDi(int i) => angoloDelMazzo() + i * 2 * math.pi / quanteNelMazzo;

  /// **LA PROFONDITA' DELLA CARTA [i]**, da meno uno (in fondo) a uno
  /// (davanti).
  double profonditaDi(int i) => math.sin(angoloDi(i));

  /// La carta che adesso sta davanti a tutte.
  int indiceDavanti() {
    var migliore = 0;
    var piu = -2.0;
    for (var i = 0; i < quanteNelMazzo; i++) {
      final p = profonditaDi(i);
      if (p > piu) {
        piu = p;
        migliore = i;
      }
    }
    return migliore;
  }

  /// **LA SUA CARTA SI STACCA DALL'ANELLO** nell'ultimo momento.
  bool get laSuaSiStacca => senzaMoto || momento >= 5;

  /// Quanto la sua carta e' venuta avanti, da 0 a 1.
  double avanzata() => senzaMoto
      ? 1.0
      : (momento < 5
          ? 0.0
          : Curves.easeInOutCubic.transform(dentroIlMomento(5)));

  /// Quanto la sua carta si e' girata, da 0 (coperta) a 1 (scoperta).
  double girata() {
    if (senzaMoto) return 1.0;
    if (momento < 5) return 0.0;
    final q = dentroIlMomento(5);
    return Curves.easeInOut.transform(((q - 0.25) / 0.75).clamp(0.0, 1.0));
  }

  /// Quanto l'anello si spegne dietro la carta che viene avanti.
  double velo() => senzaMoto ? 0.75 : 0.75 * avanzata();
}

/// **IL CALCOLO A SCHERMO**: il numero grande e sotto le cifre della data,
/// che si accendono man mano che entrano nella somma. Il numero romano qui
/// non c'e': sta sulla carta, dove il mazzo lo porta.
class _IlCalcolo extends StatelessWidget {
  const _IlCalcolo({
    required this.regia,
    required this.colore,
    required this.tenue,
  });

  final RegiaDellaRivelazione regia;
  final Color colore;
  final Color tenue;

  @override
  Widget build(BuildContext context) {
    final numero = regia.numeroAlCentro();
    final passi = regia.passi;
    final accese = regia.cifreSommate();
    final riducendo = regia.momento == 3 && passi.riduzioni.isNotEmpty;
    final cifreDelTotale = [
      for (final c in '${passi.totale}'.split('')) int.parse(c)
    ];
    return SizedBox(
      height: 104,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 64,
            child: numero == null
                ? null
                : Text(
                    '$numero',
                    key: const Key('carta_di_nascita_numero'),
                    textAlign: TextAlign.center,
                    style: TypographyTokens.cerimonialeGrande()
                        .copyWith(color: colore, height: 1.1),
                  ),
          ),
          const SizedBox(height: SpacingTokens.xxs),
          if (regia.senzaMoto || regia.momento >= 1)
            Text.rich(
              key: const Key('carta_di_nascita_cifre'),
              textAlign: TextAlign.center,
              TextSpan(children: [
                if (riducendo)
                  for (var i = 0; i < cifreDelTotale.length; i++) ...[
                    if (i > 0) const TextSpan(text: ' + '),
                    TextSpan(
                        text: '${cifreDelTotale[i]}',
                        style: TextStyle(color: colore)),
                  ]
                else
                  for (var i = 0; i < passi.cifre.length; i++) ...[
                    if (i > 0) const TextSpan(text: ' + '),
                    TextSpan(
                      text: '${passi.cifre[i]}',
                      style: TextStyle(
                          color: i < accese ? colore : ColorTokens.textMuted),
                    ),
                  ],
              ]),
              style: TypographyTokens.corpo(weight: 600)
                  .copyWith(color: ColorTokens.textMuted, letterSpacing: 1),
            ),
        ],
      ),
    );
  }
}

/// **LA SCENA**: l'anello delle settantotto e, sopra, la sua carta che viene
/// avanti e si gira.
class _LaScena extends StatefulWidget {
  const _LaScena({
    super.key,
    required this.tempo,
    required this.regiaDi,
    required this.carta,
    required this.palette,
    required this.misura,
    required this.visibiliInsieme,
  });

  final Animation<double> tempo;
  final RegiaDellaRivelazione Function() regiaDi;
  final TarotCard carta;
  final MaestroPalette palette;
  final Size misura;
  final int visibiliInsieme;

  /// **QUANTO E' ALTA LA CARTA GIRATA**, in frazione della scena: la voce
  /// DC.14 ne vuole almeno il settanta per cento.
  static const double quotaDellaCartaFinale = 0.86;

  /// La larghezza di una carta dell'anello, in frazione della scena.
  static const double quotaDellaCartaNelMazzo = 0.19;

  @override
  State<_LaScena> createState() => _LaScenaState();
}

class _LaScenaState extends State<_LaScena> {
  /// Il dorso decodificato una volta sola: l'anello lo disegna settantotto
  /// volte da qui, in una chiamata sola.
  ui.Image? _dorso;
  ImageStream? _flusso;
  late final ImageStreamListener _ascolto = ImageStreamListener((info, _) {
    if (mounted) setState(() => _dorso = info.image);
  });

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final flusso = AssetImage(TarotDeck.dorsoThumb)
        .resolve(createLocalImageConfiguration(context));
    if (flusso.key == _flusso?.key) return;
    _flusso?.removeListener(_ascolto);
    _flusso = flusso..addListener(_ascolto);
  }

  @override
  void dispose() {
    _flusso?.removeListener(_ascolto);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.misura.width;
    final h = widget.misura.height;
    final larga = w * _LaScena.quotaDellaCartaNelMazzo;
    final alta = larga / TarotFrame.aspect;
    final centro = Offset(w / 2, h * 0.58);
    final rx = w * 0.40;
    final ry = h * 0.13;
    final tempo = widget.tempo;
    final regiaDi = widget.regiaDi;
    // **LA SCENA HA LA SUA MISURA INTERA**, dalla prova sul telefono: senza,
    // prima del momento finale l'unico figlio non posizionato era un vuoto,
    // la `Stack` usciva larga zero e la colonna la metteva a meta' schermo.
    // L'anello, disegnato su una tela larga zero, finiva spostato di mezza
    // scena a destra, e si centrava solo quando la carta si fermava.
    return SizedBox.fromSize(
      size: widget.misura,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                key: const Key('carta_di_nascita_mazzo'),
                painter: PittoreDellAnello(
                  tempo: tempo,
                  regiaDi: regiaDi,
                  dorso: _dorso,
                  centro: centro,
                  rx: rx,
                  ry: ry,
                  carta: Size(larga, alta),
                  visibili: widget.visibiliInsieme,
                ),
              ),
            ),
          ),
          // Il velo sull'anello, uno solo: settantotto opacita' diverse
          // sarebbero settantotto livelli da comporre a ogni fotogramma.
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: tempo,
                builder: (context, _) {
                  final velo = regiaDi().velo();
                  return velo <= 0
                      ? const SizedBox.shrink()
                      : ColoredBox(
                          color:
                              const Color(0xFF05060A).withValues(alpha: velo));
                },
              ),
            ),
          ),
          AnimatedBuilder(
            animation: tempo,
            builder: (context, _) {
              final regia = regiaDi();
              if (!regia.laSuaSiStacca) return const SizedBox.shrink();
              final a = regia.avanzata();
              final finaleAlta = math.min(h * _LaScena.quotaDellaCartaFinale,
                  w * 0.9 / TarotFrame.aspect);
              final altaOra = alta + (finaleAlta - alta) * a;
              final largaOra = altaOra * TarotFrame.aspect;
              final daDove = Offset(centro.dx, centro.dy + ry);
              final aDove = Offset(w / 2, h / 2);
              final dove = Offset.lerp(daDove, aDove, a)!;
              final g = regia.girata();
              final scoperta = g >= 0.5;
              final angolo = scoperta ? (g - 1) * math.pi : g * math.pi;
              return Positioned(
                left: dove.dx - largaOra / 2,
                top: dove.dy - altaOra / 2,
                width: largaOra,
                height: altaOra,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0012)
                    ..rotateY(angolo),
                  child: scoperta
                      ? TarotCardArt(
                          key: const Key('carta_di_nascita_la_carta'),
                          card: widget.carta,
                          palette: widget.palette,
                          borderRadius: 10,
                        )
                      : Image.asset(
                          TarotDeck.dorsoThumb,
                          key: const Key('carta_di_nascita_il_dorso'),
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// **L'ANELLO, SENZA FIGLI E SENZA RITAGLI.** Ordine DP voce 01.3.
///
/// **Qui c'era un `Flow` con settantotto figli**, ognuno un'immagine dentro
/// un ritaglio arrotondato. Misurato sul Realme di collaudo, in profilo: fra
/// 38 e 43 fotogrammi al secondo, contro i 60 che lo stesso telefono consegna
/// a scena vuota. Adesso le settantotto si dipingono da una sola immagine
/// decodificata, ognuna nel suo rettangolo gia' calcolato, nell'ordine della
/// profondita'. Il dorso ha gia' il suo bordo scuro, quindi il ritaglio non
/// serviva.
///
/// **E NON COL `drawAtlas`**, e la ragione e' una schermata. La prima
/// stesura disegnava le settantotto con un atlante, una chiamata sola: al
/// banco era giusta, **sul telefono il centro dell'anello finiva al bordo
/// destro della scena**, in orizzontale e non in verticale. Col rettangolo
/// di destinazione non c'e' niente da interpretare.
class PittoreDellAnello extends CustomPainter {
  PittoreDellAnello({
    required this.tempo,
    required this.regiaDi,
    required this.dorso,
    required this.centro,
    required this.rx,
    required this.ry,
    required this.carta,
    required this.visibili,
  }) : super(repaint: tempo);

  final Animation<double> tempo;
  final RegiaDellaRivelazione Function() regiaDi;

  /// Il dorso vero, `TarotDeck.dorsoThumb`, decodificato; nullo finche'
  /// non e' pronto, e allora l'anello non si disegna.
  final ui.Image? dorso;
  final Offset centro;
  final double rx;
  final double ry;
  final Size carta;
  final int visibili;

  /// **L'ASSET CHE L'ANELLO DISEGNA**, per la guardia.
  static String get asset => TarotDeck.dorsoThumb;

  /// **LE CARTE CHE ADESSO SI DISEGNANO**, dalla piu' lontana alla piu'
  /// vicina, con la loro scala e il loro centro. Pubblica per la guardia.
  List<({int indice, double scala, Offset centro})> carteDaDisegnare() {
    final regia = regiaDi();
    final sua = regia.indiceDellaSua;
    final ordine = <(int, double)>[
      for (var i = 0; i < RegiaDellaRivelazione.quanteNelMazzo; i++)
        if (!(regia.laSuaSiStacca && i == sua)) (i, regia.profonditaDi(i)),
    ]..sort((a, b) => a.$2.compareTo(b.$2));
    final salta = math.max(0, ordine.length - visibili);
    return [
      for (final (i, p) in ordine.skip(salta))
        (
          indice: i,
          scala: 0.5 + 0.5 * (p + 1) / 2,
          centro: Offset(
              centro.dx + rx * math.cos(regia.angoloDi(i)), centro.dy + ry * p),
        ),
    ];
  }

  @override
  void paint(Canvas canvas, Size size) {
    final immagine = dorso;
    if (immagine == null) return;
    final sorgente = Rect.fromLTWH(
        0, 0, immagine.width.toDouble(), immagine.height.toDouble());
    final pennello = Paint()..filterQuality = FilterQuality.medium;
    for (final c in carteDaDisegnare()) {
      canvas.drawImageRect(
        immagine,
        sorgente,
        Rect.fromCenter(
          center: c.centro,
          width: carta.width * c.scala,
          height: carta.height * c.scala,
        ),
        pennello,
      );
    }
  }

  @override
  bool shouldRepaint(PittoreDellAnello vecchio) =>
      vecchio.dorso != dorso ||
      vecchio.visibili != visibili ||
      vecchio.carta != carta;
}
