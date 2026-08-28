import '../assets/family_image.dart';
import '../astro/data_italiana.dart';
import '../astro/zodiac.dart';

/// QUANTO E' SOLIDA L'ORA DI NASCITA DI UN VIP.
///
/// **Esiste perche' un'ora sbagliata e' peggio di un'ora mancante.**
/// L'Ascendente si sposta di un grado ogni quattro minuti: dichiarare un'ora
/// che nessuno ha mai verificato vorrebbe dire costruire mezza lettura su un
/// numero inventato, e l'ordine BO lo vieta con la voce V4. I quattro gradi
/// ricalcano la scala che gli archivi astrologici usano da sempre.
enum AffidabilitaDellOra {
  /// Da un registro o da un atto: l'ora e' un fatto.
  certificata,

  /// Dichiarata pubblicamente dalla persona o da un familiare.
  dichiarata,

  /// Da una fonte biografica che non cita nessun registro.
  approssimata,

  /// Nessuna fonte. **Non si inventa**: la lettura lo dichiara e parla ai
  /// pianeti lenti.
  ignota,
}

/// L'ora di nascita col grado di affidabilita' della sua fonte.
class OraDiNascita {
  const OraDiNascita({
    required this.ore,
    required this.minuti,
    required this.affidabilita,
  });

  /// L'ora che non si conosce, che nel catalogo di oggi sono tutte e cinquanta.
  const OraDiNascita.ignota()
      : ore = null,
        minuti = null,
        affidabilita = AffidabilitaDellOra.ignota;

  final int? ore;
  final int? minuti;
  final AffidabilitaDellOra affidabilita;

  /// Vera solo quando c'e' un'ora E una fonte che la regge.
  bool get eNota =>
      ore != null && affidabilita != AffidabilitaDellOra.ignota;
}

/// Un luogo con le sue coordinate: serve alla carta e alla distanza.
class LuogoDelVip {
  const LuogoDelVip({
    required this.nome,
    required this.nazione,
    required this.latitudine,
    required this.longitudine,
  });

  final String nome;
  final String nazione;
  final double latitudine;
  final double longitudine;

  /// Come si scrive a video: "Los Angeles, Stati Uniti".
  String get esteso => '$nome, $nazione';
}

/// Se il VIP e' in vita. **Non e' un dettaglio di contorno**: e' la voce che
/// decide se la domanda dell'app e' "vi incontrerete" oppure "cosa ti ha
/// lasciato", ordine BO voce 04.
enum StatoInVita { inVita, scomparso }

/// QUANTO IL VIP SI FA VEDERE IN PUBBLICO, su una scala dichiarata.
///
/// **Non e' un dato sulla persona, e' una scala di questa app**, e per questo
/// la sua fonte e' [FonteDelDato.scalaDelCerchio] e non una biografia. La
/// regola e' quella dell'ordine: chi fa tour, concerti e gare sta in alto, chi
/// non si mostra sta in basso. Il grado di partenza viene dalla categoria
/// (Musica e Sport in cima, Cinema sotto, Icone al centro, Impresa in fondo) e
/// si scosta solo dove l'attivita' pubblica lo dice chiaramente.
enum EsposizionePubblica {
  altissima(1.0, 'si vede in pubblico quasi ogni settimana'),
  alta(0.7, 'si vede spesso, fra set e apparizioni'),
  media(0.45, 'si vede a eventi e occasioni'),
  bassa(0.2, 'si mostra di rado'),
  riservata(0.05, 'non si mostra');

  const EsposizionePubblica(this.peso, this.comeSiDice);

  /// Quanto pesa nel calcolo dell'incontro, fra 0 e 1.
  final double peso;

  /// Come si dice nella riga che spiega il numero.
  final String comeSiDice;
}

/// I campi del dossier che devono portare una fonte. Chi ne aggiunge uno lo
/// aggiunge anche qui, e la prova lo pretende.
enum CampoDelVip { data, ora, luogoDiNascita, cittaDiOggi, statoInVita, esposizione }

/// DA DOVE VIENE UN DATO. Ordine BO, vincolo V4: solo fonti pubbliche, e ogni
/// dato porta la sua.
enum FonteDelDato {
  corpusDelCerchio(
      'il corpus docs/corpus/vip.json, dove la data di nascita è già '
      'verificata'),
  biografiaPubblica('biografie e stampa pubbliche'),
  archivioAstrologico('un archivio astrologico che cita il registro'),
  luoghiDelCerchio('assets/data/luoghi.csv, le coordinate già nel repository'),
  scalaDelCerchio('la scala di esposizione dichiarata da questa app');

  const FonteDelDato(this.comeSiCita);

  final String comeSiCita;
}

/// Un VIP del cerchio per la Sinastria VIP.
///
/// **Il dossier si e' allargato con l'ordine BO voce 01**, e non per gusto di
/// completezza: finche' del VIP si sapeva solo il segno solare, cinquanta
/// personaggi davano allo stesso utente **93 coppie di responsi identici**, la
/// possibilita' di incontro non conosceva ne' la citta' ne' se la persona
/// fosse ancora viva, e l'app prometteva un incontro a chi sceglieva Giorgio
/// Armani. Adesso il dossier porta la data intera, il luogo con le coordinate,
/// la citta' di oggi quando e' pubblica, lo stato in vita, l'esposizione e
/// **una fonte per ogni campo compilato**.
///
/// **DOVE UN DATO NON C'E' NON SI INVENTA.** Il campo resta vuoto e il codice
/// sa comportarsi senza: e' la ragione per cui l'ora di nascita di tutti e
/// cinquanta e' [OraDiNascita.ignota]. Nessuna delle fonti pubbliche a
/// disposizione cita un registro, e un'ora indovinata sposterebbe
/// l'Ascendente di gradi interi.
class Vip {
  /// **QUANTI GIORNI VALE UN FATTO.** Novanta, dal corpus: oltre, il fatto
  /// non e' piu' attualita' ed e' meglio non dirlo che dirlo vecchio.
  static const int giorniDiValidita = 90;

