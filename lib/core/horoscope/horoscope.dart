import '../tempo/confine_del_giorno.dart';
import 'il_livello_del_cielo.dart';
import 'il_numero_e_il_colore.dart';
import '../astro/night_sky.dart';
import '../astro/zodiac.dart';
import '../chat/user_profile.dart';
import 'cielo_di_oggi.dart';
import 'corrente_del_cielo.dart';
import 'horoscope_data.dart';
import 'i_testi_eu.dart';
import '../astro/natal_chart.dart';
import '../astro/transiti_del_giorno.dart';

/// I quattro domini dell'Oroscopo, nell'ordine di layout. L'indice enum e' anche
/// l'intero fisso del dominio: Generale 0, Amore 1, Carriera 2, Fortuna 3.
enum HoroscopeDomain {
  generale('Generale'),
  amore('Amore'),
  carriera('Carriera'),
  fortuna('Fortuna');

  const HoroscopeDomain(this.label);

  final String label;
}

/// Una scheda dell'Oroscopo, gia' composta e deterministica: titolo del dominio
/// per quel segno, testo (ancora del segno piu' corrente del giorno), indicatore
/// da due a cinque. Solo la scheda Fortuna porta numero fortunato e colore.
class HoroscopeCard {
  const HoroscopeCard({
    required this.domain,
    required this.title,
    required this.text,
    required this.synthesis,
    required this.indicator,
    this.opening,
    this.luckyNumber,
    this.dayColor,
    this.dalCieloVero = false,
    this.rigaDelLivello,
    this.rigaDellaFortuna,
    this.metodo,
    this.numeriDelGiorno,
    this.rigaSoloDelLivello,
  });

  /// **LA SOLA RIGA DEL LIVELLO**, ordine EU voce 02: nella Settimana e nel
  /// Mese della Vedica e della Cinese ogni giorno porta, sotto la sua data,
  /// la riga che dice da dove viene il suo livello. La riga intera di "Da
  /// dove viene" dice "oggi" e "di oggi", ed era giusta solo sotto il Giorno
  /// (la stessa svista dell'Occidentale, corretta con l'ordine ES): questa e'
  /// la riga del livello detta per il giorno della sua data. Null dove la
  /// scheda non la distingue.
  final String? rigaSoloDelLivello;

  /// **IL METODO DI QUESTA SCHEDA, quando non e' quello occidentale.** Ordine
  /// ES voce 08: la lettura cinese porta la sua nota (l'almanacco, i Dieci
  /// Dei), e il punto interrogativo della scheda la mostra al posto di quella
  /// del cielo occidentale. Null vuol dire la nota occidentale.
  final String? metodo;

  /// **I NUMERI DELL'ELEMENTO**, ordine ES voce 08: nella tradizione cinese
  /// sono due, quelli dello He Tu (il legno ha il 3 e l'8). Null nella
  /// lettura occidentale, che ha il solo [luckyNumber].
  final List<int>? numeriDelGiorno;

  /// **LA REGOLA DEL NUMERO E DEL COLORE, ordine ES voce 29**, solo sulla
  /// scheda della Fortuna: "Il numero è il tuo giorno personale... Il colore
  /// è quello di Venere, il pianeta del passaggio più stretto di oggi."
  final String? rigaDellaFortuna;

  /// **DA DOVE VIENE IL LIVELLO, ordine ES voce 28.** La riga sotto
  /// l'indicatore: "Dal cielo di oggi: Venere in trigono al tuo Sole di
  /// nascita." oppure "Dalla Luna di oggi in Bilancia, nella tua settima casa
  /// solare, in opposizione al tuo segno."
  final String? rigaDelLivello;

  final HoroscopeDomain domain;
  final String title;
  final String text;

  /// La prima parte della scheda, senza la corrente del giorno. **Dall'ordine
  /// ER voce 14 cambia ogni giorno** (era la sintesi fissa del segno).
  ///
  /// **Esiste per chiudere una porta.** La card da condividere mostrava questa
  /// frase rileggendosela da `HoroscopeData.anchors` per conto suo, cioe' alle
  /// spalle di `Horoscope`: chi avesse sostituito la composizione avrebbe
  /// cambiato lo schermo e lasciato l'immagine condivisa col testo vecchio,
  /// che e' l'angolo peggiore in cui restare indietro, perche' e' quello che
  /// la gente manda agli altri. Adesso la frase esce da qui, e chi cambia la
  /// composizione la cambia in tutti e due i posti.
  final String synthesis;

