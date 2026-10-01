import '../astro/effemeridi.dart';
import '../astro/zodiac.dart';
import '../chat/user_profile.dart';
import 'horoscope.dart';
import 'i_testi_eu.dart';
import 'la_rivoluzione_solare.dart';
import 'le_parti_del_responso.dart';
import 'oroscopo_annuale_data.dart';

/// **L'ANNUALE DAL COMPLEANNO, ordine ES voce 04.**
///
/// Le quattro schede dal tema della Rivoluzione Solare
/// ([LaRivoluzioneSolare]), con le frasi di `docs/corpus/oroscopo_annuale.md`:
/// - **Generale**: l'Ascendente dell'anno, la casa del Sole, la casa della
///   Luna;
/// - **Amore**: la casa di Venere;
/// - **Lavoro**: il segno del Medio Cielo e la casa di Saturno;
/// - **Fortuna**: la casa di Giove.
///
/// **La variante e' quella dell'anno**: la stessa persona legge l'annuale una
/// volta l'anno, e in due anni di fila lo stesso caso ha l'altra frase.
///
/// **LE TRE PARTI DEL RESPONSO**, dal 30 settembre 2026. Il fondatore:
/// *"all'utente non gliene frega un cazzo dei transiti [...] Se vuoi inserire
/// i transiti, li inserisci dopo giusto per motivare da dove arriva la
/// risposta."* Ogni frase del corpus ha il suo testo, in parole di tutti i
/// giorni, e il suo "da dove viene", dove stanno il pianeta, il segno e la
/// casa ([LePartiDelResponso]). La scheda mette i testi nella lettura e i "da
/// dove viene" nella riga sotto; i titoli sono in parole ([titoli]).
///
/// **Breve e Lunga**, dal 30 settembre 2026. Il fondatore: *"Ogni scheda deve
/// avere sempre il pulsante profondità e la scelta "approfondita" è esclusiva
/// dei premium."* La Breve e' il testo che da' il tono di ogni scheda
/// (dall'Ascendente, da Venere, dal Medio Cielo, da Giove). La Lunga aggiunge
/// cio' che il tema dice in piu': nella Generale i testi del Sole e della
/// Luna, nel Lavoro quello di Saturno, nell'Amore e nella Fortuna la seconda
/// lettura dello stesso caso; e nel "da dove viene" il segno in cui Venere e
/// Giove stanno al ritorno del Sole e quanto conta la loro casa.
///
/// **Il livello viene dall'angolarita'**, la regola che Volguine mette per
/// prima nella Rivoluzione: il pianeta in una casa angolare (1, 4, 7, 10) e'
/// il protagonista dell'anno, in una succedente (2, 5, 8, 11) lavora in
/// secondo piano, in una cadente (3, 6, 9, 12) resta sullo sfondo. Per
/// Saturno, che pesa, l'angolo vuol dire un anno che chiede fatica.
abstract final class LAnnuale {
  static const List<String> _segni = [
    'Ariete', 'Toro', 'Gemelli', 'Cancro', 'Leone', 'Vergine', //
    'Bilancia', 'Scorpione', 'Sagittario', 'Capricorno', 'Acquario', 'Pesci',
  ];

  /// **I TITOLI DELLE QUATTRO SCHEDE, IN PAROLE.** Fino al 30 settembre 2026
  /// erano "Un anno con l'Ascendente in Pesci", "Venere in casa 5", "Il Medio
  /// Cielo in Sagittario", "Giove in casa 5": la scheda apriva col simbolo, e
  /// le Linee Guida (sezione 2) dicono che *"il simbolo non apre mai"*. Il
  /// segno e la casa stanno nella riga del "da dove viene", sotto la lettura.
  static const Map<HoroscopeDomain, String> titoli = {
    HoroscopeDomain.generale: 'Il tono del tuo anno',
    HoroscopeDomain.amore: 'L\'amore nel tuo anno',
    HoroscopeDomain.carriera: 'Il lavoro nel tuo anno',
    HoroscopeDomain.fortuna: 'La fortuna nel tuo anno',
  };

  /// Quanto conta una casa: angolare, succedente, cadente.
  static int forza(int casa) => switch (casa % 3) {
        1 => 3, // 1, 4, 7, 10
        2 => 2, // 2, 5, 8, 11
        _ => 1, // 3, 6, 9, 12
      };

