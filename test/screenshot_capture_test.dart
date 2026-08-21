import 'package:esoteric_circle/core/responsi/anatomia_del_responso.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' show Random;
import 'dart:ui' as ui;

import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/angels/angel_catalog.dart';
import 'package:esoteric_circle/core/assets/family_image.dart';
import 'package:esoteric_circle/core/astro/moon_phase.dart';
import 'package:esoteric_circle/core/astro/night_sky.dart';
import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/immersive_intents.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/features/maestri/chat/widgets/chat_composer.dart';
import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:esoteric_circle/core/astro/birth_place.dart' as astro;
import 'package:esoteric_circle/core/astro/natal_chart_controller.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/identity/identity_controller.dart';
import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/design_system/components/natal_wheel.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/features/account/profile_screen.dart';
import 'package:esoteric_circle/core/archetypes/archetype.dart';
import 'package:esoteric_circle/core/archetypes/archetype_history.dart';
import 'package:esoteric_circle/core/archetypes/archetype_scoring.dart';
import 'package:esoteric_circle/core/face/face_classifier.dart';
import 'package:esoteric_circle/features/maestri/aura/archetype/archetype_share_card.dart';
import 'package:esoteric_circle/features/maestri/aura/face/face_constellation.dart';
import 'package:esoteric_circle/core/rituals/guide_animal_derivation.dart';
import 'package:esoteric_circle/features/maestri/aura/face/face_constellation_screen.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/rituals/rune_presage.dart';
import 'package:esoteric_circle/core/rituals/runes.dart';
import 'package:esoteric_circle/features/maestri/caligo/animal/guide_animal_screen.dart';
import 'package:esoteric_circle/features/maestri/caligo/animal/guide_animal_share_card.dart';
import 'package:esoteric_circle/features/maestri/caligo/rune/rune_draw_screen.dart';
import 'package:esoteric_circle/features/maestri/caligo/rune/rune_share_card.dart';
import 'package:esoteric_circle/features/maestri/chat/chat_openers.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_screen.dart';
import 'package:esoteric_circle/features/passport/cosmic_passport_screen.dart';
import 'package:esoteric_circle/features/maestri/aura/face/face_share_card.dart';
import 'package:esoteric_circle/features/maestri/aura/face/face_silhouette.dart';
import 'package:esoteric_circle/core/maestro/frase_di_ripiego.dart';
import 'package:esoteric_circle/core/maestro/consiglio_finale.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/features/maestri/widgets/maestro_bust.dart';
import 'package:esoteric_circle/features/santuario/widgets/maestro_bust.dart'
    as santuario;
import 'package:esoteric_circle/design_system/components/consulto_del_cielo_view.dart';
import 'package:esoteric_circle/core/maestro/tempi_dell_attesa.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/onboarding/onboarding_controller.dart';
import 'package:esoteric_circle/design_system/components/loto_dorato.dart';
import 'package:esoteric_circle/core/rituals/daily_rituals.dart';
import 'package:esoteric_circle/core/rituals/dream_rite_corpus.dart';
import 'package:esoteric_circle/design_system/components/zodiac_figures.dart';
import 'package:esoteric_circle/features/rituals/dream_rite_card.dart';
import 'package:esoteric_circle/features/rituals/dream_rite_screen.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/components/immersive_scaffold.dart';
import 'package:esoteric_circle/features/identity/circle_seal_screen.dart';
import 'package:esoteric_circle/features/maestri/caligo/sigillo/sigillo_intenzione_screen.dart';
import 'package:esoteric_circle/features/santuario/sky_overview_screen.dart';
import 'package:esoteric_circle/features/onboarding/natal_chart_reveal.dart';
import 'package:esoteric_circle/core/cammino/cammino_da_custodire.dart';
import 'package:esoteric_circle/core/cammino/ritrovamento.dart';
import 'package:esoteric_circle/features/onboarding/scena_del_ritrovamento.dart';
import 'package:esoteric_circle/features/onboarding/custodia_del_cielo_step.dart';
import 'package:esoteric_circle/core/identity/account_del_cerchio.dart';
import 'package:esoteric_circle/features/shell/barra_dell_identita.dart';
import 'package:esoteric_circle/features/onboarding/onboarding_screen.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/rituals/breath_destiny_screen.dart';
import 'package:esoteric_circle/core/rituals/avvisi_del_rito.dart';
import 'package:esoteric_circle/features/rituals/dawn_rite_screen.dart';
import 'package:esoteric_circle/features/rituals/day_oracle_screen.dart';
import 'package:esoteric_circle/core/rituals/sunset_rune.dart';
import 'package:esoteric_circle/features/rituals/sunset_rune_screen.dart';
import 'package:esoteric_circle/features/santuario/sky_postcard.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/horoscope/cielo_di_oggi.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/design_system/components/zodiac_glyph.dart';
import 'package:esoteric_circle/core/synastry/vip_catalog.dart';
import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/features/sigilli/sentiero_screen.dart';
import 'package:esoteric_circle/features/tarot/stesa_share_card.dart';
import 'package:esoteric_circle/features/tarot/stesa_reveal.dart';
import 'package:esoteric_circle/features/tarot/tarot_card_art.dart';
import 'package:esoteric_circle/features/maestri/widgets/busto_del_maestro.dart';
import 'package:esoteric_circle/features/tarot/attesa_di_medora.dart';
import 'package:esoteric_circle/features/tarot/stesa_choreography.dart';
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_share_card.dart';
import 'package:esoteric_circle/features/synastry/sinastria_gallery_screen.dart';
import 'package:esoteric_circle/features/synastry/sinastria_vip_screen.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:esoteric_circle/core/rituals/daily_elements.dart';
import 'package:esoteric_circle/features/maestri/ask/ask_maestri_screen.dart';
import 'package:esoteric_circle/features/maestri/domain_screen.dart';
import 'package:esoteric_circle/features/santuario/daily_strip.dart';
import 'package:esoteric_circle/core/rituals/tempi_del_respiro.dart';
import 'package:esoteric_circle/design_system/components/guida_del_respiro.dart';
import 'package:esoteric_circle/features/shell/barra_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/registro_degli_eos.dart';
import 'package:esoteric_circle/design_system/components/volo_degli_eos.dart';
import 'package:esoteric_circle/features/sigilli/celebrazione.dart';
import 'package:esoteric_circle/features/santuario/santuario_screen.dart';
import 'package:esoteric_circle/core/arts/arti_preferite.dart';
import 'package:esoteric_circle/features/santuario/widgets/tue_arti_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'istante_dichiarato.dart';

/// Cattura headless delle schermate, con font reali (corpo e icone), provider
/// AI offline e conversazioni gia' seminate. Nessuna rete, nessun device.
///
/// Dove finiscono i PNG. Di default in `build/preview/`, cartella ignorata dal
/// versionamento: cosi' `flutter test` verifica che ogni schermata renda ancora
/// senza mai sporcare l'albero di lavoro. Le anteprime committate in
/// `docs/preview/` si aggiornano solo su richiesta esplicita, valorizzando
/// AGGIORNA_ANTEPRIME=1, cosa che fanno gli script in `tool/`.
/// IL RAPPORTO DI PIXEL DEL CORREDO, dichiarato: TRE.
///
/// **Non e' un dettaglio di resa, e' la fedelta' dell'anteprima.** A rapporti
/// diversi cambiano la rasterizzazione dei glifi, i tratti sottili e la
/// diffusione delle ombre: **un'anteprima a rapporto piu' basso puo' nascondere
/// esattamente i difetti che il corredo esiste per prendere.** E se 360 punti
/// logici sono la prima misura, quella su cui si giudica, giudicarla a un
/// rapporto che il telefono non ha svuota la regola.
///
/// **Prima era UNO**, e l'immagine veniva poi ingrandita tre volte in scrittura:
/// il file usciva della misura giusta, ma dipinto come su un telefono che non
/// esiste. Ingrandire dopo non restituisce cio' che il rapporto decide durante.
const double rapportoDelCorredo = 3.0;

