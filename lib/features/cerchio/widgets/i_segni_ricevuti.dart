import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/cerchio/i_segni_del_cerchio.dart';
import '../../../core/cerchio/il_cerchio_sociale.dart';
import '../../../core/chat/la_marca_del_genere.dart';
import '../../../core/identity/profile_controller.dart';
import '../../../design_system/theme/maestro_palette.dart';
import '../../../design_system/tokens/color_tokens.dart';
import '../../../design_system/tokens/spacing_tokens.dart';
import '../../../design_system/tokens/typography_tokens.dart';
import '../../maestri/art_navigation.dart';
import '../confronto_del_cielo_screen.dart';
import '../scheda_dell_amico_screen.dart';
import 'disegni_del_cerchio.dart';

/// **I SEGNI, ricevuti e mandati, ordine EY voci 10 e 11.** Ogni segno arriva
/// come un disegno da guardare prima che da leggere. Chi riceve risponde
/// SCEGLIENDO una delle risposte del segno, oppure con una reazione: zero
/// testo libero. Le richieste aprono la loro funzione al tocco.
class ISegniRicevuti extends StatelessWidget {
  const ISegniRicevuti({super.key, required this.segni});

  final List<SegnoScambiato> segni;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [for (final s in segni) _UnSegno(segno: s)],
    );
  }
}

class _UnSegno extends StatelessWidget {
  const _UnSegno({required this.segno});

  final SegnoScambiato segno;

  Future<void> _rispondi(BuildContext context,
      {int? risposta, Reazione? reazione}) async {
    final esito = await context.read<IlCerchioSociale>().rispondiAlSegno(
        segno.id,
        risposta: risposta,
        reazione: reazione?.name);
    if (!context.mounted) return;
    if (!esito.ok && esito.riga != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(esito.riga!)));
    }
  }

  void _apri(BuildContext context, ArteDellaRichiesta arte) {
    final navigatore = Navigator.of(context);
    DateTime? nascita;
    try {
      final id = context.read<ProfileController>().identity;
      nascita = id.isExample ? null : id.birthDate;
    } catch (senzaQuelDato) {
      // Il dato e' facoltativo: senza, si va avanti col ripiego.
    }
    final amico = context
        .read<IlCerchioSociale>()
        .cerchio
        .amici
        .where((p) => p.uid == segno.con)
        .firstOrNull;
    // Ogni richiesta apre la sua funzione (ordine EZ voce 08).
    switch (arte) {
      case ArteDellaRichiesta.confronto:
        if (amico != null) {
          navigatore.push(ConfrontoDelCieloScreen.route(amico));
        }
      case ArteDellaRichiesta.sinastria:
        // Il Cerchio non porta la nascita di un amico, solo il segno: la
        // sinastria si apre sulla sua porta, dove si sceglie con chi farla.
        final r = artRouteFor('synastry_vip', userBirth: nascita);
        if (r != null) navigatore.push(r);
      case ArteDellaRichiesta.tarocchi:
        final r = artRouteFor('day_oracle', userBirth: nascita);
        if (r != null) navigatore.push(r);
      case ArteDellaRichiesta.rune:
        final r = artRouteFor('rune_draw', userBirth: nascita);
        if (r != null) navigatore.push(r);
      case ArteDellaRichiesta.archetipo:
        final r = artRouteFor('archetype_test', userBirth: nascita);
        if (r != null) navigatore.push(r);
      case ArteDellaRichiesta.glifo:
        if (amico != null) {
          navigatore.push(SchedaDellAmicoScreen.route(amico));
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    const palette = MaestroPalette.neutral;
    final dato = ISegniDelCerchio.perId(segno.segno);
    if (dato == null) return const SizedBox.shrink();
    final reazione = Reazione.da(segno.reazione);
    final risposta = segno.risposta == null ||
            segno.risposta! < 0 ||
            segno.risposta! >= dato.risposte.length
        ? null
        : dato.risposte[segno.risposta!];
    return Card(
      key: Key('segno_${segno.id}'),
      color: palette.surfaceElevated.withValues(alpha: 0.8),
      margin: const EdgeInsets.symmetric(vertical: SpacingTokens.xxs),
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DisegnoDelSegno(
                    motivo: dato.motivo,
                    maestro: segno.ricevuto ? segno.maestroCon : null,
                    lato: 56),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Chi riceve legge la sua riga, chi ha mandato il
                      // titolo del pulsante; il nome lo dice la cornice.
                      Text(
                          segno.ricevuto
                              ? LaMarcaDelGenere.risolvi(dato.rigaDiChiRiceve)
                              : dato.testo,
                          style: TypographyTokens.titoloDiRiga()
                              .copyWith(color: palette.goldSoft)),
                      Text(
                          segno.ricevuto
                              ? 'Da ${segno.nomeCon}'
                              : 'A ${segno.nomeCon}',
                          style: TypographyTokens.didascalia()
                              .copyWith(color: ColorTokens.textSecondary)),
                    ],
                  ),
                ),
                if (reazione != null)
                  VoltoDellaReazione(reazione: reazione, lato: 36),
              ],
            ),
            if (risposta != null)
              Padding(
                padding: const EdgeInsets.only(top: SpacingTokens.xs),
                child: Text(
                    segno.ricevuto
                        ? 'Hai risposto: $risposta'
                        : 'Ti ha risposto: $risposta',
                    style: TypographyTokens.corpo()
                        .copyWith(color: ColorTokens.textPrimary)),
              ),
            if (segno.ricevuto && !segno.risposto) ...[
              const SizedBox(height: SpacingTokens.xs),
              Wrap(
                spacing: SpacingTokens.xs,
                runSpacing: SpacingTokens.xs,
                children: [
                  for (var i = 0; i < dato.risposte.length; i++)
                    ActionChip(
                      key: Key('risposta_${segno.id}_$i'),
                      backgroundColor: palette.deepest,
                      side: BorderSide(
                          color: palette.gold.withValues(alpha: 0.5)),
                      label: Text(dato.risposte[i],
                          style: TypographyTokens.etichetta()
                              .copyWith(color: palette.goldSoft)),
                      onPressed: () {
                        _rispondi(context, risposta: i);
                        if (dato.apre != null && i == 0) {
                          _apri(context, dato.apre!);
                        }
                      },
                    ),
                ],
              ),
              const SizedBox(height: SpacingTokens.xs),
              // LE REAZIONI RISPONDONO A QUESTO SEGNO: senza un segno a cui
              // rispondere non esistono, e il verso negativo nasce solo qui.
              Wrap(
                spacing: SpacingTokens.xxs,
                children: [
                  for (final r in Reazione.values)
                    Tooltip(
                      message: r.nome,
                      child: InkResponse(
                        key: Key('reazione_${segno.id}_${r.name}'),
                        enableFeedback: false,
                        onTap: () => _rispondi(context, reazione: r),
                        child: Padding(
                          padding: const EdgeInsets.all(SpacingTokens.xxs),
                          child: VoltoDellaReazione(reazione: r, lato: 34),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
