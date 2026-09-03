import '../astro/moon_phase.dart';
import '../astro/night_sky.dart';
import '../astro/luogo_attuale.dart';
import '../astro/sky_location.dart';
import '../astro/solar_time.dart';
import '../astro/zodiac.dart';
import '../maestro/maestro.dart';
import 'daily_rituals.dart';
import 'rito_alba_corpus.dart';
import 'risposta_del_dono.dart';

/// DA DOVE VENGONO LE COORDINATE dell'alba.
///
/// **Un'alba è dove sei stamattina, non dove sei nato.** Chi è nato a Sydney e
/// vive a Milano vede sorgere il sole a Milano: usare il luogo di nascita
/// sbaglierebbe di ore, e sbaglierebbe proprio a chi si è spostato.
///
/// **Non riusa `OrigineCoordinate`** di `sky_location.dart`, che pure esiste e
/// dichiara `dispositivo`, `nascita` e `nessuna`: le manca il caso della
/// posizione STIMATA dal fuso, e quel file non si puo' modificare. Qui il caso
/// `nascita` non compare apposta, perché per l'alba non è mai una risposta
/// valida.
enum OrigineDellAlba {
  /// Dal GPS del telefono. Coordinate e scarto di fuso vengono dallo stesso
  /// dispositivo, quindi l'ora del sorgere è quella vera di dove sei.
  dispositivo,

  /// DICHIARATA DALLA PERSONA, scegliendo la citta' in cui vive.
  ///
  /// **Ordine P voce 23, e vale quanto il dispositivo.** Il sorgere dipende da
  /// latitudine e longitudine, e dentro una citta' la differenza fra un
  /// quartiere e l'altro non arriva al minuto: chi dichiara "vivo a Milano" ha
  /// detto tutto quello che serve. Lo scarto di fuso resta quello del telefono,
  /// che per chi vive dove ha dichiarato e' lo stesso della citta': l'invariante
  /// delle due origini regge, perche' entrambe descrivono dove la persona STA.
  ///
  /// Esiste perche' senza di lei chi non concede il permesso non vede mai l'ora
  /// del sorgere, e sono la maggioranza.
  dichiarata,

  /// Dedotta dallo scarto di fuso: la longitudine si ricava dall'offset, la
  /// latitudine è quella dichiarata di ripiego. Coordinate e fuso restano della
  /// stessa origine per costruzione, ma il punto puo' distare centinaia di
  /// chilometri da dove sei davvero, quindi **l'ora che ne esce non si dichiara
  /// alla persona**.
  stimataDalFuso,
}

/// LA POSIZIONE CON CUI SI CALCOLA L'ALBA, e la sua origine dichiarata.
///
/// **L'invariante che questa classe esiste per garantire**: le coordinate e lo
/// scarto di fuso vengono sempre dalla STESSA origine. Prima non era vero, e il
/// difetto era invisibile: le coordinate arrivavano dal luogo di NASCITA e il
/// fuso dall'orologio del telefono, quindi per chi si era spostato l'ora del
/// sorgere nasceva da due punti diversi del mondo messi insieme.
class PosizioneDiStamattina {
  const PosizioneDiStamattina({
    required this.lat,
    required this.lon,
    required this.scartoDiFuso,
    required this.origine,
  });

  final double lat;
  final double lon;
  final Duration scartoDiFuso;
  final OrigineDellAlba origine;

