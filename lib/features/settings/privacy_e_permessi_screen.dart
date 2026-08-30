import 'package:flutter/material.dart';

import '../../core/arts/art_catalog.dart';
import '../../core/legal/fonti_dei_dati.dart';
import '../../design_system/components/depth_card.dart';
import '../../design_system/components/section_title.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';
import '../../design_system/typography/paragrafi_di_lettura.dart';
import 'interruttore_della_misura.dart';
import 'permessi_di_sistema.dart';

/// PRIVACY E PERMESSI, il sotto menu' dedicato. Ordine CE voce 03.
///
/// **Le parole del fondatore, verbatim:** "B ma tutto quel blocco di permessi
/// deve andare in un sotto menu' dedicato."
///
/// **Perche' questo nome.** Dentro ci stanno due famiglie di cose: cosa il
/// Cerchio sa di te e cosa il Cerchio puo' toccare del tuo telefono. "Privacy
/// e permessi" le nomina tutte e due e non promette altro. Un nome piu'
/// elegante che dicesse meno, come "Il tuo spazio", avrebbe costretto ad
/// aprirlo per sapere cosa c'e' dentro, che e' l'opposto di quello che serve
/// qui.
///
/// **Perche' un sotto menu' e non quattro righe in fila.** Le Impostazioni
/// sono la schermata dove si cerca una cosa sola: quattro blocchi di privacy
/// in cima allungano la strada verso tutto il resto per servire chi apre
/// quella pagina una volta l'anno. Dietro una riga sola restano raggiungibili
/// in due tocchi, ed e' il modo in cui ogni app che il fondatore ha nominato
/// tiene questa materia.
///
/// **L'ordine dentro non e' casuale.** Prima cosa il Cerchio dice di se',
/// cioe' il disclaimer; poi cosa conta di te, cioe' la misura; poi da dove
/// vengono i suoi numeri; e in fondo cosa puo' toccare del telefono. Si va dal
/// piu' generale al piu' concreto.
class PrivacyEPermessiScreen extends StatelessWidget {
  const PrivacyEPermessiScreen({super.key});

  static Route<void> route() => PassaggioDelCerchio.rotta<void>(
      (_) => const PrivacyEPermessiScreen());

  @override
  Widget build(BuildContext context) {
    final palette = MaestroScope.forse(context) ?? MaestroPalette.neutral;
    return Scaffold(
      key: const Key('privacy_e_permessi'),
      backgroundColor: palette.deepest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: palette.goldSoft),
        title: Text('Privacy e permessi',
            style: TypographyTokens.display(size: 20)
                .copyWith(color: palette.goldSoft)),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, 0,
              SpacingTokens.lg, SpacingTokens.xxl),
          children: [
            // **IL DISCLAIMER, E QUESTO RESTA L'UNICO POSTO DOVE COMPARE.**
            //
            // Ne esistevano SETTE a schermo prima dell'ordine BB: una finestra
            // all'apertura della chat, poi Angeli, Oroscopo, intro delle arti,
            // schermata del Maestro, Rune, Stesa a tre carte. Un disclaimer
            // ripetuto smette di essere letto. Con l'ordine CE cambia il posto
            // e non la regola: sta qui, dove chi lo cerca lo trova, e chi non
            // lo cerca non se lo ritrova addosso su ogni carta.
            const SectionTitle(
              title: 'Cosa diciamo di noi',
              subtitle: 'Una volta sola, e non su ogni carta.',
            ),
            const SizedBox(height: SpacingTokens.sm),
            DepthCard(
              raised: true,
              child: Row(
                key: const Key('privacy_disclaimer'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.eco_outlined, size: 18, color: palette.goldSoft),
                  const SizedBox(width: SpacingTokens.md),
                  Expanded(
                    child: ParagrafiDiLettura(
                      testo: ArtCatalog.disclaimerCornice,
                      stile: TypographyTokens.lettura()
                          .copyWith(color: ColorTokens.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SpacingTokens.xl),

            const SectionTitle(
              title: 'Cosa contiamo',
              subtitle: 'Numeri per giorno, mai un profilo.',
            ),
            const SizedBox(height: SpacingTokens.sm),
            DepthCard(
              raised: true,
              padding: EdgeInsets.zero,
              child: InterruttoreDellaMisura(palette: palette),
            ),
            const SizedBox(height: SpacingTokens.xl),

            const SectionTitle(
              title: 'Da dove vengono i numeri',
              subtitle: 'Chi pubblica i dati, e con quale licenza.',
            ),
            const SizedBox(height: SpacingTokens.sm),
            DepthCard(
              raised: true,
              child: Column(
                key: const Key('elenco_delle_fonti'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final f in fontiDeiDati) ...[
                    Text(f.cosa,
                        style: TypographyTokens.etichetta()
                            .copyWith(color: ColorTokens.textPrimary)),
                    const SizedBox(height: SpacingTokens.xxs),
                    Text('${f.chi}. ${f.licenza}. ${f.dove}',
                        style: TypographyTokens.didascalia()
                            .copyWith(color: ColorTokens.textSecondary)),
                    if (f != fontiDeiDati.last)
                      const SizedBox(height: SpacingTokens.md),
                  ],
                ],
              ),
            ),
            const SizedBox(height: SpacingTokens.xl),

            const SectionTitle(
              title: 'Cosa tocca del telefono',
              subtitle: 'Quello che hai negato si concede da qui.',
            ),
            const SizedBox(height: SpacingTokens.sm),
            DepthCard(
              raised: true,
              padding: const EdgeInsets.all(SpacingTokens.md),
              child: PermessiDiSistema(palette: palette),
            ),
          ],
        ),
      ),
    );
  }
}
