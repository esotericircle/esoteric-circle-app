import 'dart:math' as math;
import 'dart:typed_data';

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
///
/// **E LA VOCE DEVE ESSERE VOCE.** Ordine EM voce 04, 25 settembre 2026. Il
/// fondatore: *"il microfono è troppo sensibile, rileva anche solo il
/// respiro, è molto grave perché fin quando il microfono rileva il minimo
/// rumore, la risposta non parte"*; e subito dopo: *"Non è solo il respiro,
/// ma potrebbe sempre esserci un rumore di fondo in qualunque ambiente. Io
/// uso "Ok Google" giornalmente con TV accesa e gemini riconosce la mia voce
/// Senza problemi. Ho bisogno dello stesso livello di accuratezza e
/// tolleranza"*.
///
/// **La causa.** Qui un pezzo era parlato se era abbastanza forte, e nient'
/// altro: il respiro vicino al microfono, un ventilatore o una televisione
/// superavano il fondo come una voce, la frase non si chiudeva, e l'orologio
/// dei trenta secondi non contava perche' la persona "parlava". Padre: ordine
/// EJ voce 01, che ha scritto la regola sul solo livello.
///
/// **Adesso un pezzo e' parlato solo se sono vere due cose in piu':**
///
/// - **e' voce**: la voce umana ha un'altezza, cioe' si ripete da 70 a 400
///   volte al secondo; il respiro, un ventilatore e un fruscio no.
///   [LaMisuraDellaVoce] lo misura sul PCM, e [sogliaDellaVoce] dice quanto
///   deve ripetersi. Le consonanti sorde dentro una parola, la "s" e la "f",
///   non spezzano la frase: dopo l'ultimo pezzo di voce la frase resta viva
///   per [codaDellaVoce];
/// - **sta sopra il sottofondo**, non solo sopra il silenzio: [LaStanza]
///   ricorda anche il livello alto di cio' che si sente quando nessuno parla
///   al telefono, per esempio una televisione, e per cominciare una frase la
///   voce deve stargli [sopraIlSottofondo] decibel sopra; per continuarla,
///   [sopraIlSottofondoPerContinuare]. Chi parla al telefono e' vicino, la
///   televisione e' lontana.
///
/// **LA TELEVISIONE CHE NON SI FERMA MAI.** Ordine EM voce 04, secondo giro,
/// 25 settembre 2026. Sul Realme, con un notiziario e una musica suonati
/// dalle casse del PC e la domanda dodici decibel sopra, la prima stesura di
/// questa regola ha aperto una frase sulla televisione al terzo secondo e
/// **l'ha tenuta aperta per 141,6 secondi**, finche' la traccia non e'
/// finita: la risposta non partiva, esattamente il guasto del fondatore. La
/// causa stava qui: la stanza imparava solo dai pezzi **sotto** la soglia
/// d'inizio, e una televisione piu' forte della soglia non poteva essere
/// imparata mai. Padre: questa stessa voce, prima stesura.
///
/// Adesso le cose sono tre:
///
/// - contro la televisione decide la **media dell'energia** dell'ultimo
///   mezzo secondo, [finestraDelLivello], non un pezzo solo, e la stanza
///   impara la stessa media: su mezzo secondo, al ritmo delle sillabe, chi
///   parla vicino al telefono e la televisione si separano; pezzo per pezzo
///   no;
/// - quando una frase resta aperta su un **suono continuo**, cioe' con meno
///   di [quotaDiSilenzio] del tempo preso per silenzio, ogni [controlloOgni]
///   la frase chiede un **controllo**: la schermata la fa trascrivere, e se
///   era solo sottofondo la scarta e la stanza impara il suo livello
///   ([LaStanza.imparaTutte]); se le parole di chi parla smettono di
///   crescere, la chiude e la manda. Le pause di pensiero in una stanza
///   silenziosa sono silenzio, e non chiedono controlli;
/// - la stanza **dimentica** cio' che ha imparato dopo [LaStanza.memoria] di
///   ascolto: una televisione spenta smette di alzare la soglia.
class IlSilenzioVero {
  IlSilenzioVero({
    this.silenzioCheChiude = const Duration(milliseconds: 2000),
    this.parlatoMinimo = const Duration(milliseconds: 250),
    this.sopraIlFondo = 12,
    this.perContinuare = 4,
    this.pavimento = -70,
    this.sopraIlSottofondo = 4,
    this.sopraIlSottofondoPerContinuare = 2,
    this.sogliaDellaVoce = 0.55,
    this.codaDellaVoce = const Duration(milliseconds: 400),
    this.silenzioDiPausa = const Duration(milliseconds: 700),
    this.finestraDelLivello = const Duration(milliseconds: 500),
    this.controlloOgni = const Duration(seconds: 3),
    this.quotaDiSilenzio = 0.35,
    LaStanza? stanza,
  }) : stanza = stanza ?? LaStanza();

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

