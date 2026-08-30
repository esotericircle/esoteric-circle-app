import 'riga_di_messa_a_punto.dart';
import 'package:flutter/material.dart';

import '../account/account_screen.dart';
import 'package:provider/provider.dart';

import '../../core/entitlement/entitlement_service.dart';
import '../../core/entitlement/plan_catalog.dart';
import '../../core/identity/profile_controller.dart';
import '../../core/settings/settings_controller.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/components/depth_card.dart';
import '../../design_system/components/section_title.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../services/app_services.dart';
import '../debug/app_check_debug_view.dart';
import '../pricing/pricing_screen.dart';
import '../../core/identity/dimenticanza_del_telefono.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';
import 'privacy_e_permessi_screen.dart';
import 'riga_interruttore.dart';

/// Schermata Impostazioni, in stile 2.5D e nella palette del Maestro attivo.
///
/// Sezioni: Aspetto (Riduci animazioni, Modalita' semplice), Voce e sottotitoli
/// (Sottotitoli, segnaposto in attesa della voce), Privacy e dati (Cancella i
/// miei dati, che chiama la cancellazione GDPR con una conferma di custodia),
/// Account (segnaposto). Freccia Indietro, mai un vicolo cieco.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static Route<void> route() => PassaggioDelCerchio.rotta<void>((_) => const MaestroScope(child: SettingsScreen()));

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final settings = context.watch<SettingsController>();

    return Scaffold(
      key: const Key('settings_screen'),
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: palette.deepest.withValues(alpha: 0.35),
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: palette.goldSoft),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Indietro',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text('Impostazioni', style: TypographyTokens.titoloDiSchermata()),
      ),
      body: CosmosBackground(
        seed: 16,
        showZodiac: false,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              SpacingTokens.lg,
              SpacingTokens.md,
              SpacingTokens.lg,
              SpacingTokens.xxxl,
            ),
            children: [
              const SectionTitle(
                title: 'Il tuo piano',
                subtitle: 'Quanto lontano portare il cammino.',
              ),
              const SizedBox(height: SpacingTokens.sm),
              DepthCard(
                raised: true,
                child: _PlanTile(palette: palette),
              ),
              const SizedBox(height: SpacingTokens.xl),

              const SectionTitle(
                title: 'Aspetto',
                subtitle: 'Come si muove e si mostra il cerchio.',
              ),
              const SizedBox(height: SpacingTokens.sm),
              DepthCard(
                raised: true,
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    RigaInterruttore(
                      itemKey: const Key('settings_reduce'),
                      icon: Icons.motion_photos_paused_rounded,
                      title: 'Riduci animazioni',
                      subtitle: 'Meno movimento e parallasse.',
                      value: settings.reduceAnimations,
                      onChanged: settings.setReduceAnimations,
                      palette: palette,
                    ),
                    _divider(palette),
                    RigaInterruttore(
                      itemKey: const Key('settings_simple'),
                      icon: Icons.blur_off_rounded,
                      title: 'Modalità semplice',
                      subtitle: 'Grafica alleggerita, più fluida.',
                      value: settings.simpleMode,
                      onChanged: settings.setSimpleMode,
                      palette: palette,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SpacingTokens.xl),

              const SectionTitle(
                title: 'Voce e sottotitoli',
                subtitle: 'La voce dei Maestri arriverà presto.',
              ),
              const SizedBox(height: SpacingTokens.sm),
              DepthCard(
                raised: true,
                padding: EdgeInsets.zero,
                child: RigaInterruttore(
                  itemKey: const Key('settings_subtitles'),
                  icon: Icons.subtitles_rounded,
                  title: 'Sottotitoli',
                  subtitle: 'Attivi di default, in attesa della voce.',
                  value: settings.subtitles,
                  onChanged: settings.setSubtitles,
                  palette: palette,
                ),
              ),
              const SizedBox(height: SpacingTokens.xl),

              const SectionTitle(
                title: 'Suono e vibrazione',
                subtitle: 'Il comando grande spegne tutto. Sotto, i soli '
                    'suoni.',
              ),
              const SizedBox(height: SpacingTokens.sm),
              DepthCard(
                raised: true,
                padding: EdgeInsets.zero,
                child: RigaInterruttore(
                  itemKey: const Key('settings_suono_vibrazione'),
                  icon: Icons.graphic_eq_rounded,
                  title: 'Suono e vibrazione',
                  subtitle: 'Governa insieme i suoni del Cerchio e le '
                      'vibrazioni. Chi vuole silenzio lo spegne una volta sola.',
                  value: settings.suonoEVibrazione,
                  onChanged: settings.setSuonoEVibrazione,
                  palette: palette,
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              // **SOLO GLI EFFETTI SONORI, ordine BX voce 05.** Il fondatore
              // ha chiesto un comando che spenga i suoni: quello sopra
              // spegne anche la vibrazione, che per chi tiene il telefono in
              // silenzio e\' l'unico canale che resta. Chi vuole il silenzio
              // senza perdere il tocco spegne questo.
              //
              // **Si spegne da solo quando l'interruttore unico e\' spento**,
              // perche\' li\' non c'e\' piu\' niente da decidere: mostrarlo
              // acceso sotto un comando gia\' spento direbbe il falso.
              DepthCard(
                raised: true,
                padding: EdgeInsets.zero,
                child: RigaInterruttore(
                  itemKey: const Key('settings_effetti_sonori'),
                  icon: Icons.music_note_rounded,
                  title: 'Effetti sonori',
                  subtitle: 'I suoni dei responsi, uno per Maestro. Spegnili '
                      'e la vibrazione resta.',
                  value: settings.suonoPermesso,
                  onChanged: settings.suonoEVibrazione
                      ? settings.setEffettiSonori
                      : null,
                  palette: palette,
                ),
              ),
              const SizedBox(height: SpacingTokens.xl),

              const SectionTitle(
                title: 'Privacy e dati',
                subtitle: 'Il tuo cammino è tuo.',
              ),
              const SizedBox(height: SpacingTokens.sm),
              // **TUTTO IL BLOCCO E' ANDATO IN UN SOTTO MENU'. Ordine CE voce
              // 03**, parole del fondatore: "ma tutto quel blocco di permessi
              // deve andare in un sotto menu' dedicato".
              //
              // Qui restano due righe sole: la porta del sotto menu' e la
              // cancellazione, che lui non ha chiesto di spostare e che e' la
              // cosa piu' grave che si possa fare da questa schermata.
              DepthCard(
                raised: true,
                child: InkWell(
                  key: const Key('settings_privacy_e_permessi'),
                  onTap: () => Navigator.of(context)
                      .push(PrivacyEPermessiScreen.route()),
                  child: Row(
                    children: [
                      Icon(Icons.shield_outlined,
                          color: palette.goldSoft, size: 22),
                      const SizedBox(width: SpacingTokens.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Privacy e permessi',
                                style: TypographyTokens.titoloDiRiga()),
                            const SizedBox(height: SpacingTokens.xxs),
                            Text(
                              'Cosa contiamo, da dove vengono i numeri e cosa '
                              'il Cerchio può toccare del telefono.',
                              style: TypographyTokens.corpo()
                                  .copyWith(color: ColorTokens.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: palette.goldSoft),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              DepthCard(
                raised: true,
                child: _DeleteDataTile(palette: palette),
              ),
              const SizedBox(height: SpacingTokens.xl),

              const SectionTitle(
                title: 'Account',
                subtitle: 'Accesso e profilo.',
              ),
              const SizedBox(height: SpacingTokens.sm),
              // **LA VOCE ACCOUNT SI ACCENDE.** Ordine AZ voce 11, che e' lo
              // stesso lavoro della voce 13 dell'ordine AX. Situazione S35
              // del censimento, e fatto F9 del fondatore: era spenta e
              // portava la pillola "Dietro il velo" mentre l'area account
              // esisteva gia' e funzionava. Un vicolo cieco davanti a una
              // porta aperta.
              DepthCard(
                raised: true,
                child: InkWell(
                  key: const Key('impostazioni_account'),
                  onTap: () =>
                      Navigator.of(context).push(AccountScreen.route()),
                  child: Row(
                    children: [
                      Icon(Icons.person_outline_rounded,
                          color: palette.goldSoft, size: 22),
                      const SizedBox(width: SpacingTokens.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Il tuo account',
                              style: TypographyTokens.titoloDiRiga(),
                            ),
                            Text(
                              'Profilo, accesso e dati di nascita',
                              style: TypographyTokens.didascalia()
                                  .copyWith(color: ColorTokens.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: ColorTokens.textSecondary, size: 22),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: SpacingTokens.xl),
              const SectionTitle(
                title: 'Messa a punto',
                subtitle: 'Cosa sta facendo il movimento del cielo, adesso.',
              ),
              const SizedBox(height: SpacingTokens.sm),
              const DepthCard(
                raised: true,
                child: RigaDiMessaAPunto(),
              ),

              // Ultime righe, solo nelle build di debug: il token di App Check
              // da registrare in console e il ripristino del Risveglio, che
              // serve a riprovare il rito senza svuotare i dati dell'app dalle
              // impostazioni di sistema. In release spariscono del tutto.
              const AppCheckDebugTokenRow(),
              const RipristinaRisveglioRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider(MaestroPalette palette) => Divider(
        height: 1,
        thickness: 1,
        indent: SpacingTokens.md,
        endIndent: SpacingTokens.md,
        color: palette.gold.withValues(alpha: 0.12),
      );
}

/// Riga di cancellazione dei dati, con conferma di custodia (mai punitiva).
class _DeleteDataTile extends StatelessWidget {
  const _DeleteDataTile({required this.palette});

  final MaestroPalette palette;

  Future<void> _confirmAndDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: palette.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
          side: BorderSide(color: palette.gold.withValues(alpha: 0.3)),
        ),
        title: Text('Cancellare i tuoi dati?',
            style: TypographyTokens.titoloDiSchermata()),
        content: Text(
          'Lasceremo andare tutto il tuo cammino: profilo, ricordi dei Maestri '
          'e conversazioni. Non è una perdita, è il tuo diritto. Il cerchio '
          'ti accoglierà di nuovo come il primo giorno.',
          style: TypographyTokens.corpo()
              .copyWith(color: ColorTokens.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('Resta',
                style:
                    TypographyTokens.corpo().copyWith(color: palette.goldSoft)),
          ),
          FilledButton(
            key: const Key('settings_delete_confirm'),
            style: FilledButton.styleFrom(
              backgroundColor: palette.gold,
              foregroundColor: palette.deepest,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Cancella i miei dati'),
          ),
        ],
      ),
    );

    if (ok != true || !context.mounted) return;
    final services = context.read<AppServices>();
    final profile = context.read<ProfileController>();
    try {
      // Le due meta' del diritto all'oblio, dentro lo stesso try: il ramo
      // remoto su Firestore, piu' tutto quel che sta sul telefono. Prima
      // partiva solo la prima, quindi nome, data, luogo e fotografia del volto
      // tornavano al riavvio, mentre la finestra prometteva il contrario.
      // **LE TRE META' DEL DIRITTO ALL'OBLIO. Ordine BZ voce 01.**
      //
      // Prima ce n'erano due, e mancava la piu' grande: il ramo remoto su
      // Firestore e il profilo sul telefono. Il profilo cancellava secondo
      // una lista sua, con sette prefissi, mentre la via dell'Account ne
      // usava dodici: **chi cancellava da qui si teneva il cammino, il
      // borsellino, i Sigilli, i sogni, le letture del viso e l'ingresso nel
      // Cerchio**, mentre questa finestra gli prometteva tutto il cammino.
      //
      // Adesso la dimenticanza del telefono e' la stessa delle altre vie e
      // legge la verita' unica: cio' che questa finestra promette e cio' che
      // succede sono la stessa cosa.
      // **LE TRE META' DEL DIRITTO ALL'OBLIO. Ordine BZ voce 01.**
      //
      // Prima ce n'erano due, e mancava la piu' grande: il ramo remoto su
      // Firestore e il profilo sul telefono. Il profilo cancellava secondo
      // una lista sua, con sette prefissi, mentre la via dell'Account ne
      // usava dodici: **chi cancellava da qui si teneva il cammino, il
      // borsellino, i Sigilli, i sogni, le letture del viso e l'ingresso nel
      // Cerchio**, mentre questa finestra gli prometteva tutto il cammino.
      //
      // Adesso la dimenticanza del telefono e' la stessa delle altre vie e
      // legge la verita' unica: cio' che questa finestra promette e cio' che
      // succede sono la stessa cosa.
      await services.memory.deleteAllData();
      await profile.forget();
      final quante = await DimenticanzaDelTelefono.dimentica();
      debugPrint('Oblio dalle Impostazioni: $quante spazi cancellati.');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fatto. Il cerchio riparte da capo, quando vorrai.'),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Non è stato possibile ora. Riprova più tardi.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: const Key('settings_delete'),
      borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
      onTap: () => _confirmAndDelete(context),
      child: Row(
        children: [
          Icon(Icons.delete_outline_rounded, color: palette.goldSoft, size: 22),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cancella i miei dati',
                    style: TypographyTokens.titoloDiRiga()),
                const SizedBox(height: 2),
                Text(
                  'Profilo, ricordi e conversazioni. Il tuo diritto all\'oblio.',
                  style: TypographyTokens.corpo()
                      .copyWith(color: ColorTokens.textSecondary),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: palette.goldSoft),
        ],
      ),
    );
  }
}

/// Riga dei permessi: riporta alle impostazioni di sistema dell'app.
///
/// Serve perche' un permesso negato una volta non si puo' richiedere di nuovo
/// dall'app: il sistema smette di mostrare la richiesta. Senza questa via, chi
/// aveva detto no al microfono restava senza soffio per sempre, senza sapere
/// dove rimediare.
/// Riga del piano attuale, con la via ai piani del Cerchio.
class _PlanTile extends StatelessWidget {
  const _PlanTile({required this.palette});

  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    final tier = context.watch<EntitlementService>().tier;
    final plan = PlanCatalog.forTier(tier);
    return InkWell(
      key: const Key('settings_plans'),
      borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
      onTap: () => Navigator.of(context).push(PricingScreen.route()),
      child: Row(
        children: [
          Icon(Icons.workspace_premium_outlined,
              color: palette.goldSoft, size: 22),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Piano ${plan.name}',
                    style: TypographyTokens.titoloDiRiga()),
                const SizedBox(height: 2),
                Text(
                  'Vedi i piani del Cerchio e cosa aprono.',
                  style: TypographyTokens.corpo()
                      .copyWith(color: ColorTokens.textSecondary),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: palette.goldSoft),
        ],
      ),
    );
  }
}
