import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/astro/zodiac.dart';
import '../../core/maestro/maestro.dart';
import '../../core/synastry/vip_catalog.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'sinastria_vip_screen.dart';
import '../maestri/rotta_arte.dart';

/// La galleria di apertura della Sinastria VIP: si sceglie il VIP, poi si vede
/// il responso. E' l'apertura vera dell'arte.
///
/// Ricerca dal vivo per nome, filtri per categoria costruiti dal catalogo, una
/// fascia "In evidenza" con un tasto "A caso", e la griglia di tutti i VIP col
/// volto nella cornice. Tutto deterministico, tranne il tasto "A caso" che pesca
/// con `Random`. Il segno, la data e il nome dell'utente scorrono da qui fino al
/// responso, cosi' la card resta personale.
class SinastriaGalleryScreen extends StatefulWidget {
  const SinastriaGalleryScreen({
    super.key,
    this.userSign,
    this.userName,
    this.userBirth,
    this.random,
  });

  final Zodiac? userSign;
  final String? userName;
  final DateTime? userBirth;

  /// Iniettabile nei test, cosi' il tasto "A caso" e' verificabile. In
  /// produzione resta nullo e si usa un `Random` vero.
  final math.Random? random;

  static Route<void> route({
    Zodiac? userSign,
    String? userName,
    DateTime? userBirth,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => SogliaArte(
        id: 'synastry_vip',
        maestro: Maestro.medora,
        child: SinastriaGalleryScreen(
          userSign: userSign,
          userName: userName,
          userBirth: userBirth,
        ),
      ),
    );
  }

  @override
  State<SinastriaGalleryScreen> createState() => _SinastriaGalleryScreenState();
}

class _SinastriaGalleryScreenState extends State<SinastriaGalleryScreen> {
  static const String _tutti = 'Tutti';

  final TextEditingController _ricerca = TextEditingController();
  late final math.Random _rng = widget.random ?? math.Random();

  String _query = '';
  String _categoria = _tutti;

  @override
  void dispose() {
    _ricerca.dispose();
    super.dispose();
  }

  List<Vip> get _filtrati {
    final q = _query.trim().toLowerCase();
    return VipCatalog.vips.where((v) {
      final okCat = _categoria == _tutti || v.category == _categoria;
      final okNome = q.isEmpty || v.name.toLowerCase().contains(q);
      return okCat && okNome;
    }).toList(growable: false);
  }

  void _apri(Vip vip) {
    Navigator.of(context).push(SinastriaVipScreen.route(
      vip: vip,
      userSign: widget.userSign,
      userName: widget.userName,
      userBirth: widget.userBirth,
    ));
  }

  void _aCaso() {
    const vips = VipCatalog.vips;
    _apri(vips[_rng.nextInt(vips.length)]);
  }

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
    final categorie = [_tutti, ...VipCatalog.categorie];
    final filtrati = _filtrati;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: palette.deepest.withValues(alpha: 0.35),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: palette.goldSoft),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('Scegli il tuo VIP',
              maxLines: 1, style: TypographyTokens.display(size: 19)),
        ),
      ),
      body: CosmosBackground(
        seed: 17,
        showZodiac: false,
        child: SafeArea(
          child: CustomScrollView(
            key: const Key('sinastria_gallery'),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(SpacingTokens.lg,
                      kToolbarHeight, SpacingTokens.lg, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _BarraRicerca(
                        controller: _ricerca,
                        palette: palette,
                        onCambia: (v) => setState(() => _query = v),
                      ),
                      const SizedBox(height: SpacingTokens.md),
                      _FiltriCategoria(
                        categorie: categorie,
                        attiva: _categoria,
                        palette: palette,
                        onScegli: (c) => setState(() => _categoria = c),
                      ),
                      const SizedBox(height: SpacingTokens.lg),
                      _InEvidenza(
                        palette: palette,
                        onApri: _apri,
                        onACaso: _aCaso,
                      ),
                      const SizedBox(height: SpacingTokens.lg),
                      Text('Tutti i VIP',
                          style: TypographyTokens.display(size: 18)
                              .copyWith(color: palette.goldSoft)),
                      const SizedBox(height: SpacingTokens.sm),
                    ],
                  ),
                ),
              ),
              if (filtrati.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(SpacingTokens.xl),
                    child: Center(
                      child: Text('Nessun VIP con questo nome.',
                          key: const Key('sinastria_gallery_empty'),
                          style: TypographyTokens.corpo().copyWith(
                              color: ColorTokens.textSecondary)),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, 0,
                      SpacingTokens.lg, SpacingTokens.xxxl),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: SpacingTokens.md,
                      crossAxisSpacing: SpacingTokens.md,
                      childAspectRatio: 0.66,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _VipTile(
                        key: Key('vip_${filtrati[i].name}'),
                        vip: filtrati[i],
                        palette: palette,
                        onTap: () => _apri(filtrati[i]),
                      ),
                      childCount: filtrati.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// La barra di ricerca che filtra i VIP per nome, dal vivo.
class _BarraRicerca extends StatelessWidget {
  const _BarraRicerca({
    required this.controller,
    required this.palette,
    required this.onCambia,
  });

  final TextEditingController controller;
  final MaestroPalette palette;
  final ValueChanged<String> onCambia;

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: const Key('sinastria_search'),
      controller: controller,
      onChanged: onCambia,
      style: TypographyTokens.corpo()
          .copyWith(color: ColorTokens.textPrimary),
      cursorColor: palette.goldSoft,
      decoration: InputDecoration(
        hintText: 'Cerca un VIP per nome',
        hintStyle: TypographyTokens.corpo()
            .copyWith(color: ColorTokens.textSecondary),
        prefixIcon: Icon(Icons.search_rounded, color: palette.goldSoft),
        filled: true,
        fillColor: palette.surface.withValues(alpha: 0.4),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 0, horizontal: SpacingTokens.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
          borderSide: BorderSide(color: palette.gold.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
          borderSide: BorderSide(color: palette.gold.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
          borderSide: BorderSide(color: palette.goldSoft),
        ),
      ),
    );
  }
}

