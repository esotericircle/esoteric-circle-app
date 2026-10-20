import 'il_presagio_dal_corpus.dart';
import 'rune_cast.dart';

/// **IL TITOLO DEL PRESAGIO DI UNA GETTATA.** Ordine FK, aggiunta voce A1, 11
/// ottobre 2026.
///
/// Il fondatore: *"ogni risposta doveva partire da un titolo"*. Il presagio
/// delle rune apriva con l'etichetta "Il presagio di Calìgo", che dice di chi
/// e' la voce e non che cosa dice. Il titolo e' la riga di una runa della
/// gettata, nel suo verso (`RunaGettata.riga`): e' la riga con cui la Runa del
/// Tramonto apre il suo responso dall'ordine EH, e non c'e' una parola nuova
/// da scrivere.
///
/// **LA RUNA DEL TITOLO E' LA PIETRA CHE DECIDE. Ordine GA voci GA.03 e
/// GA.07, 20 ottobre 2026.** Qui c'era la runa a meta' dell'elenco delle
/// scoperte (`scoperte[length ~/ 2]`): nelle Norne Verdhandi, nella Croce
/// l'Ostacolo, sul telo una pietra "Ai margini". La risposta e il gesto
/// poggiano invece sulla pietra che decide dell'ordine EX voce 03 (Skuld,
/// l'Esito, quella al centro del telo), e la voce GA.03 vuole il riquadro
/// "Cosa fare adesso" *"scritto per quel titolo"*: un titolo da una pietra e
/// un riquadro da un'altra dicevano due cose diverse nella stessa bolla.
/// **Il difetto ha due padri**: questa classe (ordine FK, aggiunta voce A1)
/// e la scelta della pietra che decide (ordine EX voce 03), fatte in due
/// ordini senza guardarsi. Adesso la pietra e' una sola e la dice
/// `IlPresagioDalCorpus.pietraCheDecide`.
class IlTitoloDellaGettata {
  const IlTitoloDellaGettata._();

  static String di(EsitoGettata esito) {
    if (esito.rune.isEmpty) return '';
    return IlPresagioDalCorpus.pietraCheDecide(esito).riga.trim();
  }
}
