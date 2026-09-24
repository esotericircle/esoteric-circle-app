import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';

import '../../core/permissions/app_permission.dart';
import '../../core/permissions/esito_del_permesso.dart';
import '../../features/maestri/live/il_silenzio_vero.dart';
import '../ai/firebase_maestro_ai_provider.dart';
import '../ai/registro_dei_guasti.dart';

/// **L'ORECCHIO DEL LIVE.** Ordine EJ voce 01, 24 settembre 2026.
///
/// Prima il LIVE ascoltava con il riconoscitore di Android, che chiude da
/// solo: dopo qualche secondo di silenzio iniziale, e dopo ogni pausa. Il
/// fondatore: *"mi lascia circa un secondo per parlare [...] mi tronca la
/// mia domanda che cmq viene inviata"*.
///
/// Adesso il LIVE **registra** la persona e decide lui quando una frase e'
/// finita, con `IlSilenzioVero`: dopo due secondi di silenzio vero dopo aver
/// parlato, mai col silenzio iniziale. **Oppure la persona tiene premuto**, e
/// allora parla senza limiti finche' non lascia.
///
/// **E il microfono non si chiude fra una frase e l'altra.** La prima stesura
/// lo chiudeva per trascrivere, e sul Realme chi riprendeva a parlare in quel
/// secondo e mezzo non era ascoltato: la domanda arrivava senza l'inizio.
/// Ogni frase chiusa esce da [suFrase] e l'ascolto continua; decide la
/// schermata, con `LeFrasiDellaPersona`, quando le frasi diventano domanda.
class LOrecchioDelLive {
  LOrecchioDelLive({AudioRecorder? registratore})
      : _registratore = registratore ?? AudioRecorder();

  final AudioRecorder _registratore;
  StreamSubscription<Uint8List>? _flusso;
  IlSilenzioVero _silenzio = IlSilenzioVero();
  final _parlato = BytesBuilder(copy: false);
  bool _inAscolto = false;
  bool _parlavaGia = false;

  /// L'audio di prima che la persona parlasse: un secondo, perche' l'attacco
  /// di una frase sta spesso sotto la soglia d'inizio, e sul Realme il nome
  /// del Maestro in apertura andava perso con mezzo secondo solo.
  final _prima = <Uint8List>[];
  int _byteDiPrima = 0;

  static const int tasso = 16000;
  static const int _unSecondo = tasso * 2; // 16 bit mono

  /// Vero mentre la persona tiene premuto: la frase non si chiude da sola.
  bool aMano = false;

  /// Il livello istantaneo, fra 0 e 1, per chi disegna l'ascolto.
  void Function(double livello)? suLivello;

  /// Una frase si e' chiusa: il suo PCM a 16 bit, mono, a [tasso].
  void Function(Uint8List pcm)? suFrase;

  bool get inAscolto => _inAscolto;

  /// Vero mentre la persona sta dicendo una frase, o tiene premuto: in quel
  /// tempo la stanza non e' in silenzio, anche se la frase dura un minuto.
  bool get staParlando => _inAscolto && (aMano || _silenzio.haParlato);

  /// Apre il microfono, e lo tiene aperto finche' qualcuno non lo ferma.
  /// Falso se il permesso manca.
  Future<bool> ascolta() async {
    if (_inAscolto) return true;
    final esito = await PortaDelPermesso.chiedi(
      AppPermission.microphone,
      richiestaDiSistema: _registratore.hasPermission,
    );
    if (esito != EsitoDelPermesso.concesso) return false;
    _nuovaFrase();
    _inAscolto = true;
    final flusso = await _registratore.startStream(const RecordConfig(
      encoder: AudioEncoder.pcm16bits,
      sampleRate: tasso,
      numChannels: 1,
    ));
    var dalRegistro = Duration.zero;
    _flusso = flusso.listen((pezzo) {
      final db = decibelDi(pezzo);
      final durata = Duration(microseconds: pezzo.length * 500000 ~/ tasso);
      _silenzio.senti(db, durata);
      // **IL REGISTRO DEI LIVELLI**, una riga ogni quarto di secondo: la
      // regola del silenzio si tara sui numeri veri del telefono, non su
      // quelli immaginati. Ordine EJ voce 01.
      dalRegistro += durata;
      if (dalRegistro >= const Duration(milliseconds: 250)) {
        dalRegistro = Duration.zero;
        debugPrint('ORECCHIO db ${db.round()} fondo '
            '${_silenzio.fondo?.round()} parlato ${_silenzio.haParlato} '
            'silenzio ${_silenzio.silenzioDiFila.inMilliseconds} mano $aMano');
      }
      suLivello?.call(((db + 60) / 50).clamp(0.0, 1.0));
      if (_silenzio.haParlato || aMano) {
        if (!_parlavaGia) {
          _parlavaGia = true;
          for (final p in _prima) {
            _parlato.add(p);
          }
          _prima.clear();
          _byteDiPrima = 0;
        }
        _parlato.add(pezzo);
      } else {
        _prima.add(pezzo);
        _byteDiPrima += pezzo.length;
        while (_byteDiPrima > _unSecondo && _prima.isNotEmpty) {
          _byteDiPrima -= _prima.removeAt(0).length;
        }
      }
      if (_silenzio.fraseChiusa && !aMano) _consegna();
    });
    return true;
  }

