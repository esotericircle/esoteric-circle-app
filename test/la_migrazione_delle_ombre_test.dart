import 'dart:convert';

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/viaggio/diario_dei_viaggi.dart';
import 'package:esoteric_circle/core/viaggio/l_animale_di_potere.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **LA MIGRAZIONE UNA TANTUM DI FZ.02.** Ordine FZ voce 02, 17 ottobre 2026.
///
/// **DOMANDA**, le parole del fondatore alla lettera: *"4. Chi ha già
/// concluso il viaggio, te compreso, tiene il suo animale? E chi è a metà
/// riparte."* (risposta "4 si").
///
/// **PROVA**: `lib/core/viaggio/diario_dei_viaggi.dart`,
/// `DiarioDeiViaggi.completaMigrazioneFZ02`, chiamata da
/// `AnimaleDiPotere.migraSeServe`/`caricaERisolvi`.
///
/// **MISURA**: chi aveva gia' concluso (vecchia chiave booleana a vero)
/// tiene l'animale del suo segno, senza avviso; chi era a meta' (qualche
/// discesa, nessuna conclusione) perde l'ombra gia' seguita (torna a zero
/// per il nuovo riconoscimento) e riceve un avviso; chi apre l'app per la
/// prima volta non riceve nessun avviso.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
      'CHI AVEVA GIA\' CONCLUSO (vecchia chiave a vero) tiene l\'animale '
      'del suo segno, senza avviso', () async {
    // Il vecchio sistema, prima dell'ordine FZ: `viaggio.riconosciuto` a
    // vero, quattro discese, nessun nome salvato (quella chiave non
    // esisteva ancora).
    SharedPreferences.setMockInitialValues({
      'viaggio.quante': 4,
      'viaggio.riconosciuto': true,
    });
    final diario = DiarioDeiViaggi();
    // Zodiac.cancer -> Lupo, dalla tabella di curatela che la migrazione
    // legge (vedi guide_animal_derivation.dart).
    final esito = await AnimaleDiPotere.caricaERisolvi(diario, Zodiac.cancer);
    expect(esito.avviso, isNull,
        reason: 'chi aveva gia\' concluso non deve ricevere nessun avviso: '
            'per lui non cambia niente che si veda');
    expect(esito.animale?.name, 'Lupo',
        reason: 'chi aveva gia\' concluso deve tenere l\'animale che vedeva');
    expect(diario.riconosciuto, isTrue);

    // **E RESTA COSI' ANCHE RICARICANDO**: la migrazione e' una tantum, e
    // un secondo carica/risolvi non deve ripetere l'avviso ne' il calcolo.
    final diario2 = DiarioDeiViaggi();
    final esito2 = await AnimaleDiPotere.caricaERisolvi(diario2, Zodiac.cancer);
    expect(esito2.avviso, isNull);
    expect(esito2.animale?.name, 'Lupo');
  });

  test(
      'CHI ERA A META\' (discese fatte, nessuna conclusione) riparte da '
      'capo e riceve l\'avviso', () async {
    // Il vecchio sistema: due discese fatte, non ancora riconosciuto, e le
    // due discese vere nel diario, sempre con l'ombra del segno (Lupo, dal
    // Cancro): sotto il vecchio sistema non c'era scelta, quindi ogni
    // discesa portava lo stesso nome.
    final vecchieDiscese = [
      for (var i = 0; i < 2; i++)
        jsonEncode(UnViaggio(
          quando: DateTime(2026, 10, 10 + i),
          domanda: '',
          temaDellaDomanda: '',
          pezzi: const [],
          animaleSeguito: 'Lupo',
          nitidezza: 1,
        ).toJson()),
    ];
    SharedPreferences.setMockInitialValues({
      'viaggio.quante': 2,
      'viaggio.diario': vecchieDiscese,
    });
    final diario = DiarioDeiViaggi();
    final esito = await AnimaleDiPotere.caricaERisolvi(diario, Zodiac.cancer);
    expect(esito.avviso, isNotNull,
        reason: 'chi era a meta\' deve ricevere l\'avviso di una riga');
    expect(esito.animale, isNull,
        reason: 'chi era a meta\' non deve tenere nessun animale: riparte '
            'da capo con la regola delle ombre');
    expect(diario.riconosciuto, isFalse);
    // Le vecchie discese non devono contare per il nuovo riconoscimento:
    // sotto il vecchio sistema erano tutte la stessa ombra (quella del
    // segno), e lasciarle contare darebbe un vantaggio di partenza che
    // l'ordine non vuole dare.
    expect(diario.scelteInOrdine.where((s) => s.isNotEmpty), isEmpty,
        reason: 'le discese di prima della migrazione continuano a contare '
            'per il riconoscimento: non e\' un vero "riparte da capo"');

    // **LA PROVA DIRETTA: seguire di nuovo "Lupo" due volte NON basta.** Se
    // le due vecchie discese contassero ancora, due nuove sullo stesso nome
    // farebbero quattro e riconoscerebbero subito: e' esattamente il
    // vantaggio di partenza che l'ordine non vuole dare a chi era a meta'.
    for (var i = 0; i < 2; i++) {
      await diario.segna(UnViaggio(
        quando: DateTime(2026, 10, 17 + i),
        domanda: '',
        temaDellaDomanda: '',
        pezzi: const [],
        animaleSeguito: 'Lupo',
        nitidezza: 1,
      ));
    }
    expect(diario.riconosciuto, isFalse,
        reason: 'due nuove scelte di "Lupo" hanno riconosciuto l\'animale: '
            'le due discese di prima della migrazione stanno ancora '
            'contando');

    // **E NON SI RIPETE L\'AVVISO**: ricaricando di nuovo, la migrazione e'
    // gia' fatta.
    final diario2 = DiarioDeiViaggi();
    final esito2 = await AnimaleDiPotere.caricaERisolvi(diario2, Zodiac.cancer);
    expect(esito2.avviso, isNull,
        reason: 'la migrazione si ripete a ogni apertura, e l\'avviso '
            'torna ogni volta');
  });

  test('CHI APRE L\'APP PER LA PRIMA VOLTA non riceve nessun avviso', () async {
    final diario = DiarioDeiViaggi();
    final esito = await AnimaleDiPotere.caricaERisolvi(diario, Zodiac.cancer);
    expect(esito.avviso, isNull);
    expect(esito.animale, isNull);
  });

  test(
      'DOPO LA MIGRAZIONE "A META\'", LE NUOVE SCELTE PORTANO AL '
      'RICONOSCIMENTO ESATTAMENTE ALLA QUARTA', () async {
    SharedPreferences.setMockInitialValues({'viaggio.quante': 2});
    final diario = DiarioDeiViaggi();
    await AnimaleDiPotere.caricaERisolvi(diario, Zodiac.cancer);
    expect(diario.riconosciuto, isFalse);
    for (var i = 0; i < 3; i++) {
      await diario.segna(UnViaggio(
        quando: DateTime(2026, 10, 17 + i),
        domanda: '',
        temaDellaDomanda: '',
        pezzi: const [],
        animaleSeguito: 'Orso',
        nitidezza: 1,
      ));
      expect(diario.riconosciuto, isFalse,
          reason: 'a ${i + 1} nuove scelte non deve essere ancora '
              'riconosciuto');
    }
    await diario.segna(UnViaggio(
      quando: DateTime(2026, 10, 21),
      domanda: '',
      temaDellaDomanda: '',
      pezzi: const [],
      animaleSeguito: 'Orso',
      nitidezza: 1,
    ));
    expect(diario.riconosciuto, isTrue);
    expect(diario.animaleRiconosciuto, 'Orso');
  });
}
