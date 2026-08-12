import '../astro/night_sky.dart';
import '../astro/natal_chart.dart';
import '../astro/zodiac.dart';
import '../horoscope/cielo_di_oggi.dart';
import '../horoscope/corrente_del_cielo.dart';
import '../identity/birth_identity.dart';
import '../maestro/maestro.dart';
import 'daily_rituals.dart';
import 'rito_alba.dart';

/// Il tipo di dono del Rito dell'Alba cambia col Maestro di turno.
///
/// Medora orienta con il cielo del giorno, Aura offre un'intenzione energetica,
/// Caligo lascia un monito o un simbolo. E' struttura, non contenuto: l'etichetta
/// rende esplicito il tipo di dono, senza affermare nulla di astrologico.
enum DawnGiftKind {
  orientamento('Orientamento del giorno'),
  intenzione('Intenzione del giorno'),
  monito('Monito del giorno');

  const DawnGiftKind(this.label);

  final String label;
}

/// La base di un dono: da dove nasce, la sua fondazione sulla carta dell'utente.
///
/// Regola non negoziabile: un dono non puo' esistere senza la sua base. Per
/// questo [DawnGift] la richiede come campo obbligatorio.
///
/// **QUESTA INTESTAZIONE DICEVA IL FALSO, e il codice sotto le credeva.**
/// C'era scritto che non esiste ancora un motore a effemeridi con i transiti
/// planetari reali. Esiste dal 5 agosto 2026, e' lo stesso che compone
/// l'Oroscopo, e da quel giorno il campo del transito lo riempie lui: vedi
/// [DawnGift.transitoDiOggi].
///
/// Restano due cose vuote, e per due ragioni diverse. Il transito e' nullo
/// quando la persona non ha dato ora e luogo di nascita, perche' senza carta
/// non ci sono transiti da leggere. La fonte nella tradizione e' nulla sempre,
/// perche' per i nove riti dell'Alba non esiste oggi una fonte verificata da
/// citare. In tutti e due i casi LA RIGA SPARISCE, e non si riempie con una
/// frase che dice di aspettare: mostrare l'impalcatura e' peggio che mostrare
/// meno.
class GiftSource {
  const GiftSource({
    required this.natalSunSign,
    required this.transit,
    required this.tradition,
    required this.provisional,
  });

  /// Segno solare natale dell'utente, dato reale dalla data di nascita. Null se
  /// il profilo non porta ancora un'identita' di nascita.
  final Zodiac? natalSunSign;

  /// Quale transito e' attivo oggi sulla carta dell'utente, composto dal
  /// motore vero. Nullo quando la carta non c'e', e allora la riga sparisce.
  final String? transit;

  /// LA FONTE REALE DELLA PRATICA, oppure nulla.
  ///
  /// **Regola di trasparenza metodologica, e qui morde davvero.** Un rito di
  /// questa app poggia su una tradizione documentata oppure dichiara di non
  /// poggiare su niente: non esiste la terza via di una frase generica che
  /// suoni antica. I nove riti dell'Alba sono composti dal progetto, gesto per
  /// gesto, e per nessuno di loro esiste oggi una fonte verificata da citare.
  ///
  /// Quindi questo campo resta nullo, E LA RIGA SPARISCE. Il giorno in cui una
  /// fonte arrivera', entrera' in `FormaDelRito.fonte` e da li' fin qui.
  /// Riempirlo con "In attesa dei contenuti astrologici verificati" era
  /// mostrare alla persona l'impalcatura dell'app.
  final String? tradition;

  /// Vero finche' la base non e' fondata su contenuti verificati.
  final bool provisional;

  /// L'ancora natale in chiaro, dato reale. Frase neutra se il segno non c'e'.
  String get natalDescription => natalSunSign == null
      ? 'Segno solare non ancora noto'
      : 'Il tuo Sole in ${natalSunSign!.italianName}';
}

/// Il dono del giorno del Rito dell'Alba, in forma strutturata e fondata.
///
/// La UI ne porge tre livelli: l'orientamento del giorno, la parola del giorno e
/// la base apribile che spiega da dove nasce. Nessun contenuto astrologico e'
/// generato qui: [orientation] e [word] restano provvisori e chiaramente marcati
/// finche' non arriva il file di contenuti verificati. Il modello resta gia'
/// collegato alla carta natale dell'utente tramite [source].
class DawnGift {
  const DawnGift({
    required this.maestro,
    required this.kind,
    required this.source,
    required this.orientation,
    required this.word,
    required this.provisional,
    this.rito,
  });

  /// IL RITO DI OGGI, in forma strutturata: gesto, respiro contato, parola.
  ///
  /// Null solo se nessuna variante era compatibile col cielo disponibile, che
  /// e' una cintura e non un caso atteso. Chi mostra il dono puo' usare
  /// [orientation] per il testo gia' composto, oppure questo per disporre i tre
  /// momenti a modo suo.
  final RitoDiOggi? rito;

  /// Il Maestro di turno che porge il dono.
  final Maestro maestro;

  /// Il tipo di dono, coerente col Maestro.
  final DawnGiftKind kind;

  /// La base del dono. Obbligatoria: nessun dono senza la sua fondazione.
  final GiftSource source;

  /// L'orientamento del giorno. Provvisorio finche' non arriva il contenuto
  /// verificato: mai una frase astrologica inventata.
  final String orientation;

  /// La parola del giorno, breve, da mettere in risalto. Null finche' non
  /// arriva dai contenuti verificati.
  final String? word;