  /// L'apertura personalizzata col nome, solo sulla scheda Generale: si mostra
  /// prima del testo. Null sulle altre schede.
  final String? opening;

  /// Unita' piene dell'indicatore, sempre da 2 a 5.
  final int indicator;

  /// Numero fortunato da 1 a 90, solo per la scheda Fortuna.
  final int? luckyNumber;

  /// Colore del giorno, dalla palette del segno, solo per la scheda Fortuna.
  final String? dayColor;

  /// SE LA SECONDA META' DEL TESTO VIENE DAL CIELO VERO.
  ///
  /// **Serve perche' il ripiego non sia mai muto.** Falso vuol dire che la
  /// corrente del giorno e' stata pescata dalla hash su segno, giorno e anno,
  /// cioe' che il cielo di questa persona non e' stato interrogato perche' non
  /// c'era una carta natale da interrogare. Chi mostra la scheda deve
  /// dichiararlo, e c'e' una prova che casca se non lo fa.
  final bool dalCieloVero;

  /// LA RIGA DEL CIELO, separata dalla sintesi dell'ancora. Ordine P voce 25.
  ///
  /// **Non e' un campo nuovo: e' il testo che c'e' gia', letto per quello che
  /// e'.** Il testo di una scheda nasce come sintesi dell'ancora piu' la riga
  /// del cielo di oggi, e la sintesi la scheda ce l'ha per suo conto: la riga
  /// del cielo e' cio' che resta. Aggiungere un campo avrebbe voluto dire
  /// scrivere due volte la stessa stringa.
  ///
  /// Nulla quando la scheda non viene dal cielo vero: in quel caso non c'e'
  /// nessun transito da mostrare, e mostrarne uno finto sarebbe peggio di non
  /// mostrarlo.
  ///
  /// **DALLA EU AGGIUNTA il cielo non sta piu' nel testo**: sta solo in "Da
  /// dove viene" (voce EU.01). La riga del cielo e' quindi [rigaDelLivello],
  /// quando viene dal cielo vero.
  String? get rigaDelCielo => dalCieloVero ? rigaDelLivello : null;
}

/// La composizione deterministica dell'Oroscopo a quattro schede.
///
/// Tutto nasce da interi (indice del segno, giorno ordinale, anno, dominio) via
/// una hash stabile FNV-1a: stesso ingresso, stessa uscita, su ogni piattaforma
/// e a ogni apertura. Niente Random, niente ora, niente fuso, niente
/// [DateTime.now] dentro l'hash. Il giorno si legge una sola volta a livello di
/// schermata e si passa come intero.
class Horoscope {
  const Horoscope._();

  /// Unita' massime dell'indicatore.
  static const int indicatorMax = 5;

  /// Giorno ordinale nell'anno (0 il primo gennaio), come i riti del giorno.
  /// Viene dalla porta unica, `ConfineDelGiorno.giornoDellAnno`.
  ///
  /// **Prima sottraeva due date, ed era un difetto misurato.** Ordine BK voce
  /// 06: `date.difference(DateTime(date.year)).inDays` misura una durata, e
  /// con l'ora legale di mezzo la durata non e' un multiplo di ventiquattro
  /// ore. Con `TZ=Europe/Rome`, alle 00:00 del 5 agosto 2026 dava 215 e dalle
  /// 01:00 dava 216: il responso dell'Oroscopo cambiava alle una di notte, e
  /// per la prima ora del giorno mostrava ancora quello di ieri. La premessa
  /// dell'ordine, cioe' che la regola del responso stabile esistesse gia',
  /// era falsa per i sette mesi dell'ora legale, e il numero l'ha detto.
  static int dayOfYear(DateTime date) => ConfineDelGiorno.giornoDellAnno(date);

  // Moltiplicazione a 32 bit esatta anche dove gli interi sono a doppia
  // precisione (web): si divide l'operando in due meta' da 16 bit cosi' nessun
  // prodotto intermedio supera i 2^53 bit sicuri. Su mobile gli interi sono a 64
  // bit e il risultato coincide.
  static int _mul32(int a, int b) {
    final aLo = a & 0xFFFF;
    final aHi = (a >> 16) & 0xFFFF;
    final lo = aLo * b;
    final hi = ((aHi * b) & 0xFFFF) << 16;
    return (lo + hi) & 0xFFFFFFFF;
  }

