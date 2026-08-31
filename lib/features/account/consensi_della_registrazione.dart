import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../core/misura/misura_del_ritorno.dart';
import '../../core/misura/registro_del_ritorno.dart';
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
/// **2. La misura del ritorno e' un interruttore separato, e nasce SPENTO.**
/// Questa e' l'unica cosa qui dentro che il GDPR chiama consenso, e un
/// consenso pre-acceso non e' libero: sarebbe illecito, e il fondatore ha
/// chiesto una soluzione "che rispetti le norme". Sta nella stessa schermata,
/// quindi non e' un secondo passo e non e' un popup: e' una riga sopra i
/// pulsanti, e accenderla costa un tocco.
///
/// **3. Nessun testo lungo qui.** La policy intera sta dietro il suo nome, e
/// il disclaimer e le fonti stanno nel sotto menu' della voce CE.03. Chi vuole
/// leggere legge, chi vuole entrare entra.
///
/// **4. Chi non si registra non viene contato.** L'app si usa per intero senza
/// registrarsi, e da quando i due fogli sono usciti dal Santuario, voce CE.02,
/// questa e' l'unica porta dove il consenso alla misura si puo' dare. Chi non
/// passa di qui resta `nonChiesto`, e il registro non manda niente: e' la
/// scelta piu' veloce, la meno invasiva e l'unica che regge davanti alle norme,
/// perche' contare qualcuno che non ha mai avuto modo di dire di no sarebbe
/// contare senza consenso.
class ConsensiDellaRegistrazione extends StatefulWidget {
  const ConsensiDellaRegistrazione({super.key});

  @override
  State<ConsensiDellaRegistrazione> createState() =>
      _ConsensiDellaRegistrazioneState();
}

class _ConsensiDellaRegistrazioneState
    extends State<ConsensiDellaRegistrazione> {
  /// **Nasce spento, sempre**, e non si legge da disco: questa e' la schermata
  /// dove il consenso si DA', non dove si rilegge. Chi lo ha gia' dato lo
  /// cambia dal sotto menu' Privacy e permessi.
  bool _misura = false;

  @override
  void initState() {
    super.initState();
    _apri.onTap = () {
      if (mounted) Navigator.of(context).push(PrivacyPolicyScreen.route());
    };
  }

  Future<void> _cambia(bool acceso) async {
    setState(() => _misura = acceso);
    await ConsensoDellaMisura.segna(acceso);
    await RegistroDelRitorno.corrente?.rileggiIlConsenso();
  }

  @override
  Widget build(BuildContext context) {
    final palette = MaestroScope.forse(context) ?? MaestroPalette.neutral;
    return Column(
      key: const Key('consensi_della_registrazione'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          key: const Key('consenso_misura'),
          children: [
            Expanded(
              child: Text(
                'Conta i gesti, non me: numeri per giorno, senza nome, per '
                'capire cosa funziona.',
                style: TypographyTokens.didascalia()
                    .copyWith(color: ColorTokens.textSecondary),
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),
            Switch(
              key: const Key('consenso_misura_interruttore'),
              value: _misura,
              onChanged: _cambia,
              thumbColor: WidgetStateProperty.resolveWith(
                (stati) => stati.contains(WidgetState.selected)
                    ? palette.deepest
                    : palette.goldSoft.withValues(alpha: 0.7),
              ),
              trackColor: WidgetStateProperty.resolveWith(
                (stati) => stati.contains(WidgetState.selected)
                    ? palette.gold
                    : palette.surfaceElevated,
              ),
              trackOutlineColor:
                  WidgetStateProperty.all(palette.gold.withValues(alpha: 0.35)),
            ),
          ],
        ),
        const SizedBox(height: SpacingTokens.xs),
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
              const TextSpan(text: ' del Cerchio.'),
            ],
          ),
          key: const Key('consenso_informativa'),
        ),
      ],
    );
  }

  /// Il riconoscitore del tocco sul nome della policy, tenuto qui perche' viva
  /// e muoia con lo stato di questa riga: un riconoscitore creato dentro
  /// build non viene mai liberato.
  final TapGestureRecognizer _apri = TapGestureRecognizer();

  @override
  void dispose() {
    _apri.dispose();
    super.dispose();
  }
}