  /// Dalla posizione del dispositivo se c'è, altrimenti stimata dal fuso.
  ///
  /// [luogo] è quello che torna `SkyLocation.resolveSeConcesso()`, cioè la
  /// posizione reale **solo se il permesso è già stato concesso**: il Rito
  /// dell'Alba non apre una richiesta di permesso all'alba.
  /// [dichiarato] e' la citta' che la persona ha scelto nel profilo, ordine P
  /// voce 23: si usa quando il dispositivo non ha risposto, prima di ripiegare
  /// sulla stima dal fuso.
  factory PosizioneDiStamattina.da(SkyPlace? luogo, Duration scartoDiFuso,
      {LuogoAttuale? dichiarato}) {
    if (luogo != null) {
      return PosizioneDiStamattina(
        lat: luogo.latitude,
        lon: luogo.longitude,
        scartoDiFuso: scartoDiFuso,
        origine: OrigineDellAlba.dispositivo,
      );
    }
    // LA CITTA' DICHIARATA VIENE PRIMA DELLA STIMA, ordine P voce 23. La stima
    // dal fuso puo' sbagliare di centinaia di chilometri e non si puo'
    // dichiarare; una citta' scelta dalla persona e' un punto vero.
    if (dichiarato != null) {
      return PosizioneDiStamattina(
        lat: dichiarato.lat,
        lon: dichiarato.lon,
        scartoDiFuso: scartoDiFuso,
        origine: OrigineDellAlba.dichiarata,
      );
    }
    // Il ripiego sta tutto dentro `SunsetTime` e non apre una seconda porta: la
    // longitudine si ricava dallo stesso scarto di fuso che poi riporta l'ora a
    // muro, quindi le due cose non possono divergere.
    return PosizioneDiStamattina(
      lat: SunsetTime.latDiRipiego,
      lon: SunsetTime.longitudineDaFuso(scartoDiFuso),
      scartoDiFuso: scartoDiFuso,
      origine: OrigineDellAlba.stimataDalFuso,
    );
  }

  /// Se l'ora del sorgere si puo' DICHIARARE alla persona.
  ///
  /// Col dispositivo oppure con la citta' DICHIARATA dalla persona. Una
  /// longitudine dedotta dal fuso puo' sbagliare di mezz'ora abbondante, e
  /// un'ora sbagliata detta come esatta è una promessa che non possiamo
  /// mantenere: vale la stessa regola del caso senza luogo.
  ///
  /// **La citta' scelta entra qui con l'ordine P voce 23**, ed e' cio' che
  /// rende la fascia raggiungibile a chi non concede il permesso: prima erano
  /// escluse tutte e due le strade tranne il GPS.
  bool get oraDichiarabile =>
      origine == OrigineDellAlba.dispositivo ||
      origine == OrigineDellAlba.dichiarata;
}

/// IL CIELO DI STAMATTINA, cioe' i dati veri che il rito puo' nominare.
///
/// **Si LEGGE da `lib/core/astro/`, non si ricalcola.** La fase lunare viene da
/// `MoonPhase.forDate`, il segno della Luna da `NightSky.moonSign`, l'ora del
/// sorgere da `SunsetTime.albaPerData`. Nessuna astronomia e' scritta qui.
class CieloDiStamattina {
  const CieloDiStamattina({
    required this.faseLunare,
    required this.segnoLunare,
    required this.oraDellAlba,
  });

  /// Il nome italiano della fase lunare di oggi.
  final String? faseLunare;

  /// Il segno in cui si trova la Luna oggi.
  final Zodiac? segnoLunare;

  /// L'ora del sorgere del sole, per il luogo della persona. **Null se il luogo
  /// non e' noto**, e in quel caso i momenti che la nominano non entrano.
  final DateTime? oraDellAlba;

  /// Legge il cielo di [giorno] dalla posizione di stamattina.
  ///
  /// **L'ora dell'alba entra solo se si puo' dichiarare**, cioè solo se le
  /// coordinate vengono dal dispositivo. Con la posizione stimata dal fuso
  /// l'ora resta nulla e il rito nomina la Luna al suo posto: è la stessa
  /// regola del caso senza luogo, perché una longitudine dedotta dal fuso puo'
  /// sbagliare di mezz'ora abbondante.
  static CieloDiStamattina per(
    DateTime giorno, {
    PosizioneDiStamattina? posizione,
  }) {
    DateTime? alba;
    if (posizione != null && posizione.oraDichiarabile) {
      alba = SunsetTime.albaPerData(
        giorno,
        lat: posizione.lat,
        lon: posizione.lon,
        offset: posizione.scartoDiFuso,
      );
      // Casi polari: il Sole non sorge. Non si ripiega su un'ora media qui,
      // perche' un'ora media dichiarata come "la tua alba" sarebbe falsa: il
      // rito cambia momento e non nomina l'alba affatto.
    }
    return CieloDiStamattina(
      faseLunare: MoonPhase.forDate(giorno).italianName,
      segnoLunare: NightSky.moonSign(giorno),
      oraDellAlba: alba,
    );
  }

  /// Se il dato c'e' davvero.
  bool ha(DatoDelCielo dato) => switch (dato) {
        DatoDelCielo.faseLunare => faseLunare != null,
        DatoDelCielo.segnoLunare => segnoLunare != null,
        DatoDelCielo.oraDellAlba => oraDellAlba != null,
      };

