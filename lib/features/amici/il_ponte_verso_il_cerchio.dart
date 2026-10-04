import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/cerchio/il_cerchio_sociale.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../cerchio/il_tuo_cerchio_screen.dart';
import '../cerchio/invita_nel_cerchio_screen.dart';

/// I tre casi della riga del Cerchio, dichiarati (ordine FC voce 09).
enum CasoDelPonte {
  /// Amici nel Cerchio, e il numero dei presenti noto da una tendina fresca.
  conIPresenti,

  /// Amici nel Cerchio, e il numero dei presenti non noto: si dice solo
  /// quanti sono, e non si inventa uno "zero presenti" che sarebbe falso.
  senzaIPresenti,

  /// Nessun amico nel Cerchio: il Cerchio aspetta, e la riga porta
  /// all'invito, perche' e' la persona a cui serve di piu'.
  ilCerchioTiAspetta,
}

/// **IL CERCHIO SI VEDE DALLA RUBRICA DEGLI AMICI. Ordine FC voce 09, 4
/// ottobre 2026.**
///
/// Il fondatore: *"in amico vorrei che comparissero anche gli amici
/// online"*. **La ragione della voce**: la persona ha DUE elenchi che per lei
/// si chiamano tutti e due amici. "I tuoi amici" sono le schede che scrive
/// lei, vivono sul telefono e servono agli oroscopi e alle compatibilita';
/// "Il tuo Cerchio" sono le persone con un account, e vivono sul server.
/// Nessuno usera' mai due parole diverse per queste due cose.
///
/// **LA FUSIONE DELLE DUE RUBRICHE NON SI APRE QUI**: i limiti sono diversi,
/// i dati stanno in due posti per ragioni di consenso che non si toccano, e
/// c'e' una decisione di prodotto che spetta al fondatore e che non e' stata
/// presa, cioe' cosa succede a una scheda quando quella persona entra
/// davvero nel Cerchio. Questa riga e' un ponte, non unisce le stanze; e il
/// ponte e' uno solo, dalla rubrica al Cerchio: dal Cerchio alla rubrica non
/// ce n'e' uno (misurato il 4 ottobre 2026), e non si costruisce qui.
///
/// **NESSUNA LETTURA IN PIU'.** Il numero degli amici nel Cerchio viene dai
/// legami che il telefono ha gia' ([IlCerchioSociale.cerchio]); quello dei
/// presenti SOLO dall'ultima tendina, se e' di questa sessione e non piu'
/// vecchia di un minuto ([freschezzaDellaTendina]). La riga non chiama la
/// tendina e non apre nessuna porta: se il dato non c'e', vale il caso
/// [CasoDelPonte.senzaIPresenti], un ripiego dichiarato.
///
/// **LA RIGA NON ELENCA NESSUNO**: niente nomi, niente icone di persone.
/// L'elenco delle persone del Cerchio vive nel Cerchio, e la riga ci porta.
///
/// Senza il Cerchio sociale fra i provider (una prova che monta la rubrica da
/// sola) la riga non c'e': non c'e' un Cerchio a cui portare.
class IlPonteVersoIlCerchio extends StatelessWidget {
  const IlPonteVersoIlCerchio({super.key, this.adesso});

  /// L'istante di adesso, per le prove; nell'app l'orologio.
  final DateTime? adesso;

  /// Quanto puo' essere vecchia la tendina perche' il suo numero valga.
  static const Duration freschezzaDellaTendina = Duration(minutes: 1);

  /// Il caso e i due numeri: amici nel Cerchio, e presenti (nullo se la
  /// tendina non c'e' o non e' fresca).
  static (CasoDelPonte, int, int?) leggi(IlCerchioSociale s, DateTime adesso) {
    final amici = s.cerchio.amici.length;
    if (amici == 0) return (CasoDelPonte.ilCerchioTiAspetta, 0, null);
    final t = s.tendina;
    final arrivata = s.tendinaArrivata;
    final fresca = t != null &&
        arrivata != null &&
        !adesso.isBefore(arrivata) &&
        adesso.difference(arrivata) <= freschezzaDellaTendina;
    if (!fresca) return (CasoDelPonte.senzaIPresenti, amici, null);
    return (CasoDelPonte.conIPresenti, amici, t.amiciPresenti.length);
  }

  /// **I TESTI SONO SEGNAPOSTO DICHIARATI**: li scrive l'Architetto (ordine
  /// FC voce 09, punto 2), come per i segni. Al neutro: "persone", non
  /// "amici", perche' il genere di chi e' nel Cerchio non si sa.
  static String testo(CasoDelPonte caso, int amici, int? presenti) {
    final quante = amici == 1 ? 'c\'è 1 persona' : 'ci sono $amici persone';
    return switch (caso) {
      // SEGNAPOSTO, ordine FC voce 09.
      CasoDelPonte.conIPresenti => 'Nel tuo Cerchio $quante: '
          '${presenti == 1 ? '1 è qui' : '$presenti sono qui'} adesso.',
      // SEGNAPOSTO, ordine FC voce 09.
      CasoDelPonte.senzaIPresenti => 'Nel tuo Cerchio $quante.',
      // SEGNAPOSTO, ordine FC voce 09.
      CasoDelPonte.ilCerchioTiAspetta =>
        'Il tuo Cerchio ti aspetta: chiama chi ti sta a cuore.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final IlCerchioSociale sociale;
    try {
      sociale = Provider.of<IlCerchioSociale>(context);
    } on ProviderNotFoundException catch (senzaCerchio) {
      debugPrint('La riga del Cerchio: nessun Cerchio sociale. $senzaCerchio');
      return const SizedBox.shrink();
    }
    final palette = MaestroScope.forse(context) ?? MaestroPalette.neutral;
    final (caso, amici, presenti) = leggi(sociale, adesso ?? DateTime.now());
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.md),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: Key('amici_ponte_${caso.name}'),
          enableFeedback: false,
          borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
          onTap: () => Navigator.of(context).push(
              caso == CasoDelPonte.ilCerchioTiAspetta
                  ? InvitaNelCerchioScreen.route()
                  : IlTuoCerchioScreen.route()),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.md, vertical: SpacingTokens.sm),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
              color: palette.surfaceElevated.withValues(alpha: 0.55),
              border: Border.all(color: palette.gold.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                // La lucina del Cerchio, non un'icona di persona.
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: caso == CasoDelPonte.conIPresenti
                        ? ColorTokens.lucinaOnline
                        : palette.gold.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: Text(testo(caso, amici, presenti),
                      key: const Key('amici_ponte_testo'),
                      style: TypographyTokens.corpo().copyWith(
                          color: ColorTokens.textPrimary, height: 1.35)),
                ),
                Icon(Icons.chevron_right_rounded,
                    size: 22, color: palette.goldSoft),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
