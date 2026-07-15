import '../astro/night_sky.dart';
import '../astro/zodiac.dart';
import '../identity/birth_identity.dart';
import '../maestro/maestro.dart';
import 'daily_rituals.dart';

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
/// L'unico dato reale e deterministico disponibile oggi nel repo e' il segno
/// solare natale, calcolato dalla data di nascita. Non esiste ancora un motore
/// a effemeridi con i transiti planetari reali: percio' quale transito sia
/// attivo oggi, e cosa significhi nella tradizione, restano vuoti e marcati come
/// provvisori. Non si inventano ne posizioni planetarie ne interpretazioni: il
/// contenuto reale arrivera' da un file di contenuti verificati.
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

  /// Quale transito e' attivo oggi sulla carta dell'utente. Null finche' non
  /// arriva dal file di contenuti verificati: qui non si inventa nulla.
  final String? transit;

  /// Cosa significa nella tradizione. Null finche' non arriva dai contenuti
  /// verificati.
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
  });

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
  static DawnGift forChart(DateTime date, {BirthIdentity? identity}) {
    final maestro = DailyRituals.dawnMaestro(date);
    final natalSun =
        identity == null ? null : NightSky.sunSign(identity.birthMoment);
    return DawnGift(
      maestro: maestro,
      kind: _kindFor(maestro),
      source: GiftSource(
        natalSunSign: natalSun,
        transit: null,
        tradition: null,
        provisional: true,
      ),
      orientation: provisionalOrientation,
      word: null,
      provisional: true,
    );
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
