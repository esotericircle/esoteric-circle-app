import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/maestro/maestro.dart';
import '../../core/sensi/la_suoneria.dart';
import '../../core/settings/settings_controller.dart';
import '../../core/synastry_approfondita/cielo_approfondito.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/components/titolo_che_non_si_rompe.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'lo_studio_di_medora.dart';

/// **LA SINASTRIA APPROFONDITA.** Ordine FT, 14 ottobre 2026.
///
/// **QUESTA SCHERMATA PORTA LA SCENA (FT.02) E IL CALCOLO (FT.05).** Le
/// voci sul contenuto del responso (FT.06-FT.11, i capitoli, i legami, il
/// Composito, gli intervalli di Keplero, Oggi fra voi, il Momento giusto,
/// il Ritratto) e il loro corpus (FT.12) arrivano a parte: qui i due cieli
/// e i loro aspetti si vedono gia' per intero, ma il testo di ogni capitolo
/// resta da scrivere finche' il corpus non esiste. Non e' un vicolo cieco:
/// e' dichiarato nel rapporto come lavoro ancora aperto.
class SinastriaApprofonditaScreen extends StatefulWidget {
  const SinastriaApprofonditaScreen({
    super.key,
    required this.nomeTuo,
    required this.cieloTuo,
    required this.nomeSuo,
    required this.cieloSuo,
    this.fabbricaDellaScena,
  });

  final String nomeTuo;
  final CieloApprofondito cieloTuo;
  final String nomeSuo;
  final CieloApprofondito cieloSuo;

  /// La finta del lettore video, per le prove headless.
  final FabbricaDellaScenaSinastria? fabbricaDellaScena;

  static Route<void> route({
    required String nomeTuo,
    required CieloApprofondito cieloTuo,
    required String nomeSuo,
    required CieloApprofondito cieloSuo,
  }) =>
      MaterialPageRoute(
        builder: (_) => SinastriaApprofonditaScreen(
          nomeTuo: nomeTuo,
          cieloTuo: cieloTuo,
          nomeSuo: nomeSuo,
          cieloSuo: cieloSuo,
        ),
      );

  @override
  State<SinastriaApprofonditaScreen> createState() =>
      _SinastriaApprofonditaScreenState();
}

class _SinastriaApprofonditaScreenState
    extends State<SinastriaApprofonditaScreen> with WidgetsBindingObserver {
  bool _reduceMotion = false;
  bool _avviata = false;
  LettoreDellaScenaSinastria? _lettore;
  bool _filmatoSospesoDaNoi = false;

  late final List<AspettoApprofondito> _aspetti =
      AspettiApprofonditi.fra(widget.cieloTuo, widget.cieloSuo);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.of(context).disableAnimations;
    if (_avviata) return;
    _avviata = true;
    WidgetsBinding.instance.addObserver(this);
    unawaited(_apriIlFilmato());
  }

  /// **IL VIDEO DELLA SCENA, una volta per apertura.** Stessa forma di
  /// `_apriIlFilmato` nella Stesa (FS voce A2): con Riduci Movimento la
  /// scena resta ferma, con la posa a mani aperte.
  Future<void> _apriIlFilmato() async {
    if (_reduceMotion) return;
    final lettore =
        (widget.fabbricaDellaScena ?? LettoreDellaScenaSinastria.vero)();
    _lettore = lettore;
    lettore.ascolta(() {
      if (mounted) setState(() {});
    });
    await lettore.apri();
    if (!mounted || !identical(_lettore, lettore) || !lettore.pronto) return;
    final suono = _forse<SettingsController>(context)?.suonoEVibrazione ??
        false;
    final muto = !suono || await LaSuoneria.spenta();
    if (!mounted) return;
    await lettore.volume(muto ? 0 : 1);
    if (!mounted || !identical(_lettore, lettore)) return;
    await lettore.avvia();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final lettore = _lettore;
    if (lettore == null || !lettore.pronto || lettore.finito) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      if (_filmatoSospesoDaNoi) return;
      _filmatoSospesoDaNoi = true;
      unawaited(lettore.sospendi());
    } else if (state == AppLifecycleState.resumed && _filmatoSospesoDaNoi) {
      _filmatoSospesoDaNoi = false;
      unawaited(lettore.avvia());
    }
  }

  Widget? get _filmatoInScena {
    final l = _lettore;
    if (l == null || l.fallito || !l.cominciato) return null;
    return l.disegna();
  }

  String get _posaDiMedora {
    final l = _lettore;
    return l == null || l.fallito
        ? GeometriaDelloStudio.posaDelleManiAperte
        : GeometriaDelloStudio.posaDellAstrolabio;
  }

  T? _forse<T>(BuildContext context, {bool osserva = false}) {
    try {
      return osserva ? context.watch<T>() : context.read<T>();
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _lettore?.chiudi();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // Stesso velo costante dei Tarocchi dopo la revisione del 15
        // ottobre 2026: semitrasparente gia' all'apertura.
        backgroundColor: palette.deepest.withValues(alpha: 0.16),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: palette.goldSoft),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Indietro',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: TitoloCheNonSiRompe(
            chiaveDelTesto: const Key('sinastria_approfondita_titolo'),
            testo: 'Sinastria approfondita',
            righe: 1,
            stile: TypographyTokens.titoloSezione()),
      ),
      body: CosmosBackground(
        key: const Key('sinastria_approfondita_sfondo'),
        seed: 7,
        showZodiac: false,
        child: SafeArea(
          top: false,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Builder(
                builder: (corpo) => Padding(
                  padding:
                      EdgeInsets.only(top: MediaQuery.paddingOf(corpo).top),
                  child: LoStudioDiMedora(
                    key: const Key('sinastria_approfondita_scena'),
                    posa: _posaDiMedora,
                    filmato: _filmatoInScena,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${widget.nomeTuo} e ${widget.nomeSuo}',
                        key: const Key('sinastria_approfondita_nomi'),
                        style: TypographyTokens.titoloSezione()
                            .copyWith(color: palette.goldSoft)),
                    const SizedBox(height: 16),
                    // **I CAPITOLI ARRIVANO CON FT.06-FT.12.** Qui, in
                    // attesa del corpus, l'elenco degli aspetti veri: non e'
                    // il responso finale, e' la prova che il calcolo (FT.05)
                    // alimenta davvero la lettura.
                    for (final a in _aspetti.take(5))
                      Padding(
                        key: Key(
                            'sinastria_aspetto_${a.tuo.name}_${a.suo.name}'),
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          a.frase(widget.nomeTuo, widget.nomeSuo),
                          style: TypographyTokens.corpo(),
                        ),
                      ),
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
