import 'package:flutter/material.dart';

import '../../../../core/astro/data_italiana.dart';
import '../../../../core/maestro/maestro.dart';
import '../../../../core/viaggio/diario_dei_viaggi.dart';
import '../../../../core/viaggio/la_domanda_del_viaggio.dart';
import '../../../../core/viaggio/le_parole_del_cammino.dart';
import '../../../../design_system/components/depth_card.dart';
import '../../../../design_system/components/titolo_che_non_si_rompe.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/theme/maestro_scope.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import '../../../../design_system/transizioni/passaggio_del_cerchio.dart';
import '../../../../design_system/typography/paragrafi_di_lettura.dart';
import 'il_tunnel_che_scende.dart';

/// **IL DIARIO DEI VIAGGI, e i quattro strati si leggono di fila.** Ordine DQ
/// voci 01 e 02, 15 settembre 2026.
///
/// **Il Diario c'era dall'ordine DC voce 09, e non si vedeva.** *"Chi torna
/// dopo sei mesi rilegge le domande che si faceva e le risposte che aveva
/// avuto"*: il Diario le conservava sul telefono, e nessuna schermata le
/// mostrava. L'ordine DQ lo vuole a schermo: *"alla quarta, i quattro strati
/// si leggono di fila. Non quattro frasi sparse in quattro schede: una pagina
/// sola, nel Diario, che si rilegge. E' la risposta alla domanda 'cosa mi
/// rimane', ed e' la cosa che di questa funzione resta alla persona."*
///
/// **Vive sul telefono**, come il Diario: le domande di una persona non
/// passano da nessun server per essere rilette.
class IlDiarioDeiViaggiScreen extends StatelessWidget {
  const IlDiarioDeiViaggiScreen({
    super.key,
    required this.diario,
    this.evidenzia,
  });

  final DiarioDeiViaggi diario;

  /// Il cammino da mettere in cima, quando si arriva dalla rivelazione.
  final String? evidenzia;

