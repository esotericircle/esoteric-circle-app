import '../config/app_flags.dart';
import '../entitlement/plan_catalog.dart';
import '../entitlement/tier.dart';
import 'i_quattro_viaggi.dart';
import '../tempo/confine_del_giorno.dart';

/// **I TETTI DEL VIAGGIO, E LA DEMO SENZA LIMITI.**
/// Ordine DE voce 14, 11 settembre 2026.
///
/// **DUE REGOLE CHE SEMBRANO UNA E NON LO SONO.**
///
/// **La prima e' commerciale**: dopo la rivelazione il Viaggio risponde a
/// domande, e le domande al giorno seguono il piano. Una per il gratuito, tre
/// per il primo livello, sette per il secondo, venti per il terzo, e oltre il
/// tetto si comprano con gli Eos.
///
/// **La seconda non lo e' affatto**: le quattro discese del riconoscimento
/// restano **una al giorno per tutti**, anche per il livello piu' alto, e
/// **non si comprano**. Le parole dell'ordine: *"se un pagante puo' fare i
/// quattro viaggi in dieci minuti, l'incontro con il proprio animale diventa
/// una schermata di caricamento"*. L'attesa qui non e' una trattenuta: e' il
/// metodo di Harner, e una funzione che vende la propria fonte smette di
/// avere una fonte.
///
/// **UN CODICE SOLO, DUE CONFIGURAZIONI.** L'ordine lo dice e la ragione e'
/// dichiarata: *"due strade divergono e la Demo finirebbe per provare una
/// funzione che gli utenti non hanno"*. Qui la Demo non e' un ramo: e' il
/// parametro [demo] che vale [AppFlags.isDemo] quando nessuno lo dichiara, ed
/// e' la **stessa chiave gia' in uso** in sei altri punti del progetto, dal
/// catalogo delle arti alla schermata dei piani.
///
/// **COME SI ACCENDE E COME SI SPEGNE**, che l'ordine chiede di dichiarare:
/// si cambia `AppFlags.isDemo` in `lib/core/config/app_flags.dart`, oggi
/// `true`. E' una costante a compilazione, quindi la si spegne ricompilando, e
/// in futuro puo' arrivare da Remote Config, dove il parametro `demo_mode` e'
/// gia' pubblicato, **dietro la stessa lettura**. Nelle prove si passa [demo]
/// a mano, senza toccare niente di globale.
///
/// **DALL'ORDINE DI VOCE 15, 12 settembre 2026, i numeri della prima regola
/// sono cambiati, e vivono nella matrice dei piani.** Qui c'era una mappa,
/// `domandeAlGiorno`, con uno, tre, sette e venti: l'ordine DI vuole *"la
/// matrice in plan_catalog.dart resta la fonte unica"*, e i valori nuovi sono
/// **una discesa al giorno per Viandante, Iniziato e Adepto, due per
/// l'Illuminato**. E *"oltre il tetto si comprano con gli Eos"* non era vero:
/// nessuna strada del codice vendeva una discesa, e la riga del rifiuto
/// prometteva una cosa che non esisteva. Adesso il rifiuto dice quando si
/// torna a scendere e offre il nutrimento, che e' sempre aperto.
///
/// **LA SECONDA REGOLA RESTA INTERA**: prima del riconoscimento una discesa al
/// giorno per tutti, anche per l'Illuminato che dopo ne ha due.
abstract final class TettiDelViaggio {
  /// **QUANTE DISCESE AL GIORNO PER QUESTO PIANO**, dopo la rivelazione.
  /// Letto dalla matrice dei piani, ordine DI voce 15.
  static int discesePerIlPiano(Tier tier) =>
      PlanCatalog.limiteGiornaliero(RigaDelPiano.discese, tier) ?? 0;

  /// **QUANTI SEGNI SI POSSONO CHIEDERE, E IN QUALE PERIODO.** Ordine DI voce
  /// 15: al giorno o alla settimana secondo il piano, letto dalla matrice.
  static ({int quanti, bool allaSettimana}) segniPerIlPiano(Tier tier) =>
      PlanCatalog.limiteDelPeriodo(RigaDelPiano.segni, tier);

