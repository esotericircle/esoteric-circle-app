import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/services/memory/firestore_maestro_memory_repository.dart';
import 'package:esoteric_circle/core/cammino/cammino_da_custodire.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// CIO' CHE VIVE SUL SERVER, ordine N voce 2f: le tre prove di accettazione.
///
/// 1. reinstallazione con lo stesso account: contatori non azzerati, memoria
///    tornata, saldo tornato;
/// 2. orologio del dispositivo spostato avanti e indietro di un giorno: i
///    contatori non cambiano;
/// 3. un client che prova a scriversi saldo o contatori viene respinto dalle
///    regole vere. La terza gira contro l'emulatore Firestore con le regole
///    vere caricate (`npm run test:regole` dentro functions/), perche' una
///    prova sulle regole scritta in Dart proverebbe solo la nostra idea delle
///    regole. Qui resta la guardia che quelle regole vengano DISTRIBUITE:
///    esistevano da settimane e `firebase.json` non le nominava, quindi
///    nessun comando le mandava mai al progetto.
class _ServerFinto extends PortaDelCerchio {
  _ServerFinto({
    this.giorno = '2026-08-11',
    Map<String, int>? spesi,
    this.saldo = 0,
  }) : spesi = spesi ?? {};

  String giorno;
  final Map<String, int> spesi;
  int saldo;

  /// Gli identificativi gia' visti: il server non conta due volte lo stesso
  /// gesto, ed e' cio' che rende innocuo il rimando dei gesti offline.
  final Set<String> visti = {};

  /// Quando e' falso il server non risponde: la rete che non c'e'.
  bool risponde = true;

  static const _limiti = {
    'domande': 3,
    'approfondimenti': 0,
    'confronti': 0,
    'gettate': 3,
  };

  @override
  bool get viva => true;

  @override
  Future<StatoDelCerchio?> stato(
      {CamminoDaCustodire? cammino, bool azzeraIlCammino = false}) async {
    if (!risponde) return null;
    return StatoDelCerchio(
      giorno: giorno,
      piano: 'free',
      spesi: Map<String, int>.from(spesi),
      saldoEos: saldo,
    );
  }

  @override
  Future<EsitoDelConsumo?> consuma({
    required String budget,
    required String idMovimento,
  }) async {
    if (!risponde) return null;
    if (visti.contains(idMovimento)) {
      return const EsitoDelConsumo(concesso: true);
    }
    visti.add(idMovimento);
    final limite = _limiti[budget] ?? 0;
    final gia = spesi[budget] ?? 0;
    if (gia >= limite) {
      return const EsitoDelConsumo(concesso: false, resta: 0);
    }
    spesi[budget] = gia + 1;
    return EsitoDelConsumo(concesso: true, resta: limite - spesi[budget]!);
  }

  @override
  Future<int?> muoviGliEos({
    required String causale,
    required String motivo,
    required String idMovimento,
    int? quanti,
  }) async {
    if (!risponde || visti.contains(idMovimento)) return saldo;
    visti.add(idMovimento);
    saldo += causale == 'spesa' ? -(quanti ?? 0) : 10;
    return saldo;
  }

  @override
  Future<bool> scriviLaMemoria({
    required String operazione,
    String? maestro,
    Map<String, Object?> campi = const {},
  }) async =>
      risponde;

  @override
  Future<bool> cancellaIlCerchio() async => risponde;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const uid = 'la-stessa-persona';