/// Imposta lo schermo da una misura LOGICA, col rapporto dichiarato.
///
/// **Una sola porta.** I tre punti che impostavano lo schermo scrivevano
/// ciascuno il proprio `devicePixelRatio`, e per tre volte era uno: bastava
/// dimenticarne uno per avere due anteprime rese in due modi diversi senza che
/// nessuno lo sapesse. Qui la misura si dichiara logica, e il rapporto lo mette
/// il corredo.
Future<void> montaLoSchermo(WidgetTester tester, Size logico,
    {double rapporto = rapportoDelCorredo}) async {
  tester.view.devicePixelRatio = rapporto;
  tester.view.physicalSize = logico * rapporto;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  // **TRE FRAMI DOPO IL CAMBIO DI MISURA, e non uno.** Ordine S, punto 6 della
  // decisione D5.
  //
  // Cambiare la misura dello schermo allarga la finestra di scorrimento, e cio'
  // che prima stava sotto la piega adesso ci sta dentro: ma i figli nuovi di una
  // lista pigra non nascono nel frame in cui la finestra cresce, e nel frame
  // dopo devono ancora essere dipinti. **Nella schermata dei Piani si vedevano
  // due livelli su quattro:** l'Iniziato e l'Adepto, cioe' i piani che si pagano,
  // non c'erano. Misurato coll'inchiostro dell'immagine, cioe' quanti pixel
  // chiari porta: 8.266 con un frame, 27.027 con tre, che e' esattamente il
  // valore dello scatto lento.
  //
  // Sta QUI e non nei cinquanta punti che cambiano misura, perche' altrimenti il
  // difetto rientra dal primo che se ne dimentica.
  for (var i = 0; i < 3; i++) {
    await tester.pump(const Duration(milliseconds: 400));
  }
}

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  // Un solo comando rigenera le anteprime: tool/aggiorna_anteprime.ps1 su
  // Windows, tool/aggiorna_anteprime.sh altrove.
  final aggiornaAnteprime =
      Platform.environment['AGGIORNA_ANTEPRIME'] == '1';
  // **LO SCATTO LENTO, e serve a scoprire le anteprime che dipingono a meta'.**
  // Ordine S, punto 6 della decisione D5 di Mauro del 13 agosto 2026.
  //
  // Il difetto trovato sulle rune: `ScrollReveal` ha UNA sola occasione per far
  // partire la comparsa, il postFrame di `didChangeDependencies`, e se in quel
  // frame la scatola non ha ancora geometria l'occasione si perde. Su un telefono
  // la recupera il primo scorrimento; in una cattura non arriva nessuno
  // scorrimento, e l'anteprima esce col contenuto dipinto a opacita' ZERO. Le
  // prove non se ne accorgono: il widget e' nell'albero e lo trovano.
  //
  // **Come si trovano le altre.** Con questo interruttore ogni scatto riceve
  // molto piu' tempo e finisce in una cartella a parte: le immagini che CAMBIANO
  // fra i due giri sono quelle che dipendevano dal tempo, cioe' quelle che
  // qualcuno potrebbe aver giudicato mentre erano incomplete. Non e' una prova
  // che passa o cade, e' uno strumento di misura, e resta qui perche' questa
  // famiglia di difetti tornera'.
  const bool anteprimeLente = bool.fromEnvironment('ANTEPRIME_LENTE');
  final previewDir = anteprimeLente
      ? 'build/preview_lento'
      : (aggiornaAnteprime ? 'docs/preview' : 'build/preview');

  // Ogni cattura parte da uno store locale noto e ripulito, quello di chi torna:
  // risveglio gia' fatto, cosi' si apre il Santuario e non l'onboarding, e saluto
  // della prima volta gia' visto, cosi' non compare a coprire la scena. Nessuna
  // continuita' di rito e' seminata se non dove serve. Senza questo ripristino
  // prima di ogni test, il mock di SharedPreferences di una cattura si
  // trascinerebbe nelle successive e ne cambierebbe il rendering.
  // **LA GENERAZIONE E' GIA' QUELLA, ordine AR voce 06.** Senza questa riga
  // ogni cattura parte da un telefono alla sua PRIMA apertura dopo la
  // riprogettazione del Cammino, e il Santuario apre il foglio della rinascita
  // sopra la scena: nelle anteprime comparirebbe un foglio che non si stava
  // fotografando, e nella cattura dell'Oroscopo il tocco su "Profonda" cadeva
  // sul foglio invece che sul menu. Le anteprime mostrano l'app di chi la usa,
  // non il suo primo minuto.
  setUp(() => SharedPreferences.setMockInitialValues(
        const {
          'onboarding.done': true,
          'santuario.greeted': true,
          'cammino.generazione': 2,
        },
      ));

  Future<void> loadFont(String family, String path) async {
    final loader = FontLoader(family);
    final bytes = File(path).readAsBytesSync();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
    await loader.load();
  }

  Future<void> loadFonts() async {
    await loadFont('Cinzel', 'assets/fonts/Cinzel-variable.ttf');
    await loadFont('EBGaramond', 'assets/fonts/EBGaramond-variable.ttf');
    // Le icone Material NON si caricano piu' qui. Stavano dentro questa
    // funzione, cioe' dentro il corredo soltanto: ogni altro file di cattura
    // disegnava quadrati vuoti al posto delle icone senza che nessuno lo
    // dicesse. Adesso stanno in `test/flutter_test_config.dart`, che vale per
    // tutta la suite, e li' un percorso mancante spezza invece di ripiegare.
  }

  // Silenzia i sensori: in headless non esistono, e senza questo la parallasse
  // solleva una MissingPluginException asincrona che sporca il test.
  void silenceSensors() {
    final messenger = binding.defaultBinaryMessenger;
    // IL CANALE AUDIO, muto nelle anteprime.
    //
    // Da quando il lettore reale e' il default, aprire la Meditazione dalla
    // rotta vera tenta di riprodurre, e in prova il plugin non esiste: la
    // cattura cadeva e due anteprime smettevano di rigenerarsi senza che
    // nessuno se ne accorgesse. L'anteprima misura la grafica, non il suono,
    // quindi il canale si spegne qui invece di far cadere la cattura.
    for (final canale in const [
      'xyz.luan/audioplayers',
      'xyz.luan/audioplayers.global',
      'xyz.luan/audioplayers/events',
      'xyz.luan/audioplayers.global/events',
    ]) {
      messenger.setMockMethodCallHandler(
          MethodChannel(canale), (call) async => null);
      messenger.setMockStreamHandler(
          EventChannel(canale), MockStreamHandler.inline(onListen: (a, e) {}));
    }
    messenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (call) async => null,
    );
    for (final name in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      messenger.setMockStreamHandler(
        EventChannel(name),
        MockStreamHandler.inline(onListen: (args, events) {}),
      );
    }
  }

  Future<void> step(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  List<(ChatRole, String)> seedFor(Maestro maestro) {
    switch (maestro) {
      case Maestro.medora:
        return const [
          (ChatRole.user, 'Parlami del mio segno'),
          (
            ChatRole.maestro,
            'Il tuo segno racconta una tensione fra il cuore e la volontà. '
                'Oggi le stelle ti invitano a scegliere con calma, senza '
                'fretta. Vuoi che guardi un ambito, l\'amore o il lavoro?'
          ),
          (ChatRole.user, 'L\'amore, ti ascolto'),
          (
            ChatRole.maestro,
            'Venere ti sfiora con dolcezza. Un legame chiede verità, non '
                'perfezione. Prova a dire una cosa sincera a chi ami oggi, poi '
                'osserva come cambia la luce fra voi.'
          ),
        ];
      case Maestro.aura:
        return const [
          (ChatRole.user, 'Aiutami a rilassarmi'),
          (
            ChatRole.maestro,
            'Chiudi gli occhi un istante. Porta il respiro nel ventre, lento e '
                'profondo. Lascia scendere le spalle. Senti già un piccolo '
                'spazio in più?'
          ),
          (ChatRole.user, 'Sì, un poco'),
          (
            ChatRole.maestro,
            'Bene. Resta lì tre respiri. Il chakra del cuore si apre quando '
                'smetti di spingere. Vuoi una frequenza dolce per stasera?'
          ),
        ];
      case Maestro.caligo:
        return const [
          (ChatRole.user, 'Estrai una runa per me'),
          (
            ChatRole.maestro,
            'Esce Uruz, la forza del toro selvatico. Parla di energia grezza '
                'che chiede una direzione. Dove, in questi giorni, senti una '
                'potenza che non hai ancora incanalato?'
          ),
          (ChatRole.user, 'Nel lavoro'),
          (
            ChatRole.maestro,
            'Allora incanala. Un gesto solo, deciso, prima di sera. La forza '
                'onora chi la usa, non chi la trattiene.'
          ),
        ];
    }
  }

  Future<AppServices> buildServices(Maestro maestro,
      {required bool seeded}) async {
    final memory = InMemoryMaestroMemoryRepository();
    await memory.saveProfile(
      UserProfile(disclaimerAcceptedAt: DateTime(2026, 7, 1)),
    );
    if (seeded) {
      for (final (role, text) in seedFor(maestro)) {
        await memory.appendMessage(
            maestro, ChatMessage(role: role, text: text));
      }
    }
    return AppServices(
      ai: _ScriptedMaestro(),
      memory: memory,
      memoryPersistent: true,
      diagnostics: 'Cattura offline.',
    );
  }

  /// Le due altezze su cui si guarda ogni schermata che puo' stringersi.
  ///
  /// LE TRE MISURE DEL CORREDO, e la prima e' quella su cui si giudica.
  ///
  /// [schermoReale] e' il telefono di Mauro: 1080 per 2392 pixel fisici, che con
  /// un rapporto di pixel di 3 fanno **360 per 797 punti logici**. E' la misura
  /// su cui l'app viene guardata davvero, quindi viene prima.
  ///
  /// **Qui c'era il difetto che ha prodotto nove segnalazioni.** La costante che
  /// diceva di essere "quella di Mauro" valeva `Size(390, 797)`: l'altezza era
  /// giusta e la LARGHEZZA no, trenta punti logici in piu', novanta pixel
  /// fisici. Il commento dichiarava la cosa giusta mentre il codice ne faceva
  /// un'altra. Su trenta punti in meno il testo va a capo prima, i titoli si
  /// spezzano, le etichette si troncano e le bolle crescono in altezza perche'
  /// occupano due righe invece di una: e' l'elenco esatto dei difetti che nelle
  /// anteprime non si vedevano.
  const schermoReale = Size(360, 797);
  const schermoAlto = Size(390, 844);
  const schermoBasso = Size(360, 797);

  Future<GlobalKey> mount(WidgetTester tester, AppServices services,
      {DateTime Function()? clock, Size? schermo}) async {
    await montaLoSchermo(tester, schermo ?? schermoReale);

    final rootKey = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: rootKey,
        child: EsotericCircleApp(conIntro: false, services: services, clock: clock),
      ),
    );
    await step(tester);
    tester
        .element(find.byType(MaterialApp))
        .read<QualityTierController>()
        .setTier(QualityTier.medium);
    await step(tester);
    return rootKey;
  }

  // La fascia oraria in cui il Maestro dato e' quello attivo della striscia,
  // cosi' striscia ed eroe della home derivano dallo stesso istante e mostrano
  // un momento coerente: Soffio per Aura, Oracolo per Medora, Runa per Caligo.
  DateTime Function() clockFor(Maestro maestro) {
    switch (maestro) {
      case Maestro.aura:
        return () => DateTime(2026, 7, 14, 11, 0);
      case Maestro.medora:
        return () => DateTime(2026, 7, 14, 13, 0);
      case Maestro.caligo:
        return () => DateTime(2026, 7, 14, 19, 0);
    }
  }

  void selectCentral(WidgetTester tester, Maestro maestro) {
    tester
        .element(find.byType(MaterialApp))
        .read<MaestroController>()
        .selectMaestro(maestro);
  }

  // Precarica i volti dei tre Maestri, cosi' busti e avatar sono decodificati
  // alla cattura, senza cerchi vuoti.
  Future<void> precacheFaces(WidgetTester tester) async {
    await tester.runAsync(() async {
      final element = tester.element(find.byType(MaterialApp));
      for (final m in Maestro.values) {
        await precacheImage(AssetImage(m.avatarAsset), element);
      }
      // Anche il fondale del tempio, cosi' e' decodificato alla cattura.
      await precacheImage(
        const AssetImage('brand_assets/santuario/tempio.png'),
        element,
      );
    });
    await step(tester);
  }

  // Dal Santuario: mette il Maestro al centro, entra nel dominio toccando il
  // busto, poi apre la chat.
  Future<void> openChat(WidgetTester tester, Maestro maestro) async {
    selectCentral(tester, maestro);
    await step(tester);
    await tester.tap(find.byKey(const Key('santuario_central_bust')));
    await step(tester);
    await step(tester);
    await tester.tap(find.text('Consulta ${maestro.displayName}'));
    await step(tester);
    await step(tester);
  }

  /// PRECARICA DA SOLO OGNI IMMAGINE CHE LA SCENA MONTA.
  ///
  /// **La porta che si riapriva.** In cattura headless nessuno decodifica gli
  /// asset: chi non li precarica ottiene un'anteprima coi buchi. La regola
  /// c'era, ma andava ricordata a mano in ogni cattura, e una regola che si
  /// ricorda a mano cade sempre. Era gia' successo col glifo del segno, con
  /// tanto di commento che spiegava il difetto, e nonostante quel commento e'
  /// successo di nuovo il 6 agosto 2026 nella cattura della chat di Aura.
  ///
  /// **Adesso non si ricorda: si fa.** Prima di ogni scatto si percorre
  /// l'albero, si raccolgono le immagini che ci sono davvero, e si precaricano
  /// tutte. Nessuna cattura nuova puo' nascere senza, perche' non c'e' niente
  /// da scrivere: sta dentro `capture`.
  ///
  /// Enumerare invece di elencare a mano e' la stessa scelta fatta ovunque in
  /// questo progetto: l'elenco scritto invecchia, l'albero no.
  Future<void> precaricaCioCheLaScenaMonta(WidgetTester tester) async {
    final immagini = tester
        .widgetList<Image>(find.byType(Image, skipOffstage: false))
        .map((i) => i.image)
        .toList(growable: false);
    if (immagini.isEmpty) return;
    final element = tester.element(find.byType(MaterialApp).first);
    await tester.runAsync(() async {
      for (final provider in immagini) {
        // **L'ERRORE SI PASSA A `onError`, non si prova a prenderlo.**
        // `precacheImage` NON lancia: riporta il guasto a `FlutterError.onError`,
        // e in una prova quello fa cadere il test. Un `try` attorno non serve a
        // niente, e infatti al primo giro cinquantotto catture sono cadute con
        // "image failed to precache".
        //
        // Un asset che manca non deve fermare la cattura: si lascia proseguire
        // e sara' l'anteprima a mostrare cosa non c'e', che e' esattamente cio'
        // che il corredo serve a guardare.
        await precacheImage(provider, element, onError: (errore, _) {
          debugPrint('precache non riuscito per $provider: $errore');
        });
      }
    });
    // **UN FOTOGRAMMA CHE NON MUOVE L'OROLOGIO.** Qui c'era `step`, che avanza
    // di quattrocento millisecondi: bastava a far proseguire le animazioni
    // delle catture che hanno tempi voluti, e la Runa del Tramonto usciva con
    // la velatura a meta', cioe' con i margini di cielo semitrasparenti,
    // alfa 194 invece di 255. A occhio l'immagine sembrava giusta; il
    // guardiano delle anteprime l'ha presa perche' legge RGBA premoltiplicato,
    // dove i salti del gradiente si schiacciano sotto la soglia.
    //
    // `pump()` senza durata ridisegna e basta: le immagini appena decodificate
    // compaiono, e nessuna animazione avanza di un millisecondo.
    await tester.pump();
  }

  Future<void> capture(
      WidgetTester tester, GlobalKey rootKey, String name) async {
    // COL GIRO LENTO si da' tempo a tutto cio' che compare in ritardo, e si
    // guarda quali immagini cambiano: vedi la nota sull'interruttore.
    if (anteprimeLente) {
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 400));
      }
    }
    // PRIMA DI OGNI SCATTO, sempre, senza che nessuno se lo ricordi.
    await precaricaCioCheLaScenaMonta(tester);
    await tester.runAsync(() async {
      final boundary =
          rootKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      // LO STESSO rapporto con cui si e' impaginato, non un altro numero.
      // Quando qui c'era 3 scritto a mano e lo schermo era montato a 1,
      // l'immagine usciva della misura giusta ingrandendo un disegno fatto per
      // un telefono piu' povero. Legandoli, non possono piu' divergere.
      final image = await boundary.toImage(pixelRatio: rapportoDelCorredo);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      final out = File('$previewDir/$name');
      out.createSync(recursive: true);
      out.writeAsBytesSync(data!.buffer.asUint8List());
    });
    expect(File('$previewDir/$name').existsSync(), isTrue);
  }

  // --- Il Santuario, con al centro ciascun Maestro (aura e cosmo virati) ---
  for (final maestro in Maestro.fixedOrder) {
    testWidgets('Cattura il Santuario, ${maestro.id}', (tester) async {
      silenceSensors();
      await loadFonts();
      // Istante forzato nella fascia del Maestro: striscia ed eroe coerenti.
      final rootKey = await mount(
          tester, await buildServices(maestro, seeded: false),
          clock: clockFor(maestro));
      selectCentral(tester, maestro);
      await step(tester);
      await precacheFaces(tester);
      await capture(tester, rootKey, 'santuario-${maestro.id}.png');
    });
  }

  // --- Il Sigillo dell'Intenzione, su due altezze ---
  //
  // Catturato A FINE TRACCIAMENTO: il cammino si disegna in 2,4 secondi e
  // fotografarlo prima mostrerebbe un sigillo incompleto.
  for (final basso in const [false, true]) {
    testWidgets('Cattura il Sigillo${basso ? ", schermo basso" : ""}',
        (tester) async {
      silenceSensors();
      await loadFonts();
      await montaLoSchermo(tester, basso ? schermoBasso : schermoAlto);
      final rootKey = GlobalKey();
      await tester.pumpWidget(RepaintBoundary(
        key: rootKey,
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(
                create: (_) =>
                    MaestroController(initial: const ThemeKey.of(Maestro.caligo))),
            ChangeNotifierProvider(create: (_) => QualityTierController()),
            ChangeNotifierProvider(create: (_) => ParallaxController()),
          ],
          child: const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: MaestroScope(child: SigilloIntenzioneScreen()),
          ),
        ),
      ));
      await tester.pump();
      await tester.tap(find.byKey(const Key('sigillo_inizia')));
      await tester.pump();
      await tester.enterText(find.byKey(const Key('sigillo_campo')),
          'Chiedo chiarezza sulla mia strada');
      await tester.pump();
      await tester.tap(find.byKey(const Key('sigillo_traccia')));
      // Fine tracciamento: 3,2 secondi su 2,4 di animazione.
      for (var i = 0; i < 16; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      await capture(tester, rootKey,
          'sigillo-intenzione${basso ? "-2392" : ""}.png');
    });
  }

  // --- La stessa home a 2392, l'altezza del telefono di Mauro ---
  //
  // La bolla di Medora era stata corretta, verificata verde sull'anteprima a
  // 2532, e sul telefono a 2392 copriva ancora l'avatar. Una sola altezza non
  // e' una verifica, e' una fotografia fortunata: da qui in avanti le
  // schermate che possono stringersi si guardano su due.
  testWidgets('Cattura il Santuario, Medora, schermo basso', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey = await mount(
        tester, await buildServices(Maestro.medora, seeded: false),
        clock: clockFor(Maestro.medora),
        schermo: schermoBasso);
    selectCentral(tester, Maestro.medora);
    await step(tester);
    await precacheFaces(tester);
    await capture(tester, rootKey, 'santuario-medora-2392.png');
  });

  // --- Il Santuario con l'invito al cielo visibile (mano del tap) ---
  testWidgets('Cattura il Santuario con l\'invito al cielo', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey = await mount(
        tester, await buildServices(Maestro.medora, seeded: false),
        clock: clockFor(Maestro.medora));
    selectCentral(tester, Maestro.medora);
    await step(tester);
    await precacheFaces(tester);
    // Oltre i tre secondi di inattivita', senza toccare nulla, cosi' l'invito
    // compare; poi qualche frame perche' la dissolvenza e l'animazione si
    // assestino a meta' gesto.
    await tester.pump(const Duration(milliseconds: 3200));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    await capture(tester, rootKey, 'santuario-invito.png');
  });

  // --- La cartolina condivisibile del cielo, costruita apposta ---
  testWidgets('Cattura la cartolina del cielo, verticale e quadrata',
      (tester) async {
    await loadFonts();
    await tester.runAsync(() async {
      final now = DateTime(2026, 7, 13, 22);
      final moon = MoonPhase.forDate(now);
      final high = NightSky.constellationsHighTonight(now);
      for (final (format, name) in const [
        (PostcardFormat.story, 'cartolina-cielo.png'),
        (PostcardFormat.feed, 'cartolina-cielo-quadrata.png'),
      ]) {
        final bytes = await SkyPostcard.render(
          now: now,
          moon: moon,
          high: high,
          palette: MaestroPalette.medora,
          format: format,
        );
        final out = File('$previewDir/$name');
        out.createSync(recursive: true);
        out.writeAsBytesSync(bytes);
      }
    });
    expect(File('$previewDir/cartolina-cielo.png').existsSync(), isTrue);
    expect(File('$previewDir/cartolina-cielo-quadrata.png').existsSync(),
        isTrue);
  });

  // --- La schermata "Il cielo sopra di te", aperta dal cielo del Santuario ---
  testWidgets('Cattura Il cielo sopra di te', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
    selectCentral(tester, Maestro.medora);
    await step(tester);
    await tester.tap(find.byKey(const Key('santuario_sky_tap')));
    await step(tester);
    await step(tester);
    // All'ingresso compare il pre-avviso della posizione: prima lo catturo,
    // poi lo declino per la veduta pulita del cielo.
    if (find.byKey(const Key('sky_location_prompt')).evaluate().isNotEmpty) {
      await capture(tester, rootKey, 'cielo-avvio-posizione.png');
      await tester.tap(find.byKey(const Key('sky_location_decline')));
      await step(tester);
      await step(tester);
    }
    await precacheFaces(tester);
    await capture(tester, rootKey, 'cielo-sopra-di-te.png');
  });

  // --- Chiedi ai Maestri: parte dal dominio, poi il confronto degli sguardi ---
  testWidgets('Cattura Chiedi ai Maestri, vista comparativa', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
    // Tier a pagamento, cosi' il confronto e' disponibile per l'anteprima.
    tester
        .element(find.byType(MaterialApp))
        .read<EntitlementService>()
        .setTier(Tier.tier1);
    selectCentral(tester, Maestro.medora);
    await step(tester);
    await tester.tap(find.byKey(const Key('santuario_central_bust')));
    await step(tester);
    await step(tester);
    // Dal dominio si entra nella Consulta, poi dall'header della chat si apre
    // il confronto a piu' voci.
    await tester.ensureVisible(find.byKey(const Key('domain_consulta_card')));
    await step(tester);
    await tester.tap(find.byKey(const Key('domain_consulta_card')));
    await step(tester);
    await step(tester);
    final accept = find.text('Ho capito, entriamo');
    if (accept.evaluate().isNotEmpty) {
      await tester.tap(accept);
      await step(tester);
    }
    // LA STRADA NUOVA, dal 3 agosto 2026.
    //
    // Prima si toccava l'icona a bilancia nell'intestazione e si arrivava a
    // una schermata dove la domanda andava RISCRITTA da capo. Adesso la
    // domanda si fa una volta sola, nella chat, le altre voci arrivano li'
    // dentro, e la sintesi si raggiunge soltanto quando ce ne sono almeno due.
    // Questa cattura percorre esattamente cio' che percorre la persona.
    final campo = find.descendant(
      of: find.byType(ChatComposer),
      matching: find.byType(TextField),
    );
    await tester.enterText(campo, 'Devo cambiare lavoro?');
    await step(tester);
    await tester.testTextInput.receiveAction(TextInputAction.send);
    // La pausa del consulto dura almeno 1,8 secondi, piu' la dissolvenza.
    for (var i = 0; i < 12; i++) {
      await step(tester);
    }
    // UNA PORTA SOLA, dal 5 agosto 2026: "Chiedi anche agli altri" apre
    // direttamente il Consiglio dei Maestri. Prima incollava le altre due voci
    // dentro la chat di Medora e poi serviva un secondo tocco per aprire il
    // confronto: due porte allo stesso posto.
    await tester.tap(find.byKey(const Key('chat_altre_voci')));
    for (var i = 0; i < 24; i++) {
      await step(tester);
    }
    // Decodifica gli avatar, cosi' i mezzi busti delle lenti si vedono nel
    // preview invece dell'icona di ripiego che sta dietro l'anello.
    await precacheFaces(tester);
    await capture(tester, rootKey, 'chiedi-ai-maestri.png');

    // E LA SINTESI, CHE ADESSO STA IN FONDO.
    //
    // Due immagini e non una, perche' la novita' e' proprio l'ordine: in cima
    // le tre carte, e la sintesi dove un confronto si conclude. Prima stava
    // sopra e da sola occupava tutto il primo schermo, quindi aprendo il
    // Consiglio non si vedevano tre Maestri, si vedeva un muro di testo.
    await tester.scrollUntilVisible(
      find.byKey(const Key('ask_synthesis')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await step(tester);
    await capture(tester, rootKey, 'consiglio-sintesi-in-fondo.png');
  });

  // --- Il Test Archetipo di Aura: il responso, visivo prima del testo ---
  testWidgets('Cattura il Test Archetipo', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.aura, seeded: false));
    selectCentral(tester, Maestro.aura);
    await step(tester);
    await tester.tap(find.byKey(const Key('santuario_central_bust')));
    await step(tester);
    await step(tester);
    // Dal dominio di Aura si apre il Test Archetipo, che ora ha la sua
    // esperienza vera e non piu' la soglia dell'arte.
    await tester.scrollUntilVisible(
      find.byKey(const Key('art_archetype_test')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.byKey(const Key('art_archetype_test')));
    await step(tester);
    await tester.tap(find.byKey(const Key('art_archetype_test')));
    await step(tester);
    await step(tester);
    await tester.tap(find.byKey(const Key('archetype_start')));
    await step(tester);
    // Le dodici risposte: sempre la quarta, che porta al Realista.
    for (var i = 0; i < 12; i++) {
      await tester.tap(find.byKey(const Key('archetype_answer_3')));
      await step(tester);
    }
    // Le catture locali non decodificano gli asset da sole: si precarica la
    // statua del dominante e le dodici miniature della classifica, altrimenti
    // nell'anteprima resta il ripiego.
    await tester.runAsync(() async {
      final element = tester.element(find.byType(MaterialApp));
      await precacheImage(
          AssetImage(Archetype.realista.artePiena), element);
      for (final a in Archetype.values) {
        await precacheImage(AssetImage(a.arteThumb), element);
      }
    });
    await step(tester);
    // Superficie alta, cosi' l'anteprima mostra la ruota, la statua, i testi,
    // la classifica dei dodici e i due pulsanti in fondo.
    // La misura resta LOGICA, e il rapporto lo mette il corredo: scrivere qui
    // una misura fisica vorrebbe dire un rapporto implicito.
    await montaLoSchermo(tester, const Size(360, 3600));
    await step(tester);
    await step(tester);
    await capture(tester, rootKey, 'test-archetipo.png');

    // La statua nell'Ombra: al tocco sulla statua in cima si volta.
    await tester.tap(
        find.byKey(const Key('archetype_statue_realista')).first);
    await step(tester);
  });

  testWidgets('Cattura la card del Test Archetipo', (tester) async {
    silenceSensors();
    await loadFonts();
    await montaLoSchermo(tester, const Size(460, 1160));
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final rootKey = GlobalKey();
    final profilo = ArchetypeScoring.calcola(List.filled(12, 3));
    await tester.pumpWidget(MaterialApp(
      // IL NASTRO DI DEBUG SPENTO. Un'anteprima col nastro non e' cio' che la
      // persona vede, ed e' il segno che la scena e' montata a mano invece che
      // presa dall'app. Cinque catture lo mostravano.
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF03140F),
        body: Center(
          child: RepaintBoundary(
            key: rootKey,
            child: ArchetypeShareCard(profilo: profilo),
          ),
        ),
      ),
    ));
    // La statua del dominante e le miniature della classifica compatta.
    await tester.runAsync(() async {
      final element = tester.element(find.byType(MaterialApp));
      await precacheImage(
          AssetImage(profilo.dominante.artePiena), element);
      for (final a in profilo.graduatoria.take(3)) {
        await precacheImage(AssetImage(a.arteThumb), element);
      }
    });
    await step(tester);
    await capture(tester, rootKey, 'test-archetipo-card.png');
  });

  // La soglia del Test, col selettore dei transiti prima delle domande.
  testWidgets('Cattura la soglia del Test Archetipo', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.aura, seeded: false));
    selectCentral(tester, Maestro.aura);
    await step(tester);
    await tester.tap(find.byKey(const Key('santuario_central_bust')));
    await step(tester);
    await step(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('art_archetype_test')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.byKey(const Key('art_archetype_test')));
    await step(tester);
    await tester.tap(find.byKey(const Key('art_archetype_test')));
    await step(tester);
    await step(tester);
    // La soglia mostra il selettore del cielo prima di cominciare.
    expect(find.byKey(const Key('archetype_sky_setting')), findsOneWidget);
    await montaLoSchermo(tester, const Size(360, 640));
    await step(tester);
    await step(tester);
    await capture(tester, rootKey, 'test-archetipo-soglia.png');
  });

  // Una domanda in corso, con l'avanzamento in chiaro.
  testWidgets('Cattura una domanda del Test Archetipo', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.aura, seeded: false));
    selectCentral(tester, Maestro.aura);
    await step(tester);
    await tester.tap(find.byKey(const Key('santuario_central_bust')));
    await step(tester);
    await step(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('art_archetype_test')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.byKey(const Key('art_archetype_test')));
    await step(tester);
    await tester.tap(find.byKey(const Key('art_archetype_test')));
    await step(tester);
    await step(tester);
    await tester.tap(find.byKey(const Key('archetype_start')));
    await step(tester);
    // Qualche risposta, cosi' l'avanzamento non e' alla prima domanda.
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byKey(const Key('archetype_answer_1')));
      await step(tester);
    }
    expect(find.byKey(const Key('archetype_question')), findsOneWidget);
    await montaLoSchermo(tester, const Size(360, 700));
    await step(tester);
    await step(tester);
    await capture(tester, rootKey, 'test-archetipo-domanda.png');
  });

  // --- La Costellazione del Viso di Aura: la fotocamera dal vivo non si cattura
  // in headless, quindi si usa la sagoma neutra come stand-in deterministico. ---
  Widget faceApp(Widget schermata) => MultiProvider(
        providers: [
          // LO SCAFFALE PERSONALE, ordine P voce 27: senza di lui il cuore
          // delle arti preferite non si disegna, e l'anteprima mostrerebbe una
          // barra che nell'app ha un elemento in piu'.
          ChangeNotifierProvider(
              create: (_) => ArtiPreferiteController(maestroAssegnato: Maestro.aura)),
          ChangeNotifierProvider(
              create: (_) =>
                  MaestroController(initial: const ThemeKey.of(Maestro.aura))),
          ChangeNotifierProvider(
              create: (_) => QualityTierController()..setTier(QualityTier.medium)),
          ChangeNotifierProvider(create: (_) => EntitlementService()),
          ChangeNotifierProvider(create: (_) => QuestionAllowance()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
        ],
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.dark(),
            home: MaestroScope(child: schermata)),
      );

  /// LA CATTURA MONTA CIO' CHE L'APP MONTA, ordine P voce 27.
  ///
  /// **Il difetto: queste catture montavano la schermata NUDA.** L'app la monta
  /// dentro `SogliaArte`, che porta `ArteCorrente` e `ConCuore`, cioe' il cuore
  /// delle arti preferite nella barra, e fissa la palette sul proprietario
  /// dell'arte invece di prenderla dal controller. Le sedici anteprime dei
  /// quattro flussi provavano una scena che nell'app non esiste, e il cuore non
  /// si vedeva in nessuna.
  ///
  /// La soglia non si ricostruisce qui: si chiede alla schermata, che la
  /// dichiara una volta sola per se' e per la sua rotta.
  Future<GlobalKey> mountFace(WidgetTester tester, Widget schermata,
      {required Size size}) async {
    await montaLoSchermo(tester, size);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final rootKey = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
        key: rootKey,
        child: faceApp(FaceConstellationScreen.conLaSoglia(schermata))));
    await step(tester);
    await step(tester);
    return rootKey;
  }

  testWidgets('Cattura la soglia della Costellazione del Viso', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey = await mountFace(tester, const FaceConstellationScreen(),
        size: const Size(360, 820));
    expect(find.byKey(const Key('face_sky_setting')), findsOneWidget);
    await capture(tester, rootKey, 'costellazione-viso-soglia.png');
  });

  testWidgets('Cattura la costellazione sulla sagoma', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey = await mountFace(tester, const FaceConstellationScreen(),
        size: const Size(360, 1400));
    // Si entra nella cattura: senza fotocamera resta la sagoma neutra con la
    // costellazione sopra, che e' proprio lo stand-in deterministico.
    await tester.tap(find.byKey(const Key('face_start')));
    await step(tester);
    await step(tester);
    expect(find.byKey(const Key('face_constellation_live')), findsOneWidget);
    await capture(tester, rootKey, 'costellazione-viso-sagoma.png');
  });

  testWidgets('Cattura il responso della Costellazione del Viso',
      (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey = await mountFace(tester, const FaceConstellationScreen(),
        size: const Size(360, 2200));
    // Percorso deterministico: si entra nella cattura e si scatta sulla sagoma.
    await tester.tap(find.byKey(const Key('face_start')));
    await step(tester);
    await step(tester);
    await tester.tap(find.byKey(const Key('face_shutter')));
    await step(tester);
    await step(tester);
    expect(find.byKey(const Key('face_result')), findsOneWidget);
    await capture(tester, rootKey, 'costellazione-viso.png');
  });

  testWidgets('Cattura la card della Costellazione del Viso', (tester) async {
    silenceSensors();
    await loadFonts();
    await montaLoSchermo(tester, const Size(460, 1100));
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final contorni = FaceSilhouette.contorni();
    final rootKey = GlobalKey();
    await tester.pumpWidget(MaterialApp(
      // IL NASTRO DI DEBUG SPENTO. Un'anteprima col nastro non e' cio' che la
      // persona vede, ed e' il segno che la scena e' montata a mano invece che
      // presa dall'app. Cinque catture lo mostravano.
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF03140F),
        body: Center(
          child: RepaintBoundary(
            key: rootKey,
            child: FaceShareCard(
              reading: FaceClassifier.leggi(contorni),
              costellazione: FaceConstellation.da(contorni),
            ),
          ),
        ),
      ),
    ));
    await step(tester);
    await capture(tester, rootKey, 'costellazione-viso-card.png');
  });

  testWidgets('Cattura il ripiego della Costellazione del Viso', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey = await mountFace(
        tester, const FaceConstellationScreen(partiDalRipiego: true),
        size: const Size(360, 1080));
    expect(find.byKey(const Key('face_fallback')), findsOneWidget);
    await capture(tester, rootKey, 'costellazione-viso-ripiego.png');
  });

  // --- La Meditazione di Aura: cimatica, respiro e suono generato a runtime ---
  testWidgets('Cattura la Meditazione di Aura', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.aura, seeded: false));
    selectCentral(tester, Maestro.aura);
    await step(tester);
    await tester.tap(find.byKey(const Key('santuario_central_bust')));
    await step(tester);
    await step(tester);
    // Nel dominio di Aura, la card della Meditazione nel riquadro Energia apre
    // la schermata.
    await tester.scrollUntilVisible(
      find.byKey(const Key('art_meditation')),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await step(tester);
    await tester.tap(find.byKey(const Key('art_meditation')));
    await step(tester);
    await step(tester);
    // Avvio il suono e porto il respiro verso il pieno: il mandala si apre.
    await tester.tap(find.byKey(const Key('meditation_play')));
    await tester.pump(const Duration(milliseconds: 2600));
    await capture(tester, rootKey, 'meditazione-aura.png');
  });

  // --- I quattro rituali del giorno ---
  Future<void> captureRitual(
    WidgetTester tester,
    GlobalKey rootKey,
    Route<void> route,
    Future<void> Function() reveal,
    String name,
  ) async {
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    unawaited(nav.push(route));
    await step(tester);
    await step(tester);
    await reveal();
    await tester.pump(const Duration(milliseconds: 700));
    await capture(tester, rootKey, name);
  }

  testWidgets('Cattura il Rito dell\'Alba, velato e col dono', (tester) async {
    silenceSensors();
    // Semina la continuita' in locale cosi' la cattura del dono mostra il chip
    // dei giorni consecutivi e se ne validano posizione e stile. Ieri l'ultimo
    // rito, sei di fila: il gesto di oggi lo porta a sette, come sul device di
    // chi torna ogni mattina. La logica dello streak non cambia, si prepara solo
    // lo stato di partenza che sul device arriva dai giorni precedenti.
    SharedPreferences.setMockInitialValues({
      'onboarding.done': true,
      'santuario.greeted': true,
      'ritual.dawn.lastDay': '2026-07-12',
      'ritual.dawn.streak': 6,
      // **IL CAMMINO E' GIA' PERCORSO, ordine AS voce 06.** Compiere il rito
      // matura un traguardo, e la celebrazione si apre SOPRA il dono: la
      // cattura usciva con la festa al posto della scheda, e chi la guardava
      // credeva di vedere il dono. Con tutti i Sigilli gia' accesi non matura
      // niente e sotto c'e' quello che si sta fotografando.
      'cammino.generazione': 2,
      'cammino.accesi': [for (final t in Sentieri.tuttiITraguardi) t.id],
    });
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
    // Il Rito dell'Alba compone tre livelli reali: si precaricano cosi' nella
    // cattura headless sono gia' decodificati e la scena appare, senza restare
    // in caricamento.
    final element = tester.element(find.byType(MaterialApp));
    await tester.runAsync(() async {
      for (final a in const [
        'assets/ritual_backgrounds/dawn_sky_night.png',
        'assets/ritual_backgrounds/dawn_sky_day.png',
        'assets/ritual_backgrounds/dawn_sun.png',
      ]) {
        await precacheImage(AssetImage(a), element);
      }
    });
    await step(tester);

    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    // GLI AVVISI SPENTI, dall'ordine M: la rotta vera parla col servizio
    // vero, che alla prima apertura porge la spiegazione del permesso. La
    // cattura fotografa il RITO, non la richiesta: il servizio spento tiene
    // la scena com'era, che e' quella approvata.
    unawaited(nav.push(DawnRiteScreen.route(
        now: DateTime(2026, 7, 13), avvisi: const AvvisiSpenti())));
    await step(tester);
    await step(tester);
    // Lascia che lo screen risolva i tre livelli dalla cache immagini.
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 60));
    });
    await step(tester);
    await step(tester);
    // Stato velato: la notte con la luna e mezzo sole sull'orizzonte, l'invito.
    await capture(tester, rootKey, 'rito-alba.png');

    // Il gesto tattile solleva l'alba e porge il dono del giorno.
    await tester.tap(find.byKey(const Key('ritual_gesture')));
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await step(tester);
    await capture(tester, rootKey, 'rito-alba-dono.png');

    // **IL PONTE VERSO IL SOFFIO, ordine S voce 13.** La scheda del dono scorre:
    // il respiro guidato che stava qui dentro e' uscito, e al suo posto c'e' una
    // riga che porta nel Soffio del Destino. Si scorre la scheda fino in fondo,
    // perche' e' li' che la riga vive.
    // Di scorrimenti verticali ce n'e' piu' d'uno in scena: quello della scheda
    // e' l'ULTIMO montato, cioe' il piu' interno.
    final dentroLaScheda = tester
        .state<ScrollableState>(find
            .byWidgetPredicate(
                (w) => w is Scrollable && w.axisDirection == AxisDirection.down)
            .last)
        .position;
    dentroLaScheda.jumpTo(dentroLaScheda.maxScrollExtent);
    await step(tester);
    await capture(tester, rootKey, 'alba-ponte-al-soffio.png');

    // La base apribile del dono: da dove nasce, con l'ancora natale reale e i
    // livelli provvisori chiaramente marcati. Superficie piu' alta, cosi'
    // l'anteprima mostra il pannello intero, che sul device e' scorrevole.
    await tester.tap(find.byKey(const Key('gift_base_toggle')));
    await step(tester);
    await montaLoSchermo(tester, const Size(360, 1150));
    await step(tester);
    await capture(tester, rootKey, 'rito-alba-base.png');
  });

  /// LA SCHEDA PIENA COL COLORE DEL MAESTRO DEL GIORNO, in due giorni diversi.
  ///
  /// Servono due catture e non una: il punto della voce e' che il colore
  /// CAMBIA col Maestro, e una sola immagine non lo puo' mostrare. Le due date
  /// non sono scelte a occhio, sono cercate finche' i due Maestri non risultano
  /// diversi, cosi' la cattura non dipende da come ruota il calendario.
  for (final quale in [0, 1]) {
    testWidgets('Cattura il dono col colore del Maestro, giorno $quale',
        (tester) async {
      silenceSensors();
      SharedPreferences.setMockInitialValues({
        'onboarding.done': true,
        'santuario.greeted': true,
        'ritual.dawn.lastDay': '2026-07-12',
        'ritual.dawn.streak': 6,
      });

      // Due giorni consecutivi con Maestri diversi, trovati e non supposti.
      final partenza = DateTime(2026, 7, 13);
      var secondo = partenza.add(const Duration(days: 1));
      while (DailyRituals.dawnMaestro(secondo) ==
          DailyRituals.dawnMaestro(partenza)) {
        secondo = secondo.add(const Duration(days: 1));
      }
      final giorno = quale == 0 ? partenza : secondo;
      final maestro = DailyRituals.dawnMaestro(giorno);
      expect(DailyRituals.dawnMaestro(partenza),
          isNot(DailyRituals.dawnMaestro(secondo)),
          reason: 'le due anteprime mostrerebbero lo stesso Maestro, quindi '
              'non direbbero che il colore cambia');

      await loadFonts();
      final rootKey = await mount(
          tester, await buildServices(Maestro.medora, seeded: false));
      final element = tester.element(find.byType(MaterialApp));
      await tester.runAsync(() async {
        for (final a in const [
          'assets/ritual_backgrounds/dawn_sky_night.png',
          'assets/ritual_backgrounds/dawn_sky_day.png',
          'assets/ritual_backgrounds/dawn_sun.png',
        ]) {
          await precacheImage(AssetImage(a), element);
        }
      });
      await step(tester);

      final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
      unawaited(nav.push(DawnRiteScreen.route(now: giorno)));
      await step(tester);
      await step(tester);
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 60));
      });
      await step(tester);
      await step(tester);

      await tester.tap(find.byKey(const Key('ritual_gesture')));
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await step(tester);
      await capture(tester, rootKey, 'rito-alba-dono-${maestro.id}.png');
    });
  }

  /// LA CHAT DI AURA COL LOTO E L'INVITO, dalla strada vera dell'app.
  ///
  /// **La prima stesura montava il widget in isolamento, ed era inutile.**
  /// Usciva col nastro di debug in alto a destra e con un fondo verde pieno
  /// invece del cosmo condiviso: due segni che quella non era la schermata, era
  /// il componente. Non diceva niente su come il loto appare dentro la chat di
  /// Aura, che era l'unica cosa da giudicare.
  ///
  /// Adesso si entra come entra un dito: Santuario, busto, Consulta Aura,
  /// domanda. La voce non risponde mai, e la scena del consulto vive
  /// esattamente li'.
  testWidgets("Cattura la chat di Aura col loto e l'invito", (tester) async {
    silenceSensors();
    await loadFonts();
    final memory = InMemoryMaestroMemoryRepository();
    await memory
        .saveProfile(UserProfile(disclaimerAcceptedAt: DateTime(2026, 7, 1)));
    final services = AppServices(
      ai: _VoceCheFaAspettare(),
      memory: memory,
      memoryPersistent: true,
      diagnostics: 'Cattura offline.',
    );
    final rootKey = await mount(tester, services);
    // I dati di nascita ci sono, l'ARCHETIPO NO: e' esattamente la persona che
    // questa immagine deve mostrare, quella che non ha ancora fatto il Test.
    tester
        .element(find.byType(MaterialApp))
        .read<BirthIdentityController>()
        .setBirth(
          BirthDetails(
            date: DateTime(1990, 8, 10),
            time: const TimeOfDay(hour: 12, minute: 0),
            place: const astro.BirthPlace(
                label: 'Roma',
                latitude: 41.9,
                longitude: 12.5,
                timezone: 'Europe/Rome'),
          ),
          NatalChart.essential(sunSign: Zodiac.leo, hasTime: false),
        );
    await step(tester);
    await openChat(tester, Maestro.aura);
    await precacheFaces(tester);

    final campo = find.descendant(
      of: find.byType(ChatComposer),
      matching: find.byType(TextField),
    );
    await tester.enterText(campo, 'Da dove comincio, oggi?');
    await step(tester);
    await tester.testTextInput.receiveAction(TextInputAction.send);
    // Il tratto del simbolo scende in tre secondi: si aspetta che il fiore sia
    // intero, altrimenti l'anteprima mostra un loto a meta' e sembra un
    // ritaglio sbagliato invece di un'animazione colta a meta'.
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    // LA VERIFICA PRIMA DELLA CATTURA. Se il loto o l'invito non ci fossero,
    // l'anteprima uscirebbe senza e nessuno se ne accorgerebbe guardandola.
    expect(find.byKey(const Key('consulto_del_cielo')), findsOneWidget,
        reason: "la scena del consulto non e' comparsa: l'immagine "
            "mostrerebbe la chat e basta");
    expect(find.byType(LotoDorato), findsOneWidget,
        reason: "il loto non e' nella scena");
    expect(find.byKey(const Key('consulto_invito')), findsOneWidget,
        reason: "l'invito non e' nella scena");
    // E nessun emblema di archetipo: sarebbe la bugia che la regola vieta.
    await precacheFaces(tester);
    await capture(tester, rootKey, 'chat-aura-loto-e-invito.png');
  });

  /// L'ALTRA META': la stessa scena, ma col Test Archetipo gia' fatto.
  ///
  /// Le due immagini vanno guardate una accanto all'altra, perche' il difetto
  /// che hanno chiuso stava proprio nel passaggio fra loro: fatto il Test,
  /// Aura continuava a mostrare il fiore che aspetta, e l'emblema arrivava
  /// solo riaprendo l'app. La schermata del Test scriveva in una copia sua
  /// dello storico, la chat leggeva quella condivisa, e le due si incontravano
  /// soltanto su disco.
  testWidgets("Cattura la chat di Aura con l'emblema dell'archetipo",
      (tester) async {
    silenceSensors();
    // L'ARCHETIPO GIA' SCOPERTO, sul disco: e' cio' che l'app trova aprendo.
    SharedPreferences.setMockInitialValues({
      'onboarding.done': true,
      'archetipo.storico': [
        jsonEncode(ArchetypeEsito(
          quando: DateTime(2026, 8, 3, 18, 30),
          percentuali:
              ArchetypeScoring.calcola(List.filled(12, 3)).percentuali,
          dominante: Archetype.realista,
        ).toJson()),
      ],
    });
    await loadFonts();
    final memory = InMemoryMaestroMemoryRepository();
    await memory
        .saveProfile(UserProfile(disclaimerAcceptedAt: DateTime(2026, 7, 1)));
    final services = AppServices(
      ai: _VoceCheFaAspettare(),
      memory: memory,
      memoryPersistent: true,
      diagnostics: 'Cattura offline.',
    );
    final rootKey = await mount(tester, services);
    tester
        .element(find.byType(MaterialApp))
        .read<BirthIdentityController>()
        .setBirth(
          BirthDetails(
            date: DateTime(1990, 8, 10),
            time: const TimeOfDay(hour: 12, minute: 0),
            place: const astro.BirthPlace(
                label: 'Roma',
                latitude: 41.9,
                longitude: 12.5,
                timezone: 'Europe/Rome'),
          ),
          NatalChart.essential(sunSign: Zodiac.leo, hasTime: false),
        );
    await step(tester);
    await openChat(tester, Maestro.aura);
    await precacheFaces(tester);

    final campo = find.descendant(
      of: find.byType(ChatComposer),
      matching: find.byType(TextField),
    );
    await tester.enterText(campo, 'Da dove comincio, oggi?');
    await step(tester);
    await tester.testTextInput.receiveAction(TextInputAction.send);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    // IL PRECARICO DELL'EMBLEMA prima dello scatto: senza, l'immagine non si
    // decodifica in headless e la scena esce con un buco dove sta l'arte.
    await tester.runAsync(() async {
      await precacheImage(AssetImage(Archetype.realista.arteThumb),
          tester.element(find.byType(MaterialApp)));
    });
    await step(tester);

    // LE VERIFICHE PRIMA DELLA CATTURA.
    expect(find.byKey(const Key('consulto_del_cielo')), findsOneWidget,
        reason: "la scena del consulto non e' comparsa");
    expect(find.byType(LotoDorato), findsNothing,
        reason: "col Test fatto Aura guarda ancora il fiore che aspetta: e' "
            "il difetto che questa immagine deve mostrare chiuso");
    expect(find.byKey(const Key('consulto_invito')), findsNothing,
        reason: "l'invito al Test resta a chi il Test l'ha gia' fatto");
    expect(
        find.byWidgetPredicate((w) =>
            w is Image &&
            w.image is AssetImage &&
            (w.image as AssetImage).assetName == Archetype.realista.arteThumb),
        findsWidgets,
        reason: "l'emblema dell'archetipo non e' nella scena");
    await capture(tester, rootKey, 'chat-aura-emblema.png');
  });

  testWidgets('Cattura il Soffio del Destino, testa piena e col dono',
      (tester) async {
    silenceSensors();
    // Continuita' seminata, cosi' la cattura del dono mostra il chip.
    SharedPreferences.setMockInitialValues({
      'onboarding.done': true,
      'santuario.greeted': true,
      'ritual.breath.lastDay': '2026-07-12',
      'ritual.breath.streak': 4,
    });
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.aura, seeded: false));
    // I due livelli reali del Soffio: prato e soffione. Si precaricano.
    final element = tester.element(find.byType(MaterialApp));
    await tester.runAsync(() async {
      for (final a in const [
        'assets/ritual_backgrounds/breath_meadow.png',
        'assets/ritual_backgrounds/breath_dandelion.png',
      ]) {
        await precacheImage(AssetImage(a), element);
      }
    });
    await step(tester);

    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    unawaited(nav.push(BreathDestinyScreen.route(now: DateTime(2026, 7, 13))));
    await step(tester);
    await step(tester);
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 60));
    });
    await step(tester);
    await step(tester);
    // Stato di partenza: testa piena col soffione e l'invito.
    await capture(tester, rootKey, 'soffio-destino.png');

    // Ripiego tattile per la cattura, dato che in headless il microfono non c'e'.
    await tester.longPress(find.byKey(const Key('ritual_gesture')));
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await step(tester);
    await capture(tester, rootKey, 'soffio-destino-dono.png');
  });

  testWidgets('Cattura l\'Oracolo del Giorno', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
    await captureRitual(
      tester,
      rootKey,
      DayOracleScreen.route(now: DateTime(2026, 7, 13)),
      () async => tester.drag(
          find.byKey(const Key('ritual_gesture')), const Offset(250, 0)),
      'oracolo-giorno.png',
    );
  });

  // La Runa del Tramonto ha un flusso lungo: attesa, getto, incisione, due voci,
  // striscia della settimana, sigillo alla settima sera. La sera e' fissata alle
  // 20 e la nascita al 2 novembre 1975, cosi' esce Laguz, una runa a due tratti
  // con un rovescio vero, buona da mostrare tratto per tratto.
  final serataTramonto = DateTime(2026, 7, 13, 20);
  final nascitaTramonto = DateTime(1975, 11, 2);

  Route<dynamic> rottaTramonto() => SunsetRuneScreen.route(
        now: serataTramonto,
        dataNascita: nascitaTramonto,
      );

  // Precarica gli artwork rune_bone, cosi' il glifo inciso e' decodificato alla
  // cattura e non resta un buco al posto dell'arte finale.
  Future<void> precacheTramonto(WidgetTester tester) async {
    // I tre fondali sono 1284 per 2778: decodificati pesano una quarantina di
    // megabyte in tutto e, sommati alle ventiquattro pietre, sfondano il tetto
    // predefinito della cache immagini, che espelle le miniature gia' caricate e
    // lascia le caselle della settimana vuote. Qui il tetto si alza: e' solo la
    // cattura, l'app in esercizio non ha bisogno di tenerle tutte insieme.
    PaintingBinding.instance.imageCache.maximumSizeBytes = 512 << 20;
    await tester.runAsync(() async {
      final element = tester.element(find.byType(SunsetRuneScreen));
      for (final r in kElderFuthark) {
        if (r.hasImage) {
          await precacheImage(AssetImage(r.fullPath!), element);
          // Anche le miniature, per le caselle della striscia settimanale.
          await precacheImage(AssetImage(r.thumbPath!), element);
        }
      }
      // E i tre fondali del tramonto: senza, la cattura sorprende il momento
      // successivo con l'immagine non ancora decodificata e finisce sul ripiego
      // procedurale. La lista si legge da `kFondaliTramonto`, la stessa della
      // schermata, cosi' i percorsi non possono divergere.
      for (final slot in kFondaliTramonto) {
        await precacheImage(AssetImage(slot), element);
      }
    });
    await step(tester);
    // L'AnimatedSwitcher del fondale dura novecento millisecondi: si lascia
    // arrivare a regime, altrimenti lo scatto coglie la dissolvenza a meta'.
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  // Semina alcune sere gia' vissute, per una striscia che non sia vuota.
  String sereSeminate(int quante) {
    final giorno = SunsetRune.giornoRituale(serataTramonto);
    const rune = ['Fehu', 'Uruz', 'Ansuz', 'Raidho', 'Gebo', 'Wunjo'];
    final voci = <String>[];
    for (var i = quante; i >= 1; i--) {
      final g = SunsetRune.iso(giorno.subtract(Duration(days: i)));
      voci.add('{"giorno":"$g","rune":"${rune[(i - 1) % rune.length]}",'
          '"ombra":false,"lasciare":"la fretta","porta":"la quiete"}');
    }
    return '[${voci.join(',')}]';
  }

  // Incide tenendo il dito finche' il segno e' compiuto e si apre la lettura.
  Future<void> incidiTramonto(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('sunset_getto_gesture')));
    await step(tester);
    final centro =
        tester.getCenter(find.byKey(const Key('sunset_incisione_gesture')));
    final g = await tester.startGesture(centro);
    // Tiene il dito a lungo: nel gesto manuale ogni frame scava al piu' 50 ms,
    // quindi servono parecchie battute per compiere il segno e aprire la lettura.
    for (var i = 0; i < 44; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    await g.up();
    await step(tester);
    await step(tester);
    // Col segno compiuto il fondale passa al terzo momento: si lascia finire la
    // dissolvenza da novecento millisecondi prima di scattare.
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  // Che cosa fotografa davvero ciascuno dei tre nomi. I nomi sono piu' vecchi
  // del flusso e non corrispondono piu' alla lettera, ma NON si rinominano: il
  // lucchetto in preview_integrity_test.dart e la relazione li citano per nome, e
  // una rinomina costerebbe senza portare niente. Quindi si dichiara qui:
  //   runa-tramonto-attesa.png    la pietra velata prima del getto, cioe' la
  //                               fase di attesa vera e propria.
  //   runa-tramonto-getto.png     il momento SUBITO DOPO il getto, con la pietra
  //                               gia' scoperta e pronta a essere incisa: e' la
  //                               fase di incisione appena cominciata, non il
  //                               lancio in volo, che non ha una cattura.
  //   runa-tramonto-incisione.png il segno a meta', col solco in corso di scavo.
  testWidgets('Cattura la Runa del Tramonto, attesa getto e incisione',
      (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.caligo, seeded: false));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    unawaited(nav.push(rottaTramonto()));
    await step(tester);
    await step(tester);
    await precacheTramonto(tester);
    // Attesa: la pietra velata sotto il tramonto.
    await capture(tester, rootKey, 'runa-tramonto-attesa.png');
    // Il getto col tocco, ripiego dello scuotimento: la pietra si scopre.
    await tester.tap(find.byKey(const Key('sunset_getto_gesture')));
    await tester.pump(const Duration(milliseconds: 700));
    await capture(tester, rootKey, 'runa-tramonto-getto.png');
    // L'incisione a meta': il dito resta sulla pietra, il segno nasce a tratti.
    final centro =
        tester.getCenter(find.byKey(const Key('sunset_incisione_gesture')));
    final g = await tester.startGesture(centro);
    // Oltre la soglia del tocco prolungato, poi incide a meta' della runa: piu'
    // battute brevi fanno avanzare il ticker un passo alla volta.
    for (var i = 0; i < 7; i++) {
      await tester.pump(const Duration(milliseconds: 140));
    }
    await capture(tester, rootKey, 'runa-tramonto-incisione.png');
    expect(find.byKey(const Key('sunset_voce_uno')), findsNothing);
    await g.up();
  });

  testWidgets('Cattura la Runa del Tramonto, le due voci e la settimana',
      (tester) async {
    silenceSensors();
    await loadFonts();
    // Quattro sere gia' vissute: stasera fa cinque, la striscia respira.
    SharedPreferences.setMockInitialValues({
      'onboarding.done': true,
      'santuario.greeted': true,
      'sunset_rune.settimana': sereSeminate(4),
    });
    final rootKey =
        await mount(tester, await buildServices(Maestro.caligo, seeded: false));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    unawaited(nav.push(rottaTramonto()));
    await step(tester);
    await step(tester);
    await precacheTramonto(tester);
    await incidiTramonto(tester);
    // La prima voce e la trasparenza dei tre fattori.
    expect(find.byKey(const Key('sunset_voce_uno')), findsOneWidget);
    await capture(tester, rootKey, 'runa-tramonto-voce-uno.png');
    // La seconda voce dietro la rotazione, ripiego doppio tap.
    final loc = tester.getCenter(find.byKey(const Key('sunset_gira_doppio')));
    await tester.tapAt(loc);
    await tester.pump(const Duration(milliseconds: 60));
    await tester.tapAt(loc);
    await step(tester);
    await step(tester);
    await capture(tester, rootKey, 'runa-tramonto-voce-due.png');
    // La striscia delle sette sere, portata a vista.
    await tester.ensureVisible(find.byKey(const Key('sunset_settimana')));
    await step(tester);
    await capture(tester, rootKey, 'runa-tramonto-settimana.png');
  });

  testWidgets('Cattura il Sigillo del Tramonto, alla settima sera',
      (tester) async {
    silenceSensors();
    await loadFonts();
    // Sei sere gia' vissute: stasera fa sette, il sigillo si compone.
    SharedPreferences.setMockInitialValues({
      'onboarding.done': true,
      'santuario.greeted': true,
      'sunset_rune.settimana': sereSeminate(6),
    });
    final rootKey =
        await mount(tester, await buildServices(Maestro.caligo, seeded: false));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    unawaited(nav.push(rottaTramonto()));
    await step(tester);
    await step(tester);
    await precacheTramonto(tester);
    await incidiTramonto(tester);
    await tester.ensureVisible(find.byKey(const Key('sunset_sigillo')));
    await step(tester);
    await capture(tester, rootKey, 'runa-tramonto-sigillo.png');
  });

  // --- Il Rito del Sogno: nebbia, cielo, costellazione unita, saluto ---
  testWidgets('Cattura il Rito del Sogno', (tester) async {
    silenceSensors();
    await loadFonts();
    final quando = DateTime(2026, 7, 13, 22, 40);
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    unawaited(nav.push(DreamRiteScreen.route(now: quando)));
    await step(tester);
    await step(tester);
    // Apertura nella nebbia, buio e ovattato.
    await capture(tester, rootKey, 'rito-sogno-nebbia.png');

    // La nebbia si dirada col ripiego tattile, emergono le stelle.
    await tester.tap(find.byKey(const Key('dream_fog_skip')));
    await step(tester);
    await capture(tester, rootKey, 'rito-sogno-cielo.png');

    // Si uniscono le stelle della costellazione del segno della Luna.
    final figura = kZodiacConstellations
        .firstWhere((c) => c.sign == NightSky.moonSign(quando));
    for (var i = 0; i < figura.points.length; i++) {
      await tester.tap(find.byKey(Key('dream_star_$i')));
      await tester.pump(const Duration(milliseconds: 80));
    }
    await capture(tester, rootKey, 'rito-sogno-costellazione.png');

    // Dalla figura unita scende il saluto della notte.
    await montaLoSchermo(tester, const Size(360, 1250));
    await tester.pump(const Duration(milliseconds: 1000));
    await step(tester);
    expect(find.byKey(const Key('dream_message')), findsOneWidget);
    await capture(tester, rootKey, 'rito-sogno.png');
  });

  testWidgets('Cattura la carta della notte del Rito del Sogno',
      (tester) async {
    silenceSensors();
    await loadFonts();
    final quando = DateTime(2026, 7, 13, 22, 40);
    await montaLoSchermo(tester, const Size(460, 1100));
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final maestro = DailyRituals.nightMaestro(quando);
    final rootKey = GlobalKey();
    await tester.pumpWidget(MaterialApp(
      // IL NASTRO DI DEBUG SPENTO. Un'anteprima col nastro non e' cio' che la
      // persona vede, ed e' il segno che la scena e' montata a mano invece che
      // presa dall'app. Cinque catture lo mostravano.
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF05060C),
        body: Center(
          child: RepaintBoundary(
            key: rootKey,
            child: DreamRiteCard(
              luna: DreamRiteCorpus.lunaDi(quando),
              palette: MaestroPalette.forKey(ThemeKey.of(maestro)),
              saluto: DreamRiteCorpus.saluto(quando),
              maestroNome: maestro.displayName,
            ),
          ),
        ),
      ),
    ));
    await step(tester);
    await capture(tester, rootKey, 'rito-sogno-carta.png');
  });

  // --- Il Sigillo del Cerchio, emblema personale procedurale ---
  testWidgets('Cattura il Sigillo del Cerchio', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    unawaited(nav.push(CircleSealScreen.route(name: 'Sofia')));
    await step(tester);
    // Lascia comporre il sigillo con la sua animazione, fino al Sole posato e al
    // Numero acceso.
    await tester.pump(const Duration(milliseconds: 2700));
    await capture(tester, rootKey, 'sigillo-cerchio.png');
  });

  // --- La Sinastria VIP, raggiungibile dallo scaffale del Santuario ---
  Future<void> precacheSinastria(WidgetTester tester) async {
    // Decodifica la cornice VIP e il ritratto pieno del VIP in testa, cosi'
    // l'anteprima del responso mostra l'arte reale e non il ripiego.
    await tester.runAsync(() async {
      final element = tester.element(find.byType(SinastriaVipScreen));
      await precacheImage(const AssetImage('assets/vip_cornice.webp'), element);
      final first = VipCatalog.first;
      if (first.fullPath != null) {
        await precacheImage(AssetImage(first.fullPath!), element);
      }
    });
    await step(tester);
    await step(tester);
  }

  testWidgets('Cattura la galleria di scelta della Sinastria VIP',
      (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
    // Superficie alta, cosi' la galleria mostra ricerca, filtri, In evidenza col
    // tasto A caso e le prime righe della griglia dei volti.
    await montaLoSchermo(tester, const Size(360, 1720));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    unawaited(nav.push(SinastriaGalleryScreen.route(userSign: Zodiac.gemini)));
    await step(tester);
    await step(tester);
    // Decodifica tutte le miniature, cosi' le tessere mostrano i volti.
    await tester.runAsync(() async {
      final element = tester.element(find.byType(SinastriaGalleryScreen));
      for (final vip in VipCatalog.vips) {
        if (vip.thumbPath != null) {
          await precacheImage(AssetImage(vip.thumbPath!), element);
        }
      }
    });
    await step(tester);
    await step(tester);
    await capture(tester, rootKey, 'sinastria-galleria.png');
  });

  testWidgets('Cattura la Sinastria VIP', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
    // Superficie alta quanto basta perche' l'anteprima mostri, oltre ai due
    // poli, anche le quattro barre, la riga di sfida, il tasto Condividi e il
    // tasto Cambia VIP che ha preso il posto del selettore in fondo.
    await montaLoSchermo(tester, const Size(360, 1340));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    unawaited(nav.push(SinastriaVipScreen.route()));
    await step(tester);
    await step(tester);
    await precacheSinastria(tester);
    await capture(tester, rootKey, 'sinastria-vip.png');
  });

  testWidgets('Cattura la Sinastria VIP col nome utente reale', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
    await montaLoSchermo(tester, const Size(360, 1340));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    // Nome e data reali sul polo di sinistra, cosi' si vede l'effetto personale.
    unawaited(nav.push(SinastriaVipScreen.route(
        userName: 'Sofia', userBirth: DateTime(1993, 4, 12))));
    await step(tester);
    await step(tester);
    await precacheSinastria(tester);
    await capture(tester, rootKey, 'sinastria-vip-personale.png');
  });

  // --- L'Animale Guida di Caligo: popup, rivelazione, responso, card ---
  Widget caligoApp(Widget schermata) => MultiProvider(
        providers: [
          // LO SCAFFALE PERSONALE, ordine P voce 27: senza di lui il cuore
          // delle arti preferite non si disegna, e l'anteprima mostrerebbe una
          // barra che nell'app ha un elemento in piu'.
          ChangeNotifierProvider(
              create: (_) => ArtiPreferiteController(maestroAssegnato: Maestro.caligo)),
          ChangeNotifierProvider(
              create: (_) =>
                  MaestroController(initial: const ThemeKey.of(Maestro.caligo))),
          ChangeNotifierProvider(
              create: (_) => QualityTierController()..setTier(QualityTier.medium)),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
          // Il piano e il contatore delle gettate, dall'ordine I: la
          // schermata delle rune li legge per il limite giornaliero.
          ChangeNotifierProvider(create: (_) => EntitlementService()),
          ChangeNotifierProvider(create: (_) => QuestionAllowance()),
          // LO STORICO CONDIVISO, che le schermate non si costruiscono piu' da
          // sole: chi le monta glielo fornisce, qui come nell'app.
          ChangeNotifierProvider(create: (_) => ArchetypeHistory()..carica()),
        ],
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.dark(),
            home: MaestroScope(child: schermata)),
      );

  /// Come `mountFace`, ordine P voce 27: la schermata entra dentro la SUA
  /// soglia, che la dichiara lei. Questo aggancio serve due arti di Caligo,
  /// l'Animale Guida e l'Estrazione Rune, e ognuna porta la propria.
  /// LA SOGLIA DELL'ARTE CHE SI STA MONTANDO, chiesta all'arte.
  ///
  /// L'aggancio delle catture di Caligo serve due arti: l'identificativo e il
  /// proprietario li dichiara ciascuna per se', qui si sceglie solo a quale
  /// chiederli. Scriverli in questo file sarebbe la seconda dichiarazione, ed e'
  /// il difetto che la voce 27 chiude.
  Widget _conLaSuaSoglia(Widget schermata) => switch (schermata) {
        RuneDrawScreen() => RuneDrawScreen.conLaSoglia(schermata),
        GuideAnimalScreen() => GuideAnimalScreen.conLaSoglia(schermata),
        _ => schermata,
      };

  Future<GlobalKey> mountAnimal(WidgetTester tester, Widget schermata,
      {required Size size}) async {
    await montaLoSchermo(tester, size);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final rootKey = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
        key: rootKey, child: caligoApp(_conLaSuaSoglia(schermata))));
    await step(tester);
    await step(tester);
    return rootKey;
  }

  Future<void> precacheTotem(WidgetTester tester) async {
    await tester.runAsync(() async {
      final element = tester.element(find.byType(GuideAnimalScreen));
      final animal = GuideAnimalDerivation.forSign(Zodiac.cancer);
      await precacheImage(AssetImage(animal.fullPath), element);
    });
    await step(tester);
  }


  void seedArchetipoCaligo() {
    final esito = ArchetypeEsito(
      quando: DateTime(2026, 7, 22, 10),
      percentuali: ArchetypeScoring.calcola(List.filled(12, 3)).percentuali,
      dominante: Archetype.realista,
    );
    SharedPreferences.setMockInitialValues({
      'archetipo.storico': [jsonEncode(esito.toJson())],
    });
  }

  testWidgets('Cattura il popup dell\'Animale Guida', (tester) async {
    silenceSensors();
    await loadFonts();
    // Senza Test Archetipo, il popup evocativo compare all'ingresso.
    SharedPreferences.setMockInitialValues({});
    final rootKey = await mountAnimal(
        tester, const GuideAnimalScreen(userSign: Zodiac.cancer),
        size: const Size(360, 900));
    await precacheTotem(tester);
    expect(find.byKey(const Key('animal_test_popup')), findsOneWidget);
    await capture(tester, rootKey, 'guide-animale-popup.png');
  });

  testWidgets('Cattura il viaggio col tamburo', (tester) async {
    silenceSensors();
    await loadFonts();
    // Con un archetipo salvato niente popup: si vede il viaggio col tamburo.
    seedArchetipoCaligo();
    final rootKey = await mountAnimal(
        tester, const GuideAnimalScreen(userSign: Zodiac.cancer),
        size: const Size(360, 900));
    expect(find.byKey(const Key('animal_journey')), findsOneWidget);
    // DALL'ORDINE L il viaggio e' la costellazione: si uniscono due stelle,
    // cosi' i pallini si accendono e la scena mostra la sagoma in cammino.
    await tester.tap(find.byKey(const Key('animal_star_0')));
    await step(tester);
    await tester.tap(find.byKey(const Key('animal_star_1')));
    await step(tester);
    await capture(tester, rootKey, 'guide-animale-viaggio.png');
  });

  testWidgets('Cattura la rivelazione nella nebbia', (tester) async {
    silenceSensors();
    await loadFonts();
    seedArchetipoCaligo();
    final rootKey = await mountAnimal(
        tester, const GuideAnimalScreen(userSign: Zodiac.cancer),
        size: const Size(360, 900));
    await precacheTotem(tester);
    // Compie il viaggio col tasto di ripiego, poi coglie un istante fisso della
    // dissolvenza: la nebbia e' ancora densa, gli occhi accesi, il totem affiora.
    await tester.tap(find.byKey(const Key('animal_journey_skip')));
    await tester.pump(const Duration(milliseconds: 400)); // supera il ritardo
    await tester.pump(const Duration(milliseconds: 600)); // dentro la nebbia
    await capture(tester, rootKey, 'guide-animale-rivelazione.png');
  });

  testWidgets('Cattura il Messaggio del Giorno col blocco di trasparenza',
      (tester) async {
    silenceSensors();
    await loadFonts();
    seedArchetipoCaligo();
    // Con la data di nascita la trasparenza mostra anche la Luna natale.
    final rootKey = await mountAnimal(
        tester,
        GuideAnimalScreen(
            userSign: Zodiac.cancer, userBirth: DateTime(1988, 7, 5, 9, 30)),
        size: const Size(360, 2000));
    await precacheTotem(tester);
    // Compie il viaggio, poi lascia posare la rivelazione, cosi' il totem e'
    // pieno e si vede il Messaggio del Giorno col blocco di trasparenza.
    await tester.tap(find.byKey(const Key('animal_journey_skip')));
    await tester.pump(const Duration(milliseconds: 400));
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 800));
    }
    expect(find.byKey(const Key('animal_result')), findsOneWidget);
    expect(find.byKey(const Key('animal_transparency')), findsOneWidget);
    await capture(tester, rootKey, 'guide-animale.png');
  });

  testWidgets('Cattura la lettura di identita\' dell\'Animale Guida',
      (tester) async {
    silenceSensors();
    await loadFonts();
    seedArchetipoCaligo();
    // La lettura fissa di identita', come si apre dal Cosmic Passport.
    final rootKey = await mountAnimal(
        tester,
        const GuideAnimalScreen(
            userSign: Zodiac.cancer, modo: GuideAnimalMode.identita),
        size: const Size(360, 1980));
    await precacheTotem(tester);
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 800));
    }
    expect(find.byKey(const Key('animal_identity')), findsOneWidget);
    await capture(tester, rootKey, 'guide-animale-identita.png');
  });

  testWidgets('Cattura la card dell\'Animale Guida', (tester) async {
    silenceSensors();
    await loadFonts();
    await montaLoSchermo(tester, const Size(460, 900));
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final animal = GuideAnimalDerivation.forSign(Zodiac.cancer);
    final rootKey = GlobalKey();
    await tester.pumpWidget(MaterialApp(
      // IL NASTRO DI DEBUG SPENTO. Un'anteprima col nastro non e' cio' che la
      // persona vede, ed e' il segno che la scena e' montata a mano invece che
      // presa dall'app. Cinque catture lo mostravano.
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF14060A),
        body: Center(
          child: RepaintBoundary(
            key: rootKey,
            child: GuideAnimalShareCard(
                animal: animal, origine: 'Dal tuo cielo, Cancro'),
          ),
        ),
      ),
    ));
    await tester.runAsync(() async {
      final element = tester.element(find.byType(MaterialApp));
      await precacheImage(AssetImage(animal.fullPath), element);
    });
    await step(tester);
    await capture(tester, rootKey, 'guide-animale-card.png');
  });

  testWidgets('Cattura la faccia dell\'Animale Guida nel Passport',
      (tester) async {
    silenceSensors();
    await loadFonts();
    SharedPreferences.setMockInitialValues({});
    await montaLoSchermo(tester, const Size(360, 1500));
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final rootKey = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
      key: rootKey,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => ArchetypeHistory()),
        ChangeNotifierProvider(create: (_) => NatalChartController()),
          ChangeNotifierProvider(create: (_) => QuestionAllowance()),
          ChangeNotifierProvider(create: (_) => EntitlementService()),
          ChangeNotifierProvider(create: (_) => QuestionAllowance()),
          ChangeNotifierProvider(
              create: (_) => QualityTierController()..setTier(QualityTier.medium)),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
          ChangeNotifierProvider(create: (_) => ProfileController()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(),
          home: const MaestroScope(child: CosmicPassport()),
        ),
      ),
    ));
    await step(tester);
    await tester.runAsync(() async {
      final element = tester.element(find.byType(CosmicPassport));
      final animal = GuideAnimalDerivation.forSign(
          NightSky.sunSign(BirthIdentity.example.birthMoment));
      await precacheImage(AssetImage(animal.thumbPath), element);
    });
    await step(tester);
    await tester.ensureVisible(find.byKey(const Key('passport_guide_animal')));
    await step(tester);
    await capture(tester, rootKey, 'guide-animale-passport.png');
  });

  testWidgets('Cattura la chat aperta con la domanda gia\' scritta',
      (tester) async {
    silenceSensors();
    await loadFonts();
    final services = await buildServices(Maestro.caligo, seeded: false);
    await montaLoSchermo(tester, const Size(360, 1000));
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final rootKey = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
      key: rootKey,
      child: MultiProvider(
        providers: [
          Provider<AppServices>.value(value: services),
          ChangeNotifierProvider(
              create: (_) =>
                  MaestroController(initial: const ThemeKey.of(Maestro.caligo))),
          ChangeNotifierProvider(
              create: (_) => QualityTierController()..setTier(QualityTier.medium)),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => ArchetypeHistory()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
          ChangeNotifierProvider(create: (_) => BirthIdentityController()),
          ChangeNotifierProvider(create: (_) => EntitlementService()),
          ChangeNotifierProvider(create: (_) => QuestionAllowance()),
          ChangeNotifierProvider(create: (_) => ProfileController()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(),
          home: Navigator(
            onGenerateRoute: (_) => MaestroChatScreen.route(
              maestro: Maestro.caligo,
              services: services,
              initialUserMessage:
                  ChatOpeners.animale(GuideAnimalDerivation.forSign(Zodiac.cancer).name),
            ),
          ),
        ),
      ),
    ));
    // SI ASPETTA QUANTO DURA LA PAUSA, chiesto al dato invece che contato a
    // mano. Erano otto pompate da 250, cioe' due secondi, che coprivano la
    // pausa vecchia da 1800 per un soffio: portata a 3200 la cattura e' caduta
    // con un timer ancora appeso. Un numero scritto a mano che dipende da un
    // altro numero prima o poi resta indietro.
    final quanto = TempiDellAttesa.allaPrimaParola(0) +
        TempiDellAttesa.durataBattuta;
    for (var i = 0; i < 10; i++) {
      await tester.pump(quanto ~/ 8);
    }
    await precacheFaces(tester);
    await capture(tester, rootKey, 'guide-animale-chat.png');
  });

  // --- L'Estrazione Rune di Caligo: soglia, lancio, rivelazioni, card ---
  Future<void> precacheRune(WidgetTester tester) async {
    await tester.runAsync(() async {
      final element = tester.element(find.byType(RuneDrawScreen));
      for (final r in kElderFuthark) {
        if (r.hasImage) {
          await precacheImage(AssetImage(r.thumbPath!), element);
          await precacheImage(AssetImage(r.fullPath!), element);
        }
      }
    });
    await step(tester);
  }

  // Sceglie la gettata e getta le rune col pulsante di ripiego.
  Future<void> lancia(WidgetTester tester, String segmento) async {
    await tester.tap(find.byKey(Key('rune_segment_$segmento')));
    await step(tester);
    final cast = find.byKey(const Key('rune_cast_button'));
    await tester.ensureVisible(cast);
    await tester.pump();
    await tester.tap(cast);
    // **TRE PASSI, NON UNO, E IL PERCHE' VA SCRITTO.** Con un passo solo le
    // anteprime del responso uscivano VUOTE sotto il conto delle gettate: il
    // presagio e le bolle delle rune stanno nell'albero, e le prove qui sotto lo
    // verificavano, ma erano dipinte a opacita' ZERO. Misurato: dopo 400
    // millisecondi il presagio e' a 0,00, dopo 1200 e' a 1,00.
    //
    // La causa e' in `ScrollReveal`: la comparsa ha UNA sola occasione, il
    // postFrame di `didChangeDependencies`, e se in quel frame la scatola non ha
    // ancora geometria l'occasione si perde. In un telefono la recupera il primo
    // scorrimento, che qui non arriva mai; la recupera invece il rimontaggio
    // successivo, e per quello serve piu' di un frame. **Un'anteprima vuota non
    // dice "va bene", dice che non si e' guardato niente**, e nasconde anche cio'
    // che la spedisce.
    await step(tester);
    await step(tester);
    await step(tester);
  }

  testWidgets('Cattura la soglia dell\'Estrazione Rune', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey = await mountAnimal(
        tester, RuneDrawScreen(userSign: Zodiac.aries, random: Random(7)),
        size: const Size(360, 1960));
    expect(find.byKey(const Key('rune_selector')), findsOneWidget);
    await capture(tester, rootKey, 'rune-soglia.png');
  });

  testWidgets('Cattura il lancio nel Pozzo di Urdhr', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey = await mountAnimal(
        tester, RuneDrawScreen(userSign: Zodiac.aries, random: Random(5)),
        size: const Size(360, 840));
    await precacheRune(tester);
    await lancia(tester, 'norne');
    expect(find.byKey(const Key('rune_result')), findsOneWidget);
    await capture(tester, rootKey, 'rune-lancio.png');
  });

  testWidgets('Cattura la rivelazione a tre Norne col presagio',
      (tester) async {
    silenceSensors();
    await loadFonts();
    // **3400 E NON 2900, misurato.** Il fondo del sigillo cade a 3295 punti: a
    // 2900 il sigillo restava FUORI dalla finestra, e `ScrollReveal` non rivela
    // cio' che non e' mai entrato in scena. L'anteprima mostrava la sua scatola
    // vuota e sembrava un difetto del sigillo.
    final rootKey = await mountAnimal(
        tester, RuneDrawScreen(userSign: Zodiac.aries, random: Random(5)),
        size: const Size(360, 3400));
    await precacheRune(tester);
    await lancia(tester, 'norne');
    expect(find.byKey(const Key('rune_presage')), findsOneWidget);
    expect(find.byKey(const Key('rune_sigillo')), findsOneWidget);
    await capture(tester, rootKey, 'rune-norne.png');
  });

  testWidgets('Cattura la Runa di Odino, una runa', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey = await mountAnimal(
        tester, RuneDrawScreen(userSign: Zodiac.aries, random: Random(9)),
        size: const Size(360, 2120));
    await precacheRune(tester);
    await lancia(tester, 'odino');
    await capture(tester, rootKey, 'rune-odino.png');
  });

  testWidgets('Cattura la Croce delle Cinque', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey = await mountAnimal(
        tester, RuneDrawScreen(userSign: Zodiac.aries, random: Random(4)),
        size: const Size(360, 3500));
    await precacheRune(tester);
    await lancia(tester, 'croce');
    await capture(tester, rootKey, 'rune-croce.png');
  });

  testWidgets('Cattura il getto sul telo, la sorte libera', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey = await mountAnimal(
        tester, RuneDrawScreen(userSign: Zodiac.aries, random: Random(6)),
        size: const Size(360, 3100));
    await precacheRune(tester);
    await lancia(tester, 'telo');
    expect(find.byKey(const Key('rune_result')), findsOneWidget);
    expect(find.byKey(const Key('rune_sigillo')), findsOneWidget);
    await capture(tester, rootKey, 'rune-getto.png');
  });

  testWidgets('Cattura la card dell\'Estrazione Rune', (tester) async {
    silenceSensors();
    await loadFonts();
    await montaLoSchermo(tester, const Size(460, 1320));
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final esito = RuneCast.getta(gettataNorne, random: Random(5));
    final presagio = RunePresagio.componi(esito);
    final rootKey = GlobalKey();
    await tester.pumpWidget(MaterialApp(
      // IL NASTRO DI DEBUG SPENTO. Un'anteprima col nastro non e' cio' che la
      // persona vede, ed e' il segno che la scena e' montata a mano invece che
      // presa dall'app. Cinque catture lo mostravano.
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF14060A),
        body: Center(
          child: RepaintBoundary(
            key: rootKey,
            child: RuneShareCard(esito: esito, presagio: presagio),
          ),
        ),
      ),
    ));
    await tester.runAsync(() async {
      final element = tester.element(find.byType(MaterialApp));
      for (final r in esito.rune) {
        if (r.rune.hasImage) {
          await precacheImage(AssetImage(r.rune.thumbPath!), element);
        }
      }
    });
    await step(tester);
    await capture(tester, rootKey, 'rune-card.png');
  });

  // --- L'Oroscopo a quattro schede, la headline di Medora ---
  testWidgets('Cattura l\'Oroscopo', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    // Un segno mostrato per intero, giorno fisso per un'anteprima stabile.
    // Superficie alta quanto basta prima di aprire, cosi' le forme a tema
    // finiscono il riempimento una volta sola: il segno per intero, quattro
    // schede piu' il tasto Condividi e il disclaimer, senza troppo vuoto.
    await montaLoSchermo(tester, const Size(360, 1560));
    // Ariete al 10 luglio 2026: valori variati tra le schede (2, 4, 5, 3), cosi'
    // si vede la differenza tra le quattro forme a tema.
    unawaited(nav.push(OroscopoScreen.route(
        userSign: Zodiac.aries, now: DateTime(2026, 7, 10))));
    await step(tester);
    await step(tester);
    // Decodifica l'emblema 3D del segno e i simboli dei chip, cosi' l'anteprima
    // mostra l'arte vera e non un posto vuoto.
    await tester.runAsync(() async {
      final element = tester.element(find.byType(OroscopoScreen));
      await precacheImage(
          AssetImage(ZodiacArt.emblemPath(Zodiac.aries)), element);
    });
    await step(tester);
    // **SI APRE IL CONSULTO**, altrimenti l'anteprima del corredo mostra una
    // pagina muta con mezzo schermo vuoto: dall'ordine 2171, voce 5, i responsi
    // arrivano solo dopo Interroga il cielo. Questa immagine deve mostrare la
    // funzione, non la sua soglia; l'apertura ha la sua anteprima a parte,
    // `oroscopo_apertura_dopo.png`.
    await tester.tap(find.byKey(const Key('oroscopo_interroga')));
    await step(tester);
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 3));
    // Lascia completare la micro-animazione di riempimento delle forme.
    await tester.pump(const Duration(seconds: 2));
    await capture(tester, rootKey, 'oroscopo.png');
  });

  // --- L'OROSCOPO CHE NOMINA UN TRANSITO VERO ---
  //
  // **E' l'immagine che dice se la voce e' stata consegnata.** L'altra
  // cattura mostra l'Oroscopo di chi ha dato solo la data di nascita, cioe' il
  // ripiego sulla hash, che adesso si dichiara in fondo. Qui invece c'e' una
  // carta natale completa, quindi la corrente del giorno la scrive il cielo:
  // il pianeta che si muove, la casa che sta attraversando, il punto della
  // carta che tocca. E la profondita' e' la Profonda, che e' l'altra cosa che
  // fino a ieri si pagava senza riceverla.
  testWidgets('Cattura l\'Oroscopo dai transiti veri', (tester) async {
    // **IL CAMMINO E' GIA' PERCORSO, ordine AR voce 09.** Col corpus della
    // revisione C interrogare il cielo matura un traguardo, e la celebrazione
    // si apre sopra la scena: il tocco sul selettore della profondita' cadeva
    // sulla festa che stava entrando, e il menu non si apriva mai. Il difetto
    // sfuggiva anche a chi stampava i testi a schermo, perche' una festa in
    // dissolvenza intercetta i tocchi prima di avere qualcosa da leggere.
    // Misurato per bisezione sui commit: questa cattura e' verde fino ad
    // AR.11 e rossa dal commit che porta il corpus nuovo. Con tutti i Sigilli
    // gia' accesi non matura niente, e sotto il dito c'e' l'Oroscopo.
    SharedPreferences.setMockInitialValues({
      'onboarding.done': true,
      'santuario.greeted': true,
      'cammino.generazione': 2,
      'cammino.accesi': [for (final t in Sentieri.tuttiITraguardi) t.id],
    });
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    final ctx = tester.element(find.byType(MaterialApp));
    // Un abbonato, perche' la Profonda e' del Cerchio Premium.
    ctx.read<EntitlementService>().setTier(Tier.tier2);
    // UNA CARTA COMPLETA, con l'ora: senza ora non ci sono case, e senza case
    // il testo parlerebbe di geometria invece che di settori della vita.
    ctx.read<BirthIdentityController>().setBirth(
          BirthDetails(
            date: DateTime(1990, 8, 10),
            time: const TimeOfDay(hour: 12, minute: 0),
            place: const astro.BirthPlace(
                label: 'Roma',
                latitude: 41.9,
                longitude: 12.5,
                timezone: 'Europe/Rome'),
          ),
          NatalChart(
            sunSign: Zodiac.leo,
            planets: const [
              PlanetPosition(
                  id: 'sun', name: 'Sole', glyph: '\u2609', longitude: 128.4, sign: Zodiac.leo),
              PlanetPosition(
                  id: 'moon', name: 'Luna', glyph: '\u263d', longitude: 12.7, sign: Zodiac.leo),
              PlanetPosition(
                  id: 'venus', name: 'Venere', glyph: '\u2640', longitude: 150.2, sign: Zodiac.leo),
              PlanetPosition(
                  id: 'mars', name: 'Marte', glyph: '\u2642', longitude: 61.9, sign: Zodiac.leo),
              PlanetPosition(
                  id: 'saturn', name: 'Saturno', glyph: '\u2644', longitude: 300.5, sign: Zodiac.leo),
            ],
            ascendantLongitude: 205.0,
            midheavenLongitude: 115.0,
            houses: [
              for (var n = 1; n <= 12; n++)
                HouseCusp(
                    number: n, longitude: (205.0 + (n - 1) * 30.0) % 360.0),
            ],
            hasTime: true,
          ),
        );
    await montaLoSchermo(tester, const Size(360, 1800));
    unawaited(nav.push(OroscopoScreen.route(
        userSign: Zodiac.leo, now: DateTime.utc(2026, 8, 5, 12))));
    await step(tester);
    await step(tester);
    await tester.runAsync(() async {
      final element = tester.element(find.byType(OroscopoScreen));
      await precacheImage(
          AssetImage(ZodiacArt.emblemPath(Zodiac.leo)), element);
    });
    await step(tester);
    // **SI CHIEDE IL CONSULTO.** Dall'ordine 2171, voce 5, l'oroscopo non e'
    // piu' a schermo all'apertura: lo si domanda col gesto Interroga il cielo.
    // Poi si aspettano i due tempi dichiarati dalla schermata, la pulsazione
    // dell'emblema e la scrittura dei responsi, perche' l'anteprima deve
    // mostrare i testi interi e non a meta' riga.
    await tester.tap(find.byKey(const Key('oroscopo_interroga')));
    await step(tester);
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 3));
    await step(tester);
    // Si sceglie la Profonda sulla scheda Generale: e' il gesto che ieri non
    // faceva niente.
    await tester.tap(find.byKey(const Key('oroscopo_depth_generale')));
    await step(tester);
    await tester.tap(find.text('Profonda').last);
    await step(tester);
    // Cambiando profondita' il testo e' un altro e si riscrive: due secondi
    // non bastavano piu', la scrittura ne dichiara due e sei decimi.
    await tester.pump(const Duration(seconds: 4));
    // IL GUARDIANO: se il testo non nominasse un transito vero, questa
    // immagine mostrerebbe il ripiego e direbbe il falso col suo nome.
    expect(find.textContaining('casa'), findsWidgets,
        reason: 'nessuna scheda nomina una casa: l\'anteprima dei transiti '
            'veri sta mostrando la hash');
    expect(find.byKey(const Key('oroscopo_nota_del_cielo')), findsNothing,
        reason: 'la nota del ripiego e\' a video, quindi il cielo non e\' '
            'stato letto');
    await capture(tester, rootKey, 'oroscopo-transito-vero.png');

    // DUE SCHEDE AFFIANCATE, per vedere che non usano la stessa forma.
    //
    // E' il difetto 1 dell'ordine OROSCOPO 4: nella build 2148 tutte le
    // schede dicevano il transito con la stessa sintassi, e in una schermata
    // sola si vedeva il modello del testo invece del testo. Qui si scorre
    // fino ad avere due schede nello stesso fotogramma.
    //
    // ALLA MISURA DEL TELEFONO, 360 per 797: la cattura di sopra usa uno
    // schermo alto apposta per far entrare tutte e quattro le schede, e a
    // quell'altezza l'immagine esce 1080 per 5400. Questa deve essere quella
    // che si vede in mano, quindi lo schermo torna alla sua misura.
    await montaLoSchermo(tester, const Size(360, 797));
    await step(tester);
    await tester.drag(find.byType(ListView).first, const Offset(0, -1180));
    await step(tester);
    await tester.pump(const Duration(seconds: 1));
    await capture(tester, rootKey, 'oroscopo-due-schede-affiancate.png');
  });

  // --- I TRE SENTIERI ALL'APERTURA. Ordine S voci 01 e 02 ---
  //
  // **All'apertura si resta sul disegno, fermi.** Prima della voce S.01 la
  // schermata scendeva da se' al traguardo raggiunto, quindi il disegno esisteva
  // e nessuno lo vedeva: queste tre immagini sono la prova a video che adesso e'
  // la prima cosa che si vede, e sono anche le tre che la voce S.02 confronta.
  //
  // **TRE STATI PER SENTIERO, e servono tutti e tre**, ordine S voce 02: a ZERO
  // si deve INTUIRE la forma senza vederla, a META' si deve capire in che
  // direzione sta crescendo, COMPLETA si deve riconoscere una figura e non una
  // nuvola di punti. Se a zero si vede gia' tutto, o se a meta' non si capisce
  // dove va, il disegno non e' finito.
  // **I NOVE NOMI PER INTERO, e non e' una ripetizione oziosa.** Il corredo
  // riconosce un'anteprima cercando il suo nome NELLA SORGENTE di questo file:
  // un nome composto a runtime non si trova, e le nove immagini risultavano
  // "orfane", cioe' prodotte da nessuno. Scritti qui, e confrontati sotto con
  // quello che la cattura usa davvero, i due non possono divergere.
  const nomiDeiSentieri = <String>[
    'sentiero-albero-zero.png',
    'sentiero-albero-meta.png',
    'sentiero-albero-completo.png',
    'sentiero-costellazione-zero.png',
    'sentiero-costellazione-meta.png',
    'sentiero-costellazione-completo.png',
    'sentiero-loto-zero.png',
    'sentiero-loto-meta.png',
    'sentiero-loto-completo.png',
  ];
  for (final sentiero in Sentiero.values) {
    for (final stato in const [
      ('zero', 0, 0),
      ('meta', 25, 2),
      ('completo', 50, 5),
    ]) {
      testWidgets('Cattura il sentiero ${sentiero.name} ${stato.$1}',
          (tester) async {
      silenceSensors();
      await loadFonts();
      final rootKey =
          await mount(tester, await buildServices(Maestro.medora, seeded: false));
      final ctx = tester.element(find.byType(MaterialApp));
      // UN CAMMINO A META', altrimenti il disegno e' tutto spento e non si
      // vedrebbe la figura che si compone coi gesti.
      // I MINI E I GRANDI dello stato chiesto: i grandi non si accendono da se'
      // quando i mini salgono, hanno le loro condizioni, e senza accenderli la
      // figura resterebbe senza le stelle che la reggono.
      final diario = ctx.read<DiarioDelCammino>();
      for (final t in Sentieri.miniDi(sentiero).take(stato.$2)) {
        await tester.runAsync(() => diario.accendi(t.id));
      }
      for (final t in Sentieri.grandiDi(sentiero).take(stato.$3)) {
        await tester.runAsync(() => diario.accendi(t.id));
      }
      await step(tester);
      final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
      unawaited(nav.push(SentieroScreen.route(sentiero)));
      await step(tester);
      await step(tester);
      await tester.pump(const Duration(seconds: 1));
      // IL GUARDIANO: se lo scorrimento non fosse a zero, l'immagine mostrerebbe
      // l'elenco e la voce S.01 non sarebbe quella che si vede.
      final scorrimento =
          tester.state<ScrollableState>(find.byType(Scrollable).last).position;
      expect(scorrimento.pixels, 0.0,
          reason: 'la schermata si e\' mossa da se\': l\'anteprima mostrerebbe '
              'l\'elenco invece del disegno');
      final nome = 'sentiero-${sentiero.name}-${stato.$1}.png';
      expect(nomiDeiSentieri, contains(nome),
          reason: 'questa cattura scrive un nome che non e\' fra i nove '
              'dichiarati: il corredo non lo trovera\' e l\'anteprima '
              'risultera\' orfana');
      await capture(tester, rootKey, nome);
      });
    }
  }

  // --- IL PORTAFOGLIO APERTO. Ordine S voce 06 ---
  //
  // **Le tre cose in una schermata sola**: il saldo, quando tornano i gesti del
  // giorno, e da dove sono arrivati gli ultimi Eos. Il saldo e i movimenti si
  // seminano qui perche' un portafoglio vuoto mostrerebbe soltanto la riga
  // dell'attesa, e la voce chiede di guardare cio' che vede chi ha camminato.
  testWidgets('Cattura il portafoglio aperto', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
    final ctx = tester.element(find.byType(MaterialApp));
    await tester.runAsync(() async {
      final registro = ctx.read<RegistroDegliEos>();
      await registro.segna(quanti: 10, perche: 'Il primo passo');
      await registro.segna(quanti: 5, perche: 'Tre giorni di seguito all\'alba');
      await registro.segna(quanti: 30, perche: 'La Costellazione a metà');
    });
    await step(tester);
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    unawaited(nav.push(SentieroScreen.route(Sentiero.costellazione)));
    await step(tester);
    await step(tester);
    // **IL SALDO SI SEMINA PER ULTIMO, e la prima stesura sbagliava qui.** Il
    // guscio dell'app crea il contatore con `..load()`, che legge il disco in
    // asincrono: seminato prima, il saldo veniva sovrascritto da quella lettura
    // e l'anteprima mostrava "0 Eos" accanto a tre movimenti in entrata, cioe'
    // esattamente il difetto del borsellino a zero della voce S.04.
    await tester.runAsync(() => ctx.read<QuestionAllowance>().applicaSaldo(45));
    await step(tester);
    await tester.tap(find.byKey(const Key('borsellino')));
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 60));
    }
    await capture(tester, rootKey, 'portafoglio-aperto.png');
  });

  // --- GLI EOS IN VOLO VERSO IL BORSELLINO. Ordine S voce 07 ---
  //
  // **Si cattura a meta' corsa**, perche' e' l'unico fotogramma in cui il volo si
  // vede: all'inizio le scintille sono un punto al centro, alla fine sono
  // spente sopra il numero. A meta' si legge la direzione, che e' cio' che la
  // voce chiede di far capire.
  testWidgets('Cattura gli Eos in volo', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
    final ctx = tester.element(find.byType(MaterialApp));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    unawaited(nav.push(SentieroScreen.route(Sentiero.costellazione)));
    await step(tester);
    await step(tester);
    await tester.runAsync(() => ctx.read<QuestionAllowance>().applicaSaldo(45));
    await step(tester);
    final dentro = tester.element(find.byKey(const Key('borsellino')));
    VoloDegliEos.lancia(dentro, quanti: 30);
    await tester.pump();
    await tester.pump(VoloDegliEos.durata * 0.45);
    await capture(tester, rootKey, 'eos-in-volo.png');
  });

  // --- LA CELEBRAZIONE BREVE SOPRA UNA SCHERMATA PIENA DI TESTO ---
  //
  // **Ordine S voce 09.** Sulla 2177 il testo della schermata sotto si leggeva
  // attraverso la festa, e due celebrazioni si dipingevano insieme. Questa
  // immagine e' la prova a video del velo: sotto ci sta il sentiero, che di testo
  // ne ha molto, e di quel testo non si deve leggere niente.
  testWidgets('Cattura la celebrazione breve col velo', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
    final ctx = tester.element(find.byType(MaterialApp));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    unawaited(nav.push(SentieroScreen.route(Sentiero.costellazione)));
    await step(tester);
    await step(tester);
    final dentro = tester.element(find.byKey(const Key('sentiero_disegno')));
    final mini = Sentieri.miniDi(Sentiero.costellazione).first;
    expect(
        mostraLaSovrimpressione(dentro,
            traguardi: [mini], sentieri: const [Sentiero.costellazione]),
        isTrue);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await capture(tester, rootKey, 'celebrazione-breve-col-velo.png');
  });

  // --- La card condivisibile dell'Oroscopo, CON LA RIGA DEL CIELO ---
  //
  // **Ordine P voce 25, chiusa il 12 agosto 2026 con la scelta di Mauro.** La
  // card porta il transito come riga in oro sotto la sintesi, quindi questa
  // cattura deve montare un cielo VERO: con la corrente presa dalla hash la riga
  // non esiste, e l'anteprima mostrerebbe la card di prima facendo credere che
  // la scelta non sia stata applicata.
  testWidgets('Cattura la card Oroscopo', (tester) async {
    await loadFonts();
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
    final carta = NatalChart(
      sunSign: Zodiac.aries,
      planets: const [
        PlanetPosition(
            id: 'sun',
            name: 'Sole',
            glyph: '\u2609',
            longitude: 18.4,
            sign: Zodiac.aries),
        PlanetPosition(
            id: 'moon',
            name: 'Luna',
            glyph: '\u263d',
            longitude: 102.7,
            sign: Zodiac.cancer),
        PlanetPosition(
            id: 'venus',
            name: 'Venere',
            glyph: '\u2640',
            longitude: 40.2,
            sign: Zodiac.taurus),
        PlanetPosition(
            id: 'mars',
            name: 'Marte',
            glyph: '\u2642',
            longitude: 251.9,
            sign: Zodiac.sagittarius),
        PlanetPosition(
            id: 'saturn',
            name: 'Saturno',
            glyph: '\u2644',
            longitude: 300.5,
            sign: Zodiac.aquarius),
      ],
      ascendantLongitude: 205.0,
      midheavenLongitude: 115.0,
      houses: [
        for (var n = 1; n <= 12; n++)
          HouseCusp(number: n, longitude: (205.0 + (n - 1) * 30.0) % 360.0),
      ],
      hasTime: true,
    );
    final cielo = CieloDiOggi.perIlGiorno(
        adesso: DateTime.utc(2026, 7, 9, 12), carta: carta);
    expect(cielo.ceCieloVero, isTrue,
        reason: 'il cielo del giorno scelto non porta nessun fatto, quindi la '
            'riga del cielo non ci sarebbe e l\'anteprima mostrerebbe la card '
            'di prima della voce 25');
    final cards = Horoscope.forSign(
        sign: Zodiac.aries, dayOfYear: 190, year: 2026, cielo: cielo);
    await montaLoSchermo(tester, const Size(400, 900));
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final rootKey = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
      key: rootKey,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color(0xFF0A0E24),
          body: Center(
            child: SingleChildScrollView(
              child: OroscopoShareCard(
                  sign: Zodiac.aries, cards: cards, palette: palette),
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    // L'emblema del segno decodificato anche nella card.
    await tester.runAsync(() async => precacheImage(
        AssetImage(ZodiacArt.emblemPath(Zodiac.aries)),
        tester.element(find.byType(OroscopoShareCard))));
    await tester.pumpAndSettle();
    // IL GUARDIANO: se la riga del cielo non fosse a schermo, questa immagine
    // mostrerebbe la card senza transito e nessuno se ne accorgerebbe.
    expect(find.byKey(const Key('share_transito_riga')), findsOneWidget,
        reason: 'la riga del cielo non e\' nella card: la composizione scelta '
            'per la voce 25 non e\' quella che l\'anteprima mostra');
    await capture(tester, rootKey, 'oroscopo-card.png');
  });

  // --- La Stesa a Tre Carte, con una carta rovesciata ---
  testWidgets('Cattura la Stesa a Tre Carte', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
    // La schermata e' lunga: sintesi, tre posizioni lette, dialogo, carta
    // chiave, consiglio, domanda, azioni e disclaimer.
    await montaLoSchermo(tester, const Size(360, 2360));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    // Seme 1: Fante di Bastoni rovesciato, Dieci di Coppe, La Luna rovesciata.
    // Scelto perche' contiene una carta di corte col suo numero, un nome su due
    // righe e due rovesciate.
    const spread = TarotSpread.reversedChance; // documenta la meccanica
    assert(spread > 0);
    unawaited(nav.push(MaterialPageRoute<void>(
      builder: (_) => const MaestroScope(
        child: StesaTreCarteScreen(
          seed: 1,
          revealAll: true,
          topic: TarotTopic.bivio,
        ),
      ),
    )));
    await step(tester);
    await step(tester);
    // Decodifica l'arte delle tre carte, cosi' l'anteprima mostra le carte vere.
    await tester.runAsync(() async {
      final element = tester.element(find.byType(StesaTreCarteScreen));
      for (final drawn in TarotSpread.draw(seed: 1).cards) {
        await precacheImage(AssetImage(drawn.card.fullPath), element);
      }
    });
    await step(tester);
    await tester.pump(const Duration(seconds: 2));
    await capture(tester, rootKey, 'stesa-tre-carte.png');
  });

  // --- La scena della Stesa a riposo, prima della scelta ---
  testWidgets('Cattura la scena della Stesa a riposo', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
    await montaLoSchermo(tester, const Size(360, 910));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    // Senza intro e senza carte gia' scelte: e' il ventaglio che aspetta, con
    // Medora sopra e i gesti del mazzo sotto.
    unawaited(nav.push(MaterialPageRoute<void>(
      builder: (_) => const MaestroScope(
        child: StesaTreCarteScreen(seed: 1, skipIntro: true),
      ),
    )));
    await step(tester);
    await step(tester);
    await tester.runAsync(() async {
      final element = tester.element(find.byType(StesaTreCarteScreen));
      await precacheImage(AssetImage(TarotDeck.dorsoFull), element);
    });
    // Si lascia finire l'ingresso a spirale e ci si ferma sul respiro. Serve
    // un secondo battito: la scena passa a riposo quando la Future
    // dell'ingresso si risolve, non nello stesso fotogramma.
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    await capture(tester, rootKey, 'stesa-scena.png');
  });

  // --- LE QUATTRO FASI DEL TAGLIO, una per una. Ordine P voce 05 ---
  //
  // **La voce 05 era stata MISURATA e non GUARDATA, e la differenza e' questa.**
  // Una prova sa dire che le fasi sono quattro, che la durata sta scritta in un
  // punto solo e che la meta' di sotto passa sopra: non sa dire se il gesto si
  // capisce guardandolo. Queste quattro immagini sono lo stesso taglio colto nel
  // mezzo di ciascuna fase, cioe' dove la fase e' al suo pieno.
  testWidgets('Cattura le quattro fasi del taglio', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
    await montaLoSchermo(tester, const Size(360, 1020));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    unawaited(nav.push(MaterialPageRoute<void>(
      builder: (_) => const MaestroScope(
        child: StesaTreCarteScreen(seed: 1, skipIntro: true),
      ),
    )));
    await step(tester);
    await step(tester);
    await tester.runAsync(() async {
      final element = tester.element(find.byType(StesaTreCarteScreen));
      await precacheImage(AssetImage(TarotDeck.dorsoFull), element);
    });
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 100));
    // IL GESTO VERO, quello che la persona fa col dito.
    await tester.tap(find.byKey(const Key('stesa_taglia')));
    await tester.pump();
    // Si cammina fino alla META' di ogni fase, e la si chiede alla schermata
    // invece di contare i millisecondi qui: se domani le durate cambiassero,
    // queste quattro immagini resterebbero al centro delle fasi nuove.
    final stato = tester.state(find.byType(StesaTreCarteScreen)) as dynamic;
    // I quattro nomi per intero, nell'ordine delle fasi, per la stessa ragione
    // detta sopra: un nome composto a pezzi non ha nessun generatore, agli
    // occhi di chi va a cercarlo.
    const nomi = [
      'stesa-taglio-1-raccolta.png',
      'stesa-taglio-2-divisione.png',
      'stesa-taglio-3-ricomposizione.png',
      'stesa-taglio-4-ristesa.png',
    ];
    expect(nomi, hasLength(TaglioFasi.fasi.length),
        reason: 'i nomi delle anteprime sono ${nomi.length} e le fasi '
            '${TaglioFasi.fasi.length}: una fase nuova resterebbe senza '
            'immagine, o un nome punterebbe a una fase che non esiste');
    var orologio = Duration.zero;
    for (var i = 0; i < TaglioFasi.fasi.length; i++) {
      final fase = TaglioFasi.fasi[i];
      // **IL CENTRO SI CHIEDE ALLA COREOGRAFIA**, `TaglioFasi.centroDi`, che
      // esiste per questo: sommare le durate qui vorrebbe dire scrivere una
      // seconda volta un conto che sta gia' scritto, e la prima stesura
      // sbagliava proprio quel conto, accumulando i centri invece degli inizi.
      final centro = StesaTiming.taglio * TaglioFasi.centroDi(i);
      await tester.pump(centro - orologio);
      orologio = centro;
      expect(stato.faseDelTaglioInScena, i,
          reason: 'a meta\' della fase ${fase.nome} la scena dice di essere '
              'nella fase ${stato.faseDelTaglioInScena}: l\'immagine '
              'mostrerebbe un\'altra fase da quella che il nome promette');
      await capture(tester, rootKey, nomi[i]);
    }
    // Il taglio finisce, altrimenti la prova chiude con un tempo ancora vivo.
    await tester.pump(TaglioFasi.totale);
    await tester.pump(const Duration(seconds: 6));
  });

  // --- MEDORA CI PENSA, PRIMA DI RISPONDERE. Ordine P voce 06 ---
  //
  // **L'anteprima che dice se l'attesa e' un'attesa e non un vuoto.** La prova
  // della voce sa contare le cinque righe e sa che i tempi vengono da
  // `TempiDellAttesa`: non sa dire se, guardandola, si capisce che dall'altra
  // parte qualcuno sta pensando.
  testWidgets('Cattura l\'attesa di Medora', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
    await montaLoSchermo(tester, const Size(360, 1020));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    unawaited(nav.push(MaterialPageRoute<void>(
      builder: (_) => const MaestroScope(
        child: StesaTreCarteScreen(seed: 1, skipIntro: true),
      ),
    )));
    await step(tester);
    await step(tester);
    await tester.runAsync(() async {
      final element = tester.element(find.byType(StesaTreCarteScreen));
      await precacheImage(AssetImage(TarotDeck.dorsoFull), element);
      // Il ritratto dalla PORTA UNICA del busto, la stessa che l'attesa usa.
      await precacheImage(
          AssetImage(BustoDelMaestro.assetDi(Maestro.medora)), element);
      for (final drawn in TarotSpread.draw(seed: 1).cards) {
        await precacheImage(AssetImage(drawn.card.fullPath), element);
      }
    });
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 100));
    // LE TRE CARTE, col gesto vero: l'attesa arriva solo dopo la terza.
    //
    // **Gli indici sono quelli del ventaglio A SCHERMO, non quelli del mazzo.**
    // Il ventaglio ne mostra una quindicina attorno al centro, quindi chiedere
    // la carta 20 vuol dire chiedere una carta che non e' montata: la prima
    // stesura cascava li'.
    for (final indice in const [38, 36, 41]) {
      await tester.tap(find.byKey(Key('stesa_fan_$indice')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 200));
    }
    // Dentro l'attesa, oltre la dissolvenza di ingresso: la si vuole piena.
    await tester.pump(AttesaDiMedora.dissolvenza);
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.byKey(const Key('stesa_attesa')), findsOneWidget,
        reason: 'l\'attesa non e\' in scena: l\'immagine mostrerebbe la '
            'schermata di prima e la voce 06 resterebbe non guardata');
    await capture(tester, rootKey, 'stesa-attesa-di-medora.png');
    // Si lascia scadere l'attesa e la scrittura del responso.
    //
    // **Non `pumpAndSettle`**: il cerchio di dodici stelle gira senza fine, che
    // e' cio' che lo rende un'attesa e non un vuoto, quindi la scena non si
    // assesta mai e la prova cadrebbe per un tempo scaduto invece che per
    // l'immagine. Si avanza a passi dichiarati.
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
  });

  // --- La Stesa con una carta gia' scelta, per vedere slot e ventaglio ---
  testWidgets('Cattura la Stesa in corso', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
    await montaLoSchermo(tester, const Size(360, 1020));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    unawaited(nav.push(MaterialPageRoute<void>(
      builder: (_) => const MaestroScope(
        child: StesaTreCarteScreen(seed: 1, skipIntro: true),
      ),
    )));
    await step(tester);
    await step(tester);
    await tester.runAsync(() async {
      final element = tester.element(find.byType(StesaTreCarteScreen));
      await precacheImage(AssetImage(TarotDeck.dorsoFull), element);
      for (final drawn in TarotSpread.draw(seed: 1).cards) {
        await precacheImage(AssetImage(drawn.card.fullPath), element);
      }
    });
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 100));
    // Si pesca una carta: cosi' si vede il rapporto fra slot e ventaglio, col
    // primo slot gia' scoperto e gli altri due che aspettano.
    await tester.tap(find.byKey(const Key('stesa_fan_38')));
    await tester.pump();
    // Il volo, poi il flip: servono due attese distinte, perche' il flip
    // parte solo quando la carta e' arrivata nel suo slot.
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 200));
    await capture(tester, rootKey, 'stesa-in-corso.png');
    // La schermata lascia in piedi un tempo che scade dopo la cattura: senza
    // farlo scadere qui, la prova finisce con un timer ancora vivo e cade per
    // quello, non per l'immagine.
    await tester.pump(const Duration(seconds: 6));
  });

  // --- L'aura elementale delle quattro carte, ferma a meta' fioritura ---
  testWidgets('Cattura il reveal elementale', (tester) async {
    await loadFonts();
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
    // Una carta per elemento, piu' un Maggiore per la fioritura solenne.
    final carte = [
      'Asso di Bastoni',
      'Asso di Coppe',
      'Asso di Denari',
      'Asso di Spade',
      'Il Mondo',
    ].map((n) => TarotDeck.cards.firstWhere((c) => c.name == n)).toList();

    await montaLoSchermo(tester, const Size(600, 250));
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final rootKey = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
      key: rootKey,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color(0xFF0A0E24),
          body: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                for (final c in carte)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          AspectRatio(
                            aspectRatio: TarotFrame.aspect,
                            child: TarotCardArt(card: c, palette: palette),
                          ),
                          Positioned.fill(
                            child: ElementalReveal(
                              spec: RevealSpec.of(c),
                              // Fermi a meta' fioritura: e' li' che l'aura si
                              // vede al suo pieno.
                              progress: 0.5,
                              palette: palette,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.runAsync(() async {
      final el = tester.element(find.byType(TarotCardArt).first);
      for (final c in carte) {
        await precacheImage(AssetImage(c.fullPath), el);
      }
    });
    await tester.pump();
    await capture(tester, rootKey, 'stesa-reveal.png');
  });

  // --- La card condivisibile della Stesa ---
  testWidgets('Cattura la card Stesa', (tester) async {
    await loadFonts();
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
    final spread = TarotSpread.draw(seed: 1);
    // La card e' cresciuta: argomento, estratto della lettura, carta chiave e
    // consiglio oltre alla sintesi.
    await montaLoSchermo(tester, const Size(420, 1080));
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final rootKey = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
      key: rootKey,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color(0xFF0A0E24),
          body: Center(
            child: SingleChildScrollView(
              child: StesaShareCard(
              spread: spread,
              palette: palette,
              topic: TarotTopic.bivio,
            ),
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      final element = tester.element(find.byType(StesaShareCard));
      for (final drawn in spread.cards) {
        await precacheImage(AssetImage(drawn.card.fullPath), element);
      }
    });
    await tester.pumpAndSettle();
    await capture(tester, rootKey, 'stesa-card.png');
  });

  // --- Il Santuario, alto pulito senza bolle sopra l'immagine ---
  testWidgets('Cattura il Santuario, alto pulito', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey = await mount(
        tester, await buildServices(Maestro.medora, seeded: false),
        clock: clockFor(Maestro.medora));
    selectCentral(tester, Maestro.medora);
    await step(tester);
    await precacheFaces(tester);
    await capture(tester, rootKey, 'santuario-alto.png');
  });

  // --- Il Calendario degli Eventi, dal centro della barra (ordine AN.03) ---
  testWidgets('Cattura il Calendario degli Eventi', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey = await mount(
        tester, await buildServices(Maestro.medora, seeded: false),
        clock: clockFor(Maestro.medora));
    await step(tester);
    // Si apre come si apre nell'app: dal centro della barra, con un tocco
    // solo. **Ordine AO voce 01**: prima ne servivano due, perche' il primo
    // apriva la fascia e il secondo colpiva i tre eventi; adesso al centro
    // c'e' la porta "Eventi Cosmici" e un tocco basta.
    await tester.tap(find.byKey(const Key('barra_eventi_cosmici')),
        warnIfMissed: false);
    await step(tester);
    await step(tester);
    await capture(tester, rootKey, 'calendario-degli-eventi.png');
  });

  // --- L'area Utente, aperta dall'icona in alto a destra nel Cerchio ---
  testWidgets('Cattura l\'area Utente', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey = await mount(
        tester, await buildServices(Maestro.medora, seeded: false),
        clock: clockFor(Maestro.medora));
    selectCentral(tester, Maestro.medora);
    await step(tester);
    await precacheFaces(tester);
    // Due tocchi: il primo apre la barra sottile, il secondo va all'account.
    await tester.tap(find.byKey(const Key('porta_dell_account')));
    await step(tester);
    await tester.tap(find.byKey(const Key('porta_dell_account')));
    await step(tester);
    await step(tester);
    await capture(tester, rootKey, 'area-utente.png');
  });

  // --- Il Santuario, scaffale delle funzioni a scorrimento ---
  // --- LA GIUNTURA FRA I MAESTRI E LO SCAFFALE. Ordine S voce 10 ---
  //
  // **La fascia morta si guarda, non si racconta.** La prova la misura in punti;
  // questa immagine la mostra alla larghezza reale, con la riga delle arti in alto
  // e "Le tue arti" sotto, cosi' si vede quanto respiro c'e' fra le due.
  testWidgets('Cattura la giuntura fra i Maestri e lo scaffale', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey = await mount(
        tester, await buildServices(Maestro.medora, seeded: false),
        clock: clockFor(Maestro.medora));
    selectCentral(tester, Maestro.medora);
    await step(tester);
    await precacheFaces(tester);
    // Si scorre finche' il titolo dello scaffale entra nella meta' alta: e' la
    // sola posizione in cui la giuntura si vede tutta.
    final titolo = find.byKey(const Key('tue_arti_titolo'), skipOffstage: false);
    // **LO SCORRIMENTO GIUSTO E' QUELLO VERTICALE, e non il primo che capita.**
    // `find.byType(Scrollable).first` prende la striscia dei doni del giorno, che
    // scorre in orizzontale: la prima stesura di questa cattura muoveva quella e
    // l'immagine restava in cima alla home.
    final position = tester
        .state<ScrollableState>(find.byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down))
        .position;
    for (var i = 0; i < 20; i++) {
      final scatola = tester.renderObject<RenderBox>(titolo);
      final dove = scatola.localToGlobal(Offset.zero).dy;
      if (dove > 200 && dove < 520) break;
      position.jumpTo(position.pixels + 60);
      await step(tester);
    }
    await capture(tester, rootKey, 'home-giuntura-scaffale.png');
  });

  testWidgets('Cattura il Santuario, scaffale funzioni', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey = await mount(
        tester, await buildServices(Maestro.medora, seeded: false),
        clock: clockFor(Maestro.medora));
    selectCentral(tester, Maestro.medora);
    await step(tester);
    await precacheFaces(tester);
    // Scorre sotto l'alto, cosi' l'anteprima mostra lo scaffale delle funzioni.
    final position =
        tester.state<ScrollableState>(find.byType(Scrollable).first).position;
    position.jumpTo(position.maxScrollExtent);
    await step(tester);
    await capture(tester, rootKey, 'santuario-scaffale.png');
  });

  // --- La striscia del giorno, dove ora vivono i quattro riti ---
  //
  // La card del Rito dell'Alba non sta piu' nel dominio del Maestro: il dominio
  // e' il luogo delle arti, i riti del giorno appartengono alla striscia del
  // Santuario. L'anteprima segue il posto vero.
  testWidgets('Cattura la striscia del giorno', (tester) async {
    silenceSensors();
    await loadFonts();
    final dawn = DailyRituals.dawnMaestro(DateTime.now());
    final rootKey =
        await mount(tester, await buildServices(dawn, seeded: false));
    selectCentral(tester, dawn);
    await step(tester);
    await precacheFaces(tester);
    await tester.ensureVisible(find.byKey(const Key('santuario_daily_strip')));
    await step(tester);
    await capture(tester, rootKey, 'striscia-del-giorno.png');
  });

  // --- L'hub di dominio e il Cosmic Passport ---
  testWidgets('Cattura l\'hub di dominio, medora', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
    selectCentral(tester, Maestro.medora);
    await step(tester);
    await tester.tap(find.byKey(const Key('santuario_central_bust')));
    await step(tester);
    await step(tester);
    await precacheFaces(tester);
    // Superficie alta, cosi' l'anteprima mostra la presenza, la Consulta e il
    // primo riquadro di sottocategoria per intero.
    await montaLoSchermo(tester, const Size(360, 2800));
    await step(tester);
    await capture(tester, rootKey, 'dominio-medora.png');

    // Lo stesso dominio coi gruppi APERTI: il collasso raccoglie le arti in
    // cammino, quindi la seconda anteprima mostra cosa c'e' dietro. Si aprono
    // gli apri e chiudi delle sottocategorie vive e le intestazioni di quelle
    // tutte in arrivo, poi si cattura.
    // La lista e' pigra e le sottocategorie in fondo non sono ancora costruite:
    // si scorre fino a ciascuna prima di toccarla, nell'ordine in cui stanno.
    for (final chiave in const [
      'art_soon_toggle_astrologia',
      'art_soon_toggle_cartomanzia',
      'art_section_header_lunologia',
      'art_section_header_destino',
    ]) {
      final f = find.byKey(Key(chiave));
      await tester.scrollUntilVisible(f, 300,
          scrollable: find.byType(Scrollable).first);
      await tester.ensureVisible(f);
      await step(tester);
      await tester.tap(f);
      await step(tester);
      await step(tester);
    }
    // Coi gruppi aperti la lista cresce oltre la finestra della cattura: si
    // guarda il fondo, dove stanno le sottocategorie tutte in cammino.
    final position =
        tester.state<ScrollableState>(find.byType(Scrollable).first).position;
    position.jumpTo(position.maxScrollExtent);
    await step(tester);
    await step(tester);
    await capture(tester, rootKey, 'dominio-medora-aperto.png');
  });

  // Lo stesso impianto generico visto dal dominio di Aura: nessun codice suo,
  // solo il catalogo diverso, quindi l'anteprima serve a verificarlo a video.
  testWidgets('Cattura l\'hub di dominio, aura', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.aura, seeded: false));
    selectCentral(tester, Maestro.aura);
    await step(tester);
    await tester.tap(find.byKey(const Key('santuario_central_bust')));
    await step(tester);
    await step(tester);
    await precacheFaces(tester);
    await montaLoSchermo(tester, const Size(360, 2800));
    await step(tester);
    await capture(tester, rootKey, 'dominio-aura.png');

    for (final chiave in const [
      'art_soon_toggle_energia',
      'art_soon_toggle_archetipi',
      'art_section_header_chakra',
    ]) {
      final f = find.byKey(Key(chiave));
      await tester.scrollUntilVisible(f, 300,
          scrollable: find.byType(Scrollable).first);
      await tester.ensureVisible(f);
      await step(tester);
      await tester.tap(f);
      await step(tester);
      await step(tester);
    }
    final posAura =
        tester.state<ScrollableState>(find.byType(Scrollable).first).position;
    posAura.jumpTo(posAura.maxScrollExtent);
    await step(tester);
    await step(tester);
    await capture(tester, rootKey, 'dominio-aura-aperto.png');
  });

  // Caligo: tre sottocategorie tutte miste, ciascuna con la sua distintiva.
  testWidgets('Cattura l\'hub di dominio, caligo', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.caligo, seeded: false));
    selectCentral(tester, Maestro.caligo);
    await step(tester);
    await tester.tap(find.byKey(const Key('santuario_central_bust')));
    await step(tester);
    await step(tester);
    await precacheFaces(tester);
    await montaLoSchermo(tester, const Size(360, 2800));
    await step(tester);
    await capture(tester, rootKey, 'dominio-caligo.png');

    // La Cabala non ha piu' un'arte viva, uscito l'Albero della Vita dalla
    // Demo: si apre dalla sua intestazione invece che dal toggle.
    for (final chiave in const [
      'art_soon_toggle_rune',
      'art_soon_toggle_rituali',
      'art_section_header_cabala',
    ]) {
      final f = find.byKey(Key(chiave));
      await tester.scrollUntilVisible(f, 300,
          scrollable: find.byType(Scrollable).first);
      await tester.ensureVisible(f);
      await step(tester);
      await tester.tap(f);
      await step(tester);
      await step(tester);
    }
    final posCaligo =
        tester.state<ScrollableState>(find.byType(Scrollable).first).position;
    posCaligo.jumpTo(posCaligo.maxScrollExtent);
    await step(tester);
    await step(tester);
    await capture(tester, rootKey, 'dominio-caligo-aperto.png');
  });

  testWidgets('Cattura il Cosmic Passport', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
    await tester.tap(find.text('Passport'));
    await step(tester);
    await capture(tester, rootKey, 'passport.png');
  });

  /// LA TESSERA VIVA DELL'ARCHETIPO, col Test gia' fatto.
  ///
  /// La cattura qui sopra mostra il Passaporto di chi il Test non l'ha fatto,
  /// e la tessera dell'archetipo li' dentro dice cosa fare. Questa mostra
  /// l'altra meta': l'emblema vero, il nome con l'articolo e la data.
  testWidgets('Cattura la tessera dell archetipo nel Passaporto',
      (tester) async {
    silenceSensors();
    // Il Test gia' fatto, sul disco: e' cio' che l'app trova all'apertura.
    SharedPreferences.setMockInitialValues({
      'onboarding.done': true,
      'archetipo.storico': [
        jsonEncode(ArchetypeEsito(
          quando: DateTime(2026, 8, 3, 18, 30),
          percentuali:
              ArchetypeScoring.calcola(List.filled(12, 3)).percentuali,
          dominante: Archetype.realista,
        ).toJson()),
      ],
    });
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
    await tester.tap(find.text('Passport'));
    await step(tester);

    // IL PRECARICO PRIMA DELLA CATTURA: senza, l'emblema non si decodifica in
    // headless e la tessera esce con un buco al posto dell'arte.
    await tester.runAsync(() async {
      await precacheImage(AssetImage(Archetype.realista.arteThumb),
          tester.element(find.byType(MaterialApp)));
    });
    await step(tester);

    // **PRIMA SI CONGEDA LA FESTA, e questa riga nasce guardando
    // l'anteprima.** Visitare il Passaporto matura dei traguardi, quindi
    // sopra la tessera si apriva una celebrazione a schermo pieno: lo scatto
    // usciva con la festa e non con l'archetipo, mentre la verifica qui
    // sotto passava lo stesso, perche' un widget coperto e' comunque
    // nell'albero. E' la misura che guarda la cosa sbagliata, di nuovo.
    for (var giro = 0; giro < 4; giro++) {
      final congedo = find.byKey(const Key('celebrazione_continua'));
      if (congedo.evaluate().isEmpty) break;
      await tester.tap(congedo.first, warnIfMissed: false);
      await step(tester);
    }
    // **E ANCHE LA FASCIA IN SOVRIMPRESSIONE**, che non ha un congedo da
    // toccare: se ne va da sola dopo il suo tempo, e qui si aspetta invece
    // di fotografarla addosso alla tessera.
    for (var giro = 0; giro < 10; giro++) {
      if (find
          .byKey(const Key('sovrimpressione_del_traguardo'))
          .evaluate()
          .isEmpty) {
        break;
      }
      await tester.pump(const Duration(seconds: 1));
    }
    await tester.ensureVisible(find.byKey(const Key('passport_archetipo')));
    await step(tester);
    // LA VERIFICA PRIMA DELLO SCATTO. Un'anteprima esce lo stesso anche senza
    // cio' che dovrebbe mostrare, e sembra una prova.
    expect(find.byKey(const Key('celebrazione_nome')), findsNothing,
        reason: 'la festa copre ancora la tessera che questa anteprima '
            'dovrebbe mostrare');
    expect(find.byKey(const Key('sovrimpressione_del_traguardo')), findsNothing,
        reason: 'la fascia della celebrazione vela ancora la tessera');
    expect(find.byKey(const Key('passport_archetipo_nome')), findsOneWidget);
    expect(
        tester
            .widget<Text>(find.byKey(const Key('passport_archetipo_quando')))
            .data,
        'Scoperto il 3/8/2026');
    await capture(tester, rootKey, 'passport-archetipo.png');
  });

  // --- Il cielo di nascita, aperto dal portale del Cosmic Passport ---
  testWidgets('Cattura Il tuo cielo di nascita', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
    await tester.tap(find.text('Passport'));
    await step(tester);
    // Dal portale attivo del passaporto si apre la volta di nascita, immersiva
    // e fissa. Non chiede la posizione: il luogo e' quello della nascita.
    await tester.tap(find.byKey(const Key('passport_birth_sky')));
    await step(tester);
    await step(tester);
    await capture(tester, rootKey, 'cielo-di-nascita.png');
  });

  testWidgets('Cattura le Impostazioni', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
    await tester.tap(find.text('Passport'));
    await step(tester);
    // La rotellina non c'e' piu' (ordine AK voce 03): la via e' porta
    // dell'account, "Il tuo account", voce Impostazioni.
    // **DUE TOCCHI dall'ordine AM voce 04**: il volto vive nella barra
    // sottile in alto, e il primo tocco la apre invece di portare via.
    for (var tocco = 0; tocco < 2; tocco++) {
      await tester.tap(find.byKey(const Key('porta_dell_account')).last,
          warnIfMissed: false);
      for (var g = 0; g < 5; g++) {
        await tester.pump(const Duration(milliseconds: 120));
      }
    }
    await tester.tap(find.byKey(const Key('account_impostazioni')),
        warnIfMissed: false);
    await step(tester);
    await step(tester);
    await capture(tester, rootKey, 'impostazioni.png');
  });

  // --- La sezione Profilo dell'Area Utente, col volto dell'utente ---
  testWidgets('Cattura il Profilo', (tester) async {
    silenceSensors();
    await loadFonts();
    await montaLoSchermo(tester, const Size(360, 844));
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Un segno impostato, cosi' l'avatar di default mostra l'emblema del segno.
    final birth = BirthIdentityController()
      ..setBirth(
        BirthDetails(
          date: DateTime(1990, 8, 10),
          time: const TimeOfDay(hour: 12, minute: 0),
          place: const astro.BirthPlace(
              label: 'Roma',
              latitude: 41.9,
              longitude: 12.5,
              timezone: 'Europe/Rome'),
        ),
        NatalChart.essential(sunSign: Zodiac.leo, hasTime: false),
      );

    final rootKey = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: rootKey,
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ProfileController()),
            ChangeNotifierProvider<BirthIdentityController>.value(value: birth),
            ChangeNotifierProvider(create: (_) => MaestroController()),
            ChangeNotifierProvider(create: (_) => ArchetypeHistory()),
        ChangeNotifierProvider(create: (_) => NatalChartController()),
          ChangeNotifierProvider(create: (_) => QuestionAllowance()),
          ChangeNotifierProvider(create: (_) => EntitlementService()),
          ChangeNotifierProvider(create: (_) => QuestionAllowance()),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            builder: (ctx, child) => MediaQuery(
              data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
              child: MaestroScope(child: child!),
            ),
            home: const ProfileScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      final element = tester.element(find.byType(MaterialApp));
      await precacheImage(
          const AssetImage('assets/img/zodiac/zod_leone.webp'), element);
    });
    await tester.pumpAndSettle();
    await capture(tester, rootKey, 'profilo.png');
  });

  // --- I piani del Cerchio, aperti dalle Impostazioni ---
  testWidgets('Cattura i piani del Cerchio', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mount(tester, await buildServices(Maestro.medora, seeded: false));
    await tester.tap(find.text('Passport'));
    await step(tester);
    // La rotellina non c'e' piu' (ordine AK voce 03): la via e' porta
    // dell'account, "Il tuo account", voce Impostazioni.
    // **DUE TOCCHI dall'ordine AM voce 04**: il volto vive nella barra
    // sottile in alto, e il primo tocco la apre invece di portare via.
    for (var tocco = 0; tocco < 2; tocco++) {
      await tester.tap(find.byKey(const Key('porta_dell_account')).last,
          warnIfMissed: false);
      for (var g = 0; g < 5; g++) {
        await tester.pump(const Duration(milliseconds: 120));
      }
    }
    await tester.tap(find.byKey(const Key('account_impostazioni')),
        warnIfMissed: false);
    await step(tester);
    await step(tester);
    await tester.tap(find.byKey(const Key('settings_plans')));
    await step(tester);
    await step(tester);
    // Superficie alta, cosi' l'anteprima mostra la card Demo e i quattro livelli.
    await montaLoSchermo(tester, const Size(360, 2600));
    await step(tester);
    await capture(tester, rootKey, 'piani.png');
  });

  // --- La chat che instrada verso una funzione immersiva ---
  testWidgets('Cattura la chat che instrada a una funzione', (tester) async {
    silenceSensors();
    await loadFonts();
    final memory = InMemoryMaestroMemoryRepository();
    await memory.saveProfile(
        UserProfile(disclaimerAcceptedAt: DateTime(2026, 7, 1)));
    final intent = ImmersiveIntents.all
        .firstWhere((i) => i.target == ImmersiveTarget.tarocchiStesa);
    await memory.appendMessage(Maestro.medora,
        const ChatMessage(role: ChatRole.user, text: 'Puoi leggermi i tarocchi?'));
    await memory.appendMessage(
        Maestro.medora,
        ChatMessage(
            role: ChatRole.maestro, text: intent.invite, intentId: intent.id));
    final services = AppServices(
      ai: _ScriptedMaestro(),
      memory: memory,
      memoryPersistent: true,
      diagnostics: 'Cattura offline.',
    );
    final rootKey = await mount(tester, services);
    await openChat(tester, Maestro.medora);
    await precacheFaces(tester);
    await capture(tester, rootKey, 'chat-instradamento.png');
  });

  // --- IL CONSULTO NELLA CHAT VERA, a conversazione vuota e piena ---
  //
  // La stessa scena nelle due situazioni che decidono la sua misura: senza
  // niente sopra prende tutto lo spazio che avanza, con la conversazione piena
  // si stringe. Sono due immagini e non una perche' la regola e' proprio la
  // differenza fra le due.
  // I NOMI SCRITTI PER ESTESO, non composti a runtime: la prova che ogni
  // anteprima abbia un generatore cerca il nome nel sorgente del corredo, e un
  // nome montato con un ternario non lo trova. L'ha bocciata, ed era giusto.
  const consultoNellaChat = <String, bool>{
    'consulto-chat-vuota.png': false,
    'consulto-chat-piena.png': true,
  };

  // IL SIMBOLO CHE SI COMPONE, nei tre istanti che contano.
  //
  // All'inizio, a META' e a composizione INTERA, tre file di peso diverso: due
  // fotogrammi che pesano uguale sono lo stesso fotogramma, ed e' successo con
  // la coppia del Riduci Movimento, che pesava 105.481 byte in tutti e due i
  // file. L'istante zero c'e' perche' e' quello che decide se l'effetto
  // funziona, e la sua assenza ha fatto diagnosticare male due volte il
  // difetto precedente.
  //
  // **Qui c'era l'emblema che si colorava, e non c'e' piu'.** Si accendeva il
  // volto del Maestro passando da grigio a colore: era una lettura sbagliata
  // di cio' che il fondatore aveva chiesto, che era un SIMBOLO della persona.
  const composizione = <String, Duration>{
    'consulto-simbolo-inizio.png': Duration.zero,
    'consulto-simbolo-meta.png': Duration(milliseconds: 1500),
    'consulto-simbolo-intero.png': Duration(milliseconds: 3000),
  };
  for (final istante in composizione.entries) {
    testWidgets('Cattura ${istante.key}', (tester) async {
      silenceSensors();
      await loadFonts();
      await montaLoSchermo(tester, schermoReale);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final rootKey = GlobalKey();
      await tester.pumpWidget(RepaintBoundary(
        key: rootKey,
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => QualityTierController()),
            ChangeNotifierProvider(create: (_) => MaestroController()),
            ChangeNotifierProvider(create: (_) => ArchetypeHistory()),
            ChangeNotifierProvider(create: (_) => ParallaxController()),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: MaestroScope(
              maestro: Maestro.medora,
              child: Scaffold(
                backgroundColor: const Color(0xFF080B1A),
                body: Center(
                  child: ConsultoDelCieloView(
                    natal: NatalContext(
                      sunSign: Zodiac.leo.italianName,
                      moonSign: Zodiac.pisces.italianName,
                      ascendant: Zodiac.virgo.italianName,
                    ),
                    maestro: Maestro.medora,
                  ),
                ),
              ),
            ),
          ),
        ),
      ));
      await tester.pump();
      await precacheFaces(tester);
      await tester.pump(istante.value);
      await capture(tester, rootKey, istante.key);
    });
  }
  for (final caso in consultoNellaChat.entries) {
    final piena = caso.value;
    testWidgets('Cattura ${caso.key}', (tester) async {
      silenceSensors();
      await loadFonts();
      final memory = InMemoryMaestroMemoryRepository();
      await memory
          .saveProfile(UserProfile(disclaimerAcceptedAt: DateTime(2026, 7, 1)));
      if (piena) {
        for (final (role, text) in seedFor(Maestro.medora)) {
          await memory.appendMessage(
              Maestro.medora, ChatMessage(role: role, text: text));
        }
      }
      final services = AppServices(
        ai: _VoceCheFaAspettare(),
        memory: memory,
        memoryPersistent: true,
        diagnostics: 'Cattura offline.',
      );
      final rootKey = await mount(tester, services);
      // I DATI DI NASCITA, cosi' la scena guarda un corpo vero di questa
      // persona invece del punto luminoso che spetta a chi non ne ha dati.
      tester
          .element(find.byType(MaterialApp))
          .read<BirthIdentityController>()
          .setBirth(
            BirthDetails(
              date: DateTime(1990, 8, 10),
              time: const TimeOfDay(hour: 12, minute: 0),
              place: const astro.BirthPlace(
                  label: 'Roma',
                  latitude: 41.9,
                  longitude: 12.5,
                  timezone: 'Europe/Rome'),
            ),
            NatalChart.essential(sunSign: Zodiac.leo, hasTime: false),
          );
      await step(tester);
      await openChat(tester, Maestro.medora);
      await precacheFaces(tester);

      // Si fa una domanda e la si lascia in volo: la scena del consulto vive
      // esattamente li'.
      final campo = find.descendant(
        of: find.byType(ChatComposer),
        matching: find.byType(TextField),
      );
      await tester.enterText(campo, 'Devo cambiare lavoro?');
      await step(tester);
      await tester.testTextInput.receiveAction(TextInputAction.send);
      for (var i = 0; i < 8; i++) {
        await step(tester);
      }
      await precacheFaces(tester);
      await capture(tester, rootKey, caso.key);
    });
  }

  // --- LA RISPOSTA BREVE, LA STELLA, E IL SEGUITO CHE ARRIVA AL TOCCO ---
  //
  // **Tre fotogrammi, e la differenza fra loro e' la voce intera.**
  //
  // 1. La risposta breve, che finisce con la STELLA e il consiglio in oro: e'
  //    la cosa che una persona di fretta legge al posto di tutto il resto.
  // 2. La stessa dopo il tocco, col seguito inserito FRA il corpo e il
  //    consiglio: la stella resta l'ultima riga, che e' il vincolo che decide
  //    dove il seguito si infila.
  // 3. L'ATTESA DEL SEGUITO, che e' il fotogramma in mezzo: la persona ha
  //    appena toccato, e cio' che stava leggendo e' ancora tutto li'. Prima
  //    di oggi qui ripartiva la scena a schermo intero e la bolla si
  //    svuotava, e questa immagine e' la prova che non succede piu'.
  // 4. Come la vede un VIANDANTE: la freccia si vede lo stesso, perche' un
  //    lucchetto muto e' un vicolo cieco, e al tocco porta agli abbonamenti.
  for (final caso in const ['breve', 'seguito', 'attesa', 'viandante']) {
    final dopoIlTocco = caso == 'seguito' || caso == 'attesa';
    final durante = caso == 'attesa';
    final viandante = caso == 'viandante';
    final nome = {
      'breve': 'chat-breve-con-la-stella.png',
      'seguito': 'chat-seguito-col-consiglio-in-fondo.png',
      'attesa': 'chat-attesa-del-seguito-nella-bolla.png',
      'viandante': 'chat-freccia-per-il-viandante.png',
    }[caso]!;
    testWidgets('Cattura $nome', (tester) async {
      silenceSensors();
      await loadFonts();
      final memory = InMemoryMaestroMemoryRepository();
      await memory
          .saveProfile(UserProfile(disclaimerAcceptedAt: DateTime(2026, 7, 1)));
      final services = AppServices(
        // Nel caso dell'attesa il seguito ci mette del tempo, perche' e'
        // esattamente il tempo che questa immagine deve mostrare.
        ai: _VoceInDueStrati(
            ritardoDelSeguito:
                durante ? const Duration(seconds: 4) : Duration.zero),
        memory: memory,
        memoryPersistent: true,
        diagnostics: 'Cattura offline.',
      );
      final rootKey = await mount(tester, services);
      // IL LIVELLO decide cosa succede al tocco della freccia: chi ha il
      // secondo strato nel cammino riceve il seguito, il Viandante arriva
      // agli abbonamenti. Sono due immagini della stessa schermata.
      tester
          .element(find.byType(MaterialApp))
          .read<EntitlementService>()
          .setTier(viandante ? Tier.free : Tier.tier1);
      tester
          .element(find.byType(MaterialApp))
          .read<BirthIdentityController>()
          .setBirth(
            BirthDetails(
              date: DateTime(1990, 8, 10),
              time: const TimeOfDay(hour: 12, minute: 0),
              place: const astro.BirthPlace(
                  label: 'Roma',
                  latitude: 41.9,
                  longitude: 12.5,
                  timezone: 'Europe/Rome'),
            ),
            NatalChart.essential(sunSign: Zodiac.leo, hasTime: false),
          );
      await step(tester);
      await openChat(tester, Maestro.medora);
      await precacheFaces(tester);
      // IL GLIFO DEL SEGNO, precaricato a mano.
      //
      // Accanto ai messaggi della persona c'e' il simbolo del suo segno, non
      // la sua iniziale. Le catture locali non decodificano gli asset da sole,
      // e senza questa riga nell'anteprima restava un tondo dorato vuoto: un
      // difetto della cattura, non dell'app, ma un'anteprima che mostra un
      // buco e' un'anteprima che dice il falso.
      await tester.runAsync(() async {
        final el = tester.element(find.byType(MaterialApp));
        // Tutte e due le arti del segno: il tondo accanto ai messaggi usa
        // l'emblema grande, la scena dell'attesa la miniatura.
        await precacheImage(AssetImage(ZodiacArt.emblemPath(Zodiac.leo)), el);
        await precacheImage(AssetImage(ZodiacArt.symbolPath(Zodiac.leo)), el);
      });
      await step(tester);

      final campo = find.descendant(
        of: find.byType(ChatComposer),
        matching: find.byType(TextField),
      );
      await tester.enterText(campo, 'Devo cambiare lavoro?');
      await step(tester);
      await tester.testTextInput.receiveAction(TextInputAction.send);
      // La pausa minima piu' la scrittura a macchina da scrivere.
      for (var i = 0; i < 30; i++) {
        await step(tester);
      }
      if (dopoIlTocco) {
        // LA FRECCIA VA PRIMA PORTATA IN VISTA: la chat scorre all'inizio
        // della risposta, quindi il fondo della bolla, con la freccia, resta
        // sotto la piega, dietro il compositore sospeso della voce 2 del
        // 2161. Un tocco fuori vista non tocca niente, e l'attesa che questa
        // cattura fotografa non partirebbe mai.
        // In vista non basta: sotto il vetro della barra il contenuto si
        // vede ma il tocco lo prende il vetro. Si porta la lista a fondo
        // corsa, dove il fondo interno solleva l'ultima bolla sopra il
        // compositore, come farebbe il dito di chi vuole toccare.
        for (var i = 0; i < 3; i++) {
          await tester.drag(find.byType(ListView).first,
              const Offset(0, -400), warnIfMissed: false);
          await step(tester);
        }
        await tester.tap(find.byKey(const Key('chat_approfondisci')));
        // DUE PASSI SOLI PER L'ATTESA, e non dodici: con dodici il seguito
        // sarebbe gia' sceso e l'immagine mostrerebbe l'altro fotogramma.
        for (var i = 0; i < (durante ? 2 : 12); i++) {
          await step(tester);
        }
        if (durante) {
          expect(find.byKey(const Key('chat_seguito_in_arrivo')),
              findsOneWidget,
              reason: 'l\'anteprima dell\'attesa non ha nessuna attesa dentro '
                  'da mostrare: mostrerebbe il falso');
          expect(find.byKey(const Key('chat_seguito')), findsNothing);
        }
      }
      await precacheFaces(tester);
      await capture(tester, rootKey, nome);
      // SI SCOLA L'ATTESA prima di chiudere: il ritardo del seguito e' un
      // timer vero, e lasciarlo pendente fa cadere la cattura sull'albero
      // gia' smontato.
      if (durante) {
        for (var i = 0; i < 20; i++) {
          await step(tester);
        }
      }
    });
  }

  // --- LA BOLLA DELLA CHAT COL CONTATORE, a tre e a uno ---
  //
  // **E' il difetto 4 dell'ordine OROSCOPO 4 e CHAT 12.** Nella build 2148 si
  // leggeva "Oggi te ne resta 3 su 3", che e' sgrammaticato: al plurale ci
  // vuole "te ne restano". Due immagini perche' l'accordo si vede solo
  // confrontando i due casi, e a uno la forma singolare deve restare.
  for (final quanti in const [3, 1]) {
    // I NOMI PER ESTESO, e non composti a runtime: il corredo li cerca come
    // stringhe dentro questo file, e un nome interpolato lo lascerebbe orfano.
    final nome = const {
      3: 'chat-contatore-a-3.png',
      1: 'chat-contatore-a-1.png',
    }[quanti]!;
    testWidgets('Cattura la bolla col contatore a $quanti', (tester) async {
      silenceSensors();
      await loadFonts();
      final memory = InMemoryMaestroMemoryRepository();
      await memory
          .saveProfile(UserProfile(disclaimerAcceptedAt: DateTime(2026, 7, 1)));
      final services = AppServices(
        ai: _VoceInDueStrati(),
        memory: memory,
        memoryPersistent: true,
        diagnostics: 'Cattura offline.',
      );
      final rootKey = await mount(tester, services);
      final ctx = tester.element(find.byType(MaterialApp));
      ctx.read<EntitlementService>().setTier(Tier.tier1);
      await step(tester);
      await openChat(tester, Maestro.medora);
      await precacheFaces(tester);
      final campo = find.descendant(
        of: find.byType(ChatComposer),
        matching: find.byType(TextField),
      );
      await tester.enterText(campo, 'Devo cambiare lavoro?');
      await step(tester);
      await tester.testTextInput.receiveAction(TextInputAction.send);
      for (var i = 0; i < 30; i++) {
        await step(tester);
      }
      await precacheFaces(tester);
      // I CONFRONTI GIA' SPESI, registrati QUI e non prima di aprire la chat.
      //
      // Prima stavano prima dell'apertura, e le due immagini uscivano
      // identiche byte per byte: il contatore si legge dal provider vivo che
      // la rotta della chat tiene, e mutarlo prima che quella rotta esista non
      // arrivava a video. Con la conta fatta a chat aperta il numero cambia
      // davvero, e le due anteprime sono due.
      final conto = tester
          .element(find.byType(ChatComposer))
          .read<QuestionAllowance>();
      for (var i = 0; i < 3 - quanti; i++) {
        conto.registraConfronto(Tier.tier1);
      }
      await step(tester);
      await step(tester);

      // IL GUARDIANO: senza il contatore a video l'immagine non mostra il
      // difetto che deve mostrare.
      expect(find.byKey(const Key('chat_residuo_confronti')), findsOneWidget,
          reason: 'il contatore non e\' a video: questa cattura non serve');
      await capture(tester, rootKey, nome);
    });
  }

  // --- La chat RIAPERTA dopo un turno fallito ---
  //
  // **Il dato che ha fatto nascere questa cattura.** Negli screenshot del
  // fondatore del 2 agosto 2026, riaprendo la chat si leggevano sette domande
  // di fila e nessuna risposta. Questa immagine mostra lo stesso gesto, cioe'
  // riaprire dopo un guasto, e cio' che si deve vedere: la domanda con il suo
  // turno accanto, dichiarato ripiego, col suo Riprova.
  testWidgets('Cattura la chat riaperta dopo un turno fallito',
      (tester) async {
    silenceSensors();
    await loadFonts();
    final memory = InMemoryMaestroMemoryRepository();
    await memory
        .saveProfile(UserProfile(disclaimerAcceptedAt: DateTime(2026, 7, 1)));
    // La cronologia com'e' rimasta sul telefono: la domanda, e il turno del
    // Maestro che e' fallito. Prima di oggi il secondo non c'era.
    await memory.appendMessage(
        Maestro.medora,
        const ChatMessage(
            role: ChatRole.user, text: 'Devo cambiare lavoro?'));
    await memory.appendMessage(
        Maestro.medora,
        ChatMessage(
          role: ChatRole.maestro,
          text: RipiegoDelMaestro.silenzioDi(Maestro.medora),
          failed: true,
          ripiego: true,
        ));
    final services = AppServices(
      ai: _ScriptedMaestro(),
      memory: memory,
      memoryPersistent: true,
      diagnostics: 'Cattura offline.',
    );
    final rootKey = await mount(tester, services);
    await openChat(tester, Maestro.medora);
    await precacheFaces(tester);
    await capture(tester, rootKey, 'chat-riaperta-turno-fallito.png');
  });

  // --- Le chat: conversazione, pannello suggerimenti, stato vuoto ---
  for (final maestro in Maestro.values) {
    final id = maestro.id;

    testWidgets('Cattura la conversazione, $id', (tester) async {
      silenceSensors();
      await loadFonts();
      final rootKey =
          await mount(tester, await buildServices(maestro, seeded: true));
      await openChat(tester, maestro);
      await precacheFaces(tester);
      await capture(tester, rootKey, '$id-chat.png');
    });

    testWidgets('Cattura il pannello dei suggerimenti, $id', (tester) async {
      silenceSensors();
      await loadFonts();
      final rootKey =
          await mount(tester, await buildServices(maestro, seeded: true));
      await openChat(tester, maestro);
      await tester.tap(find.text('Suggerimenti'));
      await step(tester);
      await step(tester);
      await capture(tester, rootKey, '$id-chat-suggerimenti.png');
    });

    testWidgets('Cattura lo stato vuoto, $id', (tester) async {
      silenceSensors();
      await loadFonts();
      final rootKey =
          await mount(tester, await buildServices(maestro, seeded: false));
      await openChat(tester, maestro);
      await precacheFaces(tester);
      await capture(tester, rootKey, '$id-chat-vuoto.png');
    });
  }

  // --- Il Risveglio, rituale a passi, e la rivelazione del cielo ---
  // Riduci Movimento attivo su tutte le route: accensioni e ruota gia' compiute
  // e ferme alla cattura, cosi' l'anteprima e' netta e deterministica.
  Future<GlobalKey> mountRisveglio(WidgetTester tester,
      {DateTime Function()? clock, Size? schermo}) async {
    await montaLoSchermo(tester, schermo ?? schermoReale);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final rootKey = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: rootKey,
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ProfileController()),
            ChangeNotifierProvider(create: (_) => OnboardingController()),
            // Il Risveglio ora poggia sul cosmo profondo: servono i controller
            // che lo animano (fermo sotto Riduci Movimento) e il tema neutro.
            ChangeNotifierProvider(create: (_) => MaestroController()),
            ChangeNotifierProvider(create: (_) => ArchetypeHistory()),
        ChangeNotifierProvider(create: (_) => NatalChartController()),
          ChangeNotifierProvider(create: (_) => QuestionAllowance()),
          ChangeNotifierProvider(create: (_) => EntitlementService()),
          ChangeNotifierProvider(create: (_) => QuestionAllowance()),
            ChangeNotifierProvider(create: (_) => ParallaxController()),
            ChangeNotifierProvider(create: (_) => QualityTierController()),
            ChangeNotifierProvider(create: (_) => ZodiacController()),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            builder: (ctx, child) => MediaQuery(
              data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
              child: MaestroScope(child: child!),
            ),
            home: OnboardingScreen(clock: clock),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      final element = tester.element(find.byType(MaterialApp));
      for (final m in Maestro.values) {
        await precacheImage(AssetImage(m.avatarAsset), element);
      }
    });
    await tester.pumpAndSettle();
    return rootKey;
  }

  Future<void> continua(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('onboarding_continue')));
    await tester.pumpAndSettle();
  }

  // --- LE TRE FESTE, MONTATE DALL'APP VERA (ordine AQ voce 02) ---
  //
  // **Perche' non bastava `tool/anteprime_delle_feste.dart`.** Quello
  // strumento compone il pittore a mano: dimostra che il pittore sa
  // disegnare, non che la persona vede qualcosa. Queste tre nascono dalla
  // scena vera della celebrazione, con un traguardo vero per sentiero, ed e'
  // l'unico modo per rispondere alla frase di Mauro "si vedono tutte
  // uguali".
  for (final sentiero in Sentiero.values) {
    testWidgets('Cattura la festa di ${sentiero.name}', (tester) async {
      silenceSensors();
      await loadFonts();
      SharedPreferences.setMockInitialValues(const {});
      await montaLoSchermo(tester, schermoReale);
      final rootKey = GlobalKey();
      final diario = DiarioDelCammino(orologio: orologioDelleProve);
      await diario.carica();
      await tester.pumpWidget(
        RepaintBoundary(
          key: rootKey,
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => MaestroController()),
              ChangeNotifierProvider(create: (_) => QualityTierController()),
              ChangeNotifierProvider(create: (_) => ParallaxController()),
              ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              // Lo scope porta il Maestro del sentiero, ordine AS voce 02.
              builder: (ctx, child) =>
                  MaestroScope(maestro: sentiero.maestro, child: child!),
              home: CelebrazioneAScermoPieno(
                traguardi: [Sentieri.di(sentiero).first],
                sentieri: [sentiero],
              ),
            ),
          ),
        ),
      );
      // A meta' della corsa, dove il campo delle particelle e' pieno: una
      // festa fotografata alla fine sarebbe una festa gia' finita.
      await tester.pump(const Duration(milliseconds: 900));
      // **IL NOME SI SCRIVE PER INTERO, ordine AQ voce 06.** Composto a
      // pezzi non compare nei sorgenti, e la guardia del corredo dichiara
      // orfana l'immagine che nessuno sembra generare: sarebbe verde solo
      // finche' nessuno la cerca.
      final nomeFile = switch (sentiero) {
        Sentiero.costellazione => 'festa-costellazione.png',
        Sentiero.albero => 'festa-albero.png',
        Sentiero.loto => 'festa-loto.png',
      };
      await capture(tester, rootKey, nomeFile);
    });
  }

  // --- I TRE FOTOGRAMMI DI OGNI FESTA, DALLA SCENA VERA (ordine AS voce 02) ---
  //
  // **Perche' nascono qui e non piu' in `tool/anteprime_delle_feste.dart`.**
  // Quello strumento compone il pittore a mano dentro una scatola: dimostra
  // che il pittore sa disegnare, non che la persona veda qualcosa. La guardia
  // dell'esplosione in tondo LEGGE queste immagini, quindi finche' nascevano
  // da uno strumento la guardia sorvegliava lo strumento e non l'app.
  //
  // Tre fotogrammi per Maestro: all'inizio, a meta' corsa (dove il campo e'
  // pieno) e alla fine.
  for (final sentiero in Sentiero.values) {
    testWidgets('Cattura i tre tempi della festa di ${sentiero.name}',
        (tester) async {
      silenceSensors();
      await loadFonts();
      SharedPreferences.setMockInitialValues(const {});
      await montaLoSchermo(tester, schermoReale);
      final rootKey = GlobalKey();
      final diario = DiarioDelCammino(orologio: orologioDelleProve);
      await diario.carica();
      await tester.pumpWidget(
        RepaintBoundary(
          key: rootKey,
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => MaestroController()),
              ChangeNotifierProvider(create: (_) => QualityTierController()),
              ChangeNotifierProvider(create: (_) => ParallaxController()),
              ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              // **LO SCOPE PORTA IL MAESTRO DEL SENTIERO, ordine AS voce 02.**
              // Nell'app la rotta della celebrazione se lo porta da se', e
              // senza questa riga la cattura mostrava la festa di Caligo coi
              // colori del Maestro corrente: un'anteprima che dice una cosa
              // che sullo schermo non succede.
              builder: (ctx, child) =>
                  MaestroScope(maestro: sentiero.maestro, child: child!),
              home: CelebrazioneAScermoPieno(
                traguardi: [Sentieri.grandiDi(sentiero).first],
                sentieri: [sentiero],
              ),
            ),
          ),
        ),
      );
      final maestro = sentiero.maestro;
      // I tre tempi sono cumulativi: si avanza e si scatta, come vedrebbe
      // qualcuno che guarda la scena dall'inizio alla fine.
      await tester.pump(const Duration(milliseconds: 320));
      await capture(tester, rootKey, 'festa_${maestro.id}_inizio.png');
      await tester.pump(const Duration(milliseconds: 700));
      await capture(tester, rootKey, 'festa_${maestro.id}_meta.png');
      await tester.pump(const Duration(milliseconds: 1400));
      await capture(tester, rootKey, 'festa_${maestro.id}_fine.png');
    });
  }

  // --- LA CUSTODIA DEL CIELO, dall'app vera (ordine AQ voce 05) ---
  //
  // Mauro l'ha vista confusionaria: nove elementi in colonna. Senza
  // un'immagine alla larghezza vera non si puo' giudicare se adesso si legge.
  testWidgets('Cattura la custodia del cielo', (tester) async {
    silenceSensors();
    await loadFonts();
    SharedPreferences.setMockInitialValues(const {});
    await montaLoSchermo(tester, schermoReale);
    final rootKey = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: rootKey,
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => MaestroController()),
            ChangeNotifierProvider(create: (_) => QualityTierController()),
            ChangeNotifierProvider(create: (_) => ParallaxController()),
            ChangeNotifierProvider<AccountDelCerchio>(
                create: (_) => AccountDelCerchio(porta: const IdentitaAssente())),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            builder: (ctx, child) => MaestroScope(child: child!),
            home: CustodiaDelCieloStep(
              maestro: Maestro.medora,
              suFine: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
    await capture(tester, rootKey, 'custodia-del-cielo.png');
  });

  // --- LA SCENA DEL RITROVAMENTO, ordine AP voce 05 ---
  //
  // **E' la schermata su cui si gioca la promessa di tutto l'ordine**, e
  // finora non esisteva nessuna sua immagine: e' cio' che vede chi torna col
  // suo account dopo aver cambiato telefono. I numeri sono quelli di un
  // cammino vero, non un esempio ornamentale, perche' la scena a schermo dice
  // proprio quei numeri e un numero inventato qui la trasformerebbe in una
  // vanteria.
  testWidgets('Cattura la scena del ritrovamento', (tester) async {
    silenceSensors();
    await loadFonts();
    await montaLoSchermo(tester, schermoReale);
    final rootKey = GlobalKey();
    final ritrovamento = Ritrovamento.da(
      CamminoDaCustodire(
        identita: IdentitaDaCustodire(
          nome: 'Sofia',
          giorno: DateTime(1990, 4, 12),
          ora: '07:30',
          luogo: 'Roma',
          latitudine: 41.9,
          longitudine: 12.5,
        ),
        sigilli: {
          'med_1': DateTime(2026, 8, 1),
          'cal_1': DateTime(2026, 8, 3),
          'aur_1': DateTime(2026, 8, 7),
        },
      ),
      saldoEos: 340,
    );
    await tester.pumpWidget(
      RepaintBoundary(
        key: rootKey,
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => MaestroController()),
            ChangeNotifierProvider(create: (_) => QualityTierController()),
            ChangeNotifierProvider(create: (_) => ParallaxController()),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            builder: (ctx, child) => MediaQuery(
              data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
              child: MaestroScope(child: child!),
            ),
            home: ScenaDelRitrovamento(
              ritrovamento: ritrovamento,
              onProsegui: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await capture(tester, rootKey, 'ritrovamento.png');
  });

  testWidgets('Cattura il Risveglio, la data col Sole nel segno',
      (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mountRisveglio(tester, clock: () => DateTime(2026, 7, 15));
    await continua(tester); // accoglienza -> data
    await capture(tester, rootKey, 'risveglio-data.png');
  });

  testWidgets('Cattura il Risveglio, l\'ora e l\'Ascendente', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mountRisveglio(tester, clock: () => DateTime(2026, 7, 15));
    await continua(tester); // -> data
    await continua(tester); // -> ora
    await capture(tester, rootKey, 'risveglio-ora.png');
  });

  testWidgets('Cattura il Risveglio, il luogo offline', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mountRisveglio(tester, clock: () => DateTime(2026, 7, 15));
    await continua(tester); // -> data
    await continua(tester); // -> ora
    await continua(tester); // -> luogo
    await tester.enterText(
        find.byKey(const Key('risveglio_luogo_field')), 'Roma');
    await tester.pumpAndSettle();
    await capture(tester, rootKey, 'risveglio-luogo.png');
  });

  // Il planisfero col luogo SCELTO: la stella accesa nel punto giusto e' il
  // senso della cosa, quindi va guardata, non dedotta.
  testWidgets('Cattura il Risveglio, il luogo scelto', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mountRisveglio(tester, clock: () => DateTime(2026, 7, 15));
    await continua(tester); // -> data
    await continua(tester); // -> ora
    await continua(tester); // -> luogo
    await tester.enterText(
        find.byKey(const Key('risveglio_luogo_field')), 'Roma');
    await tester.pumpAndSettle();
    // **NESSUN TOCCO SULL'ELENCO, e non e' una semplificazione.** Dall'ordine
    // 2169 voce 1, scrivere per intero il nome di una citta' che nel catalogo
    // e' unica la sceglie da sola, e Roma nel catalogo e' una sola: l'elenco
    // non compare affatto. Questa cattura mostra percio' cio' che vede
    // davvero chi scrive il nome della propria citta'.
    await capture(tester, rootKey, 'risveglio-luogo-scelto.png');
  });

  // L'accoglienza, col suo astrolabio. Catturata A FINE COSTRUZIONE, non a
  // meta': gli anelli si tracciano in 2,6 secondi e fotografarli prima
  // direbbe che l'astrolabio e' incompleto.
  testWidgets('Cattura il Risveglio, accoglienza', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mountRisveglio(tester, clock: () => DateTime(2026, 7, 15));
    for (var i = 0; i < 18; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    await capture(tester, rootKey, 'risveglio-accoglienza.png');
  });

  // La schermata del genere, con una scelta fatta: Mauro dice di non vedere
  // nessuna frase d'esempio, quindi va guardata invece che dedotta. Su due
  // altezze, perche' se la frase sta sotto la piega su uno schermo basso e'
  // come non averla scritta.
  for (final basso in const [false, true]) {
    testWidgets('Cattura il Risveglio, il genere${basso ? ', schermo basso' : ''}',
        (tester) async {
      silenceSensors();
      await loadFonts();
      final rootKey = await mountRisveglio(tester,
          clock: () => DateTime(2026, 7, 15),
          schermo: basso ? schermoBasso : schermoAlto);
      await continua(tester); // -> data
      await continua(tester); // -> ora
      await continua(tester); // -> luogo
      await continua(tester); // -> nome
      await tester.enterText(
          find.byKey(const Key('risveglio_nome_field')), 'Mauro');
      await tester.pumpAndSettle();
      await continua(tester); // -> vocativo
      await tester.tap(find.byKey(const Key('vocativo_lui')));
      // A fine scrittura, non a meta': la frase si scrive lettera per lettera
      // e fotografarla a meta' direbbe che manca.
      for (var i = 0; i < 14; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      await capture(tester, rootKey,
          'risveglio-genere${basso ? '-2392' : ''}.png');
    });
  }

  testWidgets('Cattura il Risveglio, il sigillo', (tester) async {
    silenceSensors();
    await loadFonts();
    final rootKey =
        await mountRisveglio(tester, clock: () => DateTime(2026, 7, 15));
    await continua(tester); // -> data
    await continua(tester); // -> ora
    await continua(tester); // -> luogo
    await continua(tester); // -> nome
    await tester.enterText(
        find.byKey(const Key('risveglio_nome_field')), 'Sofia');
    await tester.pumpAndSettle();
    await continua(tester); // -> vocativo
    await tester.tap(find.byKey(const Key('vocativo_lei')));
    await tester.pumpAndSettle();
    await continua(tester); // -> sigillo
    await capture(tester, rootKey, 'risveglio-sigillo.png');
  });

  // Il ponte per le catture della coda: dai dati di nascita nascono la carta
  // (essenziale senza chiave API) e i fatti identitari, come nel Risveglio.
  Future<
      ({
        NatalChartController chart,
        IdentityController ident,
        BirthIdentityController birth,
        BirthDetails details,
      })> natalBridge(WidgetTester tester) async {
    final details = BirthDetails(
      date: DateTime(1990, 6, 15),
      time: const TimeOfDay(hour: 2, minute: 30),
      place: const astro.BirthPlace(
        label: 'Roma',
        latitude: 41.9,
        longitude: 12.5,
        timezone: 'Europe/Rome',
      ),
      gender: Gender.female,
    );
    final chart = NatalChartController();
    await tester.runAsync(() => chart.compute(details));
    final birth = BirthIdentityController()..setBirth(details, chart.chart);
    final ident = IdentityController()
      ..setName('Sofia')
      ..setForm(AddressForm.feminine);
    return (chart: chart, ident: ident, birth: birth, details: details);
  }

  /// Una carta natale PIENA, costruita a mano: pianeti, angoli, case e
  /// aspetti.
  ///
  /// Serve perche' l'anteprima della carta natale e' sempre stata quella
  /// essenziale, senza pianeti: la ruota ornata non si e' mai potuta guardare,
  /// e ogni modifica alle linee d'aspetto restava una cosa scritta e mai
  /// vista. Le longitudini qui sono verosimili e fisse, non calcolate: questa
  /// e' una posa per il ritratto, non una carta di qualcuno.
  NatalChart cartaPiena() {
    PlanetPosition p(String id, String nome, String glifo, double lon) =>
        PlanetPosition(
          id: id,
          name: nome,
          glyph: glifo,
          longitude: lon,
          sign: Zodiac.values[(lon ~/ 30) % 12],
          house: (lon ~/ 30) + 1,
        );
    final pianeti = [
      p('sun', 'Sole', '\u2609', 84),
      p('moon', 'Luna', '\u263D', 212),
      p('mercury', 'Mercurio', '\u263F', 71),
      p('venus', 'Venere', '\u2640', 116),
      p('mars', 'Marte', '\u2642', 3),
      p('jupiter', 'Giove', '\u2643', 158),
      p('saturn', 'Saturno', '\u2644', 292),
      p('uranus', 'Urano', '\u2645', 268),
      p('neptune', 'Nettuno', '\u2646', 283),
      p('pluto', 'Plutone', '\u2647', 227),
    ];
    // Gli aspetti fra le coppie che cadono vicine agli angoli canonici.
    final aspetti = <ChartAspect>[];
    for (var i = 0; i < pianeti.length; i++) {
      for (var j = i + 1; j < pianeti.length; j++) {
        var d = (pianeti[i].longitude - pianeti[j].longitude).abs();
        if (d > 180) d = 360 - d;
        AspectType? tipo;
        if (d < 8) {
          tipo = AspectType.conjunction;
        } else if ((d - 60).abs() < 6) {
          tipo = AspectType.sextile;
        } else if ((d - 90).abs() < 7) {
          tipo = AspectType.square;
        } else if ((d - 120).abs() < 7) {
          tipo = AspectType.trine;
        } else if ((d - 180).abs() < 8) {
          tipo = AspectType.opposition;
        }
        if (tipo != null) {
          aspetti.add(ChartAspect(
            aLongitude: pianeti[i].longitude,
            bLongitude: pianeti[j].longitude,
            type: tipo,
          ));
        }
      }
    }
    return NatalChart(
      sunSign: Zodiac.gemini,
      moonSign: Zodiac.scorpio,
      ascendant: Zodiac.aquarius,
      ascendantLongitude: 312,
      midheaven: Zodiac.scorpio,
      midheavenLongitude: 222,
      planets: pianeti,
      houses: [
        for (var i = 0; i < 12; i++)
          HouseCusp(number: i + 1, longitude: (312 + i * 30) % 360),
      ],
      aspects: aspetti,
      hasTime: true,
    );
  }

  Widget natalHost({required Widget home}) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
        child: MaestroScope(child: child!),
      ),
      home: home,
    );
  }

  // La ruota natale PIENA, con pianeti e aspetti: era il buco permanente del
  // corredo delle anteprime, perche' la carta d'anteprima e' sempre stata
  // quella essenziale e la ruota non si e' mai potuta guardare.
  testWidgets('Cattura la ruota natale piena, con gli aspetti',
      (tester) async {
    silenceSensors();
    await loadFonts();
    await montaLoSchermo(tester, const Size(360, 420));
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final rootKey = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: rootKey,
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => MaestroController()),
            ChangeNotifierProvider(create: (_) => ArchetypeHistory()),
        ChangeNotifierProvider(create: (_) => NatalChartController()),
          ChangeNotifierProvider(create: (_) => QuestionAllowance()),
          ChangeNotifierProvider(create: (_) => EntitlementService()),
          ChangeNotifierProvider(create: (_) => QuestionAllowance()),
            ChangeNotifierProvider(create: (_) => QualityTierController()),
          ],
          child: natalHost(
            home: Scaffold(
              backgroundColor: const Color(0xFF0B0A1A),
              body: Center(
                child: NatalWheel(
                  chart: cartaPiena(),
                  size: 340,
                  showAspects: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    // La ruota entra in 3,6 secondi e gli aspetti compaiono nell'ultimo
    // quinto: catturare prima vorrebbe dire fotografare una ruota senza le
    // linee e concludere che non ci sono.
    for (var i = 0; i < 26; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    await capture(tester, rootKey, 'carta-ruota-piena.png');
  });

  testWidgets('Cattura il cielo reale di nascita', (tester) async {
    silenceSensors();
    await loadFonts();
    await montaLoSchermo(tester, const Size(360, 844));
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final b = await natalBridge(tester);
    final rootKey = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: rootKey,
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider<IdentityController>.value(value: b.ident),
            ChangeNotifierProvider(create: (_) => MaestroController()),
            ChangeNotifierProvider(create: (_) => ArchetypeHistory()),
        ChangeNotifierProvider(create: (_) => NatalChartController()),
          ChangeNotifierProvider(create: (_) => QuestionAllowance()),
          ChangeNotifierProvider(create: (_) => EntitlementService()),
          ChangeNotifierProvider(create: (_) => QuestionAllowance()),
            ChangeNotifierProvider(create: (_) => ParallaxController()),
            ChangeNotifierProvider(create: (_) => QualityTierController()),
            ChangeNotifierProvider(create: (_) => ZodiacController()),
          ],
          child: natalHost(
            // Il cielo alla nascita e' ora la STESSA schermata del cielo in
            // tempo reale, ancorata al momento di nascita, con la CTA del
            // flusso: e' quello che l'onboarding monta davvero.
            home: SkyOverviewScreen(
              now: b.details.dateTime,
              birth: true,
              showBack: false,
              ctaLabel: 'Leggi la tua carta',
              onCta: () {},
            ),
          ),
        ),
      ),
    );
    // La volta pulsa in continuo: non si attende l'idle, si pompano pochi
    // frame per far posare la scena, poi si cattura.
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    await capture(tester, rootKey, 'cielo-nascita.png');
  });

  testWidgets('Cattura la carta natale, ruota ornata e legenda',
      (tester) async {
    silenceSensors();
    await loadFonts();
    // Alta abbastanza da mostrare la ruota ornata e la legenda viva a tessere
    // (una tessera per pianeta) sotto di essa, senza scorrere.
    await montaLoSchermo(tester, const Size(360, 1600));
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final b = await natalBridge(tester);
    final rootKey = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: rootKey,
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider<NatalChartController>.value(value: b.chart),
            ChangeNotifierProvider<BirthIdentityController>.value(
                value: b.birth),
            ChangeNotifierProvider<IdentityController>.value(value: b.ident),
            ChangeNotifierProvider(create: (_) => MaestroController()),
            ChangeNotifierProvider(create: (_) => ArchetypeHistory()),
        ChangeNotifierProvider(create: (_) => NatalChartController()),
          ChangeNotifierProvider(create: (_) => QuestionAllowance()),
          ChangeNotifierProvider(create: (_) => EntitlementService()),
          ChangeNotifierProvider(create: (_) => QuestionAllowance()),
            ChangeNotifierProvider(create: (_) => ParallaxController()),
            ChangeNotifierProvider(create: (_) => QualityTierController()),
            ChangeNotifierProvider(create: (_) => ZodiacController()),
          ],
          child: natalHost(
            home: ImmersiveScaffold(
              child: NatalChartReveal(onContinue: () {}),
            ),
          ),
        ),
      ),
    );
    // Le tre miniature degli angeli vanno decodificate prima dello scatto.
    // Senza, la cattura ne mostra una sola e le altre due restano vuote: e'
    // un artefatto dell'headless, non un difetto della tessera, ma
    // un'anteprima che mostra un volto su tre non serve a nessuno.
    await tester.runAsync(() async {
      for (final a in AngelCatalog.all) {
        await precacheImage(
            AssetImage(FamilyImage.thumb(AssetFamily.angeli, a.artStem)),
            tester.element(find.byType(NatalChartReveal)));
      }
    });
    // La legenda ha micro-animazioni: pochi frame invece dell'idle.
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    await capture(tester, rootKey, 'carta-natale.png');
  });

  // --- La mano che invita al tocco, isolata e ingrandita ---
  //
  // Stava in un file suo che scriveva dritto in docs/preview senza passare di
  // qui: era la SECONDA PORTA, e per questo la sua anteprima non ha mai visto
  // la misura reale. Una regola messa in una porta quando le porte sono due non
  // e' una regola.
  testWidgets('Cattura la mano del tocco', (tester) async {
    silenceSensors();
    await loadFonts();
    await montaLoSchermo(tester, schermoReale);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final rootKey = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
      key: rootKey,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          color: const Color(0xFF0B0714),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final f in const [-1.0, 0.35, 0.7])
                SizedBox(
                  width: 100,
                  height: 260,
                  child: CustomPaint(
                    painter: TapHandPainter(phase: f, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    ));
    await tester.pump();
    await capture(tester, rootKey, 'mano-terza-stesura.png');
  });

  // --- Lo scaffale personale, alla misura reale ---
  //
  // Era nata da una prova temporanea poi cancellata: nessuno la rigenerava e
  // restava ferma a 390 per 844, cioe' a uno schermo che non esiste.
  testWidgets('Cattura Le tue arti', (tester) async {
    silenceSensors();
    await loadFonts();
    SharedPreferences.setMockInitialValues({});
    final pref = ArtiPreferiteController(maestroAssegnato: Maestro.medora);
    await pref.carica();
    await montaLoSchermo(tester, schermoReale);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final rootKey = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
      key: rootKey,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => ArchetypeHistory()),
        ChangeNotifierProvider(create: (_) => NatalChartController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider<ArtiPreferiteController>.value(value: pref),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          builder: (ctx, child) => MediaQuery(
            data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
            child: MaestroScope(child: child!),
          ),
          home: Scaffold(
            backgroundColor: const Color(0xFF0B0714),
            body: SingleChildScrollView(child: TueArtiView(onOpen: (_) {})),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    await capture(tester, rootKey, 'le-tue-arti.png');
  });

  // --- I RITRATTI TONDI DEI TRE MAESTRI, E IL LORO CONFRONTO --------------
  //
  // Due cose che nessun'altra cattura fa vedere. Il TONDO: nell'app l'anello
  // va da 26 a 48 punti, una misura in cui un volto inquadrato male si vede
  // appena. L'inquadratura scala linearmente col diametro, quindi un anello
  // grande mostra esattamente lo stesso taglio, solo leggibile; accanto
  // restano le misure vere, cosi' non si giudica una cosa diversa da quella
  // che l'app disegna. Il CONFRONTO: i tre affiancati sulla stessa linea di
  // terra, che e' l'unico modo di vedere se una figura e' piu' bassa delle
  // altre invece di sembrarlo.
  for (final maestro in Maestro.fixedOrder) {
    testWidgets('Cattura il tondo di ${maestro.displayName}', (tester) async {
      silenceSensors();
      await loadFonts();
      SharedPreferences.setMockInitialValues({});
      await montaLoSchermo(tester, schermoReale);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final rootKey = GlobalKey();
      await tester.pumpWidget(RepaintBoundary(
        key: rootKey,
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => MaestroController()),
            ChangeNotifierProvider(create: (_) => QualityTierController()),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            builder: (ctx, child) => MediaQuery(
              data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
              child: MaestroScope(child: child!),
            ),
            home: Scaffold(
              backgroundColor: const Color(0xFF0B0B14),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(maestro.displayName,
                        style: const TextStyle(
                            fontFamily: 'Cinzel',
                            color: Color(0xFFE8D9A8),
                            fontSize: 22,
                            height: 2.2)),
                    // Il taglio della bolla: il volto contenuto nel tondo.
                    MaestroBust(maestro: maestro, ring: 230, popOut: false),
                    const SizedBox(height: 40),
                    const Text('il taglio dell\'header, la testa sporge',
                        style: TextStyle(
                            fontFamily: 'EBGaramond',
                            color: Color(0x99E8D9A8),
                            fontSize: 13)),
                    const SizedBox(height: 14),
                    MaestroBust(maestro: maestro, ring: 150),
                    const SizedBox(height: 46),
                    const Text('le misure vere dell\'app: 26, 34, 40, 48',
                        style: TextStyle(
                            fontFamily: 'EBGaramond',
                            color: Color(0x99E8D9A8),
                            fontSize: 13)),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        MaestroBust(maestro: maestro, ring: 26, popOut: false),
                        const SizedBox(width: 22),
                        MaestroBust(maestro: maestro, ring: 34, popOut: false),
                        const SizedBox(width: 22),
                        MaestroBust(maestro: maestro, ring: 40),
                        const SizedBox(width: 22),
                        MaestroBust(maestro: maestro, ring: 48),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ));
      await step(tester);
      await precacheFaces(tester);
      await capture(tester, rootKey, 'avatar-tondo-${maestro.id}.png');
    });
  }

  testWidgets('Cattura i tre Maestri alla stessa scala', (tester) async {
    silenceSensors();
    await loadFonts();
    SharedPreferences.setMockInitialValues({});
    await montaLoSchermo(tester, schermoReale);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final rootKey = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
      key: rootKey,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          builder: (ctx, child) => MediaQuery(
            data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
            child: MaestroScope(child: child!),
          ),
          home: Scaffold(
            backgroundColor: const Color(0xFF0B0B14),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                      'stessa altezza di figura, piedi sulla stessa linea',
                      style: TextStyle(
                          fontFamily: 'EBGaramond',
                          color: Color(0xFFE8D9A8),
                          fontSize: 14)),
                  const SizedBox(height: 18),
                  // 165 e non di piu': tre figure affiancate devono stare nei
                  // 360 punti logici del telefono, altrimenti la riga sfora e
                  // la cattura si rompe.
                  SizedBox(
                    height: 165,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (final m in Maestro.fixedOrder)
                          Image.asset(m.avatarAsset,
                              height: 165,
                              fit: BoxFit.contain,
                              alignment: Alignment.bottomCenter),
                      ],
                    ),
                  ),
                  // La riga di terra: si giudica a occhio, non a impressione.
                  Container(
                      height: 2, width: 350, color: const Color(0xFFE8D9A8)),
                  const SizedBox(height: 40),
                  for (final m in Maestro.fixedOrder) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 96,
                          child: Text(m.displayName,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                  fontFamily: 'EBGaramond',
                                  color: Color(0xFFE8D9A8),
                                  fontSize: 13)),
                        ),
                        const SizedBox(width: 12),
                        Image.asset(m.avatarAsset,
                            height: 150,
                            fit: BoxFit.contain,
                            alignment: Alignment.bottomCenter),
                      ],
                    ),
                    Container(
                        height: 1, width: 330, color: const Color(0x66E8D9A8)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    ));
    await step(tester);
    await precacheFaces(tester);
    await capture(tester, rootKey, 'avatar-confronto-tre.png');
  });


  // --- I TRE TONDI AFFIANCATI, ALLE MISURE VERE DELL'APP ------------------
  //
  // Il giudizio su come si somigliano si da' su questa: i tre uno accanto
  // all'altro, alle misure a cui l'app li disegna davvero, 26 e 34 nella bolla
  // e 40 e 48 dove la testa sporge. Sopra, gli stessi tre piu' grandi, perche'
  // a 26 punti un difetto si vede appena.
  testWidgets('Cattura i tre tondi affiancati', (tester) async {
    silenceSensors();
    await loadFonts();
    SharedPreferences.setMockInitialValues({});
    await montaLoSchermo(tester, schermoReale);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Widget riga(String titolo, double anello, bool sporge) => Column(
          children: [
            Text(titolo,
                style: const TextStyle(
                    fontFamily: 'EBGaramond',
                    color: Color(0x99E8D9A8),
                    fontSize: 12)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final m in Maestro.fixedOrder) ...[
                  MaestroBust(maestro: m, ring: anello, popOut: sporge),
                  const SizedBox(width: 18),
                ],
              ],
            ),
            const SizedBox(height: 22),
          ],
        );

    final rootKey = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
      key: rootKey,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          builder: (ctx, child) => MediaQuery(
            data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
            child: MaestroScope(child: child!),
          ),
          home: Scaffold(
            backgroundColor: const Color(0xFF0B0B14),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  riga('ingranditi, per giudicare il taglio', 92, false),
                  riga('le misure vere dell\'app: 26, 34, 40, 48', 26, false),
                  riga('', 34, false),
                  riga('', 40, true),
                  riga('', 48, true),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
    await step(tester);
    await precacheFaces(tester);
    await capture(tester, rootKey, 'avatar-tondi-affiancati.png');
  });


  testWidgets('Cattura le tre carte prima e dopo l\'alone', (tester) async {
    // IL GIUDIZIO E' DI MAURO, SULLE DUE FILE AFFIANCATE. Una carta sola,
    // guardata da sola, non dice se l'alone stacca la figura: dice solo che
    // c'e' qualcosa di chiaro. La differenza si vede mettendo le due file una
    // sopra l'altra, che e' lo stesso confronto che fa la prova a pixel.
    silenceSensors();
    await loadFonts();
    await montaLoSchermo(tester, schermoReale);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Widget fila(String titolo, bool conAlone) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(titolo,
                style: const TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 13,
                    color: Color(0xFFD8C89B),
                    letterSpacing: 2)),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final m in Maestro.fixedOrder)
                  // Il busto del SANTUARIO, non quello della chat: hanno lo
                  // stesso nome e sono due cose diverse, uno e' la carta col
                  // fondo e la cornice, l'altro e' il volto nel tondo.
                  //
                  // L'altezza e' quella che fa stare tre carte in fila sullo
                  // schermo vero: a 300 la riga sforava di 319 pixel, e una
                  // scena che trabocca non e' un confronto, e' un difetto. A 190 sforava
                  // ancora di 70 e a 160 di 1,9: la misura buona e' 152.
                  santuario.MaestroBust(
                    maestro: m,
                    height: 152,
                    central: true,
                    conAlone: conAlone,
                  ),
              ],
            ),
          ],
        );

    final rootKey = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
      key: rootKey,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          builder: (ctx, child) => MediaQuery(
            data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
            child: MaestroScope(child: child!),
          ),
          home: Scaffold(
            backgroundColor: const Color(0xFF0B0B14),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  fila('PRIMA, SENZA ALONE', false),
                  const SizedBox(height: 40),
                  fila('DOPO, CON ALONE', true),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
    await step(tester);
    await precacheFaces(tester);
    await step(tester);
    await capture(tester, rootKey, 'alone-prima-e-dopo.png');
  });

  // --- IL RESPIRO E LE PIETRE COPERTE --------------------------------------

  testWidgets('Cattura il respiro, i tre momenti', (tester) async {
    silenceSensors();
    await loadFonts();
    await montaLoSchermo(tester, schermoReale);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const tempi = TempiDelRespiro(tempi: 4, giri: 3);
    final rootKey = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
      key: rootKey,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          // Il verde del prato del Soffio, che e' la superficie su cui la
          // parola grande deve leggersi.
          backgroundColor: const Color(0xFFBFD5B2),
          body: Center(
            child: GuidaDelRespiro(
                tempi: tempi, colore: const Color(0xFFD8C89B)),
          ),
        ),
      ),
    ));
    await tester.pump();
    await capture(tester, rootKey, 'respiro-apertura.png');

    // ORDINE 2163 VOCE 11: il respiro parte col tocco e dopo il conto, non
    // piu' da solo. Per la scena del gesto si tocca e si attraversa il conto.
    await tester.tap(find.byKey(const Key('respiro_tocca')));
    await tester.pump();
    await tester.pump(ParoleDelRespiro.durataDelConto);
    await tester.pump(const Duration(milliseconds: 300));
    await capture(tester, rootKey, 'respiro-inspira.png');

    await tester.pump(tempi.intero);
    await tester.pump(const Duration(milliseconds: 300));
    await capture(tester, rootKey, 'respiro-compiuto.png');
  });

  testWidgets('Cattura le pietre coperte e il confronto', (tester) async {
    // **NON si monta `RuneDrawScreen` intera, e va detto.** Quella schermata
    // ascolta l'accelerometro e dipinge il cosmo animato: in cattura il
    // precarico resta appeso e il test finisce in timeout dopo dieci minuti,
    // provato. Qui si montano gli ASSET veri, che sono cio' che la scena
    // dovrebbe mostrare: i retri a vista e una pietra girata accanto alla sua
    // incisa, per vedere che sia lo stesso sasso.
    silenceSensors();
    await loadFonts();
    await montaLoSchermo(tester, schermoReale);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Widget pietra(String percorso, double lato) => SizedBox(
          width: lato,
          height: lato * 1.2,
          child: Image.asset(percorso, fit: BoxFit.contain),
        );

    final rootKey = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
      key: rootKey,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color(0xFF0B0710),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('LE PIETRE COPERTE, PRIMA DELLA SORTE',
                    style: TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 13,
                        color: Color(0xFFD8C89B),
                        letterSpacing: 2)),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final runa in kElderFuthark.take(5))
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: pietra(pathVergineDi(runa.stem)!, 58),
                      ),
                  ],
                ),
                const SizedBox(height: 46),
                const Text('LA STESSA PIETRA, GIRATA E INCISA',
                    style: TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 13,
                        color: Color(0xFFD8C89B),
                        letterSpacing: 2)),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    pietra(pathVergineDi(kElderFuthark.first.stem)!, 128),
                    const SizedBox(width: 26),
                    pietra(kElderFuthark.first.fullPath!, 128),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ));
    await step(tester);
    await capture(tester, rootKey, 'rune-coperte.png');
  });

  // --- LA BARRA DEL CERCHIO: dove si vede e dove no ------------------------
  //
  // Montate come e' montato cio' che provano, cioe' l'APP INTERA: la barra vive
  // nel builder di MaterialApp e non nel guscio, quindi una cattura che monti
  // solo lo shell mostrerebbe un'altra cosa.
  Future<GlobalKey> montaApp(WidgetTester tester,
      {required bool giaRisvegliato}) async {
    silenceSensors();
    await loadFonts();
    SharedPreferences.setMockInitialValues(
        giaRisvegliato ? {'onboarding.done': true} : {});
    await montaLoSchermo(tester, schermoReale);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final rootKey = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
      key: rootKey,
      child: EsotericCircleApp(conIntro: false, services: AppServices.offline()),
    ));
    await step(tester);
    await precacheFaces(tester);
    await step(tester);
    return rootKey;
  }

  Finder corpoScorribile() => find.byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.down);

  /// Porta la barra a meta' corsa col dito, e ce la lascia.
  Future<TestGesture> aMetaCorsa(WidgetTester tester, Finder dove) async {
    final gesto = await tester.startGesture(tester.getCenter(dove));
    await gesto.moveBy(const Offset(0, -kDragSlopDefault));
    await tester.pump();
    await gesto.moveBy(const Offset(0, -BarraDelCerchio.corsa / 2));
    await tester.pump();
    return gesto;
  }

  testWidgets('Cattura la barra nella home', (tester) async {
    final rootKey = await montaApp(tester, giaRisvegliato: true);
    await capture(tester, rootKey, 'barra-home.png');
  });

  /// Porta la barra a fondo corsa, cioe' fuori, e ce la lascia.
  Future<TestGesture> aFondoCorsa(WidgetTester tester, Finder dove) async {
    final gesto = await tester.startGesture(tester.getCenter(dove));
    await gesto.moveBy(const Offset(0, -kDragSlopDefault));
    await tester.pump();
    await gesto.moveBy(const Offset(0, -BarraDelCerchio.corsa));
    await tester.pump();
    return gesto;
  }

  testWidgets('Cattura la home con la barra fuori', (tester) async {
    // La terza delle tre scene che provano che il contenuto STA FERMO: i tre
    // Maestri devono avere la stessa grandezza che hanno con la barra dentro e
    // a meta' corsa.
    final rootKey = await montaApp(tester, giaRisvegliato: true);
    final gesto = await aFondoCorsa(tester, corpoScorribile().first);
    await capture(tester, rootKey, 'barra-home-fuori.png');
    await gesto.up();
    await tester.pump();
  });

  testWidgets('Cattura la home scorsa fino in fondo', (tester) async {
    final rootKey = await montaApp(tester, giaRisvegliato: true);
    for (var i = 0; i < 8; i++) {
      await tester.drag(corpoScorribile().first, const Offset(0, -400));
      await tester.pump();
    }
    await step(tester);
    await capture(tester, rootKey, 'home-in-fondo.png');
  });

  testWidgets('Cattura la chat a meta corsa', (tester) async {
    final rootKey = await montaApp(tester, giaRisvegliato: true);
    final nav = tester.state<NavigatorState>(find.byType(Navigator).last);
    nav.push(MaestroChatScreen.route(
        maestro: Maestro.medora, services: AppServices.offline()));
    await step(tester);
    await precacheFaces(tester);
    await step(tester);
    final gesto =
        await aMetaCorsa(tester, find.byType(Scrollable).first);
    await capture(tester, rootKey, 'barra-chat-meta-corsa.png');
    await gesto.up();
    await tester.pump();
  });

  testWidgets('Cattura la chat con la barra fuori', (tester) async {
    final rootKey = await montaApp(tester, giaRisvegliato: true);
    final nav = tester.state<NavigatorState>(find.byType(Navigator).last);
    nav.push(MaestroChatScreen.route(
        maestro: Maestro.medora, services: AppServices.offline()));
    await step(tester);
    await precacheFaces(tester);
    await step(tester);
    final gesto =
        await aFondoCorsa(tester, find.byType(Scrollable).first);
    await capture(tester, rootKey, 'barra-chat-fuori.png');
    await gesto.up();
    await tester.pump();
  });

  // --- LA BARRA COL SALDO LUNGO (ordine AR voce 10) ---
  //
  // La coda di Mauro chiede di guardarla con un saldo a quattro cifre: in una
  // fascia da trenta punti un numero lungo e' il primo candidato a troncarsi,
  // e adesso che il nome e' uscito lo spazio c'e', ma va guardato.
  testWidgets('Cattura la barra col saldo a quattro cifre', (tester) async {
    final rootKey = await montaApp(tester, giaRisvegliato: true);
    final borsa = tester
        .element(find.byType(BarraDellIdentita))
        .read<QuestionAllowance>();
    await borsa.applicaSaldo(9999);
    await step(tester);
    await step(tester);
    await capture(tester, rootKey, 'barra-saldo-lungo.png');
  });

  testWidgets('Cattura la barra a meta corsa nella home', (tester) async {
    // LA SCENA CHE PROVA IL MOVIMENTO CONTINUO. Con due stati non esisterebbe
    // affatto: o la barra c'e' o non c'e'.
    final rootKey = await montaApp(tester, giaRisvegliato: true);
    final gesto = await aMetaCorsa(tester, corpoScorribile().first);
    await capture(tester, rootKey, 'barra-meta-corsa.png');
    await gesto.up();
    await tester.pump();
  });

  testWidgets('Cattura la barra in un dominio', (tester) async {
    final rootKey = await montaApp(tester, giaRisvegliato: true);
    final nav = tester.state<NavigatorState>(find.byType(Navigator).last);
    nav.push(DomainScreen.route(
        maestro: Maestro.medora, services: AppServices.offline()));
    await step(tester);
    await precacheFaces(tester);
    await step(tester);
    await capture(tester, rootKey, 'barra-dominio.png');
  });

  testWidgets('Cattura la barra in una chat', (tester) async {
    final rootKey = await montaApp(tester, giaRisvegliato: true);
    final nav = tester.state<NavigatorState>(find.byType(Navigator).last);
    nav.push(MaestroChatScreen.route(
        maestro: Maestro.medora, services: AppServices.offline()));
    await step(tester);
    await precacheFaces(tester);
    await step(tester);
    await capture(tester, rootKey, 'barra-chat.png');
  });

  testWidgets('Cattura la barra nel Consiglio dei Maestri', (tester) async {
    final rootKey = await montaApp(tester, giaRisvegliato: true);
    final nav = tester.state<NavigatorState>(find.byType(Navigator).last);
    nav.push(AskMaestriScreen.perLaSintesi(
      starter: Maestro.medora,
      tema: 'una scelta',
      lenti: [
        MaestroLens.strati(
            maestro: Maestro.aura,
            glance: 'respiro',
            reading: 'il corpo sa dove sei',
            invite: 'ascolta il fiato'),
        MaestroLens.strati(
            maestro: Maestro.caligo,
            glance: 'runa',
            reading: 'il segno parla di soglie',
            invite: 'traccia il sigillo'),
      ],
    ));
    await step(tester);
    await precacheFaces(tester);
    await step(tester);
    await capture(tester, rootKey, 'barra-consiglio.png');
  });

  testWidgets('Cattura, in un Dono del giorno la barra non si vede',
      (tester) async {
    final rootKey = await montaApp(tester, giaRisvegliato: true);
    final nav = tester.state<NavigatorState>(find.byType(Navigator).last);
    nav.push(dailyElementRoute(DailyElement.oracle));
    await step(tester);
    await capture(tester, rootKey, 'barra-assente-in-un-dono.png');
  });

  testWidgets('Cattura, in una immersiva la barra non si vede', (tester) async {
    final rootKey = await montaApp(tester, giaRisvegliato: true);
    final nav = tester.state<NavigatorState>(find.byType(Navigator).last);
    // MaestroScope attorno, come fa `home` in app.dart: lo scope avvolge la
    // home e non il builder, quindi una rotta spinta a mano ne resta fuori e il
    // fondale cosmico cade sul suo assert.
    nav.push(MaterialPageRoute<void>(
        builder: (_) => const MaestroScope(
            child: StesaTreCarteScreen(skipIntro: true, revealAll: true))));
    await step(tester);
    await capture(tester, rootKey, 'barra-assente-in-immersiva.png');
  });

}

