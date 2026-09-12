import 'package:esoteric_circle/core/maestro/chakra_del_giorno.dart';
import 'package:esoteric_circle/core/maestro/traccia_del_loto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **IL LOTO SI RIEMPIE COI GIORNI.** Ordine CZ, voce 10.
///
/// **Parole del fondatore**: *"Il centro respirato di piu' e' visibile, quello
/// mai respirato resta spento: chi guarda il proprio fiore vede da solo di
/// avere lavorato sette volte sulla gola e mai sul cuore. E' il richiamo a
/// tornare, e non ha bisogno di una notifica per funzionare."*
///
/// **REGOLA H.** Non basta provare che una goccia si aggiunge: si prova anche
/// che **i centri mai respirati restino spenti**, perche' e' quella l'assenza
/// che fa da richiamo. Una traccia che accendesse tutto in proporzione
/// perderebbe proprio la cosa che il fondatore ha chiesto.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Il fiore nasce tutto spento', () async {
    SharedPreferences.setMockInitialValues(const {});
    final t = TracciaDelLoto();
    await t.carica();
    expect(t.sessioniInTutto, 0);
    expect(t.quantoEPieno, 0.0);
    expect(t.maiRespirati.length, ChakraDelGiorno.tutti.length,
        reason: 'un fiore appena nato ha gia' ' qualche petalo acceso');
    expect(t.ilPiuRespirato, isNull);
  });

  test('Una sessione lascia la goccia sul centro DI QUEL GIORNO', () async {
    SharedPreferences.setMockInitialValues(const {});
    final t = TracciaDelLoto();
    await t.carica();
    // Un martedi': il centro e' il secondo della lista.
    final giorno = DateTime(2026, 9, 8);
    final atteso = ChakraDelGiorno.di(giorno);
    await t.unaGoccia(quando: giorno);
    expect(t.goccePer(atteso), 1,
        reason: 'la goccia non e\' finita sul centro del giorno');
    expect(t.sessioniInTutto, 1);
  });

  test('REGOLA H: gli altri sei restano SPENTI, ed e\' il richiamo', () async {
    SharedPreferences.setMockInitialValues(const {});
    final t = TracciaDelLoto();
    await t.carica();
    final giorno = DateTime(2026, 9, 8);
    final acceso = ChakraDelGiorno.di(giorno);
    // Sette sessioni tutte sullo stesso giorno della settimana: e' il caso
    // esatto che il fondatore descrive, sette volte sulla gola e mai sul
    // cuore.
    for (var s = 0; s < 7; s++) {
      await t.unaGoccia(quando: giorno);
    }
    expect(t.goccePer(acceso), 7);
    expect(t.sessioniInTutto, 7);
    expect(t.maiRespirati.length, ChakraDelGiorno.tutti.length - 1,
        reason: 'sette sessioni sullo stesso centro hanno acceso anche gli '
            'altri: il vuoto che fa da richiamo non esiste piu\'');
    expect(t.quantoEPieno, closeTo(1 / 7, 0.001),
        reason: 'il fiore risulta pieno per ${t.quantoEPieno} dopo sette '
            'sessioni su un centro solo: quanto e\' pieno conta i CENTRI, non '
            'le sessioni, ed e\' la differenza fra un richiamo e un punteggio');
    expect(t.ilPiuRespirato?.nome, acceso.nome);
  });

  test('Sette giorni diversi riempiono il fiore per intero', () async {
    SharedPreferences.setMockInitialValues(const {});
    final t = TracciaDelLoto();
    await t.carica();
    for (var g = 0; g < 7; g++) {
      await t.unaGoccia(quando: DateTime(2026, 9, 7).add(Duration(days: g)));
    }
    expect(t.maiRespirati, isEmpty,
        reason: 'dopo una settimana intera restano centri spenti: due giorni '
            'della settimana portano allo stesso centro');
    expect(t.quantoEPieno, 1.0);
  });

  test('La traccia sopravvive alla chiusura dell\'app', () async {
    SharedPreferences.setMockInitialValues(const {});
    final giorno = DateTime(2026, 9, 8);
    final prima = TracciaDelLoto();
    await prima.carica();
    await prima.unaGoccia(quando: giorno);
    await prima.unaGoccia(quando: giorno);

    // Una seconda traccia, come dopo un riavvio.
    final dopo = TracciaDelLoto();
    await dopo.carica();
    expect(dopo.sessioniInTutto, 2,
        reason: 'la traccia non e\' stata riletta: il fiore ripartirebbe '
            'vuoto a ogni apertura, e non crescerebbe mai');
    expect(dopo.goccePer(ChakraDelGiorno.di(giorno)), 2);
  });

  test('REGOLA H: una memoria vuota non accende niente per sbaglio', () async {
    // L'assenza: nessuna goccia inventata quando non c'e' niente da leggere.
    SharedPreferences.setMockInitialValues(const {});
    final t = TracciaDelLoto();
    await t.carica();
    await t.carica();
    expect(t.sessioniInTutto, 0,
        reason: 'caricare due volte ha prodotto ${t.sessioniInTutto} sessioni '
            'dal nulla');
  });
}
