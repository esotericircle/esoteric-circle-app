import '../maestro/maestro.dart';
import 'daily_rituals.dart';

/// Gli appuntamenti giornalieri del Cerchio, con l'ora della loro fascia e il
/// Maestro che ne porta il colore.
///
/// **DA CINQUE A QUATTRO, ordine DT voce 01**, 17 settembre 2026: il Rito
/// dell'Alba e l'Arcano del Giorno non sono piu' doni autonomi, e al loro
/// posto c'e' l'Arcano dell'Alba. **Ogni dono ha adesso il suo Maestro**:
/// l'Arcano dell'Alba e il Sigillo del Sogno a Medora, il Soffio del Destino ad
/// Aura, la Runa del Tramonto a Caligo.
///
/// **L'ordine di dichiarazione e' l'ordine della giornata**, e nessun conto
/// dell'app lo scrive a mano: chi conta i doni conta `values`, e la fascia
/// corrente si ricava dalle ancore. Un dono nuovo si aggiunge qui e basta
/// (voce 17).
///
/// **La voce `dawn` e' l'Arcano dell'Alba**, e non ha cambiato nome: le
/// preferenze, gli avvisi e le serie gia' salvate col nome `dawn` restano di
/// chi le aveva.
enum DailyElement {
  dawn(
    cosaFai:
        'Scegli una carta fra quelle coperte e la giri: è l\'arcano che apre la tua giornata.',
    perche:
        'Il primo minuto della giornata decide il tono di tutte le ore che vengono dopo.',
    cosaTiResta:
        'Il dono della carta, un respiro, un\'azione o una parola, che stasera il Sigillo del Sogno ti richiamerà.',
    title: 'Arcano dell\'Alba',
    conArticolo: 'l\'Arcano dell\'Alba',
    shortLabel: 'Alba',
    anchorHour: 7,
    anchorMinute: 0,
    guide: Maestro.medora,
    pushByDefault: true,
    numeroDellAvviso: 0,
    description:
        'Un arcano maggiore scelto al mattino fra le carte coperte, col suo dono '
        'per la giornata.',
  ),
  breath(
    cosaFai:
        'Respiri col simbolo che si apre e si chiude, per i giri che il rito conta.',
    perche: 'Il respiro contato è il modo più rapido di cambiare stato senza '
        'chiedere niente a nessuno.',
    cosaTiResta: 'Il tuo destino del momento, con la tensione sciolta che '
        'resta nel corpo.',
    title: 'Soffio del Destino',
    conArticolo: 'il Soffio del Destino',
    shortLabel: 'Soffio',
    // **ALLE TREDICI, ordine DT voce 14.** Era alle 10:30; le tredici erano
    // l'ora dell'Arcano del Giorno, che se n'e' andato.
    anchorHour: 13,
    anchorMinute: 0,
    guide: Maestro.aura,
    pushByDefault: false,
    numeroDellAvviso: 1,
    description: 'Un respiro guidato che allinea il tuo destino del momento e '
        'scioglie la tensione.',
  ),
  rune(
    cosaFai: 'Estrai la runa della sera dal mazzo delle ventiquattro.',
    perche:
        'Il tramonto è il momento in cui si sceglie cosa lasciare fuori dalla notte.',
    cosaTiResta:
        'Una runa che il Sigillo del Sogno nominerà fra poche ore, con '
        'il suo presagio.',
    title: 'La Runa del Tramonto',
    conArticolo: 'la Runa del Tramonto',
    shortLabel: 'Tramonto',
    anchorHour: 18,
    anchorMinute: 30,
    guide: Maestro.caligo,
    pushByDefault: false,
    numeroDellAvviso: 3,
    description:
        'La runa della sera che raccoglie e custodisce quello che il giorno '
        'ti ha lasciato.',
  ),
  night(
    cosaFai:
        'Soffi sulla nebbia, unisci la costellazione della Luna di stanotte e chiudi il giorno.',
    perche:
        'Un giorno che non si chiude resta addosso: il rito della buonanotte gli mette un punto.',
    cosaTiResta:
        'La tua costellazione della notte da condividere, col giorno raccolto in una carta.',
    title: 'Sigillo del Sogno',
    conArticolo: 'il Sigillo del Sogno',
    shortLabel: 'Notte',
    anchorHour: 22,
    anchorMinute: 30,
    // **A MEDORA, ordine DT voce 15.** Non ruota piu' fra i tre Maestri.
    guide: Maestro.medora,
    pushByDefault: true,
    numeroDellAvviso: 4,
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
    required this.conArticolo,
    required this.shortLabel,
    required this.anchorHour,
    required this.anchorMinute,
    required this.guide,
    required this.pushByDefault,
    required this.numeroDellAvviso,
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

  /// Il nome dentro una frase, col suo articolo: *"il Soffio del Destino"*.
  /// Serve agli elenchi che si compongono dai doni invece di scriverli.
  final String conArticolo;

  final String shortLabel;
  final int anchorHour;
  final int anchorMinute;

  /// Il Maestro che presta il colore all'elemento. **Dall'ordine DT tutti i
  /// doni ne hanno uno**; resta annullabile perche' un dono futuro senza
  /// Maestro fisso possa ancora esistere, e in quel caso ruota col giorno.
  final Maestro? guide;

  /// Se di default questo elemento invia una notifica push. Unico punto di
  /// verita': di default l'Arcano dell'Alba e il Sigillo del Sogno notificano;
  /// Soffio e Tramonto restano disponibili, attivabili dall'utente.
  final bool pushByDefault;

  /// **IL NUMERO FISSO DELL'AVVISO DI QUESTO DONO**, ordine DT voce 17.
  ///
  /// L'id dell'avviso si ricavava dalla posizione nell'elenco: togliere un dono
  /// spostava l'id di quelli dopo, e un avviso gia' in coda sul telefono
  /// restava orfano col numero vecchio. **Il numero e' del dono, non del
  /// posto**: il 2 era dell'Arcano del Giorno e non si riusa.
  final int numeroDellAvviso;

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

  /// **IL TITOLO SOPRA LE TRE RIGHE DEL RITO.**
  /// Ordine CO voce 15, 3 settembre 2026.
  ///
  /// Il fondatore ha chiesto "IL RITO DI STAMATTINA" sopra il paragrafo del
  /// rito, perche' quelle tre righe cominciavano senza dire di cosa
  /// parlassero: chi leggeva "Cosa fai" trovava un'istruzione senza sapere a
  /// che cosa appartenesse.
  ///
  /// **Le parole seguono l'ora del rito e non il suo nome**, ed e' la ragione
  /// per cui questo getter sta qui invece che nel testo della scheda. Le tre
  /// righe vivono nel design system e le montano tutti i riti: un
  /// titolo scritto dentro la scheda dell'Alba direbbe "stamattina" anche
  /// sotto il Sigillo del Sogno, che apre alle ventidue. L'ora ce l'hanno gia'
  /// tutti, e da lei si ricava la parola giusta senza aggiungere un dato che
  /// qualcuno domani dimenticherebbe di riempire.
  String get titoloDelRito => switch (anchorHour) {
        < 12 => 'IL RITO DI STAMATTINA',
        < 18 => 'IL RITO DI OGGI',
        < 22 => 'IL RITO DI STASERA',
        _ => 'IL RITO DI STANOTTE',
      };

  /// L'orario di apertura della fascia, nel formato h:mm (ad esempio 7:00,
  /// 13:00). Serve al riquadro orario nella striscia del giorno.
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
  /// La fascia va da un'ancora alla successiva; prima della prima ancora del
  /// giorno la fascia e' ancora dell'ultimo dono della sera, cosi' la notte
  /// fonda resta del Sigillo del Sogno.
  ///
  /// **Si legge dalle ancore, non da una catena scritta a mano** (ordine DT
  /// voce 17): la catena nominava i cinque doni uno per uno, e togliendone uno
  /// non compilava piu'; aggiungendone uno lo avrebbe ignorato in silenzio.
  static DailyElement current(DateTime now) {
    final minutes = now.hour * 60 + now.minute;
    final perOra = [...DailyElement.values]
      ..sort((a, b) => a.anchorMinutes.compareTo(b.anchorMinutes));
    var corrente = perOra.last;
    for (final e in perOra) {
      if (e.anchorMinutes <= minutes) corrente = e;
    }
    return corrente;
  }

  /// Il Maestro attivo di un elemento: il suo Maestro fisso, e per un dono
  /// senza Maestro fisso il Maestro di turno del giorno.
  static Maestro maestroFor(DailyElement element, DateTime now) =>
      element.guide ?? DailyRituals.dawnMaestro(now);

  /// Gli elementi che di default inviano una notifica push: l'Arcano
  /// dell'Alba e il Sigillo del Sogno. Soffio del Destino e Runa del Tramonto
  /// restano disponibili senza push, attivabili dall'utente.
  /// **I DONI IN UNA FRASE**, dal primo all'ultimo: *"l'Arcano dell'Alba, il
  /// Soffio del Destino, la Runa del Tramonto e il Sigillo del Sogno"*. Ordine
  /// DT voce 17: gli elenchi a video si compongono da qui, e un dono nuovo ci
  /// entra da solo.
  static String get elencoInFrase {
    final nomi = DailyElement.values.map((e) => e.conArticolo).toList();
    if (nomi.length == 1) return nomi.single;
    return '${nomi.sublist(0, nomi.length - 1).join(', ')} e ${nomi.last}';
  }

  /// Quanti sono i doni, in lettere: *"quattro"*.
  static String get quantiInLettere => const [
        'zero', 'uno', 'due', 'tre', 'quattro', 'cinque', 'sei', 'sette', //
        'otto', 'nove', 'dieci',
      ][DailyElement.values.length.clamp(0, 10)];

  static List<DailyElement> get defaultPushElements =>
      DailyElement.values.where((e) => e.pushByDefault).toList(growable: false);
}
