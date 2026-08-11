import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/entitlement/entitlement_service.dart';
import '../../core/entitlement/question_allowance.dart';
import '../../core/entitlement/tier.dart';
import '../../core/sigilli/diario_del_cammino.dart';
import '../../core/sigilli/sentieri.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../maestri/rotta_arte.dart';
import '../pricing/upgrade_invite.dart';
import 'celebrazione.dart';

/// IL SENTIERO DEI SIGILLI: Albero, Costellazione o Loto.
///
/// **L'apertura viene dall'alto**, come deciso: prima il traguardo 50 in
/// piena luce, poi lo scorrimento scende a ritroso e si ferma sul punto
/// raggiunto. Non e' un vezzo: chi apre un journal vuoto deve vedere prima
/// dove si arriva, non dove non e' ancora arrivato.
class SentieroScreen extends StatefulWidget {
  const SentieroScreen({super.key, required this.sentiero, this.senzaVolo = false});

  final Sentiero sentiero;

  /// Per le prove e le anteprime: niente scorrimento animato, la scena si
  /// monta gia' ferma sul punto raggiunto.
  final bool senzaVolo;

  static Route<void> route(Sentiero sentiero) => MaterialPageRoute<void>(
        builder: (_) => SogliaArte(
          id: 'sigilli_${sentiero.name}',
          maestro: sentiero.maestro,
          child: SentieroScreen(sentiero: sentiero),
        ),
      );

  @override
  State<SentieroScreen> createState() => _SentieroScreenState();
}

class _SentieroScreenState extends State<SentieroScreen> {
  final ScrollController _scorrimento = ScrollController();

