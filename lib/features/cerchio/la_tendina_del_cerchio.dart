import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/cerchio/il_cerchio_sociale.dart';
import '../../core/cerchio/l_arte_di_adesso.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/transizioni/velo_del_cerchio.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'confronto_del_cielo_screen.dart';
import 'il_tuo_cerchio_screen.dart';
import 'scheda_dell_amico_screen.dart';
import 'widgets/disegni_del_cerchio.dart';

/// **LA TENDINA DELL'INDICATORE ONLINE, ordine EY voce 08.** Al tocco
/// sull'indicatore scende una tendina, col movimento di un velo che si apre e
/// non di un menu'. Si chiude toccando fuori oppure trascinando in alto.
///
/// **Due piani.** Il primo: i tuoi amici presenti, col semaforino, cosa
/// stanno facendo in forma generica ("ai tarocchi", mai il responso ne' la
/// domanda), e due gesti: manda un segno, apri il confronto del cielo. Il
/// secondo: il Cerchio adesso, presenze aggregate per arte, e al massimo
/// dodici persone che ti somigliano col criterio scritto sotto ogni nome.
/// **Non esiste una via per scorrere tutti i presenti.**
///
/// I dati arrivano dall'istantanea del server, rifatta al massimo ogni trenta
/// secondi per tutto il Cerchio, e non da un calcolo per ogni telefono.
Future<void> apriLaTendinaDelCerchio(BuildContext context) {
  final sociale = context.read<IlCerchioSociale>();
  sociale.caricaLaTendina();
  return dialogoGeneraleDelCerchio<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Chiudi la tendina',
    barrierColor: const Color(0xAA05030F),
    transitionDuration: const Duration(milliseconds: 420),
    // Il fondo e' trasparente apposta: il velo lo mette la porta, e la
    // tendina porta il suo. Il tocco fuori dalla tendina la chiude.
    pageBuilder: (c, _, __) => ChangeNotifierProvider.value(
      value: sociale,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(c).pop(),
            ),
          ),
          const _LaTendina(),
        ]),
      ),
    ),
    transitionBuilder: (c, animazione, _, figlio) {
      final curva =
          CurvedAnimation(parent: animazione, curve: Curves.easeOutCubic);
      // Il velo: scende dall'alto e prende luce mentre scende.
      return FadeTransition(
        opacity: curva,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, -0.35), end: Offset.zero)
              .animate(curva),
          child: figlio,
        ),
      );
    },
  );
}

class _LaTendina extends StatelessWidget {
  const _LaTendina();

  @override
  Widget build(BuildContext context) {
    const palette = MaestroPalette.neutral;
    final sociale = context.watch<IlCerchioSociale>();
    final t = sociale.tendina;
    final altezza = MediaQuery.sizeOf(context).height * 0.82;
    // I presenti della tendina sono un elenco solo: gli amici e le persone
    // simili (ordine FA voce 04, il sigillo quando due nomi coincidono).
    return ElencoDelCerchio(
      persone: t == null ? const [] : [...t.amiciPresenti, ...t.somiglianti],
      child: Align(
        alignment: Alignment.topCenter,
        child: GestureDetector(
          // Trascinando in alto la tendina si chiude.
          onVerticalDragEnd: (d) {
            if ((d.primaryVelocity ?? 0) < -200) Navigator.of(context).pop();
          },
          child: Material(
            key: const Key('la_tendina_del_cerchio'),
            color: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(maxHeight: altezza),
              margin: EdgeInsets.only(
                  top: MediaQuery.paddingOf(context).top + SpacingTokens.xs,
                  left: SpacingTokens.xs,
                  right: SpacingTokens.xs),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    palette.surfaceElevated.withValues(alpha: 0.97),
                    palette.deepest.withValues(alpha: 0.97),
                  ],
                ),
                border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
                boxShadow: [
                  BoxShadow(
                      color: palette.gold.withValues(alpha: 0.18),
                      blurRadius: 30),
                ],
              ),
              child: sociale.chiusoPerEta
                  // Sotto i quattordici anni la tendina dice la riga sola
                  // (ordine EZ voce 04).
                  ? Padding(
                      key: const Key('tendina_quattordici_anni'),
                      padding: const EdgeInsets.all(SpacingTokens.xl),
                      child: Text(IlCerchioSociale.rigaDeiQuattordici,
                          textAlign: TextAlign.center,
                          style: TypographyTokens.corpo()
                              .copyWith(color: palette.goldSoft)),
                    )
                  : t == null
                      ? const Padding(
                          padding: EdgeInsets.all(SpacingTokens.xl),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : ListView(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(SpacingTokens.md),
                          children: [
                            Center(
                              child: Container(
                                width: 44,
                                height: 4,
                                decoration: BoxDecoration(
                                    color: palette.gold.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(2)),
                              ),
                            ),
                            if (t.visibilita == VisibilitaNelCerchio.invisibile)
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: SpacingTokens.sm),
                                child: Text(
                                    'Sei invisibile: nessuno ti vede e tu vedi gli '
                                    'altri.',
                                    key: const Key('tendina_invisibile'),
                                    style: TypographyTokens.didascalia()
                                        .copyWith(color: palette.goldSoft)),
                              ),
                            const _Piano('I tuoi amici presenti'),
                            if (t.amiciPresenti.isEmpty)
                              Text(
                                  sociale.cerchio.amici.isEmpty
                                      ? 'Il tuo Cerchio è ancora da chiamare.'
                                      : 'Nessuno dei tuoi amici è qui adesso.',
                                  style: TypographyTokens.corpo().copyWith(
                                      color: ColorTokens.textSecondary)),
                            for (final p in t.amiciPresenti)
                              _AmicoPresente(persona: p),
                            const _Piano('Il Cerchio adesso'),
                            _LeArti(perArte: t.perArte),
                            if (t.somiglianti.isNotEmpty) ...[
                              const _Piano('Ti somigliano'),
                              for (final p in t.somiglianti)
                                _Simile(persona: p),
                            ],
                            const SizedBox(height: SpacingTokens.sm),
                            TextButton(
                              key: const Key('tendina_al_cerchio'),
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.of(context)
                                    .push(IlTuoCerchioScreen.route());
                              },
                              child: Text('Il tuo Cerchio',
                                  style: TypographyTokens.etichetta()
                                      .copyWith(color: palette.goldSoft)),
                            ),
                          ],
                        ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Piano extends StatelessWidget {
  const _Piano(this.titolo);
  final String titolo;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(
            top: SpacingTokens.md, bottom: SpacingTokens.xs),
        child: Text(titolo.toUpperCase(),
            style: TypographyTokens.etichetta().copyWith(
                color: MaestroPalette.neutral.goldSoft, letterSpacing: 1.4)),
      );
}

class _AmicoPresente extends StatelessWidget {
  const _AmicoPresente({required this.persona});
  final PersonaDelCerchio persona;

