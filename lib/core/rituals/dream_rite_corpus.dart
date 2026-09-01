import '../astro/night_sky.dart';
import '../astro/zodiac.dart';
import '../identity/birth_moon.dart';
import '../maestro/maestro.dart';
import 'daily_rituals.dart';
import 'relazione_lunare.dart';

/// La voce del Sigillo del Sogno per un segno della Luna: una parola calmante e le
/// righe che guardano al giorno appena concluso.
///
/// Non e' tradizione nuova: ogni voce riscrive in chiave riflessiva il
/// significato del segno lunare gia' nel repo (`BirthMoon.meaningFor`, il
/// sentire nel segno, nella voce di Medora). Il rito guarda al passato e al
/// presente della giornata, mai al futuro.
class VoceDelSogno {
  const VoceDelSogno({
    required this.parola,
    required this.immagine,
    required this.giorno,
    required this.riconoscimento,
    required this.posa,
  });

  /// Una parola sola, calmante, per la carta della notte.
  final String parola;

  /// L'immagine del segno, in poche parole.
  final String immagine;

  /// Cosa hai fatto oggi, al passato.
  final String giorno;

  /// Cosa ti riconosci, guardando indietro.
  final String riconoscimento;

  /// L'invito al presente, per posare il giorno.
  final String posa;
}

/// Il Sigillo del Sogno, ex Rito della Buonanotte: il messaggio della notte, la
/// parola e la trasparenza, tutti deterministici dal cielo reale di adesso.
///
/// La Luna arriva da `NightSky.moonSign` per il segno e da `MoonPhase.forDate`
/// per la fase, tramite `BirthMoon.forDate`. Nessuna AI a runtime.
class DreamRiteCorpus {
  const DreamRiteCorpus._();

  static const Map<Zodiac, VoceDelSogno> _voci = {
    Zodiac.aries: VoceDelSogno(
      parola: 'Calma',
      immagine: 'il fuoco che parte per primo',
      giorno: 'hai acceso in fretta, forse più di una volta',
      riconoscimento: 'hai avuto coraggio quando serviva',
      posa:
          "lascia che la scintilla si abbassi, la notte non chiede slancio, chiede riposo",
    ),
    Zodiac.taurus: VoceDelSogno(
      parola: 'Radice',
      immagine: 'la terra che tiene',
      giorno: 'hai retto il peso senza fare rumore',
      riconoscimento: 'hai dato stabilità a chi ti sta intorno',
      posa: 'posa il carico, la notte non chiede solidità, chiede riposo',
    ),
    Zodiac.gemini: VoceDelSogno(
      parola: 'Silenzio',
      immagine: 'le due voci che si rincorrono',
      giorno: 'hai parlato molto, hai ascoltato altrettanto',
      riconoscimento: 'hai tenuto vivi i fili con gli altri',
      posa:
          'lascia posare le parole, la notte non chiede risposte, chiede riposo',
    ),
    Zodiac.cancer: VoceDelSogno(
      parola: 'Rifugio',
      immagine: 'la conchiglia che custodisce',
      giorno: 'hai protetto qualcuno, forse senza dirlo',
      riconoscimento: 'hai fatto sentire qualcuno a casa',
      posa: 'chiudi il guscio, la notte non chiede cura, chiede riposo',
    ),
    Zodiac.leo: VoceDelSogno(
      parola: 'Calore',
      immagine: 'il sole che scalda gli altri',
      giorno: 'hai dato luce, ti sei speso',
      riconoscimento: 'hai illuminato una stanza senza accorgertene',
      posa: 'abbassa la fiamma, la notte non chiede di brillare, chiede riposo',
    ),
    Zodiac.virgo: VoceDelSogno(
      parola: 'Ordine',
      immagine: 'le mani che mettono a posto',
      giorno: 'hai curato i dettagli, uno dopo l\'altro',
      riconoscimento: 'hai reso semplice qualcosa di complicato',
      posa:
          'lascia il resto per domani, la notte non chiede precisione, chiede riposo',
    ),
    Zodiac.libra: VoceDelSogno(
      parola: 'Equilibrio',
      immagine: 'la bilancia che pesa',
      giorno: 'hai misurato molto, chi accontentare e cosa lasciare andare',
      riconoscimento: 'hai tenuto insieme più di quanto credi',
      posa: 'posa i piatti, la notte non chiede equilibrio, chiede riposo',
    ),
    Zodiac.scorpio: VoceDelSogno(
      parola: 'Profondità',
      immagine: "l'acqua che scava",
      giorno: 'hai sentito tutto fino in fondo',
      riconoscimento: 'hai guardato una verità senza voltarti',
      posa:
          'lascia scendere il fondo, la notte non chiede intensità, chiede riposo',
    ),
    Zodiac.sagittarius: VoceDelSogno(
      parola: 'Sosta',
      immagine: 'la freccia che cerca lontano',
      giorno: 'hai guardato avanti, forse troppo avanti',
      riconoscimento: 'hai tenuto viva la fiducia',
      posa: "abbassa l'arco, la notte non chiede orizzonti, chiede riposo",
    ),
    Zodiac.capricorn: VoceDelSogno(
      parola: 'Tregua',
      immagine: 'la roccia che sale piano',
      giorno: 'hai portato responsabilità che nessuno ha visto',
      riconoscimento: 'hai retto quello che dovevi reggere',
      posa:
          'lascia la salita a domani, la notte non chiede disciplina, chiede riposo',
    ),
    Zodiac.aquarius: VoceDelSogno(
      parola: 'Respiro',
      immagine: "l'aria che non si lascia stringere",
      giorno: 'hai pensato in largo, per tutti',
      riconoscimento: 'hai tenuto uno sguardo libero',
      posa:
          'lascia andare il pensiero, la notte non chiede visione, chiede riposo',
    ),
    Zodiac.pisces: VoceDelSogno(
      parola: 'Sogno',
      immagine: "l'acqua che confonde i bordi",
      giorno: 'hai assorbito molto, anche ciò che non era tuo',
      riconoscimento: 'hai avuto compassione, anche quando costava',
      posa:
          'lascia sciogliere i confini, la notte non chiede empatia, chiede riposo',
    ),
  };

