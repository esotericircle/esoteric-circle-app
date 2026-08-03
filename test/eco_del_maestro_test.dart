import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/raccolta_delle_risposte.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/eco/archivio_dell_eco.dart';
import 'package:esoteric_circle/core/eco/eco_del_maestro.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/maestro/voce_del_maestro.dart';
import 'package:esoteric_circle/core/tempo/confine_del_giorno.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_controller.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// L'ECO, e la persona sa perche'.
///
/// **Non e' una cosa in piu': e' la chiusura che gia' esiste, resa
/// persistente.** Ogni Maestro chiude a modo suo, e da quella chiusura nasce
/// UNA parola sola, che ha nominato lui. Nessuna seconda chiamata all'AI.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  final oggi = DateTime(2026, 8, 3, 21, 30);
  final domani = DateTime(2026, 8, 4, 0, 1);

  group('3a. La parola nasce dalla CHIUSURA, non da un secondo elenco', () {
    test('Il nome noto vince, ed e\' quello che il Maestro ha detto', () {
      final eco = NascitaDellEco.da(
        maestro: Maestro.caligo,
        risposta: 'Una nebbia argentea si posa. Il sentiero si apre. '
            'Ti affido il sigillo di Laguz.',
        domanda: 'mi sento fermo',
        adesso: oggi,
      );
      expect(eco, isNotNull);
      expect(eco!.parola, 'Laguz');
      expect(eco.chiusura, 'Ti affido il sigillo di Laguz.',
          reason: 'la provenienza deve poter mostrare la riga VERA: una '
              'provenienza che non si può leggere non è una provenienza');
    });

    test('Senza nome noto vale il lessico di FIRMA, che esiste gia\'', () {
      final eco = NascitaDellEco.da(
        maestro: Maestro.aura,
        risposta: 'Il respiro si ferma. Il corpo lo sa. '
            'Posa una mano sul ventre e senti il respiro.',
        domanda: 'mi sento fermo',
        adesso: oggi,
      );
      expect(eco!.parola, 'respiro');
      expect(VoceDelMaestro.di(Maestro.aura).lessicoDiFirma,
          contains(eco.parola),
          reason: 'la parola viene da un dato che esisteva PRIMA dell\'Eco, '
              'non da un elenco scritto per lei');
    });

    test('La parola si cerca SOLO nella chiusura', () {
      // "runa" sta nel corpo della risposta, non nella chiusura: non deve
      // diventare l'Eco, altrimenti non nascerebbe piu' dalla chiusura.
      final parola = NascitaDellEco.parolaNella(
          'Guarda dove ti porta il passo.', Maestro.caligo);
      expect(parola, isNull);
      final eco = NascitaDellEco.da(
        maestro: Maestro.caligo,
        risposta: 'La runa parla del fuoco. Il presagio è chiaro. '
            'Guarda dove ti porta il passo.',
        domanda: 'mi sento fermo',
        adesso: oggi,
      );
      expect(eco, isNull,
          reason: 'la chiusura non porta nessuna parola nominabile, e non si '
              'ripiega su una parola qualunque presa altrove');
    });

    test('E\' DIVERSA per i tre Maestri sullo stesso tema', () {
      // Le tre chiusure sono diverse per costruzione, e le tre parole con
      // loro: se due coincidessero, l'Eco non direbbe piu' chi l'ha lasciata.
      const chiusure = {
        Maestro.medora: 'Torna a guardare il cielo fra sette giorni.',
        Maestro.aura: 'Posa una mano sul ventre e senti il respiro.',
        Maestro.caligo: 'Ti affido il sigillo di Laguz.',
      };
      final parole = <String>{};
      for (final voce in chiusure.entries) {
        final p = NascitaDellEco.parolaNella(voce.value, voce.key);
        expect(p, isNotNull, reason: '${voce.key.displayName} non lascia nulla');
        parole.add(p!);
      }
      expect(parole.length, 3,
          reason: 'due Maestri lasciano la stessa parola sullo stesso tema');
    });
  });

  group('3b. La persona sa PERCHE\'', () {
    test('La riga la dice LUI, ed e\' diversa per i tre', () {
      final righe = <String>{};
      for (final maestro in Maestro.values) {
        final voce = VoceDelMaestro.di(maestro);
        final riga = voce.ecoCon('Laguz');
        // 1. Porta la parola.
        expect(riga, contains('Laguz'));
        // 2. Dice cosa succede DOMANI: senza, la persona non sa perche'
        //    dovrebbe tornare.
        expect(riga.toLowerCase(), contains('mezzanotte'),
            reason: '${maestro.displayName} non dice fino a quando');
        // 3. E' nella sua voce: porta una parola del suo lessico di firma.
        expect(
          voce.lessicoDiFirma.any((f) => riga.toLowerCase().contains(f)),
          isTrue,
          reason: '${maestro.displayName}: la riga potrebbe essere di '
              'chiunque, cioè è un avviso di sistema travestito',
        );
        righe.add(riga);
      }
      expect(righe.length, Maestro.values.length,
          reason: 'due Maestri lasciano la parola con la stessa frase');
    });

    test('Il giorno dopo, la riga dice DA DOVE VIENE', () {
      const eco = EcoDelMaestro(
        maestro: Maestro.medora,
        parola: 'cielo',
        chiusura: 'Torna a guardare il cielo fra sette giorni.',
        domanda: 'ho paura di sbagliare',
        giorno: '2026-8-3',
      );
      // Le due cose che servono: quale Maestro, e quale conversazione.
      expect(eco.daDoveViene, contains('Medora'));
      expect(eco.daDoveViene, contains('ho paura di sbagliare'));
    });

    test('Senza la domanda dice comunque chi l\'ha lasciata', () {
      const eco = EcoDelMaestro(
        maestro: Maestro.aura,
        parola: 'respiro',
        chiusura: 'Senti il respiro.',
        domanda: '',
        giorno: '2026-8-3',
      );
      expect(eco.daDoveViene, contains('Aura'));
      expect(eco.daDoveViene.trim(), isNotEmpty,
          reason: 'la riga che spiega il perché c\'è SEMPRE');
    });
  });

  group('3c. Dove vive e quanto dura', () {
    test('Vale oggi, non vale domani: il confine e\' MEZZANOTTE', () {
      final eco = EcoDelMaestro(
        maestro: Maestro.medora,
        parola: 'cielo',
        chiusura: 'Torna a guardare il cielo.',
        domanda: 'mi sento fermo',
        giorno: ConfineDelGiorno.chiaveDi(oggi),
      );
      expect(eco.valeA(oggi), isTrue);
      expect(eco.valeA(DateTime(2026, 8, 3, 23, 59)), isTrue,
          reason: 'un minuto prima di mezzanotte vale ancora');
      expect(eco.valeA(domani), isFalse,
          reason: 'un minuto dopo mezzanotte non vale piu\'');
    });

    test('Il confine e\' lo STESSO dei tetti d\'uso, non quello rituale', () {
      // Se fossero due definizioni diverse, l'app ribalterebbe i contatori in
      // un momento e l'Eco in un altro.
      expect(ConfineDelGiorno.chiaveDi(DateTime(2026, 8, 3, 23, 59)),
          ConfineDelGiorno.chiaveDi(DateTime(2026, 8, 3, 0, 1)),
          reason: 'la giornata d\'uso non si spezza a mezzogiorno');
      expect(ConfineDelGiorno.chiaveDi(DateTime(2026, 8, 3, 12, 1)),
          isNot(ConfineDelGiorno.chiaveDi(DateTime(2026, 8, 4, 11, 59))));
    });

    testWidgets('SOPRAVVIVE alla chiusura dell\'app', (tester) async {
      // Si posa con un archivio, si rilegge con un ALTRO: e' il modo in cui si
      // prova che il dato e' uscito dalla memoria e tornato.
      final eco = EcoDelMaestro(
        maestro: Maestro.caligo,
        parola: 'Laguz',
        chiusura: 'Ti affido il sigillo di Laguz.',
        domanda: 'mi sento fermo',
        giorno: ConfineDelGiorno.chiaveDi(oggi),
      );
      await (ArchivioDellEco(clock: () => oggi)).posa(eco);

      final riaperto = ArchivioDellEco(clock: () => oggi);
      expect(riaperto.viva, isNull, reason: 'prima di caricare non c\'è nulla');
      await riaperto.carica();
      expect(riaperto.viva, isNotNull);
      expect(riaperto.viva!.parola, 'Laguz');
      expect(riaperto.viva!.chiusura, 'Ti affido il sigillo di Laguz.');
      expect(riaperto.viva!.domanda, 'mi sento fermo');
    });

    testWidgets('E SPARISCE al confine di mezzanotte, anche da salvata',
        (tester) async {
      final eco = EcoDelMaestro(
        maestro: Maestro.caligo,
        parola: 'Laguz',
        chiusura: 'Ti affido il sigillo di Laguz.',
        domanda: 'mi sento fermo',
        giorno: ConfineDelGiorno.chiaveDi(oggi),
      );
      await (ArchivioDellEco(clock: () => oggi)).posa(eco);

      final ilGiornoDopo = ArchivioDellEco(clock: () => domani);
      await ilGiornoDopo.carica();
      expect(ilGiornoDopo.viva, isNull,
          reason: 'l\'Eco di ieri non deve comparire oggi: il controllo si fa '
              'in LETTURA, perché un\'app chiusa a mezzanotte non può '
              'eseguire nessuna pulizia');
    });
  });

  group('3d. Quando non c\'e\', non si finge', () {
    test('Una conversazione senza risposte compiute non lascia nulla',
        () async {
      final controller = await _conVoce(_VoceMuta());
      await controller.send('mi sento fermo');
      expect(controller.messages.last.ripiego, isTrue);
      // Il MECCANISMO, non solo l'esito: l'Eco nasce dalla risposta VIVA, e
      // fra soli ripieghi non ce n'e' nessuna. Guardare il solo esito lasciava
      // passare il difetto, perche' il testo di un ripiego non porta comunque
      // nessuna parola nominabile nella sua ultima frase: la prova sarebbe
      // stata verde per la ragione sbagliata.
      expect(RaccoltaDelleRisposte.indiceDellaViva(controller.messages), -1,
          reason: 'un ripiego non è una lettura viva');
      expect(controller.ecoDellUltima, isNull,
          reason: 'un ripiego non lascia una parola');
    });

    test('Una risposta senza chiusura nominabile non lascia nulla', () {
      final eco = NascitaDellEco.da(
        maestro: Maestro.medora,
        risposta: 'Il tempo passa. Le cose cambiano. Vedrai da te.',
        domanda: 'mi sento fermo',
        adesso: oggi,
      );
      expect(eco, isNull,
          reason: 'meglio nessuna parola che una parola qualunque da portare '
              'per un giorno intero');
    });

    test('Un ripiego DOPO non cancella la parola già lasciata', () async {
      // Il caso che distingue "l'ultima bolla" da "l'ultima LETTURA VIVA".
      // Senza questa prova, far nascere l'Eco dall'ultimo messaggio qualunque
      // restava verde: il testo di un ripiego non porta comunque nessuna
      // parola nominabile, quindi l'esito coincideva per la ragione sbagliata.
      final voce = _VoceCheTaceDopo('La tua Luna in Pesci chiude un ciclo. '
          'Ti affido il sigillo di Laguz.');
      final controller = await _conVoce(voce);
      await controller.send('mi sento fermo');
      expect(controller.ecoDellUltima?.parola, 'Laguz');

      await controller.send('e adesso');
      expect(controller.messages.last.ripiego, isTrue);
      expect(controller.ecoDellUltima?.parola, 'Laguz',
          reason: 'la parola era già stata lasciata: un guasto dopo non '
              'gliela toglie di mano');
    });

    test('Da una lettura VERA, invece, nasce e si posa', () async {
      final archivio = ArchivioDellEco(clock: () => oggi);
      final controller = await _conVoce(
        _VoceCheRisponde('La tua Luna in Pesci chiude un ciclo. '
            'Ti affido il sigillo di Laguz.'),
        eco: archivio,
      );
      await controller.send('mi sento fermo');
      expect(controller.ecoDellUltima?.parola, 'Laguz');
      expect(archivio.viva?.parola, 'Laguz',
          reason: 'si posa nel Cerchio, non solo nella conversazione');
      expect(archivio.viva?.domanda, 'mi sento fermo');
    });
  });
}

