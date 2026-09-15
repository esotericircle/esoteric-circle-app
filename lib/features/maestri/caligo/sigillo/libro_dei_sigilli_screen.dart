import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/astro/data_italiana.dart';
import '../../../../core/chat/la_marca_del_genere.dart';
import '../../../../core/config/app_flags.dart';
import '../../../../core/magic/il_sigillo_dal_modello.dart';
import '../../../../core/magic/il_sigillo_vivo.dart';
import '../../../../core/magic/intention_sigil.dart';
import '../../../../core/magic/la_voce_del_sigillo.dart';
import '../../../../core/magic/libro_dei_sigilli.dart';
import '../../../../core/maestro/maestro.dart';
import '../../../../design_system/components/cosmos_background.dart';
import '../../../../design_system/components/depth_card.dart';
import '../../../../design_system/components/titolo_che_non_si_rompe.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/theme/maestro_scope.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import '../../../../design_system/transizioni/passaggio_del_cerchio.dart';
import '../../../../design_system/transizioni/velo_del_cerchio.dart';
import '../../../../design_system/typography/paragrafi_di_lettura.dart';
import '../../../../services/il_libro_del_cerchio.dart';
import '../../../../services/lo_sfondo_del_telefono.dart';
import '../../rotta_arte.dart';
import 'i_pezzi_del_sigillo.dart';
import 'il_segno_del_sigillo.dart';

/// **IL LIBRO DEI SIGILLI.** Ordine DO voce 06, 15 settembre 2026.
///
/// E' il posto dove stanno i sigilli della persona: prima quelli arrivati
/// alla loro data, con la domanda di Caligo, poi i vivi con la loro luce e la
/// data che si avvicina, poi i compiuti e i lasciati, in ordine di tempo. **E'
/// la risposta a "cosa mi rimane"**, e senza questa schermata nessun'altra
/// voce dell'ordine ha un posto dove esistere.
///
/// **Nessun contatore in vista**, voce DO.04: la carica si legge dalla luce
/// del segno, mai da un numero.
class LibroDeiSigilliScreen extends StatefulWidget {
  const LibroDeiSigilliScreen({
    super.key,
    this.libro,
    this.chiamata,
    this.porta = const PortaDelloSfondo(),
  });

  final LibroDeiSigilli? libro;
  final ChiamataDelSigillo? chiamata;
  final PortaDelloSfondo porta;

  static Route<void> route({
    LibroDeiSigilli? libro,
    ChiamataDelSigillo? chiamata,
    PortaDelloSfondo porta = const PortaDelloSfondo(),
  }) =>
      PassaggioDelCerchio.rotta<void>((_) => MaestroScope(
            maestro: Maestro.caligo,
            child: LibroDeiSigilliScreen(
                libro: libro, chiamata: chiamata, porta: porta),
          ));

  @override
  State<LibroDeiSigilliScreen> createState() => _LibroDeiSigilliScreenState();
}

class _LibroDeiSigilliScreenState extends State<LibroDeiSigilliScreen> {
  LibroDeiSigilli get _libro => widget.libro ?? libroDelCerchio;

  @override
  void initState() {
    super.initState();
    _libro.addListener(_cambiato);
    unawaited(_libro.apri());
  }

