import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/entitlement/question_allowance.dart';
import '../../core/identity/account_del_cerchio.dart';
import '../../services/app_services.dart';
import '../../services/server/porta_del_cerchio.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/components/icona_degli_eos.dart';
import '../../design_system/components/volo_degli_eos.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/transizioni/velo_del_cerchio.dart';

/// LA FESTA DELLA REGISTRAZIONE. Ordine BH voce 02.
///
/// Parole del fondatore: "subito dopo, ovviamente, vorrei una festa dedicata
/// alla registrazione e al premio". Non e' una celebrazione di Sentiero (non
/// c'e' un Traguardo dietro): e' la sua scena, piu' sobria, che dice la
/// registrazione compiuta e il premio arrivato, col numero VERO che il
/// server ha accreditato.
///
/// [dopoLaCustodia] e' l'unico ingresso: sincronizza la borsa e decide da
/// sola cosa e' vero. Tre casi, tre verita':
/// 1. il benvenuto e' arrivato: la festa, col numero;
/// 2. l'email aspetta la verifica: nessuna festa, la riga che dice che il
///    premio arriva a verifica compiuta (la strada di BH.04);
/// 3. la lapide ha fermato il premio (l'email lo aveva gia' ricevuto):
///    nessuna festa e la riga onesta, perche' festeggiare un premio non
///    arrivato sarebbe la bugia peggiore di tutte.
class FestaDellaRegistrazione extends StatelessWidget {
  const FestaDellaRegistrazione({super.key, this.premio});

  /// Quanti Eos sono arrivati col benvenuto. Nullo se il server non ha
  /// dichiarato il numero: la festa allora parla del dono senza cifra.
  final int? premio;

