import 'tone_generator.dart';

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

/// Lettore silenzioso, di default: non emette suono e non tocca la piattaforma.
/// Genera comunque i byte del tono, cosi' la generazione e' esercitata davvero;
/// li scarta, in attesa del lettore reale sul device.
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