/// Maestro offline: risponde con un testo fisso, senza rete.
class _ScriptedMaestro implements MaestroAiProvider {
  // Aggiunto con la voce S.19: il presagio delle rune passa dal confine come
  // tutte le altre voci, e una finta che non lo implementa non compila.
  @override
  Future<Responso> presagioDelleRune({
    required EsitoGettata esito,
    required String domanda,
    required UserProfile profile,
    NatalContext natal = NatalContext.none,
  }) async =>
      throw const MaestroAiUnavailable();

  @override
  bool get isReady => true;

  @override
  Future<String> reply({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory memory,
    required List<ChatMessage> history,
    required String userMessage,
    NatalContext natal = NatalContext.none,
    bool insistiSullAncoraggio = false,
    String? rispostaGiaData,
  }) async {
    return 'Le stelle ti ascoltano. Dimmi ancora, cerchiamo insieme il filo.';
  }

  @override
  Future<MaestroReply> consult({
    required Maestro maestro,
    required String theme,
    required UserProfile profile,
    MaestroMemory memory = MaestroMemory.empty,
    NatalContext? natal,
    ConsultDepth depth = ConsultDepth.breve,
  }) async {
    // Testo per Maestro, cosi' l'anteprima del confronto mostra sguardi diversi.
    switch (maestro) {
      case Maestro.medora:
        return const MaestroReply(
          glance: 'Le stelle segnano un tempo di scelta.',
          reading: 'Un transito passa, non una sentenza: le posizioni invitano, '
              'non obbligano.',
          invite: 'Qual è la prima piccola mossa che senti giusta ora?',
        );
      case Maestro.aura:
        return const MaestroReply(
          glance: 'Il corpo sa già qualcosa su questo.',
          reading: 'Se stringe la gola o il petto, chiede ascolto, non '
              'battaglia. Accolgo l\'emozione senza gonfiarla.',
          invite: 'Fai un respiro lento, una mano sul cuore: cosa si scioglie?',
        );
      case Maestro.caligo:
        return const MaestroReply(
          glance: 'La runa indica una soglia da varcare.',
          reading: 'Un passaggio di crescita e protezione, mai potere sugli '
              'altri: il simbolo mostra la via, non forza la mano.',
          invite: 'Quale gesto semplice segnerebbe il tuo passo, stasera?',
        );
    }
  }

