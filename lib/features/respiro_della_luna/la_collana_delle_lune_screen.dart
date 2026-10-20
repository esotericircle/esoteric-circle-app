import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/condivisione/porta_della_condivisione.dart';
import '../../core/condivisione/premio_della_condivisione.dart';
import '../../core/lunario/il_respiro_della_luna.dart';
import '../../core/lunario/la_collana_delle_lune.dart';
import '../../core/maestro/maestro.dart';
import '../../design_system/theme/app_theme.dart';
import '../../design_system/components/titolo_che_non_si_rompe.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';
import '../../design_system/transizioni/velo_del_cerchio.dart';
import '../lunario/la_luna_nel_castone.dart' show IlMeseInItaliano;
import '../maestri/rotta_arte.dart';
import '../maestri/widgets/foglio_delle_fonti.dart';
import '../scene/la_scena_in_video.dart';
import '../synastry/sinastria_share_card.dart' show captureBoundaryPng;
import 'i_comandi_dipinti.dart';
import 'la_collana_dipinta.dart';

/// **LA COLLANA DELLE LUNE.** Ordine FX voce FX.05, ridisegnata
/// dall'aggiunta FXA.01 il 16 ottobre 2026.
///
/// La schermata e' lo scrigno dipinto ([LaCollanaDipinta]): la pittura con
/// la collana spenta e, sopra, i ritagli dipinti delle perle respirate. La
/// Luna vera dentro le perle (FX.05) non si posa piu' qui: la Luna del giorno
/// resta nella Luna di quest'ora del Respiro (FX.03). Se il ciclo precedente
/// si e' chiuso con almeno un giorno respirato e la sua consegna non e' mai
/// partita, la precede la scena della consegna.
class LaCollanaDelleLuneScreen extends StatefulWidget {
  const LaCollanaDelleLuneScreen(
      {super.key, this.now, this.fabbricaDellaScena});

  final DateTime? now;

  /// Chi fa il video della consegna: iniettabile per le prove di FXA.08.
  /// Senza, il video vero.
  final FabbricaDiScena? fabbricaDellaScena;

  static Route<void> route({DateTime? now}) => PassaggioDelCerchio.rotta<void>(
      (_) => MaestroScope(child: LaCollanaDelleLuneScreen(now: now)));

  @override
  State<LaCollanaDelleLuneScreen> createState() =>
      _LaCollanaDelleLuneScreenState();
}

class _LaCollanaDelleLuneScreenState extends State<LaCollanaDelleLuneScreen> {
  late final IlRespiroDellaLuna _flag = IlRespiroDellaLuna();
  late final LaCollanaDelleLune _collana = LaCollanaDelleLune(respiro: _flag);
  bool _consegnaDaMostrare = false;
  bool _pronto = false;

  DateTime get _adesso => widget.now ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    unawaited(_carica());
  }

  Future<void> _carica() async {
    await _flag.leggi();
    await _collana.leggi();
    if (!mounted) return;
    setState(() {
      _consegnaDaMostrare = _collana.consegnaInAttesa(_adesso);
      _pronto = true;
    });
  }

  @override
  void dispose() {
    _flag.dispose();
    _collana.dispose();
    super.dispose();
  }

  void _consegnaFatta() {
    unawaited(_collana.segnaConsegnata(_adesso));
    setState(() => _consegnaDaMostrare = false);
  }

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
    if (!_pronto) {
      return Scaffold(
        backgroundColor: palette.deepest,
        body: const Center(
            child: CircularProgressIndicator(key: Key('collana_caricamento'))),
      );
    }
    if (_consegnaDaMostrare) {
      return _ScenaDellaConsegna(
        fabbrica: widget.fabbricaDellaScena,
        palette: palette,
        perle: _collana.perleDelCicloAppenaChiuso(_adesso),
        onFinita: _consegnaFatta,
      );
    }
    return AnimatedBuilder(
      animation: Listenable.merge([_flag, _collana]),
      builder: (context, _) => _LaCollanaInCorso(
        palette: palette,
        collana: _collana,
        now: _adesso,
      ),
    );
  }
}

