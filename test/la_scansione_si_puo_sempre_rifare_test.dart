import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'sorgenti_di_lib.dart';

/// **LA SCANSIONE SI PUO' SEMPRE RIFARE, E SI VEDE CHE SI PUO'.**
/// Ordine CX, 8 settembre 2026.
///
/// **Parole del fondatore**: *"aprendo la costellazione del viso, non mi fa
/// piu' fare la scansione con i comandi destra, sinistra, sopra e sotto e mi
/// avverte: i tuoi tratti li ho gia' ecc. PERCHE'? CHI TI HA DETTO DI NON DARE
/// L'OPPORTUNITA' DI RIFARE LA SCANSIONE?"*
///
/// **E la funzione c'era.** Il pulsante *"Rifai la lettura piena"* apre la
/// cattura a quattro pose e non l'aveva tolto nessuno. **A mancare era il
/// senso della schermata**: la riga *"I tuoi tratti li ho gia'"* descrive il
/// pulsante del ritorno ma era stampata **fra i due pulsanti**, cioe' subito
/// sopra quello della lettura piena. Chi legge dall'alto in basso la attacca a
/// cio' che viene dopo e riceve il messaggio opposto a quello vero.
///
/// **La grandezza misurata e' quante didascalie stanno fra i due pulsanti.**
/// Una sola riga fra due pulsanti appartiene a tutti e due: e' ambigua per
/// costruzione, e nessuna prova che cerchi la presenza del pulsante l'avrebbe
/// mai vista. Quindi qui si pretende che **ogni pulsante abbia la sua**.
///
/// **REGOLA H.** Si prova anche l'assenza del difetto opposto: le due
/// didascalie devono dire cose DIVERSE. Due righe uguali sotto due pulsanti
/// diversi sarebbero ambigue quanto una riga sola, e passerebbero un conteggio.
void main() {
  final sorgente = File(
          'lib/features/maestri/aura/face/face_constellation_screen.dart')
      .readAsStringSync();
  final codice = senzaCommenti(sorgente);

  test('OGNI PULSANTE HA LA SUA DIDASCALIA, e non ne condividono una', () {
    for (final chiave in const [
      'face_didascalia_ritorno',
      'face_didascalia_piena',
    ]) {
      expect(codice.contains(chiave), isTrue,
          reason: 'manca la didascalia "$chiave": se un pulsante resta senza '
              'la sua riga, quella dell\'altro descrive tutti e due, ed e\' '
              'come il fondatore ha letto una scansione negata dove c\'era un '
              'pulsante che la apriva');
    }
  });

  test('E LE DUE RIGHE NON DICONO LA STESSA COSA', () {
    // **REGOLA H.** Il conteggio di sopra passerebbe anche con due righe
    // identiche, che sarebbero ambigue esattamente come una riga sola.
    String testoVicino(String chiave) {
      final i = codice.indexOf(chiave);
      if (i < 0) return '';
      // La stringa del Text sta poco sopra la chiave, dentro lo stesso widget.
      final da = i - 400 < 0 ? 0 : i - 400;
      return codice.substring(da, i);
    }

    final a = testoVicino('face_didascalia_ritorno');
    final b = testoVicino('face_didascalia_piena');
    expect(a.isNotEmpty && b.isNotEmpty, isTrue,
        reason: 'non si trova il testo di una delle due didascalie: questa '
            'prova non sta guardando quello che crede');
    expect(a.contains('li ho già'), isTrue,
        reason: 'la didascalia del ritorno non e\' quella che il fondatore ha '
            'letto: la prova sta misurando un\'altra riga');
    expect(b.contains('Quattro pose'), isTrue,
        reason: 'la didascalia della lettura piena non nomina le quattro '
            'pose, cioe\' non dice che quel pulsante apre la scansione: e\' '
            'proprio l\'informazione che mancava');
  });

  test('L\'AVVISO SUGLI ACCESSORI ESISTE, e viene PRIMA dei pulsanti', () {
    // Ordine CX voce 07. **La posizione conta quanto il testo**: un avviso
    // stampato dopo il pulsante che apre la fotocamera arriva quando la
    // persona si e' gia' inquadrata col cappello.
    final avviso = codice.indexOf('face_avviso_accessori');
    final ritorno = codice.indexOf('face_return_start');
    final piena = codice.indexOf('face_start');
    expect(avviso, greaterThanOrEqualTo(0),
        reason: 'non esiste nessun avviso sugli accessori: chi si inquadra '
            'col cappello lo scopre dal responso, che glielo descrive lo '
            'stesso perche\' la mesh posa i punti anche dove non vede');
    expect(ritorno, greaterThanOrEqualTo(0),
        reason: 'non si trova il pulsante del ritorno');
    expect(piena, greaterThanOrEqualTo(0),
        reason: 'non si trova il pulsante della lettura piena');
    expect(avviso, lessThan(ritorno),
        reason: 'l\'avviso sugli accessori e\' scritto DOPO il pulsante che '
            'apre la fotocamera: arriva quando serviva prima');
    expect(avviso, lessThan(piena),
        reason: 'l\'avviso sugli accessori e\' scritto DOPO il pulsante della '
            'lettura piena');
    // E nomina le cose che nascondono i tratti, non genericamente "accessori".
    final attorno = codice.substring(
        avviso, avviso + 1400 > codice.length ? codice.length : avviso + 1400);
    for (final parola in const ['cappello', 'occhiali', 'capelli']) {
      expect(attorno.toLowerCase().contains(parola), isTrue,
          reason: 'l\'avviso non nomina "$parola": un invito generico a '
              'togliere gli accessori non dice a nessuno cosa togliere');
    }
  });

  test('IL CONFRONTO FRA DUE VOLTI SI PUO\' CHIUDERE', () {
    // Ordine CX voce 10, parole del fondatore: *"nel responso resta in primo
    // piano un riquadro due volti nello stesso cerchio che non posso
    // togliere"*. Il riquadro vive FUORI dall'area che scorre, quindi da
    // quando compare si prende un terzo di schermo per sempre e taglia il
    // responso a meta'.
    expect(codice.contains('face_due_volti_chiudi'), isTrue,
        reason: 'il riquadro del confronto non ha nessun modo di chiudersi, e '
            'sta fuori dall\'area scorrevole: una volta aperto resta li\'');
    // **E la chiusura deve fare qualcosa**, non essere un bottone muto.
    expect(codice.contains('onChiudi'), isTrue,
        reason: 'la chiusura non e\' collegata a niente');
  });
}
