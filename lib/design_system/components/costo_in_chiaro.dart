import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/entitlement/entitlement_service.dart';
import '../../core/entitlement/listino_degli_eos.dart';
import '../../core/entitlement/question_allowance.dart';
import '../../core/entitlement/tier.dart';
import '../theme/maestro_palette.dart';
import '../theme/maestro_scope.dart';
import '../tokens/color_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';
import 'icona_degli_eos.dart';

/// IL COSTO IN CHIARO, PRIMA DI SPENDERE. Ordine AN voce 05.
///
/// Sopra il pulsante di un'arte a consumo si legge sempre una riga vera: se
/// oggi ne resta una gratis lo dice ("1 stesa rimasta oggi"), e quando il
/// gratuito e' finito dice quanto costa la prossima ("un'altra stesa, 120
/// Eos"). Mai un lucchetto muto, mai una sorpresa dopo il tocco.
///
/// **Il costo viene dal listino unico**, mai da un numero scritto qui; il
/// residuo viene dal contatore che parla col server. Questo widget non
/// decide niente: mostra.
class CostoInChiaro extends StatelessWidget {
  const CostoInChiaro({
    super.key,
    required this.voce,
    required this.cosa,
    this.giaUsateOggi = 0,
  });

  /// La voce del listino, che porta il costo e i tetti.
  final VoceDelListino voce;

  /// Come si chiama la cosa al singolare, per la riga del residuo: "stesa",
  /// "domanda", "sinastria".
  final String cosa;

  /// Quante se ne sono gia' usate oggi. Chi lo sa e' la schermata.
  final int giaUsateOggi;

  @override
  Widget build(BuildContext context) {
    final palette = MaestroScope.forse(context) ?? MaestroPalette.neutral;
    Tier tier = Tier.free;
    int saldo = 0;
    try {
      tier = context.watch<EntitlementService>().tier;
      saldo = context.watch<QuestionAllowance>().saldoEos;
    } catch (errore) {
      // Senza i controller nell'albero resta il caso piu' prudente, il
      // Viandante a saldo zero: si mostra il costo, mai un'esperienza
      // regalata per sbaglio.
    }
    final restano = voce.quanteRestano(tier, giaUsateOggi);

    // SENZA TETTO non c'e' niente da dire: il piano la include, e una riga
    // sul costo confonderebbe chi ha gia' pagato.
    if (restano == null) return const SizedBox.shrink();

    if (restano > 0) {
      return Text(
        ListinoDegliEos.residuo(restano, cosa),
        key: const Key('costo_residuo_del_giorno'),
        style: TypographyTokens.didascalia()
            .copyWith(color: ColorTokens.textSecondary),
      );
    }

    // TETTO RAGGIUNTO: il costo in chiaro accanto al pulsante, con lo stato
    // onesto quando gli Eos non bastano.
    final bastano = saldo >= voce.costo;
    return Row(
      key: const Key('costo_in_chiaro'),
      mainAxisSize: MainAxisSize.min,
      children: [
        IconaDegliEos(misura: 14, colore: palette.goldSoft),
        const SizedBox(width: SpacingTokens.xs),
        Flexible(
          child: Text(
            bastano
                ? '${voce.nome}, ${ListinoDegliEos.prezzo(voce.costo)}'
                : 'Ti servono ${ListinoDegliEos.prezzo(voce.costo)}, ne hai '
                    '$saldo',
            style: TypographyTokens.didascalia().copyWith(
                color: bastano ? palette.goldSoft : ColorTokens.textMuted),
          ),
        ),
      ],
    );
  }
}
