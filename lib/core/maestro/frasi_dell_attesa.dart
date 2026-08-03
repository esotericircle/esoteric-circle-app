import '../chat/maestro_memory.dart';
import 'maestro.dart';
import 'natal_context.dart';

/// CHE COSA C'E' DAVVERO NEL CONTESTO CHE PARTE VERSO IL MODELLO.
///
/// Enumerato leggendo `MaestroPersona`, non a memoria. Sono questi e nessun
/// altro: chi ne aggiunge uno la' deve aggiungerlo qui, e il compilatore lo
/// costringe perche' l'enum e' chiuso.
enum DatoDelContesto {
  /// Nessuno: la frase e' vera sempre, perche' descrive cio' che l'app fa
  /// comunque, non un dato che potrebbe mancare.
  sempreVero,

  /// `- Segno solare: ...`
  segnoSolare,

  /// `- Segno lunare: ...`
  segnoLunare,

  /// `- Ascendente: ...`
  ascendente,

  /// `- Numero della vita: ...`
  numeroDellaVita,

  /// `- Fase lunare di nascita: ...`
  faseLunareDiNascita,

  /// Il blocco della memoria: dove eravate rimasti, e i fatti stabili.
  memoria,
}

/// Una riga dell'attesa, e il dato senza il quale NON si puo' mostrare.
class FraseDellAttesa {
  const FraseDellAttesa(this.testo, this.chiede);

  /// Cosa si legge. Gia' in italiano, con gli accenti veri.
  final String testo;

  /// Il dato che questa frase dichiara di stare guardando.
  final DatoDelContesto chiede;
}

/// LE FRASI DELL'ATTESA DEVONO DIRE IL VERO.
///
/// **La regola che non si negozia.** "Sto consultando il tuo ascendente" si
/// puo' scrivere SOLO se l'ascendente e' davvero nel contesto che parte verso
/// il modello. Una frase che dichiara un lavoro che non stiamo facendo e' una
/// costante che dichiara il falso, e in questo progetto ne abbiamo gia'
/// bruciate troppe.
///
/// **Cosa ho trovato enumerando, e che va detto.** Fra gli esempi di tono del
/// fondatore c'era "Sto analizzando i transiti". I transiti NON entrano nel
/// contesto: `MaestroPersona` manda segno solare, segno lunare, Ascendente,
/// numero della vita, fase lunare di nascita e la memoria, e nient'altro.
/// Quella frase non esiste qui, e non e' una dimenticanza.
///
/// **Niente frasi comuni ai tre.** Ogni Maestro guarda lo stesso dato con il
/// suo mestiere: Medora ci legge il moto nel tempo, Aura l'effetto nel corpo,
/// Caligo il simbolo. Una riga condivisa suonerebbe come un caricamento con
/// sopra un nome diverso.
class FrasiDellAttesa {
  const FrasiDellAttesa._();

  static const Map<Maestro, List<FraseDellAttesa>> perMaestro = {
    Maestro.medora: [
      FraseDellAttesa(
          'Sto guardando il tuo Ascendente', DatoDelContesto.ascendente),
      FraseDellAttesa(
          'Sto leggendo il tuo Sole', DatoDelContesto.segnoSolare),
      FraseDellAttesa(
          'Sto seguendo la tua Luna', DatoDelContesto.segnoLunare),
      FraseDellAttesa('Sto contando il tuo numero della vita',
          DatoDelContesto.numeroDellaVita),
      FraseDellAttesa('Sto tornando alla Luna della tua nascita',
          DatoDelContesto.faseLunareDiNascita),
      FraseDellAttesa(
          'Sto riprendendo da dove eravamo', DatoDelContesto.memoria),
      FraseDellAttesa(
          'Sto rileggendo la tua domanda', DatoDelContesto.sempreVero),
    ],
    Maestro.aura: [
      FraseDellAttesa('Sto sentendo dove si posa la tua Luna',
          DatoDelContesto.segnoLunare),
      FraseDellAttesa('Sto ascoltando il calore del tuo Sole',
          DatoDelContesto.segnoSolare),
      FraseDellAttesa('Sto cercando il respiro del tuo Ascendente',
          DatoDelContesto.ascendente),
      FraseDellAttesa('Sto misurando il tuo numero della vita',
          DatoDelContesto.numeroDellaVita),
      FraseDellAttesa('Sto risalendo alla Luna sotto cui sei nato',
          DatoDelContesto.faseLunareDiNascita),
      FraseDellAttesa(
          'Sto ricordando cosa ti muoveva', DatoDelContesto.memoria),
      FraseDellAttesa(
          'Sto respirando insieme alla tua domanda', DatoDelContesto.sempreVero),
    ],
    Maestro.caligo: [
      FraseDellAttesa('Sto cercando il segno del tuo Ascendente',
          DatoDelContesto.ascendente),
      FraseDellAttesa(
          'Sto incidendo il tuo Sole', DatoDelContesto.segnoSolare),
      FraseDellAttesa(
          'Sto interrogando la tua Luna', DatoDelContesto.segnoLunare),
      FraseDellAttesa('Sto pesando il tuo numero della vita',
          DatoDelContesto.numeroDellaVita),
      FraseDellAttesa('Sto guardando la Luna della tua nascita',
          DatoDelContesto.faseLunareDiNascita),
      FraseDellAttesa(
          'Sto riaprendo quello che avevi lasciato', DatoDelContesto.memoria),
      FraseDellAttesa(
          'Sto ascoltando cosa chiedi davvero', DatoDelContesto.sempreVero),
    ],
  };

  /// Vero se quel dato e' DAVVERO nel contesto di questa persona.
  ///
  /// Le condizioni sono le stesse, riga per riga, che `MaestroPersona` usa per
  /// decidere se scrivere quella riga nel prompt: se una diverge, la frase
  /// dichiara un lavoro che non si sta facendo.
  static bool ceIlDato(
    DatoDelContesto dato, {
    required NatalContext natal,
    required MaestroMemory memoria,
  }) {
    bool pieno(String? v) => v != null && v.trim().isNotEmpty;
    switch (dato) {
      case DatoDelContesto.sempreVero:
        return true;
      case DatoDelContesto.segnoSolare:
        return pieno(natal.sunSign);
      case DatoDelContesto.segnoLunare:
        return pieno(natal.moonSign);
      case DatoDelContesto.ascendente:
        return pieno(natal.ascendant);
      case DatoDelContesto.numeroDellaVita:
        return natal.lifeNumber != null;
      case DatoDelContesto.faseLunareDiNascita:
        return pieno(natal.moonPhase);
      case DatoDelContesto.memoria:
        return !memoria.isEmpty;
    }
  }

  /// Le frasi che questo Maestro puo' dire VERAMENTE a questa persona.
  ///
  /// Mai vuoto: l'ultima di ogni elenco non chiede nessun dato, quindi una
  /// persona senza carta natale e senza memoria vede comunque una riga vera
  /// invece di una scena muta.
  static List<String> per(
    Maestro maestro, {
    required NatalContext natal,
    required MaestroMemory memoria,
  }) {
    final tutte = perMaestro[maestro]!;
    return [
      for (final f in tutte)
        if (ceIlDato(f.chiede, natal: natal, memoria: memoria)) f.testo,
    ];
  }
}
