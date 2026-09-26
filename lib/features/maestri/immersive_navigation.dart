import 'package:flutter/widgets.dart';

import '../../core/arts/le_arti_del_giorno.dart';
import '../../core/chat/immersive_intents.dart';
import 'art_navigation.dart';

/// **L'ARTE CHE OGNI PULSANTE DELLA CHAT APRE.** Ordine DS voce 07, 17
/// settembre 2026.
///
/// **Il fatto**: nella chat con Caligo il pulsante delle rune apriva la Runa
/// del Tramonto, il dono del giorno, invece dell'Estrazione. La causa non era
/// quel pulsante: la chat aveva **una tavola delle destinazioni sua**,
/// scritta accanto a quella dello scaffale, e le due si erano separate.
/// Contati tutti i pulsanti dei tre Maestri, **sei su quattordici** aprivano
/// altro da cio' che promettevano: le rune; la Stesa, la Costellazione del
/// Viso e il Sigillo, che la chat dava in arrivo mentre dallo scaffale si
/// aprivano; l'oroscopo, che apriva l'Arcano.
///
/// **Adesso la chat non nomina nessuna schermata.** Ogni pulsante nomina
/// un'arte, e la rotta la decide `artRouteFor`, la stessa funzione dello
/// scaffale, con la stessa nascita: la destinazione della chat e quella della
/// card sono la stessa cosa per costruzione. La guardia
/// `ogni_pulsante_della_chat_apre_cio_che_promette` pretende anche che il
/// pulsante porti il nome dell'arte che apre.
const Map<ImmersiveTarget, String?> artDellIntento = {
  ImmersiveTarget.tarocchiStesa: 'tarot_spread_three',
  ImmersiveTarget.cartaNatale: 'natal_chart',
  ImmersiveTarget.sinastriaVip: 'synastry_vip',
  ImmersiveTarget.oroscopoGiorno: 'horoscope',
  ImmersiveTarget.arcanoDellAlba: 'day_oracle',
  ImmersiveTarget.meditazione: 'meditation',
  ImmersiveTarget.breathwork: 'meditation',
  ImmersiveTarget.frequenze: 'meditation',
  ImmersiveTarget.costellazioneViso: 'face_constellation',
  ImmersiveTarget.scanChakra: 'chakra_scan',
  ImmersiveTarget.lancioRune: 'rune_draw',
  ImmersiveTarget.sigilloMagico: 'magic_sigil',
  ImmersiveTarget.iChing: 'i_ching',
  ImmersiveTarget.pendolo: 'pendulum',
  // Il rito della candela non e' un'arte del catalogo: il pulsante dice che
  // arriva presto, ed e' vero.
  ImmersiveTarget.ritualeCandela: null,
};

/// La rotta di un pulsante della chat: quella dello scaffale per la sua arte,
/// oppure null se l'arte e' ancora dietro il velo.
Route<void>? immersiveRouteFor(
  ImmersiveTarget target, {
  DateTime? userBirth,
  String? userName,
}) {
  final id = artDellIntento[target];
  if (id == null) return null;
  final rotta = artRouteFor(id, userBirth: userBirth, userName: userName);
  // L'arte si apre anche dalla chat: il puntino d'oro delle arti del giorno
  // si spegne anche da qui (ordine EP voce 06).
  if (rotta != null) LeArtiDelGiorno.istanza.aperta(id);
  return rotta;
}
