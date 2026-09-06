import 'dart:convert';

import 'package:esoteric_circle/core/face/espressione_dell_istante.dart';
import 'package:esoteric_circle/core/face/scansione_a_pose.dart';
import 'package:esoteric_circle/core/face/storico_degli_istanti.dart';
import 'package:esoteric_circle/core/face/tenuta_di_fronte.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **IL RITORNO E' PIU' CORTO, NON PIU' FACILE.** Ordine CR voce 08,
/// 6 settembre 2026.
///
/// **Parole dell'ordine**: la funzione vive in due momenti, *"la PRIMA VOLTA,
/// che e' la scansione piena a quattro pose e produce la lettura dei tratti,
/// che si conserva"* e *"i RITORNI, che sono una scansione breve di fronte e
/// producono soltanto la lettura dell'istante, confrontata con la propria
/// linea"*.
///
/// **IL RISCHIO CHE QUESTA GUARDIA SORVEGLIA.** Una scansione breve puo'
/// diventare la porta di servizio del muro: se bastasse essere inquadrati, una
/// fotografia stampata passerebbe. Qui si pretende che il fronte vada
/// **tenuto**, e che perderlo azzeri: un istante di fronte non basta, e quattro
/// istanti sparsi non si sommano.
class SoglieDiProva extends SoglieInUso {
  const SoglieDiProva();
  @override
  double get gradiDiProfilo => 20;
  @override
  double get gradiDiInclinazione => 15;
  @override
  double get tolleranzaDelFronte => 5;
  @override
  Duration get tenuta => const Duration(milliseconds: 800);
}