  static String _tipo(int casa) => switch (forza(casa)) {
        3 => 'angolare',
        2 => 'succedente',
        _ => 'cadente',
      };

  /// **DOVE STA IL PIANETA, E QUANTO CONTA**: la riga che la Lunga aggiunge
  /// al "da dove viene" dell'Amore e della Fortuna. Il segno e la casa sono
  /// calcolati dal tema; il peso e' la regola dell'angolarita' scritta qui
  /// sopra, con le sue parole.
  static String doveSta(
      String pianeta, CorpoCeleste corpo, TemaDellaRivoluzione tema) {
    final casa = tema.casaDi(corpo);
    final segno = _segni[TemaDellaRivoluzione.segno(tema.longitudini[corpo]!)];
    final peso = switch (forza(casa)) {
      3 => 'una casa angolare, dove per la tradizione il pianeta è fra i '
          'protagonisti dell\'anno',
      2 => 'una casa succedente, dove per la tradizione il pianeta lavora '
          'in secondo piano',
      _ => 'una casa cadente, dove per la tradizione il pianeta resta sullo '
          'sfondo',
    };
    return 'Al tuo compleanno $pianeta era in $segno, nella casa $casa del '
        'tuo anno: $peso.';
  }

  /// Le quattro schede dell'anno che comincia col ritorno [tema].
  ///
  /// [approfondite] dice, scheda per scheda, se si legge la Lunga; senza, si
  /// leggono tutte intere, come nel PDF dell'anno.
  static List<HoroscopeCard> schede(
    TemaDellaRivoluzione tema, {
    CourtesyForm? forma,
    String? apertura,
    Map<HoroscopeDomain, bool>? approfondite,
    DateTime? nascita,
  }) {
    final anno = tema.istante.year;
    // **I TESTI DELL'ARCHITETTO, EU Aggiunta, 1 ottobre 2026**: il titolo e
    // i paragrafi di ogni scheda vengono dal corpus dell'Anno occidentale,
    // nella fascia del livello; la voce e' (numero dell'anno della persona +
    // scarto) modulo le voci della fascia, cosi' due anni di fila leggono
    // l'altra ([ITestiEu]). Le frasi di lettura del corpus annuale di prima
    // non vanno piu' a video; le righe di "Da dove viene" restano.
    final scarto = ITestiEu.scarto(nascita);
    final numeroDellAnno = nascita == null ? anno : anno - nascita.year;
    VoceEu voceDi(HoroscopeDomain d, int livello) => ITestiEu.voce(
        TradizioneEu.occidentale,
        PeriodoEu.anno,
        d,
        FasciaEu.di(livello.clamp(2, 5)),
        ITestiEu.indiceDellAnno(numeroDellAnno, scarto));
    // Il testo e il "da dove viene" della variante dell'anno; con [passo] la
    // variante accanto, che la Lunga aggiunge dove il caso e' uno solo.
    (String, String) frase(List<String> varianti, [int passo = 0]) =>
        LePartiDelResponso.di(LaMarcaDelGenere.risolvi(
            varianti[(anno + passo) % varianti.length],
            forma: forma));
    bool lunga(HoroscopeDomain d) =>
        approfondite == null || (approfondite[d] ?? false);
    final asc = tema.segnoDellAscendente;
    final mc = tema.segnoDelMedioCielo;
    final casaSole = tema.casaDi(CorpoCeleste.sole);
    final casaLuna = tema.casaDi(CorpoCeleste.luna);
    final casaVenere = tema.casaDi(CorpoCeleste.venere);
    final casaGiove = tema.casaDi(CorpoCeleste.giove);
    final casaSaturno = tema.casaDi(CorpoCeleste.saturno);

    final (_, ascDaDove) = frase(OroscopoAnnualeData.ascendente[asc]);
    final (_, soleDaDove) = frase(OroscopoAnnualeData.sole[casaSole - 1]);
    final (_, lunaDaDove) = frase(OroscopoAnnualeData.luna[casaLuna - 1]);
    final (_, venereDaDove) = frase(OroscopoAnnualeData.venere[casaVenere - 1]);
    final (_, mcDaDove) = frase(OroscopoAnnualeData.medioCielo[mc]);
    final (_, saturnoDaDove) =
        frase(OroscopoAnnualeData.saturno[casaSaturno - 1]);
    final (_, gioveDaDove) = frase(OroscopoAnnualeData.giove[casaGiove - 1]);

    /// Il "da dove viene" che si legge sempre e cio' che la Lunga aggiunge;
    /// [delLivello] dice da dove viene il livello, in fondo alla riga.
    HoroscopeCard scheda(
      HoroscopeDomain d, {
      required String daDove,
      required List<String> daDoveInPiu,
      required String delLivello,
      required int livello,
      required String metodo,
    }) {
      final voce = voceDi(d, livello);
      return HoroscopeCard(
        domain: d,
        title: voce.titolo,
        synthesis: voce.risposta,
        text: voce.testo(lunga: lunga(d)),
        indicator: livello.clamp(2, 5),
        rigaDelLivello: LePartiDelResponso.insieme(
            [daDove, if (lunga(d)) ...daDoveInPiu, delLivello]),
        opening: d == HoroscopeDomain.generale ? apertura : null,
        metodo: metodo,
      );
    }

    return [
      scheda(HoroscopeDomain.generale,
          daDove: ascDaDove.isEmpty
              ? 'L\'Ascendente del tuo anno è in ${_segni[asc]}.'
              : ascDaDove,
          daDoveInPiu: [soleDaDove, lunaDaDove],
          delLivello: 'Il livello viene dal Sole della tua Rivoluzione Solare '
              'in casa $casaSole, ${_tipo(casaSole)}.',
          livello: 2 + forza(casaSole),
          metodo: '${OroscopoAnnualeData.notaGenerale} '
              '${OroscopoAnnualeData.notaTutte}'),
      scheda(HoroscopeDomain.amore,
          daDove: venereDaDove.isEmpty
              ? 'Venere nella tua Rivoluzione Solare cade nella casa '
                  '$casaVenere.'
              : venereDaDove,
          daDoveInPiu: [doveSta('Venere', CorpoCeleste.venere, tema)],
          delLivello: 'Il livello viene da Venere nella casa $casaVenere, '
              '${_tipo(casaVenere)}.',
          livello: 2 + forza(casaVenere),
          metodo: '${OroscopoAnnualeData.notaDomini} '
              '${OroscopoAnnualeData.notaTutte}'),
      scheda(HoroscopeDomain.carriera,
          daDove: mcDaDove.isEmpty
              ? 'Il Medio Cielo del tuo anno è in ${_segni[mc]}.'
              : mcDaDove,
          daDoveInPiu: [saturnoDaDove],
          // Fonte, ordine EV voce EV.08, verifica dell'Architetto (O-A-003):
          // le case angolari, succedenti e cadenti e la forza delle angolari
          // sono di William Lilly, Christian Astrology (1647), libro I, le
          // dignita' accidentali. Dalla casa al livello e' una regola
          // dell'app, e la nota dell'anno lo dice.
          delLivello: 'Il livello viene da Saturno nella casa $casaSaturno, '
              '${_tipo(casaSaturno)}: più è in vista, più il lavoro chiede.',
          // Saturno angolare: l'anno chiede fatica.
          livello: 6 - forza(casaSaturno),
          metodo: '${OroscopoAnnualeData.notaDomini} '
              '${OroscopoAnnualeData.notaTutte}'),
      scheda(HoroscopeDomain.fortuna,
          daDove: gioveDaDove.isEmpty
              ? 'Giove nella tua Rivoluzione Solare cade nella casa '
                  '$casaGiove.'
              : gioveDaDove,
          daDoveInPiu: [doveSta('Giove', CorpoCeleste.giove, tema)],
          delLivello: 'Il livello viene da Giove nella casa $casaGiove, '
              '${_tipo(casaGiove)}.',
          livello: 2 + forza(casaGiove),
          metodo: '${OroscopoAnnualeData.notaDomini} '
              '${OroscopoAnnualeData.notaTutte}'),
    ];
  }

  /// Il segno zodiacale di una longitudine, per chi disegna.
  static Zodiac segno(double l) => Zodiac.values[TemaDellaRivoluzione.segno(l)];
}
