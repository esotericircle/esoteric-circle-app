import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show Offset;

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Sorgente del moto per la parallasse multistrato.
///
/// Combina due segnali:
/// - lo scorrimento della schermata attiva ([updateScroll]);
/// - una leggera inclinazione del dispositivo letta dall'accelerometro.
///
/// Se il sensore manca o non e' disponibile (device senza accelerometro,
/// permesso negato, anteprima web headless), la parallasse resta guidata dal
/// solo scorrimento e da uno stato statico: nessun blocco, coerente con la
/// regola d'oro dei sensori con fallback tattile o statico.
class ParallaxController extends ChangeNotifier {
  ParallaxController() {
    _tryListenTilt();
  }

  // Inclinazione normalizzata in [-1, 1] su entrambi gli assi, filtrata.
  double _tiltX = 0;
  double _tiltY = 0;

  // Scorrimento normalizzato (0 in cima, cresce scendendo).
  double _scroll = 0;

  StreamSubscription<AccelerometerEvent>? _sub;
  bool _sensorActive = false;

  /// Vero se l'inclinazione dal sensore sta contribuendo al moto.
  bool get sensorActive => _sensorActive;

  double get tiltX => _tiltX;
  double get tiltY => _tiltY;
  double get scroll => _scroll;

  /// Quanto si sposta al massimo il piano di riferimento del cielo quando il
  /// telefono si inclina fino in fondo.
  ///
  /// La misura che conta e' a trenta gradi di inclinazione, dove il tilt
  /// normalizzato vale 0,5 perche' e' la proiezione della gravita': li' il
  /// piano principale deve spostarsi di almeno il dieci per cento della
  /// larghezza dello schermo, 39 px su 390 logici. Con 500 di ampiezza il
  /// piano a profondita' 0,16 fa 40 px a trenta gradi. La storia di questo
  /// numero: 18 all'origine, cioe' 2,88 px a fondo corsa, il "si sposta di due
  /// millimetri" di Mauro; poi 150, cioe' 12 px a trenta gradi, ancora poco.
  static const double tiltRangeDefault = 500;

  /// La profondita' del piano che fa da riferimento, cioe' il campo stellare:
  /// e' quello che l'occhio segue, quindi e' su quello che si misura.
  static const double depthPianoPrincipale = 0.16;

  /// Spostamento massimo da sensore del piano di riferimento, in pixel logici.
  /// E' il numero che l'utente sente in mano.
  static double get spostamentoPianoPrincipale =>
      tiltRangeDefault * profonditaEfficace(depthPianoPrincipale);

  /// Spostamento massimo che il dito puo' dare allo stesso piano: lo
  /// scorrimento satura a tre schermate e pesa quaranta pixel per unita' di
  /// profondita'.
  static double get spostamentoDitoPianoPrincipale =>
      3 * 40 * depthPianoPrincipale;

  /// Comprime la profondita' oltre il piano di riferimento.
  ///
  /// Senza compressione, con l'ampiezza che serve a far muovere davvero il
  /// campo stellare, il piano piu' vicino (profondita' 1,3) volerebbe a
  /// seicentocinquanta pixel a fondo corsa. Oltre il riferimento la scala
  /// cresce di quindici centesimi: il vicino resta piu' mobile del lontano,
  /// che e' il senso della parallasse, cioe' 83 px a trenta gradi contro i 40
  /// del principale e i 15 del lontano, senza uscire di scena.
  static double profonditaEfficace(double depth) {
    if (depth <= depthPianoPrincipale) return depth;
    return depthPianoPrincipale + (depth - depthPianoPrincipale) * 0.15;
  }

  /// Offset di un piano in base alla sua profondita' (0 lontano, 1 vicino).
  /// I piani lontani si muovono poco, quelli vicini di piu'.
  Offset layerOffset(double depth, {double tiltRange = tiltRangeDefault}) {
    final d = profonditaEfficace(depth);
    final dx = _tiltX * tiltRange * d;
    final dy = _tiltY * tiltRange * d - _scroll * 40 * depth;
    return Offset(dx, dy);
  }

