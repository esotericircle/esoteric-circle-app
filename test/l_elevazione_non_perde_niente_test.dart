import 'package:esoteric_circle/core/identity/account_del_cerchio.dart';
import 'package:esoteric_circle/core/identity/inventario_dell_utente.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// L'ELEVAZIONE NON PERDE NIENTE, ordine N voce 1e.
///
/// La prova non guarda tre cose a mano: FOTOGRAFA tutto cio' che appartiene
/// alla persona, eleva l'account, rifotografa e pretende che le due
/// fotografie coincidano voce per voce. Cosi' un dato nuovo che nascera'
/// domani entra nella sorveglianza il giorno stesso in cui entra
/// nell'inventario, senza che nessuno debba ricordarsene.
///
/// La seconda prova e' il caso che fa perdere tutto: un fornitore che invece
/// di collegarsi all'account che c'e' ne crea un secondo. Deve essere
/// riconosciuto e NON raccontato come una riuscita.
class _PortaFinta implements PortaDellIdentita {
  _PortaFinta({
    required String uid,
    this.creaUnSecondoAccount = false,
    this.esito = EsitoDellaCustodia.riuscita,
  })  : _uid = uid,
        _anonimo = true;

  String _uid;
  bool _anonimo;
  String? _email;
  final List<String> _fornitori = [];

  /// Il difetto da simulare: il fornitore entra invece di collegarsi, e
  /// l'uid cambia. E' cio' che succede davvero usando `signInWithProvider`
  /// al posto di `linkWithProvider`.
  final bool creaUnSecondoAccount;
  final EsitoDellaCustodia esito;

  @override
  String? get uid => _uid;

  @override
  bool get anonimo => _anonimo;

  @override
  String? get email => _email;

  @override
  List<String> get fornitori => List.unmodifiable(_fornitori);

  @override
  Future<String?> assicuraUnAccount() async => _uid;

  @override
  Future<void> ricarica() async {}

