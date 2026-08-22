import 'package:esoteric_circle/core/identity/account_del_cerchio.dart';
import 'package:esoteric_circle/features/account/custodia_del_cielo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

/// CHI TORNA RIESCE A ENTRARE. Ordine AX voce 01.
///
/// **Il fatto del fondatore, riproducibile.** Disinstalla, reinstalla, tocca
/// "Faccio gia' parte del Cerchio", sceglie lo STESSO account Google.
/// L'accesso non va a buon fine. **E da quel momento non funziona piu' nemmeno
/// la registrazione**: la porta si chiude alle spalle.
///
/// **Le due cause, lette nel codice e non indovinate.**
///
/// UNO: chi torna passava dalla stessa porta di chi custodisce, cioe' da
/// `eleva`, che ATTACCA l'identita' all'anonimo di questo telefono. Ma quella
/// identita' e' gia' di un altro Cerchio, quindi il collegamento **fallisce per
/// forza**. La via d'uscita era un secondo tocco che riusava
/// `_riconosciuta.credenziale`, **la credenziale gia' spesa dal tentativo
/// fallito**: su Google un token speso non entra piu'.
///
/// DUE: `GoogleSignIn().signIn()` lascia il client "gia' entrato". Alla
/// chiamata dopo restituisce lo stesso account **senza riaprire il selettore**,
/// con un token che puo' essere gia' stato speso. **E' il motivo per cui dopo
/// il fallimento non ripartiva nemmeno la registrazione**: non era la
/// registrazione, era Google che rispondeva con cio' che aveva in mano.
///
/// **Si esercita la porta VERA**, `PortaDellIdentitaFirebase`, come fa gia' la
/// prova della custodia nativa: cio' che si finge sta SOTTO, l'auth e il
/// flusso, mai la logica che si vuole misurare. Una porta finta che contasse
/// le proprie dimenticanze misurerebbe se stessa.
void main() {
  // I CINQUE RAMI DI USCITA, enumerati e non campionati. Non sono i sei valori
  // dell'esito: `giaDiUnAltroCerchio` e `cerchioCambiato` nascono
  // dall'elevazione e da qui non si raggiungono. Questi cinque sono tutto cio'
  // che puo' capitare a chi torna.
  final rami = <String, _Ramo>{
    'entra davvero': _Ramo(atteso: EsitoDellaCustodia.riuscita),
    'chiude la finestra di Google': _Ramo(
      atteso: EsitoDellaCustodia.annullata,
      senzaCredenziale: true,
    ),
    'il fornitore dice annullato': _Ramo(
      atteso: EsitoDellaCustodia.annullata,
      codice: 'web-context-canceled',
    ),
    'il Cerchio non c e con quelle chiavi': _Ramo(
      atteso: EsitoDellaCustodia.nonRiconosciuto,
      codice: 'invalid-credential',
    ),
    'la rete non risponde': _Ramo(
      atteso: EsitoDellaCustodia.nonRiuscita,
      codice: 'network-request-failed',
    ),
  };

  rami.forEach((racconto, ramo) {
    test('ramo: $racconto', () async {
      final auth = _AuthFinta(
        _UtenteFinto(uid: 'anonimo'),
        codiceDellIngresso: ramo.codice,
      );
      final flusso = _FlussoCheConta(
          daConsegnare: ramo.senzaCredenziale ? null : _credenzialeDiProva());
      final porta = PortaDellIdentitaFirebase(auth: auth, flussoGoogle: flusso);
      final account = AccountDelCerchio(porta: porta);

      final esito = await account.entraDirettamente(ViaDellaCustodia.google);
      final frase = frasePerEsito(esito);
      // ignore: avoid_print
      print('ORDINE AX VOCE 01, ramo "$racconto": esito ${esito.name}, '
          'dimenticanze ${flusso.dimenticanze}, la persona legge '
          '${frase ?? "niente, e va bene cosi"}');

      expect(esito, ramo.atteso,
          reason: 'il ramo "$racconto" finisce invece in ${esito.name}');

      // **NESSUN RAMO E UN VICOLO CIECO.** Riuscita porta in home e annullata
      // e' la persona che ha chiuso da sola: quelle due tacciono di proposito.
      // Tutte le altre devono dire qualcosa, e non un codice tecnico.
      if (esito != EsitoDellaCustodia.riuscita &&
          esito != EsitoDellaCustodia.annullata) {
        expect(frase, isNotNull,
            reason: 'il ramo "$racconto" non dice niente alla persona');
        expect(frase, isNot(contains(ramo.codice ?? 'codice')),
            reason: 'la frase mostra il codice tecnico del fornitore');
      }

      // **IL CLIENT VA LASCIATO PULITO IN OGNI RAMO**, se no il tentativo
      // successivo riceve cio' che questo ha lasciato in mano.
      expect(flusso.dimenticanze, greaterThan(0),
          reason: 'nel ramo "$racconto" il client di Google non e stato '
              'dimenticato: la porta si chiude alle spalle');
    });
  });

  test('chi torna ENTRA, e non passa mai dall elevazione', () async {
    // **LA CAUSA NUMERO UNO, MISURATA.** Chi torna con un account che e' gia'
    // di un altro Cerchio: se passasse ancora da `linkWithCredential` questo
    // sarebbe `giaDiUnAltroCerchio`, cioe' il fallimento del fondatore.
    final utente = _UtenteFinto(
      uid: 'anonimo',
      codiceDelCollegamento: 'credential-already-in-use',
    );
    final auth = _AuthFinta(utente);
    final flusso = _FlussoCheConta(daConsegnare: _credenzialeDiProva());
    final porta = PortaDellIdentitaFirebase(auth: auth, flussoGoogle: flusso);
    final account = AccountDelCerchio(porta: porta);

    final esito = await account.entraDirettamente(ViaDellaCustodia.google);
    // ignore: avoid_print
    print('ORDINE AX VOCE 01: con un account gia di un altro Cerchio, chi '
        'torna riceve ${esito.name}; collegamenti tentati '
        '${utente.collegamentiTentati}, uid finale ${porta.uid}');

    expect(esito, EsitoDellaCustodia.riuscita,
        reason: 'chi torna non entra, ed e il difetto piu grave della 2191');
    expect(utente.collegamentiTentati, 0,
        reason: 'chi torna passa ancora dall elevazione, che per lui fallisce '
            'per forza');
    expect(porta.uid, 'chi-torna',
        reason: 'l ingresso non ha cambiato utente: non e entrato nessuno');
  });

  test('la credenziale e SEMPRE fresca, e chiesta DOPO il dimentica', () async {
    // **UN TOKEN SPESO NON ENTRA PIU'.** Non basta che la credenziale venga
    // chiesta: va chiesta DOPO aver dimenticato, se no il selettore non si
    // riapre e il token e' quello di prima. Qui si guarda l'ordine dei fatti.
    final auth = _AuthFinta(_UtenteFinto(uid: 'anonimo'));
    final flusso = _FlussoCheConta(daConsegnare: _credenzialeDiProva());
    final porta = PortaDellIdentitaFirebase(auth: auth, flussoGoogle: flusso);

    await porta.entraDirettamente(ViaDellaCustodia.google);
    // ignore: avoid_print
    print('ORDINE AX VOCE 01: il flusso ha visto ${flusso.diario}');

    expect(flusso.credenzialiChieste, 1,
        reason: 'nessuna credenziale nuova e stata chiesta: si sta riusando '
            'quella di prima');
    expect(flusso.diario.first, 'dimentica',
        reason: 'la credenziale e stata chiesta PRIMA di dimenticare: il '
            'selettore non si riapre e il token puo essere gia speso');
  });

  test('dopo un fallimento la porta resta aperta', () async {
    // **LA GARANZIA NUMERO DUE DELL'ORDINE**: si puo' riprovare subito, senza
    // chiudere e riaprire l'app. Il primo tentativo cade sulla rete, e il
    // secondo entra.
    final auth = _AuthFinta(
      _UtenteFinto(uid: 'anonimo'),
      codiceDellIngresso: 'network-request-failed',
      soloIlPrimo: true,
    );
    final flusso = _FlussoCheConta(daConsegnare: _credenzialeDiProva());
    final porta = PortaDellIdentitaFirebase(auth: auth, flussoGoogle: flusso);
    final account = AccountDelCerchio(porta: porta);

    final primo = await account.entraDirettamente(ViaDellaCustodia.google);
    final secondo = await account.entraDirettamente(ViaDellaCustodia.google);
    // ignore: avoid_print
    print('ORDINE AX VOCE 01: primo tentativo ${primo.name}, secondo '
        '${secondo.name}, il flusso ha visto ${flusso.diario}');

    expect(primo, EsitoDellaCustodia.nonRiuscita);
    expect(secondo, EsitoDellaCustodia.riuscita,
        reason: 'dopo un fallimento il secondo tentativo non entra: la porta '
            'si e chiusa alle spalle, ed e cio che il fondatore ha visto');
    expect(flusso.dimenticanze, greaterThanOrEqualTo(2),
        reason: 'fra un tentativo e l altro il client non viene dimenticato');
  });

  test('anche l elevazione fallita lascia il client pulito', () async {
    // **IL FONDATORE HA VISTO CHE NON RIPARTIVA NEMMENO LA REGISTRAZIONE.**
    // Quella passa da `eleva`: anche li' il client va lasciato pulito, se no
    // il tentativo dopo riceve il token gia' speso da questo.
    final utente = _UtenteFinto(
      uid: 'anonimo',
      codiceDelCollegamento: 'credential-already-in-use',
    );
    final auth = _AuthFinta(utente);
    final flusso = _FlussoCheConta(daConsegnare: _credenzialeDiProva());
    final porta = PortaDellIdentitaFirebase(auth: auth, flussoGoogle: flusso);
    final account = AccountDelCerchio(porta: porta);

    final esito = await account.custodisci(ViaDellaCustodia.google);
    // ignore: avoid_print
    print('ORDINE AX VOCE 01: elevazione fallita con ${esito.name}, il flusso '
        'ha visto ${flusso.diario}');

    expect(esito, EsitoDellaCustodia.giaDiUnAltroCerchio);
    expect(flusso.dimenticanze, greaterThan(0),
        reason: 'dopo un elevazione fallita il client resta con l account in '
            'mano, e il tentativo dopo riceve quello');
  });
}