  /// Di quanti decibel la voce deve stare sopra il sottofondo per COMINCIARE
  /// una frase. Ordine EM voce 04. **Quattro e non sei**, secondo giro:
  /// adesso si confrontano medie di mezzo secondo, che nella televisione
  /// variano poco. Sul Realme la domanda stava in media sette decibel sopra
  /// la televisione: con sei, pezzo per pezzo, si apriva a fatica.
  final double sopraIlSottofondo;

  /// E per CONTINUARLA: sopra il sottofondo, cosi' che nelle pause della
  /// persona la televisione conti come silenzio. Ordine EM voce 04.
  final double sopraIlSottofondoPerContinuare;

  /// Da zero a uno: quanto un pezzo deve ripetersi per essere voce. Ordine
  /// EM voce 04. **Tarato al banco il 25 settembre 2026**, pezzi di 32
  /// millesimi sopra -40 dB: la voce vera di `test/fixtures/em` passa al 91
  /// per cento, un respiro sintetico e un fruscio mai; a 0,45 il respiro
  /// passava all'1,1 per cento.
  final double sogliaDellaVoce;

  /// Quanto la frase resta viva dopo l'ultimo pezzo di voce, per le
  /// consonanti sorde. Ordine EM voce 04.
  final Duration codaDellaVoce;

  /// **Dopo quanto silenzio la frase e' in pausa**, cioe' forse finita: la
  /// schermata comincia a trascriverla prima che [silenzioCheChiude] la
  /// chiuda, e la risposta arriva prima. Ordine EM voce 11.
  final Duration silenzioDiPausa;

  /// **Su quanto tempo si media l'energia** del livello che si confronta con
  /// la televisione. Ordine EM voce 04, secondo giro: mezzo secondo sono due
  /// o tre sillabe. La prima stesura mediava centocinquanta millesimi, una
  /// sillaba: al banco, con i livelli della televisione del Realme, una
  /// persona sette decibel sopra la televisione non apriva la frase.
  final Duration finestraDelLivello;

  /// **Ogni quanto una frase aperta su un suono continuo chiede un
  /// controllo**, e su quanta coda si misura se il suono e' continuo. Ordine
  /// EM voce 04, secondo giro.
  final Duration controlloOgni;

  /// **Sotto questa parte di tempo preso per silenzio il suono e'
  /// continuo.** Si misura proprio cio' che tiene aperta una frase: quanto
  /// spesso la regola sente parlare. Sul Realme il 25 settembre 2026, su
  /// finestre di tre secondi, la frase aperta dalla televisione finta aveva
  /// il silenzio a circa il cinque per cento del tempo, la domanda con due
  /// pause di pensiero sopra il trenta. La prima stesura contava i pezzi
  /// vicini al fondo: in una stanza con un fondo alto le code della
  /// televisione ci stavano, e la televisione non sembrava continua.
  final double quotaDiSilenzio;

  /// La stanza, che si ricorda da una frase all'altra. Ordine EM voce 04.
  final LaStanza stanza;

