import 'dart:async';
import '../../chat/chat_openers.dart';
import '../../../ricordi/azioni_del_responso.dart';
import 'package:flutter/material.dart';
import '../../../sigilli/regia_del_cammino.dart';

import '../../../../core/magic/intention_sigil.dart';
import '../../../../core/maestro/maestro.dart';
import '../../../../design_system/components/cosmos_background.dart';
import '../../../../design_system/components/depth_card.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/theme/maestro_scope.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import '../../rotta_arte.dart';
import '../../../../../design_system/components/titolo_che_non_si_rompe.dart';
import '../../../../design_system/transizioni/passaggio_del_cerchio.dart';
import '../../../../design_system/typography/paragrafi_di_lettura.dart';

/// Il Sigillo dell'Intenzione, terza arte distintiva di Caligo.
///
/// Si scrive una intenzione in una frase, e ne nasce un glifo unico. Il metodo
/// e' quello di Austin Osman Spare per le lettere e la Rosa dei Petali della
/// Golden Dawn per la ruota: il calcolo vive in `IntentionSigil`, qui c'e'
/// solo la messa in scena.
///
/// **Perche' non somiglia alla bindrune** (regola 21). La bindrune
/// dell'Estrazione Rune intreccia tratti su un'ASTA VERTICALE centrale e nasce
/// da un lancio; questo e' un CAMMINO SPEZZATO su una ruota di lettere e nasce
/// da una frase scritta. Nessuna asta, nessun ramo, nessuna simmetria attorno
/// a un centro: un percorso poligonale che si legge come un tragitto. Le due
/// cose sono diverse per costruzione, non per accorgimento.
class SigilloIntenzioneScreen extends StatefulWidget {
  const SigilloIntenzioneScreen({super.key});

  static Route<void> route() => PassaggioDelCerchio.rotta<void>((_) => const SogliaArte(
        id: 'magic_sigil',
        maestro: Maestro.caligo,
          child: SigilloIntenzioneScreen(),
        ));

  /// Quanto dura il tracciamento del cammino, tratto dopo tratto.
  static const Duration tracciamento = Duration(milliseconds: 2400);

  @override
  State<SigilloIntenzioneScreen> createState() =>
      _SigilloIntenzioneScreenState();
}

enum _Fase { soglia, scrittura, tracciamento, rivelazione }