/// I giorni accesi di una collana, contati dal primo (1) all'ultimo.
Set<int> giorniAccesi(List<PerlaDellaCollana> perle) => {
      for (var i = 0; i < perle.length; i++)
        if (perle[i].stato == StatoDellaPerla.accesa) i + 1,
    };

/// Una collana e' completa quando ogni giorno del ciclo e' acceso.
bool collanaCompleta(List<PerlaDellaCollana> perle) =>
    perle.isNotEmpty && perle.every((p) => p.stato == StatoDellaPerla.accesa);

/// La vista del ciclo in corso: lo scrigno dipinto, lo scrigno delle
/// collane passate e la condivisione (la ricucitura e' uscita con la
/// decisione del fondatore del 20 ottobre 2026).
class _LaCollanaInCorso extends StatefulWidget {
  const _LaCollanaInCorso(
      {required this.palette, required this.collana, required this.now});

  final MaestroPalette palette;
  final LaCollanaDelleLune collana;
  final DateTime now;

  @override
  State<_LaCollanaInCorso> createState() => _LaCollanaInCorsoState();
}

class _LaCollanaInCorsoState extends State<_LaCollanaInCorso> {
  /// La finestra sulla pittura v2, in righe del file: l'ovale (righe
  /// 501-2071) con circa cento pixel di margine sopra e sotto, come ai lati
  /// (FY.08).
  static const double _cimaDellaFinestra = 400;
  static const double _bassoDellaFinestra = 2172;

  final GlobalKey _cardKey = GlobalKey();
  bool _rendiLaCard = false;

  // LAPIDE, ordine GA, decisione del fondatore del 20 ottobre 2026: qui
  // c'era la ricucitura a video di una perla spenta (ordine FX aggiunta
  // FXA.03): l'ago col filo, la conferma della spesa di 25 Eos e la porta
  // del server `ricuciUnaPerlaDelRespiro`, che non e' mai stata pubblicata
  // (dalla build 2314 la persona arrivava alla conferma e poi leggeva che la
  // funzione non era aperta, ordine GA voce 11). Il fondatore: "Le funzioni
  // del Respiro non si pubblicano". La collana mostra le perle respirate e
  // non offre piu' una ricucitura che il server non sa fare; il modello
  // della ricucitura (`LaCollanaDelleLune.giorniRicucibili`) resta, senza
  // porta a video.