Future<MaestroChatController> _conVoce(
  MaestroAiProvider voce, {
  ArchivioDellEco? eco,
}) async {
  final memoria = InMemoryMaestroMemoryRepository();
  await memoria
      .saveProfile(UserProfile(disclaimerAcceptedAt: DateTime(2026, 7, 1)));
  final controller = MaestroChatController(
    maestro: Maestro.medora,
    ai: voce,
    memory: memoria,
    allowance: QuestionAllowance(),
    eco: eco,
    natal: () => const NatalContext(sunSign: 'Cancro', moonSign: 'Pesci'),
  );
  await controller.init();
  return controller;
}

class _VoceCheRisponde implements MaestroAiProvider {
  _VoceCheRisponde(this.testo);
  final String testo;

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
    bool approfondisci = false,
  }) async =>
      testo;

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

/// Risponde la prima volta, poi tace: serve a distinguere l'ultima bolla
/// dall'ultima lettura viva.
class _VoceCheTaceDopo extends _VoceCheRisponde {
  _VoceCheTaceDopo(super.testo);

  int _giri = 0;

  @override
  Future<String> reply({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory memory,
    required List<ChatMessage> history,
    required String userMessage,
    NatalContext natal = NatalContext.none,
    bool insistiSullAncoraggio = false,
    bool approfondisci = false,
  }) async {
    _giri++;
    if (_giri > 1) throw const MaestroAiUnavailable('la voce tace');
    return testo;
  }
}

class _VoceMuta extends _VoceCheRisponde {
  _VoceMuta() : super('');

  @override
  Future<String> reply({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory memory,
    required List<ChatMessage> history,
    required String userMessage,
    NatalContext natal = NatalContext.none,
    bool insistiSullAncoraggio = false,
    bool approfondisci = false,
  }) async =>
      throw const MaestroAiUnavailable('la voce tace');
}
