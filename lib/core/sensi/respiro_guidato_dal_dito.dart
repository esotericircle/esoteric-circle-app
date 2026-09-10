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
/// **NESSUNA SCHERMATA LO MONTA PIU', DAL 10 SETTEMBRE 2026.** Ordine DD voce
/// 17, decisione del fondatore: *"elimina la possibilita' di tenere il dito
/// premuto, solo pulsante play e stop"*.
///
/// **Non e' stato cancellato, ed e' una scelta.** Questo file misura una cosa
/// difficile e la misura bene: distingue uno scivolo del dito da un espiro
/// vero, butta i respiri piu' lunghi di un minuto, e non conta due volte un
/// dito alzato due volte. Sono tarature che sono costate un ordine intero, e
/// le sue quattordici prove restano verdi.
///
/// **Se un giorno il respiro guidato dal dito torna**, torna da qui, con le
/// sue soglie gia' provate. Cancellarlo vorrebbe dire rifarle a memoria.
///
/// **Chi conta i file di `lib` sappia che questo non ha chiamanti**: e'
/// dichiarato qui, non dedotto, e il conto e' stato fatto col grep il
/// 10 settembre 2026.
class RespiroGuidatoDalDito {
  RespiroGuidatoDalDito({
    Duration riferimento = riferimentoDelRespiro,
  }) : _riferimento = riferimento;

  /// **SEI ATTI AL MINUTO, E NON E' UN NUMERO SCELTO A OCCHIO.**
  /// Ordine DB voce 03, 9 settembre 2026.
  ///
  /// **Parole dell'ordine**: *"La respirazione attorno a sei atti al minuto,
  /// cioe' 0,1 Hz, e' la frequenza di risonanza del sistema cardiovascolare
  /// umano ed e' oggetto di ricerca peer reviewed su biofeedback della
  /// variabilita' cardiaca, pressione e umore. Il respiro guidato dall'app
  /// punta quindi a sei atti al minuto, e la durata di inspiro e di espiro
  /// discende da li'."*
  ///
  /// **E' l'unica cosa in questa funzione con letteratura scientifica seria
  /// alle spalle**, ed e' per questo che il riferimento non e' piu' i quattro
  /// secondi di prima: quelli erano un numero comodo per il disegno.
  ///
  /// Sei atti al minuto fanno **dieci secondi a respiro**, cioe' **cinque
  /// secondi di inspiro e cinque di espiro**. Il riferimento qui e' la meta'
  /// del ciclo, perche' descrive un solo verso.
  ///
  /// **NON E' UN RITMO DA RISPETTARE.** L'ordine e' esplicito: *"chi respira
  /// da solo con il dito non viene corretto e non viene giudicato: il suo
  /// ritmo e' il suo"*. Questo numero serve al disegno e alla lettura finale,
  /// e a nessuno viene detto che sta sbagliando.
  static const Duration riferimentoDelRespiro = Duration(seconds: 5);

  /// **QUANTI ATTI AL MINUTO SONO**, per i testi e per le prove: due mezzi
  /// respiri fanno un respiro, e sessanta secondi diviso quello da' il ritmo.
  static double get attiAlMinuto =>
      60 / (riferimentoDelRespiro.inMilliseconds * 2 / 1000);

  /// **IL TREMOLIO DEL CONTATTO, e nasce dal gesto che l'app chiede.**
  /// Ordine DA voce 01, 10 settembre 2026.
  ///
  /// **Il difetto che chiude**: l'app chiede di respirare **a occhi chiusi**,
  /// e a occhi chiusi il dito scivola. Uno scivolo di un attimo valeva come
  /// un dito alzato, quindi il respiro risultava finito quando non lo era, e
  /// dentro la sessione finivano due mezzi respiri al posto di uno intero.
  ///
  /// **Duecento millisecondi**: sotto questa soglia non c'e' nessun gesto
  /// umano di respiro, c'e' il contatto che salta. E' la stessa cura che si
  /// fa sui pulsanti per il rimbalzo del tocco.
  ///
  /// **Non si perde niente e non si inventa niente**: l'inspiro riprende da
  /// dove stava, con il suo tempo che continua a correre, perche' chi respira
  /// non ha mai smesso.
  static const Duration sogliaDelTremolio = Duration(milliseconds: 200);

  /// **UN RESPIRO PIU' LUNGO DI UN MINUTO NON E' UN RESPIRO.**
  /// Ordine DA voce 02, 10 settembre 2026.
  ///
  /// **Il difetto che chiude**: arriva una telefonata, l'app va in secondo
  /// piano col dito giu', e al ritorno il respiro risulta aperto da tre
  /// minuti. Quel numero finisce **nella media, nella figura della card e
  /// nella memoria**, e le sporca tutte e tre.
  ///
  /// **Sessanta secondi e' un confine largo e onesto**: il respiro di
  /// riferimento e' dieci secondi, il piu' lento dei respiri umani da sveglio
  /// non arriva al minuto, e chi trattiene il fiato per gioco non sta
  /// meditando. Oltre, si scarta.
  static const Duration respiroPiuLungoCheAbbiaSenso = Duration(seconds: 60);

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