void main() {
  const soglie = SoglieDiProva();
  const passo = Duration(milliseconds: 100);

  test('un istante di fronte non compie la tenuta', () {
    final t = TenutaDiFronte(soglie: soglie);
    expect(t.passo(yaw: 0, pitch: 0, trascorso: passo), isFalse);
    expect(t.compiuta, isFalse,
        reason: 'un solo fotogramma di fronte basta a compiere il ritorno: '
            'allora una fotografia stampata passa, e il ritorno diventa la '
            'porta di servizio del muro');
  });

  test('il fronte tenuto abbastanza a lungo compie la tenuta', () {
    final t = TenutaDiFronte(soglie: soglie);
    var compiuta = false;
    for (var i = 0; i < 8 && !compiuta; i++) {
      compiuta = t.passo(yaw: 0, pitch: 0, trascorso: passo);
    }
    expect(t.compiuta, isTrue,
        reason: 'otto decimi di fronte non compiono una tenuta di otto '
            'decimi: chi torna resta bloccato davanti a una richiesta che '
            'non si soddisfa mai');
  });

  test('perdere il fronte azzera, e gli istanti sparsi non si sommano', () {
    final t = TenutaDiFronte(soglie: soglie);
    // **DODICI VOLTE, E IL NUMERO CONTA.** Fronte per un decimo, poi via.
    // Sommati fanno un secondo e due, cioe' BEN OLTRE la tenuta di otto
    // decimi: se l'azzeramento sparisse, la tenuta si compirebbe e questa
    // prova cadrebbe. Con sette giri la somma restava sotto la soglia e
    // la prova passava anche senza azzeramento: era una pretesa debole,
    // trovata dalla Regola A e non da un difetto del codice.
    for (var i = 0; i < 12; i++) {
      t.passo(yaw: 0, pitch: 0, trascorso: passo);
      t.passo(yaw: 40, pitch: 0, trascorso: passo);
    }
    expect(t.compiuta, isFalse,
        reason: 'dodici istanti di fronte sparsi hanno compiuto la tenuta: '
            'allora la tenuta non misura una tenuta, misura una somma');
  });

  test('il ritorno chiede meno della prima volta, e lo si vede', () {
    // **LA PRETESA E\' UN CONFRONTO FRA DUE MACCHINE**, non un numero
    // scritto a mano: se domani si cambia il tempo di tenuta, questa resta
    // vera, perche' dice cio' che l'ordine dice davvero, cioe' che il
    // ritorno e' piu' corto.
    final breve = TenutaDiFronte(soglie: soglie);
    final piena = ScansioneAPose(soglie: soglie);

    var fotogrammi = 0;
    while (!breve.compiuta && fotogrammi < 200) {
      breve.passo(yaw: 0, pitch: 0, trascorso: passo);
      fotogrammi++;
    }
    final costoDelRitorno = fotogrammi;

    // La scansione piena, guidata perfettamente: fronte per agganciare, poi
    // le quattro pose una a una.
    fotogrammi = 0;
    piena.passo(yaw: 0, pitch: 0, trascorso: passo);
    fotogrammi++;
    for (final p in ScansioneAPose.ordine) {
      final yaw = switch (p) {
        Posa.destra => 30.0,
        Posa.sinistra => -30.0,
        _ => 0.0,
      };
      final pitch = switch (p) {
        Posa.alto => 25.0,
        Posa.basso => -25.0,
        _ => 0.0,
      };
      while (piena.compiute < ScansioneAPose.ordine.indexOf(p) + 1 &&
          fotogrammi < 400) {
        piena.passo(yaw: yaw, pitch: pitch, trascorso: passo);
        fotogrammi++;
      }
    }
    expect(piena.compiuta, isTrue, reason: 'la scansione piena non si compie');
    expect(costoDelRitorno, lessThan(fotogrammi),
        reason: 'il ritorno costa quanto la prima volta: allora i due momenti '
            'non sono due, e chi torna paga il prezzo di una misura che '
            'nessuno rifara\'');
  });

  group('la propria linea', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('senza passato non si confronta niente', () async {
      final s = StoricoDegliIstanti();
      await s.carica();
      expect(s.confronta([SegnoDelVolto.values.first]), isNull,
          reason: 'con nessuna lettura passata il confronto dice comunque '
              'qualcosa: sta confrontando col vuoto e chiamandolo linea');
    });

    test('un segno mai visto prima risulta nuovo', () async {
      final s = StoricoDegliIstanti();
      await s.carica();
      final primo = SegnoDelVolto.values.first;
      final secondo = SegnoDelVolto.values[1];
      await s.segna([primo]);

      final c = s.confronta([secondo]);
      expect(c, isNotNull);
      expect(c!.nuovi, contains(secondo),
          reason: 'un segno che non era mai comparso non risulta nuovo');
      expect(c.ricorrenti, isEmpty,
          reason: 'un segno mai visto risulta ricorrente');
      expect(c.quanteLetture, 1,
          reason: 'il confronto non dice su quante letture si regge, e chi '
              'legge non sa quanto pesa');
    });

    test('un segno gia\' visto risulta ricorrente, non nuovo', () async {
      final s = StoricoDegliIstanti();
      await s.carica();
      final primo = SegnoDelVolto.values.first;
      await s.segna([primo]);
      await s.segna([primo]);

      final c = s.confronta([primo]);
      expect(c!.ricorrenti, contains(primo));
      expect(c.nuovi, isEmpty,
          reason: 'un segno visto due volte risulta ancora nuovo: la memoria '
              'non viene letta');
    });

    test('la linea sopravvive alla chiusura dell\'app', () async {
      final primo = SegnoDelVolto.values.first;
      final scrive = StoricoDegliIstanti();
      await scrive.carica();
      await scrive.segna([primo]);

      // Un'altra istanza, come al riavvio: se non rilegge il disco, la
      // linea si azzera a ogni apertura e il confronto non esiste.
      final rilegge = StoricoDegliIstanti();
      await rilegge.carica();
      expect(rilegge.istanti, isNotEmpty,
          reason: 'la linea non sopravvive al riavvio: ogni ritorno sarebbe '
              'sempre il primo');
      expect(rilegge.ultimo!.segni, contains(primo));
    });

    test('sul disco non finisce niente da cui rifare un volto', () async {
      final s = StoricoDegliIstanti();
      await s.carica();
      await s.segna([SegnoDelVolto.values.first]);

      final p = await SharedPreferences.getInstance();
      final scritto = p.getString(StoricoDegliIstanti.chiave) ?? '';
      expect(scritto, isNotEmpty);
      // **CR.11: SI DICHIARA COSA SI SCRIVE, E SI MISURA LA STRUTTURA.**
      //
      // La prima stesura cercava numeri con la virgola, e cadeva sui
      // MILLESIMI DELLA DATA ISO: stava misurando un errore mio invece
      // del fatto. Qui si legge il JSON e si pretende che dentro non ci
      // sia altro che una data e dei nomi gia' dichiarati: cosi' un
      // coefficiente o una coordinata che entrasse domani farebbe cadere
      // questa guardia, e i millesimi di una data no.
      final decodificato = jsonDecode(scritto);
      expect(decodificato, isA<List<dynamic>>());
      final nomiVeri = {for (final x in SegnoDelVolto.values) x.name};
      for (final voce in decodificato as List<dynamic>) {
        expect(voce, isA<Map<String, dynamic>>(),
            reason: 'sul disco c''e'' una voce che non e'' una lettura');
        final m = voce as Map<String, dynamic>;
        expect(m.keys.toSet(), {'quando', 'segni'},
            reason: 'sul disco compaiono campi non dichiarati: '
                '${m.keys.toList()}. L''ordine chiede che si sappia '
                'esattamente cosa del volto viene scritto');
        expect(DateTime.tryParse(m['quando'] as String), isNotNull,
            reason: 'il campo della data non e'' una data');
        for (final n in m['segni'] as List<dynamic>) {
          expect(nomiVeri, contains(n),
              reason: 'sul disco c''e'' «$n», che non e'' il nome di un '
                  'segno: e'' un dato del volto entrato senza dichiararsi');
        }
      }
    });
  });
}
