import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/responsi/anatomia_del_responso.dart';
import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/lettura_di_ripiego.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/misura_della_risposta.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_controller.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// "Vai piu' a fondo", e il silenzio che non lascia a mani vuote.
///
/// La profondita' non si sceglie PRIMA di leggere: la prima risposta arriva
/// sempre alla stessa misura per tutti, e chi vuole scendere lo chiede dopo.
/// Chi lo chiede ha gia' deciso che quella risposta gli interessa.
/// Una lettura lunga come quelle vere, cioe' con un secondo strato dentro.
const String _letturaLunga =
    'Il tuo Sole in Cancro chiede riparo prima di chiedere strada. '
    'Quello che senti come confusione e\' un confine che si sposta. '
    'Guarda dove ti fermi a respirare: quella e\' la direzione. '
    'Sotto la superficie c\'e\' un secondo movimento, piu\' lento, che '
    'lavora da mesi senza chiedere il tuo permesso. Non e\' la scelta a '
    'spaventarti, e\' quello che la scelta rende definitivo. Aspetta la '
    'prossima luna nuova e rileggi queste stesse parole.';

void main() {
  const natalCancro = NatalContext(sunSign: 'Cancro');

  Future<MaestroChatController> conVoce(
    _VoceContata voce, {
    Tier piano = Tier.tier1,
    QuestionAllowance? contatore,
  }) async {
    final memoria = InMemoryMaestroMemoryRepository();
    await memoria
        .saveProfile(UserProfile(disclaimerAcceptedAt: DateTime(2026, 7, 1)));
    final controller = MaestroChatController(
      maestro: Maestro.medora,
      ai: voce,
      memory: memoria,
      allowance: contatore ?? QuestionAllowance(),
      tier: () => piano,
      natal: () => natalCancro,
    );
    await controller.init();
    return controller;
  }

  group('La prima e\' breve, il seguito ha la sua misura', () {
    test('Cinquanta la prima, centotrenta il seguito, centottanta in tutto',
        () {
      expect(MisuraDellaRisposta.perChat, MisuraDellaRisposta.letturaBreve);
      expect(MisuraDellaRisposta.perIlSeguito, MisuraDellaRisposta.seguito);
      expect(MisuraDellaRisposta.letturaBreve.parole, 50);
      expect(MisuraDellaRisposta.seguito.parole, 130);
      expect(MisuraDellaRisposta.letturaDellaChat.parole, 180);
    });

    test('La lunghezza chiesta arriva al Maestro, e cambia col momento', () {
      final prima = MaestroPersona.systemInstruction(
        maestro: Maestro.medora,
        profile: UserProfile.empty,
        memory: MaestroMemory.empty,
      );
      final seguito = MaestroPersona.systemInstruction(
        maestro: Maestro.medora,
        profile: UserProfile.empty,
        memory: MaestroMemory.empty,
        rispostaGiaData: 'quel che ho gia\' detto.',
      );
      expect(prima, contains('circa cinquanta parole'));
      expect(seguito, contains('circa centotrenta parole'));
    });

    test('La regola dei due strati e\' in OGNI istruzione, non in una sola',
        () {
      for (final maestro in Maestro.values) {
        final istr = MaestroPersona.systemInstruction(
          maestro: maestro,
          profile: UserProfile.empty,
          memory: MaestroMemory.empty,
        );
        expect(istr, contains(MaestroPersona.regolaDeiDueStrati),
            reason: '${maestro.displayName} non sa che le prime frasi devono '
                'reggere da sole');
      }
    });
  });

  group('Il budget governa cio\' che si SCRIVE, non cio\' che si legge', () {
    test('Il Viandante non ha il secondo strato nel piano', () {
      final contatore = QuestionAllowance();
      expect(contatore.pianoConApprofondimento(Tier.free), isFalse);
      expect(contatore.puoiApprofondire(Tier.free), isFalse);
    });

    test('Iniziato tre, Adepto dieci, Illuminato trenta', () {
      // **TRENTA, E NON PIU' "SENZA LIMITE".** Ordine CE voce 08: il
      // fondatore ha chiesto che l'illimitato sparisca da ogni cella. Il
      // numero segue il dato del listino, non lo anticipa, e il residuo
      // dell'Illuminato adesso e' un conto vero invece del tetto di
      // correttezza che si usava quando non c'era nessun tetto.
      final contatore = QuestionAllowance();
      expect(contatore.limiteApprofondimenti(Tier.tier1), 3);
      expect(contatore.limiteApprofondimenti(Tier.tier2), 10);
      expect(contatore.limiteApprofondimenti(Tier.tier3), 30);
      expect(contatore.approfondimentiRimasti(Tier.tier3), 30);
    });

    test('Una lettura intera NON consuma una domanda del giorno', () {
      final contatore = QuestionAllowance();
      final domandePrima = contatore.remaining(Tier.tier1);
      contatore.registraApprofondimento(Tier.tier1);
      expect(contatore.remaining(Tier.tier1), domandePrima,
          reason: 'se consumasse una domanda la persona esiterebbe, e '
              'l\'esitazione uccide l\'intimita\'');
      expect(contatore.approfondimentiRimasti(Tier.tier1), 2);
    });

    test('I due budget ribaltano insieme, perche\' il giorno e\' lo stesso',
        () {
      var oggi = DateTime(2026, 8, 2, 23, 0);
      final contatore = QuestionAllowance(clock: () => oggi);
      contatore.record(Tier.tier1);
      contatore.registraApprofondimento(Tier.tier1);
      expect(contatore.approfondimentiRimasti(Tier.tier1), 2);
      oggi = DateTime(2026, 8, 3, 1, 0);
      expect(contatore.approfondimentiRimasti(Tier.tier1), 3);
      expect(contatore.usedToday(), 0);
    });

    test('Il budget si consuma quando si LEGGE, non quando si scrive',
        () async {
      // **QUESTA PROVA DICEVA IL CONTRARIO, e sbagliava.** Nell'ordine 9 il
      // budget era stato spostato a governare la produzione: chi non toccava
      // mai la freccia consumava lo stesso, e soprattutto il secondo strato
      // era smesso di essere un Premium. I tetti governano l'ACCESSO.
      final contatore = QuestionAllowance();
      final voce = _VoceContata([_letturaLunga]);
      final controller = await conVoce(voce, contatore: contatore);
      final prima = contatore.approfondimentiRimasti(Tier.tier1);
      await controller.send('cosa mi manca');
      expect(contatore.approfondimentiRimasti(Tier.tier1), prima,
          reason: 'scrivere non consuma: consuma leggere');
      await controller.approfondisci();
      expect(contatore.approfondimentiRimasti(Tier.tier1), prima - 1);
    });

    test('Finito il budget, la lettura resta breve e non si legge oltre',
        () async {
      final contatore = QuestionAllowance();
      for (var i = 0; i < 3; i++) {
        contatore.registraApprofondimento(Tier.tier1);
      }
      expect(contatore.puoiApprofondire(Tier.tier1), isFalse);
      final voce = _VoceContata([_letturaLunga]);
      final controller = await conVoce(voce, contatore: contatore);
      await controller.send('cosa mi manca');
      expect(voce.ultimoSeguito, isNull,
          reason: 'a chi non puo\' leggere il secondo strato e\' stato chiesto '
              'un seguito lo stesso');
      await controller.approfondisci();
      expect(controller.messages.last.approfondita, isFalse,
          reason: 'finito il budget si legge lo stesso');
    });
  });

  group('L\'invito, e cosa succede al tocco', () {
    test('Compare su una lettura che ha davvero un secondo strato', () async {
      final voce = _VoceContata([_letturaLunga]);
      final controller = await conVoce(voce);
      expect(controller.puoiChiedereDiApprofondire, isFalse,
          reason: 'a conversazione vuota non c\'e\' niente da rivelare');
      await controller.send('cosa mi manca');
      expect(controller.puoiChiedereDiApprofondire, isTrue);
      await controller.approfondisci();
      expect(controller.puoiChiedereDiApprofondire, isFalse,
          reason: 'due volte sarebbe una scala senza fine');
    });

    test('La freccia si vede SEMPRE, anche su una lettura corta', () async {
      // **QUESTA PROVA DICEVA IL CONTRARIO, e sbagliava.** Diceva che sotto
      // una lettura corta non c'e' niente da rivelare, quindi la freccia non
      // compare. Ma il seguito adesso si genera al tocco: non serve che
      // esistesse gia'. E la freccia deve vedersi anche a chi non ha il
      // secondo strato nel piano, perche' e' li' che si scopre che esiste.
      final voce = _VoceContata(['Il tuo Sole in Cancro chiede riparo.']);
      final controller = await conVoce(voce);
      await controller.send('cosa mi manca');
      expect(controller.puoiChiedereDiApprofondire, isTrue,
          reason: 'la freccia sparisce, e con lei sparisce il modo di sapere '
              'che il secondo strato esiste');
    });

    test('Il tocco CHIAMA il modello, e chiede solo il seguito', () async {
      // **QUESTA PROVA DICEVA IL CONTRARIO, e sbagliava.** Nell'ordine 9 il
      // testo lungo si generava insieme al breve, quindi il tocco non
      // chiamava nessuno. Adesso si genera al tocco: se un Premium non tocca
      // mai la freccia, quella spesa non si fa.
      final voce = _VoceContata([_letturaLunga]);
      final controller = await conVoce(voce);
      await controller.send('cosa mi manca');
      final quanteBolle = controller.messages.length;
      final chiamatePrima = voce.chiamate;
      final testoPrima = controller.messages.last.text;

      await controller.approfondisci();
      expect(voce.chiamate, chiamatePrima + 1,
          reason: 'il tocco non ha chiesto niente al Maestro');
      expect(voce.ultimoSeguito, testoPrima,
          reason: 'il Maestro non ha ricevuto cio\' che aveva gia\' detto');
      expect(controller.messages.length, quanteBolle,
          reason: 'e\' la stessa lettura, non una seconda risposta');
      expect(controller.messages.last.text, testoPrima,
          reason: 'il breve non si tocca: il seguito sta in un campo suo');
      expect(controller.messages.last.seguito, isNotNull);
      expect(controller.messages.last.approfondita, isTrue);
    });

    test('Non compare su un ripiego', () async {
      final voce = _VoceContata([], sempreInGuasto: true);
      final controller = await conVoce(voce);
      await controller.send('cosa mi manca');
      expect(controller.messages.last.ripiego, isTrue);
      expect(controller.puoiChiedereDiApprofondire, isFalse,
          reason: 'non si rivela cio\' che il Maestro non ha detto');
    });
  });

  group('Il silenzio consegna una lettura vera', () {
    test('Con dei dati, legge davvero e dichiara di essere un ripiego', () {
      final testo = LetturaDiRipiego.componi(
        maestro: Maestro.medora,
        domanda: 'cosa mi manca',
        natal: natalCancro,
      );
      // 1. Dichiara di non essere la sua voce.
      expect(testo, startsWith('Il cielo si è coperto'));
      // 2. Legge DAVVERO, col dato vero di questa persona.
      expect(testo, contains('Cancro'));
      // 3. E porta da qualche parte: nessuno stato senza uscita.
      expect(testo, contains('carta natale'));
    });

    test('Senza dati non inventa, ma la via d\'uscita resta', () {
      final testo = LetturaDiRipiego.componi(
        maestro: Maestro.caligo,
        domanda: 'cosa mi manca',
        natal: NatalContext.none,
      );
      expect(testo, contains('nebbia'),
          reason: 'il ripiego di Caligo apre come sempre');
      expect(testo, contains('runa'),
          reason: 'anche senza dati la porta c\'è');
      // Non deve nominare un segno che non esiste.
      expect(testo.contains('in Cancro'), isFalse);
    });

    test('Ogni Maestro ha la sua lettura e la sua uscita', () {
      // Enumerati: la regola vale per i tre, e per quello che nascera' domani.
      final uscite = <String>{};
      for (final maestro in Maestro.values) {
        final testo = LetturaDiRipiego.componi(
          maestro: maestro,
          domanda: 'cosa mi manca',
          natal: natalCancro,
        );
        expect(testo.trim(), isNotEmpty);
        uscite.add(testo.split('\n').last);
      }
      expect(uscite.length, Maestro.values.length,
          reason: 'tre Maestri con la stessa uscita non sono tre Maestri');
    });

    test('La chat consegna la lettura vera quando la voce tace', () async {
      final voce = _VoceContata([], sempreInGuasto: true);
      final controller = await conVoce(voce);
      await controller.send('cosa mi manca');
      final bolla = controller.messages.last;
      expect(bolla.ripiego, isTrue);
      expect(bolla.text, contains('Cancro'),
          reason: 'il ripiego deve LEGGERE, non solo scusarsi');
      expect(bolla.text, contains('carta natale'),
          reason: 'nessuno stato senza una via di uscita');
    });
  });
}

