/// **QUANDO LA PERSONA HA FINITO DI PARLARE.** Ordine EJ voce 01, 24
/// settembre 2026.
///
/// Il fondatore, sulla 2278: *"Quando il maestro sta per finire di parlare,
/// il microfono si riattiva, ma mi lascia circa un secondo per parlare. Anche
/// quando inizio a parlare nuovamente, subito dopo il microfono si disattiva
/// e mi tronca la mia domanda che cmq viene inviata anche se ovviamente
/// sbagliata essendo troncata."*
///
/// **Le due cause erano nostre.** Il riconoscitore di Android chiude da solo
/// dopo qualche secondo di silenzio iniziale, e dopo la prima parola la
/// schermata chiudeva la frase a un secondo e mezzo dall'ultima parola
/// riconosciuta: una pausa per pensare a meta' frase la troncava, e il pezzo
/// partiva come domanda.
///
/// **Adesso il silenzio lo misura l'app**, sul livello del microfono, e la
/// regola sta qui, fuori dal widget, dove una prova la raggiunge:
///
/// - il rumore di fondo si impara dal livello piu' basso sentito, e parlare
///   vuol dire stare almeno [sopraIlFondo] decibel sopra di lui;
/// - finche' la persona non ha parlato, il silenzio non chiude niente;
/// - una frase si chiude solo dopo [silenzioCheChiude] di silenzio vero
///   **dopo** aver parlato: una pausa a meta' frase non basta;
/// - un colpo breve (un tocco, una porta) non e' parlare: serve almeno
///   [parlatoMinimo] di voce.
class IlSilenzioVero {
  IlSilenzioVero({
    this.silenzioCheChiude = const Duration(milliseconds: 2000),
    this.parlatoMinimo = const Duration(milliseconds: 250),
    this.sopraIlFondo = 12,
    this.perContinuare = 4,
    this.pavimento = -70,
  });

  /// **L'ISTERESI, ordine EJ voce 01.** Per COMINCIARE una frase la voce deve
  /// stare [sopraIlFondo] decibel sopra il fondo; per CONTINUARLA ne bastano
  /// questi. Misurato sul Realme il 24 settembre 2026: silenzio vero fra -85
  /// e -91 dB, voce che attacca a -42, code e attacchi deboli fra -58 e -75.
  /// Con una soglia sola le code diventavano silenzio, e una pausa di un
  /// secondo e mezzo chiudeva la frase a meta'.
  final double perContinuare;

  /// Sotto questo livello il microfono non insegna il fondo. Il registratore
  /// apre spesso con pezzi di zeri esatti, -100 dB: imparato li', il fondo
  /// faceva sembrare voce la stanza, e la frase non si chiudeva mai.
  final double pavimento;

  /// Quanto silenzio, dopo aver parlato, chiude la frase.
  final Duration silenzioCheChiude;

  /// Quanta voce serve perche' sia parlato e non un rumore.
  final Duration parlatoMinimo;

  /// Di quanti decibel la voce sta sopra il rumore di fondo.
  final double sopraIlFondo;

  double? _fondo;
  Duration _voce = Duration.zero;
  Duration _silenzio = Duration.zero;
  bool _haParlato = false;
  bool _chiusa = false;

  /// Vero quando la persona ha parlato abbastanza da contare come parlato.
  bool get haParlato => _haParlato;

  /// Vero quando la frase e' finita: silenzio vero dopo aver parlato.
  bool get fraseChiusa => _chiusa;

  /// Il rumore di fondo imparato finora, in decibel.
  double? get fondo => _fondo;

  /// Quanto silenzio di fila si e' sentito finora, per il registro.
  Duration get silenzioDiFila => _silenzio;

  /// Un pezzo di audio lungo [durata] al livello [decibel] (dBFS, negativo).
  void senti(double decibel, Duration durata) {
    if (_chiusa) return;
    if (decibel < pavimento) decibel = pavimento;
    // Il fondo scende subito al livello piu' basso, e risale piano SOLO
    // mentre la persona tace. La prima stesura lo faceva risalire anche
    // sulla voce: in una frase di otto secondi la voce finiva sotto la
    // soglia e diventava silenzio, cioe' lo stesso troncamento di prima.
    final f = _fondo ?? decibel;
    final parla = decibel >=
        f +
            (_haParlato || _voce > Duration.zero
                ? perContinuare
                : sopraIlFondo);
    if (decibel < f) {
      _fondo = decibel;
    } else if (!parla) {
      _fondo = f + (decibel - f) * 0.02;
    } else {
      _fondo = f;
    }
    if (parla) {
      _voce += durata;
      _silenzio = Duration.zero;
      if (_voce >= parlatoMinimo) _haParlato = true;
    } else {
      _silenzio += durata;
      if (!_haParlato && _silenzio > const Duration(milliseconds: 600)) {
        // Un colpo isolato non accumula parlato.
        _voce = Duration.zero;
      }
      if (_haParlato && _silenzio >= silenzioCheChiude) _chiusa = true;
    }
  }
}