  /// Hash FNV-1a a 32 bit su una sequenza di interi, byte per byte.
  static int _fnv1a(List<int> values) {
    var hash = 0x811c9dc5;
    for (final v in values) {
      final x = v & 0xFFFFFFFF;
      for (var i = 0; i < 4; i++) {
        final byte = (x >> (8 * i)) & 0xFF;
        hash = (hash ^ byte) & 0xFFFFFFFF;
        hash = _mul32(hash, 0x01000193);
      }
    }
    return hash & 0xFFFFFFFF;
  }

  /// Il seme di base per (segno, giorno, anno, dominio).
  static int baseSeed(
          int signIndex, int dayOfYear, int year, int domainIndex) =>
      _fnv1a([signIndex, dayOfYear, year, domainIndex]);

  /// Il vocativo con cui aprire l'oroscopo: Caro o Cara piu' il nome quando il
  /// genere e' noto dall'onboarding, altrimenti Ciao piu' il nome.
  ///
  /// **UNA MARCA**, ordine DL voce 06: la parola si risolve prima di
  /// attaccare il nome, cosi' un nome non puo' diventare una marca.
  static String vocativeFor(String name, CourtesyForm courtesy) =>
      '${courtesy.risolvi('[Caro|Cara|Ciao]')} $name';

  /// L'apertura personalizzata del giorno, pescata dal pool del corpus con lo
  /// stesso seme del giorno: deterministica e riproducibile. Quando Gemini e'
  /// acceso l'apertura la personalizza lui, questa resta il fallback.
  static String openingFor({
    required Zodiac sign,
    required int dayOfYear,
    required int year,
    required String vocative,
  }) {
    final base = baseSeed(sign.index, dayOfYear, year, 0);
    final seed = _fnv1a([base, 0x55]);
    final template =
        HoroscopeData.openings[seed % HoroscopeData.openings.length];
    return template.replaceAll(HoroscopeData.namePlaceholder, vocative);
  }

  /// **LA CASA CHE LA LUNA ATTRAVERSA**, contata dal segno solare: 0 vuol dire
  /// la casa 1 (la Luna nel segno), 11 la casa 12. Ordine ER voce 14.
  ///
  /// E' la tecnica tradizionale dei transiti lunari nelle case solari, e si
  /// calcola sul dispositivo dalle effemeridi della Luna ([NightSky]) a
  /// mezzogiorno del giorno dato: nessun modello e nessuna rete.
  static int casaDellaLuna(Zodiac sign, int dayOfYear, int year) {
    final mezzogiorno =
        DateTime.utc(year).add(Duration(days: dayOfYear, hours: 12));
    return (NightSky.moonSign(mezzogiorno).index - sign.index) % 12;
  }

  /// **LA VARIANTE DEL GIORNO**, fra le tre di ogni casa. Il resto della
  /// divisione per tre del giorno dell'anno: due giorni di fila non hanno mai
  /// lo stesso resto, nemmeno a capodanno (364 e 365 danno 1 e 2, il primo
  /// gennaio 0). La Luna resta in una casa al piu' tre giorni: nella stessa
  /// casa due giorni vicini leggono varianti diverse, in due case diverse
  /// leggono testi diversi. **Cosi' titolo e prima parte non sono mai quelli
  /// del giorno prima**, e sono gli stessi fino a mezzanotte.
  static int varianteDelGiorno(int dayOfYear) => dayOfYear % 3;

  /// **LA LETTURA DEL GIORNO IN PAROLE**, per un dominio: il titolo e la
  /// prima parte che la scheda di quel giorno portera' (ordine ER voce 14),
  /// scelti dalla casa che la Luna attraversa contando dal segno e dalla
  /// variante del giorno. La chiamano la scheda del Giorno e le righe dei
  /// giorni della Settimana e del Mese: chi apre la settimana legge per
  /// sabato la stessa frase che sabato trovera' nella scheda.
  static (String, String) letturaDelGiorno(
      Zodiac sign, HoroscopeDomain domain, int dayOfYear, int year) {
    final casa = casaDellaLuna(sign, dayOfYear, year);
    final variante = varianteDelGiorno(dayOfYear);
    return (
      HoroscopeData.titoliDelGiorno[domain.index]![casa][variante],
      HoroscopeData.primeDelGiorno[domain.index]![casa][variante],
    );
  }

