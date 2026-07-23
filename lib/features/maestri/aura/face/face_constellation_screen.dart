import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:provider/provider.dart';

import '../../../../core/archetypes/archetype_allowance.dart';
import '../../../../core/archetypes/archetype_sky.dart';
import '../../../../core/archetypes/archetype_transits.dart' show Pianeta;
import '../../../../core/entitlement/entitlement_service.dart';
import '../../../../core/entitlement/tier.dart';
import '../../../../core/face/face_classifier.dart';
import '../../../../core/face/face_corpus.dart';
import '../../../../core/face/face_history.dart';
import '../../../../core/face/face_trait.dart';
import '../../../../core/face/face_transits.dart';
import '../../../../core/maestro/maestro.dart';
import '../../../../design_system/components/cosmos_background.dart';
import '../../../../design_system/components/depth_card.dart';
import '../../../../design_system/components/scroll_reveal.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/theme/maestro_scope.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import '../../../../services/app_services.dart';
import '../../chat/chat_openers.dart';
import '../../chat/maestro_chat_screen.dart';
import 'face_constellation.dart';
import 'face_constellation_painter.dart';
import 'face_share_card.dart';
import 'face_silhouette.dart';

/// La Costellazione del Viso, dominio Aura.
///
/// La lettura dei tratti e' tutta nel cuore deterministico (`FaceClassifier`,
/// `FaceCorpus`): qui c'e' la messa in scena, nessuna AI, nessuna casualita'. Il
/// volto si rileva on-device coi contorni di ML Kit; nessuna immagine lascia il
/// dispositivo. Chi non ha fotocamera o nega il permesso passa dal ripiego
/// tattile, che alimenta lo stesso motore e porta allo stesso responso.
class FaceConstellationScreen extends StatefulWidget {
  const FaceConstellationScreen({
    super.key,
    this.clock,
    this.pianetiDelGiorno,
    this.readingIniziale,
    this.partiDalRipiego = false,
  });

  final DateTime Function()? clock;
  final Set<Pianeta> Function(DateTime)? pianetiDelGiorno;

  /// Una lettura gia' pronta, per i test e le anteprime: salta la cattura e va
  /// al responso in modo deterministico.
  final FaceReading? readingIniziale;

  /// Apre direttamente sul ripiego tattile, per le anteprime del ripiego.
  final bool partiDalRipiego;

  static Route<void> route({
    DateTime Function()? clock,
    Set<Pianeta> Function(DateTime)? pianetiDelGiorno,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => MaestroScope(
        child: FaceConstellationScreen(
          clock: clock,
          pianetiDelGiorno: pianetiDelGiorno,
        ),
      ),
    );
  }

  @override
  State<FaceConstellationScreen> createState() =>
      _FaceConstellationScreenState();
}

enum _Fase { soglia, cattura, risultato, ripiego }

class _FaceConstellationScreenState extends State<FaceConstellationScreen> {
  late final DateTime Function() _clock = widget.clock ?? DateTime.now;
  late final FaceHistory _storico = FaceHistory(clock: _clock);

  _Fase _fase = _Fase.soglia;
  bool _conCielo = false;
  bool _pronto = false;

  FaceReading? _reading;
  FaceConstellation? _costellazione;
  String? _fotoPath;

  @override
  void initState() {
    super.initState();
    _storico.carica().then((_) {
      if (!mounted) return;
      setState(() {
        _pronto = true;
        if (widget.readingIniziale != null) {
          _reading = widget.readingIniziale;
          _costellazione = FaceConstellation.da(FaceSilhouette.contorni());
          _fase = _Fase.risultato;
        } else if (widget.partiDalRipiego) {
          _fase = _Fase.ripiego;
        }
      });
    });
  }

  @override
  void dispose() {
    _storico.dispose();
    super.dispose();
  }

  Tier get _tier => context.read<EntitlementService>().tier;

  bool get _consentito => ArchetypeAllowance.consentito(
        fattiOggi: _storico.fattiOggi,
        tier: _tier,
      );

  Set<Pianeta> get _pianeti {
    final f = widget.pianetiDelGiorno ?? ArchetypeSky.pianetiDelGiorno;
    return f(_clock());
  }

