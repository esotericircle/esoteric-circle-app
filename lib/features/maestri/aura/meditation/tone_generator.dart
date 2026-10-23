import 'dart:math' as math;
import 'dart:typed_data';

/// Genera i toni della meditazione via codice, senza file audio esterni.
///
/// Sintetizza campioni PCM a 16 bit, stereo, per una frequenza per canale: cosi'
/// un tono puro ha la stessa frequenza a destra e a sinistra, mentre un battito
/// binaurale nasce dalla piccola differenza fra i due canali (la differenza e'
/// il battito percepito, da ascoltare con le cuffie). Un breve dissolvenza in
/// entrata e in uscita evita i clic quando il tono si ripete in loop.
///
/// La riproduzione vera sul canale audio del sistema resta al device, dietro
/// l'astrazione `TonePlayer`: qui si costruisce solo il suono, in modo puro e
/// verificabile.
class ToneGenerator {
  const ToneGenerator({this.sampleRate = 44100});

  final int sampleRate;

  /// Campioni PCM16 stereo interlacciati (L, R, L, R, ...) per due frequenze,
  /// una per canale. L'ampiezza resta morbida, con dissolvenza ai bordi.
  Int16List pcm16Stereo({
    required double leftHz,
    required double rightHz,
    required Duration duration,
    double amplitude = 0.35,
  }) {
    final frames = (sampleRate * duration.inMicroseconds / 1e6).round();
    final out = Int16List(frames * 2);
    final fade = (sampleRate * 0.02).round().clamp(1, frames); // 20 ms
    const maxAmp = 32767.0;
    for (var i = 0; i < frames; i++) {
      final t = i / sampleRate;
      // Dissolvenza in entrata e in uscita, cosi' il loop non fa clic.
      var env = 1.0;
      if (i < fade) env = i / fade;
      if (i > frames - fade) env = (frames - i) / fade;
      final a = amplitude * env * maxAmp;
      out[i * 2] = (a * math.sin(2 * math.pi * leftHz * t)).round();
      out[i * 2 + 1] = (a * math.sin(2 * math.pi * rightHz * t)).round();
    }
    return out;
  }

  /// Avvolge i campioni PCM16 stereo in un contenitore WAV completo, pronto per
  /// essere passato a un lettore sul device. Nessun file su disco: solo byte in
  /// memoria.
  Uint8List wav({
    required double leftHz,
    required double rightHz,
    required Duration duration,
    double amplitude = 0.35,
  }) {
    final pcm = pcm16Stereo(
        leftHz: leftHz,
        rightHz: rightHz,
        duration: duration,
        amplitude: amplitude);
    final pcmBytes = pcm.buffer.asUint8List();
    const channels = 2;
    const bitsPerSample = 16;
    final byteRate = sampleRate * channels * bitsPerSample ~/ 8;
    const blockAlign = channels * bitsPerSample ~/ 8;
    final dataLen = pcmBytes.length;
    final out = BytesBuilder();
    void str(String s) => out.add(s.codeUnits);
    void u32(int v) {
      final b = ByteData(4)..setUint32(0, v, Endian.little);
      out.add(b.buffer.asUint8List());
    }

    void u16(int v) {
      final b = ByteData(2)..setUint16(0, v, Endian.little);
      out.add(b.buffer.asUint8List());
    }

    str('RIFF');
    u32(36 + dataLen);
    str('WAVE');
    str('fmt ');
    u32(16);
    u16(1); // PCM
    u16(channels);
    u32(sampleRate);
    u32(byteRate);
    u16(blockAlign);
    u16(bitsPerSample);
    str('data');
    u32(dataLen);
    out.add(pcmBytes);
    return out.toBytes();
  }
}