  const Vip({
    required this.name,
    required this.sign,
    required this.annoDiNascita,
    required this.meseDiNascita,
    required this.giornoDiNascita,
    required this.statoInVita,
    required this.esposizione,
    required this.fonti,
    this.category = '',
    this.attualita = '',
    this.attualitaVerificataIl,
    this.stem,
    this.ora = const OraDiNascita.ignota(),
    this.luogoDiNascita,
    this.luogoDiOggi,
    this.annoDellaScomparsa,
  });

  final String name;
  final Zodiac sign;

  /// La data di nascita, in tre pezzi perche' il catalogo resti costante.
  final int annoDiNascita;
  final int meseDiNascita;
  final int giornoDiNascita;

  /// L'ora, quando una fonte la regge. Ignota per tutti e cinquanta, oggi.
  final OraDiNascita ora;

  final LuogoDelVip? luogoDiNascita;

  /// Dove vive oggi, quando e' pubblicamente noto. Nullo per chi non lo
  /// dichiara, e il calcolo dell'incontro sa comportarsi senza.
  final LuogoDelVip? luogoDiOggi;

  final StatoInVita statoInVita;

  /// L'anno della scomparsa, per chi non c'e' piu'. Nullo per gli altri.
  final int? annoDellaScomparsa;

  final EsposizionePubblica esposizione;

  /// La fonte di ogni campo compilato. La prova cade se ne manca una.
  final Map<CampoDelVip, FonteDelDato> fonti;

  /// **L'ATTUALITA' DEL PERSONAGGIO. Ordine CA voce 05.**
  ///
  /// Un solo fatto pubblico e professionale, breve, con accanto il giorno in
  /// cui e' stato verificato. **Nel catalogo compilato e' VUOTA per tutti e
  /// cinquanta**, e non e' una dimenticanza: il corpus dice che il fatto "lo
  /// scrive chi aggiorna il catalogo", e chi aggiorna non e' un modello
  /// lasciato libero di raccontare la vita di una persona. Il fatto arriva
  /// dal server, dalla stessa strada che gia' corregge lo stato in vita
  /// (`CorrezioniDeiVip`), come DATO VERIFICABILE e non come frase generata.
  ///
  /// Quando manca, o e' piu' vecchia di novanta giorni, il testo la salta e
  /// nessuno se ne accorge: la frase regge lo stesso.
  final String attualita;

  /// Il giorno in cui l'attualita' e' stata verificata. Nullo quando non c'e'.
  final DateTime? attualitaVerificataIl;

  /// Categoria del VIP, per il banner basso della card. Vuota se non nota.
  final String category;

  /// Nome del file del ritratto senza estensione, oppure null se non agganciato.
  final String? stem;

  /// **IL MOMENTO DI NASCITA, UNA VOLTA SOLA.** Quando l'ora non e' nota si
  /// ancora a mezzogiorno, esattamente come fa `BirthIdentity.fromParts` con
  /// chi la propria ora non l'ha data: due punti dell'app che trattano la
  /// stessa incertezza allo stesso modo.
  DateTime get momentoDiNascita => DateTime.utc(
        annoDiNascita,
        meseDiNascita,
        giornoDiNascita,
        ora.eNota ? ora.ore! : 12,
        ora.eNota ? (ora.minuti ?? 0) : 0,
      );

  /// Vero se il VIP non e' piu' in vita.
  ///
  /// **PASSA DALLE CORREZIONI DEL SERVER, ordine BX voce 09, quarto rilievo.**
  /// Il catalogo e' una costante Dart: prima di quest'ordine lo stato in vita
  /// di una persona poteva cambiare SOLO pubblicando una versione nuova
  /// dell'app, e per una persona famosa che muore quella e' una bugia a
  /// schermo per tutto il tempo che passa fra il fatto e la pubblicazione.
  /// **Verificato, non dedotto**: `vips` e' `static const List<Vip>`, quindi
  /// nessuna riga di codice puo' cambiarne un campo a runtime.
  ///
  /// Adesso il server puo' correggere lo stato, e la correzione arriva con
  /// `statoDelCerchio`, che l'app chiede a ogni apertura. Il catalogo resta la
  /// verita' di partenza; la correzione e' l'ultima parola.
  bool get eScomparso =>
      CorrezioniDeiVip.statoDi(name, statoInVita) == StatoInVita.scomparso;

  /// La data di nascita per esteso, in italiano.
  ///
  /// **Era un campo, ed e' diventata una lettura.** La data viveva due volte,
  /// come stringa in `note` e implicitamente nel segno: due copie della stessa
  /// cosa divergono sempre. Adesso la stringa nasce dai tre numeri.
  String get note => dataItalianaEstesa(
      DateTime(annoDiNascita, meseDiNascita, giornoDiNascita));

  /// Percorso della miniatura del ritratto, per il picker e la card.
  String? get thumbPath =>
      stem == null ? null : FamilyImage.thumb(AssetFamily.vip, stem!);

  /// Percorso del ritratto pieno, per la vista a fuoco o ingrandita.
  String? get fullPath =>
      stem == null ? null : FamilyImage.full(AssetFamily.vip, stem!);

  /// **L'ATTUALITA' CHE VALE ADESSO**, o nulla.
  ///
  /// Torna il fatto solo se c'e', se la sua data di verifica c'e', se non e'
  /// piu' vecchia di [giorniDiValidita], e se la persona e' ancora in vita:
  /// per chi non c'e' piu' il corpus vuole il passato e nessuna attualita'.
  /// La correzione del server vince sul catalogo, come per lo stato in vita.
  String? attualitaAl(DateTime adesso) {
    if (eScomparso) return null;
    final dalServer = CorrezioniDeiVip.attualitaDi(name);
    final testo = dalServer?.testo ?? attualita;
    final quando = dalServer?.verificataIl ?? attualitaVerificataIl;
    if (testo.trim().isEmpty || quando == null) return null;
    final giorni = adesso.difference(quando).inDays;
    if (giorni < 0 || giorni > giorniDiValidita) return null;
    return testo.trim();
  }

