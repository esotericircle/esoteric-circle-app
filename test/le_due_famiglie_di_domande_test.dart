import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/responsi/anatomia_del_responso.dart';
import 'dart:io';

import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_screen.dart';
import 'package:esoteric_circle/features/maestri/chat/widgets/chat_suggestions.dart';
import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LE DUE FAMIGLIE DI DOMANDE, INTERE E DIVISE, NEL PANNELLO.
///
/// Storia a due tempi. Il 12 luglio 2026 (93e1481) le famiglie sparirono
/// dietro un bottone; l'ordine 2161 le riporto' sul primo schermo; l'ordine
/// 2163 (voci 3 e 4) le ha spostate nel PANNELLO unito, che e' la casa
/// definitiva: sul primo schermo resta un assaggio di tre voci in riga.
/// Questa prova custodisce cio' che non cambia: le famiglie INTERE e
/// DIVISE, il vero sulle personali (una domanda che nomina un dato assente
/// non compare), la rotazione deterministica sul giorno.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzia() {
    final messenger = binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (call) async => null,
    );
    for (final nome in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      messenger.setMockStreamHandler(
        EventChannel(nome),
        MockStreamHandler.inline(onListen: (args, events) {}),
      );
    }
  }

  testWidgets('i tre domini, enumerati: due famiglie, conti pieni',
      (tester) async {
    silenzia();
    SharedPreferences.setMockInitialValues({
      'onboarding.done': true,
      // La data di nascita c'e': il Sole si calcola dalla data, quindi le
      // personali sul Sole devono comparire. Luna e Ascendente chiedono la
      // carta, che qui non c'e': quelle domande NON devono comparire.
      'profile.birthDate': '1990-08-15',
    });
    tester.view.physicalSize = const Size(1080, 2391);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    final servizi = AppServices(
      ai: const _VocePronta(),
      memory: InMemoryMaestroMemoryRepository(),
      memoryPersistent: false,
    );
    await tester
        .pumpWidget(EsotericCircleApp(conIntro: false, services: servizi));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).last);

    final colpe = <String>[];
    for (final maestro in Maestro.fixedOrder) {
      nav.push(MaestroChatScreen.route(maestro: maestro, services: servizi));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // Dal 2163 le famiglie vivono nel pannello, e dal 2164 (voci 3 e 4)
      // la porta che lo apre e' UNA SOLA: l'icona a stelline accanto al
      // campo. L'invito che questa prova toccava prima non esiste piu'.
      await tester.tap(find.byKey(const Key('chat_stelline')),
          warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      // Il pannello e' scorrevole e PIGRO: cio' che sta sotto la piega non
      // e' ancora costruito, quindi ogni pretesa si cerca scorrendo.
      Future<bool> trovaScorrendo(String domanda) async {
        var c = 0;
        while (find.text(domanda).evaluate().isEmpty && c < 12) {
          await tester.drag(find.byKey(const Key('pannello_suggerimenti')),
              const Offset(0, -120),
              warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 120));
          c++;
        }
        return find.text(domanda).evaluate().isNotEmpty;
      }

      // **LE DUE FAMIGLIE ADESSO SONO DUE TITOLI SELEZIONABILI**, ordine
      // 2164 voce 7: prima stavano una dopo l'altra nello stesso
      // scorrevole e si raggiungevano scorrendo. I titoli ci sono tutti e
      // due subito, e le personali si leggono dopo aver toccato il loro.
      // La regola provata NON cambia: le liste restano intere e le
      // personali passano dal filtro del vero.
      if (find.text('DOMANDE FREQUENTI').evaluate().isEmpty) {
        colpe.add('${maestro.displayName}: manca la famiglia delle '
            'frequenti nel pannello');
      }
      if (find.text('DOMANDE PERSONALI').evaluate().isEmpty) {
        colpe.add('${maestro.displayName}: manca la famiglia delle '
            'personali nel pannello');
      }
      final attese = SuggestionSets.frequent(maestro).length;
      var visti = 0;
      for (final domanda in SuggestionSets.frequent(maestro)) {
        if (await trovaScorrendo(domanda)) visti++;
      }
      if (visti < attese) {
        colpe.add('${maestro.displayName}: frequenti nel pannello $visti '
            'su $attese, il taglio e\' tornato');
      }
      // Si passa alle personali col tocco sul loro titolo.
      await tester.tap(find.byKey(const Key('titolo_personali')),
          warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      // Le personali disponibili con la sola data: quelle sul Sole, tutte.
      // Quelle su Luna e Ascendente non devono esserci: direbbero il falso.
      for (final domanda in SuggestionSets.personal(maestro)) {
        final b = domanda.toLowerCase();
        if (b.contains('sole') &&
            !b.contains('luna') &&
            !b.contains('ascendente')) {
          if (!await trovaScorrendo(domanda)) {
            colpe.add('${maestro.displayName}: "$domanda" ha il suo dato '
                'e non compare nel pannello');
          }
        } else if ((b.contains('luna') || b.contains('ascendente')) &&
            find.text(domanda).evaluate().isNotEmpty) {
          colpe.add('${maestro.displayName}: "$domanda" nomina un dato '
              'assente ed e\' comparsa lo stesso');
        }
      }
      // Si chiude il pannello prima di lasciare la stanza.
      await tester.tapAt(const Offset(10, 60));
      await tester.pump(const Duration(milliseconds: 400));
      nav.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });

  test('la prima schermata non monta piu\' i soli starters', () {
    final testo = File('lib/features/maestri/chat/maestro_chat_screen.dart')
        .readAsStringSync();
    expect(testo.contains('SuggestionSets.starters('), isFalse,
        reason: 'La prima schermata e\' tornata ai tre chip senza famiglie: '
            'e\' la riduzione del 12 luglio che Mauro ha revocato.');
  });

  test('la rotazione e\' deterministica su persona e giorno', () {
    final a = SuggestionSets.ruotaPerGiorno(
        SuggestionSets.personal(Maestro.medora), 'x', DateTime(2026, 8, 7));
    final b = SuggestionSets.ruotaPerGiorno(
        SuggestionSets.personal(Maestro.medora), 'x', DateTime(2026, 8, 7));
    expect(a, b,
        reason: 'Stessa persona e stesso giorno, ordine diverso: '
            'c\'e\' un caso vero nella rotazione.');
    final c = SuggestionSets.ruotaPerGiorno(
        SuggestionSets.personal(Maestro.medora), 'x', DateTime(2026, 8, 9));
    expect(a, isNot(c),
        reason: 'Due giorni diversi, stesso ordine: la rotazione non ruota.');
  });
}

/// Una voce pronta: con la voce spenta l'invito alle stelline e' spento
/// anch'esso, e il pannello non si aprirebbe.
class _VocePronta implements MaestroAiProvider {
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

  const _VocePronta();

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
      'Il cielo osserva con te questa domanda e la tiene aperta.';

  @override
  Future<MaestroReply> consult({
    required Maestro maestro,
    required String theme,
    required UserProfile profile,
    MaestroMemory memory = MaestroMemory.empty,
    NatalContext? natal,
    ConsultDepth depth = ConsultDepth.breve,
  }) async =>
      throw const MaestroAiUnavailable();

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
