import '../astro/celestial.dart';
import '../astro/effemeridi.dart';
import '../astro/natal_chart.dart';
import '../tempo/confine_del_giorno.dart';
import 'cielo_della_sinastria.dart';

/// IL CIELO DEL GIORNO SULLA COPPIA. Ordine BO voce 12.
///
/// **Parole del fondatore**: "ma non sarebbe piu' giusto che siano le stelle e
/// i transiti del giorno a decidere?".
///
/// **Il principio, in una riga**: la geografia dice se un incontro e'
/// possibile, il cielo dice quando.
///
/// **LA TRAPPOLA CHE QUESTA CLASSE ESISTE PER EVITARE.** Se il moltiplicatore
/// nascesse da un transito dell'UTENTE, per esempio Venere sul suo
/// Discendente, quel giorno tutti e cinquanta i VIP avrebbero lo stesso
/// identico numero: sarebbero le 93 coppie identiche della voce 02 in una
/// forma nuova, e il difetto piu' grave dell'ordine tornerebbe da un'altra
/// porta. Il moltiplicatore nasce quindi dai transiti che **attivano gli
/// aspetti della sinastria di QUELLA coppia**, cioe' da un pianeta che oggi
/// passa sul grado dove i due cieli si toccano. E' specifico della coppia,
/// cambia ogni giorno, e sta dentro la tradizione dell'astrologia relazionale.
class MoltiplicatoreCeleste {
  const MoltiplicatoreCeleste({
    required this.valore,
    required this.transito,
    required this.aspettoAcceso,
    required this.soloPianeti,
  });

  /// Il moltiplicatore, fra [minimo] e [massimo].
  final double valore;

  /// Il corpo che oggi accende il legame, nullo se non ne accende nessuno.
  final CorpoCeleste? transito;

  /// L'aspetto della sinastria che oggi e' acceso, nullo se nessuno.
  final AspettoDiSinastria? aspettoAcceso;

  /// Vero quando il conto ha guardato **soltanto i pianeti**, perche' gli
  /// angoli non esistono: l'ora di nascita dei VIP e' ignota per cinquanta su
  /// cinquanta, come dichiara la voce 01, e senza ora non c'e' Ascendente.
  final bool soloPianeti;

  /// **LA FINESTRA, DICHIARATA, E NON RIBALTA LA GEOGRAFIA.**
  ///
  /// Da 0,45 a 2,2. Sotto meta' il legame e' spento, poco piu' del doppio e'
  /// il massimo che il cielo puo' dire: un moltiplicatore piu' largo
  /// prenderebbe il posto della distanza, e la distanza e' il fatto, il cielo
  /// e' il momento. Il tetto di 18 e il pavimento di 0,1 della voce 03
  /// restano e valgono DOPO la moltiplicazione.
  static const double minimo = 0.45;
  static const double massimo = 2.2;

  /// Il valore quando non c'e' niente da accendere: **uno**, cioe' il cielo
  /// non dice niente e la geografia resta com'e'.
  static const double neutro = 1.0;

  /// **GLI ORBI DEL TRANSITO SULL'ASPETTO**, e non sono quelli della
  /// sinastria.
  ///
  /// Un transito e' una finestra che si apre e si chiude in giorni, quindi va
  /// tenuta corta: sono gli stessi orbi che `AspettiDiOggi` gia' usa per il
  /// cielo del giorno, cinque gradi sui maggiori e quattro sul sestile, con la
  /// Luna a due perche' percorre mezzo grado ogni ora e con un orbo largo
  /// sarebbe in aspetto con qualcosa tutti i giorni.
  static const Map<AspectType, double> orbo = {
    AspectType.conjunction: 5.0,
    AspectType.opposition: 5.0,
    AspectType.square: 5.0,
    AspectType.trine: 5.0,
    AspectType.sextile: 4.0,
  };

  static const double orboDellaLuna = 2.0;

  static double orboPer(CorpoCeleste corpo, AspectType tipo) {
    final base = orbo[tipo]!;
    if (corpo != CorpoCeleste.luna) return base;
    return base < orboDellaLuna ? base : orboDellaLuna;
  }

