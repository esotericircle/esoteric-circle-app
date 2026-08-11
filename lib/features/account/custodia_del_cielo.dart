import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    case EsitoDellaCustodia.giaDiUnAltroCerchio:
      return 'Quell\'identità appartiene già a un altro Cerchio. Il tuo '
          'resta intero qui: prova con un\'altra via, oppure scrivici e '
          'uniremo i due.';
    case EsitoDellaCustodia.cerchioCambiato:
      return 'Qualcosa non ha funzionato e il tuo cielo non è stato '
          'collegato. Niente è andato perso: riprova più tardi.';
    case EsitoDellaCustodia.nonRiuscita:
      return 'Non è riuscito adesso. Il tuo cielo resta dove sta: puoi '
          'riprovare quando vuoi dall\'area account.';
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

class _FoglioDellInvito extends StatefulWidget {
  const _FoglioDellInvito({
    required this.momenti,
    required this.palette,
    required this.account,
  });

  final int momenti;
  final MaestroPalette palette;
  final AccountDelCerchio account;

  @override
  State<_FoglioDellInvito> createState() => _FoglioDellInvitoState();
}

class _FoglioDellInvitoState extends State<_FoglioDellInvito> {
  ViaDellaCustodia? _inCorso;
  String? _guaio;

  Future<void> _custodisci(ViaDellaCustodia via,
      {String? email, String? parola}) async {
    setState(() {
      _inCorso = via;
      _guaio = null;
    });
    final esito = await widget.account
        .custodisci(via, email: email, parola: parola);
    if (!mounted) return;
    if (esito == EsitoDellaCustodia.riuscita) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _inCorso = null;
      _guaio = frasePerEsito(esito);
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
                  child: Text('Il Cerchio custodisce $quanti',
                      key: const Key('invito_numero_dei_momenti'),
                      style: TypographyTokens.titoloScheda()
                          .copyWith(color: palette.goldSoft)),
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.sm),
            Text(
              'Vuoi che restino tuoi anche se cambi telefono? Basta un tocco: '
              'nulla di quello che hai fatto si perde.',
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
