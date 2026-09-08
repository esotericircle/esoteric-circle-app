/// **IL RESPIRO GUIDATO DAL DITO.** Ordine CZ voce 08, 8 settembre 2026.
///
/// **Il fatto del fondatore**: *"Il cerchio che si gonfia esce. E' la forma di
/// ogni altra app di meditazione e non e' la nostra."* E poi: *"Il ritmo non
/// e' un preset. L'utente tiene il dito sullo schermo mentre inspira e lo alza
/// quando espira, e sono i suoi tempi reali a muovere il fiore."*
///
/// **Cosa fa questo modulo, e cosa non fa.** Tiene i tempi veri di ogni
/// inspiro e di ogni espiro, e da quelli ricava l'apertura del fiore. **Non
/// disegna niente e non tocca nessun sensore**: il gesto e' il dito, quindi la
/// regola di casa sul ripiego tattile e' soddisfatta per costruzione, non con
/// una via di scorta aggiunta dopo.
///
/// **Perche' i tempi VERI e non un ritmo imposto.** Un ritmo imposto e' un
/// compito: chi non ci sta dietro sbaglia. I tempi propri non si possono
/// sbagliare, e sono anche cio' che rende la figura finale diversa per
/// ognuno, che e' la ragione per cui vale la pena condividerla.
library;

/// La fase in cui il respiro si trova adesso.
enum FaseDelRespiro {
  /// Il dito non e' ancora sceso: si aspetta.
  attesa,

  /// Dito giu': si inspira, e il fiore si apre.
  dentro,

  /// Dito alzato: si espira, e il fiore si chiude.
  fuori,
}

/// Un respiro compiuto: quanto e' durato dentro e quanto fuori.
class UnRespiro {
  const UnRespiro({required this.dentro, required this.fuori});

  /// Quanto e' durato l'inspiro.
  final Duration dentro;

  /// Quanto e' durato l'espiro.
  final Duration fuori;

  /// Il respiro intero.
  Duration get intero => dentro + fuori;

  /// **QUANTO PESA IL DENTRO SUL TOTALE**, da 0 a 1.
  ///
  /// E' la sola misura che descrive la FORMA di un respiro e non la sua
  /// durata: chi inspira a lungo ed espira corto ha un profilo diverso da chi
  /// fa il contrario, anche se i due respiri durano uguale. E' quella che
  /// disegna la figura della card.
  double get quotaDelDentro =>
      intero.inMilliseconds == 0 ? 0.5 : dentro.inMilliseconds / intero.inMilliseconds;
}

/// **IL MOTORE DEL RESPIRO.** Riceve il dito e restituisce l'apertura.
///
/// Non ha timer suoi: chi lo usa gli dice che ora e', e lui risponde. Cosi'
/// una prova puo' far scorrere venti minuti in un millisecondo, e la scena non
/// ha due orologi che si contraddicono.
class RespiroGuidatoDalDito {
  RespiroGuidatoDalDito({
    Duration riferimento = const Duration(seconds: 4),
  }) : _riferimento = riferimento;

  /// **QUANTO DURA UN INSPIRO PIENO, per il disegno e basta.**
  ///
  /// Non e' un ritmo da rispettare e nessuno lo chiede a chi respira: serve
  /// solo a sapere a che punto disegnare i petali quando il dito e' giu' da
  /// tre secondi. Chi tiene il dito piu' a lungo trova il fiore gia' tutto
  /// aperto, e va bene cosi'.
  final Duration _riferimento;

  FaseDelRespiro _fase = FaseDelRespiro.attesa;
  DateTime? _iniziata;
  Duration _ultimoDentro = Duration.zero;
  final List<UnRespiro> _compiuti = [];

  /// La fase di adesso.
  FaseDelRespiro get fase => _fase;

  /// I respiri compiuti finora, in ordine.
  List<UnRespiro> get compiuti => List.unmodifiable(_compiuti);

  /// Quanti respiri interi sono stati compiuti.
  int get quanti => _compiuti.length;

  /// **IL DITO SCENDE: comincia un inspiro.**
  void ditoGiu(DateTime adesso) {
    if (_fase == FaseDelRespiro.dentro) return;
    _fase = FaseDelRespiro.dentro;
    _iniziata = adesso;
  }

  /// **IL DITO SI ALZA: finisce l'inspiro e comincia l'espiro.**
  void ditoSu(DateTime adesso) {
    if (_fase != FaseDelRespiro.dentro) return;
    _ultimoDentro = adesso.difference(_iniziata ?? adesso);
    _fase = FaseDelRespiro.fuori;
    _iniziata = adesso;
  }

  /// **IL RESPIRO SI CHIUDE**, e lo chiama chi rimette il dito giu' oppure il
  /// tempo che scorre. Torna il respiro appena compiuto, se ce n'era uno.
  UnRespiro? chiudiIlRespiro(DateTime adesso) {
    if (_fase != FaseDelRespiro.fuori) return null;
    final fuori = adesso.difference(_iniziata ?? adesso);
    final r = UnRespiro(dentro: _ultimoDentro, fuori: fuori);
    _compiuti.add(r);
    _fase = FaseDelRespiro.attesa;
    _iniziata = null;
    return r;
  }

  /// **QUANTO E' APERTO IL FIORE ADESSO**, da 0 chiuso a 1 aperto.
  ///
  /// Si apre mentre il dito e' giu' e si chiude mentre e' alzato, **sui tempi
  /// veri di chi respira**. La chiusura usa la durata dell'inspiro appena
  /// fatto: chi ha inspirato a lungo vede il fiore chiudersi con la stessa
  /// calma con cui si e' aperto, ed e' quello che rende il gesto simmetrico
  /// senza imporre nessun ritmo.
  double aperturaAdesso(DateTime adesso) {
    final da = _iniziata;
    if (da == null) return _fase == FaseDelRespiro.dentro ? 1.0 : 0.0;
    final passata = adesso.difference(da);
    switch (_fase) {
      case FaseDelRespiro.attesa:
        return 0.0;
      case FaseDelRespiro.dentro:
        final q = passata.inMilliseconds / _riferimento.inMilliseconds;
        return q.clamp(0.0, 1.0);
      case FaseDelRespiro.fuori:
        final quanto = _ultimoDentro.inMilliseconds == 0
            ? _riferimento.inMilliseconds
            : _ultimoDentro.inMilliseconds;
        final q = 1.0 - (passata.inMilliseconds / quanto);
        return q.clamp(0.0, 1.0);
    }
  }

  /// **LA FIGURA DEL RESPIRO**, cioe' la quota del dentro di ogni respiro.
  ///
  /// E' cio' che la card disegna, ed e' diversa per ognuno perche' nessuno
  /// respira come un altro.
  List<double> get figura =>
      _compiuti.map((r) => r.quotaDelDentro).toList(growable: false);
}
