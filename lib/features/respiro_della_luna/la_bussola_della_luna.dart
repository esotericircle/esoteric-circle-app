/// LA BUSSOLA DELLA LUNA, ordine FX voce FX.06, 16 ottobre 2026.
///
/// "Alzi il telefono e una scia d'argento ti guida verso la Luna nel cielo
/// vero. Se è sopra l'orizzonte: Esci, è lì." (la proposta approvata).
///
/// **Come punta.** Il quadrante resta fermo a schermo; l'ago e la scia
/// (asset dipinti, mai un pennello scritto a mano o un cerchio finto)
/// ruotano con lo scarto fra l'azimut che il telefono guarda adesso e
/// l'azimut vero della Luna, letto con lo stesso schema del Real Time Cosmo
/// (`OrientamentoDelTelefono`, ordine FG parte 2 voce 2.9): la gravità dice
/// l'alto, il magnetometro il nord, il prodotto vettoriale l'est. A scarto
/// zero l'ago resta come l'asset lo disegna, "a riposo" verso l'alto dello
/// schermo; uno scarto positivo (la Luna sta in senso orario, verso est, da
/// dove punta il telefono) ruota l'ago in senso orario, perché in Flutter un
/// angolo positivo passato a `Transform.rotate` ruota il figlio in senso
/// orario sullo schermo (gli assi hanno la y verso il basso): è la stessa
/// direzione in cui la persona deve girare il telefono per raggiungerla.
///
/// **La soglia, dichiarata.** Sotto [kSogliaDellaBussola] gradi di
/// separazione angolare VERA (non solo di azimut: anche l'altezza entra,
/// con la stessa formula sferica di `Celestial.equatorialToHorizontal`) il
/// telefono "punta la Luna": una vibrazione breve (lo schema conferma della
/// palette sensoriale, `lib/core/sensi/palette_sensoriale.dart`) e la
/// fotografia vera della Luna di oggi (`LeLuneDellaNasa`) prende il posto
/// dell'ago al centro del quadrante. Dodici gradi stanno nella forchetta
/// 10-15 che la voce propone: il magnetometro grezzo di un telefono (senza
/// la taratura di sistema del vettore di rotazione fuso, vedi il commento
/// sopra `OrientamentoDelTelefono`) sbaglia facilmente di qualche grado, e
/// una soglia più stretta avrebbe fatto sfarfallare l'incontro fra l'ago e
/// la Luna vera.
///
/// **Il ripiego, mai di serie B** (regola del progetto: ogni esperienza su
/// sensore ha un gesto che la sostituisce). Senza bussola, o senza una
/// lettura per più di due secondi, il quadrante lascia il posto a una riga
/// di parole: dove sta la Luna adesso (uno degli otto punti cardinali) e a
/// che altezza, con l'invito a muovere il telefono descrivendo un otto se
/// la lettura sembra instabile (la taratura vera la fa il sistema operativo,
/// non questa app).
///
/// **Chi dice quando sorge.** La riga "quando sorge", mostrata quando la
/// Luna è sotto l'orizzonte, chiama `prossimoSorgere` da
/// `lib/core/lunario/il_sorgere_della_luna.dart` (ordine FX voce 2): la
/// soglia di Meeus 15.1 con la parallasse vera della Luna, verificata al
/// minuto contro effemeridi pubblicate, non la soglia generica del Real
/// Time Cosmo (pensata per le stelle, non per un corpo vicino come la
/// Luna). Non si duplica qui: si chiama.
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/astro/celestial.dart';
import '../../core/astro/luogo_attuale.dart';
import '../../core/astro/real_time_cosmo/la_camera_del_cielo.dart';
import '../../core/lunario/il_sorgere_della_luna.dart';
import '../../core/lunario/la_posizione_orizzontale_della_luna.dart';
import '../../core/sensi/palette_sensoriale.dart';
import '../../core/lunario/le_lune_della_nasa.dart';
import '../../core/motion/l_orientamento_del_telefono.dart';
import '../../core/motion/parallax_controller.dart';

/// Sotto questa separazione angolare vera (gradi), il telefono punta la
/// Luna. La scelta e' spiegata nel commento sopra la classe.
const double kSogliaDellaBussola = 12.0;

