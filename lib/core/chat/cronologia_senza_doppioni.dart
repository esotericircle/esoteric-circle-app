import 'chat_message.dart';

/// **LA CRONOLOGIA SI LEGGE SENZA I DOPPIONI CHE IL DIFETTO HA LASCIATO.**
/// Ordine DV, 18 settembre 2026.
///
/// **Da dove vengono.** Dall'11 agosto 2026 (commit `7797f63c`, ordine N)
/// ogni scrittura della memoria passa dal server attraverso una coda, e la
/// coda si svuotava in due corse insieme: la domanda arrivava al server due
/// volte, e il server la scriveva due volte perche' scrive ogni messaggio con
/// un documento nuovo. La coda adesso si svuota una corsa alla volta, ma i
/// doppioni gia' scritti restano nelle cronologie delle persone.
///
/// **Perche' si possono riconoscere senza sbagliare.** In una cronologia sana
/// una domanda della persona e' sempre seguita da un turno del Maestro: la
/// risposta, il turno in attesa, l'invito di un instradamento o il messaggio
/// del limite. **Due domande uguali una dietro l'altra, senza niente in
/// mezzo, non le puo' produrre nessun gesto**: le produceva solo la coda.
/// Una domanda ripetuta davvero ha la sua risposta in mezzo, e resta.
///
/// **Cosa non fa.** Non cancella niente dai dati: toglie il doppione da cio'
/// che si mostra e da cio' che torna al modello. La pulizia dei dati e' un
/// lavoro del server, e lo strumento sta in `functions/src/pulisci_doppioni.ts`,
/// con la stessa regola in `functions/src/doppioni.ts`.
abstract final class CronologiaSenzaDoppioni {
  /// La [cronologia] senza le domande che ripetono, identiche, la domanda
  /// subito prima.
  static List<ChatMessage> di(List<ChatMessage> cronologia) {
    final pulita = <ChatMessage>[];
    for (final m in cronologia) {
      if (pulita.isNotEmpty && doppione(pulita.last, m)) continue;
      pulita.add(m);
    }
    return pulita;
  }

  /// Quanti doppioni ci sono in [cronologia]: serve a chi misura, e a
  /// chi deve decidere se una cronologia va pulita sul server.
  static int quanti(List<ChatMessage> cronologia) =>
      cronologia.length - di(cronologia).length;

  /// Vero se [dopo] e' il doppione di [prima]: due domande della persona,
  /// una dietro l'altra, con lo stesso testo e nella stessa conversazione.
  static bool doppione(ChatMessage prima, ChatMessage dopo) =>
      prima.isUser &&
      dopo.isUser &&
      prima.text.trim() == dopo.text.trim() &&
      prima.conversazione == dopo.conversazione;
}
