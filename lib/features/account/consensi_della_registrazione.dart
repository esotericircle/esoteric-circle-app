import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../core/arts/art_catalog.dart';
import '../../core/legal/pagina_legale.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
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
/// **1. Un solo atto attivo, ed e' il pulsante stesso.** Sopra le vie
/// d'accesso c'e' una riga sola che dice cosa si accetta.
///
/// **QUI SI PROMETTEVANO DUE NOMI TOCCABILI, e non era vero. Ordine CF
/// voce 15.** Il fondatore ha chiesto conto della riga del consenso e la
/// verifica ha trovato dell'altro: **il Cerchio non aveva termini di
/// servizio.** Misurato allora: zero occorrenze della parola in tutto `lib/`,
/// nessun indirizzo, nessuna schermata. La riga nomino' la sola privacy
/// policy, che esisteva, e quel commento lo dichiaro' invece di promettere un
/// secondo nome che non c'era. **La nota diceva che il giorno in cui i
/// termini fossero esistiti la riga li avrebbe nominati: quel giorno e' il
/// 20 settembre 2026, ordine EA voce 18.** Le condizioni d'uso le ha scritte
/// il fondatore, stanno in `lib/core/legal/condizioni_uso.dart` con la
/// privacy policy e il disclaimer, e **i nomi toccabili adesso sono tre**,
/// uno per parte.
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

/// **LA CASELLA GOVERNA I PULSANTI SOTTO. Ordine FN, 13 ottobre 2026.** Il
/// fondatore ha chiesto di tornare a una casella esplicita, non spuntata di
/// default: finche' non e' spuntata, chi monta [ConsensiDellaRegistrazione]
/// deve tenere il proprio pulsante semitrasparente e non toccabile. Risale
/// l'albero con una `Notification`, non un parametro del costruttore, cosi'
/// il punto di montaggio resta `ConsensiDellaRegistrazione()` com'era: due
/// guardie di ordini precedenti ne contano le occorrenze esatte nel sorgente.
class ConsensoCambiatoNotification extends Notification {
  const ConsensoCambiatoNotification(this.accettato);

  final bool accettato;
}

class _ConsensiDellaRegistrazioneState
    extends State<ConsensiDellaRegistrazione> {
  bool _accettato = false;

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
    return Row(
      key: const Key('consensi_della_registrazione'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // **IL QUADRATINO, non spuntato di default.** Ordine FN, 13 ottobre
        // 2026: prima "premere il pulsante era l'accettazione", e il
        // fondatore ha chiesto una casella esplicita che tenga spento il
        // pulsante finche' non e' spuntata.
        Checkbox(
          key: const Key('consenso_casella'),
          value: _accettato,
          activeColor: palette.gold,
          onChanged: (v) {
            setState(() => _accettato = v ?? false);
            ConsensoCambiatoNotification(_accettato).dispatch(context);
          },
        ),
        // **UNA FRASE SOLA, PIU' LEGGIBILE. Ordine FN, 13 ottobre 2026.** Il
        // fondatore: le stesse informazioni tornavano piu' volte, scritte
        // piccole (`didascalia`). Privacy, condizioni e disclaimer stavano
        // in due paragrafi separati; sono diventati uno, alla misura di
        // `corpo`, che e' quella in cui si legge il resto del foglio.
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text.rich(
              TextSpan(
                style: TypographyTokens.corpo()
                    .copyWith(color: ColorTokens.textSecondary, height: 1.4),
                children: [
                  const TextSpan(text: 'Continuando accetti la '),
                  TextSpan(
                    text: 'privacy policy',
                    style: TextStyle(
                        color: palette.goldSoft,
                        decoration: TextDecoration.underline),
                    recognizer: _apri,
                  ),
                  const TextSpan(text: ', le '),
                  TextSpan(
                    text: 'condizioni d\'uso',
                    style: TextStyle(
                        color: palette.goldSoft,
                        decoration: TextDecoration.underline),
                    recognizer: _apriLeCondizioni,
                  ),
                  const TextSpan(text: ' e il disclaimer del Cerchio. '),
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
              key: const Key('consenso_informativa'),
            ),
          ),
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