/// La riga dei filtri per categoria, con "Tutti" davanti.
class _FiltriCategoria extends StatelessWidget {
  const _FiltriCategoria({
    required this.categorie,
    required this.attiva,
    required this.palette,
    required this.onScegli,
  });

  final List<String> categorie;
  final String attiva;
  final MaestroPalette palette;
  final ValueChanged<String> onScegli;

  @override
  Widget build(BuildContext context) {
    // Un Wrap, non una lista orizzontale: tutte le categorie sono sempre a
    // vista, nessuna resta nascosta oltre il bordo.
    return Wrap(
      spacing: SpacingTokens.sm,
      runSpacing: SpacingTokens.sm,
      children: [
        for (final c in categorie)
          GestureDetector(
            key: Key('sinastria_filter_$c'),
            onTap: () => onScegli(c),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.md, vertical: SpacingTokens.xs),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
                color: c == attiva
                    ? palette.primary.withValues(alpha: 0.5)
                    : palette.surface.withValues(alpha: 0.35),
                border: Border.all(
                    color: c == attiva
                        ? palette.goldSoft
                        : palette.gold.withValues(alpha: 0.3),
                    width: c == attiva ? 1.5 : 1),
              ),
              child: Text(c,
                  style: TypographyTokens.label(size: 12).copyWith(
                      color: c == attiva
                          ? palette.goldSoft
                          : ColorTokens.textPrimary,
                      letterSpacing: 0.4)),
            ),
          ),
      ],
    );
  }
}

/// La fascia "In evidenza": una selezione curata piu' il tasto "A caso".
class _InEvidenza extends StatelessWidget {
  const _InEvidenza({
    required this.palette,
    required this.onApri,
    required this.onACaso,
  });

  final MaestroPalette palette;
  final ValueChanged<Vip> onApri;
  final VoidCallback onACaso;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('In evidenza',
                  style: TypographyTokens.display(size: 18)
                      .copyWith(color: palette.goldSoft)),
            ),
            FilledButton.icon(
              key: const Key('sinastria_random'),
              onPressed: onACaso,
              style: FilledButton.styleFrom(
                  backgroundColor: palette.primary,
                  foregroundColor: palette.onPrimary,
                  padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.md, vertical: SpacingTokens.xs)),
              icon: const Icon(Icons.casino_rounded, size: 18),
              label: Text('A caso',
                  style: TypographyTokens.label(size: 12)
                      .copyWith(letterSpacing: 0.4)),
            ),
          ],
        ),
        const SizedBox(height: SpacingTokens.sm),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: VipCatalog.inEvidenza.length,
            separatorBuilder: (_, __) => const SizedBox(width: SpacingTokens.md),
            itemBuilder: (context, i) {
              final vip = VipCatalog.inEvidenza[i];
              return SizedBox(
                width: 96,
                child: _VipTile(
                  key: Key('vip_evidenza_${vip.name}'),
                  vip: vip,
                  palette: palette,
                  onTap: () => onApri(vip),
                  compatta: true,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Una tessera VIP: il volto nella cornice, sotto il nome e il segno.
class _VipTile extends StatelessWidget {
  const _VipTile({
    super.key,
    required this.vip,
    required this.palette,
    required this.onTap,
    this.compatta = false,
  });

  final Vip vip;
  final MaestroPalette palette;
  final VoidCallback onTap;
  final bool compatta;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      palette.surfaceElevated.withValues(alpha: 0.7),
                      palette.deepest.withValues(alpha: 0.7),
                    ],
                  ),
                  border:
                      Border.all(color: palette.gold.withValues(alpha: 0.6)),
                ),
                clipBehavior: Clip.antiAlias,
                child: vip.hasImage
                    ? Image.asset(vip.thumbPath!,
                        // Un ritratto e' un soggetto: con cover il volto veniva
                        // tagliato dal riquadro. Trovato da una prova che
                        // enumera, non da una segnalazione.
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(Icons.auto_awesome,
                            color: palette.goldSoft, size: 28))
                    : Icon(Icons.auto_awesome,
                        color: palette.goldSoft, size: 28),
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(vip.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TypographyTokens.display(size: compatta ? 12 : 13)
                  .copyWith(color: ColorTokens.textPrimary)),
          Text(vip.sign.italianName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TypographyTokens.etichetta()
                  .copyWith(color: palette.goldSoft, letterSpacing: 0.4)),
        ],
      ),
    );
  }
}
