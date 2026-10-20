import '../responsi/i_riti_propiziatori.dart';
import '../responsi/la_forma_del_responso.dart';
import 'horoscope.dart';
import 'i_testi_eu.dart';
import 'l_almanacco_cinese.dart';

/// **IL RESPONSO DELL'OROSCOPO NELLA FORMA NUOVA, IN UN PUNTO SOLO.** Ordine
/// GA, voci GA.03, GA.04 e GA.05, 20 ottobre 2026.
///
/// Ogni scheda dell'Oroscopo, in ogni tradizione e in ogni periodo, nasce
/// qui come [ResponsoInterpretato]: il titolo e i paragrafi della voce del
/// corpus ([VoceEu]), il rito propiziatorio della tradizione nella Lunga, il
/// "Da dove viene" della scheda con in coda la fonte del rito. I compositori
/// (`Horoscope.cardFor`, `LaLetturaVedica.schede`, `LaLetturaCinese.schede`,
/// `LaSettimanaDelCielo`, `LAnnuale.schede`, `LAnnoDelleTradizioni.schede`)
/// chiamano [componi] e nient'altro: il rito si sceglie in un punto solo.
///
/// **IL REGGENTE.** Il fondatore, voce GA.04: l'inno al pianeta che governa
/// il giorno, il mantra del graha del giorno, il gesto dell'ufficiale del
/// giorno; *"Per Settimana, Mese e Anno vale il pianeta, il graha o
/// l'ufficiale del primo giorno del periodo; il testo lo dice"*. Il primo
/// giorno e' quello che il codice dell'Oroscopo da' al periodo: la Settimana
/// e il Mese cominciano oggi (sette e trenta giorni da oggi,
/// `LaSettimanaDelCielo.per` e `dalleSchede`), l'Anno dal compleanno al
/// compleanno, l'anno cinese a Capodanno lunare, l'anno vedico al
/// compleanno (`AnnoDellaTradizione.da`).
abstract final class IlResponsoDellOroscopo {
  /// L'arte della forma per la tradizione: il titolo del riquadro del rito
  /// segue la tradizione scelta.
  static ArteInterpretata arte(TradizioneEu t) => switch (t) {
        TradizioneEu.occidentale => ArteInterpretata.oroscopoOccidentale,
        TradizioneEu.vedica => ArteInterpretata.oroscopoVedico,
        TradizioneEu.cinese => ArteInterpretata.oroscopoCinese,
      };

  /// La raccolta dei riti della tradizione.
  static String raccolta(TradizioneEu t) => switch (t) {
        TradizioneEu.occidentale => IRitiPropiziatori.inniOrfici,
        TradizioneEu.vedica => IRitiPropiziatori.mantraNavagraha,
        TradizioneEu.cinese => IRitiPropiziatori.gestiTongShu,
      };

  /// I pianeti che governano i giorni, da lunedi' a domenica: la Luna il
  /// lunedi', Marte il martedi', Mercurio il mercoledi', Giove il giovedi',
  /// Venere il venerdi', Saturno il sabato, il Sole la domenica.
  static const List<String> pianetiDeiGiorni = [
    'Luna', 'Marte', 'Mercurio', 'Giove', 'Venere', 'Saturno', 'Sole', //
  ];

  /// I graha dei Navagraha che governano i giorni, da lunedi' a domenica.
  static const List<String> grahaDeiGiorni = [
    'Chandra', 'Mangala', 'Budha', 'Guru', 'Shukra', 'Shani', 'Surya', //
  ];

  /// **I DODICI UFFICIALI DEL GIORNO coi nomi delle intestazioni dei riti**,
  /// nell'ordine del codice ([LAlmanaccoCinese.guardiani]: 0 Stabilire, cioe'
  /// Jian, ... 11 Chiudere, cioe' Bi).
  static const List<String> ufficiali = [
    'Jian', 'Chu', 'Man', 'Ping', 'Ding', 'Zhi', //
    'Po', 'Wei', 'Cheng', 'Shou', 'Kai', 'Bi',
  ];

  /// **CHI GOVERNA IL GIORNO CIVILE [giorno]** nella tradizione [t], col
  /// nome dell'intestazione del rito; null dove l'almanacco cinese non sa
  /// l'ufficiale (fuori dal 1900-2100).
  static String? reggente(TradizioneEu t, DateTime giorno) => switch (t) {
        TradizioneEu.occidentale => pianetiDeiGiorni[giorno.weekday - 1],
        TradizioneEu.vedica => grahaDeiGiorni[giorno.weekday - 1],
        TradizioneEu.cinese => switch (LAlmanaccoCinese.guardiano(
              DateTime(giorno.year, giorno.month, giorno.day))) {
            final int g => ufficiali[g],
            null => null,
          },
      };

