import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:provider/provider.dart';

import 'widgets/disegni_del_cerchio.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/cerchio/il_cerchio_sociale.dart';
import '../../core/condivisione/porta_della_condivisione.dart';
import '../../core/entitlement/question_allowance.dart';
import '../../core/sigilli/bonus_della_condivisione.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';
import 'la_richiesta_di_legame.dart';

/// **CHIAMA QUALCUNO NEL TUO CERCHIO, ordine EY voce 04.** Due vie e non tre:
/// il link da mandare, e il codice da inquadrare quando i due telefoni sono
/// vicini. **La ricerca libera delle persone non esiste**: c'e' solo il
/// sigillo, che e' un'identita' da sapere e non un nome da cercare.
class InvitaNelCerchioScreen extends StatefulWidget {
  const InvitaNelCerchioScreen({super.key});

  static Route<void> route() => PassaggioDelCerchio.rotta<void>(
      (_) => const MaestroScope(neutro: true, child: InvitaNelCerchioScreen()));

  @override
  State<InvitaNelCerchioScreen> createState() => _InvitaNelCerchioScreenState();
}

class _InvitaNelCerchioScreenState extends State<InvitaNelCerchioScreen> {
  final TextEditingController _sigillo = TextEditingController();
  String? _riga;

  @override
  void dispose() {
    _sigillo.dispose();
    super.dispose();
  }

  Future<void> _mandaIlLink() async {
    int? premio;
    try {
      premio = context.read<QuestionAllowance>().premioDellInvito;
    } catch (_) {}
    // Il link col codice opaco lo aggiunge la porta della condivisione, in un
    // posto solo (EY.15): qui non passa nessun uid.
    await PortaDellaCondivisione.testo(
        TestoDellaCondivisione.invitoLibero(premioInvito: premio));
  }

  Future<void> _colSigillo() async {
    final esito = await context
        .read<IlCerchioSociale>()
        .chiediIlLegame(sigillo: _sigillo.text);
    if (!mounted) return;
    setState(() => _riga = esito.ok
        ? 'Il tuo invito è partito: aspetti la sua risposta.'
        : (esito.riga ?? EsitoDelGesto.silenzio.riga));
  }

  @override
  Widget build(BuildContext context) {
    const palette = MaestroPalette.neutral;
    return conIPulsantiDOro(
        context,
        Scaffold(
          backgroundColor: palette.deepest,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: palette.goldSoft),
            title: Text('Chiama nel tuo Cerchio',
                style: TypographyTokens.titoloDiSchermata()
                    .copyWith(color: palette.goldSoft)),
          ),
          body: ListView(
            key: const Key('invita_nel_cerchio'),
            padding: const EdgeInsets.fromLTRB(
                SpacingTokens.md, 0, SpacingTokens.md, SpacingTokens.xl),
            children: [
              _Via(
                icona: Icons.link_rounded,
                titolo: 'Manda il tuo invito',
                riga: 'Il link vale trenta giorni e porta solo un codice del '
                    'Cerchio: niente del tuo nome vero, niente della tua nascita.',
                child: FilledButton(
                  key: const Key('invita_link'),
                  style: FilledButton.styleFrom(
                      backgroundColor: palette.gold,
                      foregroundColor: palette.onPrimary,
                      minimumSize: const Size.fromHeight(48)),
                  onPressed: _mandaIlLink,
                  child: const Text('Manda il link'),
                ),
              ),
              _Via(
                icona: Icons.qr_code_2_rounded,
                titolo: 'Siete vicini',
                riga:
                    'Uno mostra il suo codice, l’altro lo inquadra. Il codice '
                    'vale cinque minuti: una sua fotografia domani non vale niente.',
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        key: const Key('invita_mostra'),
                        onPressed: () => Navigator.of(context).push(
                            PassaggioDelCerchio.rotta<void>(
                                (_) => const IlMioCodice())),
                        child: const Text('Mostra il mio'),
                      ),
                    ),
                    const SizedBox(width: SpacingTokens.sm),
                    Expanded(
                      child: OutlinedButton(
                        key: const Key('invita_inquadra'),
                        onPressed: () async {
                          final codice = await Navigator.of(context)
                              .push<String>(PassaggioDelCerchio.rotta<String>(
                                  (_) => const InquadraIlCodice()));
                          if (codice != null && context.mounted) {
                            await mostraLaRichiestaDiLegame(context, codice);
                          }
                        },
                        child: const Text('Inquadra il suo'),
                      ),
                    ),
                  ],
                ),
              ),
              _Via(
                icona: Icons.tag_rounded,
                titolo: 'Hai il suo sigillo?',
                riga:
                    'Quattro caratteri: lo trovi nel suo profilo del Cerchio.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      key: const Key('invita_campo_sigillo'),
                      controller: _sigillo,
                      maxLength: 4,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp('[0-9A-Za-z]')),
                      ],
                      style: TypographyTokens.titoloScheda().copyWith(
                          color: ColorTokens.textPrimary, letterSpacing: 6),
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(counterText: ''),
                    ),
                    TextButton(
                      key: const Key('invita_col_sigillo'),
                      onPressed: _colSigillo,
                      child: const Text('Manda l’invito'),
                    ),
                    if (_riga != null)
                      Text(_riga!,
                          key: const Key('invita_riga'),
                          textAlign: TextAlign.center,
                          style: TypographyTokens.didascalia()
                              .copyWith(color: palette.goldSoft)),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}