/// L'intervallo del sensore, in secondi, e la costante di tempo del filtro
/// di `OrientamentoDelTelefono.passo`: una via di mezzo fissa fra i due
/// estremi del campo di gioco del Real Time Cosmo (fra 0,08 e 0,45), perché
/// qui non esiste uno zoom che la cambi.
const double kDtDellaBussola = 0.06;
const double kCostanteDellaBussola = 0.25;

/// Lo scarto firmato da [daAzimut] a [aAzimut], fra -180 e 180 gradi:
/// positivo se [aAzimut] sta in senso orario (verso est) da [daAzimut].
double scartoAzimutGradi(double daAzimut, double aAzimut) {
  var d = aAzimut - daAzimut;
  d = (d + 540) % 360 - 180;
  return d;
}

/// La separazione angolare vera fra due punti del cielo dati da azimut e
/// altezza, in gradi: la stessa formula sferica di
/// `Celestial.equatorialToHorizontal` (il seno dell'altezza), qui applicata
/// a due punti dell'orizzonte invece che a un punto equatoriale e
/// all'orizzonte del luogo.
double separazioneAngolareGradi(
    double az1, double alt1, double az2, double alt2) {
  final a1 = alt1 * math.pi / 180, a2 = alt2 * math.pi / 180;
  final d = (az1 - az2) * math.pi / 180;
  final cosC =
      math.sin(a1) * math.sin(a2) + math.cos(a1) * math.cos(a2) * math.cos(d);
  return math.acos(cosC.clamp(-1.0, 1.0)) * 180 / math.pi;
}

/// La rotazione dell'ago, in radianti, da uno scarto di azimut in gradi:
/// pura funzione dell'angolo, cosi' la prova la chiama senza montare
/// nessun widget.
double rotazioneAgoRadianti(double scartoAzimutGradi) =>
    scartoAzimutGradi * math.pi / 180;

/// Le otto parole cardinali, a passi di 45 gradi centrati su nord: il
/// ripiego tattile le usa per dire dove sta la Luna senza la bussola.
String direzioneCardinale(double azimutGradi) {
  const parole = [
    'nord',
    'nord-est',
    'est',
    'sud-est',
    'sud',
    'sud-ovest',
    'ovest',
    'nord-ovest',
  ];
  final a = ((azimutGradi % 360) + 360) % 360;
  final i = (((a + 22.5) % 360) / 45).floor();
  return parole[i];
}

/// LA BUSSOLA DELLA LUNA. Il quadrante, l'ago e la scia sono asset (nessun
/// disegno procedurale, vedi il commento sopra il file): questo widget li
/// ruota, li posiziona e li mostra o li scambia col ripiego.
class LaBussolaDellaLuna extends StatefulWidget {
  const LaBussolaDellaLuna({
    super.key,
    required this.luogo,
    this.telefono,
    this.adesso,
    this.vibra,
  });

  /// Dove sta la persona adesso: la chiede e la conserva chi monta questo
  /// widget (`DoveSonoAdesso`), così la bussola resta pura e si prova senza
  /// una posizione vera.
  final LuogoAttuale luogo;

  /// Iniettabile per le prove: senza, se ne costruisce una vera sopra
  /// `sensors_plus`, con la gravità dal `ParallaxController` dell'app (lo
  /// stesso schema del Real Time Cosmo, `cielo_reale_screen.dart`).
  final OrientamentoDelTelefono? telefono;

  /// L'istante di "adesso", iniettabile per le prove: senza, `DateTime.now`.
  final DateTime Function()? adesso;

  /// La vibrazione quando il telefono centra la Luna, iniettabile per le
  /// prove: senza, lo schema `conferma` della palette sensoriale.
  final VoidCallback? vibra;

  @override
  State<LaBussolaDellaLuna> createState() => _LaBussolaDellaLunaState();
}

class _LaBussolaDellaLunaState extends State<LaBussolaDellaLuna> {
  OrientamentoDelTelefono? _telefono;
  Timer? _battitoDelSensore;
  Timer? _battitoDellaLuna;

  /// Quanti battiti di fila il sensore non ha risposto: si conta sui
  /// battiti del timer (gia' virtualizzati nelle prove, `tester.pump`) e
  /// non sull'orologio vero, che in una prova non avanza da solo mentre il
  /// tempo del test sì.
  int _battitiSenzaSensore = 0;

  OrientamentoDellaCamera? _orientamento;
  bool _ripiego = false;
  bool _centrata = false;

