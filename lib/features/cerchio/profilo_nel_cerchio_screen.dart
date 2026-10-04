import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/archetypes/archetype_history.dart';
import '../../core/cerchio/i_segni_del_cerchio.dart';
import '../../core/cerchio/il_cerchio_sociale.dart';
import '../../core/cerchio/le_icone_del_cerchio.dart';
import '../../core/cerchio/le_regole_del_nome.dart';
import '../../core/identity/birth_identity.dart';
import '../../core/identity/profile_controller.dart';
import '../../core/sigilli/diario_del_cammino.dart';
import '../../design_system/components/interruttore_del_cerchio.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';
import '../../design_system/transizioni/velo_del_cerchio.dart';
import 'widgets/disegni_del_cerchio.dart';

/// **IL TUO NOME NEL CERCHIO, ordine EY voce 03.** Una schermata sola, dal
/// profilo: il nome e il sigillo in alto, il cambio del nome con la sua
/// cadenza e il giorno in cui si riapre, la scelta dell'icona, la
/// visibilita', chi puo' invitarti, i doni ricevuti e l'elenco delle persone
/// bloccate con la via per sbloccarle. E' l'unico posto dove vive il rosso.
class ProfiloNelCerchioScreen extends StatefulWidget {
  const ProfiloNelCerchioScreen({super.key});

  static Route<void> route() => PassaggioDelCerchio.rotta<void>((_) =>
      const MaestroScope(neutro: true, child: ProfiloNelCerchioScreen()));

  @override
  State<ProfiloNelCerchioScreen> createState() =>
      _ProfiloNelCerchioScreenState();
}

class _ProfiloNelCerchioScreenState extends State<ProfiloNelCerchioScreen> {
  final TextEditingController _nome = TextEditingController();
  LeRegoleDelNome? _regole;
  String? _rigaDelNome;
  bool _scrivo = false;

  @override
  void initState() {
    super.initState();
    LeRegoleDelNome.carica().then((r) {
      if (mounted) setState(() => _regole = r);
    }).catchError((Object _) {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final sociale = context.read<IlCerchioSociale>();
      _nome.text = sociale.profilo?.nome ?? '';
      sociale.caricaIlCerchio();
    });
  }

  @override
  void dispose() {
    _nome.dispose();
    super.dispose();
  }

  Future<void> _salvaIlNome() async {
    final verdetto = _regole?.verdetto(_nome.text);
    if (verdetto != null) {
      setState(() => _rigaDelNome = verdetto.riga);
      return;
    }
    setState(() => _scrivo = true);
    final esito =
        await context.read<IlCerchioSociale>().scegliIlNome(_nome.text);
    if (!mounted) return;
    setState(() {
      _scrivo = false;
      _rigaDelNome = esito.ok
          ? 'Il tuo nome nel Cerchio adesso è ${_nome.text.trim()}.'
          : (esito.riga ?? EsitoDelGesto.silenzio.riga);
    });
  }

