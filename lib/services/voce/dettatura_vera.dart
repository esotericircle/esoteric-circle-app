/// LA DETTATURA VERA, quella che parla col sistema. Ordine CI voce 05.
///
/// **Il permesso passa dalla porta di casa**, `PortaDelPermesso`, e non dal
/// plugin: quella porta sa distinguere tre cose che il sistema confonde in
/// una, cioe' un no della persona, un no per sempre e una piattaforma che il
/// sensore non ce l'ha. Serve perche' la riga da mostrare e' diversa nei tre
/// casi, e in uno dei tre non c'e' niente da richiedere.
///
/// **Il permesso si chiede AL PRIMO TOCCO sul microfono**, mai prima, come
/// vuole la sezione 25 delle Linee Guida UX: `disponibile()` non chiede
/// niente, guarda solo se la piattaforma sa riconoscere la voce.
///
/// **Nessun audio esce da qui.** Il plugin usa il riconoscitore della
/// piattaforma e restituisce parole gia' scritte: questo file non salva
/// niente, non manda niente e non conserva niente.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:speech_to_text/speech_to_text.dart';

import '../../core/voce/dettatura.dart';

class DettaturaVera extends Dettatura {
  DettaturaVera({SpeechToText? motore, Locale? Function()? lingua})
      : _motore = motore ?? SpeechToText(),
        _lingua = lingua;

  final SpeechToText _motore;

  /// **LA LINGUA IN CUI SI ASCOLTA E' QUELLA DELL'APP. Ordine DX voce 02.**
  ///
  /// Il fatto: su un iPhone la frase *"quindi, cosa devo fare della mia
  /// lettura?"* e' arrivata nel campo come *"Indicate"*. La causa: senza una
  /// lingua il plugin iOS ascolta con `Locale.current`, e per un'app
  /// `Locale.current` e' la lingua scelta fra quelle che l'app DICHIARA. Il
  /// progetto iOS dichiara solo l'inglese, quindi la voce italiana finiva a un
  /// riconoscitore inglese, che sente "quindi" e scrive "Indicate". Su Android
  /// il plugin prende la lingua del sistema, ed e' per questo che al banco del
  /// telefono Android il difetto non c'era.
  ///
  /// Una funzione e non un valore: la lingua dell'app si puo' cambiare dal
  /// profilo mentre la chat e' aperta, e la dettatura deve seguirla al tocco.
  final Locale? Function()? _lingua;

  /// **LA VOCE DEL RICONOSCITORE CHE PARLA QUELLA LINGUA**, scelta fra quelle
  /// che la piattaforma dichiara di avere.
  ///
  /// I nomi arrivano in due forme, `it_IT` e `it-IT`, secondo la piattaforma:
  /// si confrontano senza badare al separatore e alle maiuscole, e si
  /// restituisce il nome COSI' COME la piattaforma l'ha dato. Preferenza: la
  /// lingua col suo paese se l'app lo dice, poi la lingua col paese omonimo
  /// (`it_IT` prima di `it_CH`), poi la prima di quella lingua. Se la
  /// piattaforma non dice niente si costruisce `it_IT` da soli: meglio una
  /// voce italiana chiesta per nome che nessuna voce, perche' nessuna voce
  /// vuol dire l'inglese.
  @visibleForTesting
  static String? voceDellaLingua(Locale? lingua, List<String> disponibili) {
    if (lingua == null || lingua.languageCode.isEmpty) return null;
    String piano(String id) => id.replaceAll('-', '_').toLowerCase();
    final codice = lingua.languageCode.toLowerCase();
    final paese = lingua.countryCode?.toLowerCase();
    final stessaLingua = [
      for (final id in disponibili)
        if (piano(id).split('_').first == codice) id,
    ];
    if (paese != null && paese.isNotEmpty) {
      for (final id in stessaLingua) {
        if (piano(id) == '${codice}_$paese') return id;
      }
    }
    for (final id in stessaLingua) {
      if (piano(id) == '${codice}_$codice') return id;
    }
    if (stessaLingua.isNotEmpty) return stessaLingua.first;
    final suo = (paese != null && paese.isNotEmpty) ? paese : codice;
    return '${codice}_${suo.toUpperCase()}';
  }

