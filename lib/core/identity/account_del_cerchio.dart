import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// COME STA LA PERSONA DENTRO IL CERCHIO.
///
/// Tre stati e non due: chi non ha ancora nessun account (Firebase non e'
/// partito, oppure siamo in una prova) non e' la stessa cosa di chi ne ha uno
/// anonimo. Confonderli farebbe apparire l'invito a custodire il proprio
/// cielo a chi un cielo non ce l'ha ancora.
enum StatoDellAccount {
  /// Nessun account: niente da custodire e niente da offrire.
  assente,

  /// Anonimo: tutto funziona, ma quello che fa vive attaccato a un uid che
  /// muore con la disinstallazione.
  anonimo,

  /// Custodito: l'account e' legato a Google, Apple o a un'email, quindi
  /// sopravvive al telefono.
  custodito,
}

/// L'esito di un tentativo di custodia, coi motivi che si mostrano.
enum EsitoDellaCustodia {
  riuscita,

  /// La persona ha chiuso la finestra del fornitore: non e' un errore.
  annullata,

  /// Quell'identita' e' gia' di un altro account del Cerchio. E' il caso
  /// delicato: qui NON si butta via cio' che la persona ha fatto da anonima
  /// senza dirglielo, si dichiara e si chiede.
  giaDiUnAltroCerchio,

  /// La rete, il fornitore non configurato, un imprevisto.
  nonRiuscita,

  /// IL FORNITORE HA CAMBIATO PERSONA SOTTO I PIEDI: dopo l'operazione l'uid
  /// non e' piu' quello di prima, quindi non e' stata un'elevazione ma un
  /// secondo account, e tutto cio' che stava attaccato al primo (carta natale,
  /// memoria, contatori, Eos) sarebbe rimasto orfano. Non e' una riuscita e
  /// non si racconta come tale.
  cerchioCambiato,
}

/// I MODI PER CUSTODIRE IL PROPRIO CIELO.
enum ViaDellaCustodia { google, apple, email }

/// LA PORTA VERSO L'IDENTITA', astratta perche' le prove non tocchino
/// Firebase e perche' si possa enumerare cosa appartiene alla persona prima e
/// dopo l'elevazione senza una rete di mezzo.
abstract class PortaDellIdentita {
  /// L'uid corrente, nullo se non c'e' nessun account.
  String? get uid;

  /// Vero se l'account corrente e' anonimo.
  bool get anonimo;

  /// L'email dell'account, se ne ha una.
  String? get email;

  /// I fornitori attaccati all'account (google.com, apple.com, password).
  List<String> get fornitori;

  /// Assicura che ci sia almeno un account anonimo e torna l'uid.
  Future<String?> assicuraUnAccount();

  /// ELEVA l'account che c'e' gia': non ne crea un secondo.
  Future<EsitoDellaCustodia> eleva(
    ViaDellaCustodia via, {
    String? email,
    String? parola,
  });

  /// Ricarica lo stato dell'utente dal fornitore.
  Future<void> ricarica();
}

