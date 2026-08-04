import 'dart:io';

import 'package:esoteric_circle/core/astro/celestial.dart';
import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/maestro/ancoraggio.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/maestro/sorgente_natale.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_controller.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// Il cielo della persona arriva al Maestro, da OGNI superficie.
///
/// Prima ci arrivava da una sola: il Consulta passava i dati natali, la chat no.
/// Nella chat `NatalContext` esisteva, ma serviva alla frase di benvenuto,
/// quindi il Maestro accoglieva sapendo di chi e poi rispondeva senza saperlo.
void main() {
  group('La conduttura: nessuna superficie chiama il Maestro senza il cielo',
      () {
    /// Le superfici che parlano con un Maestro. Si ENUMERANO leggendo il
    /// sorgente, non si visitano una per una: la regola deve valere per la
    /// terza superficie che nascera' domani, senza che nessuno se ne ricordi.
    test('Ogni chiamata al provider porta l\'ancoraggio', () {
      final colpe = <String>[];
      final chiamata = RegExp(r'\.(reply|consult)\(');

      for (final file in Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))) {
        final percorso = file.path.replaceAll(r'\', '/');
        // Il provider e la sorveglianza SONO il confine: la' dentro il
        // parametro si dichiara, non si passa.
        if (percorso.startsWith('lib/services/ai/')) continue;
        final sorgente = file.readAsStringSync();
        for (final trovata in chiamata.allMatches(sorgente)) {
          // Chi NON e' il provider AI, dichiarato per nome invece che escluso
          // da una regola stretta. L'oracolo e' locale e deterministico: non
          // parla con nessun Maestro, quindi non ha un cielo da portare.
          const nonSonoIlProvider = ['oracle', 'oracolo'];
          final prima = sorgente.substring(
              (trovata.start - 60).clamp(0, sorgente.length), trovata.start);
          if (nonSonoIlProvider.any(prima.contains)) continue;
          // La finestra dopo l'apertura della chiamata: gli argomenti stanno
          // li', non a duecento righe di distanza.
          final fine = (trovata.end + 420).clamp(0, sorgente.length);
          final finestra = sorgente.substring(trovata.end, fine);
          // Si taglia alla chiusura della chiamata, per non leggere quella dopo.
          final chiusura = finestra.indexOf('\n      );');
          final argomenti =
              chiusura > 0 ? finestra.substring(0, chiusura) : finestra;
          if (!argomenti.contains('natal:')) {
            final riga =
                '\n'.allMatches(sorgente.substring(0, trovata.start)).length + 1;
            colpe.add('$percorso riga $riga: chiama '
                '${trovata.group(1)} senza passare natal. Il Maestro '
                'risponderebbe senza sapere di chi.');
          }
        }
      }
      expect(colpe, isEmpty, reason: '\n${colpe.join('\n')}\n');
    });

    test('La sorgente del contesto natale e\' UNA sola', () {
      // Prima la stessa riga stava scritta due volte, in due schermate. Chi
      // ricostruisce il contesto a mano crea una seconda porta, e le due copie
      // divergono: e' gia' successo, e una delle due serviva al benvenuto
      // invece che al Maestro.
      final colpe = <String>[];
      for (final file in Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))) {
        final percorso = file.path.replaceAll(r'\', '/');
        if (percorso.endsWith('core/maestro/sorgente_natale.dart')) continue;
        if (percorso.endsWith('core/maestro/natal_context.dart')) continue;
        final sorgente = file.readAsStringSync();
        if (sorgente.contains('NatalContext.fromNatal(')) {
          colpe.add('$percorso costruisce il contesto natale a mano: '
              'deve chiederlo a SorgenteNatale.daIdentita');
        }
      }
      expect(colpe, isEmpty, reason: '\n${colpe.join('\n')}\n');
    });

    test('La sorgente unica tace quando non c\'e\' nascita', () {
      final vuoto = BirthIdentityController();
      expect(SorgenteNatale.daIdentita(vuoto).isEmpty, isTrue,
          reason: 'senza data di nascita non si inventa un segno');
    });
  });

  group('L\'ancoraggio, e quando NON si pretende', () {
    test('Senza dati non c\'e\' nessun ancoraggio, e la regola non scatta', () {
      final disponibili =
          VerificaAncoraggio.disponibiliPer(natal: NatalContext.none);
      expect(disponibili, isEmpty);
      // Qualunque risposta e' valida: pretendere un segno da chi non lo ha dato
      // porterebbe a inventarlo, e un ancoraggio falso e' peggio di nessuno.
      expect(
        VerificaAncoraggio.eAncorata('Il cielo è vasto stanotte.', disponibili),
        isTrue,
      );
    });

    test('Coi dati, gli ancoraggi vanno dal piu\' personale al piu\' generale',
        () {
      const natal = NatalContext(
        sunSign: 'Cancro',
        moonSign: 'Pesci',
        ascendant: 'Vergine',
        lifeNumber: 7,
        lifeNumberTitle: 'il Cercatore',
        moonIllumination: MoonIllumination(
            fraction: 0.25, waxing: true, elongationDeg: 60),
      );
      final disponibili = VerificaAncoraggio.disponibiliPer(natal: natal);
      expect(disponibili.first.nome, 'ascendente',
          reason: 'l\'ascendente e\' il dato piu\' personale dei tre segni');
      expect(disponibili.map((a) => a.valore), contains('Cancro'));
      expect(disponibili.map((a) => a.nome), contains('numero della vita'));
    });

    test('Un campo assente NON compare, e non si riempie', () {
      const soloSole = NatalContext(sunSign: 'Cancro');
      final disponibili = VerificaAncoraggio.disponibiliPer(natal: soloSole);
      expect(disponibili.length, 1);
      expect(disponibili.single.valore, 'Cancro');
    });

    test('Il controllo riconosce l\'ancoraggio nel testo, e la sua assenza',
        () {
      const natal = NatalContext(sunSign: 'Cancro');
      final disponibili = VerificaAncoraggio.disponibiliPer(natal: natal);
      expect(
        VerificaAncoraggio.eAncorata(
            'Il tuo Sole in Cancro chiede riparo.', disponibili),
        isTrue,
      );
      expect(
        VerificaAncoraggio.eAncorata(
            'Capisco che tu abbia paura di sbagliare.', disponibili),
        isFalse,
        reason: 'questa frase poteva essere scritta per chiunque',
      );
    });

    test('Un fatto della memoria e\' un ancoraggio a pieno titolo', () {
      const memoria = MaestroMemory(
        facts: ['A giugno ha lasciato il lavoro in tipografia'],
      );
      final disponibili = VerificaAncoraggio.disponibiliPer(
        natal: NatalContext.none,
        memory: memoria,
      );
      expect(disponibili, isNotEmpty);
      // Il Maestro riformula invece di ripetere alla lettera: basta una parola
      // sostanziosa in comune.
      expect(
        VerificaAncoraggio.eAncorata(
            'Da quando hai lasciato la tipografia, il tempo si è aperto.',
            disponibili),
        isTrue,
      );
    });
  });

  group('La rigenerazione: una sola volta, mai due', () {
    Future<MaestroChatController> conVoce(
      _VoceFinta voce, {
      NatalContext natal = const NatalContext(sunSign: 'Cancro'),
    }) async {
      final memoria = InMemoryMaestroMemoryRepository();
      await memoria.saveProfile(
          UserProfile(disclaimerAcceptedAt: DateTime(2026, 7, 1)));
      final controller = MaestroChatController(
        maestro: Maestro.medora,
        ai: voce,
        memory: memoria,
        natal: () => natal,
      );
      await controller.init();
      return controller;
    }

    test('Risposta gia\' ancorata: nessuna rigenerazione', () async {
      final voce = _VoceFinta(['Il tuo Sole in Cancro chiede riparo.']);
      final controller = await conVoce(voce);
      await controller.send('cosa mi manca');
      expect(controller.rigenerazioniPerAncoraggio, 0);
      expect(voce.chiamate, 1);
    });

    test('Risposta senza ancoraggio: UNA rigenerazione, e la seconda vale',
        () async {
      final voce = _VoceFinta([
        'Capisco che tu abbia paura.',
        'La tua Luna in Cancro ti fa sentire due volte.',
      ]);
      final controller = await conVoce(voce);
      await controller.send('cosa mi manca');
      expect(controller.rigenerazioniPerAncoraggio, 1);
      expect(voce.chiamate, 2);
      expect(voce.insistenze, 1,
          reason: 'la seconda chiamata deve chiedere di insistere');
      expect(controller.consegneSenzaAncoraggio, 0);
      expect(controller.messages.last.text, contains('Cancro'));
    });

    test('Due risposte senza ancoraggio: si consegna, e MAI una terza chiamata',
        () async {
      final voce = _VoceFinta([
        'Capisco che tu abbia paura.',
        'È normale sentirsi così.',
      ]);
      final controller = await conVoce(voce);
      await controller.send('cosa mi manca');
      expect(voce.chiamate, 2, reason: 'mai due rigenerazioni');
      expect(controller.rigenerazioniPerAncoraggio, 1);
      expect(controller.consegneSenzaAncoraggio, 1,
          reason: 'la consegna senza ancoraggio si registra, non si nasconde');
      expect(controller.messages.last.text, 'È normale sentirsi così.');
    });

    test('Senza dati natali il controllo non scatta mai', () async {
      final voce = _VoceFinta(['Il cielo è vasto stanotte.']);
      final controller = await conVoce(voce, natal: NatalContext.none);
      await controller.send('cosa mi manca');
      expect(controller.rigenerazioniPerAncoraggio, 0,
          reason: 'senza niente da ancorare non si rigenera e non si inventa');
      expect(voce.chiamate, 1);
    });
  });

  group('L\'avviso di configurazione nomina il Maestro giusto', () {
    test('Nessun nome di Maestro scritto a mano nella chat', () {
      // Diceva "La voce di Medora si attiva" anche nella chat di Aura e in
      // quella di Caligo. Si enumerano i tre nomi invece di correggere quella
      // riga: cosi' vale anche per il nome che qualcuno scrivesse domani.
      final sorgente =
          File('lib/features/maestri/chat/maestro_chat_screen.dart')
              .readAsStringSync();
      // Le stringhe mostrate, cioe' fra apici, fuori dai commenti.
      final righe = sorgente.split('\n');
      final colpe = <String>[];
      for (var i = 0; i < righe.length; i++) {
        final riga = righe[i].trim();
        if (riga.startsWith('//') || riga.startsWith('///')) continue;
        for (final maestro in Maestro.values) {
          if (riga.contains("'") && riga.contains(maestro.displayName)) {
            colpe.add('riga ${i + 1}: "${maestro.displayName}" scritto a mano '
                'in una stringa: ricavalo da maestro.displayName');
          }
        }
      }
      expect(colpe, isEmpty, reason: '\n${colpe.join('\n')}\n');
    });
  });
}

/// Una voce che restituisce risposte preparate, e conta come e' stata chiamata.
class _VoceFinta implements MaestroAiProvider {
  _VoceFinta(this._risposte);

  final List<String> _risposte;
  int chiamate = 0;
  int insistenze = 0;

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
    bool aDueStrati = true,
  }) async {
    if (insistiSullAncoraggio) insistenze++;
    final indice = chiamate.clamp(0, _risposte.length - 1);
    chiamate++;
    return _risposte[indice];
  }

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
