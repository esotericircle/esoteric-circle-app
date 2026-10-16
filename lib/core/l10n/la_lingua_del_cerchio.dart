import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../chat/la_marca_del_genere.dart';
import 'app_strings.dart';

/// LA LINGUA DEL CERCHIO, UN DATO SOLO. Ordine DM voce 01.
///
/// **Il fatto da cui nasce.** Prima di quest'ordine la lingua non era un dato:
/// era **tre cose scollegate**. `AppStrings.languageCode` diceva `'it'` e
/// nessuno lo scriveva mai; `LaMarcaDelGenere.lingua` diceva italiano e
/// **nessun file di `lib` lo scriveva mai**, misurato; e i widget di sistema
/// non sapevano niente di niente, percio' parlavano inglese. Tre verita'
/// separate sulla stessa domanda sono la famiglia di difetti piu' numerosa di
/// questo progetto.
///
/// **Qui la lingua e' una sola, e da qui scende dove serve.** Chi la cambia
/// chiama [scegli] e non tocca nient'altro: la porta scrive il codice nelle
/// stringhe dell'interfaccia, dice alla marca del genere in che lingua si
/// risolve, se lo ricorda sul telefono e avvisa chi disegna.
///
/// **Perche' e' statica, e non un provider.** Per la stessa ragione per cui lo
/// e' `LaMarcaDelGenere.formaCorrente`: i testi stanno dentro i corpora, e un
/// corpus non ha un `BuildContext`. Se ogni lettore dovesse andarsi a prendere
/// la lingua, il primo che se ne dimenticasse scriverebbe nella lingua
/// sbagliata. Chi disegna ascolta [corrente], che e' un `ValueListenable`.
///
/// **E l'italiano resta il default, non la lingua del telefono.** Un'app che
/// al primo avvio dopo l'aggiornamento parlasse inglese a chi ha sempre letto
/// in italiano avrebbe cambiato il comportamento visibile, che quest'ordine
/// vieta. La lingua del telefono si potra' proporre, mai imporre.
enum LinguaDelCerchio {
  /// L'italiano, la lingua di casa.
  italiano('it', 'Italiano', 'italiano', senzaGenere: false),

  /// L'inglese, che oggi esiste per **provare che l'impalcatura regge** e non
  /// perche' l'app sia tradotta: i testi tradotti sono quelli di
  /// `AppStrings`, e il corpus editoriale resta italiano.
  inglese('en', 'English', 'inglese', senzaGenere: true);

  const LinguaDelCerchio(
    this.codice,
    this.nomeNellaSuaLingua,
    this.nomeInItaliano, {
    required this.senzaGenere,
  });

  /// Il codice ISO a due lettere, quello che leggono `AppStrings` e i
  /// delegati di sistema.
  final String codice;

  /// Come la lingua chiama se stessa. **Non si traduce**: in un elenco di
  /// lingue ognuna si presenta con la propria parola, o chi non capisce la
  /// lingua corrente non ritrova la sua.
  final String nomeNellaSuaLingua;

  /// Come si chiama **in italiano**, per i prompt del modello, che sono
  /// scritti in italiano: *"Scrivi sempre e solo in italiano"*, *"Scrivi
  /// sempre e solo in inglese"*.
  final String nomeInItaliano;

  /// **SE LE TRE FORME DEL GENERE COINCIDONO**, come in inglese.
  ///
  /// Sta qui e non in un `if` altrove per una ragione precisa: chi aggiunge
  /// una lingua **deve dichiararlo**. Un ternario scritto fuori di qui
  /// tratterebbe in silenzio ogni lingua nuova come se il genere non ce
  /// l'avesse, e il francese o lo spagnolo arriverebbero a schermo col campo
  /// neutro senza che nessuno se ne accorga. Qui il compilatore lo chiede.
  final bool senzaGenere;

  /// La lingua di quel codice, o l'italiano se il codice non e' di nessuna.
  static LinguaDelCerchio dalCodice(String? codice) {
    for (final l in LinguaDelCerchio.values) {
      if (l.codice == codice) return l;
    }
    return LinguaDelCerchio.italiano;
  }
}

abstract final class LaLinguaDelCerchio {
  /// **LA CHIAVE STA NELLA FAMIGLIA DELLE IMPOSTAZIONI**, `settings.`, che
  /// `CioCheETuo` dichiara come cio' che **non e' di nessuno e resta**: e'
  /// come questo telefono e' regolato, non chi lo usa. La ragione e' la
  /// stessa gia' scritta li' per la qualita' grafica e i sottotitoli:
  /// buttarla all'oblio rimetterebbe in italiano un'app che qualcuno aveva
  /// messo in inglese, e sarebbe una punizione, non una pulizia.
  static const String chiave = 'settings.lingua';

  /// La lingua di adesso. Chi disegna ci si aggancia con un
  /// `ValueListenableBuilder`, cosi' un cambio di lingua ridisegna l'app
  /// intera senza che nessuno debba ricordarsene.
  static final ValueNotifier<LinguaDelCerchio> corrente =
      ValueNotifier<LinguaDelCerchio>(LinguaDelCerchio.italiano);

  /// Legge la lingua conservata e la fa valere. Si chiama all'avvio, prima di
  /// disegnare: dopo sarebbe un lampo nella lingua sbagliata.
  static Future<void> risveglia({SharedPreferences? prefs}) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    faiValere(LinguaDelCerchio.dalCodice(p.getString(chiave)));
  }

  /// Sceglie la lingua, la fa valere e se la ricorda.
  static Future<void> scegli(LinguaDelCerchio lingua,
      {SharedPreferences? prefs}) async {
    faiValere(lingua);
    final p = prefs ?? await SharedPreferences.getInstance();
    await p.setString(chiave, lingua.codice);
  }

  /// **DOVE LA LINGUA SCENDE, ed e' l'unico posto dove scende.**
  ///
  /// Separata da [scegli] perche' le prove possano cambiarla senza toccare il
  /// disco, e perche' si veda a colpo d'occhio che cosa dipende dalla lingua:
  /// se domani dipendera' una quarta cosa, si aggiunge qui e non in una
  /// schermata.
  static void faiValere(LinguaDelCerchio lingua) {
    AppStrings.languageCode = lingua.codice;
    // **ORDINE DM VOCE 05.** `LinguaSenzaGenere` esisteva dall'ordine DL,
    // scritta per le lingue dove le tre forme coincidono, e **nessuno la
    // collegava a niente**: era una porta murata. Adesso la lingua che non ha
    // genere se la prende, e i testi con la marca `[a|b|c]` in inglese
    // rendono il campo neutro invece di scegliere fra maschile e femminile.
    LaMarcaDelGenere.lingua =
        lingua.senzaGenere ? const LinguaSenzaGenere() : const LinguaItaliana();
    corrente.value = lingua;
  }

  /// Rimette tutto com'era. Serve alle prove, che altrimenti si passerebbero
  /// la lingua l'una all'altra.
  @visibleForTesting
  static void dimentica() => faiValere(LinguaDelCerchio.italiano);
}
