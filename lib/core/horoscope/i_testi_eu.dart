import 'horoscope.dart';
import 'i_testi_eu_cinese_data.dart';
import 'i_testi_eu_occidentale_data.dart';
import 'i_testi_eu_vedica_data.dart';

/// **I TESTI DELL'ARCHITETTO, EU Aggiunta, 1 ottobre 2026.**
///
/// I dodici corpora di `docs/corpus/eu/` (tre tradizioni per quattro periodi)
/// sono la fonte unica dei testi dell'Oroscopo: il titolo della scheda, la
/// Risposta e Che cosa fare in Breve, e in Lunga anche Risposta, Lunga e Che
/// cosa fare, Lunga. Il codice li porta carattere per carattere
/// (`tool/_gen_oroscopo_eu.py`, `i_testi_eu_<tradizione>_data.dart`) e la
/// prova `i_testi_eu_sono_quelli_dell_architetto_test` li confronta coi file.
/// Code non scrive, non riscrive e non riformula nessuno di questi testi
/// (regola fissa 11 dell'ordine EU).
///
/// Qui stanno le regole della EU Aggiunta: la fascia dal livello, quale voce
/// ogni volta, come si compone una scheda.

/// Le tre tradizioni che hanno i loro corpora.
enum TradizioneEu { occidentale, vedica, cinese }

/// I quattro periodi.
enum PeriodoEu { giorno, settimana, mese, anno }

/// **LA FASCIA**, voce EU.17: il livello del dominio nel periodo decide quale
/// gruppo di voci si legge. Sopra il neutro Favorevole, il neutro (3) In
/// equilibrio, sotto il neutro In salita.
enum FasciaEu {
  favorevole,
  equilibrio,
  salita;

  static FasciaEu di(int livello) => livello >= 4
      ? FasciaEu.favorevole
      : livello == 3
          ? FasciaEu.equilibrio
          : FasciaEu.salita;
}

/// Una voce del corpus: il titolo e i quattro paragrafi.
class VoceEu {
  const VoceEu(this.titolo, this.risposta, this.cosaFare, this.rispostaLunga,
      this.cosaFareLunga);

  final String titolo;
  final String risposta;
  final String cosaFare;
  final String rispostaLunga;
  final String cosaFareLunga;

  /// I paragrafi della scheda: due in Breve, quattro in Lunga (voce EU.01).
  List<String> paragrafi({required bool lunga}) => [
        risposta,
        cosaFare,
        if (lunga) ...[rispostaLunga, cosaFareLunga],
      ];

  /// Il testo della scheda, coi paragrafi separati da una riga vuota: chi lo
  /// mostra li tiene come sono (`spezzaInParagrafi`).
  String testo({required bool lunga}) =>
      paragrafi(lunga: lunga).join(ITestiEu.fraIParagrafi);
}

abstract final class ITestiEu {
  /// Il separatore dei paragrafi nel testo di una scheda.
  static const String fraIParagrafi = '\n\n';

  /// Il segnaposto delle aperture del Giorno.
  static const String segnapostoDelNome = '[Nome]';

  /// Il giorno zero delle regole di scelta: il 1 gennaio 2026.
  static final DateTime giornoZero = DateTime.utc(2026, 1, 1);

  static List<List<List<List<VoceEu>>>> _voci(TradizioneEu t) => switch (t) {
        TradizioneEu.occidentale => ITestiEuOccidentaleData.voci,
        TradizioneEu.vedica => ITestiEuVedicaData.voci,
        TradizioneEu.cinese => ITestiEuCineseData.voci,
      };

  static List<List<String>> _aperture(TradizioneEu t) => switch (t) {
        TradizioneEu.occidentale => ITestiEuOccidentaleData.aperture,
        TradizioneEu.vedica => ITestiEuVedicaData.aperture,
        TradizioneEu.cinese => ITestiEuCineseData.aperture,
      };