  Future<void> _concludi(FaceReading reading, FaceConstellation cost,
      {String? fotoPath}) async {
    await _storico.registra(reading);
    if (!mounted) return;
    setState(() {
      _reading = reading;
      _costellazione = cost;
      _fotoPath = fotoPath;
      _fase = _Fase.risultato;
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.aura));
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: palette.deepest.withValues(alpha: 0.35),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: palette.goldSoft),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Indietro',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        // FittedBox cosi' "Costellazione del Viso" entra intero nella barra,
        // rimpicciolendosi se serve invece di troncarsi coi puntini.
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('Costellazione del Viso',
              maxLines: 1, style: TypographyTokens.display(size: 19)),
        ),
        actions: [
          IconButton(
            key: const Key('face_sources'),
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'Fonti e metodo',
            onPressed: () => _mostraFonti(context, palette),
          ),
        ],
      ),
      body: CosmosBackground(
        showZodiac: false,
        child: SafeArea(
          child: !_pronto
              ? const SizedBox.shrink()
              : switch (_fase) {
                  _Fase.soglia => _Soglia(
                      palette: palette,
                      consentito: _consentito,
                      rimanenti: ArchetypeAllowance.rimanenti(
                          fattiOggi: _storico.fattiOggi, tier: _tier),
                      ultimo: _storico.ultimo,
                      conCielo: _conCielo,
                      onCielo: (v) => setState(() => _conCielo = v),
                      onInizia: () => setState(() => _fase = _Fase.cattura),
                      onRipiego: () => setState(() => _fase = _Fase.ripiego),
                    ),
                  _Fase.cattura => _Cattura(
                      palette: palette,
                      onFatto: _concludi,
                      onRipiego: () => setState(() => _fase = _Fase.ripiego),
                    ),
                  _Fase.ripiego => _Ripiego(
                      palette: palette,
                      onFatto: (reading) => _concludi(
                          reading, FaceConstellation.da(FaceSilhouette.contorni())),
                    ),
                  _Fase.risultato => _Risultato(
                      palette: palette,
                      reading: _reading!,
                      costellazione: _costellazione!,
                      fotoPath: _fotoPath,
                      conCielo: _conCielo,
                      pianeti: _pianeti,
                      onCielo: (v) => setState(() => _conCielo = v),
                    ),
                },
        ),
      ),
    );
  }

  void _mostraFonti(BuildContext context, MaestroPalette palette) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheet) => Container(
        key: const Key('face_sources_sheet'),
        padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.md,
            SpacingTokens.lg, SpacingTokens.xl),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [palette.surfaceElevated, palette.deepest],
          ),
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(SpacingTokens.radiusXl)),
          border: Border.all(color: palette.gold.withValues(alpha: 0.3)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Fonti e metodo',
                  style: TypographyTokens.display(size: 19)
                      .copyWith(color: palette.goldSoft)),
              const SizedBox(height: SpacingTokens.sm),
              Text(FaceCorpus.fontiEMetodo,
                  style: TypographyTokens.body(size: 15).copyWith(
                      color: ColorTokens.textPrimary, height: 1.45)),
              const SizedBox(height: SpacingTokens.lg),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(sheet).pop(),
                  child: Text('Va bene',
                      style: TypographyTokens.label(size: 13)
                          .copyWith(color: palette.goldSoft)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// La soglia: si entra da qui, si sceglie il cielo di oggi PRIMA di iniziare, e
/// c'e' l'ingresso alternativo al ripiego tattile.
class _Soglia extends StatelessWidget {
  const _Soglia({
    required this.palette,
    required this.consentito,
    required this.rimanenti,
    required this.ultimo,
    required this.conCielo,
    required this.onCielo,
    required this.onInizia,
    required this.onRipiego,
  });

  final MaestroPalette palette;
  final bool consentito;
  final int? rimanenti;
  final FaceEsito? ultimo;
  final bool conCielo;
  final ValueChanged<bool> onCielo;
  final VoidCallback onInizia;
  final VoidCallback onRipiego;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: SpacingTokens.xl),
          Text('I tratti del tuo volto, una costellazione',
              style: TypographyTokens.display(size: 24)
                  .copyWith(color: palette.goldSoft)),
          const SizedBox(height: SpacingTokens.sm),
          Text(
            'La fotocamera legge la geometria del tuo viso e la unisce in una '
            'costellazione. I significati sono la Personologia, la fisiognomica '
            'di Jones e Tickle, con la nostra curatela.',
            style: TypographyTokens.body(size: 16)
                .copyWith(color: ColorTokens.textPrimary, height: 1.5),
          ),
          const SizedBox(height: SpacingTokens.md),
          // La rassicurazione sulla privacy.
          DepthCard(
            padding: const EdgeInsets.all(SpacingTokens.md),
            child: Row(
              children: [
                Icon(Icons.lock_outline_rounded, size: 20, color: palette.goldSoft),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: Text(
                    'Tutto resta sul tuo dispositivo: nessuna immagine viene '
                    'inviata, nessuna foto viene salvata oltre l\'uso del momento.',
                    key: const Key('face_privacy'),
                    style: TypographyTokens.body(size: 14).copyWith(
                        color: ColorTokens.textSecondary, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          // La scelta del cielo, PRIMA della cattura, come nel Test Archetipo.
          DepthCard(
            padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.md, vertical: SpacingTokens.xs),
            child: SwitchListTile(
              key: const Key('face_sky_setting'),
              value: conCielo,
              onChanged: onCielo,
              contentPadding: EdgeInsets.zero,
              activeThumbColor: palette.goldSoft,
              title: Text('Lega al cielo di oggi',
                  style: TypographyTokens.display(size: 16)
                      .copyWith(color: ColorTokens.textPrimary)),
              subtitle: Text(
                  'I transiti del giorno si accostano alla tua lettura, come '
                  'sincronicità.',
                  style: TypographyTokens.body(size: 13)
                      .copyWith(color: ColorTokens.textSecondary)),
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          if (consentito) ...[
            FilledButton.icon(
              key: const Key('face_start'),
              style: FilledButton.styleFrom(
                  backgroundColor: palette.primary,
                  foregroundColor: palette.onPrimary),
              onPressed: onInizia,
              icon: const Icon(Icons.camera_front_rounded),
              label: const Text('Inquadra il tuo volto'),
            ),
            const SizedBox(height: SpacingTokens.sm),
            TextButton.icon(
              key: const Key('face_fallback_entry'),
              onPressed: onRipiego,
              icon: Icon(Icons.touch_app_outlined, color: palette.goldSoft),
              label: Text('Non hai la fotocamera? Tocca qui',
                  style: TypographyTokens.label(size: 13)
                      .copyWith(color: palette.goldSoft)),
            ),
            if (rimanenti != null) ...[
              const SizedBox(height: SpacingTokens.xs),
              Text(
                  rimanenti == 1
                      ? 'Ne hai una oggi.'
                      : 'Ne hai $rimanenti oggi.',
                  style: TypographyTokens.label(size: 12)
                      .copyWith(color: ColorTokens.textSecondary)),
            ],
          ] else
            _Bloccato(palette: palette, ultimo: ultimo, onRipiego: onRipiego),
        ],
      ),
    );
  }
}

/// Limite raggiunto: mai un vicolo cieco, si mostra l'ultima lettura salvata.
class _Bloccato extends StatelessWidget {
  const _Bloccato(
      {required this.palette, required this.ultimo, required this.onRipiego});

  final MaestroPalette palette;
  final FaceEsito? ultimo;
  final VoidCallback onRipiego;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('face_blocked'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lock_rounded, size: 18, color: palette.goldSoft),
            const SizedBox(width: SpacingTokens.xs),
            Expanded(
              child: Text(
                'Per oggi hai già guardato il tuo volto. Il Cerchio ne apre di più.',
                style: TypographyTokens.body(size: 15)
                    .copyWith(color: ColorTokens.textPrimary, height: 1.4),
              ),
            ),
          ],
        ),
        if (ultimo != null) ...[
          const SizedBox(height: SpacingTokens.lg),
          Text('La tua ultima lettura',
              style: TypographyTokens.label(size: 12)
                  .copyWith(color: palette.goldSoft, letterSpacing: 0.6)),
          const SizedBox(height: SpacingTokens.sm),
          DepthCard(
            key: const Key('face_last_saved'),
            padding: const EdgeInsets.all(SpacingTokens.md),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, color: palette.goldSoft, size: 28),
                const SizedBox(width: SpacingTokens.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ultimo!.reading.dominante.titoloEvocativo,
                          style: TypographyTokens.display(size: 18)
                              .copyWith(color: palette.goldSoft)),
                      const SizedBox(height: 2),
                      Text(ultimo!.reading.dominante.nome,
                          style: TypographyTokens.body(size: 14).copyWith(
                              color: ColorTokens.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// La cattura dal vivo: anteprima della fotocamera frontale coi contorni, oppure
/// la sagoma neutra quando la fotocamera non c'e' o nega il permesso. Al tocco
/// dello scatto la costellazione si congela e si va al responso.
class _Cattura extends StatefulWidget {
  const _Cattura({
    required this.palette,
    required this.onFatto,
    required this.onRipiego,
  });

  final MaestroPalette palette;
  final void Function(FaceReading, FaceConstellation, {String? fotoPath}) onFatto;
  final VoidCallback onRipiego;

  @override
  State<_Cattura> createState() => _CatturaState();
}

class _CatturaState extends State<_Cattura>
    with SingleTickerProviderStateMixin {
  late final AnimationController _battito = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat();

  CameraController? _camera;
  FaceDetector? _detector;
  FaceContours? _contorniVivi;
  bool _occupato = false;

  @override
  void initState() {
    super.initState();
    _prepara();
  }

  Future<void> _prepara() async {
    try {
      final camere = await availableCameras();
      final frontale = camere.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => camere.first,
      );
      final controller = CameraController(
        frontale,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );
      await controller.initialize();
      _detector = FaceDetector(
          options: FaceDetectorOptions(enableContours: true));
      await controller.startImageStream(_analizza);
      if (!mounted) return;
      setState(() => _camera = controller);
    } catch (_) {
      // Nessuna fotocamera o permesso negato: resta la sagoma neutra, mai un
      // vicolo cieco. La build mostra gia' la sagoma quando la fotocamera e'
      // assente, quindi non serve altro stato.
    }
  }

  Future<void> _analizza(CameraImage image) async {
    if (_occupato || _detector == null || _camera == null) return;
    _occupato = true;
    try {
      final input = _inputDaCamera(image, _camera!.description);
      if (input != null) {
        final volti = await _detector!.processImage(input);
        if (volti.isNotEmpty) {
          final c = _contorniDaVolto(volti.first);
          if (c != null && mounted) setState(() => _contorniVivi = c);
        }
      }
    } catch (_) {
      // Un frame illeggibile non ferma il flusso.
    } finally {
      _occupato = false;
    }
  }

  Future<void> _scatta() async {
    final contorni = _contorniVivi ?? FaceSilhouette.contorni();
    final reading = FaceClassifier.leggi(contorni);
    final cost = FaceConstellation.da(contorni);
    String? foto;
    try {
      if (_camera != null) {
        await _camera!.stopImageStream();
        final x = await _camera!.takePicture();
        foto = x.path;
      }
    } catch (_) {
      foto = null;
    }
    widget.onFatto(reading, cost, fotoPath: foto);
  }

  @override
  void dispose() {
    _battito.dispose();
    _camera?.dispose();
    _detector?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final contorni = _contorniVivi ?? FaceSilhouette.contorni();
    final cost = FaceConstellation.da(contorni);
    return Padding(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        children: [
          const SizedBox(height: SpacingTokens.sm),
          Text('Centra il viso nel cerchio, sguardo dritto.',
              key: const Key('face_guide'),
              textAlign: TextAlign.center,
              style: TypographyTokens.body(size: 15)
                  .copyWith(color: ColorTokens.textPrimary)),
          const SizedBox(height: SpacingTokens.md),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(SpacingTokens.radiusXl),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_camera != null && _camera!.value.isInitialized)
                        FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _camera!.value.previewSize?.height ?? 300,
                            height: _camera!.value.previewSize?.width ?? 400,
                            child: CameraPreview(_camera!),
                          ),
                        )
                      else
                        _FondoSagoma(palette: palette),
                      AnimatedBuilder(
                        animation: _battito,
                        builder: (context, _) => CustomPaint(
                          key: const Key('face_constellation_live'),
                          painter: FaceConstellationPainter(
                            costellazione: cost,
                            palette: palette,
                            pulsazione: _battito.value,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          FilledButton.icon(
            key: const Key('face_shutter'),
            style: FilledButton.styleFrom(
                backgroundColor: palette.primary,
                foregroundColor: palette.onPrimary),
            onPressed: _scatta,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Cattura la costellazione'),
          ),
          const SizedBox(height: SpacingTokens.xs),
          TextButton(
            onPressed: widget.onRipiego,
            child: Text('Preferisci scegliere a mano? Tocca qui',
                style: TypographyTokens.label(size: 12)
                    .copyWith(color: palette.goldSoft)),
          ),
        ],
      ),
    );
  }

  // --- Adattatore ML Kit ---

  /// Converte i contorni del volto rilevato da ML Kit nel dato puro del cuore.
  FaceContours? _contorniDaVolto(Face volto) {
    List<Offset> punti(FaceContourType t) {
      final c = volto.contours[t];
      if (c == null) return const [];
      return [for (final p in c.points) Offset(p.x.toDouble(), p.y.toDouble())];
    }

    final oval = punti(FaceContourType.face);
    if (oval.length < 4) return null;
    return FaceContours(
      volto: oval,
      sopraccioSx: punti(FaceContourType.leftEyebrowTop),
      sopraccioDx: punti(FaceContourType.rightEyebrowTop),
      occhioSx: punti(FaceContourType.leftEye),
      occhioDx: punti(FaceContourType.rightEye),
      nasoPonte: punti(FaceContourType.noseBridge),
      nasoBase: punti(FaceContourType.noseBottom),
      labbroSopra: punti(FaceContourType.upperLipTop),
      labbroSotto: punti(FaceContourType.lowerLipBottom),
      guanciaSx: _primo(punti(FaceContourType.leftCheek)),
      guanciaDx: _primo(punti(FaceContourType.rightCheek)),
    );
  }

  static Offset? _primo(List<Offset> p) => p.isEmpty ? null : p.first;

  InputImage? _inputDaCamera(CameraImage image, CameraDescription cam) {
    final rotazione =
        InputImageRotationValue.fromRawValue(cam.sensorOrientation) ??
            InputImageRotation.rotation0deg;
    final formato = InputImageFormatValue.fromRawValue(image.format.raw);
    if (formato == null || image.planes.isEmpty) return null;
    return InputImage.fromBytes(
      bytes: image.planes.first.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotazione,
        format: formato,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }
}

/// Il fondo con la sagoma neutra del volto, quando non c'e' la fotocamera.
class _FondoSagoma extends StatelessWidget {
  const _FondoSagoma({required this.palette});

  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            palette.surfaceElevated.withValues(alpha: 0.6),
            palette.deepest.withValues(alpha: 0.9),
          ],
        ),
      ),
      child: CustomPaint(painter: FaceSilhouettePainter(palette: palette)),
    );
  }
}