  /// Compone la scheda di un dominio per il segno e il giorno dati.
  ///
  /// **TITOLO E PRIMA PARTE SONO DEL GIORNO. Ordine ER voce 14, 27 settembre
  /// 2026.** Il fondatore: *"la prima metà delle schede, oggi uguale tutti i
  /// giorni"*. Prima venivano dalle ancore fisse del segno
  /// (`HoroscopeData.anchors`), identiche ogni giorno per lo stesso segno e
  /// dominio; cambiava solo la corrente che le seguiva. Adesso li sceglie la
  /// casa che la Luna attraversa quel giorno contando dal segno
  /// ([casaDellaLuna]), con la variante del giorno ([varianteDelGiorno]). La
  /// via e' quella del progetto, il sistema a scheletri: testi del corpus
  /// scelti dal cielo vero, senza modello, a costo zero.
  ///
  /// **DOVE MUORE L'HASH.** Con un [cielo] che porta fatti veri, la corrente
  /// del giorno la scrive [CorrenteDelCielo] nominando il pianeta, la casa
  /// attraversata e il punto natale toccato. Senza, si torna alla hash su
  /// segno, giorno e anno, e la scheda esce con [HoroscopeCard.dalCieloVero]
  /// falso, cosi' chi la mostra e' obbligato a dichiarare il ripiego.
  ///
  /// **La porta e' UNA SOLA, e sono due chi la attraversa**: la schermata
  /// dell'Oroscopo e la card da condividere, che pero' riceve gia' le schede
  /// composte qui invece di rileggersi il corpus per conto suo. Cambiare la
  /// composizione le cambia tutte e due.
  static HoroscopeCard cardFor({
    required Zodiac sign,
    required int dayOfYear,
    required int year,
    required HoroscopeDomain domain,
    String? opening,
    CieloDiOggi cielo = CieloDiOggi.nessuno,
    bool profonda = false,
    DateTime? nascita,
    String? vocativo,
  }) {
    // **IL LIVELLO DAL CIELO VERO, ordine ES voce 28.** Era
    // `2 + (seed % 4)`, una hash uguale per tutto il segno anche con la carta
    // natale. Adesso lo fanno gli aspetti del giorno che parlano al dominio,
    // o senza carta la Luna di oggi nelle case solari: vedi
    // [IlLivelloDelCielo]. La scala resta da due a cinque.
    final quando = DateTime.utc(year).add(Duration(days: dayOfYear, hours: 12));
    final (indicator, rigaDelLivello) = IlLivelloDelCielo.per(
        dominio: domain, segno: sign, cielo: cielo, quando: quando);

    // **I TESTI DELL'ARCHITETTO, EU Aggiunta, 1 ottobre 2026.** Il fondatore:
    // *"ALL'UTENTE NON GLIENE FREGA UN CAZZO DEI TRANSITI: VUOLE RISPOSTE O
    // UNA GUIDA"*, e *"per breve sono sufficienti 2 paragrafi e per lunga
    // aggiungere altri 2 paragrafi mai di transiti o tecnicismi perché sotto
    // c'è già sempre "da dove arriva""* (voce EU.01). Prima il testo era la
    // prima parte del giorno piu' la corrente del cielo, cioe' i transiti
    // dentro la lettura e di nuovo sotto, in "Da dove viene". Adesso il
    // titolo e i paragrafi vengono dal corpus del Giorno occidentale, nella
    // fascia del livello (voce EU.17), con la voce scelta contando quante
    // volte la stessa fascia e' gia' tornata per questa persona ([ITestiEu]).
    // Il cielo sta solo in [HoroscopeCard.rigaDelLivello].
    final giorno = DateTime(year, 1, 1 + dayOfYear);
    final fascia = FasciaEu.di(indicator);
    final carta = cielo.carta;
    final indice = ITestiEu.indiceDelGiorno(
      chiave: chiaveDellaStoria(sign, carta),
      oggi: giorno,
      d: domain,
      fasciaDiOggi: fascia,
      scarto: ITestiEu.scarto(nascita),
      livelli: (g) => livelliDelGiorno(sign, carta, g),
    );
    final voce = ITestiEu.voce(
        TradizioneEu.occidentale, PeriodoEu.giorno, domain, fascia, indice);
    final title = voce.titolo;
    final text = voce.testo(lunga: profonda);
    final primaParte = voce.risposta;

    // L'apertura personalizzata vive solo sulla scheda Generale: dal corpus,
    // con lo stesso indice della scheda e il vocativo di oggi.
    final cardOpening = domain != HoroscopeDomain.generale
        ? null
        : vocativo != null
            ? ITestiEu.apertura(
                TradizioneEu.occidentale, fascia, indice, vocativo)
            : opening;
    final dalCielo = cielo.ceCieloVero;

    if (domain == HoroscopeDomain.fortuna) {
      // **IL NUMERO E IL COLORE CON UNA REGOLA, ordine ES voce 29.** Erano due
      // hash: `1 + (seed % 90)` e `palette[seed]`. Vedi [IlNumeroEIlColore].
      final (numero, colore, regola) = IlNumeroEIlColore.per(
          segno: sign,
          cielo: cielo,
          quando: DateTime.utc(year).add(Duration(days: dayOfYear, hours: 12)),
          nascita: nascita);
      return HoroscopeCard(
        domain: domain,
        title: title,
        text: text,
        synthesis: primaParte,
        indicator: indicator,
        luckyNumber: numero,
        dayColor: colore,
        dalCieloVero: dalCielo,
        rigaDelLivello: rigaDelLivello,
        rigaDellaFortuna: regola,
      );
    }
    return HoroscopeCard(
      domain: domain,
      title: title,
      text: text,
      synthesis: primaParte,
      indicator: indicator,
      opening: cardOpening,
      dalCieloVero: dalCielo,
      rigaDelLivello: rigaDelLivello,
    );
  }

