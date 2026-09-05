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
    final nellaFase = entra ? dentroIlGiro : dentroIlGiro - fase.inMilliseconds;
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

  /// La parola che accompagna la fase, dal punto unico delle parole.
  String get parola =>
      entra ? ParoleDelRespiro.inspira : ParoleDelRespiro.espira;
}

/// LE PAROLE DEL RESPIRO, in un punto solo.
///
/// **Perche' non stanno nella schermata.** Sono testi approvati da Mauro, e il
/// giorno che cambiano non devono esserci due posti da allineare. Stanno qui,
/// accanto ai numeri che governano l'animazione, perche' e' da quei numeri che
/// la forma del rito si scrive.
///
/// **Perche' non dicono piu' "dentro" e "fuori".** Quelle due parole
/// descrivono dove va l'aria, non il gesto da fare: chi tiene gli occhi
/// socchiusi le legge e non sa cosa fare. "Inspira" ed "Espira" sono il gesto.
class ParoleDelRespiro {
  const ParoleDelRespiro._();

  /// La frase grande dell'apertura, prima che il conteggio cominci.
  static const String preparati = 'Preparati a respirare';

  /// Le due parole del gesto, quelle grandi al centro.
  static const String inspira = 'Inspira';
  static const String espira = 'Espira';

  /// La chiusura, quando l'ultimo giro si e' chiuso.
  static const String compiuto = 'Il respiro è compiuto.';

  /// La parola del pulsante che fa partire il conto.
  ///
  /// ORDINE 2163, VOCE 11: il respiro non parte piu' da solo. L'apertura resta
  /// a video FINCHE' la persona non tocca, e il tempo di lettura lo decide lei.
  static const String tocca = 'Tocca per cominciare';

  /// Quanto dura il conto alla rovescia, dal tocco al primo gesto.
  ///
  /// Quattro secondi: 3, 2, 1, 0, un numero al secondo, deterministico. Non e'
  /// piu' l'attesa dell'apertura di due secondi: quel timer partiva da solo, e
  /// Mauro l'ha revocato con l'ordine 2163.
  static const Duration durataDelConto = Duration(seconds: 4);

  /// LA FORMA DEL RITO, coi numeri VERI.
  ///
  /// **I numeri arrivano dai tempi che l'animazione esegue**, non da una frase
  /// scritta a mano: una riga che dichiara quattro tempi mentre la figura ne
  /// conta sei e' peggio di nessuna riga, e questo progetto l'ha gia' pagato
  /// una volta.
  static String formaDi(TempiDelRespiro tempi) {
    final t = _inLettere(tempi.tempi);
    final g = _inLettere(tempi.giri);
    final volte = tempi.giri == 1 ? 'Una volta' : '$g volte';
    return '$t tempi dentro, ${t.toLowerCase()} fuori. $volte.';
  }

  /// La riga di servizio sotto la parola grande.
  static String giro(int quale, int quanti) => 'giro $quale di $quanti';

  /// I numeri piccoli si dicono in lettere, come li direbbe un Maestro: fino a
  /// dodici bastano e avanzano per una cadenza di respiro, e oltre si torna
  /// alla cifra invece di inventare una parola.
  static String _inLettere(int n) {
    const nomi = [
      '',
      'Uno',
      'Due',
      'Tre',
      'Quattro',
      'Cinque',
      'Sei',
      'Sette',
      'Otto',
      'Nove',
      'Dieci',
      'Undici',
      'Dodici',
    ];
    return n >= 1 && n < nomi.length ? nomi[n] : '$n';
  }
}
