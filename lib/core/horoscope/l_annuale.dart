import '../astro/il_segno_del_cielo.dart';
import '../astro/meeus/il_cielo_di_meeus.dart';
import '../chat/user_profile.dart';
import 'horoscope.dart';
import 'i_testi_eu.dart';
import 'il_lessico_del_cielo.dart';
import 'il_responso_dell_oroscopo.dart';
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

  static const List<String> _mesi = [
    'gennaio', 'febbraio', 'marzo', 'aprile', 'maggio', 'giugno', //
    'luglio', 'agosto', 'settembre', 'ottobre', 'novembre', 'dicembre',
  ];

  /// "dal 24 novembre 2025", "dall'8 marzo 2026", "dall'11 aprile 2026".
  static String _dal(DateTime g) {
    final apostrofo = g.day == 8 || g.day == 11;
    return '${apostrofo ? 'dall\'' : 'dal '}${g.day} ${_mesi[g.month - 1]} '
        '${g.year}';
  }

  /// "al 23 novembre 2026", "all'8 marzo 2027".
  static String _al(DateTime g) {
    final apostrofo = g.day == 8 || g.day == 11;
    return '${apostrofo ? 'all\'' : 'al '}${g.day} ${_mesi[g.month - 1]} '
        '${g.year}';
  }

  /// **IL COMPLEANNO DELL'ANNO CHE COMINCIA COL RITORNO [ritorno]**: il
  /// giorno civile della nascita piu' vicino al ritorno del Sole (che cade
  /// il giorno del compleanno o uno accanto); senza la data di nascita, il
  /// giorno del ritorno. Chi e' nato il 29 febbraio, negli anni che non lo
  /// hanno, lo festeggia il 28.
  static DateTime compleanno(DateTime ritorno, DateTime? nascita) {
    final r = ritorno.toLocal();
    final giorno = DateTime(r.year, r.month, r.day);
    if (nascita == null) return giorno;
    DateTime di(int anno) {
      final ultimo = DateTime(anno, nascita.month + 1, 0).day;
      return DateTime(
          anno, nascita.month, nascita.day > ultimo ? ultimo : nascita.day);
    }

    var migliore = di(giorno.year);
    for (final anno in [giorno.year - 1, giorno.year + 1]) {
      final c = di(anno);
      if (c.difference(giorno).inHours.abs() <
          migliore.difference(giorno).inHours.abs()) {
        migliore = c;
      }
    }
    return migliore;
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
    bool lunga(HoroscopeDomain d) =>
        approfondite == null || (approfondite[d] ?? false);
    final casaSole = tema.casaDi(CorpoCeleste.sole);
    final casaVenere = tema.casaDi(CorpoCeleste.venere);
    final casaGiove = tema.casaDi(CorpoCeleste.giove);
    final casaSaturno = tema.casaDi(CorpoCeleste.saturno);
    final primoGiorno = compleanno(tema.istante, nascita);
    final ultimoGiorno =
        DateTime(primoGiorno.year + 1, primoGiorno.month, primoGiorno.day - 1);

    // **SESTO GIRO GA.06**: il corpo del "Da dove viene" dell'anno e' di
    // due frasi (tre nella Lunga della Generale): dove sta il pianeta del
    // campo, in quale area della vita e quanto pesa, e che cosa vuol dire
    // per il campo. Niente case, Ascendente, Medio Cielo, Rivoluzione Solare:
    // chi legge sa il compleanno e il pianeta.
    String doveStaIlPianeta(String pianeta, int casa, {bool doveri = false}) {
      final periodo = 'Nell\'anno ${_dal(primoGiorno)} ${_al(ultimoGiorno)}';
      final area = IlLessicoDelCielo.areaDellaVita(casa);
      // **MICRO-GIRO GA.06**: "il Sole sta nell'area del lavoro di ogni
      // giorno: li' resta sullo sfondo" non diceva niente. Adesso si dice
      // che cosa fa il pianeta (mette in primo piano, da' forza, tocca da
      // lontano) e che cosa vuol dire per l'anno.
      if (!doveri) {
        return switch (forza(casa)) {
          3 => '$periodo $pianeta mette in primo piano l\'$area: è un tema '
              'che nell\'anno conta molto.',
          2 => '$periodo $pianeta dà forza all\'$area: è un tema che '
              'nell\'anno conta.',
          _ => '$periodo $pianeta tocca l\'$area da lontano: è un tema che '
              'nell\'anno resta in secondo piano.',
        };
      }
      return switch (forza(casa)) {
        3 => '$periodo $pianeta mette in primo piano l\'$area e pesa molto: '
            'l\'anno di lavoro chiede costanza.',
        2 =>
          '$periodo $pianeta dà forza all\'$area: l\'anno di lavoro chiede un '
              'po\' di impegno.',
        _ => '$periodo $pianeta tocca l\'$area da lontano e pesa poco: '
            'l\'anno di lavoro è più leggero.',
      };
    }

    // Il corpo del campo (il Sole, Venere, Saturno, Giove) e il segno in cui
    // stava al ritorno del Sole.
    CorpoCeleste corpoDel(HoroscopeDomain d) => switch (d) {
          HoroscopeDomain.generale => CorpoCeleste.sole,
          HoroscopeDomain.amore => CorpoCeleste.venere,
          HoroscopeDomain.carriera => CorpoCeleste.saturno,
          HoroscopeDomain.fortuna => CorpoCeleste.giove,
        };
    String nomeDelPianeta(HoroscopeDomain d) => switch (d) {
          HoroscopeDomain.generale => 'il Sole',
          HoroscopeDomain.amore => 'Venere',
          HoroscopeDomain.carriera => 'Saturno',
          HoroscopeDomain.fortuna => 'Giove',
        };
    String segnoDelPianeta(HoroscopeDomain d) =>
        IlSegnoDelCielo.dellaLongitudine(tema.longitudini[corpoDel(d)]!)
            .italianName;

    HoroscopeCard scheda(
      HoroscopeDomain d, {
      required String chiSta,
      required int livello,
      required String metodo,
    }) {
      final voce = voceDi(d, livello);
      // La Lunga aggiunge dove stava il pianeta al compleanno, nel segno: un
      // fatto del cielo in piu' che la Breve non ha (terza frase del corpo).
      final cielo = LePartiDelResponso.insieme([
        chiSta,
        // Per il Sole non serve: al compleanno sta sempre nel tuo segno.
        if (lunga(d) && d != HoroscopeDomain.generale)
          'Al tuo compleanno ${nomeDelPianeta(d)} era in '
              '${segnoDelPianeta(d)}.',
        IlLessicoDelCielo.conclusione(d, livello.clamp(2, 5),
            quando: 'dell\'anno'),
      ]);
      final responso = IlResponsoDellOroscopo.componi(
        voce: voce,
        tradizione: TradizioneEu.occidentale,
        periodo: PeriodoEu.anno,
        dominio: d,
        primoGiorno: primoGiorno,
        lunga: lunga(d),
        cielo: cielo,
      );
      return HoroscopeCard(
        domain: d,
        title: responso.titolo,
        synthesis: responso.risposta,
        text: IlResponsoDellOroscopo.testo(responso),
        responso: responso,
        indicator: livello.clamp(2, 5),
        rigaDelLivello: cielo,
        opening: d == HoroscopeDomain.generale ? apertura : null,
        metodo: metodo,
      );
    }

    return [
      scheda(HoroscopeDomain.generale,
          chiSta: doveStaIlPianeta('il Sole', casaSole),
          livello: 2 + forza(casaSole),
          metodo: '${OroscopoAnnualeData.notaGenerale} '
              '${OroscopoAnnualeData.notaTutte}'),
      scheda(HoroscopeDomain.amore,
          chiSta:
              doveStaIlPianeta('Venere, il pianeta dell\'amore,', casaVenere),
          livello: 2 + forza(casaVenere),
          metodo: '${OroscopoAnnualeData.notaDomini} '
              '${OroscopoAnnualeData.notaTutte}'),
      scheda(HoroscopeDomain.carriera,
          // Fonte, ordine EV voce EV.08, verifica dell'Architetto (O-A-003):
          // le case angolari, succedenti e cadenti e la forza delle angolari
          // sono di William Lilly, Christian Astrology (1647), libro I, le
          // dignita' accidentali. Dalla casa al livello e' una regola
          // dell'app, e la nota dell'anno lo dice. Saturno in primo piano:
          // l'anno chiede fatica.
          chiSta: doveStaIlPianeta(
              'Saturno, il pianeta dei doveri,', casaSaturno,
              doveri: true),
          livello: 6 - forza(casaSaturno),
          metodo: '${OroscopoAnnualeData.notaDomini} '
              '${OroscopoAnnualeData.notaTutte}'),
      scheda(HoroscopeDomain.fortuna,
          chiSta:
              doveStaIlPianeta('Giove, il pianeta della fortuna,', casaGiove),
          livello: 2 + forza(casaGiove),
          metodo: '${OroscopoAnnualeData.notaDomini} '
              '${OroscopoAnnualeData.notaTutte}'),
    ];
  }
}
