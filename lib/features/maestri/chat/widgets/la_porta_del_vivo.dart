import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/entitlement/entitlement_service.dart';
import '../../../../core/entitlement/tier.dart';
import '../../../../core/maestro/maestro.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/theme/maestro_scope.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import '../../../../design_system/transizioni/velo_del_cerchio.dart';
import '../../../pricing/pricing_screen.dart';
import '../../widgets/busto_del_maestro.dart';

/// **LA PASTIGLIA "DAL VIVO" NELLA TESTATA DELLA CHAT.** Ordine EJ voce 10,
/// 25 settembre 2026.
///
/// Il fondatore: *"Per ora il "live" è nel menù, ma vorrei un pulsante in
/// bella vista grigio se non hai abbonamento almeno tier 2 con avviso
/// elegante per chi ci preme e non ha almeno tier 2"*. Sta nella testata,
/// quindi non scorre e non copre i messaggi.
///
/// **Due stati, mai un vicolo cieco.** Dal tier 2 in su e' d'oro e porta nel
/// LIVE. Sotto e' grigia col lucchetto, e il tocco apre [IlFoglioDelVivo],
/// dove il Maestro dice con parole sue cosa succede dal vivo e porta ai
/// piani. La voce "Parlami a voce" nel menu resta dov'e'.
///
/// **Il telefono non e' il cancello.** Chi la vede d'oro entra nella
/// schermata LIVE, e li' il server guarda di nuovo abbonamento e minuti: se
/// dice di no, la schermata lo dice con la frase del Maestro, come dal menu.
class LaPortaDelVivo extends StatelessWidget {
  const LaPortaDelVivo({
    super.key,
    required this.maestro,
    required this.onEntra,
  });

  final Maestro maestro;

  /// Chi ha il piano giusto entra: chi monta la pastiglia apre il LIVE.
  final VoidCallback onEntra;

  /// Il piano da cui la voce viva e' aperta.
  static const Tier pianoMinimo = Tier.tier2;

  /// Quanto e' larga, in punti: la testata la toglie al titolo.
  static const double larghezza = 72;

  /// Quanto e' alta: sta sopra l'icona della conversazione nuova.
  static const double altezza = 26;

  /// Se la persona ha il piano che apre la voce viva. Senza il servizio
  /// nell'albero, come nelle prove che montano la chat da sola, vale il caso
  /// prudente: chiusa, e il foglio spiega.
  static bool aperta(BuildContext context) {
    try {
      return context.watch<EntitlementService>().tier.satisfies(pianoMinimo);
    } catch (errore) {
      // Senza il servizio nell'albero vale il caso prudente, non un guasto.
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = MaestroScope.forse(context) ?? MaestroPalette.neutral;
    final si = aperta(context);
    final colore = si ? palette.goldSoft : ColorTokens.textSecondary;
    return Semantics(
      button: true,
      // **"LIVE", IN MAIUSCOLO. Ordine EP voce 13.** Il fondatore: *"nella
      // chat il pulsante sara' semplicemente "LIVE" in maiuscolo"*. Prima
      // diceva "Dal vivo" (ordine EO voce 16).
      label: si ? 'LIVE' : 'LIVE, dal piano dell\'Adepto',
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          enableFeedback: false,
          key: Key(si ? 'chat_dal_vivo_aperta' : 'chat_dal_vivo_chiusa'),
          borderRadius: BorderRadius.circular(altezza / 2),
          onTap: si ? onEntra : () => IlFoglioDelVivo.apri(context, maestro),
          child: Container(
            width: larghezza,
            height: altezza,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(altezza / 2),
              color: si
                  ? palette.gold.withValues(alpha: 0.16)
                  : Colors.transparent,
              border:
                  Border.all(color: colore.withValues(alpha: si ? 0.85 : 0.45)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(si ? Icons.mic_rounded : Icons.lock_rounded,
                    size: 14, color: colore),
                const SizedBox(width: 4),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'LIVE',
                      key: const Key('chat_dal_vivo_scritta'),
                      style: TypographyTokens.didascalia(weight: 600)
                          .copyWith(color: colore),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// **IL FOGLIO DI CHI NON HA ANCORA LA VOCE VIVA.** Ordine EJ voce 10.
///
/// Il Maestro dice con il suo lessico cosa succede dal vivo, e invita al
/// piano che lo apre. Due strade: *Non ora*, che chiude, e il piano, che
/// porta ai piani del Cerchio. Nessun messaggio d'errore.
abstract final class IlFoglioDelVivo {
  /// Le parole del Maestro, una volta sola e per ciascuno le sue.
  static String parole(Maestro m) => switch (m) {
        Maestro.medora => 'Dal vivo ci guardiamo in viso e parliamo a voce: '
            'il tuo cielo lo leggiamo insieme mentre mi racconti. Questa '
            'stanza si apre con il piano dell\'Adepto. Quando vorrai '
            'entrarci, ti aspetto lì.',
        Maestro.aura => 'Dal vivo ci parliamo con la voce. Io ascolto '
            'anche il respiro fra le tue parole. È un incontro che si apre '
            'con il piano dell\'Adepto. Quando sarà il momento, ti aspetto '
            'lì con calma.',
        Maestro.caligo => 'Dal vivo le parole si dicono a voce. Le rune '
            'ascoltano chi parla. Questa soglia si varca con il piano '
            'dell\'Adepto. Quando vorrai, la porta resta qui.',
      };

  static Future<void> apri(BuildContext context, Maestro maestro) async {
    final palette = MaestroScope.forse(context) ?? MaestroPalette.neutral;
    final aiPiani = await foglioDelCerchio<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (foglio) => Container(
        key: const Key('chat_foglio_dal_vivo'),
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BustoDelMaestro(maestro: maestro, height: 150),
                const SizedBox(height: SpacingTokens.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mic_rounded, color: palette.goldSoft, size: 20),
                    const SizedBox(width: SpacingTokens.xs),
                    Flexible(
                      child: Text(
                        'LIVE con ${maestro.displayName}',
                        textAlign: TextAlign.center,
                        style: TypographyTokens.titoloDiSchermata()
                            .copyWith(color: palette.goldSoft),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SpacingTokens.sm),
                Text(
                  parole(maestro),
                  key: const Key('chat_foglio_dal_vivo_parole'),
                  textAlign: TextAlign.center,
                  style: TypographyTokens.corpo()
                      .copyWith(color: ColorTokens.textPrimary, height: 1.45),
                ),
                const SizedBox(height: SpacingTokens.lg),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    key: const Key('chat_foglio_dal_vivo_piani'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: palette.goldSoft,
                      side: BorderSide(
                          color: palette.gold.withValues(alpha: 0.7)),
                      padding: const EdgeInsets.symmetric(
                          vertical: SpacingTokens.sm),
                    ),
                    onPressed: () => Navigator.of(foglio).pop(true),
                    child: Text('Scopri il piano dell\'Adepto',
                        style: TypographyTokens.label()),
                  ),
                ),
                const SizedBox(height: SpacingTokens.xs),
                TextButton(
                  key: const Key('chat_foglio_dal_vivo_non_ora'),
                  onPressed: () => Navigator.of(foglio).pop(false),
                  child: Text('Non ora',
                      style: TypographyTokens.etichetta()
                          .copyWith(color: ColorTokens.textSecondary)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (aiPiani == true && context.mounted) {
      await Navigator.of(context).push(PricingScreen.route());
    }
  }
}