  bool get hasImage => stem != null;
  bool get hasCategory => category.isNotEmpty;

  /// I campi compilati di questo dossier: la prova pretende che ognuno abbia
  /// la sua fonte, e questa lista e' cio' che confronta.
  List<CampoDelVip> get campiCompilati => [
        CampoDelVip.data,
        if (ora.eNota) CampoDelVip.ora,
        if (luogoDiNascita != null) CampoDelVip.luogoDiNascita,
        if (luogoDiOggi != null) CampoDelVip.cittaDiOggi,
        CampoDelVip.statoInVita,
        CampoDelVip.esposizione,
      ];
}

/// I 50 VIP precaricati per la Sinastria, dal corpus `docs/corpus/vip.json`,
/// ognuno col ritratto bundlato, il segno solare dalla data reale e il dossier
/// dell'ordine BO voce 01.
class VipCatalog {
  const VipCatalog._();

  static const List<Vip> vips = [
    Vip(
      name: 'Angelina Jolie',
      sign: Zodiac.gemini,
      category: 'Cinema',
      stem: 'vip_angelina-jolie_v1',
      annoDiNascita: 1975,
      meseDiNascita: 6,
      giornoDiNascita: 4,
      luogoDiNascita: LuogoDelVip(nome: 'Los Angeles', nazione: 'Stati Uniti', latitudine: 34.0522, longitudine: -118.2437),
      esposizione: EsposizionePubblica.alta,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'Ariana Grande',
      sign: Zodiac.cancer,
      category: 'Musica',
      stem: 'vip_ariana-grande_v1',
      annoDiNascita: 1993,
      meseDiNascita: 6,
      giornoDiNascita: 26,
      luogoDiNascita: LuogoDelVip(nome: 'Boca Raton', nazione: 'Stati Uniti', latitudine: 26.3683, longitudine: -80.1289),
      esposizione: EsposizionePubblica.altissima,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'Bad Bunny',
      sign: Zodiac.pisces,
      category: 'Musica',
      stem: 'vip_bad-bunny_v1',
      annoDiNascita: 1994,
      meseDiNascita: 3,
      giornoDiNascita: 10,
      luogoDiNascita: LuogoDelVip(nome: 'Vega Baja', nazione: 'Portorico', latitudine: 18.4444, longitudine: -66.3877),
      luogoDiOggi: LuogoDelVip(nome: 'San Juan', nazione: 'Portorico', latitudine: 18.4663, longitudine: -66.1057),
      esposizione: EsposizionePubblica.altissima,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.cittaDiOggi: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'Beyonce',
      sign: Zodiac.virgo,
      category: 'Musica',
      stem: 'vip_beyonce_v1',
      annoDiNascita: 1981,
      meseDiNascita: 9,
      giornoDiNascita: 4,
      luogoDiNascita: LuogoDelVip(nome: 'Houston', nazione: 'Stati Uniti', latitudine: 29.7633, longitudine: -95.3633),
      luogoDiOggi: LuogoDelVip(nome: 'Los Angeles', nazione: 'Stati Uniti', latitudine: 34.0522, longitudine: -118.2437),
      esposizione: EsposizionePubblica.altissima,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.cittaDiOggi: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'Bill Gates',
      sign: Zodiac.scorpio,
      category: 'Impresa',
      stem: 'vip_bill-gates_v1',
      annoDiNascita: 1955,
      meseDiNascita: 10,
      giornoDiNascita: 28,
      luogoDiNascita: LuogoDelVip(nome: 'Seattle', nazione: 'Stati Uniti', latitudine: 47.6062, longitudine: -122.3321),
      luogoDiOggi: LuogoDelVip(nome: 'Medina', nazione: 'Stati Uniti', latitudine: 47.6207, longitudine: -122.2287),
      esposizione: EsposizionePubblica.bassa,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.cittaDiOggi: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'Billie Eilish',
      sign: Zodiac.sagittarius,
      category: 'Musica',
      stem: 'vip_billie-eilish_v1',
      annoDiNascita: 2001,
      meseDiNascita: 12,
      giornoDiNascita: 18,
      luogoDiNascita: LuogoDelVip(nome: 'Los Angeles', nazione: 'Stati Uniti', latitudine: 34.0522, longitudine: -118.2437),
      esposizione: EsposizionePubblica.altissima,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'Brad Pitt',
      sign: Zodiac.sagittarius,
      category: 'Cinema',
      stem: 'vip_brad-pitt_v1',
      annoDiNascita: 1963,
      meseDiNascita: 12,
      giornoDiNascita: 18,
      luogoDiNascita: LuogoDelVip(nome: 'Shawnee', nazione: 'Stati Uniti', latitudine: 35.3273, longitudine: -96.9253),
      esposizione: EsposizionePubblica.alta,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'Chiara Ferragni',
      sign: Zodiac.taurus,
      category: 'Icone',
      stem: 'vip_chiara-ferragni_v1',
      annoDiNascita: 1987,
      meseDiNascita: 5,
      giornoDiNascita: 7,
      luogoDiNascita: LuogoDelVip(nome: 'Cremona', nazione: 'Italia', latitudine: 45.1333, longitudine: 10.0227),
      luogoDiOggi: LuogoDelVip(nome: 'Milano', nazione: 'Italia', latitudine: 45.4642, longitudine: 9.192),
      esposizione: EsposizionePubblica.media,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.cittaDiOggi: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'Damiano David',
      sign: Zodiac.capricorn,
      category: 'Musica',
      stem: 'vip_damiano-david_v1',
      annoDiNascita: 1999,
      meseDiNascita: 1,
      giornoDiNascita: 8,
      luogoDiNascita: LuogoDelVip(nome: 'Roma', nazione: 'Italia', latitudine: 41.9004, longitudine: 12.4957),
      esposizione: EsposizionePubblica.altissima,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'Leonardo DiCaprio',
      sign: Zodiac.scorpio,
      category: 'Cinema',
      stem: 'vip_dicaprio_v1',
      annoDiNascita: 1974,
      meseDiNascita: 11,
      giornoDiNascita: 11,
      luogoDiNascita: LuogoDelVip(nome: 'Los Angeles', nazione: 'Stati Uniti', latitudine: 34.0522, longitudine: -118.2437),
      esposizione: EsposizionePubblica.alta,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'Drake',
      sign: Zodiac.scorpio,
      category: 'Musica',
      stem: 'vip_drake_v1',
      annoDiNascita: 1986,
      meseDiNascita: 10,
      giornoDiNascita: 24,
      luogoDiNascita: LuogoDelVip(nome: 'Toronto', nazione: 'Canada', latitudine: 43.7064, longitudine: -79.3986),
      luogoDiOggi: LuogoDelVip(nome: 'Toronto', nazione: 'Canada', latitudine: 43.7064, longitudine: -79.3986),
      esposizione: EsposizionePubblica.altissima,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.cittaDiOggi: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'Dwayne Johnson',
      sign: Zodiac.taurus,
      category: 'Cinema',
      stem: 'vip_dwayne-johnson_v1',
      annoDiNascita: 1972,
      meseDiNascita: 5,
      giornoDiNascita: 2,
      luogoDiNascita: LuogoDelVip(nome: 'Hayward', nazione: 'Stati Uniti', latitudine: 37.6688, longitudine: -122.0808),
      esposizione: EsposizionePubblica.alta,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'Elon Musk',
      sign: Zodiac.cancer,
      category: 'Impresa',
      stem: 'vip_elon-musk_v1',
      annoDiNascita: 1971,
      meseDiNascita: 6,
      giornoDiNascita: 28,
      luogoDiNascita: LuogoDelVip(nome: 'Pretoria', nazione: 'Sudafrica', latitudine: -25.7449, longitudine: 28.1878),
      luogoDiOggi: LuogoDelVip(nome: 'Austin', nazione: 'Stati Uniti', latitudine: 30.2672, longitudine: -97.7431),
      esposizione: EsposizionePubblica.bassa,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.cittaDiOggi: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'Emma Watson',
      sign: Zodiac.aries,
      category: 'Cinema',
      stem: 'vip_emma-watson_v1',
      annoDiNascita: 1990,
      meseDiNascita: 4,
      giornoDiNascita: 15,
      luogoDiNascita: LuogoDelVip(nome: 'Parigi', nazione: 'Francia', latitudine: 48.8534, longitudine: 2.3488),
      esposizione: EsposizionePubblica.alta,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'Roger Federer',
      sign: Zodiac.leo,
      category: 'Sport',
      stem: 'vip_federer_v1',
      annoDiNascita: 1981,
      meseDiNascita: 8,
      giornoDiNascita: 8,
      luogoDiNascita: LuogoDelVip(nome: 'Basilea', nazione: 'Svizzera', latitudine: 47.5596, longitudine: 7.5886),
      luogoDiOggi: LuogoDelVip(nome: 'Wollerau', nazione: 'Svizzera', latitudine: 47.1833, longitudine: 8.7167),
      esposizione: EsposizionePubblica.media,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.cittaDiOggi: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'Fedez',
      sign: Zodiac.libra,
      category: 'Musica',
      stem: 'vip_fedez_v1',
      annoDiNascita: 1989,
      meseDiNascita: 10,
      giornoDiNascita: 15,
      luogoDiNascita: LuogoDelVip(nome: 'Milano', nazione: 'Italia', latitudine: 45.4642, longitudine: 9.192),
      luogoDiOggi: LuogoDelVip(nome: 'Milano', nazione: 'Italia', latitudine: 45.4642, longitudine: 9.192),
      esposizione: EsposizionePubblica.altissima,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.cittaDiOggi: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'Giorgio Armani',
      sign: Zodiac.cancer,
      category: 'Icone',
      stem: 'vip_giorgio-armani_v1',
      annoDiNascita: 1934,
      meseDiNascita: 7,
      giornoDiNascita: 11,
      luogoDiNascita: LuogoDelVip(nome: 'Piacenza', nazione: 'Italia', latitudine: 45.0526, longitudine: 9.6929),
      esposizione: EsposizionePubblica.riservata,
      statoInVita: StatoInVita.scomparso,
      annoDellaScomparsa: 2025,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'Jeff Bezos',
      sign: Zodiac.capricorn,
      category: 'Impresa',
      stem: 'vip_jeff-bezos_v1',
      annoDiNascita: 1964,
      meseDiNascita: 1,
      giornoDiNascita: 12,
      luogoDiNascita: LuogoDelVip(nome: 'Albuquerque', nazione: 'Stati Uniti', latitudine: 35.0844, longitudine: -106.6504),
      luogoDiOggi: LuogoDelVip(nome: 'Miami', nazione: 'Stati Uniti', latitudine: 25.7743, longitudine: -80.1937),
      esposizione: EsposizionePubblica.bassa,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.cittaDiOggi: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'Kanye West',
      sign: Zodiac.gemini,
      category: 'Musica',
      stem: 'vip_kanye-west_v1',
      annoDiNascita: 1977,
      meseDiNascita: 6,
      giornoDiNascita: 8,
      luogoDiNascita: LuogoDelVip(nome: 'Atlanta', nazione: 'Stati Uniti', latitudine: 33.749, longitudine: -84.388),
      esposizione: EsposizionePubblica.alta,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'Keanu Reeves',
      sign: Zodiac.virgo,
      category: 'Cinema',
      stem: 'vip_keanu-reeves_v1',
      annoDiNascita: 1964,
      meseDiNascita: 9,
      giornoDiNascita: 2,
      luogoDiNascita: LuogoDelVip(nome: 'Beirut', nazione: 'Libano', latitudine: 33.8938, longitudine: 35.5018),
      esposizione: EsposizionePubblica.alta,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'Kim Kardashian',
      sign: Zodiac.libra,
      category: 'Icone',
      stem: 'vip_kim-kardashian_v1',
      annoDiNascita: 1980,
      meseDiNascita: 10,
      giornoDiNascita: 21,
      luogoDiNascita: LuogoDelVip(nome: 'Los Angeles', nazione: 'Stati Uniti', latitudine: 34.0522, longitudine: -118.2437),
      luogoDiOggi: LuogoDelVip(nome: 'Los Angeles', nazione: 'Stati Uniti', latitudine: 34.0522, longitudine: -118.2437),
      esposizione: EsposizionePubblica.media,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.cittaDiOggi: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'Kylie Jenner',
      sign: Zodiac.leo,
      category: 'Icone',
      stem: 'vip_kylie-jenner_v1',
      annoDiNascita: 1997,
      meseDiNascita: 8,
      giornoDiNascita: 10,
      luogoDiNascita: LuogoDelVip(nome: 'Los Angeles', nazione: 'Stati Uniti', latitudine: 34.0522, longitudine: -118.2437),
      luogoDiOggi: LuogoDelVip(nome: 'Los Angeles', nazione: 'Stati Uniti', latitudine: 34.0522, longitudine: -118.2437),
      esposizione: EsposizionePubblica.media,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.cittaDiOggi: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'Lady Gaga',
      sign: Zodiac.aries,
      category: 'Musica',
      stem: 'vip_lady-gaga_v1',
      annoDiNascita: 1986,
      meseDiNascita: 3,
      giornoDiNascita: 28,
      luogoDiNascita: LuogoDelVip(nome: 'New York', nazione: 'Stati Uniti', latitudine: 40.7143, longitudine: -74.006),
      esposizione: EsposizionePubblica.altissima,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'LeBron James',
      sign: Zodiac.capricorn,
      category: 'Sport',
      stem: 'vip_lebron-james_v1',
      annoDiNascita: 1984,
      meseDiNascita: 12,
      giornoDiNascita: 30,
      luogoDiNascita: LuogoDelVip(nome: 'Akron', nazione: 'Stati Uniti', latitudine: 41.0814, longitudine: -81.519),
      luogoDiOggi: LuogoDelVip(nome: 'Los Angeles', nazione: 'Stati Uniti', latitudine: 34.0522, longitudine: -118.2437),
      esposizione: EsposizionePubblica.altissima,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.cittaDiOggi: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'Margot Robbie',
      sign: Zodiac.cancer,
      category: 'Cinema',
      stem: 'vip_margot-robbie_v1',
      annoDiNascita: 1990,
      meseDiNascita: 7,
      giornoDiNascita: 2,
      luogoDiNascita: LuogoDelVip(nome: 'Dalby', nazione: 'Australia', latitudine: -27.1806, longitudine: 151.2622),
      esposizione: EsposizionePubblica.alta,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'Mark Zuckerberg',
      sign: Zodiac.taurus,
      category: 'Impresa',
      stem: 'vip_mark-zuckerberg_v1',
      annoDiNascita: 1984,
      meseDiNascita: 5,
      giornoDiNascita: 14,
      luogoDiNascita: LuogoDelVip(nome: 'White Plains', nazione: 'Stati Uniti', latitudine: 41.034, longitudine: -73.7629),
      luogoDiOggi: LuogoDelVip(nome: 'Palo Alto', nazione: 'Stati Uniti', latitudine: 37.4419, longitudine: -122.143),
      esposizione: EsposizionePubblica.bassa,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.cittaDiOggi: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'Kylian Mbappe',
      sign: Zodiac.sagittarius,
      category: 'Sport',
      stem: 'vip_mbappe_v1',
      annoDiNascita: 1998,
      meseDiNascita: 12,
      giornoDiNascita: 20,
      luogoDiNascita: LuogoDelVip(nome: 'Parigi', nazione: 'Francia', latitudine: 48.8534, longitudine: 2.3488),
      luogoDiOggi: LuogoDelVip(nome: 'Madrid', nazione: 'Spagna', latitudine: 40.4165, longitudine: -3.7026),
      esposizione: EsposizionePubblica.altissima,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.cittaDiOggi: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'Lionel Messi',
      sign: Zodiac.cancer,
      category: 'Sport',
      stem: 'vip_messi_v1',
      annoDiNascita: 1987,
      meseDiNascita: 6,
      giornoDiNascita: 24,
      luogoDiNascita: LuogoDelVip(nome: 'Rosario', nazione: 'Argentina', latitudine: -32.9468, longitudine: -60.6393),
      luogoDiOggi: LuogoDelVip(nome: 'Miami', nazione: 'Stati Uniti', latitudine: 25.7743, longitudine: -80.1937),
      esposizione: EsposizionePubblica.altissima,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.cittaDiOggi: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'Michelle Obama',
      sign: Zodiac.capricorn,
      category: 'Icone',
      stem: 'vip_michelle-obama_v1',
      annoDiNascita: 1964,
      meseDiNascita: 1,
      giornoDiNascita: 17,
      luogoDiNascita: LuogoDelVip(nome: 'Chicago', nazione: 'Stati Uniti', latitudine: 41.85, longitudine: -87.65),
      luogoDiOggi: LuogoDelVip(nome: 'Washington', nazione: 'Stati Uniti', latitudine: 38.8951, longitudine: -77.0364),
      esposizione: EsposizionePubblica.media,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.cittaDiOggi: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'Monica Bellucci',
      sign: Zodiac.libra,
      category: 'Cinema',
      stem: 'vip_monica-bellucci_v1',
      annoDiNascita: 1964,
      meseDiNascita: 9,
      giornoDiNascita: 30,
      luogoDiNascita: LuogoDelVip(nome: 'Città di Castello', nazione: 'Italia', latitudine: 43.465, longitudine: 12.24),
      esposizione: EsposizionePubblica.alta,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'Rafael Nadal',
      sign: Zodiac.gemini,
      category: 'Sport',
      stem: 'vip_nadal_v1',
      annoDiNascita: 1986,
      meseDiNascita: 6,
      giornoDiNascita: 3,
      luogoDiNascita: LuogoDelVip(nome: 'Manacor', nazione: 'Spagna', latitudine: 39.5697, longitudine: 3.2089),
      luogoDiOggi: LuogoDelVip(nome: 'Manacor', nazione: 'Spagna', latitudine: 39.5697, longitudine: 3.2089),
      esposizione: EsposizionePubblica.media,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.cittaDiOggi: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'Oprah Winfrey',
      sign: Zodiac.aquarius,
      category: 'Icone',
      stem: 'vip_oprah-winfrey_v1',
      annoDiNascita: 1954,
      meseDiNascita: 1,
      giornoDiNascita: 29,
      luogoDiNascita: LuogoDelVip(nome: 'Kosciusko', nazione: 'Stati Uniti', latitudine: 33.0576, longitudine: -89.5873),
      luogoDiOggi: LuogoDelVip(nome: 'Montecito', nazione: 'Stati Uniti', latitudine: 34.4367, longitudine: -119.632),
      esposizione: EsposizionePubblica.media,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.cittaDiOggi: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'Priyanka Chopra',
      sign: Zodiac.cancer,
      category: 'Cinema',
      stem: 'vip_priyanka-chopra_v1',
      annoDiNascita: 1982,
      meseDiNascita: 7,
      giornoDiNascita: 18,
      luogoDiNascita: LuogoDelVip(nome: 'Jamshedpur', nazione: 'India', latitudine: 22.8046, longitudine: 86.2029),
      esposizione: EsposizionePubblica.alta,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'Rihanna',
      sign: Zodiac.pisces,
      category: 'Musica',
      stem: 'vip_rihanna_v1',
      annoDiNascita: 1988,
      meseDiNascita: 2,
      giornoDiNascita: 20,
      luogoDiNascita: LuogoDelVip(nome: 'Bridgetown', nazione: 'Barbados', latitudine: 13.1073, longitudine: -59.6202),
      esposizione: EsposizionePubblica.media,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'Cristiano Ronaldo',
      sign: Zodiac.aquarius,
      category: 'Sport',
      stem: 'vip_ronaldo_v1',
      annoDiNascita: 1985,
      meseDiNascita: 2,
      giornoDiNascita: 5,
      luogoDiNascita: LuogoDelVip(nome: 'Funchal', nazione: 'Portogallo', latitudine: 32.6669, longitudine: -16.9241),
      luogoDiOggi: LuogoDelVip(nome: 'Riad', nazione: 'Arabia Saudita', latitudine: 24.6877, longitudine: 46.7219),
      esposizione: EsposizionePubblica.altissima,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.cittaDiOggi: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'Scarlett Johansson',
      sign: Zodiac.sagittarius,
      category: 'Cinema',
      stem: 'vip_scarlett-johansson_v1',
      annoDiNascita: 1984,
      meseDiNascita: 11,
      giornoDiNascita: 22,
      luogoDiNascita: LuogoDelVip(nome: 'New York', nazione: 'Stati Uniti', latitudine: 40.7143, longitudine: -74.006),
      esposizione: EsposizionePubblica.alta,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'Selena Gomez',
      sign: Zodiac.cancer,
      category: 'Musica',
      stem: 'vip_selena-gomez_v1',
      annoDiNascita: 1992,
      meseDiNascita: 7,
      giornoDiNascita: 22,
      luogoDiNascita: LuogoDelVip(nome: 'Grand Prairie', nazione: 'Stati Uniti', latitudine: 32.746, longitudine: -96.9978),
      esposizione: EsposizionePubblica.altissima,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'Serena Williams',
      sign: Zodiac.libra,
      category: 'Sport',
      stem: 'vip_serena-williams_v1',
      annoDiNascita: 1981,
      meseDiNascita: 9,
      giornoDiNascita: 26,
      luogoDiNascita: LuogoDelVip(nome: 'Saginaw', nazione: 'Stati Uniti', latitudine: 43.4195, longitudine: -83.9508),
      esposizione: EsposizionePubblica.media,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'Shakira',
      sign: Zodiac.aquarius,
      category: 'Musica',
      stem: 'vip_shakira_v1',
      annoDiNascita: 1977,
      meseDiNascita: 2,
      giornoDiNascita: 2,
      luogoDiNascita: LuogoDelVip(nome: 'Barranquilla', nazione: 'Colombia', latitudine: 10.9685, longitudine: -74.7813),
      luogoDiOggi: LuogoDelVip(nome: 'Miami', nazione: 'Stati Uniti', latitudine: 25.7743, longitudine: -80.1937),
      esposizione: EsposizionePubblica.altissima,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.cittaDiOggi: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'Jannik Sinner',
      sign: Zodiac.leo,
      category: 'Sport',
      stem: 'vip_sinner_v1',
      annoDiNascita: 2001,
      meseDiNascita: 8,
      giornoDiNascita: 16,
      luogoDiNascita: LuogoDelVip(nome: 'San Candido', nazione: 'Italia', latitudine: 46.7333, longitudine: 12.2833),
      luogoDiOggi: LuogoDelVip(nome: 'Monte Carlo', nazione: 'Monaco', latitudine: 43.7372, longitudine: 7.4215),
      esposizione: EsposizionePubblica.altissima,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.cittaDiOggi: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'Snoop Dogg',
      sign: Zodiac.libra,
      category: 'Musica',
      stem: 'vip_snoop-dogg_v1',
      annoDiNascita: 1971,
      meseDiNascita: 10,
      giornoDiNascita: 20,
      luogoDiNascita: LuogoDelVip(nome: 'Long Beach', nazione: 'Stati Uniti', latitudine: 33.7701, longitudine: -118.1937),
      luogoDiOggi: LuogoDelVip(nome: 'Los Angeles', nazione: 'Stati Uniti', latitudine: 34.0522, longitudine: -118.2437),
      esposizione: EsposizionePubblica.altissima,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.cittaDiOggi: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'Steve Jobs',
      sign: Zodiac.pisces,
      category: 'Impresa',
      stem: 'vip_steve-jobs_v1',
      annoDiNascita: 1955,
      meseDiNascita: 2,
      giornoDiNascita: 24,
      luogoDiNascita: LuogoDelVip(nome: 'San Francisco', nazione: 'Stati Uniti', latitudine: 37.7749, longitudine: -122.4194),
      esposizione: EsposizionePubblica.riservata,
      statoInVita: StatoInVita.scomparso,
      annoDellaScomparsa: 2011,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'Taylor Swift',
      sign: Zodiac.sagittarius,
      category: 'Musica',
      stem: 'vip_taylor-swift_v1',
      annoDiNascita: 1989,
      meseDiNascita: 12,
      giornoDiNascita: 13,
      luogoDiNascita: LuogoDelVip(nome: 'West Reading', nazione: 'Stati Uniti', latitudine: 40.3348, longitudine: -75.9463),
      luogoDiOggi: LuogoDelVip(nome: 'Nashville', nazione: 'Stati Uniti', latitudine: 36.1627, longitudine: -86.7816),
      esposizione: EsposizionePubblica.altissima,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.cittaDiOggi: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'The Weeknd',
      sign: Zodiac.aquarius,
      category: 'Musica',
      stem: 'vip_the-weeknd_v1',
      annoDiNascita: 1990,
      meseDiNascita: 2,
      giornoDiNascita: 16,
      luogoDiNascita: LuogoDelVip(nome: 'Toronto', nazione: 'Canada', latitudine: 43.7064, longitudine: -79.3986),
      esposizione: EsposizionePubblica.altissima,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'Timothee Chalamet',
      sign: Zodiac.capricorn,
      category: 'Cinema',
      stem: 'vip_timothee-chalamet_v1',
      annoDiNascita: 1995,
      meseDiNascita: 12,
      giornoDiNascita: 27,
      luogoDiNascita: LuogoDelVip(nome: 'New York', nazione: 'Stati Uniti', latitudine: 40.7143, longitudine: -74.006),
      esposizione: EsposizionePubblica.alta,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'Tom Cruise',
      sign: Zodiac.cancer,
      category: 'Cinema',
      stem: 'vip_tom-cruise_v1',
      annoDiNascita: 1962,
      meseDiNascita: 7,
      giornoDiNascita: 3,
      luogoDiNascita: LuogoDelVip(nome: 'Syracuse', nazione: 'Stati Uniti', latitudine: 43.0481, longitudine: -76.1474),
      esposizione: EsposizionePubblica.alta,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'Usain Bolt',
      sign: Zodiac.leo,
      category: 'Sport',
      stem: 'vip_usain-bolt_v1',
      annoDiNascita: 1986,
      meseDiNascita: 8,
      giornoDiNascita: 21,
      luogoDiNascita: LuogoDelVip(nome: 'Sherwood Content', nazione: 'Giamaica', latitudine: 18.3667, longitudine: -77.65),
      luogoDiOggi: LuogoDelVip(nome: 'Kingston', nazione: 'Giamaica', latitudine: 17.997, longitudine: -76.7936),
      esposizione: EsposizionePubblica.media,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.cittaDiOggi: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'Valentino Rossi',
      sign: Zodiac.aquarius,
      category: 'Sport',
      stem: 'vip_valentino-rossi_v1',
      annoDiNascita: 1979,
      meseDiNascita: 2,
      giornoDiNascita: 16,
      luogoDiNascita: LuogoDelVip(nome: 'Urbino', nazione: 'Italia', latitudine: 43.7298, longitudine: 12.6356),
      luogoDiOggi: LuogoDelVip(nome: 'Tavullia', nazione: 'Italia', latitudine: 43.8975, longitudine: 12.7517),
      esposizione: EsposizionePubblica.media,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.cittaDiOggi: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'Warren Buffett',
      sign: Zodiac.virgo,
      category: 'Impresa',
      stem: 'vip_warren-buffett_v1',
      annoDiNascita: 1930,
      meseDiNascita: 8,
      giornoDiNascita: 30,
      luogoDiNascita: LuogoDelVip(nome: 'Omaha', nazione: 'Stati Uniti', latitudine: 41.2563, longitudine: -95.9404),
      luogoDiOggi: LuogoDelVip(nome: 'Omaha', nazione: 'Stati Uniti', latitudine: 41.2563, longitudine: -95.9404),
      esposizione: EsposizionePubblica.bassa,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.cittaDiOggi: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),
    Vip(
      name: 'Zendaya',
      sign: Zodiac.virgo,
      category: 'Cinema',
      stem: 'vip_zendaya_v1',
      annoDiNascita: 1996,
      meseDiNascita: 9,
      giornoDiNascita: 1,
      luogoDiNascita: LuogoDelVip(nome: 'Oakland', nazione: 'Stati Uniti', latitudine: 37.8044, longitudine: -122.2712),
      luogoDiOggi: LuogoDelVip(nome: 'Los Angeles', nazione: 'Stati Uniti', latitudine: 34.0522, longitudine: -118.2437),
      esposizione: EsposizionePubblica.alta,
      statoInVita: StatoInVita.inVita,
      fonti: {
        CampoDelVip.data: FonteDelDato.corpusDelCerchio,
        CampoDelVip.luogoDiNascita: FonteDelDato.biografiaPubblica,
        CampoDelVip.cittaDiOggi: FonteDelDato.biografiaPubblica,
        CampoDelVip.statoInVita: FonteDelDato.biografiaPubblica,
        CampoDelVip.esposizione: FonteDelDato.scalaDelCerchio,
      },
    ),  ];

