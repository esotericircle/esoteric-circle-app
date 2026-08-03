import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/eco/eco_del_maestro.dart';
import '../../../core/maestro/maestro.dart';
import '../../../core/maestro/voce_del_maestro.dart';
import '../../../design_system/theme/maestro_palette.dart';
import '../../../design_system/tokens/spacing_tokens.dart';
import '../../../design_system/tokens/typography_tokens.dart';

/// IL SIGILLO DELL'ECO, nella striscia del giorno.
///
/// La parola che un Maestro ti ha lasciato ieri sera, posata nel Cerchio fino a
/// mezzanotte. **Non e' un'icona muta**: la riga sotto dice da dove viene, e al
/// tocco si apre da dove viene per davvero.
class SigilloDellEco extends StatelessWidget {
  const SigilloDellEco({
    super.key,
    required this.eco,
    required this.larghezza,
    required this.onApri,
  });

  final EcoDelMaestro eco;
  final double larghezza;

  /// Riapre la chat di quel Maestro con la parola gia' nel contesto.
  final VoidCallback onApri;

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(ThemeKey.of(eco.maestro));
    return SizedBox(
      width: larghezza,
      child: GestureDetector(
        key: const Key('sigillo_eco'),
        onTap: onApri,
        onLongPress: () => mostraDaDoveNasce(context, eco),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  palette.primary.withValues(alpha: 0.55),
                  palette.deepest.withValues(alpha: 0.9),
                ]),
                border: Border.all(color: palette.gold.withValues(alpha: 0.7)),
              ),
              child: Icon(Icons.auto_awesome_rounded,
                  size: 20, color: palette.goldSoft),
            ),
            const SizedBox(height: 6),
            // LA PAROLA, che e' la cosa: non un'etichetta di funzione.
            Text(
              eco.parola,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TypographyTokens.display(size: 16)
                  .copyWith(color: palette.goldSoft),
            ),
            // LA RIGA CHE DICE DA DOVE VIENE.
            //
            // Una parola che ricompare senza dire da dove viene e' magia
            // inspiegata. Qui, nella striscia, c'e' spazio per il nome di chi
            // l'ha lasciata; la conversazione da cui viene si legge per intero
            // aprendo "Da dove nasce questo dono".
            Text(
              'da ${eco.maestro.displayName}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TypographyTokens.label(size: 11)
                  .copyWith(color: palette.textSecondary, letterSpacing: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}

/// "DA DOVE NASCE QUESTO DONO", nella forma gia' usata dalle altre arti.
///
/// **Nessuna magia inspiegata.** Si dichiara che la parola viene dalla
/// CHIUSURA del Maestro, si mostra la chiusura vera per esteso, e si dice da
/// quale conversazione: le tre cose che rendono una provenienza verificabile
/// invece che dichiarata.
Future<void> mostraDaDoveNasce(BuildContext context, EcoDelMaestro eco) {
  final palette = MaestroPalette.forKey(ThemeKey.of(eco.maestro));
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => Container(
      key: const Key('eco_da_dove_nasce'),
      padding: EdgeInsets.only(
        left: SpacingTokens.lg,
        right: SpacingTokens.lg,
        top: SpacingTokens.lg,
        bottom: SpacingTokens.xl + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.surfaceElevated, palette.deepest],
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(SpacingTokens.radiusXl),
        ),
        border: Border.all(color: palette.gold.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 15, color: palette.goldSoft),
              const SizedBox(width: 6),
              Text('Da dove nasce questo dono',
                  style: TypographyTokens.label(size: 11)
                      .copyWith(color: palette.goldSoft, letterSpacing: 0.4)),
            ],
          ),
          const SizedBox(height: SpacingTokens.md),
          Text(eco.parola, style: TypographyTokens.display(size: 26)),
          const SizedBox(height: SpacingTokens.sm),
          Text(
            'Questa parola non l\'ha scelta l\'app: l\'ha nominata '
            '${eco.maestro.displayName} chiudendo la sua lettura. È la sua '
            'chiusura di sempre, ${_comeChiude(eco)}.',
            style: TypographyTokens.body(size: 14)
                .copyWith(color: palette.textPrimary, height: 1.4),
          ),
          const SizedBox(height: SpacingTokens.md),
          Text('La riga da cui viene',
              style: TypographyTokens.label(size: 11)
                  .copyWith(color: palette.goldSoft, letterSpacing: 0.6)),
          const SizedBox(height: SpacingTokens.xxs),
          Text('«${eco.chiusura}»',
              style: TypographyTokens.body(size: 14).copyWith(
                  color: palette.textPrimary,
                  height: 1.4,
                  fontStyle: FontStyle.italic)),
          const SizedBox(height: SpacingTokens.md),
          Text(eco.daDoveViene,
              style: TypographyTokens.body(size: 13)
                  .copyWith(color: palette.textSecondary)),
          const SizedBox(height: SpacingTokens.lg),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              key: const Key('eco_condividi'),
              onTap: () => condividiLEco(eco),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.ios_share_rounded, size: 18, color: palette.goldSoft),
                  const SizedBox(width: 6),
                  Text('Condividi',
                      style: TypographyTokens.body(size: 14, weight: 600)
                          .copyWith(color: palette.goldSoft)),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Come chiude questo Maestro, dal tipo che esiste gia' nel dato.
String _comeChiude(EcoDelMaestro eco) {
  switch (VoceDelMaestro.di(eco.maestro).tipoDiChiusura) {
    case TipoDiChiusura.direzioneNelTempo:
      return 'una direzione nel tempo';
    case TipoDiChiusura.gestoDelCorpo:
      return 'un gesto del corpo';
    case TipoDiChiusura.simboloDaPortare:
      return 'un segno da portare';
  }
}

/// Condivide la parola col suo sigillo.
///
/// **La parola, non il paragrafo.** Una parola sola col nome di chi l'ha
/// lasciata si posta; una lettura di settanta parole no.
Future<void> condividiLEco(EcoDelMaestro eco) => SharePlus.instance.share(
      ShareParams(
        text: '${eco.parola}. Me l\'ha lasciata ${eco.maestro.displayName} '
            'nel Cerchio. #EsotericCircle',
      ),
    );
