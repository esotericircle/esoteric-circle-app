import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../core/sensi/wav_da_pcm.dart';

/// **IL BANCO DELL'ORECCHIO, SOLO NELLE BUILD DI COLLAUDO.** Ordine EM voce
/// 04, secondo giro, 25 settembre 2026.
///
/// Sul Realme, con la televisione finta sotto, la trascrizione ha perso "Aura"
/// in apertura e "e anche a Vishuddha" in mezzo, due volte su due; al banco,
/// sullo stesso audio mescolato al computer e con la stessa istruzione, le
/// undici parole tornavano tutte, quattro volte su quattro. Le parole si
/// perdono quindi fra il microfono e la trascrizione: nella sorgente del
/// telefono e nei suoi filtri. Per misurarlo servono l'audio vero di ogni
/// frase e la possibilita' di cambiare sorgente senza una build nuova.
///
/// **Si accende soltanto con `--dart-define=EM_BANCO=true`.** La build da
/// distribuire si fa senza, e allora [acceso] e' falso a compilazione e nulla
/// di qui viene chiamato:
///
/// - [configurazione] legge `files/em_sorgente.txt` nella cartella esterna
///   dell'app, una riga come `voiceRecognition no`: la sorgente di Android e
///   se accendere la soppressione del rumore e dell'eco;
/// - [registra] scrive ogni frase consegnata in `files/frasi/`, in WAV.
abstract final class IlBancoDellOrecchio {
  static const bool acceso = bool.fromEnvironment('EM_BANCO');

  /// La configurazione del banco, o [normale] se il file manca o non si
  /// legge.
  static Future<RecordConfig> configurazione(RecordConfig normale) async {
    try {
      final cartella = await getExternalStorageDirectory();
      final file = File('${cartella!.path}/em_sorgente.txt');
      if (!file.existsSync()) {
        debugPrint('ORECCHIO BANCO: nessun em_sorgente.txt, configurazione '
            'normale');
        return normale;
      }
      final parti = file.readAsStringSync().trim().split(RegExp(r'\s+'));
      final sorgente =
          AndroidAudioSource.values.firstWhere((s) => s.name == parti.first);
      final filtri = parti.length > 1 && parti[1] == 'si';
      debugPrint('ORECCHIO BANCO: sorgente ${sorgente.name}, filtri $filtri');
      return RecordConfig(
        encoder: normale.encoder,
        sampleRate: normale.sampleRate,
        numChannels: normale.numChannels,
        androidConfig: AndroidRecordConfig(audioSource: sorgente),
        noiseSuppress: filtri,
        echoCancel: filtri,
        audioInterruption: normale.audioInterruption,
      );
    } catch (errore) {
      debugPrint('ORECCHIO BANCO: configurazione illeggibile, $errore');
      return normale;
    }
  }

  /// Scrive la frase [frase] in `files/frasi/`; [nome] dice il momento, la
  /// consegna o un controllo.
  static Future<void> registra(Uint8List pcm, int frase, int tasso,
      {String nome = 'consegna'}) async {
    try {
      final cartella = await getExternalStorageDirectory();
      final dir = Directory('${cartella!.path}/frasi')
        ..createSync(recursive: true);
      final file =
          'frase_${DateTime.now().millisecondsSinceEpoch}_${frase}_$nome.wav';
      File('${dir.path}/$file').writeAsBytesSync(wavDaPcm(pcm, tasso: tasso));
      debugPrint('ORECCHIO BANCO: registrata $file, ${pcm.length ~/ 32} ms');
    } catch (errore) {
      debugPrint('ORECCHIO BANCO: la frase non si registra, $errore');
    }
  }
}
