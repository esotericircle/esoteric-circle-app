import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Annota nel log un errore che NON interrompe l'esperienza.
///
/// E' l'alternativa onesta al catch muto: ci sono guasti che davvero non devono
/// fermare niente, per esempio una preferenza che non si salva, ma "non fermare
/// niente" e' un'altra cosa da "non essere mai esistito". Chi ignora un errore
/// lo dice qui, con la frase che spiega cosa stava facendo, e il tipo
/// dell'eccezione resta leggibile.
///
/// Volutamente NON usa `FlutterError.reportError`: quello in prova fa cadere il
/// test che lo incontra, e un'annotazione non e' un fallimento.
void annotaGuastoInnocuo(String cosa, Object errore, [StackTrace? traccia]) {
  developer.log(
    cosa,
    name: RegistroDeiGuasti.nomeDelLog,
    error: errore,
    stackTrace: traccia,
  );
}

/// Un guasto della voce dei Maestri, con tutto cio' che serve per riconoscerlo
/// senza aprire un debugger: quale operazione si stava chiedendo, che tipo di
/// eccezione e' arrivata, con quale messaggio, e quando.
///
/// E' un dato puro, senza dipendenze da Firebase ne' dalla UI. Esiste perche'
/// per due giri di lavoro la chat ha taciuto senza che nessuno potesse sapere
/// perche': i `catch (_)` trasformavano l'errore vero in una frase gentile, e la
/// frase gentile non si puo' misurare.
@immutable
class GuastoDellaVoce {
  const GuastoDellaVoce({
    required this.operazione,
    required this.tipo,
    required this.messaggio,
    required this.quando,
  });

  /// Quale delle quattro operazioni del provider ha fallito: `reply`,
  /// `consult`, `synthesize` oppure `distill`. Serve a sapere da quale porta
  /// arriva il guasto senza doverlo dedurre.
  final String operazione;

  /// Il nome del tipo dell'eccezione, cioe' il dato che i `catch (_)`
  /// buttavano via. `ServiceApiNotEnabled` e `QuotaExceeded` dicono due cose
  /// opposte, e prima erano la stessa frase a video.
  final String tipo;

  /// Il testo dell'eccezione, per esteso.
  final String messaggio;

  final DateTime quando;

  /// Vero quando il guasto e' l'API di Firebase AI non abilitata sul progetto
  /// Google. E' un caso a se' perche' non si corregge nel codice: si accende
  /// `firebasevertexai.googleapis.com` sul progetto, e da quel momento sparisce
  /// senza che una riga cambi.
  bool get eLApiSpenta =>
      tipo == 'ServiceApiNotEnabled' ||
      messaggio.contains('firebasevertexai.googleapis.com');

  /// Riga compatta per il log e per il pannello di messa a punto.
  String get riga => '$operazione: $tipo, $messaggio';

  @override
  String toString() => riga;
}

/// Il registro dei guasti della voce dei Maestri.
///
/// Una sola istanza vive nei servizi dell'app e la attraversano TUTTE le
/// chiamate all'AI, da qualunque schermata partano: la chat, il Consulta, la
/// sintesi comparativa e il distillato di memoria. Non e' un campo di un
/// controllore ne' una variabile di una schermata, ed e' pubblico apposta:
/// una regola che vive dentro una classe privata e' una regola che nessuna
/// prova puo' raggiungere.
class RegistroDeiGuasti extends ChangeNotifier {
  RegistroDeiGuasti({this.tetto = 20});

  /// Quanti guasti si conservano. Oltre questo numero i piu' vecchi cadono:
  /// serve a leggere cosa e' successo, non a fare da archivio.
  final int tetto;

  final List<GuastoDellaVoce> _guasti = [];

  /// Tutti i guasti conservati, dal piu' recente al piu' vecchio.
  List<GuastoDellaVoce> get guasti => List.unmodifiable(_guasti);

  /// L'ultimo guasto, quello che di solito spiega il silenzio in corso.
  GuastoDellaVoce? get ultimo => _guasti.isEmpty ? null : _guasti.first;

  /// Vero se qualcosa e' andato storto almeno una volta in questa sessione.
  bool get haGuasti => _guasti.isNotEmpty;

  /// Registra un guasto e lo scrive nel log, sempre. Il log e' la seconda
  /// uscita: il registro serve a video, il log serve quando il telefono e'
  /// attaccato al PC.
  void registra({
    required String operazione,
    required Object errore,
    DateTime? quando,
  }) {
    final guasto = GuastoDellaVoce(
      operazione: operazione,
      tipo: errore.runtimeType.toString(),
      messaggio: errore.toString(),
      quando: quando ?? DateTime.now(),
    );
    _guasti.insert(0, guasto);
    while (_guasti.length > tetto) {
      _guasti.removeLast();
    }
    developer.log(
      guasto.riga,
      name: nomeDelLog,
      error: errore,
    );
    notifyListeners();
  }

  /// Il nome sotto cui i guasti compaiono nel log. Un solo nome, cosi' si
  /// filtra da `flutter logs` o da `adb logcat` senza indovinare.
  static const String nomeDelLog = 'esoteric.voce';

  /// Svuota il registro. Serve alle prove e al pannello di messa a punto.
  void pulisci() {
    if (_guasti.isEmpty) return;
    _guasti.clear();
    notifyListeners();
  }
}
