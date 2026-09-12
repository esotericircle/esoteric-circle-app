import 'package:esoteric_circle/core/identity/account_del_cerchio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/identity/dimenticanza_del_telefono.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SI ESCE, SI CANCELLA DAVVERO, E SI SA CHI SI E'. Ordine AZ, voci 07, 08
/// e 09. Situazioni S09, S13, S23, S24, S25 e S36 del censimento.
///
/// **Tre buchi misurati contando le occorrenze in `lib/`, non a memoria.**
///
/// **S23, uscire: non esisteva.** In tutto `lib/` c'era un `signOut` solo,
/// quello di Google dentro `dimentica()`, e **non toccava Firebase**. Chi
/// sceglieva l'account sbagliato (S09) non aveva nessuna via di ritorno, e
/// due persone sullo stesso telefono (S13) non erano previste: la seconda
/// ereditava il Cerchio della prima.
///
/// **S24, cancellare: sul server era gia' intero.** La callable
/// `cancellaIlCerchio` fa `recursiveDelete` del ramo e `deleteUser`
/// dell'account. **Mancava il "qui"** che il testo prometteva: sul telefono
/// restavano il diario, i dati di nascita e la preferenza del rito, quindi
/// chi ricominciava si ritrovava il cammino di prima sopra un Cerchio che non
/// esisteva piu'.
///
/// **S36, sapere chi si e': non c'era nessuna riga**, in nessuna schermata.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues(const {}));

  test('la dimenticanza toglie cio che e di una persona e lascia il resto',
      () async {
    // **LE CHIAVI SONO QUELLE VERE, e la prima stesura sbagliava.** Il file
    // nasceva con nove chiavi scritte a memoria, e **nessuna delle nove
    // esisteva**: le chiavi vere si leggono nelle costanti di `lib/`. Per
    // questo adesso si ragiona per prefisso.
    SharedPreferences.setMockInitialValues(const {
      'onboarding.done': true,
      'cammino.gesti': '{}',
      'cammino.accesi': '[]',
      'allowance.saldoEos': 445,
      'profile.name': 'Mauro',
      'archetipo.storico': '[]',
      'borsellino.movimenti': '[]',
      'account.ultimoInvito': '2026-08-22',
      'santuario.greeted': true,
      // **QUESTE DEVONO RESTARE**: sono come il telefono e' stato regolato,
      // non chi lo usa. Buttarle vorrebbe dire punire chi esce, e rimettere a
      // mano un'accessibilita' che qualcuno aveva scelto per necessita'.
      'settings.reduceAnimations': true,
      'settings.simpleMode': false,
      'settings.subtitles': true,
    });
    final prefs = await SharedPreferences.getInstance();
    final prima = prefs.getKeys().length;

    final quante = await DimenticanzaDelTelefono.dimentica();

    final dopo = await SharedPreferences.getInstance();
    final rimaste = dopo.getKeys().toList()..sort();
    // ignore: avoid_print
    print('ORDINE AZ VOCE 07: chiavi prima $prima, dimenticate $quante, '
        'rimaste $rimaste');

    expect(quante, 9,
        reason: 'non sono state dimenticate tutte e nove le chiavi che '
            'appartengono alla persona');
    expect(
        rimaste,
        [
          'settings.reduceAnimations',
          'settings.simpleMode',
          'settings.subtitles'
        ],
        reason: 'sono state buttate anche le regolazioni del telefono, che '
            'non sono di nessuno');
    expect(dopo.getBool('onboarding.done'), isNull,
        reason: 'il rito resterebbe segnato come gia fatto per chi arriva '
            'dopo');
    expect(dopo.getInt('allowance.saldoEos'), isNull,
        reason: 'il saldo di chi se ne va resterebbe in mano al prossimo');
  });

  test('uscire chiude la sessione, dimentica il telefono, e lascia un anonimo',
      () async {
    SharedPreferences.setMockInitialValues(const {
      'onboarding.done': true,
      'cammino.gesti': '{"alba":3}',
      'settings.simpleMode': true,
    });
    final porta = _PortaCheRegistra();
    final account = AccountDelCerchio(porta: porta);

    await account.esci();

    final prefs = await SharedPreferences.getInstance();
    // ignore: avoid_print
    print('ORDINE AZ VOCE 07: uscite ${porta.uscite}, anonimo dopo '
        '${porta.anonimo}, chiavi rimaste ${prefs.getKeys().toList()}');

    expect(porta.uscite, 1,
        reason: 'uscire non chiude nessuna sessione: e il buco S23');
    expect(porta.anonimo, isTrue,
        reason: 'dopo l uscita non resta nessuna identita: l app senza uid '
            'non sta in piedi');
    expect(prefs.getKeys(), ['settings.simpleMode'],
        reason: 'il telefono ricorda ancora il cammino di chi e uscito: chi '
            'entra dopo se lo ritrova, ed e la situazione S13');
  });

  test(
      'sulla porta VERA: prima si dimentica Google, poi si esce, poi si '
      'rientra anonimi', () async {
    // **SI ESERCITA LA PORTA VERA**, come gia' in AX voce 01: una porta finta
    // che registrasse la sequenza che le si e' insegnata misurerebbe se
    // stessa. Qui si finge solo cio' che sta SOTTO, l'auth e il flusso.
    //
    // L'ordine dei tre gesti non e' un dettaglio. Senza il `dimentica` in
    // testa, il client di Google resta con l'account in mano e chi entra
    // dopo si ritrova quello di prima **senza nemmeno vedere il selettore**:
    // e' il difetto curato in AX voce 01, e qui sarebbe peggio, perche'
    // uscire serve proprio a cambiare persona.
    final flusso = _FlussoCheConta();
    final auth = _AuthCheConta();
    final porta = PortaDellIdentitaFirebase(auth: auth, flussoGoogle: flusso);

    await porta.esci();

    final diario = [...flusso.diario, ...auth.diario]..sort();
    // ignore: avoid_print
    print('ORDINE AZ VOCE 07, porta vera: il flusso ha visto ${flusso.diario}, '
        "l auth ha visto ${auth.diario}");

    expect(flusso.diario, ['dimentica'],
        reason: 'la porta vera non dimentica il client di Google quando si '
            'esce: chi entra dopo riceve l account di chi e uscito');
    expect(auth.diario, ['signOut', 'signInAnonymously'],
        reason: 'la porta vera non chiude la sessione, oppure non rientra '
            'come anonima: senza uid l app non sta in piedi');
    expect(diario, hasLength(3));
  });
  test('uscendo, il borsellino dimentica i numeri di chi se ne va', () async {
    // **IL DISCO NON BASTA.** Ordine AZ voce 15: uscire cancella le chiavi
    // delle preferenze, ma il borsellino vive in memoria per tutta la
    // sessione. Senza dimenticarlo, **il saldo di chi se ne e' andato
    // resterebbe in barra** davanti a chi arriva dopo, fino al riavvio.
    final borsa = QuestionAllowance(porta: const PortaSpentaDelCerchio());
    SharedPreferences.setMockInitialValues(const {
      'allowance.saldoEos': 715,
      'allowance.count': 3,
    });
    await borsa.load();
    final prima = borsa.saldoEos;

    borsa.dimenticaChiSeNeVa();

    // ignore: avoid_print
    print('ORDINE AZ VOCE 15: il saldo passa da $prima a ${borsa.saldoEos}');
    expect(prima, 715,
        reason: 'la prova non parte da un saldo vero: non misura niente');
    expect(borsa.saldoEos, 0,
        reason: 'il saldo di chi e uscito resta in barra per chi arriva dopo');
  });
}

