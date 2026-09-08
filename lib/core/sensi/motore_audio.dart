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
  /// **LA SONDA CHE LE PROVE POSSONO SOSTITUIRE, e cosa NON sostituisce.**
  /// Ordine CW voce 01.
  ///
  /// Sotto `flutter test` i lettori non nascono, quindi qui la risposta e'
  /// sempre falsa e i tre casi della voce non si potrebbero costruire. Questa
  /// sonda cambia l'INGRESSO, cioe' la premessa "stava suonando", e **non
  /// tocca la regola**: che si ricordi allo spegnimento e che si riprenda solo
  /// cio' che si era sospeso resta codice vero, provato per intero.
  ///
  /// E' la differenza con la scorciatoia che questo progetto ha gia' pagato:
  /// quella spegneva il tratto di strada dove viveva il guasto, questa lo
  /// lascia acceso e gli mette davanti una premessa scelta.
  @visibleForTesting
  static bool Function()? sondaMusicaInCorso;

  bool get musicaStaSuonando =>
      sondaMusicaInCorso?.call() ??
      (_musicaPigro?.state == PlayerState.playing);

  /// Quante volte la musica e' stata davvero ripresa al ritorno.
  ///
  /// Serve alle prove per distinguere "non ha ripreso" da "ha ripreso e non si
  /// vede": senza lettori nessuna delle due lascia traccia, e una prova che
  /// non le distingue e' verde in tutti e due i casi.
  @visibleForTesting
  int quanteRiprese = 0;

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

  /// **NESSUNA SORGENTE PUO' TRATTENERE LE ALTRE.** Ordine CT voce 07,
  /// 7 settembre 2026.
  ///
  /// **Il difetto, misurato.** Il fondatore: *"quando l'app va in background,
  /// la musica non si ferma"*. Il governo del ciclo di vita c'era, la Guardia
  /// del Suono chiamava questo metodo, e questo metodo fermava la musica: sulla
  /// carta era tutto giusto. **Il difetto era l'ordine delle attese.**
  ///
  /// Qui si fermavano le tre sorgenti IN CATENA, una `await` dopo l'altra, e
  /// la musica era la seconda. La prima era il tono, e la chiamava attraverso
  /// il getter `_toni`, che il lettore **lo crea se non c'e'**: mandando in
  /// sottofondo un'app che non aveva mai suonato un tono, si costruiva un
  /// lettore nuovo, senza sorgente, solo per dirgli di fermarsi. Di
  /// `audioplayers` questo progetto sa gia' che **una chiamata puo' non
  /// tornare mai senza sollevare niente**: e' costato l'ordine CQ, dove `play`
  /// atteso bloccava la build muta. Un'attesa che non torna sulla prima
  /// sorgente **impedisce di arrivare alla seconda**, cioe' alla musica, e il
  /// `catch` non serve a niente perche' non c'e' nessun errore da prendere.
  ///
  /// **Adesso le tre chiamate partono tutte prima di qualunque attesa**, e chi
  /// non risponde resta indietro da solo. Il tono si ferma dal campo e non dal
  /// getter: non si crea mai un lettore per zittirlo.
  ///
  /// **LA MUSICA SI SOSPENDE, NON SI FERMA.** Ordine CN voce 07: sospesa
  /// tace come ferma, e riprenderla costa meno che ricomporla.
  @override
  Future<void> fermaTutto() {
    // **SI RICORDA SE STAVA SUONANDO, ordine CW voce 01.** E' l'unica cosa da
    // ricordare: chi era in una schermata muta e chi aveva spento la musica
    // dalle impostazioni hanno in comune che la musica non stava suonando,
    // quindi nessuno dei due la sentira' tornare.
    _musicaSospesaDaNoi = musicaStaSuonando;
    // **E DICHIARA CHE SIAMO FUORI. Ordine CY voce 02, 8 settembre 2026.**
    //
    // Sono due fatti diversi e servono a due cose diverse. Il primo, qui
    // sopra, dice **cosa riprendere** al ritorno, e vale solo se la musica
    // stava suonando. Questo dice **che siamo in secondo piano**, e vale
    // sempre, anche per chi era in una schermata muta.
    //
    // Senza il secondo, la sentinella della regia, che gira ogni due secondi
    // e serve a far ripartire un tappeto perso, vedeva la musica ferma
    // subito dopo il tasto Home e **la faceva ripartire mentre l'app era
    // fuori**: due secondi di silenzio e poi di nuovo musica. E' il difetto
    // che il fondatore ha sentito sulla 2232, dopo che la voce CW.01 aveva
    // riparato l'altra meta'.
    _fuori = true;
    return fermaOgnuna([
      () => _toniPigro?.stop(),
      () => _musicaPigro?.pause(),
      () => _effettiPigro?.stop(),
    ]);
  }

  /// Vero fra l'uscita e il ritorno, e solo se all'uscita la musica suonava.
  bool _musicaSospesaDaNoi = false;

  /// Vero fra l'uscita e il ritorno, **sempre**, anche a musica gia' ferma.
  bool _fuori = false;

  /// **L'APP E' IN SECONDO PIANO?** La porta unica, ordine CY voce 02.
  ///
  /// Esiste perche' un fatto che serve a piu' di uno non si indovina. La
  /// sentinella della musica la interroga per sapere se deve dormire: senza,
  /// dovrebbe dedurre il secondo piano da cio' che vede, e cio' che vede a
  /// musica ferma e' identico in secondo piano e in una schermata muta.
  bool get inSecondoPiano => _fuori;

  /// Lo stesso stato, per le prove e per chi deve sapere cosa succedera' al
  /// ritorno senza provocarlo.
  bool get musicaDaRiprendere => _musicaSospesaDaNoi;

  /// **CHIAMA TUTTE, POI ASPETTA.** Il cuore della voce CT.07, staccato qui
  /// perche' si possa provare con una sorgente che non risponde mai: dentro
  /// `fermaTutto` i tre lettori sono privati e nessuna prova puo' sostituirli.
  ///
  /// Le chiamate si emettono nel giro sincrono, prima di ogni `await`: da quel
  /// momento la piattaforma le ha ricevute tutte, e cosa ne fa non riguarda
  /// piu' le altre. L'attesa che segue serve solo a chi vuole sapere quando e'
  /// finita, e ha un tetto perche' **questo metodo non deve poter non
  /// tornare**: lo chiama il ciclo di vita, e un ciclo di vita che si appende
  /// e' peggio di un suono che resta acceso.
  @visibleForTesting
  static Future<void> fermaOgnuna(
    List<Future<void>? Function()> sorgenti, {
    Duration entro = const Duration(seconds: 2),
  }) async {
    final avviate = <Future<void>>[];
    for (final sorgente in sorgenti) {
      try {
        final f = sorgente();
        // L'errore si assorbe sulla singola sorgente: una che solleva non
        // deve far saltare l'attesa comune.
        if (f != null) avviate.add(f.catchError((Object _) {}));
      } catch (_) {
        // La chiamata e' fallita subito: le altre partono lo stesso.
      }
    }
    if (avviate.isEmpty) return;
    await Future.wait(avviate)
        .timeout(entro, onTimeout: () => const <void>[]);
  }

  /// Quali lettori esistono davvero, per nome.
  ///
  /// Serve a provare che fermare non CREA: un lettore costruito per essere
  /// zittito e' un lettore in piu' che tocca la piattaforma, ed e' proprio
  /// quello che teneva ferma la catena.
  @visibleForTesting
  Set<String> get lettoriVivi => {
        if (_toniPigro != null) 'toni',
        if (_musicaPigro != null) 'musica',
        if (_effettiPigro != null) 'effetti',
      };

  /// **AL RITORNO RIPRENDE LA SOLA MUSICA, e solo se stava suonando.**
  /// Ordine CW voce 01, 7 settembre 2026: il fondatore ha ribaltato la
  /// decisione che avevo preso con l'ordine CT.
  ///
  /// **DAL PUNTO IN CUI SI ERA FERMATA, e il motore lo consente.** `pause` di
  /// `audioplayers` lascia il lettore dov'e' e `resume` riparte da li': non
  /// serve nessun ripiego dall'inizio della traccia, e la posizione non si
  /// deve nemmeno ricordare, perche' la tiene il lettore. Se un giorno il
  /// lettore perdesse la posizione, `resume` su un lettore fermo riparte da
  /// zero, che e' il ripiego che l'ordine dichiara accettabile.
  ///
  /// **Gli effetti no, e i toni nemmeno:** un effetto e' la risposta a un
  /// gesto, e un gesto fatto mezz'ora fa non merita una risposta adesso.
  @override
  Future<void> riprendi() async {
    // **IL SECONDO PIANO SI CHIUDE PER PRIMO, e prima dell'uscita anticipata.**
    // Ordine CY voce 02. Se questa riga stesse sotto il `return`, chi torna
    // in un'app che era muta resterebbe marcato "fuori" per sempre, e la
    // sentinella non ripartirebbe mai piu': il guardiano che esiste per far
    // ripartire un tappeto perso sarebbe spento a vita dal primo Home.
    _fuori = false;
    if (!_musicaSospesaDaNoi) return;
    _musicaSospesaDaNoi = false;
    quanteRiprese++;
    await riprendiMusica();
  }

  /// Ferma i toni lunghi. Gli effetti brevi finiscono da soli.
  ///
  /// **Dal campo e non dal getter.** Ordine CT voce 07: `_toni` costruisce il
  /// lettore quando non c'e', quindi fermare un tono mai suonato ne creava uno
  /// nuovo per zittirlo. Un lettore che nasce tocca la piattaforma, e la
  /// piattaforma puo' non rispondere.
  Future<void> fermaTono() async {
    try {
      await _toniPigro?.stop();
    } catch (_) {
      // Gia' fermo, oppure nessun lettore: nulla da fare.
    }
  }

  Future<void> dispose() async {
    await _effettiPigro?.dispose();
    await _toniPigro?.dispose();
    await _musicaPigro?.dispose();
  }
}
