import 'package:flutter/material.dart';

import '../../../core/maestro/maestro.dart';
import '../../../design_system/components/la_conferma_della_spesa.dart';
import '../../../services/live/porta_del_live.dart';
import '../chat/maestro_chat_controller.dart';
import 'schermata_live.dart';

/// L'ENTRATA NEL LIVE, una sola. Ordine FD voce 01.
///
/// **Il difetto.** Il tocco sulla pastiglia d'oro e la voce del menu'
/// spingevano subito `SchermataLive`, che apriva una sessione vera a
/// pagamento, con la voce sintetizzata e il volto: i minuti del mese
/// scendevano al primo tocco, senza che la persona avesse letto quanto
/// costava. Padre: ordine EG, che ha messo il LIVE dietro la pastiglia senza
/// una conferma.
///
/// **Adesso.** Prima si leggono i minuti dal server, poi si mostra la
/// conferma unica della spesa coi minuti della sessione e quelli che
/// restano, e solo il pulsante "Apri la sessione" spinge la schermata, col
/// consenso che la rotta pretende.
Future<void> entraNelVivo(
  BuildContext context, {
  required Maestro maestro,
  MaestroChatController? chat,
}) async {
  final minuti = await PortaDelLive.minuti();
  if (!context.mounted) return;
  if (minuti == null) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      key: Key('live_minuti_muti'),
      content: Text('Il conto dei tuoi minuti non risponde adesso. '
          'Riprova fra poco.'),
    ));
    return;
  }
  final consenso = await LaConfermaDellaSpesa.deiMinuti(
    context,
    minuti: minuti.apribile ? minuti.minutiDellaSessione : 0,
    disponibili: minuti.rimasti,
  );
  if (consenso == null || !context.mounted) return;
  await Navigator.of(context).push(
      SchermataLive.route(maestro: maestro, chat: chat, consenso: consenso));
}
