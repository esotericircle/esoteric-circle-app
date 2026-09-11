import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import '../rituals/animal_catalog.dart';
import '../sensi/motore_audio.dart';

/// **IL VERSO, UNA VOLTA SOLA NELLA VITA.** Ordine DE voce 07,
/// 11 settembre 2026.
///
/// *"Per tre discese l'animale e' muto. Alla quarta, nell'istante esatto in cui
/// la testa esce dal velo, si sente il suo verso. Il verso si sente una volta
/// sola nella vita dell'utente, alla rivelazione. Non si ripete a ogni
/// apertura."*
///
/// **UNA VOLTA SOLA E' LA PARTE DIFFICILE, e non e' un vezzo.** Un suono che
/// si ripete diventa l'effetto sonoro di una schermata: la decima volta che si
/// apre il Passaporto, l'ululato e' il rumore che fa quel pulsante. **La prima
/// e unica volta, invece, e' un momento**, e nessun altro momento dell'app puo'
/// piu' somigliargli. Per questo il ricordo di averlo udito e' persistente e
/// non vive nella sessione.
///
/// **LO SLOT VUOTO BATTE IL SUONO GENERICO**, e l'ordine e' esplicito: *"se i
/// file non ci sono, il momento resta muto e non si sostituisce con un suono
/// generico: uno slot vuoto e' meglio di un ululato che non e' il suo"*. Un
/// verso sbagliato in quel momento e' peggio del silenzio, perche' il silenzio
/// non dice niente di falso.
///
/// **STATO AL 11 SETTEMBRE 2026: i dodici file NON CI SONO.** La cartella
/// `assets/audio/animali/` non esiste sul ramo, quindi oggi la rivelazione e'
/// muta, e [percorsi] dice a chi li produrra' come vanno chiamati. Il giorno
/// in cui arrivano, questa classe li suona senza che nessuno tocchi una riga.
abstract final class IlVersoDellAnimale {
  /// La cartella dove i dodici file vanno consegnati.
  static const String cartella = 'audio/animali';

  /// **IL PERCORSO DEL VERSO di [animale]**, com'e' scritto negli asset.
  ///
  /// Senza il prefisso `assets/`, che e' la convenzione di `AssetSource` e
  /// quindi del motore audio di casa.
  static String percorsoPer(GuideAnimal animale) =>
      '$cartella/verso_${animale.stem}.mp3';

  /// **IL PERCORSO COMPLETO**, per chi deve chiedere al pacchetto se il file
  /// c'e': `rootBundle` vuole il percorso intero, il lettore audio no.
  static String percorsoNelPacchetto(GuideAnimal animale) =>
      'assets/${percorsoPer(animale)}';

  /// **I DODICI FILE ATTESI**, con il nome esatto con cui vanno consegnati.
  ///
  /// Chi li produce legge questo elenco e non il codice. **Circa due secondi
  /// l'uno**, come dice la voce: un verso e' un verso, non una traccia.
  static List<String> get percorsi =>
      [for (final a in AnimalCatalog.animals) percorsoPer(a)];

  /// La chiave dove vive il ricordo di averlo udito.
  static const String _chiave = 'viaggio.verso.udito';

  /// **SE QUESTO ANIMALE HA GIA' FATTO SENTIRE LA SUA VOCE.**
  ///
  /// Per nome e non con un solo interruttore: il giorno in cui la voce DE.13
  /// portera' un secondo animale, quello avra' la sua prima volta, e un
  /// interruttore unico gliel'avrebbe tolta.
  static Future<bool> giaUdito(String nome) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return (prefs.getStringList(_chiave) ?? const []).contains(nome);
    } catch (errore) {
      // **UN ARCHIVIO MUTO NON RIPETE UN MOMENTO UNICO.** Nel dubbio si tace:
      // sentirlo una volta di meno e' un peccato, sentirlo dieci volte e'
      // averlo distrutto.
      return true;
    }
  }

  static Future<void> _segnaUdito(String nome) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final gia = prefs.getStringList(_chiave) ?? const <String>[];
      if (gia.contains(nome)) return;
      await prefs.setStringList(_chiave, [...gia, nome]);
    } catch (errore) {
      // Il verso e' gia' suonato: si perde solo il ricordo di averlo fatto.
    }
  }

  /// **SE IL FILE ESISTE DAVVERO NEL PACCHETTO.**
  ///
  /// **Si chiede, non si suppone.** Dare per scontato che ci sia e lasciar
  /// fallire il lettore vorrebbe dire segnare come udito un verso che non ha
  /// suonato, e **bruciare la prima volta senza averla data**.
  static Future<bool> ilFileCE(GuideAnimal animale) async {
    try {
      final dati = await rootBundle.load(percorsoNelPacchetto(animale));
      return dati.lengthInBytes > 0;
    } catch (errore) {
      return false;
    }
  }

  /// **FA SENTIRE IL VERSO, se e' il momento e se c'e'.**
  ///
  /// Torna **vero soltanto se ha suonato davvero**, e chi chiama puo' usarlo
  /// per sapere se quel momento c'e' stato: a un momento che non e' avvenuto
  /// non si accompagna niente.
  ///
  /// **Tre porte in fila, e ognuna chiude per una ragione diversa**: non e' la
  /// rivelazione, l'ha gia' udito, il file non c'e'.
  static Future<bool> faiSentire(
    GuideAnimal animale, {
    required bool eLaRivelazione,
    MotoreAudio? motore,
  }) async {
    if (!eLaRivelazione) return false;
    if (await giaUdito(animale.name)) return false;
    if (!await ilFileCE(animale)) {
      debugPrint('Ordine DE voce 07: il verso di ${animale.name} non e nel '
          'pacchetto, il momento resta muto. Atteso in '
          '${percorsoNelPacchetto(animale)}');
      return false;
    }
    // **IL VOLUME DELL'APP E IL SILENZIO DI SISTEMA li rispetta il motore**,
    // come per ogni altro effetto: non c'e' nessuna strada privata per questo
    // suono, ed e' il motivo per cui passa di qui invece che da un lettore
    // suo.
    await (motore ?? MotoreAudio.condiviso).effetto(percorsoPer(animale));
    await _segnaUdito(animale.name);
    return true;
  }
}
