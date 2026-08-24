import 'package:firebase_auth/firebase_auth.dart';
import 'dimenticanza_del_telefono.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  /// **NESSUN CERCHIO CON QUELLE CHIAVI.** Ordine AX voce 01: chi torna ha
  /// sbagliato account o non ne ha mai avuto uno, e va detto con parole sue
  /// invece di un generico "non e' riuscito".
  nonRiconosciuto,

  /// La rete, il fornitore non configurato, un imprevisto.
  nonRiuscita,

  /// IL FORNITORE HA CAMBIATO PERSONA SOTTO I PIEDI: dopo l'operazione l'uid
  /// non e' piu' quello di prima, quindi non e' stata un'elevazione ma un
  /// secondo account, e tutto cio' che stava attaccato al primo (carta natale,
  /// memoria, contatori, Eos) sarebbe rimasto orfano. Non e' una riuscita e
  /// non si racconta come tale.
  cerchioCambiato,

  /// **QUESTO CIELO E' GIA' CUSTODITO.** Ordine AZ, dal collaudo del fondatore
  /// sulla 2194: arrivato in fondo al rito gli veniva chiesto di registrarsi
  /// **mentre era gia' dentro col suo account**, e il tentativo falliva.
  ///
  /// **Non e' un guasto ed e' importante che non lo sembri**: e' una domanda
  /// che non andava fatta. Chi la riceve deve solo proseguire.
  ///
  /// **Sta qui e non nei chiamanti, e la ragione e' misurata.** I punti che
  /// propongono di custodire sono tre: l'area account, il Santuario e
  /// l'ultimo passo del Risveglio. I primi due guardavano se l'account era
  /// gia' custodito, **il terzo no**, ed e' quello in cui il fondatore e'
  /// finito. Una difesa affidata a chi chiama regge finche' qualcuno non se
  /// ne dimentica, e qualcuno se ne era gia' dimenticato.
  giaCustodito,
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

  /// ENTRA in un Cerchio che esiste gia', con una credenziale fresca. Ordine
  /// AX voce 01: e' la via di chi torna, e non passa dall'elevazione.
  Future<EsitoDellaCustodia> entraDirettamente(
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

  /// IL NOME CHE IL TELEFONO PROPONE DA SOLO, ordine AP voce 08.
  ///
  /// Nullo quando il telefono non propone niente, e il nulla NON e' un
  /// guasto: e' la risposta piu' probabile, e chi chiama non mostra nulla.
  Future<String?> nomeGiaProposto();

  /// **SI ESCE DAL PROPRIO ACCOUNT.** Ordine AZ voce 07, situazioni S09, S13
  /// e S23 del censimento.
  ///
  /// **Non esisteva.** In tutto `lib/` c'era un `signOut` solo, quello di
  /// Google dentro `dimentica()`, e non toccava Firebase: **chi sceglieva
  /// l'account sbagliato non aveva nessuna via di ritorno**, e due persone
  /// sullo stesso telefono non erano previste, perche' la seconda ereditava
  /// il Cerchio della prima.
  ///
  /// **Si esce verso un anonimo nuovo, non verso il vuoto**: l'app senza
  /// un'identita' non sta in piedi, e lasciare il telefono senza nessuno
  /// vorrebbe dire spegnerlo. Il cammino di chi esce resta sul Cerchio e lo
  /// ritrova rientrando.
  Future<void> esci();

  /// **LA PAROLA PERSA.** Ordine AZ voce 05, situazione S14.
  ///
  /// **Non esisteva**: zero `sendPasswordResetEmail` in tutto `lib/`. Chi si
  /// era custodito con un'email e aveva dimenticato la parola **era fuori dal
  /// proprio Cerchio per sempre**, senza nessuna via.
  Future<EsitoDellaCustodia> mandaLaViaPerLaParola(String email);

  /// **LA VERIFICA DELL'EMAIL.** Ordine AZ voce 06, situazione S18.
  ///
  /// **Non esisteva**: zero `sendEmailVerification` e zero `emailVerified`.
  /// Un'email non verificata vuol dire che chiunque puo' registrarsi con
  /// l'indirizzo di un altro, e che la via per la parola persa arriva a una
  /// casella che potrebbe non essere sua.
  Future<EsitoDellaCustodia> mandaLaVerificaDellEmail();

  /// Vero se l'email di chi e' dentro e' stata verificata. Nullo per chi non
  /// e' entrato con un'email: la domanda non ha senso e non si finge una
  /// risposta.
  bool? get emailVerificata;

  /// **CAMBIARE LA PAROLA.** Ordine AZ voce 12, situazione S20.
  ///
  /// **Non esisteva**: zero `updatePassword`. Firebase pretende una sessione
  /// recente per questa operazione: quando non lo e', risponde
  /// `requires-recent-login`, e la persona deve rientrare. Si dice, invece di
  /// far fallire in silenzio.
  Future<EsitoDellaCustodia> cambiaLaParola(String nuova);
}

