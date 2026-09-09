import 'chakra_del_giorno.dart';

/// **LA LIBRERIA DEI RESPIRI.** Ordine DB voci 01 e 02, 9 settembre 2026.
///
/// **DA DOVE NASCE, e la ragione conta quanto la forma.** Il riferimento
/// indicato e' la Z-App di Zappkit, con circa millecinquecento sequenze di
/// frequenze Rife. **La struttura di prodotto si prende, il contenuto no**, e
/// la ragione e' documentata: quelle sequenze vengono dalla lista CAFL di
/// Electroherbalism, i cui stessi compilatori scrivono che le frequenze non
/// sono ben testate e che alcune possono essere mera speculazione. La terapia
/// Rife e' classificata come pseudomedicina.
///
/// **Questo e' prendere la forma e metterci sotto un fondamento vero.** E' la
/// lezione degli Angeli applicata prima invece che dopo.
///
/// **NESSUNA VOCE NOMINA UNA CONDIZIONE.** Ordine DB voce 01: *"se una pratica
/// ha bisogno di nominare una condizione per avere senso, quella pratica non
/// entra"*. Qui dentro non c'e' niente da curare: ci sono pratiche brevi, col
/// loro centro, la loro durata e la loro tradizione nominata.
///
/// **LA PORTA PRINCIPALE RESTA QUELLA DECISA**: la pratica di oggi la sceglie
/// Aura dal chakra del giorno. La libreria sta sotto, per chi vuole cercare.
abstract final class LibreriaDeiRespiri {
  /// **QUANTE PRATICHE ESISTONO IN TUTTO**, comprese quelle che arriveranno.
  ///
  /// Ordine DB voce 01: *"la libreria dichiara la propria ampiezza, come fa la
  /// Z-App con il numero in home: chi entra deve vedere che qui dentro c'e'
  /// piu' di quanto finira'"*.
  ///
  /// **E' un numero onesto e non un vanto**: dice quante ne sono previste, e
  /// il conto di quelle gia' pronte si legge da `pronte.length`. Dichiarare
  /// millecinquecento pratiche che non esistono sarebbe la stessa cosa che
  /// rende la Z-App inaffidabile.
  static const int previste = 36;

  /// Le pratiche pronte oggi.
  static const List<Respiro> pronte = [
    // --- I SETTE SUONI SEME, uno per centro ---
    Respiro(
      id: 'bija_lam',
      nome: 'Il suono della radice',
      centro: 0,
      durata: Duration(minutes: 5),
      cosaSiFa: 'Ripeti il suono LAM sul respiro che esce, senza forzare la '
          'voce. Il suono sta sotto, non sopra.',
      tradizione: Tradizione.suoniSeme,
    ),
    Respiro(
      id: 'bija_vam',
      nome: 'Il suono del sacro',
      centro: 1,
      durata: Duration(minutes: 5),
      cosaSiFa: 'Ripeti il suono VAM sul respiro che esce. Lascia che si '
          'appoggi al ventre.',
      tradizione: Tradizione.suoniSeme,
    ),
    Respiro(
      id: 'bija_ram',
      nome: 'Il suono del fuoco',
      centro: 2,
      durata: Duration(minutes: 5),
      cosaSiFa: 'Ripeti il suono RAM sul respiro che esce, con la stessa '
          'forza dall inizio alla fine.',
      tradizione: Tradizione.suoniSeme,
    ),
    Respiro(
      id: 'bija_yam',
      nome: 'Il suono del cuore',
      centro: 3,
      durata: Duration(minutes: 5),
      cosaSiFa: 'Ripeti il suono YAM sul respiro che esce, tenendo il petto '
          'aperto senza gonfiarlo.',
      tradizione: Tradizione.suoniSeme,
    ),
    Respiro(
      id: 'bija_ham',
      nome: 'Il suono della gola',
      centro: 4,
      durata: Duration(minutes: 5),
      cosaSiFa: 'Ripeti il suono HAM sul respiro che esce, lasciando la gola '
          'larga.',
      tradizione: Tradizione.suoniSeme,
    ),
    Respiro(
      id: 'bija_om',
      nome: 'Il suono del terzo occhio',
      centro: 5,
      durata: Duration(minutes: 5),
      cosaSiFa: 'Ripeti il suono OM sul respiro che esce. Ascolta dove '
          'risuona invece di dove esce.',
      tradizione: Tradizione.suoniSeme,
    ),
    Respiro(
      id: 'silenzio_corona',
      nome: 'Il silenzio della corona',
      centro: 6,
      durata: Duration(minutes: 5),
      cosaSiFa: 'Nessun suono. Segui il respiro e lascia che si faccia da '
          'solo, senza guidarlo.',
      tradizione: Tradizione.suoniSeme,
    ),

    // --- IL RESPIRO DI RISONANZA, il fondamento vero ---
    Respiro(
      id: 'risonanza_sei',
      nome: 'Sei respiri al minuto',
      centro: 3,
      durata: Duration(minutes: 7),
      cosaSiFa: 'Cinque secondi dentro e cinque fuori, seguendo il fiore. '
          'Se il tuo ritmo è un altro, tieni il tuo.',
      tradizione: Tradizione.risonanza,
    ),

    // --- LE FREQUENZE, dichiarate per quello che sono ---
    Respiro(
      id: 'solfeggio_giorno',
      nome: 'La frequenza del giorno',
      centro: -1,
      durata: Duration(minutes: 7),
      cosaSiFa: 'Ascolta il tono del centro di oggi e respira senza contare. '
          'Il tono accompagna, non guida.',
      tradizione: Tradizione.solfeggio,
    ),
    Respiro(
      id: 'binaurale_calma',
      nome: 'Due toni che si incontrano',
      centro: -1,
      durata: Duration(minutes: 10),
      cosaSiFa: 'Con le cuffie, due toni vicini formano una pulsazione. '
          'Seguila senza inseguirla.',
      tradizione: Tradizione.binaurali,
    ),
  ];

