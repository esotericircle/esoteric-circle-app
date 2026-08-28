import 'package:shared_preferences/shared_preferences.dart';

import '../tempo/confine_del_giorno.dart';
import 'cielo_di_oggi.dart';
import 'corrente_del_cielo.dart';

/// LA RIFLESSIONE PRIMA DEL RESPONSO. Ordine BK, voci 02, 03 e 05.
///
/// **Il difetto che l'ha fatta nascere.** Parole del fondatore: "l'ho appena
/// provato e la pausa con animazione di riflessione NON C'E'! il risultato
/// dell'oroscopo arriva di botto". La pausa esisteva nel codice e non era mai
/// visibile: al tocco le quattro schede montavano subito, e siccome montavano
/// con `scrivendo` falso il responso si costruiva INTERO. La macchina da
/// scrivere partiva dopo, su un testo gia' letto.
///
/// **Perche' due momenti e non uno.** Il fondatore ha chiesto "2 animazioni di
/// riflessione leggibili di 3 secondi credo in totale, per fare sembrare che
/// sia una risposta elaborata e impegnativa e non automatica". Un solo giro di
/// clessidra dice "sto caricando"; due passaggi che si susseguono dicono che
/// qualcuno sta guardando qualcosa e poi lo nomina. La differenza non e'
/// decorativa: e' la differenza fra un'attesa e un lavoro.
///
/// **E i due momenti mostrano il cielo VERO.** I dati ci sono gia' e non si
/// inventa niente: i corpi del giorno vengono dalle effemeridi, il fatto
/// nominato viene da `CorrenteDelCielo.fattoDelGiorno`, che e' la stessa porta
/// della chiamata del mattino. Quando la carta natale manca, il secondo
/// momento NON finge un transito: dichiara che la lettura parla al segno.
class RiflessioneDelCielo {
  const RiflessioneDelCielo._();

  /// Quanto dura UN momento nella riflessione piena.
  ///
  /// **DUEMILA, E NON PIU' MILLE E QUATTROCENTO. Ordine BZ voce 06.** Parole
  /// del fondatore: "quando faccio click su Interroga il cielo, parte una
  /// animazione strana che dura una frazione di secondo... mi sembra cmq
  /// scarsa". Due momenti da duemila fanno **4.000**: la scena si guarda
  /// invece di passare.
  ///
  /// **La finestra dell'ordine BK, fra 2,8 e 3,2 secondi, non vale piu'**, ed
  /// e' una decisione del fondatore che ne sostituisce una sua di prima. Con
  /// lei si spostano i due tetti delle schede, che da quella finestra
  /// dipendevano: sono scritti qui sotto.
  static const Duration momentoPieno = Duration(milliseconds: 2000);

  /// Quanto dura UN momento nella riflessione breve, dalla seconda
  /// interrogazione del giorno in poi.
  ///
  /// **MILLECINQUECENTO, E NON PIU' CINQUECENTO.** Era qui il difetto che il
  /// fondatore ha visto: chi aveva gia' interrogato il cielo quel giorno
  /// vedeva due momenti da mezzo secondo, cioe' un secondo in tutto, ed e'
  /// esattamente "una frazione di secondo". I momenti restano COMPRESSI
  /// rispetto alla prima volta, tremila contro quattromila, ma smettono di
  /// essere un lampo.
  static const Duration momentoBreve = Duration(milliseconds: 1500);

  static Duration momento({required bool piena}) =>
      piena ? momentoPieno : momentoBreve;

  /// La riflessione intera: i due momenti, uno dopo l'altro.
  static Duration intera({required bool piena}) =>
      momento(piena: piena) * numeroDeiMomenti;

  /// I momenti sono due, e il numero vive qui perche' le prove lo contino
  /// invece di scriverlo.
  static const int numeroDeiMomenti = 2;

  /// **LA SCRITTURA A CASCATA, e il numero che la governa.**
  ///
  /// L'ordine pone due tetti diversi: la PRIMA scheda leggibile per intero
  /// entro 3,5 secondi dal tocco, l'ULTIMA delle quattro entro 6,0. Due tetti
  /// diversi hanno senso solo se le schede non finiscono tutte insieme, ed e'
  /// la lettura giusta: chi apre l'Oroscopo legge la Generale mentre le altre
  /// si compongono, invece di aspettare fermo che appaia tutto.
  ///
  /// **Prima era 2.600 millesimi per scheda, in parallelo.** Le quattro schede
  /// montavano insieme e scrivevano insieme, quindi finivano tutte a 2.600
  /// millesimi dall'inizio della scrittura: con la riflessione davanti, la
  /// prima scheda sarebbe stata leggibile a 5.400, cioe' quasi due secondi
  /// oltre il tetto.
  ///
  /// **I DUE TETTI SI SPOSTANO COL MOMENTO. Ordine BZ voce 06.** Erano 3,5 e
  /// 6,0 secondi e dipendevano da una riflessione da 2.800; con la
  /// riflessione da 4.000 diventano **5,0 e 7,0**. Non e' una soglia
  /// abbassata: e' la stessa legge (la prima scheda si legge presto, l'ultima
  /// non fa aspettare) applicata a una riflessione che il fondatore ha
  /// chiesto piu' lunga.
  ///
  /// Coi numeri di qui, e la riflessione piena da 4.000:
  /// la prima scheda e' intera a **4.600** (tetto 5.000), la quarta a
  /// 4.000 + 3 x 700 + 600 = **6.700** (tetto 7.000).
  static const Duration scritturaDiUnaScheda = Duration(milliseconds: 600);

