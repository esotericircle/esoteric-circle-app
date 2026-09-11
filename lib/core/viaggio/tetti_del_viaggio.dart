import '../config/app_flags.dart';
import '../entitlement/tier.dart';

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
abstract final class TettiDelViaggio {
  /// **QUANTE DOMANDE AL GIORNO, PIANO PER PIANO**, dopo la rivelazione.
  static const Map<Tier, int> domandeAlGiorno = {
    Tier.free: 1,
    Tier.tier1: 3,
    Tier.tier2: 7,
    Tier.tier3: 20,
  };

  /// **QUANTE DISCESE AL GIORNO PRIMA DELLA RIVELAZIONE.** Una, per tutti.
  ///
  /// Non c'e' nessuna mappa per piano, e **l'assenza della mappa e' la
  /// regola**: se il numero vivesse in una tabella, prima o poi qualcuno gli
  /// aggiungerebbe una riga per il livello piu' alto.
  static const int discesePrimaDellaRivelazione = 1;

  /// **LA RIVELAZIONE NON SI COMPRA CON GLI EOS.** Ordine DE voce 14.
  static const bool laRivelazioneSiCompra = false;

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
    return domandeAlGiorno[tier];
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

  /// **QUANTE NE RESTANO OGGI**, oppure nulla quando non c'e' un tetto.
  static int? quanteNeRestano({
    required bool giaRiconosciuto,
    required int quanteOggi,
    required Tier tier,
    bool demo = AppFlags.isDemo,
  }) {
    final tetto = quanteAlGiorno(
        giaRiconosciuto: giaRiconosciuto, tier: tier, demo: demo);
    if (tetto == null) return null;
    final resta = tetto - quanteOggi;
    return resta < 0 ? 0 : resta;
  }

  /// **SE IL TETTO DI OGGI SI PUO' SUPERARE COMPRANDO**, che e' una domanda
  /// diversa da quante ne restano.
  ///
  /// **Prima della rivelazione mai**, e non perche' manchi una porta di
  /// pagamento: perche' quel limite non e' in vendita. **Dopo, si**, con gli
  /// Eos, come per tutti gli altri budget del giorno.
  static bool siPuoComprareAncora({required bool giaRiconosciuto}) =>
      giaRiconosciuto ? true : laRivelazioneSiCompra;

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
  }) {
    if (siPuoScendere(
        giaRiconosciuto: giaRiconosciuto,
        quanteOggi: quanteOggi,
        tier: tier,
        demo: demo)) {
      return null;
    }
    if (!giaRiconosciuto) {
      return 'Oggi sei già sceso. I quattro viaggi cadono in quattro giorni '
          'diversi, e non è una regola nostra: è il metodo.';
    }
    final tetto = domandeAlGiorno[tier] ?? 1;
    return tetto == 1
        ? 'Oggi hai già fatto la tua domanda. Con gli Eos puoi farne un\'altra.'
        : 'Oggi hai fatto le tue $tetto domande. Con gli Eos puoi farne '
            'un\'altra.';
  }
}
