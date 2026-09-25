import 'dart:async';

/// **CIO' CHE UN TURNO CHIEDE E LA FIRMA DI `reply` NON PORTA.** Ordine EN
/// voci 01 e 06, 25 settembre 2026.
///
/// Due cose che il provider deve sapere per comporre l'istruzione giusta, e
/// che fino a quest'ordine non sapeva:
///
/// - **se il turno e' detto nel LIVE**, per chiedere la misura della voce e
///   non quella della chat (voce EN.01, *"bisogna ridurre questa pausa"*);
/// - **quale risposta gia' data non va ripetuta**, quando il Maestro ne ha
///   appena riscritta una uguale (voce EN.06, Medora che restituisce la
///   stessa risposta parola per parola);
/// - **quale risposta non va data**, quando il Maestro ha appena parlato di
///   se' come di un programma (voce EN.06, Calìgo che risponde *"Non ho
///   memoria delle conversazioni precedenti"*).
///
/// **Perche' viaggia nella zona e non nella firma.** `reply` la implementano
/// il provider vero, la voce sorvegliata e quaranta provider finti delle
/// prove: un parametro nuovo nella firma li toccherebbe tutti, per una cosa
/// che interessa a due. La zona di Dart attraversa ogni `await`, e quindi
/// anche la voce sorvegliata che sta in mezzo: chi la legge sono il provider
/// vero e la voce vera dei banchi, chi non la legge risponde come prima.
class LaRichiestaDelTurno {
  const LaRichiestaDelTurno({
    this.nelLive = false,
    this.daNonRipetere,
    this.daProgramma,
  });

  /// Vero quando il turno e' detto nel LIVE.
  final bool nelLive;

  /// La risposta gia' data che il Maestro ha appena ripetuto, da non
  /// ripetere di nuovo; null quando non c'e'.
  final String? daNonRipetere;

  /// La risposta che il Maestro stava per dare parlando di se' come di un
  /// programma, da non dare; null quando non c'e'.
  final String? daProgramma;

  /// La richiesta di un turno qualunque della chat.
  static const LaRichiestaDelTurno normale = LaRichiestaDelTurno();

  static const Symbol _chiave = #laRichiestaDelTurno;

  /// La richiesta del turno in corso, o [normale] fuori da un turno.
  static LaRichiestaDelTurno get corrente =>
      Zone.current[_chiave] as LaRichiestaDelTurno? ?? normale;

  /// Esegue [chiamata] dentro questa richiesta.
  Future<T> per<T>(Future<T> Function() chiamata) =>
      runZoned(chiamata, zoneValues: {_chiave: this});
}
