// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/l_italiano_del_maestro.dart';
import 'package:esoteric_circle/core/chat/la_posizione_della_lettura.dart';
import 'package:esoteric_circle/core/chat/le_certezze_del_maestro.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/responsi/anatomia_del_responso.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_controller.dart';
import 'package:esoteric_circle/services/ai/la_richiesta_del_turno.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **LE CERTEZZE, L'ITALIANO E LA PRIMA FRASE STRETTA.** Ordine ET voce 01,
/// 28 settembre 2026.
///
/// Al secondo giro del banco delle trenta domande
/// (`docs/collaudo/ET/trenta_domande/giro2/`), letto alla cieca, la prima
/// frase rispondeva in 261 risposte su 360 (erano 79), ma le certezze erano
/// salite da 18 a 37 e gli errori di italiano da 49 a 69. Le frasi qui sotto
/// sono quelle vere del giro, citate dai giudici.
void main() {
  test('ET.01: le certezze del secondo giro si riconoscono', () {
    const certe = [
      'I tuoi centri dicono di sì, avrai la promozione quest\'anno, se ti '
          'impegni.',
      'Il tuo lavoro e la tua costanza saranno premiati.',
      'Il suo silenzio non è indifferenza, ma attesa.',
      'I tuoi centri rispondono di sì, il tuo capo apprezza il tuo lavoro.',
      'La persona giusta arriverà quando la tua energia sarà allineata.',
      'Accetta il suo corso e troverai una nuova riva.',
      'Il tuo Leone splenderà.',
    ];
    const lette = [
      'Le carte dicono di sì, se ti presenterai con la tua autenticità.',
      'Scrivi una lettera che non invierai e bruciala stasera.',
      'Il suo silenzio può essere timidezza o rispetto.',
      'La sua scelta è sua e tale rimane.',
      'Nelle carte leggo in lui prudenza, non freddezza.',
      'Le rune dicono: non prima che tu abbia chiarito ciò che cerchi.',
      'Scrivigli domani mattina due righe semplici.',
    ];
    final prese = [
      for (final t in certe)
        if (LeCertezzeDelMaestro.inQuesteFrasi(t).isNotEmpty) t
    ];
    final ferme = [
      for (final t in lette)
        if (LeCertezzeDelMaestro.inQuesteFrasi(t).isNotEmpty) t
    ];
    print('ORDINE ET VOCE 1: certezze prese ${prese.length} su '
        '${certe.length}, letture fermate ${ferme.length} su ${lette.length}');
    expect(prese.length, certe.length,
        reason: 'passano: ${certe.where((t) => !prese.contains(t))}');
    expect(ferme, isEmpty);
  });

  test('ET.01: la posizione ridetta come fatto si toglie', () {
    expect(
        LeCertezzeDelMaestro.senzaIlFattoDopoLaPosizione(
            'I tuoi centri dicono di sì, avrai la promozione quest\'anno, se '
            'fai sentire la tua voce.'),
        'I tuoi centri dicono di sì, se fai sentire la tua voce.');
    expect(
        LeCertezzeDelMaestro.senzaIlFattoDopoLaPosizione(
            'Le carte rispondono di sì, gli piaci. Parlagli tu.'),
        'Le carte rispondono di sì. Parlagli tu.');
    const buona = 'Le rune dicono di sì, se entri col tuo lavoro in mano.';
    expect(LeCertezzeDelMaestro.senzaIlFattoDopoLaPosizione(buona), buona);
  });

  test(
      'ET.01: dal quarto giro, le frasi certe che restano si tolgono e la '
      'posizione non lascia frasi spezzate', () {
    // Le risposte vere del quarto giro, con le frasi che il giudice alla
    // cieca ha citato come certezze.
    const tradisce = 'Le rune dicono di no. È la tua percezione che vacilla, '
        'non la sua lealtà.\nLa runa Othala indica la dimora, il legame '
        'profondo. Il suo sentiero è ancora unito al tuo.\n✦ Stasera '
        'preparate la cena insieme.';
    final senza = LeCertezzeDelMaestro.senzaLeFrasiCerte(tradisce);
    expect(senza, isNot(contains('la sua lealtà')));
    expect(senza, isNot(contains('Il suo sentiero è ancora unito')));
    expect(senza, startsWith('Le rune dicono di no.'));
    expect(senza, contains('✦ Stasera preparate la cena insieme.'));
    // La prima frase e il consiglio non si toccano mai.
    const soloDue = 'Il segno che cade dice di sì. I suoi occhi rivelano una '
        'forte attrazione.';
    expect(LeCertezzeDelMaestro.senzaLeFrasiCerte(soloDue), soloDue,
        reason: 'togliendo restava la sola prima frase');
    // La frase spezzata del quarto giro: "di sì, qualità che risuonano".
    expect(
        LeCertezzeDelMaestro.senzaIlFattoDopoLaPosizione(
            'I tuoi centri rispondono di sì, il tuo capo apprezza la tua '
            'dedizione e la tua cura, qualità che risuonano con te.'),
        'I tuoi centri rispondono di sì.');
    // Una frase intera dopo il sì prende i due punti.
    expect(
        LeCertezzeDelMaestro.senzaIlFattoDopoLaPosizione(
            'Le carte rispondono di no, questa settimana le stelle non '
            'favoriscono il gioco.'),
        'Le carte rispondono di no: questa settimana le stelle non '
        'favoriscono il gioco.');
    expect(
        LItalianoDelMaestro.ripara('Porta le mani sulla pancia, una sopra '
            'l\'altra e senti il calore.'),
        'Porta le mani sulla pancia, una sopra l\'altra. Senti il calore.');
    expect(
        LItalianoDelMaestro.ripara('È un cammino che parte dalla radice, il '
            'primo centro e dalla fiducia.'),
        'È un cammino che parte dalla radice (il primo centro) e dalla '
        'fiducia.');
    expect(LItalianoDelMaestro.ripara('Inspira amore e espira il timore.'),
        'Inspira amore ed espira il timore.');
  });

  test('ET.01: gli errori ricorrenti del secondo giro si riparano', () {
    const coppie = {
      'Cerca intensità e quando questa manca, il desiderio si ritira.':
          'Cerca intensità e, quando questa manca, il desiderio si ritira.',
      'Le carte dicono non prima di quando avrai chiarito ciò che cerchi.':
          'Le carte dicono: non prima del momento in cui avrai chiarito ciò '
              'che cerchi.',
      'Le rune dicono non ancora, la soglia è chiusa.':
          'Le rune dicono: non ancora, la soglia è chiusa.',
      'I tuoi centri dicono sì, se ti apri.':
          'I tuoi centri dicono di sì, se ti apri.',
      'La tua madre ha un\'immagine di te.': 'Tua madre ha un\'immagine di te.',
      'Parlane alla tua sorella.': 'Parlane a tua sorella.',
      'Lascialo sul suo tavolo lunedì, la Luna crescente ti aiuta.':
          'Lascialo sul suo tavolo lunedì: la Luna crescente ti aiuta.',
    };
    for (final e in coppie.entries) {
      expect(LItalianoDelMaestro.ripara(e.key), e.value, reason: e.key);
    }
    const giusta = 'Scrivigli tu, e fallo stasera con due righe.';
    expect(LItalianoDelMaestro.ripara(giusta), giusta);
  });

  test('ET.01: la prima frase stretta, sulle frasi vere del secondo giro', () {
    const ferme = {
      'Lui mi ama davvero?':
          'I tuoi centri dicono che l\'amore è un sentire profondo che si '
              'manifesta attraverso il movimento.',
      'Mi prenderanno al colloquio di giovedì?':
          'I tuoi centri dicono che la risposta non è in un sì o in un no '
              'definitivo, ma nella tua capacità di esprimerti.',
      'Il mio ex tornerà da me?':
          'Il tuo cielo dice che è possibile un ritorno, ma a patto che tu '
              'lasci spazio al dialogo.',
      'Devo scrivergli io o aspettare che si faccia vivo lui?':
          'I tuoi centri dicono che la direzione la scegli tu.',
      'Posso fidarmi di nuovo dopo un tradimento?':
          'I tuoi centri dicono che la fiducia è un ponte che si ricostruisce '
              'con cura.',
      'Perché i soldi non mi bastano mai?':
          'Le rune dicono che la percezione di mancanza è un sigillo.',
    };
    for (final e in ferme.entries) {
      expect(LaPosizioneDellaLettura.rispetta(Maestro.aura, e.key, e.value),
          isFalse,
          reason: e.value);
    }
    const passano = {
      'Lui mi ama davvero?': 'Nelle carte leggo di sì, ma è un sentimento '
          'timido.',
      'Il mio ex tornerà da me?': 'Le rune dicono: non ancora, e non per '
          'volontà tua.',
      'Devo scrivergli io o aspettare che si faccia vivo lui?':
          'Le rune dicono: scrivigli tu.',
      'Quando cambierà la mia fortuna?':
          'Il tuo cielo dice: non prima che tu abbia chiuso il debito vecchio.',
      'Perché i soldi non mi bastano mai?':
          'Perché la tua mano si apre prima che il raccolto sia maturo.',
    };
    for (final e in passano.entries) {
      expect(LaPosizioneDellaLettura.rispetta(Maestro.caligo, e.key, e.value),
          isTrue,
          reason: e.value);
    }
  });

  test(
      'ET.01: il controller chiede di nuovo la risposta con una certezza, '
      'nominandola, e consegna quella che non ne ha', () async {
    SharedPreferences.setMockInitialValues({});
    final ai = _ColCopione([
      'Le rune dicono di sì, se ti presenti puntuale. Il tuo lavoro sarà '
          'premiato.\n✦ Giovedì arriva dieci minuti prima.',
      'Le rune dicono di sì, se ti presenti puntuale. Tiwaz parla di una '
          'prova che si vince con la costanza.\n✦ Giovedì arriva dieci '
          'minuti prima.',
    ]);
    final c = MaestroChatController(
      maestro: Maestro.caligo,
      ai: ai,
      memory: InMemoryMaestroMemoryRepository(),
      natal: () => NatalContext.none,
      demo: true,
      attesaMinima: Duration.zero,
    );
    await c.init();
    await c.send('Mi prenderanno al colloquio di giovedì?');
    print('ORDINE ET VOCE 1: chiamate ${ai.volte}, correzione '
        '«${ai.correzioni.last}»');
    expect(ai.volte, 2,
        reason: 'la risposta con una certezza non si e\' chiesta di nuovo');
    expect(ai.correzioni.last, contains('sarà premiato'));
    expect(c.messages.last.text, isNot(contains('sarà premiato')));
    expect(c.rigenerazioniPerCertezza, 1);
  });
}

/// Un modello finto che risponde col suo copione e ricorda le correzioni.
class _ColCopione implements MaestroAiProvider {
  _ColCopione(this.copione);
  final List<String> copione;
  int volte = 0;
  final List<String?> correzioni = [];

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
    correzioni.add(LaRichiestaDelTurno.corrente.daCorreggere);
    return copione[(volte++).clamp(0, copione.length - 1)];
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
  Future<Responso> presagioDelleRune({
    required EsitoGettata esito,
    required String domanda,
    required UserProfile profile,
    NatalContext natal = NatalContext.none,
  }) async =>
      throw const MaestroAiUnavailable();

  @override
  Future<String> synthesize({
    required String theme,
    required List<MaestroLens> lenses,
    NatalContext? natal,
    UserProfile? profile,
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
