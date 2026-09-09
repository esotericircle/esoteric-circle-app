import 'package:esoteric_circle/core/maestro/colore_del_centro.dart';
import 'package:esoteric_circle/features/maestri/aura/meditation/loto_che_respira.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **IL LOTO RIEMPIE LA SCENA, E RESPIRA A ONDA.** Ordine DB voce 04.
///
/// **La prima stesura e' stata respinta dal fondatore**, e l'ordine dice
/// perche': *"Il cerchio che si gonfia esce, ed esce anche qualunque figura
/// piccola circondata da spazio vuoto. Questa voce non lascia margine di
/// interpretazione: sono misure."*
///
/// **Le misure che questa guardia pretende**, tutte scritte nella voce:
/// - al culmine dell'inspiro la corona esterna arriva **almeno
///   all'ottantacinque per cento** della larghezza;
/// - al fondo dell'espiro il fiore **non scende sotto il cinquanta per
///   cento**: si chiude, non sparisce;
/// - **almeno quattro corone**, col numero di petali che cresce;
/// - l'apertura **parte dal cuore e arriva dopo al bordo**, che e' l'onda
///   senza la quale il fiore e' solo una figura che si ingrandisce.
///
/// **REGOLA H.** Non basta provare che al culmine il fiore e' grande: si prova
/// anche che **al fondo dell'espiro non sparisce**, e che **con Riduci
/// Movimento il colore resta**. Un fiore che si chiude fino a un punto
/// passerebbe la misura del culmine a pieni voti.
void main() {
  const finestra = Size(390, 844);

  test('AL CULMINE IL FIORE OCCUPA ALMENO L\'85 PER CENTO', () {
    final corone = LotoCheRespira.petaliPerCorona.length;
    final raggio = PittoreDelLoto.raggioDellaCorona(
        finestra.width, 1.0, corone - 1, corone);
    final quota = raggio * 2 / finestra.width;
    // ignore: avoid_print
    print('ORDINE DB: al culmine la corona esterna e larga '
        '${(quota * 100).toStringAsFixed(1)} per cento della finestra da '
        '${finestra.width.toInt()} punti');
    expect(quota, greaterThanOrEqualTo(0.85),
        reason: 'al culmine dell inspiro il fiore occupa solo il '
            '${(quota * 100).toStringAsFixed(1)} per cento della larghezza: e '
            'la figura piccola con la cornice vuota attorno che il fondatore '
            'ha respinto');
  });

  test('REGOLA H: AL FONDO DELL ESPIRO NON SCENDE SOTTO IL 50 PER CENTO', () {
    final corone = LotoCheRespira.petaliPerCorona.length;
    final raggio = PittoreDelLoto.raggioDellaCorona(
        finestra.width, 0.0, corone - 1, corone);
    final quota = raggio * 2 / finestra.width;
    // ignore: avoid_print
    print('ORDINE DB: al fondo dell espiro il fiore e largo '
        '${(quota * 100).toStringAsFixed(1)} per cento');
    expect(quota, greaterThanOrEqualTo(0.50),
        reason: 'al fondo dell espiro il fiore scende al '
            '${(quota * 100).toStringAsFixed(1)} per cento: sparisce invece '
            'di chiudersi, e chi guarda perde il filo del respiro');
    // E non deve nemmeno restare grande quanto al culmine: se non si chiude,
    // il respiro non si vede.
    final aperto = PittoreDelLoto.raggioDellaCorona(
        finestra.width, 1.0, corone - 1, corone);
    expect(raggio, lessThan(aperto * 0.95),
        reason: 'fra chiuso e aperto il fiore cambia meno del cinque per '
            'cento: a schermo il respiro non si legge');
  });

  test('QUATTRO CORONE, coi petali che crescono', () {
    const quante = LotoCheRespira.petaliPerCorona;
    // ignore: avoid_print
    print('ORDINE DB: corone ${quante.length}, petali per corona '
        '${quante.join(", ")}, totale ${quante.reduce((a, b) => a + b)}');
    cardinaleMinimo(quante.length, 4,
        cosa: 'corone del mandala',
        perche: 'L ordine ne chiede almeno quattro: con meno e un fiore a '
            'petali contati, non un mandala.');
    for (var i = 1; i < quante.length; i++) {
      expect(quante[i], greaterThan(quante[i - 1]),
          reason: 'la corona $i non ha piu petali della precedente: il numero '
              'deve crescere anello dopo anello');
    }
    // **NESSUN PETALO SULLO STESSO RAGGIO DI UN ALTRO.** Due corone in
    // rapporto intero allineano i petali e disegnano braccia, che e' la
    // stella a punte da cui questo fiore deve stare lontano.
    for (var a = 0; a < quante.length; a++) {
      for (var b = a + 1; b < quante.length; b++) {
        expect(quante[b] % quante[a], isNot(0),
            reason: 'la corona con ${quante[b]} petali e multipla di quella '
                'con ${quante[a]}: i petali si allineano su raggi comuni e il '
                'mandala diventa una stella a braccia');
      }
    }
  });

  test('L ONDA: il cuore si apre PRIMA del bordo', () {
    final corone = LotoCheRespira.petaliPerCorona.length;
    // A meta' respiro il cuore deve essere piu' avanti del bordo.
    final cuore = PittoreDelLoto.aperturaDellaCorona(0.5, 0);
    final bordo = PittoreDelLoto.aperturaDellaCorona(0.5, corone - 1);
    // ignore: avoid_print
    print('ORDINE DB: a meta inspiro il cuore e aperto al '
        '${(cuore * 100).toStringAsFixed(0)} per cento e il bordo al '
        '${(bordo * 100).toStringAsFixed(0)} per cento');
    expect(cuore, greaterThan(bordo),
        reason: 'a meta inspiro il cuore e il bordo sono aperti uguale: non '
            'c e nessuna onda, e il fiore e solo una figura che si '
            'ingrandisce, che e cio che il fondatore ha respinto');
    // **E ALLA FINE SONO TUTTI APERTI.** Un'onda che non arriva in fondo
    // lascia il bordo a meta' per sempre.
    for (var i = 0; i < corone; i++) {
      expect(PittoreDelLoto.aperturaDellaCorona(1.0, i), 1.0,
          reason: 'la corona $i non arriva mai al pieno: l onda non finisce '
              'la sua corsa');
    }
    // E all'inizio nessuna e' partita.
    expect(PittoreDelLoto.aperturaDellaCorona(0.0, corone - 1), 0.0);
  });

  test('IL COLORE E QUELLO DEL CENTRO DI OGGI, e cambia ogni giorno', () {
    final visti = <Color>{};
    for (var g = 0; g < 7; g++) {
      final giorno = DateTime(2026, 9, 7).add(Duration(days: g));
      visti.add(ColoreDelCentro.di(giorno));
    }
    // ignore: avoid_print
    print('ORDINE DB: in una settimana i colori distinti del fiore sono '
        '${visti.length}');
    expect(visti.length, 7,
        reason: 'in una settimana il fiore prende solo ${visti.length} colori '
            'diversi: due giorni sono uguali, e il motivo per tornare domani '
            'si spegne');
    // **E NON E BIANCO E NERO.** E il difetto che la voce esiste per chiudere.
    for (final c in ColoreDelCentro.perCentro) {
      final grigio = (c.r - c.g).abs() < 0.04 && (c.g - c.b).abs() < 0.04;
      expect(grigio, isFalse,
          reason: 'un centro ha un colore grigio: il bianco e nero e uscito, '
              'e questo e un modo di farlo rientrare');
    }
  });

  test('REGOLA H: con Riduci Movimento il colore RESTA', () {
    // L'ordine e' esplicito: *"i petali non si animano, la fase cambia con uno
    // stato fermo e visibile, il colore resta, e la vibrazione resta"*. Un
    // fiore che con Riduci Movimento diventa grigio toglierebbe a chi ha
    // bisogno di quella impostazione proprio la cosa che cambia ogni giorno.
    const colore = Color(0xFF2E9E6B);
    final fermo = PittoreDelLoto(
      apertura: 1.0,
      coloreDelCentro: colore,
      gocce: const [],
      centroDiOggi: 0,
      senzaMoto: true,
    );
    expect(fermo.coloreDelCentro, colore,
        reason: 'con Riduci Movimento il fiore perde il colore del centro');
    expect(fermo.inclinazione, Offset.zero,
        reason: 'con Riduci Movimento resta la parallasse: e movimento, ed e '
            'proprio quello che quella impostazione chiede di togliere');
  });

  test('LE FORME AL CULMINE, dichiarate e sotto il tetto', () {
    final forme = PittoreDelLoto.formeAlCulmine();
    // ignore: avoid_print
    print('ORDINE DB: forme vive al culmine $forme, con '
        '${LotoCheRespira.petaliPerCorona.reduce((a, b) => a + b)} petali su '
        '${LotoCheRespira.petaliPerCorona.length} corone');
    // Il tetto in uso nel progetto per una scena viva: sotto le duecento
    // forme una CustomPaint resta comodamente dentro i sedici millisecondi.
    expect(forme, lessThan(200),
        reason: 'il fiore disegna $forme forme al culmine: sopra le duecento '
            'una scena viva comincia a perdere fotogrammi sui telefoni bassi');
  });
}