  Future<void> _scegliLIcona() async {
    BirthIdentity? identita;
    DiarioDelCammino? diario;
    var archetipi = <int>{};
    try {
      final i = context.read<ProfileController>().identity;
      identita = i.isExample ? null : i;
    } catch (senzaQuelDato) {
      // Il dato e' facoltativo: senza, si va avanti col ripiego.
    }
    try {
      diario = context.read<DiarioDelCammino>();
    } catch (senzaQuelDato) {
      // Il dato e' facoltativo: senza, si va avanti col ripiego.
    }
    try {
      archetipi = {
        for (final e in context.read<ArchetypeHistory>().esiti)
          e.dominante.index,
      };
    } catch (senzaQuelDato) {
      // Il dato e' facoltativo: senza, si va avanti col ripiego.
    }
    final scelta = await foglioDelCerchio<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (c) => fondoDelFoglio(
        c,
        _LaSceltaDellIcona(
          attuale: context.read<IlCerchioSociale>().profilo?.icona,
          incontrata: (i) => i.incontrata(
              diario: diario,
              identita: identita,
              archetipiIncontrati: archetipi),
        ),
      ),
    );
    if (scelta == null || !mounted) return;
    await context.read<IlCerchioSociale>().aggiorna(icona: scelta);
  }

  @override
  Widget build(BuildContext context) {
    const palette = MaestroPalette.neutral;
    final sociale = context.watch<IlCerchioSociale>();
    final p = sociale.profilo;
    final riapre = p?.nomeSiRiapre;
    return conIPulsantiDOro(
        context,
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: palette.goldSoft),
            title: Text('Nome nel Cerchio',
                style: TypographyTokens.titoloDiSchermata()
                    .copyWith(color: palette.goldSoft)),
          ),
          body: ListView(
            key: const Key('profilo_nel_cerchio'),
            padding: const EdgeInsets.fromLTRB(
                SpacingTokens.md, 0, SpacingTokens.md, SpacingTokens.xl),
            children: [
              if (p == null)
                Text(
                  // Il ripiego dichiarato: senza il server il profilo non c'e'.
                  'Il Cerchio non risponde adesso: il tuo nome e il tuo sigillo '
                  'arrivano appena c’è la rete.',
                  key: const Key('profilo_silenzio'),
                  style: TypographyTokens.corpo()
                      .copyWith(color: ColorTokens.textSecondary, height: 1.4),
                ),
              if (p != null) ...[
                Center(
                  child: InkWell(
                    key: const Key('profilo_icona'),
                    enableFeedback: false,
                    customBorder: const CircleBorder(),
                    onTap: _scegliLIcona,
                    child: IconaTonda(icona: p.icona, lato: 112),
                  ),
                ),
                const SizedBox(height: SpacingTokens.sm),
                Text(p.haUnNome ? p.nome : 'Ancora senza nome',
                    textAlign: TextAlign.center,
                    style: TypographyTokens.cerimoniale()
                        .copyWith(color: palette.goldSoft)),
                // IL SIGILLO SI MOSTRA QUI, nel profilo, e nella ricerca col
                // sigillo: non sotto ogni nome negli elenchi.
                Text('Il tuo sigillo: ${p.sigillo}',
                    key: const Key('profilo_sigillo'),
                    textAlign: TextAlign.center,
                    style: TypographyTokens.titoloDiRiga().copyWith(
                        color: ColorTokens.textPrimary, letterSpacing: 3)),
                Text(
                    'Il nome può essere di più persone, il sigillo è solo tuo e '
                    'non cambia mai.',
                    textAlign: TextAlign.center,
                    style: TypographyTokens.didascalia()
                        .copyWith(color: ColorTokens.textSecondary)),
                const _Sezione('Il nome'),
                TextField(
                  key: const Key('profilo_campo_nome'),
                  controller: _nome,
                  maxLength: 20,
                  enabled: riapre == null,
                  style: TypographyTokens.titoloDiRiga()
                      .copyWith(color: ColorTokens.textPrimary),
                  decoration: InputDecoration(
                    counterText: '',
                    helperText: riapre == null
                        ? (p.primoNomeLibero
                            ? 'Il primo cambio è libero, poi uno ogni trenta giorni.'
                            : 'Il nome si cambia una volta ogni trenta giorni.')
                        : 'Il cambio del nome si riapre il '
                            '${riapre.day}/${riapre.month}/${riapre.year}.',
                    helperMaxLines: 2,
                    helperStyle: TypographyTokens.didascalia()
                        .copyWith(color: ColorTokens.textSecondary),
                  ),
                ),
                if (_rigaDelNome != null)
                  Text(_rigaDelNome!,
                      key: const Key('profilo_riga_nome'),
                      style: TypographyTokens.didascalia()
                          .copyWith(color: palette.goldSoft)),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    style: TextButton.styleFrom(
                        foregroundColor: MaestroPalette.neutral.goldSoft),
                    key: const Key('profilo_salva_nome'),
                    onPressed: riapre == null && !_scrivo ? _salvaIlNome : null,
                    child: Text(_scrivo ? 'Un momento...' : 'Cambia il nome'),
                  ),
                ),
                const _Sezione('Chi ti vede'),
                RadioGroup<VisibilitaNelCerchio>(
                  groupValue: p.visibilita,
                  onChanged: (nuova) => nuova == null
                      ? null
                      : context
                          .read<IlCerchioSociale>()
                          .aggiorna(visibilita: nuova),
                  child: Column(children: [
                    for (final v in VisibilitaNelCerchio.values)
                      RadioListTile<VisibilitaNelCerchio>(
                        key: Key('visibilita_${v.name}'),
                        value: v,
                        activeColor: palette.goldSoft,
                        title: Text(
                            switch (v) {
                              VisibilitaNelCerchio.amici => 'I tuoi amici',
                              VisibilitaNelCerchio.tutti => 'Tutto il Cerchio',
                              VisibilitaNelCerchio.invisibile =>
                                'Nessuno: sei invisibile',
                            },
                            style: TypographyTokens.corpo()
                                .copyWith(color: ColorTokens.textPrimary)),
                        subtitle: Text(
                            switch (v) {
                              VisibilitaNelCerchio.amici =>
                                'Solo i tuoi amici vedono che sei nel Cerchio.',
                              VisibilitaNelCerchio.tutti =>
                                'Chi non è tuo amico potrà vedere che sei nel Cerchio '
                                    'e invitarti.',
                              VisibilitaNelCerchio.invisibile =>
                                'Non compari da nessuna parte e continui a vedere gli '
                                    'altri. È gratuito per tutti i piani.',
                            },
                            style: TypographyTokens.didascalia()
                                .copyWith(color: ColorTokens.textSecondary)),
                      ),
                  ]),
                ),
                if (p.visibilita != p.visibilitaEffettiva)
                  Text('Per ora la tua presenza resta visibile ai soli amici.',
                      style: TypographyTokens.didascalia()
                          .copyWith(color: ColorTokens.textSecondary)),
                const _Sezione('Chi può invitarti'),
                InterruttoreDelCerchio(
                  key: const Key('solo_col_sigillo'),
                  acceso: p.soloColSigillo,
                  onCambia: (v) => context
                      .read<IlCerchioSociale>()
                      .aggiorna(soloColSigillo: v),
                  titolo: 'Solo chi ha il tuo sigillo',
                  sottotitolo: p.soloColSigillo
                      ? 'Chi ti ha solo visto in un elenco non può invitarti.'
                      : 'Oggi ti può invitare chiunque ti veda nel Cerchio.',
                ),
                const _Sezione('Il tuo link d’invito'),
                Text(
                    'Vale trenta giorni. Se è finito dove non volevi, rinnovalo: '
                    'quello di prima smette di valere.',
                    style: TypographyTokens.didascalia()
                        .copyWith(color: ColorTokens.textSecondary)),
                Row(
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                          foregroundColor: MaestroPalette.neutral.goldSoft),
                      key: const Key('link_rinnova'),
                      onPressed: () => context
                          .read<IlCerchioSociale>()
                          .codice(rinnova: true),
                      child: const Text('Rinnova'),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          foregroundColor: MaestroPalette.neutral.goldSoft),
                      key: const Key('link_revoca'),
                      onPressed: () =>
                          context.read<IlCerchioSociale>().codice(revoca: true),
                      child: const Text('Revoca'),
                    ),
                  ],
                ),
                if (sociale.cerchio.doni.isNotEmpty) ...[
                  const _Sezione('I doni ricevuti'),
                  Wrap(
                    spacing: SpacingTokens.sm,
                    children: [
                      for (final d in sociale.cerchio.doni)
                        Tooltip(
                          message: '${Dono.da(d.dono)?.nome ?? 'Un dono'} da '
                              '${d.nomeDa}',
                          child: DisegnoDelDono(
                              dono: Dono.da(d.dono) ?? Dono.cenno, lato: 44),
                        ),
                    ],
                  ),
                ],
                const _Sezione('Le persone bloccate'),
                if (sociale.cerchio.bloccati.isEmpty)
                  Text('Nessuna.',
                      style: TypographyTokens.didascalia()
                          .copyWith(color: ColorTokens.textSecondary)),
                for (final b in sociale.cerchio.bloccati)
                  ListTile(
                    key: Key('bloccata_${b.uid}'),
                    enableFeedback: false,
                    // IL ROSSO VIVE SOLO QUI.
                    leading: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Color(0xFFE5484D)),
                    ),
                    // Il sigillo accanto al nome solo quando due persone
                    // bloccate si chiamano allo stesso modo (ordine FA voce
                    // 04): prima lo portava sempre, sotto il nome.
                    title: ElencoDelCerchio(
                      persone: sociale.cerchio.bloccati,
                      child: NomeDellaPersona(
                          nome: b.nome,
                          sigillo: b.sigillo,
                          stile: TypographyTokens.corpo()
                              .copyWith(color: ColorTokens.textPrimary)),
                    ),
                    trailing: TextButton(
                      style: TextButton.styleFrom(
                          foregroundColor: MaestroPalette.neutral.goldSoft),
                      key: Key('sblocca_${b.uid}'),
                      onPressed: () => context
                          .read<IlCerchioSociale>()
                          .blocca(b.uid, sblocca: true),
                      child: const Text('Sblocca'),
                    ),
                  ),
              ],
            ],
          ),
        ));
  }
}

