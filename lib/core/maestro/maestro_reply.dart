/// I tre strati testuali della risposta di un Maestro su un tema.
///
/// E' il modello di dominio neutro dell'anatomia del responso: il primo strato,
/// il segno visivo, lo dà la UI; qui vivono il colpo d'occhio, il testo narrato
/// e l'invito. Sta fuori dalla UI e fuori dal confine AI apposta, cosi' lo
/// producono allo stesso modo l'oracolo locale in ripiego e il provider Gemini,
/// senza che l'uno debba conoscere l'altro.
class MaestroReply {
  const MaestroReply({
    required this.glance,
    required this.reading,
    required this.invite,
  });

  /// Sintesi in una riga, il colpo d'occhio.
  final String glance;

  /// Testo narrato nel tono del Maestro, poche righe.
  final String reading;

  /// Invito o domanda sola per il passo successivo.
  final String invite;

  /// Vero se tutti e tre gli strati portano testo: la soglia minima perche' una
  /// risposta valga la pena di essere mostrata. Sotto questa soglia si cade sul
  /// ripiego, mai a video una risposta monca.
  bool get isComplete =>
      glance.trim().isNotEmpty &&
      reading.trim().isNotEmpty &&
      invite.trim().isNotEmpty;
}
