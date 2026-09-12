import '../astro/aspetti_di_oggi.dart';
import '../astro/effemeridi.dart';
import '../astro/moon_phase.dart';
import '../astro/natal_chart.dart';
import '../astro/night_sky.dart';
import '../astro/transiti_del_giorno.dart';
import '../astro/zodiac.dart';
import '../astro/eclissi.dart';

/// GLI EVENTI DEL CIELO VERI DI OGGI, in un punto solo.
///
/// **Perche' questa famiglia di traguardi vale piu' delle altre.** Un
/// traguardo che dipende dal cielo NON SI PUO' AFFRETTARE: la Luna piena
/// arriva quando arriva, Mercurio torna diretto quando torna, e nel frattempo
/// si torna a guardare. E' anche la cosa che nessun concorrente puo' copiare
/// senza avere un motore astronomico vero, che qui c'e' gia' e calcola in
/// locale, senza rete.
///
/// **Tutto nasce da cio' che esisteva.** Le fasi da `MoonPhase`, il segno
/// della Luna da `NightSky`, i retrogradi da `AspettiDiOggi.retrogradiDelGiorno`,
/// le longitudini da `Effemeridi`. Le uniche due cose che non c'erano, il
/// RITORNO SOLARE e il passaggio da retrogrado a DIRETTO, si ricavano da
/// quelle stesse effemeridi confrontando due giorni vicini: nessun motore
/// nuovo, nessuna seconda porta dell'astronomia.
class EventiDelCielo {
  const EventiDelCielo._();

  // I nomi degli eventi. Sono stringhe perche' finiscono nei file di dati dei
  // sentieri, dove una costante di codice non potrebbe stare: qui c'e'
  // l'elenco completo, e la prova dei traguardi pretende che ogni evento
  // nominato da un traguardo esista in questa lista.
  static const lunaPiena = 'luna_piena';
  static const lunaNuova = 'luna_nuova';
  static const primoQuarto = 'primo_quarto';
  static const ultimoQuarto = 'ultimo_quarto';
  static const lunaCrescente = 'luna_crescente';
  static const lunaCalante = 'luna_calante';
  static const lunaNelTuoSegno = 'luna_nel_tuo_segno';
  static const lunaNelSegnoOpposto = 'luna_nel_segno_opposto';
  static const soleNelTuoSegno = 'sole_nel_tuo_segno';
  static const ritornoSolare = 'ritorno_solare';
  static const solstizio = 'solstizio';
  static const equinozio = 'equinozio';

  /// **L'ECLISSI, dall'ordine CE voce 16.** Prima non c'era, e tre gradini
  /// del Cammino dormivano per questo. Il giorno si intende in Tempo
  /// Universale, come lo data il canone: e' lo stesso confine con cui il
  /// mondo intero nomina un'eclissi.
  static const eclissi = 'eclissi';
  static const mercurioRetrogrado = 'mercurio_retrogrado';
  static const mercurioDiretto = 'mercurio_diretto';
  static const venereRetrograda = 'venere_retrograda';
  static const venereDiretta = 'venere_diretta';
  static const marteRetrogrado = 'marte_retrogrado';
  static const marteDiretto = 'marte_diretto';
  static const gioveRetrogrado = 'giove_retrogrado';
  static const gioveDiretto = 'giove_diretto';
  static const saturnoRetrogrado = 'saturno_retrogrado';
  static const saturnoDiretto = 'saturno_diretto';
  static const transitoSullAscendente = 'transito_sull_ascendente';
  static const transitoSulSole = 'transito_sul_sole';
  static const transitoSullaLuna = 'transito_sulla_luna';
  static const transitoSuVenere = 'transito_su_venere';
  static const transitoSuMarte = 'transito_su_marte';
  static const lunaPienaNelTuoSegno = 'luna_piena_nel_tuo_segno';
  static const lunaNuovaNelTuoSegno = 'luna_nuova_nel_tuo_segno';
  static const treTransitiInsieme = 'tre_transiti_insieme';

