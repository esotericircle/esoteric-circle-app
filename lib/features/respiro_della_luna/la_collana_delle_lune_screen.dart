import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../core/cerchio/il_cerchio_sociale.dart';
import '../../core/condivisione/porta_della_condivisione.dart';
import '../../core/condivisione/premio_della_condivisione.dart';
import '../../core/entitlement/listino_degli_eos.dart';
import '../../core/entitlement/question_allowance.dart';
import '../../core/lunario/il_respiro_della_luna.dart';
import '../../core/lunario/la_collana_delle_lune.dart';
import '../../core/maestro/maestro.dart';
import '../../design_system/components/icona_degli_eos.dart';
import '../../design_system/components/la_conferma_della_spesa.dart';
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
  const LaCollanaDelleLuneScreen({super.key, this.now});

  final DateTime? now;

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

/// La vista del ciclo in corso: lo scrigno dipinto, la ricucitura, lo
/// scrigno delle collane passate e la condivisione.
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
  final GlobalKey _cardKey = GlobalKey();
  bool _rendiLaCard = false;

  /// Il giorno su cui e' posato l'ago col filo, mentre si ricuce.
  DateTime? _inRicucitura;

  T? _forse<T>() {
    try {
      return context.read<T>();
    } catch (senzaProvider) {
      debugPrint('Collana delle Lune: manca $T, ripiego ($senzaProvider)');
      return null;
    }
  }

  Future<void> _avviso(String titolo, String testo) {
    return finestraDipinta<void>(
      context,
      titolo: titolo,
      contenuto: Text(testo),
      azioni: (c) => [
        PulsanteDipinto(
          key: const Key('collana_avviso_va_bene'),
          testo: 'Va bene',
          larghezzaPiena: true,
          onTap: () => Navigator.of(c).pop(),
        ),
      ],
    );
  }

  /// **LA RICUCITURA VERA** (FXA.03). Si tocca una perla spenta ricucibile:
  /// compare l'ago col filo sulla perla, poi la conferma della spesa in Eos
  /// (la stessa dell'app, vestita coi pezzi dipinti). Pagato sul server, la
  /// perla passa dalla pittura spenta alla accesa in dissolvenza e il giorno
  /// risulta ricucito anche sul telefono.
  Future<void> _ricuci(DateTime giorno) async {
    setState(() => _inRicucitura = giorno);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 650));
      if (!mounted) return;
      final sociale = _forse<IlCerchioSociale>();
      if (sociale == null) {
        await _avviso(
            'Ricuci questa perla', EsitoDelGesto.silenzio.rigaPerLaPersona);
        return;
      }
      final consenso = await LaConfermaDellaSpesa.degliEos(context,
          costo: ListinoDegliEos.perlaRicucita.costo, vestito: confermaDipinta);
      if (consenso == null || !mounted) return;
      final ciclo = widget.collana.cicloDi(widget.now);
      final esito = await sociale.ricuciUnaPerlaDelRespiro(
          consenso: consenso, giorno: giorno, inizioCiclo: ciclo.inizio);
      if (!mounted) return;
      if (esito.ok) {
        // Il saldo che il server ha scalato arriva subito nel borsellino a
        // schermo, senza aspettare la prossima lettura dello stato.
        final saldo = esito.dati['saldo'];
        if (saldo is int)
          await _forse<QuestionAllowance>()?.applicaSaldo(saldo);
        await widget.collana.ricuciUnaPerlaLocalmente(giorno, now: widget.now);
      } else {
        await _avviso('Ricuci questa perla', esito.rigaPerLaPersona);
      }
    } finally {
      if (mounted) setState(() => _inRicucitura = null);
    }
  }

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
    final ricucibili = widget.collana.giorniRicucibili(widget.now);
    final oggiAcceso = accesi.contains(perle.indexWhere((p) =>
            IlRespiroDellaLuna.data(p.giorno) ==
            IlRespiroDellaLuna.data(widget.now)) +
        1);
    int numeroDelGiorno(DateTime g) =>
        perle.indexWhere((p) =>
            IlRespiroDellaLuna.data(p.giorno) == IlRespiroDellaLuna.data(g)) +
        1;

    final collana = LaCollanaDipinta(
      accesi: accesi,
      completa: completa,
      numeroDiPerle: perle.length,
      sopra: (context, scala) => Stack(
        children: [
          // **IL NOME E IL CONTO, DOVE IL VELLUTO LI LASCIA LEGGERE**: nel
          // velluto liscio dentro la collana, fra x 430 e 1010 e da y 1000
          // della pittura.
          Positioned(
            left: 430 * scala,
            width: 580 * scala,
            top: 950 * scala,
            child: Column(
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(nome,
                      key: const Key('collana_nome_ciclo'),
                      style: TypographyTokens.titoloSezione()
                          .copyWith(color: palette.goldSoft)),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                      '${accesi.length} perle accese di ${perle.length}',
                      key: const Key('collana_conteggio'),
                      style: TypographyTokens.didascalia()
                          .copyWith(color: coloreSulVelluto)),
                ),
              ],
            ),
          ),
          // **IL TOCCO SCEGLIE LA PERLA PIU' VICINA AL DITO.** Le perle a
          // schermo distano meno di un dito: zone di tocco larghe 44 punti
          // si sovrapponevano, e il tocco sul giorno 13 ricuciva il 14
          // (preso dalla prova della schermata). Un tocco solo sulla
          // pittura sceglie la perla ricucibile piu' vicina, entro mezzo
          // dito dal suo centro.
          if (ricucibili.isNotEmpty)
            Positioned.fill(
              child: GestureDetector(
                key: const Key('collana_tocchi_della_ricucitura'),
                behavior: HitTestBehavior.translucent,
                onTapUp: _inRicucitura != null
                    ? null
                    : (d) {
                        DateTime? scelto;
                        var distanza = 26.0;
                        for (final g in ricucibili) {
                          final n = numeroDelGiorno(g);
                          if (n <= 0 || n > LePerleDellaCollana.giorni.length) {
                            continue;
                          }
                          final p = LePerleDellaCollana.giorni[n - 1];
                          final dd = (Offset(p.x * scala, p.y * scala) -
                                  d.localPosition)
                              .distance;
                          if (dd < distanza) {
                            distanza = dd;
                            scelto = g;
                          }
                        }
                        if (scelto != null) unawaited(_ricuci(scelto));
                      },
              ),
            ),
          // I segni delle perle ricucibili, uno per giorno: non toccano
          // niente, dicono dove sta il centro di ciascuna (e le prove ci
          // toccano sopra).
          for (final g in ricucibili)
            if (numeroDelGiorno(g) > 0 &&
                numeroDelGiorno(g) <= LePerleDellaCollana.giorni.length)
              Positioned(
                left: LePerleDellaCollana.giorni[numeroDelGiorno(g) - 1].x *
                        scala -
                    4,
                top: LePerleDellaCollana.giorni[numeroDelGiorno(g) - 1].y *
                        scala -
                    4,
                width: 8,
                height: 8,
                child: IgnorePointer(
                  child: SizedBox(
                      key: Key('collana_ricuci_${IlRespiroDellaLuna.data(g)}')),
                ),
              ),
          // L'ago col filo, posato sulla perla che si sta ricucendo.
          if (_inRicucitura != null && numeroDelGiorno(_inRicucitura!) > 0)
            Positioned(
              left: LePerleDellaCollana
                          .giorni[numeroDelGiorno(_inRicucitura!) - 1].x *
                      scala -
                  36,
              top: LePerleDellaCollana
                          .giorni[numeroDelGiorno(_inRicucitura!) - 1].y *
                      scala -
                  40,
              width: 72,
              height: 74,
              child: IgnorePointer(
                child: Image.asset(
                    'assets/img/respiro_della_luna/comandi/ago_e_filo_v1.webp',
                    key: const Key('collana_ago_e_filo'),
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink()),
              ),
            ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: palette.deepest,
      appBar: AppBar(
        toolbarHeight: altezzaDellaBarraDelRespiro(context),
        backgroundColor: palette.deepest,
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
                child: AspectRatio(
                  aspectRatio: LePerleDellaCollana.larghezza /
                      LePerleDellaCollana.altezza,
                  child: LayoutBuilder(builder: (context, v) {
                    final scala = v.maxWidth / LePerleDellaCollana.larghezza;
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: RepaintBoundary(key: _cardKey, child: collana),
                        ),
                        // **LA GUIDA, MAI DA INDOVINARE.** Il fondatore, 16
                        // ottobre 2026: "l'utente deve sapere dov'e', cosa
                        // deve fare, per ottenere cosa, obiettivo ed
                        // eventualmente guida. Non puo' indovinare". Sta
                        // scritta nel velluto al centro della collana, sotto
                        // il nome del ciclo, cosi' lo scrigno resta a tutto
                        // schermo; fuori dalla card che si condivide.
                        // Dentro il velluto e sopra la medaglia: da y 1150
                        // a y 1830 della pittura, e il testo si rimpicciolisce
                        // invece di scendere sulle perle.
                        Positioned(
                          left: 390 * scala,
                          width: 660 * scala,
                          top: 1150 * scala,
                          height: 680 * scala,
                          child: IgnorePointer(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.topCenter,
                              child: SizedBox(
                                width: 660 * scala,
                                child: Column(
                                  key: const Key('collana_guida'),
                                  children: [
                                    Text(
                                        completa
                                            ? 'La collana è completa: tutte le '
                                                'perle di questa lunazione sono '
                                                'accese.'
                                            : oggiAcceso
                                                ? 'La perla di oggi è accesa. '
                                                    'Torna domani a respirare per '
                                                    'accendere la prossima.'
                                                : 'La perla di oggi è ancora '
                                                    'spenta: un minuto di respiro '
                                                    'con la Luna la accende.',
                                        key: const Key('collana_perla_di_oggi'),
                                        textAlign: TextAlign.center,
                                        style: TypographyTokens.etichetta()
                                            .copyWith(color: palette.goldSoft)),
                                    SizedBox(height: 30 * scala),
                                    Text(
                                        '${completa ? '' : 'Ogni giorno respirato accende una perla. '}'
                                        'Alla Luna nuova del ${ciclo.fine.day} '
                                        '${IlMeseInItaliano.mesi[ciclo.fine.month - 1].toLowerCase()} '
                                        'Medora ti consegna la collana.',
                                        key: const Key('collana_obiettivo'),
                                        textAlign: TextAlign.center,
                                        style: TypographyTokens.didascalia()
                                            .copyWith(color: coloreSulVelluto)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            if (ricucibili.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    SpacingTokens.lg, SpacingTokens.xs, SpacingTokens.lg, 0),
                child: Row(
                  key: const Key('collana_invito_ricucitura'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                          'Tocca una perla spenta recente per ricucirla:',
                          textAlign: TextAlign.center,
                          style: TypographyTokens.label(size: 13)
                              .copyWith(color: coloreSulVelluto)),
                    ),
                    const SizedBox(width: SpacingTokens.xs),
                    const IconaDegliEos(misura: 16, colore: coloreSulVelluto),
                    const SizedBox(width: 4),
                    Text('${ListinoDegliEos.perlaRicucita.costo} Eos',
                        style: TypographyTokens.label(size: 13)
                            .copyWith(color: coloreSulVelluto)),
                  ],
                ),
              ),
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
      {required this.palette, required this.perle, required this.onFinita});

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
      RegiaDellaScena(() => LettoreDiScena.vero(_video));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    unawaited(_regia.avvia(context));
  }

  @override
  void dispose() {
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
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
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
          ],
        ),
      ),
    );
  }
}
