import 'package:flutter/material.dart';
import '../../design_system/components/la_conferma_della_spesa.dart';
import 'package:provider/provider.dart';

import '../../core/cerchio/i_segni_del_cerchio.dart';
import '../../core/cerchio/il_cerchio_sociale.dart';
import '../../core/cerchio/il_glifo_del_legame.dart';
import '../../core/astro/zodiac.dart';
import '../../core/entitlement/listino_degli_eos.dart';
import '../../core/feature_flags/feature_flag.dart';
import '../../core/identity/profile_controller.dart';
import '../../core/maestro/maestro.dart';
import '../../core/maestro/maestro_controller.dart';
import '../../design_system/components/borsellino.dart';
import '../../design_system/components/icona_degli_eos.dart';
import '../../design_system/components/status_badge.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';
import '../../design_system/transizioni/velo_del_cerchio.dart';
import 'confronto_del_cielo_screen.dart';
import 'widgets/disegni_del_cerchio.dart';

/// **LA SCHEDA DELL'AMICO, ordine EY.** Il suo profilo nel Cerchio, il glifo
/// del vostro legame, i segni da mandargli, i doni, il confronto del cielo,
/// e il pannello Fonti e metodo, dove il glifo si dichiara un segno del
/// Cerchio e non un sigillo tradizionale.
class SchedaDellAmicoScreen extends StatelessWidget {
  const SchedaDellAmicoScreen({super.key, required this.amico});

  final PersonaDelCerchio amico;

  static Route<void> route(PersonaDelCerchio amico) =>
      PassaggioDelCerchio.rotta<void>((_) => MaestroScope(
          maestro: amico.maestro, child: SchedaDellAmicoScreen(amico: amico)));

