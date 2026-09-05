import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../settings/settings_controller.dart';
import 'catalogo_musiche.dart';
import 'motore_audio.dart';

/// LA REGIA DELLA MUSICA: tutte le regole del tappeto, in un posto solo.
/// Ordine CN voce 07, 1 settembre 2026.
///
/// **Perche' esiste una regia e non una chiamata per schermata.** Le regole
/// della musica non sono di una schermata: sono del rapporto FRA le schermate.
/// Quando si passa da Medora a Caligo, chi decide la dissolvenza non e' ne'
/// l'una ne' l'altra. Se ogni schermata suonasse per conto suo, il passaggio
/// sarebbe un taglio, e nessuno saprebbe dove ripararlo.
///
/// **Le regole, e da dove viene ogni numero.**
///
/// - **La musica scende sotto un effetto e risale quando finisce.** Scende al
///   35 per cento in 220 millisecondi, risale in 600. La discesa e' rapida
///   perche' deve essere gia' avvenuta quando l'effetto attacca, altrimenti
///   l'attacco, che e' la parte che si riconosce, resta coperto. La risalita e'
///   lenta perche' un tappeto che torna di colpo si nota, e un tappeto che si
///   nota non e' piu' un tappeto.
/// - **Il passaggio da una traccia all'altra e' una dissolvenza incrociata**
///   di 1200 millisecondi, mai un taglio.
/// - **La musica tace quando l'app va in secondo piano e riprende al ritorno**,
///   e riprende dov'era: quello lo fa il motore, chiamato dalla Guardia del
///   Suono.
/// - **Nessuna musica dedicata ai Doni del Giorno**: il Dono non ha una sua
///   traccia, e quella che sta suonando continua. Spegnerla farebbe del Dono un
///   buco di silenzio.
///
/// **I cursori riflettono, non scavalcano.** Il volume che esce e' sempre il
/// prodotto di tre cose: l'interruttore unico, quello della musica, e il
/// cursore. Se uno dei due interruttori dice di no, il cursore non fa uscire
/// niente. Un cursore che suona mentre un interruttore dice di no e' un'app che
/// non obbedisce.
class RegiaDellaMusica {
  RegiaDellaMusica._();

  /// L'unica regia. Come il motore, e per la stessa ragione: due registi
  /// vogliono dire due tappeti sovrapposti.
  static final RegiaDellaMusica sola = RegiaDellaMusica._();

  /// Quanto scende la musica sotto un effetto: al 35 per cento, cioe' nove
  /// decibel sotto. Gli effetti stanno gia' sette decibel sopra la musica per
  /// come sono normalizzati: nove in piu' li mette chiaramente davanti senza
  /// far sparire il tappeto, che deve restare percepibile.
  static const double quotaAbbassata = 0.35;

  /// Quanto ci mette a scendere. Rapida: deve aver finito prima dell'attacco.
  static const Duration discesa = Duration(milliseconds: 220);

  /// Quanto ci mette a risalire. Lenta: una risalita che si nota e' un difetto.
  static const Duration risalita = Duration(milliseconds: 600);

  /// La dissolvenza incrociata fra due tracce.
  static const Duration incrocio = Duration(milliseconds: 1200);

  /// Ogni quanto si muove il volume durante una dissolvenza. Cinquanta
  /// millisecondi sono venti passi al secondo: sotto questa soglia l'orecchio
  /// sente una rampa e non una scala.
  static const Duration passo = Duration(milliseconds: 50);

  /// La spia delle prove: ogni cambio di traccia passa di qui.
  ///
  /// Serve perche' una prova non puo' ascoltare: senza questa riga, una
  /// guardia sulla musica potrebbe solo verificare che il codice esista, non
  /// che la traccia giusta parta nel posto giusto.
  @visibleForTesting
  static void Function(MusicaDelCerchio? traccia)? spia;

