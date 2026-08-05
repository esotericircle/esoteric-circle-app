/// I TEMPI DEL RESPIRO, come numeri e non come prosa.
///
/// **Perche' esiste.** Il rito del giorno dichiara una cadenza, per esempio
/// "sei tempi dentro e sei fuori, tre volte", e fino a ieri quella cadenza
/// viveva solo dentro una frase da leggere: la persona doveva contare a mente
/// mentre guardava un simbolo fermo. Il testo resta, come spiegazione, ma la
/// cadenza adesso e' anche un dato, e da un dato si puo' muovere una figura.
///
/// **Un tempo e' un secondo.** Non e' una scelta arbitraria e nemmeno una
/// convenzione nostra: nelle pratiche di respiro guidato il "tempo" e' il
/// conteggio lento che si fa a voce, ed e' vicino al secondo. Vale la pena
/// dirlo qui perche' e' l'unico numero di questo file che non arrivi dal
/// corpus, e un numero che non si sa da dove viene diventa magico dopo un
/// mese.
class TempiDelRespiro {
  const TempiDelRespiro({required this.tempi, required this.giri});

  /// Quanti tempi dura ogni fase, dentro e fuori.
  final int tempi;

  /// Quanti giri completi, cioe' quante volte dentro piu' fuori.
  final int giri;

  /// Quanto dura un tempo.
  static const Duration unTempo = Duration(seconds: 1);

  /// Quanto dura una fase, cioe' l'entrata o l'uscita.
  Duration get fase => unTempo * tempi;

  /// Quanto dura un giro intero: entrata piu' uscita.
  Duration get giro => fase * 2;

  /// Quanto dura tutto il respiro.
  Duration get intero => giro * giri;

  /// Vero se questi tempi hanno senso: un respiro di zero tempi o di zero giri
  /// non e' un respiro, e chi lo riceve deve poterlo sapere invece di
  /// mostrare una figura ferma che sembra guasta.
  bool get reggono => tempi > 0 && giri > 0;

  /// A CHE PUNTO SI E' a un dato istante dall'inizio.
  ///
  /// Torna null quando il respiro e' finito: chi guarda deve poter distinguere
  /// "sono all'ultimo istante dell'ultimo giro" da "e' finito", e un valore
  /// che continua a girare non lo permetterebbe.
  MomentoDelRespiro? momento(Duration trascorso) {
    if (!reggono || trascorso >= intero || trascorso.isNegative) return null;
    final dentroIlGiro = trascorso.inMilliseconds % giro.inMilliseconds;
    final entra = dentroIlGiro < fase.inMilliseconds;
    final nellaFase =
        entra ? dentroIlGiro : dentroIlGiro - fase.inMilliseconds;
    return MomentoDelRespiro(
      giro: trascorso.inMilliseconds ~/ giro.inMilliseconds + 1,
      entra: entra,
      avanzamento: nellaFase / fase.inMilliseconds,
    );
  }
}

/// Dove si e' dentro il respiro, in un certo istante.
class MomentoDelRespiro {
  const MomentoDelRespiro({
    required this.giro,
    required this.entra,
    required this.avanzamento,
  });

  /// Il giro in corso, contato da uno: e' il numero che si mostra.
  final int giro;

  /// Vero mentre l'aria entra, falso mentre esce.
  final bool entra;

  /// Quanto e' avanzata la fase in corso, da zero a uno.
  final double avanzamento;

  /// LA MISURA DELLA FIGURA, da 0,55 a 1.
  ///
  /// Non da zero a uno: un simbolo che si azzera sparisce, e un rito in cui la
  /// figura sparisce a ogni espirazione si legge come un guasto. Il minimo
  /// tiene la figura sempre presente e riconoscibile, e l'escursione resta
  /// abbastanza ampia perche' il movimento si veda anche con la coda
  /// dell'occhio, che e' come lo si guarda mentre si respira.
  double get misura {
    const minima = 0.55;
    final t = entra ? avanzamento : 1 - avanzamento;
    return minima + (1 - minima) * t;
  }

  /// La parola che accompagna la fase. Due sole, e brevi: chi respira non
  /// legge una frase, coglie una parola.
  String get parola => entra ? 'Dentro' : 'Fuori';
}