  /// Le voci di una fascia, in fila.
  static List<VoceEu> fascia(
          TradizioneEu t, PeriodoEu p, HoroscopeDomain d, FasciaEu f) =>
      _voci(t)[p.index][d.index][f.index];

  /// La voce di posto [indice] (gia' ridotto o no: si riduce qui).
  static VoceEu voce(
      TradizioneEu t, PeriodoEu p, HoroscopeDomain d, FasciaEu f, int indice) {
    final elenco = fascia(t, p, d, f);
    return elenco[indice % elenco.length];
  }

  /// L'apertura del Giorno di posto [indice] nella fascia [f], col
  /// vocativo di oggi al posto di [segnapostoDelNome].
  static String apertura(
      TradizioneEu t, FasciaEu f, int indice, String vocativo) {
    final elenco = _aperture(t)[f.index];
    return elenco[indice % elenco.length]
        .replaceAll(segnapostoDelNome, vocativo);
  }

  /// Il giorno civile come intero, in UTC: senza l'ora legale di mezzo.
  static int _giornoCivile(DateTime g) =>
      DateTime.utc(g.year, g.month, g.day).millisecondsSinceEpoch ~/ 86400000;

  /// I giorni dal giorno zero alla data civile [g] (negativi prima).
  static int giorniDalloZero(DateTime g) =>
      _giornoCivile(g) - _giornoCivile(giornoZero);

  /// **LO SCARTO DELLA PERSONA**: i giorni fra il 1 gennaio 1900 e la sua
  /// data di nascita. Due persone con le stesse fasce non leggono la stessa
  /// voce lo stesso giorno. Senza la data, zero.
  static int scarto(DateTime? nascita) => nascita == null
      ? 0
      : _giornoCivile(nascita) - _giornoCivile(DateTime.utc(1900, 1, 1));

  /// **LA SETTIMANA**: (numero della settimana + scarto) modulo 14, col
  /// numero della settimana la parte intera dei giorni dal giorno zero
  /// diviso sette.
  static int indiceDellaSettimana(DateTime oggi, int scarto) =>
      (giorniDalloZero(oggi) / 7).floor() + scarto;

  /// **IL MESE**: (numero del mese dal gennaio 2026 + scarto) modulo 4.
  static int indiceDelMese(DateTime oggi, int scarto) =>
      (oggi.year - 2026) * 12 + oggi.month - 1 + scarto;

  /// **L'ANNO**: (numero dell'anno della persona + scarto) modulo 2.
  static int indiceDellAnno(int numeroDellAnno, int scarto) =>
      numeroDellAnno + scarto;

  // **IL GIORNO**: la storia delle fasce, per persona e tradizione. Per ogni
  // giorno dal giorno zero i livelli dei quattro domini, calcolati con la
  // stessa funzione del livello di oggi e tenuti in memoria.
  static final Map<String, List<List<int>>> _storie = {};

  /// **L'INDICE DEL GIORNO**: quante volte, dal giorno zero a ieri, il
  /// dominio [d] ha avuto per questa persona la stessa fascia di oggi, piu'
  /// lo [scarto]. [chiave] dice la persona e la tradizione; [livelli] da' i
  /// livelli dei quattro domini di un giorno civile.
  static int indiceDelGiorno({
    required String chiave,
    required DateTime oggi,
    required HoroscopeDomain d,
    required FasciaEu fasciaDiOggi,
    required int scarto,
    required List<int> Function(DateTime giorno) livelli,
  }) {
    final storia = _storie.putIfAbsent(chiave, () => []);
    final ieri = giorniDalloZero(oggi);
    while (storia.length < ieri) {
      final g = DateTime(2026, 1, 1 + storia.length);
      storia.add(livelli(g));
    }
    var volte = 0;
    for (var i = 0; i < ieri && i < storia.length; i++) {
      if (FasciaEu.di(storia[i][d.index]) == fasciaDiOggi) volte++;
    }
    return volte + scarto;
  }

  /// Svuota la memoria delle storie: per le prove.
  static void dimentica() => _storie.clear();
}