class _Via extends StatelessWidget {
  const _Via(
      {required this.icona,
      required this.titolo,
      required this.riga,
      required this.child});
  final IconData icona;
  final String titolo;
  final String riga;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const palette = MaestroPalette.neutral;
    return Container(
      margin: const EdgeInsets.only(top: SpacingTokens.md),
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        color: palette.surfaceElevated.withValues(alpha: 0.75),
        border: Border.all(color: palette.gold.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Icon(icona, color: palette.goldSoft, size: 32),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: Text(titolo,
                  style: TypographyTokens.titoloScheda()
                      .copyWith(color: palette.goldSoft)),
            ),
          ]),
          const SizedBox(height: SpacingTokens.xs),
          Text(riga,
              style: TypographyTokens.didascalia()
                  .copyWith(color: ColorTokens.textSecondary, height: 1.4)),
          const SizedBox(height: SpacingTokens.sm),
          child,
        ],
      ),
    );
  }
}

/// **IL MIO CODICE DA INQUADRARE**: un codice nuovo del server, valido
/// cinque minuti, disegnato in QR e scritto sotto (per chi non puo'
/// inquadrare: il fallback a gesto tattile e' scriverlo).
class IlMioCodice extends StatefulWidget {
  const IlMioCodice({super.key});

  @override
  State<IlMioCodice> createState() => _IlMioCodiceState();
}

class _IlMioCodiceState extends State<IlMioCodice> {
  String? _codice;
  DateTime? _scade;
  bool _silenzio = false;
  Timer? _orologio;

  @override
  void initState() {
    super.initState();
    _chiedi();
    _orologio = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _chiedi() async {
    final c = await context.read<IlCerchioSociale>().codice(vicino: true);
    if (!mounted) return;
    setState(() {
      _codice = c?.codice;
      _scade = c?.scade;
      _silenzio = c == null || c.codice == null;
    });
  }

  @override
  void dispose() {
    _orologio?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const palette = MaestroPalette.neutral;
    final resta = _scade?.difference(DateTime.now());
    final scaduto = resta != null && resta.isNegative;
    return conIPulsantiDOro(
        context,
        Scaffold(
          backgroundColor: palette.deepest,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: palette.goldSoft),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(SpacingTokens.lg),
              child: _silenzio
                  ? Text(
                      'Il Cerchio non risponde adesso: il codice arriva appena '
                      'c’è la rete.',
                      key: const Key('codice_silenzio'),
                      textAlign: TextAlign.center,
                      style: TypographyTokens.corpo()
                          .copyWith(color: ColorTokens.textSecondary))
                  : _codice == null
                      ? const CircularProgressIndicator()
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(SpacingTokens.md),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                    SpacingTokens.radiusLg),
                              ),
                              child: QrImageView(
                                key: const Key('il_mio_qr'),
                                data: IlCerchioSociale.linkDi(_codice!),
                                size: 220,
                              ),
                            ),
                            const SizedBox(height: SpacingTokens.md),
                            Text(_codice!,
                                key: const Key('il_mio_codice'),
                                style: TypographyTokens.cerimoniale().copyWith(
                                    color: palette.goldSoft, letterSpacing: 8)),
                            const SizedBox(height: SpacingTokens.xs),
                            Text(
                                scaduto
                                    ? 'Il codice è scaduto.'
                                    : 'Vale ancora ${resta!.inMinutes}:'
                                        '${(resta.inSeconds % 60).toString().padLeft(2, '0')}.',
                                style: TypographyTokens.didascalia().copyWith(
                                    color: ColorTokens.textSecondary)),
                            if (scaduto)
                              TextButton(
                                key: const Key('codice_nuovo'),
                                onPressed: _chiedi,
                                child: const Text('Un codice nuovo'),
                              ),
                          ],
                        ),
            ),
          ),
        ));
  }
}

