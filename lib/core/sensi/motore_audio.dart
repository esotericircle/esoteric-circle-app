import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import 'guardia_del_suono.dart';

/// IL MOTORE AUDIO del Cerchio: uno solo, tre consumatori.
///
/// **Il fatto di partenza.** L'app era MUTA per costruzione: l'unico lettore di
/// toni generava i byte e li scartava, e nel pubspec non esisteva alcuna
/// dipendenza di riproduzione. C'era `record`, che registra soltanto. E' la
/// voce P03 del Registro delle Prescrizioni, e non era rifinitura: era la
/// fondazione che mancava.
///
/// **Tre usi, una dipendenza.**
///
/// 1. Gli effetti brevi della palette sonora, che sono file negli asset.
/// 2. Le frequenze e il battito theta della Meditazione e del Sigillo del Sogno,
///    che sono byte sintetizzati sul momento.
/// 3. Domani la voce dei Maestri del cantiere Protoface.
///
/// Un test fallisce se ricompare un secondo motore audio: due motori vogliono
/// dire due volumi, due comportamenti in sottofondo e due modi di fermarsi.
class MotoreAudio implements MotoreSonoro {
  MotoreAudio._();

  /// L'UNICA istanza. La classe dichiarava di essere una sola mentre ne
  /// convivevano due: quella statica della palette e una nuova per ogni
  /// apertura della Meditazione e del Sigillo del Sogno. Un commento che mente e'
  /// peggio di un difetto, perche' chi legge smette di verificare. Adesso la
  /// dichiarazione e' vera, e il costruttore e' privato perche' resti tale.
  static final MotoreAudio condiviso = MotoreAudio._();

  /// **SOTTO `flutter test` I LETTORI NON SI TOCCANO, e c'e' una porta
  /// sola per dirlo.**
  ///
  /// `audioplayers` apre due canali di eventi appena nasce un lettore, e
  /// **l'errore di un canale non passa da nessun `catch`**: arriva come
  /// eccezione di piattaforma e fa cadere prove che col suono non
  /// c'entrano niente. Finche' gli effetti nascevano spenti il problema
  /// non si vedeva; **dal 2 settembre 2026 nascono accesi**, e ogni prova
  /// che monta l'app arriva al plugin.
  ///
  /// **Questa non e' la scorciatoia che ha nascosto il difetto della
  /// 2218.** Quella era muta e definitiva; questa si spegne: una guardia
  /// mette [lettoriForzati] a falso e guarda cosa arriva davvero al
  /// canale. Il tratto di strada fra la decisione e il suono resta
  /// sorvegliato, ed e' la lezione che quel difetto e' costato.
  static final bool _sottoLeProve =
      Platform.environment.containsKey('FLUTTER_TEST');

  /// Una prova puo' riaccendere i lettori per guardare il canale.
  @visibleForTesting
  static bool? lettoriForzati;

  static bool get senzaLettori => lettoriForzati ?? _sottoLeProve;

  /// I lettori nascono PIGRI, alla prima riproduzione.
  ///
  /// Costruirli subito tocca la piattaforma, quindi in un ambiente senza plugin,
  /// come una prova o un'anteprima, il solo fatto di creare il motore
  /// solleverebbe. Il motore deve poter esistere ovunque: e' il suono a essere
  /// facoltativo, non la sua esistenza.
  AudioPlayer? _effettiPigro;
  AudioPlayer? _toniPigro;
  AudioPlayer? _musicaPigro;

  AudioPlayer get _effetti =>
      _effettiPigro ??= AudioPlayer(playerId: 'cerchio_effetti');

  AudioPlayer get _toni => _toniPigro ??= AudioPlayer(playerId: 'cerchio_toni');

  AudioPlayer get _musica =>
      _musicaPigro ??= AudioPlayer(playerId: 'cerchio_musica');

