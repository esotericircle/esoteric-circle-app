library;

import '../../core/maestro/maestro.dart';
import '../../core/sigilli/sentieri.dart';

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

  /// **RUNE, tracciate a segni e non scritte.** Decisione di Mauro del 15 agosto
  /// 2026, che cambia una sua indicazione precedente: la materia era `numeri`,
  /// "una pioggia fitta di numeri di dimensioni diverse". **Una pioggia di cifre
  /// arabe si legge come pioggia digitale, e i numeri arabi non stanno in
  /// nessuna tradizione di Caligo.** La direzione non cambia: resta dall'alto
  /// verso il basso.
  rune,

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
      materia: MateriaDellaFesta.rune,
      // **QUARANTA, E IL NUMERO E' MISURATO, non ereditato.** Il criterio non e'
      // "quante ce ne stanno": e' **arrivare alla copertura delle altre due**,
      // perche' tre feste che pesano in modo diverso si leggerebbero come tre
      // cure diverse. Misurato sul fotogramma di meta' corsa, che e' il pieno
      // della festa: 150 particelle davano l'8,1 per cento di schermo coperto,
      // 70 il 4,3, 55 il 3,6, 45 il 3,2, **40 il 2,8**, che cade fra il 2,5 di
      // Medora e il 2,9 di Aura.
      //
      // **La previsione era sbagliata, e va detto.** Sembrava che una runa a
      // tratti fosse piu' leggera di una cifra piena e che il numero dovesse
      // salire dai sessanta di prima: una runa e' fatta di tratti LUNGHI, che
      // attraversano tutto il riquadro, mentre una cifra sta raccolta al centro
      // del suo. A parita' di grandezza una runa copre di piu', non di meno.
      quanteParticelle: 40,
    ),
    Maestro.aura: FestaDelMaestro(
      direzione: DirezioneDellaFesta.dalBasso,
      materia: MateriaDellaFesta.polline,
      quanteParticelle: 90,
    ),
  };

  static FestaDelMaestro di(Maestro maestro) => tutte[maestro]!;

  /// **DI CHI E' LA FESTA, quando i traguardi celebrati sono piu' di uno.**
  /// Ordine AO voce 05.
  ///
  /// **La regola**: e' del traguardo PIU' IMPORTANTE, cioe' del primo grande
  /// se ce n'e' uno, e a parita' del primo nominato. E' la stessa regola con
  /// cui la scena sceglie gia' l'INTENSITA', e tenerne due diverse per due
  /// aspetti della stessa scena vorrebbe dire mostrare la festa piena di un
  /// Maestro con la materia di un altro.
  ///
  /// **Cosa faceva prima, e perche' Mauro vedeva sempre la stessa festa.** La
  /// scena prendeva `sentieri.first.maestro`, cioe' il primo dell'elenco. E
  /// l'elenco non e' casuale: nasce scorrendo i traguardi nell'ordine in cui
  /// sono dichiarati, dove i Sigilli di Medora vengono prima. Nella festa
  /// unita, che e' il caso normale, vinceva quasi sempre Medora: misurato con
  /// un mini di Medora davanti a un GRANDE di Caligo, dove si vedevano le
  /// stelle mentre si celebrava una runa.
  static Maestro dellaScena(
    List<Traguardo> traguardi,
    List<Sentiero> sentieri,
  ) {
    // Le due liste camminano appaiate: la scena stessa lo pretende prima di
    // aprirsi, e qui si e' prudenti perche' un indice fuori posto in una
    // celebrazione sarebbe uno schermo nero al posto di una festa.
    if (sentieri.isEmpty) return Maestro.medora;
    for (var i = 0; i < traguardi.length && i < sentieri.length; i++) {
      if (traguardi[i].eGrande) return sentieri[i].maestro;
    }
    return sentieri.first.maestro;
  }

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