/// Una voce che conta come e' stata chiamata e sa fallire su richiesta.
class _VoceContata implements MaestroAiProvider {
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

  _VoceContata(
    this._risposte, {
    this.sempreInGuasto = false,
  });

  final List<String> _risposte;
  final bool sempreInGuasto;
  int chiamate = 0;

  /// Cio' che il Maestro ha ricevuto come "gia' detto". Nullo sulla prima
  /// chiamata: e' il modo di distinguere la risposta breve dal seguito.
  String? ultimoSeguito;

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
    ultimoSeguito = rispostaGiaData;
    if (sempreInGuasto) throw Exception('la voce tace');
    chiamate++;
    // IL SEGUITO E' UN TESTO DIVERSO, altrimenti l'app lo ripulisce tutto e
    // la prova misurerebbe il filtro invece del budget.
    //
    // **E DICEVA IL FALSO.** Il testo di prima era "Sotto quel confine lavora
    // un movimento piu' lento, che dura da mesi senza chiedere il tuo
    // permesso", cioe' la stessa frase del primo strato girata in un altro
    // modo: somiglianza 0,667 contro una soglia di 0,32. Passava soltanto
    // perche' il filtro di allora confrontava le frasi per identita' esatta.
    // Le due frasi qui sotto stanno a 0,174 e a 0,050, misurate con
    // `SeguitoDellaLettura.somiglianza`.
    if (rispostaGiaData != null) {
      return 'La luna nuova cade fra undici giorni: fino ad allora nessuna '
          'porta si chiude per davvero. Chi ti sta vicino in questo passaggio '
          'pesa piu\' del passaggio stesso.';
    }
    final indice = (chiamate - 1).clamp(0, _risposte.length - 1);
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