  /// Riproduce un effetto breve da un file negli asset.
  ///
  /// Se il file non c'e' non succede niente e non si solleva: e' il ripiego
  /// silenzioso dichiarato, che tiene l'app viva finche' gli asset non
  /// arrivano.
  /// Riproduce un effetto e dice QUANTO DURA, quando si riesce a saperlo.
  ///
  /// La durata serve a chi deve accordare qualcosa al suono, per esempio la
  /// scritta dell'intro che si scrive al ritmo della voce: prenderla dal file
  /// invece che da una costante significa che se un giorno il suono cambia,
  /// chi lo accompagna lo segue da solo.
  ///
  /// Nulla quando il suono non parte o la durata non si legge: chi chiama ha il
  /// proprio ripiego, e il rito continua lo stesso.
  Future<Duration?> effetto(String percorsoAsset,
      {double volume = 1.0}) async {
    if (senzaLettori) return null;
    try {
      await _preparaGliEffetti();
      // Il volume di questo suono, dichiarato nel catalogo. Si imposta prima
      // di suonare e resta finche' un altro suono non lo cambia: il lettore
      // degli effetti e' uno solo e li suona uno alla volta.
      await _effetti.setVolume(volume.clamp(0.0, 1.0));
      // **NON SI ASPETTA LA CONFERMA DEL LETTORE, ed e' lo STESSO difetto
      // della build 2218.** Ordine CQ voce 1.04, 3 settembre 2026.
      //
      // La coda dell'ordine CN aveva misurato che `play` di audioplayers non
      // e' una chiamata che finisce: dentro attende un evento `prepared` dalla
      // piattaforma e, se non arriva, **resta appesa per sempre senza
      // sollevare niente**. La cura era stata applicata alla musica e **non
      // agli effetti**, che sono rimasti con l'attesa dentro: e' per questo
      // che il fondatore non sente la carta girarsi.
      //
      // Qui si chiede e si va avanti. Chi ascolta e' il lettore, non noi.
      unawaited(_effetti
          .stop()
          .then((_) => _effetti.play(AssetSource(percorsoAsset)))
          .catchError((Object e) {
        debugPrint('Suono non riprodotto ($percorsoAsset): $e');
      }));
      return null;
    } catch (e) {
      // Nessun suono: il rito continua lo stesso.
      debugPrint('Suono non riprodotto ($percorsoAsset): $e');
      return null;
    }
  }

  /// **GLI EFFETTI NON CHIEDONO IL FUOCO AUDIO ESCLUSIVO.**
  /// Ordine CQ voce 1.04, 3 settembre 2026.
  ///
  /// `audioplayers` chiede di partenza `AndroidAudioFocus.gain`, cioe' il
  /// fuoco esclusivo: dice al sistema che questa app e' l'unica sorgente che
  /// la persona sta ascoltando. **La musica di questa app non lo molla**,
  /// perche' e' un tappeto che suona sempre, e i video dei Maestri nemmeno
  /// mentre parlano. Il lettore degli effetti lo chiedeva, non lo otteneva, e
  /// **restava muto senza sollevare niente**: e' la stessa diagnosi che la
  /// coda dell'ordine CN aveva fatto per la musica, e che agli effetti non era
  /// mai stata applicata.
  ///
  /// Un effetto breve non ha bisogno di essere l'unica sorgente: sta sopra a
  /// cio' che gia' suona, e **l'abbassamento della musica sotto un effetto lo
  /// decide la regia**, per conto suo, come gia' fa.
  ///
  /// Si prepara UNA VOLTA SOLA: il contesto e' del lettore, non del singolo
  /// suono, e rifarlo a ogni effetto vorrebbe dire una chiamata alla
  /// piattaforma in piu' davanti a ogni carta che si gira.
  bool _effettiPreparati = false;

  Future<void> _preparaGliEffetti() async {
    if (_effettiPreparati) return;
    _effettiPreparati = true;
    try {
      await _effetti.setAudioContext(AudioContext(
        android: const AudioContextAndroid(
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.assistanceSonification,
          audioFocus: AndroidAudioFocus.none,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: const {AVAudioSessionOptions.mixWithOthers},
        ),
      ));
    } catch (e) {
      // Il contesto non si e' potuto impostare: si suona lo stesso, col
      // comportamento di partenza del lettore.
      debugPrint('Contesto degli effetti non impostato: $e');
      _effettiPreparati = false;
    }
  }

