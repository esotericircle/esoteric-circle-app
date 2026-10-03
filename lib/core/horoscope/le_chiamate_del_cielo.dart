import '../astro/l_alba_e_il_tramonto.dart';
import '../astro/natal_chart.dart';
import '../rituals/avvisi_del_rito.dart';
import 'l_ora_d_oro.dart';
import 'la_lettura_vedica.dart';

/// **LE DUE CHIAMATE DEL CIELO, ordine ES voce 32.**
///
/// La voce: *"un quarto d'ora prima dell'ora d'oro e il Rahu Kalam del
/// mattino"*. Sono le due notifiche che l'Oroscopo porta con se': la prima per
/// chi ha la carta natale, perche' l'ora d'oro e' un aspetto della Luna al
/// suo Sole, alla sua Venere o al suo Giove di nascita; la seconda per chi
/// legge la tradizione vedica e ha detto la sua citta', perche' il Rahu Kalam
/// si conta dall'alba e dal tramonto del luogo.
///
/// **Sette giorni alla volta, e ogni volta da capo.** Si programmano i giorni
/// che vengono, e a ogni nuovo giro si annullano prima tutti e quattordici
/// gli id: un giorno che ieri aveva un'ora d'oro e oggi, ricalcolato con una
/// carta corretta, non ce l'ha piu', non deve lasciare una chiamata orfana.
/// L'app riprogramma a ogni avvio (`RegiaDelleChiamate`), quindi chi la apre
/// almeno una volta la settimana non resta mai senza.
///
/// **Un giorno senza ora d'oro non chiama**, come la scheda non la mostra:
/// non se ne inventa una. E un'ora d'oro gia' passata, o a meno di un quarto
/// d'ora, non chiama piu': un avviso che arriva dopo la cosa che annuncia e'
/// rumore.
abstract final class LeChiamateDelCielo {
  /// Quanti giorni si programmano in avanti, oggi compreso.
  static const int giorni = 7;

  /// Gli id: sette per l'ora d'oro, sette per il Rahu Kalam, lontani da
  /// quelli dei Doni, dell'anno (90404) e della prova (90001).
  static const int primoIdDellOraDOro = 90510;
  static const int primoIdDelRahuKalam = 90520;

  /// Tutti e quattordici, per chi deve annullarli o contarli.
  static List<int> get tuttiGliId => [
        for (var i = 0; i < giorni; i++) primoIdDellOraDOro + i,
        for (var i = 0; i < giorni; i++) primoIdDelRahuKalam + i,
      ];

  /// Quanto prima dell'ora d'oro arriva l'avviso.
  static const Duration anticipo = Duration(minutes: 15);

  static const String canaleOraDOro = 'ora_d_oro';
  static const String canaleRahuKalam = 'rahu_kalam';

  /// L'ora locale in cifre, "15:40".
  static String _oraLocale(DateTime t) {
    final l = t.toLocal();
    return '${l.hour.toString().padLeft(2, '0')}:'
        '${l.minute.toString().padLeft(2, '0')}';
  }

  /// Il testo dell'avviso dell'ora d'oro. **Non dice "fra un quarto d'ora"**:
  /// su Android la consegna e' approssimata (`ServizioAvvisi.programma`), e
  /// l'avviso puo' arrivare qualche minuto dopo. L'ora scritta resta vera.
  static String testoDellOraDOro(OraDOro o) =>
      'Alle ${_oraLocale(o.istante)} la Luna forma '
      '${OraDOro.conArticolo[o.aspetto]} ${OraDOro.alPunto[o.punto]} di '
      'nascita: la tua ora d\'oro sta arrivando.';

  /// Il testo dell'avviso del Rahu Kalam.
  static String testoDelRahuKalam(
          String dove, DateTime inizio, DateTime fine) =>
      'Oggi a $dove il Rahu Kalam va dalle ${_oraLocale(inizio)} alle '
      '${_oraLocale(fine)}: la tradizione vedica non gli affida gli inizi.';

  /// Annulla le chiamate di prima e programma quelle dei prossimi [giorni].
  /// Torna gli id programmati.
  static Future<List<int>> programma({
    required ServizioAvvisi servizio,
    required DateTime adesso,
    NatalChart? carta,
    LuogoDelGiorno? luogo,
    required bool oraDOro,
    required bool rahuKalam,
  }) async {
    for (final id in tuttiGliId) {
      await servizio.annulla(id);
    }
    final fatti = <int>[];
    final oggi = DateTime(adesso.year, adesso.month, adesso.day);
    for (var i = 0; i < giorni; i++) {
      final giorno = DateTime(oggi.year, oggi.month, oggi.day + i);
      if (oraDOro && carta != null) {
        final o = LOraDOro.di(carta, giorno);
        final quando = o?.istante.toLocal().subtract(anticipo);
        if (o != null && quando != null && quando.isAfter(adesso)) {
          await servizio.programma(
            id: primoIdDellOraDOro + i,
            quando: quando,
            titolo: 'Medora · L\'ora d\'oro',
            testo: testoDellOraDOro(o),
            canale: canaleOraDOro,
            carico: AvvisiDelRito.caricoOroscopo,
          );
          fatti.add(primoIdDellOraDOro + i);
        }
      }
      if (rahuKalam && luogo != null) {
        final mezzogiorno = DateTime(giorno.year, giorno.month, giorno.day, 12);
        final e = LAlbaEIlTramonto.delGiorno(giorno,
            lat: luogo.lat, lon: luogo.lon, offset: mezzogiorno.timeZoneOffset);
        final rk = LaLetturaVedica.rahuKalam(giorno, luogo);
        // **All'alba**, che nella tradizione vedica e' l'inizio del giorno:
        // il Rahu Kalam non cade mai nel primo ottavo, quindi l'avviso
        // arriva sempre prima.
        final quando = e?.alba.toLocal();
        if (rk != null && quando != null && quando.isAfter(adesso)) {
          await servizio.programma(
            id: primoIdDelRahuKalam + i,
            quando: quando,
            titolo: 'Medora · Il Rahu Kalam di oggi',
            testo: testoDelRahuKalam(luogo.citta, rk.$1, rk.$2),
            canale: canaleRahuKalam,
            carico: AvvisiDelRito.caricoOroscopo,
          );
          fatti.add(primoIdDelRahuKalam + i);
        }
      }
    }
    return fatti;
  }
}
