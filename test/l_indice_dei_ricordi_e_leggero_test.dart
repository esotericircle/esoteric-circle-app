/// LE MISURE DELL'INDICE DEI RICORDI. Ordine CG voce 03.
///
/// Le tre misure di accettazione dell'ordine, tutte contate e non stimate:
/// una scrittura al giorno, dodici letture per dodici mesi, duecento byte per
/// riga. La prova del rosso di ognuna sta scritta nel suo `reason`.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:esoteric_circle/core/ricordi/registro_dei_ricordi.dart';
import 'package:esoteric_circle/core/ricordi/voce_del_ricordo.dart';

/// Una porta che non tocca la rete e conta cosa le passa davanti.
class _PortaContata extends PortaDeiRicordi {
  _PortaContata({this.rispondiDiSi = true});

  final bool rispondiDiSi;
  final List<String> mesiMandati = [];
  final List<String> mesiLetti = [];
  final Map<String, List<VoceDelRicordo>> magazzino = {};

  @override
  Future<bool> manda(String mese, List<VoceDelRicordo> righe) async {
    mesiMandati.add(mese);
    if (rispondiDiSi) magazzino[mese] = righe;
    return rispondiDiSi;
  }

  @override
  Future<List<VoceDelRicordo>> leggi(String mese) async {
    mesiLetti.add(mese);
    return magazzino[mese] ?? const [];
  }
}

