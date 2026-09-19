# -*- coding: utf-8 -*-
"""CQ1.04: l'effetto non aspetta la piattaforma e non chiede il fuoco."""
NL = chr(10)
CR = chr(13)
P = 'lib/core/sensi/motore_audio.dart'

grezzo = open(P, 'rb').read().decode('utf-8')
crlf = CR in grezzo
s = grezzo.replace(CR + NL, NL) if crlf else grezzo

vecchio = """  Future<Duration?> effetto(String percorsoAsset) async {
    if (senzaLettori) return null;
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
"""

nuovo = """  Future<Duration?> effetto(String percorsoAsset) async {
    if (senzaLettori) return null;
    try {
      await _preparaGliEffetti();
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
"""

assert s.count(vecchio) == 1, s.count(vecchio)
s = s.replace(vecchio, nuovo)
if 'import' in s and "import 'dart:async';" not in s:
    s = s.replace("import 'package:audioplayers/audioplayers.dart';",
                  "import 'dart:async';" + NL + NL +
                  "import 'package:audioplayers/audioplayers.dart';")
open(P, 'wb').write((s.replace(NL, CR + NL) if crlf else s).encode('utf-8'))
controllo = open(P, 'rb').read().decode('utf-8')
assert '_preparaGliEffetti' in controllo
assert 'await _effetti.play(' not in controllo
print('FATTO. play non e piu atteso, contesto degli effetti presente.')