  /// La voce del segno lunare. C'e' sempre, per tutti e dodici.
  static VoceDelSogno voce(Zodiac sign) => _voci[sign]!;

  /// La parola sola della notte, per la carta.
  static String parola(Zodiac sign) => _voci[sign]!.parola;

  /// La Luna reale di adesso: segno da `NightSky.moonSign`, fase da `MoonPhase`.
  static BirthMoon lunaDi(DateTime quando) => BirthMoon.forDate(quando);

  /// L'apertura sulla Luna, dalla sua fase reale.
  static String aperturaLuna(BirthMoon luna) {
    final segno = luna.sign.italianName;
    switch (luna.phase.italianName) {
      case 'Luna piena':
        return 'Stanotte la Luna è piena in $segno';
      case 'Luna nuova':
        return 'Stanotte la Luna è nuova in $segno';
      default:
        return luna.phase.waxing
            ? 'Stanotte la Luna cresce in $segno'
            : 'Stanotte la Luna cala in $segno';
    }
  }

  /// L'attacco nella voce del Maestro di turno, che apre lo sguardo indietro.
  static String aperturaMaestro(Maestro maestro) {
    switch (maestro) {
      case Maestro.medora:
        return 'Il cielo ha girato una carta sola, oggi.';
      case Maestro.aura:
        return 'Il corpo ha portato il giorno fin qui.';
      case Maestro.caligo:
        return 'Il giorno ha lasciato la sua ombra lunga.';
    }
  }

  /// L'invito nella nebbia, all'apertura del rito, nella voce del Maestro.
  static String invitoNebbia(Maestro maestro) =>
      'Hai vissuto un giorno intero. Prima di lasciarlo andare, dirada la '
      'nebbia e guarda il cielo che ti sta sopra.';

