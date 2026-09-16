import 'package:flutter/material.dart';

import '../../core/l10n/la_lingua_del_cerchio.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// LA RIGA DELLA LINGUA, dentro Impostazioni. Ordine DM voce 06.
///
/// **Perche' esiste, e non e' una comodita'.** Una porta che nessuno puo'
/// aprire non si puo' provare: finche' la lingua non si sceglie da nessuna
/// parte, tutto quello che questa voce ha costruito resta una promessa scritta
/// in un file. Questa riga e' il punto in cui l'impalcatura si tocca.
///
/// **E' scritta con l'idioma di `RigaInterruttore`, non con misure proprie.**
/// La prima stesura aveva un corpo 16 per il titolo e un 15 per l'elenco,
/// scritti a mano: **tre guardie di casa l'hanno presa insieme**, quella delle
/// misure tipografiche scritte a mano (da 75 a 77), quella del testo di
/// lettura sotto i sedici punti (da 0 a 1) e quella dei vuoti verticali (da
/// 148 a 149). Non e' una formalita': un corpo 15 e' testo che qualcuno legge
/// male, e la scala del testo di sistema non lo salva perche' parte gia'
/// sotto. I token esistono per questo.
///
/// **Ogni lingua si presenta con la propria parola.** In un elenco di lingue
/// *"Italiano"* e *"English"* non si traducono: chi non capisce la lingua
/// corrente deve poter ritrovare la sua, e tradurre i nomi delle lingue e' il
/// modo piu' sicuro di nasconderle a chi le cerca.
///
/// **E la riga sotto non promette niente che non ci sia.** L'app e'
/// predisposta, non tradotta: i testi dei Maestri restano in italiano, e chi
/// sceglie l'inglese trova tradotta l'interfaccia di sistema e le voci che
/// passano dalla porta dei testi. Dirlo qui costa una riga e risparmia una
/// delusione.
class LaRigaDellaLingua extends StatelessWidget {
  const LaRigaDellaLingua({super.key, required this.palette});

  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<LinguaDelCerchio>(
      valueListenable: LaLinguaDelCerchio.corrente,
      builder: (context, corrente, _) => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md,
          vertical: SpacingTokens.xs,
        ),
        child: Row(
          children: [
            Icon(Icons.translate_rounded, color: palette.goldSoft, size: 22),
            const SizedBox(width: SpacingTokens.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Lingua', style: TypographyTokens.titoloDiRiga()),
                  const SizedBox(height: SpacingTokens.xxs),
                  Text(
                    'L\'interfaccia e i selettori di sistema. I testi dei '
                    'Maestri restano in italiano.',
                    style: TypographyTokens.corpo()
                        .copyWith(color: ColorTokens.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),
            DropdownButton<LinguaDelCerchio>(
              key: const Key('settings_lingua'),
              value: corrente,
              underline: const SizedBox.shrink(),
              dropdownColor: palette.deepest,
              style: TypographyTokens.corpo().copyWith(color: palette.goldSoft),
              items: [
                for (final l in LinguaDelCerchio.values)
                  DropdownMenuItem<LinguaDelCerchio>(
                    key: Key('settings_lingua_${l.codice}'),
                    value: l,
                    child: Text(l.nomeNellaSuaLingua),
                  ),
              ],
              onChanged: (scelta) {
                if (scelta == null) return;
                // Non si aspetta il disco per ridisegnare: la lingua vale
                // subito e si scrive dopo. Se il disco fallisse, il giro dopo
                // si ripartirebbe in italiano, che e' il male minore fra un
                // ritardo a schermo e una lingua persa.
                LaLinguaDelCerchio.scegli(scelta);
              },
            ),
          ],
        ),
      ),
    );
  }
}
