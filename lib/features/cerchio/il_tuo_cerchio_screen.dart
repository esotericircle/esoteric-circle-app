import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/cerchio/i_segni_del_cerchio.dart';
import '../../core/cerchio/il_cerchio_sociale.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';
import 'invita_nel_cerchio_screen.dart';
import 'profilo_nel_cerchio_screen.dart';
import 'scheda_dell_amico_screen.dart';
import 'widgets/disegni_del_cerchio.dart';
import 'widgets/i_segni_ricevuti.dart';

/// **IL TUO CERCHIO, ordine EY.** La casa del motore sociale: gli amici col
/// semaforino verde, chi ti ha invitato (arancione pieno: accetta o
/// rifiuta), chi hai invitato tu (arancione chiaro: aspetti), i segni
/// ricevuti con le loro risposte, e i posti del piano.
///
/// **Nessun cancello sociale** (legge L1 dell'ordine): niente qui si apre
/// invitando qualcuno, e niente fuori di qui si chiude per chi non invita.
class IlTuoCerchioScreen extends StatefulWidget {
  const IlTuoCerchioScreen({super.key});

  static Route<void> route() =>
      PassaggioDelCerchio.rotta<void>((_) => const IlTuoCerchioScreen());

  @override
  State<IlTuoCerchioScreen> createState() => _IlTuoCerchioScreenState();
}

