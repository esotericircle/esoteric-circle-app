import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/cerchio/gli_enigmi_del_cerchio.dart';
import '../../../core/cerchio/il_cerchio_sociale.dart';
import '../../../core/entitlement/listino_degli_eos.dart';
import '../../../core/entitlement/question_allowance.dart';
import '../../../design_system/components/la_conferma_della_spesa.dart';
import '../../../design_system/theme/maestro_palette.dart';
import '../../../design_system/theme/maestro_scope.dart';
import '../../../design_system/tokens/color_tokens.dart';
import '../../../design_system/tokens/spacing_tokens.dart';
import '../../../design_system/tokens/typography_tokens.dart';
import '../../../design_system/transizioni/passaggio_del_cerchio.dart';
import '../widgets/disegni_del_cerchio.dart';
import 'i_mattoni_degli_enigmi.dart';
import 'il_ritratto_screen.dart';

/// **CHI DEL CERCHIO.** Ordine FF voce 04, 8 ottobre 2026.
///
/// Il fondatore: *"il gioco indovina chi, indovina chi è l'archetipo di un
/// utente, oppure chi è il mago del cerchio secondo te"*. Quattro persone del
/// proprio Cerchio e una domanda con una risposta giusta, da un dato vero. Si
/// gioca da soli, contro i dati: il risultato arriva subito. Gli indizi uno
/// alla volta, il primo gratis, poi cinque Eos (voce FF.03); ogni indizio
/// abbassa i punti.
class LIndovinelloScreen extends StatefulWidget {
  const LIndovinelloScreen({super.key, this.partita});

  /// Una partita gia' aperta, per le prove e le anteprime.
  final PartitaDellEnigma? partita;

  static Route<void> route() => PassaggioDelCerchio.rotta<void>(
      (_) => const MaestroScope(neutro: true, child: LIndovinelloScreen()));

  @override
  State<LIndovinelloScreen> createState() => _LIndovinelloScreenState();
}

class _LIndovinelloScreenState extends State<LIndovinelloScreen> {
  PartitaDellEnigma? _partita;
  String? _riga;
  String? _perche;
  bool _aspetto = false;

