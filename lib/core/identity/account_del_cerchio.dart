import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  /// L'IDENTITA' RICONOSCIUTA, ordine AL voce 07.
  ///
  /// Quando la custodia risponde "appartiene gia' a un altro Cerchio", quel
  /// rifiuto porta con se' CHI e' stato riconosciuto: prima si buttava via
  /// tutto e alla persona restava solo un vicolo. Qui resta il nome (l'email
  /// dell'account, che e' l'unica cosa vera che si sa prima di entrare) e la
  /// credenziale con cui si puo' entrare in quel Cerchio.
  IdentitaRiconosciuta? get riconosciuta;

  /// ENTRA nel Cerchio riconosciuto, con la credenziale rimasta dall'ultimo
  /// rifiuto. Non e' un'elevazione: e' un cambio di account, e chi chiama lo
  /// dice alla persona con la riga onesta PRIMA del tocco.
  Future<EsitoDellaCustodia> entraComeRiconosciuto();
}

/// Chi e' stato riconosciuto da un tentativo di custodia finito su un
/// Cerchio gia' esistente, con la via per entrarci.
class IdentitaRiconosciuta {
  const IdentitaRiconosciuta({required this.nome, required this.credenziale});

  /// L'email dell'account riconosciuto: il nome vero si sapra' solo dentro.
  final String? nome;

  /// La credenziale con cui entrare, quando la si ha.
  final AuthCredential? credenziale;
}

/// LA PORTA VERSO IL FLUSSO NATIVO DI GOOGLE. Ordine AD voce 01.
///
/// **Esiste perche' le prove non aprano nessuna finestra e non tocchino la
/// rete**, come tutto il resto dell'identita': chi prova monta una porta finta
/// che consegna una credenziale costruita a mano, e la porta vera vive solo
/// dentro l'app.
abstract class PortaDelFlussoGoogle {
  /// La credenziale del flusso nativo, oppure nulla se la persona ha chiuso la
  /// finestra: il nulla NON e' un errore, e' un'annullata.
  Future<AuthCredential?> credenziale();
}

/// Il flusso vero, sopra `google_sign_in`.
///
/// **Il client id web non sta scritto qui, e non e' una dimenticanza**: su
/// Android il pacchetto lo legge da solo dalla configurazione generata da
/// `google-services.json`, che porta il client con `client_type` 3. Scriverlo a
/// mano nel codice vorrebbe dire una seconda copia che diverge alla prima
/// rigenerazione del file.
class FlussoGoogleNativo implements PortaDelFlussoGoogle {
  @override
  Future<AuthCredential?> credenziale() async {
    final account = await GoogleSignIn().signIn();
    // Il pacchetto risponde nulla quando la persona chiude la finestra.
    if (account == null) return null;
    final autenticazione = await account.authentication;
    return GoogleAuthProvider.credential(
      idToken: autenticazione.idToken,
      accessToken: autenticazione.accessToken,
    );
  }
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
/// **LA VIA GOOGLE E' NATIVA DAL 16 AGOSTO 2026, ordine AD.** Prima passava dal
/// fornitore federato di Firebase (`linkWithProvider`), che su Android apre la
/// pagina web su firebaseapp.com: provato sul telefono vero, il ritorno dal
/// consenso muore con "missing initial state", perche' i browser Android con lo
/// storage partizionato non reggono il flusso via redirect, e nessuna
/// configurazione di console lo salva. Adesso le credenziali nascono dal flusso
/// nativo di Google e si attaccano con `linkWithCredential`: stessa garanzia
/// sull'uid, nessun browser di mezzo. **Apple resta su `linkWithProvider`**:
/// non compare su Android e si rivede alla build iOS.
class PortaDellIdentitaFirebase implements PortaDellIdentita {
  PortaDellIdentitaFirebase({
    FirebaseAuth? auth,
    PortaDelFlussoGoogle? flussoGoogle,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _flussoGoogle = flussoGoogle ?? FlussoGoogleNativo();

  final FirebaseAuth _auth;
  final PortaDelFlussoGoogle _flussoGoogle;

  IdentitaRiconosciuta? _riconosciuta;

  @override
  IdentitaRiconosciuta? get riconosciuta => _riconosciuta;

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
    // La credenziale che si prova ad attaccare: se il Cerchio risulta di un
    // altro, e' anche la via per ENTRARCI, e non si butta piu' via.
    AuthCredential? tentata;
    try {
      switch (via) {
        case ViaDellaCustodia.google:
          final credenziale = await _flussoGoogle.credenziale();
          if (credenziale == null) return EsitoDellaCustodia.annullata;
          tentata = credenziale;
          await utente.linkWithCredential(credenziale);
        case ViaDellaCustodia.apple:
          await utente.linkWithProvider(AppleAuthProvider());
        case ViaDellaCustodia.email:
          if (email == null || parola == null) {
            return EsitoDellaCustodia.nonRiuscita;
          }
          tentata = EmailAuthProvider.credential(email: email, password: parola);
          await utente.linkWithCredential(tentata);
      }
      await ricarica();
      return EsitoDellaCustodia.riuscita;
    } on FirebaseAuthException catch (errore) {
      switch (errore.code) {
        case 'credential-already-in-use':
        case 'email-already-in-use':
        case 'account-exists-with-different-credential':
          // **IL RIFIUTO PORTA CON SE' CHI E', ordine AL voce 07.** Quando
          // l'errore consegna la credenziale aggiornata si tiene quella,
          // altrimenti quella appena tentata: e' cio' che rende possibile il
          // "Continua come" invece del vicolo cieco.
          _riconosciuta = IdentitaRiconosciuta(
            nome: errore.email ?? email,
            credenziale: errore.credential ?? tentata,
          );
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

  @override
  Future<EsitoDellaCustodia> entraComeRiconosciuto() async {
    final credenziale = _riconosciuta?.credenziale;
    if (credenziale == null) return EsitoDellaCustodia.nonRiuscita;
    try {
      await _auth.signInWithCredential(credenziale);
      _riconosciuta = null;
      await ricarica();
      return EsitoDellaCustodia.riuscita;
    } catch (errore) {
      // Anche qui l'esito parla alla persona: il suo telefono e' rimasto
      // com'era e puo' riprovare, magari ripetendo la via Google per una
      // credenziale fresca.
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

  @override
  IdentitaRiconosciuta? get riconosciuta => null;

  @override
  Future<EsitoDellaCustodia> entraComeRiconosciuto() async =>
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

  /// Il nome dell'identita' riconosciuta dall'ultimo rifiuto, per il
  /// "Continua come [nome]" dell'ordine AL voce 07. Nullo finche' nessun
  /// Cerchio e' stato riconosciuto.
  String? get nomeRiconosciuto => _porta.riconosciuta?.nome;

  /// ENTRA nel Cerchio riconosciuto. Qui il cambio di uid non e' un guasto,
  /// e' esattamente cio' che la persona ha chiesto col tocco, dopo la riga
  /// onesta che le ha detto cosa succede al cammino di questo telefono.
  Future<EsitoDellaCustodia> entraNelCerchioRiconosciuto() async {
    final esito = await _porta.entraComeRiconosciuto();
    rileggi();
    return esito;
  }
}
