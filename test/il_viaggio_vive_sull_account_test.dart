// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/cammino/cammino_da_custodire.dart';
import 'package:esoteric_circle/core/viaggio/il_viaggio_custodito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';
import 'sorgenti_di_lib.dart';

/// **IL VIAGGIO DELLO SCIAMANO VIVE SULL'ACCOUNT.** Ordine EE voce 13, 23
/// settembre 2026.
///
/// **Il fatto del fondatore, verbatim**: *"adesso ho aggiornato l'app alla
/// nuova build e ho aperto il viaggio dello SCIAMANO che io avevo gia'
/// concluso e invece devo rifarlo da zero"*.
///
/// **La causa, misurata prima di curare.** Il Viaggio viveva su otto chiavi
/// di `SharedPreferences` e **non aveva nessuna porta verso il Cerchio**:
/// zero chiamate al server in tutto `diario_dei_viaggi.dart`. Non era un
/// difetto di sincronizzazione: era un dato che non aveva mai lasciato il
/// telefono, e che il diario stesso dichiara costare **quattro giorni**.
/// **Padre: PROVENIENZA IGNOTA**, il Viaggio nasce senza porta e nessun
/// ordine risulta averne discusso la custodia.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('le chiavi del Viaggio sono enumerate, non indovinate dal prefisso', () {
    // **Il cardinale, e non e' un numero a caso.** Sono le chiavi che
    // `diario_dei_viaggi.dart` dichiara: se ne nascesse una nona e nessuno
    // la aggiungesse qui, resterebbe sul telefono in silenzio, ed e'
    // esattamente il difetto di questa voce che si ripeterebbe piu' piccolo.
    cardinaleMinimo(IlViaggioCustodito.chiavi.length, 8,
        cosa: 'chiavi del Viaggio dello Sciamano',
        perche: 'Se l\'elenco si svuotasse, il Viaggio smetterebbe di '
            'viaggiare senza che nessuna prova cadesse.');

    final diario = senzaCommenti(
        File('lib/core/viaggio/diario_dei_viaggi.dart').readAsStringSync());
    final dichiarate = RegExp("'(viaggio\\.[a-z.]+)'")
        .allMatches(diario)
        .map((m) => m.group(1)!)
        .toSet();
    final dimenticate =
        dichiarate.difference(IlViaggioCustodito.chiavi.toSet());
    print('ORDINE EE VOCE 13: chiavi nel diario ${dichiarate.length}, '
        'custodite ${IlViaggioCustodito.chiavi.length}, '
        'dimenticate ${dimenticate.length}');
    expect(dimenticate, isEmpty,
        reason: 'queste chiavi del Viaggio non vengono custodite e restano '
            'sul telefono: $dimenticate');
  });

  test('il Viaggio concluso si raccoglie dalle preferenze', () {
    SharedPreferences.setMockInitialValues({
      'viaggio.quante': 4,
      'viaggio.riconosciuto': true,
      'viaggio.cammino': '{"strato":4}',
    });
    return IlViaggioCustodito.daCustodire().then((sacchetto) {
      print('ORDINE EE VOCE 13, raccolto: '
          '${sacchetto == null ? "niente" : sacchetto.keys.toList()}');
      expect(sacchetto, isNotNull,
          reason: 'il Viaggio concluso non viene raccolto: resta sul '
              'telefono e muore con l\'app');
      expect(sacchetto!['viaggio.quante'], 4);
      expect(sacchetto['viaggio.riconosciuto'], true);
    });
  });

  test('e un Viaggio mai cominciato non manda un guscio vuoto', () {
    SharedPreferences.setMockInitialValues({});
    return IlViaggioCustodito.daCustodire().then((sacchetto) {
      print('ORDINE EE VOCE 13, mai cominciato: '
          '${sacchetto == null ? "niente" : "un guscio"}');
      expect(sacchetto, isNull,
          reason: 'si manderebbe al Cerchio un guscio vuoto a ogni apertura');
    });
  });

  test('il Viaggio che il Cerchio custodisce torna sul telefono', () async {
    // **Il caso del fondatore per intero**: telefono appena aggiornato, senza
    // niente, e il Cerchio che ha il Viaggio concluso.
    SharedPreferences.setMockInitialValues({});
    await IlViaggioCustodito.adottaDalCerchio(const {
      'viaggio.quante': 4,
      'viaggio.riconosciuto': true,
      'viaggio.cammino': '{"strato":4}',
    });
    final prefs = await SharedPreferences.getInstance();
    print('ORDINE EE VOCE 13, adottato: quante '
        '${prefs.getInt('viaggio.quante')}, riconosciuto '
        '${prefs.getBool('viaggio.riconosciuto')}');
    expect(prefs.getInt('viaggio.quante'), 4,
        reason: 'il Viaggio custodito non torna sul telefono: chi aggiorna '
            'l\'app rifa\' quattro discese in quattro giorni');
    expect(prefs.getBool('viaggio.riconosciuto'), isTrue);
    expect(prefs.getString('viaggio.cammino'), '{"strato":4}');
  });

  test('e il cammino da custodire se lo porta al Cerchio', () {
    // **Senza questa, le altre restano verdi a vuoto**: il sacchetto potrebbe
    // essere raccolto benissimo e non entrare mai nel corpo che parte.
    const cammino = CamminoDaCustodire(
      viaggioDelloSciamano: {'viaggio.quante': 4},
    );
    final mappa = cammino.aMappa();
    print('ORDINE EE VOCE 13, nel corpo: ${mappa.keys.toList()}');
    expect(mappa['viaggioDelloSciamano'], isNotNull,
        reason: 'il Viaggio non entra nel corpo che va al Cerchio');
    expect(cammino.eVuoto, isFalse,
        reason: 'un cammino col solo Viaggio si considera vuoto, quindi non '
            'parte: il Viaggio non arriverebbe mai al Cerchio');
  });
}