  /// L'altezza di un gradino del sentiero: serve a sapere dove fermarsi.
  static const double altezzaDelGradino = 92;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scendiAlPunto());
  }

  @override
  void dispose() {
    _scorrimento.dispose();
    super.dispose();
  }

  /// LA DISCESA: dal 50 in luce fino al punto raggiunto.
  ///
  /// La lista e' rovesciata, quindi il 50 sta in cima e l'offset zero e'
  /// proprio il traguardo piu' alto: si parte da li' e si scende. Con Riduci
  /// Movimento, o nelle anteprime, ci si posa senza volo.
  Future<void> _scendiAlPunto() async {
    if (!mounted) return;
    final diario = context.read<DiarioDelCammino>();
    final accesi = diario.quantiAccesiDi(widget.sentiero);
    // Si scende fino al primo traguardo non ancora acceso, che e' il punto
    // dove il cammino si e' fermato.
    final gradini = (50 - accesi).clamp(0, 50);
    final dove = (50 - gradini) * altezzaDelGradino;
    if (dove <= 0 || !_scorrimento.hasClients) return;
    final fermo = widget.senzaVolo ||
        MediaQuery.maybeOf(context)?.disableAnimations == true;
    if (fermo) {
      _scorrimento.jumpTo(dove.clamp(0, _scorrimento.position.maxScrollExtent));
      return;
    }
    await _scorrimento.animateTo(
      dove.clamp(0, _scorrimento.position.maxScrollExtent),
      duration: const Duration(milliseconds: 1400),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final diario = context.watch<DiarioDelCammino>();
    final borsa = context.watch<QuestionAllowance>();
    final piano = context.watch<EntitlementService>().tier;
    // I traguardi si mostrano dal 50 al 1: l'apertura viene dall'alto.
    final mini = Sentieri.miniDi(widget.sentiero).reversed.toList();

    return CosmosBackground(
      seed: 19,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(widget.sentiero.titolo,
              style: TypographyTokens.titoloSezione()
                  .copyWith(color: palette.goldSoft)),
          actions: [
            // IL SALDO EOS, che legge dal server e non finge: finche' le
            // funzioni non sono distribuite mostra l'ultimo saldo noto.
            Padding(
              padding: const EdgeInsets.only(right: SpacingTokens.md),
              child: Row(
                key: const Key('saldo_eos'),
                children: [
                  Icon(Icons.auto_awesome, size: 16, color: palette.goldSoft),
                  const SizedBox(width: 4),
                  Text('${borsa.saldoEos}',
                      key: const Key('saldo_eos_numero'),
                      style: TypographyTokens.etichetta()
                          .copyWith(color: palette.goldSoft)),
                ],
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            _FasciaDeiGrandi(sentiero: widget.sentiero, diario: diario),
            Expanded(
              child: ListView.builder(
                key: const Key('sentiero_scorrimento'),
                controller: _scorrimento,
                padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.lg, vertical: SpacingTokens.md),
                itemCount: mini.length,
                itemBuilder: (context, i) => _GradinoDelSentiero(
                  traguardo: mini[i],
                  sentiero: widget.sentiero,
                  diario: diario,
                  piano: piano,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// I CINQUE GRANDI, sempre visibili in anticipo: modello tessera punti.
class _FasciaDeiGrandi extends StatelessWidget {
  const _FasciaDeiGrandi({required this.sentiero, required this.diario});

  final Sentiero sentiero;
  final DiarioDelCammino diario;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      key: const Key('fascia_dei_grandi'),
      padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.lg, vertical: SpacingTokens.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (final grande in Sentieri.grandiDi(sentiero))
            Column(
              children: [
                Icon(
                  diario.eAcceso(grande.id)
                      ? Icons.auto_awesome
                      : Icons.circle_outlined,
                  size: 26,
                  color: diario.eAcceso(grande.id)
                      ? palette.goldSoft
                      : ColorTokens.textSecondary.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 2),
                Text('${grande.posizione}',
                    style: TypographyTokens.etichetta().copyWith(
                      color: diario.eAcceso(grande.id)
                          ? palette.goldSoft
                          : ColorTokens.textSecondary,
                    )),
              ],
            ),
        ],
      ),
    );
  }
}

/// UN GRADINO: il Sigillo nei suoi tre stati.
class _GradinoDelSentiero extends StatelessWidget {
  const _GradinoDelSentiero({
    required this.traguardo,
    required this.sentiero,
    required this.diario,
    required this.piano,
  });

  final Traguardo traguardo;
  final Sentiero sentiero;
  final DiarioDelCammino diario;
  final Tier piano;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final acceso = diario.eAcceso(traguardo.id);
    final prossimo = diario.prossimoDi(sentiero)?.id == traguardo.id;
    final bloccato = Sentieri.chiedeIlTier(traguardo) && piano == Tier.free;

    // I TRE STATI: acceso, in corso, non ancora conquistato in grigio
    // trasparente. Il Sigillo si accende al RAGGIUNGIMENTO, sempre: la
    // condivisione governa solo il bonus, e chi non condivide non vede buchi.
    final colore = acceso
        ? palette.goldSoft
        : prossimo
            ? palette.goldSoft.withValues(alpha: 0.7)
            : ColorTokens.textSecondary.withValues(alpha: 0.35);

    return Opacity(
      opacity: acceso || prossimo ? 1 : 0.55,
      child: ListTile(
        key: Key('gradino_${traguardo.id}'),
        leading: Icon(
          acceso
              ? Icons.auto_awesome
              : prossimo
                  ? Icons.radio_button_unchecked
                  : Icons.lock_outline_rounded,
          color: colore,
        ),
        title: Text(traguardo.nome,
            style: TypographyTokens.titoloScheda().copyWith(color: colore)),
        subtitle: Text(
          acceso
              ? traguardo.frase
              : bloccato
                  ? 'Dal Tier 1 in su'
                  : '${traguardo.posizione} di 50',
          maxLines: 2,
          style: TypographyTokens.didascalia()
              .copyWith(color: ColorTokens.textSecondary),
        ),
        trailing: Text('${traguardo.eos}',
            style: TypographyTokens.etichetta().copyWith(color: colore)),
        // OGNI SIGILLO ACCESO E' TOCCABILE, voce 2e: riapre la sua card e la
        // si puo' condividere anche settimane dopo, incassando il bonus
        // rimasto in sospeso. Nessun traguardo raggiunto resta senza una via
        // per condividerlo.
        onTap: acceso
            ? () => mostraLaCardDelTraguardo(context,
                traguardo: traguardo, sentiero: sentiero)
            : bloccato
                ? () => showUpgradeInvite(
                      context,
                      title: 'Il cammino continua dal Tier 1',
                      message:
                          'I primi venti traguardi di ogni sentiero sono di '
                          'tutti. Dal ventunesimo il cammino prosegue con '
                          'l\'Iniziato, e gli Eos che hai già preso restano '
                          'tuoi per sempre.',
                    )
                : null,
      ),
    );
  }
}
