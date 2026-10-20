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
/// nessun file, nessun video, nessun `Timer` qui. Col manifesto v2 del 20
/// ottobre 2026 la `fine_uscita` la portano tutti e dodici: Cavallo, Cervo,
/// Lince, Lupo, Orso, Serpente e Volpe diventavano trasparenti sul sentiero
/// alla fine dell'uscita, e la loro uscita si ferma prima.
///
/// **IL PEZZO "VOLTA", 20 ottobre 2026.** La verifica fotogramma per
/// fotogramma dei dodici animali ha trovato che il "centro" mostra il verso
/// dell'animale e non il voltarsi: il voltarsi c'e' solo nel primo secondo
/// dell'uscita. Il fondatore: *"Certo che devi controllare che il gufo si
/// giri, ma anche gli altri animali devono comportarsi allo stesso modo"*, e
/// la cura scelta, *"Taglio andata e ritorno"*: il pezzo `volta` e' quel
/// primo tratto dell'uscita, dalla posa al punto in cui l'animale ha girato
/// il capo o il corpo, e poi lo stesso tratto al contrario, fino alla posa
/// (`tool/gli_asset_del_viaggio_v2.py`, manifesto v2). Il centro resta per
/// la rivelazione e per "si avvicina", dove il verso e' giusto.
enum PezzoDelCammino { arrivo, centro, volta, uscita }

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
  static const rivelazione = LaSequenzaDelCammino(
      [PezzoDelCammino.centro], EsitoDelCammino.restaInPosa);

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
        // **IL PEZZO VOLTA, NON IL CENTRO**: il centro mostra il verso, e la
        // riga dice "si volta a guardare dietro di sé".
        return const LaSequenzaDelCammino(
            [PezzoDelCammino.volta], EsitoDelCammino.restaInPosa);
      case GestoDelSegno.siAllontana:
        return LaSequenzaDelCammino(
            [PezzoDelCammino.uscita],
            haFineUscita
                ? EsitoDelCammino.dissolveNellaScenaVuota
                : EsitoDelCammino.restaInPosa);
    }
  }
}