  /// Il valore da mettere al posto del segnaposto.
  String valoreDi(DatoDelCielo dato) => switch (dato) {
        // IL PREDICATO, non il nome: le frasi del corpus dicono tutte
        // "La Luna e' {fase}", e li dentro il nome della fase produce
        // "La Luna e' Luna calante" oppure "La Luna e' Ultimo quarto".
        DatoDelCielo.faseLunare =>
          faseLunare == null ? '' : MoonPhase.comeSiDice(faseLunare!),
        DatoDelCielo.segnoLunare => segnoLunare?.italianName ?? '',
        DatoDelCielo.oraDellAlba => oraDellAlba == null
            ? ''
            : '${oraDellAlba!.hour}:'
                '${oraDellAlba!.minute.toString().padLeft(2, '0')}',
      };

  /// I dati disponibili stamattina.
  Set<DatoDelCielo> get disponibili => {
        for (final d in DatoDelCielo.values)
          if (ha(d)) d
      };
}

/// IL RITO DELL'ALBA DI OGGI, composto e pronto.
class RitoDiOggi {
  const RitoDiOggi({
    required this.maestro,
    required this.forma,
    required this.risposta,
    required this.gesto,
    required this.viaTattile,
    required this.respiro,
    required this.tempi,
    required this.giri,
    required this.parola,
    required this.perche,
    required this.datiNominati,
  });

  final Maestro maestro;

  /// Il nome della forma da cui nasce.
  final String forma;

  /// **LE PRIME DUE COSE CHE SI LEGGONO, ordine CO voce 17.**
  ///
  /// Un titolo che e' gia' una risposta, e la risposta vera. Nascono dal fatto
  /// del cielo che questo rito nomina e dalla lente del Maestro che lo porge:
  /// nessuna delle due frasi e' generata, tutte e due vengono da un elenco
  /// chiuso di dodici, scelto dal cielo di stamattina.
  ///
  /// **Stanno nel rito e non nella schermata**, perche' una risposta scritta
  /// dentro la scheda sarebbe la sesta porta sullo stesso contenuto: il Dono
  /// dell'Alba e il Soffio del Destino montano la stessa scheda, e i cinque
  /// Doni la stessa gerarchia.
  final RispostaDelDono risposta;

  /// Il gesto, col dato del cielo gia' dentro.
  final String gesto;

  /// La via col dito, sempre presente.
  final String viaTattile;

  /// Il respiro contato, col suo numero gia' dentro.
  final String respiro;

  /// QUANTI TEMPI DURA OGNI FASE DEL RESPIRO, e quanti giri se ne fanno.
  ///
  /// Erano nel corpus e si fermavano li': venivano usati per comporre la coda
  /// in cifre del testo e poi buttati. Il testo quella coda non ce l'ha piu',
  /// e i numeri servono a chi il respiro deve GUIDARLO: una schermata che dice
  /// "sei tempi dentro e sei fuori, tre volte" e poi lascia contare a mente e'
  /// un foglio di istruzioni, non un rito.
  final int tempi;

  /// Quanti giri completi di respiro chiede questa variante.
  final int giri;

  /// La parola da portare nella giornata.
  final String parola;

  /// Perche' quella parola.
  final String perche;

  /// Quali dati veri del cielo questo rito nomina. **Mai vuoto**: un rito che
  /// non nomina niente del cielo di stamattina non e' un rito dell'alba, e' una
  /// frase.
  final Set<DatoDelCielo> datiNominati;
}

/// LA FASCIA DEL RISVEGLIO, cioe' l'ora che premia.
///
/// **La persona lo sa PRIMA di toccare.** Chi compie il rito entro un'ora dal
/// proprio sorgere del sole riceve una riga in piu' dal Maestro. Chi arriva
/// dopo compie il rito **per intero e senza penalita'**: manca solo quella
/// riga, e nient'altro si accorcia.
///
/// **Se il luogo non e' noto la fascia NON si dichiara.** Un'ora fissa detta a
/// tutti sarebbe una promessa che non possiamo mantenere: qui si dice invece
/// che serve il luogo di nascita per calcolarla, e il rito resta intero.
class FasciaDelRisveglio {
  const FasciaDelRisveglio({required this.inizio, required this.durata});

  /// Il sorgere del sole vero per il luogo della persona. Null se il luogo non
  /// e' noto, o nei casi polari dove il Sole non sorge.
  final DateTime? inizio;