  /// **SOTTO `flutter test` IL LETTORE NON SI TOCCA, e non e' un modo di
  /// nascondere un difetto.**
  ///
  /// Il plugin audio non esiste nell'ambiente di prova. Il motore ha il
  /// suo `try`, ma **non basta**: `audioplayers` apre un canale globale
  /// alla prima costruzione, e l'errore di QUEL canale arriva come
  /// eccezione di piattaforma fuori dalla catena di chiamate, quindi non
  /// passa da nessun `catch` e fa cadere prove che col suono non
  /// c'entrano niente. Misurato il 1 settembre 2026: una prova sul campo
  /// di scrittura della chat, caduta per un `MissingPluginException` di
  /// `ambiente_home.mp3`.
  ///
  /// **Gli effetti non avevano questo problema per caso**: nascono spenti
  /// dall'ordine BZ, quindi in prova non arrivano mai al lettore. La
  /// musica nasce accesa per una decisione di disegno, e la stessa
  /// protezione va scritta a mano.
  ///
  /// **Cio' che resta vivo in prova e' tutto il resto**: la traccia
  /// scelta, la spia, il volume voluto, l'abbassamento. Una prova puo'
  /// ancora verificare CHE COSA suonerebbe, che e' l'unica cosa che una
  /// prova possa verificare del suono.
  static final bool _sottoLeProve =
      Platform.environment.containsKey('FLUTTER_TEST');

  /// **UNA PROVA PUO' RIACCENDERE IL LETTORE, e una deve.**
  ///
  /// La scorciatoia qui sopra ha un prezzo che si e' pagato: **fra la
  /// decisione e il suono non c'era piu' niente di sorvegliato.** La build
  /// 2218 e' uscita muta, e tutte le prove erano verdi perche' si fermavano
  /// alla decisione. Chi vuole guardare cosa arriva davvero al lettore mette
  /// questo a falso e ascolta il canale della piattaforma.
  @visibleForTesting
  static bool? lettoreForzato;

  static bool get senzaLettore => lettoreForzato ?? MotoreAudio.senzaLettori;

  MusicaDelCerchio? _corrente;
  double _volumeVoluto = 0.0;
  int _effettiInCorso = 0;

  /// **QUALE SFUMATURA COMANDA ADESSO.**
  ///
  /// Qui c'era un `Timer? _dissolvenza` che nessuno assegnava mai:
  /// `cancel()` veniva chiamato su un nulla, e **due sfumature potevano
  /// correre insieme scrivendosi il volume a vicenda**. E' cosi' che la
  /// 2219 e' partita col tappeto a volume quasi zero: la voce dell'intro
  /// faceva scendere la musica sotto un effetto mentre la musica stava
  /// ancora salendo da zero, e chi finiva per ultimo lasciava il volume
  /// dove capitava. Il fondatore la sentiva comparire solo dopo il login,
  /// quando un altro passaggio riscriveva il volume per intero.
  ///
  /// Adesso ogni sfumatura prende un numero: se ne parte un'altra, la
  /// precedente se ne accorge al passo dopo e si ferma.
  int _generazione = 0;

  /// **LA SENTINELLA: ogni due secondi guarda se il tappeto suona.**
  ///
  /// La verifica al cambio di schermata non basta, e la 2219 lo mostra:
  /// il Risveglio e' una schermata sola, ci si resta minuti, e in quei
  /// minuti nessun passaggio avrebbe rimesso in moto niente.
  ///
  /// Costa un confronto ogni due secondi e non tocca la piattaforma
  /// quando tutto va bene. **Non e' una toppa elegante**, ed e' scritto
  /// apposta: non sono riuscito a riprodurre sul banco perche' la prima
  /// richiesta a volte non produce suono, e finche' non lo so questa e'
  /// la differenza fra un'app che si ripara e una che resta muta.
  Timer? _sentinella;

