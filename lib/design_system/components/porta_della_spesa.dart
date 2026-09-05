import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/entitlement/listino_degli_eos.dart';
import '../../core/entitlement/question_allowance.dart';
import '../../core/entitlement/spesa_degli_eos.dart';
import '../../services/app_services.dart';
import '../theme/maestro_palette.dart';
import '../theme/maestro_scope.dart';
import '../tokens/color_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';
import 'borsellino.dart';

/// LA PORTA DELLA SPESA: dove si spendono Eos, il gesto non parte da solo.
/// Ordine CE voce 05.
///
/// **La decisione del fondatore, verbatim, sul caso che ha aperto la voce:**
/// "se un utente, invitato dall'app, sceglie in 2 vip, in automatico parte
/// animazione e responso, ma magari lui voleva solo vederli accoppiati o cmq
/// non e' informato che quando sceglieva il vip partira' subito il responso e,
/// di conseguenza, verra' addebitato un utilizzo". La strada che aveva scelto:
/// "annota con la seconda strada, il pulsante esplicito".
///
/// **E la precisazione del 30 agosto, che restringe la voce:** "serve pulsante
/// consenso esplicito solo se l'utente spende EOS." Messo davanti al fatto che
/// la Sinastria VIP consuma il limite del giorno e non gli Eos, ha confermato.
/// **Sui limiti del giorno basta il conteggio residuo della voce CE.04.**
///
/// **UN FATTO MISURATO, e cambia la portata di questa voce.** Oggi **nessun
/// punto dell'app spende Eos**: `SpesaDegliEos.perLaVoce` non ha nessun
/// chiamante sotto `lib/features`, e nemmeno `muoviGliEos`. Questa porta non
/// ripara quindi un difetto in vigore: e' la casa che il primo punto che
/// spendera' Eos dovra' attraversare, e una prova enumera i chiamanti perche'
/// nessuno possa nascere fuori di qui.
///
/// **Le due cose che questa porta risolve per costruzione.**
///
/// **1. Il doppio tocco non spende due volte.** Il pulsante si spegne
/// all'istante del primo tocco e resta spento finche' la chiamata non torna:
/// non e' una cortesia, e' l'unica difesa locale contro il dito che batte due
/// volte su una rete lenta. La seconda difesa e' sul server, ed e'
/// l'identificativo del movimento, che rende l'accredito idempotente.
///
/// **2. Il consumo si paga sull'ESITO e non sul gesto.** Se la spesa non
/// riesce non si addebita niente e non si procede: `SpesaDegliEos` distingue
/// gia' il saldo insufficiente dal guasto, e questa porta non prosegue in
/// nessuno dei due casi. E' la stessa legge di `CostoDelTurno` sulla chat, che
/// paga solo quando la risposta e' arrivata davvero.
class PortaDellaSpesa extends StatefulWidget {
  const PortaDellaSpesa({
    super.key,
    required this.voce,
    required this.etichetta,
    required this.suSpesaFatta,
  });

  /// Cosa si compra, dal listino: il costo non si scrive mai qui.
  final VoceDelListino voce;

  /// Cosa dice il pulsante, senza il prezzo: il prezzo lo mette la porta.
  final String etichetta;

  /// Cosa succede quando la spesa e' andata a buon fine. **Non viene chiamata
  /// se la spesa non riesce**, ed e' il punto della voce.
  final VoidCallback suSpesaFatta;

  @override
  State<PortaDellaSpesa> createState() => _PortaDellaSpesaState();
}

class _PortaDellaSpesaState extends State<PortaDellaSpesa> {
  /// **VERO DAL PRIMO TOCCO E FINCHE' LA CHIAMATA NON TORNA.** E' la difesa
  /// contro il doppio tocco, e sta qui e non nel chiamante perche' un chiamante
  /// che se la dimentica spende due volte.
  bool _inCorso = false;

  Future<void> _tocca() async {
    if (_inCorso) return;
    setState(() => _inCorso = true);
    final borsa = context.read<QuestionAllowance>();
    final porta = context.read<AppServices>().porta;
    final esito = await SpesaDegliEos.perLaVoce(
      porta: porta,
      borsa: borsa,
      voce: widget.voce,
      idMovimento: SpesaDegliEos.nuovoMovimento(widget.voce.id),
    );
    if (!mounted) return;
    setState(() => _inCorso = false);
    switch (esito) {
      case EsitoDellaSpesa.fatta:
        widget.suSpesaFatta();
      case EsitoDellaSpesa.saldoInsufficiente:
        // **NON UN VICOLO CIECO, ordine CE voce 06.** Chi non ha abbastanza
        // Eos viene portato al borsellino, dove trova l'avvertenza e le due
        // vie: i pacchetti e l'abbonamento.
        await PortafoglioDelCerchio.apri(context);
      case EsitoDellaSpesa.nonRiuscita:
        // **NON SI ADDEBITA E NON SI PROCEDE.** Il rifiuto del server e la rete
        // assente si somigliano da qui: in tutti e due i casi non si e' speso
        // niente, e dirlo e' meglio che far finta che sia successo qualcosa.
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Non si è potuto spendere adesso. '
              'Non ti è stato tolto niente.'),
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = MaestroScope.forse(context) ?? MaestroPalette.neutral;
    return Column(
      key: const Key('porta_della_spesa'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // **COSA FA E QUANTO COSTA, PRIMA DEL TOCCO.** E' tutta la voce: il
        // fondatore non voleva che un gesto partisse senza che la persona
        // sapesse cosa avrebbe speso.
        Text(
          '${widget.voce.nome}, ${ListinoDegliEos.prezzo(widget.voce.costo)}',
          key: const Key('porta_della_spesa_costo'),
          style: TypographyTokens.corpo()
              .copyWith(color: ColorTokens.textSecondary),
        ),
        const SizedBox(height: SpacingTokens.xs),
        FilledButton(
          key: const Key('porta_della_spesa_conferma'),
          onPressed: _inCorso ? null : _tocca,
          style: FilledButton.styleFrom(
            backgroundColor: palette.gold,
            foregroundColor: palette.onPrimary,
            minimumSize: const Size.fromHeight(48),
          ),
          child: Text(
            _inCorso ? 'Un momento...' : widget.etichetta,
            style: TypographyTokens.etichetta(),
          ),
        ),
      ],
    );
  }
}