  /// Deriva automatica di ripiego, quando il giroscopio non contribuisce: un
  /// moto lento e continuo, cosi' il cosmo resta vivo anche senza sensore. [t]
  /// e' una fase in 0..1 fornita da un'animazione; i piani vicini derivano piu'
  /// di quelli lontani, come per l'inclinazione.
  Offset autoDrift(double depth, double t, {double range = 12}) {
    final a = 2 * math.pi * t;
    final dx = math.cos(a) * range * depth;
    final dy = math.sin(a * 0.7) * range * 0.7 * depth;
    return Offset(dx, dy);
  }

  /// **QUANTO DERIVA IL CIELO QUANDO IL SENSORE NON C'E'. Ordine AR voce 01.**
  ///
  /// La deriva normale vale 12 per la profondita', cioe' 1,9 punti sul piano
  /// di fondo: e' un respiro accanto a un'inclinazione che ne corre 80, e da
  /// sola e' esattamente "il si sposta di due millimetri" che Mauro descrive.
  /// Su un telefono senza accelerometro, o dove lo stream non parte, quella
  /// deriva e' TUTTO cio' che la persona vedra' per sempre.
  ///
  /// Per quel caso la deriva sale a un range di 250 e usa la stessa
  /// profondita' efficace della corsa, cosi' i piani restano in proporzione
  /// fra loro: 40 punti sul fondo (la meta' della corsa satura) e 83 sul
  /// piano vicino. **Non e' il movimento del sensore e non finge di esserlo**:
  /// e' un cielo che vive comunque, e chi lo guarda vede qualcosa muoversi.
  static const double rangeSenzaSensore = 250;

  /// La deriva da usare quando `sensorActive` e' falso.
  Offset derivaSenzaSensore(double depth, double t) {
    final d = profonditaEfficace(depth);
    final a = 2 * math.pi * t;
    final dx = math.cos(a) * rangeSenzaSensore * d;
    final dy = math.sin(a * 0.7) * rangeSenzaSensore * 0.7 * d;
    return Offset(dx, dy);
  }

  /// Aggiornato dallo scorrimento della schermata (pixel).
  void updateScroll(double pixels) {
    // Normalizza su una finestra ampia, con saturazione morbida.
    final next = (pixels / 600).clamp(-1.0, 3.0);
    if ((next - _scroll).abs() < 0.001) return;
    _scroll = next;
    notifyListeners();
  }

  void _tryListenTilt() {
    try {
      _sub = accelerometerEventStream(
        samplingPeriod: const Duration(milliseconds: 66),
      ).listen(
        _onAccel,
        onError: (_) => _sensorActive = false,
        cancelOnError: false,
      );
    } catch (_) {
      // Nessun sensore disponibile: si resta sullo scorrimento.
      _sensorActive = false;
    }
  }

  /// **SOLO PER LE PROVE: il tilt a comando.** La guardia dei bordi
  /// (ordine AJ voce 02) deve rendere il cielo a fondo corsa nelle quattro
  /// direzioni, e i sensori in prova non esistono: questa porta imposta il
  /// tilt saturo senza filtro, come un telefono inclinato fino in fondo.
  @visibleForTesting
  void inclinaPerLaProva(double tiltX, double tiltY) {
    _tiltX = tiltX.clamp(-1.0, 1.0);
    _tiltY = tiltY.clamp(-1.0, 1.0);
    notifyListeners();
  }

  /// **QUANTO IN FRETTA IL RIPOSO INSEGUE LA POSTURA.** Ordine AS voce 01.
  ///
  /// Deve essere abbastanza lento da NON seguire un'inclinazione voluta, che
  /// dura uno o due secondi, e abbastanza svelto da accorgersi che la persona
  /// si e' sdraiata o ha appoggiato il telefono. A 66 millisecondi per
  /// campione, con questo passo in due secondi il riposo si sposta dell'otto
  /// per cento (l'inclinazione resta quasi tutta deviazione) e in mezzo minuto
  /// si sposta del settantacinque per cento (la postura nuova diventa il nuovo
  /// zero).
  static const double passoDelRiposo = 0.003;