  /// **SE SI PUO' CHIEDERE UN SEGNO ADESSO**, dati gli istanti dei segni gia'
  /// chiesti. La settimana e' quella che scorre, gli ultimi sette giorni, e
  /// non quella del calendario: chi chiede il suo segno di domenica non deve
  /// poterne chiedere un altro lunedi'.
  static bool siPuoChiedereUnSegno({
    required Iterable<DateTime> segniChiesti,
    required DateTime adesso,
    required Tier tier,
    bool demo = AppFlags.isDemo,
  }) {
    if (demo) return true;
    return quantiSegniRestano(
            segniChiesti: segniChiesti, adesso: adesso, tier: tier) >
        0;
  }

  /// Quanti segni restano nel periodo del piano.
  static int quantiSegniRestano({
    required Iterable<DateTime> segniChiesti,
    required DateTime adesso,
    required Tier tier,
  }) {
    final limite = segniPerIlPiano(tier);
    final dentro = segniChiesti.where((s) => limite.allaSettimana
        ? adesso.difference(s) < const Duration(days: 7)
        : _stessoGiorno(s, adesso));
    final resta = limite.quanti - dentro.length;
    return resta < 0 ? 0 : resta;
  }

  /// **QUANDO TORNA UN SEGNO**, detto in parole: *domani*, oppure il giorno
  /// della settimana in cui il piu' vecchio dei segni del periodo esce dai
  /// sette giorni. L'ordine: *"quando un limite e' raggiunto non si mostra un
  /// muro: si dice quando torna disponibile e si offre il nutrimento"*.
  ///
  /// [conArticolo] e' l'animale col suo articolo, *il Lupo* o *la Volpe*:
  /// la frase lo nomina invece di usare un pronome, che al maschile
  /// sbaglierebbe su quattro animali su dodici.
  static String quandoTornaUnSegno({
    required Iterable<DateTime> segniChiesti,
    required DateTime adesso,
    required Tier tier,
    String? conArticolo,
  }) {
    final limite = segniPerIlPiano(tier);
    if (!limite.allaSettimana) {
      return 'Un altro segno potrai chiederlo domani. ${_intanto(conArticolo)}';
    }
    final nellaSettimana = segniChiesti
        .where((s) => adesso.difference(s) < const Duration(days: 7))
        .toList()
      ..sort();
    final torna = nellaSettimana.isEmpty
        ? adesso
        : nellaSettimana.first.add(const Duration(days: 7));
    // **I GIORNI SI CONTANO DALLA PORTA**, `ConfineDelGiorno.giorniDa`: la
    // sottrazione di due date locali, qui fino alla suite dell'ordine DI, con
    // l'ora legale di mezzo non fa giorni interi.
    final fra = ConfineDelGiorno.giorniDa(adesso, torna);
    final quando = fra <= 1
        ? 'domani'
        : fra == 2
            ? 'dopodomani'
            : _giorni[torna.weekday - 1];
    return 'Un altro segno potrai chiederlo $quando. ${_intanto(conArticolo)}';
  }

  /// **L'OFFERTA DEL NUTRIMENTO**, che accompagna ogni tetto raggiunto.
  static String _intanto(String? conArticolo) => conArticolo == null
      ? 'Intanto il tamburo è sempre aperto.'
      : 'Intanto puoi nutrire $conArticolo: il tamburo è sempre aperto.';

  static const List<String> _giorni = [
    'lunedì',
    'martedì',
    'mercoledì',
    'giovedì',
    'venerdì',
    'sabato',
    'domenica',
  ];