/// La porta vera, sopra `firebase_auth`.
///
/// **Perche' `link...` e non `signIn...`, ed e' il cuore della voce 1d.**
/// Entrare con Google creerebbe un SECONDO account e lascerebbe il primo
/// orfano, con dentro la carta natale, la memoria e i contatori di chi stava
/// usando l'app: l'utente vedrebbe sparire tutto proprio nel momento in cui
/// gli si e' chiesto di non perdere niente. Il collegamento invece ATTACCA
/// l'identita' nuova all'account che c'e' gia', e l'uid resta lo stesso: e'
/// per questo che nulla di cio' che vive sul server ha bisogno di essere
/// migrato, e la prova che enumera prima e dopo lo dimostra elemento per
/// elemento.
///
/// **Google e Apple passano dal fornitore federato di Firebase**
/// (`linkWithProvider`), senza pacchetti nativi in piu': un pacchetto in piu'
/// vorrebbe dire configurazione nativa in piu' su tutte e due le piattaforme,
/// e la stessa cosa si ottiene con quello che c'e'. Resta a carico della
/// console l'abilitazione dei due fornitori, che nessun codice puo' fare.
class PortaDellIdentitaFirebase implements PortaDellIdentita {
  PortaDellIdentitaFirebase({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  User? get _utente => _auth.currentUser;

  @override
  String? get uid => _utente?.uid;

  @override
  bool get anonimo => _utente?.isAnonymous ?? false;

  @override
  String? get email => _utente?.email;

  @override
  List<String> get fornitori =>
      _utente?.providerData.map((p) => p.providerId).toList(growable: false) ??
      const [];

  @override
  Future<String?> assicuraUnAccount() async {
    final gia = _auth.currentUser;
    if (gia != null) return gia.uid;
    try {
      final nuovo = await _auth.signInAnonymously();
      return nuovo.user?.uid;
    } catch (errore) {
      // Si ignora e si torna nulla: senza account l'app resta intera e
      // funziona in locale. Chi chiama distingue gia' il nulla dal vuoto, e
      // sollevare qui vorrebbe dire non far partire l'app per una rete
      // assente.
      return null;
    }
  }

  @override
  Future<void> ricarica() async {
    try {
      await _auth.currentUser?.reload();
    } catch (errore) {
      // Si ignora: se non si puo' ricaricare si tiene quello che si sa gia',
      // che e' vecchio di secondi, non di giorni.
    }
  }

  @override
  Future<EsitoDellaCustodia> eleva(
    ViaDellaCustodia via, {
    String? email,
    String? parola,
  }) async {
    final utente = _auth.currentUser;
    if (utente == null) return EsitoDellaCustodia.nonRiuscita;
    try {
      switch (via) {
        case ViaDellaCustodia.google:
          await utente.linkWithProvider(GoogleAuthProvider());
        case ViaDellaCustodia.apple:
          await utente.linkWithProvider(AppleAuthProvider());
        case ViaDellaCustodia.email:
          if (email == null || parola == null) {
            return EsitoDellaCustodia.nonRiuscita;
          }
          await utente.linkWithCredential(
            EmailAuthProvider.credential(email: email, password: parola),
          );
      }
      await ricarica();
      return EsitoDellaCustodia.riuscita;
    } on FirebaseAuthException catch (errore) {
      switch (errore.code) {
        case 'credential-already-in-use':
        case 'email-already-in-use':
        case 'account-exists-with-different-credential':
          return EsitoDellaCustodia.giaDiUnAltroCerchio;
        case 'web-context-canceled':
        case 'canceled':
        case 'user-cancelled':
          return EsitoDellaCustodia.annullata;
        default:
          return EsitoDellaCustodia.nonRiuscita;
      }
    } catch (errore) {
      // Si ignora il dettaglio tecnico e si risponde con l'esito che la
      // persona puo' capire: qualunque cosa sia andata storta, il suo
      // Cerchio non e' stato toccato e puo' riprovare.
      return EsitoDellaCustodia.nonRiuscita;
    }
  }
}

/// L'IDENTITA' CHE NON C'E', per quando Firebase non e' partito.
///
/// Non solleva e non finge: l'account risulta assente, quindi l'app non
/// propone di custodire un cielo che non ha nessun posto dove essere
/// custodito, e tutto il resto continua a funzionare.
class IdentitaAssente implements PortaDellIdentita {
  const IdentitaAssente();

  @override
  String? get uid => null;

  @override
  bool get anonimo => false;

  @override
  String? get email => null;

  @override
  List<String> get fornitori => const [];

  @override
  Future<String?> assicuraUnAccount() async => null;

  @override
  Future<void> ricarica() async {}

  @override
  Future<EsitoDellaCustodia> eleva(
    ViaDellaCustodia via, {
    String? email,
    String? parola,
  }) async =>
      EsitoDellaCustodia.nonRiuscita;
}

/// L'ACCOUNT DEL CERCHIO, guardato dall'app.
///
/// Tiene lo stato, lo racconta a chi lo ascolta e sa dire QUANTI momenti la
/// persona ha gia' affidato al Cerchio: quel numero non si inventa mai, lo
/// conta la memoria, ed e' il numero che si mostra a chi ha rimandato.
class AccountDelCerchio extends ChangeNotifier {
  AccountDelCerchio({required PortaDellIdentita porta}) : _porta = porta;

  final PortaDellIdentita _porta;

  StatoDellAccount _stato = StatoDellAccount.assente;
  StatoDellAccount get stato => _stato;

  String? get uid => _porta.uid;
  String? get email => _porta.email;
  List<String> get fornitori => _porta.fornitori;

  bool get eAnonimo => _stato == StatoDellAccount.anonimo;
  bool get eCustodito => _stato == StatoDellAccount.custodito;

  /// Quante volte l'invito e' gia' stato rimandato: chi dice di no non deve
  /// vederselo davanti a ogni apertura.
  int _rimandi = 0;
  int get rimandi => _rimandi;

  void rileggi() {
    final uid = _porta.uid;
    if (uid == null) {
      _stato = StatoDellAccount.assente;
    } else {
      _stato =
          _porta.anonimo ? StatoDellAccount.anonimo : StatoDellAccount.custodito;
    }
    notifyListeners();
  }

  Future<void> avvia() async {
    await _porta.assicuraUnAccount();
    rileggi();
  }

  void rimanda() {
    _rimandi++;
    notifyListeners();
  }

  Future<EsitoDellaCustodia> custodisci(
    ViaDellaCustodia via, {
    String? email,
    String? parola,
  }) async {
    // L'UID DI PARTENZA SI SEGNA PRIMA, ed e' il presidio della voce 1d.
    //
    // Elevare vuol dire attaccare un'identita' all'account che c'e' gia'. Se
    // dopo l'operazione l'uid e' cambiato, allora non e' stata un'elevazione:
    // e' nato un secondo account e il primo e' rimasto indietro con dentro
    // tutto quello che la persona aveva fatto. Dichiararlo "riuscito"
    // sarebbe la bugia peggiore possibile, proprio nel momento in cui le si
    // e' promesso di non farle perdere niente.
    final prima = _porta.uid;
    final esito = await _porta.eleva(via, email: email, parola: parola);
    rileggi();
    if (esito == EsitoDellaCustodia.riuscita &&
        prima != null &&
        _porta.uid != prima) {
      return EsitoDellaCustodia.cerchioCambiato;
    }
    return esito;
  }
}