  group('Prova 1: la reinstallazione non cancella piu\' niente', () {
    test('contatori, memoria e saldo tornano con lo stesso account', () async {
      final server = _ServerFinto(saldo: 40);
      final db = FakeFirebaseFirestore();
      final memoria = FirestoreMaestroMemoryRepository(uid: uid, firestore: db);
      SharedPreferences.setMockInitialValues({});

      // Il primo telefono: due domande fatte e una conversazione.
      final primo = QuestionAllowance(porta: server);
      await primo.load();
      await primo.sincronizza();
      primo.record(Tier.free);
      primo.record(Tier.free);
      await Future<void>.delayed(Duration.zero);
      expect(primo.remaining(Tier.free), 1);
      await memoria.appendMessage(
        Maestro.medora,
        const ChatMessage(role: ChatRole.user, text: 'devo cambiare lavoro?'),
      );

      // LA REINSTALLAZIONE: il dispositivo non porta piu' niente con se'.
      // Il file delle preferenze e' perfino escluso dal backup di Android,
      // quindi questo e' esattamente cio' che vede chi reinstalla.
      SharedPreferences.setMockInitialValues({});
      final dopo = QuestionAllowance(porta: server);
      await dopo.load();
      await dopo.sincronizza();

      expect(dopo.remaining(Tier.free), 1,
          reason: 'reinstallando, le domande del giorno sono tornate intere: '
              'il limite si aggira disinstallando l\'app');
      expect(dopo.saldoEos, 40,
          reason: 'il saldo Eos non e\' tornato con l\'account');

      final tornati = await memoria.recentMessages(Maestro.medora);
      expect(tornati, hasLength(1),
          reason: 'la memoria non e\' tornata: e\' morta col telefono');
      expect(tornati.first.text, contains('cambiare lavoro'));
    });

    test('i gesti fatti senza rete arrivano dopo, e una volta sola', () async {
      final server = _ServerFinto();
      SharedPreferences.setMockInitialValues({});
      final borsa = QuestionAllowance(porta: server);
      await borsa.load();
      await borsa.sincronizza();

      // La rete cade. Il gesto si compie lo stesso, e resta in coda.
      server.risponde = false;
      borsa.record(Tier.free);
      borsa.record(Tier.free);
      await Future<void>.delayed(Duration.zero);
      expect(borsa.gestiInAttesa, 2,
          reason: 'senza rete i gesti devono restare in coda, non sparire');
      expect(server.spesi['domande'] ?? 0, 0);

      // La rete torna: partono tutti e il server li conta una volta sola.
      server.risponde = true;
      await borsa.sincronizza();
      expect(borsa.gestiInAttesa, 0);
      expect(server.spesi['domande'], 2,
          reason: 'i gesti fatti senza rete non sono arrivati al server');
      await borsa.sincronizza();
      expect(server.spesi['domande'], 2,
          reason: 'una seconda sincronizzazione ha contato due volte gli '
              'stessi gesti');
    });
  });

  group('Prova 2: l\'orologio del telefono non conta piu\'', () {
    test('spostato avanti e indietro di un giorno, i contatori non cambiano',
        () async {
      var adesso = DateTime(2026, 8, 11, 10);
      final server = _ServerFinto(
          giorno: '2026-08-11', spesi: {'domande': 3, 'gettate': 3});
      SharedPreferences.setMockInitialValues({});
      final borsa = QuestionAllowance(clock: () => adesso, porta: server);
      await borsa.load();
      await borsa.sincronizza();
      expect(borsa.remaining(Tier.free), 0);
      expect(borsa.gettateRimaste(Tier.free), 0);

      adesso = DateTime(2026, 8, 12, 10);
      expect(borsa.remaining(Tier.free), 0,
          reason: 'spostando l\'orologio avanti di un giorno le domande sono '
              'tornate: il limite lo decide ancora il telefono');
      expect(borsa.gettateRimaste(Tier.free), 0,
          reason: 'spostando l\'orologio avanti di un giorno le gettate sono '
              'tornate');

      adesso = DateTime(2026, 8, 10, 10);
      expect(borsa.remaining(Tier.free), 0,
          reason: 'spostando l\'orologio indietro di un giorno i contatori '
              'sono cambiati');

      // E quando il giorno cambia DAVVERO, cioe' lo dice il server, i budget
      // tornano interi: il presidio non deve aver murato il ribaltamento.
      server
        ..giorno = '2026-08-12'
        ..spesi.clear();
      await borsa.sincronizza();
      expect(borsa.remaining(Tier.free), 3,
          reason: 'col giorno nuovo dichiarato dal server i budget devono '
              'tornare interi');
    });
  });

  group('Prova 3: le regole vere respingono il client', () {
    test('le regole sono dichiarate per la distribuzione', () {
      final config = jsonDecode(File('firebase.json').readAsStringSync());
      expect(config['firestore'], isNotNull,
          reason: 'firebase.json non nomina le regole di Firestore: erano '
              'nel repository da settimane e nessun comando le distribuiva, '
              'quindi il progetto girava con quelle della console e nessuno '
              'sapeva quali fossero');
      expect(config['firestore']['rules'], 'firestore.rules');
      expect(File('firestore.rules').existsSync(), isTrue);
    });

    test('nel testo delle regole non c\'e\' nessuna scrittura concessa', () {
      // I COMMENTI FUORI PRIMA DI GUARDARE: dentro c'e' scritta, per
      // spiegarla, proprio la riga vietata che questa prova cerca. La prima
      // stesura ci e' cascata e accusava il commento che racconta il difetto.
      final regole = const LineSplitter()
          .convert(File('firestore.rules').readAsStringSync())
          .where((riga) => !riga.trimLeft().startsWith('//'))
          .join(' ');
      final concesse = RegExp(r'allow\s+[^:]*:[^;]*;')
          .allMatches(regole)
          .map((m) => m.group(0)!)
          .where((riga) => !riga.contains('if false'))
          .where((riga) => !riga.startsWith('allow read:'))
          .toList();
      expect(concesse, isEmpty,
          reason: 'una scrittura del client e\' stata riaperta nelle regole: '
              '$concesse. La verifica vera gira contro l\'emulatore con '
              '`npm run test:regole` dentro functions/, questa e\' la '
              'sentinella che sta nella suite di tutti i giorni');
    });
  });
}
