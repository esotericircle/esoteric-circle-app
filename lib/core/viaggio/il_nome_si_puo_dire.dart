import 'diario_dei_viaggi.dart';
import 'i_quattro_viaggi.dart';

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
/// [dalCioCheSiSaGia] risponde **senza aspettare**, con l'ultimo conto letto
/// dal diario in questa sessione. Serve a chi disegna dentro un `build`
/// sincrono e non puo' fermarsi, come il simbolo dell'attesa di una chat.
/// **Quando non si sa ancora niente risponde di no**, ed e' la sola risposta
/// prudente: sbagliare per eccesso di segreto costa un totem non mostrato,
/// sbagliare per difetto costa il finale della storia.
class IlNomeSiPuoDire {
  const IlNomeSiPuoDire._();

  /// **L'ULTIMO CONTO DI DISCESE LETTO DAL DIARIO**, in questa sessione.
  ///
  /// Lo aggiorna `DiarioDeiViaggi.carica`, che e' l'unico posto in cui quel
  /// numero nasce. Vale zero finche' nessuno ha letto l'archivio.
  static int quanteDisceseNote = 0;

  /// Risposta **sincera**: legge l'archivio e poi risponde.
  static Future<bool> chiedendoloAllArchivio(String animale) async {
    final diario = DiarioDeiViaggi();
    await diario.carica();
    return IQuattroViaggi.nomeDopoLeQuattroDiscese(
          diario.quanteDiscese,
          animale,
        ) !=
        null;
  }

  /// Risposta **immediata**, con cio' che si sa gia'. Vedi la nota della
  /// classe: quando non si sa niente risponde di no.
  static bool dalCioCheSiSaGia(String animale) =>
      IQuattroViaggi.nomeDopoLeQuattroDiscese(quanteDisceseNote, animale) !=
      null;

  /// **CHE COSA SI SCRIVE AL POSTO DEL NOME.** Una casella vuota per davvero,
  /// e non un nome mascherato.
  static const String alPostoDelNome = 'Ancora senza nome';

  /// **PERCHE' NON SI DICE**, in una riga sola da mettere sotto l'ombra.
  static const String percheNonSiDice =
      'Si rivela scendendo nel Mondo di Sotto.';
}
