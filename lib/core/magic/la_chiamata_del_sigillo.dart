import '../rituals/avvisi_del_rito.dart';
import 'il_sigillo_vivo.dart';
import 'la_voce_del_sigillo.dart';

/// **LA NOTIFICA ALLA SCADENZA, LOCALE E SENZA SERVER.** Ordine DO voce 08,
/// 15 settembre 2026.
///
/// La data la sceglie la persona nel momento in cui traccia, quindi e' nota
/// in anticipo e basta una notifica locale programmata dal telefono. **Si
/// riusa il meccanismo dei Doni**, `ServizioAvvisi` sopra
/// `flutter_local_notifications`, senza costruirne uno nuovo: stesso motore,
/// stessa consegna, un canale suo che si spegne da solo nelle impostazioni.
///
/// **I DUE LIMITI, DICHIARATI E NON NASCOSTI.**
///
/// 1. **La finestra e' approssimata**, non un orario esatto al minuto: e' la
///    consegna `inexactAllowWhileIdle` dei Doni, e la ragione e' la stessa,
///    scritta accanto ad `AvvisiDelRito`. L'ora esatta su Android 14 vuole un
///    permesso che Google Play concede solo a sveglie e calendari.
/// 2. **La gestione della batteria di alcuni produttori puo' ritardarla o
///    sopprimerla.** Nessun codice lo impedisce da dentro l'app.
///
/// **Per questo la notifica non e' l'unica via**: se non arriva, la domanda
/// della voce DO.05 aspetta nel Libro dei Sigilli, e il sigillo compare fra
/// quelli arrivati alla loro data alla prima apertura del Libro o della
/// schermata del Sigillo.
///
/// **Il testo non contiene l'intenzione**: una notifica si legge sulla
/// schermata di blocco, davanti a chiunque passi.
abstract final class LaChiamataDelSigillo {
  /// Il canale di sistema, dichiarato in `AvvisiLocali.canali`.
  static const String canale = 'sigillo_scadenza';

  /// Il carico che l'apertura riceve: porta al Libro, dove la domanda
  /// aspetta.
  static const String carico = 'sigillo:libro';

  /// L'ora del giorno scelto, a finestra approssimata: la mattina, quando
  /// una domanda si legge con calma.
  static const int ora = 10;

  /// **GLI ID STANNO DA 2000 A 6999**, lontano dai Doni (1100 e seguenti),
  /// dalle chiamate di prima (1001-1004) e dalla prova (90001). Si ricavano
  /// dall'id del sigillo con un'impronta stabile fra un avvio e l'altro,
  /// cosi' la chiamata si annulla e si riprogramma senza tenerne un registro.
  static int idDi(String idDelSigillo) {
    var h = 0x811c9dc5;
    for (final c in idDelSigillo.codeUnits) {
      h = ((h ^ c) * 0x01000193) & 0xffffffff;
    }
    return 2000 + h % 5000;
  }

  /// Quando suona per [sigillo]: il giorno scelto, all'[ora].
  static DateTime quandoPer(SigilloVivo sigillo) => DateTime(
      sigillo.scadenza.year, sigillo.scadenza.month, sigillo.scadenza.day, ora);

  /// **PROGRAMMA LA CHIAMATA**, chiedendo il permesso se non c'e': la riga a
  /// tracciamento finito promette *"ti cerco io alla data che hai scelto"*, e
  /// senza permesso la promessa non si mantiene. Chi dice no trova la domanda
  /// nel Libro lo stesso. Non solleva mai: una chiamata che non si programma
  /// non rompe il sigillo.
  static Future<bool> programma(
    SigilloVivo sigillo,
    ServizioAvvisi servizio, {
    DateTime? adesso,
  }) async {
    try {
      if (!servizio.disponibile) return false;
      final quando = quandoPer(sigillo);
      if (!quando.isAfter(adesso ?? DateTime.now())) return false;
      if (!await servizio.permessoConcesso() &&
          !await servizio.chiediPermesso()) {
        return false;
      }
      await servizio.programma(
        id: idDi(sigillo.id),
        quando: quando,
        titolo: LaVoceDelSigillo.titoloDellAvviso,
        testo: LaVoceDelSigillo.testoDellAvviso,
        canale: canale,
        carico: carico,
      );
      return true;
    } catch (errore) {
      // Una chiamata che non si programma non rompe il sigillo: la domanda
      // aspetta nel Libro, che e' la seconda via della voce DO.08.
      return false;
    }
  }

  /// Toglie la chiamata di un sigillo chiuso prima della sua data.
  static Future<void> annulla(
      String idDelSigillo, ServizioAvvisi servizio) async {
    try {
      if (servizio.disponibile) await servizio.annulla(idDi(idDelSigillo));
    } catch (errore) {
      // Una chiamata rimasta in coda porta al Libro, dove il sigillo e' gia'
      // chiuso: niente di rotto.
    }
  }
}
