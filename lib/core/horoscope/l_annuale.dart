import '../astro/effemeridi.dart';
import '../astro/zodiac.dart';
import '../chat/user_profile.dart';
import 'horoscope.dart';
import 'la_rivoluzione_solare.dart';
import 'oroscopo_annuale_data.dart';

/// **L'ANNUALE DAL COMPLEANNO, ordine ES voce 04.**
///
/// Le quattro schede dal tema della Rivoluzione Solare
/// ([LaRivoluzioneSolare]), con le frasi di `docs/corpus/oroscopo_annuale.md`:
/// - **Generale**: l'Ascendente dell'anno, la casa del Sole, la casa della
///   Luna;
/// - **Amore**: la casa di Venere;
/// - **Lavoro**: la casa di Saturno e il segno del Medio Cielo;
/// - **Fortuna**: la casa di Giove.
///
/// **La variante e' quella dell'anno**: la stessa persona legge l'annuale una
/// volta l'anno, e in due anni di fila lo stesso caso ha l'altra frase.
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

  /// Le quattro schede dell'anno che comincia col ritorno [tema].
  static List<HoroscopeCard> schede(
    TemaDellaRivoluzione tema, {
    CourtesyForm? forma,
    String? apertura,
  }) {
    final anno = tema.istante.year;
    String frase(List<String> varianti) =>
        LaMarcaDelGenere.risolvi(varianti[anno % varianti.length],
            forma: forma);
    final asc = tema.segnoDellAscendente;
    final mc = tema.segnoDelMedioCielo;
    final casaSole = tema.casaDi(CorpoCeleste.sole);
    final casaLuna = tema.casaDi(CorpoCeleste.luna);
    final casaVenere = tema.casaDi(CorpoCeleste.venere);
    final casaGiove = tema.casaDi(CorpoCeleste.giove);
    final casaSaturno = tema.casaDi(CorpoCeleste.saturno);

    final generale = [
      frase(OroscopoAnnualeData.ascendente[asc]),
      frase(OroscopoAnnualeData.sole[casaSole - 1]),
      frase(OroscopoAnnualeData.luna[casaLuna - 1]),
    ];
    HoroscopeCard scheda(HoroscopeDomain d, String titolo, List<String> testi,
            int livello, String riga, String metodo) =>
        HoroscopeCard(
          domain: d,
          title: titolo,
          synthesis: testi.first.split(RegExp(r'(?<=[.!?]) ')).first,
          text: testi.join(' '),
          indicator: livello.clamp(2, 5),
          rigaDelLivello: riga,
          opening: d == HoroscopeDomain.generale ? apertura : null,
          metodo: metodo,
        );

    return [
      scheda(
          HoroscopeDomain.generale,
          'Un anno con l\'Ascendente in ${_segni[asc]}',
          generale,
          2 + forza(casaSole),
          'Dal Sole della tua Rivoluzione in casa $casaSole, '
              '${_tipo(casaSole)}.',
          '${OroscopoAnnualeData.notaGenerale} ${OroscopoAnnualeData.notaTutte}'),
      scheda(
          HoroscopeDomain.amore,
          'Venere in casa $casaVenere',
          [frase(OroscopoAnnualeData.venere[casaVenere - 1])],
          2 + forza(casaVenere),
          'Da Venere nella casa $casaVenere del tuo anno, '
              '${_tipo(casaVenere)}.',
          '${OroscopoAnnualeData.notaDomini} ${OroscopoAnnualeData.notaTutte}'),
      scheda(
          HoroscopeDomain.carriera,
          'Il Medio Cielo in ${_segni[mc]}',
          [
            frase(OroscopoAnnualeData.medioCielo[mc]),
            frase(OroscopoAnnualeData.saturno[casaSaturno - 1]),
          ],
          // Saturno angolare: l'anno chiede fatica.
          6 - forza(casaSaturno),
          'Da Saturno nella casa $casaSaturno del tuo anno, '
              '${_tipo(casaSaturno)}: più è in vista, più il lavoro chiede.',
          '${OroscopoAnnualeData.notaDomini} ${OroscopoAnnualeData.notaTutte}'),
      scheda(
          HoroscopeDomain.fortuna,
          'Giove in casa $casaGiove',
          [frase(OroscopoAnnualeData.giove[casaGiove - 1])],
          2 + forza(casaGiove),
          'Da Giove nella casa $casaGiove del tuo anno, '
              '${_tipo(casaGiove)}.',
          '${OroscopoAnnualeData.notaDomini} ${OroscopoAnnualeData.notaTutte}'),
    ];
  }

  /// Il segno zodiacale di una longitudine, per chi disegna.
  static Zodiac segno(double l) => Zodiac.values[TemaDellaRivoluzione.segno(l)];
}