  /// **LA MUSICA D'AMBIENTE, in ciclo continuo.** Ordine CN.
  ///
  /// Un terzo lettore e non un terzo motore: la regola di questo file
  /// resta una sola istanza. Serve un lettore suo perche' la musica deve
  /// poter scendere sotto un effetto **mentre l'effetto suona**, e un
  /// lettore che fa tutti e due i mestieri non puo' abbassarsi da solo.
  ///
  /// Torna vero se la musica e' partita davvero: chi chiama deve poter
  /// distinguere "sta suonando" da "ho chiesto e non e' successo",
  /// altrimenti la regia crederebbe di avere un tappeto che non c'e'.
  Future<bool> musica(String percorsoAsset, {double volume = 1.0}) async {
    if (senzaLettori) return true;
    try {
      // **IL TAPPETO NON CHIEDE IL FUOCO AUDIO A NESSUNO, ed e' LA
      // ragione per cui la musica non partiva dopo l'intro.**
      //
      // `audioplayers` chiede di partenza `AndroidAudioFocus.gain`, cioe'
      // **il fuoco audio esclusivo**: dice al sistema che questa app e'
      // l'unica sorgente che la persona sta ascoltando. L'intro e la
      // rivelazione dei Maestri sono video, e mentre suonano il fuoco ce
      // l'hanno loro: il nostro lettore lo chiedeva, non lo otteneva, e
      // **restava muto senza sollevare niente**.
      //
      // Il fondatore lo ha detto meglio di qualunque misura: *la musica
      // non parte dopo l'intro, ma parte dopo il video di rivelazione,
      // quando si entra nella home*. Cioe' **appena il video molla il
      // fuoco**. La sentinella riprovava ogni due secondi, e ci riusciva
      // esattamente li'.
      //
      // Un tappeto d'ambiente non e' l'unica sorgente di niente: sta
      // sotto, e sotto ci deve stare anche quando qualcos'altro parla.
      // Con `none` non chiede nessun fuoco e convive. **L'abbassamento
      // sotto un effetto lo decide la regia**, per conto suo, che e' il
      // modo giusto: il volume di questa app lo governa questa app, non
      // una contesa fra lettori.
      await _musica.setAudioContext(AudioContext(
        android: const AudioContextAndroid(
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.none,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: const {AVAudioSessionOptions.mixWithOthers},
        ),
      ));
      await _musica.setReleaseMode(ReleaseMode.loop);
      await _musica.setVolume(volume.clamp(0.0, 1.0));
      // **NON SI ASPETTA LA CONFERMA DEL LETTORE, E QUESTA RIGA E' IL DIFETTO
      // DELLA BUILD 2218.**
      //
      // `play` di audioplayers NON e' una chiamata che finisce: dentro
      // aspetta un evento `prepared` che deve arrivare dalla piattaforma, e
      // se quell'evento non arriva **resta appesa per sempre**. Attendendola,
      // il motore non tornava ne' vero ne' falso, la regia restava sospesa a
      // meta', la traccia non veniva mai impostata, e **il `catch` non
      // scattava perche' non c'era nessun errore: c'era un'attesa infinita**.
      //
      // L'app e' uscita muta con quattromiladuecento prove verdi, e senza una
      // riga di log a dirlo.
      //
      // Si chiede al lettore di suonare e si va avanti. Se poi fallisce
      // davvero, lo dice il `catch` qui sotto invece di sparire nel nulla.
      unawaited(_musica.play(AssetSource(percorsoAsset)).catchError((Object e) {
        debugPrint('Musica non partita ($percorsoAsset): $e');
      }));
      return true;
    } catch (e) {
      // Nessuna musica: l'app resta viva e muta, come senza asset.
      debugPrint('Musica non riprodotta ($percorsoAsset): $e');
      return false;
    }
  }

  /// **STA SUONANDO DAVVERO?**
  ///
  /// Serve perche' chiedere di suonare e suonare sono due cose diverse, e
  /// la 2219 lo ha dimostrato: la richiesta partiva e dal telefono non
  /// usciva niente. Chi comanda la musica non puo' fidarsi della propria
  /// memoria di aver chiesto: deve poter guardare.
  bool get musicaStaSuonando => _musicaPigro?.state == PlayerState.playing;