  /// Quanto dura la fascia dal sorgere.
  final Duration durata;

  /// Un'ora dal sorgere: abbastanza per alzarsi e farlo, abbastanza poco da
  /// significare davvero "presto".
  static const Duration durataStandard = Duration(hours: 1);

  /// La fascia per un giorno e la posizione di stamattina.
  ///
  /// **Si dichiara solo con la posizione del dispositivo.** Senza posizione, o
  /// con una stimata dal fuso, torna una fascia non dichiarabile: vale la
  /// stessa regola, perché un'ora sbagliata di mezz'ora detta come esatta è una
  /// promessa che non possiamo mantenere.
  static FasciaDelRisveglio per(
    DateTime giorno, {
    PosizioneDiStamattina? posizione,
  }) {
    if (posizione == null || !posizione.oraDichiarabile) {
      return const FasciaDelRisveglio(inizio: null, durata: durataStandard);
    }
    return FasciaDelRisveglio(
      inizio: SunsetTime.albaPerData(giorno,
          lat: posizione.lat,
          lon: posizione.lon,
          offset: posizione.scartoDiFuso),
      durata: durataStandard,
    );
  }

  /// Se si puo' dire alla persona a che ora e', con un'ora vera.
  bool get dichiarabile => inizio != null;

  /// La fine della fascia.
  DateTime? get fine => inizio?.add(durata);

  /// Se [istante] cade dentro la fascia. Falso quando la fascia non e'
  /// dichiarabile: senza un'ora vera non si premia nessuno, perche' non si
  /// saprebbe rispetto a cosa.
  bool contiene(DateTime istante) {
    final da = inizio;
    if (da == null) return false;
    final a = da.add(durata);
    return !istante.isBefore(da) && istante.isBefore(a);
  }

  /// L'ora del sorgere in forma leggibile, oppure null.
  String? get oraDiInizio => inizio == null
      ? null
      : '${inizio!.hour}:${inizio!.minute.toString().padLeft(2, '0')}';

  /// L'ora di fine in forma leggibile, oppure null.
  String? get oraDiFine => fine == null
      ? null
      : '${fine!.hour}:${fine!.minute.toString().padLeft(2, '0')}';
}

/// LA COMPOSIZIONE DEL RITO DEL GIORNO.
///
/// **Non e' un testo pescato da un elenco.** E' una forma che si riempie col
/// cielo di oggi: tre momenti scelti dentro la forma del Maestro di turno, e
/// ogni momento nomina un dato vero di stamattina. Il cielo non si ripete, e
/// nemmeno il rito.
///
/// **Se un dato manca, il rito non lo inventa: cambia momento.** Chi non ha dato
/// il luogo di nascita non ha l'ora dell'alba, quindi le varianti che la
/// nominano non entrano nemmeno nella scelta, e il rito resta intero con gli
/// altri dati.
class RitoAlba {
  const RitoAlba._();

  /// Il rito di [giorno] per il Maestro di turno.
  ///
  /// Il Maestro lo dice `DailyRituals.dawnMaestro`, che e' gia' la porta sola
  /// della rotazione: qui non se ne scrive una seconda.
  static RitoDiOggi? diOggi(
    DateTime giorno, {
    PosizioneDiStamattina? posizione,
    Zodiac? soleNatale,
  }) {
    final cielo = CieloDiStamattina.per(giorno, posizione: posizione);
    return componi(giorno, DailyRituals.dawnMaestro(giorno), cielo,
        soleNatale: soleNatale);
  }

