import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/amici/amici_offline.dart';
import '../../core/astro/luogo_attuale.dart';
import '../../core/astro/zodiac.dart';
import '../../core/chat/user_profile.dart';
import '../../core/horoscope/astro_tradition.dart';
import '../../core/horoscope/horoscope.dart';
import '../../core/horoscope/i_segni_delle_tradizioni.dart';
import '../../core/horoscope/la_lettura_cinese.dart';
import '../../core/horoscope/la_lettura_vedica.dart';
import '../../core/maestro/maestro.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../horoscope/horoscope_visuals.dart';
import '../horoscope/la_testa_della_tradizione.dart';
import '../horoscope/oroscopo_share_card.dart';

/// **L'OROSCOPO DI UN AMICO, ordine ES voce 12.** Si sceglie la tradizione,
/// si scopre il suo segno, si leggono le quattro schede del giorno e si
/// mandano con la card.
///
/// Le letture sono le stesse della persona, sui dati dell'amico:
/// l'Occidentale sul suo segno solare (senza la sua carta natale, e si dice),
/// la Cinese dal suo animale e dal tronco del suo giorno, la Vedica dalla sua
/// Luna di nascita. Chi legge e' l'amico, quindi si parla al neutro.
class LOroscopoDellAmicoScreen extends StatefulWidget {
  const LOroscopoDellAmicoScreen({super.key, required this.amico, this.adesso});

  final Amico amico;

  /// L'istante di oggi, per le prove.
  final DateTime? adesso;

  /// Vestita da Medora, come la lista degli amici e il Calendario.
  static Route<void> route(Amico amico) => MaterialPageRoute<void>(
      builder: (_) => MaestroScope(
          maestro: Maestro.medora,
          child: LOroscopoDellAmicoScreen(amico: amico)));

  @override
  State<LOroscopoDellAmicoScreen> createState() =>
      _LOroscopoDellAmicoScreenState();
}