  @override
  Future<EsitoDellaCustodia> eleva(
    ViaDellaCustodia via, {
    String? email,
    String? parola,
  }) async {
    if (esito != EsitoDellaCustodia.riuscita) return esito;
    if (creaUnSecondoAccount) _uid = 'un-altro-uid-appena-nato';
    _anonimo = false;
    _email = email ?? 'sofia@esotericircle.app';
    _fornitori.add(switch (via) {
      ViaDellaCustodia.google => 'google.com',
      ViaDellaCustodia.apple => 'apple.com',
      ViaDellaCustodia.email => 'password',
    });
    return EsitoDellaCustodia.riuscita;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const uidAnonimo = 'anonimo-del-primo-giorno';

  /// Una persona che ha gia' vissuto nel Cerchio: memoria, contatori, Eos,
  /// e le sue cose sul dispositivo.
  Future<FakeFirebaseFirestore> unaVitaGiaVissuta() async {
    final db = FakeFirebaseFirestore();
    final utente = db.collection('users').doc(uidAnonimo);
    await utente.set({
      'displayName': 'Sofia',
      'courtesyForm': 'tu',
      'disclaimerAcceptedAt': DateTime(2026, 8, 1),
    });
    for (final maestro in Maestro.values) {
      await utente.collection('maestri').doc(maestro.id).set({
        'facts': ['ha chiesto del lavoro', 'nata sotto il Leone'],
        'sessionSummary': 'Cerca una direzione.',
      });
      await utente
          .collection('maestri')
          .doc(maestro.id)
          .collection('messages')
          .add({'role': 'user', 'text': 'devo cambiare lavoro?'});
    }
    await utente.collection('stato').doc('contatori').set({
      'giorno': '2026-08-11',
      'spesi': {'domande': 2, 'gettate': 1},
    });
    await utente.collection('stato').doc('borsellino').set({'saldo': 40});
    await utente.collection('movimenti').doc('premio-1').set({
      'causale': 'premio_sigillo',
      'importo': 10,
      'saldoDopo': 40,
    });
    SharedPreferences.setMockInitialValues({
      'onboarding.done': true,
      'profile.birthDate': '1990-08-15',
      'profile.natalChart': '{"sunSign":"leo"}',
      'ritual.dawn.streak': 6,
      'allowance.day': '2026-08-11',
      'allowance.count': 2,
    });
    return db;
  }

  testWidgets('cio\' che era suo resta suo, voce per voce', (tester) async {
    final db = await unaVitaGiaVissuta();
    final porta = _PortaFinta(uid: uidAnonimo);
    final account = AccountDelCerchio(porta: porta);
    await account.avvia();
    expect(account.stato, StatoDellAccount.anonimo);

    final prima = await InventarioDellUtente.fotografa(
      uid: account.uid,
      db: db,
      preferenze: await SharedPreferences.getInstance(),
    );
    // La fotografia deve avere dentro qualcosa, altrimenti la prova
    // confronterebbe due vuoti e sarebbe verde per cecita'.
    expect(prima.quante, greaterThan(10),
        reason: 'l\'inventario e\' troppo magro per provare qualcosa');

    final esito = await account.custodisci(ViaDellaCustodia.google);
    expect(esito, EsitoDellaCustodia.riuscita);
    expect(account.stato, StatoDellAccount.custodito,
        reason: 'dopo la custodia l\'account non risulta piu\' anonimo');

    final dopo = await InventarioDellUtente.fotografa(
      uid: account.uid,
      db: db,
      preferenze: await SharedPreferences.getInstance(),
    );
    expect(prima.differenzeCon(dopo), isEmpty,
        reason: 'elevando l\'account si e\' perso qualcosa per strada');
  });

  testWidgets('un fornitore che crea un secondo account non e\' una riuscita',
      (tester) async {
    final db = await unaVitaGiaVissuta();
    final porta = _PortaFinta(uid: uidAnonimo, creaUnSecondoAccount: true);
    final account = AccountDelCerchio(porta: porta);
    await account.avvia();

    final prima = await InventarioDellUtente.fotografa(
      uid: account.uid,
      db: db,
      preferenze: await SharedPreferences.getInstance(),
    );

    final esito = await account.custodisci(ViaDellaCustodia.google);
    expect(esito, EsitoDellaCustodia.cerchioCambiato,
        reason: 'e\' nato un secondo account e l\'app lo ha chiamato '
            'riuscita: e\' la bugia peggiore, proprio dove si e\' promesso '
            'che non si perde niente');

    // E la prova mostra COSA si sarebbe perso, invece di dire solo che
    // qualcosa non torna.
    final dopo = await InventarioDellUtente.fotografa(
      uid: account.uid,
      db: db,
      preferenze: await SharedPreferences.getInstance(),
    );
    final perse = prima.differenzeCon(dopo);
    expect(perse, isNotEmpty);
    expect(perse.where((v) => v.contains('maestri')), isNotEmpty,
        reason: 'con un secondo account la memoria dei Maestri resta '
            'attaccata al primo');
  });

  testWidgets('un\'identita\' gia\' di un altro non butta via il Cerchio',
      (tester) async {
    final porta = _PortaFinta(
      uid: uidAnonimo,
      esito: EsitoDellaCustodia.giaDiUnAltroCerchio,
    );
    final account = AccountDelCerchio(porta: porta);
    await account.avvia();
    final esito = await account.custodisci(ViaDellaCustodia.google);
    expect(esito, EsitoDellaCustodia.giaDiUnAltroCerchio);
    expect(account.uid, uidAnonimo,
        reason: 'il Cerchio anonimo deve restare esattamente dov\'era');
    expect(account.stato, StatoDellAccount.anonimo);
  });

  testWidgets('chi rimanda non perde niente e non viene registrato custodito',
      (tester) async {
    final porta = _PortaFinta(uid: uidAnonimo);
    final account = AccountDelCerchio(porta: porta);
    await account.avvia();
    account.rimanda();
    account.rimanda();
    expect(account.rimandi, 2);
    expect(account.stato, StatoDellAccount.anonimo,
        reason: 'rimandare non deve cambiare lo stato dell\'account');
  });
}
