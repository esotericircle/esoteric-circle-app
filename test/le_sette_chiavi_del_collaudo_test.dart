import 'dart:io';

import 'package:esoteric_circle/core/identity/cio_che_e_tuo.dart';
import 'package:esoteric_circle/core/identity/dimenticanza_del_telefono.dart';
import 'package:esoteric_circle/core/identity/profile_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LE SETTE CHIAVI DEL COLLAUDO. Ordine CB voce 04.
///
/// **La fonte non e' l'Architetto**: e' un collaudo indipendente del 28 agosto
/// 2026, verdetto NON REGGE, che ha letto il codice e ha dichiarato sette
/// chiavi sopravvissute alla cancellazione. Il collaudo e' ANTERIORE
/// all'ordine BZ voce 01, che ha poi introdotto `CioCheETuo`: stabilire se
/// quelle sette siano dentro o fuori da quel lavoro era il primo compito.
///
/// **L'esito, misurato qui sotto: tutte e sette se ne vanno**, su tutte e tre
/// le vie che l'app espone. La premessa dell'ordine era falsa, e lo era perche'
/// il lavoro di BZ.01 l'aveva gia' resa falsa.
///
/// **Cosa questa prova aggiunge a `niente_resta_di_te_test`**, che gia'
/// sorveglia le chiavi nuove: quella legge il CODICE e pretende che un
/// prefisso copra ogni chiave scritta. Questa scrive le chiavi VERE nelle
/// preferenze, chiama le vie vere e conta cosa resta: la misura prima e dopo,
/// che e' quello che l'ordine chiede.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Le sette del collaudo, col valore che avrebbero sul telefono di una
  /// persona vera, e la riga del collaudo che le nomina.
  const setteChiavi = <String, String>{
    'luogo.attuale': '1, la posizione dichiarata di dove la persona vive',
    'device.id': '2, l\'identita\' del dispositivo che regge i Doni',
    'filo.parola_del_giorno': '3, la parola del giorno',
    'filo.domanda_di_medora': '4, la domanda di Medora',
    'avvisi.alba.giaChiesto':
        '5, se l\'avviso dell\'alba e\' gia\' stato chiesto',
    'maestro.welcome.rotation.medora': '6, il benvenuto gia\' detto da Medora',
    'sunset_rune.settimana': '7, la settimana della Runa del Tramonto',
  };

  /// Cio' che NON e' di nessuno e deve restare in piedi: se una via portasse
  /// via anche questo, la cancellazione starebbe punendo chi esce.
  const nonSonoDiNessuno = <String, String>{
    'settings.qualita': 'medium',
    'app_check_debug_token': 'gettone-della-macchina',
  };

  Future<Map<String, bool>> quantoCeNePrima() async {
    final p = await SharedPreferences.getInstance();
    return {for (final c in setteChiavi.keys) c: p.containsKey(c)};
  }

  Future<void> riempi() async {
    SharedPreferences.setMockInitialValues(const {});
    final p = await SharedPreferences.getInstance();
    for (final c in setteChiavi.keys) {
      await p.setString(c, 'qualcosa di questa persona');
    }
    for (final c in nonSonoDiNessuno.entries) {
      await p.setString(c.key, c.value);
    }
    // Un compagno di viaggio: la carta natale, che il collaudo dichiara NON
    // sopravvissuta. Si misura anche lei, per vedere se il collaudo aveva
    // ragione su quel punto.
    await p.setString('natal.chart.v1', '{}');
  }

  Future<List<String>> superstiti() async {
    final p = await SharedPreferences.getInstance();
    return [
      for (final c in setteChiavi.keys)
        if (p.containsKey(c)) c
    ];
  }

  test('prima della cancellazione ci sono tutte e sette', () async {
    await riempi();
    final prima = await quantoCeNePrima();
    // ignore: avoid_print
    print('ORDINE CB VOCE 04: prima della cancellazione le chiavi presenti '
        'sono ${prima.values.where((c) => c).length} su ${setteChiavi.length}');
    expect(prima.values.every((c) => c), isTrue,
        reason: 'la prova non ha nemmeno scritto le chiavi che dice di '
            'misurare: senza il prima, il dopo non dimostra niente');
  });

  test('la via dell\'oblio le porta via tutte e sette', () async {
    await riempi();
    final prima = (await superstiti()).length;
    final quante = await DimenticanzaDelTelefono.dimentica();
    final dopo = await superstiti();
    // ignore: avoid_print
    print('ORDINE CB VOCE 04, oblio totale: prima $prima, dopo ${dopo.length}, '
        'chiavi rimosse in tutto $quante');
    expect(dopo, isEmpty,
        reason: 'queste chiavi del collaudo sopravvivono all\'oblio: $dopo');
  });

  test('la via che azzera i dati tenendo l\'account le porta via lo stesso',
      () async {
    // E' la voce "Ricomincia da zero": tiene la custodia, che e' la chiave
    // con cui si rientra, e porta via tutto il resto.
    await riempi();
    final prima = (await superstiti()).length;
    await DimenticanzaDelTelefono.dimentica(tenendo: const ['account.']);
    final dopo = await superstiti();
    // ignore: avoid_print
    print('ORDINE CB VOCE 04, azzera i dati: prima $prima, dopo '
        '${dopo.length}');
    expect(dopo, isEmpty,
        reason: 'queste chiavi sopravvivono all\'azzeramento: $dopo');
  });

  test('anche ProfileStore.clear le porta via', () async {
    // **L\'OTTAVO FATTO DEL COLLAUDO**: `ProfileStore.clear()` risulta
    // cablato solo nella vista di debug. E\' vero, ed e\' senza conseguenze:
    // `clear()` non ha una lista sua, chiama la stessa dimenticanza delle vie
    // vere. Non e\' una porta che nessuno apre, e\' un altro nome della
    // stessa porta.
    await riempi();
    await const ProfileStore().clear();
    final dopo = await superstiti();
    // ignore: avoid_print
    print('ORDINE CB VOCE 04, ProfileStore.clear: dopo ${dopo.length}');
    expect(dopo, isEmpty, reason: 'sopravvivono a ProfileStore.clear: $dopo');
  });

  test('cio\' che non e\' di nessuno resta in piedi', () async {
    await riempi();
    await DimenticanzaDelTelefono.dimentica();
    final p = await SharedPreferences.getInstance();
    for (final c in nonSonoDiNessuno.keys) {
      expect(p.containsKey(c), isTrue,
          reason: '$c e\' stata cancellata, e non e\' di nessuno: la '
              'cancellazione sta punendo chi esce');
    }
    // E il nono fatto del collaudo, verificato: la carta natale se ne va.
    expect(p.containsKey('natal.chart.v1'), isFalse);
  });

  test('ognuna delle sette e\' coperta da un prefisso dichiarato', () {
    final scoperte = <String>[];
    for (final c in setteChiavi.keys) {
      if (!CioCheETuo.eTua(c)) scoperte.add(c);
    }
    // ignore: avoid_print
    print('ORDINE CB VOCE 04: chiavi del collaudo coperte da un prefisso '
        '${setteChiavi.length - scoperte.length} su ${setteChiavi.length}');
    expect(scoperte, isEmpty,
        reason: 'queste non le copre nessun prefisso: $scoperte');
  });

  test('la guardia strutturale di BZ.01 sorveglia davvero queste chiavi', () {
    // L'ordine chiede di verificare se la prova nata con BZ.01 le copra. Non
    // si crede alla parola: si legge il suo codice e si guarda che cerchi le
    // chiavi in tutto `lib/` invece di elencarle a mano.
    final guardia =
        File('test/niente_resta_di_te_test.dart').readAsStringSync();
    expect(guardia.contains("Directory('lib')"), isTrue,
        reason: 'la guardia di BZ.01 non legge piu\' il codice: se elenca '
            'chiavi a mano, la prossima chiave nuova passera\' inosservata');
    expect(guardia.contains('CioCheETuo'), isTrue,
        reason: 'la guardia non confronta piu\' con la verita\' unica');
  });
}
