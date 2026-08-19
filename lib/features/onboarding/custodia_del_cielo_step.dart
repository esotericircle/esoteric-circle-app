import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/cammino/custode_del_cammino.dart';
import '../../core/identity/account_del_cerchio.dart';
import '../../core/maestro/maestro.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../account/custodia_del_cielo.dart';

/// L'ULTIMO PASSO DEL RISVEGLIO: non perdere il tuo cielo.
///
/// **Perche' qui e non all'ingresso.** All'ingresso non c'e' niente da
/// perdere: chiedere un account prima di aver dato qualcosa e' un pedaggio, e
/// si paga in persone che non entrano. Qui invece la carta natale e' stata
/// calcolata, il Maestro si e' rivelato, il primo momento personale c'e'
/// stato: la ragione che si dice e' vera e riguarda proprio cio' che si e'
/// appena fatto.
///
/// **Si puo' sempre rimandare, e rimandare non toglie niente.** Chi dice
/// "piu' tardi" entra nel Cerchio con tutto quello che ha appena ricevuto;
/// l'invito tornera' piu' avanti, col numero vero dei momenti custoditi.
class CustodiaDelCieloStep extends StatefulWidget {
  const CustodiaDelCieloStep({
    super.key,
    required this.maestro,
    required this.suFine,
  });

  /// Il Maestro appena rivelato: la frase lo nomina, perche' e' successo
  /// adesso e non un giorno qualunque.
  final Maestro maestro;

  /// Chiude il Risveglio, custodito o rimandato che sia.
  final VoidCallback suFine;

  @override
  State<CustodiaDelCieloStep> createState() => _CustodiaDelCieloStepState();
}

class _CustodiaDelCieloStepState extends State<CustodiaDelCieloStep> {
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
    final esito = await context
        .read<AccountDelCerchio>()
        .custodisci(via, email: email, parola: parola);
    if (!mounted) return;
    if (esito == EsitoDellaCustodia.riuscita) {
      widget.suFine();
      return;
    }
    setState(() {
      _inCorso = null;
      _guaio = frasePerEsito(esito);
      // LA VIA IN AVANTI, ordine AL voce 07: il Risveglio riconosce e
      // propone, con lo STESSO componente del foglio dell'account.
      _riconosciuto = esito == EsitoDellaCustodia.giaDiUnAltroCerchio;
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return CosmosBackground(
      seed: 31,
      // IL MATERIAL SOPRA IL CONTENUTO, e non e' un dettaglio: senza, ogni
      // riga di testo esce sottolineata di giallo, che e' il modo di Flutter
      // di dire "qui sopra non c'è nessun Material". L'anteprima lo ha
      // mostrato al primo scatto, e nessuna prova lo cercava.
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),
                Icon(Icons.shield_moon_outlined,
                    size: 46, color: palette.goldSoft),
                const SizedBox(height: SpacingTokens.md),
                Text(
                  'Non perdere il tuo cielo',
                  key: const Key('custodia_titolo'),
                  textAlign: TextAlign.center,
                  style: TypographyTokens.cerimoniale()
                      .copyWith(color: palette.goldSoft),
                ),
                const SizedBox(height: SpacingTokens.md),
                // **UNA RIGA SOLA, ordine AQ voce 05.** Qui stavano DUE
                // blocchi di seguito, e con l'eventuale guaio e il "Continua
                // come" la colonna arrivava a nove elementi: Mauro l'ha vista
                // confusionaria, e aveva ragione. Il testo che avanzava si e'
                // TOLTO, non rimpicciolito: il corpo resta quello di casa,
                // sedici punti. Chi e' gia' riconosciuto non la legge
                // affatto, perche' per lui la strada e' un'altra, e le parole
                // che non servono spariscono invece di restare grigie.
                if (!_riconosciuto)
                  Text(
                    'La tua carta natale e il tuo cammino vivono su questo '
                    'telefono: collegali a te, e ti seguiranno ovunque.',
                    key: const Key('custodia_ragione'),
                    textAlign: TextAlign.center,
                    style: TypographyTokens.corpo().copyWith(
                      color: ColorTokens.textPrimary,
                      height: 1.5,
                    ),
                  ),
                if (_guaio != null) ...[
                  const SizedBox(height: SpacingTokens.md),
                  Text(_guaio!,
                      key: const Key('custodia_guaio'),
                      textAlign: TextAlign.center,
                      style: TypographyTokens.didascalia()
                          .copyWith(color: palette.goldSoft, height: 1.4)),
                ],
                if (_riconosciuto) ...[
                  const SizedBox(height: SpacingTokens.md),
                  ContinuaComeRiconosciuto(
                    account: context.read<AccountDelCerchio>(),
                    suEsito: (esito) async {
                      if (!mounted) return;
                      if (esito == EsitoDellaCustodia.riuscita) {
                        // **QUI IL PULSANTE NON SI LIMITA PIU' A FAR
                        // ENTRARE, ordine AP voce 06**: chiama il giro del
                        // Custode, che riporta il cammino, salta il rito se
                        // non resta niente da chiedere e mostra cio' che e'
                        // stato ritrovato. E' lo stesso giro della porta
                        // piccola della voce 04: due strade, un posto solo.
                        await CustodeDelCammino.dopoIlRiconoscimento(context);
                        if (!mounted) return;
                        widget.suFine();
                        return;
                      }
                      setState(() => _guaio = frasePerEsito(esito));
                    },
                  ),
                ],
                const SizedBox(height: SpacingTokens.xl),
                VieDellaCustodia(
                  inCorso: _inCorso,
                  suScelta: (via, {email, parola}) =>
                      _custodisci(via, email: email, parola: parola),
                ),
                // IL VUOTO IN FONDO E' MISURATO, non uno Spacer pari: con
                // due Spacer uguali il Piu' tardi finiva a mezzo schermo dai
                // pulsanti, e sembrava di un'altra scena. Visto sull'anteprima.
                const Spacer(),
                const SizedBox(height: SpacingTokens.xxl),
                TextButton(
                  key: const Key('custodia_piu_tardi'),
                  onPressed: _inCorso != null
                      ? null
                      : () {
                          context.read<AccountDelCerchio>().rimanda();
                          widget.suFine();
                        },
                  child: Text(
                    'Più tardi',
                    style: TypographyTokens.etichetta()
                        .copyWith(color: ColorTokens.textSecondary),
                  ),
                ),
                const SizedBox(height: SpacingTokens.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