  void _cambiato() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _libro.removeListener(_cambiato);
    super.dispose();
  }

  void _apri(SigilloVivo s) {
    Navigator.of(context).push(SigilloDelLibroScreen.route(
        id: s.id,
        libro: widget.libro,
        chiamata: widget.chiamata,
        porta: widget.porta));
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final scaduti = _libro.scaduti;
    final vivi = _libro.vivi;
    final chiusi = _libro.chiusi;
    return Scaffold(
      backgroundColor: ColorTokens.neutralDeepest,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: palette.goldSoft),
        title: TitoloCheNonSiRompe(
            testo: 'Il Libro dei Sigilli',
            stile: TypographyTokens.titoloDiSchermata()
                .copyWith(color: palette.goldSoft)),
        actions: const [AngoloDellaBarra()],
      ),
      body: CosmosBackground(
        seed: 29,
        child: SafeArea(
          child: ListView(
            key: const Key('libro_dei_sigilli'),
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
            children: [
              const SizedBox(height: SpacingTokens.md),
              Text(
                'Qui stanno i tuoi sigilli. Si caricano col dito e si '
                'rinnovano. Alla loro data si chiudono.',
                textAlign: TextAlign.center,
                style: TypographyTokens.corpo()
                    .copyWith(color: ColorTokens.textSecondary, height: 1.45),
              ),
              if (_libro.tutti.isEmpty && _libro.aperto) ...[
                const SizedBox(height: SpacingTokens.xl),
                ParagrafiDiLettura(
                  key: const Key('libro_vuoto'),
                  testo: 'Il Libro è vuoto. Il primo sigillo si traccia dalla '
                      'schermata del Sigillo dell\'Intenzione.',
                  stile: TypographyTokens.lettura().copyWith(height: 1.45),
                ),
              ],
              if (scaduti.isNotEmpty) ...[
                _Intestazione('ARRIVATI ALLA LORO DATA', palette: palette),
                for (final s in scaduti)
                  Padding(
                    padding: const EdgeInsets.only(bottom: SpacingTokens.md),
                    child: LaDomandaDiCaligo(
                      sigillo: s,
                      libro: _libro,
                      palette: palette,
                      chiamata: widget.chiamata,
                      porta: widget.porta,
                      suApri: () => _apri(s),
                    ),
                  ),
              ],
              if (vivi.isNotEmpty) ...[
                _Intestazione('VIVI', palette: palette),
                for (final s in vivi)
                  _VoceDelLibro(
                      sigillo: s,
                      adesso: _libro.adesso,
                      palette: palette,
                      onTap: () => _apri(s)),
              ],
              if (chiusi.isNotEmpty) ...[
                _Intestazione('COMPIUTI E LASCIATI', palette: palette),
                for (final s in chiusi)
                  _VoceDelLibro(
                      sigillo: s,
                      adesso: _libro.adesso,
                      palette: palette,
                      onTap: () => _apri(s)),
              ],
              const SizedBox(height: SpacingTokens.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _Intestazione extends StatelessWidget {
  const _Intestazione(this.testo, {required this.palette});

  final String testo;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(
            top: SpacingTokens.xl, bottom: SpacingTokens.sm),
        child: Text(testo,
            style: TypographyTokens.etichetta()
                .copyWith(color: palette.goldSoft, letterSpacing: 2)),
      );
}

/// **COME SI DIPINGE UN SIGILLO NEL LIBRO**: il colore e la luce, dallo
/// stato. Il compiuto e' sigillato nell'oro e a luce piena; il lasciato e'
/// spento e grigio; il vivo e l'arrivato hanno la loro via e la loro carica.
({Color colore, double luce}) aspettoDi(
    SigilloVivo s, DateTime adesso, MaestroPalette palette) {
  return switch (s.statoA(adesso)) {
    StatoDelSigillo.compiuto => (colore: palette.goldSoft, luce: 1.0),
    StatoDelSigillo.lasciato => (colore: ColorTokens.textMuted, luce: 0.0),
    _ => (colore: coloreDellaVia(s.via), luce: s.luceA(adesso)),
  };
}

/// Come si dice lo stato, in parole.
String statoInParole(SigilloVivo s, DateTime adesso) =>
    switch (s.statoA(adesso)) {
      StatoDelSigillo.vivo => 'Vivo',
      StatoDelSigillo.scaduto => 'Arrivato alla sua data',
      StatoDelSigillo.compiuto => 'Compiuto',
      StatoDelSigillo.lasciato => 'Lasciato andare',
    };

String _laRigaDelTempo(SigilloVivo s, DateTime adesso) =>
    switch (s.statoA(adesso)) {
      StatoDelSigillo.vivo =>
        'Caligo chiede com\'è andata il ${dataItalianaEstesa(s.scadenza)}',
      StatoDelSigillo.scaduto =>
        'Arrivato il ${dataItalianaEstesa(s.scadenza)}',
      StatoDelSigillo.compiuto =>
        'Compiuto il ${dataItalianaEstesa(s.chiusoIl ?? s.scadenza)}',
      StatoDelSigillo.lasciato =>
        'Lasciato andare il ${dataItalianaEstesa(s.chiusoIl ?? s.scadenza)}',
    };

/// Una voce del Libro: il segno piccolo con la sua luce, l'intenzione, la
/// via e la data.
class _VoceDelLibro extends StatelessWidget {
  const _VoceDelLibro({
    required this.sigillo,
    required this.adesso,
    required this.palette,
    required this.onTap,
  });

  final SigilloVivo sigillo;
  final DateTime adesso;
  final MaestroPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final a = aspettoDi(sigillo, adesso, palette);
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
      child: GestureDetector(
        key: Key('libro_voce_${sigillo.id}'),
        onTap: onTap,
        child: DepthCard(
          reveal: false,
          child: Row(
            children: [
              SizedBox(
                width: 72,
                height: 72,
                child: CustomPaint(
                  size: const Size(72, 72),
                  painter: SegnoDelSigilloPainter(
                    cammino: IntentionSigil.cammino(sigillo.riformulata),
                    colore: a.colore,
                    luce: a.luce,
                  ),
                ),
              ),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sigillo.intenzione,
                        style: TypographyTokens.corpo()
                            .copyWith(color: ColorTokens.textPrimary)),
                    const SizedBox(height: SpacingTokens.xxs),
                    Text(sigillo.via.nome,
                        style: TypographyTokens.corpo()
                            .copyWith(color: coloreDellaVia(sigillo.via))),
                    Text(_laRigaDelTempo(sigillo, adesso),
                        style: TypographyTokens.corpo()
                            .copyWith(color: ColorTokens.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// **LA FINE DEL CICLO.** Ordine DO voce 05: alla data, Caligo chiede com'e'
/// andata. Una domanda sola, tre risposte. **Senza una fine non esiste il
/// senso di aver ottenuto.**
class LaDomandaDiCaligo extends StatelessWidget {
  const LaDomandaDiCaligo({
    super.key,
    required this.sigillo,
    required this.libro,
    required this.palette,
    required this.chiamata,
    required this.porta,
    this.suApri,
  });

  final SigilloVivo sigillo;
  final LibroDeiSigilli libro;
  final MaestroPalette palette;
  final ChiamataDelSigillo? chiamata;
  final PortaDelloSfondo porta;

  /// Nel Libro la domanda porta alla scheda del sigillo; nella scheda no.
  final VoidCallback? suApri;

  @override
  Widget build(BuildContext context) {
    final a = aspettoDi(sigillo, libro.adesso, palette);
    return DepthCard(
      key: Key('libro_domanda_${sigillo.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (suApri != null)
            GestureDetector(
              onTap: suApri,
              child: Row(
                children: [
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: CustomPaint(
                      size: const Size(56, 56),
                      painter: SegnoDelSigilloPainter(
                        cammino: IntentionSigil.cammino(sigillo.riformulata),
                        colore: a.colore,
                        luce: a.luce,
                      ),
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.md),
                  Expanded(
                    child: Text(sigillo.intenzione,
                        style: TypographyTokens.corpo()
                            .copyWith(color: ColorTokens.textPrimary)),
                  ),
                ],
              ),
            ),
          if (suApri != null) const SizedBox(height: SpacingTokens.sm),
          Text(LaVoceDelSigillo.laDomanda,
              key: const Key('libro_la_domanda'),
              style: TypographyTokens.titoloSezione()
                  .copyWith(color: palette.goldSoft)),
          const SizedBox(height: SpacingTokens.md),
          LeTreRisposte(
            sigillo: sigillo,
            libro: libro,
            palette: palette,
            chiamata: chiamata,
            porta: porta,
            rinnovo: LaVoceDelSigillo.loRinnovo,
          ),
        ],
      ),
    );
  }
}

/// **LE TRE RISPOSTE**: si e' compiuto, lo lascio andare, lo rinnovo. Le
/// stesse dalla domanda alla scadenza e dalla scheda di un sigillo vivo,
/// perche' dal Libro *"si rinnova, si dichiara il compimento"*, voce DO.06.
class LeTreRisposte extends StatefulWidget {
  const LeTreRisposte({
    super.key,
    required this.sigillo,
    required this.libro,
    required this.palette,
    required this.chiamata,
    required this.porta,
    required this.rinnovo,
  });

  final SigilloVivo sigillo;
  final LibroDeiSigilli libro;
  final MaestroPalette palette;
  final ChiamataDelSigillo? chiamata;
  final PortaDelloSfondo porta;

  /// "Lo rinnovo" alla scadenza, "Cambia la data" su un sigillo ancora vivo.
  final String rinnovo;

  @override
  State<LeTreRisposte> createState() => _LeTreRisposteState();
}

class _LeTreRisposteState extends State<LeTreRisposte> {
  bool _scrive = false;

  Future<void> _compiuto() async {
    // Il navigatore si prende PRIMA delle attese: nel Libro, dichiarato il
    // compimento, questa domanda sparisce dalla lista e con lei il contesto.
    final allaScheda = _allaScheda();
    setState(() => _scrive = true);
    // **IL TESTO DEL COMPIMENTO NOMINA L'INTENZIONE**, voce DO.05 e DO.10:
    // dal modello se regge alle guardie, di casa altrimenti.
    final r = await IlSigilloDalModello.compimento(
      intenzione: widget.sigillo.intenzione,
      forma: LaMarcaDelGenere.formaCorrente,
      chiamata: widget.chiamata,
    );
    await widget.libro.dichiara(widget.sigillo.id, StatoDelSigillo.compiuto,
        testoDelCompimento: r.testo);
    if (mounted) setState(() => _scrive = false);
    allaScheda();
  }

  Future<void> _lasciato() async {
    final allaScheda = _allaScheda();
    await widget.libro.dichiara(widget.sigillo.id, StatoDelSigillo.lasciato);
    allaScheda();
  }

  /// Dopo la dichiarazione si va alla scheda, dove il sigillo chiuso resta:
  /// e' la risposta a *"cosa ho ottenuto"*. Se ci si e' gia', la scheda si
  /// aggiorna da sola e il passo non fa niente.
  VoidCallback _allaScheda() {
    if (context.findAncestorWidgetOfExactType<SigilloDelLibroScreen>() !=
        null) {
      return () {};
    }
    final navigatore = Navigator.of(context);
    final rotta = SigilloDelLibroScreen.route(
        id: widget.sigillo.id,
        libro: widget.libro,
        chiamata: widget.chiamata,
        porta: widget.porta);
    return () => navigatore.push(rotta);
  }

  Future<void> _rinnova() async {
    final oggi = widget.libro.adesso;
    var scelta = TempoDelSigillo.mese.da(oggi)!;
    final conferma = await foglioDelCerchio<bool>(
      context: context,
      backgroundColor: widget.palette.deepest,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.lg),
          child: StatefulBuilder(
            builder: (ctx, aggiorna) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Una data nuova',
                    style: TypographyTokens.titoloSezione()
                        .copyWith(color: widget.palette.goldSoft)),
                const SizedBox(height: SpacingTokens.xs),
                Text('Il segno riparte spento e si riaccende a ogni carica.',
                    style: TypographyTokens.corpo()
                        .copyWith(color: ColorTokens.textSecondary)),
                const SizedBox(height: SpacingTokens.md),
                LaDataDelSigillo(
                  oggi: oggi,
                  scadenza: scelta,
                  palette: widget.palette,
                  onScelta: (d) => aggiorna(() => scelta = d),
                ),
                const SizedBox(height: SpacingTokens.lg),
                PulsanteDelSigillo(
                  key: const Key('libro_rinnova_conferma'),
                  testo: 'Rinnova il sigillo',
                  palette: widget.palette,
                  onPressed: () => Navigator.of(ctx).pop(true),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (conferma != true) return;
    await widget.libro.rinnova(widget.sigillo.id, scelta);
  }

  @override
  Widget build(BuildContext context) {
    if (_scrive) {
      return Text('Caligo scrive per te...',
          key: const Key('libro_scrive'),
          textAlign: TextAlign.center,
          style: TypographyTokens.corpo()
              .copyWith(color: ColorTokens.textSecondary));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PulsanteDelSigillo(
          key: Key('libro_compiuto_${widget.sigillo.id}'),
          testo: LaVoceDelSigillo.siECompiuto,
          palette: widget.palette,
          onPressed: _compiuto,
        ),
        const SizedBox(height: SpacingTokens.sm),
        PulsanteLeggeroDelSigillo(
          key: Key('libro_lasciato_${widget.sigillo.id}'),
          testo: LaVoceDelSigillo.loLascioAndare,
          palette: widget.palette,
          onPressed: _lasciato,
        ),
        const SizedBox(height: SpacingTokens.sm),
        PulsanteLeggeroDelSigillo(
          key: Key('libro_rinnova_${widget.sigillo.id}'),
          testo: widget.rinnovo,
          palette: widget.palette,
          onPressed: _rinnova,
        ),
      ],
    );
  }
}

/// **LA SCHEDA DI UN SIGILLO**, voce DO.06: il segno, l'intenzione per
/// esteso, la via, la data in cui e' stato tracciato e quella di scadenza,
/// lo stato. Da qui si carica, si mette come sfondo, si rinnova e si
/// dichiara il compimento.
class SigilloDelLibroScreen extends StatefulWidget {
  const SigilloDelLibroScreen({
    super.key,
    required this.id,
    this.libro,
    this.chiamata,
    this.porta = const PortaDelloSfondo(),
  });

  final String id;
  final LibroDeiSigilli? libro;
  final ChiamataDelSigillo? chiamata;
  final PortaDelloSfondo porta;

  static Route<void> route({
    required String id,
    LibroDeiSigilli? libro,
    ChiamataDelSigillo? chiamata,
    PortaDelloSfondo porta = const PortaDelloSfondo(),
  }) =>
      PassaggioDelCerchio.rotta<void>((_) => MaestroScope(
            maestro: Maestro.caligo,
            child: SigilloDelLibroScreen(
                id: id, libro: libro, chiamata: chiamata, porta: porta),
          ));

  @override
  State<SigilloDelLibroScreen> createState() => _SigilloDelLibroScreenState();
}

class _SigilloDelLibroScreenState extends State<SigilloDelLibroScreen> {
  LibroDeiSigilli get _libro => widget.libro ?? libroDelCerchio;

  /// Vero subito dopo una carica, per dire che il segno si e' acceso.
  bool _appenaCaricato = false;

  @override
  void initState() {
    super.initState();
    _libro.addListener(_cambiato);
    if (!_libro.aperto) unawaited(_libro.apri());
  }

  void _cambiato() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _libro.removeListener(_cambiato);
    super.dispose();
  }

  Future<void> _carica() async {
    final ok = await _libro.caricaIlSigillo(widget.id);
    if (mounted && ok) setState(() => _appenaCaricato = true);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final s = _libro.diId(widget.id);
    final adesso = _libro.adesso;
    final stato = s?.statoA(adesso);
    return Scaffold(
      backgroundColor: ColorTokens.neutralDeepest,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: palette.goldSoft),
        title: TitoloCheNonSiRompe(
            testo: 'Il tuo sigillo',
            stile: TypographyTokens.titoloDiSchermata()
                .copyWith(color: palette.goldSoft)),
        actions: const [AngoloDellaBarra()],
      ),
      body: CosmosBackground(
        seed: 31,
        child: SafeArea(
          child: s == null
              ? const SizedBox.shrink()
              : ListView(
                  key: const Key('libro_scheda'),
                  padding:
                      const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
                  children: [
                    const SizedBox(height: SpacingTokens.md),
                    _ilSegno(s, stato!, adesso, palette),
                    const SizedBox(height: SpacingTokens.sm),
                    _laRigaDellaCarica(s, stato, adesso, palette),
                    const SizedBox(height: SpacingTokens.lg),
                    if (stato == StatoDelSigillo.compiuto &&
                        s.testoDelCompimento != null) ...[
                      DepthCard(
                        child: ParagrafiDiLettura(
                          key: const Key('libro_testo_compimento'),
                          testo: s.testoDelCompimento!,
                          stile:
                              TypographyTokens.lettura().copyWith(height: 1.5),
                        ),
                      ),
                      const SizedBox(height: SpacingTokens.md),
                    ],
                    if (stato == StatoDelSigillo.lasciato) ...[
                      DepthCard(
                        child: ParagrafiDiLettura(
                          key: const Key('libro_testo_lasciato'),
                          testo: LaVoceDelSigillo.lasciato,
                          stile:
                              TypographyTokens.lettura().copyWith(height: 1.5),
                        ),
                      ),
                      const SizedBox(height: SpacingTokens.md),
                    ],
                    _laScheda(s, stato, palette),
                    const SizedBox(height: SpacingTokens.lg),
                    if (stato != StatoDelSigillo.lasciato) ...[
                      IlSigilloSulTelefono(
                        via: s.via,
                        cammino: IntentionSigil.cammino(s.riformulata),
                        palette: palette,
                        porta: widget.porta,
                      ),
                      const SizedBox(height: SpacingTokens.lg),
                    ],
                    if (stato == StatoDelSigillo.scaduto)
                      LaDomandaDiCaligo(
                        sigillo: s,
                        libro: _libro,
                        palette: palette,
                        chiamata: widget.chiamata,
                        porta: widget.porta,
                      )
                    else if (stato == StatoDelSigillo.vivo) ...[
                      Text('PRIMA DELLA DATA',
                          style: TypographyTokens.etichetta().copyWith(
                              color: palette.goldSoft, letterSpacing: 2)),
                      const SizedBox(height: SpacingTokens.sm),
                      LeTreRisposte(
                        sigillo: s,
                        libro: _libro,
                        palette: palette,
                        chiamata: widget.chiamata,
                        porta: widget.porta,
                        rinnovo: 'Cambia la data',
                      ),
                      // **IL COMANDO DI COLLAUDO**, solo nella Demo: porta il
                      // sigillo alla sua data, per provare la domanda della
                      // voce DO.05 senza aspettare un mese.
                      if (AppFlags.isDemo) ...[
                        const SizedBox(height: SpacingTokens.md),
                        TextButton(
                          key: const Key('libro_demo_scadenza'),
                          onPressed: () =>
                              _libro.anticipaLaScadenzaPerIlCollaudo(widget.id),
                          child: Text('Porta alla data (Demo)',
                              style: TypographyTokens.corpo()
                                  .copyWith(color: ColorTokens.textMuted)),
                        ),
                      ],
                    ],
                    const SizedBox(height: SpacingTokens.xl),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _ilSegno(SigilloVivo s, StatoDelSigillo stato, DateTime adesso,
      MaestroPalette palette) {
    final a = aspettoDi(s, adesso, palette);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
      child: CaricaColDito(
        cammino: IntentionSigil.cammino(s.riformulata),
        colore: a.colore,
        luce: a.luce,
        attiva: s.siPuoCaricareA(adesso),
        onCompiuta: _carica,
      ),
    );
  }

  /// **COSA DEVO FARE?** Voce DO.03: si carica col dito, e il segno cambia.
  Widget _laRigaDellaCarica(SigilloVivo s, StatoDelSigillo stato,
      DateTime adesso, MaestroPalette palette) {
    final String testo;
    if (stato != StatoDelSigillo.vivo) {
      testo = statoInParole(s, adesso);
    } else if (_appenaCaricato) {
      testo = 'Il segno si è acceso. Si carica di nuovo domani.';
    } else if (s.siPuoCaricareA(adesso)) {
      testo = 'Ripassa il segno col dito, dal cerchio alla barra: si accende '
          'un poco ogni volta.';
    } else {
      testo = 'Per oggi la carica è fatta. Il segno ti aspetta domani.';
    }
    return Text(testo,
        key: const Key('libro_riga_della_carica'),
        textAlign: TextAlign.center,
        style: TypographyTokens.corpo().copyWith(
            color:
                _appenaCaricato ? palette.goldSoft : ColorTokens.textSecondary,
            height: 1.45));
  }

  Widget _laScheda(
      SigilloVivo s, StatoDelSigillo stato, MaestroPalette palette) {
    TextStyle etichetta() => TypographyTokens.etichetta()
        .copyWith(color: palette.goldSoft, letterSpacing: 2);
    TextStyle valore() => TypographyTokens.corpo()
        .copyWith(color: ColorTokens.textPrimary, height: 1.4);
    return DepthCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (s.titolo != null) ...[
            Text(s.titolo!,
                style: TypographyTokens.titoloSezione()
                    .copyWith(color: palette.goldSoft)),
            const SizedBox(height: SpacingTokens.xs),
          ],
          if (s.responso != null) ...[
            ParagrafiDiLettura(
                testo: s.responso!,
                stile: TypographyTokens.lettura().copyWith(height: 1.45)),
            const SizedBox(height: SpacingTokens.md),
          ],
          Text('L\'INTENZIONE', style: etichetta()),
          const SizedBox(height: SpacingTokens.xxs),
          ParagrafiDiLettura(
              key: const Key('libro_intenzione'),
              testo: s.intenzione,
              stile: TypographyTokens.lettura().copyWith(height: 1.45)),
          const SizedBox(height: SpacingTokens.sm),
          Text('LA VIA', style: etichetta()),
          Text(s.via.nome,
              style: TypographyTokens.corpo()
                  .copyWith(color: coloreDellaVia(s.via))),
          const SizedBox(height: SpacingTokens.sm),
          Text('TRACCIATO IL', style: etichetta()),
          Text(dataItalianaEstesa(s.nascita), style: valore()),
          const SizedBox(height: SpacingTokens.sm),
          Text('LA DATA', style: etichetta()),
          Text(dataItalianaEstesa(s.scadenza),
              key: const Key('libro_scadenza'), style: valore()),
          const SizedBox(height: SpacingTokens.sm),
          Text('LO STATO', style: etichetta()),
          Text(statoInParole(s, _libro.adesso),
              key: const Key('libro_stato'), style: valore()),
        ],
      ),
    );
  }
}
