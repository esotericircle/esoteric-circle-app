import '../astro/zodiac.dart';

/// **IL GIORNO LUNARE**, ordine FV voce FV.04, 15 ottobre 2026: tutto cio'
/// che il Calendario Lunare sa di un giorno, calcolato sul telefono dal
/// motore lunare (`IlMotoreLunare`), nell'ora locale della persona, senza
/// rete e senza modello (Master V13 sezioni 41 e 43).
///
/// E' il contratto fra il motore, le regole delle attivita' e la schermata:
/// il motore lo riempie, le regole lo leggono, la schermata lo mostra.
class GiornoLunare {
  const GiornoLunare({
    required this.giorno,
    required this.elongazione,
    required this.illuminazione,
    required this.crescente,
    required this.fase,
    required this.segno,
    required this.cambiDiSegno,
    required this.fuoriCorso,
    required this.giornoLunare,
    required this.tipoBiodinamico,
    required this.lunaNuova,
    required this.lunaPiena,
  });

  /// Il giorno del calendario, a mezzanotte locale.
  final DateTime giorno;

  /// L'elongazione della Luna dal Sole a mezzogiorno locale, in gradi da 0
  /// a 360 (0 la Luna nuova, 180 la piena): sceglie la fotografia della Luna
  /// (FV.03).
  final double elongazione;

  /// La frazione illuminata del disco a mezzogiorno locale, da 0 a 1.
  final double illuminazione;

  /// Vero dalla Luna nuova alla piena.
  final bool crescente;

  /// La fase del giorno, col suo nome italiano.
  final FaseLunare fase;

  /// Il segno della Luna a mezzogiorno locale.
  final Zodiac segno;

  /// Gli ingressi della Luna in un segno nuovo dentro questo giorno locale
  /// (di solito zero o uno).
  final List<CambioDiSegno> cambiDiSegno;

  /// Gli intervalli di Luna fuori corso che toccano questo giorno locale,
  /// tagliati sul giorno.
  final List<IntervalloFuoriCorso> fuoriCorso;

  /// Il giorno lunare, da 1 a 30, contato dall'ultima Luna nuova.
  final int giornoLunare;

  /// Il tipo di giorno del calendario biodinamico a mezzogiorno locale; nullo
  /// se il confine della costellazione non si documenta (FV.04).
  final TipoBiodinamico? tipoBiodinamico;

  /// Vero se il momento esatto della Luna nuova cade in questo giorno locale.
  final bool lunaNuova;

  /// Vero se il momento esatto della Luna piena cade in questo giorno locale.
  final bool lunaPiena;

  /// Vero se in qualche ora del giorno la Luna e' fuori corso.
  bool get haFuoriCorso => fuoriCorso.isNotEmpty;
}

/// Le otto fasi, coi nomi italiani.
enum FaseLunare {
  nuova('Luna nuova'),
  crescente('Luna crescente'),
  primoQuarto('Primo quarto'),
  gibbosaCrescente('Gibbosa crescente'),
  piena('Luna piena'),
  gibbosaCalante('Gibbosa calante'),
  ultimoQuarto('Ultimo quarto'),
  calante('Luna calante');

  const FaseLunare(this.nome);
  final String nome;
}

/// Un ingresso della Luna in un segno.
class CambioDiSegno {
  const CambioDiSegno({required this.istante, required this.segno});

  /// L'istante dell'ingresso, in ora locale.
  final DateTime istante;

  /// Il segno in cui la Luna entra.
  final Zodiac segno;
}

/// **LA LUNA FUORI CORSO**: dall'ultimo aspetto maggiore della Luna a un
/// pianeta fino al suo ingresso nel segno successivo (Master V13 sezione 43).
class IntervalloFuoriCorso {
  const IntervalloFuoriCorso({required this.inizio, required this.fine});

  /// In ora locale.
  final DateTime inizio;

  /// In ora locale.
  final DateTime fine;

  Duration get durata => fine.difference(inizio);
}

/// I quattro tipi di giorno del metodo di Maria Thun, dall'elemento della
/// costellazione vera davanti a cui passa la Luna.
enum TipoBiodinamico {
  radice('Giorno radice', 'terra'),
  foglia('Giorno foglia', 'acqua'),
  fiore('Giorno fiore', 'aria'),
  frutto('Giorno frutto', 'fuoco');

  const TipoBiodinamico(this.nome, this.elemento);
  final String nome;
  final String elemento;

  /// Il sigillo dipinto del tipo (P2 dell'ordine FV).
  String get sigillo => 'assets/img/calendario_lunare/sig_thun_${name}_v1.webp';
}
