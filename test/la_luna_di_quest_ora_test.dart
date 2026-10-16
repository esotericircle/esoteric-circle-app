import 'package:esoteric_circle/core/astro/luogo_attuale.dart';
import 'package:esoteric_circle/core/lunario/la_luna_di_quest_ora.dart';
import 'package:esoteric_circle/features/respiro_della_luna/gli_avvisi_del_respiro.dart';
import 'package:flutter_test/flutter_test.dart';

/// I numeri sotto la Luna di quest'ora (ordine FX voce FX.03): composizione
/// di porte già verificate altrove, non un calcolo nuovo. Qui si verifica
/// solo che la composizione sia coerente, non le formule astronomiche (già
/// provate da `test/la_distanza_della_luna_test.dart` e
/// `test/il_sorgere_della_luna_test.dart`).
void main() {
  // **LE DUE SOGLIE DELLA SUPERLUNA SONO LA STESSA FONTE, NON DUE SCELTE.**
  // `la_luna_di_quest_ora.dart` (il dato puro) e `gli_avvisi_del_respiro.dart`
  // (la UI degli avvisi, FX.08) dichiarano la stessa costante di Richard
  // Nolle in due file diversi per non far dipendere il dominio dalla
  // schermata: questa prova cade se un giorno divergono.
  test('la soglia della Superluna è la stessa nei due file che la citano', () {
    expect(sogliaSuperlunaKm, GliAvvisiDelRespiro.sogliaSuperlunaKm);
  });

  test('senza luogo, sorgere, tramonto, culminazione e altezza restano '
      'nulli', () {
    final dati =
        DatiDellaLunaDiQuestOra.calcola(DateTime.utc(2026, 10, 16, 12), null);
    expect(dati.sorgere, isNull);
    expect(dati.tramonto, isNull);
    expect(dati.culminazione, isNull);
    expect(dati.altezzaGradi, isNull);
  });

  test('con un luogo, sorgere, tramonto, culminazione e altezza sono '
      'calcolati', () {
    const piacenza = LuogoAttuale(
        lat: 45.05, lon: 9.69, citta: 'Piacenza', origine: OrigineDelLuogo.scelto);
    final dati = DatiDellaLunaDiQuestOra.calcola(
        DateTime.utc(2026, 10, 16, 12), piacenza);
    expect(dati.sorgere, isNotNull);
    expect(dati.tramonto, isNotNull);
    expect(dati.culminazione, isNotNull);
    expect(dati.altezzaGradi, isNotNull);
    expect(dati.altezzaGradi, inInclusiveRange(-90.0, 90.0));
  });

  test('la percentuale di luce sta sempre fra 0 e 1', () {
    for (var giorno = 0; giorno < 30; giorno++) {
      final dati = DatiDellaLunaDiQuestOra.calcola(
          DateTime.utc(2026, 10, 1).add(Duration(days: giorno)), null);
      expect(dati.percentualeDiLuce, inInclusiveRange(0.0, 1.0));
    }
  });

  test('la prossima Luna piena e la prossima nuova cadono davvero avanti '
      'nel tempo', () {
    final adesso = DateTime.utc(2026, 10, 16, 12);
    final dati = DatiDellaLunaDiQuestOra.calcola(adesso, null);
    expect(dati.prossimaPiena.isAfter(adesso), isTrue);
    expect(dati.prossimaNuova.isAfter(adesso), isTrue);
    // Mai più lontane di una lunazione intera: altrimenti la finestra di
    // ricerca di 36 giorni non le avrebbe trovate (fallback silenzioso su
    // `istante`, il difetto che questa prova prende).
    expect(dati.prossimaPiena.difference(adesso).inDays, lessThan(30));
    expect(dati.prossimaNuova.difference(adesso).inDays, lessThan(30));
  });

  test('la distanza della Luna sta nell\'intervallo fisico vero', () {
    final dati = DatiDellaLunaDiQuestOra.calcola(
        DateTime.utc(2026, 10, 16, 12), null);
    // Perigeo minimo circa 356500 km, apogeo massimo circa 406700 km (vedi
    // il commento di gli_avvisi_del_respiro.dart sulla stessa misura).
    expect(dati.distanzaKm, inInclusiveRange(356000.0, 407000.0));
  });
}