/// Un flusso di Google che segna cosa gli viene chiesto.
class _FlussoCheConta implements PortaDelFlussoGoogle {
  final List<String> diario = [];

  @override
  Future<void> dimentica() async => diario.add('dimentica');

  @override
  Future<AuthCredential?> credenziale() async {
    diario.add('credenziale');
    return null;
  }

  @override
  Future<String?> nomeGiaAutorizzato() async => null;
}

/// Un'auth che segna cosa le viene chiesto, e in che ordine.
class _AuthCheConta implements FirebaseAuth {
  final List<String> diario = [];
  User? _utente = _UtenteQualunque();

  @override
  User? get currentUser => _utente;

  @override
  Future<void> signOut() async {
    diario.add('signOut');
    _utente = null;
  }

  @override
  Future<UserCredential> signInAnonymously() async {
    diario.add('signInAnonymously');
    _utente = _UtenteQualunque();
    return _CredenzialeQualunque();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UtenteQualunque implements User {
  @override
  String get uid => 'qualunque';

  @override
  bool get isAnonymous => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _CredenzialeQualunque implements UserCredential {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Una porta che registra cosa le viene chiesto e in che ordine.
class _PortaCheRegistra implements PortaDellIdentita {
  // Ordine CI voce 07: il sostituto la data di nascita dell'account non la conosce.
  @override
  DateTime? get natoIl => null;

  @override
  bool? get emailVerificata => null;

  @override
  Future<EsitoDellaCustodia> mandaLaViaPerLaParola(String email) async =>
      EsitoDellaCustodia.riuscita;

  @override
  Future<EsitoDellaCustodia> mandaLaVerificaDellEmail() async =>
      EsitoDellaCustodia.riuscita;

  @override
  Future<EsitoDellaCustodia> cambiaLaParola(String nuova) async =>
      EsitoDellaCustodia.riuscita;

  @override
  Future<EsitoDellaCustodia> cambiaLEmail(String nuova) async =>
      EsitoDellaCustodia.nonRiuscita;

  final List<String> diario = [];
  int uscite = 0;
  @override
  bool anonimo = false;

  @override
  String? uid = 'chi-esce';

  @override
  String? get email => 'mauro@esempio.it';

  @override
  List<String> get fornitori => const ['google.com'];

  @override
  IdentitaRiconosciuta? get riconosciuta => null;

  @override
  Future<String?> assicuraUnAccount() async {
    diario.add('assicura');
    uid = 'anonimo-nuovo';
    anonimo = true;
    return uid;
  }

  @override
  Future<void> ricarica() async {}

  @override
  Future<EsitoDellaCustodia> eleva(ViaDellaCustodia via,
          {String? email, String? parola}) async =>
      EsitoDellaCustodia.riuscita;

  @override
  Future<EsitoDellaCustodia> entraDirettamente(ViaDellaCustodia via,
          {String? email, String? parola}) async =>
      EsitoDellaCustodia.riuscita;

  @override
  Future<EsitoDellaCustodia> entraComeRiconosciuto() async =>
      EsitoDellaCustodia.riuscita;

  @override
  Future<String?> nomeGiaProposto() async => null;

  @override
  Future<void> esci() async {
    // La porta vera dimentica Google, chiude la sessione e rientra anonima:
    // qui si registra la stessa sequenza per poterla leggere.
    diario.add('dimentica');
    uscite++;
    diario.add('signOut');
    await assicuraUnAccount();
  }
}
