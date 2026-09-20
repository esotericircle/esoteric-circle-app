/// IL LINK D'INGRESSO, SENZA PAROLA. Ordine EA voce 19, 20 settembre 2026.
///
/// **La scelta del fondatore**: *"Link piu' App Check"*, cioe' si scrive
/// l'indirizzo, arriva un messaggio, si tocca il link e si e' dentro. Nessuna
/// parola da inventare, nessuna da ricordare, nessuna da perdere: **e' la via
/// che disturba meno**, ed e' anche quella che verifica l'indirizzo per
/// costruzione, perche' il link ci e' arrivato davvero.
///
/// Qui vivono le due cose che servono a tutti e due i capi del viaggio:
/// **dove torna il link** e **a chi era stato mandato**.
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../brand/brand.dart';

/// Il nome dell'applicazione su Android, cioe' la stessa cosa che sta in
/// `android/app/build.gradle.kts`. Scritto qui perche' il link deve saper
/// dire a Firebase quale app riaprire.
const String pacchettoAndroid = 'com.esotericircle.esoteric_circle';

/// L'identificativo su iPhone, da `ios/Runner/Info.plist`.
const String pacchettoApple = 'com.esotericircle.esotericCircle';

/// **DOVE TORNA IL LINK.** E' un indirizzo del nostro dominio, quello che
/// Firebase Hosting pubblica: il messaggio porta li', e il telefono se lo
/// prende perche' l'app dichiara quel dominio come suo (App Links su Android,
/// Associated Domains su iPhone).
String get indirizzoDelRitorno => '${Brand.url}/entra';

/// Le impostazioni del link, in un punto solo: le usa chi lo manda, e una
/// guardia le rilegge per dire che non sono cambiate di nascosto.
ActionCodeSettings impostazioniDelLink() => ActionCodeSettings(
      url: indirizzoDelRitorno,
      // **SI APRE NELL'APP, non in un browser**: e' tutto il senso della via
      // scelta. Senza questa riga il link aprirebbe una pagina web che poi
      // non saprebbe dove mandare la persona.
      handleCodeInApp: true,
      androidPackageName: pacchettoAndroid,
      androidInstallApp: true,
      androidMinimumVersion: '1',
      iOSBundleId: pacchettoApple,
    );

/// **A CHI ERA STATO MANDATO.** Il link, da solo, non dice per quale
/// indirizzo vale: Firebase lo pretende al ritorno, ed e' giusto, perche'
/// senza chiunque intercetti il messaggio potrebbe usarlo. L'indirizzo resta
/// sul telefono che lo ha chiesto, e se ne va appena si e' entrati.
abstract final class MemoriaDellEmailDelLink {
  /// **La chiave sta sotto `ingresso.`**, un prefisso dichiarato in
  /// `CioCheETuo`: chi cancella i propri dati se ne va anche da qui.
  static const String chiave = 'ingresso.emailDelLink';

  static Future<void> segna(String email) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(chiave, email.trim());
    } catch (errore) {
      // Senza disco il link si potra' usare solo riscrivendo l'indirizzo, e
      // la schermata lo chiede: non e' un guasto, e' una strada piu' lunga.
    }
  }

  static Future<String?> letta() async {
    try {
      final p = await SharedPreferences.getInstance();
      final v = p.getString(chiave)?.trim();
      return v == null || v.isEmpty ? null : v;
    } catch (errore) {
      return null;
    }
  }

  static Future<void> dimentica() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.remove(chiave);
    } catch (errore) {
      // Best effort: al massimo resta un indirizzo che nessuno rilegge.
    }
  }
}
