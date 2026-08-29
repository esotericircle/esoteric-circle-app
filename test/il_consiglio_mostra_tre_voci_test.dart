import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/responsi/anatomia_del_responso.dart';
import 'dart:io';

import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/ask/ask_maestri_screen.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:esoteric_circle/features/onboarding/primo_approdo.dart';

/// IL CONSIGLIO MOSTRA LE TRE VOCI, SUBITO.
///
/// **Cosa aveva chiesto il fondatore, e cosa aveva avuto.** Un pulsante che
/// porta alla schermata di confronto. Arrivava invece in una stanza con UNA
/// carta, e le altre due voci andavano chieste una per volta con due chip.
///
/// La stanza a tre carte esisteva gia' e non era mai stata rimossa: il ciclo
/// disegna una carta per ogni Maestro in attesa o risolto. Mancava soltanto
/// che ci arrivassero tre voci invece di una.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues(const {}));

  Widget host({
    Tier tier = Tier.tier1,
    Maestro starter = Maestro.medora,
    AppServices? servizi,
    QuestionAllowance? contatore,
  }) =>
      MultiProvider(
        providers: [
          Provider<AppServices>.value(value: servizi ?? _servizi(_VoceViva())),
          ChangeNotifierProvider(create: (_) => ProfileController()),
          ChangeNotifierProvider(create: (_) => BirthIdentityController()),
          ChangeNotifierProvider(create: (_) => EntitlementService(initial: tier)),
          ChangeNotifierProvider(create: (_) => contatore ?? QuestionAllowance()),
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
        ],
        child: MaterialApp(
          home: MaestroScope(
            child: AskMaestriScreen(
                starter: starter, temaIniziale: 'devo cambiare lavoro'),
          ),
        ),
      );

  testWidgets('Le tre carte ci sono dal primo istante', (tester) async {
    await tester.pumpWidget(host());
    // UN SOLO fotogramma: nessuno ha toccato niente, e le tre carte devono
    // esserci gia'. Se comparissero solo dopo, la persona dovrebbe chiedere
    // cio' per cui e' entrata.
    await tester.pump();
    // Le prime due sono a video subito.
    for (final m in const [Maestro.medora, Maestro.caligo]) {
      expect(find.byKey(Key('ask_card_${m.id}')), findsOneWidget,
          reason: 'la carta di ${m.displayName} non c\'e\' al primo '
              'fotogramma: va chiesta, e non si doveva piu\' chiedere niente');
    }
    // LA TERZA STA SOTTO LA PIEGA, e la lista non costruisce cio' che non
    // vede. Scorrere non e' "chiedere una voce": la carta esiste gia' e non
    // aspetta nessun tocco su nessun comando. Lo si verifica scorrendo.
    // Si scorre finche' compare, invece di una trascinata a misura fissa: con
    // la sintesi passata in fondo alla lista, 1400 punti portavano oltre la
    // terza carta invece che sopra.
    await tester.scrollUntilVisible(
        find.byKey(const Key('ask_card_aura')), 300,
        scrollable: find.byType(Scrollable).first);
    expect(find.byKey(const Key('ask_card_aura')), findsOneWidget,
        reason: 'la terza carta non arriva nemmeno scorrendo');
  });

  testWidgets('Nessun pulsante chiede una singola voce', (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
    // SI SCORRE FINO IN FONDO PRIMA DI DIRE CHE NON C'E'.
    //
    // **Questa parte nasce da una prova del rosso rimasta VERDE.** Il riquadro
    // coi chip stava in CODA alla lista, sotto le tre carte: la prova guardava
    // il primo fotogramma e non lo vedeva, quindi rimettendolo dove stava
    // restava verde. Cio' che la lista non costruisce non si trova, e non
    // trovarlo non vuol dire che non ci sia.
    for (var i = 0; i < 6; i++) {
      await tester.drag(
          find.byKey(const Key('ask_results')), const Offset(0, -900));
      await tester.pump();
    }
    expect(find.byKey(const Key('ask_another_invite')), findsNothing,
        reason: 'il riquadro che chiedeva le voci una per volta e\' tornato');
    for (final m in Maestro.values) {
      expect(find.byKey(Key('ask_add_${m.id}')), findsNothing);
    }
  });

  testWidgets('Le tre voci si raccolgono UNA ALLA VOLTA', (tester) async {
    final voce = _VoceCheConta();
    await tester.pumpWidget(host(servizi: _servizi(voce)));
    await tester.pumpAndSettle();
    expect(voce.chiamate, 3, reason: 'non sono arrivate tre voci');
    expect(voce.massimoInVolo, 1,
        reason: 'sono partite ${voce.massimoInVolo} chiamate insieme, ed e\' '
            'esattamente il carico che fa scattare il 429 di Vertex');
  });

  testWidgets('Se una voce cade, le altre restano', (tester) async {
    final voce = _VoceCheCadeSu(Maestro.caligo);
    await tester.pumpWidget(host(servizi: _servizi(voce)));
    await tester.pumpAndSettle();
    // Le carte ci sono lo stesso: quella caduta porta il ripiego dichiarato.
    for (final m in const [Maestro.medora, Maestro.caligo]) {
      expect(find.byKey(Key('ask_card_${m.id}')), findsOneWidget);
    }
    // Quella arrivata bene porta la sua lettura, non un ripiego.
    expect(find.textContaining('La lettura di ${Maestro.medora.displayName}'),
        findsWidgets);
  });

  testWidgets('Continua con sta sotto OGNI carta', (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
    for (final m in const [Maestro.medora, Maestro.caligo]) {
      expect(find.text('Continua con ${m.displayName}'), findsOneWidget,
          reason: 'da ${m.displayName} non si puo\' proseguire: con tre carte '
              'da due delle tre si resterebbe fermi');
    }
  });

  test('Il dominio nasce da UN punto solo, e non si accorcia', () {
    // ENUMERA tutti i punti che mostrano o compongono un dominio, prompt della
    // sintesi compreso. E' la famiglia di difetti piu' numerosa del progetto,
    // e l'ultima e' sfuggita perche' una prova guardava due file scelti a mano.
    // **IL SECONDO FUMETTO DEL TUTORIAL E' SCRITTO DAL FONDATORE. Ordine CC
    // voce 01.**
    //
    // La regola qui sopra vale e resta: un dominio non si scrive a mano, nasce
    // dal Maestro. Il secondo fumetto del primo approdo e' l'unica eccezione,
    // e non e' una scappatoia: quelle parole le ha scritte il fondatore di suo
    // pugno il 29 agosto 2026, e l'ordine vieta di riformularle.
    //
    // **E ADESSO LE SUE PAROLE COINCIDONO CON `domainArts`**, dopo le sue
    // decisioni del 29 agosto 2026: ha allineato le sue parole all'app per
    // Medora e per Aura, e l'app alle sue per Caligo, dove la macro categoria
    // Cabala e' diventata Numerologia.
    //
    // **L'eccezione non e' piu' una scappatoia, e' pagata.** Il file del
    // tutorial esce da questa regola perche' quel testo e' suo e non si
    // compone, ma la prova qui sotto, "il fumetto dei Maestri dice
    // esattamente i domini", pretende che contenga i tre domini carattere per
    // carattere: se domani uno dei due cambia senza l'altro, cade.
    const modiLeciti = [
      'domainArts',
      'domainArtsPhrase',
    ];
    const fuoriRegola = 'lib/features/onboarding/primo_approdo.dart';
    final colpe = <String>[];
    final da = <FileSystemEntity>[Directory('lib')];
    while (da.isNotEmpty) {
      final voce = da.removeLast();
      if (voce is Directory) {
        da.addAll(voce.listSync());
        continue;
      }
      if (voce is! File || !voce.path.endsWith('.dart')) continue;
      final percorso = voce.path.replaceAll(Platform.pathSeparator, '/');
      if (percorso.endsWith(fuoriRegola)) continue;
      final righe = voce.readAsLinesSync();
      for (var i = 0; i < righe.length; i++) {
        final riga = righe[i];
        if (riga.trimLeft().startsWith('//')) continue;
        // Il campo corto non deve tornare.
        if (riga.contains('domainTitle')) {
          colpe.add('$percorso riga ${i + 1}: domainTitle e\' tornato');
        }
        // E NESSUNA SCHERMATA COMPONE UN DOMINIO SCRIVENDONE I NOMI A MANO.
        //
        // Il segno non e' il nome di un'arte: quello compare legittimamente in
        // decine di posti, per esempio "Astrologia Vedica" nel catalogo delle
        // funzioni e "Rune, I-Ching e Pendolo" nel listino. Il segno e' DUE
        // arti dello STESSO Maestro nella stessa riga, che e' il modo in cui
        // si scrive a mano un dominio.
        if (!modiLeciti.any(riga.contains)) {
          for (final m in Maestro.values) {
            final arti = m.domainArts.split(',').map((s) => s.trim());
            final quante = arti.where(riga.contains).length;
            if (quante >= 2) {
              colpe.add('$percorso riga ${i + 1}: ${riga.trim()}');
            }
          }
        }
      }
    }
    expect(colpe, isEmpty,
        reason: 'il dominio deve nascere dal Maestro e da nessun altro '
            'posto:\n${colpe.join("\n")}');
  });

  /// **IL FUMETTO DEI MAESTRI DICE ESATTAMENTE I DOMINI. Ordine CC voce 01.**
  ///
  /// E' il prezzo dell'eccezione qui sopra. Quel testo e' del fondatore e non
  /// si compone da `domainArts`, perche' comporlo vorrebbe dire che domani un
  /// cambio nel codice riscrive le sue parole senza che lui lo sappia. In
  /// cambio si pretende che le due cose dicano lo stesso: **tre domini, nove
  /// parole, carattere per carattere**.
  test('il fumetto dei Maestri dice esattamente i domini', () {
    final testo = cinqueFumetti[1].testo;
    final mute = <String>[];
    for (final m in Maestro.values) {
      final atteso = '${m.displayName}: ${m.domainArts}';
      if (!testo.contains(atteso)) mute.add(atteso);
    }
    // ignore: avoid_print
    print('ORDINE CC VOCE 01: domini del fumetto che non coincidono col '
        'Maestro ${mute.length} su ${Maestro.values.length}');
    expect(mute, isEmpty,
        reason: 'il tutorial e il codice dicono domini diversi, e chi legge '
            'trova due Cerchi: $mute');
  });

  test('Il dominio mostrato e\' quello INTERO del Maestro', () {
    for (final m in Maestro.values) {
      final arti = m.domainArts.split(',').map((s) => s.trim()).toList();
      expect(arti, hasLength(3));
      for (final arte in arti) {
        expect(m.domainArtsPhrase, contains(arte),
            reason: 'la frase del dominio di ${m.displayName} perde "$arte": '
                'accorciare il dato significa dichiarare che quell\'arte '
                'conta meno delle altre');
      }
    }
    expect(Maestro.medora.domainArtsPhrase, contains('Cartomanzia'));
  });
}

