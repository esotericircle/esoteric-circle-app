import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';

import '../../core/astro/zodiac.dart';
import '../../core/maestro/maestro.dart';
import '../../core/maestro/chakra_del_giorno.dart';
import '../../core/permissions/app_permission.dart';
import '../../core/permissions/esito_del_permesso.dart';
import '../../core/rituals/runes.dart';
import '../../core/tarot/tarot_card.dart';
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

  /// **La stanza si ricorda il fondo e il sottofondo da una frase
  /// all'altra.** Ordine EM voce 04: una televisione accesa si impara una
  /// volta, non a ogni frase.
  final _stanza = LaStanza();
  late IlSilenzioVero _silenzio = IlSilenzioVero(stanza: _stanza);

  /// Quanto ogni pezzo e' voce. Ordine EM voce 04.
  final _misura = LaMisuraDellaVoce(tasso: tasso);
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

  /// **COME SI APRE IL MICROFONO DEL LIVE**, in un posto solo e pubblico
  /// perche' una prova lo guardi. Ordine EM voci 04 e 08, 25 settembre 2026.
  ///
  /// - **La sorgente e' quella delle chiamate**, `voiceCommunication`, con la
  ///   soppressione del rumore e dell'eco del telefono: e' l'elaborazione che
  ///   il telefono usa per far sentire chi parla vicino e non la stanza.
  ///   Prima era la sorgente di serie, senza filtri.
  /// - **Il microfono non si ferma quando un altro suono prende l'audio.** Il
  ///   registratore, di serie, chiede il fuoco audio e alla prima perdita si
  ///   mette in pausa per sempre: la ripresa esiste solo nel modo
  ///   `pauseResume`. L'anteprima delle voci nel selettore suona con un
  ///   lettore che chiede il fuoco, e dopo averla ascoltata il microfono del
  ///   LIVE restava muto. Il fondatore: *"Quando torno indietro dal selettore,
  ///   il microfono non funziona più."* Padre: ordine EJ voce 01, che ha
  ///   aperto il microfono col modo di serie. Adesso il microfono non chiede
  ///   il fuoco e non lo perde.
  static const RecordConfig configurazione = RecordConfig(
    encoder: AudioEncoder.pcm16bits,
    sampleRate: tasso,
    numChannels: 1,
    androidConfig: AndroidRecordConfig(
      audioSource: AndroidAudioSource.voiceCommunication,
    ),
    noiseSuppress: true,
    echoCancel: true,
    audioInterruption: AudioInterruptionMode.none,
  );

  /// Vero mentre la persona tiene premuto: la frase non si chiude da sola.
  bool aMano = false;

  /// Il livello istantaneo, fra 0 e 1, per chi disegna l'ascolto.
  void Function(double livello)? suLivello;

  /// Una frase si e' chiusa: il suo PCM a 16 bit, mono, a [tasso], e la
  /// pausa che l'ha chiusa, cioe' il numero dato da [suPausa]; -1 quando
  /// l'ha chiusa la mano che lascia il pulsante.
  void Function(Uint8List pcm, int pausa)? suFrase;

  /// **LA FRASE E' IN PAUSA, E FORSE FINITA.** Ordine EM voce 11: dopo
  /// settecento millesimi di silenzio l'orecchio da' l'audio detto finora col
  /// numero della pausa, e la schermata comincia a trascriverlo; se la frase
  /// si chiude con quella stessa pausa, la trascrizione e' gia' pronta.
  void Function(Uint8List pcm, int pausa)? suPausa;

  /// L'istante dell'ultimo pezzo di voce: la fine del parlato, da cui si
  /// misura l'attesa della risposta. Ordine EM voce 11.
  DateTime? ultimaVoce;

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
    final flusso = await _registratore.startStream(configurazione);
    var dalRegistro = Duration.zero;
    _flusso = flusso.listen((pezzo) {
      final db = decibelDi(pezzo);
      final durata = Duration(microseconds: pezzo.length * 500000 ~/ tasso);
      final voce = _misura.aggiungi(pezzo);
      final eraInPausa = _silenzio.inPausa;
      _silenzio.senti(db, durata, voce: voce);
      if (_silenzio.parlaAdesso) ultimaVoce = DateTime.now();
      // **IL REGISTRO DEI LIVELLI**, una riga ogni quarto di secondo: la
      // regola del silenzio si tara sui numeri veri del telefono, non su
      // quelli immaginati. Ordine EJ voce 01; la voce e il sottofondo,
      // ordine EM voce 04.
      dalRegistro += durata;
      if (dalRegistro >= const Duration(milliseconds: 250)) {
        dalRegistro = Duration.zero;
        debugPrint('ORECCHIO db ${db.round()} fondo '
            '${_silenzio.fondo?.round()} sottofondo '
            '${_stanza.sottofondo?.round()} voce ${voce.toStringAsFixed(2)} '
            'parla ${_silenzio.parlaAdesso} parlato ${_silenzio.haParlato} '
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
      if (!eraInPausa && _silenzio.inPausa && !aMano) {
        suPausa?.call(_parlato.toBytes(), _silenzio.pause);
      }
      if (_silenzio.fraseChiusa && !aMano) _consegna(_silenzio.pause);
    });
    return true;
  }

  void _nuovaFrase() {
    _silenzio = IlSilenzioVero(stanza: _stanza);
    _parlato.clear();
    _prima.clear();
    _byteDiPrima = 0;
    _parlavaGia = false;
  }

  /// La frase finita esce, e l'ascolto ricomincia da una frase nuova.
  void _consegna([int pausa = -1]) {
    final pcm = _parlato.takeBytes();
    _nuovaFrase();
    if (pcm.isNotEmpty) suFrase?.call(pcm, pausa);
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

  /// **I NOMI CHE UNA PERSONA DICE AI MAESTRI.** Ordine EK voce 03, 24
  /// settembre 2026.
  ///
  /// Il rapporto EJ: *"la trascrizione del LIVE ha scritto "Mezz'ora" invece
  /// di "Medora""*; sul Realme anche *"Mei d'ora"*. Il fondatore: *"è Calìgo e
  /// non Càligo"*. Chi trascrive non sapeva di trovarsi davanti a tre Maestri
  /// e alle loro arti, e un nome che non conosce lo sente come la parola
  /// comune piu' vicina. Qui glieli si dice, **presi dai cataloghi dell'app e
  /// non scritti a mano**: se un catalogo cresce, cresce anche l'elenco, e la
  /// guardia `i_nomi_del_live_si_trascrivono_giusti` pretende che ci siano
  /// tutti.
  static List<String> get nomiDelleArti => [
        'Medora',
        'Aura',
        'Calìgo',
        for (final c in TarotDeck.cards)
          if (c.arcana == TarotArcana.maggiore) c.name,
        'Bastoni',
        'Coppe',
        'Spade',
        'Denari',
        for (final r in kElderFuthark) r.name,
        for (final z in Zodiac.values) z.italianName,
        for (final c in ChakraDelGiorno.tutti) c.nome,
      ];

  /// **LE VOCI DI SOTTOFONDO NON SONO LA PERSONA.** Ordine EM voce 04, 25
  /// settembre 2026: il fondatore usa "Ok Google" con la televisione accesa
  /// e vuole la stessa tolleranza. La regola del silenzio lascia fuori la
  /// televisione che sta sotto chi parla al telefono; quando una frase di
  /// sola televisione passa lo stesso, e' chi trascrive a riconoscerla.
  static const String sottofondo =
      'Trascrivi soltanto la persona che parla vicino al telefono: ignora le '
      'voci lontane o di sottofondo, come la televisione, la radio, la musica '
      'o altre persone nella stanza. Se si sentono solo voci di sottofondo, '
      'scrivi soltanto $silenzio.';

  /// **NEL LIVE DI AURA, "LAURA" E' AURA.** Ordine EM voce 01, 25 settembre
  /// 2026. Sul Realme, nell'ordine EK voce 03, la trascrizione ha scritto
  /// "Laura" per "Aura" una volta su una. Il fondatore ha scelto la regola
  /// solo per il LIVE di Aura, *"Sì"*, sapendo che una Laura vera di cui la
  /// persona parla diventerebbe Aura. Negli altri LIVE il testo resta com'e'.
  static String nelLiveDi(Maestro maestro, String testo) =>
      maestro == Maestro.aura ? testo.replaceAll(_laura, 'Aura') : testo;

  static final RegExp _laura =
      RegExp(r'(?<!\p{L})Laura(?!\p{L})', unicode: true);

  /// Cio' che si chiede a Gemini insieme alla registrazione.
  static String get istruzione =>
      'Trascrivi esattamente, nella lingua in cui parla, ciò che dice la '
      'persona in questa registrazione, dalla prima all\'ultima parola. '
      'Scrivi solo le sue parole, senza commenti e senza virgolette. Se non '
      'si sente nessuna parola, scrivi soltanto $silenzio.\n'
      '$sottofondo\n'
      'La persona parla con tre Maestri di un\'app di astrologia, carte, '
      'rune e chakra: può nominarli o nominare le loro arti. Questi nomi '
      'scrivili esattamente così quando li senti, anche se somigliano a una '
      'parola comune: ${nomiDelleArti.join(', ')}. Non aggiungerli se la '
      'persona non li dice.';

  /// Le parole di un testo, minuscole, senza segni: "L'Appeso" fa "l",
  /// "appeso".
  static List<String> _parole(String testo) => testo
      .toLowerCase()
      .split(RegExp(r'[^\p{L}]+', unicode: true))
      .where((p) => p.isNotEmpty)
      .toList();

  /// **UN ELENCO DI NOMI NON E' UNA FRASE.** Ordine EK voce 03. Sul Realme un
  /// pezzo di frase che cominciava con "Aura, sento un blocco" e' tornato
  /// *"Medora Aura Calìgo"*; al banco Flash-Lite ha risposto con l'elenco
  /// intero, settantadue nomi, a due frasi su sei. Una trascrizione fatta
  /// soltanto di tre o piu' nomi consecutivi dell'elenco, e di nient'altro,
  /// e' il modello che ricopia l'istruzione: nessuno parla ai Maestri
  /// recitando il loro elenco. Vale come silenzio.
  static bool eUnPezzoDellElenco(String testo) {
    final parole = _parole(testo);
    if (parole.isEmpty) return false;
    final nomi = [for (final n in nomiDelleArti) _parole(n)];
    for (var primo = 0; primo < nomi.length; primo++) {
      var lette = 0;
      var quanti = 0;
      while (primo + quanti < nomi.length && lette < parole.length) {
        final nome = nomi[primo + quanti];
        if (lette + nome.length > parole.length) break;
        var uguale = true;
        for (var k = 0; k < nome.length && uguale; k++) {
          uguale = parole[lette + k] == nome[k];
        }
        if (!uguale) break;
        lette += nome.length;
        quanti++;
      }
      if (lette == parole.length && quanti >= 3) return true;
    }
    return false;
  }

  /// Il nome del Maestro scritto senza accento, o con quello sbagliato.
  static final RegExp _caligo =
      RegExp(r'(?<!\p{L})[Cc][aàá]l[iìí]go(?!\p{L})', unicode: true);

  /// **LA TRASCRIZIONE RIPULITA, prima di diventare una domanda.** Il
  /// fondatore: *"è Calìgo e non Càligo"*. Al banco Flash ha scritto
  /// "Caligo" due volte su quattro: il nome giusto lo conosce l'app, e lo
  /// rimette lei. Poi l'elenco ricopiato vale come silenzio.
  static String ripulita(String testo) {
    final giusto = testo.replaceAll(_caligo, 'Calìgo');
    return eUnPezzoDellElenco(giusto) ? '' : giusto;
  }

  static Future<String> _daGemini(Uint8List wav) async {
    final modello =
        FirebaseAI.vertexAI(location: FirebaseMaestroAiProvider.kVertexLocation)
            .generativeModel(
      // **FLASH E NON FLASH-LITE. Ordine EK voce 03.** Al banco
      // (`tool/banco_orecchio_ek.dart`, stessi audio e stessa istruzione)
      // Flash-Lite ha ricopiato l'elenco dei nomi al posto della frase in due
      // frasi su sei, ha scritto "Medora" su tre secondi di fruscio e
      // "Ariete" dentro una frase interrotta; Flash nessuna delle tre cose,
      // 42 nomi giusti su 44 contro 40, e un tempo mediano di 1.060 ms
      // contro 1.161. Il modello sta nella regione dei dati.
      model: FirebaseMaestroAiProvider.kMaestroChatModel,
      generationConfig: GenerationConfig(
        temperature: 0,
        maxOutputTokens: 600,
        thinkingConfig: ThinkingConfig.withThinkingBudget(0),
      ),
    );
    final risposta = await modello.generateContent([
      Content.multi([
        TextPart(istruzione),
        InlineDataPart('audio/wav', wav),
      ]),
    ]);
    // Gemini manda una frase per riga: la domanda della persona e' una sola,
    // e a capo nella bolla sembrerebbe un elenco. Visto sul Realme.
    final testo =
        (risposta.text ?? '').replaceAll(RegExp(r'\s*\n+\s*'), ' ').trim();
    return testo == silenzio ? '' : ripulita(testo);
  }
}
