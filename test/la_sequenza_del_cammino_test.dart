import 'package:esoteric_circle/core/viaggio/il_segno_dell_animale.dart';
import 'package:esoteric_circle/core/viaggio/la_sequenza_del_cammino.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LA SEQUENZA DEI PEZZI, ALLA LETTERA DELL'ORDINE.** Ordine FZ voce
/// FZ.05: *"si avvicina, "la risposta è sì": arrivo e centro, poi resta
/// sulla posa; si volta, "guarda meglio": il solo centro, dalla posa alla
/// posa; si allontana, "la risposta è no": dalla posa, l'uscita."* e *"dove
/// il file dei tagli scrive 'fine_uscita' [...] l'uscita si ferma al
/// fotogramma indicato e l'app chiude con una dissolvenza [...] sulla scena
/// vuota."*
void main() {
  test('si avvicina: arrivo e centro, resta in posa', () {
    final s = LaSequenzaDelCammino.perIlGesto(GestoDelSegno.siAvvicina,
        haFineUscita: false);
    expect(s.pezzi, [PezzoDelCammino.arrivo, PezzoDelCammino.centro]);
    expect(s.esito, EsitoDelCammino.restaInPosa);
  });

  // **DAL 20 OTTOBRE 2026 IL PEZZO VOLTA, NON IL CENTRO**: il centro mostra
  // il verso e non il voltarsi (verifica fotogramma per fotogramma dei
  // dodici animali); la cura del fondatore, "Taglio andata e ritorno".
  test('si volta: il solo pezzo volta, resta in posa', () {
    final s = LaSequenzaDelCammino.perIlGesto(GestoDelSegno.siVolta,
        haFineUscita: false);
    expect(s.pezzi, [PezzoDelCammino.volta]);
    expect(s.esito, EsitoDelCammino.restaInPosa);
  });

  test('si allontana senza fine_uscita: la sola uscita, resta in posa', () {
    final s = LaSequenzaDelCammino.perIlGesto(GestoDelSegno.siAllontana,
        haFineUscita: false);
    expect(s.pezzi, [PezzoDelCammino.uscita]);
    expect(s.esito, EsitoDelCammino.restaInPosa);
  });

  test(
      'si allontana con fine_uscita (Tartaruga, Gufo, Falco, Aquila, Corvo): '
      'la sola uscita, dissolve nella scena vuota', () {
    final s = LaSequenzaDelCammino.perIlGesto(GestoDelSegno.siAllontana,
        haFineUscita: true);
    expect(s.pezzi, [PezzoDelCammino.uscita]);
    expect(s.esito, EsitoDelCammino.dissolveNellaScenaVuota);
  });

  test(
      'la rivelazione: il solo centro, senza stacco dalla posa, resta in '
      'posa, qualunque sia fine_uscita', () {
    expect(LaSequenzaDelCammino.rivelazione.pezzi, [PezzoDelCammino.centro]);
    expect(LaSequenzaDelCammino.rivelazione.esito, EsitoDelCammino.restaInPosa);
  });
}