  void _nuovaFrase() {
    _silenzio = IlSilenzioVero();
    _parlato.clear();
    _prima.clear();
    _byteDiPrima = 0;
    _parlavaGia = false;
  }

  /// La frase finita esce, e l'ascolto ricomincia da una frase nuova.
  void _consegna() {
    final pcm = _parlato.takeBytes();
    _nuovaFrase();
    if (pcm.isNotEmpty) suFrase?.call(pcm);
  }

  /// La persona ha lasciato il pulsante: la frase finisce adesso.
  void lascia() {
    aMano = false;
    if (_inAscolto) _consegna();
  }

  /// Ferma l'ascolto senza mandare niente.
  Future<void> ferma() async {
    _inAscolto = false;
    aMano = false;
    await _flusso?.cancel();
    _flusso = null;
    try {
      await _registratore.stop();
    } catch (errore) {
      // Il registratore gia' fermo non e' un guasto: si ferma comunque.
      annotaGuastoInnocuo('il microfono del LIVE era già fermo', errore);
    }
    _nuovaFrase();
  }

  Future<void> dispose() async {
    await ferma();
    await _registratore.dispose();
  }

  /// Il livello di un pezzo di PCM a 16 bit, in dBFS.
  static double decibelDi(Uint8List pezzo) {
    final n = pezzo.length ~/ 2;
    if (n == 0) return -100;
    final dati = ByteData.sublistView(pezzo);
    var somma = 0.0;
    for (var i = 0; i < n; i++) {
      final c = dati.getInt16(i * 2, Endian.little) / 32768.0;
      somma += c * c;
    }
    final rms = math.sqrt(somma / n);
    return rms <= 0 ? -100 : 20 * math.log(rms) / math.ln10;
  }
}

/// **LA TRASCRIZIONE DELLA FRASE, con Gemini nella regione dei dati.**
/// Ordine EJ voce 01. Sostituibile nelle prove.
abstract final class LaTrascrizione {
  static Future<String> Function(Uint8List wav) trascrivi = _daGemini;

  /// Il segno con cui Gemini dice che nella registrazione non c'e' parola.
  static const String silenzio = '[SILENZIO]';

  static Future<String> _daGemini(Uint8List wav) async {
    final modello =
        FirebaseAI.vertexAI(location: FirebaseMaestroAiProvider.kVertexLocation)
            .generativeModel(
      model: FirebaseMaestroAiProvider.kMaestroBreveModel,
      generationConfig: GenerationConfig(
        temperature: 0,
        maxOutputTokens: 600,
        thinkingConfig: ThinkingConfig.withThinkingBudget(0),
      ),
    );
    final risposta = await modello.generateContent([
      Content.multi([
        const TextPart('Trascrivi esattamente, nella lingua in cui parla, '
            'ciò che dice la persona in questa registrazione, dalla prima '
            'all\'ultima parola. '
            'Scrivi solo le sue parole, senza commenti e senza virgolette. Se '
            'non si sente nessuna parola, scrivi soltanto $silenzio.'),
        InlineDataPart('audio/wav', wav),
      ]),
    ]);
    // Gemini manda una frase per riga: la domanda della persona e' una sola,
    // e a capo nella bolla sembrerebbe un elenco. Visto sul Realme.
    final testo =
        (risposta.text ?? '').replaceAll(RegExp(r'\s*\n+\s*'), ' ').trim();
    return testo == silenzio ? '' : testo;
  }
}
