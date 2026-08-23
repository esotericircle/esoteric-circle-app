import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// QUANTO DEVE PASSARE FRA DUE FESTE. Ordine AU voce 06.
///
/// **La decisione del fondatore, e sostituisce quella del 16 agosto.** Fino a
/// ieri, quando piu' traguardi maturavano insieme, si celebrava una volta sola
/// e quella celebrazione li nominava TUTTI. Sulla 2188 il fondatore ha visto
/// una card che ne nominava cinque con centoventi Eos, e la regola cambia:
/// **una card celebra UN SOLO traguardo**. Una festa a raffica smette di
/// essere un premio.
///
/// **Perche' la coda da sola non basta.** Se gli altri traguardi restassero in
/// coda senza una distanza, la coda si svuoterebbe tutta nella stessa
/// schermata: cinque feste una dietro l'altra invece di una card con cinque
/// nomi. Cambierebbe la forma del fastidio, non il fastidio.
///
/// **Cosa NON e' in attesa.** Il Sigillo si accende subito nel sentiero e i
/// suoi Eos si accreditano subito. In attesa c'e' solo la festa, che e' il
/// modo di dirlo: non hai perso niente, te lo racconto dopo.
class DistanzaFraLeFeste {
  const DistanzaFraLeFeste._();

  static const String _chiaveUltima = 'cammino.ultima_festa';

  /// **NOVANTA SECONDI, non piu' tre ore.** Ordine BD voce 08, decisione del
  /// fondatore del 23 agosto 2026, e SOSTITUISCE le regole dell'ordine AU:
  /// "festa sempre, subito". Sulla 2198 il fondatore ha raggiunto obiettivi
  /// senza vedere nessuna animazione, e la misura ha detto che le feste
  /// FUNZIONAVANO ed erano TRATTENUTE dalle tre ore e dal limite per
  /// apertura: dalla sua poltrona era identico a "non funzionano".
  ///
  /// Questa distanza vale solo per il GUARDIANO che svuota la coda a freddo:
  /// una maturazione fresca festeggia sempre, nell'istante del gesto, e la
  /// coda riparte appena la festa di prima si chiude.
  static const Duration quantoPassa = Duration(seconds: 90);

  /// **NON PIU' DI UNA FESTA PER APERTURA DELL'APP.** Vive in memoria e non su
  /// disco apposta: "questa apertura" finisce quando il processo finisce, e un
  /// valore salvato sopravviverebbe alla chiusura dicendo il falso.
  static bool _giaFestaInQuestaApertura = false;

  /// Azzera il conto dell'apertura. Lo chiamano l'avvio dell'app e le prove.
  @visibleForTesting
  static void nuovaApertura() => _giaFestaInQuestaApertura = false;

  /// Vero se la festa e' gia' stata mostrata da quando l'app e' aperta.
  static bool get giaFestaInQuestaApertura => _giaFestaInQuestaApertura;

  /// Si puo' festeggiare adesso? Guarda tutte e due le regole.
  ///
  /// **Il primo Sigillo in assoluto passa comunque**, ed e' voluto: chi apre
  /// l'app per la prima volta non ha nessuna festa alle spalle, e fargli
  /// aspettare tre ore il primo premio sarebbe il contrario di cio' che
  /// l'ordine chiede.
  static Future<bool> siPuoFesteggiare({bool primoInAssoluto = false}) async {
    if (primoInAssoluto) return true;
    // **IL LIMITE DI UNA FESTA PER APERTURA NON ESISTE PIU'.** Ordine BD
    // voce 08: era la prima delle due mani che trattenevano le feste, e il
    // fondatore ha scelto di aprirle entrambe. Il campo resta per le prove
    // che raccontano la storia, ma qui non decide piu' niente.
    final disco = await SharedPreferences.getInstance();
    final ultima = disco.getInt(_chiaveUltima);
    if (ultima == null) return true;
    final passato = DateTime.now().millisecondsSinceEpoch - ultima;
    return passato >= quantoPassa.inMilliseconds;
  }

  /// Si segna che una festa e' appena stata mostrata.
  static Future<void> segnaFesta({DateTime? quando}) async {
    _giaFestaInQuestaApertura = true;
    final disco = await SharedPreferences.getInstance();
    await disco.setInt(
        _chiaveUltima, (quando ?? DateTime.now()).millisecondsSinceEpoch);
  }

  /// Solo per le prove: sposta indietro l'istante dell'ultima festa.
  @visibleForTesting
  static Future<void> fingiCheSiaPassato(Duration quanto) async {
    final disco = await SharedPreferences.getInstance();
    await disco.setInt(_chiaveUltima,
        DateTime.now().subtract(quanto).millisecondsSinceEpoch);
  }
}