  /// Compone il rito per un Maestro e un cielo dati.
  ///
  /// Torna null solo se nessuna variante e' compatibile col cielo disponibile,
  /// cosa che non accade finche' la fase lunare si calcola in locale: e' una
  /// cintura, non un caso atteso.
  static RitoDiOggi? componi(
      DateTime giorno, Maestro maestro, CieloDiStamattina cielo,
      {Zodiac? soleNatale}) {
    final forme = RitoAlbaCorpus.perMaestro(maestro);
    if (forme.isEmpty) return null;

    final seme = _seme(giorno, maestro, soleNatale);
    final forma = forme[seme % forme.length];

    // Solo le varianti il cui dato c'e' davvero.
    final gesti = forma.gesti.where((g) => cielo.ha(g.dato)).toList();
    if (gesti.isEmpty) return null;
    final respiri = forma.respiri
        .where((r) => r.dato == null || cielo.ha(r.dato!))
        .toList();
    if (respiri.isEmpty) return null;
    final parole =
        forma.parole.where((p) => p.dato == null || cielo.ha(p.dato!)).toList();
    if (parole.isEmpty) return null;

    // Due semi derivati distinti per gesto e respiro, cosi' i due momenti non
    // si muovono in blocco: con un seme solo, cambiando giorno cambierebbero
    // insieme e le combinazioni vere sarebbero quattro invece di sedici.
    final gesto = gesti[_derivato(seme, 1) % gesti.length];
    final respiro = respiri[_derivato(seme, 2) % respiri.length];

    // **LA PAROLA VIENE DAL GESTO, non da un terzo seme. Ordine AS voce 06.**
    //
    // Qui c'era `parole[_derivato(seme, 3) % parole.length]`, cioe' un'estrazione
    // indipendente: il gesto poteva dire "conta quante ore mancano a stasera" e
    // la parola essere "Ombra". Le combinazioni erano sessantaquattro per forma,
    // ma la maggior parte non stava insieme, e la parola del giorno e' proprio
    // la cosa che la persona si porta dietro.
    //
    // Adesso ogni gesto DICHIARA la sua parola nel corpus, e qui la si cerca per
    // nome. Il ripiego sull'indice del gesto esiste come cintura, per il giorno
    // in cui qualcuno scrivesse un gesto con una parola che nella sua forma non
    // c'e': meglio una parola vicina che nessuna parola, e la guardia
    // `test/la_parola_appartiene_al_gesto_test.dart` fa in modo che quel giorno
    // non arrivi.
    final parola = parole.firstWhere(
      (p) => p.parola == gesto.parola,
      orElse: () => parole[_derivato(seme, 1) % parole.length],
    );

    final dati = <DatoDelCielo>{gesto.dato};
    if (respiro.dato != null) dati.add(respiro.dato!);
    if (parola.dato != null) dati.add(parola.dato!);

    return RitoDiOggi(
      maestro: maestro,
      forma: forma.nome,
      // **LA RISPOSTA NASCE DAL FATTO CHE IL GESTO NOMINA**, non da un quarto
      // seme. Ordine CO voce 17: e' la stessa lezione della voce AS.06, dove
      // la parola del giorno si estraeva per conto suo e usciva un rito che
      // diceva "conta le ore che mancano a stasera" con la parola "Ombra".
      // Il fatto del cielo e' uno solo per rito, ed e' quello: la risposta lo
      // nomina, il gesto lo usa, la parola gli appartiene.
      risposta: RispostaDelDono.perIlRisveglio(
        maestro: maestro,
        fatto: gesto.dato,
        parola: parola.parola,
        valoreDelFatto: cielo.valoreDi(gesto.dato),
      ),
      gesto: _riempi(gesto.testo, cielo),
      viaTattile: gesto.viaTattile,
      // IL RESPIRO SI LEGGE IN PAROLE, e le cifre in coda se ne vanno.
      //
      // Qui il testo finiva con "(6 tempi, 3 giri)", che ripeteva in cifre
      // cio' che la frase aveva appena detto in parole: "sei tempi dentro e
      // sei fuori, tre volte". Due volte la stessa cosa, e la seconda in una
      // forma da manuale d'istruzioni. I numeri restano dove servono davvero,
      // cioe' in `respiro.tempi` e `respiro.giri`, che sono i dati con cui il
      // simbolo si muove: al testo non serve ripeterli.
      respiro: respiro.testo,
      tempi: respiro.tempi,
      giri: respiro.giri,
      parola: parola.parola,
      perche: parola.perche,
      datiNominati: dati,
    );
  }

