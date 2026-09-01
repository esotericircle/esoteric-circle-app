import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferenze dell'utente, tenute in un solo posto e persistite in locale.
///
/// - [reduceAnimations]: riduce o ferma i movimenti (parallasse, animazioni). Si
///   riversa su `MediaQuery.disableAnimations`, cosi' tutto il codice che gia'
///   rispetta Riduci Movimento lo onora senza modifiche.
/// - [simpleMode]: modalita' semplice, abbassa la qualita' grafica (meno stelle,
///   niente blur) per fluidita' e leggibilita'.
/// - [subtitles]: sottotitoli attivi, di default veri. Segnaposto in attesa del
///   passo voce: la preferenza si conserva, l'effetto arriva con la voce.
/// - [suonoEVibrazione]: l'INTERRUTTORE UNICO del livello sensoriale. Governa i
///   due canali INSIEME, suono e aptica, come prescrivono le Linee Guida alla
///   sezione 6. Un comando solo e non due, perche' chi vuole silenzio vuole
///   silenzio: due interruttori separati obbligherebbero a spegnere due volte la
///   stessa intenzione.
///
/// La persistenza e' best effort: se `SharedPreferences` non e' disponibile
/// (test senza mock, avvio a freddo) le preferenze restano solo in memoria,
/// senza crash.
class SettingsController extends ChangeNotifier {
  SettingsController({
    bool reduceAnimations = false,
    bool simpleMode = false,
    bool subtitles = true,
    bool suonoEVibrazione = true,
    bool effettiSonori = true,
    bool musicaAttiva = true,
    double volumeMusica = 0.6,
    double volumeEffetti = 1.0,
  })  : _reduceAnimations = reduceAnimations,
        _simpleMode = simpleMode,
        _subtitles = subtitles,
        _suonoEVibrazione = suonoEVibrazione,
        _effettiSonori = effettiSonori,
        _musicaAttiva = musicaAttiva,
        _volumeMusica = volumeMusica,
        _volumeEffetti = volumeEffetti;

  static const _kReduce = 'settings.reduceAnimations';
  static const _kSimple = 'settings.simpleMode';
  static const _kSubtitles = 'settings.subtitles';
  static const _kSuono = 'settings.suonoEVibrazione';
  static const _kEffetti = 'settings.effettiSonori';
  static const _kMusica = 'settings.musicaAttiva';
  static const _kVolumeMusica = 'settings.volumeMusica';
  static const _kVolumeEffetti = 'settings.volumeEffetti';

  bool _reduceAnimations;
  bool _simpleMode;
  bool _subtitles;
  bool _suonoEVibrazione;
  bool _effettiSonori;
  bool _musicaAttiva;
  double _volumeMusica;
  double _volumeEffetti;

  bool get reduceAnimations => _reduceAnimations;
  bool get simpleMode => _simpleMode;
  bool get subtitles => _subtitles;

  /// Se il livello sensoriale e' acceso: suono E vibrazione insieme.
  ///
  /// Ogni funzione che vibra o suona lo legge da qui, e nessuna tiene una
  /// propria preferenza separata: due comandi per la stessa intenzione sono un
  /// modo di non averne nessuno.
  bool get suonoEVibrazione => _suonoEVibrazione;

  /// **SOLO GLI EFFETTI SONORI, ordine BX voce 05.**
  ///
  /// L'ordine chiede un comando che disattivi gli effetti sonori, e
  /// l'interruttore unico non basta: quello spegne anche la vibrazione, che
  /// per chi tiene il telefono in silenzio e' l'unico canale che resta.
  /// **Chi vuole il silenzio senza perdere il tocco spegne questo**; chi
  /// vuole il silenzio totale spegne l'altro, che comanda su tutti e due.
  ///
  /// **VERO DI PARTENZA, ordine CN, 2 settembre 2026.** Decisione del
  /// fondatore: chi apre l'app per la prima volta sente i suoni.
  ///
  /// **SUPERA LA VOCE BZ.05 DEL 28 AGOSTO 2026, e la riga di prima si
  /// tiene perche' spiega perche' oggi si puo' cambiare.** Parole del
  /// fondatore di allora: "gli effetti sonori vanno per ora disabilitati
  /// per default, almeno fino a quando non ne scegliero qualcuno decente,
  /// adesso sembrano un giochino anni 80".
  ///
  /// **Quella ragione e' scaduta con l'ordine CN**, che ha fatto
  /// esattamente cio' che la condizione chiedeva: i suoni sono tredici e
  /// non sei, scelti dal fondatore uno per uno, e portati tutti alla
  /// stessa sonorita' con una misura sola. Il sigillo del Custodisci non
  /// sta piu' quindici decibel sotto le pietre.
  ///
  /// L'interruttore resta dov'e': chi vuole il silenzio senza perdere il
  /// tocco lo spegne, e lo ritrova spento alla riapertura.
  bool get effettiSonori => _effettiSonori;

  /// Vero se un suono puo' uscire adesso: servono tutti e due gli
  /// interruttori, e quello unico comanda.
  bool get suonoPermesso => _suonoEVibrazione && _effettiSonori;