  /// Quanto forte suona la musica adesso, da 0 a 1.
  Future<void> volumeDellaMusica(double volume) async {
    try {
      await _musicaPigro?.setVolume(volume.clamp(0.0, 1.0));
    } catch (errore) {
      // Il lettore non c'e' ancora, oppure la piattaforma non risponde:
      // in tutti e due i casi non c'e' nessun volume da regolare, e
      // il silenzio e' il ripiego dichiarato di questo motore.
      debugPrint('Volume della musica non applicato: $errore');
    }
  }

  /// Ferma la musica. Gli effetti in corso non si toccano.
  Future<void> fermaMusica() async {
    try {
      await _musicaPigro?.stop();
    } catch (errore) {
      // Gia' ferma, o nessun lettore: non c'e' niente da fermare.
      debugPrint('Musica non fermata: $errore');
    }
  }

  /// Sospende la musica lasciandola dov'e', per riprenderla al ritorno.
  Future<void> sospendiMusica() async {
    try {
      await _musicaPigro?.pause();
    } catch (errore) {
      // Gia' sospesa, o nessun lettore.
      debugPrint('Musica non sospesa: $errore');
    }
  }

  /// Riprende la musica dal punto in cui era.
  Future<void> riprendiMusica() async {
    try {
      await _musicaPigro?.resume();
    } catch (errore) {
      // Nessun lettore: non c'e' niente da riprendere.
      debugPrint('Musica non ripresa: $errore');
    }
  }

  /// Riproduce byte sintetizzati, per esempio un tono binaurale in WAV.
  ///
  /// In ciclo continuo quando [inCiclo] e' vero, che e' il caso della
  /// Meditazione: il tono deve durare quanto la sessione, non quanto il
  /// campione.
  Future<void> tono(Uint8List byte, {bool inCiclo = true}) async {
    if (senzaLettori) return;
    try {
      await _toni
          .setReleaseMode(inCiclo ? ReleaseMode.loop : ReleaseMode.release);
      // **NEMMENO IL TONO ASPETTA LA PIATTAFORMA. Ordine CQ voce 1.04.**
      // Stessa chiamata che non finisce della musica e degli effetti: qui
      // sarebbe il battito theta della Meditazione e del Sigillo del Sogno a
      // non partire mai, in silenzio e senza un log. **Curare un difetto in
      // un posto solo vuol dire vederlo tornare dall'altro**, ed e'
      // esattamente cio' che e' successo fra l'ordine CN e questo.
      unawaited(_toni.play(BytesSource(byte)).catchError((Object e) {
        debugPrint('Tono non riprodotto: $e');
      }));
    } catch (e) {
      debugPrint('Tono non riprodotto: $e');
    }
  }

  /// Ferma ogni suono in corso: e' cio' che la Guardia del Suono chiama quando
  /// l'app perde il primo piano.
  @override
  Future<void> fermaTutto() async {
    await fermaTono();
    // **LA MUSICA SI SOSPENDE, NON SI FERMA.** Ordine CN voce 07:
    // l'app che torna in primo piano deve riprendere dov'era, non
    // ricominciare il tappeto da capo, che si sentirebbe come un
    // salto.
    await sospendiMusica();
    try {
      await _effettiPigro?.stop();
    } catch (_) {
      // Nessun effetto in corso: nulla da fare.
    }
  }

  /// **AL RITORNO RIPRENDE LA SOLA MUSICA.** Ordine CN voce 07.
  ///
  /// Gli effetti no, e i toni nemmeno: un effetto e' la risposta a un
  /// gesto, e un gesto fatto un minuto fa non merita una risposta
  /// adesso. La musica invece e' un luogo, e il luogo e' ancora quello.
  @override
  Future<void> riprendi() async {
    await riprendiMusica();
  }

  /// Ferma i toni lunghi. Gli effetti brevi finiscono da soli.
  Future<void> fermaTono() async {
    try {
      await _toni.stop();
    } catch (_) {
      // Gia' fermo, oppure nessun motore: nulla da fare.
    }
  }

  Future<void> dispose() async {
    await _effettiPigro?.dispose();
    await _toniPigro?.dispose();
    await _musicaPigro?.dispose();
  }
}