  /// La chiave della storia delle fasce di una persona nell'Occidentale: il
  /// segno e la carta, se c'e'.
  static String chiaveDellaStoria(Zodiac sign, NatalChart? carta) => carta ==
          null
      ? 'occidentale|${sign.index}|-'
      // In millesimi di grado interi: e' una chiave, non un numero da
      // leggere, e non passa per un decimale col punto.
      : 'occidentale|${sign.index}|'
          '${carta.ascendantLongitude == null ? '-' : (carta.ascendantLongitude! * 1000).round()}|'
          '${[
          for (final p in carta.planets) (p.longitude * 1000).round()
        ].join(',')}';

  /// **I LIVELLI DI UN GIORNO CIVILE** nei quattro domini, con la stessa
  /// funzione del livello della scheda ([IlLivelloDelCielo]) e lo stesso
  /// istante del giorno: servono a contare le fasce dei giorni passati.
  static List<int> livelliDelGiorno(
      Zodiac sign, NatalChart? carta, DateTime giorno) {
    final m = TransitiDelGiorno.istanteDi(
        DateTime(giorno.year, giorno.month, giorno.day, 12));
    final cielo = carta == null
        ? CieloDiOggi.nessuno
        : CieloDiOggi.perIlGiorno(adesso: m, carta: carta);
    return [
      for (final d in HoroscopeDomain.values)
        IlLivelloDelCielo.per(dominio: d, segno: sign, cielo: cielo, quando: m)
            .$1,
    ];
  }

  /// Le quattro schede del segno per il giorno dato, nell'ordine di layout. Con
  /// [opening] la scheda Generale porta l'apertura personalizzata col nome.
  static List<HoroscopeCard> forSign({
    required Zodiac sign,
    required int dayOfYear,
    required int year,
    String? opening,
    CieloDiOggi cielo = CieloDiOggi.nessuno,
    Map<HoroscopeDomain, bool> profonde = const {},
    DateTime? nascita,
    String? vocativo,
  }) =>
      [
        for (final domain in HoroscopeDomain.values)
          cardFor(
              sign: sign,
              dayOfYear: dayOfYear,
              year: year,
              domain: domain,
              opening: opening,
              cielo: cielo,
              profonda: profonde[domain] ?? false,
              nascita: nascita,
              vocativo: vocativo),
      ];

  /// La riga di disclaimer, una sola volta nella schermata.
  static String get disclaimer => HoroscopeData.disclaimer;
}