  static bool _stessoGiorno(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// **IL TETTO TECNICO, oltre il piano, per la sola difesa dai costi.**
  /// Ordine DI voce 15: *"dieci chiamate al modello al giorno per utente,
  /// contando discese e segni insieme"*. Oltre, le vie di riserva: il Viaggio
  /// continua a rispondere, senza modello. Lo conta `IlTettoDelleChiamate`.
  static const int chiamateAlModelloAlGiorno = 10;

  /// **QUANTE DISCESE AL GIORNO PRIMA DELLA RIVELAZIONE.** Una, per tutti.
  ///
  /// Non c'e' nessuna mappa per piano, e **l'assenza della mappa e' la
  /// regola**: se il numero vivesse in una tabella, prima o poi qualcuno gli
  /// aggiungerebbe una riga per il livello piu' alto.
  static const int discesePrimaDellaRivelazione = 1;

  /// **LA RIVELAZIONE NON SI COMPRA CON GLI EOS**, ordine DE voce 14, **e
  /// nemmeno le discese dopo**, ordine DI voce 15. Qui c'erano una costante
  /// che valeva falso e `siPuoComprareAncora`, che la restituiva: nessuna
  /// strada dell'app vendeva una discesa, e nessuno le chiamava. **Tolte con
  /// l'ordine DJ voce 05**: il codice mai raggiunto mente a chi legge, e fra
  /// due mesi qualcuno ci costruirebbe sopra un ragionamento sbagliato. Il
  /// giorno che si decidera' di vendere una discesa si riscrive. La regola la
  /// sorveglia `i_tetti_del_viaggio_e_la_demo`, dove si potrebbe vendere
  /// davvero: il listino del server non ha un budget per le discese, e nessun
  /// file del Viaggio tocca le porte che spendono gli Eos.

  /// **IL TETTO DI OGGI**, oppure nulla quando non c'e' nessun tetto.
  ///
  /// Nullo vuol dire **illimitato**, ed e' il caso della Demo. E' la stessa
  /// convenzione dei budget del giorno, dove nullo vuol dire tacere invece di
  /// indovinare un numero.
  static int? quanteAlGiorno({
    required bool giaRiconosciuto,
    required Tier tier,
    bool demo = AppFlags.isDemo,
  }) {
    // **IN DEMO OGNI LIMITE CADE, e cade per primo.** Il fondatore deve poter
    // fare le quattro discese di seguito e continuare oltre, altrimenti per
    // valutare la funzione dovrebbe aspettare quattro giorni.
    if (demo) return null;
    if (!giaRiconosciuto) return discesePrimaDellaRivelazione;
    return discesePerIlPiano(tier);
  }

  /// **SE SI PUO' SCENDERE OGGI**, dato quante volte si e' gia' sceso oggi.
  static bool siPuoScendere({
    required bool giaRiconosciuto,
    required int quanteOggi,
    required Tier tier,
    bool demo = AppFlags.isDemo,
  }) {
    final tetto = quanteAlGiorno(
        giaRiconosciuto: giaRiconosciuto, tier: tier, demo: demo);
    if (tetto == null) return true;
    return quanteOggi < tetto;
  }

  /// **LA RIGA CHE DICE PERCHE' NON SI SCENDE**, e nulla quando si scende.
  ///
  /// **Due frasi diverse per due limiti diversi**, ed e' il punto della voce:
  /// chi non e' ancora arrivato alla quarta discesa legge il metodo, chi ci e'
  /// arrivato legge il piano. Scrivere una frase sola vorrebbe dire dire a chi
  /// aspetta per il metodo che gli basterebbe pagare.
  static String? percheNonOggi({
    required bool giaRiconosciuto,
    required int quanteOggi,
    required Tier tier,
    bool demo = AppFlags.isDemo,
    String? conArticolo,
  }) {
    if (siPuoScendere(
        giaRiconosciuto: giaRiconosciuto,
        quanteOggi: quanteOggi,
        tier: tier,
        demo: demo)) {
      return null;
    }
    // **SENZA PARTICIPIO**: qui c'era *"Oggi sei gia' sceso"*, che a chi
    // legge da donna diceva di essere un uomo. Ordine DI voce 05.
    if (!giaRiconosciuto) {
      return 'La discesa di oggi è già fatta. I quattro viaggi cadono in '
          'quattro giorni diversi. Non è una regola nostra: è il metodo.';
    }
    // **QUANDO SI TORNA, E COSA SI PUO' FARE INTANTO.** Ordine DI voce 15:
    // *"quando un limite e' raggiunto non si mostra un muro: si dice quando
    // torna disponibile e si offre il nutrimento, che e' sempre aperto"*.
    // Qui c'era *"Con gli Eos puoi farne un'altra"*, e nessuna strada del
    // codice vendeva una discesa.
    final tetto = discesePerIlPiano(tier);
    return tetto == 1
        ? 'La tua discesa di oggi è fatta. Puoi scendere di nuovo domani. '
            '${_intanto(conArticolo)}'
        : 'Le tue ${IQuattroViaggi.inLettere(tetto)} discese di oggi sono '
            'fatte. Puoi scendere di nuovo domani. ${_intanto(conArticolo)}';
  }
}