  @override
  Future<String> synthesize({
    required String theme,
    required List<MaestroLens> lenses,
    NatalContext? natal,
  }) async =>
      throw const MaestroAiUnavailable();

  @override
  Future<MemoryDigest?> distill({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory previous,
    required List<ChatMessage> history,
  }) async =>
      null;

}

/// Non risponde mai: serve a fotografare la scena del consulto, che vive solo
/// mentre la risposta e' in volo.
/// Una voce che consegna una lettura INTERA, cioe' con un secondo strato
/// dentro: e' il solo caso in cui la freccia dell'approfondimento compare,
/// perche' sotto una lettura breve non c'e' niente da rivelare.
/// Una voce che consegna una lettura BREVE col suo consiglio marcato, e al
/// tocco il SEGUITO, cioe' il testo che manca.
class _VoceInDueStrati implements MaestroAiProvider {
  // Aggiunto con la voce S.19: il presagio delle rune passa dal confine come
  // tutte le altre voci, e una finta che non lo implementa non compila.
  @override
  Future<Responso> presagioDelleRune({
    required EsitoGettata esito,
    required String domanda,
    required UserProfile profile,
    NatalContext natal = NatalContext.none,
  }) async =>
      throw const MaestroAiUnavailable();

  _VoceInDueStrati({this.ritardoDelSeguito = Duration.zero});