AppServices _servizi(MaestroAiProvider ai) => AppServices(
      ai: ai,
      memory: InMemoryMaestroMemoryRepository(),
      memoryPersistent: true,
    );

class _VoceViva implements MaestroAiProvider {
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
  }) async =>
      'La voce viva di ${maestro.displayName}.';

  @override
  Future<MaestroReply> consult({
    required Maestro maestro,
    required String theme,
    required UserProfile profile,
    MaestroMemory memory = MaestroMemory.empty,
    NatalContext? natal,
    ConsultDepth depth = ConsultDepth.breve,
  }) async =>
      MaestroReply(
        glance: 'Lo sguardo di ${maestro.displayName}.',
        reading: 'La lettura di ${maestro.displayName}, per esteso.',
        invite: 'Il passo di ${maestro.displayName}.',
      );

  @override
  Future<String> synthesize({
    required String theme,
    required List<MaestroLens> lenses,
    NatalContext? natal,
  }) async =>
      throw const MaestroAiUnavailable('nessuna sintesi viva in prova');

  @override
  Future<MemoryDigest?> distill({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory previous,
    required List<ChatMessage> history,
  }) async =>
      null;
}

/// Conta quante consultazioni sono in volo nello stesso momento.
class _VoceCheConta extends _VoceViva {
  int chiamate = 0;
  int inVolo = 0;
  int massimoInVolo = 0;

  @override
  Future<MaestroReply> consult({
    required Maestro maestro,
    required String theme,
    required UserProfile profile,
    MaestroMemory memory = MaestroMemory.empty,
    NatalContext? natal,
    ConsultDepth depth = ConsultDepth.breve,
  }) async {
    chiamate++;
    inVolo++;
    if (inVolo > massimoInVolo) massimoInVolo = inVolo;
    await Future<void>.delayed(const Duration(milliseconds: 5));
    inVolo--;
    return super.consult(
        maestro: maestro, theme: theme, profile: profile, memory: memory);
  }
}

/// Cade su un Maestro solo.
class _VoceCheCadeSu extends _VoceViva {
  _VoceCheCadeSu(this.chiCade);
  final Maestro chiCade;

  @override
  Future<MaestroReply> consult({
    required Maestro maestro,
    required String theme,
    required UserProfile profile,
    MaestroMemory memory = MaestroMemory.empty,
    NatalContext? natal,
    ConsultDepth depth = ConsultDepth.breve,
  }) async {
    if (maestro == chiCade) throw const MaestroAiUnavailable('la rete non risponde');
    return super.consult(
        maestro: maestro, theme: theme, profile: profile, memory: memory);
  }
}
