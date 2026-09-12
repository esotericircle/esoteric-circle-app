import '../sigilli/eventi_del_cielo.dart';
import 'natal_chart.dart';
import 'zodiac.dart';

/// UN EVENTO DEL CIELO CHE DEVE ANCORA ARRIVARE.
class EventoInArrivo {
  const EventoInArrivo({
    required this.evento,
    required this.quando,
    required this.fraQuantiGiorni,
    required this.personale,
  });

  /// Il nome dell'evento, dallo stesso elenco di [EventiDelCielo].
  final String evento;

  /// Il giorno in cui comincia, a mezzanotte locale.
  final DateTime quando;

  /// Quanti giorni mancano: zero vuol dire oggi.
  final int fraQuantiGiorni;

  /// Vero se l'evento riguarda QUESTA persona e non tutti: serve il segno o
  /// la carta natale per saperlo, e senza non si calcola.
  final bool personale;

  bool get eOggi => fraQuantiGiorni == 0;
}

/// IL MOTORE DELLA PROSSIMA DATA. Ordine AN voce 01.
///
/// **Una porta sola per l'astronomia, e questa non ne apre una seconda.**
/// `EventiDelCielo.diOggi` sa dire quali eventi sono attivi in un giorno
/// dato, leggendo da `MoonPhase`, `NightSky`, `AspettiDiOggi` ed
/// `Effemeridi`. Qui non si ricalcola niente di astronomico: si CHIEDE A LUI
/// giorno per giorno, avanti nel tempo, e si registra dove ogni evento
/// comincia. Un secondo motore darebbe due risposte diverse alla stessa
/// domanda, ed e' esattamente la famiglia di difetti che il progetto evita.
///
/// **La prossima occorrenza e' l'INIZIO, non ogni giorno in cui l'evento
/// dura.** Mercurio resta retrogrado per settimane e il Sole sta nel tuo
/// segno per un mese: un calendario che li ripetesse ogni giorno sarebbe
/// illeggibile. Quindi un evento "arriva" nel giorno in cui e' attivo e il
/// giorno prima non lo era. L'unica eccezione e' OGGI: se e' attivo adesso,
/// la sua prossima data e' oggi, perche' e' cio' che la persona vede.
///
/// **Cosa serve per gli eventi personali.** Luna e Sole nel tuo segno
/// chiedono il segno; ritorno solare e transiti chiedono la carta natale.
/// Senza, non si calcolano e non compaiono: l'assenza si dichiara a chi
/// guarda, non si riempie con un segnaposto.
class ProssimiEventi {
  const ProssimiEventi._();

  /// L'ORIZZONTE, dichiarato. Poco piu' di un anno: abbastanza per contenere
  /// il ritorno solare e i due solstizi di chiunque, poco abbastanza da
  /// restare una scansione breve. Oltre questo non si guarda, e chi non ha
  /// una data entro l'orizzonte semplicemente non compare.
  static const int orizzonteDiGiorni = 400;

  /// GLI EVENTI CHE NON SONO APPUNTAMENTI, dichiarati qui e non sparsi.
  ///
  /// La Luna e' sempre crescente o calante: sono due stati che si alternano,
  /// non due date da attendere, e in un calendario direbbero solo che il
  /// tempo passa. Restano vivi come eventi di oggi per i traguardi, che e'
  /// il posto in cui hanno senso.
  static const Set<String> statiContinui = {
    EventiDelCielo.lunaCrescente,
    EventiDelCielo.lunaCalante,
  };

  /// GLI EVENTI CHE SI RICONOSCONO DA UN ATTRAVERSAMENTO, e la loro data
  /// vera e' il giorno PRIMA.
  ///
  /// `EventiDelCielo.diOggi` riconosce questi eventi confrontando la
  /// posizione di IERI con quella di OGGI, entrambe lette a mezzanotte
  /// locale: quando il confronto scatta, l'istante e' caduto fra le due
  /// mezzanotti, cioe' nel giorno precedente. Misurato: il solstizio
  /// d'inverno 2026 cade il 21 dicembre alle 15:50 UTC, e il confronto lo
  /// segnala a mezzanotte del 22. Per i traguardi il giorno segnalato va
  /// bene, perche' dice "il cielo ha appena fatto questo"; per un
  /// CALENDARIO che mostra le date la data giusta e' quella vera, e si
  /// corregge qui, in un punto solo, senza toccare il motore di oggi ne'
  /// aprire una seconda porta dell'astronomia.
  static const Set<String> attraversamenti = {
    EventiDelCielo.solstizio,
    EventiDelCielo.equinozio,
    EventiDelCielo.ritornoSolare,
    EventiDelCielo.mercurioDiretto,
    EventiDelCielo.venereDiretta,
    EventiDelCielo.marteDiretto,
    EventiDelCielo.gioveDiretto,
    EventiDelCielo.saturnoDiretto,
  };

