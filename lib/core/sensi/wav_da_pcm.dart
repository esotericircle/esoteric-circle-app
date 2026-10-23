import 'dart:typed_data';

/// **UN WAV DA UN PCM A 16 BIT.** Ordine EJ voci 01 e 02, 24 settembre 2026.
///
/// Serve due volte nel LIVE: per ascoltare le voci candidate, che il server
/// manda come PCM, e per mandare a Gemini la frase registrata dal microfono.
/// L'intestazione e' quella standard di 44 byte.
Uint8List wavDaPcm(Uint8List pcm, {required int tasso, int canali = 1}) {
  const bit = 16;
  final byteAlSecondo = tasso * canali * bit ~/ 8;
  final blocco = canali * bit ~/ 8;
  final testa = ByteData(44)
    ..setUint32(0, 0x52494646) // RIFF
    ..setUint32(4, 36 + pcm.length, Endian.little)
    ..setUint32(8, 0x57415645) // WAVE
    ..setUint32(12, 0x666d7420) // fmt
    ..setUint32(16, 16, Endian.little)
    ..setUint16(20, 1, Endian.little) // PCM
    ..setUint16(22, canali, Endian.little)
    ..setUint32(24, tasso, Endian.little)
    ..setUint32(28, byteAlSecondo, Endian.little)
    ..setUint16(32, blocco, Endian.little)
    ..setUint16(34, bit, Endian.little)
    ..setUint32(36, 0x64617461) // data
    ..setUint32(40, pcm.length, Endian.little);
  return (BytesBuilder(copy: false)
        ..add(testa.buffer.asUint8List())
        ..add(pcm))
      .toBytes();
}