class _Sezione extends StatelessWidget {
  const _Sezione(this.titolo);
  final String titolo;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(
            top: SpacingTokens.lg, bottom: SpacingTokens.xs),
        child: Text(titolo.toUpperCase(),
            style: TypographyTokens.etichetta().copyWith(
                color: MaestroPalette.neutral.goldSoft, letterSpacing: 1.4)),
      );
}

/// LA SCELTA DELL'ICONA: tre famiglie, le icone non ancora incontrate spente
/// con la riga che dice da dove si aprono. **Una vetrina, non un lucchetto.**
///
/// **UNA FAMIGLIA ALLA VOLTA, ordine FA voce 03.** Le tre scelte in cima
/// mostrano i dodici segni, i dodici animali o le dodici statue; si apre
/// sulla famiglia dell'icona di oggi. Prima la vetrina era un elenco unico:
/// con tre famiglie scorreva appena, le ultime due finivano sulla stessa
/// schermata, e una cattura della vetrina poteva mostrare una famiglia per
/// un'altra senza che nessuno se ne accorgesse (premessa F7 dell'ordine FA).
class _LaSceltaDellIcona extends StatefulWidget {
  const _LaSceltaDellIcona({required this.incontrata, this.attuale});

  final bool Function(IconaDelProfilo) incontrata;