  double? _fondo;
  Duration _voce = Duration.zero;
  Duration _silenzio = Duration.zero;
  Duration _dallUltimaVoce = const Duration(days: 1);
  bool _haParlato = false;
  bool _chiusa = false;
  bool _inPausa = false;
  bool _parlaAdesso = false;
  int _pause = 0;
  int _controlli = 0;
  Duration _daControllo = Duration.zero;
  final _energie = <(double, Duration)>[];
  final _silenzi = <(bool, Duration)>[];
  Duration _codaMisurata = Duration.zero;
  final _vociSentite = <double>[];
  Duration _voceDellaFrase = Duration.zero;

  /// Vero quando la persona ha parlato abbastanza da contare come parlato.
  bool get haParlato => _haParlato;

  /// Vero quando la frase e' finita: silenzio vero dopo aver parlato.
  bool get fraseChiusa => _chiusa;

  /// Vero quando, dopo aver parlato, il silenzio ha superato
  /// [silenzioDiPausa]: la frase forse e' finita. Ordine EM voce 11.
  bool get inPausa => _inPausa;

  /// Quante volte la frase e' andata in pausa: cambia a ogni pausa nuova,
  /// cosi' chi ha cominciato a trascrivere sa se la persona ha ripreso.
  int get pause => _pause;

  /// Vero se l'ultimo pezzo sentito e' stato parlato.
  bool get parlaAdesso => _parlaAdesso;

  /// Il rumore di fondo imparato finora, in decibel.
  double? get fondo => _fondo;

  /// Quanto silenzio di fila si e' sentito finora, per il registro.
  Duration get silenzioDiFila => _silenzio;

  /// **Quanti controlli ha chiesto la frase**: cambia a ogni controllo
  /// nuovo. Ordine EM voce 04, secondo giro.
  int get controlli => _controlli;

  /// **I livelli dei pezzi di voce di questa frase**, per la stanza, se la
  /// frase si rivela sottofondo. Ordine EM voce 04, secondo giro.
  List<double> get vociSentite => List.unmodifiable(_vociSentite);

  /// **Quanta voce vera c'e' nella frase**: la somma dei pezzi di voce, per
  /// sapere se una trascrizione vuota e' credibile. Ordine EM voce 04,
  /// secondo giro.
  Duration get voceDellaFrase => _voceDellaFrase;

  /// **Vero quando negli ultimi [controlloOgni] il suono e' stato
  /// continuo**: il tempo preso per silenzio e' meno di [quotaDiSilenzio].
  /// Una persona che pensa tace; una televisione no.
  bool get sottofondoContinuo {
    if (_codaMisurata < controlloOgni) return false;
    var silenzio = Duration.zero;
    for (final p in _silenzi) {
      if (p.$1) silenzio += p.$2;
    }
    return silenzio.inMicroseconds <
        _codaMisurata.inMicroseconds * quotaDiSilenzio;
  }

  /// Il livello medio degli ultimi [finestraDelLivello], in decibel: la
  /// media dell'energia, non dei decibel.
  double _livelloMedio(double decibel, Duration durata) {
    _energie.add((math.pow(10, decibel / 10).toDouble(), durata));
    var totale = Duration.zero;
    for (final e in _energie) {
      totale += e.$2;
    }
    while (_energie.length > 1 &&
        totale - _energie.first.$2 >= finestraDelLivello) {
      totale -= _energie.removeAt(0).$2;
    }
    if (totale <= Duration.zero) return decibel;
    var somma = 0.0;
    for (final e in _energie) {
      somma += e.$1 * e.$2.inMicroseconds;
    }
    return 10 * math.log(somma / totale.inMicroseconds) / math.ln10;
  }

  void _ricordaIlSilenzio(bool silenzio, Duration durata) {
    _silenzi.add((silenzio, durata));
    _codaMisurata += durata;
    while (_silenzi.length > 1 &&
        _codaMisurata - _silenzi.first.$2 >= controlloOgni) {
      _codaMisurata -= _silenzi.removeAt(0).$2;
    }
  }

