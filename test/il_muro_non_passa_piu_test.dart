import 'dart:io';

import 'package:esoteric_circle/core/face/cancello_della_scansione.dart';
import 'package:esoteric_circle/core/face/face_classifier.dart';
import 'package:esoteric_circle/core/face/soglie_del_rilevamento.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL MURO NON PASSA PIU'.** Ordine CR voce 01, seconda stesura,
/// 6 settembre 2026.
///
/// **Parole del fondatore, dopo aver provato la PRIMA cura sul telefono**:
/// *"dopodiche' ho fatto la foto al muro e mi e' uscito ugualmente il responso
/// con la foto del muro"*, e *"ci sono milioni di app che hanno un
/// riconoscimento serio e professionale, pensa a tutti i servizi finanziari o
/// anche casino online"*.
///
/// **LE DUE RAGIONI PER CUI IL MURO PASSAVA, ed erano diverse dalla prima.**
///
/// UNO, alla fonte. La catena di MediaPipe nasce con l'inseguimento acceso, e
/// dopo il primo aggancio **il rilevatore non gira piu'**: la mesh continua a
/// posare punti dentro la regione dove il volto era stato. Il pacchetto lo
/// documenta: *"Null when the frame was served by landmark tracking, in which
/// case the detector did not run"*. Chi finiva la scansione col proprio viso e
/// poi inquadrava una parete riceveva ancora punti, e il cancello vedeva una
/// lista piena. Curato nel motore, che ora spegne l'inseguimento e pretende
/// due punteggi di confidenza.
///
/// DUE, nel cancello. Guardava l'ultima lettura **senza chiedersi di quando
/// fosse**. E' quello che si prova qui.
void main() {
  FaceContours voltoVero() => const FaceContours(
        volto: [Offset(400, 100), Offset(600, 500), Offset(500, 900)],
        sopraccioSx: [Offset(430, 300)],
        sopraccioDx: [Offset(570, 300)],
        occhioSx: [Offset(440, 350)],
        occhioDx: [Offset(560, 350)],
        nasoPonte: [Offset(500, 400)],
        nasoBase: [Offset(500, 520)],
        labbroSopra: [Offset(500, 640)],
        labbroSotto: [Offset(500, 700)],
        guanciaSx: Offset(420, 500),
        guanciaDx: Offset(580, 500),
      );

  test('senza nessuna lettura non si passa', () {
    final esito = CancelloDellaScansione.giudica(
        contorniVivi: null, eta: null);
    expect(esito, isA<NessunVolto>(),
        reason: 'senza nessun volto rilevato nasce comunque una lettura');
  });

  test('una lettura appena fatta passa', () {
    final esito = CancelloDellaScansione.giudica(
      contorniVivi: voltoVero(),
      eta: Duration.zero,
    );
    expect(esito, isA<VoltoTrovato>(),
        reason: 'un volto rilevato in questo istante viene rifiutato: allora '
            'il cancello non lascia passare nemmeno chi ha il viso davanti');
  });

  test('una lettura VECCHIA non passa, ed e\' il muro del fondatore', () {
    // Il gesto vero: la scansione si compie col proprio viso, poi il telefono
    // si gira verso una parete, poi si tocca lo scatto. Fra l'ultimo
    // fotogramma con un volto e il tocco passa del tempo.
    final esito = CancelloDellaScansione.giudica(
      contorniVivi: voltoVero(),
      eta: SoglieDelRilevamento.letturaAncoraFresca +
          const Duration(milliseconds: 1),
    );
    expect(esito, isA<NessunVolto>(),
        reason: 'una lettura piu\' vecchia della soglia viene ancora '
            'accettata: e\' il ricordo di un volto, non un volto, ed e\' '
            'esattamente cio\' che ha fatto uscire un responso da una foto '
            'a un muro');
  });

  test('la ragione del rifiuto dice cosa e\' successo davvero', () {
    // **DUE CAUSE DIVERSE MERITANO DUE FRASI DIVERSE.** Mandare chi ha
    // spostato il telefono a cercare piu' luce e' un modo di far sembrare
    // rotta un'app che sta funzionando.
    final maiVisto = CancelloDellaScansione.giudica(
        contorniVivi: null, eta: null) as NessunVolto;
    final perso = CancelloDellaScansione.giudica(
      contorniVivi: voltoVero(),
      eta: const Duration(seconds: 3),
    ) as NessunVolto;
    expect(perso.perche, isNot(equals(maiVisto.perche)),
        reason: 'chi ha perso il volto di vista riceve la stessa frase di chi '
            'non e\' mai stato inquadrato');
    for (final f in [maiVisto.perche, perso.perche]) {
      expect(f, isNot(contains('rrore')),
          reason: 'il rifiuto parla di errore: non e\' un guasto. Chi '
              'legge deve capire cosa fare');
      expect(f.length, greaterThan(20),
          reason: 'il rifiuto non dice abbastanza per essere utile');
    }
  });

  group('il motore non si fida piu di una lista non vuota', () {
    // **QUESTE PRETESE GUARDANO IL SORGENTE, e va detto perche'.** Il motore
    // vero vuole una fotocamera e i modelli nativi, che in prova non
    // esistono: qui si verifica che le tre difese siano DICHIARATE nel
    // codice del motore. E' una guardia piu' debole delle altre, e non
    // pretende di essere altro: la prova vera e' il telefono.
    final motore =
        File('lib/core/face/motore_mediapipe.dart').readAsStringSync();

    test('l\'inseguimento del volto e\' spento', () {
      expect(motore, contains('enableLandmarkTracking: false'),
          reason: 'l\'inseguimento e\' acceso: dopo il primo aggancio il '
              'rilevatore smette di girare, e davanti a un muro arrivano '
              'ancora punti');
    });

    test('il punteggio del rilevatore viene preteso', () {
      // **SI CERCA IL CONFRONTO, non il nome della soglia.** Il nome compare
      // anche dove il rilevatore viene costruito, quindi cercarlo e basta
      // restava verde anche togliendo il controllo: colto dalla Regola A.
      expect(motore, contains('rilevato.score <'),
          reason: 'il punteggio del rilevamento non viene MAI '
              'confrontato con la soglia: il nome della soglia compare '
              'solo dove il rilevatore viene costruito');
      expect(motore, contains('esito.selectedDetection'),
          reason: 'il motore non guarda nemmeno se il rilevatore ha scelto '
              'una faccia in questo fotogramma');
    });

    test('il punteggio della mesh viene preteso', () {
      expect(motore, contains('SoglieDelRilevamento.confidenzaDellaMesh'),
          reason: 'nessuna soglia sul punteggio della mesh: un volto troppo '
              'storto o troppo al buio verrebbe misurato lo stesso');
    });
  });

  test('le soglie sono severe quanto dichiarato', () {
    // Le soglie sono il cuore di questa cura: se qualcuno le abbassasse per
    // far passare una prova, questa guardia lo direbbe.
    expect(SoglieDelRilevamento.confidenzaDelRilevatore, greaterThanOrEqualTo(0.7),
        reason: 'la confidenza del rilevatore e\' scesa sotto il severo');
    expect(SoglieDelRilevamento.confidenzaDellaMesh, greaterThanOrEqualTo(0.5),
        reason: 'la confidenza della mesh e\' scesa sotto il severo');
    expect(SoglieDelRilevamento.letturaAncoraFresca,
        lessThanOrEqualTo(const Duration(milliseconds: 600)),
        reason: 'la finestra della freschezza si e\' allargata: piu\' e\' '
            'larga, piu\' tempo c\'e\' per spostare il telefono su un muro');
  });
}
