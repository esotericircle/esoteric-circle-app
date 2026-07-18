import 'package:flutter/material.dart';

import '../../core/astro/night_sky.dart';
import '../../core/astro/zodiac.dart';
import '../../core/identity/birth_identity.dart';
import '../../core/synastry/synastry_report.dart';
import '../../core/synastry/vip_catalog.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/components/depth_card.dart';
import '../../design_system/components/vip_frame.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'sinastria_share_card.dart';
import 'user_photo.dart';

const List<String> _mesiItaliani = [
  'gennaio', 'febbraio', 'marzo', 'aprile', 'maggio', 'giugno', //
  'luglio', 'agosto', 'settembre', 'ottobre', 'novembre', 'dicembre'
];

/// Data di nascita per esteso, in italiano, per il cartiglio basso.
String italianLongDate(DateTime d) =>
    '${d.day} ${_mesiItaliani[d.month - 1]} ${d.year}';

/// Sinastria VIP: l'affinita' fra il tuo cielo e quello di un VIP.
///
/// Un VIP e' sempre precaricato, cosi' la Demo puo' aprirsi da qui in un tap dal
/// Santuario. Tutto e' deterministico per coppia (elemento, modalita', aspetto):
/// a parita' di segni il responso e le quattro barre non cambiano. E' un gioco
/// simbolico di intrattenimento, non una previsione.
class SinastriaVipScreen extends StatefulWidget {
  const SinastriaVipScreen({
    super.key,
    this.userSign,
    this.userName = 'Tu',
    this.userBirth,
    this.photoController,
  });

  final Zodiac? userSign;

  /// Nome dell'utente nel cartiglio del suo polo.
  final String userName;

  /// Data di nascita dell'utente, per il cartiglio. Se nulla, usa l'esempio.
  final DateTime? userBirth;

  /// Iniettabile nei test, cosi' la scelta foto non tocca camera ne galleria.
  final UserPhotoController? photoController;

  static Route<void> route({Zodiac? userSign}) {
    return MaterialPageRoute<void>(
      builder: (_) =>
          MaestroScope(child: SinastriaVipScreen(userSign: userSign)),
    );
  }

  @override
  State<SinastriaVipScreen> createState() => _SinastriaVipScreenState();
}

