import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/archetypes/archetype_history.dart';
import '../../../../core/maestro/maestro.dart';
import '../../../../core/archetypes/archetype.dart';
import '../../../../core/rituals/animal_catalog.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/theme/maestro_scope.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import '../animal/guide_animal_screen.dart';

/// **IL TUO ANIMALE, DALLA SOGLIA DEL VIAGGIO.** Richiesta del fondatore, 20
/// ottobre 2026: *"Una volta che l'animale e' stato rivelato, devi aggiungere
/// un pulsante nella schermata di apertura della funzionalita', che apre un
/// popup che descrive le caratteristiche dell'animale rivelato. Attualmente
/// queste informazioni caratteristiche si trovano anche nella voce 'Animale
/// Guida' nel menu' Passport. Trova tu la posizione migliore"*.
///
/// **DOVE STA, E PERCHE'.** Nella soglia dopo la rivelazione, subito sotto il
/// nome dell'animale (`_ilRiconosciuto` di `ViaggioDelloSciamanoScreen`): e'
/// li' che la persona guarda il suo animale, e "Scopri chi e' il Lupo" si
/// legge come il seguito naturale del nome. La prima stesura lo metteva in
/// una fascia in cima alla soglia, e la misura ha detto che spingeva
/// "Scendi" sotto la piega del Realme (690-746 in una finestra di 719): lo
/// spazio del pulsante viene ora dall'immagine, da 340 a 280 punti. Anche
/// toccare l'immagine apre il popup. Prima della rivelazione non c'e': il
/// nome non si dice prima della quarta.
///
/// **IL CONTENUTO E' QUELLO DEL PASSPORT**, lo stesso componente
/// `LeQualitaDellAnimale`: una copia sola.
///
/// **IL POPUP DELLE QUALITA'**: ritratto, nome, la frase dell'animale e le
/// qualita' del Passport, in un foglio che scorre e si chiude trascinandolo
/// giu' o col pulsante.
Future<void> mostraLeQualitaDellAnimale(
  BuildContext context, {
  required GuideAnimal animale,
  required MaestroPalette palette,
}) {
  Archetype? archetipo;
  try {
    archetipo = context.read<ArchetypeHistory>().ultimo?.dominante;
  } catch (errore) {
    // Senza lo storico dell'archetipo il popup si apre lo stesso, senza la
    // bolla dell'intreccio.
    archetipo = null;
  }
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF120E24),
    shape: const RoundedRectangleBorder(
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(SpacingTokens.radiusLg)),
    ),
    // **VESTITO DI CALIGO**: il foglio vive sopra il Navigator, fuori dallo
    // scope della schermata, e le bolle delle qualita' lo pretendono (la
    // stessa lezione del Diario dei viaggi). Senza, ogni bolla cadeva in un
    // riquadro d'errore: trovato dalla prova del popup.
    builder: (context) => MaestroScope(
      maestro: Maestro.caligo,
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (context, scorrimento) => ListView(
          key: const Key('viaggio_qualita_dell_animale'),
          controller: scorrimento,
          padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.sm,
              SpacingTokens.lg, SpacingTokens.xxl),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: palette.goldSoft.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            SizedBox(
              height: 200,
              child: Image.asset(animale.fullPath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink()),
            ),
            const SizedBox(height: SpacingTokens.sm),
            Text(animale.name.toUpperCase(),
                textAlign: TextAlign.center,
                style: TypographyTokens.cerimoniale()
                    .copyWith(color: palette.goldSoft)),
            Text(animale.summary,
                textAlign: TextAlign.center,
                style: TypographyTokens.body(size: 16).copyWith(
                    color: ColorTokens.textSecondary,
                    fontStyle: FontStyle.italic)),
            const SizedBox(height: SpacingTokens.lg),
            LeQualitaDellAnimale(
                animal: animale, archetipo: archetipo, palette: palette),
            const SizedBox(height: SpacingTokens.lg),
            OutlinedButton(
              key: const Key('viaggio_qualita_chiudi'),
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: palette.goldSoft,
                side: BorderSide(color: palette.gold.withValues(alpha: 0.6)),
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text('Chiudi', style: TypographyTokens.etichetta()),
            ),
          ],
        ),
      ),
    ),
  );
}
