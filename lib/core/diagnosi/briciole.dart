/// LE BRICIOLE DELLA DIAGNOSI, E IL FLAG CHE LE GOVERNA TUTTE.
///
/// **Perche' esiste questo file.** La 2159 iOS muore sull'iPhone di Mauro
/// senza lasciare NIENTE: Crashlytics e' vivo ma non riceve, quindi non e' un
/// crash del codice, e' un'uccisione da parte di iOS, memoria o watchdog, che
/// nessun rapporto puo' vedere. L'unico testimone possibile e' il disco:
/// una briciola scritta IN MODO SINCRONO a ogni tappa, che l'uccisione non
/// fa in tempo a cancellare. Alla riapertura, l'ultima briciola dice fin dove
/// l'app era arrivata.
///
/// **Sincrono, e non e' una svista**: `writeAsStringSync` con flush, niente
/// code ne' buffer, perche' l'uccisione non aspetta una coda.
///
/// **TEMPORANEO E DICHIARATO**: tutto vive dietro [kDiagnosiAttiva], il flag
/// unico della build diagnostica. A diagnosi chiusa si toglie il flag e cio'
/// che ci sta dietro, ed e' un debito annotato in STATO_VIVO.
library;

import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// IL FLAG DELLA DIAGNOSI, uno solo e riconoscibile.
///
/// SPENTO, per ordine 2161: una build di consegna non parte mai con la
/// diagnosi accesa. L'interruttore resta nel codice: per una build
/// diagnostica lo si accende A MANO, qui, e si consegna con un numero suo,
/// mai col numero di una consegna ordinaria. A guardia c'e'
/// `test/la_consegna_parte_a_diagnosi_spenta_test.dart`: con il flag acceso
/// il verde di consegna cade, quindi nessuna 2161+n puo' partire accesa per
/// distrazione. Prima era legato all'ambiente (acceso su ogni app vera,
/// spento nelle prove): con quella forma la 2161 sarebbe uscita diagnostica
/// senza che nessuna prova cadesse.
const bool kDiagnosiAttiva = false;

/// Le briciole: una tappa alla volta, su disco, in modo sincrono.
class Briciole {
  const Briciole._();

  static File? _file;
  static String? _corsaPrecedente;

  /// L'ultima tappa della corsa PRECEDENTE, letta a [prepara]: e' il verdetto
  /// del telefono su dove l'app e' morta. Nulla se non c'era nessuna briciola.
  static String? get dellaCorsaPrecedente => _corsaPrecedente;

  /// Prepara il file delle briciole e legge quello della corsa precedente.
  ///
  /// La cartella si risolve UNA volta all'avvio, perche' le scritture devono
  /// poi essere sincrone: non si puo' aspettare un percorso quando l'app sta
  /// morendo. [cartella] e' l'iniezione delle prove.
  static Future<void> prepara({Directory? cartella}) async {
    final dir = cartella ?? await getApplicationSupportDirectory();
    final f = File('${dir.path}${Platform.pathSeparator}briciola_diagnosi.txt');
    if (f.existsSync()) {
      try {
        _corsaPrecedente = f.readAsStringSync();
      } catch (errore) {
        // DICHIARATO: una briciola illeggibile non deve impedire l'avvio,
        // ma non sparisce in silenzio: diventa essa stessa il racconto.
        _corsaPrecedente = 'briciola illeggibile: $errore';
      }
    }
    _file = f;
  }

  /// Lascia la briciola della [tappa]: sovrascrive la precedente, con nome e
  /// orario. Se [prepara] non e' stata chiamata, non fa niente: e' il caso
  /// delle prove, che non preparano e non devono toccare il disco vero.
  static void lascia(String tappa) {
    final f = _file;
    if (f == null) return;
    try {
      f.writeAsStringSync(
        '$tappa|${DateTime.now().toIso8601String()}',
        flush: true,
      );
    } catch (errore) {
      // DICHIARATO: se il disco rifiuta la briciola non c'e' niente da fare
      // in punto di morte, ma lo si dice a console invece di tacere.
      // ignore: avoid_print
      print('briciola non scritta ($tappa): $errore');
    }
  }

  /// Azzera lo stato, per le prove che simulano piu' corse.
  static void azzera() {
    _file = null;
    _corsaPrecedente = null;
  }
}