  /// Il moltiplicatore di questa coppia in questo giorno.
  ///
  /// [aspetti] sono gli aspetti della sinastria, gia' calcolati dal responso:
  /// **non se ne ricalcola nessuno qui**, e il grado dove i due cieli si
  /// toccano e' l'estremo di ognuno di quegli aspetti.
  static MoltiplicatoreCeleste per({
    required List<AspettoDiSinastria> aspetti,
    required CieloDiSinastria tuo,
    required CieloDiSinastria suo,
    required DateTime giorno,
  }) {
    if (aspetti.isEmpty) {
      // **NON SI FINGE**: senza aspetti da attivare il cielo non ha niente da
      // dire, e la riga non nomina nessun transito.
      return const MoltiplicatoreCeleste(
        valore: neutro,
        transito: null,
        aspettoAcceso: null,
        soloPianeti: true,
      );
    }
    final jd = Celestial.julianDay(
        DateTime.utc(giorno.year, giorno.month, giorno.day, 12));
    final transiti = Effemeridi.tutte(jd);

    var somma = 0.0;
    CorpoCeleste? migliore;
    AspettoDiSinastria? acceso;
    var forzaMigliore = 0.0;

    for (final a in aspetti) {
      // Quanto pesa questo aspetto della sinastria: uno stretto pesa piu' di
      // uno largo, ed e' la stessa forza che il responso gia' usa.
      final peso = a.forzaCon(AspettiDiSinastria.orbo[a.tipo]!);
      if (peso <= 0) continue;
      final gradi = <double>[
        if (tuo.longitudini[a.tuo] != null) tuo.longitudini[a.tuo]!,
        if (suo.longitudini[a.suo] != null) suo.longitudini[a.suo]!,
      ];
      for (final voce in transiti.entries) {
        for (final grado in gradi) {
          for (final tipo in AspectType.values) {
            final candidato = ChartAspect(
                aLongitude: voce.value, bLongitude: grado, type: tipo);
            final ammesso = orboPer(voce.key, tipo);
            if (candidato.orbe > ammesso) continue;
            // Quanto e' acceso: uno all'angolo esatto, zero al limite.
            final acceso1 = (1 - candidato.orbe / ammesso).clamp(0.0, 1.0);
            final forza = acceso1 * peso;
            somma += forza;
            if (forza > forzaMigliore) {
              forzaMigliore = forza;
              migliore = voce.key;
              acceso = a;
            }
            break;
          }
        }
      }
    }

    // **DALLA SOMMA ALLA FINESTRA, con una curva che non puo' uscirne.**
    // `x / (x + riferimento)` vale zero a somma zero e tende a uno senza
    // arrivarci: moltiplicata per l'ampiezza della finestra e sommata al
    // minimo, il risultato sta dentro 0,45 e 2,2 per costruzione, non per
    // una pinza messa dopo.
    const riferimento = 1.6;
    final quota = somma / (somma + riferimento);
    return MoltiplicatoreCeleste(
      valore: minimo + quota * (massimo - minimo),
      transito: migliore,
      aspettoAcceso: acceso,
      // Gli angoli non entrano mai finche' l'ora dei VIP resta ignota: si
      // guarda se qualcuno dei due cieli ha davvero l'Ascendente.
      soloPianeti: !tuo.haAscendente && !suo.haAscendente,
    );
  }