  /// Un pezzo di audio lungo [durata] al livello [decibel] (dBFS, negativo).
  ///
  /// [voce] dice quanto il pezzo e' voce, da zero a uno, come lo misura
  /// [LaMisuraDellaVoce]; **senza, il pezzo vale come voce**, e la regola
  /// e' quella dell'ordine EJ, sul solo livello.
  void senti(double decibel, Duration durata, {double? voce}) {
    if (_chiusa) return;
    if (decibel < pavimento) decibel = pavimento;
    final eVoce = voce == null || voce >= sogliaDellaVoce;
    if (eVoce) {
      _dallUltimaVoce = Duration.zero;
    } else {
      _dallUltimaVoce += durata;
    }
    // Il fondo scende subito al livello piu' basso, e risale piano SOLO
    // mentre la persona tace. La prima stesura lo faceva risalire anche
    // sulla voce: in una frase di otto secondi la voce finiva sotto la
    // soglia e diventava silenzio, cioe' lo stesso troncamento di prima.
    // Il fondo della frase di prima, se la stanza lo ricorda.
    final f = _fondo ?? stanza.fondo ?? decibel;
    final continua = _haParlato || _voce > Duration.zero;
    // **La stanza invecchia solo fuori dalle frasi**: una domanda lunga non
    // le fa dimenticare la televisione che sta sotto.
    if (!continua) stanza.passa(durata);
    final sottofondo = stanza.sottofondo;
    final sogliaDelFondo = f + (continua ? perContinuare : sopraIlFondo);
    // **Per cominciare serve voce vera; per continuare basta essere nella
    // coda di una voce** (le consonanti sorde).
    final vivo = continua ? _dallUltimaVoce <= codaDellaVoce : eVoce;
    // **Contro il sottofondo decide la media degli ultimi pezzi**, non il
    // pezzo solo: un picco della televisione non tiene aperta la frase.
    // Ordine EM voce 04, secondo giro. Contro il fondo decide il pezzo, come
    // prima: con la media la pausa e la chiusura arrivavano cento millesimi
    // dopo anche nella stanza silenziosa, e l'attesa della risposta, voce
    // EM.11, cresceva.
    final livello = _livelloMedio(decibel, durata);
    final sopraIlFondoGiusto = decibel >= sogliaDelFondo;
    final sopraLaTelevisione = sottofondo == null ||
        livello >=
            sottofondo +
                (continua ? sopraIlSottofondoPerContinuare : sopraIlSottofondo);
    final parla = sopraIlFondoGiusto && sopraLaTelevisione && vivo;
    _parlaAdesso = parla;
    _ricordaIlSilenzio(!parla, durata);
    if (decibel < f) {
      _fondo = decibel;
    } else if (!parla) {
      _fondo = f + (decibel - f) * 0.02;
    } else {
      _fondo = f;
    }
    stanza.fondo = _fondo;
    // **La stanza impara solo quando la persona non parla**, cioe' fuori
    // dalle frasi, e **solo dai pezzi che sono voce**: il sottofondo e' la
    // voce che non parla al telefono, una televisione o altre persone. Il
    // rumore sordo, il respiro o un ventilatore, lo scarta gia' la misura
    // della voce: se entrasse qui alzerebbe la soglia, e dopo un minuto di
    // respiro forte una voce normale non aprirebbe piu' la frase.
    // La stanza impara la media di mezzo secondo, la stessa grandezza con
    // cui poi si confronta.
    if (!parla && !continua && eVoce) stanza.impara(livello);
    if (eVoce && (parla || continua)) {
      _voceDellaFrase += durata;
      if (_vociSentite.length < 600) _vociSentite.add(livello);
    }
    if (parla) {
      _voce += durata;
      _silenzio = Duration.zero;
      _inPausa = false;
      if (_voce >= parlatoMinimo) _haParlato = true;
    } else {
      _silenzio += durata;
      if (!_haParlato && _silenzio > const Duration(milliseconds: 600)) {
        // Un colpo isolato non accumula parlato.
        _voce = Duration.zero;
      }
      if (_haParlato && !_inPausa && _silenzio >= silenzioDiPausa) {
        _inPausa = true;
        _pause++;
      }
      if (_haParlato && _silenzio >= silenzioCheChiude) _chiusa = true;
    }
    // **IL CONTROLLO DELLA FRASE APERTA SU UN SUONO CONTINUO.** Ordine EM
    // voce 04, secondo giro: una televisione non torna mai al fondo, e senza
    // questo la frase non si chiudeva.
    if (_haParlato && !_chiusa) {
      _daControllo += durata;
      if (_daControllo >= controlloOgni && sottofondoContinuo) {
        _daControllo = Duration.zero;
        _controlli++;
      }
    }
  }
}