  /// Vero finche' il dono non e' fondato su contenuti verificati.
  final bool provisional;

  /// Costruisce il dono di [date] a partire dalla carta natale dell'utente.
  ///
  /// Collega il modello alla carta natale tramite il segno solare natale, dato
  /// reale. Non essendoci un motore di transiti reali nel repo, la base resta
  /// provvisoria e i testi restano segnaposto marcati: il contenuto verificato
  /// li sostituira' senza cambiare questa forma.
  /// [posizione] è dove la persona si trova STAMATTINA, non dove è nata: serve
  /// solo all'ora del sorgere. Si ottiene da `SkyLocation.resolveSeConcesso()`,
  /// quindi senza aprire nessuna richiesta di permesso.
  static DawnGift forChart(DateTime date,
          {BirthIdentity? identity,
          PosizioneDiStamattina? posizione,
          NatalChart? carta}) =>
      forMaestro(date, DailyRituals.dawnMaestro(date),
          identity: identity, posizione: posizione, carta: carta);

  /// Come [forChart] ma per un Maestro dato, non quello a rotazione. Serve ai
  /// riti legati a un solo Maestro, come il Soffio del Destino di Aura.
  static DawnGift forMaestro(DateTime date, Maestro maestro,
      {BirthIdentity? identity,
      PosizioneDiStamattina? posizione,
      NatalChart? carta}) {
    final natalSun =
        identity == null ? null : NightSky.sunSign(identity.birthMoment);

    // IL RITO VERO, che ha preso il posto del segnaposto.
    //
    // **Il luogo di NASCITA non entra qui.** Un'alba è dove sei stamattina: chi
    // è nato a Sydney e vive a Milano vede sorgere il sole a Milano. Prima
    // questa riga leggeva `identity.birthPlace`, e per chi si era spostato
    // l'ora del sorgere era sbagliata di ore. L'identità resta, ma serve solo
    // al segno solare natale.
    //
    // Il cielo si LEGGE da lib/core/astro, non si ricalcola qui.
    final rito = RitoAlba.diOggi(date, posizione: posizione);

    return DawnGift(
      maestro: maestro,
      kind: _kindFor(maestro),
      source: GiftSource(
        natalSunSign: natalSun,
        transit: transitoDiOggi(date, carta),
        tradition: null,
        provisional: true,
      ),
      orientation: rito == null
          ? provisionalOrientation
          // IL RESPIRO NON STA PIU' NEL TESTO, ordine P voce 17: e' un
          // respiro guidato a schermo, con la figura che si espande e si
          // contrae. Una istruzione criptica scritta e' un compito, un respiro
          // guidato e' un'esperienza. I suoi numeri restano in `rito.tempi` e
          // `rito.giri`, che sono cio' con cui il simbolo si muove.
          : '${rito.gesto}\n\n'
              'Se ti è più comodo: ${rito.viaTattile}',
      word: rito?.parola,
      rito: rito,
      // Il dono non e' piu' provvisorio quando il rito c'e': il contenuto
      // esiste, ed e' diverso ogni giorno.
      provisional: rito == null,
    );
  }

  /// IL TRANSITO ATTIVO OGGI, dal motore vero e da nessun'altra parte.
  ///
  /// **Cosa c'era prima.** Questo campo nasceva `null` cablato, e la scheda ci
  /// metteva sopra la frase "In attesa dei contenuti astrologici verificati":
  /// un'app che mostra alla persona la propria impalcatura. Il commento
  /// diceva "qui non si inventa nulla", ed era una cautela giusta con una
  /// conclusione sbagliata, perche' il motore per non inventare c'era gia'.
  ///
  /// **E' LA STESSA PORTA DELL'OROSCOPO.** `CieloDiOggi.perIlGiorno` piu'
  /// `CorrenteDelCielo.frase`: le stesse due funzioni che compongono la
  /// corrente del giorno nelle quattro schede. Non se ne scrive una seconda,
  /// altrimenti il Rito e l'Oroscopo potrebbero dire due cose diverse dello
  /// stesso cielo nella stessa mattina.
  ///
  /// **Nullo quando la carta non c'e', e allora la riga sparisce.** Senza ora
  /// e luogo di nascita non ci sono transiti sulla carta, e una riga che dice
  /// di aspettare qualcosa e' peggio di nessuna riga.
  static String? transitoDiOggi(DateTime date, NatalChart? carta) {
    final cielo = CieloDiOggi.perIlGiorno(adesso: date, carta: carta);
    if (!cielo.ceCieloVero) return null;
    // IL PIU' STRETTO, che e' quello che oggi pesa di piu': la lista arriva
    // gia' ordinata per orbo crescente, e qui ne serve UNO, non tre.
    return CorrenteDelCielo.frase(cielo.voci.first);
  }

  /// Testo dell'orientamento quando il contenuto verificato non c'e' ancora.
  /// Chiaro sul fatto che e' provvisorio, senza fingere una lettura del cielo.
  static const String provisionalOrientation =
      'L\'orientamento del giorno arriverà dai contenuti astrologici '
      'verificati, fondato sui transiti reali della tua carta. Qui non si '
      'inventa nulla.';

  static DawnGiftKind _kindFor(Maestro maestro) => switch (maestro) {
        Maestro.medora => DawnGiftKind.orientamento,
        Maestro.aura => DawnGiftKind.intenzione,
        Maestro.caligo => DawnGiftKind.monito,
      };
}
