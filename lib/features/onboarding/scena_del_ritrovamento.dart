import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/cammino/ritrovamento.dart';
import '../../core/maestro/maestro.dart';
import '../../core/chat/user_profile.dart';
import '../../core/identity/profile_controller.dart';
import '../../design_system/components/zodiac_glyph.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/components/depth_card.dart';
import '../../design_system/components/icona_degli_eos.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// LA SCENA DEL RITROVAMENTO. Ordine AP voce 05.
///
/// **Perche' esiste.** La voce della custodia promette di non far perdere
/// nulla, e fino a quest'ordine quella frase era falsa per la parte del
/// cammino. Adesso e' vera, e questa scena e' la PROVA A SCHERMO che lo sia:
/// chi rientra col suo account vede, coi numeri veri, che cosa il Cerchio
/// gli ha restituito. Una promessa mantenuta in silenzio somiglia troppo a
/// una promessa non mantenuta.
///
/// **Numeri veri e mai numeri d'esempio**: se il Cerchio non ha ritrovato
/// niente, questa scena non compare affatto. Celebrare il ritrovamento di
/// zero cose sarebbe la bugia peggiore, perche' arriverebbe nel momento in
/// cui una persona sta verificando se puo' fidarsi.
class ScenaDelRitrovamento extends StatelessWidget {
  const ScenaDelRitrovamento({
    super.key,
    required this.ritrovamento,
    required this.onProsegui,
  });

  final Ritrovamento ritrovamento;
  final VoidCallback onProsegui;

  static Route<void> route({
    required Ritrovamento ritrovamento,
    required VoidCallback onProsegui,
  }) =>
      MaterialPageRoute<void>(
        builder: (_) => MaestroScope(
          maestro: Maestro.medora,
          child: ScenaDelRitrovamento(
            ritrovamento: ritrovamento,
            onProsegui: onProsegui,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final palette = MaestroScope.forse(context) ?? MaestroPalette.neutral;
    final nome = ritrovamento.nome;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CosmosBackground(
        seed: 11,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(SpacingTokens.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // **IL LIVELLO VISIVO PRIMA DEL TESTO, ordine AQ voce 04.**
                // La schermata che Mauro ha visto vuota si apriva con una
                // riga di testo: qui arriva prima l'EMBLEMA del proprio
                // segno, preso dagli asset che il Cerchio ha gia'. Non e' un
                // ornamento: e' la prima cosa che dice "questo sei tu", e
                // compare solo se il segno c'e' davvero, perche' l'emblema di
                // qualcun altro sarebbe peggio di nessun emblema.
                if (ritrovamento.segno != null) ...[
                  ZodiacEmblem(
                    key: const Key('ritrovamento_emblema'),
                    sign: ritrovamento.segno!,
                    size: 120,
                    ripiego: Icon(Icons.auto_awesome,
                        size: 72, color: palette.goldSoft),
                  ),
                  const SizedBox(height: SpacingTokens.md),
                ],
                Text(
                  // **IL SALUTO SI DECLINA, ordine BG voce 03.** La forma di
                  // cortesia scelta all'onboarding governa ogni testo che
                  // parla alla persona: qui era cablato il maschile. Con la
                  // forma ignota vale il neutro, come da convenzione della
                  // casa.
                  _saluto(context, nome),
                  key: const Key('ritrovamento_saluto'),
                  textAlign: TextAlign.center,
                  style: TypographyTokens.cerimonialeGrande()
                      .copyWith(color: palette.goldSoft),
                ),
                const SizedBox(height: SpacingTokens.sm),
                Text(
                  // **LA FRASE DEL FONDATORE, ordine BI voce 03**: via il
                  // possesso (ti aveva tenuto tutto), resta il ricordo.
                  'Il Cerchio si ricorda di te.',
                  textAlign: TextAlign.center,
                  style: TypographyTokens.corpo()
                      .copyWith(color: ColorTokens.textPrimary, height: 1.5),
                ),
                const SizedBox(height: SpacingTokens.lg),
                DepthCard(
                  key: const Key('ritrovamento_elenco'),
                  padding: const EdgeInsets.all(SpacingTokens.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (ritrovamento.cartaRitrovata)
                        _Voce(
                          chiave: 'ritrovamento_carta',
                          icona: Icons.auto_awesome,
                          testo: 'La tua carta natale',
                          palette: palette,
                        ),
                      if (ritrovamento.quantiTraguardi > 0)
                        _Voce(
                          chiave: 'ritrovamento_traguardi',
                          icona: Icons.workspace_premium_outlined,
                          testo: ritrovamento.quantiTraguardi == 1
                              ? '1 Sigillo acceso'
                              : '${ritrovamento.quantiTraguardi} Sigilli '
                                  'accesi',
                          palette: palette,
                        ),
                      if (ritrovamento.quantiEos > 0)
                        _Voce(
                          chiave: 'ritrovamento_eos',
                          icona: null,
                          testo: '${ritrovamento.quantiEos} Eos',
                          palette: palette,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: SpacingTokens.xl),
                // **A TUTTA LARGHEZZA come ogni altro invito dell'app.**
                // L'anteprima lo mostrava stretto e appoggiato a sinistra,
                // orfano in mezzo al vuoto: qui non c'e' niente accanto a
                // lui, ed e' l'unica cosa da toccare.
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    key: const Key('ritrovamento_prosegui'),
                    style: FilledButton.styleFrom(
                      backgroundColor: palette.primary,
                      foregroundColor: palette.onPrimary,
                    ),
                    onPressed: onProsegui,
                    // **LO STILE E' DICHIARATO, come in ogni altro pulsante
                    // dell'app.** Senza, il testo prende quello del tema di
                    // Material e non il token di casa: l'anteprima lo ha
                    // mostrato subito, coi rettangoli al posto delle lettere,
                    // che e' il segno di un carattere diverso da quelli
                    // dell'app.
                    child: Text('Entra nel Cerchio',
                        style: TypographyTokens.etichetta()),
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

class _Voce extends StatelessWidget {
  const _Voce({
    required this.chiave,
    required this.icona,
    required this.testo,
    required this.palette,
  });

  final String chiave;
  final IconData? icona;
  final String testo;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: Key(chiave),
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xs),
      child: Row(
        children: [
          if (icona != null)
            Icon(icona, color: palette.goldSoft, size: 20)
          else
            IconaDegliEos(misura: 20, colore: palette.goldSoft),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Text(
              testo,
              style: TypographyTokens.corpo()
                  .copyWith(color: ColorTokens.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}


/// Il saluto del ritrovamento, declinato sulla forma di cortesia.
String _saluto(BuildContext context, String? nome) {
  var forma = CourtesyForm.unknown;
  try {
    forma = context.read<ProfileController>().profile.courtesyForm;
  } catch (errore) {
    forma = CourtesyForm.unknown;
  }
  switch (forma) {
    case CourtesyForm.masculine:
      return nome == null ? 'Bentornato nel Cerchio' : 'Bentornato, $nome';
    case CourtesyForm.feminine:
      return nome == null ? 'Bentornata nel Cerchio' : 'Bentornata, $nome';
    case CourtesyForm.neutral:
    case CourtesyForm.unknown:
      return nome == null ? 'Di nuovo nel Cerchio' : 'Di nuovo nel Cerchio, $nome';
  }
}
