import 'package:shared_preferences/shared_preferences.dart';

/// I SUGGERIMENTI AL PRIMO USO, UNO PER ZONA E UNA VOLTA SOLA.
///
/// **La seconda meta' dell'arrivo.** Decisione del fondatore del 28 agosto
/// 2026: chi entra la prima volta incontra il tutorial di primo approdo, e poi,
/// nel momento in cui una zona serve davvero, una riga che dice cosa si fa li'.
/// La prima meta' esiste dall'ordine CB voce 02; questa e' la seconda.
///
/// **I VINCOLI DEL FONDATORE, non negoziabili.** Si vede una volta sola, non
/// blocca, non e' un popup che si mette in mezzo. Il fondatore ha appena fatto
/// togliere due fogli dal Santuario perche' li considerava un ostacolo, e
/// questa voce non deve rimettere lo stesso ostacolo con un altro nome: il
/// suggerimento vive DENTRO il contenuto della zona, come una riga sua, e
/// mentre e' li' la zona funziona.
///
/// **LE ZONE NON LE HO SCELTE IO, LE DICHIARA L'APP.** Ordine CE voce 11 e
/// seguenti hanno insegnato che un elenco inventato invecchia: qui le zone sono
/// esattamente le vie della barra del Cerchio, cioe' la divisione che la
/// persona vede e tocca. Il Cerchio non ne ha una, perche' e' la zona che il
/// tutorial spiega per intero: dirlo due volte sarebbe la ripetizione che il
/// fondatore ha gia' rifiutato per il disclaimer.
enum ZonaDelCerchio {
  /// Il dominio di un Maestro: le arti, vive e in cammino.
  dominio(
    chiave: 'dominio',
    titolo: 'Le arti di questo Maestro',
    testo: 'Quelle accese si aprono adesso. Quelle in grigio arrivano: '
        'toccale e ti dicono quando.',
  ),

  /// La conversazione con un Maestro.
  chat(
    chiave: 'chat',
    titolo: 'Parlagli come parleresti a una persona',
    testo: 'Non servono parole giuste. Se una risposta ti interessa, chiedi '
        'di andare più a fondo e si allunga.',
  ),

  /// La zona dove la stessa domanda va a piu' sguardi. Il suo nome vive
  /// in un punto unico, e non si ricopia qui.
  consiglio(
    chiave: 'consiglio',
    titolo: 'Tre sguardi sulla stessa domanda',
    testo: 'Ognuno risponde dalla sua arte. In fondo trovi la sintesi che li '
        'mette a confronto.',
  ),

  /// Il Passaporto Cosmico.
  passaporto(
    chiave: 'passaporto',
    titolo: 'Qui si raccoglie quello che fai',
    testo: 'Sigilli, cammino e carta natale stanno insieme. Cresce da solo, '
        'mentre usi il Cerchio.',
  );

  const ZonaDelCerchio({
    required this.chiave,
    required this.titolo,
    required this.testo,
  });

  /// Il nome della zona nella memoria del telefono.
  final String chiave;

  /// **TESTO PROVVISORIO, da approvare.** Il fondatore approva i testi
  /// definitivi: queste quattro righe sono scritte per reggere la forma e la
  /// misura, e vanno lette come una proposta.
  final String titolo;

  /// **TESTO PROVVISORIO, da approvare.** Come sopra.
  final String testo;

  /// La chiave nel disco. **Sta sotto `avvisi.`**, che e' un prefisso che la
  /// cancellazione gia' porta via: chi cancella tutto e torna e' una persona
  /// nuova e li rivede, come rivede il tutorial.
  String get chiaveDiMemoria => 'avvisi.suggerimento.$chiave';
}

/// LA MEMORIA DEI SUGGERIMENTI.
///
/// **NON NASCONO ACCESI, SI ARMANO.** E' la stessa lezione che il primo
/// approdo porta scritta addosso: un avviso che nascesse acceso si
/// accenderebbe anche nelle prove e nelle anteprime, dove il disco e' vuoto e
/// "mai visto" e "appena arrivato" sono la stessa cosa. Qui l'arma la mette lo
/// stesso gesto che chiude la prima meta' dell'arrivo, cioe' il tutorial visto
/// o rivisto: le due meta' sono una cosa sola e si accendono insieme.
abstract final class MemoriaDeiSuggerimenti {
  /// La chiave che arma: finche' non c'e', nessun suggerimento compare.
  static const chiaveArmata = 'avvisi.suggerimenti.armati';

  /// **ARMA I SUGGERIMENTI**, cioe' dice che d'ora in poi la prima volta che
  /// si entra in una zona quella zona si presenta.
  static Future<void> arma() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(chiaveArmata, true);
    } catch (errore) {
      // Se il disco non risponde non si arma niente: un suggerimento mancato
      // e' molto meno grave di una schermata che non si apre.
    }
  }

  /// Vero solo se qualcuno ha armato E questa zona non si e' ancora
  /// presentata.
  static Future<bool> daMostrare(ZonaDelCerchio zona) async {
    try {
      final p = await SharedPreferences.getInstance();
      if (!(p.getBool(chiaveArmata) ?? false)) return false;
      return !(p.getBool(zona.chiaveDiMemoria) ?? false);
    } catch (errore) {
      return false;
    }
  }

  /// Questa zona si e' presentata: non lo fa mai piu'.
  static Future<void> segnaVisto(ZonaDelCerchio zona) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(zona.chiaveDiMemoria, true);
    } catch (errore) {
      // Come sopra: al peggio si rivede una volta.
    }
  }

  /// La via del menu' utente, insieme al tutorial: si dimentica di averli
  /// visti e si riarma. **Le due meta' tornano insieme**, perche' rivedere
  /// meta' spiegazione non e' rivedere la spiegazione.
  static Future<void> rivedi() async {
    try {
      final p = await SharedPreferences.getInstance();
      for (final z in ZonaDelCerchio.values) {
        await p.remove(z.chiaveDiMemoria);
      }
      await p.setBool(chiaveArmata, true);
    } catch (errore) {
      // Come sopra.
    }
  }
}
