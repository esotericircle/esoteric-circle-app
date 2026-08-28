import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/entitlement/question_allowance.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/typography/paragrafi_di_lettura.dart';
import '../../services/app_services.dart';

/// CHI TI HA INVITATO. Ordine BX voce 02.
///
/// **Perche' esiste.** Il premio dell'invito si pagava alla condivisione:
/// bastava mandare il link a se stessi per incassare sessanta Eos, mentre la
/// riga sotto il pulsante prometteva sessanta Eos quando l'amico entra nel
/// Cerchio. Adesso il premio lo paga l'ingresso vero, e l'ingresso ha bisogno
/// di una porta: questa.
///
/// **Perche' si incolla un codice e non si apre un link.** Firebase Dynamic
/// Links, il servizio che avrebbe portato il codice dentro l'installazione, e'
/// stato spento da Google nell'agosto 2025: non e' una strada percorribile. La
/// strada che resta e' la piu' semplice che funziona davvero, e la persona la
/// capisce senza spiegazioni: il link porta il codice, chi arriva lo incolla.
Future<void> apriIlRiscattoDellInvito(BuildContext context) async {
  final palette = MaestroScope.of(context);
  final scritto = TextEditingController();
  final esito = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: palette.surfaceElevated,
    shape: const RoundedRectangleBorder(
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(SpacingTokens.radiusLg)),
    ),
    // **IL FONDO SE LO DIPINGE IL FOGLIO, e non e' una ridondanza.** Ordine
    // BX: nell'anteprima il colore del foglio copriva il titolo e il
    // paragrafo e finiva li', mentre il campo e il pulsante restavano
    // trasparenti sopra la home, che si leggeva attraverso. Un foglio che
    // lascia vedere la schermata di sotto e' lo stesso difetto che la voce
    // BX.07 ha curato sulla festa. Il colore resta anche in
    // `backgroundColor`, perche' quello veste gli angoli arrotondati del
    // foglio; questo veste il contenuto.
    builder: (foglio) => Container(
      decoration: BoxDecoration(
        color: palette.surfaceElevated,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(SpacingTokens.radiusLg)),
      ),
      padding: EdgeInsets.only(
          left: SpacingTokens.lg,
          right: SpacingTokens.lg,
          top: SpacingTokens.lg,
          bottom: MediaQuery.viewInsetsOf(foglio).bottom + SpacingTokens.lg),
      child: Column(
        key: const Key('riscatta_invito'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Chi ti ha invitato',
              style: TypographyTokens.titoloScheda()
                  .copyWith(color: palette.goldSoft)),
          const SizedBox(height: SpacingTokens.xs),
          ParagrafiDiLettura(
            testo: 'Incolla qui il codice che hai ricevuto: chi ti ha portato '
                'nel Cerchio riceverà il suo premio. Si fa una volta sola.',
            stile: TypographyTokens.didascalia()
                .copyWith(color: ColorTokens.textSecondary),
          ),
          const SizedBox(height: SpacingTokens.md),
          TextField(
            key: const Key('riscatta_invito_codice'),
            controller: scritto,
            style: TypographyTokens.didascalia()
                .copyWith(color: ColorTokens.textPrimary),
            decoration: InputDecoration(
              hintText: 'Il codice, o il link intero',
              hintStyle: TypographyTokens.didascalia()
                  .copyWith(color: ColorTokens.textSecondary),
              filled: true,
              fillColor: palette.deepest.withValues(alpha: 0.45),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
                borderSide:
                    BorderSide(color: palette.gold.withValues(alpha: 0.35)),
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: const Key('riscatta_invito_conferma'),
              onPressed: () =>
                  Navigator.of(foglio).pop(scritto.text.trim()),
              style: FilledButton.styleFrom(
                  backgroundColor: palette.gold,
                  foregroundColor: palette.onPrimary,
                  minimumSize: const Size.fromHeight(48)),
              child: Text('Riconosci chi ti ha invitato',
                  style: TypographyTokens.etichetta()),
            ),
          ),
        ],
      ),
    ),
  );
  final codice = codiceDaCioCheEStatoIncollato(esito ?? '');
  scritto.dispose();
  if (codice.isEmpty || !context.mounted) return;
  final porta = context.read<AppServices>().porta;
  final accolto = await porta.riscattaLInvito(codice);
  if (!context.mounted) return;
  // Il conto degli inviti vive sul server: si richiede lo stato, che lo porta.
  if (accolto) await context.read<QuestionAllowance>().sincronizza();
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(accolto
        ? 'Fatto: chi ti ha invitato riceverà il suo premio.'
        : 'Questo codice non vale: forse è il tuo, o lo hai già usato.'),
  ));
}

/// **DAL LINK AL CODICE, e si accetta tutto e due.** Chi riceve un invito
/// copia quasi sempre il link intero: pretendere il solo codice sarebbe una
/// trappola scritta bene. Qui si prende cio' che segue `invito=`, e se non
/// c'e' nessun link si prende cio' che e' stato scritto.
String codiceDaCioCheEStatoIncollato(String grezzo) {
  final pulito = grezzo.trim();
  if (pulito.isEmpty) return '';
  const marcatore = 'invito=';
  final dove = pulito.indexOf(marcatore);
  if (dove < 0) return pulito;
  final coda = pulito.substring(dove + marcatore.length);
  final fine = coda.indexOf(RegExp(r'[&\s]'));
  return fine < 0 ? coda : coda.substring(0, fine);
}