  /// **IL GUADAGNO, e il numero viene dal criterio di Mauro.** Ordine AS voce
  /// 01: quindici gradi dal riposo devono dare quasi tutta la corsa, cioe' piu'
  /// di 60 punti sugli 80 del piano di fondo.
  ///
  /// Quindici gradi valgono `sin(15) = 0,2588` di gravita'. Con guadagno 5,
  /// `tanh(0,2588 * 5) = 0,860`, cioe' 68,8 punti a regime. **Il primo numero
  /// provato era 4, e la misura lo ha bocciato**: dava 62 punti a regime ma
  /// 58,4 nel gesto vero, perche' il passa-basso che rende dolce il moto ci
  /// mette una trentina di campioni ad arrivare, e un'inclinazione dura un
  /// secondo. La soglia non si e' abbassata: si e' alzato il guadagno, che e'
  /// la cosa che si stava tarando.
  ///
  /// A novanta gradi la deviazione vale 1 e `tanh(5) = 0,9999`, quindi la
  /// corsa resta 80 e non la supera mai: la saturazione e' MORBIDA, non un
  /// taglio netto, e fra i quindici e i novanta gradi il cielo continua a
  /// rispondere invece di essere gia' finito.
  static const double guadagnoDellInclinazione = 34.0;

  /// **LA ZONA MORTA ATTORNO AL RIPOSO.** Ordine AU voce 04, primo dei tre
  /// pezzi.
  ///
  /// **Il difetto che cura, misurato dal fondatore sulla build 2188**: telefono
  /// tenuto in mano FERMO, e il piano di fondo correva 32,8 punti sugli 80.
  /// Non era un difetto dello zero appreso, che funziona: era che vicino al
  /// riposo la risposta era ripida quanto a meta' corsa, circa 80 punti per
  /// unita' di inclinazione, quindi il tremore della mano muoveva il cielo di
  /// continuo, e con lui i tre Maestri in home.
  ///
  /// Sotto questa soglia il cielo non si muove AFFATTO. Zero, non poco: un
  /// movimento piccolissimo che resta e' peggio di nessun movimento, perche'
  /// l'occhio lo insegue.
  ///
  /// **Il numero e' tarato sulla misura, non scelto.** L'ordine indicava 0,05
  /// come punto di partenza. Dalla riga diagnostica si risale alla deviazione
  /// vera con mano ferma, `atanh(0,41) / 5 = 0,0871`, e con 0,05 la risposta
  /// resterebbe a 1,9 punti, cioe' appena sotto la soglia di accettazione di
  /// 2: troppo poco margine per un numero che viene da una misura sola. Con
  /// 0,07 restano 0,9 punti, e quindici gradi ne danno ancora 70,9.
  static const double zonaMorta = 0.07;

  /// **L'ESPONENTE DELLA CURVA.** Ordine AU voce 04, terzo pezzo: morbida
  /// vicino allo zero, piena verso il fondo corsa.
  ///
  /// Con esponente 1 la risposta e' una retta ripida appena fuori dalla zona
  /// morta, e il cielo salta appena si supera la soglia. Con 2 la curva parte
  /// piatta e si alza dopo: il gesto piccolo resta piccolo, quello grande
  /// arriva in fondo lo stesso.
  ///
  /// **Il guadagno e' salito da 5 a 34, e NON e' un guadagno alzato.** La
  /// deviazione ora entra elevata al quadrato e ridotta della zona morta,
  /// quindi il numero davanti deve crescere perche' la corsa piena resti
  /// raggiungibile: a quindici gradi si passa da 68,8 punti a 70,9. Abbassare
  /// il guadagno, che e' la strada corta, riporterebbe il difetto di due
  /// giorni fa, quando quindici gradi valevano 21 punti sugli 80.
  static const double esponenteDellaCurva = 2.0;

