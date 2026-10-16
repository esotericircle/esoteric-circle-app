import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/condivisione/porta_della_condivisione.dart';
import '../../core/condivisione/premio_della_condivisione.dart';
import '../../design_system/components/icona_degli_eos.dart';
import '../../core/lunario/il_listino_del_respiro.dart';
import '../../core/lunario/il_respiro_della_luna.dart';
import '../../core/lunario/la_collana_delle_lune.dart';
import 'gli_eos_del_respiro.dart';
import '../../core/maestro/maestro.dart';
import '../../design_system/components/titolo_che_non_si_rompe.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';
import '../maestri/rotta_arte.dart';
import '../maestri/widgets/foglio_delle_fonti.dart';
import '../scene/la_scena_in_video.dart';
import '../synastry/sinastria_share_card.dart' show captureBoundaryPng;

const String _assetCollana =
    'assets/img/respiro_della_luna/collana/';

/// **LA COLLANA DELLE LUNE.** Ordine FX voce FX.05, 16 ottobre 2026.
///
/// Mostra il ciclo in corso perla per perla, con la ricucitura per i giorni
/// spenti recenti; se il ciclo precedente si e' chiuso con almeno un giorno
/// respirato e la sua consegna non e' mai partita, la precede la scena
/// della consegna.
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

/// La vista del ciclo in corso: le perle, la ricucitura, lo scrigno delle
/// collane passate e la condivisione.
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

  // **IL BORSELLINO DEGLI EOS, non un numero promesso a vuoto.** Linee Guida
  // UX V13, sezione 4: "quando la fonte non ha parlato, il numero non si
  // indovina e non si scrive a mano, si tace". La porta server che vende la
  // ricucitura (`ListinoDegliEos.perlaRicucita`) non e' ancora pubblicata
  // (R3 dell'ordine FX): finche' non lo e', `GliEosDelRespiro` non ha mai un
  // credito da spendere, e questo tasto lo dichiara invece di fingere una
  // spesa che non succede davvero.
  late final GliEosDelRespiro _eos = GliEosDelRespiro();

  @override
  void initState() {
    super.initState();
    unawaited(_eos.leggi());
  }

  @override
  void dispose() {
    _eos.dispose();
    super.dispose();
  }

  Future<void> _ricuci(DateTime giorno) async {
    const costo = IlListinoDelRespiro.costoRicucituraInEos;
    if (_eos.perleRicucite <= 0) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: widget.palette.deepest,
          title: const Text('Ricuci questa perla'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconaDegliEos(misura: 20, colore: widget.palette.goldSoft),
                  const SizedBox(width: SpacingTokens.xs),
                  Text('$costo Eos',
                      style: TypographyTokens.titoloScheda()
                          .copyWith(color: widget.palette.goldSoft)),
                ],
              ),
              const SizedBox(height: SpacingTokens.sm),
              const Text(
                  'Potrai riaccendere questo giorno con la Luna vera di '
                  'allora: arriva con il prossimo aggiornamento.'),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                  foregroundColor: widget.palette.goldSoft),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Va bene'),
            ),
          ],
        ),
      );
      return;
    }
    final conferma = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.palette.deepest,
        title: const Text('Ricuci questa perla'),
        content: const Text(
            'Usi una ricucitura già comprata per riaccendere questo giorno '
            'con la Luna vera di allora.'),
        actions: [
          TextButton(
            style:
                TextButton.styleFrom(foregroundColor: widget.palette.goldSoft),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Non ora'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Ricuci'),
          ),
        ],
      ),
    );
    if (conferma != true) return;
    if (!_eos.consumaUnaPerlaRicucita()) return;
    await widget.collana.ricuciUnaPerlaLocalmente(giorno, now: widget.now);
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

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final ciclo = widget.collana.cicloDi(widget.now);
    final perle = widget.collana.perle(widget.now);
    final accese = perle.where((p) => p.stato == StatoDellaPerla.accesa).length;
    final nome = widget.collana.nomeDelCiclo(ciclo.inizio);
    final ricucibili = widget.collana.giorniRicucibili(widget.now);
    return Scaffold(
      backgroundColor: palette.deepest,
      appBar: AppBar(
        backgroundColor: palette.deepest,
        elevation: 0,
        // **NESSUNA ICONA MATERIAL QUI DENTRO**, fuori dall'elenco
        // dichiarato della guardia `la_grafica_del_lunario_e_dipinta_test
        // .dart`: la freccia indietro resta quella automatica dell'AppBar
        // (come fa `calendario_lunare_screen.dart`), e "Condividi" e'
        // testo, non un'icona.
        iconTheme: IconThemeData(color: palette.goldSoft),
        title: TitoloCheNonSiRompe(
            testo: 'La Collana delle Lune',
            stile: TypographyTokens.titoloDiSchermata()),
        actions: [
          FoglioDelleFonti.bottone(context,
              palette: palette,
              testo: TestiDelleFonti.respiroDellaLuna,
              chiave: 'collana_delle_lune_fonti'),
          TextButton(
            key: const Key('collana_condividi'),
            onPressed: _rendiLaCard ? null : () => _condividi(nome, accese),
            child: _rendiLaCard
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Text(PremioDellaCondivisione.etichetta(context),
                    style: TypographyTokens.label(size: 13)
                        .copyWith(color: palette.goldSoft)),
          ),
          const AngoloDellaBarra(),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(SpacingTokens.lg),
              child: RepaintBoundary(
                key: _cardKey,
                child: _CartaDellaCollana(
                  palette: palette,
                  nome: nome,
                  perle: perle,
                  accese: accese,
                ),
              ),
            ),
            if (ricucibili.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.lg),
                child: Wrap(
                  spacing: SpacingTokens.sm,
                  children: [
                    for (final giorno in ricucibili)
                      ActionChip(
                        key: Key('collana_ricuci_${IlRespiroDellaLuna.data(giorno)}'),
                        label: Text('Ricuci il ${giorno.day}'),
                        onPressed: () => _ricuci(giorno),
                      ),
                  ],
                ),
              ),
            const Spacer(),
            if (widget.collana.scrigno.isNotEmpty)
              _LoScrignoDelleCollane(
                  palette: palette, scrigno: widget.collana.scrigno),
          ],
        ),
      ),
    );
  }
}

