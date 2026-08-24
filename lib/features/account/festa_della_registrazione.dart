import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/entitlement/question_allowance.dart';
import '../../core/identity/account_del_cerchio.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/components/icona_degli_eos.dart';
import '../../design_system/components/volo_degli_eos.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// LA FESTA DELLA REGISTRAZIONE. Ordine BH voce 02.
///
/// Parole del fondatore: "subito dopo, ovviamente, vorrei una festa dedicata
/// alla registrazione e al premio". Non e' una celebrazione di Sentiero (non
/// c'e' un Traguardo dietro): e' la sua scena, piu' sobria, che dice la
/// registrazione compiuta e il premio arrivato, col numero VERO che il
/// server ha accreditato.
///
/// [dopoLaCustodia] e' l'unico ingresso: sincronizza la borsa e decide da
/// sola cosa e' vero. Tre casi, tre verita':
/// 1. il benvenuto e' arrivato: la festa, col numero;
/// 2. l'email aspetta la verifica: nessuna festa, la riga che dice che il
///    premio arriva a verifica compiuta (la strada di BH.04);
/// 3. la lapide ha fermato il premio (l'email lo aveva gia' ricevuto):
///    nessuna festa e la riga onesta, perche' festeggiare un premio non
///    arrivato sarebbe la bugia peggiore di tutte.
class FestaDellaRegistrazione extends StatelessWidget {
  const FestaDellaRegistrazione({super.key, this.premio});

  /// Quanti Eos sono arrivati col benvenuto. Nullo se il server non ha
  /// dichiarato il numero: la festa allora parla del dono senza cifra.
  final int? premio;

  /// Da chiamare dopo una custodia riuscita (la registrazione vera).
  static Future<void> dopoLaCustodia(BuildContext context) async {
    QuestionAllowance? borsa;
    try {
      borsa = context.read<QuestionAllowance>();
    } catch (senzaProvider) {
      return;
    }
    await borsa.sincronizza();
    if (!context.mounted) return;
    if (borsa.benvenutoAppenaArrivato) {
      await Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black54,
        transitionDuration:
            MediaQuery.maybeOf(context)?.disableAnimations == true
                ? Duration.zero
                : const Duration(milliseconds: 350),
        // La rotta si avvolge da sola nello scope, come ogni rotta spinta
        // di casa: la festa usa la palette e non deve dipendere da dove
        // sta il Navigator.
        pageBuilder: (_, __, ___) => MaestroScope(
            child:
                FestaDellaRegistrazione(premio: borsa!.premioDellaRegistrazione)),
        transitionsBuilder: (_, anima, __, figlio) =>
            FadeTransition(opacity: anima, child: figlio),
      ));
      return;
    }
    // Niente festa: si dice perche', mai un silenzio che lascia aspettare
    // un premio promesso.
    AccountDelCerchio? account;
    try {
      account = context.read<AccountDelCerchio>();
    } catch (senzaProvider) {
      account = null;
    }
    final aspettaLaVerifica = account != null &&
        account.fornitori.contains('password') &&
        account.emailVerificata == false;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
      key: const Key('registrazione_senza_festa'),
      content: Text(aspettaLaVerifica
          ? 'Registrazione quasi compiuta: apri l\'email che ti abbiamo '
              'mandato e verifica l\'indirizzo. Il dono di benvenuto '
              'arriva con la verifica.'
          : 'La registrazione è compiuta. Il benvenuto non si ripete: '
              'questa email lo aveva già ricevuto.'),
      duration: const Duration(seconds: 8),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      key: const Key('festa_della_registrazione'),
      backgroundColor: Colors.transparent,
      body: CosmosBackground(
        child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(SpacingTokens.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: palette.primary.withValues(alpha: 0.35),
                      border: Border.all(
                          color: palette.gold.withValues(alpha: 0.7),
                          width: 1.4),
                    ),
                    child: Icon(Icons.shield_moon_outlined,
                        color: palette.goldSoft, size: 42),
                  ),
                  const SizedBox(height: SpacingTokens.lg),
                  Text('Sei nel Cerchio',
                      key: const Key('festa_registrazione_titolo'),
                      textAlign: TextAlign.center,
                      style: TypographyTokens.cerimoniale()
                          .copyWith(color: palette.goldSoft)),
                  const SizedBox(height: SpacingTokens.md),
                  Text(
                    'La tua registrazione è compiuta: il tuo cielo, i tuoi '
                    'Sigilli e i tuoi Eos ti seguono su qualsiasi telefono.',
                    textAlign: TextAlign.center,
                    style: TypographyTokens.corpo().copyWith(
                        color: ColorTokens.textPrimary, height: 1.5),
                  ),
                  const SizedBox(height: SpacingTokens.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconaDegliEos(misura: 26, colore: palette.goldSoft),
                      const SizedBox(width: SpacingTokens.sm),
                      Text(
                        premio == null
                            ? 'Il dono di benvenuto è tuo'
                            : '+$premio Eos',
                        key: const Key('festa_registrazione_premio'),
                        // Il titolo cerimoniale grande, non una misura scritta a mano:
                        // e' il numero della festa, merita il ruolo pieno.
                        style: TypographyTokens.cerimonialeGrande()
                            .copyWith(color: palette.goldSoft),
                      ),
                    ],
                  ),
                  const Spacer(flex: 3),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      key: const Key('festa_registrazione_continua'),
                      style: FilledButton.styleFrom(
                        backgroundColor: palette.gold,
                        foregroundColor: palette.deepest,
                        padding: const EdgeInsets.symmetric(
                            vertical: SpacingTokens.md),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(SpacingTokens.radiusPill),
                        ),
                      ),
                      onPressed: () {
                        final quanti = premio ?? 0;
                        Navigator.of(context).pop();
                        if (quanti > 0) {
                          VoloDegliEos.lancia(context, quanti: quanti);
                        }
                      },
                      child: Text('Continua',
                          style: TypographyTokens.etichetta()
                              .copyWith(color: palette.deepest)),
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