  /// Tutti gli eventi che questo catalogo sa riconoscere.
  static const List<String> tutti = [
    // L'eclissi, dall'ordine CE voce 16: senza questa riga il catalogo non la
    // riconoscerebbe e i tre gradini non si accenderebbero mai.
    eclissi,
    lunaPiena,
    lunaNuova,
    primoQuarto,
    ultimoQuarto,
    lunaCrescente,
    lunaCalante,
    lunaNelTuoSegno,
    lunaNelSegnoOpposto,
    soleNelTuoSegno,
    ritornoSolare,
    solstizio,
    equinozio,
    mercurioRetrogrado,
    mercurioDiretto,
    venereRetrograda,
    venereDiretta,
    marteRetrogrado,
    marteDiretto,
    gioveRetrogrado,
    gioveDiretto,
    saturnoRetrogrado,
    saturnoDiretto,
    transitoSullAscendente,
    transitoSulSole,
    transitoSullaLuna,
    transitoSuVenere,
    transitoSuMarte,
    lunaPienaNelTuoSegno,
    lunaNuovaNelTuoSegno,
    treTransitiInsieme,
  ];

  /// LA FINESTRA DELLE FASI, e perche' non e' un istante.
  ///
  /// La Luna e' piena in un istante preciso, ma una persona non vive in un
  /// istante: se la finestra fosse il minuto esatto, il traguardo della Luna
  /// piena sarebbe irraggiungibile per chiunque dorma. La finestra e' il
  /// giorno in cui l'illuminazione supera il 96 per cento, che a occhio nudo
  /// e' "la Luna e' piena".
  static const double _sogliaPiena = 0.96;
  static const double _sogliaNuova = 0.04;

  /// Quanto vicino deve essere un quarto per contare, in frazione di ciclo.
  static const double _tolleranzaQuarto = 0.02;

  /// Quanti gradi bastano perche' un transito conti come "sopra" un punto.
  static const double _orbeStretto = 2.0;

