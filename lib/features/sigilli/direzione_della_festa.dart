library;

import '../../core/maestro/maestro.dart';

/// LA DIREZIONE DELLA FESTA, UNA PER MAESTRO. Ordine U voce 02.
///
/// **Perche' la direzione e non solo il colore.** Oggi le celebrazioni sono due,
/// una per i mini e una per i grandi, e sono uguali per tutti e tre i Maestri:
/// cambia la palette e basta. La persona deve riconoscere **di chi e' la festa
/// prima di leggere una parola**, e il colore da solo non basta perche' su una
/// scena che dura tre secondi si legge dopo il movimento, non prima.
///
/// **La direzione e' un DATO dichiarato, non un effetto che si intuisce
/// guardando.** Vive qui, una prova enumera i tre Maestri e pretende tre
/// direzioni diverse: se domani qualcuno riusa la scena di Medora per Aura, una
/// riga cade invece che passare inosservata.

/// Da dove parte il movimento e dove va.
enum DirezioneDellaFesta {
  /// **MEDORA: dal centro verso fuori.** Un'esplosione di stelle che si apre dal
  /// punto in cui il traguardo si e' acceso e riempie lo schermo, e nel farlo
  /// scopre il traguardo e il premio.
  dalCentro,

  /// **CALIGO: dall'alto verso il basso.** Una pioggia fitta di numeri di
  /// dimensioni diverse che cadono e riempiono la schermata; quando la cascata
  /// finisce verso il basso, sotto di essa restano scoperti il traguardo e il
  /// premio.
  dallAlto,

  /// **AURA: dal basso verso l'alto.** Polline e petali che salgono dal margine
  /// inferiore, si aprono e nel salire scoprono il traguardo e il premio.
  dalBasso,
}

/// Di che cosa e' fatta la festa: e' il segno del Maestro, non un ornamento.
enum MateriaDellaFesta {
  /// Stelle a cinque punte, di grandezze diverse.
  stelle,

  /// Cifre, e sono cifre vere perche' Caligo e' il Maestro dei numeri e delle
  /// rune: una pioggia di scintille sarebbe la stessa di Medora girata.
  numeri,

  /// Polline e petali.
  polline,
}

/// LA FESTA DI UN MAESTRO.
class FestaDelMaestro {
  const FestaDelMaestro({
    required this.direzione,
    required this.materia,
    required this.quanteParticelle,
  });

  final DirezioneDellaFesta direzione;
  final MateriaDellaFesta materia;

  /// Quante particelle a Quality Tier pieno. **Non e' un numero libero:** sotto
  /// questa quantita' il movimento non si legge come una direzione ma come
  /// qualche puntino che passa.
  final int quanteParticelle;
}

/// IL REGISTRO DELLE TRE FESTE.
class FesteDeiMaestri {
  const FesteDeiMaestri._();

  static const Map<Maestro, FestaDelMaestro> tutte = {
    Maestro.medora: FestaDelMaestro(
      direzione: DirezioneDellaFesta.dalCentro,
      materia: MateriaDellaFesta.stelle,
      quanteParticelle: 90,
    ),
    Maestro.caligo: FestaDelMaestro(
      direzione: DirezioneDellaFesta.dallAlto,
      materia: MateriaDellaFesta.numeri,
      // **Meno particelle delle altre due, e non e' una svista.** Una cifra e'
      // un segno complesso e occupa piu' spazio di una stella: novanta cifre
      // sarebbero una parete di inchiostro invece di una pioggia.
      quanteParticelle: 60,
    ),
    Maestro.aura: FestaDelMaestro(
      direzione: DirezioneDellaFesta.dalBasso,
      materia: MateriaDellaFesta.polline,
      quanteParticelle: 90,
    ),
  };

  static FestaDelMaestro di(Maestro maestro) => tutte[maestro]!;

  /// **QUANTO IL GRANDE E' PIU' AMPIO E PIU' LUNGO DEL MINI, in due numeri.**
  ///
  /// Non "piu' grande" a parole: una volta e mezzo le particelle, e un terzo di
  /// tempo in piu'. Sono rapporti e non misure, quindi valgono anche se domani
  /// la durata di base cambia.
  static const double quanteVolteIlGrande = 1.5;
  static const double quantoDuraDiPiuIlGrande = 1.33;

  /// **LA DURATA SI SCEGLIE SUL TEMPO DI LETTURA, non su quello
  /// dell'animazione.** Cio' che si scopre sotto la festa e' il nome del
  /// traguardo e il premio: due righe brevi. **Milleottocento millesimi** e' il
  /// tempo in cui il movimento arriva in fondo e la scritta e' gia' leggibile
  /// per intero, e vale la regola dell'attesa che e' una scena: piu' veloce non
  /// e' piu' breve, e' un difetto grafico, perche' la persona vede finire una
  /// cosa che non ha ancora cominciato a leggere.
  static const int millesimiDelMini = 1800;

  static int millesimiDi({required bool eGrande}) => eGrande
      ? (millesimiDelMini * quantoDuraDiPiuIlGrande).round()
      : millesimiDelMini;

  static int particelleDi(Maestro maestro, {required bool eGrande}) {
    final base = di(maestro).quanteParticelle;
    return eGrande ? (base * quanteVolteIlGrande).round() : base;
  }
}
