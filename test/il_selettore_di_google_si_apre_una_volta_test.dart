// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/identity/account_del_cerchio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL SELETTORE DI GOOGLE SI APRE UNA VOLTA SOLA. Ordine EA voci 10 e 11,
/// 20 settembre 2026.
///
/// **Il fatto, misurato sul Realme** e non dedotto: dal menu' utente, con il
/// telefono anonimo, *Continua con Google* apre il selettore, e il primo
/// tentativo **non entra**: a video compare *"Quell'identita' vive gia' in un
/// altro Cerchio. Puoi entrarci qui sotto"*. Il collegamento e' fallito con
/// `credential-already-in-use`, che e' giusto, perche' quell'identita' e'
/// davvero di un altro Cerchio.
///
/// **Cosa costava.** Il *"Continua come"* rifaceva tutta la strada, cioe'
/// dimenticava il client e chiedeva una credenziale nuova: **il selettore si
/// riapriva**, e la persona doveva scegliere il proprio account due volte per
/// entrare una.
///
/// **La cura.** Firebase mette dentro l'errore una credenziale **fresca**,
/// che non e' il gettone speso dal tentativo: con quella si entra senza
/// chiedere di nuovo chi sei. La strada di prima resta come rete, e questa
/// guardia pretende tutte e due le cose.
///
/// **La conferma resta, ed e' una decisione**: entrare in quel Cerchio
/// sostituisce Eos e ricordi di questo telefono, e il foglio lo dice prima di
/// farlo. Togliere quella conferma per risparmiare un tocco vorrebbe dire
/// cambiare i dati di qualcuno senza dirglielo.
void main() {
  AuthCredential quellaDelRifiuto() => GoogleAuthProvider.credential(
        idToken: 'id-token-dal-rifiuto',
        accessToken: 'access-token-dal-rifiuto',
      );

  AuthCredential quellaSpesa() => GoogleAuthProvider.credential(
        idToken: 'id-token-speso',
        accessToken: 'access-token-speso',
      );

  test(
      'col rifiuto che porta la credenziale, si entra senza riaprire il '
      'selettore', () async {
    final flusso = _FlussoCheConta(daConsegnare: quellaSpesa());
    final auth = _AuthFinta(
      _UtenteFinto(
          uid: 'anonimo',
          codiceDelCollegamento: 'credential-already-in-use',
          credenzialeDelRifiuto: quellaDelRifiuto()),
      credenzialeDelRifiuto: quellaDelRifiuto(),
    );
    final porta = PortaDellIdentitaFirebase(auth: auth, flussoGoogle: flusso);

    final primo = await porta.eleva(ViaDellaCustodia.google);
    expect(primo, EsitoDellaCustodia.giaDiUnAltroCerchio,
        reason: 'il primo tentativo doveva riconoscere un altro Cerchio');
    expect(porta.riconosciuta?.dallErrore, isTrue,
        reason: 'la credenziale del rifiuto non e\' stata tenuta, quindi il '
            'selettore si riaprira\'');

    final apertePrima = flusso.credenzialiChieste;
    final secondo = await porta.entraComeRiconosciuto();
    print('ORDINE EA VOCE 11: esito ${secondo.name}, selettore aperto '
        '$apertePrima volta, poi ${flusso.credenzialiChieste}');
    expect(secondo, EsitoDellaCustodia.riuscita);
    expect(flusso.credenzialiChieste, apertePrima,
        reason: 'il selettore di Google si e\' riaperto: la persona sceglie '
            'il proprio account due volte per entrare una');
    expect(auth.credenzialiUsate.single.token, quellaDelRifiuto().token,
        reason: 'si e\' entrati con una credenziale che non e\' quella del '
            'rifiuto');
  });

  test('se quella credenziale non entra, la strada di prima resta', () async {
    // **LA RETE, e serve**: con altre vie, o con un fornitore che non
    // consegna niente nell'errore, il rientro deve continuare a funzionare
    // come prima, cioe' rifacendo il giro.
    final flusso = _FlussoCheConta(daConsegnare: quellaSpesa());
    final auth = _AuthFinta(
      _UtenteFinto(
          uid: 'anonimo',
          codiceDelCollegamento: 'credential-already-in-use',
          credenzialeDelRifiuto: quellaDelRifiuto()),
      credenzialeDelRifiuto: quellaDelRifiuto(),
      primoIngressoFallisce: true,
    );
    final porta = PortaDellIdentitaFirebase(auth: auth, flussoGoogle: flusso);

    await porta.eleva(ViaDellaCustodia.google);
    final esito = await porta.entraComeRiconosciuto();
    print('ORDINE EA VOCE 11, rete: esito ${esito.name}, selettore aperto '
        '${flusso.credenzialiChieste} volte');
    expect(esito, EsitoDellaCustodia.riuscita,
        reason: 'la rete non ha retto: chi arriva da una via senza '
            'credenziale nel rifiuto resta fuori');
    expect(flusso.credenzialiChieste, greaterThanOrEqualTo(2),
        reason: 'la strada di prima non e\' stata rifatta');
  });

  test('senza credenziale nel rifiuto non si finge di averla', () async {
    final flusso = _FlussoCheConta(daConsegnare: quellaSpesa());
    final auth = _AuthFinta(
      _UtenteFinto(
          uid: 'anonimo', codiceDelCollegamento: 'credential-already-in-use'),
      credenzialeDelRifiuto: null,
    );
    final porta = PortaDellIdentitaFirebase(auth: auth, flussoGoogle: flusso);
    await porta.eleva(ViaDellaCustodia.google);
    expect(porta.riconosciuta?.dallErrore, isFalse,
        reason: 'la credenziale tentata da noi e\' gia\' spesa: dichiararla '
            'buona farebbe fallire il rientro senza rete');
  });
}