class _SinastriaVipScreenState extends State<SinastriaVipScreen>
    with SingleTickerProviderStateMixin {
  late Vip _vip = VipCatalog.first;
  late final UserPhotoController _photo =
      widget.photoController ?? UserPhotoController();
  final GlobalKey _cardKey = GlobalKey();
  late final AnimationController _anim;
  bool _sharing = false;

  /// La card condivisibile vive nell'albero solo l'istante dello scatto, cosi'
  /// non raddoppia i testi a schermo ne pesa a ogni frame.
  bool _renderCard = false;

  Zodiac get _userSign =>
      widget.userSign ?? NightSky.sunSign(BirthIdentity.example.birthMoment);

  DateTime get _userBirth =>
      widget.userBirth ?? BirthIdentity.example.birthMoment;

  String get _userDate => italianLongDate(_userBirth);

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
    _photo.addListener(_onPhotoChanged);
  }

  void _onPhotoChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _photo.removeListener(_onPhotoChanged);
    // Se il controller e' nostro lo chiudiamo; se e' iniettato lo lascia il test.
    if (widget.photoController == null) _photo.dispose();
    _anim.dispose();
    super.dispose();
  }

  void _selectVip(Vip vip) {
    setState(() => _vip = vip);
    _anim.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final report = SynastryReport.forPair(_userSign, _vip);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: palette.goldSoft),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Indietro',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text('Sinastria VIP', style: TypographyTokens.display(size: 20)),
      ),
      // Il cosmo profondo avvolge la schermata, senza le figure di costellazione
      // a linee che finivano coperte dalle cornici: qui restano stelle,
      // nebulose, parallasse e stella cadente, un cielo pulito.
      body: CosmosBackground(
        showZodiac: false,
        child: SafeArea(
          child: Stack(
            children: [
              _content(palette, report),
              // La card condivisibile, disegnata fuori campo solo durante lo
              // scatto, cosi' e' pronta da catturare a immagine senza mostrarla.
              if (_renderCard)
                Positioned(
                  left: -3000,
                  top: 0,
                  child: RepaintBoundary(
                    key: _cardKey,
                    child: SinastriaShareCard(
                      report: report,
                      vip: _vip,
                      userSign: _userSign,
                      userName: widget.userName,
                      userDate: _userDate,
                      palette: palette,
                      userPhoto: _photo.bytes,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content(MaestroPalette palette, SynastryReport report) {
    return ListView(
      key: const Key('sinastria_list'),
      padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, kToolbarHeight,
          SpacingTokens.lg, SpacingTokens.xxxl),
      children: [
        // I due poli nella cornice VIP col cuore.
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _Pole(
                key: const Key('sinastria_pole_user'),
                palette: palette,
                sign: _userSign,
                hint: _photo.hasPhoto
                    ? 'Modifica la tua foto'
                    : 'Aggiungi la tua foto',
                onTap: _openPhotoSheet,
                portrait: VipFramedPortrait(
                  palette: palette,
                  name: widget.userName,
                  date: _userDate,
                  sign: _userSign.symbol,
                  photo: _photo.bytes,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 90),
              child: Icon(Icons.favorite_rounded,
                  color: palette.goldSoft, size: 26),
            ),
            Expanded(
              child: _Pole(
                key: const Key('sinastria_pole_vip'),
                palette: palette,
                sign: _vip.sign,
                // Il ritratto VIP con la sua cornice originale, senza aggiunte.
                portrait: VipFramedPortrait(
                  palette: palette,
                  name: _vip.name,
                  date: _vip.note,
                  sign: _vip.sign.symbol,
                  vipAsset: _vip.fullPath,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: SpacingTokens.lg),
        // Il cerchio grande con percentuale animata ed etichetta di fascia.
        Center(
          child: SizedBox(
            width: 180,
            height: 180,
            child: AnimatedBuilder(
              animation: _anim,
              builder: (context, _) {
                final t = Curves.easeOutCubic.transform(_anim.value);
                final shown = (report.overall * t).round();
                return CustomPaint(
                  key: const Key('sinastria_gauge'),
                  painter: SynastryGaugePainter(
                      percent: report.overall, palette: palette, progress: t),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$shown%',
                            style: TypographyTokens.display(size: 36)
                                .copyWith(color: palette.goldSoft)),
                        Text(report.band,
                            textAlign: TextAlign.center,
                            style: TypographyTokens.label(size: 11).copyWith(
                                color: ColorTokens.textSecondary,
                                letterSpacing: 0.6)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: SpacingTokens.lg),
        // Il testo del responso, PRIMA delle barre.
        DepthCard(
          raised: true,
          padding: const EdgeInsets.all(SpacingTokens.lg),
          child: Text(report.reading,
              key: const Key('sinastria_reading'),
              style: TypographyTokens.body(size: 16)
                  .copyWith(color: ColorTokens.textPrimary, height: 1.5)),
        ),
        const SizedBox(height: SpacingTokens.md),
        // Le quattro barre infografica animate.
        DepthCard(
          padding: const EdgeInsets.all(SpacingTokens.lg),
          child: AnimatedBuilder(
            animation: _anim,
            builder: (context, _) {
              final t = Curves.easeOutCubic.transform(_anim.value);
              return Column(
                children: [
                  for (final bar in report.bars) ...[
                    SynastryBarRow(
                        bar: bar,
                        palette: palette,
                        progress: t,
                        meetingReport: report),
                    if (bar != report.bars.last)
                      const SizedBox(height: SpacingTokens.sm),
                  ],
                ],
              );
            },
          ),
        ),
        const SizedBox(height: SpacingTokens.lg),
        // Il rilancio e il tasto Condividi.
        Text(SynastryReport.challengeLine(_vip.name),
            textAlign: TextAlign.center,
            style: TypographyTokens.body(size: 14)
                .copyWith(color: ColorTokens.textSecondary, height: 1.4)),
        const SizedBox(height: SpacingTokens.sm),
        Center(
          child: FilledButton.icon(
            key: const Key('sinastria_share'),
            onPressed: _sharing ? null : _onShare,
            style: FilledButton.styleFrom(
              backgroundColor: palette.gold,
              foregroundColor: palette.deepest,
              padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.xl, vertical: SpacingTokens.sm),
            ),
            icon: _sharing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.ios_share_rounded, size: 18),
            label: Text(_sharing ? 'Preparo la card' : 'Condividi',
                style: TypographyTokens.label(size: 13)
                    .copyWith(letterSpacing: 0.6)),
          ),
        ),
        const SizedBox(height: SpacingTokens.lg),
        Text('Il tuo VIP',
            style: TypographyTokens.display(size: 16)
                .copyWith(color: palette.goldSoft)),
        const SizedBox(height: SpacingTokens.sm),
        // Selettore dei VIP precaricati, con la miniatura del ritratto.
        SizedBox(
          height: 170,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: VipCatalog.vips.length,
            separatorBuilder: (_, __) => const SizedBox(width: SpacingTokens.sm),
            itemBuilder: (context, i) {
              final vip = VipCatalog.vips[i];
              return _VipChip(
                vip: vip,
                selected: vip.name == _vip.name,
                palette: palette,
                onTap: () => _selectVip(vip),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _onShare() async {
    setState(() {
      _sharing = true;
      _renderCard = true;
    });
    try {
      // Assicura il ritratto del VIP e la cornice decodificati, poi lascia un
      // paio di frame perche' la card fuori campo sia disegnata prima dello scatto.
      if (_vip.fullPath != null) {
        await precacheImage(AssetImage(_vip.fullPath!), context);
      }
      if (mounted) {
        await precacheImage(const AssetImage(VipFrame.asset), context);
      }
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 80));
      await shareSynastryCard(
        boundaryKey: _cardKey,
        text: SynastryReport.challengeLine(_vip.name),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Non riesco a preparare la card ora.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _sharing = false;
          _renderCard = false;
        });
      }
    }
  }

  // Il foglio di consenso alla foto: scelta esplicita, con la promessa che la
  // foto resta sul dispositivo ed entra solo nella card condivisa.
  Future<void> _openPhotoSheet() async {
    final palette = context.palette;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: palette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(SpacingTokens.radiusLg)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(SpacingTokens.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('La tua foto nella cornice',
                    style: TypographyTokens.display(size: 18)
                        .copyWith(color: palette.goldSoft)),
                const SizedBox(height: SpacingTokens.sm),
                Text(
                    'La foto resta sul tuo dispositivo. Entra solo nella card che decidi di condividere, senza mai essere caricata da nessuna parte. Se preferisci, resta il tuo avatar a costellazione.',
                    style: TypographyTokens.body(size: 14).copyWith(
                        color: ColorTokens.textSecondary, height: 1.4)),
                const SizedBox(height: SpacingTokens.lg),
                FilledButton.icon(
                  key: const Key('photo_camera'),
                  style: FilledButton.styleFrom(
                      backgroundColor: palette.gold,
                      foregroundColor: palette.deepest),
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    _photo.pickFrom(UserPhotoSource.camera);
                  },
                  icon: const Icon(Icons.photo_camera_rounded, size: 18),
                  label: const Text('Usa la fotocamera'),
                ),
                const SizedBox(height: SpacingTokens.sm),
                OutlinedButton.icon(
                  key: const Key('photo_gallery'),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: palette.goldSoft,
                      side: BorderSide(
                          color: palette.gold.withValues(alpha: 0.6))),
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    _photo.pickFrom(UserPhotoSource.gallery);
                  },
                  icon: const Icon(Icons.photo_library_rounded, size: 18),
                  label: const Text('Scegli dalla galleria'),
                ),
                if (_photo.hasPhoto) ...[
                  const SizedBox(height: SpacingTokens.sm),
                  TextButton.icon(
                    key: const Key('photo_clear'),
                    style: TextButton.styleFrom(
                        foregroundColor: ColorTokens.textSecondary),
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      _photo.clear();
                    },
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Togli la foto, torna alla costellazione'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Pole extends StatelessWidget {
  const _Pole({
    super.key,
    required this.palette,
    required this.sign,
    required this.portrait,
    this.hint,
    this.onTap,
  });

  final MaestroPalette palette;
  final Zodiac sign;
  final Widget portrait;

  /// Suggerimento sotto il polo dell'utente, per invitare alla foto.
  final String? hint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          portrait,
          const SizedBox(height: SpacingTokens.sm),
          Text(sign.italianName,
              style: TypographyTokens.label(size: 11)
                  .copyWith(color: palette.goldSoft, letterSpacing: 0.6)),
          if (hint != null) ...[
            const SizedBox(height: 2),
            Text(hint!,
                textAlign: TextAlign.center,
                style: TypographyTokens.label(size: 9).copyWith(
                    color: ColorTokens.textSecondary, letterSpacing: 0.3)),
          ],
        ],
      ),
    );
  }
}

class _VipChip extends StatelessWidget {
  const _VipChip({
    required this.vip,
    required this.selected,
    required this.palette,
    required this.onTap,
  });

  final Vip vip;
  final bool selected;
  final MaestroPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: Key('vip_${vip.name}'),
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(SpacingTokens.sm),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
          gradient: selected
              ? LinearGradient(colors: [
                  palette.primary.withValues(alpha: 0.6),
                  palette.surfaceElevated.withValues(alpha: 0.6),
                ])
              : null,
          border: Border.all(
              color: selected
                  ? palette.gold.withValues(alpha: 0.7)
                  : palette.gold.withValues(alpha: 0.22)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Miniatura del ritratto nel picker: la misura leggera, e' una vista
            // con piu' voci.
            if (vip.hasImage) ...[
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(SpacingTokens.radiusSm),
                  child: Image.asset(
                    vip.thumbPath!,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(Icons.auto_awesome,
                        color: palette.goldSoft, size: 22),
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(vip.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TypographyTokens.display(size: 14).copyWith(
                    color:
                        selected ? palette.goldSoft : ColorTokens.textPrimary)),
            Text(vip.sign.italianName,
                style: TypographyTokens.label(size: 9)
                    .copyWith(color: palette.goldSoft, letterSpacing: 0.4)),
            const SizedBox(height: 2),
            Expanded(
              child: Text(vip.note,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TypographyTokens.body(size: 11)
                      .copyWith(color: ColorTokens.textSecondary, height: 1.2)),
            ),
            if (vip.hasCategory) ...[
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(SpacingTokens.radiusSm),
                  color: palette.primary.withValues(alpha: 0.5),
                  border: Border.all(color: palette.gold.withValues(alpha: 0.4)),
                ),
                child: Text(vip.category.toUpperCase(),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TypographyTokens.label(size: 9).copyWith(
                        color: palette.goldSoft, letterSpacing: 0.8)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
