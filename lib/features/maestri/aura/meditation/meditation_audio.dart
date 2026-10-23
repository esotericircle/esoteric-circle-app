import 'tone_generator.dart';

import '../../../../core/sensi/motore_audio.dart';

/// I preset sonori della meditazione di Aura, generati via codice.
///
/// Fondamento onesto: le frequenze Solfeggio e il 432 sono tradizione culturale
/// e cornice di benessere, non un fatto medico. Il battito binaurale nasce dalla
/// differenza fra i due canali e va ascoltato con le cuffie.
enum MeditationPreset {
  calm432(
    id: 'calm432',
    label: '432 Hz',
    subtitle: 'La corda calma',
    leftHz: 432,
    rightHz: 432,
    binaural: false,
  ),
  // **IL 528 C'ERA GIA', ed e' il terzo centro.** Non si duplica: si dichiara
  // a quale centro appartiene, cosi' l'elenco resta uno solo.
  green528(
    id: 'green528',
    label: '528 Hz',
    subtitle: 'Il fuoco',
    leftHz: 528,
    rightHz: 528,
    binaural: false,
    centro: 2,
  ),
  thetaBeat(
    id: 'theta',
    label: 'Battito theta',
    subtitle: 'Onde lente',
    leftHz: 210,
    rightHz: 217,
    binaural: true,
  ),
  // **LE SETTE DEI CENTRI, ordine DD voce 12, 10 settembre 2026.**
  //
  // **Non mancavano per un file audio assente**, ed e' la prima cosa che
  // l'ordine chiede di dichiarare: qui non ci sono file, i toni li **sintetizza**
  // `ToneGenerator` campione per campione. Mancavano perche' nessuno le aveva
  // scritte in questo elenco, mentre `FrequenzaDelGiorno.hertzPerCentro` le
  // portava tutte e sette da sempre.
  //
  // **E la loro assenza faceva dire una bugia all'app.** La schermata scriveva
  // *"la tradizione gli accosta i 639 hertz, e' la frequenza di questa
  // sessione"* e poi suonava i 432 di `calm432`, perche' era l'unico preset di
  // partenza possibile. **Il numero scritto e il numero suonato erano due.**
  radice396(
    id: 'radice396',
    label: '396 Hz',
    subtitle: 'La radice',
    leftHz: 396,
    rightHz: 396,
    binaural: false,
    centro: 0,
  ),
  sacro417(
    id: 'sacro417',
    label: '417 Hz',
    subtitle: 'Il sacro',
    leftHz: 417,
    rightHz: 417,
    binaural: false,
    centro: 1,
  ),
  cuore639(
    id: 'cuore639',
    label: '639 Hz',
    subtitle: 'Il cuore',
    leftHz: 639,
    rightHz: 639,
    binaural: false,
    centro: 3,
  ),
  gola741(
    id: 'gola741',
    label: '741 Hz',
    subtitle: 'La gola',
    leftHz: 741,
    rightHz: 741,
    binaural: false,
    centro: 4,
  ),
  terzoOcchio852(
    id: 'terzoocchio852',
    label: '852 Hz',
    subtitle: 'Il terzo occhio',
    leftHz: 852,
    rightHz: 852,
    binaural: false,
    centro: 5,
  ),
  corona963(
    id: 'corona963',
    label: '963 Hz',
    subtitle: 'La corona',
    leftHz: 963,
    rightHz: 963,
    binaural: false,
    centro: 6,
  );

  const MeditationPreset({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.leftHz,
    required this.rightHz,
    required this.binaural,
    this.centro,
  });

  /// **L'INDICE DEL CENTRO A CUI QUESTA FREQUENZA APPARTIENE**, oppure nulla.
  ///
  /// Nulla per il 432, che e' un'accordatura e non un centro, e per il battito
  /// theta, che e' un battito e non una nota. Serve a una cosa sola e
  /// importante: **far suonare alla sessione la frequenza che la schermata
  /// dichiara**.
  final int? centro;

  /// La frequenza del centro [indice], oppure nulla se nessuna la porta.
  ///
  /// Se un giorno un centro restasse senza la sua frequenza, questa torna
  /// nulla e la schermata ripiega dichiarandolo, invece di suonare un numero
  /// diverso da quello che ha scritto.
  static MeditationPreset? perCentro(int indice) {
    for (final p in MeditationPreset.values) {
      if (p.centro == indice) return p;
    }
    return null;
  }

  final String id;
  final String label;
  final String subtitle;
  final double leftHz;
  final double rightHz;

  /// Vero se e' un battito binaurale, da ascoltare con le cuffie.
  final bool binaural;

  /// Il battito percepito, in Hz: la differenza fra i due canali.
  double get beatHz => (rightHz - leftHz).abs();

  /// La frequenza di riferimento per il visualizzatore (la portante).
  double get baseHz => (leftHz + rightHz) / 2;
}

/// Confine astratto verso la riproduzione del tono sul canale audio del sistema.
///
/// La sintesi dei toni e' reale e vive in `ToneGenerator`; l'uscita sul device,
/// con il plugin audio nativo, e' il passo sul dispositivo (come la chiamata
/// vera a Vertex). Cosi' la schermata resta testabile in headless, dove si usa
/// il lettore silenzioso, senza canali di piattaforma.
abstract interface class TonePlayer {
  Future<void> play(MeditationPreset preset);
  Future<void> stop();
}

/// Il lettore REALE: sintetizza il tono e lo manda al motore audio unico.
///
/// Prima qui c'era solo `SilentTonePlayer`, che generava i byte e li scartava:
/// la Meditazione di Aura prometteva frequenze e battito theta e non emetteva
/// nulla. E' la parte muta della voce P03 del Registro.
///
/// Il motore e' quello condiviso del Cerchio, non uno suo: due motori audio
/// vorrebbero dire due volumi e due modi di fermarsi.
class LettoreToniReale implements TonePlayer {
  LettoreToniReale(
      {MotoreAudio? motore, this.generator = const ToneGenerator()})
      : _motore = motore ?? MotoreAudio.condiviso;

  final MotoreAudio _motore;
  final ToneGenerator generator;

  @override
  Future<void> play(MeditationPreset preset) async {
    // Trenta secondi di tono, riprodotti in ciclo: la sessione dura quanto
    // vuole la persona, non quanto il campione.
    final byte = generator.wav(
      leftHz: preset.leftHz,
      rightHz: preset.rightHz,
      duration: const Duration(seconds: 30),
    );
    await _motore.tono(byte);
  }

  @override
  Future<void> stop() => _motore.fermaTono();
}

/// Lettore silenzioso: non emette suono e non tocca la piattaforma.
///
/// Resta per i test e per le anteprime, dove un suono vero non serve e
/// rallenterebbe soltanto. Genera comunque i byte, cosi' la sintesi e'
/// esercitata davvero.
class SilentTonePlayer implements TonePlayer {
  const SilentTonePlayer({this.generator = const ToneGenerator()});

  final ToneGenerator generator;

  @override
  Future<void> play(MeditationPreset preset) async {
    // Genera un secondo di tono in loop: prova che la sintesi funziona, senza
    // riprodurre nulla qui.
    generator.wav(
      leftHz: preset.leftHz,
      rightHz: preset.rightHz,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  Future<void> stop() async {}
}