  Future<void> _condividi(String nome, int accese) async {
    setState(() => _rendiLaCard = true);
    try {
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 80));
      final png = await captureBoundaryPng(_cardKey);
      if (png == null) return;
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/collana_delle_lune.png');
      await file.writeAsBytes(png, flush: true);
      final andata = await PortaDellaCondivisione.daFile(file.path,
          testo: '$nome, $accese perle accese sul Respiro della Luna');
      if (andata && mounted) {
        await PremioDellaCondivisione.premia(context,
            cosa: 'Hai condiviso la tua Collana delle Lune');
      }
    } finally {
      if (mounted) setState(() => _rendiLaCard = false);
    }
  }

  void _apriLoScrigno() {
    final scrigno = widget.collana.scrigno.reversed.toList();
    unawaited(foglioDelCerchio<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (c) => Padding(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: PannelloDipinto(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Lo scrigno delle collane',
                  style: TypographyTokens.titoloScheda()
                      .copyWith(color: widget.palette.goldSoft)),
              const SizedBox(height: SpacingTokens.sm),
              SizedBox(
                height: 230,
                child: ListView(
                  key: const Key('collana_scrigno'),
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final c in scrigno)
                      Padding(
                        padding: const EdgeInsets.only(right: SpacingTokens.sm),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 200,
                              // La stessa pittura in piccolo, mai una forma
                              // disegnata.
                              child: LaCollanaDipinta(
                                accesi: giorniAccesi(c.perle),
                                completa: collanaCompleta(c.perle),
                                numeroDiPerle: c.perle.length,
                              ),
                            ),
                            Text(c.nome,
                                style: TypographyTokens.label(size: 12)
                                    .copyWith(color: coloreSulVelluto)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final ciclo = widget.collana.cicloDi(widget.now);
    final perle = widget.collana.perle(widget.now);
    final accesi = giorniAccesi(perle);
    final completa = collanaCompleta(perle);
    final nome = widget.collana.nomeDelCiclo(ciclo.inizio);
    final oggiAcceso = accesi.contains(perle.indexWhere((p) =>
            IlRespiroDellaLuna.data(p.giorno) ==
            IlRespiroDellaLuna.data(widget.now)) +
        1);

    final collana = LaCollanaDipinta(
      accesi: accesi,
      completa: completa,
      numeroDiPerle: perle.length,
      sopra: (context, scala) => Stack(
        children: [
          // **POCHE PAROLE GRANDI, INTORNO ALLA LUNA** (ordine FY voce
          // FY.08). Il fondatore: "il testo è illeggibile"; poi le pitture
          // v2, con la Luna al centro del velluto (x 720, y 1292, raggio 165).
          // Il velluto libero fra le perle va da x 466 a 960 della pittura:
          // sopra la Luna, fra le perle in alto e il suo bordo (y 950-1117),
          // il mese; sotto, fra la Luna e le perle del fondo (y 1467-1604),
          // le perle accese. La guida sta sotto lo scrigno.
          Positioned(
            left: 466 * scala,
            width: 494 * scala,
            top: 960 * scala,
            height: 150 * scala,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                // Solo il mese, in grande: "Collana di ottobre" nel velluto
                // finiva a 8 punti; "Collana" e' gia' nel titolo.
                child: Text(IlMeseInItaliano.mesi[ciclo.inizio.month - 1],
                    key: const Key('collana_nome_ciclo'),
                    style: TypographyTokens.titoloSezione()
                        .copyWith(color: palette.goldSoft)),
              ),
            ),
          ),
          Positioned(
            left: 466 * scala,
            width: 494 * scala,
            top: 1470 * scala,
            height: 130 * scala,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${accesi.length} di ${perle.length}',
                        key: const Key('collana_conteggio'),
                        style: TypographyTokens.cerimonialeGrande()
                            .copyWith(color: coloreSulVelluto)),
                    Text('perle accese',
                        style: TypographyTokens.titoloScheda()
                            .copyWith(color: coloreSulVelluto)),
                  ],
                ),
              ),
            ),
          ),
          // LAPIDE, ordine GA, decisione del fondatore del 20 ottobre 2026:
          // qui c'erano i tocchi della ricucitura, i segni delle perle
          // ricucibili e l'ago col filo (FXA.03), la porta a video di una
          // funzione del server mai pubblicata.
        ],
      ),
    );

    return Scaffold(
      backgroundColor: palette.deepest,
      appBar: AppBar(
        toolbarHeight: altezzaDellaBarraDelRespiro(context),
        // SEMITRASPARENTE IN OGNI STATO (ordine FY voce FY.20): il velo
        // comune delle barre del titolo, mai il pieno.
        backgroundColor:
            palette.deepest.withValues(alpha: AppTheme.veloDellaBarra),
        elevation: 0,
        // **SOLO I COMANDI COMUNI DELLA BARRA** (FXA.02): la freccia
        // automatica, le fonti e l'angolo della barra, come in tutta l'app.
        // "Condividi" e' sceso sotto la collana, pulsante dipinto.
        iconTheme: IconThemeData(color: palette.goldSoft),
        title: TitoloCheNonSiRompe(
            testo: 'La Collana delle Lune',
            stile: TypographyTokens.titoloDiSchermata()),
        actions: [
          FoglioDelleFonti.bottone(context,
              palette: palette,
              testo: TestiDelleFonti.respiroDellaLuna,
              chiave: 'collana_delle_lune_fonti'),
          const AngoloDellaBarra(),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: Center(
                // **LO SCRIGNO INTERO, COL SUO MARGINE, IN GRANDE** (ordine
                // FY voce FY.08). Nella pittura v2 l'ovale d'argento va dalla
                // riga 501 alla 2071 e dalla colonna 111 alla 1325: ai lati ha
                // il suo margine di velluto scuro, sopra e sotto molto di
                // piu'. Si mostra la pittura dalla riga 400 alla 2172, cioe'
                // lo stesso margine di circa cento pixel tutto intorno, e lo
                // scrigno a schermo cresce invece di rimpicciolirsi per
                // l'altezza della pittura intera. La card che si condivide e'
                // la pittura intera.
                child: AspectRatio(
                  aspectRatio: LePerleDellaCollana.larghezza /
                      (_bassoDellaFinestra - _cimaDellaFinestra),
                  child: LayoutBuilder(builder: (context, v) {
                    final scala = v.maxWidth / LePerleDellaCollana.larghezza;
                    return ClipRect(
                      key: const Key('collana_finestra'),
                      child: OverflowBox(
                        alignment: Alignment.topCenter,
                        maxHeight: LePerleDellaCollana.altezza * scala,
                        child: Transform.translate(
                          offset: Offset(0, -_cimaDellaFinestra * scala),
                          child: SizedBox(
                            width: v.maxWidth,
                            height: LePerleDellaCollana.altezza * scala,
                            child:
                                RepaintBoundary(key: _cardKey, child: collana),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            // **LA GUIDA, MAI DA INDOVINARE, ADESSO SOTTO LO SCRIGNO** (FY.08).
            // Il fondatore, 16 ottobre 2026: "l'utente deve sapere dov'e',
            // cosa deve fare, per ottenere cosa, obiettivo ed eventualmente
            // guida. Non puo' indovinare". Nel velluto era scritta troppo
            // piccola per leggersi: qui ha la sua misura di lettura.
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  SpacingTokens.md, SpacingTokens.xs, SpacingTokens.md, 0),
              child: _LaStrisciaDellaGuida(
                child: Column(
                  key: const Key('collana_guida'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                        completa
                            ? 'La collana è completa: tutte le perle di questa '
                                'lunazione sono accese.'
                            : oggiAcceso
                                ? 'La perla di oggi è accesa. Torna domani a '
                                    'respirare per accendere la prossima.'
                                : 'La perla di oggi è ancora spenta: un minuto '
                                    'di respiro con la Luna la accende.',
                        key: const Key('collana_perla_di_oggi'),
                        textAlign: TextAlign.center,
                        style: TypographyTokens.etichetta()
                            .copyWith(color: palette.goldSoft)),
                    const SizedBox(height: SpacingTokens.xxs),
                    Text(
                        'Alla Luna nuova del ${ciclo.fine.day} '
                        '${IlMeseInItaliano.mesi[ciclo.fine.month - 1].toLowerCase()} '
                        'Medora ti consegna la collana.',
                        key: const Key('collana_obiettivo'),
                        textAlign: TextAlign.center,
                        style: TypographyTokens.etichetta()
                            .copyWith(color: coloreSulVelluto)),
                  ],
                ),
              ),
            ),
            // LAPIDE, ordine GA, decisione del fondatore del 20 ottobre 2026:
            // qui c'era l'invito "Tocca una perla spenta recente per
            // ricucirla" col prezzo in Eos, tolto con la ricucitura.
            Padding(
              padding: const EdgeInsets.fromLTRB(SpacingTokens.md,
                  SpacingTokens.sm, SpacingTokens.md, SpacingTokens.md),
              child: Row(
                children: [
                  if (!oggiAcceso && !completa) ...[
                    Expanded(
                      child: PulsanteDipinto(
                        key: const Key('collana_vai_a_respirare'),
                        testo: 'Respira oggi',
                        larghezzaPiena: true,
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                    ),
                    const SizedBox(width: SpacingTokens.sm),
                  ],
                  Expanded(
                    child: PulsanteDipinto(
                      key: const Key('collana_condividi'),
                      testo: _rendiLaCard
                          ? 'Preparo la card'
                          : PremioDellaCondivisione.etichetta(context),
                      larghezzaPiena: true,
                      onTap: _rendiLaCard
                          ? null
                          : () => _condividi(nome, accesi.length),
                    ),
                  ),
                  if (widget.collana.scrigno.isNotEmpty) ...[
                    const SizedBox(width: SpacingTokens.sm),
                    Expanded(
                      child: PulsanteDipinto(
                        key: const Key('collana_apri_scrigno'),
                        testo: 'Lo scrigno',
                        larghezzaPiena: true,
                        onTap: _apriLoScrigno,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// **LA SCENA DELLA CONSEGNA.** Medora apre lo scrigno con la collana vera
/// della persona, poi comincia quella nuova. Parte una volta sola per
/// ciclo ([LaCollanaDelleLune.consegnaInAttesa]).
class _ScenaDellaConsegna extends StatefulWidget {
  const _ScenaDellaConsegna(
      {required this.palette,
      required this.perle,
      required this.onFinita,
      this.fabbrica});

  final FabbricaDiScena? fabbrica;
  final MaestroPalette palette;
  final List<PerlaDellaCollana> perle;
  final VoidCallback onFinita;

  @override
  State<_ScenaDellaConsegna> createState() => _ScenaDellaConsegnaState();
}

class _ScenaDellaConsegnaState extends State<_ScenaDellaConsegna> {
  static const String _video =
      'brand_assets/respiro_della_luna/medora_la_consegna_della_collana_v1.mp4';
  static const String _primoFotogramma =
      'assets/img/respiro_della_luna/consegna_primo_fotogramma_v1.webp';
  static const String _ultimoFotogramma =
      'assets/img/respiro_della_luna/consegna_ultimo_fotogramma_v1.webp';

  late final RegiaDellaScena _regia =
      RegiaDellaScena(widget.fabbrica ?? () => LettoreDiScena.vero(_video));

  /// **PRIMA LA SCENA, POI IL PANNELLO** (FXA.08): la scena ascolta la
  /// regia, cosi' il pannello e il pulsante compaiono quando il video finisce
  /// o il tocco lo salta, non mentre gira. Prima la schermata non ascoltava
  /// la regia, e il pannello stava sopra il video dal primo fotogramma.
  void _quandoLaScenaCambia() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _regia.addListener(_quandoLaScenaCambia);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    unawaited(_regia.avvia(context));
  }

  @override
  void dispose() {
    _regia.removeListener(_quandoLaScenaCambia);
    _regia.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final ferma = _regia.ferma;
    final accese =
        widget.perle.where((p) => p.stato == StatoDellaPerla.accesa).length;
    return Scaffold(
      backgroundColor: palette.deepest,
      body: IlToccoCheSalta(
        inCorso: _regia.inCorso,
        onSalta: _regia.salta,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: Image.asset(ferma ? _ultimoFotogramma : _primoFotogramma,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      ColoredBox(color: palette.deepest)),
            ),
            if (_regia.filmatoInScena && (!ferma || _regia.saltata))
              Positioned.fill(
                child: IlFilmatoCheSfuma(
                  saltato: _regia.saltata,
                  child: _regia.disegna(),
                ),
              ),
            if (ferma)
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: TweenAnimationBuilder<double>(
                    key: const Key('consegna_comparsa'),
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 700),
                    builder: (context, v, figlio) =>
                        Opacity(opacity: v, child: figlio),
                    child: Padding(
                      padding: const EdgeInsets.all(SpacingTokens.lg),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PannelloDipinto(
                            child: Text(
                                'La tua collana è completa: $accese perle '
                                'accese. Una nuova collana comincia oggi.',
                                textAlign: TextAlign.center,
                                style: TypographyTokens.titoloScheda()
                                    .copyWith(color: palette.goldSoft)),
                          ),
                          const SizedBox(height: SpacingTokens.md),
                          PulsanteDipinto(
                            key: const Key('consegna_continua'),
                            testo: 'Comincia una nuova collana',
                            larghezzaPiena: true,
                            onTap: widget.onFinita,
                          ),
                        ],
                      ),
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

/// La striscia dipinta su cui sta la guida della Collana (FY.08): il pezzo del
/// pulsante largo, allungato in nove parti, con il testo al centro.
class _LaStrisciaDellaGuida extends StatelessWidget {
  const _LaStrisciaDellaGuida({required this.child});

  final Widget child;

  static const double _altezzaMinima = 56;

  @override
  Widget build(BuildContext context) {
    const scala = PulsanteDipinto.altezzaDellImmagine / _altezzaMinima;
    final angolo = PulsanteDipinto.taglio.left / scala;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: _altezzaMinima),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned.fill(
            child: ImmagineANoveParti(
              asset: PulsanteDipinto.immagine,
              misura: Size(1133, PulsanteDipinto.altezzaDellImmagine),
              taglio: PulsanteDipinto.taglio,
              scala: scala,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: angolo * 0.6, vertical: SpacingTokens.xs),
            child: child,
          ),
        ],
      ),
    );
  }
}