  /// La chiave del rito: il reggente, il dominio col nome dell'intestazione
  /// (Generale, Amore, Carriera, Fortuna) e 'giorno' per il Giorno,
  /// 'periodo' per la Settimana, il Mese e l'Anno.
  static List<String>? chiaveDelRito(TradizioneEu t, PeriodoEu periodo,
      HoroscopeDomain dominio, DateTime primoGiorno) {
    final chi = reggente(t, primoGiorno);
    if (chi == null) return null;
    return [
      chi,
      dominio.label,
      periodo == PeriodoEu.giorno ? 'giorno' : 'periodo',
    ];
  }

  static const List<String> _giorni = [
    'lunedì', 'martedì', 'mercoledì', 'giovedì', 'venerdì', 'sabato', //
    'domenica',
  ];
  static const List<String> _mesi = [
    'gennaio', 'febbraio', 'marzo', 'aprile', 'maggio', 'giugno', //
    'luglio', 'agosto', 'settembre', 'ottobre', 'novembre', 'dicembre',
  ];

  static String _data(DateTime g, {required bool conLAnno}) =>
      '${_giorni[g.weekday - 1]} ${g.day} ${_mesi[g.month - 1]}'
      '${conLAnno ? ' ${g.year}' : ''}';

  static String _minuscola(String s) =>
      s.isEmpty ? s : '${s[0].toLowerCase()}${s.substring(1)}';

  /// **IL "DA DOVE VIENE" DELLA SCHEDA**: la riga di oggi ([cielo]) e, nella
  /// Lunga, in coda la fonte del rito, legata da una frase che dice quale
  /// giorno il rito segue.
  static String? daDoveViene(String? cielo,
      {String? fonteDelRito,
      required PeriodoEu periodo,
      required DateTime primoGiorno}) {
    final riga = cielo?.trim() ?? '';
    if (fonteDelRito == null || fonteDelRito.trim().isEmpty) {
      return riga.isEmpty ? null : riga;
    }
    final legame = periodo == PeriodoEu.giorno
        ? 'Il rito propiziatorio segue il giorno: '
        : 'Il rito propiziatorio segue il primo giorno del periodo, '
            '${_data(primoGiorno, conLAnno: periodo == PeriodoEu.anno)}: ';
    final coda = '$legame${_minuscola(fonteDelRito.trim())}';
    return riga.isEmpty ? coda : '$riga $coda';
  }

  /// **COMPONE IL RESPONSO** dalla [voce] del corpus, nella [tradizione] e
  /// nel [periodo], per il [dominio]; [primoGiorno] e' il giorno del
  /// reggente (il Giorno stesso, o il primo giorno del periodo); [lunga] dice
  /// la profondita' Lunga; [cielo] e' la riga di oggi del "Da dove viene"
  /// della scheda.
  static ResponsoInterpretato componi({
    required VoceEu voce,
    required TradizioneEu tradizione,
    required PeriodoEu periodo,
    required HoroscopeDomain dominio,
    required DateTime primoGiorno,
    required bool lunga,
    String? cielo,
  }) {
    String? rito;
    String? fonte;
    if (lunga) {
      final chiave = chiaveDelRito(tradizione, periodo, dominio, primoGiorno);
      if (chiave != null) {
        rito = IRitiPropiziatori.rito(raccolta(tradizione), chiave);
        if (rito != null) {
          fonte = IRitiPropiziatori.fonte(raccolta(tradizione), chiave);
        }
      }
    }
    return ResponsoInterpretato(
      arte: arte(tradizione),
      titolo: voce.titolo,
      risposta: voce.risposta,
      cosaFare: voce.cosaFare,
      approfondimento: lunga ? voce.rispostaLunga : null,
      rito: rito,
      daDoveViene: daDoveViene(cielo,
          fonteDelRito: fonte, periodo: periodo, primoGiorno: primoGiorno),
    );
  }

  /// **IL TESTO DELLA SCHEDA**, per chi lo legge fuori dallo schermo (la
  /// chat con Medora, il Diario, il PDF dell'anno, la lettura completa): i
  /// paragrafi del responso nell'ordine in cui si leggono, separati da una
  /// riga vuota ([ITestiEu.fraIParagrafi]).
  static String testo(ResponsoInterpretato r) =>
      r.paragrafi.join(ITestiEu.fraIParagrafi);
}
