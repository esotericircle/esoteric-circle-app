// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/la_posizione_della_lettura.dart';
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
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';

/// **LA POSIZIONE E' UNA LETTURA, E SI PRENDE SEMPRE.** Ordine ET voce 01, 28
/// settembre 2026.
///
/// Nel banco delle trenta domande, sul commit di partenza, alle domande su
/// cio' che nessuno puo' sapere ("Lui mi ama davvero?", "Il mio ex tornera'
/// da me?", "Mi prenderanno al colloquio?") i tre Maestri giravano intorno:
/// Calìgo con le massime "Non X, ma Y", Medora con "Per comprendere...
/// rivolgiti a lui", Aura aprendo con "Aura è qui.". L'istruzione chiedeva il
/// si' o il no e insieme vietava di dare per certo cio' che nessuno sa, senza
/// dire la forma permessa: la lettura della propria arte. E diceva "se chiede
/// come andra', dice come andra'", cioe' una previsione.
///
/// Qui: ogni Maestro, in chat e nel LIVE, riceve la regola della posizione
/// detta come lettura; l'app riconosce che cosa chiede la domanda
/// (`LaPosizioneDellaLettura`), e il controller chiede di nuovo, una volta,
/// la risposta la cui prima frase gira intorno.
void main() {
  final profilo = UserProfile(displayName: 'Mauro');
  const memoria = MaestroMemory.empty;

  const pretese = <String, String>{
    'LA TUA POSIZIONE È UNA LETTURA: LA PRENDI SEMPRE':
        'la regola della posizione detta come lettura',
    'Non dirla mai come un fatto certo': 'il divieto del fatto certo',
    'una frase costruita come "Non X, ma Y" non è una posizione':
        'il divieto della massima al posto della posizione',
    'La tua prima frase non è mai una presentazione né un saluto':
        'il divieto della presentazione in apertura',
    'prima dici la tua lettura, poi, se serve, che la sua volontà è sua':
        'l\'ordine fra la lettura e la volonta\' dell\'altra persona',
  };

  test(
      'ET.01: i tre Maestri, in chat e nel LIVE, ricevono la regola della '
      'posizione detta come lettura', () {
    cardinaleMinimo(Maestro.values.length, 3,
        cosa: 'Maestri del cerchio',
        perche: 'Se l\'elenco si svuotasse, la prova direbbe di si\' a '
            'nessuno.');
    final mancanti = <String>[];
    var guardate = 0;
    for (final m in Maestro.values) {
      for (final live in [false, true]) {
        final istruzione = MaestroPersona.systemInstruction(
            maestro: m,
            profile: profilo,
            memory: memoria,
            nelLive: live,
            domandaDiAdesso: 'Lui mi ama davvero?');
        guardate++;
        for (final p in pretese.entries) {
          if (!istruzione.contains(p.key)) {
            mancanti.add('${m.id}${live ? ' nel LIVE' : ''}: ${p.value}');
          }
        }
        if (!istruzione
            .contains('comincia con "${LaPosizioneDellaLettura.inizio(m)}"')) {
          mancanti.add('${m.id}${live ? ' nel LIVE' : ''}: manca la forma '
              'della prima frase per questa domanda');
        }
        if (istruzione.contains('se chiede come andrà, dice come andrà')) {
          mancanti.add('${m.id}${live ? ' nel LIVE' : ''}: chiede ancora di '
              'dire come andra\', cioe\' una previsione');
        }
      }
    }
    print('ORDINE ET VOCE 1: istruzioni guardate $guardate, regole mancanti '
        '${mancanti.length}');
    expect(mancanti, isEmpty, reason: mancanti.join('; '));
  });

  test('ET.01: che cosa chiedono le domande del banco', () {
    const attesi = {
      'Lui mi ama davvero?': TipoDellaDomanda.siONo,
      'Il mio ex tornerà da me?': TipoDellaDomanda.siONo,
      'Devo scrivergli io o aspettare che si faccia vivo lui?':
          TipoDellaDomanda.scelta,
      'Perché non ho più desiderio con la persona che ho accanto?':
          TipoDellaDomanda.aperta,
      'Quando incontrerò la persona giusta?': TipoDellaDomanda.quando,
      'Sono innamorata di due persone: chi devo scegliere?':
          TipoDellaDomanda.aperta,
      'Mi sento sola anche in coppia: che cosa mi manca?':
          TipoDellaDomanda.aperta,
      'Riuscirò ad avere un figlio?': TipoDellaDomanda.siONo,
      'Gli piaccio? Mi guarda sempre ma non mi dice niente.':
          TipoDellaDomanda.siONo,
      'Sono felice nella mia relazione o mi sto accontentando?':
          TipoDellaDomanda.scelta,
      'Quando cambierà la mia fortuna?': TipoDellaDomanda.quando,
      'Qual è il lavoro fatto davvero per me?': TipoDellaDomanda.aperta,
      // Dalla suite, alla prima stesura della regola stretta: la frase che
      // chiede e' quella dell'ultimo punto interrogativo, proposizione per
      // proposizione; una domanda su un fatto non chiede una lettura.
      'Nella mia stesa sono uscite tre carte. Come si legge questa '
          'sequenza?': TipoDellaDomanda.aperta,
      'Vorrei cambiare lavoro, cosa faccio?': TipoDellaDomanda.aperta,
      'Ricordi il nome del mio cane?': TipoDellaDomanda.aperta,
      'Mia moglie mi ha lasciato. Cosa posso fare per farla tornare?':
          TipoDellaDomanda.aperta,
    };
    for (final e in attesi.entries) {
      expect(LaPosizioneDellaLettura.tipo(e.key), e.value, reason: e.key);
    }
  });

  /// **LE DOMANDE DETTE A VOCE, COME LE HA SCRITTE LA TRASCRIZIONE.** Ordine
  /// ET, 28 settembre 2026, sul Realme: nel LIVE tredici domande su
  /// diciassette sono arrivate senza punto interrogativo, e senza "?" erano
  /// tutte aperte: la regola del sì o del no non arrivava al modello e la
  /// rete della prima frase taceva. Qui le trascrizioni vere del telefono.
  /// Vista rossa sul codice di prima: "Lui mi ama davvero" tornava aperta.
  /// La prima stesura della cura valeva anche nella chat scritta, e la suite
  /// l'ha presa: "Lettura generale energia oggi" diventava una domanda del
  /// sì o del no e costava una chiamata in piu'. Adesso vale nel solo LIVE.
  test('ET.01: le domande dette a voce, senza punto interrogativo', () {
    const attesi = {
      'Lui mi ama davvero': TipoDellaDomanda.siONo,
      'Ma mia, ma ancora, dopo tutto quello che è successo.':
          TipoDellaDomanda.siONo,
      'Il mio ex tornerà': TipoDellaDomanda.siONo,
      'Mi prenderanno al colloquio di giovedì.': TipoDellaDomanda.siONo,
      'Il colloquio di giovedì andrà bene.': TipoDellaDomanda.siONo,
      'vero scrivergli io o aspettare che si faccia vivo lui.':
          TipoDellaDomanda.scelta,
      'Trovo l\'amore quest\'anno': TipoDellaDomanda.siONo,
      // Quelle che restano aperte: il perche', il come, la richiesta, il
      // saluto e il grazie.
      'perché i soldi non mi bastano mai.': TipoDellaDomanda.aperta,
      'Parlami del mio amore di adesso': TipoDellaDomanda.aperta,
      'Grazie Medora': TipoDellaDomanda.aperta,
      'Ciao Caligo, come stai': TipoDellaDomanda.aperta,
    };
    for (final e in attesi.entries) {
      final detta = LaPosizioneDellaLettura.comeDomandaDetta(e.key);
      expect(LaPosizioneDellaLettura.tipo(detta), e.value,
          reason: '${e.key} -> $detta');
    }
    expect(
        LaPosizioneDellaLettura.comeDomandaDetta('Mi prenderanno al '
            'colloquio di giovedì.'),
        'Mi prenderanno al colloquio di giovedì?');
    // Nella chat scritta la richiesta senza "?" resta una richiesta.
    expect(LaPosizioneDellaLettura.tipo('Lettura generale energia oggi'),
        TipoDellaDomanda.aperta);
  });

  test(
      'ET.01: nel LIVE la domanda detta senza "?" chiede la posizione, e la '
      'prima frase vera del telefono che non la prende si chiede di nuovo',
      () async {
    SharedPreferences.setMockInitialValues({});
    // La prima frase vera di Caligo sul Realme, turno 7: non prende
    // posizione e non e' una massima, quindi la ferma soltanto la regola del
    // sì o del no, cioe' soltanto se la domanda si legge come domanda.
    final ai = _ColCopione([
      'La runa Hagalaz indica un cambiamento repentino, un\'interruzione '
          'necessaria.\n✦ Prepara una risposta chiara sul tuo passato '
          'professionale.',
      'Le rune dicono di sì, se arrivi con la tua storia pronta.\n✦ '
          'Stasera scrivi i tre lavori che ti hanno fatto crescere.',
    ]);
    final c = MaestroChatController(
      maestro: Maestro.caligo,
      ai: ai,
      memory: InMemoryMaestroMemoryRepository(),
      natal: () => NatalContext.none,
      demo: true,
      attesaMinima: Duration.zero,
    )..nelLive = true;
    await c.init();
    await c.send('Mi prenderanno al colloquio di giovedì.');
    print('ORDINE ET VOCE 1, LIVE: chiamate ${ai.volte}, domanda salvata '
        '«${c.messages.where((m) => m.role == ChatRole.user).last.text}»');
    expect(ai.volte, 2,
        reason: 'nel LIVE la prima frase senza posizione non si e\' chiesta '
            'di nuovo: la domanda detta senza "?" era aperta');
    expect(c.rigenerazioniPerPosizione, 1);
    expect(c.messages.where((m) => m.role == ChatRole.user).last.text,
        'Mi prenderanno al colloquio di giovedì?');
  });

  test(
      'ET.01: le prime frasi vere del banco che giravano intorno non '
      'passano, la lettura che prende posizione si', () {
    const girano = {
      'Lui mi ama davvero?':
          'Non chiedere a me dei sentimenti altrui, io leggo il segno, non il '
              'cuore.',
      'Il mio ex tornerà da me?':
          'Nessun gesto, rito, lettera o momento del cielo fa tornare '
              'qualcuno: la sua scelta è sua.',
      'Troverò l\'amore quest\'anno?':
          'Il futuro è un velo che non scopro in un tempo definito.',
      'Il mio capo mi apprezza?':
          'Il tuo capo riconosce il tuo valore professionale.',
      'Mi prenderanno al colloquio di giovedì?':
          'Il colloquio è una soglia, non un sigillo.',
    };
    for (final e in girano.entries) {
      expect(LaPosizioneDellaLettura.rispetta(Maestro.caligo, e.key, e.value),
          isFalse,
          reason: e.value);
    }
    expect(
        LaPosizioneDellaLettura.rispetta(
            Maestro.caligo,
            'Mi prenderanno al colloquio di giovedì?',
            'Le rune dicono di sì, se entri col tuo lavoro in mano.'),
        isTrue);
    expect(
        LaPosizioneDellaLettura.rispetta(Maestro.medora, 'Lui mi ama davvero?',
            'Le carte e il tuo cielo dicono di sì, ma è un sentimento timido.'),
        isTrue);
  });

  test(
      'ET.01: l\'apertura gira con le risposte gia\' date, e la massima '
      'dietro la formula non passa', () {
    // Al secondo giro del banco le trenta risposte di ciascun Maestro
    // cominciavano tutte con le stesse parole.
    for (final m in Maestro.values) {
      final dette = <String>{};
      for (var giro = 0; giro < 8; giro++) {
        final blocco = LaPosizioneDellaLettura.perIlTurno(
            m, 'Lui mi ama davvero?',
            giro: giro);
        final apertura = LaPosizioneDellaLettura.inizio(m, giro: giro);
        expect(blocco, contains('comincia con "$apertura"'));
        dette.add(apertura);
        expect(
            LaPosizioneDellaLettura.rispetta(m, 'Lui mi ama davvero?',
                '$apertura di sì, ma è un sentimento timido.'),
            isTrue,
            reason:
                'l\'apertura "$apertura" non e\' riconosciuta come lettura');
      }
      print('ORDINE ET VOCE 1: ${m.id}, aperture diverse in otto turni '
          '${dette.length}');
      expect(dette.length, greaterThanOrEqualTo(4),
          reason: '${m.id}: in otto turni la prima frase comincia sempre con '
              'le stesse parole');
    }
    const massime = {
      'Perché attiro sempre persone che mi fanno soffrire?':
          'Le rune dicono che la sorgente della sofferenza non è negli altri, '
              'ma nella soglia che non hai ancora varcato.',
      'Sono innamorata di due persone: chi devo scegliere?':
          'I tuoi centri dicono che la scelta non è solo tra due persone, ma '
              'tra due risonanze energetiche che senti dentro di te.',
    };
    for (final e in massime.entries) {
      expect(LaPosizioneDellaLettura.rispetta(Maestro.caligo, e.key, e.value),
          isFalse,
          reason: e.value);
    }
  });

  test(
      'ET.01: il controller chiede di nuovo la risposta che gira intorno, '
      'nominando la sua prima frase', () async {
    SharedPreferences.setMockInitialValues({});
    final ai = _ColCopione([
      'Non scegliere, attendi.\n✦ Stasera accendi una candela.',
      'Le rune dicono: scrivigli tu, Raidho parla di un cammino.\n✦ Domani '
          'mattina mandagli due righe.',
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
    await c.send('Devo scrivergli io o aspettare che si faccia vivo lui?');
    print('ORDINE ET VOCE 1: chiamate ${ai.volte}, correzione '
        '«${ai.correzioni.last}»');
    expect(ai.volte, 2,
        reason: 'la risposta che gira intorno non si e\' chiesta di nuovo');
    expect(ai.correzioni.last, contains('Non scegliere, attendi.'));
    expect(c.messages.last.text, startsWith('Le rune dicono'));
    expect(c.rigenerazioniPerPosizione, 1);
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
