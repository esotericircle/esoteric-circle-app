import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/cammino/custode_del_cammino.dart';
import '../../core/identity/account_del_cerchio.dart';
import '../../core/identity/promessa_della_registrazione.dart';
import 'festa_della_registrazione.dart';
import '../../services/app_services.dart';
import '../../services/server/porta_del_cerchio.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'consensi_della_registrazione.dart';
import '../../design_system/transizioni/velo_del_cerchio.dart';

/// LE TRE VIE PER CUSTODIRE IL PROPRIO CIELO, in un componente solo.
///
/// **Perche' un componente e non due schermate.** La richiesta si presenta in
/// due momenti (l'ultimo passo del Risveglio e l'invito successivo a chi ha
/// rimandato) e in tutti e due si offre esattamente la stessa cosa: se i
/// pulsanti vivessero in due posti, un giorno uno dei due avrebbe una via in
/// meno e nessuno se ne accorgerebbe.
///
/// **Apple c'e' sempre dove Google c'e', su iOS.** Le regole dell'App Store
/// pretendono Sign in with Apple accanto a qualunque accesso social di terzi,
/// e questa e' la riga che lo garantisce: le due vie nascono insieme.
class VieDellaCustodia extends StatelessWidget {
  const VieDellaCustodia({
    super.key,
    required this.suScelta,
    this.inCorso,
  });

  /// Cosa fare quando una via viene scelta. L'email arriva con le sue
  /// credenziali gia' raccolte.
  final void Function(ViaDellaCustodia via, {String? email, String? parola})
      suScelta;

  /// La via in corso, se una e' in corso: gli altri pulsanti restano fermi.
  final ViaDellaCustodia? inCorso;

  /// Su iOS e macOS la via di Apple e' obbligatoria accanto a Google, e la
  /// piattaforma si guarda dal tema, non da `Platform`: cosi' una prova puo'
  /// montare la scena come la vedrebbe un iPhone senza girare su un iPhone.
  static bool suApple(BuildContext context) {
    final piattaforma = Theme.of(context).platform;
    return piattaforma == TargetPlatform.iOS ||
        piattaforma == TargetPlatform.macOS;
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // **I CONSENSI STANNO QUI, sopra le vie, e in nessun altro posto.**
        // Ordine CE voce 01. Le vie d'accesso vivono in tre schermate diverse:
        // montare i consensi accanto a ognuna vorrebbe dire tre copie che
        // divergono al primo che ne cambia una. Qui sono una cosa sola col
        // gesto che le usa.
        const ConsensiDellaRegistrazione(),
        const SizedBox(height: SpacingTokens.md),
        _PulsanteDellaVia(
          chiave: const Key('custodia_google'),
          etichetta: 'Continua con Google',
          icona: Icons.g_mobiledata_rounded,
          inCorso: inCorso == ViaDellaCustodia.google,
          fermo: inCorso != null,
          suTocco: () => suScelta(ViaDellaCustodia.google),
        ),
        if (suApple(context)) ...[
          const SizedBox(height: SpacingTokens.sm),
          _PulsanteDellaVia(
            chiave: const Key('custodia_apple'),
            etichetta: 'Continua con Apple',
            icona: Icons.apple_rounded,
            inCorso: inCorso == ViaDellaCustodia.apple,
            fermo: inCorso != null,
            suTocco: () => suScelta(ViaDellaCustodia.apple),
          ),
        ],
        const SizedBox(height: SpacingTokens.sm),
        TextButton(
          key: const Key('custodia_email'),
          onPressed: inCorso != null
              ? null
              : () async {
                  final dati = await _chiediEmail(context);
                  if (dati == null) return;
                  suScelta(
                    ViaDellaCustodia.email,
                    email: dati.$1,
                    parola: dati.$2,
                  );
                },
          child: Text(
            'Preferisco un\'email',
            style:
                TypographyTokens.etichetta().copyWith(color: palette.goldSoft),
          ),
        ),
      ],
    );
  }

  /// L'email e la parola d'accesso, raccolte in una finestra sola.
  ///
  /// Non si chiede il telefono: sta scritto nei briefing e vale anche qui.
  ///
  /// **E ADESSO IL FOGLIO PARLA.** Ordine AZ voce 10, situazione S21. Il
  /// pulsante "Custodisci" faceva `if (!a.contains('@') || b.length < 6)
  /// return;`, cioe' **non faceva niente e non diceva niente**: si toccava,
  /// non succedeva nulla, e nessuno spiegava che mancava una chiocciola o che
  /// la parola era corta. Era un vicolo cieco muto in mezzo alla
  /// registrazione.
  static Future<(String, String)?> _chiediEmail(BuildContext context) {
    final email = TextEditingController();
    final parola = TextEditingController();
    final palette = context.palette;
    return dialogoDelCerchio<(String, String)>(
      context: context,
      builder: (dialogo) => _FoglioDellEmail(
        email: email,
        parola: parola,
        palette: palette,
        // **IL FONDO SI DICHIARA DOVE LA PORTA SI APRE.** Ordine AL voce 04:
        // una porta che lascia decidere il fondo a Material si apre bianca
        // sopra un cielo notturno. Il foglio lo riceve invece di sceglierlo,
        // cosi' chi legge questa chiamata vede su cosa si apre.
        backgroundColor: palette.surfaceElevated,
      ),
    );
  }
}