  /// Quanto passa fra l'inizio di una scheda e l'inizio della successiva.
  static const Duration passoFraLeSchede = Duration(milliseconds: 700);

  /// Quando l'ultima di [quante] schede ha finito di scriversi, contando dal
  /// tocco. Serve alle prove per non indovinare nessun numero.
  static Duration finoAllUltimaScheda(int quante, {required bool piena}) =>
      intera(piena: piena) +
      passoFraLeSchede * (quante - 1) +
      scritturaDiUnaScheda;

  /// Quando la PRIMA scheda ha finito di scriversi, contando dal tocco.
  static Duration finoAllaPrimaScheda({required bool piena}) =>
      intera(piena: piena) + scritturaDiUnaScheda;

  /// IL FATTO CHE IL SECONDO MOMENTO NOMINA, o nulla se non c'e' cielo vero.
  ///
  /// Non e' una frase nuova: e' la stessa riga della chiamata del mattino,
  /// presa dal transito piu' forte del giorno. Un secondo posto che scrivesse
  /// per conto proprio finirebbe per dire una cosa diversa dal responso che
  /// segue, ed e' esattamente cio' che una riflessione non deve fare.
  static String? fattoDaNominare(CieloDiOggi cielo) =>
      CorrenteDelCielo.fattoDelGiorno(cielo);

  /// COSA DICE IL SECONDO MOMENTO QUANDO IL CIELO VERO NON C'E'.
  ///
  /// **Non finge un transito.** Chi ha dato solo la data di nascita non ha
  /// case ne' aspetti: inventare qui un passaggio planetario sarebbe una
  /// promessa non mantenuta detta proprio nel momento in cui la persona sta
  /// guardando. Si dichiara il ripiego, con le stesse parole della nota del
  /// cielo che la schermata gia' porta piu' in basso.
  static const String senzaCieloVero = 'La lettura di oggi parla al tuo segno.';

  /// La riga del secondo momento, sempre vera: il fatto quando c'e', la
  /// dichiarazione del ripiego quando manca.
  static String rigaDelSecondoMomento(CieloDiOggi cielo) =>
      fattoDaNominare(cielo) ?? senzaCieloVero;
}

/// I DUE MOMENTI, nell'ordine in cui si susseguono.
enum MomentoDellaRiflessione {
  /// Il cielo si raccoglie: i corpi veri del giorno attorno all'emblema.
  raccolta,

  /// Il fatto vero viene nominato, in una riga.
  nomina,
}

/// LA MEMORIA DELL'ATTESA PIENA. Ordine BK voce 05.
///
/// Parole del fondatore: "riduci il tempo di attesa, ma alla mezzanotte
/// ripristina il conteggio cosi' la prima volta con l'oroscopo originale
/// l'utente aspetta di piu', ma le successive consultazioni saranno
/// esattamente le stesse".
///
/// **Il confine del giorno e' quello dell'app, non un secondo confine.**
/// `ConfineDelGiorno.chiaveDi` e' l'autorita', la stessa che decide l'istante
/// dei transiti: due confini diversi nella stessa app vorrebbero dire che a
/// mezzanotte cambia il responso ma non l'attesa, o il contrario. E il
/// conteggio sta sul disco, quindi sopravvive alla chiusura dell'app: tenerlo
/// in memoria vorrebbe dire ridare l'attesa piena a ogni riavvio.
class MemoriaDellaRiflessione {
  const MemoriaDellaRiflessione._();

  /// La chiave sul disco. Vive qui in una casa sola, e l'inventario la
  /// riferisce da qui invece di riscriverla.
  static const String chiave = 'oroscopo_riflessione_piena_v1';

  /// Se l'attesa piena e' GIA' stata spesa nel giorno di [adesso].
  static Future<bool> giaSpesaOggi(DateTime adesso) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(chiave) == ConfineDelGiorno.chiaveDi(adesso);
  }

  /// Segna che l'attesa piena e' stata spesa nel giorno di [adesso].
  ///
  /// Si chiama dal TOCCO e non dall'apertura della schermata: aprire
  /// l'Oroscopo senza interrogarlo non deve consumare la prima volta del
  /// giorno, o chi entra e esce si troverebbe l'attesa breve senza aver mai
  /// visto quella piena.
  static Future<void> segnaSpesaOggi(DateTime adesso) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(chiave, ConfineDelGiorno.chiaveDi(adesso));
  }

  /// Dimentica, per le prove e per la cancellazione dei dati.
  static Future<void> dimentica() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(chiave);
  }
}