class _LOroscopoDellAmicoScreenState extends State<LOroscopoDellAmicoScreen>
    with SingleTickerProviderStateMixin {
  late final DateTime _adesso = widget.adesso ?? DateTime.now();
  AstroTradition _tradizione = AstroTradition.occidentale;
  LuogoDelGiorno? _luogo;
  final GlobalKey _cardKey = GlobalKey();
  bool _renderCard = false;
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  )..repeat();

  @override
  void initState() {
    super.initState();
    unawaited(DoveSonoAdesso.letto().then((l) {
      if (!mounted || l == null) return;
      setState(() =>
          _luogo = LuogoDelGiorno(lat: l.lat, lon: l.lon, citta: l.citta));
    }));
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  NascitaDeiSegni get _nascita => NascitaDeiSegni(
        locale: widget.amico.momento,
        oraNota: widget.amico.oraNota,
        fuso: widget.amico.fuso,
      );

  List<HoroscopeCard>? _schede(SegnoDellaTradizione segno) {
    final a = widget.amico;
    switch (_tradizione) {
      case AstroTradition.cinese:
        if (segno.animale == null) return null;
        return LaLetturaCinese.schede(
            oggi: _adesso,
            nascita: a.nascita,
            animale: segno.animale!,
            forma: CourtesyForm.unknown);
      case AstroTradition.vedica:
        return LaLetturaVedica.schede(
            adesso: _adesso,
            nascita: _nascita,
            luogo: _luogo,
            forma: CourtesyForm.unknown);
      default:
        final sole = Zodiac.fromDate(a.nascita);
        // **AL NEUTRO, per l'amico**: le marche del genere del pool si
        // risolvono con la forma di chi usa l'app, e il genere dell'amico
        // non si sa. Si torna alla forma di prima subito dopo.
        final prima = LaMarcaDelGenere.formaCorrente;
        LaMarcaDelGenere.formaCorrente = CourtesyForm.unknown;
        try {
          return Horoscope.forSign(
              sign: sole,
              dayOfYear: Horoscope.dayOfYear(_adesso),
              year: _adesso.year);
        } finally {
          LaMarcaDelGenere.formaCorrente = prima;
        }
    }
  }

  Future<void> _condividi(SegnoDellaTradizione segno) async {
    setState(() => _renderCard = true);
    try {
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 80));
      await shareOroscopoCard(
        boundaryKey: _cardKey,
        text: 'Il tuo oroscopo di oggi, ${widget.amico.nome}: ${segno.nome}. '
            'Esoteric Circle.',
      );
    } finally {
      if (mounted) setState(() => _renderCard = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
    final segno = ISegniDelleTradizioni.per(_tradizione, _nascita);
    final schede = _schede(segno);
    return Scaffold(
      backgroundColor: palette.deepest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: palette.goldSoft),
        title: Text('L\'oroscopo di ${widget.amico.nome}',
            style: TypographyTokens.titoloDiSchermata()
                .copyWith(color: palette.goldSoft)),
      ),
      body: Stack(
        children: [
          ListView(
            key: const Key('amico_oroscopo_lista'),
            padding: const EdgeInsets.all(SpacingTokens.lg),
            children: [
              Wrap(
                spacing: SpacingTokens.sm,
                alignment: WrapAlignment.center,
                children: [
                  for (final t in const [
                    AstroTradition.occidentale,
                    AstroTradition.cinese,
                    AstroTradition.vedica,
                  ])
                    ChoiceChip(
                      key: Key('amico_tradizione_${t.name}'),
                      label: Text(t.label),
                      selected: _tradizione == t,
                      onSelected: (_) => setState(() => _tradizione = t),
                    ),
                ],
              ),
              const SizedBox(height: SpacingTokens.md),
              LaTestaDellaTradizione(
                  tradizione: _tradizione, segno: segno, palette: palette),
              const SizedBox(height: SpacingTokens.md),
              if (_tradizione == AstroTradition.occidentale)
                Text(
                    'Letto sul segno solare di ${widget.amico.nome}: con la '
                    'sua carta natale la lettura sarebbe più sua.',
                    key: const Key('amico_nota_occidentale'),
                    textAlign: TextAlign.center,
                    style: TypographyTokens.didascalia()
                        .copyWith(color: ColorTokens.textSecondary)),
              if (schede == null)
                Text(
                    'Per questa tradizione servono dati che non ci sono: '
                    'l\'ora di nascita di ${widget.amico.nome}.',
                    key: const Key('amico_senza_lettura'),
                    textAlign: TextAlign.center,
                    style: TypographyTokens.corpo()
                        .copyWith(color: ColorTokens.textSecondary)),
              if (schede != null)
                for (final s in schede) ...[
                  const SizedBox(height: SpacingTokens.md),
                  _Scheda(scheda: s, palette: palette, pulse: _pulse),
                ],
              const SizedBox(height: SpacingTokens.lg),
              if (schede != null)
                FilledButton.icon(
                  key: const Key('amico_condividi'),
                  onPressed: () => _condividi(segno),
                  icon: const Icon(Icons.ios_share_rounded),
                  label: Text('Manda a ${widget.amico.nome}'),
                ),
            ],
          ),
          if (_renderCard && schede != null)
            Positioned(
              left: -3000,
              top: 0,
              child: RepaintBoundary(
                key: _cardKey,
                child: OroscopoShareCard(
                  sign: Zodiac.fromDate(widget.amico.nascita),
                  cards: schede,
                  palette: palette,
                  nome: OroscopoShareCard.soloIlNome(widget.amico.nome),
                  nomeDelSegno: _tradizione == AstroTradition.occidentale
                      ? null
                      : segno.nome,
                  figuraDelSegno: _tradizione == AstroTradition.occidentale
                      ? null
                      : LaTestaDellaTradizione.figura(_tradizione, segno),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Scheda extends StatelessWidget {
  const _Scheda(
      {required this.scheda, required this.palette, required this.pulse});

  final HoroscopeCard scheda;
  final MaestroPalette palette;
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('amico_scheda_${scheda.domain.name}'),
      padding: const EdgeInsets.all(SpacingTokens.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        color: palette.surfaceElevated.withValues(alpha: 0.9),
        border: Border.all(color: palette.gold.withValues(alpha: 0.32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(scheda.title,
              style: TypographyTokens.titoloScheda()
                  .copyWith(color: palette.goldSoft)),
          Text(scheda.domain.label.toUpperCase(),
              style: TypographyTokens.etichetta().copyWith(
                  color: ColorTokens.textSecondary, letterSpacing: 1.4)),
          const SizedBox(height: SpacingTokens.sm),
          DomainLevel(
              domain: scheda.domain,
              value: scheda.indicator,
              palette: palette,
              pulse: pulse),
          const SizedBox(height: SpacingTokens.sm),
          Text(scheda.text,
              style: TypographyTokens.lettura()
                  .copyWith(color: ColorTokens.textPrimary, height: 1.5)),
        ],
      ),
    );
  }
}