  /// Quando e' cominciato l'inspiro di adesso, che NON e' `_iniziata`: quello
  /// riparte a ogni cambio di fase, questo tiene il principio del dentro anche
  /// quando il dito rimbalza.
  DateTime? _inizioDelDentro;

  /// **QUANTI RESPIRI SONO STATI SCARTATI perche' non erano respiri.**
  /// Il numero si dichiara invece di sparire: un conto che cala in silenzio e'
  /// il modo migliore per non accorgersi mai di un difetto.
  int _scartati = 0;

  /// Quanti tremolii del contatto sono stati assorbiti.
  int _tremolii = 0;

  /// La fase di adesso.
  FaseDelRespiro get fase => _fase;

  /// I respiri compiuti finora, in ordine.
  List<UnRespiro> get compiuti => List.unmodifiable(_compiuti);

  /// **QUANTI RESPIRI INTERI**, per la memoria della sessione.
  /// Ordine DB voce 07.
  int get quantiRespiri => _compiuti.length;

  /// **IL RITMO MEDIO DELL'INSPIRO**, o zero quando non si e' respirato.
  ///
  /// Serve alla memoria e alla lettura finale, **non a correggere nessuno**:
  /// l'ordine e' esplicito, *"chi respira da solo con il dito non viene
  /// corretto e non viene giudicato: il suo ritmo e' il suo"*.
  Duration get mediaDentro => _media((r) => r.dentro);

  /// Lo stesso per l'espiro.
  Duration get mediaFuori => _media((r) => r.fuori);

  Duration _media(Duration Function(UnRespiro) quale) {
    if (_compiuti.isEmpty) return Duration.zero;
    var somma = 0;
    for (final r in _compiuti) {
      somma += quale(r).inMilliseconds;
    }
    return Duration(milliseconds: somma ~/ _compiuti.length);
  }

  /// Quanti respiri interi sono stati compiuti.
  int get quanti => _compiuti.length;

  /// **QUANTI NE SONO STATI SCARTATI**, ordine DA voce 02: un respiro piu'
  /// lungo di un minuto non entra ne' nella media ne' nella figura.
  int get scartati => _scartati;

  /// **QUANTI TREMOLII DEL CONTATTO SONO STATI ASSORBITI**, ordine DA voce
  /// 01: sono i momenti in cui il dito e' scivolato e l'inspiro e' proseguito.
  int get tremoliiAssorbiti => _tremolii;

  /// **IL DITO SCENDE: comincia un inspiro, oppure ne riprende uno.**
  ///
  /// **Se il dito si era staccato da meno di [sogliaDelTremolio]**, non era un
  /// espiro: era il contatto che saltava sotto un dito fermo a occhi chiusi.
  /// L'inspiro riprende da dove stava, col suo tempo che non si e' mai
  /// fermato, e nessun mezzo respiro finisce nella memoria.
  void ditoGiu(DateTime adesso) {
    if (_fase == FaseDelRespiro.dentro) return;
    final principio = _inizioDelDentro;
    if (_fase == FaseDelRespiro.fuori &&
        principio != null &&
        adesso.difference(_iniziata ?? adesso) < sogliaDelTremolio) {
      _tremolii++;
      _fase = FaseDelRespiro.dentro;
      // **Il tempo dell'inspiro non riparte da zero**: chi respira non ha mai
      // smesso, e far ripartire il fiore da chiuso sarebbe la bugia visibile
      // di questo difetto.
      _iniziata = principio;
      return;
    }
    _fase = FaseDelRespiro.dentro;
    _iniziata = adesso;
    _inizioDelDentro = adesso;
  }

  /// **IL DITO SI ALZA: finisce l'inspiro e comincia l'espiro.**
  ///
  /// L'alzata si registra lo stesso anche quando l'inspiro e' durato un
  /// attimo: **e' il rientro a decidere** se quello era un espiro vero o un
  /// tremolio, e lo decide `ditoGiu` guardando quanto e' durato il distacco.
  /// Giudicare qui, sul solo dentro, vorrebbe dire buttare via gli inspiri
  /// brevi di chi respira corto.
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
    _fase = FaseDelRespiro.attesa;
    _iniziata = null;
    _inizioDelDentro = null;
    // **CIO' CHE NON E' UN RESPIRO NON ENTRA.** Ordine DA voce 02: se l'app e'
    // stata in secondo piano col dito giu', questo mezzo respiro dura minuti.
    // Lasciarlo entrare sporcherebbe la media, la figura della card e la
    // memoria, cioe' tutte e tre le cose che poi vengono raccontate.
    if (r.dentro > respiroPiuLungoCheAbbiaSenso ||
        r.fuori > respiroPiuLungoCheAbbiaSenso) {
      _scartati++;
      return null;
    }
    _compiuti.add(r);
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
