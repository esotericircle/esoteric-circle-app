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
  /// (Generale, Amore, Carriera, Fortuna) e il periodo col suo nome
  /// ('giorno', 'settimana', 'mese', 'anno').
  ///
  /// **ORDINE GA VOCE GA.06, UN RITO PER OGNI PERIODO.** Prima la Settimana,
  /// il Mese e l'Anno avevano un solo rito "periodo": la Settimana e l'Anno
  /// con lo stesso reggente mostravano lo stesso rito parola per parola
  /// (lettore cieco, oroscopo-7 e 15, 37 e 45, 39 e 47), la Settimana e il
  /// Mese, che cominciano tutti e due oggi, lo mostravano lo stesso giorno, e
  /// un rito scritto per un periodo che comincia oggi ("Al primo mattino del
  /// periodo", "Inaugura il tratto") finiva sotto un Anno cominciato da sette
  /// mesi (oroscopo-32, 45, 47). Adesso ogni periodo ha il suo rito, e quello
  /// dell'Anno e' scritto per valere in qualunque punto dell'anno.
  static List<String>? chiaveDelRito(TradizioneEu t, PeriodoEu periodo,
      HoroscopeDomain dominio, DateTime primoGiorno) {
    final chi = reggente(t, primoGiorno);
    if (chi == null) return null;
    return [chi, dominio.label, periodo.name];
  }

  static String _minuscola(String s) =>
      s.isEmpty ? s : '${s[0].toLowerCase()}${s.substring(1)}';

  /// **LA FONTE**, una riga separata in coda (sesto giro GA.06): la tradizione
  /// e la scuola in poche parole, con al piu' un termine tecnico e spiegato.
  static String laFonte(TradizioneEu tradizione, PeriodoEu periodo) =>
      switch ((tradizione, periodo)) {
        (TradizioneEu.occidentale, PeriodoEu.giorno) =>
          'astrologia occidentale, che legge il cielo di oggi rispetto al tuo '
              'segno.',
        (TradizioneEu.occidentale, PeriodoEu.anno) =>
          'astrologia occidentale, che legge l\'anno dal cielo del tuo '
              'compleanno.',
        (TradizioneEu.occidentale, _) =>
          'astrologia occidentale, che segue la Luna e i pianeti nel periodo.',
        (TradizioneEu.vedica, PeriodoEu.anno) =>
          'astrologia indiana, che guarda Giove e Saturno al tuo compleanno.',
        (TradizioneEu.vedica, _) =>
          'astrologia indiana, che conta i segni a partire dalla tua Luna di '
              'nascita.',
        (TradizioneEu.cinese, PeriodoEu.giorno) =>
          'astrologia cinese, che legge il tuo carattere di nascita (il BaZi) '
              'e il calendario del giorno.',
        (TradizioneEu.cinese, PeriodoEu.anno) =>
          'astrologia cinese, che legge il rapporto fra il tuo animale e '
              'quello dell\'anno.',
        (TradizioneEu.cinese, _) =>
          'astrologia cinese, che legge il rapporto fra il tuo animale e i '
              'giorni del periodo.',
      };

  /// **IL "DA DOVE VIENE" DELLA SCHEDA**, sesto giro GA.06, come lo direbbe
  /// un amico che sa leggere il cielo: il corpo ([cielo], due frasi nella
  /// Breve e tre nella Lunga, senza termini tecnici), nella Lunga la riga
  /// breve del rito ("Il rito del giorno: ...", senza nomi di dei o scuole) e
  /// in coda, su una riga separata, la fonte. Due letture cieche
  /// indipendenti hanno dato D3 sei e tre su dodici: spiegare il termine
  /// accanto al termine allungava il testo e il lettore trovava muri.
  static String? daDoveViene(String? cielo,
      {String? fonteDelRito,
      required PeriodoEu periodo,
      required DateTime primoGiorno,
      TradizioneEu tradizione = TradizioneEu.occidentale}) {
    final corpo = cielo?.trim() ?? '';
    if (corpo.isEmpty) return null;
    final quando = switch (periodo) {
      PeriodoEu.giorno => 'del giorno',
      PeriodoEu.settimana => 'della settimana',
      PeriodoEu.mese => 'del mese',
      PeriodoEu.anno => 'dell\'anno',
    };
    final rito = fonteDelRito == null || fonteDelRito.trim().isEmpty
        ? null
        : 'Il rito $quando: ${_minuscola(fonteDelRito.trim())}';
    return [
      corpo,
      if (rito != null) rito,
      'Fonte: ${laFonte(tradizione, periodo)}',
    ].join('\n');
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
          fonteDelRito: fonte,
          periodo: periodo,
          primoGiorno: primoGiorno,
          tradizione: tradizione),
    );
  }

  /// **IL TESTO DELLA SCHEDA**, per chi lo legge fuori dallo schermo (la
  /// chat con Medora, il Diario, il PDF dell'anno, la lettura completa): i
  /// paragrafi del responso nell'ordine in cui si leggono, separati da una
  /// riga vuota ([ITestiEu.fraIParagrafi]).
  static String testo(ResponsoInterpretato r) =>
      r.paragrafi.join(ITestiEu.fraIParagrafi);
}