  static Vip get first => vips.first;

  /// Il VIP col nome dato, oppure nullo. Serve alle prove e alle rotte.
  static Vip? conNome(String nome) {
    for (final v in vips) {
      if (v.name == nome) return v;
    }
    return null;
  }

  /// Le categorie distinte presenti nel catalogo, nell'ordine di prima comparsa.
  /// La galleria vi antepone la voce "Tutti".
  static List<String> get categorie {
    final viste = <String>[];
    for (final v in vips) {
      if (v.hasCategory && !viste.contains(v.category)) viste.add(v.category);
    }
    return viste;
  }

  /// Una selezione curata e statica di VIP di richiamo, per la fascia
  /// "In evidenza" della galleria. Otto volti fra le categorie.
  static const List<String> inEvidenzaNomi = [
    'Angelina Jolie',
    'Taylor Swift',
    'Cristiano Ronaldo',
    'Elon Musk',
    'Rihanna',
    'Leonardo DiCaprio',
    'Zendaya',
    'Lionel Messi',
  ];

  static List<Vip> get inEvidenza => [
        for (final nome in inEvidenzaNomi)
          vips.firstWhere((v) => v.name == nome),
      ];
}


/// LE CORREZIONI DEL CATALOGO CHE ARRIVANO DAL SERVER. Ordine BX voce 09.
///
/// **Perche' esiste.** Il catalogo dei VIP e' una costante compilata dentro
/// l'app: il giorno che una persona famosa muore, l'app continua a proporre
/// la possibilita' di incontrarla finche' non esce una versione nuova. Non e'
/// un difetto di gusto, e' una cosa falsa detta a chi legge.
///
/// **Cosa puo' correggere, e cosa no.** Solo lo stato in vita, che e' l'unico
/// campo che cambia da solo nel mondo: la data di nascita e il luogo non
/// cambiano mai, e lasciarli correggibili vorrebbe dire lasciare che il
/// server riscriva l'astrologia di una persona.
///
/// **Vive in memoria e non tocca il disco**: arriva con lo stato a ogni
/// apertura, e senza rete l'app usa il catalogo compilato, che e' l'ultima
/// verita' conosciuta.
class CorrezioniDeiVip {
  const CorrezioniDeiVip._();