  void _accendiLaSentinella(SettingsController s) {
    _sentinella?.cancel();
    // **SOTTO LE PROVE NON GIRA MAI**, nemmeno quando una prova riaccende
    // il lettore per guardare il canale: un temporizzatore che vive due
    // secondi alla volta sopravvive alla fine di una prova e la fa
    // cadere per una ragione che con la musica non c'entra. E' un
    // guardiano di produzione, e li' deve stare.
    if (_sottoLeProve) return;
    _sentinella = Timer.periodic(const Duration(seconds: 2), (_) {
      final atteso = _corrente;
      if (atteso == null) return;
      if (MotoreAudio.condiviso.musicaStaSuonando) return;
      debugPrint('La sentinella ha trovato il tappeto fermo: riparte.');
      _corrente = null;
      unawaited(vaiA(atteso, s));
    });
  }

  /// La traccia che sta suonando adesso, o nulla se tace.
  MusicaDelCerchio? get corrente => _corrente;

  /// Quanto vale il volume in questo istante, prima dell'abbassamento.
  double get volumeVoluto => _volumeVoluto;

  /// Vero se la musica sta scendendo sotto un effetto.
  bool get abbassata => _effettiInCorso > 0;

  double _volumeDa(SettingsController s) =>
      s.musicaPermessa ? s.volumeMusica : 0.0;

  /// **PORTA IL LUOGO, NON IL BRANO.** Chi chiama dice dove si trova, e la
  /// regia decide cosa suona: non esiste un comando che scelga un brano,
  /// perche' la licenza non lo consente e perche' un selettore non e' quello
  /// che questa app vuole essere.
  Future<void> vaiA(MusicaDelCerchio? luogo, SettingsController s) async {
    if (luogo == _corrente) {
      // **SI GUARDA SE STA SUONANDO DAVVERO, e non e' pignoleria.**
      //
      // La 2219 e' uscita col tappeto che non si sentiva fino al login.
      // La regia ricordava di aver chiesto la traccia, quindi a ogni
      // passaggio dopo si limitava a ritoccare il volume e non provava
      // piu' a farla partire: **credeva alla propria memoria invece di
      // guardare il lettore**.
      //
      // Non sono riuscito a riprodurre sul banco la ragione per cui la
      // prima richiesta non produceva suono, e lo dichiaro invece di
      // fingere di saperlo. **Ma la memoria non e' una prova**, e adesso
      // la regia riprova ogni volta che qualcuno cambia schermata.
      if (luogo != null &&
          !senzaLettore &&
          !MotoreAudio.condiviso.musicaStaSuonando) {
        debugPrint(
            'Il tappeto risulta fermo pur essendo stato chiesto: riparte.');
        _corrente = null;
      } else {
        await _applica(_volumeDa(s));
        return;
      }
    }

    if (luogo == null) {
      await _sfuma(da: _volumeAttuale(), a: 0.0, quanto: incrocio);
      if (!senzaLettore) await MotoreAudio.condiviso.fermaMusica();
      _corrente = null;
      _volumeVoluto = 0.0;
      _sentinella?.cancel();
      spia?.call(null);
      return;
    }

    // **LA DISSOLVENZA INCROCIATA CON UN LETTORE SOLO.** Due lettori
    // suonerebbero davvero insieme, ma vorrebbero dire due tappeti e un
    // secondo motore, che questo progetto vieta. Con uno solo si scende a
    // zero e si risale sulla traccia nuova: e' una dissolvenza in serie, e
    // all'orecchio la differenza sta nel mezzo secondo centrale, dove un
    // taglio si sentirebbe e questo no.
    final meta = Duration(milliseconds: incrocio.inMilliseconds ~/ 2);
    if (_corrente != null) {
      await _sfuma(da: _volumeAttuale(), a: 0.0, quanto: meta);
    }

    final voluto = _volumeDa(s);
    final partita = senzaLettore ||
        await MotoreAudio.condiviso
            .musica(luogo.percorso, volume: _corrente == null ? voluto : 0.0);
    if (!partita) {
      // Nessun asset, nessun lettore: si resta in silenzio senza mentire su
      // cosa sta suonando.
      _corrente = null;
      _volumeVoluto = 0.0;
      spia?.call(null);
      return;
    }
    _corrente = luogo;
    _volumeVoluto = voluto;
    spia?.call(luogo);
    _accendiLaSentinella(s);
    if (voluto > 0) {
      await _sfuma(da: 0.0, a: voluto, quanto: meta);
      // **E SI CHIUDE SUL VALORE VERO.** Una sfumatura puo' essere
      // stata interrotta a meta' da un effetto che abbassa la musica:
      // senza questa riga il tappeto resterebbe al volume dove
      // l'interruzione l'ha lasciato, che e' come essere muti.
      await MotoreAudio.condiviso.volumeDellaMusica(_volumeAttuale());
    }
  }

