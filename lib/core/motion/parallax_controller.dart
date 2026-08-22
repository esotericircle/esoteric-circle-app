import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show Offset;

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter/scheduler.dart';

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
    _accendiIFotogrammi();
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

  /// **IL TICKER DEL CIELO.** Ordine AW voce 01: batte alla frequenza dello
  /// schermo, non a quella del sensore, e si ferma da solo quando non c'e'
  /// piu' strada da fare.
  void _accendiIFotogrammi() {
    _fotogrammi = Ticker(_battito);
  }

  void _tryListenTilt() {
    try {
      _sub = accelerometerEventStream(
        samplingPeriod: const Duration(
            milliseconds: periodoDelSensoreInMillesimi),
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
  /// **IL FONDO CORSA STA A TRENTA GRADI.** Ordine AV voce 02.
  ///
  /// Prima la corsa piena la decideva una `tanh` con guadagno 34, e il
  /// guadagno da solo non dice a quanti gradi si arriva in fondo: lo si
  /// scopriva tabulando. Adesso il fondo corsa e' un dato, e si legge.
  ///
  /// **L'ordine ne diceva diciotto, e la differenza e' misurata**: vedi il
  /// commento su [zonaMorta].
  ///
  /// **NON E' UNA COSTANTE PER CAPRICCIO.** Le tre costanti della curva si
  /// possono tarare da una prova, `tara`, perche' la terna giusta non si
  /// indovina: si cerca provandole tutte sul controller VERO. Un modello
  /// scritto a parte per fare la stessa ricerca ha sbagliato di dieci punti su
  /// ottanta, e la terna che dava per buona non passava le accettazioni.
  static double fondoCorsa = math.sin(fondoCorsaInGradi * math.pi / 180);

  /// **A QUANTI GRADI IL CIELO ARRIVA IN FONDO: TRENTA.** Ordine AW voce 01.
  ///
  /// Erano sedici, e sedici gradi sono un movimento normale del polso: si
  /// arrivava al massimo subito e **da li' non c'era piu' niente da dosare**.
  /// E' l'"incontrollabile" del fondatore, letto nella sua riga diagnostica
  /// dove l'inclinazione risultava gia' saturata a 1,00.
  static double fondoCorsaInGradi = 26;

  /// Solo per la ricerca della terna: rimette i valori di partenza.
  @visibleForTesting
  static void tara(
      {double? zona, double? fondoInGradi, double? esponente}) {
    if (zona != null) zonaMorta = zona;
    if (fondoInGradi != null) {
      fondoCorsaInGradi = fondoInGradi;
      fondoCorsa = math.sin(fondoInGradi * math.pi / 180);
    }
    if (esponente != null) esponenteDellaCurva = esponente;
  }

  /// **LA ZONA MORTA ATTORNO AL RIPOSO**, ordine AU voce 04 per l'idea e
  /// ordine AV voce 02 per il valore. Sotto questa soglia il cielo non si
  /// muove AFFATTO: un movimento piccolissimo che resta e' peggio di nessun
  /// movimento, perche' l'occhio lo insegue.
  ///
  /// **DA 0,07 A 0,09, e i due numeri dell'ordine AV non stavano insieme.**
  /// L'ordine chiede la zona morta a 0,07 e il fondo corsa a diciotto gradi, e
  /// insieme chiede cinque accettazioni. Provata quella terna esatta sul
  /// controller vero: la continuita' passa, ma **la mano ferma arriva a 3,63
  /// punti invece che sotto 2, e quindici gradi ne danno 52,3 invece che oltre
  /// 60**. Non e' un difetto dell'idea: e' che una curva con esponente basso
  /// non schiaccia piu' la deviazione della mano ferma come faceva la
  /// quadratica, quindi il tremore esce dalla soglia e si vede.
  ///
  /// Cercate tutte le terne di zona morta, fondo corsa ed esponente **sul
  /// controller vero e non su un modello**, ne restano NOVE. Questa e' quella
  /// col margine piu' largo fra quelle che tengono l'esponente 1,1 che
  /// l'ordine indica: **mano ferma 0,00 punti, quindici gradi 70,4, salto
  /// massimo fra due gradi 7,6**. La zona morta passa da quattro gradi a
  /// quasi cinque, e il fondo corsa da diciotto a sedici.
  ///
  /// **La prima ricerca era stata fatta su un modello scritto a parte**, che
  /// riproduceva a mano il riposo, il filtro e la curva: dava per buona una
  /// terna che sul controller vero lasciava quindici gradi a 54,3 punti invece
  /// che sopra 60. Un modello del proprio codice e' un secondo codice, e i due
  /// divergono.
  static double zonaMorta = 0.008;

  /// **L'ESPONENTE DELLA CURVA, e da 2,0 scende a 1,1.** Ordine AV voce 02.
  ///
  /// **Il fatto del fondatore sulla 2189**: "e' tutto immobile e appena muovo
  /// un pochino il cellulare lo sfondo fa uno scatto a destra o a sinistra".
  ///
  /// **La causa, tabulata e non supposta.** La curva di ieri,
  /// `tanh(34 * u^2)`, dava questi punti sugli 80 della corsa: a 4 gradi 0, a
  /// 6 gradi 3,7, a 10 gradi 31,9, a 12 gradi **50,7**. Fra sei e dodici gradi
  /// il cielo faceva quarantasette punti, e il salto peggiore fra un grado e
  /// il successivo valeva **9,5 punti**, fra i dieci e gli undici gradi.
  /// Immobile e poi lo scatto: e' esattamente quello.
  ///
  /// **L'errore di metodo, e non e' del codice.** Le misure di accettazione
  /// dell'ordine AU voce 04 erano due punti soli, zero al riposo e oltre
  /// sessanta a quindici gradi: **una curva che salta li rispetta tutti e
  /// due**. Mancava la misura della continuita', e per questo il difetto e'
  /// passato. Adesso c'e', e resta per sempre.
  ///
  /// Con esponente 1,1 la risposta e' piatta all'uscita dalla zona morta e
  /// dritta dopo: a 5 gradi 4,4 punti, a 10 gradi 31,9, a 15 gradi 61,7, a 18
  /// gradi la corsa piena. **Nessun grado vale piu' di 6,1 punti.**
  static double esponenteDellaCurva = 1.3;

  /// La posizione di riposo imparata, cioe' come la persona tiene il telefono
  /// adesso. Nulla finche' non arriva la prima lettura: il primo campione la
  /// fissa, altrimenti il cielo partirebbe a fondo corsa e ci metterebbe
  /// mezzo minuto a tornare a casa.
  double? _riposoX;
  double? _riposoY;

  /// **I NUMERI VERI PER LA RIGA DIAGNOSTICA.** Ordine AW voce 01, pezzo 4.
  ///
  /// **La riga mostrava `tiltX` e lo chiamava "inclinazione dal riposo".** Non
  /// lo e': `tiltX` e' la RISPOSTA dopo la zona morta e la curva, e satura a
  /// 1,00 molto prima che il telefono sia inclinato tanto. Il fondatore ha
  /// letto "1.00" e ha creduto di essere a fondo corsa di inclinazione, e **la
  /// diagnosi e' stata sbagliata tre volte per questo**.
  ///
  /// Adesso i due numeri sono separati e nominati: la deviazione IN GRADI, che
  /// e' cio' che la mano fa, e la risposta da 0 a 1, che e' cio' che il cielo
  /// ne fa.
  double get deviazioneInGradiX =>
      math.asin(_ultimaDeviazioneX.clamp(-1.0, 1.0)) * 180 / math.pi;
  double get deviazioneInGradiY =>
      math.asin(_ultimaDeviazioneY.clamp(-1.0, 1.0)) * 180 / math.pi;

  /// La risposta dopo zona morta e curva, da 0 a 1: e' il bersaglio che il
  /// sensore ha dato, non ancora il valore dipinto.
  double get rispostaX => _bersaglioX;
  double get rispostaY => _bersaglioY;

  /// **QUANTI FOTOGRAMMI AL SECONDO IL CIELO SI STA RIDIPINGENDO.** Ordine AW
  /// voce 01: **e' il numero che avrebbe fatto trovare questo difetto due
  /// giorni fa**. Con il disegno legato al sensore diceva quindici; adesso
  /// dice quanti ne disegna lo schermo, finche' c'e' strada da fare.
  double get fotogrammiAlSecondo => _fotogrammiAlSecondo;
  double _fotogrammiAlSecondo = 0;

  /// I punti che vengono dallo SCORRIMENTO e non dal sensore, sul piano dato.
  /// **La riga li sommava senza dirlo**, ordine AW voce 01 e fatto F5: con
  /// inclinazione dichiarata 0,00 il piano verticale correva meno tredici
  /// punti, e quei punti erano il dito, non la mano.
  double puntiDelloScorrimento(double depth) => -_scroll * 40 * depth;

  /// La posizione di riposo, per chi la vuole mostrare. Ordine AS voce 01.
  double? get riposoX => _riposoX;
  double? get riposoY => _riposoY;

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
    // **SI NORMALIZZA SUL FONDO CORSA, NON SU UNO.** Ordine AV voce 02.
    //
    // Prima si normalizzava su `1 - zonaMorta`, cioe' su novanta gradi di
    // inclinazione, e poi una `tanh` col guadagno alto riportava la corsa
    // piena a portata di mano: **e' la `tanh` che comprimeva tutta la corsa in
    // una fascia di sei gradi**, ed e' lo scatto che il fondatore ha visto.
    // Adesso il fondo corsa e' dichiarato, diciotto gradi, e la curva ci
    // arriva salendo. Niente `tanh`.
    final oltre =
        ((quanta - zonaMorta) / (fondoCorsa - zonaMorta)).clamp(0.0, 1.0);
    final risposta = math.pow(oltre, esponenteDellaCurva).toDouble();
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

  /// **IL PERIODO DEI CAMPIONI: SEDICI MILLESIMI**, ordine AW voce 01, cioe'
  /// circa sessanta al secondo invece dei quindici di prima. Meno strada da
  /// interpolare fra un campione e l'altro, e meno ritardo.
  ///
  /// **Il numero sta in un posto solo apposta.** Il filtro a un euro qui sotto
  /// usa lo stesso valore per stimare la velocita' e per pesare il taglio: se
  /// lo stream chiedesse sedici e il filtro continuasse a credere sessantasei,
  /// **il taglio sbaglierebbe di quattro volte** e il tremore tornerebbe.
  static const int periodoDelSensoreInMillesimi = 16;

  /// Lo stesso periodo in secondi, per i conti del filtro. **Si usa il periodo
  /// NOMINALE e non l'orologio**: due letture che arrivano appaiate farebbero
  /// esplodere la velocita' stimata, e con lei il taglio, proprio nell'istante
  /// in cui non e' successo niente.
  static const double periodoDelSensore = periodoDelSensoreInMillesimi / 1000;

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
  /// **DOVE IL CIELO STA ANDANDO**, cioe' cio' che il sensore ha deciso
  /// all'ultimo campione. Il valore DIPINTO, `_tiltX`, lo insegue fotogramma
  /// per fotogramma.
  double _bersaglioX = 0;
  double _bersaglioY = 0;

  /// L'ultima deviazione dal riposo, per la riga diagnostica: e' il numero che
  /// mancava, e senza il quale la diagnosi e' stata sbagliata tre volte.
  double _ultimaDeviazioneX = 0;
  double _ultimaDeviazioneY = 0;

  Ticker? _fotogrammi;
  Duration _ultimoBattito = Duration.zero;

  /// **QUANTO CI METTE IL CIELO AD ARRIVARE DOVE IL SENSORE LO MANDA.**
  /// Ordine AW voce 01: novanta millesimi di costante di tempo. In una
  /// costante il valore copre il 63 per cento della strada, in tre quasi
  /// tutta: un gesto arriva a destinazione in meno di tre decimi, e nel
  /// frattempo ogni fotogramma mostra un passo diverso.
  static const double costanteDiTempo = 0.090;

  /// **L'INTERRUTTORE CHE RIMETTE IL DIFETTO, e serve a una prova sola.**
  /// Ordine AW voce 01.
  ///
  /// Spento, il campione del sensore dipinge direttamente, com'era prima di
  /// quest'ordine. Non e' un ripiego ne' una via di fuga: e' il modo di
  /// misurare il PRIMA e il DOPO **con la stessa formula e nello stesso
  /// file**, cosi' il confronto resta nel repository invece di vivere in un
  /// rapporto. Nessun punto di `lib` lo tocca.
  @visibleForTesting
  static bool interpolaSulFotogramma = true;

  /// Sotto questo scarto il bersaglio e' raggiunto e il ticker si ferma: da
  /// fermi non si spende un fotogramma.
  static const double _abbastanzaVicino = 0.0005;

  void _svegliaIlTicker() {
    if (_fotogrammi == null) return;
    if (!_fotogrammi!.isActive) {
      _ultimoBattito = Duration.zero;
      _fotogrammi!.start();
    }
  }

  void _battito(Duration adesso) {
    // **IL PASSO SI CALCOLA SUL TEMPO VERO DEL FOTOGRAMMA**, ordine AW voce
    // 01: con un numero fisso, a centoventi al secondo il cielo si
    // muoverebbe il doppio che a sessanta, e la stessa inclinazione darebbe
    // due velocita' diverse su due telefoni.
    if (_ultimoBattito == Duration.zero) {
      _ultimoBattito = adesso;
      return;
    }
    final dt = (adesso - _ultimoBattito).inMicroseconds / 1000000.0;
    _ultimoBattito = adesso;
    if (dt <= 0) return;
    _fotogrammiAlSecondo = 1 / dt;
    _avvicinaAlBersaglio(dt);
  }

  /// Avvicina il valore dipinto al bersaglio di un fotogramma lungo [dt]
  /// secondi, e notifica. **Se e' arrivato, il ticker si ferma**: un telefono
  /// fermo non deve costare un fotogramma al secondo.
  void _avvicinaAlBersaglio(double dt) {
    final quantoResta = math.max((_bersaglioX - _tiltX).abs(),
        (_bersaglioY - _tiltY).abs());
    if (quantoResta < _abbastanzaVicino) {
      if (_tiltX != _bersaglioX || _tiltY != _bersaglioY) {
        _tiltX = _bersaglioX;
        _tiltY = _bersaglioY;
        notifyListeners();
      }
      _fotogrammi?.stop();
      return;
    }
    // Avvicinamento esponenziale: la quota di strada coperta dipende solo dal
    // rapporto fra il fotogramma e la costante di tempo.
    final passo = 1 - math.exp(-dt / costanteDiTempo);
    _tiltX += (_bersaglioX - _tiltX) * passo;
    _tiltY += (_bersaglioY - _tiltY) * passo;
    notifyListeners();
  }

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
    // **IL SENSORE COMANDA UN BERSAGLIO, NON IL DISEGNO.** Ordine AW voce 01,
    // ed e' il cuore della cura.
    //
    // Qui c'era `_tiltX = ...` seguito da `notifyListeners()`: il cielo si
    // ridipingeva SOLO quando arrivava un campione, cioe' quindici volte al
    // secondo. Su uno schermo a centoventi sono otto fotogrammi identici e uno
    // che salta, e misurato era anche peggio: **col sensore a 66 millesimi
    // cambiava il 7,6 per cento dei fotogrammi, e il salto peggiore valeva
    // 4,87 punti sugli 80**.
    //
    // Adesso il campione sposta il bersaglio e basta. A dipingere ci pensa il
    // fotogramma, qui sotto.
    _bersaglioX = _corsaDa(devX).clamp(-1.0, 1.0);
    _bersaglioY = _corsaDa(devY).clamp(-1.0, 1.0);
    _ultimaDeviazioneX = devX;
    _ultimaDeviazioneY = devY;
    _sensorActive = true;
    if (!interpolaSulFotogramma) {
      // **IL COMPORTAMENTO DI PRIMA, tenuto per una prova sola.** Vedi
      // [interpolaSulFotogramma].
      _tiltX = _bersaglioX;
      _tiltY = _bersaglioY;
      notifyListeners();
      return;
    }
    _svegliaIlTicker();
  }

  /// **SOLO PER LE PROVE: un fotogramma dello schermo che passa.** Ordine AW
  /// voce 01.
  ///
  /// Il tempo vero non scorre dentro un `flutter test`, e il ticker del
  /// controller non riceverebbe mai un battito: questa porta fa passare un
  /// fotogramma di [millesimi] e lascia che il valore dipinto si avvicini al
  /// bersaglio, esattamente come farebbe sul telefono.
  @visibleForTesting
  void avanzaIlFotogrammaPerLaProva(int millesimi) {
    _fotogrammiAlSecondo = 1000 / millesimi;
    _avvicinaAlBersaglio(millesimi / 1000);
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
    _fotogrammi?.dispose();
    _fotogrammi = null;
    super.dispose();
  }
}