  Future<String?> _voceDaUsare() async {
    final lingua = _lingua?.call();
    if (lingua == null) return null;
    var disponibili = const <String>[];
    try {
      disponibili = [for (final l in await _motore.locales()) l.localeId];
    } catch (errore) {
      debugPrint('Dettatura: la piattaforma non elenca le lingue. $errore');
    }
    return voceDellaLingua(lingua, disponibili);
  }

  /// **L'AVVIO SI FA UNA VOLTA SOLA.** `initialize` va chiamato prima di
  /// qualunque altra cosa, e chiamarlo a ogni tocco vorrebbe dire rifare il
  /// giro col sistema operativo mentre la persona aspetta.
  bool? _pronta;

  @override
  Future<bool> accendi() => _accendi();

  Future<bool> _accendi() async {
    if (_pronta != null) return _pronta!;
    try {
      _pronta = await _motore.initialize(
        onError: (e) => debugPrint('Dettatura: ${e.errorMsg}'),
        // **NON SI CHIEDE IL PERMESSO QUI.** Il plugin lo chiederebbe da se'
        // durante l'avvio, cioe' PRIMA che la persona abbia toccato il
        // microfono, e sarebbe esattamente il difetto che la sezione 25
        // vieta: un dialogo di sistema che compare senza che nessuno lo
        // abbia chiesto.
        options: [SpeechToText.androidNoBluetooth],
      );
    } catch (errore) {
      debugPrint('Dettatura: la piattaforma non risponde. $errore');
      _pronta = false;
    }
    return _pronta!;
  }

  /// **QUI NON SI ACCENDE NIENTE, ed e' il punto.**
  ///
  /// `initialize` del riconoscitore CHIEDE IL PERMESSO DEL MICROFONO da se',
  /// e questa domanda viene fatta all'apertura della chat: chiamarlo qui
  /// vorrebbe dire far comparire il dialogo di sistema senza che nessuno
  /// abbia toccato niente, cioe' esattamente cio' che la sezione 25 delle
  /// Linee Guida UX vieta. L'ho scritto sbagliato una prima volta e la
  /// correzione sta qui.
  ///
  /// Quello che si guarda e' la PIATTAFORMA: il riconoscimento vocale di
  /// sistema esiste su Android e su iOS, e non esiste altrove. Dove non
  /// esiste il microfono non compare, che e' il vincolo f. Se poi al primo
  /// tocco l'accensione fallisce lo stesso, il comando sparisce invece di
  /// restare li' a non funzionare.
  @override
  Future<bool> disponibile() async =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  @override
  Future<bool> ascolta({
    required void Function(String parole) parole,
    required void Function() finito,
  }) async {
    if (!await _accendi()) return false;
    final voce = await _voceDaUsare();
    try {
      await _motore.listen(
        onResult: (esito) => parole(esito.recognizedWords),
        listenOptions: SpeechListenOptions(
          // Nulla solo quando nessuno ha detto la lingua dell'app: allora
          // decide la piattaforma, come prima.
          localeId: voce,
          // **I RISULTATI PARZIALI SERVONO**, ed e' una scelta: il campo si
          // riempie mentre si parla, cosi' chi detta vede che sta funzionando
          // invece di fissare un campo vuoto e chiedersi se il microfono
          // ascolta.
          partialResults: true,
          cancelOnError: true,
          // La dettatura scrive una domanda, non un dettato lungo: dopo tre
          // secondi di silenzio si ferma da sola, e in nessun caso resta in
          // ascolto piu' di un minuto.
          pauseFor: const Duration(seconds: 3),
          listenFor: const Duration(minutes: 1),
        ),
      );
    } catch (errore) {
      debugPrint('Dettatura: l\'ascolto non parte. $errore');
      return false;
    }
    _motore.statusListener = (stato) {
      if (stato == SpeechToText.doneStatus ||
          stato == SpeechToText.notListeningStatus) {
        finito();
      }
    };
    return true;
  }

  @override
  Future<void> ferma() async {
    try {
      await _motore.stop();
    } catch (errore) {
      debugPrint('Dettatura: non si ferma. $errore');
    }
  }
}