/// La card della collana, condivisibile: il nome del ciclo, le perle, il
/// conteggio. Lo stesso passaggio di `shareCardDelMese`.
class _CartaDellaCollana extends StatelessWidget {
  const _CartaDellaCollana({
    required this.palette,
    required this.nome,
    required this.perle,
    required this.accese,
  });

  final MaestroPalette palette;
  final String nome;
  final List<PerlaDellaCollana> perle;
  final int accese;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
      child: Stack(
        children: [
          Positioned.fill(
            child: ColoredBox(color: palette.surfaceElevated),
          ),
          Positioned.fill(
            child: Image.asset('${_assetCollana}scrigno_collana_v1.webp',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink()),
          ),
          _ContenutoDellaCarta(
              palette: palette, nome: nome, perle: perle, accese: accese),
        ],
      ),
    );
  }
}

/// Il testo e la fila di perle sopra lo sfondo dello scrigno.
class _ContenutoDellaCarta extends StatelessWidget {
  const _ContenutoDellaCarta({
    required this.palette,
    required this.nome,
    required this.perle,
    required this.accese,
  });

  final MaestroPalette palette;
  final String nome;
  final List<PerlaDellaCollana> perle;
  final int accese;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(nome,
              key: const Key('collana_nome_ciclo'),
              style:
                  TypographyTokens.titoloSezione().copyWith(color: palette.goldSoft)),
          Text('$accese perle accese di ${perle.length}',
              key: const Key('collana_conteggio'),
              style: TypographyTokens.didascalia()
                  .copyWith(color: Colors.white.withValues(alpha: 0.85))),
          const SizedBox(height: SpacingTokens.sm),
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Image.asset('${_assetCollana}fermaglio_falce_v1.webp',
                    height: 30,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                for (final p in perle) _Perla(perla: p),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Una singola perla della collana, nel suo stato.
class _Perla extends StatelessWidget {
  const _Perla({required this.perla});

  final PerlaDellaCollana perla;

  @override
  Widget build(BuildContext context) {
    final String asset;
    switch (perla.stato) {
      case StatoDellaPerla.accesa:
        asset = perla.immagine ?? '${_assetCollana}perla_accesa_v1.webp';
      case StatoDellaPerla.spenta:
        asset = '${_assetCollana}perla_spenta_v1.webp';
      case StatoDellaPerla.inAttesa:
        asset = '${_assetCollana}perla_finestra_v1.webp';
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: ClipOval(
        child: Image.asset(asset,
            key: Key('collana_perla_${IlRespiroDellaLuna.data(perla.giorno)}'),
            width: 30,
            height: 30,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox.shrink()),
      ),
    );
  }
}

/// Lo scrigno delle collane passate, in piccolo.
class _LoScrignoDelleCollane extends StatelessWidget {
  const _LoScrignoDelleCollane(
      {required this.palette, required this.scrigno});

  final MaestroPalette palette;
  final List<CollanaArchiviata> scrigno;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Lo scrigno delle collane',
              style:
                  TypographyTokens.label(size: 13).copyWith(color: palette.goldSoft)),
          const SizedBox(height: SpacingTokens.sm),
          SizedBox(
            height: 60,
            child: ListView(
              key: const Key('collana_scrigno'),
              scrollDirection: Axis.horizontal,
              children: [
                for (final c in scrigno.reversed)
                  Padding(
                    padding: const EdgeInsets.only(right: SpacingTokens.sm),
                    child: Column(
                      children: [
                        Image.asset(
                            '${_assetCollana}medaglia_luna_piena_v1.webp',
                            width: 32,
                            height: 32,
                            errorBuilder: (_, __, ___) =>
                                const SizedBox.shrink()),
                        Text(c.nome,
                            style: TypographyTokens.label(size: 12)
                                .copyWith(color: Colors.white70)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
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
              child: Image.asset(
                  ferma ? _ultimoFotogramma : _primoFotogramma,
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
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(SpacingTokens.md),
                        decoration: BoxDecoration(
                          color: palette.deepest.withValues(alpha: 0.82),
                          borderRadius:
                              BorderRadius.circular(SpacingTokens.radiusMd),
                        ),
                        child: Text(
                            'La tua collana è completa: $accese perle '
                            'accese. Una nuova collana comincia oggi.',
                            textAlign: TextAlign.center,
                            style: TypographyTokens.titoloScheda()
                                .copyWith(color: palette.goldSoft)),
                      ),
                      const SizedBox(height: SpacingTokens.md),
                      FilledButton(
                        key: const Key('consegna_continua'),
                        onPressed: widget.onFinita,
                        child: const Text('Comincia una nuova collana'),
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
