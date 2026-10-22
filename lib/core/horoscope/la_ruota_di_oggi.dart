import 'package:shared_preferences/shared_preferences.dart';

/// **IL FILMATO DELLA RUOTA, VISTO UNA VOLTA AL GIORNO.** Ordine GB voce 02,
/// 22 ottobre 2026.
///
/// Il filmato d'apertura dell'Oroscopo (la ruota dello zodiaco, circa nove
/// secondi) si vede per intero la prima volta che la persona apre la
/// funzione in un giorno civile; alle aperture seguenti dello stesso giorno
/// la scena parte gia' ferma, come se il video fosse gia' stato saltato.
/// Fonte: la proposta dell'Architetto nel rapporto dell'ordine GA,
/// approvata dal fondatore il 22 ottobre 2026 ("Ok per tutto").
///
/// Stessa forma di [LaLungaDiOggi]: una chiave sola, il giorno civile scritto
/// come stringa, mai un contatore che si possa sbagliare di uno.
///
/// **LA DECISIONE VERA E' SINCRONA, ordine GB voce 02.** La schermata
/// dell'Oroscopo decide se avviare il video nello stesso istante in cui si
/// apre (`didChangeDependencies`), e quella decisione non puo' aspettare un
/// giro del disco: l'avvio del video e' la cosa stessa che dodici voci di
/// prova misurano al centesimo di secondo (FXA.08, FU.15), e un`await`
/// davanti ad `avvia()` le fa cadere tutte, perche' senza un finto
/// `SharedPreferences` (`setMockInitialValues`) la lettura vera non
/// risponde mai in prova. [vistaOggiSubito] legge solo la memoria di questa
/// sessione, scaldata da [segna] nello stesso istante in cui viene
/// chiamata (la riga che scrive la memoria sta prima di ogni `await`, e
/// gira sul colpo anche se la chiamata non si aspetta): la primissima
/// apertura di un'installazione, in un giorno, vede sempre il filmato (la
/// cautela di sempre, uguale a quella di [vistaOggi] quando il disco non
/// risponde) e lo segna; le aperture seguenti NELLA STESSA SESSIONE lo
/// trovano gia' segnato e saltano. Il disco resta la fonte vera fra una
/// sessione e l'altra: [vistaOggi] lo legge e scalda la memoria per quando
/// la schermata lo chiede di nuovo, per chi puo' aspettarla (non la
/// schermata dell'Oroscopo, che decide sul colpo).
abstract final class LaRuotaDiOggi {
  static const String _chiave = 'oroscopo_ruota_vista_il';

  /// Il giorno per cui questa sessione sa, senza chiedere al disco, che il
  /// filmato e' gia' stato visto. Nullo finche' nessuna lettura o scrittura
  /// l'ha ancora scaldata.
  static String? _giornoInMemoria;

  static String _giorno(DateTime g) =>
      '${g.year}-${g.month.toString().padLeft(2, '0')}-'
      '${g.day.toString().padLeft(2, '0')}';

  /// **LA DECISIONE SINCRONA**, quella che la schermata usa davvero per
  /// decidere se avviare il video. Vero solo se questa sessione ha gia'
  /// scaldato la memoria per il giorno [oggi] (da [vistaOggi] o da
  /// [segna]): una sessione appena partita, che non ha ancora chiesto nulla
  /// al disco, risponde sempre falso, come se la ruota non fosse mai stata
  /// vista, ed e' la stessa cautela di [vistaOggi] quando il disco non
  /// risponde.
  static bool vistaOggiSubito(DateTime oggi) =>
      _giornoInMemoria == _giorno(oggi);

  /// Se la ruota del giorno [oggi] e' gia' stata vista, leggendo il disco e
  /// scaldando la memoria di questa sessione per la prossima volta che
  /// [vistaOggiSubito] viene chiesta. Nessuna schermata la aspetta per
  /// decidere se avviare il video: serve a scaldare la memoria in anticipo
  /// (per esempio in `initState`), o a chi puo' davvero aspettare la
  /// risposta del disco.
  static Future<bool> vistaOggi(DateTime oggi) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final letto = prefs.getString(_chiave);
      if (letto != null) _giornoInMemoria = letto;
      return letto == _giorno(oggi);
    } catch (errore) {
      // Se il disco non legge, vale la vecchia regola: si vede il filmato.
      return false;
    }
  }

  /// Le prove ripartono da una sessione senza niente scaldato.
  static void dimentica() => _giornoInMemoria = null;

  /// Segna la ruota del giorno [oggi] come vista: scalda subito la memoria
  /// di questa sessione (sincrono, prima di toccare il disco) e poi scrive
  /// sul disco per le sessioni che verranno.
  static Future<void> segna(DateTime oggi) async {
    _giornoInMemoria = _giorno(oggi);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_chiave, _giorno(oggi));
    } catch (errore) {
      // Se il disco non scrive vale per questa sessione: la prossima
      // installazione rivedra' il filmato, che non e' un errore grave
      // quanto bloccarla.
    }
  }
}
