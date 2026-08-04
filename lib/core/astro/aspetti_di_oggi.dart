import 'effemeridi.dart';
import 'natal_chart.dart';
import 'transiti_del_giorno.dart';

/// QUANTO DELL'OROSCOPO SI PUO' PERSONALIZZARE DAVVERO, per questa persona.
///
/// Serve a chi mostra il responso per dire una cosa vera invece di far credere
/// che il cielo intero sia stato interrogato. Non porta testo: il testo lo
/// scrive l'ordine 2 di 2.
enum LivelloPersonalizzazione {
  /// Si conosce solo la data di nascita, quindi il segno solare. Nessun
  /// aspetto: senza le posizioni natali non c'e' un lato natale da confrontare.
  soloSegno,

  /// C'e' la carta, ma senza ora di nascita: pianeti si, Ascendente e Medio
  /// Cielo no. Gli aspetti ai pianeti si calcolano tutti.
  cartaSenzaOra,

  /// Carta completa, con Ascendente e Medio Cielo. Gli aspetti li comprendono.
  cartaCompleta,
}

/// GLI ASPETTI FRA IL CIELO DI OGGI E LA CARTA DI QUESTA PERSONA.
///
/// **Dove muore l'hash.** L'Oroscopo Personalizzato compone le sue schede con
/// una hash FNV-1a su segno, giorno e anno: un numero stabile, che pero' non
/// guarda il cielo. Qui c'e' il primo pezzo di cielo vero legato alla persona.
/// Questo file NON scrive nessun responso: produce il dato su cui l'ordine 2 di
/// 2 costruira' il testo.
///
/// **Aritmetica pura.** Nessuna rete, nessun LLM, nessun costo: differenza di
/// longitudine, confronto con gli angoli tolemaici, orbo. Gira sul dispositivo
/// anche in aereo.
///
/// **LE DUE ORIGINI, e vanno dette.** Il lato NATALE arriva dalle effemeridi
/// svizzere, per la callable `natalChart`, ed e' conservato cosi' com'e'. Il
/// lato TRANSITO arriva dal motore locale di `Effemeridi`, elementi orbitali di
/// Meeus. Sono due sorgenti diverse per lo stesso tipo di grandezza: misurate
/// contro JPL Horizons, le longitudini locali stanno entro un decimo di grado
/// (la Luna e Saturno entro due decimi), mentre l'orbo piu' stretto che qui si
/// usa e' due gradi. Lo scarto fra le due origini e' dunque venti volte piu'
/// piccolo della soglia che decide se un aspetto c'e': in pratica non sposta
/// niente. Va scritto lo stesso, perche' chi trovera' questo file fra sei mesi
/// deve sapere che le origini sono due e non una.
class AspettiDiOggi {
  const AspettiDiOggi._();

  /// ORBI, e nessuno di questi numeri e' indovinato.
  ///
  /// **Cosa e' saldo nelle fonti.** Che gli orbi dei TRANSITI siano piu'
  /// stretti di quelli natali e' concorde in tutta la letteratura consultata:
  /// un transito descrive una finestra che si apre e si chiude, non un tratto
  /// permanente del carattere, quindi la finestra va tenuta corta. Concorde
  /// anche che la Luna in transito voglia l'orbo piu' stretto di tutti, perche'
  /// percorre mezzo grado ogni ora e con un orbo largo sarebbe in aspetto con
  /// qualcosa tutto il giorno, tutti i giorni.
  ///
  /// **Cosa invece diverge, e lo dichiaro invece di sceglierlo in silenzio.**
  /// Il numero esatto cambia da autore ad autore: le tavole per la carta natale
  /// arrivano a dieci gradi sugli aspetti maggiori e otto sul sestile, mentre
  /// per i transiti le fonti consultate stanno fra uno e cinque gradi, con uno
  /// o due gradi per la Luna e per i pianeti lenti. Non esiste una tavola
  /// canonica da copiare.
  ///
  /// **La scelta del progetto**, dentro quella forbice e dichiarata come
  /// scelta: cinque gradi sugli aspetti maggiori, quattro sul sestile che in
  /// ogni tavola prende meno degli altri, due sulla Luna in transito.
  static const Map<AspectType, double> orboBase = {
    AspectType.conjunction: 5.0,
    AspectType.opposition: 5.0,
    AspectType.square: 5.0,
    AspectType.trine: 5.0,
    AspectType.sextile: 4.0,
  };