class _FlussoCheConta implements PortaDelFlussoGoogle {
  _FlussoCheConta({required this.daConsegnare});

  final AuthCredential? daConsegnare;
  final List<String> diario = [];

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

class _AuthFinta implements FirebaseAuth {
  _AuthFinta(this._utente,
      {this.credenzialeDelRifiuto, this.primoIngressoFallisce = false});

  _UtenteFinto? _utente;
  final AuthCredential? credenzialeDelRifiuto;
  final bool primoIngressoFallisce;
  final List<AuthCredential> credenzialiUsate = [];

  @override
  User? get currentUser => _utente;

  @override
  Future<UserCredential> signInWithCredential(AuthCredential credential) async {
    credenzialiUsate.add(credential);
    if (primoIngressoFallisce && credenzialiUsate.length == 1) {
      throw FirebaseAuthException(code: 'invalid-credential');
    }
    _utente = _UtenteFinto(uid: 'chi-torna', gia: true);
    return _CredenzialeUtenteFinta();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UtenteFinto implements User {
  _UtenteFinto({
    required String uid,
    this.codiceDelCollegamento,
    this.credenzialeDelRifiuto,
    bool gia = false,
  })  : _uid = uid,
        _gia = gia;

  final String _uid;
  final bool _gia;
  final String? codiceDelCollegamento;

  /// Quella che Firebase mette DENTRO l'errore, che e' il punto della prova.
  final AuthCredential? credenzialeDelRifiuto;

  @override
  String get uid => _uid;

  @override
  bool get isAnonymous => !_gia;

  @override
  Future<UserCredential> linkWithCredential(AuthCredential credential) async {
    final codice = codiceDelCollegamento;
    if (codice != null) {
      throw FirebaseAuthException(
          code: codice,
          email: 'chi@torna.it',
          credential: credenzialeDelRifiuto);
    }
    return _CredenzialeUtenteFinta();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _CredenzialeUtenteFinta implements UserCredential {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