  /// **LA MUSICA D'AMBIENTE, ordine CN del 1 settembre 2026.**
  ///
  /// **NASCE ACCESA, e gli effetti no. Non e' una svista.** Gli effetti
  /// nascono spenti dall'ordine BZ per una ragione precisa e scritta:
  /// quelli di allora "sembravano un giochino anni 80". Quella ragione
  /// non riguarda la musica, che e' nuova ed e' stata scelta dal
  /// fondatore uno per uno.
  ///
  /// E c'e' una ragione di disegno: l'ordine CN vuole che lo Shaman parta
  /// con la PRIMA schermata del Risveglio e prosegua senza interrompersi
  /// fino alla home. **Nascerla spenta cancellerebbe proprio quel
  /// disegno**, cioe' la prima impressione che qualcuno ha scelto.
  bool get musicaAttiva => _musicaAttiva;

  /// Quanto forte suona la musica, da 0 a 1. Sessanta per cento di
  /// partenza, deciso dal fondatore.
  ///
  /// Il cursore **riflette** lo stato globale e non lo scavalca: se
  /// l'interruttore unico e' spento, o quello della musica lo e', questo
  /// numero non fa uscire niente. Un cursore che suona mentre un
  /// interruttore dice di no e' un'app che non obbedisce.
  double get volumeMusica => _volumeMusica;

  /// Quanto forte suonano gli effetti, da 0 a 1. Cento per cento di
  /// partenza, deciso dal fondatore: gli effetti sono gia' normalizzati
  /// sette decibel sopra la musica, e il rapporto giusto c'e' prima che
  /// qualcuno tocchi un cursore.
  double get volumeEffetti => _volumeEffetti;

  /// Vero se la musica puo' uscire adesso.
  bool get musicaPermessa => _suonoEVibrazione && _musicaAttiva;

  /// Carica le preferenze salvate, best effort.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _reduceAnimations = prefs.getBool(_kReduce) ?? _reduceAnimations;
      _simpleMode = prefs.getBool(_kSimple) ?? _simpleMode;
      _subtitles = prefs.getBool(_kSubtitles) ?? _subtitles;
      _suonoEVibrazione = prefs.getBool(_kSuono) ?? _suonoEVibrazione;
      _effettiSonori = prefs.getBool(_kEffetti) ?? _effettiSonori;
      _musicaAttiva = prefs.getBool(_kMusica) ?? _musicaAttiva;
      _volumeMusica = prefs.getDouble(_kVolumeMusica) ?? _volumeMusica;
      _volumeEffetti = prefs.getDouble(_kVolumeEffetti) ?? _volumeEffetti;
      notifyListeners();
    } catch (_) {
      // Nessuna persistenza disponibile: si resta sui valori in memoria.
    }
  }

  /// Accende o spegne il livello sensoriale intero.
  void setSuonoEVibrazione(bool value) {
    if (value == _suonoEVibrazione) return;
    _suonoEVibrazione = value;
    notifyListeners();
    _persist(_kSuono, value);
  }

  /// Accende o spegne i soli effetti sonori. Ordine BX voce 05.
  void setEffettiSonori(bool value) {
    if (value == _effettiSonori) return;
    _effettiSonori = value;
    notifyListeners();
    _persist(_kEffetti, value);
  }

  /// Accende o spegne la sola musica d'ambiente.
  void setMusicaAttiva(bool value) {
    if (value == _musicaAttiva) return;
    _musicaAttiva = value;
    notifyListeners();
    _persist(_kMusica, value);
  }

  /// Quanto forte la musica. Il valore si stringe fra 0 e 1 qui e non
  /// dove viene usato: una preferenza fuori scala salvata sul disco
  /// tornerebbe fuori scala a ogni apertura.
  void setVolumeMusica(double value) {
    final v = value.clamp(0.0, 1.0);
    if (v == _volumeMusica) return;
    _volumeMusica = v;
    notifyListeners();
    _persistDouble(_kVolumeMusica, v);
  }

  /// Quanto forte gli effetti.
  void setVolumeEffetti(double value) {
    final v = value.clamp(0.0, 1.0);
    if (v == _volumeEffetti) return;
    _volumeEffetti = v;
    notifyListeners();
    _persistDouble(_kVolumeEffetti, v);
  }

  void setReduceAnimations(bool value) {
    if (value == _reduceAnimations) return;
    _reduceAnimations = value;
    notifyListeners();
    _persist(_kReduce, value);
  }

  void setSimpleMode(bool value) {
    if (value == _simpleMode) return;
    _simpleMode = value;
    notifyListeners();
    _persist(_kSimple, value);
  }

  void setSubtitles(bool value) {
    if (value == _subtitles) return;
    _subtitles = value;
    notifyListeners();
    _persist(_kSubtitles, value);
  }

  Future<void> _persistDouble(String key, double value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(key, value);
    } catch (errore) {
      // Nessuna persistenza disponibile, per esempio in una prova
      // senza finto: la preferenza resta in memoria e la sessione
      // continua, che e' il patto dichiarato in cima a questo file.
      debugPrint('Preferenza $key non salvata: $errore');
    }
  }

  Future<void> _persist(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (_) {
      // Best effort: un errore di scrittura non deve rompere l'app.
    }
  }
}
