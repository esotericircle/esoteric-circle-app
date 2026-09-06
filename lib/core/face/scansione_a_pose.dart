import 'soglie_della_scansione.dart';

/// **LA SCANSIONE GUIDATA A QUATTRO POSE.** Ordine CR voce 03, 6 settembre
/// 2026.
///
/// **Parole del fondatore**: *"voglio una funzionalita' iper professionale con
/// la rilevazione reale del volto, con la richiesta di girare il volto a
/// destra, sinistra in alto e in basso mentre un fascio di luce fa la
/// scansione"*.
///
/// **QUATTRO POSE, E UN AGGANCIO CHE VIENE PRIMA.** L'ordine dice *"quattro
/// momenti"* e poi ne elenca cinque: *"di fronte, verso destra, verso
/// sinistra, in alto e in basso"*. I due conti tornano leggendoli cosi', ed e'
/// anche l'unico modo in cui la sequenza ha senso: **il fronte non e' una posa
/// da compiere, e' l'aggancio** che dice alla macchina di aver trovato la
/// testa e da cui si misurano tutte le altre. Le pose vere sono quattro, e
/// sono quelle che chiedono un movimento.
///
/// **PERCHE' E' UNA PORTA PURA E NON UN `if` DENTRO LA SCHERMATA.** Una
/// macchina a stati che vive dentro un widget si prova solo montando una
/// fotocamera, che nelle prove non esiste: la regola resterebbe scritta e mai
/// misurata. Qui entrano numeri e tempo, esce uno stato, e uno stato si
/// interroga. E' la stessa ragione di `CancelloDellaScansione`.
///
/// **NON SI SALTA AVANTI.** L'ordine e' esplicito: *"se la persona non riesce,
/// la funzione lo dice e ricomincia da quella posa, non salta avanti"*. Qui
/// quella regola e' strutturale e non una raccomandazione: [avanza] passa alla
/// posa successiva solo quando la corrente e' stata tenuta per intero, e
/// perdere l'angolo azzera la tenuta di quella posa e di nessun'altra.
class ScansioneAPose {
  ScansioneAPose({this.soglie = const _SoglieVive()});

  /// Le soglie in vigore. Si passano invece di leggerle da una costante
  /// globale perche' **la taratura di domani deve poter entrare da qui**, e
  /// perche' una prova ha bisogno di soglie sue per non dipendere da valori
  /// che cambiano sotto di lei.
  final SoglieInUso soglie;

  /// Le quattro pose, nell'ordine in cui si chiedono. Destra e sinistra prima
  /// perche' la rotazione del collo e' piu' facile della flessione, e chi
  /// comincia con un gesto che riesce continua.
  static const List<Posa> ordine = [
    Posa.destra,
    Posa.sinistra,
    Posa.alto,
    Posa.basso,
  ];

  int _quale = 0;
  Duration _tenuta = Duration.zero;
  bool _agganciato = false;

  /// La posa che si sta chiedendo adesso, o nulla se sono finite.
  Posa? get posaCorrente => _quale < ordine.length ? ordine[_quale] : null;

  /// Quante pose sono state compiute per intero.
  int get compiute => _quale;

  /// Vero quando la testa e' stata trovata dritta almeno una volta: prima di
  /// questo non si chiede nessun movimento, perche' chiedere di girarsi a chi
  /// non e' ancora inquadrato e' chiedere al buio.
  bool get agganciato => _agganciato;

  /// Vero quando tutte e quattro le pose sono state compiute.
  bool get compiuta => _quale >= ordine.length;

  /// Quanto manca alla posa corrente, da zero a uno. Serve alla scena per
  /// mostrare che il tempo sta passando invece di lasciare la persona ferma
  /// davanti a una richiesta muta.
  double get progresso {
    final tenutaRichiesta = soglie.tenuta.inMicroseconds;
    if (tenutaRichiesta <= 0) return 1;
    final q = _tenuta.inMicroseconds / tenutaRichiesta;
    return q < 0 ? 0 : (q > 1 ? 1 : q);
  }

  /// Un fotogramma: gli angoli della testa e quanto tempo e' passato.
  ///
  /// [yaw] positivo vuol dire testa girata a destra di chi guarda lo schermo,
  /// [pitch] positivo vuol dire mento alzato. Restituisce vero se questo
  /// fotogramma ha COMPIUTO la posa corrente.
  bool passo({
    required double yaw,
    required double pitch,
    required Duration trascorso,
  }) {
    if (compiuta) return false;
    // **L'AGGANCIO VIENE PRIMA DI TUTTO.** Finche' la testa non e' stata
    // vista dritta, nessuna posa comincia: senza questo, una persona che si
    // presenta gia' girata vedrebbe la prima posa compiuta senza aver mosso
    // niente, e la scansione mentirebbe al primo passo.
    if (!_agganciato) {
      if (yaw.abs() <= soglie.tolleranzaDelFronte &&
          pitch.abs() <= soglie.tolleranzaDelFronte) {
        _agganciato = true;
      }
      return false;
    }
    if (_dentro(posaCorrente!, yaw, pitch)) {
      _tenuta += trascorso;
      if (_tenuta >= soglie.tenuta) {
        _quale++;
        _tenuta = Duration.zero;
        return true;
      }
      return false;
    }
    // **PERDERE L'ANGOLO AZZERA, e azzera SOLO questa posa.** Chi esce dalla
    // soglia non torna indietro di una posa: ricomincia a tenere quella che
    // stava tenendo, che e' esattamente cio' che l'ordine chiede.
    _tenuta = Duration.zero;
    return false;
  }

  /// Ricomincia da capo. L'aggancio si perde con tutto il resto: se la
  /// scansione riparte, riparte davvero.
  void ricomincia() {
    _quale = 0;
    _tenuta = Duration.zero;
    _agganciato = false;
  }

  bool _dentro(Posa p, double yaw, double pitch) => switch (p) {
        Posa.destra => yaw >= soglie.gradiDiProfilo,
        Posa.sinistra => yaw <= -soglie.gradiDiProfilo,
        Posa.alto => pitch >= soglie.gradiDiInclinazione,
        Posa.basso => pitch <= -soglie.gradiDiInclinazione,
      };
}

/// Una delle quattro pose che la scansione chiede.
enum Posa {
  destra('Gira lentamente il viso verso destra'),
  sinistra('Adesso verso sinistra'),
  alto('Alza il mento, guarda in alto'),
  basso('Abbassa il mento, guarda in basso');

  const Posa(this.richiesta);

  /// Cosa si legge a schermo quando questa posa e' quella corrente. E' una
  /// richiesta e non un ordine: *gira lentamente*, non *gira*.
  final String richiesta;
}

/// Le soglie che la scansione applica, passate invece che lette da fuori.
abstract class SoglieInUso {
  const SoglieInUso();
  double get gradiDiProfilo;
  double get gradiDiInclinazione;
  double get tolleranzaDelFronte;
  Duration get tenuta;
}

/// Le soglie vere dell'app, quelle provvisorie di `SoglieDellaScansione`.
class _SoglieVive extends SoglieInUso {
  const _SoglieVive();
  @override
  double get gradiDiProfilo => SoglieDellaScansione.gradiDiProfilo;
  @override
  double get gradiDiInclinazione => SoglieDellaScansione.gradiDiInclinazione;
  @override
  double get tolleranzaDelFronte => SoglieDellaScansione.tolleranzaDelFronte;
  @override
  Duration get tenuta => SoglieDellaScansione.tenuta;
}