  /// Da chiamare dopo una custodia riuscita (la registrazione vera).
  static Future<void> dopoLaCustodia(BuildContext context) async {
    QuestionAllowance? borsa;
    try {
      borsa = context.read<QuestionAllowance>();
    } catch (senzaProvider) {
      return;
    }
    await borsa.sincronizza();
    if (!context.mounted) return;
    if (borsa.benvenutoAppenaArrivato) {
      await Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black54,
        transitionDuration:
            MediaQuery.maybeOf(context)?.disableAnimations == true
                ? Duration.zero
                : const Duration(milliseconds: 350),
        // La rotta si avvolge da sola nello scope, come ogni rotta spinta
        // di casa: la festa usa la palette e non deve dipendere da dove
        // sta il Navigator.
        pageBuilder: (_, __, ___) => MaestroScope(
            child: FestaDellaRegistrazione(
                premio: borsa!.premioDellaRegistrazione)),
        transitionsBuilder: (_, anima, __, figlio) =>
            FadeTransition(opacity: anima, child: figlio),
      ));
      return;
    }
    // Niente festa: si dice perche', mai un silenzio che lascia aspettare
    // un premio promesso.
    AccountDelCerchio? account;
    try {
      account = context.read<AccountDelCerchio>();
    } catch (senzaProvider) {
      account = null;
    }
    final aspettaLaVerifica = account != null &&
        account.fornitori.contains('password') &&
        account.emailVerificata == false;
    if (aspettaLaVerifica) {
      // **IL CODICE NUMERICO PRIMA DEL COLLEGAMENTO, ordine BI voce 04.**
      // Se il mittente e' configurato arriva il codice di sei cifre e il
      // foglio qui sotto lo chiede; se non lo e', vale il collegamento di
      // Firebase gia' partito con la registrazione (BH.04), e lo si dice.
      final compiuta = await _verificaColCodice(context);
      if (!context.mounted) return;
      if (compiuta) {
        // L'email adesso e' verificata: si rifa' il giro, che stavolta
        // trova il benvenuto e apre la festa.
        await dopoLaCustodia(context);
        return;
      }
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(const SnackBar(
        key: Key('registrazione_senza_festa'),
        content:
            Text('Registrazione quasi compiuta: apri l\'email che ti abbiamo '
                'mandato e verifica l\'indirizzo. Il dono di benvenuto '
                'arriva con la verifica.'),
        duration: Duration(seconds: 8),
      ));
      return;
    }
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(const SnackBar(
      key: Key('registrazione_senza_festa'),
      content: Text('La registrazione è compiuta. Il benvenuto non si '
          'ripete: questa email lo aveva già ricevuto.'),
      duration: Duration(seconds: 8),
    ));
  }

  /// Prova la strada del codice numerico. Torna vero solo a email
  /// verificata (col gettone gia' rinfrescato dalla ricarica).
  static Future<bool> _verificaColCodice(BuildContext context) async {
    PortaDelCerchio? porta;
    try {
      porta = context.read<AppServices>().porta;
    } catch (senzaProvider) {
      return false;
    }
    EsitoDelSecondoFattore? mandato;
    try {
      mandato = await porta.secondoFattore(operazione: 'manda');
    } catch (errore) {
      mandato = null;
    }
    if (!context.mounted || mandato == null || !mandato.mandato) return false;
    final verificato = await dialogoDelCerchio<bool>(
          context: context,
          // Il fondo si dichiara dove la porta si apre (legge AL.04).
          builder: (dialogo) => _FoglioDelCodice(
              porta: porta!, backgroundColor: ColorTokens.neutralSurface),
        ) ??
        false;
    if (!verificato || !context.mounted) return false;
    try {
      await context.read<AccountDelCerchio>().ricarica();
    } catch (senzaProvider) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      key: const Key('festa_della_registrazione'),
      backgroundColor: Colors.transparent,
      body: CosmosBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(SpacingTokens.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: palette.primary.withValues(alpha: 0.35),
                    border: Border.all(
                        color: palette.gold.withValues(alpha: 0.7), width: 1.4),
                  ),
                  child: Icon(Icons.shield_moon_outlined,
                      color: palette.goldSoft, size: 42),
                ),
                const SizedBox(height: SpacingTokens.lg),
                Text('Sei nel Cerchio',
                    key: const Key('festa_registrazione_titolo'),
                    textAlign: TextAlign.center,
                    style: TypographyTokens.cerimoniale()
                        .copyWith(color: palette.goldSoft)),
                const SizedBox(height: SpacingTokens.md),
                Text(
                  'La tua registrazione è compiuta: il tuo cielo, i tuoi '
                  'Sigilli e i tuoi Eos ti seguono su qualsiasi telefono.',
                  textAlign: TextAlign.center,
                  style: TypographyTokens.corpo()
                      .copyWith(color: ColorTokens.textPrimary, height: 1.5),
                ),
                const SizedBox(height: SpacingTokens.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconaDegliEos(misura: 26, colore: palette.goldSoft),
                    const SizedBox(width: SpacingTokens.sm),
                    Text(
                      premio == null
                          ? 'Il dono di benvenuto è tuo'
                          : '+$premio Eos',
                      key: const Key('festa_registrazione_premio'),
                      // Il titolo cerimoniale grande, non una misura scritta a mano:
                      // e' il numero della festa, merita il ruolo pieno.
                      style: TypographyTokens.cerimonialeGrande()
                          .copyWith(color: palette.goldSoft),
                    ),
                  ],
                ),
                const Spacer(flex: 3),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    key: const Key('festa_registrazione_continua'),
                    style: FilledButton.styleFrom(
                      backgroundColor: palette.gold,
                      foregroundColor: palette.deepest,
                      padding: const EdgeInsets.symmetric(
                          vertical: SpacingTokens.md),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(SpacingTokens.radiusPill),
                      ),
                    ),
                    onPressed: () {
                      final quanti = premio ?? 0;
                      Navigator.of(context).pop();
                      if (quanti > 0) {
                        VoloDegliEos.lancia(context, quanti: quanti);
                      }
                    },
                    child: Text('Continua',
                        style: TypographyTokens.etichetta()
                            .copyWith(color: palette.deepest)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// IL FOGLIO DEL CODICE DI SEI CIFRE. Ordine BI voce 04.
class _FoglioDelCodice extends StatefulWidget {
  const _FoglioDelCodice({required this.porta, required this.backgroundColor});

  final PortaDelCerchio porta;

  /// Il fondo, dichiarato da chi apre la porta (legge AL.04).
  final Color backgroundColor;

  @override
  State<_FoglioDelCodice> createState() => _FoglioDelCodiceState();
}

class _FoglioDelCodiceState extends State<_FoglioDelCodice> {
  final _codice = TextEditingController();
  bool _inCorso = false;
  String? _guaio;

  Future<void> _verifica() async {
    final codice = _codice.text.trim();
    if (codice.length != 6 || int.tryParse(codice) == null) {
      setState(() => _guaio = 'Il codice è di sei cifre');
      return;
    }
    setState(() {
      _inCorso = true;
      _guaio = null;
    });
    EsitoDelSecondoFattore? esito;
    try {
      esito = await widget.porta
          .secondoFattore(operazione: 'verifica', codice: codice);
    } catch (errore) {
      esito = null;
    }
    if (!mounted) return;
    if (esito != null && esito.verificato) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _inCorso = false;
      _guaio = switch (esito?.motivo) {
        'scaduto' => 'Il codice è scaduto: chiedine uno nuovo',
        'esaurito' => 'Troppi tentativi: chiedi un codice nuovo',
        'sbagliato' => 'Il codice non è giusto: controlla e riprova',
        _ => 'Non sono riuscito a verificare adesso: riprova',
      };
    });
  }

  Future<void> _mandaAncora() async {
    setState(() => _guaio = null);
    try {
      await widget.porta.secondoFattore(operazione: 'manda');
    } catch (errore) {
      // Il guaio si vedra' alla verifica: qui non si blocca niente.
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AlertDialog(
      key: const Key('foglio_del_codice'),
      backgroundColor: widget.backgroundColor,
      title: Text('Il codice della tua email',
          style: TypographyTokens.titoloScheda()
              .copyWith(color: palette.goldSoft)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Ti abbiamo mandato una email con un codice di sei cifre: '
            'scrivilo qui e la registrazione è compiuta.',
            style: TypographyTokens.corpo()
                .copyWith(color: ColorTokens.textSecondary, height: 1.4),
          ),
          const SizedBox(height: SpacingTokens.sm),
          TextField(
            key: const Key('campo_del_codice'),
            controller: _codice,
            keyboardType: TextInputType.number,
            maxLength: 6,
            autofillHints: const [AutofillHints.oneTimeCode],
            style: TypographyTokens.corpo()
                .copyWith(color: ColorTokens.textPrimary),
            decoration: InputDecoration(
              labelText: 'Codice',
              counterText: '',
              errorText: _guaio,
              errorMaxLines: 2,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              key: const Key('codice_manda_ancora'),
              onPressed: _inCorso ? null : _mandaAncora,
              child: Text('Mandamelo di nuovo',
                  style: TypographyTokens.didascalia()
                      .copyWith(color: palette.goldSoft)),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          style:
              TextButton.styleFrom(foregroundColor: ColorTokens.textSecondary),
          onPressed: _inCorso ? null : () => Navigator.of(context).pop(false),
          child: const Text('Più tardi'),
        ),
        TextButton(
          key: const Key('codice_verifica'),
          style: TextButton.styleFrom(foregroundColor: palette.goldSoft),
          onPressed: _inCorso ? null : _verifica,
          child: Text(_inCorso ? 'Verifico...' : 'Verifica'),
        ),
      ],
    );
  }
}