  /// LE TRE RIGHE CHE LA PERSONA LEGGE PRIMA DI TOCCARE.
  ///
  /// Tre righe, non un regolamento: che esiste una fascia e quale, con l'ora
  /// vera calcolata per lei; cosa riceve chi la rispetta, detto concreto; e che
  /// chi arriva dopo fa il rito lo stesso.
  ///
  /// Senza luogo la fascia non si dichiara e la prima riga cambia: si dice che
  /// serve il luogo di nascita, invece di inventare un'ora.
  static List<String> avvisoDellaFascia(FasciaDelRisveglio fascia) {
    if (!fascia.dichiarabile) {
      return const [
        'Per calcolare la tua fascia del risveglio mi serve sapere dove sei '
            'stamattina: senza la posizione non posso dirti a che ora sorge il '
            'sole da te. Un\'ora sbagliata non te la voglio dire.',
        'Chi compie il rito nella prima ora dopo il proprio sorgere del sole '
            'riceve una riga in più dal Maestro del giorno.',
        'Il rito resta comunque intero: non manca niente altro.',
      ];
    }
    return [
      'Oggi il sole sorge da te alle ${fascia.oraDiInizio}: la fascia del '
          'risveglio va fino alle ${fascia.oraDiFine}.',
      'Chi compie il rito dentro la fascia riceve una riga in più dal '
          'Maestro del giorno, che gli altri non ricevono.',
      'Chi arriva dopo compie il rito per intero: manca solo quella riga.',
    ];
  }

  /// LA RIGA IN PIU', solo per chi e' dentro la fascia.
  ///
  /// Torna null fuori fascia, e null anche quando la fascia non e'
  /// dichiarabile: senza un'ora vera non c'e' un dentro e un fuori.
  static String? rigaDelRisveglio(
    DateTime istante,
    Maestro maestro,
    FasciaDelRisveglio fascia,
  ) {
    if (!fascia.contiene(istante)) return null;
    final righe = RitoAlbaCorpus.righeDelRisveglio[maestro]!;
    return righe[_derivato(_seme(istante, maestro, null), 4) % righe.length];
  }

  /// Mette i valori veri al posto dei segnaposto.
  static String _riempi(String testo, CieloDiStamattina cielo) {
    var esito = testo;
    for (final dato in DatoDelCielo.values) {
      esito = esito.replaceAll(dato.segnaposto, cielo.valoreDi(dato));
    }
    return esito;
  }

  /// Il seme del giorno per un Maestro.
  ///
  /// **Perche' un'altra hash e non una gia' scritta.** In `lib/core/rituals`
  /// ce ne sono gia' due private, in `sunset_rune.dart` e in
  /// `guide_animal_day.dart`, ma lavorano su tipi diversi (una su stringa, una
  /// su lista di interi) e sono private. Riscriverle per unificarle
  /// cambierebbe la runa e l'animale che escono a tutti, che e' un cambiamento
  /// di comportamento che quest'ordine non chiede. Resta un debito dichiarato:
  /// una porta sola per il seme del giorno merita un ordine suo.
  /// Il seme del rito. **Dal 30 agosto 2026 ci entra anche il segno solare
  /// di nascita**, ordine CE voce 13: il quarto fumetto del tutorial
  /// promette che i cinque Doni nascono "incrociando il Cielo di oggi e la
  /// tua Carta natale", e questo Dono l\'incrocio ce l\'aveva soltanto nella
  /// scheda "da dove nasce": chi lo compiva non incontrava mai la propria
  /// carta dentro cio' che leggeva. Il gesto, il respiro e la parola
  /// nascono adesso anche dal suo Sole.
  ///
  /// **Chi non ha dato la nascita non perde il Dono**: senza segno la
  /// chiave e' esattamente quella di prima.
  static int _seme(DateTime giorno, Maestro maestro, Zodiac? soleNatale) {
    final chiave = '${giorno.year}-${giorno.month}-${giorno.day}|'
        '${maestro.name}'
        '${soleNatale == null ? '' : '|${soleNatale.name}'}';
    var hash = 0x811c9dc5;
    for (final unita in chiave.codeUnits) {
      hash = (hash ^ unita) & 0xFFFFFFFF;
      hash = _moltiplica32(hash, 0x01000193);
    }
    return hash & 0xFFFFFFFF;
  }

  static int _derivato(int seme, int indice) {
    var hash = seme ^ (indice * 0x9E3779B1);
    hash = _moltiplica32(hash & 0xFFFFFFFF, 0x01000193);
    return hash & 0xFFFFFFFF;
  }

  /// Moltiplicazione a 32 bit esatta anche dove gli interi sono a doppia
  /// precisione, come sul web.
  static int _moltiplica32(int a, int b) {
    final aLo = a & 0xFFFF;
    final aHi = (a >> 16) & 0xFFFF;
    final lo = aLo * b;
    final hi = ((aHi * b) & 0xFFFF) << 16;
    return (lo + hi) & 0xFFFFFFFF;
  }
}