/// **INQUADRA IL SUO CODICE.** La fotocamera legge il QR; **il fallback a
/// gesto tattile c'e' sempre** (regola del progetto): il codice si puo'
/// scrivere a mano, sei caratteri, sotto l'inquadratura.
class InquadraIlCodice extends StatefulWidget {
  const InquadraIlCodice({super.key});

  @override
  State<InquadraIlCodice> createState() => _InquadraIlCodiceState();
}

class _InquadraIlCodiceState extends State<InquadraIlCodice> {
  CameraController? _camera;
  final BarcodeScanner _lettore =
      BarcodeScanner(formats: [BarcodeFormat.qrCode]);
  final TextEditingController _scritto = TextEditingController();
  Timer? _giro;
  bool _letto = false;
  String? _rigaDellaCamera;

  @override
  void initState() {
    super.initState();
    _accendi();
  }

  Future<void> _accendi() async {
    try {
      final camere = await availableCameras();
      final dietro = camere.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
          orElse: () => camere.first);
      final c =
          CameraController(dietro, ResolutionPreset.medium, enableAudio: false);
      await c.initialize();
      if (!mounted) {
        await c.dispose();
        return;
      }
      setState(() => _camera = c);
      // Una fotografia al secondo, letta da ML Kit sul telefono: nessuna
      // immagine lascia il dispositivo.
      _giro =
          Timer.periodic(const Duration(milliseconds: 1200), (_) => _leggi());
    } catch (errore) {
      if (mounted) {
        setState(() => _rigaDellaCamera =
            'La fotocamera non si apre: scrivi il codice qui sotto.');
      }
    }
  }

  bool _occupato = false;

  Future<void> _leggi() async {
    final c = _camera;
    if (c == null || _occupato || _letto || !c.value.isInitialized) return;
    _occupato = true;
    try {
      final foto = await c.takePicture();
      final codici =
          await _lettore.processImage(InputImage.fromFilePath(foto.path));
      for (final b in codici) {
        final codice = IlCerchioSociale.codiceDaUnLink(b.rawValue ?? '');
        if (codice != null && mounted && !_letto) {
          _letto = true;
          Navigator.of(context).pop(codice);
          return;
        }
      }
    } catch (_) {
      // Una lettura mancata non e' un guasto: si riprova al giro dopo.
    } finally {
      _occupato = false;
    }
  }

  @override
  void dispose() {
    _giro?.cancel();
    _camera?.dispose();
    _lettore.close();
    _scritto.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const palette = MaestroPalette.neutral;
    final c = _camera;
    return conIPulsantiDOro(
        context,
        Scaffold(
          backgroundColor: palette.deepest,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: palette.goldSoft),
            title: Text('Inquadra il suo codice',
                style: TypographyTokens.titoloDiSchermata()
                    .copyWith(color: palette.goldSoft)),
          ),
          body: ListView(
            padding: const EdgeInsets.all(SpacingTokens.md),
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
                  child: c != null && c.value.isInitialized
                      ? CameraPreview(c)
                      : ColoredBox(
                          color: palette.surfaceElevated,
                          child: Center(
                            child: Text(_rigaDellaCamera ?? 'Un momento...',
                                textAlign: TextAlign.center,
                                style: TypographyTokens.corpo().copyWith(
                                    color: ColorTokens.textSecondary)),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
              Text('Oppure scrivi il codice che vedi sul suo telefono',
                  textAlign: TextAlign.center,
                  style: TypographyTokens.didascalia()
                      .copyWith(color: ColorTokens.textSecondary)),
              TextField(
                key: const Key('invita_campo_codice'),
                controller: _scritto,
                maxLength: 6,
                textAlign: TextAlign.center,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[0-9A-Za-z]')),
                ],
                style: TypographyTokens.titoloScheda()
                    .copyWith(color: ColorTokens.textPrimary, letterSpacing: 6),
                decoration: const InputDecoration(counterText: ''),
              ),
              FilledButton(
                key: const Key('invita_codice_scritto'),
                onPressed: () {
                  final codice = IlCerchioSociale.codiceDaUnLink(_scritto.text);
                  if (codice != null) Navigator.of(context).pop(codice);
                },
                child: const Text('Leggi il codice'),
              ),
            ],
          ),
        ));
  }
}