class _SigilloIntenzioneScreenState extends State<SigilloIntenzioneScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _campo = TextEditingController();
  late final AnimationController _traccia;
  _Fase _fase = _Fase.soglia;
  LetturaIntenzione? _lettura;

  /// Gli inviti tappabili: coprono le tre vie, cosi' chi non sa da dove
  /// cominciare vede subito che si puo' chiedere.
  static const List<String> _suggerimenti = [
    'Apro il mio cuore a un legame vero',
    'Chiedo chiarezza sulla mia strada',
    'Metto radici dove sono adesso',
    'Trovo il coraggio di dire quello che sento',
  ];

  @override
  void initState() {
    super.initState();
    _traccia = AnimationController(
      vsync: this,
      duration: SigilloIntenzioneScreen.tracciamento,
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          setState(() => _fase = _Fase.rivelazione);
          _entraNelCammino();
        }
      });
  }

  @override
  void dispose() {
    _campo.dispose();
    _traccia.dispose();
    super.dispose();
  }

  bool get _riduciMoto => MediaQuery.of(context).disableAnimations;

  /// IL SIGILLO ENTRA NEL CAMMINO, ordine P voce 35: alla rivelazione, cioe'
  /// quando il segno e' compiuto e non quando si comincia a scriverlo.
  void _entraNelCammino() {
    unawaited(RegiaDelCammino.dopoUnGesto(context, 'sigillo'));
  }

  void _traccia_() {
    final testo = _campo.text.trim();
    if (IntentionSigil.cammino(testo).length < 2) return;
    setState(() {
      _lettura = LettoreIntenzione.leggi(testo);
      _fase = _Fase.tracciamento;
    });
    if (_riduciMoto) {
      _traccia.value = 1;
      setState(() => _fase = _Fase.rivelazione);
      // RIDUCI MOVIMENTO NON TOGLIE IL TRAGUARDO: senza animazione il
      // listener non scatta, e senza questa riga il Sigillo non entrerebbe
      // mai nel cammino per chi tiene il moto spento.
      _entraNelCammino();
    } else {
      _traccia
        ..value = 0
        ..forward();
    }
  }

  Color _coloreVia(ViaMagica via, MaestroPalette palette) => switch (via) {
        ViaMagica.rossa => const Color(0xFFD9563B),
        ViaMagica.bianca => const Color(0xFFE8E4F0),
        ViaMagica.verde => const Color(0xFF3FA07A),
      };

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      backgroundColor: ColorTokens.neutralDeepest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: palette.goldSoft),
        // **IL TITOLO NON SI ROMPE**, ordine S voce 05: a capo fra le
        // parole, la misura scende solo quanto serve, e non si tronca mai.
        // Col borsellino nella riga delle azioni lo spazio del titolo si e'
        // ristretto, e un `Text` nudo qui torna a mettere i puntini.
        title: TitoloCheNonSiRompe(
            testo: 'Il Sigillo dell\'Intenzione',
            stile: TypographyTokens.titoloDiSchermata()
                .copyWith(color: palette.goldSoft)),
        // IL BORSELLINO, ordine S voce 06: stesso segno, stesso angolo, in
        // ogni schermata della pratica. Un saldo che appare e scompare non
        // si impara.
        actions: const [AngoloDellaBarra()],
      ),
      extendBodyBehindAppBar: true,
      body: CosmosBackground(
        seed: 23,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
            child: switch (_fase) {
              _Fase.soglia => _soglia(palette),
              _Fase.scrittura => _scrittura(palette),
              _Fase.tracciamento || _Fase.rivelazione => _scena(palette),
            },
          ),
        ),
      ),
    );
  }

  Widget _soglia(MaestroPalette palette) {
    return ListView(
      key: const Key('sigillo_soglia'),
      children: [
        const SizedBox(height: SpacingTokens.xxl),
        Text('Caligo ti aspetta',
            textAlign: TextAlign.center,
            style: TypographyTokens.label(size: 12)
                .copyWith(color: palette.goldSoft, letterSpacing: 3)),
        const SizedBox(height: SpacingTokens.md),
        Text(
          'Una intenzione detta bene è già mezza compiuta. Scrivila in una '
          'frase sola, al presente, come se fosse vera adesso. Ne ricaverò il '
          'tuo sigillo: un segno che è tuo e di nessun altro.',
          textAlign: TextAlign.center,
          style: TypographyTokens.body(size: 16)
              .copyWith(color: ColorTokens.textPrimary, height: 1.5),
        ),
        const SizedBox(height: SpacingTokens.xl),
        _FontiEMetodo(palette: palette),
        const SizedBox(height: SpacingTokens.xl),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            key: const Key('sigillo_inizia'),
            style: FilledButton.styleFrom(
              backgroundColor: palette.gold,
              foregroundColor: palette.deepest,
              padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
              ),
            ),
            onPressed: () => setState(() => _fase = _Fase.scrittura),
            child: Text('Scrivi la tua intenzione',
                style: TypographyTokens.body(size: 16, weight: 600)
                    .copyWith(color: palette.deepest)),
          ),
        ),
        const SizedBox(height: SpacingTokens.lg),
      ],
    );
  }

  Widget _scrittura(MaestroPalette palette) {
    final abbastanza = IntentionSigil.cammino(_campo.text).length >= 2;
    return ListView(
      key: const Key('sigillo_scrittura'),
      children: [
        const SizedBox(height: SpacingTokens.xl),
        Text('La tua intenzione',
            textAlign: TextAlign.center,
            style: TypographyTokens.titoloSezione()
                .copyWith(color: palette.goldSoft)),
        const SizedBox(height: SpacingTokens.lg),
        DepthCard(
          reveal: false,
          child: TextField(
            key: const Key('sigillo_campo'),
            controller: _campo,
            maxLines: 3,
            minLines: 2,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => setState(() {}),
            style: TypographyTokens.body(size: 17)
                .copyWith(color: ColorTokens.textPrimary, height: 1.4),
            cursorColor: palette.goldSoft,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Scrivo qui cosa voglio, al presente...',
              hintStyle: TypographyTokens.body(size: 16)
                  .copyWith(color: ColorTokens.textMuted),
            ),
          ),
        ),
        const SizedBox(height: SpacingTokens.md),
        Text('Oppure parti da qui',
            style: TypographyTokens.etichetta().copyWith(
                color: palette.goldSoft, letterSpacing: 2)),
        const SizedBox(height: SpacingTokens.sm),
        Wrap(
          spacing: SpacingTokens.sm,
          runSpacing: SpacingTokens.sm,
          children: [
            for (final s in _suggerimenti)
              GestureDetector(
                key: Key('sigillo_invito_${_suggerimenti.indexOf(s)}'),
                onTap: () => setState(() {
                  _campo.text = s;
                  _campo.selection =
                      TextSelection.collapsed(offset: s.length);
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.md,
                      vertical: SpacingTokens.xs),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(SpacingTokens.radiusPill),
                    border: Border.all(
                        color: palette.gold.withValues(alpha: 0.4)),
                  ),
                  child: Text(s,
                      style: TypographyTokens.corpo()
                          .copyWith(color: ColorTokens.textSecondary)),
                ),
              ),
          ],
        ),
        const SizedBox(height: SpacingTokens.xl),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            key: const Key('sigillo_traccia'),
            style: FilledButton.styleFrom(
              backgroundColor: abbastanza
                  ? palette.gold
                  : palette.gold.withValues(alpha: 0.3),
              foregroundColor: palette.deepest,
              padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
              ),
            ),
            onPressed: abbastanza ? _traccia_ : null,
            child: Text('Traccia il sigillo',
                style: TypographyTokens.body(size: 16, weight: 600)
                    .copyWith(color: palette.deepest)),
          ),
        ),
        if (!abbastanza) ...[
          const SizedBox(height: SpacingTokens.sm),
          Text(
            'Servono almeno due lettere diverse: il sigillo è un cammino, '
            'quindi ha bisogno di due punti.',
            textAlign: TextAlign.center,
            style: TypographyTokens.corpo()
                .copyWith(color: ColorTokens.textMuted, height: 1.4),
          ),
        ],
        const SizedBox(height: SpacingTokens.lg),
      ],
    );
  }

  Widget _scena(MaestroPalette palette) {
    final lettura = _lettura!;
    final colore = _coloreVia(lettura.via, palette);
    final finito = _fase == _Fase.rivelazione;

    return ListView(
      key: const Key('sigillo_scena'),
      children: [
        const SizedBox(height: SpacingTokens.lg),
        AspectRatio(
          aspectRatio: 1,
          child: AnimatedBuilder(
            animation: _traccia,
            builder: (context, _) => CustomPaint(
              key: const Key('sigillo_ruota'),
              painter: RuotaSigilloPainter(
                cammino: IntentionSigil.cammino(lettura.riformulata),
                lettere: IntentionSigil.lettereUniche(lettura.riformulata),
                avanzamento: _riduciMoto ? 1.0 : _traccia.value,
                colore: colore,
                oro: palette.goldSoft,
                mostraRuota: !finito,
              ),
            ),
          ),
        ),
        const SizedBox(height: SpacingTokens.lg),
        if (finito) ...[
          Text(lettura.via.nome,
              key: const Key('sigillo_via'),
              textAlign: TextAlign.center,
              style: TypographyTokens.titoloSezione()
                  .copyWith(color: colore)),
          const SizedBox(height: SpacingTokens.xxs),
          Text(lettura.via.dominio,
              textAlign: TextAlign.center,
              style: TypographyTokens.corpo()
                  .copyWith(color: ColorTokens.textSecondary)),
          const SizedBox(height: SpacingTokens.md),
          DepthCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('LA TUA INTENZIONE',
                    style: TypographyTokens.etichetta().copyWith(
                        color: palette.goldSoft, letterSpacing: 2)),
                const SizedBox(height: SpacingTokens.xxs),
                ParagrafiDiLettura(
                    testo: '"${lettura.riformulata}"',
                    stile: TypographyTokens.lettura()
                        .copyWith(height: 1.45)),
                if (lettura.eStataRiformulata) ...[
                  const SizedBox(height: SpacingTokens.sm),
                  Text(
                    'Avevi scritto di qualcun altro. Un sigillo agisce su chi '
                    'lo traccia, mai sulla volontà di un terzo, quindi ho '
                    'riportato la tua intenzione su di te: è lì che ha forza.',
                    key: const Key('sigillo_riformulata'),
                    style: TypographyTokens.corpo().copyWith(
                        color: ColorTokens.textSecondary, height: 1.45),
                  ),
                ],
                const SizedBox(height: SpacingTokens.sm),
                ParagrafiDiLettura(
                  // Dopo una riformulazione la parola che l'ha innescata NON
                  // si ripete: rimetterebbe sotto gli occhi proprio la cosa
                  // che si e' appena tolta, e suonerebbe come un rimprovero.
                  testo: lettura.eStataRiformulata
                      ? 'Un desiderio che riguarda il cuore appartiene alla '
                          '${lettura.via.nome}.'
                      : lettura.riconosciuta
                          ? 'Ho riconosciuto la ${lettura.via.nome} dalla '
                              'parola "${lettura.parolaChiave}".'
                          : 'Non ho riconosciuto nessuna delle tre vie nelle '
                              'tue parole, quindi ho scelto la Via Bianca, '
                              'che è quella della chiarezza.',
                  key: const Key('sigillo_perche'),
                  stile: TypographyTokens.lettura().copyWith(
                      color: ColorTokens.textSecondary, height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          _FontiEMetodo(palette: palette),
          const SizedBox(height: SpacingTokens.lg),
          // **LE AZIONI DA UNA PORTA SOLA, ordine CG voci 06 e 08.** Qui
          // il Condividi non c'e' e non e' una dimenticanza: il Sigillo
          // produce un segno tracciato col dito, non una carta da
          // mandare. Restano il Custodisci e il Parlane, che di
          // un'immagine non hanno bisogno.
          AzioniDelResponso(
            palette: palette,
            maestro: Maestro.caligo,
            responso: ResponsoDaCustodire(
              arte: 'sigillo',
              titolo: 'Il tuo sigillo: ${lettura.via.nome}',
              testo: lettura.riformulata,
              dati: {'via': lettura.via.nome},
            ),
            aperturaDellaChat: ChatOpeners.sigillo(lettura.riformulata),
          ),
          const SizedBox(height: SpacingTokens.lg),
        ] else
          Text(
            'Traccio il tuo cammino sulle lettere...',
            textAlign: TextAlign.center,
            style: TypographyTokens.corpo()
                .copyWith(color: ColorTokens.textSecondary),
          ),
      ],
    );
  }
}

/// Le fonti e il metodo, dichiarati dove si vedono.
class _FontiEMetodo extends StatelessWidget {
  const _FontiEMetodo({required this.palette});

  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return DepthCard(
      key: const Key('sigillo_fonti'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('FONTI E METODO',
              style: TypographyTokens.etichetta().copyWith(
                  color: palette.goldSoft, letterSpacing: 2)),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            'Il metodo delle lettere viene da Austin Osman Spare, che nel '
            'primo Novecento descrive come togliere da una frase le lettere '
            'ripetute perché la forma prenda il posto delle parole. La ruota '
            'su cui si traccia il cammino si ispira alla Rosa dei Petali '
            'della Golden Dawn, che nella sua forma storica porta lettere '
            'ebraiche: qui è adattata alle nostre, con un adattamento che è '
            'nostro. I testi che leggi sono curatela originale del Cerchio.',
            style: TypographyTokens.corpo()
                .copyWith(color: ColorTokens.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }
}

/// La ruota delle lettere col cammino che si traccia sopra.
///
/// Pubblico perche' l'avanzamento del tracciamento e' l'unica cosa che un test
/// possa leggere senza guardare i pixel.
class RuotaSigilloPainter extends CustomPainter {
  RuotaSigilloPainter({
    required this.cammino,
    required this.lettere,
    required this.avanzamento,
    required this.colore,
    required this.oro,
    this.mostraRuota = true,
  });

  /// I punti da unire, in coordinate normalizzate.
  final List<Offset> cammino;

  /// Le lettere corrispondenti, per scriverle sui petali toccati.
  final List<String> lettere;

  /// Da 0 (niente) a 1 (cammino completo).
  final double avanzamento;

  /// Il colore della via.
  final Color colore;
  final Color oro;

  /// Se disegnare la ruota di sfondo. A rivelazione avvenuta si spegne, e
  /// resta il solo segno: e' quello il sigillo, non la ruota.
  final bool mostraRuota;

  @override
  void paint(Canvas canvas, Size size) {
    Offset p(Offset n) => Offset(n.dx * size.width, n.dy * size.height);

    if (mostraRuota) {
      // I ventuno petali, ciascuno col suo pallino. La ruota si vede mentre
      // si traccia, cosi' si capisce da dove nasce il segno.
      final tenue = Paint()..color = oro.withValues(alpha: 0.22);
      for (var i = 0; i < IntentionSigil.petali; i++) {
        final l = IntentionSigil.alfabeto[i];
        final q = p(IntentionSigil.posizioneDi(l));
        final toccata = lettere.contains(l);
        canvas.drawCircle(q, toccata ? 3.4 : 2.0,
            toccata ? (Paint()..color = oro.withValues(alpha: 0.8)) : tenue);
        _lettera(canvas, l, q, size, toccata ? oro : oro.withValues(alpha: 0.3));
      }
      // Il cerchio che tiene insieme i petali, appena accennato.
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        size.width * 0.38,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..color = oro.withValues(alpha: 0.15),
      );
    }

    if (cammino.length < 2) return;

    // Il cammino: una spezzata che si rivela per lunghezza. NON un intreccio
    // su un'asta, che e' la bindrune: qui ogni segmento va da una lettera alla
    // successiva, e il tragitto si legge come un percorso.
    final punti = [for (final n in cammino) p(n)];
    var totale = 0.0;
    for (var i = 0; i + 1 < punti.length; i++) {
      totale += (punti[i + 1] - punti[i]).distance;
    }
    var percorsa = totale * avanzamento.clamp(0.0, 1.0);

    final tratto = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = colore;
    final alone = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = colore.withValues(alpha: 0.25);

    final path = Path()..moveTo(punti.first.dx, punti.first.dy);
    for (var i = 0; i + 1 < punti.length; i++) {
      final seg = (punti[i + 1] - punti[i]).distance;
      if (percorsa <= 0) break;
      if (percorsa >= seg) {
        path.lineTo(punti[i + 1].dx, punti[i + 1].dy);
        percorsa -= seg;
      } else {
        final k = percorsa / seg;
        final q = Offset.lerp(punti[i], punti[i + 1], k)!;
        path.lineTo(q.dx, q.dy);
        percorsa = 0;
      }
    }
    canvas.drawPath(path, alone);
    canvas.drawPath(path, tratto);

    // Il capo e la coda del cammino: un cerchietto dove parte, una barra
    // dove finisce. E' la convenzione dei sigilli di Spare, e serve a dire in
    // che verso si legge.
    canvas.drawCircle(
      punti.first,
      4.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = colore,
    );
    if (avanzamento >= 1) {
      final a = punti[punti.length - 2];
      final b = punti.last;
      final d = (b - a).distance;
      if (d > 0) {
        final n = Offset(-(b.dy - a.dy) / d, (b.dx - a.dx) / d);
        canvas.drawLine(b - n * 6, b + n * 6, tratto);
      }
    }
  }

  void _lettera(
      Canvas canvas, String testo, Offset centro, Size size, Color colore) {
    final tp = TextPainter(
      text: TextSpan(
        text: testo,
        // ORDINE B: era 11, sotto il pavimento dell'app. Dipinta su tela e non
        // in albero, questa lettera non passa dai token e nessun assert la
        // vedeva: adesso la misura viene dal pavimento, che e' il numero da cui
        // dipende, invece che da una costante che lo ignora.
        style: TextStyle(
          color: colore,
          fontSize: TypographyTokens.pavimento,
        // **IL CARATTERE E' EBGaramond, e la scelta e' del fondatore.**
        // Ordine BT voce 01, sulla build 2207: davanti alle tre anteprime
        // dell'ordine BM voce 02 ha detto "ok per la (b), chiudiamo BM.02".
        // EBGaramond il pacchetto lo dichiara gia' e l'app lo carica gia',
        // quindi non entra un byte di asset in piu'. Prima qui c'era
        // CormorantGaramond, che nel pacchetto non c'e' mai stato: la ruota
        // si disegnava col carattere di sistema, cioe' con uno diverso su
        // ogni telefono.
          fontFamily: 'EBGaramond',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    // La lettera sta appena fuori dal suo pallino, verso l'esterno.
    final centroRuota = Offset(size.width / 2, size.height / 2);
    final v = centro - centroRuota;
    final l = v.distance;
    final fuori = l == 0 ? centro : centro + v / l * 14;
    tp.paint(canvas, fuori - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(RuotaSigilloPainter old) =>
      old.avanzamento != avanzamento ||
      old.cammino != cammino ||
      old.mostraRuota != mostraRuota;
}