/// **LA STANZA, cioe' cio' che il microfono sente quando nessuno parla al
/// telefono.** Ordine EM voce 04, 25 settembre 2026.
///
/// Si ricorda gli ultimi [quanti] livelli sentiti fuori dalle frasi, da una
/// frase all'altra, e ne tiene il **sottofondo**: il livello sotto cui sta il
/// novanta per cento di quei pezzi. In una stanza silenziosa sta a pochi
/// decibel dal fondo; con una televisione accesa sta dove parla la
/// televisione, e una voce deve stargli sopra per essere di chi parla al
/// telefono.
///
/// **E impara anche da una frase intera**, quando chi trascrive dice che era
/// solo sottofondo, e **dimentica** dopo [memoria] di ascolto. Ordine EM voce
/// 04, secondo giro: imparando solo fuori dalle frasi, una televisione piu'
/// forte della soglia d'inizio apriva una frase e non si imparava mai.
///
/// **Il sottofondo vale solo se la voce che non parla al telefono e'
/// abbastanza**: almeno [primi] pezzi negli ultimi [conferma] di ascolto.
/// Una televisione parla meta' del tempo; una parola detta piano da chi
/// usa il telefono dura un attimo. La prima stesura bastava con dieci pezzi:
/// al banco una sola parola sotto la soglia diventava sottofondo, e la
/// persona doveva poi parlare sei decibel sopra se stessa.
class LaStanza {
  LaStanza({
    this.quanti = 400,
    this.pavimento = -70,
    this.primi = 40,
    this.memoria = const Duration(seconds: 40),
    this.conferma = const Duration(seconds: 10),
  });

  /// Quanti livelli si ricorda al massimo.
  final int quanti;

  /// **Dopo quanto ascolto un livello imparato si dimentica.** Il tempo e'
  /// quello in cui il microfono ascolta: mentre il Maestro parla la stanza
  /// non invecchia.
  final Duration memoria;

  /// Sotto questo livello non si impara niente: i pezzi muti del registratore.
  final double pavimento;

  /// Quanti livelli recenti servono perche' il sottofondo valga qualcosa:
  /// quaranta pezzi sono due secondi e mezzo di voce, sul telefono.
  final int primi;

  /// **Su quanto ascolto recente si contano i [primi].**
  final Duration conferma;

  final _livelli = <(double, Duration)>[];
  Duration _tempo = Duration.zero;

  /// Il fondo dell'ultima frase: la frase dopo parte da qui, invece di
  /// impararlo dal suo primo pezzo, che potrebbe gia' essere voce.
  double? fondo;

  /// Passa [durata] di ascolto.
  void passa(Duration durata) => _tempo += durata;

  /// Un livello sentito fuori dalle frasi.
  void impara(double decibel) {
    _livelli.add((decibel < pavimento ? pavimento : decibel, _tempo));
    if (_livelli.length > quanti) _livelli.removeAt(0);
  }

  /// **I livelli di voce di una frase intera che era solo sottofondo.**
  /// Ordine EM voce 04, secondo giro.
  void imparaTutte(Iterable<double> livelli) {
    for (final l in livelli) {
      impara(l);
    }
  }

  /// **Di quanto una frase puo' stare sopra il sottofondo e dirsi ancora
  /// sottofondo.** E' la soglia d'inizio di `IlSilenzioVero`: una frase che
  /// l'ha superata di molto e' voce vicina per costruzione.
  static const double margineDelSottofondo = 4;