class _PulsanteDellaVia extends StatelessWidget {
  const _PulsanteDellaVia({
    required this.chiave,
    required this.etichetta,
    required this.icona,
    required this.suTocco,
    required this.inCorso,
    required this.fermo,
  });

  final Key chiave;
  final String etichetta;
  final IconData icona;
  final VoidCallback suTocco;
  final bool inCorso;
  final bool fermo;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        key: chiave,
        onPressed: fermo ? null : suTocco,
        style: FilledButton.styleFrom(
          backgroundColor: palette.surfaceElevated,
          foregroundColor: palette.goldSoft,
          side: BorderSide(color: palette.gold.withValues(alpha: 0.45)),
          padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
        ),
        icon: inCorso
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icona, size: 22),
        label: Text(etichetta, style: TypographyTokens.etichetta()),
      ),
    );
  }
}

/// COSA SI DICE QUANDO LA CUSTODIA NON RIESCE, e si dice sempre qualcosa.
///
/// Ogni esito ha la sua frase: chi annulla non ha sbagliato niente, chi trova
/// quell'identita' gia' presa deve sapere che il Cerchio che sta usando NON
/// e' stato buttato via, e chi incontra un imprevisto deve sapere che puo'
/// riprovare piu' tardi senza perdere nulla.
String? frasePerEsito(EsitoDellaCustodia esito) {
  switch (esito) {
    case EsitoDellaCustodia.riuscita:
      return null;
    case EsitoDellaCustodia.annullata:
      return null;
    // **NIENTE PROMESSE DI UNIONE, ordine AL voce 07.** Qui si prometteva di
    // unire i due Cerchi scrivendoci: un'unione che non esiste da nessuna
    // parte del sistema. La via in avanti vera e' il "Continua come" sotto.
    case EsitoDellaCustodia.giaDiUnAltroCerchio:
      return 'Quell\'identità vive già in un altro Cerchio. Puoi entrarci '
          'qui sotto, oppure provare con un\'altra via.';
    case EsitoDellaCustodia.cerchioCambiato:
      return 'Qualcosa non ha funzionato e il tuo cielo non è stato '
          'collegato. Niente è andato perso: riprova più tardi.';
    // **NESSUN RAMO MUTO.** Ordine AX voce 01: se non si entra, a schermo
    // compare il perche' e cosa fare, in italiano e senza codici tecnici.
    case EsitoDellaCustodia.nonRiconosciuto:
      return 'Non troviamo un Cerchio con queste chiavi. Controlla di aver '
          "scelto l'account giusto, oppure entra con un'altra via.";
    case EsitoDellaCustodia.nonRiuscita:
      return 'Non è riuscito adesso. Il tuo cielo resta dove sta: puoi '
          'riprovare quando vuoi dall\'area account.';
    // **NON E' UN GUASTO, ed è importante che non lo sembri.** Ordine AZ: era
    // una domanda che non andava fatta, e chi la riceve deve solo proseguire.
    case EsitoDellaCustodia.giaCustodito:
      return 'Il tuo cielo è già custodito. Non devi fare altro.';
  }
}

/// "CONTINUA COME [NOME]", ordine AL voce 07, in un componente solo.
///
/// Quando la custodia risponde che l'identita' vive gia' in un altro
/// Cerchio, la via in avanti e' entrare in quel Cerchio: il pulsante porta
/// il nome riconosciuto e, PRIMA del tocco, una riga sola e onesta dice cosa
/// succede al cammino di questo telefono.
///
/// **LA RIGA E' CAMBIATA CON L'ORDINE AP, perche' il sistema e' cambiato.**
/// Prima diceva che i due Cerchi non si uniscono, ed era vero: nessuna
/// unione esisteva. Dalla voce 03 il cammino di questo telefono si FONDE con
/// quello del Cerchio in cui si entra, sul server, contatore piu' alto e
/// Sigilli in unione. Lasciare la vecchia riga sarebbe stato promettere in
/// difetto, che e' comunque una bugia detta mentre si chiede fiducia. Cio'
/// che davvero NON si fonde sono Eos e ricordi, e infatti la riga continua a
/// dirlo.
///
/// E' un componente unico per le due scene che lo mostrano, il foglio
/// dell'area account e il passo del Risveglio: due copie diventerebbero due
/// promesse diverse al primo ritocco.
class ContinuaComeRiconosciuto extends StatelessWidget {
  const ContinuaComeRiconosciuto({
    super.key,
    required this.account,
    required this.suEsito,
  });

  /// L'account lo porta chi ospita, come gia' fa il foglio dell'invito: il
  /// componente vive anche dentro fogli sul Navigator radice, dove pescare
  /// dall'albero e' fragile.
  final AccountDelCerchio account;

  /// Riceve l'esito dell'ingresso: chi ospita decide come chiudersi.
  final void Function(EsitoDellaCustodia esito) suEsito;

