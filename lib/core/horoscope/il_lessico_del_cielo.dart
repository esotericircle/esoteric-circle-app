import '../astro/aspetti_di_oggi.dart';
import '../astro/natal_chart.dart';
import 'cielo_di_oggi.dart';
import 'corrente_del_cielo.dart';
import 'horoscope.dart';

/// **IL LESSICO DEL "DA DOVE VIENE", ordine GA voce GA.06, sesto giro.**
///
/// Il fondatore, 21 ottobre 2026: *"Le risposte vanno curate, sono la parte
/// più importante e criticata dell'app."* Due letture cieche indipendenti
/// hanno dato D3 sei su dodici e tre su dodici: "spiego il termine accanto al
/// termine" non basta, perche' allunga il testo e il lettore trova muri, frasi
/// vuote e gergo. Padre: ordine ES voci 02, 03, 04, 08 e 09 (la riga del cielo
/// scritta con le parole dei metodi), e le cure GA.06 dalla prima alla quinta,
/// che avevano spiegato il gergo senza toglierlo.
///
/// **Il "Da dove viene" adesso e' come lo direbbe un amico che sa leggere il
/// cielo**: il corpo (due frasi nella Breve, tre nella Lunga) dice che cosa
/// fa il cielo e che cosa significa per il campo, senza nessun termine
/// tecnico; il rito ha la sua riga breve; la fonte sta in una riga separata
/// in coda. Questo file ha le parole di tutti i giorni che servono ai
/// compositori: i campi, i giudizi, i rapporti fra i corpi, i punti della
/// carta di nascita. La guardia e'
/// `i_termini_del_cielo_hanno_la_loro_spiegazione_test`.
abstract final class IlLessicoDelCielo {
  /// Il campo, detto in una locuzione: "Per l'amore", "In generale".
  static const Map<HoroscopeDomain, String> perIlCampo = {
    HoroscopeDomain.generale: 'In generale',
    HoroscopeDomain.amore: 'Per l\'amore',
    HoroscopeDomain.carriera: 'Per il lavoro e lo studio',
    HoroscopeDomain.fortuna: 'Per la fortuna',
  };

  /// Il campo, in mezzo a una frase: "per l'amore".
  static String perIlCampoMinuscolo(HoroscopeDomain d) =>
      d == HoroscopeDomain.generale
          ? 'in generale'
          : perIlCampo[d]!.replaceFirst('P', 'p');

  /// Che cosa riguarda il campo, per dire "l'area che riguarda l'amore".
  static const Map<HoroscopeDomain, String> cheCosaRiguarda = {
    HoroscopeDomain.generale: 'la tua giornata',
    HoroscopeDomain.amore: 'l\'amore',
    HoroscopeDomain.carriera: 'il lavoro',
    HoroscopeDomain.fortuna: 'la fortuna',
  };

  /// Chi "guida" il campo nell'astrologia occidentale: l'ordine del dominio
  /// ascolta il Sole, Venere, Marte e Giove.
  static const Map<HoroscopeDomain, String> chiGuida = {
    HoroscopeDomain.generale: 'il Sole, che guida il tono della giornata',
    HoroscopeDomain.amore: 'Venere, che guida l\'amore',
    HoroscopeDomain.carriera: 'Marte, che guida l\'azione e il lavoro',
    HoroscopeDomain.fortuna: 'Giove, che guida la fortuna',
  };

  /// Il giudizio del livello, con le stesse parole della fascia della voce.
  static String giudizio(int livello) => livello >= 4
      ? 'favorevole'
      : livello <= 2
          ? 'in salita'
          : 'in equilibrio';

