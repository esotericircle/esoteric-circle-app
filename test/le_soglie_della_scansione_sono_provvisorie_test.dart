import 'dart:io';

import 'package:esoteric_circle/core/face/soglie_della_scansione.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LE SOGLIE DELLA SCANSIONE SONO PROVVISORIE, E QUESTA PROVA E' ROSSA
/// APPOSTA.** Ordine CR voce 13, 6 settembre 2026.
///
/// **Decisione del fondatore**, voce CR.13: le soglie degli angoli e i tempi di
/// tenuta delle quattro pose non si possono misurare oggi, perche' non c'e' un
/// telefono collegato. Si parte da valori ragionati, dichiarati provvisori, e
/// la taratura vera arriva dopo.
///
/// **IL VINCOLO CHE L'ORDINE IMPONE, con le sue parole**: *"una guardia deve
/// cadere finche' quei valori restano marcati come non misurati. E' la stessa
/// famiglia della riga rossa che tieni sui manifesti finche' VOCI_APERTE non e'
/// zero: rossa apposta, e non si tocca."*
///
/// **QUESTA PROVA NON SI RIPARA SCRIVENDO CODICE.** Si spegne in un modo solo:
/// qualcuno misura gli angoli e i tempi su un telefono vero, sostituisce i
/// numeri, porta `tarateSuUnDispositivo` a vero e scrive nel referto SU QUALE
/// TELEFONO li ha presi. Chiunque la faccia passare in un altro modo sta
/// spegnendo l'unica cosa che ricorda al progetto che quei numeri sono
/// inventati.
///
/// **STA NEL REGISTRO DEI ROSSI ACCETTATI** con la sua ragione, cosi' lo
/// sbarramento produce l'archivio e il registro della build la stampa: il rosso
/// resta visibile a ogni consegna invece di essere dimenticato.
void main() {
  // **LAPIDE, ordine FC voce 11, 5 ottobre 2026.** Qui c'era "le soglie
  // delle quattro pose sono state misurate su un telefono", rossa apposta
  // finche' `tarateSuUnDispositivo` era falso. La misura aspetta una persona
  // davanti al telefono che gira la testa: un gesto che sul ramo non esiste.
  // Il fondatore ha scelto la cura (3) della FC.11: la prova gira sul ramo
  // e pretende che il flag, il referto e la riga ASPETTA del file delle
  // soglie dicano la stessa cosa. Il ricordo che quei numeri sono inventati
  // non si spegne: sta nella riga ASPETTA, nel rapporto dell'ordine FC e in
  // docs/STATO_VIVO.md, fra i gesti del fondatore.
  test(
      'le soglie delle quattro pose dicono se sono misurate, e se no quale '
      'gesto aspettano', () {
    final sorgente =
        File('lib/core/face/soglie_della_scansione.dart').readAsStringSync();
    final aspetta = RegExp(r'^/// ASPETTA: (.{40,})$', multiLine: true)
        .firstMatch(sorgente)
        ?.group(1);
    final referto = File('docs/collaudo/CR/taratura_delle_soglie.txt');
    // ignore: avoid_print
    print('ORDINE CR VOCE 13: soglie tarate su un dispositivo '
        '${SoglieDellaScansione.tarateSuUnDispositivo}, profilo '
        '${SoglieDellaScansione.gradiDiProfilo} gradi, inclinazione '
        '${SoglieDellaScansione.gradiDiInclinazione} gradi, tolleranza del '
        'fronte ${SoglieDellaScansione.tolleranzaDelFronte} gradi, tenuta '
        '${SoglieDellaScansione.tenuta.inMilliseconds} millisecondi; '
        'aspetta: ${aspetta ?? 'niente'}; referto ${referto.existsSync()}');
    if (SoglieDellaScansione.tarateSuUnDispositivo) {
      // Misurate: il referto dice su quale telefono, e niente aspetta piu'.
      expect(referto.existsSync(), isTrue,
          reason: 'le soglie si dicono tarate e il referto col nome del '
              'telefono non c\'e\'');
      expect(aspetta, isNull,
          reason: 'le soglie sono tarate e la riga ASPETTA resta');
    } else {
      // Non misurate: il file lo dice, con il gesto che aspetta, e nessun
      // referto finge una taratura.
      expect(aspetta, isNotNull,
          reason: 'LE SOGLIE NON SONO STATE MISURATE e il file non dice quale '
              'gesto aspetta: la riga "/// ASPETTA:" in '
              'lib/core/face/soglie_della_scansione.dart');
      expect(aspetta, contains('gira la testa'));
      expect(referto.existsSync(), isFalse,
          reason: 'un referto di taratura con le soglie dichiarate non '
              'misurate');
    }
  });

  test('e i numeri vivono in un posto solo, non sparsi', () {
    // **UN POSTO SOLO, e l'ordine lo chiede per nome**: *"li dichiari
    // PROVVISORI nel codice, in un punto solo e non sparsi"*. Se domani
    // qualcuno copiasse un venti o un ottocento dentro la schermata, la
    // taratura ne correggerebbe uno e lascerebbe l'altro, e nessuno se ne
    // accorgerebbe.
    final schermata =
        File('lib/features/maestri/aura/face/face_constellation_screen.dart');
    expect(schermata.existsSync(), isTrue,
        reason: 'la schermata della Costellazione non esiste piu');
    final testo = schermata.readAsStringSync();
    cardinaleMinimo(testo.length, 5000,
        cosa: 'caratteri della schermata riletti in cerca di soglie sparse',
        perche: 'Su un file vuoto non si trova nessuna soglia sparsa, e la '
            'prova passerebbe senza aver letto niente.');

    // I numeri delle soglie scritti a mano fuori dalla loro casa. Si cercano
    // come confronti su un angolo o su una durata, non come numeri qualunque:
    // un 20 dentro un padding non c'entra niente.
    final sospetti = <String>[];
    final righe = testo.split(String.fromCharCode(10));
    for (var i = 0; i < righe.length; i++) {
      final r = righe[i];
      if (r.trimLeft().startsWith('//')) continue;
      final parlaDiAngoli = r.contains('Degrees') ||
          r.contains('yaw') ||
          r.contains('pitch') ||
          r.contains('gradi');
      if (parlaDiAngoli && RegExp(r'\b(15|20|5)(\.0)?\b').hasMatch(r)) {
        sospetti.add('riga ${i + 1}: ${r.trim()}');
      }
    }
    // ignore: avoid_print
    print('ORDINE CR VOCE 13: soglie di angolo scritte a mano nella schermata '
        '${sospetti.length}');
    expect(sospetti, isEmpty,
        reason: 'queste righe scrivono a mano una soglia di angolo invece di '
            'prenderla da SoglieDellaScansione: la taratura ne correggerebbe '
            'una e lascerebbe le altre.\n  ${sospetti.join("\n  ")}');
  });
}