class _IlTuoCerchioScreenState extends State<IlTuoCerchioScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<IlCerchioSociale>().caricaIlCerchio();
    });
  }

  Future<void> _rispondi(PersonaDelCerchio p, String azione) async {
    final sociale = context.read<IlCerchioSociale>();
    final esito = await sociale.rispondiAlLegame(p.uid, azione);
    if (!mounted) return;
    final riga = esito.ok
        ? (azione == 'accetta'
            ? '${p.nome} è nel tuo Cerchio.'
            : 'Invito lasciato andare.')
        : esito.riga;
    if (riga != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(riga)));
    }
  }

  @override
  Widget build(BuildContext context) {
    const palette = MaestroPalette.neutral;
    final sociale = context.watch<IlCerchioSociale>();
    final c = sociale.cerchio;
    return conIPulsantiDOro(
        context,
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: palette.goldSoft),
            title: Text('Il tuo Cerchio',
                style: TypographyTokens.titoloDiSchermata()
                    .copyWith(color: palette.goldSoft)),
            actions: [
              IconButton(
                key: const Key('cerchio_al_profilo'),
                tooltip: 'Il tuo nome nel Cerchio',
                icon: const Icon(Icons.badge_outlined),
                onPressed: () =>
                    Navigator.of(context).push(ProfiloNelCerchioScreen.route()),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: sociale.caricaIlCerchio,
            // Tutte le persone della schermata sono un elenco solo: chi ti
            // cerca, i tuoi amici e chi aspetta la tua risposta (FA.04).
            child: ElencoDelCerchio(
              persone: [...c.ricevuti, ...c.amici, ...c.inviati],
              child: ListView(
                key: const Key('il_tuo_cerchio_lista'),
                padding: const EdgeInsets.fromLTRB(
                    SpacingTokens.md, 0, SpacingTokens.md, SpacingTokens.xl),
                children: [
                  _IPosti(
                      amici: c.amici.length, posti: c.posti, palette: palette),
                  const SizedBox(height: SpacingTokens.md),
                  if (!sociale.vivo)
                    Text(
                      // **IL RIPIEGO, DICHIARATO A SCHERMO**: senza il server il
                      // Cerchio sociale non c'e', e lo si dice invece di mostrare
                      // un elenco vuoto che sembra vero.
                      'Il Cerchio non risponde adesso: amici, segni e inviti tornano '
                      'appena c’è la rete.',
                      key: const Key('cerchio_silenzio'),
                      style: TypographyTokens.corpo().copyWith(
                          color: ColorTokens.textSecondary, height: 1.4),
                    ),
                  FilledButton.icon(
                    key: const Key('cerchio_invita'),
                    style: FilledButton.styleFrom(
                      backgroundColor: palette.gold,
                      foregroundColor: palette.onPrimary,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: () => Navigator.of(context)
                        .push(InvitaNelCerchioScreen.route()),
                    icon: const Icon(Icons.person_add_alt_1_rounded),
                    label: Text('Chiama nel tuo Cerchio',
                        style: TypographyTokens.etichetta()),
                  ),
                  if (c.ricevuti.isNotEmpty) ...[
                    const _Titolo('Ti cercano'),
                    for (final p in c.ricevuti)
                      RigaDellaPersona(
                        persona: p,
                        sotto: 'Ti ha invitato nel suo Cerchio',
                        azioniSotto: true,
                        azioni: [
                          TextButton(
                            key: Key('accetta_${p.uid}'),
                            onPressed: () => _rispondi(p, 'accetta'),
                            child: Text('Accetta',
                                style: TypographyTokens.etichetta()
                                    .copyWith(color: Semaforino.verde)),
                          ),
                          TextButton(
                            key: Key('rifiuta_${p.uid}'),
                            onPressed: () => _rispondi(p, 'rifiuta'),
                            child: Text('Non ora',
                                style: TypographyTokens.etichetta().copyWith(
                                    color: ColorTokens.textSecondary)),
                          ),
                        ],
                      ),
                  ],
                  const _Titolo('I tuoi amici'),
                  if (c.amici.isEmpty)
                    Text(
                      'Il tuo Cerchio è ancora vuoto. Manda il tuo invito, oppure '
                      'fai inquadrare il tuo codice a chi ti sta accanto.',
                      style: TypographyTokens.corpo().copyWith(
                          color: ColorTokens.textSecondary, height: 1.4),
                    ),
                  for (final p in c.amici)
                    RigaDellaPersona(
                      persona: p,
                      onTap: () => Navigator.of(context)
                          .push(SchedaDellAmicoScreen.route(p)),
                    ),
                  if (c.segni.isNotEmpty) ...[
                    const _Titolo('I segni'),
                    ISegniRicevuti(segni: c.segni),
                  ],
                  if (c.inviati.isNotEmpty) ...[
                    const _Titolo('Aspetti una risposta'),
                    for (final p in c.inviati)
                      RigaDellaPersona(
                        persona: p,
                        sotto:
                            'Hai mandato il tuo invito: aspetti la sua risposta',
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Hai invitato ${p.nome}: aspetti la sua risposta.'))),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ));
  }
}

class _Titolo extends StatelessWidget {
  const _Titolo(this.testo);
  final String testo;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(
            top: SpacingTokens.lg, bottom: SpacingTokens.xs),
        child: Text(testo.toUpperCase(),
            style: TypographyTokens.etichetta().copyWith(
                color: MaestroPalette.neutral.goldSoft, letterSpacing: 1.4)),
      );
}

/// **I POSTI DEL CERCHIO, a colpo d'occhio**: un anello per posto, pieni
/// quelli presi. Il numero lo dice il server, dalla matrice dei piani.
class _IPosti extends StatelessWidget {
  const _IPosti(
      {required this.amici, required this.posti, required this.palette});
  final int amici;
  final int posti;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    final mostrati = posti.clamp(0, 15);
    return Column(
      key: const Key('cerchio_posti'),
      children: [
        SizedBox(
          height: 120,
          child: CustomPaint(
            size: const Size(double.infinity, 120),
            painter: _AnelloDeiPosti(
                presi: amici, posti: mostrati, palette: palette),
          ),
        ),
        Text(
            '$amici ${amici == 1 ? 'amico' : 'amici'} su $posti posti del '
            'tuo piano',
            style: TypographyTokens.didascalia()
                .copyWith(color: ColorTokens.textSecondary)),
      ],
    );
  }
}

class _AnelloDeiPosti extends CustomPainter {
  _AnelloDeiPosti(
      {required this.presi, required this.posti, required this.palette});
  final int presi;
  final int posti;
  final MaestroPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.height * 0.38;
    canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = palette.gold.withValues(alpha: 0.3));
    for (var i = 0; i < posti; i++) {
      final a = -math.pi / 2 + i * 2 * math.pi / posti;
      final p = c + Offset(r * math.cos(a), r * math.sin(a));
      final preso = i < presi;
      canvas.drawCircle(
          p,
          preso ? 7 : 5,
          Paint()
            ..color = preso
                ? palette.goldSoft
                : palette.gold.withValues(alpha: 0.25));
    }
    canvas.drawCircle(c, 9, Paint()..color = palette.gold);
  }

  @override
  bool shouldRepaint(_AnelloDeiPosti old) =>
      old.presi != presi || old.posti != posti;
}

/// UNA PERSONA IN UN ELENCO DEL CERCHIO: l'icona, il nome, il semaforino.
/// **Il sigillo NON si mostra qui**: si mostra nel profilo e nella ricerca.
class RigaDellaPersona extends StatelessWidget {
  const RigaDellaPersona({
    super.key,
    required this.persona,
    this.sotto,
    this.onTap,
    this.azioni = const [],
    this.azioniSotto = false,
  });

  final PersonaDelCerchio persona;
  final String? sotto;
  final VoidCallback? onTap;
  final List<Widget> azioni;

  /// Le azioni con le parole (Accetta, Non ora) stanno sotto il nome: accanto
  /// lo schiacciavano fino a una lettera, visto nell'anteprima.
  final bool azioniSotto;

  @override
  Widget build(BuildContext context) {
    const palette = MaestroPalette.neutral;
    return Card(
      key: Key('persona_${persona.uid}'),
      color: palette.surfaceElevated.withValues(alpha: 0.8),
      margin: const EdgeInsets.symmetric(vertical: SpacingTokens.xxs),
      child: InkWell(
        enableFeedback: false,
        borderRadius: BorderRadius.circular(SpacingTokens.radiusSm),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.sm),
          child: Column(children: [
            Row(
              children: [
                IconaTonda(icona: persona.icona, lato: 44),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Flexible(
                          child: NomeDellaPersona(
                              nome: persona.nome,
                              sigillo: persona.sigillo,
                              stile: TypographyTokens.titoloDiRiga()
                                  .copyWith(color: palette.goldSoft)),
                        ),
                        const SizedBox(width: SpacingTokens.xs),
                        Semaforino(semaforo: persona.semaforo),
                      ]),
                      if (sotto != null || persona.arte != null)
                        Text(
                          sotto ?? 'È ${persona.arte!.dove}',
                          style: TypographyTokens.didascalia()
                              .copyWith(color: ColorTokens.textSecondary),
                        ),
                    ],
                  ),
                ),
                if (!azioniSotto) ...azioni,
              ],
            ),
            if (azioniSotto)
              Row(mainAxisAlignment: MainAxisAlignment.end, children: azioni),
          ]),
        ),
      ),
    );
  }
}

/// I segni ricevuti mostrano i loro ornamenti: qui serve solo il nome del
/// segno per la riga di chi lo ha mandato.
String testoDelSegno(String id) =>
    ISegniDelCerchio.perId(id)?.testo ?? 'Un segno';
