import 'package:esoteric_circle/core/identity/account_del_cerchio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA CUSTODIA CON GOOGLE PASSA DAL FLUSSO NATIVO. Ordine AD voce 01.
///
/// **Perche' queste prove esistono.** Il 16 agosto 2026, sul telefono vero, la
/// custodia con Google e' morta al ritorno dal consenso: il fornitore federato
/// di Firebase apre la pagina web su firebaseapp.com, e i browser Android con lo
/// storage partizionato non reggono il flusso via redirect. La via d'uscita e'
/// il flusso nativo agganciato con `linkWithCredential`, e queste prove
/// esercitano la porta VERA, `PortaDellIdentitaFirebase.eleva`, non una
/// controfigura: cio' che si finge sta sotto, l'auth e il flusso, non la logica
/// che si vuole provare.
///
/// **Nessuna prova apre una finestra o tocca la rete**: il flusso finto consegna
/// una credenziale costruita a mano, e l'auth finta registra cosa le viene
/// chiesto.
void main() {
  test('riuscita: stesso uid prima e dopo, e google.com fra i fornitori',
      () async {
    final utente = _UtenteFinto(uid: 'cerchio-1');
    final auth = _AuthFinta(utente);
    final flusso = _FlussoFinto(daConsegnare: _credenzialeDiProva());
    final porta = PortaDellIdentitaFirebase(auth: auth, flussoGoogle: flusso);
    final account = AccountDelCerchio(porta: porta);

    final prima = porta.uid;
    final esito = await account.custodisci(ViaDellaCustodia.google);

    expect(esito, EsitoDellaCustodia.riuscita);
    // **SUL VALORE, non sulla prosa**: l'uid di prima e quello di dopo.
    expect(prima, 'cerchio-1');
    expect(porta.uid, prima,
        reason: 'l\'elevazione ha cambiato uid: non era un\'elevazione');
    expect(porta.fornitori, contains('google.com'),
        reason: 'dopo la custodia i fornitori devono portare google.com');
    expect(utente.credenzialiCollegate, hasLength(1),
        reason: 'la credenziale del flusso nativo deve arrivare a '
            'linkWithCredential, una volta sola');
  });

  test('annullata: il flusso che torna vuoto non e\' un errore', () async {
    final utente = _UtenteFinto(uid: 'cerchio-1');
    final auth = _AuthFinta(utente);
    final flusso = _FlussoFinto(daConsegnare: null);
    final porta = PortaDellIdentitaFirebase(auth: auth, flussoGoogle: flusso);

    final esito = await porta.eleva(ViaDellaCustodia.google);

    expect(esito, EsitoDellaCustodia.annullata,
        reason: 'chi chiude la finestra del fornitore non ha sbagliato niente: '
            'annullata, non nonRiuscita');
    expect(utente.credenzialiCollegate, isEmpty,
        reason: 'senza credenziale non si deve nemmeno provare a collegare');
  });

  test('giaDiUnAltroCerchio: credential-already-in-use produce quell\'esito',
      () async {
    // **E' UN CASO VERO, non teorico**: in console esiste gia' un utente Google
    // del 14 agosto, quindi il primo collaudo dal telefono puo' cadere proprio
    // qui, e deve dirlo a schermo invece di dire "non riuscita".
    final utente = _UtenteFinto(
      uid: 'cerchio-1',
      erroreDelCollegamento:
          FirebaseAuthException(code: 'credential-already-in-use'),
    );
    final auth = _AuthFinta(utente);
    final flusso = _FlussoFinto(daConsegnare: _credenzialeDiProva());
    final porta = PortaDellIdentitaFirebase(auth: auth, flussoGoogle: flusso);

    final esito = await porta.eleva(ViaDellaCustodia.google);

    expect(esito, EsitoDellaCustodia.giaDiUnAltroCerchio);
  });

  test('cerchioCambiato: se l\'uid cambia, il presidio lo dice anche qui',
      () async {
    // Il fornitore che cambia persona sotto i piedi: dopo il collegamento
    // l'auth risponde con un ALTRO utente. Il presidio vive in custodisci e
    // deve mordere anche sulla via nativa.
    final utente = _UtenteFinto(uid: 'cerchio-1');
    final auth = _AuthFinta(utente);
    final flusso = _FlussoFinto(
      daConsegnare: _credenzialeDiProva(),
      dopoIlFlusso: () => auth.cambiaUtente(_UtenteFinto(uid: 'cerchio-2')),
    );
    final porta = PortaDellIdentitaFirebase(auth: auth, flussoGoogle: flusso);
    final account = AccountDelCerchio(porta: porta);

    final esito = await account.custodisci(ViaDellaCustodia.google);

    expect(esito, EsitoDellaCustodia.cerchioCambiato,
        reason: 'l\'uid e\' cambiato durante la custodia: raccontarla come '
            'riuscita sarebbe la bugia peggiore possibile');
  });
}

/// La credenziale finta: e' un oggetto dati, costruirla non tocca la rete.
AuthCredential _credenzialeDiProva() => GoogleAuthProvider.credential(
      idToken: 'id-token-di-prova',
      accessToken: 'access-token-di-prova',
    );

/// IL FLUSSO FINTO: consegna cio' che gli si e' detto di consegnare.
class _FlussoFinto implements PortaDelFlussoGoogle {
  _FlussoFinto({required this.daConsegnare, this.dopoIlFlusso});

  final AuthCredential? daConsegnare;

  /// Cosa succede appena il flusso e' finito: serve alla prova del fornitore
  /// che cambia persona sotto i piedi.
  final void Function()? dopoIlFlusso;

  @override
  Future<AuthCredential?> credenziale() async {
    dopoIlFlusso?.call();
    return daConsegnare;
  }
}

/// L'AUTH FINTA: risponde con l'utente che tiene in mano.
class _AuthFinta implements FirebaseAuth {
  _AuthFinta(this._utente);

  _UtenteFinto? _utente;

  void cambiaUtente(_UtenteFinto nuovo) => _utente = nuovo;

  @override
  User? get currentUser => _utente;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// L'UTENTE FINTO: registra le credenziali che gli vengono collegate.
class _UtenteFinto implements User {
  _UtenteFinto({required String uid, this.erroreDelCollegamento}) : _uid = uid;

  final String _uid;
  final FirebaseAuthException? erroreDelCollegamento;
  final List<AuthCredential> credenzialiCollegate = [];

  @override
  String get uid => _uid;

  @override
  bool get isAnonymous => credenzialiCollegate.isEmpty;

  @override
  String? get email => null;

  @override
  List<UserInfo> get providerData => credenzialiCollegate
      .map((c) => _FornitoreFinto(c.providerId))
      .toList(growable: false);

  @override
  Future<UserCredential> linkWithCredential(AuthCredential credential) async {
    final errore = erroreDelCollegamento;
    if (errore != null) throw errore;
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