  /// L'orbo della Luna in transito, che vince sempre sull'orbo base.
  static const double orboLunaInTransito = 2.0;

  /// L'orbo dei tre lenti, per la ragione OPPOSTA a quella della Luna.
  ///
  /// La Luna ha l'orbo stretto perche' corre: con un orbo largo sarebbe in
  /// aspetto con qualcosa tutto il giorno. Urano, Nettuno e Plutone ce l'hanno
  /// stretto perche' stanno quasi fermi, da uno a tre gradi l'anno: con cinque
  /// gradi di orbo lo stesso aspetto resterebbe aperto per anni e non
  /// distinguerebbe un giorno dall'altro, che e' il contrario di cio' che serve
  /// a un oroscopo quotidiano. Anche qui le fonti consultate concordano sulla
  /// stretta, uno o due gradi, e divergono sul numero.
  static const double orboLentiInTransito = 2.0;

  /// I tre lenti, per cui vale l'orbo stretto.
  static const Set<CorpoCeleste> lenti = {
    CorpoCeleste.urano,
    CorpoCeleste.nettuno,
    CorpoCeleste.plutone,
  };

  /// L'orbo ammesso per un corpo in transito su un dato aspetto.
  static double orboPer(CorpoCeleste transito, AspectType tipo) {
    final base = orboBase[tipo]!;
    final double tetto;
    if (transito == CorpoCeleste.luna) {
      tetto = orboLunaInTransito;
    } else if (lenti.contains(transito)) {
      tetto = orboLentiInTransito;
    } else {
      return base;
    }
    return base < tetto ? base : tetto;
  }

  /// I corpi natali che entrano nel confronto, oltre ai pianeti: Ascendente e
  /// Medio Cielo esistono solo con l'ora di nascita, e sono i due punti a cui
  /// la tradizione dei transiti guarda quanto ai pianeti.
  static const String idAscendente = 'asc';
  static const String idMedioCielo = 'mc';

  /// Quanto si puo' personalizzare, data la carta che si ha in mano.
  static LivelloPersonalizzazione livello(NatalChart? carta) {
    if (carta == null || carta.isEssential) {
      return LivelloPersonalizzazione.soloSegno;
    }
    return carta.hasTime
        ? LivelloPersonalizzazione.cartaCompleta
        : LivelloPersonalizzazione.cartaSenzaOra;
  }

