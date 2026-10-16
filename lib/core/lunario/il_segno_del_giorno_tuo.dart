import '../identity/birth_identity.dart';

/// **I QUATTRO GIORNI TUOI, IL CONTRATTO FRA IL CORPUS E LA SCHERMATA.**
/// Ordine FV voce FV.07, 15 ottobre 2026 (proposta dell'Architetto, voce 3,
/// "I giorni tuoi"; il fondatore: "Siz approvo tutto").
///
/// Il calcolo dei giorni e i testi brevi nella voce di Medora li scrive il
/// corpus (`lib/core/lunario/i_giorni_tuoi.dart`); la schermata del
/// Calendario li riceve come un elenco di [SegnoDelGiornoTuo] e li posa sul
/// mese coi sigilli d'oro. Questo file e' solo la forma che i due lati si
/// promettono: nessun calcolo e nessun testo stanno qui.
enum TipoDelGiornoTuo {
  /// La Luna torna al grado della tua Luna di nascita.
  ritornoLunare('sig_tuo_ritorno_lunare', dipendeDallOra: true),

  /// La Luna passa sul grado del tuo Sole.
  lunaSulTuoSole('sig_luna_sul_tuo_sole', dipendeDallOra: false),

  /// La Luna attraversa il tuo segno solare.
  lunaNelTuoSegno('sig_luna_nel_tuo_segno', dipendeDallOra: false),

  /// Torna la fase lunare della tua nascita, come contenuto simbolico (la
  /// PRIMA VIA, LA SIMBOLICA del 4 settembre 2026: nessuna parola sulla
  /// fecondita').
  faseDiNascita('sig_tua_fase_di_nascita', dipendeDallOra: true);

  const TipoDelGiornoTuo(this._base, {required this.dipendeDallOra});
  final String _base;

  /// Vero per i segni che vengono dalla Luna di nascita: senza l'ora di
  /// nascita tacciono, e al loro posto c'e' l'invito a inserirla (la regola
  /// che l'ordine FT da' alla Luna quando l'ora non e' nota).
  final bool dipendeDallOra;

  /// Il sigillo d'oro dipinto (P2 dell'ordine FV).
  String get sigillo => 'assets/img/calendario_lunare/${_base}_v1.webp';
}

/// Un giorno tuo nel mese: il giorno, il tipo e il testo breve di Medora.
class SegnoDelGiornoTuo {
  const SegnoDelGiornoTuo({
    required this.giorno,
    required this.tipo,
    required this.titolo,
    required this.testo,
  });

  /// Il giorno del calendario, a mezzanotte locale.
  final DateTime giorno;
  final TipoDelGiornoTuo tipo;

  /// Il titolo nel foglio del giorno, per esempio "Torna la tua Luna".
  final String titolo;

  /// Il testo breve nella voce di Medora, dal corpus.
  final String testo;

  String get sigillo => tipo.sigillo;
}

/// **LA PORTA DEI GIORNI TUOI**: dati la nascita e il mese, i segni di quel
/// mese. Il corpus la riempie; la schermata la chiede soltanto, e se la
/// nascita non porta l'ora toglie lei i segni che ne dipendono.
typedef IGiorniTuoiDelMese = List<SegnoDelGiornoTuo> Function(
    BirthIdentity nascita, int anno, int mese);
