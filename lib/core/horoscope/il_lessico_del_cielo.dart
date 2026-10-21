import '../astro/aspetti_di_oggi.dart';
import '../astro/natal_chart.dart';
import 'cielo_di_oggi.dart';
import 'corrente_del_cielo.dart';

/// **IL LESSICO DEL "DA DOVE VIENE", ordine GA voce GA.06, quarto giro.**
///
/// Il fondatore, 21 ottobre 2026: *"Le risposte vanno curate, sono la parte
/// più importante e criticata dell'app."* La lettura cieca indipendente ha
/// dato D3 sei su dodici, e i sei no avevano lo stesso padre: il "Da dove
/// viene" dice "in quadratura al tuo segno", "nella tua quarta casa solare",
/// "L'Ascendente della tua Rivoluzione Solare", e chi legge non sa che cosa
/// vuol dire. Padre: ordine ES voci 02 e 03 (la riga del cielo scritta con le
/// parole del metodo), rimasta uguale dopo le tre cure GA.06 precedenti.
///
/// **La regola**: la sostanza viene prima del termine. Un aspetto si dice
/// "in accordo con", "in tensione con"; una casa si dice "l'area della tua
/// vita" con la sua materia; il nome tecnico, quando serve, sta fra
/// parentesi DOPO la sostanza, oppure non c'e'. La guardia
/// `i_termini_del_cielo_hanno_la_loro_spiegazione_test` cade se un termine
/// compare senza la sua spiegazione nella stessa riga.
abstract final class IlLessicoDelCielo {
  /// Come si dice un aspetto, in parole di tutti i giorni, con la
  /// preposizione che regge il complemento ("in accordo CON la tua Venere").
  static const Map<AspectType, String> sostanzaDelRapporto = {
    AspectType.conjunction: 'a stretto contatto con',
    AspectType.sextile: 'in sintonia con',
    AspectType.square: 'in tensione con',
    AspectType.trine: 'in accordo con',
    AspectType.opposition: 'in contrasto con',
  };

  /// Lo stesso, per chi lo dice del proprio segno: "in tensione con il tuo
  /// segno".
  static String rapportoDi(AspectType a) => sostanzaDelRapporto[a]!;

  /// Il punto della carta di nascita toccato (dopo "in accordo con") e,
  /// la prima volta, la spiegazione di Ascendente e Medio Cielo. Esempi:
  /// "il tuo Ascendente (il segno che sorgeva all'orizzonte alla tua
  /// nascita)", "la tua Venere di nascita".
  static String conIlBersaglio(VoceDelCielo v, {bool spiega = true}) {
    if (v.idBersaglio == AspettiDiOggi.idAscendente) {
      return spiega
          ? 'il tuo Ascendente (il segno che sorgeva all\'orizzonte alla '
              'tua nascita)'
          : 'il tuo Ascendente';
    }
    if (v.idBersaglio == AspettiDiOggi.idMedioCielo) {
      return spiega
          ? 'il tuo Medio Cielo (il punto più alto del tuo cielo alla '
              'nascita)'
          : 'il tuo Medio Cielo';
    }
    return CorrenteDelCielo.bersagliFemminili.contains(v.idBersaglio)
        ? 'la tua ${v.bersaglio} di nascita'
        : 'il tuo ${v.bersaglio} di nascita';
  }

  /// **L'AREA DELLA VITA** di una casa solare (1-12): la materia in parole di
  /// tutti i giorni, senza il numero e senza la parola "casa". "area delle
  /// radici e della casa" (l'articolo lo mette chi la usa).
  static String areaDellaVita(int casa) =>
      'area ${CorrenteDelCielo.materiaDelleCase[casa - 1]}';

  /// Che cosa porta alla tua nascita un corpo del dominio: per dire "la tua
  /// Venere di nascita, il tuo modo di amare".
  static const Map<String, String> chePorta = {
    'sun': 'il tuo carattere di fondo',
    'moon': 'il tuo modo di sentire',
    'venus': 'il tuo modo di amare',
    'mars': 'la tua energia nel lavoro',
    'jupiter': 'la tua fortuna di fondo',
  };

  /// Il rapporto fra il corpo che passa e il segno di chi legge, per le case
  /// che lo fanno (1 3 4 5 7 9 10 11), in parole di tutti i giorni; il nome
  /// tecnico sta fra parentesi dopo la sostanza.
  static const Map<int, String> rapportoDelSegno = {
    1: 'nel tuo stesso segno',
    3: 'in sintonia con il tuo segno (un sestile)',
    11: 'in sintonia con il tuo segno (un sestile)',
    5: 'in accordo con il tuo segno (un trigono)',
    9: 'in accordo con il tuo segno (un trigono)',
    4: 'in tensione con il tuo segno (una quadratura)',
    10: 'in tensione con il tuo segno (una quadratura)',
    7: 'di fronte al tuo segno (un\'opposizione)',
  };
}
