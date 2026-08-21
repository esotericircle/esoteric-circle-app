import '../maestro/maestro.dart';
import 'daily_rituals.dart';

/// I cinque appuntamenti giornalieri del Cerchio, con l'ora della loro fascia e
/// il Maestro che ne porta il colore.
///
/// Il Rito dell'Alba e il Rito della Buonanotte non hanno un Maestro fisso
/// (ruotano di giorno in giorno) e il loro accento resta l'oro; gli altri tre
/// seguono il loro Maestro: Soffio del Destino verde di Aura, Oracolo del
/// Giorno blu di Medora, Runa del Tramonto rosso di Caligo.
///
/// L'ordine di dichiarazione e' anche l'ordine nella striscia: Alba, Soffio,
/// Oracolo, Tramonto, Notte.
enum DailyElement {
  dawn(
    cosaFai: 'Sollevi l\'alba con un gesto e ricevi la parola del giorno.',
    perche: 'Il primo minuto della giornata decide il tono di tutte le ore che vengono dopo.',
    cosaTiResta: 'Una parola da portare con te, che stasera il Rito del Sogno ti richiamerà.',
    title: 'Rito dell\'Alba',
    shortLabel: 'Alba',
    anchorHour: 7,
    anchorMinute: 0,
    guide: null,
    pushByDefault: true,
    description:
        'Apre la giornata con una parola guida e l\'energia dell\'alba, '
        'per orientare le tue prossime ore.',
  ),
  breath(
    cosaFai: 'Respiri col simbolo che si apre e si chiude, per i giri che il rito conta.',
    perche: 'Il respiro contato è il modo più rapido di cambiare stato senza '
        'chiedere niente a nessuno.',
    cosaTiResta: 'Il tuo destino del momento, con la tensione sciolta che '
        'resta nel corpo.',
    title: 'Soffio del Destino',
    shortLabel: 'Soffio',
    anchorHour: 10,
    anchorMinute: 30,
    guide: Maestro.aura,
    pushByDefault: false,
    description:
        'Un respiro guidato che allinea il tuo destino del momento e '
        'scioglie la tensione.',
  ),
  oracle(
    // **LE TRE RIGHE SEGUONO IL DONO NUOVO, ordine AS voce 08.** Dicevano "il
    // cielo di oggi si scopre" e "la riga del cielo di oggi", che erano vere
    // finche' il dono era una frase estratta da un elenco: adesso e' una carta
    // degli Arcani Maggiori, e un testo che nomina una cosa che non c'e' piu'
    // e' un testo che mente.
    cosaFai: 'Inclini il telefono oppure scorri col dito: la carta di oggi si scopre.',
    perche: 'A metà giornata la domanda che porti si è già fatta più precisa: è lì che un responso serve.',
    cosaTiResta: 'La carta del giorno con la sua risposta, più un Sigillo sul cammino se torni domani.',
    title: 'Arcano del Giorno',
    shortLabel: 'Arcano',
    anchorHour: 13,
    anchorMinute: 0,
    guide: Maestro.medora,
    pushByDefault: true,
    description:
        'Una carta degli Arcani Maggiori per la giornata, con la sua risposta.',
  ),
  rune(
    cosaFai: 'Estrai la runa della sera dal mazzo delle ventiquattro.',
    perche: 'Il tramonto è il momento in cui si sceglie cosa lasciare fuori dalla notte.',
    cosaTiResta: 'Una runa che il Rito del Sogno nominerà fra poche ore, con '
        'il suo presagio.',
    title: 'La Runa del Tramonto',
    shortLabel: 'Tramonto',
    anchorHour: 18,
    anchorMinute: 30,
    guide: Maestro.caligo,
    pushByDefault: false,
    description:
        'La runa della sera che raccoglie e custodisce quello che il giorno '
        'ti ha lasciato.',
  ),
  night(
    cosaFai: 'Soffi sulla nebbia, unisci la costellazione della Luna di stanotte e chiudi il giorno.',
    perche: 'Un giorno che non si chiude resta addosso: il rito della buonanotte gli mette un punto.',
    cosaTiResta: 'La tua costellazione della notte da condividere, col giorno raccolto in una carta.',
    title: 'Rito del Sogno',
    shortLabel: 'Notte',
    anchorHour: 22,
    anchorMinute: 30,
    guide: null,
    pushByDefault: true,
    description:
        'Uno sguardo al giorno appena concluso: la nebbia si dirada col fiato, '
        'emergono le stelle del cielo notturno reale, unisci la costellazione '
        'del segno in cui si trova la Luna adesso, poi il saluto della notte '
        'con la sua carta. Ripiego tattile sempre presente.',
  );

