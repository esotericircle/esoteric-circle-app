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
class IlSilenzioVero {
  IlSilenzioVero({
    this.silenzioCheChiude = const Duration(milliseconds: 2000),
    this.parlatoMinimo = const Duration(milliseconds: 250),
    this.sopraIlFondo = 12,
    this.perContinuare = 4,
    this.pavimento = -70,
    this.sopraIlSottofondo = 6,
    this.sopraIlSottofondoPerContinuare = 2,
    this.sogliaDellaVoce = 0.55,
    this.codaDellaVoce = const Duration(milliseconds: 400),
    this.silenzioDiPausa = const Duration(milliseconds: 700),
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
  /// una frase. Ordine EM voce 04.
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
    final sottofondo = stanza.sottofondo;
    final soglia = math.max(
      f + (continua ? perContinuare : sopraIlFondo),
      sottofondo == null
          ? double.negativeInfinity
          : sottofondo +
              (continua ? sopraIlSottofondoPerContinuare : sopraIlSottofondo),
    );
    // **Per cominciare serve voce vera; per continuare basta essere nella
    // coda di una voce** (le consonanti sorde).
    final vivo = continua ? _dallUltimaVoce <= codaDellaVoce : eVoce;
    final parla = decibel >= soglia && vivo;
    _parlaAdesso = parla;
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
    if (!parla && !continua && eVoce) stanza.impara(decibel);
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
class LaStanza {
  LaStanza({this.quanti = 200, this.pavimento = -70, this.primi = 10});

  /// Quanti livelli si ricorda: duecento pezzi sono qualche secondo.
  final int quanti;

  /// Sotto questo livello non si impara niente: i pezzi muti del registratore.
  final double pavimento;

  /// Quanti livelli servono prima che il sottofondo valga qualcosa.
  final int primi;

  final _livelli = <double>[];

  /// Il fondo dell'ultima frase: la frase dopo parte da qui, invece di
  /// impararlo dal suo primo pezzo, che potrebbe gia' essere voce.
  double? fondo;

  /// Un livello sentito fuori dalle frasi.
  void impara(double decibel) {
    _livelli.add(decibel < pavimento ? pavimento : decibel);
    if (_livelli.length > quanti) _livelli.removeAt(0);
  }

  /// Il sottofondo, o null finche' la stanza non ha sentito abbastanza.
  double? get sottofondo {
    if (_livelli.length < primi) return null;
    final ordinati = [..._livelli]..sort();
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