  double? _lunaAzimut;
  double? _lunaAltezza;
  double _elongazione = 0;
  String? _testoSorgere;

  @override
  void initState() {
    super.initState();
    final dato = widget.telefono;
    if (dato != null) {
      _telefono = dato;
    } else {
      final p = context.read<ParallaxController?>();
      _telefono = OrientamentoDelTelefono(gravita: () => p?.gravitaGrezza);
    }
    _telefono!.accendi();
    _aggiornaLaLuna();
    _battitoDelSensore = Timer.periodic(
        const Duration(milliseconds: 60), (_) => _passoDelSensore());
    // La posizione della Luna non cambia a vista in pochi secondi: si
    // ricalcola ogni dieci, come il cielo di adesso del Real Time Cosmo
    // (`cielo_reale_screen.dart`, `_fotogrammaNuovo`).
    _battitoDellaLuna =
        Timer.periodic(const Duration(seconds: 10), (_) => _aggiornaLaLuna());
  }

  @override
  void dispose() {
    _battitoDelSensore?.cancel();
    _battitoDellaLuna?.cancel();
    _telefono?.spegni();
    super.dispose();
  }

  DateTime _adesso() => widget.adesso?.call() ?? DateTime.now();

  /// La posizione vera della Luna adesso, e quando sorge se è sotto
  /// l'orizzonte.
  void _aggiornaLaLuna() {
    final adesso = _adesso();
    final jd = Celestial.julianDay(adesso.toUtc());
    // **L'ALTEZZA TOPOCENTRICA, non quella geocentrica nuda.** Ordine FX
    // voce 3: `posizioneOrizzontaleDellaLuna` applica la correzione di
    // parallasse diurna (fino a un grado), verificata contro timeanddate.com
    // in `docs/collaudo/FX/fx03_bussola_regola_a.txt`. La bussola decide "e'
    // sopra o sotto l'orizzonte" su questo numero: usare quello non
    // corretto l'avrebbe sbagliato fino a un grado vicino all'orizzonte,
    // esattamente dove la domanda conta di piu'.
    final hor = posizioneOrizzontaleDellaLuna(
        adesso, widget.luogo.lat, widget.luogo.lon);
    final elong = Celestial.moonIllumination(jd).elongationDeg;
    String? sorgere;
    if (hor.altezzaGradi <= 0) {
      // **IL SORGERE VERO DELLA LUNA, non quello generico del Real Time
      // Cosmo.** `prossimoSorgere` (ordine FX voce 2) usa la soglia di
      // Meeus 15.1 con la parallasse vera della Luna di quel momento,
      // verificata al minuto contro timeanddate.com per tre citta'
      // (`docs/collaudo/FX/fx02_sorgere_regola_a.txt`); `quandoSorgeIlBersaglio`
      // usa invece la soglia fissa delle stelle del Real Time Cosmo, pensata
      // per un corpo qualunque, non per la parallasse vicina della Luna.
      final quando = prossimoSorgere(adesso, widget.luogo.lat, widget.luogo.lon);
      sorgere = quando == null
          ? 'Oggi la Luna non sorge.'
          : 'Sorge alle ${_ora(quando.toLocal())}.';
    }
    if (!mounted) return;
    setState(() {
      _lunaAzimut = hor.azimutGradi;
      _lunaAltezza = hor.altezzaGradi;
      _elongazione = elong;
      _testoSorgere = sorgere;
    });
  }

  void _passoDelSensore() {
    if (!mounted) return;
    final telefono = _telefono;
    final nuovo = telefono?.passo(kDtDellaBussola, kCostanteDellaBussola);
    if (nuovo == null) {
      _battitiSenzaSensore++;
      // Due secondi di grazia, in battiti del timer del sensore: vedi il
      // commento sopra [_battitiSenzaSensore] sul perche' non e' l'orologio
      // vero a contarli.
      if (!_ripiego &&
          _battitiSenzaSensore * kDtDellaBussola > 2.0) {
        setState(() => _ripiego = true);
      }
      return;
    }
    _battitiSenzaSensore = 0;
    final az = _lunaAzimut, alt = _lunaAltezza;
    var centrataAdesso = _centrata;
    if (az != null && alt != null) {
      final separazione = separazioneAngolareGradi(
          nuovo.azimutGradi, nuovo.altezzaGradi, az, alt);
      centrataAdesso = separazione <= kSogliaDellaBussola;
      if (centrataAdesso && !_centrata) {
        (widget.vibra ??
                () => PaletteSensoriale.eseguiSchema(SchemaAptico.conferma))
            .call();
      }
    }
    setState(() {
      _orientamento = nuovo;
      _ripiego = false;
      _centrata = centrataAdesso;
    });
  }