  /// Il saluto della notte: guarda al passato e al presente della giornata
  /// conclusa, mai al futuro. Deterministico da Maestro di turno, segno e fase.
  /// Il saluto della notte, per chi e' nato il [nascita].
  ///
  /// **DAL 30 AGOSTO 2026 NON E' PIU' LA STESSA NOTTE PER TUTTI.** Ordine CE
  /// voce 13: il quarto fumetto del tutorial promette che i cinque Doni
  /// nascono "incrociando il Cielo di oggi e la tua Carta natale", e questo
  /// Dono, misurato, guardava soltanto la Luna di stanotte. Adesso entra anche
  /// la LUNA DI NASCITA, e il rapporto fra le due si legge come lo legge
  /// l'astrologia occidentale: dall'angolo che le separa.
  ///
  /// **Chi non ha dato la nascita non perde il Dono**: senza data il saluto e'
  /// esattamente quello di prima.
  static String saluto(DateTime quando, {DateTime? nascita}) {
    final maestro = DailyRituals.nightMaestro(quando);
    final luna = lunaDi(quando);
    final v = voce(luna.sign);
    final base = '${aperturaMaestro(maestro)} ${aperturaLuna(luna)}, '
        '${v.immagine}. Oggi ${v.giorno}. Se guardi indietro, '
        '${v.riconoscimento}. Ora ${v.posa}.';
    final tua = nascita == null ? null : lunaDi(nascita);
    if (tua == null) return '$base Buonanotte.';
    final r = RelazioneLunare.fra(luna.sign, tua.sign);
    return '$base ${r.riga} Buonanotte.';
  }

  /// La relazione fra la Luna di stanotte e quella di nascita, quando la
  /// nascita si sa. Serve alla scheda "da dove nasce", che deve poterla
  /// nominare senza ricomporre il saluto.
  static RelazioneLunare? relazione(DateTime quando, DateTime? nascita) {
    if (nascita == null) return null;
    return RelazioneLunare.fra(lunaDi(quando).sign, lunaDi(nascita).sign);
  }

  /// La riga della provenienza, per la carta: segno e fase reali di stanotte.
  static String provenienza(BirthMoon luna) =>
      'Luna in ${luna.sign.italianName}, ${luna.phase.italianName.toLowerCase()}';

  /// Il testo del tooltip "Da dove nasce questo dono": dichiara il cielo reale,
  /// la Luna di stanotte e il confine onesto sull'allineamento.
  /// La stessa scheda, quando la nascita si sa: dichiara anche l'aspetto fra
  /// la Luna di stanotte e quella natale, che dal 30 agosto 2026 entra nel
  /// saluto. **Una scheda che non nominasse l'incrocio direbbe il falso su
  /// come nasce il Dono**, ed e' proprio la cosa che questa scheda esiste per
  /// non fare.
  static String daDoveNasceCon(BirthMoon luna, RelazioneLunare? relazione) {
    final base = daDoveNasce(luna);
    if (relazione == null) return base;
    return '$base La riga finale nasce dall\'angolo fra questa Luna e '
        'la Luna del tuo giorno di nascita, calcolata anche lei sul '
        'dispositivo: stanotte è un ${relazione.nome}. L\'aspetto fra '
        'un pianeta in transito e lo stesso pianeta natale è la '
        'lettura più antica che l\'astrologia occidentale fa dei '
        'transiti.';
  }

  static String daDoveNasce(BirthMoon luna) =>
      'Il cielo che vedi è il cielo notturno reale di questo momento. Stanotte '
      'la Luna è in ${luna.sign.italianName}, in fase '
      '${luna.phase.italianName.toLowerCase()}, calcolata sul dispositivo dalla '
      'data. La costellazione che unisci è il disegno reale del segno della '
      'Luna; il messaggio nasce da segno e fase, sul sentire del segno lunare '
      '(${BirthMoon.meaningFor(luna.sign)}). La scena si muove col giroscopio '
      'per darti il gesto di puntare il cielo, ma non è allineata alla posizione '
      'esatta sopra di te: servirebbero GPS, bussola ed effemeridi in tempo '
      'reale.';

  /// La riga del cielo di stanotte, dalla fase reale, per la scena.
  static String cieloDiStanotte(BirthMoon luna) =>
      NightSky.describeMoon(luna.phase);
}
