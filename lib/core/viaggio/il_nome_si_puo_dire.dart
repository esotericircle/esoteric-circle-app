import 'diario_dei_viaggi.dart';

/// **SE IL NOME DELL'ANIMALE SI PUO' DIRE, e lo decide un posto solo.**
/// Ordine DG voce 02, 12 settembre 2026.
///
/// **Parole del fondatore, 11 settembre 2026:** *"nel Passport mi fa gia'
/// vedere il lupo. il mio animale"*, e prima ancora *"all'onboarding mi dice
/// che l'animale non puo' essere svelato, ma mi fa vedere la figura
/// chiaramente"*.
///
/// **Il difetto non era una schermata, era una regola senza casa.** Il
/// Passaporto sapeva che il nome si dice dopo quattro discese, e lo sapeva da
/// solo: chiamava `IQuattroViaggi.nomeDopoLeQuattroDiscese` con il conto del
/// diario, dentro il suo `build`. Il Viaggio sapeva la stessa cosa, per conto
/// suo. E le altre quattro schermate che mostrano l'animale **non lo sapevano
/// affatto**, perche' nessuno gliel'aveva detto: la carta natale scriveva
/// *Lupo* a lettere intere accanto alla sua miniatura.
///
/// **Adesso la regola ha una casa**, e chi mostra l'animale passa di qui.
///
/// **DUE MODI DI CHIEDERLO, e la differenza conta.**
///
/// [chiedendoloAllArchivio] legge il diario e risponde la verita'. E' quello
/// che usa chi puo' aspettare, cioe' quasi tutti: una scheda che si costruisce
/// una volta e resta a schermo.
///
/// [dalCioCheSiSaGia] risponde **senza aspettare**, con l'ultimo nome letto
/// dal diario in questa sessione. Serve a chi disegna dentro un `build`
/// sincrono e non puo' fermarsi, come il simbolo dell'attesa di una chat.
/// **Quando non si sa ancora niente risponde di no**, ed e' la sola risposta
/// prudente: sbagliare per eccesso di segreto costa un totem non mostrato,
/// sbagliare per difetto costa il finale della storia.
///
/// **DALL'ORDINE FZ VOCE 01, 17 ottobre 2026, QUESTA CLASSE RISPONDE A UNA
/// DOMANDA PRECISA, NON A UN CONTO.** Prima di FZ ogni persona poteva avere
/// un solo animale possibile (quello del segno), quindi sapere "quante
/// discese" equivaleva a sapere "e' rivelato il SUO animale": contare
/// bastava. Con le tre ombre di FZ.01 questo non e' piu' vero: le apparizioni
/// contano l'ombra che oggi guida, che prima del riconoscimento puo' ancora
/// cambiare. Le due funzioni qui sotto non guardano piu' un numero: guardano
/// se [animale] e' esattamente il nome che il Diario ha fissato per sempre
/// (`DiarioDeiViaggi.animaleRiconosciuto`), letto dalla porta unica
/// `AnimaleDiPotere`.
class IlNomeSiPuoDire {
  const IlNomeSiPuoDire._();

  /// **L'ULTIMO CONTO DI DISCESE LETTO DAL DIARIO**, in questa sessione.
  ///
  /// Lo aggiorna `DiarioDeiViaggi.carica`, che e' l'unico posto in cui quel
  /// numero nasce. Vale zero finche' nessuno ha letto l'archivio. Resta un
  /// progresso (0..4, per le barre e le dissolvenze), non un'identita': per
  /// quella vedi [animaleRiconosciutoNoto].
  static int quanteDisceseNote = 0;

  /// **L'ULTIMO NOME RICONOSCIUTO LETTO DAL DIARIO**, in questa sessione, o
  /// nullo. Ordine FZ voce 01. Lo aggiorna `DiarioDeiViaggi`, insieme a
  /// [quanteDisceseNote], a ogni `carica`, `segna` e migrazione completata.
  static String? animaleRiconosciutoNoto;

  /// Risposta **sincera**: legge l'archivio e poi risponde se [animale] e'
  /// esattamente l'animale riconosciuto.
  ///
  /// **NON COMPLETA LA MIGRAZIONE DI FZ.02**, perche' non conosce il segno di
  /// nascita: chi ha bisogno anche della migrazione chiama
  /// `AnimaleDiPotere.caricaERisolvi`, che fa tutte e due le cose. Qui, un
  /// diario a meta' non ancora migrato risponde prudentemente di no.
  static Future<bool> chiedendoloAllArchivio(String animale) async {
    final diario = DiarioDeiViaggi();
    await diario.carica();
    return diario.animaleRiconosciuto == animale;
  }

  /// Risposta **immediata**, con cio' che si sa gia'. Vedi la nota della
  /// classe: quando non si sa niente risponde di no.
  static bool dalCioCheSiSaGia(String animale) =>
      animaleRiconosciutoNoto == animale;

  /// **CHE COSA SI SCRIVE AL POSTO DEL NOME.** Una casella vuota per davvero,
  /// e non un nome mascherato.
  ///
  /// **LA SCRITTA ESATTA DELL'ORDINE FZ VOCE 02**: *"compare la sua sagoma in
  /// ombra con la scritta 'Non ancora rivelato'"*. Qui c'era "Ancora senza
  /// nome": diceva la stessa cosa con parole diverse, e due frasi per lo
  /// stesso fatto in due schermate sono due verita' sullo stesso silenzio.
  /// `AnimaleDiPotere.nonAncoraRivelato` punta qui, e non duplica la stringa.
  static const String alPostoDelNome = 'Non ancora rivelato';

  /// **PERCHE' NON SI DICE**, in una riga sola da mettere sotto l'ombra.
  static const String percheNonSiDice =
      'Si rivela scendendo nel Mondo di Sotto.';
}