  static String _maiuscola(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  /// **LA FRASE CHE DICE CHE COSA SIGNIFICA PER IL CAMPO**, l'ultima del
  /// corpo: "Per l'amore il cielo di oggi è favorevole."
  static String conclusione(HoroscopeDomain d, int livello,
          {String quando = 'di oggi'}) =>
      '${perIlCampo[d]} il cielo $quando è ${giudizio(livello)}.';

  /// Come si dice un rapporto fra due corpi, con la sostanza e non il nome:
  /// "va d'accordo con", "fa attrito con".
  static String rapportoCon(AspectType a) => switch (a.harmony) {
        AspectHarmony.soft => 'va d\'accordo con',
        AspectHarmony.hard => 'fa attrito con',
        AspectHarmony.neutral => 'è a stretto contatto con',
      };

  /// Che cosa fa quel rapporto a chi legge: "ti sostiene", "ti mette alla
  /// prova". [segno] e' il segno del peso: positivo, negativo, zero.
  static String effetto(double segno) => segno > 0
      ? 'ti sostiene'
      : segno < 0
          ? 'ti mette un po\' alla prova'
          : 'non ti spinge né ti frena';

  /// Il punto della carta di nascita toccato, in parole di tutti i giorni.
  static String bersaglioInParole(VoceDelCielo v) {
    if (v.idBersaglio == AspettiDiOggi.idAscendente) {
      return 'il modo in cui ti presenti';
    }
    if (v.idBersaglio == AspettiDiOggi.idMedioCielo) {
      return 'la tua vita pubblica e il lavoro';
    }
    return switch (v.idBersaglio) {
      'sun' => 'il tuo carattere di fondo',
      'moon' => 'il tuo modo di sentire',
      'mercury' => 'il tuo modo di pensare e di parlare',
      'venus' => 'il tuo modo di amare',
      'mars' => 'la tua energia',
      'jupiter' => 'la tua fortuna di fondo',
      'saturn' => 'il tuo senso del dovere',
      _ => 'il tuo ${v.bersaglio} di nascita',
    };
  }

  /// Lo stesso, per un corpo natale dato per id (il momento chiave).
  static const Map<String, String> chePorta = {
    'sun': 'il tuo carattere di fondo',
    'moon': 'il tuo modo di sentire',
    'venus': 'il tuo modo di amare',
    'mars': 'la tua energia nel lavoro',
    'jupiter': 'la tua fortuna di fondo',
  };

  /// Le fasi della Luna dette in parole di tutti, da dopo "in Leone": la
  /// Luna nuova, a un quarto, piena, all'ultimo quarto.
  static const List<String> fasiDellaLuna = [
    'c\'è la Luna nuova',
    'la Luna cresce verso la piena',
    'c\'è la Luna piena',
    'la Luna cala verso la nuova',
  ];

  /// Che cosa fa quella fase, in una frase che continua la precedente.
  static const List<String> effettoDelleFasi = [
    'il momento di cominciare qualcosa',
    'quando ciò che avvii prende forza',
    'quando ciò che era in corso si vede con più chiarezza',
    'il momento di chiudere e lasciare andare',
  ];

  /// "È il momento da cogliere", con il campo davanti tranne che nel
  /// Generale ("In generale è il momento" suonava male).
  static String ilMomento(HoroscopeDomain d, String cosa) =>
      d == HoroscopeDomain.generale
          ? 'È il momento $cosa.'
          : '${perIlCampo[d]} è il momento $cosa.';

  /// La conclusione della Lunga, che non ripete l\'inizio dell\'altra:
  /// "Nel complesso, per l\'amore la settimana è favorevole."
  static String nelComplesso(HoroscopeDomain d, int livello,
          {String quando = 'la settimana'}) =>
      d == HoroscopeDomain.generale
          ? 'Nel complesso $quando è ${giudizio(livello)}.'
          : 'Nel complesso, ${perIlCampoMinuscolo(d)} $quando è ${giudizio(livello)}.';

  /// La prima lettera maiuscola, per chi compone una frase.
  static String maiuscola(String s) => _maiuscola(s);

  /// Il rapporto fra due animali cinesi in parole di tutti i giorni, per la
  /// frase "il tuo Cane e il Cavallo ...". Nell'ordine di
  /// `RapportoFraAnimali`.
  static const Map<String, String> rapportoFraAnimali = {
    'armonia': 'vanno d\'accordo',
    'triplaArmonia': 'si sostengono: stanno nello stesso gruppo di tre animali',
    'scontro': 'sono opposti',
    'punizione': 'si ostacolano',
    'danno': 'si danneggiano',
    'armoniaChePunisce': 'si cercano e si urtano',
    'stessoAnimale': 'sono lo stesso animale',
    'nessuno': 'non hanno un rapporto particolare',
  };

  /// Le aree della vita di una casa solare (1-12), per "nell'area di ..."
  static String areaDellaVita(int casa) =>
      'area ${CorrenteDelCielo.materiaDelleCase[casa - 1]}';
}