  /// La musica scende, perche' sta per suonare un effetto.
  ///
  /// Si conta quanti effetti sono in corso: due effetti ravvicinati non devono
  /// far risalire il tappeto in mezzo, che sarebbe un'onda invece di un
  /// abbassamento.
  Future<void> scendiSottoUnEffetto(Duration quantoDura) async {
    // **NIENTE DA ABBASSARE SE NON SUONA NIENTE.** Senza questa riga
    // un effetto che arriva mentre la musica sta ancora partendo la
    // faceva scendere verso un bersaglio calcolato su un volume che
    // non era ancora quello vero, e il tappeto restava giu'.
    if (senzaLettore) return;
    if (_corrente == null || _volumeVoluto <= 0) return;
    _effettiInCorso++;
    await _sfuma(
        da: _volumeAttuale(),
        a: _volumeVoluto * quotaAbbassata,
        quanto: discesa);
    Future<void>.delayed(quantoDura + discesa, _risali);
  }

  Future<void> _risali() async {
    if (_effettiInCorso > 0) _effettiInCorso--;
    if (_effettiInCorso > 0) return;
    await _sfuma(
        da: _volumeVoluto * quotaAbbassata, a: _volumeVoluto, quanto: risalita);
    await MotoreAudio.condiviso.volumeDellaMusica(_volumeAttuale());
  }

  /// Il volume cambia perche' qualcuno ha mosso un cursore o un interruttore.
  Future<void> aggiorna(SettingsController s) async {
    _volumeVoluto = _volumeDa(s);
    if (_volumeVoluto == 0 && _corrente != null) {
      await MotoreAudio.condiviso.volumeDellaMusica(0);
      return;
    }
    await _applica(_volumeVoluto);
  }

  double _volumeAttuale() =>
      _effettiInCorso > 0 ? _volumeVoluto * quotaAbbassata : _volumeVoluto;

  Future<void> _applica(double v) async {
    _volumeVoluto = v;
    await MotoreAudio.condiviso.volumeDellaMusica(_volumeAttuale());
  }

  /// Muove il volume a passi, invece che di colpo.
  Future<void> _sfuma({
    required double da,
    required double a,
    required Duration quanto,
  }) async {
    if (senzaLettore) return;
    final mia = ++_generazione;
    final passi = (quanto.inMilliseconds / passo.inMilliseconds).ceil();
    if (passi <= 1) {
      await MotoreAudio.condiviso.volumeDellaMusica(a);
      return;
    }
    for (var i = 1; i <= passi; i++) {
      // Se nel frattempo ne e' partita un'altra, questa smette: due
      // sfumature che si scrivono il volume a vicenda lo lasciano
      // dove capita, e dove capita e' quasi sempre in basso.
      if (mia != _generazione) return;
      final v = da + (a - da) * (i / passi);
      await MotoreAudio.condiviso.volumeDellaMusica(v);
      if (i < passi) await Future<void>.delayed(passo);
    }
  }

  /// Dimentica tutto: serve alle prove, che devono partire da un silenzio
  /// noto invece che da cio' che ha lasciato la prova prima.
  @visibleForTesting
  void dimentica() {
    _sentinella?.cancel();
    _corrente = null;
    _volumeVoluto = 0.0;
    _effettiInCorso = 0;
  }
}