  static String _ora(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  static const String _radice = 'assets/img/respiro_della_luna/bussola/';

  @override
  Widget build(BuildContext context) {
    final orientamento = _orientamento;
    final az = _lunaAzimut, alt = _lunaAltezza;

    Widget contenuto;
    if (_ripiego) {
      contenuto = (az != null && alt != null)
          ? _ripiegoTattile(az, alt)
          : const SizedBox.shrink();
    } else if (orientamento != null && az != null && alt != null) {
      contenuto = _quadrante(orientamento, az, alt);
    } else {
      // Non e' ancora arrivata nemmeno la posizione della Luna (il primo
      // fotogramma, o il sensore si sta ancora scaldando): il quadrante
      // vuoto, senza inventare numeri.
      contenuto = Image.asset('${_radice}quadrante_bussola_v1.webp');
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 260, height: 260, child: contenuto),
        const SizedBox(height: 16),
        if (!_ripiego && az != null && alt != null)
          Text(
            alt > 0 ? 'Esci, è lì.' : (_testoSorgere ?? ''),
            key: const ValueKey('la_bussola_della_luna.riga_principale'),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }

  Widget _quadrante(OrientamentoDellaCamera o, double lunaAz, double lunaAlt) {
    final deltaAz = scartoAzimutGradi(o.azimutGradi, lunaAz);
    final deltaAlt = lunaAlt - o.altezzaGradi;
    final angolo = rotazioneAgoRadianti(deltaAz);
    // La lunghezza della scia: minima quando il telefono e' quasi centrato
    // (la Luna vera prende il suo posto), massima quando la Luna e' lontana
    // da dove punta il telefono adesso. Sessanta gradi di errore combinato
    // (azimut e altezza insieme) bastano a saturarla: oltre, la scia non
    // direbbe di piu'.
    final errore = math.sqrt(deltaAz * deltaAz + deltaAlt * deltaAlt);
    final frazione = (errore / 60).clamp(0.0, 1.0);
    final lunghezzaScia = 0.2 + 0.5 * frazione;
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset('${_radice}quadrante_bussola_v1.webp'),
        if (_centrata)
          Transform.rotate(
            angle: LeLuneDellaNasa.ruotaPer(widget.luogo.lat) ? math.pi : 0,
            child: SizedBox(
              width: 76,
              height: 76,
              child: Image.asset(
                LeLuneDellaNasa.immaginePer(_elongazione) ??
                    '${_radice}quadrante_bussola_v1.webp',
              ),
            ),
          )
        else ...[
          Transform.rotate(
            // La scia sale dal centro verso la direzione E l'altezza della
            // Luna vera: l'angolo combina lo scarto di azimut (quanto
            // girare) e quello di altezza (quanto inclinare), con la stessa
            // convenzione dell'ago (zero verso l'alto, positivo in senso
            // orario verso est).
            angle: math.atan2(deltaAz, deltaAlt),
            alignment: Alignment.center,
            child: FractionallySizedBox(
              heightFactor: lunghezzaScia,
              alignment: Alignment.bottomCenter,
              child:
                  Image.asset('${_radice}scia_di_luna_v1.webp', fit: BoxFit.contain),
            ),
          ),
          Transform.rotate(
            key: const ValueKey('la_bussola_della_luna.ago'),
            angle: angolo,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 0.5,
              child:
                  Image.asset('${_radice}ago_falce_v1.webp', fit: BoxFit.contain),
            ),
          ),
        ],
      ],
    );
  }

  Widget _ripiegoTattile(double lunaAz, double lunaAlt) {
    final direzione = direzioneCardinale(lunaAz);
    final dove = lunaAlt > 0
        ? 'la Luna sta a $direzione, alta ${lunaAlt.round()} gradi'
        : 'la Luna sta a $direzione, sotto l\'orizzonte';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          'Senza una lettura ferma della bussola: $dove. Se la lettura ti '
          'pare instabile, muovi il telefono descrivendo un otto nell\'aria: '
          'è il sistema che la tara, non questa app.',
          key: const ValueKey('la_bussola_della_luna.ripiego'),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