  /// Le pratiche di un centro, piu' quelle che valgono per tutti.
  static List<Respiro> perCentro(int centro) => [
        for (final r in pronte)
          if (r.centro == centro || r.centro < 0) r,
      ];

  /// La pratica che Aura sceglie per [giorno]: quella del centro acceso.
  static Respiro diOggi(DateTime giorno) {
    final centro = (giorno.weekday - 1) % ChakraDelGiorno.tutti.length;
    final sue = perCentro(centro);
    return sue.isEmpty ? pronte.first : sue.first;
  }
}

/// Una pratica della libreria.
class Respiro {
  const Respiro({
    required this.id,
    required this.nome,
    required this.centro,
    required this.durata,
    required this.cosaSiFa,
    required this.tradizione,
  });

  final String id;
  final String nome;

  /// L'indice del centro, oppure meno uno per le pratiche che valgono per
  /// tutti i centri.
  final int centro;

  /// **LA DURATA DICHIARATA**, ordine DB voce 01: chi entra sa quanto dura
  /// prima di cominciare, non dopo.
  final Duration durata;

  /// Cosa si fa, in due righe. **Nessuna condizione nominata**, nessun
  /// effetto promesso: si dice il gesto.
  final String cosaSiFa;

  final Tradizione tradizione;

  String get quantoDura => '${durata.inMinutes} minuti';
}

/// **LE TRADIZIONI, CON LA LORO FONTE E IL LORO PESO.** Ordine DB voce 02.
///
/// **La formula e' quella che l'ordine detta**: questa e' la tradizione,
/// questo e' cio' che riferisce chi la pratica, questo non e' un effetto
/// clinico dimostrato. **Nessun tooltip confessa mancanze e nessuno promette
/// effetti.**
enum Tradizione {
  /// **I SUONI SEME, e hanno una fonte primaria vera.** Ordine DB voce 02: si
  /// cita il Sat-Cakra-Nirupana di Purnananda, 1577, arrivato in Occidente con
  /// la traduzione di John Woodroffe, *The Serpent Power*, 1919.
  suoniSeme(
    nome: 'Suoni seme',
    fonte: 'Purnananda, Sat-Cakra-Nirupana, 1577, nella traduzione di John '
        'Woodroffe, The Serpent Power, 1919.',
    comeSiDice: 'La tradizione tantrica associa a ogni centro una sillaba. '
        'Chi la pratica riferisce che il suono aiuta a tenere l attenzione '
        'ferma su una zona del respiro.',
  ),

  /// **IL RESPIRO DI RISONANZA, l'unico con letteratura scientifica seria.**
  /// Ordine DB voce 03.
  risonanza(
    nome: 'Respiro di risonanza',
    fonte: 'Paul Lehrer e Richard Gevirtz, 2014, per la rassegna sul '
        'biofeedback della variabilità cardiaca: la respirazione attorno a '
        'sei atti al minuto, cioè 0,1 hertz, è la frequenza di risonanza del '
        'sistema cardiovascolare umano.',
    comeSiDice: 'È la sola pratica di questa libreria con letteratura peer '
        'reviewed alle spalle. Gli studi misurano variazioni della '
        'variabilità cardiaca. Gli effetti riferiti su umore e calma sono '
        'reali ma modesti.',
  ),

  /// **IL SOLFEGGIO, DETTO PER QUELLO CHE E'.** Ordine DB voce 02: *"non sono
  /// antiche: nascono nel 1998... e l'attribuzione a Guido d'Arezzo non regge
  /// a verifica documentale. Restano utilizzabili, ma dichiarate come
  /// convenzione contemporanea diffusa, mai come tradizione millenaria."*
  solfeggio(
    nome: 'Frequenze del solfeggio',
    fonte: 'Joseph Puleo e Leonard Horowitz, Healing Codes for the Biological '
        'Apocalypse, 1999. L attribuzione a Guido d Arezzo, monaco dell XI '
        'secolo, non trova riscontro nei documenti.',
    comeSiDice: 'È una convenzione contemporanea diffusa e non una '
        'tradizione di secoli. Chi la pratica riferisce che avere un tono '
        'fisso rende più facile restare fermi.',
  ),

  /// **I BATTITI BINAURALI, con letteratura reale e risultati modesti.**
  binaurali(
    nome: 'Battiti binaurali',
    fonte: 'Heinrich Wilhelm Dove, 1839, per la descrizione del fenomeno; '
        'revisioni sistematiche recenti per gli effetti riferiti.',
    comeSiDice: 'Il fenomeno acustico è documentato dal 1839. Gli studi sugli '
        'effetti riferiti danno risultati misurati ma modesti e non '
        'concordi fra loro.',
  );

  const Tradizione({
    required this.nome,
    required this.fonte,
    required this.comeSiDice,
  });

  final String nome;

  /// **AUTORE E ANNO**, ordine DB voce 02: ogni pratica porta la sua fonte,
  /// consultabile dal tooltip.
  final String fonte;

  /// Cosa riferisce chi la pratica, **senza promettere un effetto clinico**.
  final String comeSiDice;
}