  /// GLI EVENTI DI OGGI per questa persona.
  ///
  /// La carta natale puo' mancare: in quel caso restano gli eventi che
  /// valgono per tutti (fasi, retrogradi, solstizi) e spariscono quelli
  /// personali, invece di dichiararli falsi.
  static Set<String> diOggi({
    required DateTime adesso,
    NatalChart? carta,
    Zodiac? segno,
  }) {
    final eventi = <String>{};
    final fase = MoonPhase.forDate(adesso);

    if (fase.illumination >= _sogliaPiena) eventi.add(lunaPiena);
    if (fase.illumination <= _sogliaNuova) eventi.add(lunaNuova);
    if ((fase.fraction - 0.25).abs() <= _tolleranzaQuarto) {
      eventi.add(primoQuarto);
    }
    if ((fase.fraction - 0.75).abs() <= _tolleranzaQuarto) {
      eventi.add(ultimoQuarto);
    }
    eventi.add(fase.waxing ? lunaCrescente : lunaCalante);

    final segnoDellaLuna = NightSky.moonSign(adesso);
    final mio = segno ?? (carta?.sunSign);
    if (mio != null) {
      if (segnoDellaLuna == mio) {
        eventi.add(lunaNelTuoSegno);
        if (eventi.contains(lunaPiena)) eventi.add(lunaPienaNelTuoSegno);
        if (eventi.contains(lunaNuova)) eventi.add(lunaNuovaNelTuoSegno);
      }
      if (segnoDellaLuna == _opposto(mio)) eventi.add(lunaNelSegnoOpposto);
      if (NightSky.sunSign(adesso) == mio) eventi.add(soleNelTuoSegno);
    }

    // SOLSTIZI ED EQUINOZI: il Sole che passa su 0, 90, 180 o 270 gradi. Si
    // guarda il passaggio fra ieri e oggi, non il valore di oggi, altrimenti
    // l'evento durerebbe quanto la tolleranza scelta invece di un giorno solo.
    final jd = TransitiDelGiorno.giornoGiulianoDi(adesso);
    final ieri = TransitiDelGiorno.giornoGiulianoDi(
        adesso.subtract(const Duration(days: 1)));
    final soleOggi = Effemeridi.longitudineEclittica(CorpoCeleste.sole, jd);
    final soleIeri = Effemeridi.longitudineEclittica(CorpoCeleste.sole, ieri);
    for (final grado in const [0.0, 180.0]) {
      if (_haAttraversato(soleIeri, soleOggi, grado)) eventi.add(equinozio);
    }
    for (final grado in const [90.0, 270.0]) {
      if (_haAttraversato(soleIeri, soleOggi, grado)) eventi.add(solstizio);
    }

    // **L'ECLISSI, ordine CE voce 16.** Il motore la sa dire per il giorno,
    // e la sa dire offline: e' un conto di Meeus, non una chiamata.
    if (MotoreDelleEclissi.nelGiornoDi(adesso.toUtc()) != null) {
      eventi.add(eclissi);
    }

    // IL RITORNO SOLARE: il Sole torna dov'era alla nascita. E' il compleanno
    // astronomico, che cade quasi sempre il giorno del compleanno civile ma
    // non sempre: qui vale quello vero.
    final soleNatale = carta?.planets
        .where((p) => p.id == 'sun')
        .map((p) => p.longitude)
        .firstOrNull;
    if (soleNatale != null && _haAttraversato(soleIeri, soleOggi, soleNatale)) {
      eventi.add(ritornoSolare);
    }

    // I RETROGRADI, e soprattutto il RITORNO DIRETTO: il giorno in cui un
    // pianeta smette di tornare indietro e' un evento raro e atteso, ed e' il
    // genere di cosa per cui si riapre l'app.
    final retrogradiOggi = AspettiDiOggi.retrogradiDelGiorno(adesso);
    final retrogradiIeri = AspettiDiOggi.retrogradiDelGiorno(
        adesso.subtract(const Duration(days: 1)));
    const coppie = {
      CorpoCeleste.mercurio: [mercurioRetrogrado, mercurioDiretto],
      CorpoCeleste.venere: [venereRetrograda, venereDiretta],
      CorpoCeleste.marte: [marteRetrogrado, marteDiretto],
      CorpoCeleste.giove: [gioveRetrogrado, gioveDiretto],
      CorpoCeleste.saturno: [saturnoRetrogrado, saturnoDiretto],
    };
    for (final voce in coppie.entries) {
      if (retrogradiOggi.contains(voce.key)) eventi.add(voce.value[0]);
      if (!retrogradiOggi.contains(voce.key) &&
          retrogradiIeri.contains(voce.key)) {
        eventi.add(voce.value[1]);
      }
    }

    // I TRANSITI SUI TUOI PUNTI: serve la carta, e per l'Ascendente serve
    // anche l'ora di nascita. Senza, l'evento non c'e' e non si finge.
    if (carta != null) {
      final posizioni = TransitiDelGiorno.posizioni(adesso);
      final bersagli = <String, double?>{
        transitoSullAscendente: carta.ascendantLongitude,
        transitoSulSole: _longitudineNatale(carta, 'sun'),
        transitoSullaLuna: _longitudineNatale(carta, 'moon'),
        transitoSuVenere: _longitudineNatale(carta, 'venus'),
        transitoSuMarte: _longitudineNatale(carta, 'mars'),
      };
      var quanti = 0;
      for (final bersaglio in bersagli.entries) {
        final dove = bersaglio.value;
        if (dove == null) continue;
        for (final corpo in posizioni.entries) {
          if (_distanza(corpo.value, dove) <= _orbeStretto) {
            eventi.add(bersaglio.key);
            quanti++;
            break;
          }
        }
      }
      if (quanti >= 3) eventi.add(treTransitiInsieme);
    }

    return eventi;
  }

  static double? _longitudineNatale(NatalChart carta, String id) =>
      carta.planets
          .where((p) => p.id == id)
          .map((p) => p.longitude)
          .firstOrNull;

  static Zodiac _opposto(Zodiac segno) =>
      Zodiac.values[(Zodiac.values.indexOf(segno) + 6) % 12];

  /// Vero se passando da [prima] a [dopo] si e' attraversato [grado], tenendo
  /// conto del giro completo dei 360.
  static bool _haAttraversato(double prima, double dopo, double grado) {
    final a = (prima - grado) % 360.0;
    final b = (dopo - grado) % 360.0;
    // Si e' attraversato se il resto e' passato da "quasi 360" a "quasi 0",
    // cioe' se b e' piccolo e a e' grande.
    return b < 2.0 && a > 358.0 - 4.0 && a > b;
  }

  static double _distanza(double a, double b) {
    final d = (a - b).abs() % 360.0;
    return d > 180.0 ? 360.0 - d : d;
  }
}
