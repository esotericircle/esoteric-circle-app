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
  green528(
    id: 'green528',
    label: '528 Hz',
    subtitle: 'Il tono verde',
    leftHz: 528,
    rightHz: 528,
    binaural: false,
  ),
  thetaBeat(
    id: 'theta',
    label: 'Battito theta',
    subtitle: 'Onde lente',
    leftHz: 210,
    rightHz: 217,
    binaural: true,
  );

  const MeditationPreset({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.leftHz,
    required this.rightHz,
    required this.binaural,
  });

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
  LettoreToniReale({MotoreAudio? motore, this.generator = const ToneGenerator()})
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