  /// Il codice dell'icona di oggi: la vetrina si apre sulla sua famiglia.
  final String? attuale;

  @override
  State<_LaSceltaDellIcona> createState() => _LaSceltaDellIconaState();
}

class _LaSceltaDellIconaState extends State<_LaSceltaDellIcona> {
  late FamigliaDelleIcone _famiglia =
      IconaDelProfilo.da(widget.attuale).famiglia;

  @override
  Widget build(BuildContext context) {
    const palette = MaestroPalette.neutral;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (c, scorri) => ListView(
        controller: scorri,
        padding: const EdgeInsets.all(SpacingTokens.md),
        children: [
          Row(
            children: [
              Expanded(
                child: Text('La tua icona',
                    style: TypographyTokens.titoloScheda()
                        .copyWith(color: palette.goldSoft)),
              ),
              TextButton(
                onPressed: () => Navigator.of(c).pop(),
                child: const Text('Fatto'),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          Wrap(
            spacing: SpacingTokens.xs,
            runSpacing: SpacingTokens.xs,
            children: [
              for (final f in FamigliaDelleIcone.values)
                ChoiceChip(
                  key: Key('vetrina_famiglia_${f.name}'),
                  selected: f == _famiglia,
                  showCheckmark: false,
                  backgroundColor: palette.deepest,
                  selectedColor: palette.gold.withValues(alpha: 0.28),
                  side: BorderSide(
                      color: palette.gold
                          .withValues(alpha: f == _famiglia ? 0.9 : 0.4)),
                  label: Text(f.titolo,
                      style: TypographyTokens.etichetta()
                          .copyWith(color: palette.goldSoft)),
                  onSelected: (_) => setState(() => _famiglia = f),
                ),
            ],
          ),
          const SizedBox(height: SpacingTokens.md),
          Wrap(
            key: Key('vetrina_icone_${_famiglia.name}'),
            spacing: SpacingTokens.sm,
            runSpacing: SpacingTokens.sm,
            children: [
              for (final i in IconaDelProfilo.di(_famiglia))
                _UnIcona(icona: i, aperta: widget.incontrata(i)),
            ],
          ),
        ],
      ),
    );
  }
}

class _UnIcona extends StatelessWidget {
  const _UnIcona({required this.icona, required this.aperta});
  final IconaDelProfilo icona;
  final bool aperta;

  @override
  Widget build(BuildContext context) => InkWell(
        key: Key('icona_${icona.codice}'),
        enableFeedback: false,
        customBorder: const CircleBorder(),
        onTap: aperta
            ? () => Navigator.of(context).pop(icona.codice)
            : () => ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(icona.daDoveSiApre))),
        child: Tooltip(
          message: aperta ? icona.nome : icona.daDoveSiApre,
          child: IconaTonda(icona: icona.codice, lato: 64, spenta: !aperta),
        ),
      );
}
