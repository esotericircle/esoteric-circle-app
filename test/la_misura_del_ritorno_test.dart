import 'dart:io';

import 'package:esoteric_circle/core/legal/privacy_policy.dart';
import 'package:esoteric_circle/core/misura/misura_del_ritorno.dart';
import 'package:esoteric_circle/core/misura/registro_del_ritorno.dart';
import 'package:esoteric_circle/core/cammino/cammino_da_custodire.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'sorgenti_di_lib.dart';

/// LA MISURA DEL RITORNO. Ordine CC voce 09.
///
/// **Cosa difende questa prova**, che e' quello che la voce fissa: che senza
/// consenso non parta niente, che chi dice no usi l'app intera, che gli eventi
/// siano un elenco chiuso, e che quell'elenco sia LO STESSO in tre posti, cioe'
/// nel client, nel server e nella privacy policy. Tre liste che divergono sono
/// una misura che perde pezzi in silenzio e una policy che dice il falso.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('gli eventi sono gli stessi nel client, nel server e nella policy', () {
    final server = File('functions/src/ritorno.ts').readAsStringSync();
    final ammessi = RegExp(r'"([a-z_]+)",')
        .allMatches(server.substring(
            server.indexOf('EVENTI_AMMESSI'), server.indexOf('] as const')))
        .map((m) => m.group(1)!)
        .toSet();
    final client = EventoDelRitorno.values.map((e) => e.nome).toSet();
    // ignore: avoid_print
    print('ORDINE CC VOCE 09: eventi nel client ${client.length}, sul server '
        '${ammessi.length}');
    expect(client, ammessi,
        reason: 'il client e il server non ammettono gli stessi eventi: '
            'client $client, server $ammessi');

    // E la policy li nomina tutti e cinque, con le parole di chi legge.
    final policy =
        sezioniDellaPolicy.map((s) => '${s.titolo} ${s.corpo}').join(' ');
    const aParole = <String, String>{
      'apertura': 'aperture',
      'ritorno_da_avviso': 'ritorni da una notifica',
      'rito_cominciato': 'riti cominciati',
      'rito_compiuto': 'riti finiti',
      'responso_condiviso': 'responsi condivisi',
    };
    final mute = <String>[];
    for (final e in client) {
      final detto = aParole[e];
      if (detto == null || !policy.contains(detto)) mute.add(e);
    }
    expect(mute, isEmpty,
        reason: 'la policy non dice questi eventi, che invece si contano: '
            '$mute');
  });

  test('ogni evento dichiarato ha un punto che lo manda', () {
    // **UN EVENTO DICHIARATO E MAI MANDATO E' UNA PROMESSA VUOTA.** La privacy
    // policy nomina cinque cose che si contano: se una non parte da nessun
    // punto dell'app, quel numero resta zero per sempre e la policy dice una
    // cosa che non succede. Questa prova cade il giorno che qualcuno aggiunge
    // un evento senza agganciarlo, o toglie l'aggancio di uno che c'era.
    final punti = <String>[];
    for (final f in sorgentiDiLib()) {
      punti.add(f.readAsStringSync());
    }
    final tutto = punti.join('\n');
    final orfani = <String>[];
    for (final e in EventoDelRitorno.values) {
      // Si cerca la CHIAMATA, non il nome: `EventoDelRitorno.apertura` compare
      // anche nella sua stessa dichiarazione e nei commenti.
      final chiamata =
          RegExp(r'(segnalo|segna|segnaSenzaAspettare)\(\s*EventoDelRitorno\.'
              '${e.name}');
      if (!chiamata.hasMatch(tutto)) orfani.add(e.name);
    }
    // ignore: avoid_print
    print(
        'ORDINE CC VOCE 09: eventi dichiarati ${EventoDelRitorno.values.length}, '
        'senza un punto che li manda ${orfani.length}');
    expect(orfani, isEmpty,
        reason: 'questi eventi sono dichiarati e nominati nella policy, ma '
            'nessuna riga dell\'app li manda: $orfani');
  });

  test('il consenso si chiede nella registrazione, e mai in casa', () {
    // **HA CAMBIATO CASA, ordine CE voci 01 e 02.** Prima la domanda era un
    // foglio che il Santuario mostrava dopo il tutorial; il fondatore ha fatto
    // togliere quel foglio con parole non equivocabili, e adesso il consenso
    // vive dentro il gesto della registrazione, come una riga sopra le vie
    // d'accesso.
    final casa =
        File('lib/features/santuario/santuario_screen.dart').readAsStringSync();
    expect(casa.contains('DomandaDellaMisura'), isFalse,
        reason: 'il foglio della misura e\' tornato nel Santuario');
    final vie =
        File('lib/features/account/custodia_del_cielo.dart').readAsStringSync();
    expect(vie.contains('ConsensiDellaRegistrazione()'), isTrue,
        reason: 'il consenso non si chiede piu\' da nessuna parte, quindi '
            'nessuno potrebbe mai concederlo');
  });

  test('senza consenso non parte niente', () async {
    SharedPreferences.setMockInitialValues(const {});
    final porta = _PortaCheConta();
    final registro = RegistroDelRitorno(porta: porta);
    for (final e in EventoDelRitorno.values) {
      expect(await registro.segna(e), isFalse);
    }
    // ignore: avoid_print
    print('ORDINE CC VOCE 09: senza risposta, eventi partiti '
        '${porta.segnati.length}');
    expect(porta.segnati, isEmpty,
        reason: 'si misura senza aver chiesto niente a nessuno');
  });

  test('con il no non parte niente, e non si richiede piu\'', () async {
    SharedPreferences.setMockInitialValues(const {});
    await ConsensoDellaMisura.segna(false);
    expect(await ConsensoDellaMisura.letto(), ConsensoAllaMisura.negato,
        reason:
            'il no non viene ricordato, e la domanda tornerebbe ogni volta');
    final porta = _PortaCheConta();
    final registro = RegistroDelRitorno(porta: porta);
    expect(await registro.segna(EventoDelRitorno.apertura), isFalse);
    expect(porta.segnati, isEmpty);
  });

  test('col si\' parte, e porta solo il nome e una parola', () async {
    SharedPreferences.setMockInitialValues(const {});
    await ConsensoDellaMisura.segna(true);
    final porta = _PortaCheConta();
    final registro = RegistroDelRitorno(porta: porta);
    expect(
        await registro.segna(EventoDelRitorno.ritoCompiuto, contesto: 'alba'),
        isTrue);
    // ignore: avoid_print
    print('ORDINE CC VOCE 09: mandato ${porta.segnati.first}');
    expect(porta.segnati.single, 'rito_compiuto/alba');
  });

  test('il tetto per sessione esiste, e si vede', () async {
    SharedPreferences.setMockInitialValues(const {});
    await ConsensoDellaMisura.segna(true);
    final porta = _PortaCheConta();
    final registro = RegistroDelRitorno(porta: porta);
    for (var i = 0; i < RegistroDelRitorno.quantiPerSessione + 20; i++) {
      await registro.segna(EventoDelRitorno.apertura);
    }
    // ignore: avoid_print
    print(
        'ORDINE CC VOCE 09: chiamate ${RegistroDelRitorno.quantiPerSessione + 20}, '
        'eventi partiti ${porta.segnati.length}');
    expect(porta.segnati.length, RegistroDelRitorno.quantiPerSessione,
        reason: 'senza tetto un guasto in un ciclo scriverebbe migliaia di '
            'righe sul server');
  });

  test('la porta spenta non finge di aver registrato', () async {
    SharedPreferences.setMockInitialValues(const {});
    await ConsensoDellaMisura.segna(true);
    final registro = RegistroDelRitorno(porta: const PortaSpentaDelCerchio());
    expect(await registro.segna(EventoDelRitorno.apertura), isFalse,
        reason: 'una misura che si finge riuscita e\' peggio di una che manca');
  });

  test('la chiave del consenso se ne va con la cancellazione', () {
    expect(ConsensoDellaMisura.chiave.startsWith('permesso.'), isTrue,
        reason: 'la risposta sulla misura sopravvivrebbe a chi se ne va');
  });
}

/// Una porta che tiene il conto di cosa le hanno chiesto di segnare.
class _PortaCheConta extends PortaDelCerchio {
  final List<String> segnati = [];

  @override
  bool get viva => true;

  @override
  Future<bool> segnaLEvento({required String nome, String? contesto}) async {
    segnati.add(contesto == null ? nome : '$nome/$contesto');
    return true;
  }

  @override
  Future<bool> cancellaIlCerchio() async => false;

  // Il resto della porta non serve a questa prova, e dire nullo e' la
  // risposta onesta: "non lo so", che e' cio' che il vero direbbe senza rete.
  @override
  Future<StatoDelCerchio?> stato(
          {CamminoDaCustodire? cammino, bool azzeraIlCammino = false}) async =>
      null;

  @override
  Future<EsitoDelConsumo?> consuma(
          {required String budget, required String idMovimento}) async =>
      null;

  @override
  Future<int?> muoviGliEos(
          {required String causale,
          required String motivo,
          required String idMovimento,
          int? quanti}) async =>
      null;

  @override
  Future<bool> scriviLaMemoria(
          {required String operazione,
          String? maestro,
          Map<String, Object?> campi = const {}}) async =>
      false;
}