/// Chi e' stato riconosciuto da un tentativo di custodia finito su un
/// Cerchio gia' esistente, con la via per entrarci.
class IdentitaRiconosciuta {
  const IdentitaRiconosciuta({
    required this.nome,
    required this.credenziale,
    this.via,
  });

  /// **DA QUALE VIA E' ARRIVATO IL RICONOSCIMENTO.** Ordine AZ.
  ///
  /// Serve a rientrare **rifacendo la stessa strada** invece di riusare la
  /// credenziale di prima. Vedi il perche' su `entraComeRiconosciuto`.
  final ViaDellaCustodia? via;

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

  /// **DIMENTICA CHI HA SCELTO L'ULTIMA VOLTA.** Ordine AX voce 01.
  ///
  /// **Senza questa riga la porta si chiude alle spalle.** Il client di Google
  /// resta "gia' entrato" dopo un tentativo, e alla chiamata successiva
  /// restituisce lo stesso account **senza riaprire il selettore**, con un
  /// token che puo' essere gia' stato speso. E' il motivo per cui, dopo un
  /// accesso fallito, al fondatore non funzionava piu' nemmeno la
  /// registrazione: non era la registrazione, era Google che rispondeva con
  /// cio' che aveva in mano.
  Future<void> dimentica();

  /// IL NOME CHE GOOGLE PROPONE SENZA APRIRE NIENTE, ordine AP voce 08.
  ///
  /// **Sta qui e non in una casa nuova**: questa e' l'unica porta verso
  /// Google di tutta l'app, e una seconda classe che costruisse un
  /// `GoogleSignIn` per conto suo sarebbe la seconda strada per lo stesso
  /// dato. Risponde nulla ogni volta che il telefono non propone niente.
  Future<String?> nomeGiaAutorizzato();
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

  @override
  Future<void> dimentica() async {
    try {
      await GoogleSignIn().signOut();
    } catch (nienteDaDimenticare) {
      // Se non c'era niente da dimenticare, non c'e' niente da fare: quello
      // che conta e' che il tentativo dopo riparta pulito, e riparte pulito
      // anche cosi'.
    }
  }