  /// GLI ASPETTI ATTIVI OGGI, dal piu' stretto al piu' largo.
  ///
  /// L'ordine e' per orbo crescente perche' nella tradizione un aspetto e' tanto
  /// piu' forte quanto piu' e' vicino all'angolo esatto: il primo della lista e'
  /// quello che pesa di piu' oggi. A parita' di orbo l'ordine e' quello dei
  /// corpi in transito, cosi' due esecuzioni danno sempre la stessa lista.
  ///
  /// **Senza carta non si finge.** Chi non ha dato ora e luogo di nascita ha un
  /// cielo essenziale, cioe' il solo segno solare: qui torna una lista vuota, e
  /// `livello` dice cosa resta raggiungibile. Costruire aspetti su un
  /// Ascendente inventato darebbe numeri esatti e falsi insieme.
  static List<ChartAspect> fra({
    required Map<CorpoCeleste, double> transiti,
    required NatalChart? carta,
    Map<CorpoCeleste, double>? transitiDomani,
  }) {
    if (carta == null || carta.isEssential) return const [];

    final natali = <String, double>{
      for (final p in carta.planets) p.id: p.longitude,
    };
    if (carta.hasTime) {
      final asc = carta.ascendantLongitude;
      final mc = carta.midheavenLongitude;
      if (asc != null) natali[idAscendente] = asc;
      if (mc != null) natali[idMedioCielo] = mc;
    }
    if (natali.isEmpty) return const [];

    final trovati = <ChartAspect>[];
    for (final corpo in CorpoCeleste.values) {
      final lonTransito = transiti[corpo];
      if (lonTransito == null) continue;
      for (final voce in natali.entries) {
        for (final tipo in AspectType.values) {
          final candidato = ChartAspect(
            aLongitude: lonTransito,
            bLongitude: voce.value,
            type: tipo,
            aId: corpo.id,
            bId: voce.key,
          );
          if (candidato.orbe <= orboPer(corpo, tipo)) {
            // Applicativo o separativo: si guarda dove sara' l'orbo domani. Se
            // si stringe l'aspetto sta arrivando, se si allarga sta passando.
            // Il corpo natale non si muove, quindi basta muovere il transito.
            final lonDomani = transitiDomani?[corpo];
            final bool? applicativo = lonDomani == null
                ? null
                : ChartAspect(
                      aLongitude: lonDomani,
                      bLongitude: voce.value,
                      type: tipo,
                    ).orbe <
                    candidato.orbe;
            trovati.add(applicativo == null
                ? candidato
                : ChartAspect(
                    aLongitude: candidato.aLongitude,
                    bLongitude: candidato.bLongitude,
                    type: tipo,
                    aId: candidato.aId,
                    bId: candidato.bId,
                    applicativo: applicativo,
                  ));
            // Due aspetti diversi non possono valere fra la stessa coppia: gli
            // angoli tolemaici distano almeno trenta gradi e l'orbo piu' largo
            // e' cinque, quindi appena uno entra gli altri sono esclusi.
            break;
          }
        }
      }
    }

    trovati.sort((x, y) {
      final perOrbo = x.orbe.compareTo(y.orbe);
      if (perOrbo != 0) return perOrbo;
      final ax = CorpoCeleste.values.indexWhere((c) => c.id == x.aId);
      final ay = CorpoCeleste.values.indexWhere((c) => c.id == y.aId);
      if (ax != ay) return ax.compareTo(ay);
      return (x.bId ?? '').compareTo(y.bId ?? '');
    });
    return trovati;
  }

  /// Gli aspetti attivi nel giorno civile di [adesso], per questa carta.
  ///
  /// L'istante dei transiti e' quello fisso del giorno, quindi due aperture
  /// nella stessa giornata danno la stessa identica lista.
  static List<ChartAspect> perIlGiorno({
    required DateTime adesso,
    required NatalChart? carta,
  }) =>
      fra(
        transiti: TransitiDelGiorno.posizioni(adesso),
        carta: carta,
        transitiDomani: TransitiDelGiorno.posizioni(
            adesso.add(const Duration(days: 1))),
      );

  /// QUALI CORPI SONO RETROGRADI oggi.
  ///
  /// "Mercurio retrogrado" e' la cosa piu' conosciuta dell'astrologia
  /// popolare: un oroscopo che non la nomina mai si tradisce al primo giorno.
  /// Non si legge da una tabella, si misura sul moto reale, e infatti il Sole
  /// e la Luna non compaiono mai qui perche' non retrogradano.
  static Set<CorpoCeleste> retrogradiDelGiorno(DateTime adesso) {
    final jd = TransitiDelGiorno.giornoGiulianoDi(adesso);
    return {
      for (final corpo in CorpoCeleste.values)
        if (Effemeridi.retrogrado(corpo, jd)) corpo,
    };
  }
}