/// Il responso, stesso impianto del Test Archetipo.
class _Risultato extends StatefulWidget {
  const _Risultato({
    required this.palette,
    required this.reading,
    required this.costellazione,
    required this.fotoPath,
    required this.conCielo,
    required this.pianeti,
    required this.onCielo,
  });

  final MaestroPalette palette;
  final FaceReading reading;
  final FaceConstellation costellazione;
  final String? fotoPath;
  final bool conCielo;
  final Set<Pianeta> pianeti;
  final ValueChanged<bool> onCielo;

  @override
  State<_Risultato> createState() => _RisultatoState();
}

class _RisultatoState extends State<_Risultato>
    with SingleTickerProviderStateMixin {
  late final AnimationController _battito = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  );

  final GlobalKey _cardBoundary = GlobalKey();
  bool _condividendo = false;
  bool _renderCard = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Il respiro delle stelle, spento con Riduci Movimento o Quality Tier basso.
    if (ScrollReveal.motionOff(context)) {
      _battito.value = 1.0;
    } else if (!_battito.isAnimating) {
      _battito.repeat();
    }
  }

  @override
  void dispose() {
    _battito.dispose();
    super.dispose();
  }

  Future<void> _condividi() async {
    setState(() {
      _condividendo = true;
      _renderCard = true;
    });
    try {
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 80));
      await shareFaceCard(
          boundaryKey: _cardBoundary, dominante: widget.reading.dominante);
    } finally {
      if (mounted) setState(() => _condividendo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final reading = widget.reading;
    final dom = reading.dominante;
    final riga = widget.conCielo
        ? FaceTransits.riga(dom, widget.pianeti)
        : null;

    return Stack(
      children: [
        SingleChildScrollView(
          key: const Key('face_result'),
          padding: const EdgeInsets.all(SpacingTokens.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(
                  widget.conCielo
                      ? 'legato ai transiti astrologici di oggi'
                      : 'non legato ai transiti astrologici',
                  key: const Key('face_mode_subtitle'),
                  textAlign: TextAlign.center,
                  style: TypographyTokens.label(size: 12).copyWith(
                      color: palette.goldSoft, letterSpacing: 1.0),
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
              // IL VOLTO con la costellazione sovrapposta, protagonista.
              ScrollReveal(
                child: Center(
                  child: _VoltoCostellazione(
                    palette: palette,
                    costellazione: widget.costellazione,
                    fotoPath: widget.fotoPath,
                    battito: _battito,
                    lato: 300,
                  ),
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
              // IL TITOLO evocativo del tratto dominante, poi il nome del tratto.
              Center(
                child: Text(dom.titoloEvocativo,
                    key: const Key('face_title'),
                    textAlign: TextAlign.center,
                    style: TypographyTokens.display(size: 28)
                        .copyWith(color: palette.goldSoft)),
              ),
              Center(
                child: Text(dom.nome,
                    key: const Key('face_dominant_name'),
                    textAlign: TextAlign.center,
                    style: TypographyTokens.body(size: 16).copyWith(
                        color: ColorTokens.textSecondary,
                        fontStyle: FontStyle.italic)),
              ),
              const SizedBox(height: SpacingTokens.lg),
              // LA SINTESI calda, intrecciata dai tratti piu' marcati.
              ScrollReveal(
                depth: 1,
                child: DepthCard(
                  key: const Key('face_synthesis'),
                  raised: true,
                  padding: const EdgeInsets.all(SpacingTokens.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('La tua sintesi',
                          style: TypographyTokens.label(size: 12).copyWith(
                              color: palette.goldSoft, letterSpacing: 0.6)),
                      const SizedBox(height: SpacingTokens.xs),
                      Text(FaceCorpus.sintesi(reading.marcati),
                          style: TypographyTokens.body(size: 16).copyWith(
                              color: ColorTokens.textPrimary, height: 1.55)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: SpacingTokens.lg),
              // L'ELENCO dei tratti letti, ognuno con la sua stella e la frase.
              Text('I tratti del tuo volto',
                  style: TypographyTokens.label(size: 12)
                      .copyWith(color: palette.goldSoft, letterSpacing: 0.6)),
              const SizedBox(height: SpacingTokens.sm),
              for (final t in reading.marcati)
                _RigaTratto(tratto: t, palette: palette),

              const SizedBox(height: SpacingTokens.lg),
              // L'interruttore vivo dei transiti.
              _Transiti(
                palette: palette,
                acceso: widget.conCielo,
                onCambia: widget.onCielo,
                riga: riga,
              ),

              const SizedBox(height: SpacingTokens.lg),
              OutlinedButton.icon(
                key: const Key('face_share'),
                style: OutlinedButton.styleFrom(
                    foregroundColor: palette.goldSoft,
                    side: BorderSide(color: palette.gold.withValues(alpha: 0.6))),
                onPressed: _condividendo ? null : _condividi,
                icon: const Icon(Icons.ios_share_rounded),
                label: const Text('Condividi'),
              ),
              const SizedBox(height: SpacingTokens.sm),
              FilledButton.icon(
                key: const Key('face_consulta'),
                style: FilledButton.styleFrom(
                    backgroundColor: palette.primary,
                    foregroundColor: palette.onPrimary),
                onPressed: () {
                  final services = context.read<AppServices>();
                  Navigator.of(context).push(MaestroChatScreen.route(
                      maestro: Maestro.aura,
                      services: services,
                      initialUserMessage: ChatOpeners.viso(
                          dom.categoria.name, dom.nome)));
                },
                icon: const Icon(Icons.forum_outlined),
                label: const Text('Parlane con Aura'),
              ),
              const SizedBox(height: SpacingTokens.xxxl),
            ],
          ),
        ),
        if (_renderCard)
          Positioned(
            left: -3000,
            top: 0,
            child: RepaintBoundary(
              key: _cardBoundary,
              child: FaceShareCard(
                reading: widget.reading,
                costellazione: widget.costellazione,
                fotoPath: widget.fotoPath,
              ),
            ),
          ),
      ],
    );
  }
}

/// Il volto con la costellazione sovrapposta: la foto quando c'e', altrimenti la
/// sagoma neutra. La costellazione respira.
class _VoltoCostellazione extends StatelessWidget {
  const _VoltoCostellazione({
    required this.palette,
    required this.costellazione,
    required this.fotoPath,
    required this.battito,
    required this.lato,
  });

  final MaestroPalette palette;
  final FaceConstellation costellazione;
  final String? fotoPath;
  final Animation<double> battito;
  final double lato;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('face_portrait'),
      width: lato,
      height: lato,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusXl),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (fotoPath != null)
              Image.file(File(fotoPath!), fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _FondoSagoma(palette: palette))
            else
              _FondoSagoma(palette: palette),
            AnimatedBuilder(
              animation: battito,
              builder: (context, _) => CustomPaint(
                painter: FaceConstellationPainter(
                  costellazione: costellazione,
                  palette: palette,
                  pulsazione: battito.value,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Una riga di tratto letto: la sua stella e la sua frase dal corpus.
class _RigaTratto extends StatelessWidget {
  const _RigaTratto({required this.tratto, required this.palette});

  final FaceTrait tratto;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: Key('face_trait_${tratto.name}'),
      padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Icon(Icons.star_rounded, size: 16, color: palette.goldSoft),
          ),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TypographyTokens.body(size: 15)
                    .copyWith(color: ColorTokens.textPrimary, height: 1.4),
                children: [
                  TextSpan(
                      text: '${tratto.nome}. ',
                      style: TextStyle(
                          color: palette.goldSoft,
                          fontWeight: FontWeight.w600)),
                  TextSpan(text: FaceCorpus.frase(tratto)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// L'interruttore vivo dei transiti sul responso.
class _Transiti extends StatelessWidget {
  const _Transiti({
    required this.palette,
    required this.acceso,
    required this.onCambia,
    required this.riga,
  });

  final MaestroPalette palette;
  final bool acceso;
  final ValueChanged<bool> onCambia;
  final String? riga;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          key: const Key('face_transits_switch'),
          value: acceso,
          onChanged: onCambia,
          contentPadding: EdgeInsets.zero,
          activeThumbColor: palette.goldSoft,
          title: Text('Lega ai transiti',
              style: TypographyTokens.display(size: 16)
                  .copyWith(color: ColorTokens.textPrimary)),
          subtitle: Text('Il cielo di oggi si accosta alla tua lettura.',
              style: TypographyTokens.body(size: 13)
                  .copyWith(color: ColorTokens.textSecondary)),
        ),
        if (riga != null) ...[
          Text(FaceTransits.cornice,
              style: TypographyTokens.body(size: 13).copyWith(
                  color: ColorTokens.textSecondary,
                  height: 1.4,
                  fontStyle: FontStyle.italic)),
          const SizedBox(height: SpacingTokens.sm),
          Row(
            key: const Key('face_transit_line'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.brightness_1, size: 7, color: palette.goldSoft),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: Text(riga!,
                    style: TypographyTokens.body(size: 15).copyWith(
                        color: ColorTokens.textPrimary, height: 1.4)),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Il ripiego tattile: un selettore guidato dei tratti, che alimenta lo stesso
/// motore e porta allo stesso responso.
class _Ripiego extends StatefulWidget {
  const _Ripiego({required this.palette, required this.onFatto});

  final MaestroPalette palette;
  final ValueChanged<FaceReading> onFatto;

  @override
  State<_Ripiego> createState() => _RipiegoState();
}

class _RipiegoState extends State<_Ripiego> {
  // Le categorie che il ripiego chiede, con l'icona per ciascuna variante.
  static const List<FaceCategory> _categorie = [
    FaceCategory.formaVolto,
    FaceCategory.grandezzaOcchi,
    FaceCategory.sopracciglia,
    FaceCategory.labbra,
    FaceCategory.mento,
  ];

  final Map<FaceCategory, FaceTrait> _scelte = {};

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final completo = _scelte.length == _categorie.length;
    return SingleChildScrollView(
      key: const Key('face_fallback'),
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: SpacingTokens.sm),
          Text('Scegli a mano',
              style: TypographyTokens.display(size: 22)
                  .copyWith(color: palette.goldSoft)),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            'Guarda il tuo viso allo specchio e scegli, per ogni tratto, la '
            'forma che ti somiglia di più. Alimenta la stessa lettura.',
            style: TypographyTokens.body(size: 15)
                .copyWith(color: ColorTokens.textPrimary, height: 1.45),
          ),
          const SizedBox(height: SpacingTokens.lg),
          for (final cat in _categorie) ...[
            Text(cat.titolo,
                style: TypographyTokens.label(size: 12)
                    .copyWith(color: palette.goldSoft, letterSpacing: 0.6)),
            const SizedBox(height: SpacingTokens.xs),
            Wrap(
              spacing: SpacingTokens.sm,
              runSpacing: SpacingTokens.sm,
              children: [
                for (final t in FaceTrait.perCategoria(cat))
                  _Scelta(
                    key: Key('face_pick_${t.name}'),
                    tratto: t,
                    scelto: _scelte[cat] == t,
                    palette: palette,
                    onTap: () => setState(() => _scelte[cat] = t),
                  ),
              ],
            ),
            const SizedBox(height: SpacingTokens.md),
          ],
          const SizedBox(height: SpacingTokens.sm),
          FilledButton.icon(
            key: const Key('face_fallback_done'),
            style: FilledButton.styleFrom(
                backgroundColor: palette.primary,
                foregroundColor: palette.onPrimary,
                disabledBackgroundColor:
                    palette.surface.withValues(alpha: 0.5)),
            onPressed: completo
                ? () => widget.onFatto(FaceClassifier.daSelezioni(_scelte))
                : null,
            icon: const Icon(Icons.auto_awesome),
            label: Text(completo
                ? 'Vedi la tua costellazione'
                : 'Scegli tutti i tratti'),
          ),
          const SizedBox(height: SpacingTokens.xxxl),
        ],
      ),
    );
  }
}

/// Una scelta illustrata del ripiego: l'icona del tratto e il suo nome.
class _Scelta extends StatelessWidget {
  const _Scelta({
    super.key,
    required this.tratto,
    required this.scelto,
    required this.palette,
    required this.onTap,
  });

  final FaceTrait tratto;
  final bool scelto;
  final MaestroPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.md, vertical: SpacingTokens.sm),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
          color: scelto
              ? palette.primary.withValues(alpha: 0.3)
              : palette.surface.withValues(alpha: 0.4),
          border: Border.all(
            color: scelto
                ? palette.goldSoft
                : palette.gold.withValues(alpha: 0.3),
            width: scelto ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icona(tratto.categoria),
                size: 16,
                color: scelto ? palette.goldSoft : ColorTokens.textSecondary),
            const SizedBox(width: SpacingTokens.xs),
            Text(tratto.nome,
                style: TypographyTokens.body(size: 14).copyWith(
                    color: scelto
                        ? palette.goldSoft
                        : ColorTokens.textPrimary)),
          ],
        ),
      ),
    );
  }

  IconData _icona(FaceCategory c) {
    switch (c) {
      case FaceCategory.formaVolto:
        return Icons.face_outlined;
      case FaceCategory.grandezzaOcchi:
        return Icons.remove_red_eye_outlined;
      case FaceCategory.sopracciglia:
        return Icons.waves_rounded;
      case FaceCategory.labbra:
        return Icons.sentiment_satisfied_outlined;
      case FaceCategory.mento:
        return Icons.change_history_rounded;
      default:
        return Icons.star_outline_rounded;
    }
  }
}
