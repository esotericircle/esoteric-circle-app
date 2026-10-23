import 'package:flutter/material.dart';

import '../../core/cerchio/il_cerchio_sociale.dart';
import '../../core/maestro/maestro.dart';
import '../../core/synastry_evolutiva/la_sinastria_condivisa.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/components/il_responso_in_tre_paragrafi.dart';
import '../../design_system/components/titolo_del_responso.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';
import '../../design_system/theme/app_theme.dart';
import 'il_ritratto_della_coppia.dart' show immagineDellaSinastria;

/// **IL VOSTRO CIELO E' STATO LETTO.** Ordine GD voce GD.21, 23 ottobre 2026
/// (proposta dell'Architetto approvata dal fondatore con "2 si"): la lettura
/// che un amico del Cerchio ha fatto con te, arrivata col suo avviso. Per
/// vederla si entra nell'app: dal Cerchio, "Il vostro cielo è stato letto".
///
/// **LO STESSO RESPONSO**: i capitoli sono quelli che ha letto lui, parola per
/// parola, nel formato di casa dei capitoli ([ResponsoInTreParagrafi]); il
/// testo e' scritto a lui (il "tu" e' chi ha letto, il nome e' il tuo), e la
/// riga in cima lo dice. Nessuna nascita: la lettura non ne porta.
class LaSinastriaRicevutaScreen extends StatelessWidget {
  const LaSinastriaRicevutaScreen({super.key, required this.ricevuta});

  final SinastriaRicevuta ricevuta;

  static Route<void> route(SinastriaRicevuta ricevuta) =>
      PassaggioDelCerchio.rotta<void>(
          (_) => LaSinastriaRicevutaScreen(ricevuta: ricevuta));

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
    final lettura = LaSinastriaCondivisa.da(ricevuta.responso);
    final stile =
        TypographyTokens.lettura().copyWith(color: ColorTokens.textPrimary);
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // Semitrasparente in ogni stato (ordine FY voce FY.20).
        backgroundColor: palette.deepest.withValues(alpha: AppTheme.veloDellaBarra),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: palette.goldSoft),
        title: Text('Il vostro cielo',
            style: TypographyTokens.titoloSezione()
                .copyWith(color: palette.goldSoft)),
      ),
      body: CosmosBackground(
        seed: 7,
        showZodiac: false,
        child: SafeArea(
          child: ListView(
            key: const Key('sinastria_ricevuta'),
            padding: const EdgeInsets.all(SpacingTokens.lg),
            children: [
              Text('Il vostro cielo è stato letto',
                  textAlign: TextAlign.center,
                  style: TypographyTokens.titoloScheda()
                      .copyWith(color: palette.goldSoft)),
              const SizedBox(height: SpacingTokens.xs),
              Text(
                  lettura == null
                      ? 'Questa lettura non si apre: chiedi a '
                          '${ricevuta.nomeDa} di mandarla di nuovo.'
                      : '${ricevuta.nomeDa} ha letto la vostra sinastria, '
                          'legame ${lettura.legame.nome.toLowerCase()}. Il '
                          'segno della vostra relazione è ${lettura.segno}. '
                          'Qui sotto la sua lettura, com\'è arrivata a lui: '
                          'il "tu" è ${ricevuta.nomeDa}.',
                  key: const Key('sinastria_ricevuta_riga'),
                  textAlign: TextAlign.center,
                  style: TypographyTokens.didascalia()
                      .copyWith(color: ColorTokens.textSecondary)),
              const SizedBox(height: SpacingTokens.lg),
              if (lettura != null)
                for (final c in lettura.capitoli) ...[
                  Center(
                    child: ClipOval(
                      child: Image.asset(
                          immagineDellaSinastria(c.capitolo.medaglione),
                          width: 64,
                          height: 64),
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  Text(c.capitolo.nome.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TypographyTokens.etichetta().copyWith(
                          color: palette.goldSoft, letterSpacing: 2.0)),
                  const SizedBox(height: SpacingTokens.xxs),
                  TitoloDelResponso(
                    chiaveDelTesto: Key('sinastria_ricevuta_${c.capitolo.name}'),
                    testo: c.titolo,
                    allineamento: TextAlign.center,
                    aCapoFraLeParole: true,
                    stile: TypographyTokens.titoloSezione()
                        .copyWith(color: palette.goldSoft, height: 1.25),
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  ResponsoInTreParagrafi(
                    paragrafi: c.paragrafi,
                    daDoveViene: c.daDoveViene,
                    palette: palette,
                    stile: stile,
                  ),
                  const SizedBox(height: SpacingTokens.xl),
                ],
            ],
          ),
        ),
      ),
    );
  }
}