  @override
  Widget build(BuildContext context) {
    final nome = account.nomeRiconosciuto;
    if (nome == null) return const SizedBox.shrink();
    final palette = MaestroScope.forse(context) ?? MaestroPalette.neutral;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // **I CONSENSI CI SONO ANCHE QUI, ordine CF voce 15.**
        //
        // **Domanda del fondatore, verbatim**: "quando mi registro la prima
        // volta o quando disinstallo e poi reinstallo inserendo poi la mia
        // e-mail precedente, non dovrebbe esserci scritto che 'facendo click
        // accetti la privacy policy'?"
        //
        // **Aveva ragione a meta', ed era la meta' peggiore.** La riga esiste,
        // e' una sola in tutto il codice, e compare nella prima registrazione
        // con email e in quella con Google o Apple, perche' tutte e tre
        // montano `VieDellaCustodia`. **Questo ramo no**: chi rientra con
        // un'email gia' registrata vede questo pulsante, che e' costruito
        // qui e non passa di la'. Premerlo e' un ingresso nel Cerchio come
        // gli altri, quindi la riga che dice cosa si accetta deve esserci.
        const ConsensiDellaRegistrazione(),
        const SizedBox(height: SpacingTokens.sm),
        Text(
          'I passi fatti su questo telefono si uniscono al cammino di quel '
          'Cerchio: Eos e ricordi restano quelli del Cerchio in cui entri.',
          key: const Key('continua_come_riga_onesta'),
          style: TypographyTokens.didascalia()
              .copyWith(color: ColorTokens.textSecondary, height: 1.4),
        ),
        const SizedBox(height: SpacingTokens.sm),
        FilledButton(
          key: const Key('continua_come'),
          style: FilledButton.styleFrom(
            backgroundColor: palette.gold,
            foregroundColor: palette.deepest,
            padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
          ),
          onPressed: () async {
            final esito = await account.entraNelCerchioRiconosciuto();
            suEsito(esito);
          },
          child: Text('Continua come $nome',
              overflow: TextOverflow.ellipsis,
              style: TypographyTokens.etichetta()
                  .copyWith(color: palette.deepest)),
        ),
      ],
    );
  }
}

/// L'INVITO A CHI HA RIMANDATO, col numero VERO dei momenti custoditi.
///
/// Il numero lo conta la memoria (`quantiMomenti`): se fosse inventato, o
/// gonfiato con cose che la persona non riconosce come sue, questa frase
/// diventerebbe una vanteria proprio nel momento in cui chiede fiducia. Con
/// zero momenti l'invito NON si mostra: non c'e' ancora niente da perdere.
Future<bool> mostraInvitoACustodire(
  BuildContext context, {
  required int momenti,
}) async {
  // **ANCHE A ZERO MOMENTI, per il primo avviso.** Ordine BG voce 03: il
  // rifiuto sullo zero bruciava l'avviso "una volta, subito" di BE.07,
  // perche' il primo giro arriva prima di qualunque momento custodito. Con
  // zero momenti il foglio non vanta niente: dice la verita' del primo
  // avviso, e la gratuita'.
  final palette = context.palette;
  final account = context.read<AccountDelCerchio>();
  final esito = await foglioDelCerchio<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (foglio) => _FoglioDellInvito(
      momenti: momenti,
      palette: palette,
      account: account,
    ),
  );
  // **LA FESTA DELLA REGISTRAZIONE, ordine BH voce 02.** La custodia
  // riuscita e' la registrazione vera: da qui parte la scena del premio,
  // o la riga onesta quando il premio non c'e' (verifica in attesa,
  // lapide). Un punto solo per tutti i chiamanti del foglio.
  if (esito == true && context.mounted) {
    await FestaDellaRegistrazione.dopoLaCustodia(context);
  }
  return esito ?? false;
}

/// LA PORTA PICCOLA PER CHI TORNA. Ordine AP voce 04.
///
/// **Non e' un muro, ed e' la decisione di Mauro del 18 agosto**: la prima
/// schermata resta il risveglio, e la via per chi torna e' una porta
/// piccola. Chi arriva per la prima volta prosegue senza notarla.
///
/// **Non e' nemmeno una seconda porta sull'accesso**: dentro ci sono le
/// stesse `VieDellaCustodia` del foglio della custodia, cioe' Google, Apple
/// dove serve, ed email. Cambia il motivo per cui si apre, non la strada.
/// Torna vero quando il riconoscimento e' avvenuto.
Future<bool> mostraLaPortaPerChiTorna(BuildContext context) async {
  final palette = context.palette;
  final account = context.read<AccountDelCerchio>();
  final esito = await foglioDelCerchio<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (foglio) => _FoglioDellInvito(
      momenti: 0,
      palette: palette,
      account: account,
      perChiTorna: true,
    ),
  );
  return esito ?? false;
}

class _FoglioDellInvito extends StatefulWidget {
  const _FoglioDellInvito({
    required this.momenti,
    required this.palette,
    required this.account,
    this.perChiTorna = false,
  });

  /// **CHI TORNA VEDE UN'ALTRA FRASE, non un'altra porta.** Ordine AP voce
  /// 04: le vie di accesso sono le stesse, cambia cio' che si sta facendo.
  /// A chi custodisce si dice cosa non perdera'; a chi torna si dice che il
  /// Cerchio lo stava aspettando.
  final bool perChiTorna;

  final int momenti;
  final MaestroPalette palette;
  final AccountDelCerchio account;

  @override
  State<_FoglioDellInvito> createState() => _FoglioDellInvitoState();
}