  /// **COSA CHIEDE DAVVERO QUESTA RIGA, misurato sul pacchetto.**
  /// `signInSilently` di `google_sign_in` 6.3.0 finisce, su Android, dentro
  /// `GoogleSignInClient.silentSignIn()` (misurato in
  /// `google_sign_in_android` 6.2.1, `GoogleSignInPlugin.java` riga 276), che
  /// NON e' `getLastSignedInAccount`: non guarda la memoria dell'app, chiede
  /// ai servizi Google se quel telefono ha gia' autorizzato questa app. E'
  /// per questo che puo' rispondere anche dopo una reinstallazione, ed e'
  /// anche il motivo per cui puo' rispondere nulla senza che nulla sia
  /// rotto. Gli errori sono gia' soffocati dal pacchetto e tornano nulla.
  ///
  /// **Non fa entrare nessuno**: prende un nome e basta. Entrare da soli
  /// all'apertura sarebbe il muro d'accesso che Mauro ha escluso il 18
  /// agosto.
  @override
  Future<String?> nomeGiaAutorizzato() async {
    final account = await GoogleSignIn().signInSilently();
    if (account == null) return null;
    final nome = account.displayName?.trim();
    if (nome != null && nome.isNotEmpty) return nome;
    // Senza nome resta l'email, e di un'email si mostra la parte davanti:
    // "Bentornato, mauro" e' un saluto, "Bentornato, mauro@..." e' un dato.
    final email = account.email.trim();
    if (email.isEmpty) return null;
    final davanti = email.split('@').first;
    return davanti.isEmpty ? null : davanti;
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
      // **OGNI FALLIMENTO LASCIA LA PORTA APERTA.** Ordine AX voce 01: senza
      // questa riga il client di Google resta con l'account gia' scelto in
      // mano, e il tentativo successivo, di qualunque tipo, riceve cio' che
      // lui ha invece di riaprire il selettore.
      await _flussoGoogle.dimentica();
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
            via: via,
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
      await _flussoGoogle.dimentica();
      return EsitoDellaCustodia.nonRiuscita;
    }
  }

  /// Il nome proposto lo sa solo il flusso di Google, e si chiede solo a chi
  /// non ha ancora custodito: a chi ha gia' un account il telefono non deve
  /// proporre di rientrare in cio' in cui e' gia' dentro.
  @override
  Future<String?> nomeGiaProposto() async {
    if (!anonimo) return null;
    return _flussoGoogle.nomeGiaAutorizzato();
  }

  /// **CHI TORNA ENTRA, NON ELEVA.** Ordine AX voce 01, ed e' la cura del
  /// difetto piu' grave che il fondatore abbia trovato.
  ///
  /// **Cosa succedeva.** Chi reinstallava e sceglieva il proprio account
  /// passava dalla stessa porta di chi custodisce per la prima volta, cioe' da
  /// `eleva`, che ATTACCA l'identita' all'anonimo di questo telefono. Quella
  /// identita' pero' e' gia' di un altro Cerchio, quindi il collegamento
  /// falliva per forza, e la via d'uscita era un SECONDO tocco che riusava
  /// **la credenziale gia' spesa dal tentativo fallito**. Su Google un token
  /// speso non entra piu': la persona restava fuori.
  ///
  /// Qui si chiede una credenziale FRESCA e si entra e basta. Il cammino
  /// dell'anonimo non si perde: lo custodisce il Cerchio, e il Custode lo
  /// ritrova subito dopo.
  @override
  Future<EsitoDellaCustodia> entraDirettamente(ViaDellaCustodia via,
      {String? email, String? parola}) async {
    try {
      switch (via) {
        case ViaDellaCustodia.google:
          // Si dimentica PRIMA: cosi' il selettore si riapre e il token e'
          // nuovo, invece di essere quello che il client aveva in tasca.
          await _flussoGoogle.dimentica();
          final credenziale = await _flussoGoogle.credenziale();
          if (credenziale == null) return EsitoDellaCustodia.annullata;
          await _auth.signInWithCredential(credenziale);
        case ViaDellaCustodia.apple:
          await _auth.signInWithProvider(AppleAuthProvider());
        case ViaDellaCustodia.email:
          if (email == null || parola == null) {
            return EsitoDellaCustodia.nonRiuscita;
          }
          await _auth.signInWithEmailAndPassword(
              email: email, password: parola);
      }
      _riconosciuta = null;
      await ricarica();
      return EsitoDellaCustodia.riuscita;
    } on FirebaseAuthException catch (errore) {
      await _flussoGoogle.dimentica();
      switch (errore.code) {
        case 'web-context-canceled':
        case 'canceled':
        case 'user-cancelled':
          return EsitoDellaCustodia.annullata;
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return EsitoDellaCustodia.nonRiconosciuto;
        default:
          return EsitoDellaCustodia.nonRiuscita;
      }
    } catch (imprevisto) {
      // Si ignora il dettaglio tecnico e si risponde con l'esito che la
      // persona puo' capire: qualunque cosa sia andata storta, il suo Cerchio
      // non e' stato toccato e puo' riprovare. Il client di Google si
      // dimentica lo stesso, se no il tentativo dopo riceve questo.
      await _flussoGoogle.dimentica();
      return EsitoDellaCustodia.nonRiuscita;
    }
  }

  @override
  bool? get emailVerificata {
    final utente = _utente;
    if (utente == null) return null;
    // La domanda ha senso solo per chi e' entrato con un'email: con Google e
    // con Apple l'indirizzo lo ha gia' verificato il fornitore.
    final conEmail = utente.providerData.any((p) => p.providerId == 'password');
    if (!conEmail) return null;
    return utente.emailVerified;
  }

  @override
  Future<EsitoDellaCustodia> mandaLaViaPerLaParola(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return EsitoDellaCustodia.riuscita;
    } on FirebaseAuthException catch (errore) {
      switch (errore.code) {
        case 'user-not-found':
        case 'invalid-email':
          // **NON SI DICE SE QUELL'EMAIL ESISTE**, e non e' pigrizia: dirlo
          // vorrebbe dire regalare a chiunque un modo per sapere chi fa parte
          // del Cerchio. La frase a schermo e' la stessa in tutti e due i
          // casi, e questo esito serve solo a chi legge il registro.
          return EsitoDellaCustodia.nonRiconosciuto;
        default:
          return EsitoDellaCustodia.nonRiuscita;
      }
    } catch (errore) {
      return EsitoDellaCustodia.nonRiuscita;
    }
  }

  @override
  Future<EsitoDellaCustodia> mandaLaVerificaDellEmail() async {
    final utente = _utente;
    if (utente == null) return EsitoDellaCustodia.nonRiuscita;
    try {
      await utente.sendEmailVerification();
      return EsitoDellaCustodia.riuscita;
    } catch (errore) {
      return EsitoDellaCustodia.nonRiuscita;
    }
  }

  @override
  Future<EsitoDellaCustodia> cambiaLaParola(String nuova) async {
    final utente = _utente;
    if (utente == null) return EsitoDellaCustodia.nonRiuscita;
    try {
      await utente.updatePassword(nuova);
      return EsitoDellaCustodia.riuscita;
    } on FirebaseAuthException catch (errore) {
      // **LA SESSIONE VECCHIA NON BASTA, e la persona deve saperlo.**
      // Firebase pretende un accesso recente per un'operazione cosi': senza
      // questo ramo il cambio fallirebbe con la frase generica, e nessuno
      // capirebbe che basta uscire e rientrare.
      if (errore.code == 'requires-recent-login') {
        return EsitoDellaCustodia.nonRiconosciuto;
      }
      return EsitoDellaCustodia.nonRiuscita;
    } catch (errore) {
      return EsitoDellaCustodia.nonRiuscita;
    }
  }

  @override
  Future<void> esci() async {
    // **PRIMA SI DIMENTICA GOOGLE.** Senza, il client resta con l'account in
    // mano e chi entra dopo si ritrova quello di prima senza nemmeno vedere
    // il selettore: e' lo stesso difetto curato in AX voce 01, e qui sarebbe
    // anche peggio, perche' uscire serve proprio a cambiare persona.
    await _flussoGoogle.dimentica();
    try {
      await _auth.signOut();
    } catch (errore) {
      // Si ignora: se la sessione non si chiude sul momento, l'anonimo qui
      // sotto la sostituisce comunque.
    }
    _riconosciuta = null;
    // **E SI RIENTRA COME ANONIMI.** Un'app senza identita' non sta in piedi:
    // il borsellino, il diario e la memoria hanno tutti bisogno di un uid.
    await assicuraUnAccount();
  }

  @override
  Future<EsitoDellaCustodia> entraComeRiconosciuto() async {
    // **SI RIFA' LA STRADA, non si riusa il token.** Ordine AZ, ed e' lo
    // stesso difetto curato in AX voce 01 **sopravvissuto in questo punto**.
    //
    // Qui si arriva dal "Continua come", cioe' dopo che un'elevazione e'
    // stata rifiutata perche' quell'identita' e' gia' di un altro Cerchio.
    // Prima si riusava `_riconosciuta.credenziale`, **cioe' proprio il token
    // che il tentativo appena fallito aveva speso**: su Google un token speso
    // non entra piu', quindi la via d'uscita non usciva da nessuna parte.
    //
    // **Non era stato trovato da nessun collaudo** perche' per arrivarci
    // serve un account gia' di un altro Cerchio, che sul telefono di chi
    // prova capita di rado. E' stato trovato cercandolo, dopo che lo stesso
    // difetto era emerso altrove.
    //
    // Adesso si ripercorre la via da cui il riconoscimento e' arrivato, che
    // chiede una credenziale nuova: **una sola strada per entrare, e non
    // due**.
    final via = _riconosciuta?.via;
    if (via != null) {
      final esito = await entraDirettamente(via);
      if (esito == EsitoDellaCustodia.riuscita) _riconosciuta = null;
      return esito;
    }
    // Senza via registrata resta la vecchia strada, che per l'email funziona
    // (la sua credenziale non si consuma) e per Google e' l'ultima spiaggia.
    final credenziale = _riconosciuta?.credenziale;
    if (credenziale == null) return EsitoDellaCustodia.nonRiuscita;
    try {
      await _auth.signInWithCredential(credenziale);
      _riconosciuta = null;
      await ricarica();
      return EsitoDellaCustodia.riuscita;
    } catch (errore) {
      // L'esito parla alla persona: il suo telefono e' rimasto com'era e puo'
      // riprovare, ripetendo la via per una credenziale fresca.
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
  Future<EsitoDellaCustodia> entraDirettamente(
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

  @override
  Future<String?> nomeGiaProposto() async => null;

  @override
  Future<void> esci() async {}

  @override
  bool? get emailVerificata => null;

  @override
  Future<EsitoDellaCustodia> mandaLaViaPerLaParola(String email) async =>
      EsitoDellaCustodia.nonRiuscita;

  @override
  Future<EsitoDellaCustodia> mandaLaVerificaDellEmail() async =>
      EsitoDellaCustodia.nonRiuscita;

  @override
  Future<EsitoDellaCustodia> cambiaLaParola(String nuova) async =>
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
  ///
  /// **SUL DISCO, non in memoria. Ordine BG voce 03.** Il conto in RAM
  /// ripartiva da zero a ogni avvio, quindi il tetto dei tre no valeva solo
  /// dentro una sessione: chi aveva rifiutato tre volte se lo ritrovava
  /// davanti al riavvio, che e' il contrario del rispetto promesso.
  static const String _chiaveRimandi = 'account.rimandi';
  int _rimandi = 0;
  int get rimandi => _rimandi;

  Future<void> _caricaIRimandi() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _rimandi = prefs.getInt(_chiaveRimandi) ?? 0;
    } catch (errore) {
      // Senza disco il conto resta quello di sessione: meglio di niente.
    }
  }

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
    await _caricaIRimandi();
    await _porta.assicuraUnAccount();
    rileggi();
  }

  void rimanda() {
    _rimandi++;
    notifyListeners();
    // Best effort: se il disco non scrive, vale il conto di sessione.
    SharedPreferences.getInstance()
        .then((prefs) => prefs.setInt(_chiaveRimandi, _rimandi))
        .catchError((Object errore) => true);
  }

  Future<EsitoDellaCustodia> custodisci(
    ViaDellaCustodia via, {
    String? email,
    String? parola,
  }) async {
    // **NON SI CUSTODISCE CIO' CHE E' GIA' CUSTODITO.** Ordine AZ, dal
    // collaudo del fondatore sulla 2194: arrivato in fondo al rito gli veniva
    // chiesto di registrarsi **mentre era gia' dentro col suo account**, e il
    // tentativo falliva perche' quell'identita' e' gia' attaccata a lui.
    //
    // **La difesa sta QUI e non nei chiamanti.** I punti che propongono di
    // custodire sono tre, contati: l'area account, il Santuario e l'ultimo
    // passo del Risveglio. I primi due guardavano se l'account era gia'
    // custodito, **il terzo no**, ed e' quello in cui il fondatore e' finito.
    // Una difesa affidata a chi chiama regge finche' qualcuno non se ne
    // dimentica, e qualcuno se ne era gia' dimenticato.
    // **SI GUARDA `eCustodito`, NON `!eAnonimo`, e la differenza e' tutta.**
    // Gli stati sono TRE, non due: assente, anonimo, custodito. La prima
    // stesura di questa riga diceva `!eAnonimo`, che comprende anche
    // **assente**, cioe' lo stato di chi non ha ancora riletto niente: e
    // bloccava la custodia a chi ne aveva pieno diritto. **Cinque prove sono
    // cadute insieme e avevano ragione.** Si nega solo cio' che si sa: qui si
    // ferma chi e' custodito per certo, non chi non si e' ancora guardato.
    if (eCustodito) return EsitoDellaCustodia.giaCustodito;
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

  /// **ENTRA in un Cerchio che esiste gia'.** Ordine AX voce 01: e' la via di
  /// chi torna, e non passa dall'elevazione. Vedi il commento su
  /// `entraDirettamente` nella porta.
  Future<EsitoDellaCustodia> entraDirettamente(ViaDellaCustodia via,
      {String? email, String? parola}) async {
    final esito =
        await _porta.entraDirettamente(via, email: email, parola: parola);
    rileggi();
    return esito;
  }

  /// **SI ESCE, E IL TELEFONO DIMENTICA CHI ERA.** Ordine AZ voce 07.
  ///
  /// Non basta chiudere la sessione: se restassero il diario, i dati di
  /// nascita e la preferenza del rito, **chi entra dopo si troverebbe il
  /// cammino di un altro**, e la fusione lo manderebbe pure sul Cerchio del
  /// nuovo arrivato. Cio' che si cancella e' solo la copia locale: il cammino
  /// vero resta custodito e torna a chi rientra.
  Future<void> esci() async {
    await _porta.esci();
    await DimenticanzaDelTelefono.dimentica();
    rileggi();
  }

  /// La via per rifare la parola d'accesso. Ordine AZ voce 05.
  Future<EsitoDellaCustodia> mandaLaViaPerLaParola(String email) =>
      _porta.mandaLaViaPerLaParola(email);

  /// La verifica dell'email. Ordine AZ voce 06.
  Future<EsitoDellaCustodia> mandaLaVerificaDellEmail() =>
      _porta.mandaLaVerificaDellEmail();

  /// Vero se l'email e' verificata, nullo se la domanda non ha senso.
  bool? get emailVerificata => _porta.emailVerificata;

  /// Il cambio della parola. Ordine AZ voce 12.
  Future<EsitoDellaCustodia> cambiaLaParola(String nuova) async {
    final esito = await _porta.cambiaLaParola(nuova);
    rileggi();
    return esito;
  }

  /// Il nome dell'identita' riconosciuta dall'ultimo rifiuto, per il
  /// "Continua come [nome]" dell'ordine AL voce 07. Nullo finche' nessun
  /// Cerchio e' stato riconosciuto.
  String? get nomeRiconosciuto => _porta.riconosciuta?.nome;

  /// IL BENTORNATO, ordine AP voce 08. Nullo finche' il telefono non ha
  /// proposto niente, e nullo per sempre se non propone mai.
  String? _bentornato;
  String? get bentornato => _bentornato;

  bool _bentornatoChiesto = false;

  /// **SI CHIEDE UNA VOLTA SOLA E NON APRE NIENTE.** Se il telefono propone
  /// un nome, chi torna si sente chiamare per nome davanti alla porta
  /// piccola; se non propone niente non compare nulla, e non e' un guasto da
  /// raccontare: e' la risposta normale su un telefono che quell'account non
  /// l'ha mai autorizzato.
  Future<void> chiediIlBentornato() async {
    if (_bentornatoChiesto) return;
    _bentornatoChiesto = true;
    final nome = await _porta.nomeGiaProposto();
    if (nome == null || nome.isEmpty) return;
    _bentornato = nome;
    notifyListeners();
  }

  /// ENTRA nel Cerchio riconosciuto. Qui il cambio di uid non e' un guasto,
  /// e' esattamente cio' che la persona ha chiesto col tocco, dopo la riga
  /// onesta che le ha detto cosa succede al cammino di questo telefono.
  Future<EsitoDellaCustodia> entraNelCerchioRiconosciuto() async {
    final esito = await _porta.entraComeRiconosciuto();
    rileggi();
    return esito;
  }
}