VoceDelRicordo _voce(DateTime quando, {String arte = 'gettata'}) =>
    VoceDelRicordo(
      quando: quando,
      arte: arte,
      maestro: 'caligo',
      titolo: 'Una gettata di rune',
      tipo: TipoDelRicordo.gesto,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues(const {}));

  test('CG.03: una giornata da cinquanta voci costa UNA scrittura', () async {
    final porta = _PortaContata();
    var adesso = DateTime(2026, 8, 31, 9);
    final registro = RegistroDeiRicordi(orologio: () => adesso, porta: porta);
    await registro.carica();

    for (var i = 0; i < 50; i++) {
      adesso = DateTime(2026, 8, 31, 9, i);
      await registro.segna(_voce(adesso));
    }

    expect(registro.scrittureVersoIlServer, 0,
        reason: 'segnare non deve toccare il server: se questo numero e\' gia\' '
            'salito, la scrittura e\' tornata dentro il gesto');

    final fatte = await registro.sincronizza();

    expect(fatte, 1,
        reason: 'cinquanta voci dello stesso mese devono partire in UNA '
            'scrittura. IL ROSSO SI DIMOSTRA rimettendo la chiamata a '
            'sincronizza dentro segna: qui il conto diventa cinquanta');
    expect(registro.scrittureVersoIlServer, 1);
    expect(porta.mesiMandati, ['2026-08']);
    expect(registro.vociDelMese('2026-08').length, 50,
        reason: 'le cinquanta voci devono esserci tutte');
  });

  test('CG.03: la seconda sincronia dello stesso giorno non scrive', () async {
    final porta = _PortaContata();
    var adesso = DateTime(2026, 8, 31, 9);
    final registro = RegistroDeiRicordi(orologio: () => adesso, porta: porta);
    await registro.carica();
    await registro.segna(_voce(adesso));

    expect(await registro.sincronizza(), 1);
    await registro.segna(_voce(DateTime(2026, 8, 31, 10)));
    expect(await registro.sincronizza(), 0,
        reason: 'oggi la sincronia e\' gia\' avvenuta: una seconda sarebbe una '
            'scrittura in piu\' per persona al giorno');

    adesso = DateTime(2026, 9, 1, 9);
    expect(await registro.sincronizza(), 1,
        reason: 'il giorno dopo riparte, e porta cio\' che era rimasto');
  });

  test('CG.03: una sincronia fallita non perde il mese', () async {
    final rotta = _PortaContata(rispondiDiSi: false);
    var adesso = DateTime(2026, 8, 31, 9);
    final registro = RegistroDeiRicordi(orologio: () => adesso, porta: rotta);
    await registro.carica();
    await registro.segna(_voce(adesso));
    await registro.sincronizza();

    adesso = DateTime(2026, 9, 1, 9);
    expect(await registro.sincronizza(), 1,
        reason: 'il server non aveva preso il mese: deve ripartire. IL ROSSO '
            'SI DIMOSTRA togliendo dallo sporco anche quando la porta dice di '
            'no, e allora quel mese non arriva mai piu\'');
  });

  test('CG.03: scorrere dodici mesi costa al massimo dodici letture',
      () async {
    final porta = _PortaContata();
    // Il magazzino del server ha dodici mesi, e il telefono e' vuoto.
    for (var m = 1; m <= 12; m++) {
      final mese = '2025-${m.toString().padLeft(2, '0')}';
      porta.magazzino[mese] = [_voce(DateTime(2025, m, 5))];
    }
    final registro = RegistroDeiRicordi(
        orologio: () => DateTime(2026, 8, 31), porta: porta);
    await registro.carica();

    for (var m = 1; m <= 12; m++) {
      await registro.ripesca('2025-${m.toString().padLeft(2, '0')}');
    }

    expect(registro.lettureDalServer, lessThanOrEqualTo(12),
        reason: 'un mese, una lettura: dodici mesi non possono costare di piu\'');
    expect(registro.lettureDalServer, 12);

    // E riscorrerli non costa niente, perche' adesso il telefono li ha.
    for (var m = 1; m <= 12; m++) {
      await registro.ripesca('2025-${m.toString().padLeft(2, '0')}');
    }
    expect(registro.lettureDalServer, 12,
        reason: 'a indice caldo le letture sono ZERO. IL ROSSO SI DIMOSTRA '
            'togliendo il controllo su un mese gia\' conosciuto, e il conto '
            'sale a ventiquattro');
  });

  test('CG.03: aprire l\'anno con l\'indice caldo non legge niente', () async {
    final porta = _PortaContata();
    var adesso = DateTime(2026, 8, 31, 9);
    final registro = RegistroDeiRicordi(orologio: () => adesso, porta: porta);
    await registro.carica();
    for (var m = 1; m <= 8; m++) {
      await registro.segna(_voce(DateTime(2026, m, 5)));
    }

    final mesi = registro.mesiConosciuti;
    for (final mese in mesi) {
      registro.vociDelMese(mese);
    }

    expect(registro.lettureDalServer, 0,
        reason: 'l\'anno intero si legge dal telefono: ZERO letture, che e\' '
            'la misura di accettazione dell\'ordine');
    expect(mesi.first, '2026-08',
        reason: 'i mesi tornano dal piu\' recente');
  });

  test('CG.03: una riga sta sotto i duecento byte, misurati sul dato vero',
      () {
    // Il caso peggiore vero: l'arte col nome piu' lungo del catalogo, un
    // riferimento Firestore da venti caratteri, e una domanda LUNGA come
    // quelle che le persone scrivono davvero, piena di accenti, che in UTF-8
    // costano due byte ciascuno.
    //
    // **La domanda e' lunga di proposito.** Con un titolo corto togliere il
    // troncamento farebbe cadere la misura della LUNGHEZZA senza mai mettere
    // alla prova quella del PESO, che e' la grandezza che conta: una prova che
    // cade prima di arrivare a cio' che misura non misura niente.
    const domandaVera =
        'Perché ogni volta che provo a cambiare lavoro mi blocco proprio '
        'nel momento in cui sto per firmare il contratto nuovo, e cosa dice '
        'il mio cielo su questa paura che torna sempre uguale da almeno tre '
        'anni ormai, sempre nello stesso identico punto del percorso?';
    final peggiore = VoceDelRicordo(
      quando: DateTime(2026, 8, 31, 23, 59),
      arte: 'friends_compatibility',
      maestro: 'medora',
      titolo: domandaVera,
      tipo: TipoDelRicordo.conversazione,
      riferimento: 'aBcDeFgHiJkLmNoPqRsT',
    );

    expect(domandaVera.length, greaterThan(VoceDelRicordo.pesoMassimo),
        reason: 'il caso peggiore deve poter sfondare il tetto da solo, '
            'altrimenti la prova del rosso non arriva mai al peso');

    // **IL PESO PER PRIMO, ed e' voluto.** E' la misura di accettazione
    // dell'ordine; la lunghezza del titolo e' solo il modo con cui la si
    // tiene. Se la lunghezza venisse prima, togliendo il troncamento la prova
    // cadrebbe li' e il peso non verrebbe mai messo alla prova.
    expect(peggiore.peso, lessThan(VoceDelRicordo.pesoMassimo),
        reason: 'la riga pesa ${peggiore.peso} byte contro i '
            '${VoceDelRicordo.pesoMassimo} del tetto. IL ROSSO SI DIMOSTRA '
            'infilando il testo pieno dentro la riga invece del riferimento');
    expect(peggiore.titolo.length,
        lessThanOrEqualTo(VoceDelRicordo.quantiCaratteriDelTitolo),
        reason: 'il titolo si tronca, ed e\' la sola parte di lunghezza libera');
  });

  test('CG.03: due apparecchi si sommano invece di cancellarsi', () async {
    // La stessa voce mandata da due apparecchi ha la stessa chiave, quindi
    // resta una riga sola; due voci diverse restano due.
    final quando = DateTime(2026, 8, 31, 9);
    final dalTelefono = VoceDelRicordo(
        quando: quando,
        arte: 'gettata',
        maestro: 'caligo',
        titolo: 'Una gettata',
        tipo: TipoDelRicordo.gesto,
        riferimento: 'uno');
    final dalTablet = VoceDelRicordo(
        quando: quando,
        arte: 'gettata',
        maestro: 'caligo',
        titolo: 'Una gettata',
        tipo: TipoDelRicordo.gesto,
        riferimento: 'uno');
    final altra = VoceDelRicordo(
        quando: quando,
        arte: 'gettata',
        maestro: 'caligo',
        titolo: 'Un altra gettata',
        tipo: TipoDelRicordo.gesto,
        riferimento: 'due');

    expect(dalTelefono.chiave, dalTablet.chiave,
        reason: 'la stessa voce da due apparecchi deve avere la stessa chiave, '
            'altrimenti il mese porta la riga due volte');
    expect(dalTelefono.chiave, isNot(altra.chiave),
        reason: 'due voci diverse devono restare due righe');
  });

  test('CG.03: la riga sopravvive al giro fra mappa e ritorno', () {
    final prima = VoceDelRicordo(
      quando: DateTime(2026, 8, 31, 14, 30),
      arte: 'tarot_spread_three',
      maestro: 'medora',
      titolo: 'Cosa mi aspetta questa settimana',
      tipo: TipoDelRicordo.responso,
      riferimento: 'abc123',
    );
    final dopo = VoceDelRicordo.daMappa(prima.aMappa())!;

    expect(dopo.quando, prima.quando);
    expect(dopo.arte, prima.arte);
    expect(dopo.maestro, prima.maestro);
    expect(dopo.titolo, prima.titolo);
    expect(dopo.tipo, prima.tipo);
    expect(dopo.riferimento, prima.riferimento);
    expect(dopo.chiave, prima.chiave);
  });
}