  @override
  Widget build(BuildContext context) {
    final sociale = context.read<IlCerchioSociale>();
    final completo =
        sociale.cerchio.amici.where((a) => a.uid == persona.uid).firstOrNull ??
            persona;
    return RigaDellaPersona(
      persona: persona.conSemaforo(Semaforo.verde),
      onTap: () {
        Navigator.of(context).pop();
        Navigator.of(context).push(SchedaDellAmicoScreen.route(completo));
      },
      azioni: [
        IconButton(
          visualDensity: VisualDensity.compact,
          key: Key('tendina_segno_${persona.uid}'),
          tooltip: 'Manda un segno',
          icon:
              Icon(Icons.auto_awesome, color: MaestroPalette.neutral.goldSoft),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(SchedaDellAmicoScreen.route(completo));
          },
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          key: Key('tendina_confronto_${persona.uid}'),
          tooltip: 'Confronta i cieli',
          icon: Icon(Icons.join_inner_rounded,
              color: MaestroPalette.neutral.goldSoft),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(ConfrontoDelCieloScreen.route(completo));
          },
        ),
      ],
    );
  }
}

/// IL CERCHIO ADESSO, per arte: non nomi, ma presenze. Chi non ha ancora
/// amici vede un'app abitata invece di un vuoto.
class _LeArti extends StatelessWidget {
  const _LeArti({required this.perArte});
  final Map<ArteDellaPresenza, int> perArte;

  @override
  Widget build(BuildContext context) {
    const palette = MaestroPalette.neutral;
    final arti = perArte.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (arti.isEmpty) {
      return Text('Il Cerchio si sta svegliando.',
          style: TypographyTokens.corpo()
              .copyWith(color: ColorTokens.textSecondary));
    }
    final massimo = arti.first.value;
    return Column(
      key: const Key('tendina_per_arte'),
      children: [
        for (final e in arti)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                SizedBox(
                  width: 34,
                  child: Text('${e.value}',
                      textAlign: TextAlign.right,
                      style: TypographyTokens.titoloDiRiga()
                          .copyWith(color: palette.goldSoft)),
                ),
                const SizedBox(width: SpacingTokens.xs),
                Expanded(
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      FractionallySizedBox(
                        widthFactor: (e.value / massimo).clamp(0.08, 1.0),
                        child: Container(
                          height: 26,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(13),
                            color: palette.gold.withValues(alpha: 0.22),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: SpacingTokens.xs),
                        child: Text(e.key.dove,
                            style: TypographyTokens.corpo()
                                .copyWith(color: ColorTokens.textPrimary)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Simile extends StatelessWidget {
  const _Simile({required this.persona});
  final PersonaDelCerchio persona;

  Future<void> _invita(BuildContext context) async {
    final esito =
        await context.read<IlCerchioSociale>().chiediIlLegame(uid: persona.uid);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(esito.ok
            ? 'Hai invitato ${persona.nome}: aspetti la sua risposta.'
            : (esito.riga ?? EsitoDelGesto.silenzio.riga!))));
  }

  Future<void> _cenno(BuildContext context) async {
    final esito = await context
        .read<IlCerchioSociale>()
        .mandaUnDono(persona.uid, 'cenno');
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(esito.ok
            ? 'Hai salutato ${persona.nome} con un cenno.'
            : (esito.riga ?? EsitoDelGesto.silenzio.riga!))));
  }

  @override
  Widget build(BuildContext context) {
    const palette = MaestroPalette.neutral;
    return RigaDellaPersona(
      persona: persona,
      // IL CRITERIO SI DICHIARA, una riga sotto ogni nome.
      sotto: persona.criterio?.riga,
      azioni: [
        IconButton(
          visualDensity: VisualDensity.compact,
          key: Key('tendina_cenno_${persona.uid}'),
          tooltip: 'Un cenno di saluto',
          icon: Icon(Icons.waving_hand_outlined, color: palette.goldSoft),
          onPressed: () => _cenno(context),
        ),
        if (persona.invitabile && persona.semaforo == Semaforo.spento)
          IconButton(
            visualDensity: VisualDensity.compact,
            key: Key('tendina_invita_${persona.uid}'),
            tooltip: 'Invita nel tuo Cerchio',
            icon: Icon(Icons.person_add_alt_1_rounded, color: palette.goldSoft),
            onPressed: () => _invita(context),
          ),
      ],
    );
  }
}
