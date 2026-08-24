
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

  /// I lettori nascono PIGRI, alla prima riproduzione.
  ///
  /// Costruirli subito tocca la piattaforma, quindi in un ambiente senza plugin,
  /// come una prova o un'anteprima, il solo fatto di creare il motore
  /// solleverebbe. Il motore deve poter esistere ovunque: e' il suono a essere
  /// facoltativo, non la sua esistenza.
  AudioPlayer? _effettiPigro;
  AudioPlayer? _toniPigro;

  AudioPlayer get _effetti =>
      _effettiPigro ??= AudioPlayer(playerId: 'cerchio_effetti');

  AudioPlayer get _toni => _toniPigro ??= AudioPlayer(playerId: 'cerchio_toni');

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
  Future<Duration?> effetto(String percorsoAsset) async {
    try {
      await _effetti.stop();
      await _effetti.play(AssetSource(percorsoAsset));
      return await _effetti.getDuration();
    } catch (e) {
      // Nessun suono: il rito continua lo stesso.
      debugPrint('Suono non riprodotto ($percorsoAsset): $e');
      return null;
    }
  }

  /// Riproduce byte sintetizzati, per esempio un tono binaurale in WAV.
  ///
  /// In ciclo continuo quando [inCiclo] e' vero, che e' il caso della
  /// Meditazione: il tono deve durare quanto la sessione, non quanto il
  /// campione.
  Future<void> tono(Uint8List byte, {bool inCiclo = true}) async {
    try {
      await _toni.setReleaseMode(
          inCiclo ? ReleaseMode.loop : ReleaseMode.release);
      await _toni.play(BytesSource(byte));
    } catch (e) {
      debugPrint('Tono non riprodotto: $e');
    }
  }

  /// Ferma ogni suono in corso: e' cio' che la Guardia del Suono chiama quando
  /// l'app perde il primo piano.
  @override
  Future<void> fermaTutto() async {
    await fermaTono();
    try {
      await _effettiPigro?.stop();
    } catch (_) {
      // Nessun effetto in corso: nulla da fare.
    }
  }

  /// La Guardia non la chiama mai: il suono non riparte da solo. Esiste perche'
  /// il confine lo prevede, e domani potrebbe servire a chi riavvia un rito.
  @override
  Future<void> riprendi() async {}

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
  }
}