class _FoglioDellInvitoState extends State<_FoglioDellInvito> {
  ViaDellaCustodia? _inCorso;
  String? _guaio;
  bool _riconosciuto = false;

  Future<void> _custodisci(ViaDellaCustodia via,
      {String? email, String? parola}) async {
    setState(() {
      _inCorso = via;
      _guaio = null;
      _riconosciuto = false;
    });
    // **CHI TORNA ENTRA, CHI CUSTODISCE ELEVA.** Ordine AX voce 01, ed e' la
    // cura del difetto piu' grave della 2191.
    //
    // Questa porta si apre in due momenti diversi e faceva la stessa cosa in
    // tutti e due: attaccare l'identita' all'anonimo di questo telefono.
    // Giusto per chi custodisce il proprio cielo la prima volta; **sbagliato
    // per chi torna**, perche' quell'identita' e' gia' di un Cerchio e il
    // collegamento fallisce per forza. La via d'uscita era un secondo tocco
    // che riusava la credenziale gia' spesa dal tentativo fallito, e su Google
    // un token speso non entra piu': **la persona restava fuori, e da li' in
    // poi nemmeno la registrazione ripartiva**.
    //
    // **E LA PORTA SI RIAPRE ANCHE SE QUALCOSA LANCIA.** L'ordine chiede di
    // cercare uno stato appeso che impedisca al tentativo dopo di partire:
    // eccolo. `_inCorso` spegne tutti i pulsanti mentre si aspetta, e veniva
    // rimesso a nulla solo lungo la via buona. Le porte dell'identita' oggi
    // catturano tutto, ma `rileggi()` sopra di loro no: **una sola eccezione
    // da li' lasciava la scheda bloccata per sempre**, e la persona doveva
    // chiudere e riaprire l'app. Il `finally` toglie quel per sempre.
    EsitoDellaCustodia esito;
    try {
      esito = widget.perChiTorna
          ? await widget.account
              .entraDirettamente(via, email: email, parola: parola)
          : await widget.account.custodisci(via, email: email, parola: parola);
    } catch (imprevisto) {
      // **QUALUNQUE COSA SIA, LA SCHEDA DEVE RIPARTIRE.** Non si guarda cosa
      // e' successo perche' la condotta e' la stessa in tutti i casi: si dice
      // alla persona che non e' riuscito e si riaccendono i pulsanti. Il
      // dettaglio tecnico non cambierebbe niente di cio' che si fa qui.
      esito = EsitoDellaCustodia.nonRiuscita;
    } finally {
      if (mounted) setState(() => _inCorso = null);
    }
    if (!mounted) return;
    if (esito == EsitoDellaCustodia.riuscita) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _guaio = frasePerEsito(esito);
      // **LA STRADA PER CHI NON RISULTA, ordine BH voce 03.** Parole del
      // fondatore: se il sistema non rileva l'email, "l'utente deve essere
      // avvertito che l'email non risulta registrata e che potra' fare la
      // registrazione poco dopo oppure nel menu utente". La frase comune
      // dice il primo pezzo; qui, solo sulla porta di chi torna, si
      // aggiunge la strada in avanti.
      if (widget.perChiTorna && esito == EsitoDellaCustodia.nonRiconosciuto) {
        _guaio = '${_guaio!} Se non ti sei mai registrato, potrai farlo '
            'tra poco, alla fine del rito, oppure dal menu utente.';
      }
      _riconosciuto = esito == EsitoDellaCustodia.giaDiUnAltroCerchio;
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    // IL NUMERO SI DICE COME LO DIREBBE UNA PERSONA: uno non e' "1 momenti".
    final quanti = widget.momenti == 1
        ? 'un tuo momento'
        : '${widget.momenti} tuoi momenti';
    // A zero momenti (il primo avviso) niente vanterie: un'altra testata.
    final senzaMomenti = widget.momenti <= 0 && !widget.perChiTorna;
    return Container(
      key: const Key('invito_a_custodire'),
      padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.md,
          SpacingTokens.lg, SpacingTokens.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.surfaceElevated, palette.deepest],
        ),
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(SpacingTokens.radiusXl)),
        border: Border.all(color: palette.gold.withValues(alpha: 0.3)),
      ),
      child: SafeArea(
        top: false,
        // **IL FOGLIO SCORRE, ordine CE voce 01.** Qui dentro sono entrati i
        // consensi, e il foglio ha smesso di essere di altezza fissa: nel
        // caso in cui il Cerchio risulta gia' di un altro, con la riga
        // onesta e "Continua come" in piu', la colonna traboccava di 24
        // punti e quel che stava sotto non si vedeva. Un foglio che cresce
        // col contenuto deve poter scorrere.
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.shield_moon_outlined,
                      color: palette.goldSoft, size: 22),
                  const SizedBox(width: SpacingTokens.sm),
                  Expanded(
                    child: Text(
                        widget.perChiTorna
                            ? 'Il Cerchio ti stava aspettando'
                            : (senzaMomenti
                                ? 'Il Cerchio può custodire il tuo cielo'
                                : 'Il Cerchio custodisce $quanti'),
                        key: const Key('invito_numero_dei_momenti'),
                        style: TypographyTokens.titoloScheda()
                            .copyWith(color: palette.goldSoft)),
                  ),
                ],
              ),
              const SizedBox(height: SpacingTokens.sm),
              Text(
                widget.perChiTorna
                    ? 'Entra con l\'account che usavi: ritrovi la tua carta '
                        'natale, i Sigilli accesi e i tuoi Eos.'
                    : (senzaMomenti
                        ? 'Stai usando il Cerchio senza un account: ciò che '
                            'farai vive solo su questo telefono. Registrarsi è '
                            'gratuito, basta un tocco e nulla si perde più.'
                        : 'Vuoi che restino tuoi anche se cambi telefono? '
                            'Registrarsi è gratuito e basta un tocco: nulla di '
                            'quello che hai fatto si perde.'),
                style: TypographyTokens.corpo()
                    .copyWith(color: ColorTokens.textSecondary, height: 1.4),
              ),
              // **LA PROMESSA DELLA REGISTRAZIONE, ordine BH voce 01.** Il
              // premio scritto nell'invito, col numero del server, in oro:
              // e' la riga che motiva. Chi torna non la vede: il suo
              // benvenuto e' gia' stato pagato, promettere qui sarebbe
              // promettere il falso.
              if (!widget.perChiTorna) ...[
                const SizedBox(height: SpacingTokens.xs),
                Text(
                  PromessaDellaRegistrazione.frase(context),
                  key: const Key('promessa_della_registrazione'),
                  style: TypographyTokens.corpo()
                      .copyWith(color: palette.goldSoft, height: 1.4),
                ),
              ],
              if (_guaio != null) ...[
                const SizedBox(height: SpacingTokens.sm),
                Text(_guaio!,
                    key: const Key('invito_guaio'),
                    style: TypographyTokens.didascalia()
                        .copyWith(color: palette.goldSoft, height: 1.4)),
              ],
              // LA VIA IN AVANTI, ordine AL voce 07: quando il Cerchio e' di
              // un altro, si puo' entrarci col proprio nome, dopo la riga
              // onesta. "Piu' tardi" resta qui sotto, come sempre.
              if (_riconosciuto) ...[
                const SizedBox(height: SpacingTokens.md),
                ContinuaComeRiconosciuto(
                  account: widget.account,
                  suEsito: (esito) async {
                    if (!mounted) return;
                    if (esito == EsitoDellaCustodia.riuscita) {
                      // **ANCHE DA QUI IL CAMMINO TORNA, ordine AP voce 06.**
                      // Il foglio si chiude prima, perche' la scena del
                      // ritrovamento e' una rotta e non deve aprirsi dietro un
                      // foglio che sta per sparire; il giro del Custode e' lo
                      // stesso della porta piccola della voce 04.
                      final navigatore = Navigator.of(context);
                      final radice = navigatore.context;
                      navigatore.pop(true);
                      await CustodeDelCammino.dopoIlRiconoscimento(radice);
                      return;
                    }
                    setState(() => _guaio = frasePerEsito(esito));
                  },
                ),
              ],
              const SizedBox(height: SpacingTokens.lg),
              // **LA PORTA DI CHI TORNA SONDA, NON SEMBRA UNA REGISTRAZIONE.**
              // Ordine BI voce 01, parole del fondatore: "deve solo
              // controllare che effettivamente l'email dell'utente sia gia'
              // presente nel server e comunicarlo all'utente. Se non esiste,
              // l'utente deve proseguire per forza con l'onboarding". Prima
              // l'email, poi il server risponde e la porta instrada: niente
              // account creati in silenzio, niente rifiuti senza spiegazione.
              if (widget.perChiTorna)
                _SondaDellIngresso(
                  account: widget.account,
                  inCorso: _inCorso,
                  suScelta: (via, {email, parola}) {
                    _custodisci(via, email: email, parola: parola);
                  },
                  suProsegui: () => Navigator.of(context).pop(false),
                )
              else
                VieDellaCustodia(
                    inCorso: _inCorso,
                    suScelta: (via, {email, parola}) {
                      _custodisci(via, email: email, parola: parola);
                    }),
              const SizedBox(height: SpacingTokens.xs),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  key: const Key('invito_piu_tardi'),
                  onPressed: _inCorso != null
                      ? null
                      : () {
                          widget.account.rimanda();
                          Navigator.of(context).pop(false);
                        },
                  child: Text('Più tardi',
                      style: TypographyTokens.etichetta()
                          .copyWith(color: ColorTokens.textSecondary)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// **IL FOGLIO DELL'EMAIL, CHE ADESSO DICE COSA NON VA.** Ordine AZ voce 10.
///
/// **Prima era muto.** Il pulsante "Custodisci" faceva
/// `if (!a.contains('@') || b.length < 6) return;`: si toccava e non
/// succedeva niente. Chi sbagliava una lettera nell'indirizzo, o sceglieva
/// una parola di cinque caratteri, restava fermo davanti a un pulsante che
/// non rispondeva, **senza sapere che cosa correggere**.
///
/// **E porta la via per la parola persa.** Ordine AZ voce 05: e' il posto
/// giusto, perche' e' l'unico momento in cui a qualcuno viene chiesta una
/// parola d'accesso.
/// LA REGOLA DELLA PASSWORD, ordine BI voce 02, decisa dal fondatore:
/// "minimo 8 caratteri, almeno una maiuscola, almeno un numero e almeno un
/// carattere speciale e devi scrivere queste regole e validarle". Torna la
/// frase del guaio, o nulla se la password rispetta la regola.
/// **IL CANCELLO DELL'EMAIL, in un punto solo.** Ordine CB voce 03.
///
/// La regola stava scritta a mano dentro il modulo della registrazione. Il
/// cambio dell'email del menu' utente ne aveva bisogno identica, e copiarla
/// avrebbe fatto due regole che il giorno dopo dicono cose diverse: come per
/// la parola, il cancello e' una funzione sola e le due schermate la chiamano.
String? guaioDellEmail(String email) {
  if (email.isEmpty) return "Manca l'email";
  if (!email.contains(String.fromCharCode(64)) || !email.contains('.')) {
    return 'Questo indirizzo non sembra completo: manca la chiocciola o il '
        'punto';
  }
  return null;
}

String? guaioDellaPassword(String parola) {
  if (parola.isEmpty) return 'Manca la Password';
  if (parola.length < 8) {
    return 'Almeno 8 caratteri: ne mancano ${8 - parola.length}';
  }
  if (!parola.contains(RegExp('[A-Z]'))) {
    return 'Serve almeno una lettera maiuscola';
  }
  if (!parola.contains(RegExp('[0-9]'))) return 'Serve almeno un numero';
  if (!parola.contains(RegExp(r'[^A-Za-z0-9]'))) {
    return 'Serve almeno un carattere speciale (per esempio ! ? # @)';
  }
  return null;
}

/// La regola scritta sotto il campo, sempre visibile.
const String regolaDellaPassword =
    'Almeno 8 caratteri, con una maiuscola, un numero e un carattere '
    'speciale';

class _FoglioDellEmail extends StatefulWidget {
  const _FoglioDellEmail({
    required this.email,
    required this.parola,
    required this.palette,
    required this.backgroundColor,
  });

  final TextEditingController email;
  final TextEditingController parola;
  final MaestroPalette palette;

  /// Il fondo su cui il foglio si apre, dichiarato da chi lo apre.
  final Color backgroundColor;

  @override
  State<_FoglioDellEmail> createState() => _FoglioDellEmailState();
}

class _FoglioDellEmailState extends State<_FoglioDellEmail> {
  String? _guaioEmail;
  String? _guaioParola;
  String? _detto;

  /// L'occhiolino, ordine BI voce 02: "l'utente deve essere certo di
  /// quello che scrive". Parte coperta, si rivela con un tocco.
  bool _passwordCoperta = true;

  void _prova() {
    final email = widget.email.text.trim();
    final parola = widget.parola.text;
    setState(() {
      _detto = null;
      _guaioEmail = guaioDellEmail(email);
      // **LA REGOLA DEL FONDATORE, ordine BI voce 02**: otto caratteri,
      // maiuscola, numero, carattere speciale, scritti e validati.
      _guaioParola = guaioDellaPassword(parola);
    });
    if (_guaioEmail != null || _guaioParola != null) return;
    // Il gestore password del dispositivo riceve il segnale che le
    // credenziali sono buone e vanno ricordate.
    TextInput.finishAutofillContext();
    Navigator.of(context).pop((email, parola));
  }

  Future<void> _parolaPersa() async {
    final email = widget.email.text.trim();
    if (!email.contains('@')) {
      setState(() => _guaioEmail =
          "Scrivi qui la tua email e te ne mandiamo una per reimpostare "
              "la Password");
      return;
    }
    final account = context.read<AccountDelCerchio>();
    await account.mandaLaViaPerLaParola(email);
    if (!mounted) return;
    // **LA STESSA FRASE IN TUTTI I CASI, ed e' una scelta.** Dire "quella
    // email non esiste" regalerebbe a chiunque un modo per sapere chi fa
    // parte del Cerchio.
    setState(() {
      _guaioEmail = null;
      _detto = "Se quell'indirizzo fa parte del Cerchio, ti abbiamo mandato "
          "una email per reimpostare la Password.";
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    return AlertDialog(
      key: const Key('custodia_email_form'),
      backgroundColor: widget.backgroundColor,
      title: Text('Registrati con la tua email',
          style: TypographyTokens.titoloScheda()
              .copyWith(color: palette.goldSoft)),
      // **IL GESTORE PASSWORD, ordine BI voce 02**: il gruppo di autofill
      // con i suggerimenti giusti fa offrire al dispositivo di salvare le
      // credenziali appena la registrazione riesce.
      content: AutofillGroup(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('custodia_email_campo'),
              controller: widget.email,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              autofillHints: const [
                AutofillHints.username,
                AutofillHints.email
              ],
              style: TypographyTokens.corpo()
                  .copyWith(color: ColorTokens.textPrimary),
              decoration: InputDecoration(
                labelText: 'La tua email',
                errorText: _guaioEmail,
                errorMaxLines: 3,
              ),
            ),
            const SizedBox(height: SpacingTokens.sm),
            TextField(
              key: const Key('custodia_parola_campo'),
              controller: widget.parola,
              obscureText: _passwordCoperta,
              autofillHints: const [AutofillHints.newPassword],
              style: TypographyTokens.corpo()
                  .copyWith(color: ColorTokens.textPrimary),
              decoration: InputDecoration(
                labelText: 'Password',
                helperText: regolaDellaPassword,
                helperMaxLines: 2,
                errorText: _guaioParola,
                errorMaxLines: 2,
                // **L'OCCHIOLINO, ordine BI voce 02**: si rivela e si copre
                // con un tocco, cosi' si e' certi di quello che si scrive.
                suffixIcon: IconButton(
                  key: const Key('custodia_occhiolino'),
                  icon: Icon(
                    _passwordCoperta
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: ColorTokens.textSecondary,
                  ),
                  onPressed: () =>
                      setState(() => _passwordCoperta = !_passwordCoperta),
                ),
              ),
            ),
            if (_detto != null) ...[
              const SizedBox(height: SpacingTokens.sm),
              Text(
                _detto!,
                key: const Key('custodia_parola_persa_detto'),
                style: TypographyTokens.didascalia()
                    .copyWith(color: palette.goldSoft),
              ),
            ],
            const SizedBox(height: SpacingTokens.xs),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                key: const Key('custodia_parola_persa'),
                onPressed: _parolaPersa,
                child: Text(
                  'Hai perso la Password?',
                  style: TypographyTokens.didascalia()
                      .copyWith(color: palette.goldSoft),
                ),
              ),
            ),
          ],
        ),
      ),
      // **I BOTTONI COI COLORI DI CASA, ordine BI voce 02**: il blu del
      // tema di Material non si legge sul fondo notturno. L'azione che
      // conferma e' in oro, quella che lascia in grigio leggibile.
      actions: [
        TextButton(
          style:
              TextButton.styleFrom(foregroundColor: ColorTokens.textSecondary),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annulla'),
        ),
        TextButton(
          key: const Key('custodia_email_conferma'),
          style: TextButton.styleFrom(foregroundColor: palette.goldSoft),
          onPressed: _prova,
          child: const Text('Registrati'),
        ),
      ],
    );
  }
}

