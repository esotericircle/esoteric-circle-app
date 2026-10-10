import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/cerchio/il_cerchio_sociale.dart';
import '../../design_system/transizioni/velo_del_cerchio.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'widgets/disegni_del_cerchio.dart';

/// **LA RICHIESTA DI LEGAME, ordine EY voce 04.** Chi apre un link d'invito
/// con l'app installata, o inquadra il codice di chi gli sta accanto, entra
/// qui: vede chi lo chiama e decide. Chi ha dato il codice ha gia' detto si'
/// dandolo; chi lo usa dice si' adesso, e nasce l'amicizia. **Nessun legame
/// nasce senza questo tocco.**
/// La riga del link d'invito scaduto, alla lettera. Ordine FD voce 06.8.
const String rigaDelLinkScaduto =
    'Questo invito è scaduto. Chiedi alla persona che te lo ha mandato di rifarlo.';

/// La riga del codice da inquadrare scaduto, alla lettera. FD.06.8.
const String rigaDelCodiceScaduto =
    'Questo codice non vale più. Fatelo mostrare di nuovo.';

Future<void> mostraLaRichiestaDiLegame(
    BuildContext context, String codice) async {
  final sociale = context.read<IlCerchioSociale>();
  final messaggero = ScaffoldMessenger.maybeOf(context);
  final letto = await sociale.leggiIlCodice(codice);
  if (!context.mounted) return;
  if (!letto.valido || letto.chi == null) {
    // Ordine FD voce 06.8: il link d'invito (otto caratteri) e il codice da
    // inquadrare (sei) dicono ciascuno la sua scadenza, alla lettera.
    messaggero?.showSnackBar(SnackBar(
        content: Text(
            codice.length == 6 ? rigaDelCodiceScaduto : rigaDelLinkScaduto)));
    return;
  }
  final chi = letto.chi!;
  if (letto.semaforo == Semaforo.verde) {
    messaggero?.showSnackBar(
        SnackBar(content: Text('${chi.nome} è già nel tuo Cerchio.')));
    return;
  }
  final accetta = await foglioDelCerchio<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (c) => fondoDelFoglio(c, _LaRichiesta(chi: chi),
        palette: paletteDi(chi.maestro)),
  );
  if (accetta != true) return;
  final esito = await sociale.chiediIlLegame(codice: codice);
  messaggero?.showSnackBar(SnackBar(
      content: Text(esito.ok
          ? '${chi.nome} è nel tuo Cerchio.'
          : (esito.riga ?? EsitoDelGesto.silenzio.riga!))));
}

class _LaRichiesta extends StatelessWidget {
  const _LaRichiesta({required this.chi});
  final PersonaDelCerchio chi;

  @override
  Widget build(BuildContext context) {
    final palette = paletteDi(chi.maestro);
    return SafeArea(
      child: Padding(
        key: const Key('richiesta_di_legame'),
        padding: const EdgeInsets.all(SpacingTokens.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconaTonda(icona: chi.icona, lato: 96),
            const SizedBox(height: SpacingTokens.sm),
            Text('${chi.nome} ti chiama nel suo Cerchio',
                textAlign: TextAlign.center,
                style: TypographyTokens.titoloScheda()
                    .copyWith(color: palette.goldSoft)),
            if (chi.segno != null)
              Text(chi.segno!.italianName,
                  style: TypographyTokens.didascalia()
                      .copyWith(color: ColorTokens.textSecondary)),
            const SizedBox(height: SpacingTokens.md),
            FilledButton(
              key: const Key('richiesta_accetta'),
              style: FilledButton.styleFrom(
                  backgroundColor: palette.gold,
                  foregroundColor: palette.onPrimary,
                  minimumSize: const Size.fromHeight(48)),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Entra nel suo Cerchio'),
            ),
            TextButton(
              key: const Key('richiesta_non_ora'),
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Non ora',
                  style: TypographyTokens.etichetta()
                      .copyWith(color: ColorTokens.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }
}