  static Route<void> route(
          {required DiarioDeiViaggi diario, String? evidenzia}) =>
      PassaggioDelCerchio.rotta<void>((_) => MaestroScope(
            // **VESTITO DI CALIGO DAL PRIMO FOTOGRAMMA**: il Diario e' del
            // Viaggio, e una rotta spinta senza il suo scope prende il
            // colore neutro che l'app tiene sopra il Navigator. Trovato
            // dalla prova del cammino, dove quello scope non c'e' e la
            // pagina cadeva.
            maestro: Maestro.caligo,
            child: IlDiarioDeiViaggiScreen(diario: diario, evidenzia: evidenzia),
          ));

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.caligo));
    final cammini = [...diario.cammini];
    // **IL CAMMINO APPENA CHIUSO VA IN CIMA**: si arriva qui dalla
    // rivelazione per rileggere proprio quello.
    cammini.sort((a, b) => a.id == evidenzia
        ? -1
        : b.id == evidenzia
            ? 1
            : 0);
    final altre = [
      for (final v in diario.viaggi)
        if (v.cammino == null) v,
    ];
    return Scaffold(
      backgroundColor: PittoreDelTunnel.bluProfondo,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: TitoloCheNonSiRompe(
          testo: LeParoleDelCammino.ilDiario,
          stile:
              TypographyTokens.titoloScheda().copyWith(color: palette.goldSoft),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          key: const Key('diario_dei_viaggi'),
          padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.md,
              SpacingTokens.lg, SpacingTokens.xxl),
          children: [
            if (cammini.isEmpty && altre.isEmpty)
              ParagrafiDiLettura(
                testo: LeParoleDelCammino.diarioVuoto,
                stile: TypographyTokens.lettura()
                    .copyWith(color: ColorTokens.textSecondary),
              ),
            for (final c in cammini) ...[
              _UnCammino(
                  id: c.id, domanda: c.domanda, strati: c.strati, palette: palette),
              const SizedBox(height: SpacingTokens.lg),
            ],
            if (altre.isNotEmpty) ...[
              Text(
                LeParoleDelCammino.leAltreDiscese,
                style: TypographyTokens.etichetta()
                    .copyWith(color: palette.goldSoft, letterSpacing: 2.0),
              ),
              const SizedBox(height: SpacingTokens.sm),
              for (final v in altre) ...[
                _UnaDiscesa(viaggio: v, palette: palette),
                const SizedBox(height: SpacingTokens.md),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

/// Se la discesa era soltanto per incontrarlo.
bool _soloIncontro(UnViaggio v) =>
    v.temaDellaDomanda == LaDomandaDelViaggio.idSoloPerIncontrarlo ||
    v.domanda == LaDomandaDelViaggio.soloPerIncontrarlo ||
    v.domanda.trim().isEmpty;

/// **UN CAMMINO**: la domanda, quanti strati, e gli strati di fila.
class _UnCammino extends StatelessWidget {
  const _UnCammino({
    required this.id,
    required this.domanda,
    required this.strati,
    required this.palette,
  });

  final String id;
  final String domanda;
  final List<UnViaggio> strati;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    final conDomanda = strati.isEmpty || !_soloIncontro(strati.first);
    return DepthCard(
      key: Key('diario_cammino_$id'),
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LeParoleDelCammino.laDomandaDelCammino,
            style: TypographyTokens.etichetta()
                .copyWith(color: palette.goldSoft, letterSpacing: 2.0),
          ),
          const SizedBox(height: SpacingTokens.xs),
          ParagrafiDiLettura(
            testo:
                conDomanda ? domanda : LeParoleDelCammino.soloPerIncontrarlo,
            stile: TypographyTokens.lettura()
                .copyWith(color: ColorTokens.textPrimary),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            '${LeParoleDelCammino.quantiStrati(strati.length)}, dal '
            '${strati.isEmpty ? '' : dataItalianaEstesa(strati.first.quando)}',
            style: TypographyTokens.didascalia()
                .copyWith(color: ColorTokens.textSecondary),
          ),
          for (var i = 0; i < strati.length; i++) ...[
            const SizedBox(height: SpacingTokens.lg),
            Text(
              LeParoleDelCammino.etichettaDelloStrato(strati[i].strato ?? i + 1,
                  conDomanda: conDomanda),
              key: Key('diario_strato_${id}_${i + 1}'),
              style: TypographyTokens.etichetta()
                  .copyWith(color: palette.goldSoft),
            ),
            const SizedBox(height: SpacingTokens.xs),
            if ((strati[i].titolo ?? '').isNotEmpty)
              TitoloCheNonSiRompe(
                testo: strati[i].titolo!,
                stile: TypographyTokens.titoloScheda()
                    .copyWith(color: ColorTokens.textPrimary),
              ),
            if ((strati[i].risposta ?? '').isNotEmpty) ...[
              const SizedBox(height: SpacingTokens.xs),
              ParagrafiDiLettura(
                testo: strati[i].risposta!,
                stile: TypographyTokens.lettura()
                    .copyWith(color: ColorTokens.textPrimary),
              ),
            ],
            if ((strati[i].gesto ?? '').isNotEmpty) ...[
              const SizedBox(height: SpacingTokens.xs),
              ParagrafiDiLettura(
                testo: strati[i].gesto!,
                stile: TypographyTokens.lettura()
                    .copyWith(color: ColorTokens.textSecondary),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

/// **UNA DISCESA FUORI DA UN CAMMINO**: quelle di prima dell'ordine DQ e
/// quelle dopo il riconoscimento, una domanda nuova ogni volta.
class _UnaDiscesa extends StatelessWidget {
  const _UnaDiscesa({required this.viaggio, required this.palette});

  final UnViaggio viaggio;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    final v = viaggio;
    return DepthCard(
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dataItalianaEstesa(v.quando),
            style: TypographyTokens.didascalia()
                .copyWith(color: ColorTokens.textSecondary),
          ),
          const SizedBox(height: SpacingTokens.xs),
          ParagrafiDiLettura(
            testo: _soloIncontro(v)
                ? LaDomandaDelViaggio.soloPerIncontrarlo
                : v.domanda,
            stile: TypographyTokens.lettura().copyWith(color: palette.goldSoft),
          ),
          if ((v.titolo ?? '').isNotEmpty) ...[
            const SizedBox(height: SpacingTokens.xs),
            TitoloCheNonSiRompe(
              testo: v.titolo!,
              stile: TypographyTokens.titoloScheda()
                  .copyWith(color: ColorTokens.textPrimary),
            ),
          ],
          if ((v.risposta ?? '').isNotEmpty) ...[
            const SizedBox(height: SpacingTokens.xs),
            ParagrafiDiLettura(
              testo: v.risposta!,
              stile: TypographyTokens.lettura()
                  .copyWith(color: ColorTokens.textPrimary),
            ),
          ],
        ],
      ),
    );
  }
}
