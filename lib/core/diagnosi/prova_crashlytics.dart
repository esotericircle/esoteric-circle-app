import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **LA PROVA CHE CRASHLYTICS SEGNALA. Ordine GB voce 08, 22 ottobre 2026.**
///
/// Il rapporto dell'ordine GA, punto 8: *"Crashlytics su iPhone tace da
/// settembre: o l'app non cade, o non segnala. Non ho modo di distinguere i
/// due casi da qui."* Un errore di prova, non fatale, segnalato una volta
/// sola, risponde alla domanda: se compare su Crashlytics dopo la prossima
/// build di TestFlight, il canale funziona e il silenzio di settembre
/// significava che l'app non e' caduta; se non compare, il canale stesso
/// e' muto.
///
/// **TEMPORANEO E DICHIARATO, come `kDiagnosiAttiva` in `briciole.dart`**:
/// dietro [kProvaCrashlyticsAttiva], spento per ogni consegna ordinaria. A
/// guardia c'e' `test/la_consegna_parte_senza_la_prova_di_crashlytics_test
/// .dart`, che cade se il flag resta acceso: nessuna build di consegna
/// manda questo errore di prova da sola. Il fondatore lo accende a mano
/// solo per la build con cui vuole fare la prova su TestFlight, e lo
/// rispegne alla consegna successiva.
///
/// **NON PARTE IN PRODUZIONE PER GLI UTENTI**: oltre al flag spento per
/// default, [invia] si ferma anche se non e' iOS (la domanda del rapporto
/// GA e' sul silenzio DELL'IPHONE) e se e' gia' stata inviata una volta su
/// questa installazione (una sola prova, mai una ripetuta a ogni avvio).
const bool kProvaCrashlyticsAttiva = false;

abstract final class ProvaCrashlytics {
  static const String _chiave = 'diagnosi.prova_crashlytics_inviata';

  /// Manda l'errore di prova, se il flag e' acceso, siamo su iOS e questa
  /// installazione non l'ha gia' mandato.
  static Future<void> invia() async {
    if (!kProvaCrashlyticsAttiva || !Platform.isIOS) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_chiave) == true) return;
      await prefs.setBool(_chiave, true);
    } catch (errore) {
      // Senza poter leggere se e' gia' stata mandata, si rinuncia: meglio
      // zero prove che una prova ripetuta a ogni avvio.
      return;
    }
    await FirebaseCrashlytics.instance.recordError(
      StateError('PROVA GB.08: errore di prova non fatale, una volta sola'),
      StackTrace.current,
      reason: 'prova deliberata del canale Crashlytics su iPhone, '
          'ordine GB voce 08',
      fatal: false,
    );
  }
}
