import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/diagnosi/racconto_della_corsa.dart';
import 'core/archetypes/archetype_history.dart';
import 'core/astro/natal_chart_controller.dart';
import 'core/astro/zodiac_controller.dart';
import 'core/entitlement/entitlement_service.dart';
import 'core/entitlement/question_allowance.dart';
import 'core/feature_flags/feature_flag_service.dart';
import 'core/identity/identity_controller.dart';
import 'core/identity/natal_identity.dart';
import 'core/identity/profile_controller.dart';
import 'core/maestro/maestro_controller.dart';
import 'core/motion/parallax_controller.dart';
import 'core/onboarding/onboarding_controller.dart';
import 'core/quality/quality_tier.dart';
import 'core/settings/settings_controller.dart';
import 'core/arts/arti_preferite.dart';
import 'core/sensi/guardia_del_suono.dart';
import 'core/sensi/motore_audio.dart';
import 'design_system/theme/app_theme.dart';
import 'design_system/theme/maestro_scope.dart';
import 'features/debug/app_check_debug_view.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/santuario/greeting_controller.dart';
import 'features/shell/app_shell.dart';
import 'features/shell/barra_del_cerchio.dart';
import 'features/shell/navigation_controller.dart';
import 'services/app_services.dart';
import 'features/intro/sequenza_intro.dart';

/// Radice dell'app: registra i servizi condivisi e monta lo shell.
///
/// Ordine dei provider: prima i servizi a runtime (AI e memoria) e quelli di
/// base (Maestro attivo, entitlement, qualita'), poi quelli che dipendono da
/// essi (navigazione, feature flag).
class EsotericCircleApp extends StatefulWidget {
  const EsotericCircleApp({
    super.key,
    this.services,
    this.clock,
    this.conIntro = true,
  });

  /// Se l'intro di apertura va mostrata.
  ///
  /// Le prove e le anteprime la spengono: un'intro davanti a tutto sarebbe
  /// davanti anche a loro, e misurerebbero il nero invece della schermata. E'
  /// la stessa ragione per cui la sorgente di posizione nasce spenta.
  final bool conIntro;

  /// Servizi a runtime montati all'avvio. Se assenti (test, anteprima) si usa
  /// una configurazione offline che non tocca la rete.
  final AppServices? services;

  /// Orologio iniettabile per i test, inoltrato fino al Santuario per fissare la
  /// fascia oraria attiva. Di default l'ora locale del dispositivo.
  final DateTime Function()? clock;

  @override
  State<EsotericCircleApp> createState() => _EsotericCircleAppState();
}

class _EsotericCircleAppState extends State<EsotericCircleApp> {
  /// L'osservatore della pila, uno per app: lo legge il Navigator e lo legge
  /// la barra, ed e' lo stesso oggetto.
  final OsservatoreDellaPila _pila = OsservatoreDellaPila();

  _EsotericCircleAppState() {
    // La regola contro il doppione legge la stessa pila che tiene la barra.
    // Senza questa riga `apriUnaVoltaSola` non trovava nessuna pila e spingeva
    // sempre: la regola c'era nel codice e non scattava mai nell'app.
    NavigazioneDellaBarra.osservatore = _pila;
  }

  /// LA GUARDIA DEL SUONO, montata nel guscio e non in una schermata.
  ///
  /// Le porte sono tutte le schermate che suonano, oggi due e domani dieci: una
  /// regola messa dentro la Meditazione varrebbe per la sola Meditazione. Qui
  /// vale per tutte, comprese quelle che non esistono ancora.
  late final GuardiaDelSuono _guardia;

  @override
  void initState() {
    super.initState();
    _guardia = GuardiaDelSuono(motore: MotoreAudio.condiviso)..avvia();
  }

