import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/cammino/custode_del_cammino.dart';
import '../../core/identity/account_del_cerchio.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

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
            style: TypographyTokens.etichetta()
                .copyWith(color: palette.goldSoft),
          ),
        ),
      ],
    );
  }

  /// L'email e la parola d'accesso, raccolte in una finestra sola.
  ///
  /// Non si chiede il telefono: sta scritto nei briefing e vale anche qui.
  static Future<(String, String)?> _chiediEmail(BuildContext context) {
    final email = TextEditingController();
    final parola = TextEditingController();
    final palette = context.palette;
    return showDialog<(String, String)>(
      context: context,
      builder: (dialogo) => AlertDialog(
        key: const Key('custodia_email_form'),
        backgroundColor: palette.surfaceElevated,
        title: Text('Custodisci con un\'email',
            style: TypographyTokens.titoloScheda()
                .copyWith(color: palette.goldSoft)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('custodia_email_campo'),
              controller: email,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              style: TypographyTokens.corpo()
                  .copyWith(color: ColorTokens.textPrimary),
              decoration: const InputDecoration(labelText: 'La tua email'),
            ),
            const SizedBox(height: SpacingTokens.sm),
            TextField(
              key: const Key('custodia_parola_campo'),
              controller: parola,
              obscureText: true,
              style: TypographyTokens.corpo()
                  .copyWith(color: ColorTokens.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Una parola d\'accesso',
                helperText: 'Almeno sei caratteri',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogo).pop(),
            child: const Text('Annulla'),
          ),
          TextButton(
            key: const Key('custodia_email_conferma'),
            onPressed: () {
              final a = email.text.trim();
              final b = parola.text;
              if (!a.contains('@') || b.length < 6) return;
              Navigator.of(dialogo).pop((a, b));
            },
            child: const Text('Custodisci'),
          ),
        ],
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
  if (momenti <= 0) return false;
  final palette = context.palette;
  final account = context.read<AccountDelCerchio>();
  final esito = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (foglio) => _FoglioDellInvito(
      momenti: momenti,
      palette: palette,
      account: account,
    ),
  );
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
  final esito = await showModalBottomSheet<bool>(
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
    final esito = widget.perChiTorna
        ? await widget.account
            .entraDirettamente(via, email: email, parola: parola)
        : await widget.account.custodisci(via, email: email, parola: parola);
    if (!mounted) return;
    if (esito == EsitoDellaCustodia.riuscita) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _inCorso = null;
      _guaio = frasePerEsito(esito);
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
                          : 'Il Cerchio custodisce $quanti',
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
                  : 'Vuoi che restino tuoi anche se cambi telefono? Basta un '
                      'tocco: nulla di quello che hai fatto si perde.',
              style: TypographyTokens.corpo()
                  .copyWith(color: ColorTokens.textSecondary, height: 1.4),
            ),
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
            VieDellaCustodia(inCorso: _inCorso, suScelta: (via, {email, parola}) {
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
    );
  }
}