  /// Quanto ci mette il SEGUITO. Zero per le catture in cui il seguito deve
  /// essere gia' arrivato, lungo per quella che mostra l'attesa.
  final Duration ritardoDelSeguito;

  @override
  bool get isReady => true;

  @override
  Future<String> reply({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory memory,
    required List<ChatMessage> history,
    required String userMessage,
    NatalContext natal = NatalContext.none,
    bool insistiSullAncoraggio = false,
    String? rispostaGiaData,
  }) async {
    if (rispostaGiaData != null) {
      await Future<void>.delayed(ritardoDelSeguito);
      return 'Sotto la superficie lavora un secondo movimento, più lento, '
          'che dura da mesi senza chiedere il tuo permesso. Non è la scelta '
          'a spaventarti, è quello che la scelta rende definitivo. La tua '
          'Luna in Pesci dice che il tempo qui non è nemico.';
    }
    return 'Il tuo Sole in Leone chiede di essere visto prima di chiedere una '
        'strada. Quello che senti come stanchezza è un confine che si '
        'sposta, non una porta che si chiude.\n'
        '${ConsiglioFinale.stella} Non decidere adesso: guarda dove ti fermi '
        'a respirare.';
  }

  @override
  Future<MaestroReply> consult({
    required Maestro maestro,
    required String theme,
    required UserProfile profile,
    MaestroMemory memory = MaestroMemory.empty,
    NatalContext? natal,
    ConsultDepth depth = ConsultDepth.breve,
  }) =>
      Completer<MaestroReply>().future;