  @override
  void dispose() {
    _guardia.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final services = widget.services;
    final clock = widget.clock;
    final runtime = services ?? AppServices.offline();
    return MultiProvider(
      providers: [
        Provider<AppServices>.value(value: runtime),
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ProfileController()..load()),
        // Sottosistema della Carta Natale: identita' (nome e forma), motore del
        // calcolo e fatti derivati. Alimentati dal Risveglio come fonte unica.
        ChangeNotifierProvider(create: (_) => IdentityController()),
        ChangeNotifierProvider(create: (_) => NatalChartController()),
        // I dati di nascita SEGUONO IL PROFILO, che e' l'unico posto dove sono
        // persistiti. Prima questo controller si riempiva in un solo punto,
        // alla fine del Risveglio, e viveva solo in memoria: chi riapriva l'app
        // lo trovava vuoto, quindi l'app dichiarava mancante un'ora che era
        // stata data, e la carta natale partiva senza luogo, che il client
        // rifiuta prima ancora di chiamare la rete. Una causa sola per due
        // difetti che sembravano distinti.
        ChangeNotifierProxyProvider<ProfileController, BirthIdentityController>(
          create: (_) => BirthIdentityController(),
          update: (_, profilo, nascita) =>
              (nascita ?? BirthIdentityController())
                ..riprendiDa(profilo.identity)
                // E LA CARTA CONSERVATA, che e' l'altra meta': `riprendiDa`
                // riporta cio' che la persona ha dato, questa riporta il
                // cielo che ne discende. Senza, l'app riapriva sapendo chi
                // sei e non sapendo piu' il tuo cielo, e lo dichiarava come
                // se non gliel'avessi mai detto. Voce 60 del Registro.
                ..riprendiLaCarta(),
        ),
        ChangeNotifierProvider(create: (_) => EntitlementService()),
        ChangeNotifierProvider(create: (_) => QuestionAllowance()..load()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        // LO STORICO DEL TEST ARCHETIPO, DALL'AVVIO, E PER TUTTA L'APP.
        //
        // **Perche' e' salito quassu'.** Ogni schermata che ne aveva bisogno se
        // ne costruiva uno suo e lo caricava per conto proprio: il Test, la
        // pagina dell'Animale Guida. Chi non lo faceva non sapeva niente
        // dell'archetipo, e infatti nel Passaporto la tessera dell'Archetipo
        // restava col lucchetto anche a test completato, perche' guardava una
        // lista fissa invece che questo dato. Adesso il dato e' uno, arriva
        // dall'avvio, e ci si affacciano tutte le porte che lo chiedono: il
        // Passaporto, il simbolo di Aura nell'attesa della chat, e il Test.
        ChangeNotifierProvider(create: (_) => ArchetypeHistory()..carica()),
        ChangeNotifierProvider(create: (_) => SettingsController()..load()),
        ChangeNotifierProvider(
          create: (ctx) =>
              NavigationController(ctx.read<MaestroController>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => FeatureFlagService(
            entitlement: ctx.read<EntitlementService>(),
          )..initialize(),
        ),
        ChangeNotifierProvider(create: (_) => GreetingController()),
        ChangeNotifierProvider(create: (_) => OnboardingController()..load()),
        // Lo scaffale personale "Le tue arti". Nasce abitato: il seme lo
        // decide il dato, non la schermata, quindi non c'e' modo di arrivare
        // a uno scaffale vuoto. Nessun controllo di piano lo tocca.
        // Lo scaffale SEGUE IL MAESTRO. `setMaestro` non era chiamato da
        // nessuno in tutto il progetto, quindi allo scaffale arrivava sempre un
        // Maestro nullo e il seme era quello del caso senza Maestro: tre arti
        // in croce, mentre la home diceva "Entra nel Dominio di Aura". Il
        // Maestro esisteva, allo scaffale non ci arrivava.
        ChangeNotifierProxyProvider<MaestroController, ArtiPreferiteController>(
          create: (_) => ArtiPreferiteController()..carica(),
          update: (_, maestri, scaffale) {
            final s = scaffale ?? (ArtiPreferiteController()..carica());
            final m = maestri.activeMaestro;
            if (m != null) s.setMaestro(m);
            return s;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Esoteric Circle',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        // L'osservatore della pila: tiene le rotte vive, che servono sia a
        // sapere quale schermata e' in cima sia alla regola contro il doppione.
        // E' UN DATO SOLO, montato qui e passato alla barra: due copie della
        // pila divergerebbero al primo pop.
        navigatorObservers: [_pila],
        // La striscia col token di debug di App Check sta sopra il Navigator,
        // quindi si legge anche mentre l'onboarding e' aperto sopra lo shell.
        // In release non compare: lo decidono i servizi, non questa riga.
        //
        // QUI STA ANCHE L'INTRO, e ci sta per una ragione che ho imparato
        // sbagliando: era dentro `home`, cioe' dentro la ROUTE INIZIALE, e il
        // Risveglio non e' un ramo dell'albero, e' un `push`. Un push mette una
        // route SOPRA, quindi copriva l'intro: si sentiva la voce e si vedeva
        // il Risveglio, perche' l'intro era viva e sepolta. Il builder avvolge
        // il Navigator intero, quindi sta davvero davanti a tutto, comprese le
        // schermate che verranno spinte sopra domani.
        builder: (context, child) => AppCheckDebugBanner(
          child: Consumer<SettingsController>(
            builder: (context, settings, _) {
              // Modalita' semplice: abbassa la qualita' grafica. Applicata
              // fuori dal build per non scrivere stato durante la costruzione.
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final q = context.read<QualityTierController>();
                final target =
                    settings.simpleMode ? QualityTier.low : QualityTier.high;
                if (q.tier != target) q.setTier(target);
              });
              // Riduci animazioni: si riversa su disableAnimations, cosi' tutto
              // il codice che rispetta Riduci Movimento lo onora. Da qui vale
              // anche per le route spinte sopra, che prima ne restavano fuori.
              final mq = MediaQuery.of(context);
              return MediaQuery(
                data: mq.copyWith(
                  disableAnimations:
                      mq.disableAnimations || settings.reduceAnimations,
                ),
                // LA BARRA STA QUI, e ci sta per la stessa ragione dell'intro:
                // il builder avvolge il Navigator INTERO, quindi vede anche le
                // rotte spinte sopra il guscio, comprese le chat e i domini,
                // che hanno un proprio Scaffold. Dentro `home`, cioe' dentro
                // `AppShell`, vedeva solo le due viste del guscio, ed e' il
                // motivo per cui ne serviva una seconda. E' il solo punto che
                // decide dove la barra si vede: le schermate non lo sanno e non
                // lo devono sapere.
                // IL RACCONTO DELLA DIAGNOSI sta SOPRA l'intro: l'app muore
                // anche durante l'intro, e la briciola della corsa prima si
                // deve leggere comunque. Fuori diagnosi e' trasparente.
                child: RaccontoDellaCorsa(
                    child: SequenzaIntro(
                  mostra: widget.conIntro,
                  // Il silenzio dell'app vale anche per l'apertura. Passa da
                  // qui e non si legge dentro l'intro perche' l'intro e' gia'
                  // dentro questo Consumer: farglielo cercare da sola
                  // vorrebbe dire una seconda porta sullo stesso dato.
                  conSuono: settings.suonoEVibrazione,
                  child: BarraDelCerchio(
                    observatore: _pila,
                    child: child ?? const SizedBox.shrink(),
                  ),
                )),
              );
            },
          ),
        ),
        // La dissolvenza cromatica del tema riguarda lo sfondo e gli accenti,
        // gestiti da MaestroScope; qui teniamo un solo ThemeData scuro base.
        //
        // LA DESTINAZIONE STA SEMPRE SOTTO, gia' costruita: l'intro non decide
        // dove si va, ritarda solo il momento in cui si vede.
        home: _OnboardingLauncher(
          child: MaestroScope(child: AppShell(clock: clock)),
        ),
      ),
    );
  }
}

/// Al primo avvio spinge "Il Risveglio" sopra il Santuario, una volta sola; le
/// aperture successive restano dirette al Santuario. La home resta comunque lo
/// shell, cosi' l'onboarding e' una soglia che si apre e si chiude, non un ramo
/// separato dell'albero.
class _OnboardingLauncher extends StatefulWidget {
  const _OnboardingLauncher({required this.child});

  final Widget child;

  @override
  State<_OnboardingLauncher> createState() => _OnboardingLauncherState();
}

class _OnboardingLauncherState extends State<_OnboardingLauncher> {
  bool _handled = false;

  @override
  Widget build(BuildContext context) {
    final onboarding = context.watch<OnboardingController>();
    if (!_handled && onboarding.resolved && onboarding.needsOnboarding) {
      _handled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).push(OnboardingScreen.route());
      });
    }
    return widget.child;
  }
}