  /// **UNA FRASE SI IMPARA COME SOTTOFONDO SOLO SE LO SEMBRA.** Ordine EM voce
  /// 04, secondo giro, 25 settembre 2026. Sul Realme un controllo ha trovato
  /// vuota la domanda vera, con la televisione sotto: la frase e' stata
  /// scartata e la stanza ha imparato la voce della persona, il sottofondo e'
  /// salito da -26 a -19 dB e per decine di secondi nessuna domanda si
  /// sarebbe aperta. Padre: questa stessa voce, il controllo della frase
  /// aperta. Adesso, quando la stanza conosce gia' un sottofondo, una frase
  /// il cui novantesimo percentile gli sta piu' di [margineDelSottofondo]
  /// decibel sopra non e' sottofondo, qualunque cosa dica chi trascrive: non
  /// si scarta e non si impara. Quando la stanza non conosce niente, vale la
  /// trascrizione.
  bool sembraSottofondo(List<double> livelli) {
    final s = sottofondo;
    if (s == null || livelli.isEmpty) return true;
    final ordinati = [...livelli]..sort();
    final p90 = ordinati[((ordinati.length - 1) * 0.9).round()];
    return p90 <= s + margineDelSottofondo;
  }

  /// Il sottofondo, o null finche' la stanza non ha sentito abbastanza.
  double? get sottofondo {
    while (_livelli.isNotEmpty && _tempo - _livelli.first.$2 > memoria) {
      _livelli.removeAt(0);
    }
    var recenti = 0;
    for (final l in _livelli) {
      if (_tempo - l.$2 <= conferma) recenti++;
    }
    if (recenti < primi) return null;
    final ordinati = [for (final l in _livelli) l.$1]..sort();
    return ordinati[((ordinati.length - 1) * 0.9).round()];
  }
}

/// **QUANTO UN PEZZO DI AUDIO E' VOCE.** Ordine EM voce 04, 25 settembre
/// 2026.
///
/// La voce umana, quando suona, si ripete: le corde vocali battono da 70 a
/// 400 volte al secondo, e il suono di un periodo somiglia a quello del
/// periodo dopo. Il respiro, un ventilatore, un fruscio non si ripetono. Qui
/// si misura quanto l'ultimo pezzo somiglia a se stesso spostato di un
/// periodo possibile: **l'autocorrelazione normalizzata**, da zero a uno,
/// sulle ultime [finestra] campioni.
class LaMisuraDellaVoce {
  LaMisuraDellaVoce({this.tasso = 16000, this.finestra = 512});

  final int tasso;
  final int finestra;
  final _campioni = <double>[];

  /// Aggiunge un pezzo di PCM a 16 bit, mono, e torna quanto e' voce.
  double aggiungi(Uint8List pcm) {
    final dati = ByteData.sublistView(pcm);
    for (var i = 0; i + 1 < pcm.length; i += 2) {
      _campioni.add(dati.getInt16(i, Endian.little) / 32768.0);
    }
    if (_campioni.length > finestra) {
      _campioni.removeRange(0, _campioni.length - finestra);
    }
    return quantaVoce(_campioni, tasso: tasso);
  }

  /// La periodicita' di [x], da zero a uno, fra 70 e 400 cicli al secondo.
  static double quantaVoce(List<double> x, {int tasso = 16000}) {
    final n = x.length;
    final minimo = tasso ~/ 400;
    final massimo = tasso ~/ 70;
    if (n < massimo + minimo) return 0;
    var media = 0.0;
    for (final v in x) {
      media += v;
    }
    media /= n;
    final y = [for (final v in x) v - media];
    var migliore = 0.0;
    for (var ritardo = minimo; ritardo <= massimo; ritardo++) {
      var s = 0.0, a = 0.0, b = 0.0;
      for (var i = 0; i + ritardo < n; i++) {
        final p = y[i], q = y[i + ritardo];
        s += p * q;
        a += p * p;
        b += q * q;
      }
      if (a <= 0 || b <= 0) continue;
      final r = s / math.sqrt(a * b);
      if (r > migliore) migliore = r;
    }
    return migliore.clamp(0.0, 1.0);
  }
}