  /// **LA RIGA CHE DICE COSA ACCENDE IL LEGAME, e non promette niente.**
  ///
  /// Vincolo del punto 4 dell'ordine, che e' un vincolo e non uno stile: la
  /// frase non promette mai l'incontro. Si scrive che quel giorno il legame e'
  /// piu' acceso, mai che l'incontro avverra'.
  String get riga {
    final t = transito;
    final a = aspettoAcceso;
    if (t == null || a == null) {
      return 'Oggi nessun pianeta passa sui gradi dove i vostri cieli si '
          'toccano: il cielo non aggiunge niente alla distanza.';
    }
    // **LA CODA SULL'ORA IGNOTA NON C'E' PIU'. Ordine CC voce 06g.**
    //
    // Il fondatore ha fatto togliere il testo che dice "non si finge cio'"
    // che non si conosce, e al suo posto ha chiesto due righe in ogni
    // responso: Ora di Nascita e Luogo di Residenza. Questa coda diceva la
    // stessa cosa un'altra volta, dentro la riga del cielo del giorno:
    // l'anteprima la mostrava tre righe sotto la riga nuova, che gia' dice
    // SCONOSCIUTO.
    //
    // Cio' che si difendeva resta: l'app non finge un Ascendente che
    // nessuna fonte dichiara, e lo dice dove il fondatore ha chiesto.
    const coda = '';
    if (valore >= 1.5) {
      return 'Oggi ${t.nome} passa sul grado di ${a.titolo}: è uno dei giorni '
          'in cui quel legame è più acceso.$coda';
    }
    if (valore >= 1.0) {
      return 'Oggi ${t.nome} sfiora il grado di ${a.titolo}: il legame è '
          'appena vivo.$coda';
    }
    return 'Oggi nessun passaggio importante tocca ${a.titolo}: il legame '
        'resta silenzioso.$coda';
  }
}

/// LA DATA PIU' FAVOREVOLE. Ordine BO voce 12 punto 3.
///
/// **Non e' una promessa e non puo' diventarlo**: e' il giorno in cui i
/// transiti accendono di piu' gli aspetti di quella coppia, dentro i prossimi
/// sei mesi.
class GiornoPiuAcceso {
  const GiornoPiuAcceso({required this.giorno, required this.moltiplicatore});

  final DateTime giorno;
  final MoltiplicatoreCeleste moltiplicatore;

  /// Quanti giorni si guardano avanti. **Sei mesi**, come chiede l'ordine.
  static const int giorniDaGuardare = 183;

  /// Cerca il giorno migliore fra [da] e i sei mesi successivi.
  ///
  /// La scansione e' un giro solo sui giorni, e ogni giorno costa un calcolo
  /// di effemeridi piu' il confronto con gli aspetti della coppia: nessuna
  /// rete, nessuna cache da tenere allineata.
  static GiornoPiuAcceso? cerca({
    required List<AspettoDiSinastria> aspetti,
    required CieloDiSinastria tuo,
    required CieloDiSinastria suo,
    required DateTime da,
    int giorni = giorniDaGuardare,
  }) {
    if (aspetti.isEmpty) return null;
    GiornoPiuAcceso? migliore;
    final partenza = DateTime.utc(da.year, da.month, da.day);
    for (var i = 0; i < giorni; i++) {
      final g = partenza.add(Duration(days: i));
      final m = MoltiplicatoreCeleste.per(
          aspetti: aspetti, tuo: tuo, suo: suo, giorno: g);
      // **A parita' di valore vince il giorno piu' vicino**, e la regola di
      // spareggio e' dichiarata: senza, due esecuzioni potrebbero dare due
      // date diverse.
      if (migliore == null || m.valore > migliore.moltiplicatore.valore) {
        migliore = GiornoPiuAcceso(giorno: g, moltiplicatore: m);
      }
    }
    return migliore;
  }

  /// Fra quanti giorni cade, contati dal confine del giorno gia' in uso.
  int fraQuantiGiorniDa(DateTime oggi) =>
      ConfineDelGiorno.giorniDa(oggi, giorno);

  /// **LA RIGA DELLA DATA, che non promette.** Dice che quel giorno il legame
  /// e' piu' acceso, e mai che l'incontro avverra'.
  String rigaDa(DateTime oggi) {
    final quanti = fraQuantiGiorniDa(oggi);
    final quando = quanti <= 0
        ? 'oggi stesso'
        : quanti == 1
            ? 'domani'
            : 'fra $quanti giorni';
    return 'Nei prossimi sei mesi il giorno in cui quel legame è più acceso '
        'cade $quando, il ${_dataBreve(giorno)}.';
  }

  static String _dataBreve(DateTime d) {
    const mesi = [
      'gennaio', 'febbraio', 'marzo', 'aprile', 'maggio', 'giugno', //
      'luglio', 'agosto', 'settembre', 'ottobre', 'novembre', 'dicembre'
    ];
    return '${d.day} ${mesi[d.month - 1]}';
  }
}