/// LA SONDA DELL'INGRESSO. Ordine BI voce 01.
///
/// Tre momenti: si chiede l'email, il server dice se ha un Cerchio e con
/// quali vie, la porta instrada. Chi non risulta lo legge in chiaro e
/// prosegue il rito; chi risulta entra con la SUA via, senza vedere moduli
/// che non c'entrano. Se il server non risponde, la sonda lo dice e apre
/// le tre vie classiche: mai un vicolo cieco.
class _SondaDellIngresso extends StatefulWidget {
  const _SondaDellIngresso({
    required this.account,
    required this.inCorso,
    required this.suScelta,
    required this.suProsegui,
  });

  final AccountDelCerchio account;
  final ViaDellaCustodia? inCorso;
  final void Function(ViaDellaCustodia via, {String? email, String? parola})
      suScelta;

  /// Chiude il foglio per proseguire il rito: la strada obbligata di chi
  /// non risulta registrato.
  final VoidCallback suProsegui;

  @override
  State<_SondaDellIngresso> createState() => _SondaDellIngressoState();
}

class _SondaDellIngressoState extends State<_SondaDellIngresso> {
  final _email = TextEditingController();
  final _parola = TextEditingController();
  bool _controlloInCorso = false;
  bool _passwordCoperta = true;
  String? _guaio;
  String? _dettoDellaParola;