  @override
  void initState() {
    super.initState();
    _partita = widget.partita;
    if (_partita == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _apri());
    }
  }

  Future<void> _apri() async {
    setState(() {
      _aspetto = true;
      _riga = null;
      _perche = null;
      _partita = null;
    });
    final esito = await context.read<IlCerchioSociale>().apriUnIndovinello();
    if (!mounted) return;
    setState(() {
      _aspetto = false;
      if (esito.ok) {
        _partita = PartitaDellEnigma.da(esito.dati);
        return;
      }
      _perche = esito.motivo;
      _riga = switch (_perche) {
        'ritratto' =>
          'Prima di giocare compila il tuo Ritratto: otto caselle sono già '
              'pronte dalla tua carta.',
        'limite' =>
          'Hai giocato gli indovinelli di oggi. Domani ne arrivano altri.',
        'pochi' =>
          'Servono quattro persone del tuo Cerchio col Ritratto compilato: '
              'per ora ne trovo ${esito.dati['quanti'] ?? 0}.',
        'nessunaDomanda' =>
          'Oggi i quattro volti si somigliano troppo: riprova fra poco.',
        _ => esito.rigaPerLaPersona,
      };
    });
  }

  Future<void> _indizio() async {
    final p = _partita;
    if (p == null || p.costoProssimo == null) return;
    final sociale = context.read<IlCerchioSociale>();
    final EsitoDelGesto esito;
    if (p.costoProssimo == 0) {
      esito = await sociale.ilPrimoIndizio(p.id);
    } else {
      final consenso = await LaConfermaDellaSpesa.degliEos(context,
          costo: ListinoDegliEos.indizio.costo);
      if (consenso == null || !mounted) return;
      esito = await sociale.unIndizioInPiu(p.id, consenso: consenso);
    }
    if (!mounted) return;
    final saldo = esito.dati['saldo'];
    if (saldo is num) {
      try {
        await context.read<QuestionAllowance>().applicaSaldo(saldo.toInt());
      } catch (senzaIlBorsellino) {
        // Senza il borsellino montato il saldo si riallinea al ritorno.
      }
    }
    if (!mounted) return;
    setState(() {
      if (esito.ok) {
        _partita = p.conIndizio(
            IndizioDellEnigma.da(esito.dati['indizio']),
            esito.dati['costoProssimo'] is num
                ? (esito.dati['costoProssimo'] as num).toInt()
                : null);
      } else if (esito.motivo == 'eos') {
        _riga = 'Mancano ${esito.dati['manca']} Eos per un altro indizio.';
      }
    });
  }

  Future<void> _rispondi(VoltoDellEnigma volto) async {
    final p = _partita;
    if (p == null || p.chiusa) return;
    final esito = await context
        .read<IlCerchioSociale>()
        .rispondiAllIndovinello(p.id, volto.uid);
    if (!mounted) return;
    setState(() {
      if (esito.ok) {
        _partita = p.chiusaCon(esito.dati['era'] as String? ?? '',
            (esito.dati['punti'] as num? ?? 0).toDouble());
      } else if (esito.motivo == 'limite') {
        _riga =
            'Hai giocato gli indovinelli di oggi. Domani ne arrivano altri.';
      } else {
        _riga = esito.rigaPerLaPersona;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const palette = MaestroPalette.neutral;
    final p = _partita;
    return conIPulsantiDOro(
        context,
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: palette.goldSoft),
            title: Text('Chi del Cerchio',
                style: TypographyTokens.titoloDiSchermata()
                    .copyWith(color: palette.goldSoft)),
          ),
          body: ListView(
            key: const Key('l_indovinello'),
            padding: const EdgeInsets.fromLTRB(
                SpacingTokens.md, 0, SpacingTokens.md, SpacingTokens.xl),
            children: [
              if (_aspetto)
                const Padding(
                  padding: EdgeInsets.all(SpacingTokens.xl),
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (p == null && _riga != null) ...[
                RigaDegliEnigmi(_riga!),
                const SizedBox(height: SpacingTokens.md),
                if (_perche == 'ritratto')
                  PulsanteDegliEnigmi(
                    key: const Key('indovinello_al_ritratto'),
                    etichetta: 'Compila il Ritratto',
                    onPressed: () async {
                      final fatto = await Navigator.of(context)
                          .push(IlRitrattoScreen.route());
                      if (fatto == true && mounted) await _apri();
                    },
                  ),
              ],
              if (p != null) ...[
                Text(p.domanda.testo,
                    key: const Key('indovinello_domanda'),
                    textAlign: TextAlign.center,
                    style: TypographyTokens.titoloScheda()
                        .copyWith(color: ColorTokens.textPrimary, height: 1.3)),
                const SizedBox(height: SpacingTokens.md),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: SpacingTokens.sm,
                  crossAxisSpacing: SpacingTokens.sm,
                  childAspectRatio: 1.15,
                  children: [
                    for (final v in p.facce)
                      _IlVolto(
                        key: Key('indovinello_volto_${v.uid}'),
                        volto: v,
                        esito: !p.chiusa
                            ? null
                            : v.uid == p.era
                                ? true
                                : false,
                        onTap: p.chiusa ? null : () => _rispondi(v),
                      ),
                  ],
                ),
                if (p.chiusa) ...[
                  const SizedBox(height: SpacingTokens.md),
                  Text(
                      (p.punti ?? 0) > 0
                          ? 'Giusto: ${puntiADetto(p.punti!)}.'
                          : 'Era ${p.facce.firstWhere((v) => v.uid == p.era, orElse: () => p.facce.first).nome}.',
                      key: const Key('indovinello_esito'),
                      textAlign: TextAlign.center,
                      style: TypographyTokens.titoloDiRiga()
                          .copyWith(color: palette.goldSoft)),
                  const SizedBox(height: SpacingTokens.sm),
                  PulsanteDegliEnigmi(
                    key: const Key('indovinello_un_altro'),
                    etichetta: 'Un altro indovinello',
                    onPressed: _apri,
                  ),
                ] else ...[
                  const SezioneDegliEnigmi('Gli indizi'),
                  if (p.indizi.isEmpty)
                    const RigaDegliEnigmi(
                        'Nessun indizio ancora. Se indovini adesso prendi tre punti.'),
                  for (var i = 0; i < p.indizi.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: SpacingTokens.xs),
                      child: Text('${i + 1}. ${p.indizi[i].testo}',
                          key: Key('indovinello_indizio_${i + 1}'),
                          style: TypographyTokens.corpo().copyWith(
                              color: ColorTokens.textPrimary, height: 1.4)),
                    ),
                  if (p.indizi.isNotEmpty)
                    RigaDegliEnigmi(
                        'Se indovini adesso prendi ${puntiADetto(const [
                      3.0,
                      2.0,
                      1.0,
                      0.5
                    ][p.indizi.length])}.'),
                  const SizedBox(height: SpacingTokens.sm),
                  if (p.costoProssimo != null)
                    PulsanteDegliEnigmi(
                      key: const Key('indovinello_indizio'),
                      icona: Icons.lightbulb_outline_rounded,
                      etichetta: p.costoProssimo == 0
                          ? 'Chiedi un indizio, il primo è gratis'
                          : 'Un indizio in più, '
                              '${ListinoDegliEos.indizio.costo} Eos',
                      onPressed: _indizio,
                    ),
                  if (_riga != null) ...[
                    const SizedBox(height: SpacingTokens.sm),
                    RigaDegliEnigmi(_riga!, oro: true),
                  ],
                ],
              ],
            ],
          ),
        ));
  }
}

class _IlVolto extends StatelessWidget {
  const _IlVolto({
    super.key,
    required this.volto,
    required this.esito,
    required this.onTap,
  });

  final VoltoDellEnigma volto;

  /// Nullo a partita aperta; vero sul volto giusto, falso sugli altri.
  final bool? esito;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const palette = MaestroPalette.neutral;
    return InkWell(
      onTap: onTap,
      enableFeedback: false,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: esito == true
                  ? palette.goldSoft
                  : palette.goldSoft.withValues(alpha: 0.35),
              width: esito == true ? 2 : 1),
        ),
        padding: const EdgeInsets.all(SpacingTokens.sm),
        child: Opacity(
          opacity: esito == false ? 0.55 : 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // **SENZA ICONA, L'INIZIALE**: il server non manda l'emblema
              // del segno (direbbe l'elemento), e il tondo vuoto ripiegherebbe
              // su un emblema qualunque, che suggerirebbe un segno falso.
              if (volto.icona != null)
                IconaTonda(icona: volto.icona!, nome: volto.nome, lato: 64)
              else
                Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ColorTokens.neutralDeepest,
                    border: Border.all(color: palette.gold, width: 1.5),
                  ),
                  child: Text(
                      volto.nome.isEmpty ? '?' : volto.nome[0].toUpperCase(),
                      style: TypographyTokens.titoloScheda()
                          .copyWith(color: palette.goldSoft)),
                ),
              const SizedBox(height: SpacingTokens.xs),
              Text(volto.nome,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TypographyTokens.titoloDiRiga()
                      .copyWith(color: ColorTokens.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }
}