  const DailyElement({
    required this.cosaFai,
    required this.perche,
    required this.cosaTiResta,
    required this.title,
    required this.shortLabel,
    required this.anchorHour,
    required this.anchorMinute,
    required this.guide,
    required this.pushByDefault,
    required this.description,
  });

  /// COSA FAI, in una riga. Ordine P voce 17.
  ///
  /// Le tre righe stanno IN TESTA a ogni rito, prima del gesto: chi apre un
  /// rito deve sapere cosa sta per fare prima di farlo, non dopo.
  final String cosaFai;

  /// PERCHE'. Non la descrizione del rito: la ragione per cui vale il minuto
  /// che chiede.
  final String perche;

  /// COSA TI RESTA. **E' la terza, ed e' quella che oggi mancava ovunque.**
  ///
  /// Un dono che si esaurisce quando lo apri non produce ritorni; un dono che
  /// apre qualcosa che si chiude piu' tardi, si'. Questa riga e' l'unica delle
  /// tre che risponde alla domanda per cui la persona torna domani, e per
  /// questo nomina sempre qualcosa che resta o qualcuno che la richiamera'.
  final String cosaTiResta;

  final String title;
  final String shortLabel;
  final int anchorHour;
  final int anchorMinute;

  /// Il Maestro che presta il colore all'elemento. Null per i due riti che
  /// ruotano di giorno in giorno (Alba e Buonanotte), che restano oro.
  final Maestro? guide;

  /// Se di default questo elemento invia una notifica push. Unico punto di
  /// verita': di default solo Alba, Oracolo e Buonanotte notificano; Soffio e
  /// Tramonto restano disponibili in app, attivabili in futuro dall'utente.
  final bool pushByDefault;

  /// La spiegazione breve dell'elemento, cosa e' e a cosa serve, per il popup
  /// informativo della striscia.
  final String description;

  /// SE IL RITO GUIDA GIA' IL RESPIRO NELLA SUA SCENA.
  ///
  /// **Ordine P voce 17, e serve a non averne due.** Il respiro guidato e' uno
  /// solo in tutto il progetto, ma il Soffio del Destino lo monta nella scena,
  /// attorno al soffione, mentre l'Alba lo porta dentro la scheda del dono.
  /// Le due schermate condividono la scheda: senza questa riga il Soffio si
  /// ritrovava DUE anelli che respirano, uno sopra l'altro. Lo ha trovato una
  /// prova gia' esistente, che ne cercava uno e ne contava due.
  bool get guidaIlRespiroInScena => this == DailyElement.breath;

  int get anchorMinutes => anchorHour * 60 + anchorMinute;

  /// L'orario di apertura della fascia, nel formato h:mm (ad esempio 7:00,
  /// 10:30). Serve al riquadro orario nella striscia del giorno.
  String get clockLabel =>
      '$anchorHour:${anchorMinute.toString().padLeft(2, '0')}';

  /// L'id stabile per il deep-link da notifica push.
  String get id => name;

  static DailyElement? fromId(String? id) {
    for (final e in values) {
      if (e.name == id) return e;
    }
    return null;
  }
}

/// La selezione deterministica dell'elemento della fascia oraria attiva.
class DailyElements {
  const DailyElements._();

  /// L'elemento "corrente", scelto dalla fascia oraria attiva sull'ora locale.
  /// La fascia va da un'ancora alla successiva; la fascia dopo le 22:30 e prima
  /// delle 7:00 appartiene al Rito della Buonanotte, cosi' la notte fonda resta
  /// sua.
  static DailyElement current(DateTime now) {
    final minutes = now.hour * 60 + now.minute;
    if (minutes < DailyElement.dawn.anchorMinutes) return DailyElement.night;
    if (minutes < DailyElement.breath.anchorMinutes) return DailyElement.dawn;
    if (minutes < DailyElement.oracle.anchorMinutes) return DailyElement.breath;
    if (minutes < DailyElement.rune.anchorMinutes) return DailyElement.oracle;
    if (minutes < DailyElement.night.anchorMinutes) return DailyElement.rune;
    return DailyElement.night;
  }

  /// Il Maestro attivo di un elemento: per i riti che ruotano (Alba e
  /// Buonanotte) e' il Maestro di turno del giorno; per gli altri tre e' il
  /// loro Maestro fisso, Soffio ad Aura, Oracolo a Medora, Runa a Caligo.
  static Maestro maestroFor(DailyElement element, DateTime now) =>
      element.guide ?? DailyRituals.dawnMaestro(now);

  /// Gli elementi che di default inviano una notifica push: Rito dell'Alba,
  /// Arcano del Giorno e Rito della Buonanotte. Soffio del Destino e Runa del
  /// Tramonto restano disponibili in app senza push, attivabili in futuro.
  static List<DailyElement> get defaultPushElements =>
      DailyElement.values.where((e) => e.pushByDefault).toList(growable: false);
}