class _Ramo {
  _Ramo({required this.atteso, this.codice, this.senzaCredenziale = false});

  final EsitoDellaCustodia atteso;
  final String? codice;
  final bool senzaCredenziale;
}

/// La credenziale finta: e' un oggetto dati, costruirla non tocca la rete.
AuthCredential _credenzialeDiProva() => GoogleAuthProvider.credential(
      idToken: 'id-token-di-prova',
      accessToken: 'access-token-di-prova',
    );

/// IL FLUSSO CHE TIENE UN DIARIO: registra in che ORDINE gli si e' parlato.
class _FlussoCheConta implements PortaDelFlussoGoogle {
  _FlussoCheConta({required this.daConsegnare});

  final AuthCredential? daConsegnare;
  final List<String> diario = [];

  int get dimenticanze => diario.where((v) => v == 'dimentica').length;
  int get credenzialiChieste => diario.where((v) => v == 'credenziale').length;

  @override
  Future<void> dimentica() async => diario.add('dimentica');

  @override
  Future<AuthCredential?> credenziale() async {
    diario.add('credenziale');
    return daConsegnare;
  }

  @override
  Future<String?> nomeGiaAutorizzato() async => null;
}

/// L'AUTH FINTA: chi entra diventa un ALTRO utente, ed e' il punto.
class _AuthFinta implements FirebaseAuth {
  _AuthFinta(this._utente, {this.codiceDellIngresso, this.soloIlPrimo = false});

