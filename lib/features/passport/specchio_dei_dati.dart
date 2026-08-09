import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/astro/natal_chart_controller.dart';
import '../../core/identity/natal_identity.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../identity/completa_il_luogo.dart';

/// QUELLO CHE IL CERCHIO RICORDA DI TE, detto in chiaro.
///
/// **Perche' esiste.** Una fondatrice ha usato l'app per mesi convinta di aver
/// dato il proprio luogo di nascita, e non l'aveva. Non c'era modo di
/// accorgersene: da nessuna parte l'app diceva cosa risultava memorizzato.
/// Quando l'ha segnalato, non si poteva nemmeno guardare il suo telefono, e la
/// diagnosi e' stata una caccia al buio durata giorni.
///
/// **Non e' un pannello da tecnici.** Non ci sono chiavi, percorsi di file ne'
/// stati interni: ci sono le tre cose che la persona ha dato, dette come le
/// direbbe lei, e cosa il Cerchio e' riuscito a farne. Dove manca qualcosa, il
/// gesto per darlo e' li' accanto, perche' dire che manca un dato senza
/// offrire il modo di darlo e' un vicolo cieco cortese.
class SpecchioDeiDati extends StatelessWidget {
  const SpecchioDeiDati({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final porta = context.watch<BirthIdentityController>();
    final motore = context.watch<NatalChartController>();
    final dettagli = porta.details;

    // Il cielo vero, il ripiego e il niente sono TRE stati, non due: dire
    // "essenziale" a chi non ha nessuna carta sarebbe falso quanto dire
    // "completa" a chi ha il ripiego.
    final String cielo;
    if (porta.cartaCompleta != null) {
      cielo = 'Completo: Sole, Luna, pianeti e case';
    } else if (porta.cartaEssenziale || motore.ripiego) {
      cielo = 'Essenziale: per ora il Sole e il suo segno';
    } else {
      cielo = 'Non ancora tracciato';
    }

    return Container(
      key: const Key('specchio_dei_dati'),
      margin: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        border: Border.all(color: p.gold.withValues(alpha: 0.25)),
        color: p.surfaceElevated.withValues(alpha: 0.35),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('QUELLO CHE IL CERCHIO RICORDA DI TE',
              style: TypographyTokens.label(size: 12)
                  .copyWith(color: p.goldSoft, letterSpacing: 2)),
          const SizedBox(height: SpacingTokens.sm),
          _Riga(
            chiave: const Key('specchio_data'),
            nome: 'Il giorno',
            valore: dettagli?.date == null
                ? 'Non l\'hai ancora detto'
                : '${dettagli!.date.day}/${dettagli.date.month}/'
                    '${dettagli.date.year}',
            manca: dettagli?.date == null,
          ),
          _Riga(
            chiave: const Key('specchio_ora'),
            nome: 'L\'ora',
            valore: (dettagli?.hasTime ?? false)
                ? '${dettagli!.time!.hour.toString().padLeft(2, '0')}:'
                    '${dettagli.time!.minute.toString().padLeft(2, '0')}'
                : 'Non l\'hai data: l\'Ascendente resta fuori',
            manca: !(dettagli?.hasTime ?? false),
          ),
          _Riga(
            chiave: const Key('specchio_luogo'),
            nome: 'Il luogo',
            valore: dettagli?.place == null
                ? 'Non l\'hai dato: l\'Ascendente e le case restano fuori'
                : dettagli!.place!.label,
            manca: dettagli?.place == null,
            // IL GESTO STA DOVE STA LA MANCANZA. Senza, questa riga sarebbe
            // solo un modo piu' elegante di dire alla persona che le manca
            // qualcosa senza aiutarla a darlo.
            azione: dettagli?.place == null
                ? (
                    'Aggiungi il luogo',
                    () => CompletaIlLuogo.chiedi(context),
                  )
                : null,
          ),
          _Riga(
            chiave: const Key('specchio_cielo'),
            nome: 'Il tuo cielo',
            valore: cielo,
            manca: porta.cartaCompleta == null,
          ),
        ],
      ),
    );
  }
}

class _Riga extends StatelessWidget {
  const _Riga({
    required this.chiave,
    required this.nome,
    required this.valore,
    required this.manca,
    this.azione,
  });

  final Key chiave;
  final String nome;
  final String valore;

  /// Se il dato non c'e'. Non si urla: si spegne il colore, come una stella
  /// che non si e' accesa.
  final bool manca;

  /// Il gesto che completa il dato, quando c'e' un modo di completarlo.
  final (String, VoidCallback)? azione;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      key: chiave,
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(nome,
                style: TypographyTokens.body(size: 13)
                    .copyWith(color: ColorTokens.textSecondary)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(valore,
                    style: TypographyTokens.body(size: 14).copyWith(
                      color: manca ? ColorTokens.textMuted : p.goldSoft,
                      height: 1.35,
                    )),
                if (azione != null)
                  TextButton(
                    key: const Key('specchio_completa_luogo'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: azione!.$2,
                    child: Text(azione!.$1,
                        style: TypographyTokens.label(size: 13)
                            .copyWith(color: p.goldSoft)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