  @override
  Future<String> synthesize({
    required String theme,
    required List<MaestroLens> lenses,
    NatalContext? natal,
  }) =>
      Completer<String>().future;

  @override
  Future<MemoryDigest?> distill({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory previous,
    required List<ChatMessage> history,
  }) async =>
      null;
}

class _VoceCheFaAspettare implements MaestroAiProvider {
  // Aggiunto con la voce S.19: il presagio delle rune passa dal confine come
  // tutte le altre voci, e una finta che non lo implementa non compila.
  @override
  Future<Responso> presagioDelleRune({
    required EsitoGettata esito,
    required String domanda,
    required UserProfile profile,
    NatalContext natal = NatalContext.none,
  }) async =>
      throw const MaestroAiUnavailable();

  @override
  bool get isReady => true;

  @override
  Future<String> reply({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory memory,
    required List<ChatMessage> history,
    required String userMessage,
    NatalContext natal = NatalContext.none,
    bool insistiSullAncoraggio = false,
    String? rispostaGiaData,
  }) =>
      Completer<String>().future;

  @override
  Future<MaestroReply> consult({
    required Maestro maestro,
    required String theme,
    required UserProfile profile,
    MaestroMemory memory = MaestroMemory.empty,
    NatalContext? natal,
    ConsultDepth depth = ConsultDepth.breve,
  }) =>
      Completer<MaestroReply>().future;

  @override
  Future<String> synthesize({
    required String theme,
    required List<MaestroLens> lenses,
    NatalContext? natal,
  }) =>
      Completer<String>().future;

  @override
  Future<MemoryDigest?> distill({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory previous,
    required List<ChatMessage> history,
  }) async =>
      null;
}