  Future<void> _segno(BuildContext context, SegnoDelCerchio s) async {
    final esito =
        await context.read<IlCerchioSociale>().mandaUnSegno(amico.uid, s.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(esito.ok
            ? 'Il tuo segno è partito: «${s.testo}».'
            : (esito.riga ?? EsitoDelGesto.silenzio.riga!))));
  }

  Future<void> _dono(BuildContext context, Dono d) async {
    final voce = switch (d) {
      Dono.cenno => null,
      Dono.scintilla => ListinoDegliEos.scintilla,
      Dono.sigillo => ListinoDegliEos.sigilloDaDonare,
    };
    // **IL PREZZO SI DICHIARA PRIMA DEL GESTO**, e viene dal listino. Il
    // cenno e' gratuito; per gli altri la conferma unica della spesa, ordine
    // FD voce 01: il dialogo proprio del dono e' stato tolto.
    final sociale = context.read<IlCerchioSociale>();
    final EsitoDelGesto esito;
    if (voce == null) {
      esito = await sociale.mandaUnCenno(amico.uid);
    } else {
      final consenso =
          await LaConfermaDellaSpesa.degliEos(context, costo: voce.costo);
      if (consenso == null || !context.mounted) return;
      esito = await sociale.mandaUnDono(amico.uid, d.name, consenso: consenso);
    }
    if (!context.mounted) return;
    final manca = esito.dati['manca'];
    if (!esito.ok && manca is num) {
      // **QUANDO GLI EOS NON BASTANO SI VA AL BORSELLINO**, con la riga che
      // dice quanto manca.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Mancano ${manca.toInt()} Eos per ${d.nome.toLowerCase()}.')));
      await PortafoglioDelCerchio.apri(context);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(esito.ok
            ? '${d.nome} è arrivato a ${amico.nome}.'
            : (esito.riga ?? EsitoDelGesto.silenzio.riga!))));
  }

  Future<void> _regala(BuildContext context) async {
    var quanti = 100.0;
    final scelto = await foglioDelCerchio<int>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (c) => StatefulBuilder(
        builder: (c, aggiorna) => fondoDelFoglio(
          c,
          Padding(
            padding: const EdgeInsets.all(SpacingTokens.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Regala Eos a ${amico.nome}',
                    style: TypographyTokens.titoloScheda()
                        .copyWith(color: MaestroPalette.neutral.goldSoft)),
                const SizedBox(height: SpacingTokens.xs),
                Text(
                    'Da cento a cinquecento al giorno, solo dagli Eos comprati '
                    'o dalla dote del piano: quelli guadagnati nel Cammino '
                    'restano tuoi.',
                    textAlign: TextAlign.center,
                    style: TypographyTokens.didascalia()
                        .copyWith(color: ColorTokens.textSecondary)),
                Slider(
                  key: const Key('regala_quanti'),
                  min: 100,
                  max: 500,
                  divisions: 8,
                  value: quanti,
                  label: '${quanti.round()} Eos',
                  onChanged: (v) => aggiorna(() => quanti = v),
                ),
                FilledButton(
                  key: const Key('regala_conferma'),
                  onPressed: () => Navigator.of(c).pop(quanti.round()),
                  child: Text('Regala ${quanti.round()} Eos'),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                      foregroundColor: MaestroPalette.neutral.goldSoft),
                  onPressed: () => Navigator.of(c).pop(),
                  child: const Text('Fatto'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (scelto == null || !context.mounted) return;
    // Il foglio sceglie quanto; la conferma unica dice costo e saldo, ordine
    // FD voce 01.
    final consenso =
        await LaConfermaDellaSpesa.degliEos(context, costo: scelto);
    if (consenso == null || !context.mounted) return;
    final esito = await context
        .read<IlCerchioSociale>()
        .regalaGliEos(amico.uid, scelto, consenso: consenso);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(esito.ok
            ? 'Hai regalato $scelto Eos a ${amico.nome}.'
            : (esito.riga ?? EsitoDelGesto.silenzio.riga!))));
  }

  Future<void> _togliOBlocca(BuildContext context, String cosa) async {
    final sociale = context.read<IlCerchioSociale>();
    final navigatore = Navigator.of(context);
    final si = await dialogoDelCerchio<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: MaestroPalette.neutral.surfaceElevated,
        content: Text(cosa == 'blocca'
            ? 'Blocchi ${amico.nome}? Non ti vedrà, non potrà invitarti né '
                'mandarti niente e il Cerchio non glielo dirà. Lo sblocchi '
                'quando vuoi dal tuo profilo.'
            : 'Togli ${amico.nome} dal tuo Cerchio?'),
        actions: [
          TextButton(
              style: TextButton.styleFrom(
                  foregroundColor: MaestroPalette.neutral.goldSoft),
              onPressed: () => Navigator.of(c).pop(false),
              child: const Text('Non ora')),
          FilledButton(
              key: Key('conferma_$cosa'),
              onPressed: () => Navigator.of(c).pop(true),
              child: Text(cosa == 'blocca' ? 'Blocca' : 'Togli')),
        ],
      ),
    );
    if (si != true) return;
    if (cosa == 'blocca') {
      await sociale.blocca(amico.uid);
    } else {
      await sociale.rispondiAlLegame(amico.uid, 'togli');
    }
    navigatore.pop();
  }

  @override
  Widget build(BuildContext context) {
    final palette = paletteDi(amico.maestro);
    final sociale = context.watch<IlCerchioSociale>();
    final mio = sociale.profilo;
    // I tratti accesi li dice il server; la scheda si aggiorna col Cerchio.
    final aggiornato =
        sociale.cerchio.amici.where((p) => p.uid == amico.uid).firstOrNull ??
            amico;
    final glifo = IlGlifoDelLegame.di(mio?.sigillo ?? '', _mioSegno(context),
        amico.sigillo ?? '', amico.segno);
    return conIPulsantiDOro(
        context,
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: palette.goldSoft),
            actions: [
              PopupMenuButton<String>(
                key: const Key('amico_menu'),
                iconColor: palette.goldSoft,
                onSelected: (v) => _togliOBlocca(context, v),
                itemBuilder: (_) => const [
                  PopupMenuItem(
                      value: 'togli', child: Text('Togli dal Cerchio')),
                  PopupMenuItem(value: 'blocca', child: Text('Blocca')),
                ],
              ),
            ],
          ),
          body: ListView(
            key: const Key('scheda_amico'),
            padding: const EdgeInsets.fromLTRB(
                SpacingTokens.md, 0, SpacingTokens.md, SpacingTokens.xl),
            children: [
              Center(child: IconaTonda(icona: amico.icona, lato: 104)),
              const SizedBox(height: SpacingTokens.sm),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Flexible(
                  child: Text(amico.nome,
                      textAlign: TextAlign.center,
                      style: TypographyTokens.cerimoniale()
                          .copyWith(color: palette.goldSoft)),
                ),
                const SizedBox(width: SpacingTokens.xs),
                const Semaforino(semaforo: Semaforo.verde),
              ]),
              Text(
                [
                  if (amico.segno != null) amico.segno!.italianName,
                  if (amico.maestro != null) 'con ${amico.maestro!.nomeAVideo}',
                  if (amico.sigillo != null && amico.sigillo!.isNotEmpty)
                    'sigillo ${amico.sigillo}',
                ].join(', '),
                textAlign: TextAlign.center,
                style: TypographyTokens.didascalia()
                    .copyWith(color: ColorTokens.textSecondary),
              ),
              const SizedBox(height: SpacingTokens.lg),
              // IL GLIFO DEL LEGAME, che si accende un tratto per ogni giorno di
              // scambio: il colpo d'occhio della scheda.
              Center(
                child: SizedBox(
                  key: const Key('glifo_del_legame'),
                  width: 150,
                  height: 150,
                  child: CustomPaint(
                    painter: PittoreDelGlifo(
                      glifo: glifo,
                      accesi: aggiornato.tratti,
                      colore: palette.goldSoft,
                      spento: palette.gold.withValues(alpha: 0.22),
                    ),
                  ),
                ),
              ),
              Text(
                '${aggiornato.tratti.clamp(0, IlGlifoDelLegame.quantiTratti)} '
                'tratti accesi su ${IlGlifoDelLegame.quantiTratti}',
                textAlign: TextAlign.center,
                style: TypographyTokens.didascalia()
                    .copyWith(color: ColorTokens.textSecondary),
              ),
              const SizedBox(height: SpacingTokens.lg),
              FilledButton.icon(
                key: const Key('amico_confronto'),
                style: FilledButton.styleFrom(
                  backgroundColor: palette.gold,
                  foregroundColor: palette.onPrimary,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () => Navigator.of(context)
                    .push(ConfrontoDelCieloScreen.route(amico)),
                icon: const Icon(Icons.auto_awesome),
                label: Text('Confronta i cieli di oggi',
                    style: TypographyTokens.etichetta()),
              ),
              for (final cat in CategoriaDelSegno.values) ...[
                Padding(
                  padding: const EdgeInsets.only(
                      top: SpacingTokens.lg, bottom: SpacingTokens.xs),
                  child: Text(cat.titolo.toUpperCase(),
                      style: TypographyTokens.etichetta().copyWith(
                          color: palette.goldSoft, letterSpacing: 1.4)),
                ),
                // DUE COLONNE E NON TRE: a tre le parole lunghe dei segni si
                // spezzavano a meta' ("Confrontiam / o"), visto nell'anteprima.
                LayoutBuilder(
                  builder: (context, vincoli) => Wrap(
                    spacing: SpacingTokens.xs,
                    runSpacing: SpacingTokens.xs,
                    children: [
                      for (final s in ISegniDelCerchio.di(cat))
                        SizedBox(
                          width: (vincoli.maxWidth - SpacingTokens.xs) / 2,
                          child: _BottoneDelSegno(
                            segno: s,
                            maestro: _mioMaestro(context),
                            onTap: () => _segno(context, s),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.only(top: SpacingTokens.xs),
                child: Text(
                  'Oggi hai mandato ${sociale.cerchio.segniOggi} segni su '
                  '${sociale.cerchio.segniAlGiorno}. I segni non si comprano e non '
                  'fanno guadagnare Eos.',
                  style: TypographyTokens.didascalia()
                      .copyWith(color: ColorTokens.textSecondary),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: SpacingTokens.lg, bottom: SpacingTokens.xs),
                child: Text('UN DONO',
                    style: TypographyTokens.etichetta()
                        .copyWith(color: palette.goldSoft, letterSpacing: 1.4)),
              ),
              Row(
                children: [
                  for (final d in Dono.values)
                    Expanded(
                      child: InkWell(
                        key: Key('dono_${d.name}'),
                        enableFeedback: false,
                        onTap: () => _dono(context, d),
                        child: Column(children: [
                          DisegnoDelDono(dono: d, maestro: amico.maestro),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(d.nome,
                                maxLines: 1,
                                style: TypographyTokens.etichetta()
                                    .copyWith(color: palette.goldSoft)),
                          ),
                          // IL PREZZO COL SEGNO DEGLI EOS, dal listino: il
                          // denaro del Cerchio ha un'icona sua.
                          if (d == Dono.cenno)
                            Text('Gratuito',
                                style: TypographyTokens.didascalia()
                                    .copyWith(color: ColorTokens.textSecondary))
                          else
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconaDegliEos(
                                    misura: 14, colore: palette.goldSoft),
                                const SizedBox(width: SpacingTokens.xxs),
                                Text(
                                    '${d == Dono.scintilla ? ListinoDegliEos.scintilla.costo : ListinoDegliEos.sigilloDaDonare.costo}',
                                    key: Key('prezzo_${d.name}'),
                                    style: TypographyTokens.didascalia()
                                        .copyWith(
                                            color: ColorTokens.textSecondary)),
                              ],
                            ),
                        ]),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: SpacingTokens.md),
              if (IlCerchioSociale.ilGiftEosEAperto)
                OutlinedButton(
                  key: const Key('amico_regala_eos'),
                  onPressed: () => _regala(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    side:
                        BorderSide(color: palette.gold.withValues(alpha: 0.5)),
                  ),
                  child: Text('Regala Eos',
                      style: TypographyTokens.etichetta()
                          .copyWith(color: palette.goldSoft)),
                )
              else
                // **DICHIARATO, NON SPENTO A META'**, ordine EZ voce 05: la
                // voce si vede, dice da cosa si apre, e nessun tocco prova a
                // spendere.
                Opacity(
                  key: const Key('amico_regala_eos_dietro_il_velo'),
                  opacity: 0.72,
                  child: Container(
                    padding: const EdgeInsets.all(SpacingTokens.sm),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(SpacingTokens.radiusMd),
                      border: Border.all(
                          color: palette.gold.withValues(alpha: 0.35)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text('Regala Eos',
                                  style: TypographyTokens.etichetta()
                                      .copyWith(color: palette.goldSoft)),
                            ),
                            const StatusBadge(status: FeatureStatus.comingSoon),
                          ],
                        ),
                        const SizedBox(height: SpacingTokens.xxs),
                        Text(IlCerchioSociale.rigaDelGiftEos,
                            key: const Key('amico_regala_eos_riga'),
                            style: TypographyTokens.didascalia()
                                .copyWith(color: ColorTokens.textSecondary)),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: SpacingTokens.lg),
              // IL PANNELLO FONTI E METODO: qui, e mai accanto all'elenco delle
              // fonti di un'arte, il glifo si dichiara un segno del Cerchio.
              ExpansionTile(
                key: const Key('amico_fonti_e_metodo'),
                collapsedIconColor: palette.goldSoft,
                iconColor: palette.goldSoft,
                title: Text('Fonti e metodo',
                    style: TypographyTokens.titoloDiRiga()
                        .copyWith(color: palette.goldSoft)),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(SpacingTokens.sm),
                    child: Text(IlGlifoDelLegame.rigaDelMetodo,
                        style: TypographyTokens.corpo().copyWith(
                            color: ColorTokens.textPrimary, height: 1.45)),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}

/// Il segno solare di chi guarda, dalla sua nascita: mai la data al server.
Zodiac? _mioSegno(BuildContext context) {
  try {
    final id = context.read<ProfileController>().identity;
    return id.isExample ? null : id.sunSign;
  } catch (senzaQuelDato) {
    // Il dato e' facoltativo: senza, si va avanti col ripiego.
    return null;
  }
}

/// Il Maestro di chi manda il segno: il segno arriva nella sua palette.
Maestro? _mioMaestro(BuildContext context) {
  try {
    return context.read<MaestroController>().activeMaestro;
  } catch (senzaQuelDato) {
    // Il dato e' facoltativo: senza, si va avanti col ripiego.
    return null;
  }
}

class _BottoneDelSegno extends StatelessWidget {
  const _BottoneDelSegno(
      {required this.segno, required this.maestro, required this.onTap});

  final SegnoDelCerchio segno;
  final Maestro? maestro;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const palette = MaestroPalette.neutral;
    return InkWell(
      key: Key('manda_${segno.id}'),
      enableFeedback: false,
      borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(SpacingTokens.xs),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
          color: palette.surfaceElevated.withValues(alpha: 0.7),
          border: Border.all(color: palette.gold.withValues(alpha: 0.3)),
        ),
        child: Column(children: [
          DisegnoDelSegno(motivo: segno.motivo, maestro: maestro, lato: 48),
          const SizedBox(height: SpacingTokens.xxs),
          Text(segno.testo,
              textAlign: TextAlign.center,
              maxLines: 3,
              style: TypographyTokens.didascalia()
                  .copyWith(color: ColorTokens.textPrimary)),
        ]),
      ),
    );
  }
}
