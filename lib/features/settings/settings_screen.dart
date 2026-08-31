import 'riga_di_messa_a_punto.dart';
import 'package:flutter/material.dart';

import '../account/account_screen.dart';
import 'package:provider/provider.dart';

import '../../core/entitlement/entitlement_service.dart';
import '../../core/entitlement/plan_catalog.dart';
import '../../core/settings/settings_controller.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/components/depth_card.dart';
import '../../design_system/components/section_title.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../debug/app_check_debug_view.dart';
import '../pricing/pricing_screen.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';
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

              // **LA SEZIONE "PRIVACY E DATI" SE N'E' ANDATA NEL MENU'
              // UTENTE. Ordine CF voce 16.**
              //
              // **Richiesta del fondatore, verbatim**: "devi eliminare
              // dal menu' impostazioni 'privacy e permessi' [...] e deve
              // eliminare anche 'cancella i miei dati': questi devono
              // esistere al massimo in un unico posto e cioe' nel menu'
              // utente in un sotto menu'."
              //
              // **Il doppione era reale**: il menu' utente ha gia' una voce
              // "Privacy e dati" con dentro la policy, lo scarico e le due
              // cancellazioni, e questa sezione si chiamava allo stesso
              // modo e portava la stessa identica icona.
              //
              // **Niente e' andato perso, e due cose erano di legge.**
              // "Privacy e permessi" vive adesso dentro quel sotto menu',
              // con dentro l'attribuzione delle fonti, che la licenza
              // CC BY 4.0 del catalogo delle citta' pretende raggiungibile,
              // e l'interruttore della misura, che e' la via con cui si
              // revoca il consenso. La cancellazione dei dati vive nello
              // stesso sotto menu', in due gradi: il cammino che riparte e
              // l'account che sparisce.
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