  _UtenteFinto? _utente;
  final String? codiceDellIngresso;
  final bool soloIlPrimo;
  int ingressi = 0;

  @override
  User? get currentUser => _utente;

  @override
  Future<UserCredential> signInWithCredential(AuthCredential credential) async {
    ingressi++;
    final codice = codiceDellIngresso;
    if (codice != null && (!soloIlPrimo || ingressi == 1)) {
      throw FirebaseAuthException(code: codice);
    }
    _utente = _UtenteFinto(uid: 'chi-torna', gia: true);
    return _CredenzialeUtenteFinta();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// L'UTENTE FINTO: registra i collegamenti che gli vengono TENTATI, non solo
/// quelli riusciti: e' l'unico modo di dire se chi torna sta ancora elevando.
class _UtenteFinto implements User {
  _UtenteFinto({
    required String uid,
    this.codiceDelCollegamento,
    bool gia = false,
  })  : _uid = uid,
        _gia = gia;

  final String _uid;
  final bool _gia;
  final String? codiceDelCollegamento;
  final List<AuthCredential> credenzialiCollegate = [];
  int collegamentiTentati = 0;

  @override
  String get uid => _uid;

  @override
  bool get isAnonymous => !_gia && credenzialiCollegate.isEmpty;

  @override
  String? get email => null;

  @override
  List<UserInfo> get providerData => credenzialiCollegate
      .map((c) => _FornitoreFinto(c.providerId))
      .toList(growable: false);

  @override
  Future<UserCredential> linkWithCredential(AuthCredential credential) async {
    collegamentiTentati++;
    final codice = codiceDelCollegamento;
    if (codice != null) throw FirebaseAuthException(code: codice);
    credenzialiCollegate.add(credential);
    return _CredenzialeUtenteFinta();
  }

  @override
  Future<void> reload() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FornitoreFinto implements UserInfo {
  _FornitoreFinto(this.providerId);

  @override
  final String providerId;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _CredenzialeUtenteFinta implements UserCredential {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