  /// GLI EVENTI CHE RIGUARDANO TE, e non tutti.
  static const Set<String> personali = {
    EventiDelCielo.lunaNelTuoSegno,
    EventiDelCielo.lunaNelSegnoOpposto,
    EventiDelCielo.soleNelTuoSegno,
    EventiDelCielo.ritornoSolare,
    EventiDelCielo.lunaPienaNelTuoSegno,
    EventiDelCielo.lunaNuovaNelTuoSegno,
    EventiDelCielo.transitoSullAscendente,
    EventiDelCielo.transitoSulSole,
    EventiDelCielo.transitoSullaLuna,
    EventiDelCielo.transitoSuVenere,
    EventiDelCielo.transitoSuMarte,
    EventiDelCielo.treTransitiInsieme,
  };

  /// I PROSSIMI EVENTI, in ordine cronologico.
  ///
  /// Si scandisce un giorno alla volta dall'oggi in avanti, chiedendo a
  /// `EventiDelCielo.diOggi` cosa e' attivo. Il primo giorno in cui un
  /// evento compare senza esserci il giorno prima e' la sua prossima data.
  static List<EventoInArrivo> da({
    required DateTime adesso,
    NatalChart? carta,
    Zodiac? segno,
    int orizzonte = orizzonteDiGiorni,
  }) {
    final oggi = DateTime(adesso.year, adesso.month, adesso.day);
    final trovati = <String, EventoInArrivo>{};

    // Il giorno PRIMA di oggi serve a sapere cosa era gia' in corso: un
    // evento attivo ieri e ancora attivo oggi e' cominciato ieri, ma per chi
    // guarda adesso e' comunque "oggi", ed e' quello che si mostra.
    var ieri = EventiDelCielo.diOggi(
      adesso: DateTime(oggi.year, oggi.month, oggi.day - 1),
      carta: carta,
      segno: segno,
    );

    for (var i = 0; i <= orizzonte; i++) {
      // **I GIORNI SI CONTANO SUL CALENDARIO, non con una durata.**
      // Sommare Duration(days:) a un istante locale attraversa il cambio
      // dell'ora legale e sposta l'orario di un'ora: misurato, il solstizio
      // di dicembre finiva alle 23 del giorno prima, cioe' un giorno
      // sbagliato. Il costruttore normalizza il mese e l'anno da solo.
      final giorno = DateTime(oggi.year, oggi.month, oggi.day + i);
      final attivi = EventiDelCielo.diOggi(
        adesso: giorno,
        carta: carta,
        segno: segno,
      );
      for (final evento in attivi) {
        if (statiContinui.contains(evento)) continue;
        if (trovati.containsKey(evento)) continue;
        // Comincia oggi, oppure era gia' in corso e oggi e' il giorno in cui
        // la persona lo vede: in tutti e due i casi la data e' questa.
        if (i == 0 || !ieri.contains(evento)) {
          // La data VERA di un attraversamento e' il giorno prima di quello
          // in cui il confronto scatta, per la ragione scritta sopra. Mai
          // prima di oggi: se scatta gia' oggi, oggi e' cio' che si vede.
          final indietro = attraversamenti.contains(evento) && i > 0 ? 1 : 0;
          trovati[evento] = EventoInArrivo(
            evento: evento,
            quando: DateTime(giorno.year, giorno.month, giorno.day - indietro),
            fraQuantiGiorni: i - indietro,
            personale: personali.contains(evento),
          );
        }
      }
      ieri = attivi;
      // Trovati tutti quelli possibili: non serve scandire oltre.
      if (trovati.length == _quantiPossibili(carta: carta, segno: segno)) {
        break;
      }
    }

    final elenco = trovati.values.toList()
      ..sort((a, b) {
        final perData = a.fraQuantiGiorni.compareTo(b.fraQuantiGiorni);
        if (perData != 0) return perData;
        // A PARITA' DI DATA VINCE IL TUO, decisione dell'ordine AN voce 02:
        // fra la Luna piena di tutti e la Luna piena NEL TUO SEGNO, quella
        // che parla di te viene prima.
        if (a.personale != b.personale) return a.personale ? -1 : 1;
        return a.evento.compareTo(b.evento);
      });
    return elenco;
  }

  /// IL PROSSIMO EVENTO, uno solo: quello che la barra mostra.
  static EventoInArrivo? primo({
    required DateTime adesso,
    NatalChart? carta,
    Zodiac? segno,
    int orizzonte = orizzonteDiGiorni,
  }) {
    final elenco =
        da(adesso: adesso, carta: carta, segno: segno, orizzonte: orizzonte);
    return elenco.isEmpty ? null : elenco.first;
  }

  /// Quanti eventi possono comparire, dato cio' che si sa della persona:
  /// serve solo a fermare la scansione quando non resta piu' niente da
  /// trovare, mai a decidere cosa mostrare.
  static int _quantiPossibili({NatalChart? carta, Zodiac? segno}) {
    var quanti = 0;
    for (final evento in EventiDelCielo.tutti) {
      if (statiContinui.contains(evento)) continue;
      if (!personali.contains(evento)) {
        quanti++;
        continue;
      }
      final haSegno = segno != null || carta?.sunSign != null;
      final chiedeLaCarta = evento == EventiDelCielo.ritornoSolare ||
          evento.startsWith('transito_') ||
          evento == EventiDelCielo.treTransitiInsieme;
      if (chiedeLaCarta ? carta != null : haSegno) quanti++;
    }
    return quanti;
  }
}