  static Map<String, StatoInVita> _correzioni = const {};

  /// Quante correzioni sono in vigore adesso.
  static int get quante => _correzioni.length;

  /// Applica le correzioni arrivate dal server. Una mappa vuota le toglie
  /// tutte, ed e' cio' che deve succedere se il server smette di mandarle.
  static void applica(Map<String, String> dalServer) {
    final lette = <String, StatoInVita>{};
    for (final voce in dalServer.entries) {
      final stato = switch (voce.value.trim().toLowerCase()) {
        'scomparso' => StatoInVita.scomparso,
        'in_vita' || 'invita' || 'vivo' => StatoInVita.inVita,
        _ => null,
      };
      if (stato != null) lette[voce.key] = stato;
    }
    _correzioni = Map.unmodifiable(lette);
  }

  /// Lo stato che vale adesso per quel nome: la correzione se c'e', altrimenti
  /// quello del catalogo.
  static StatoInVita statoDi(String nome, StatoInVita dalCatalogo) =>
      _correzioni[nome] ?? dalCatalogo;

  /// **L'ATTUALITA' ARRIVA DALLA STESSA STRADA. Ordine CA voce 05.**
  ///
  /// Un fatto pubblico e professionale, con la data in cui e' stato
  /// verificato. Il server lo manda dentro `statoDelCerchio`, che l'app chiede
  /// a ogni apertura: nessun canale nuovo, e nessun modello che scrive frasi
  /// sulla vita di qualcuno. Una mappa vuota le toglie tutte.
  static Map<String, AttualitaDelVip> _attualita = const {};

