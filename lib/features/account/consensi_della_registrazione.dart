import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../core/arts/art_catalog.dart';
import '../../core/legal/pagina_legale.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'privacy_policy_screen.dart';

/// I CONSENSI, DENTRO IL GESTO DELLA REGISTRAZIONE. Ordine CE voce 01.
///
/// **Le parole del fondatore, verbatim:** "sistema COME VOGLIO IO i permessi
/// per memorizzare, gdpr, privacy, ecc.: TUTTO COME SE FOSSE AUTOMATICO, PER
/// L'UTENTE DEVE SEMBRARE UN'OPERAZIONE NORMALE DA ACCETTARE, ESATTAMENTE COME
/// TUTTE LE ALTRE APP ED ELIMINA TUTTI QUEI CAZZO DI POPUP CHE SONO UN GROSSO
/// OSTACOLO." E, sulla forma, due volte: "la piu' veloce e non invasiva che
/// rispetti le norme".
///
/// **LA FORMA L'HO SCELTA IO, e queste sono le quattro decisioni.**
///
/// **1. Un solo atto attivo, ed e' il pulsante stesso.** Sopra le vie d'accesso
/// c'e' una riga sola che dice cosa si accetta, **con UN nome toccabile e non
/// due**.
///
/// **QUI SI PROMETTEVANO DUE NOMI TOCCABILI, e non era vero. Ordine CF
/// voce 15.** Il fondatore ha chiesto conto della riga del consenso e la
/// verifica ha trovato dell'altro: **il Cerchio non ha termini di servizio.**
/// Misurato: zero occorrenze della parola in tutto `lib/`, nessun indirizzo,
/// nessuna schermata. La riga nomina la sola privacy policy, che esiste, e
/// **questo commento adesso lo dichiara invece di promettere un secondo nome
/// che non c'e'**. Il giorno che i termini esisteranno, la riga li nomina e
/// questa nota si cancella: e' una decisione del fondatore, non un lavoro
/// che si possa fare qui.
/// Premere "Continua con Google" e' l'accettazione: e' la forma che ogni app
/// che il fondatore ha nominato usa, ed e' lecita perche' la privacy policy e
/// le condizioni non sono un consenso ai sensi del GDPR, sono
/// un'informativa e un contratto. Una casella da spuntare in piu' sarebbe un
/// ostacolo che la legge non chiede.
///
/// **2. LA MISURA NON SI CHIEDE PIU'. Ordine EA voce 12, 19 settembre 2026.**
/// Qui c'era una riga, *"Conta i gesti, non me"*, con il suo interruttore
/// spento. Il fondatore l'ha tolta: *"la frase e selettore ... deve sparire:
/// la memorizzazione deve essere cmq attiva"*, e *"mi serve la soluzione meno
/// invasiva e meno disturbante per l'utente"*. Cio' che si conta non e' un
/// dato personale, sono contatori per giorno senza nessun identificativo, e
/// la privacy policy lo descrive nella sezione dei dati raccolti.
///
/// **3. Nessun testo lungo qui.** La policy intera sta dietro il suo nome, e
/// il disclaimer e le fonti stanno nel sotto menu' della voce CE.03. Chi vuole
/// leggere legge, chi vuole entrare entra.
///
/// **4. Anche chi non si registra viene contato, ordine EA voce 12**, e non
/// e' un peggioramento per nessuno: i contatori non sanno chi sono le persone
/// che li hanno mossi. Prima chi non passava di qui restava `nonChiesto` e
/// non veniva mai contato, e i numeri dicevano molto meno del vero.
class ConsensiDellaRegistrazione extends StatefulWidget {
  const ConsensiDellaRegistrazione({super.key});

  @override
  State<ConsensiDellaRegistrazione> createState() =>
      _ConsensiDellaRegistrazioneState();
}

class _ConsensiDellaRegistrazioneState
    extends State<ConsensiDellaRegistrazione> {
  @override
  void initState() {
    super.initState();
    _apri.onTap = () {
      if (mounted) Navigator.of(context).push(PrivacyPolicyScreen.route());
    };
    _apriLeCondizioni.onTap = () {
      if (mounted) {
        Navigator.of(context)
            .push(PrivacyPolicyScreen.route(parte: ParteLegale.condizioni));
      }
    };
    _apriIlDisclaimer.onTap = () {
      if (mounted) {
        Navigator.of(context)
            .push(PrivacyPolicyScreen.route(parte: ParteLegale.disclaimer));
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    final palette = MaestroScope.forse(context) ?? MaestroPalette.neutral;
    return Column(
      key: const Key('consensi_della_registrazione'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // **LA RIGA CHE DICE COSA SI ACCETTA, e il pulsante e' l'atto.**
        Text.rich(
          TextSpan(
            style: TypographyTokens.didascalia()
                .copyWith(color: ColorTokens.textSecondary),
            children: [
              const TextSpan(text: 'Continuando accetti la '),
              TextSpan(
                text: 'privacy policy',
                style: TextStyle(
                    color: palette.goldSoft,
                    decoration: TextDecoration.underline),
                recognizer: _apri,
              ),
              const TextSpan(text: ' e le '),
              TextSpan(
                text: 'condizioni d\'uso',
                style: TextStyle(
                    color: palette.goldSoft,
                    decoration: TextDecoration.underline),
                recognizer: _apriLeCondizioni,
              ),
              const TextSpan(text: ' del Cerchio.'),
            ],
          ),
          key: const Key('consenso_informativa'),
        ),
        const SizedBox(height: SpacingTokens.sm),
        // **IL DISCLAIMER, UNA VOLTA SOLA, ALLA REGISTRAZIONE.** Ordine EA
        // voce 18 e regola di CLAUDE.md: si dice all'onboarding e qui, mai su
        // ogni carta. Il testo e' quello di `ArtCatalog.disclaimerCornice`, e
        // il nome porta alla sua sezione nella pagina legale.
        Text.rich(
          TextSpan(
            style: TypographyTokens.didascalia()
                .copyWith(color: ColorTokens.textSecondary),
            children: [
              const TextSpan(text: '${ArtCatalog.disclaimerCornice} '),
              TextSpan(
                text: 'Leggi il disclaimer',
                style: TextStyle(
                    color: palette.goldSoft,
                    decoration: TextDecoration.underline),
                recognizer: _apriIlDisclaimer,
              ),
              const TextSpan(text: '.'),
            ],
          ),
          key: const Key('consenso_disclaimer'),
        ),
      ],
    );
  }

  /// I riconoscitori dei tocchi sulle condizioni e sul disclaimer, sorelle di
  /// quello della policy: ordine EA voce 18.
  final TapGestureRecognizer _apriLeCondizioni = TapGestureRecognizer();
  final TapGestureRecognizer _apriIlDisclaimer = TapGestureRecognizer();

  /// Il riconoscitore del tocco sul nome della policy, tenuto qui perche' viva
  /// e muoia con lo stato di questa riga: un riconoscitore creato dentro
  /// build non viene mai liberato.
  final TapGestureRecognizer _apri = TapGestureRecognizer();

  @override
  void dispose() {
    _apri.dispose();
    _apriLeCondizioni.dispose();
    _apriIlDisclaimer.dispose();
    super.dispose();
  }
}