  /// La posizione di riposo imparata, cioe' come la persona tiene il telefono
  /// adesso. Nulla finche' non arriva la prima lettura: il primo campione la
  /// fissa, altrimenti il cielo partirebbe a fondo corsa e ci metterebbe
  /// mezzo minuto a tornare a casa.
  double? _riposoX;
  double? _riposoY;

  /// La posizione di riposo, per chi la vuole mostrare. Ordine AS voce 01.
  double? get riposoX => _riposoX;
  double? get riposoY => _riposoY;

  /// Saturazione morbida: `tanh`, scritta a mano perche' `dart:math` non la
  /// porta. Cresce quasi dritta vicino allo zero e si appiattisce sull'uno.
  static double _morbida(double v) {
    final e2 = math.exp(2 * v);
    return (e2 - 1) / (e2 + 1);
  }

  /// **DALLA DEVIAZIONE ALLA CORSA, con la zona morta e la curva.** Ordine AU
  /// voce 04, pezzi uno e tre insieme perche' sono la stessa funzione.
  ///
  /// Sotto la zona morta: zero secco. Sopra: si toglie la zona morta e si
  /// rinormalizza, cosi' la corsa piena resta raggiungibile invece di essere
  /// accorciata di quanto si e' tolto, poi la curva sale come il quadrato e la
  /// `tanh` la satura dolcemente sull'uno.
  static double _corsaDa(double deviazione) {
    final quanta = deviazione.abs();
    if (quanta <= zonaMorta) return 0.0;
    final oltre = (quanta - zonaMorta) / (1.0 - zonaMorta);
    final risposta = _morbida(
        guadagnoDellInclinazione * math.pow(oltre, esponenteDellaCurva));
    return deviazione.isNegative ? -risposta : risposta;
  }

  /// **IL FILTRO ADATTIVO.** Ordine AU voce 04, secondo pezzo, e l'ordine
  /// spiega bene perche' serve: un passa-basso a coefficiente fisso **o trema
  /// o ritarda, non puo' fare le due cose**. Con alpha 0,12, quello di prima,
  /// il rumore della mano passava quasi intero, e alzando il taglio per
  /// toglierlo il gesto sarebbe arrivato in ritardo.
  ///
  /// Questo e' il filtro a un euro: taglia basso quando la mano e' quasi
  /// ferma, cioe' quando la velocita' angolare e' piccola e tutto cio' che si
  /// vede e' rumore, e taglia alto quando il gesto e' veloce, cioe' quando ogni
  /// millesimo di ritardo si vede. **Il taglio lo decide la velocita'**, ed e'
  /// per questo che il rumore sparisce senza che il gesto rallenti.
  static const double taglioAlRiposo = 0.5;
  static const double taglioPerVelocita = 8.0;
  static const double taglioDellaVelocita = 1.0;

  /// Il periodo dei campioni, quello chiesto allo stream. **Si usa il periodo
  /// nominale e non l'orologio**: due letture che arrivano appaiate farebbero
  /// esplodere la velocita' stimata, e con lei il taglio, proprio nell'istante
  /// in cui non e' successo niente.
  static const double periodoDelSensore = 0.066;

  double? _devFiltrataX, _devFiltrataY, _devPrecedenteX, _devPrecedenteY;
  double _velocitaFiltrataX = 0, _velocitaFiltrataY = 0;

  static double _pesoDelTaglio(double taglio) {
    final tau = 1.0 / (2 * math.pi * taglio);
    return periodoDelSensore / (periodoDelSensore + tau);
  }

  /// Filtra una deviazione sul suo asse e restituisce il valore pulito.
  double _aUnEuro(double grezza, bool asseX) {
    final precedente = asseX ? _devPrecedenteX : _devPrecedenteY;
    final velocitaGrezza =
        precedente == null ? 0.0 : (grezza - precedente) / periodoDelSensore;
    final pesoVelocita = _pesoDelTaglio(taglioDellaVelocita);
    final velocita = asseX
        ? (_velocitaFiltrataX +=
            (velocitaGrezza - _velocitaFiltrataX) * pesoVelocita)
        : (_velocitaFiltrataY +=
            (velocitaGrezza - _velocitaFiltrataY) * pesoVelocita);
    final taglio = taglioAlRiposo + taglioPerVelocita * velocita.abs();
    final peso = _pesoDelTaglio(taglio);
    final vecchia = asseX ? _devFiltrataX : _devFiltrataY;
    final pulita =
        vecchia == null ? grezza : vecchia + (grezza - vecchia) * peso;
    if (asseX) {
      _devFiltrataX = pulita;
      _devPrecedenteX = grezza;
    } else {
      _devFiltrataY = pulita;
      _devPrecedenteY = grezza;
    }
    return pulita;
  }

