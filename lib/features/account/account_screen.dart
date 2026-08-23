import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/feature_flags/feature_flag.dart';
import '../../core/identity/account_del_cerchio.dart';
import '../../core/identity/dimenticanza_del_telefono.dart';
import '../../core/identity/dimenticanza_della_memoria_viva.dart';
import '../../design_system/components/feature_sheet.dart';
import '../../services/app_services.dart';
import 'custodia_del_cielo.dart';

import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../pricing/pricing_screen.dart';
import '../settings/settings_screen.dart';
import 'profile_screen.dart';
import 'dati_di_nascita_screen.dart';
import 'notifiche_screen.dart';
import '../shell/vie_del_cerchio.dart';

/// L'area account, aperta dall'icona Utente in alto a destra nel Cerchio.
///
/// Raccoglie le voci personali (Profilo, Impostazioni, Abbonamento, Notifiche,
/// Privacy), distinte dal Cosmic Passport, che resta il profilo esoterico nella
/// barra in basso. Alcune voci portano gia' alla loro schermata, altre sono in
/// arrivo e lo dichiarano, mai un vicolo cieco.
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  /// **LA ROTTA DICHIARA LA SUA DESTINAZIONE.** Ordine AU voce 10: senza
  /// questa riga nessuno puo' accorgersi che il menu' utente e' gia' aperto, e
  /// ogni tocco ne impila un altro sopra quello di prima.
  static Route<void> route() => MaterialPageRoute<void>(
        builder: (_) => const AccountScreen(),
        settings: const RouteSettings(arguments: PortaDelCerchio.account),
      );

  @override
  Widget build(BuildContext context) {
    final entries = <_AccountEntry>[
      _AccountEntry(
        id: 'profilo',
        title: 'Profilo',
        subtitle: 'Nome, avatar e dati personali',
        icon: Icons.person_outline_rounded,
        onTap: (context) => Navigator.of(context).push(ProfileScreen.route()),
      ),
      // I DATI DI NASCITA SI CORREGGONO. Prima si raccoglievano una volta sola
      // nel Risveglio e non c'era piu' modo di toccarli: chi l'aveva concluso
      // senza dare l'ora non poteva piu' darla, e si rivedeva per sempre
      // "l'Ascendente e le Case restano velati". Un dato che si raccoglie una
      // volta sola e mai piu' non e' un dato, e' una trappola.
      _AccountEntry(
        id: 'nascita',
        title: 'I tuoi dati di nascita',
        subtitle: 'Giorno e ora esatta, per Ascendente e Case',
        icon: Icons.cake_outlined,
        onTap: (context) =>
            Navigator.of(context).push(DatiDiNascitaScreen.route()),
      ),
      _AccountEntry(
        id: 'impostazioni',
        title: 'Impostazioni',
        subtitle: 'Preferenze, lingua, qualità grafica',
        icon: Icons.settings_outlined,
        onTap: (context) =>
            Navigator.of(context).push(SettingsScreen.route()),
      ),
      _AccountEntry(
        id: 'abbonamento',
        title: 'Abbonamento',
        subtitle: 'Il tuo piano e i livelli del Cerchio',
        icon: Icons.workspace_premium_outlined,
        onTap: (context) =>
            Navigator.of(context).push(PricingScreen.route()),
      ),
      // LE VOCI IN ARRIVO PARLANO, ordine AL voce 06: al tocco rispondono con
      // l'anticipo elegante del Santuario, mai il silenzio, e l'anticipo dice
      // cosa arrivera' con parole sue, non con una frase qualunque.
      // **LE NOTIFICHE SI ATTIVANO DA QUI, e prima era un anticipo.**
      // Ordine BB voce 10, fatto del fondatore: "le notifiche agli orari di
      // ogni dono del giorno non funzionano e nemmeno il pulsante nel menu
      // utente".
      //
      // **Sul pulsante aveva ragione al cento per cento**: questa voce era un
      // `teaser`, cioe' una voce che al tocco racconta cosa arrivera'. Non era
      // rotta, **non esisteva**: prometteva "qui sceglierai" e non faceva
      // scegliere niente.
      //
      // **La regia delle chiamate c'era gia' e funzionava**, e riprogramma a
      // ogni avvio; ma si ferma alla prima riga se il permesso non c'e', e su
      // Android 13 e oltre **il permesso va chiesto e nessuno lo chiedeva da
      // qui**. Adesso il tocco lo chiede e poi programma davvero.
      //
      // **E DAL TOCCO SI APRE IL MENU', invece di decidere per la persona.**
      // Ordine BC voce 05, parole del fondatore: "sara' proprio l'utente che
      // potra' gestire e attivare o disattivare i singoli orari delle
      // notifiche nel menu' notifiche". Prima il tocco chiedeva il permesso e
      // programmava tutto insieme: un interruttore solo per cinque
      // appuntamenti, e per spegnerne uno bisognava uscire dall'app.
      _AccountEntry(
        id: 'notifiche',
        title: 'Notifiche',
        subtitle: 'Gli appuntamenti dei doni del giorno',
        icon: Icons.notifications_none_rounded,
        onTap: (context) =>
            Navigator.of(context).push(NotificheScreen.route()),
      ),
      const _AccountEntry(
        id: 'privacy',
        title: 'Privacy',
        subtitle: 'Dati, consensi e sicurezza',
        icon: Icons.shield_outlined,
        teaser: 'Qui vedrai i tuoi consensi e i tuoi dati, con i comandi per '
            'gestirli. Intanto la cancellazione completa vive già qui sotto.',
      ),
      // CUSTODIRE IL PROPRIO CIELO, ordine N voce 1c: la via che resta a chi
      // ha rimandato. La voce compare SOLO a chi e' ancora anonimo, perche' a
      // chi ha gia' custodito direbbe una cosa gia' fatta.
      if (_eAnonimo(context))
        _AccountEntry(
          id: 'custodia',
          title: 'Custodisci il tuo cielo',
          // IL SOTTOTITOLO DICE A COSA SERVE, ordine AL voce 06, con parole
          // che non richiedono l'Architetto per essere capite.
          //
          // **E DICE IL VERO, ordine AP voce 08.** Fino alla 2183 questa
          // riga prometteva "non perdi nulla" mentre i traguardi accesi si
          // perdevano davvero: Mauro lo ha misurato reinstallando l'app.
          // Adesso il cammino e' custodito (voci 01 e 03) e la riga puo'
          // NOMINARE cio' che torna, invece di promettere in blocco. Il
          // cielo di nascita torna perche' torna la nascita, che e' cio' da
          // cui si ricalcola: e' la stessa scelta della voce 01.
          subtitle: 'Cielo di nascita, traguardi accesi, ricordi e Eos: '
              'tornano su qualsiasi telefono',
          icon: Icons.shield_moon_outlined,
          onTap: (context) async {
            // **IL TOCCO RISPONDE SEMPRE, ordine AL voce 06.** Qui c'era
            // un'attesa nuda su `quantiMomenti`, che sono SEI letture di rete
            // in fila senza tetto: su una rete lenta il foglio arrivava dopo
            // secondi o mai, e un'eccezione moriva inghiottita dal gesto.
            // "Al tocco non succede nulla" era esattamente questo. Il numero
            // dei momenti qui e' un ornamento: due secondi di tetto, poi si
            // apre comunque, e il guasto si registra invece di sparire.
            final servizi = context.read<AppServices>();
            var momenti = 1;
            try {
              momenti = await servizi.memory
                  .quantiMomenti()
                  .timeout(const Duration(seconds: 2));
            } catch (errore) {
              servizi.guasti.registra(
                operazione: 'conta dei momenti per la custodia',
                errore: errore,
              );
            }
            if (!context.mounted) return;
            // Dall'area account si chiede sempre, anche con zero momenti: qui
            // e' la persona ad averlo cercato, e un invito che non si apre
            // sarebbe un vicolo cieco.
            await mostraInvitoACustodire(context,
                momenti: momenti > 0 ? momenti : 1);
          },
        ),
      // **LA VERIFICA DELL'EMAIL. Ordine AZ voce 06, situazione S18.** La
      // voce compare solo a chi e' entrato con un'email e non l'ha ancora
      // verificata: a chi e' entrato con Google o con Apple l'indirizzo lo ha
      // gia' verificato il fornitore, e chiederglielo sarebbe un compito
      // inventato.
      if (_emailDaVerificare(context))
        _AccountEntry(
          id: 'verifica_email',
          title: 'Verifica la tua email',
          subtitle: 'Serve per rifare la parola se la perdi',
          icon: Icons.mark_email_unread_outlined,
          onTap: (context) => _mandaLaVerifica(context),
        ),
      // **CAMBIARE LA PAROLA. Ordine AZ voce 12, situazione S20.** Anche
      // questa solo a chi ha una parola da cambiare.
      if (_haUnaParola(context))
        _AccountEntry(
          id: 'cambia_parola',
          title: "Cambia la parola d'accesso",
          subtitle: 'Serve un accesso recente, altrimenti te lo diciamo',
          icon: Icons.password_rounded,
          onTap: (context) => _chiediLaParolaNuova(context),
        ),
      // **SI ESCE. Ordine AZ voce 07, situazioni S09, S13 e S23.** Non
      // esisteva: in tutto `lib/` c'era un `signOut` solo, quello di Google
      // dentro `dimentica()`, e non toccava Firebase. Chi sbagliava account
      // non aveva via di ritorno, e due persone sullo stesso telefono non
      // erano previste. La voce compare solo a chi ha custodito: a un anonimo
      // uscire vorrebbe dire buttare il proprio cammino senza averlo mai
      // messo al sicuro, ed e' esattamente cio' che non deve poter succedere
      // per sbaglio.
      if (!_eAnonimo(context))
        _AccountEntry(
          id: 'esci',
          title: 'Esci dal Cerchio',
          subtitle: 'Il tuo cammino resta custodito e ti ritrova al rientro',
          icon: Icons.logout_rounded,
          onTap: (context) => _chiediDiUscire(context),
        ),
      // IL DIRITTO ALL'OBLIO, voce 1f: e' un obbligo, non una gentilezza, e
      // cancella anche cio' che vive sul server.
      _AccountEntry(
        id: 'oblio',
        title: 'Cancella il tuo account',
        subtitle: 'Il Cerchio dimentica tutto, qui e sul server',
        icon: Icons.delete_outline_rounded,
        onTap: (context) => _chiediLOblio(context),
      ),
    ];

    return Scaffold(
      backgroundColor: ColorTokens.neutralDeepest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: ColorTokens.textPrimary,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text('Il tuo account',
            style: TypographyTokens.display(size: 20)),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // **SAPERE CHI SI E'. Ordine AZ voce 09, situazione S36.** In
            // tutta l'app non c'era una sola riga che dicesse con quale
            // account si e' entrati: chi sceglieva l'account sbagliato non
            // aveva modo di accorgersene, e chi si chiedeva se il proprio
            // cielo fosse custodito doveva dedurlo dalla presenza o
            // dall'assenza di un'altra voce.
            //
            // **Sta FUORI dalla lista, e non e' un dettaglio di impaginazione.**
            // La guardia dell'ordine AL voce 06 pretende che ogni voce del
            // menu' porti un'azione oppure il suo anticipo, e ha ragione:
            // una riga che si tocca e non fa niente e' un vicolo cieco.
            // Questa non e' una voce, e' un'intestazione, come il nome sopra
            // un documento. Metterla nella lista avrebbe voluto dire o
            // renderla finta-toccabile o allentare la guardia, e nessuna
            // delle due e' una cura.
            const _IntestazioneDiChiSei(),
            const SizedBox(height: SpacingTokens.md),
            Expanded(
              child: ListView.separated(
          key: const Key('account_list'),
          padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.md,
              SpacingTokens.lg, SpacingTokens.xxxl),
          itemCount: entries.length,
          separatorBuilder: (_, __) => const SizedBox(height: SpacingTokens.sm),
          itemBuilder: (context, i) => _AccountTile(entry: entries[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// L'account, se l'albero ce l'ha. Le prove che montano questa schermata da
/// sola non lo hanno, e devono poterla montare lo stesso: senza account la
/// voce della custodia semplicemente non c'e'.
bool _eAnonimo(BuildContext context) {
  try {
    return context.watch<AccountDelCerchio>().eAnonimo;
  } catch (errore) {
    // Si ignora: senza account nell'albero la voce della custodia non c'e',
    // ed e' il comportamento voluto nelle prove che montano la schermata da
    // sola.
    return false;
  }
}



/// **L'INTESTAZIONE CHE DICE CHI SEI.** Ordine AZ voce 09, situazione S36.
///
/// **Non esisteva**, in nessuna schermata dell'app. Chi entrava con l'account
/// sbagliato non aveva modo di accorgersene, e chi si chiedeva se il proprio
/// cielo fosse custodito doveva dedurlo dal fatto che una certa voce ci fosse
/// o non ci fosse. Adesso e' la prima cosa che si legge.
///
/// **E' un'affermazione, non un'azione**: per questo sta sopra la lista e non
/// dentro. Vedi il commento nel corpo della schermata.
class _IntestazioneDiChiSei extends StatelessWidget {
  const _IntestazioneDiChiSei();

  @override
  Widget build(BuildContext context) {
    AccountDelCerchio? account;
    try {
      account = context.watch<AccountDelCerchio>();
    } catch (errore) {
      // Le prove che montano questa schermata da sola non hanno un account, e
      // devono poterla montare lo stesso.
      account = null;
    }
    final custodito = account != null && !account.eAnonimo;
    // **CIO' CHE SI MOSTRA E' CIO' CHE SI SA, e non di piu'.** Con Apple, che
    // permette di nascondere l'indirizzo, l'email puo' non esserci: allora si
    // dice da quale via si e' entrati, che e' il fatto vero, invece di
    // lasciare un vuoto o di inventare un nome.
    final email = account?.email;
    final via = (account?.fornitori ?? const <String>[])
        .map(_nomeDelFornitore)
        .whereType<String>()
        .join(', ');
    final String titolo;
    final String sotto;
    if (!custodito) {
      titolo = 'Il tuo cielo non è ancora custodito';
      sotto = 'Vive solo su questo telefono';
    } else {
      titolo = email ?? (via.isEmpty ? 'Il tuo cielo è custodito' : 'Entrato con $via');
      sotto = via.isEmpty
          ? 'Il tuo cielo è custodito'
          : 'Il tuo cielo è custodito, via $via';
    }
    return Padding(
      key: const Key('account_chi_sei'),
      padding: const EdgeInsets.fromLTRB(
          SpacingTokens.lg, SpacingTokens.md, SpacingTokens.lg, 0),
      child: Row(
        children: [
          Icon(
            custodito ? Icons.verified_user_outlined : Icons.cloud_off_rounded,
            color: ColorTokens.textSecondary,
            size: 22,
          ),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titolo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TypographyTokens.corpo()
                      .copyWith(color: ColorTokens.textPrimary),
                ),
                Text(
                  sotto,
                  maxLines: 2,
                  style: TypographyTokens.didascalia()
                      .copyWith(color: ColorTokens.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Il nome umano di un fornitore. Nullo per quelli che non si mostrano.
String? _nomeDelFornitore(String id) {
  switch (id) {
    case 'google.com':
      return 'Google';
    case 'apple.com':
      return 'Apple';
    case 'password':
      return 'email';
    default:
      return null;
  }
}


/// Vero se questa persona ha un'email da verificare. Ordine AZ voce 06.
bool _emailDaVerificare(BuildContext context) {
  try {
    return context.watch<AccountDelCerchio>().emailVerificata == false;
  } catch (errore) {
    return false;
  }
}

/// Vero se questa persona ha una parola d'accesso da poter cambiare.
bool _haUnaParola(BuildContext context) {
  try {
    return context.watch<AccountDelCerchio>().fornitori.contains('password');
  } catch (errore) {
    return false;
  }
}

/// Manda la verifica, e dice sempre com'e' andata. Ordine AZ voce 06.
Future<void> _mandaLaVerifica(BuildContext context) async {
  final account = context.read<AccountDelCerchio>();
  final esito = await account.mandaLaVerificaDellEmail();
  if (!context.mounted) return;
  final riuscito = esito == EsitoDellaCustodia.riuscita;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    key: const Key('verifica_mandata'),
    content: Text(riuscito
        ? 'Ti abbiamo mandato una email. Apri il link e la verifica è fatta.'
        : "Non siamo riusciti a mandarla adesso. Riprova fra poco."),
  ));
}

/// **LA PAROLA NUOVA, e cosa si dice quando la sessione è vecchia.**
/// Ordine AZ voce 12, situazione S22.
///
/// Firebase pretende un accesso recente per cambiare la parola. Senza dirlo,
/// il cambio fallirebbe con la frase generica e nessuno capirebbe che basta
/// uscire e rientrare: e' il tipo di vicolo cieco che questo ordine chiude.
Future<void> _chiediLaParolaNuova(BuildContext context) async {
  final campo = TextEditingController();
  final nuova = await showDialog<String>(
    context: context,
    builder: (dialogo) => AlertDialog(
      key: const Key('parola_nuova_form'),
      backgroundColor: ColorTokens.neutralSurface,
      title: Text("Una parola nuova", style: TypographyTokens.titoloScheda()),
      content: TextField(
        key: const Key('parola_nuova_campo'),
        controller: campo,
        obscureText: true,
        style: TypographyTokens.corpo()
            .copyWith(color: ColorTokens.textPrimary),
        decoration: const InputDecoration(
          labelText: 'La parola nuova',
          helperText: 'Almeno sei caratteri',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogo).pop(),
          child: const Text('Annulla'),
        ),
        TextButton(
          key: const Key('parola_nuova_conferma'),
          onPressed: () {
            if (campo.text.length < 6) return;
            Navigator.of(dialogo).pop(campo.text);
          },
          child: const Text('Cambia'),
        ),
      ],
    ),
  );
  if (nuova == null || !context.mounted) return;
  final esito = await context.read<AccountDelCerchio>().cambiaLaParola(nuova);
  if (!context.mounted) return;
  final String frase;
  switch (esito) {
    case EsitoDellaCustodia.riuscita:
      frase = 'Fatto. Da adesso entri con la parola nuova.';
    case EsitoDellaCustodia.nonRiconosciuto:
      // E' `requires-recent-login`, tradotto in una cosa che si puo' fare.
      frase = 'Per cambiare la parola serve un accesso recente. Esci e '
          'rientra, poi riprova.';
    default:
      frase = "Non è riuscito adesso. La tua parola di prima vale ancora.";
  }
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    key: const Key('parola_cambiata'),
    content: Text(frase),
  ));
}


/// **LA DOMANDA PRIMA DI USCIRE.** Ordine AZ voce 07.
///
/// Si dice cosa resta e cosa se ne va, perche' "esci" da solo suona come
/// "perdi tutto": il cammino resta custodito sul Cerchio ed e' proprio questo
/// che rende l'uscita una cosa che si puo' fare senza paura.
Future<void> _chiediDiUscire(BuildContext context) async {
  final conferma = await showDialog<bool>(
    context: context,
    builder: (dialogo) => AlertDialog(
      key: const Key('uscita_conferma'),
      backgroundColor: ColorTokens.neutralSurface,
      title: Text('Uscire dal Cerchio?', style: TypographyTokens.titoloScheda()),
      content: Text(
        'Il tuo cammino resta custodito e ti ritrova appena rientri. Questo '
        'telefono torna come nuovo: dovrai accedere di nuovo per rivedere i '
        'tuoi Sigilli e i tuoi Eos.',
        style: TypographyTokens.corpo()
            .copyWith(color: ColorTokens.textSecondary, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogo).pop(false),
          child: const Text('Resto'),
        ),
        TextButton(
          key: const Key('uscita_conferma_si'),
          onPressed: () => Navigator.of(dialogo).pop(true),
          child: const Text('Esci'),
        ),
      ],
    ),
  );
  if (conferma != true || !context.mounted) return;
  await context.read<AccountDelCerchio>().esci();
  if (!context.mounted) return;
  // **E LA MEMORIA VIVA, non solo il disco.** Ordine AZ voce 15: uscire
  // cancella le chiavi delle preferenze, ma i controller vivono per tutta la
  // sessione. Senza queste righe **il saldo e il cammino di chi se ne e'
  // andato resterebbero a schermo** davanti a chi arriva dopo, fino al
  // riavvio dell'app.
  DimenticanzaDellaMemoriaViva.dimentica(context);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      key: Key('uscita_fatta'),
      content: Text('Sei uscito. Il tuo cammino ti aspetta al rientro.'),
    ),
  );
  // Si torna alla radice: restare in una schermata che parla di un account
  // che non c'e' piu' sarebbe una bugia a schermo.
  Navigator.of(context).popUntil((r) => r.isFirst);
}

/// LA DOMANDA PRIMA DELL'OBLIO, che si fa una volta sola e per intero.
///
/// Si dice cosa sparisce, e non "sei sicuro?": chi cancella deve sapere che
/// se ne vanno la carta natale, la memoria dei Maestri, i Sigilli e gli Eos,
/// e che non c'e' un ripensamento dopo.
Future<void> _chiediLOblio(BuildContext context) async {
  final conferma = await showDialog<bool>(
    context: context,
    builder: (dialogo) => AlertDialog(
      key: const Key('oblio_conferma'),
      backgroundColor: ColorTokens.neutralSurface,
      title: Text('Cancellare tutto?',
          style: TypographyTokens.titoloScheda()),
      content: Text(
        'Spariscono la tua carta natale, la memoria dei Maestri, i tuoi '
        'Sigilli e i tuoi Eos, qui e sul server. Non si torna indietro.',
        style: TypographyTokens.corpo()
            .copyWith(color: ColorTokens.textSecondary, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogo).pop(false),
          child: const Text('Resto nel Cerchio'),
        ),
        TextButton(
          key: const Key('oblio_conferma_si'),
          onPressed: () => Navigator.of(dialogo).pop(true),
          child: const Text('Cancella tutto'),
        ),
      ],
    ),
  );
  if (conferma != true || !context.mounted) return;
  final servizi = context.read<AppServices>();
  await servizi.memory.deleteAllData();
  // **E IL "QUI" DELLA PROMESSA.** Ordine AZ voce 08, situazione S24. Il
  // testo prometteva "qui e sul server": sul server la callable
  // `cancellaIlCerchio` fa `recursiveDelete` del ramo e `deleteUser`
  // dell'account, quindi quella meta' era vera. **Il "qui" non veniva
  // toccato**: restavano il diario, i dati di nascita e la preferenza del
  // rito, e chi avesse ricominciato si sarebbe ritrovato il cammino di prima
  // sopra un Cerchio che non esisteva piu'.
  await DimenticanzaDelTelefono.dimentica();
  if (!context.mounted) return;
  // **E LA MEMORIA VIVA, che era il buco vero.** Ordine BC voce 02.
  //
  // Fatto del fondatore: "ho provato a cancellare l'account, ma i dati
  // restano... il borsellino, i traguardi e altri dati restano anche dopo la
  // conferma". **Il disco veniva pulito dalla riga qui sopra fin dalla build
  // 2195**, ma i controller vivono per tutta la sessione e nessuno li
  // svuotava: quello che si vedeva a schermo era la memoria, e alla prima
  // scrittura tornava anche sul disco appena pulito.
  //
  // **Questa riga esisteva gia', e stava solo nell'uscita**: uscire puliva
  // piu' che cancellare.
  DimenticanzaDellaMemoriaViva.dimentica(context);
  if (!context.mounted) return;
  // **E SI ESCE**, se no si resta dentro con un'identita' che sul server e'
  // stata cancellata: la chiamata dopo riceverebbe un rifiuto e basta.
  try {
    await context.read<AccountDelCerchio>().esci();
  } catch (errore) {
    // Senza account nell'albero non c'e' nessuna sessione da chiudere.
  }
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      key: Key('oblio_fatto'),
      content: Text('Il Cerchio ti ha dimenticato, qui e sul server. '
          'Puoi ricominciare quando vuoi.'),
    ),
  );
  Navigator.of(context).popUntil((r) => r.isFirst);
}