  /// La risposta del server, quando c'e'. Nulla prima del controllo.
  EsitoDellaSonda? _esito;

  /// Vero quando il server non ha risposto: si aprono le vie classiche.
  bool _serverMuto = false;

  Future<void> _controlla() async {
    final email = _email.text.trim().toLowerCase();
    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      setState(() =>
          _guaio = 'Scrivi la tua email per controllare se ha un Cerchio');
      return;
    }
    setState(() {
      _guaio = null;
      _controlloInCorso = true;
    });
    PortaDelCerchio? porta;
    try {
      porta = context.read<AppServices>().porta;
    } catch (senzaProvider) {
      porta = null;
    }
    EsitoDellaSonda? esito;
    try {
      esito = porta == null ? null : await porta.esiste(email);
    } catch (errore) {
      esito = null;
    }
    if (!mounted) return;
    setState(() {
      _controlloInCorso = false;
      _esito = esito;
      _serverMuto = esito == null;
    });
  }

  Future<void> _parolaPersa() async {
    await widget.account.mandaLaViaPerLaParola(_email.text.trim());
    if (!mounted) return;
    setState(() => _dettoDellaParola =
        'Ti abbiamo mandato una email per reimpostare la Password.');
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final esito = _esito;

    // 1. Prima dell'esito (o dopo Cambia email): il campo e Controlla.
    if (esito == null && !_serverMuto) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            key: const Key('sonda_email_campo'),
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            autofillHints: const [AutofillHints.username, AutofillHints.email],
            style: TypographyTokens.corpo()
                .copyWith(color: ColorTokens.textPrimary),
            decoration: InputDecoration(
              labelText: 'La tua email',
              errorText: _guaio,
              errorMaxLines: 2,
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
          FilledButton(
            key: const Key('sonda_controlla'),
            style: FilledButton.styleFrom(
              backgroundColor: palette.gold,
              foregroundColor: palette.deepest,
            ),
            onPressed: _controlloInCorso ? null : _controlla,
            child: Text(_controlloInCorso ? 'Controllo...' : 'Controlla',
                style: TypographyTokens.etichetta()
                    .copyWith(color: palette.deepest)),
          ),
        ],
      );
    }

    // 2. Il server non ha risposto: lo si dice e si aprono le vie.
    if (_serverMuto) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Non riesco a controllare la tua email in questo momento: '
            'entra direttamente con la tua via.',
            key: const Key('sonda_server_muto'),
            style: TypographyTokens.corpo()
                .copyWith(color: ColorTokens.textSecondary, height: 1.4),
          ),
          const SizedBox(height: SpacingTokens.sm),
          VieDellaCustodia(inCorso: widget.inCorso, suScelta: widget.suScelta),
        ],
      );
    }

    // 3. L'email non risulta: lo si legge in chiaro e si prosegue il rito.
    if (!esito!.esiste) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Questa email non risulta registrata nel Cerchio. Prosegui il '
            'rito: potrai registrarti alla fine, oppure più tardi dal menu '
            'utente.',
            key: const Key('sonda_non_registrata'),
            style: TypographyTokens.corpo()
                .copyWith(color: ColorTokens.textPrimary, height: 1.4),
          ),
          const SizedBox(height: SpacingTokens.sm),
          FilledButton(
            key: const Key('sonda_prosegui'),
            style: FilledButton.styleFrom(
              backgroundColor: palette.gold,
              foregroundColor: palette.deepest,
            ),
            onPressed: widget.suProsegui,
            child: Text('Prosegui il rito',
                style: TypographyTokens.etichetta()
                    .copyWith(color: palette.deepest)),
          ),
          _cambiaEmail(),
        ],
      );
    }

    // 4. L'email risulta: si entra con la via che ha davvero.
    final conParola = esito.vie.contains('password');
    final conGoogle = esito.vie.contains('google.com');
    final conApple = esito.vie.contains('apple.com');
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Questa email ha già un Cerchio: entra con la tua via.',
          key: const Key('sonda_registrata'),
          style: TypographyTokens.corpo()
              .copyWith(color: ColorTokens.textPrimary, height: 1.4),
        ),
        const SizedBox(height: SpacingTokens.sm),
        if (conGoogle)
          _PulsanteDellaVia(
            chiave: const Key('sonda_google'),
            etichetta: 'Entra con Google',
            icona: Icons.g_mobiledata_rounded,
            inCorso: widget.inCorso == ViaDellaCustodia.google,
            fermo: widget.inCorso != null,
            suTocco: () => widget.suScelta(ViaDellaCustodia.google),
          ),
        if (conApple) ...[
          const SizedBox(height: SpacingTokens.sm),
          _PulsanteDellaVia(
            chiave: const Key('sonda_apple'),
            etichetta: 'Entra con Apple',
            icona: Icons.apple_rounded,
            inCorso: widget.inCorso == ViaDellaCustodia.apple,
            fermo: widget.inCorso != null,
            suTocco: () => widget.suScelta(ViaDellaCustodia.apple),
          ),
        ],
        if (conParola) ...[
          TextField(
            key: const Key('sonda_parola_campo'),
            controller: _parola,
            obscureText: _passwordCoperta,
            autofillHints: const [AutofillHints.password],
            style: TypographyTokens.corpo()
                .copyWith(color: ColorTokens.textPrimary),
            decoration: InputDecoration(
              labelText: 'Password',
              suffixIcon: IconButton(
                key: const Key('sonda_occhiolino'),
                icon: Icon(
                  _passwordCoperta
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: ColorTokens.textSecondary,
                ),
                onPressed: () =>
                    setState(() => _passwordCoperta = !_passwordCoperta),
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
          FilledButton(
            key: const Key('sonda_entra'),
            style: FilledButton.styleFrom(
              backgroundColor: palette.gold,
              foregroundColor: palette.deepest,
            ),
            onPressed: widget.inCorso != null
                ? null
                : () => widget.suScelta(ViaDellaCustodia.email,
                    email: _email.text.trim(), parola: _parola.text),
            child: Text('Entra',
                style: TypographyTokens.etichetta()
                    .copyWith(color: palette.deepest)),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              key: const Key('sonda_parola_persa'),
              onPressed: _parolaPersa,
              child: Text('Hai perso la Password?',
                  style: TypographyTokens.didascalia()
                      .copyWith(color: palette.goldSoft)),
            ),
          ),
          if (_dettoDellaParola != null)
            Text(_dettoDellaParola!,
                key: const Key('sonda_parola_persa_detto'),
                style: TypographyTokens.didascalia()
                    .copyWith(color: palette.goldSoft)),
        ],
        _cambiaEmail(),
      ],
    );
  }

  Widget _cambiaEmail() => Align(
        alignment: Alignment.center,
        child: TextButton(
          key: const Key('sonda_cambia_email'),
          onPressed: () => setState(() {
            _esito = null;
            _serverMuto = false;
            _guaio = null;
            _dettoDellaParola = null;
            _parola.clear();
          }),
          child: Text('Cambia email',
              style: TypographyTokens.didascalia()
                  .copyWith(color: ColorTokens.textSecondary)),
        ),
      );
}