  /// **DALLA GRAVITA' ALLA DEVIAZIONE.** Ordine AS voce 01, ed e' il cuore
  /// della cura.
  ///
  /// Prima il tilt era la gravita' stessa: `tiltY = e.y / 9.8`. Ma un telefono
  /// tenuto in mano per leggere porta quasi tutta la gravita' sull'asse Y,
  /// quindi `tiltY` valeva 0,98 SEMPRE, cioe' era saturo in permanenza e meta'
  /// della parallasse era morta prima di cominciare. Sull'asse X, invece, la
  /// scala era tarata su novanta gradi: quindici gradi di inclinazione vera
  /// valevano 21 punti sugli 80, ed e' esattamente il "si sposta di pochi
  /// millimetri" che Mauro ha visto.
  ///
  /// Adesso lo zero e' la POSIZIONE DI RIPOSO, cioe' come la persona tiene il
  /// telefono adesso, e il tilt e' quanto se ne discosta. Il cielo sta fermo
  /// quando la mano sta ferma, e si muove quando la mano si muove: e' la sola
  /// cosa che una persona possa collegare al proprio gesto.
  void _onAccel(AccelerometerEvent e) {
    // La gravita' normalizzata su g, senza tagli: qui e' il riferimento da cui
    // si misura, non ancora un valore da mostrare.
    final gx = -e.x / 9.8;
    final gy = e.y / 9.8;

    // Il primo campione FISSA il riposo. Senza questo il riposo partirebbe da
    // zero, la deviazione varrebbe tutta la gravita' e il cielo si aprirebbe a
    // fondo corsa per i primi secondi di ogni avvio.
    _riposoX ??= gx;
    _riposoY ??= gy;
    _riposoX = _riposoX! + (gx - _riposoX!) * passoDelRiposo;
    _riposoY = _riposoY! + (gy - _riposoY!) * passoDelRiposo;

    // **PRIMA SI PULISCE, POI SI DECIDE.** Il filtro lavora sulla deviazione
    // grezza e non sul risultato: cosi' il rumore non entra nella curva, e la
    // zona morta giudica un numero che non trema gia' piu'.
    final devX = _aUnEuro(gx - _riposoX!, true);
    final devY = _aUnEuro(gy - _riposoY!, false);
    // **NIENTE SECONDO PASSA-BASSO.** Quello fisso di prima, alpha 0,12, era
    // l'unico smorzamento e per questo doveva essere lento; adesso il filtro
    // adattivo ha gia' fatto il suo, e tenerne un altro dietro vorrebbe dire
    // rimettere il ritardo che si e' appena tolto.
    _tiltX = _corsaDa(devX).clamp(-1.0, 1.0);
    _tiltY = _corsaDa(devY).clamp(-1.0, 1.0);
    _sensorActive = true;
    notifyListeners();
  }

  /// **SOLO PER LE PROVE: una lettura del sensore, come arriverebbe.** Ordine
  /// AS voce 01. `inclinaPerLaProva` scavalca tutto e impone il tilt: serve a
  /// misurare la corsa dei piani, non la formula. Questa invece entra dalla
  /// stessa porta del sensore vero, cosi' una prova puo' simulare una
  /// sequenza di letture, imparare il riposo e poi inclinare.
  @visibleForTesting
  void leggiDalSensorePerLaProva(double x, double y, double z) =>
      _onAccel(AccelerometerEvent(x, y, z, DateTime.now()));

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