class _AccountEntry {
  const _AccountEntry({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
    this.teaser,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;

  /// Azione della voce. Se assente, la sezione e' ancora in arrivo.
  final void Function(BuildContext context)? onTap;

  /// L'anticipo della voce in arrivo: cosa arrivera', detto con parole sue.
  /// Ordine AL voce 06: una voce senza azione DEVE averlo.
  final String? teaser;

  bool get isLive => onTap != null;
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({required this.entry});

  final _AccountEntry entry;

  void _open(BuildContext context) {
    if (entry.onTap != null) {
      entry.onTap!(context);
      return;
    }
    // **MAI UN VICOLO CIECO, ordine AL voce 06.** Le sezioni in arrivo
    // rispondono con LO STESSO anticipo elegante delle card Coming soon del
    // Santuario: era un foglio scritto a mano solo qui, cioe' la seconda
    // porta sulla stessa esperienza, e il suo testo era una frase qualunque.
    showFeatureSheet(
      context,
      feature: FeatureDefinition(
        id: 'account_${entry.id}',
        title: entry.title,
        teaser: entry.teaser ??
            'Questa sezione sta per aprirsi nel Cerchio. Torna presto per '
                'trovarla pronta.',
        icon: entry.icon,
      ),
      status: FeatureStatus.comingSoon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('account_${entry.id}'),
        onTap: () => _open(context),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(SpacingTokens.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
            color: ColorTokens.neutralSurface.withValues(alpha: 0.5),
            border: Border.all(color: ColorTokens.gold.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ColorTokens.neutralDeep,
                  border:
                      Border.all(color: ColorTokens.gold.withValues(alpha: 0.4)),
                ),
                alignment: Alignment.center,
                child: Icon(entry.icon, color: ColorTokens.goldLight, size: 22),
              ),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // **IL TITOLO NON SI SPEZZA DENTRO LE PAROLE.** Ordine AI
                    // voce 03, dalla foto di Mauro: "NOTIFIC HE" a 360 punti.
                    // Il distintivo "In arrivo" stava FUORI dalla colonna e
                    // rubava la riga: al titolo restavano 83 punti, meno di
                    // una parola. La composizione scelta e' lo SPAZIO
                    // DISPONIBILE: titolo e distintivo vivono in un Wrap
                    // dentro la colonna, il titolo ha tutta la sua larghezza
                    // e il distintivo scende sotto quando non c'e' posto.
                    Wrap(
                      spacing: SpacingTokens.sm,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(entry.title,
                            style: TypographyTokens.display(size: 17)),
                        if (!entry.isLive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  SpacingTokens.radiusPill),
                              color: ColorTokens.gold.withValues(alpha: 0.16),
                              border: Border.all(
                                  color: ColorTokens.gold
                                      .withValues(alpha: 0.5)),
                            ),
                            child: Text('In arrivo',
                                style: TypographyTokens.etichetta()
                                    .copyWith(color: ColorTokens.goldLight)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(entry.subtitle,
                        style: TypographyTokens.corpo().copyWith(
                            color: ColorTokens.textSecondary, height: 1.3)),
                  ],
                ),
              ),
              const SizedBox(width: SpacingTokens.xs),
              Icon(
                entry.isLive
                    ? Icons.chevron_right_rounded
                    : Icons.lock_clock_rounded,
                size: 20,
                color: ColorTokens.goldLight
                    .withValues(alpha: entry.isLive ? 0.9 : 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