  static void applicaAttualita(Map<String, Map<String, String>> dalServer) {
    final lette = <String, AttualitaDelVip>{};
    for (final voce in dalServer.entries) {
      final testo = (voce.value['testo'] ?? '').trim();
      final quando = DateTime.tryParse(voce.value['verificata_il'] ?? '');
      if (testo.isEmpty || quando == null) continue;
      lette[voce.key] = AttualitaDelVip(testo: testo, verificataIl: quando);
    }
    _attualita = Map.unmodifiable(lette);
  }

  /// L'attualita' che il server dichiara per quel nome, o nulla.
  static AttualitaDelVip? attualitaDi(String nome) => _attualita[nome];

  /// Quante attualita' sono in vigore adesso.
  static int get quanteAttualita => _attualita.length;

  /// Solo per le prove: si riparte dal catalogo nudo.
  static void azzera() {
    _correzioni = const {};
    _attualita = const {};
  }
}

/// UN FATTO PUBBLICO SU UN PERSONAGGIO, con la data in cui e' stato
/// verificato. Ordine CA voce 05.
///
/// **Non e' una notizia di costume**, ed e' la regola che il corpus scrive:
/// contiene un fatto pubblico, professionale e verificabile, mai qualcosa
/// sulla vita privata di nessuno.
class AttualitaDelVip {
  const AttualitaDelVip({required this.testo, required this.verificataIl});

  final String testo;
  final DateTime verificataIl;
}
