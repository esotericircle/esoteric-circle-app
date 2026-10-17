import 'il_segno_dell_animale.dart';

/// **LA SEQUENZA DI PEZZI DA FAR GIRARE, PURA.** Ordine FZ voce FZ.05, 17
/// ottobre 2026. *"I tre gesti del segno (`il_segno_dell_animale.dart`)
/// diventano tre pezzi del video e non più zoom dell'illustrazione: si
/// avvicina, "la risposta è sì": arrivo e centro, poi resta sulla posa; si
/// volta, "guarda meglio": il solo centro, dalla posa alla posa; si
/// allontana, "la risposta è no": dalla posa, l'uscita."*
///
/// **L'USCITA PUO' NON RESTARE IN POSA**: dove il file dei tagli porta
/// `fine_uscita` (Tartaruga, Gufo, Falco, Aquila, Corvo), l'uscita non si
/// ferma sulla sua posa finale, ma dissolve nella scena vuota (il manifesto
/// dei video dell'ordine FZ voce FZ.06 dice quale, terra o uccelli). Pura:
/// nessun file, nessun video, nessun `Timer` qui.
enum PezzoDelCammino { arrivo, centro, uscita }

/// Cosa fare quando la sequenza finisce di girare.
enum EsitoDelCammino {
  /// Resta fermo sull'ultimo fotogramma, cioe' la posa.
  restaInPosa,

  /// Dissolve, con la sua durata, nella scena vuota condivisa.
  dissolveNellaScenaVuota,
}

/// La sequenza intera: i pezzi in ordine e cosa fare alla fine.
class LaSequenzaDelCammino {
  const LaSequenzaDelCammino(this.pezzi, this.esito);

  final List<PezzoDelCammino> pezzi;
  final EsitoDelCammino esito;

  /// **ALLA RIVELAZIONE**, quando l'ultimo pezzo della carta cade: *"parte il
  /// centro, dal fotogramma della posa, col verso; poi resta sulla posa."*
  static const rivelazione =
      LaSequenzaDelCammino([PezzoDelCammino.centro], EsitoDelCammino.restaInPosa);

  /// **LA SEQUENZA PER UN GESTO DEL SEGNO.** [haFineUscita] viene dal
  /// manifesto dei video di quell'animale (ordine FZ voce FZ.06): vero per
  /// Tartaruga, Gufo, Falco, Aquila, Corvo.
  static LaSequenzaDelCammino perIlGesto(GestoDelSegno gesto,
      {required bool haFineUscita}) {
    switch (gesto) {
      case GestoDelSegno.siAvvicina:
        return const LaSequenzaDelCammino(
            [PezzoDelCammino.arrivo, PezzoDelCammino.centro],
            EsitoDelCammino.restaInPosa);
      case GestoDelSegno.siVolta:
        return const LaSequenzaDelCammino(
            [PezzoDelCammino.centro], EsitoDelCammino.restaInPosa);
      case GestoDelSegno.siAllontana:
        return LaSequenzaDelCammino(
            [PezzoDelCammino.uscita],
            haFineUscita
                ? EsitoDelCammino.dissolveNellaScenaVuota
                : EsitoDelCammino.restaInPosa);
    }
  }
}
