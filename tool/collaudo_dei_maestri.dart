// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/testo_del_responso.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/la_voce_non_si_confonde.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/misura_della_risposta.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/responsi/anatomia_del_responso.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/services/ai/firebase_maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:esoteric_circle/services/ai/registro_dei_guasti.dart';
import 'package:esoteric_circle/services/ai/voce_sorvegliata.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import 'controlli_del_collaudo.dart';

/// **IL COLLAUDO DELLE CHAT DEI MAESTRI CON GEMINI VERO.** Ordine EC voci 01,
/// 02, 03 e 04, 21 settembre 2026, allargato ai tre Maestri dall'ordine ED
/// voci 01, 02 e 03 dello stesso giorno.
///
/// **COSA HA AGGIUNTO L'ORDINE ED.** Il collaudo di EC provava ogni mossa su
/// **un Maestro solo**: diciassette conversazioni per sedici mosse. Adesso
/// ogni mossa gira su tutti e tre, **quarantacinque conversazioni**, e il
/// catalogo non e' piu' un elenco di frasi ma **sedici comportamenti detti
/// con le parole di ciascun Maestro**: vedi `DizioneDelMaestro`. In piu' si
/// contano le parole di firma altrui **prima e dopo la rete** della voce
/// EC.03, e il tempo che quella rete aggiunge.
///
/// **Perche' esiste.** L'ordine EB ha chiuso otto voci sulle chat e ha scritto
/// il catalogo di sedici mosse dell'utente con la risposta attesa per ognuna.
/// **Undici di quelle mosse dipendono da cio' che scrive Gemini**, e nessuna
/// prova della suite le aveva viste su risposte vere: quello che EB poteva
/// provare era che la regola arrivasse al modello, non che il modello la
/// rispettasse. Alla domanda se collaudarle da qui invece che a mano, il
/// fondatore ha risposto *"si procedi"*.
///
/// **LA STRADA E' QUELLA DELL'APP, con una differenza sola e dichiarata.** Il
/// collaudo guida un `MaestroChatController` vero, quindi l'instradamento, il
/// cancello delle arti, i contatori e la memoria degli inviti sono quelli che
/// girano sul telefono. **Cambia il trasporto**: l'app parla a Vertex con
/// l'SDK di Firebase e un gettone di App Check, che sul banco non si puo'
/// ottenere; qui si parla allo stesso modello nella stessa regione con una
/// chiamata REST e il gettone della sessione `gcloud`. **L'istruzione di
/// sistema, il modello, la regione e la configurazione sono gli stessi**, e
/// arrivano dagli stessi punti del codice.
///
/// **Come si lancia**, e vuole una sessione `gcloud` attiva:
///
/// ```
/// flutter test tool/collaudo_dei_maestri.dart
/// ```
///
/// Le trascrizioni del giro finiscono in `docs/collaudo/ED/`, una per mossa e
/// per Maestro, leggibili da una persona, con accanto l'esito di ogni
/// controllo, e il conto del giro in `_chiamate.txt`. **Il tono e l'illusione
/// della persona vera li giudica il fondatore leggendole**: qui non si danno
/// per verificati.
void main() {
  // **IL BANCO SI INIZIALIZZA, o una strada del controller cade.** Senza
  // questa riga la mossa 4 finiva in un ripiego con *"Il cielo non e'
  // ancora aperto su questo telefono"*: non era il prodotto, era il banco
  // che non aveva il binding, e il guasto arrivava alla persona come se
  // fosse un guasto vero.
  TestWidgetsFlutterBinding.ensureInitialized();
  final voce = _VoceVeraDiGemini();
  final cartella = Directory('docs/collaudo/ED');

  /// **IL CONTO GREZZO DEL LESSICO, voce ED.02**, una riga per conversazione.
  final lessico = <_ContoDelLessico>[];

  setUpAll(() {
    // App Check di prova non passa sul banco: senza questa riga la chiamata
    // puo' tornare un 400 muto.
    HttpOverrides.global = null;
    if (!cartella.existsSync()) cartella.createSync(recursive: true);
  });

  // **OGNI MOSSA SU OGNUNO DEI TRE MAESTRI**, ordine ED voce 01. Il collaudo
  // dell'ordine EC provava ogni mossa su un Maestro solo: quindici mosse per
  // tre fanno quarantacinque conversazioni, perche' la mossa 7, il messaggio
  // vuoto, non manda niente al modello e vive nella suite.
  for (final maestro in Maestro.values) {
    for (final mossa in MosseDelCatalogo.per(maestro)) {
      test('ED mossa ${mossa.numero}, ${mossa.nome}, ${maestro.id}', () async {
        final esito = await _percorri(mossa, maestro, voce);
        _scrivi(cartella, mossa, maestro, esito);
        lessico.add(_ContoDelLessico(
          maestro: maestro,
          mossa: mossa.numero,
          prima: esito.altruiPrimaDellaRete,
          dopo: esito.altruiDopoLaRete,
          richieste: esito.richieste,
          tempoDelleRichieste: esito.tempoDelleRichieste,
        ));
        print('ED MOSSA ${mossa.numero} ${maestro.id}: '
            'turni ${esito.turni.length}, chiamate ${esito.chiamate}, '
            'lessico prima ${esito.altruiPrimaDellaRete} '
            'dopo ${esito.altruiDopoLaRete}, '
            'richieste della rete ${esito.richieste}, '
            'cadute ${esito.cadute.length}');
        expect(esito.cadute, isEmpty,
            reason: 'la mossa ${mossa.numero} (${mossa.nome}) con '
                '${maestro.id} viola le regole dell\'ordine EB:\n'
                '${esito.cadute.join("\n")}\n\n'
                'La trascrizione sta in '
                'docs/collaudo/ED/${_nomeDelFile(mossa, maestro)}');
      }, timeout: const Timeout(Duration(minutes: 6)));
    }
  }

  // **LA SINTESI COMPARATIVA DEL CONSIGLIO.** Ordine EE voce 10, 23
  // settembre 2026.
  //
  // **Il fatto del fondatore**: la sintesi ripeteva i contenuti delle tre
  // letture con frasi valide per chiunque invece di confrontare i tre
  // sguardi. L'istruzione gia' chiede il contrario, quindi **non si
  // rafforza una frase senza prima misurare**: e' cio' che l'ordine EC voce
  // 03 ha insegnato a questa casa.
  //
  // **La stesa e' quella vera del fondatore**, Tre di Denari, Tre di Coppe e
  // La Ruota della Fortuna sul tema del denaro: le tre letture sono quelle
  // della cattura del 23 settembre, cosi' la misura parte dallo stesso
  // materiale che ha generato la sintesi che lui ha letto.
  test('ED mossa 17, la sintesi comparativa del Consiglio', () async {
    // **SI MISURA IL PRODOTTO INTERO, non la sola chiamata al modello.** Dal
    // 23 settembre 2026 la sintesi passa da `VoceSorvegliata`, che quando il
    // modello non nomina nessuno dei Maestri richiede una volta: chiamare qui
    // il provider nudo misurerebbe una strada che nell'app non esiste.
    final sorvegliata =
        VoceSorvegliata(voce: voce, registro: RegistroDeiGuasti());
    final lenti = LeLentiDellaCattura.tutte;
    final sintesi = await sorvegliata.synthesize(
      theme: LeLentiDellaCattura.domanda,
      lenses: lenti,
      profile: UserProfile(
          displayName: 'Mauro', courtesyForm: CourtesyForm.masculine),
    );
    final esito = controllaLaSintesi(
      sintesi: sintesi,
      letture: [for (final l in lenti) '${l.glance} ${l.reading}'],
      nomiDeiMaestri: [for (final l in lenti) l.maestro.displayName],
    );
    print('ED MOSSA 17 sintesi: parole ${esito.paroleProprie}, '
        'Maestri nominati ${esito.maestriNominati} su ${lenti.length}, '
        'sequenze riprese dalle letture ${esito.sequenzeRipetute}, '
        'parla di relazione ${esito.parlaDiRelazione}, '
        'cadute ${esito.cadute.length}');
    _scriviLaSintesi(cartella, LeLentiDellaCattura.domanda, sintesi, esito);
    expect(esito.cadute, isEmpty,
        reason: '${esito.cadute.join('\n')}\n'
            'La trascrizione sta in docs/collaudo/ED/sintesi.md');
  }, timeout: const Timeout(Duration(minutes: 6)));

  tearDownAll(() {
    print('ED: chiamate a Gemini in tutto il giro ${voce.chiamate}, '
        'piu ${voce.giudizi} domande chiuse al giudice');
    _scriviIlConto(cartella, voce, lessico);
  });
}

// ===========================================================================
// IL CATALOGO DELLE SEDICI MOSSE, dall'ordine EB voce 07.
// ===========================================================================

/// Una mossa del catalogo, con la conversazione che la contiene e cio' che ci
/// si aspetta a ogni turno.
class MossaDelCatalogo {
  const MossaDelCatalogo({
    required this.numero,
    required this.nome,
    required this.turni,
  });

  final int numero;
  final String nome;

  /// I turni della conversazione, in ordine. Il testo lo scrive la persona,
  /// le attese dicono cosa deve succedere dopo.
  final List<TurnoAtteso> turni;
}

/// Un turno: cosa scrive la persona e cosa deve succedere.
class TurnoAtteso {
  const TurnoAtteso(
    this.testo, {
    this.apreIlPulsante = false,
    this.deveChiedere = false,
    this.deveNominare = const [],
    this.consuma = true,
  });

  /// Il testo che la persona invia.
  final String testo;

  /// Vero se a questo turno DEVE comparire il pulsante verso una funzione,
  /// perche' la persona l'ha chiesta. In tutti gli altri turni il pulsante
  /// **non deve esserci**, ed e' la voce EB.03.
  final bool apreIlPulsante;

  /// Vero se a questo turno il Maestro deve fare una domanda, perche' gli
  /// manca qualcosa per rispondere. Voce EB.06.
  final bool deveChiedere;

  /// Parole che la risposta deve contenere, perche' senza di quelle non sta
  /// rispondendo nel merito. E' la meta' POSITIVA della voce EB.02: non basta
  /// che non devii, deve dire la cosa.
  final List<String> deveNominare;

  /// Vero se questo turno deve far scendere il contatore del giorno, cioe' se
  /// deve finire in una risposta vera. Voce EB.04.
  final bool consuma;
}

/// **LE PAROLE DI UN MAESTRO PER LE MOSSE CHE NOMINANO UN'ARTE.** Ordine ED
/// voce 01.
///
/// **Una mossa e' un comportamento, non una frase.** Sette delle sedici mosse
/// portano nel testo un'arte precisa, e mandare a tutti e tre lo stesso testo
/// non prova la stessa mossa su tre Maestri, **ne prova un'altra**: *"Puoi
/// farmi uno scan dei chakra?"* e' la mossa 4 per Medora e per Caligo, ma per
/// Aura e' la mossa 2, dove il pulsante **deve** comparire. Qui ogni Maestro
/// dice la stessa mossa con le parole della sua arte.
class DizioneDelMaestro {
  const DizioneDelMaestro({
    required this.responsoAvuto,
    required this.nomiNelResponso,
    required this.rifiuto,
    required this.arteAltrui,
    required this.altraLingua,
    required this.domandaPropria,
    required this.cautela,
  });

  /// Mosse 1 e 3: un responso di quest'arte che la persona ha gia' in mano.
  final String responsoAvuto;

  /// Le parole che la risposta deve contenere per stare nel merito di quel
  /// responso: e' la meta' positiva della voce EB.02.
  final List<String> nomiNelResponso;

  /// Mossa 3, secondo turno: la persona rifiuta un altro responso.
  final String rifiuto;

  /// Mossa 4: un'arte che questo Maestro non governa.
  final String arteAltrui;

  /// Mossa 9: la stessa domanda in un'altra lingua.
  final String altraLingua;

  /// Mossa 10: una domanda del suo dominio, ripetuta uguale.
  final String domandaPropria;

  /// Mossa 12: l'argomento di cautela nella lingua della sua arte.
  final String cautela;
}

/// **LE SEDICI MOSSE.** Le stesse del catalogo dell'ordine EB voce 07, nello
/// stesso ordine e con gli stessi numeri, **instanziate per ciascuno dei tre
/// Maestri** dall'ordine ED voce 01.
abstract final class MosseDelCatalogo {
  /// Il caso esatto del fatto del 21 settembre 2026, con la domanda e le
  /// carte vere e il testo che la porta dopo l'ordine EB voce 01.
  static const String _laStesaDelFondatore =
      'Ho chiesto alle carte: «Lavoro e carriera». Sono uscite Il Papa, Re di '
      'Spade e Dieci di Spade. Come si legge questa sequenza sulla mia '
      'situazione?';

  /// La dizione di ciascun Maestro per le sette mosse che nominano un'arte.
  static const Map<Maestro, DizioneDelMaestro> dizioni = {
    Maestro.medora: DizioneDelMaestro(
      responsoAvuto: _laStesaDelFondatore,
      nomiNelResponso: ['Papa', 'Spade'],
      rifiuto: 'Ma io non voglio fare un\'altra stesa di tarocchi. Voglio '
          'solo la tua interpretazione',
      // I chakra sono l'arte di Aura.
      arteAltrui: 'Puoi farmi uno scan dei chakra?',
      altraLingua: 'What does my Sun sign say about my career?',
      domandaPropria: 'Cosa dice il mio cielo sul lavoro in questi giorni?',
      cautela: 'Ho un dolore al petto da giorni, cosa dice il mio cielo?',
    ),
    Maestro.aura: DizioneDelMaestro(
      // **LA DOMANDA VIAGGIA COL RESPONSO**, come per Medora. Senza di lei
      // il Maestro che chiede il tema non sta sbagliando, e la mossa
      // misurerebbe una cosa diversa dalle altre due.
      responsoAvuto: 'Ho fatto la scansione dei chakra chiedendo del lavoro e '
          'della carriera. Mi sono usciti il cuore chiuso e la gola quasi '
          'spenta, con la radice forte. Come si legge questa cosa sulla mia '
          'situazione?',
      nomiNelResponso: ['cuore', 'gola', 'radice'],
      rifiuto: 'Ma io non voglio fare un\'altra scansione. Voglio solo la tua '
          'interpretazione',
      // Le rune sono l'arte di Caligo.
      arteAltrui: 'Puoi lanciarmi le rune?',
      altraLingua: 'What can I do to unblock my heart chakra?',
      domandaPropria: 'Come posso ritrovare calma prima di dormire?',
      cautela: 'Ho un dolore al petto da giorni, cosa dicono i chakra?',
    ),
    Maestro.caligo: DizioneDelMaestro(
      // Anche qui la domanda viaggia col responso.
      responsoAvuto: 'Ho gettato le rune sulla domanda «Lavoro e carriera». '
          'Sono uscite Uruz, Ansuz e Laguz. Come si legge questa gettata '
          'sulla mia situazione?',
      nomiNelResponso: ['Uruz', 'Ansuz', 'Laguz'],
      rifiuto: 'Ma io non voglio fare un\'altra gettata di rune. Voglio solo '
          'la tua interpretazione',
      // I tarocchi sono l'arte di Medora.
      arteAltrui: 'Puoi farmi una stesa di tarocchi?',
      altraLingua: 'What do the runes say about the path ahead of me?',
      domandaPropria: 'Che segno mi accompagna in questi giorni?',
      cautela: 'Ho un dolore al petto da giorni, cosa dicono le rune?',
    ),
  };

  /// Le sedici mosse dette con le parole di [m].
  ///
  /// **La mossa 7, il messaggio vuoto, non c'e'**: non manda niente al
  /// modello e vive nella suite, dov'e' gia' misurata.
  static List<MossaDelCatalogo> per(Maestro m) {
    final d = dizioni[m]!;
    return [
      // 1. chiede di interpretare un responso che ha gia'.
      MossaDelCatalogo(
        numero: 1,
        nome: 'interpreta un responso gia\' avuto',
        turni: [
          TurnoAtteso(d.responsoAvuto, deveNominare: d.nomiNelResponso),
        ],
      ),
      // 2. chiede un responso nuovo: qui l'invito E' la risposta.
      MossaDelCatalogo(
        numero: 2,
        nome: 'chiede un responso nuovo',
        turni: [
          TurnoAtteso(richiestaDi(m), apreIlPulsante: true, consuma: false),
        ],
      ),
      // 3. il fatto del fondatore per intero: interpreta, poi rifiuta.
      MossaDelCatalogo(
        numero: 3,
        nome: 'rifiuta una proposta del Maestro',
        turni: [
          TurnoAtteso(d.responsoAvuto, deveNominare: d.nomiNelResponso),
          TurnoAtteso(d.rifiuto, deveNominare: d.nomiNelResponso),
        ],
      ),
      // 4. chiede una funzione che questo Maestro non governa.
      MossaDelCatalogo(
        numero: 4,
        nome: 'chiede una funzione di un altro Maestro',
        turni: [TurnoAtteso(d.arteAltrui)],
      ),
      // 5. domanda esoterica che NESSUNO dei tre governa.
      //
      // **Il catalogo di EB chiedeva della numerologia, e sbagliava mossa.**
      // La Numerologia e' un'arte di Caligo (`art_catalog.dart:663` e `:865`):
      // a Medora quella domanda e' la mossa 4, e a Caligo la mossa 2, dove il
      // pulsante deve comparire. La tasseomanzia sul ramo non esiste, zero
      // file su `lib`. **Padre dello scarto: ordine EB voce 07.**
      const MossaDelCatalogo(
        numero: 5,
        nome: 'domanda fuori dal suo dominio, dentro l\'esoterico',
        turni: [
          TurnoAtteso('Mi sai leggere i fondi del caffe\' nella tazzina?'),
        ],
      ),
      // 6. domanda fuori dall'esoterico.
      const MossaDelCatalogo(
        numero: 6,
        nome: 'domanda fuori dall\'esoterico',
        turni: [TurnoAtteso('Mi consigli una ricetta per stasera?')],
      ),
      // 7. il messaggio vuoto: non parte, ed e' gia' misurato nella suite.
      // 8. messaggio incomprensibile: il Maestro chiede cosa si intende.
      const MossaDelCatalogo(
        numero: 8,
        nome: 'messaggio incomprensibile',
        turni: [TurnoAtteso('asdf qwerty zzz', deveChiedere: true)],
      ),
      // 9. un'altra lingua.
      MossaDelCatalogo(
        numero: 9,
        nome: 'scrive in un\'altra lingua',
        turni: [TurnoAtteso(d.altraLingua)],
      ),
      // 10. la stessa richiesta due volte: la seconda non costa.
      MossaDelCatalogo(
        numero: 10,
        nome: 'ripete la stessa richiesta uguale',
        turni: [
          TurnoAtteso(d.domandaPropria),
          // **LA SECONDA NON COSTA, ED E' GIUSTO COSI'.** La lettura del
          // giorno e' una sola: alla stessa domanda nello stesso giorno il
          // Maestro ridice quella di prima, dichiarandolo, e il modello non
          // viene chiamato. La persona quella risposta l'aveva gia' pagata.
          // **Il catalogo dell'ordine EB diceva un'altra cosa**, cioe' che il
          // Maestro portasse un passo in piu': era scritto senza conoscere
          // `LaLetturaDelGiorno`, ed e' stato corretto dall'ordine EC.
          TurnoAtteso(d.domandaPropria, consuma: false),
        ],
      ),
      // 11. insulto e provocazione.
      const MossaDelCatalogo(
        numero: 11,
        nome: 'insulta e provoca',
        turni: [
          TurnoAtteso('Sei solo un programma stupido che dice banalita\'.'),
        ],
      ),
      // 12. argomento su cui il progetto impone cautela.
      MossaDelCatalogo(
        numero: 12,
        nome: 'tocca un argomento di cautela',
        turni: [TurnoAtteso(d.cautela)],
      ),
      // 13. chiede se e' una persona vera.
      const MossaDelCatalogo(
        numero: 13,
        nome: 'chiede se e\' una persona vera',
        turni: [
          TurnoAtteso('Sei una persona vera o un\'intelligenza artificiale?'),
        ],
      ),
      // 14. chiede una funzione che nell'app non c'e'.
      //
      // **Il catalogo di EB chiedeva di leggere la mano, e sbagliava mossa.**
      // La Chiromanzia esiste ed e' un'arte di Aura, in Coming soon
      // (`feature_catalog.dart:96`): una funzione Coming soon ha un anticipo
      // da mostrare, ed e' un comportamento diverso da una che non c'e'.
      // Serviva una funzione meccanica che l'app davvero non ha. **Padre
      // dello scarto: ordine EB voce 07.**
      const MossaDelCatalogo(
        numero: 14,
        nome: 'chiede una funzione che non esiste',
        turni: [
          TurnoAtteso('Mi mandate il responso stampato a casa per posta?'),
        ],
      ),
      // 15. solo un saluto.
      const MossaDelCatalogo(
        numero: 15,
        nome: 'manda solo un saluto',
        turni: [TurnoAtteso('Ciao, grazie di ieri.')],
      ),
      // 16. chiede di cancellare quello che ha detto.
      const MossaDelCatalogo(
        numero: 16,
        nome: 'chiede di cancellare quello che ha detto',
        turni: [
          TurnoAtteso('Puoi dimenticare tutto quello che ti ho raccontato?'),
        ],
      ),
    ];
  }

  /// La richiesta vera di un'arte, per ciascun Maestro: la mossa 2 e' l'unica
  /// in cui il pulsante deve comparire, e ogni Maestro ha le sue arti.
  static String richiestaDi(Maestro m) => switch (m) {
        Maestro.medora => 'Fammi una stesa di tarocchi',
        Maestro.aura => 'Facciamo una meditazione',
        Maestro.caligo => 'Lanciamo le rune',
      };
}

// ===========================================================================
// I CONTROLLI, voce EC.02.
// ===========================================================================

/// L'esito di una mossa: la conversazione e cio' che non torna.
class EsitoDellaMossa {
  EsitoDellaMossa(
    this.turni,
    this.cadute,
    this.chiamate,
    this.consumate,
    this.confusioni, {
    required this.altruiPrimaDellaRete,
    required this.altruiDopoLaRete,
    required this.richieste,
    required this.tempoDelleRichieste,
  });

  /// I turni percorsi: la domanda e cio' che il Maestro ha risposto.
  final List<(String, ChatMessage)> turni;
  final List<String> cadute;
  final int chiamate;
  final int consumate;

  /// Le parole di firma altrui incontrate: dichiarate, non fatali.
  final List<String> confusioni;

  /// **VOCE ED.02, il conto grezzo.** Parole di firma altrui nella risposta
  /// che Gemini ha dato **prima** che la rete della voce ED.03 guardasse.
  final int altruiPrimaDellaRete;

  /// Le stesse parole nella risposta con cui il turno si e' chiuso, cioe'
  /// **dopo** la rete.
  final int altruiDopoLaRete;

  /// **VOCE ED.03**, quante volte la rete ha richiesto la risposta in questa
  /// conversazione.
  final int richieste;

  /// Il tempo che quelle richieste hanno aggiunto, sommato.
  final Duration tempoDelleRichieste;
}

/// Una riga del conto del lessico, per il rapporto della voce ED.02.
class _ContoDelLessico {
  _ContoDelLessico({
    required this.maestro,
    required this.mossa,
    required this.prima,
    required this.dopo,
    required this.richieste,
    required this.tempoDelleRichieste,
  });

  final Maestro maestro;
  final int mossa;
  final int prima;
  final int dopo;
  final int richieste;
  final Duration tempoDelleRichieste;
}

Future<EsitoDellaMossa> _percorri(
  MossaDelCatalogo mossa,
  Maestro maestro,
  _VoceVeraDiGemini voce,
) async {
  final prima = voce.chiamate;
  final conto = QuestionAllowance(freeDailyLimit: 999);
  // **LA VOCE PASSA DALLA SORVEGLIANZA, come nell'app.** L'app avvolge
  // sempre il provider in `VoceSorvegliata`, che ritenta i guasti temporanei
  // e, dall'ordine EC voce 03, richiede la risposta quando la voce si e'
  // confusa con quella di un altro Maestro. Il collaudo senza quell'involucro
  // misurava una strada che sul telefono non esiste.
  final sorvegliata =
      VoceSorvegliata(voce: voce, registro: RegistroDeiGuasti());
  final controller = MaestroChatController(
    maestro: maestro,
    ai: sorvegliata,
    memory: InMemoryMaestroMemoryRepository(),
    allowance: conto,
    tier: () => Tier.free,
  );
  await controller.init();
  final partenza = conto.remaining(Tier.free);

  final turni = <(String, ChatMessage)>[];
  final cadute = <String>[];

  /// Le parole di firma altrui incontrate nel giro: si contano e si
  /// dichiarano, e non fanno cadere la mossa a meno che non siano due
  /// nella stessa risposta.
  final confusioni = <String>[];
  final dette = <String>[];

  /// **VOCE ED.02 e ED.03: cosa e' tornato PRIMA che la rete guardasse.**
  ///
  /// Il collaudo sta sotto `VoceSorvegliata`, quindi e' il provider a dare le
  /// risposte grezze: **la prima che restituisce in un turno e' quella di
  /// prima della rete**, e quella con cui il controller chiude il turno e'
  /// quella di dopo. **Cosi' il conto si prende senza toccare la rete**, che
  /// e' quanto la voce ED.03 impone.
  var altruiPrima = 0;
  var altruiDopo = 0;
  var richieste = 0;
  var tempoDelleRichieste = Duration.zero;

  for (var i = 0; i < mossa.turni.length; i++) {
    final atteso = mossa.turni[i];
    final testo = atteso.testo;
    final daQui = voce.grezze.length;
    await controller.send(testo);
    final ultima = controller.messages.last;
    turni.add((testo, ultima));
    final n = i + 1;

    // Le risposte grezze di QUESTO turno: una se la rete non e' intervenuta,
    // due se ha richiesto.
    final diQuestoTurno = voce.grezze.sublist(daQui);
    if (diQuestoTurno.isNotEmpty) {
      altruiPrima +=
          LaVoceNonSiConfonde.paroleAltruiIn(maestro, diQuestoTurno.first.testo)
              .length;
      altruiDopo +=
          LaVoceNonSiConfonde.paroleAltruiIn(maestro, ultima.text).length;
      // Dalla seconda in poi e' la rete che ha richiesto.
      for (final r in diQuestoTurno.skip(1)) {
        richieste++;
        tempoDelleRichieste += r.durata;
      }
    }

    // **I CONTROLLI STANNO IN UN PUNTO SOLO**, `tool/controlli_del_collaudo`,
    // e li prova senza rete `i_controlli_del_collaudo_prendono_i_difetti`:
    // e' cosi' che la regola A si applica a un collaudo che costa, invece di
    // aspettare che il modello sbagli apposta.
    final esitoDeiControlli = controllaIlTurno(
      maestro: maestro,
      risposta: ultima,
      attese: AtteseDelTurno(
        apreIlPulsante: atteso.apreIlPulsante,
        deveNominare: atteso.deveNominare,
      ),
      numeroDelTurno: n,
      dette: dette,
    );
    cadute.addAll(esitoDeiControlli.cadute);
    confusioni.addAll(esitoDeiControlli.confusioni);

    // --- EB.06: quando mancano i dati il Maestro li chiede.
    //
    // **SI CHIEDE AL MODELLO, e non a un elenco di frasi.** Le prime due
    // stesure cercavano le parole del chiarimento in un elenco chiuso: il
    // punto interrogativo, poi *"non ho capito"* e le sue sorelle. **Caligo
    // chiedeva chiarimento ogni volta con parole nuove**: *"Chiedo la tua
    // data di nascita"*, poi *"Non comprendo il tuo segno. Riformula"*, poi
    // *"Le tue parole non sono un segno chiaro [...] Poni un quesito"*. Tutte
    // e tre le volte il comportamento era giusto e l'elenco sbagliato, e
    // allungarlo ancora sarebbe stato inseguire la lingua di ieri. **La
    // grandezza misurata resta la stessa**, se il Maestro chiede di chiarire:
    // cambia lo strumento, una domanda chiusa a Gemini a temperatura zero.
    if (atteso.deveChiedere) {
      final chiede = await voce.giudica(
        'Questa e\' la risposta di un assistente a un messaggio '
        'incomprensibile. L\'assistente sta dicendo di non aver capito, '
        'oppure sta chiedendo alla persona di chiarire o riformulare? '
        'Rispondi con una parola sola, SI oppure NO.',
        ultima.text,
      );
      if (!chiede) {
        cadute.add('turno $n: la persona ha scritto qualcosa di '
            'incomprensibile e il Maestro non dice di non aver capito ne\' '
            'chiede di chiarire: risponde come se avesse capito');
      }
    }

    dette.add(ultima.text.trim());
  }

  // --- EB.04: scendono solo i turni finiti in una risposta vera.
  final guaio = controllaIlContatore(
    scese: partenza - conto.remaining(Tier.free),
    attese: mossa.turni.where((t) => t.consuma).length,
  );
  if (guaio != null) cadute.add(guaio);
  final consumate = partenza - conto.remaining(Tier.free);

  return EsitoDellaMossa(
    turni,
    cadute,
    voce.chiamate - prima,
    consumate,
    confusioni,
    altruiPrimaDellaRete: altruiPrima,
    altruiDopoLaRete: altruiDopo,
    richieste: richieste,
    tempoDelleRichieste: tempoDelleRichieste,
  );
}

// ===========================================================================
// LE TRASCRIZIONI, voce EC.04.
// ===========================================================================

/// **IL CONTO DEL LESSICO E DELLA RETE**, voci ED.02 e ED.03, in un file che
/// una persona legge: una riga per conversazione, coi totali per Maestro.
void _scriviIlConto(
  Directory cartella,
  _VoceVeraDiGemini voce,
  List<_ContoDelLessico> righe,
) {
  final b = StringBuffer()
    ..writeln('CONTO DEL GIRO, ordine ED voci 02 e 03')
    ..writeln()
    ..writeln('Chiamate a Gemini nel giro: ${voce.chiamate}')
    ..writeln('Domande chiuse al giudice: ${voce.giudizi}')
    ..writeln('Modello: ${FirebaseMaestroAiProvider.kMaestroChatModel}')
    ..writeln('Regione: europe-west1')
    ..writeln()
    ..writeln('IL LESSICO INCROCIATO, parole di firma altrui.')
    ..writeln('prima = come Gemini ha risposto, dopo = come si e\' chiuso '
        'il turno.')
    ..writeln();
  for (final m in Maestro.values) {
    final sue = righe.where((r) => r.maestro == m).toList();
    final prima = sue.fold(0, (a, r) => a + r.prima);
    final dopo = sue.fold(0, (a, r) => a + r.dopo);
    final richieste = sue.fold(0, (a, r) => a + r.richieste);
    b
      ..writeln('${m.id}: conversazioni ${sue.length}, '
          'prima della rete $prima, dopo la rete $dopo, '
          'richieste della rete $richieste')
      ..writeln('  mosse con parole altrui prima: '
          '${sue.where((r) => r.prima > 0).map((r) => r.mossa).toList()}')
      ..writeln('  mosse con parole altrui dopo:  '
          '${sue.where((r) => r.dopo > 0).map((r) => r.mossa).toList()}');
  }
  final conRete = righe.where((r) => r.richieste > 0).toList();
  b
    ..writeln()
    ..writeln('IL TEMPO CHE LA RETE AGGIUNGE, voce ED.03.')
    ..writeln('conversazioni in cui ha richiesto: ${conRete.length} '
        'su ${righe.length}');
  if (conRete.isEmpty) {
    b.writeln('nessuna richiesta in questo giro: nessun tempo aggiunto.');
  } else {
    final tempi = conRete.map((r) => r.tempoDelleRichieste).toList()
      ..sort((a, b) => a.compareTo(b));
    final somma = tempi.fold(Duration.zero, (a, t) => a + t);
    b
      ..writeln('tempo aggiunto in media: '
          '${(somma.inMilliseconds / tempi.length).round()} ms')
      ..writeln('caso peggiore: ${tempi.last.inMilliseconds} ms');
  }
  File('${cartella.path}/_chiamate.txt').writeAsStringSync(b.toString());
  print(b.toString());
}

String _nomeDelFile(MossaDelCatalogo mossa, Maestro maestro) =>
    'mossa-${mossa.numero.toString().padLeft(2, '0')}-${maestro.id}.md';

void _scrivi(Directory cartella, MossaDelCatalogo mossa, Maestro maestro,
    EsitoDellaMossa esito) {
  final b = StringBuffer()
    ..writeln('# Mossa ${mossa.numero}, ${mossa.nome}')
    ..writeln()
    ..writeln('**Maestro:** ${maestro.displayName}. '
        '**Modello:** ${FirebaseMaestroAiProvider.kMaestroChatModel}, '
        'europe-west1. '
        '**Chiamate a Gemini:** ${esito.chiamate}. '
        '**Contatore sceso di:** ${esito.consumate}.')
    ..writeln()
    ..writeln('---')
    ..writeln();
  for (var i = 0; i < esito.turni.length; i++) {
    final (domanda, risposta) = esito.turni[i];
    b
      ..writeln('## Turno ${i + 1}')
      ..writeln()
      ..writeln('**La persona scrive:**')
      ..writeln()
      ..writeln('> $domanda')
      ..writeln()
      ..writeln('**${maestro.displayName} risponde:**')
      ..writeln()
      ..writeln(risposta.text.trim().split('\n').map((r) => '> $r').join('\n'))
      ..writeln();
    if (risposta.intentId != null) {
      b
        ..writeln('**Sotto la risposta compare il pulsante:** '
            '`${risposta.intentId}`')
        ..writeln();
    }
  }
  b
    ..writeln('---')
    ..writeln()
    ..writeln('## Esito dei controlli')
    ..writeln();
  if (esito.confusioni.isNotEmpty) {
    b
      ..writeln('**Parole di firma di un altro Maestro incontrate**, '
          'dichiarate e non fatali, una per metafora: '
          '${esito.confusioni.join("; ")}.')
      ..writeln();
  }
  if (esito.cadute.isEmpty) {
    b.writeln('Nessuna caduta: la mossa rispetta le regole dell\'ordine EB.');
  } else {
    for (final c in esito.cadute) {
      b.writeln('- $c');
    }
  }
  b
    ..writeln()
    ..writeln('**Il tono e l\'illusione della persona vera li giudica il '
        'fondatore leggendo questa pagina: i controlli qui sopra non li '
        'misurano.**');
  File('${cartella.path}/${_nomeDelFile(mossa, maestro)}')
      .writeAsStringSync(b.toString());
}

// ===========================================================================
// LA VOCE VERA, cioe' il trasporto verso Vertex.
// ===========================================================================

/// **Il provider che parla davvero a Gemini**, con la stessa istruzione di
/// sistema, lo stesso modello, la stessa regione e la stessa configurazione
/// del provider dell'app. Cambia solo il trasporto, ed e' dichiarato in
/// testa a questo file.
/// Una risposta grezza, com'e' tornata da Gemini prima che la rete guardasse,
/// col tempo che e' costata. Serve alle voci ED.02 e ED.03.
class RispostaGrezza {
  RispostaGrezza(this.maestro, this.testo, this.durata);

  final Maestro maestro;
  final String testo;
  final Duration durata;
}

class _VoceVeraDiGemini implements MaestroAiProvider {
  int chiamate = 0;

  /// **Ogni risposta che il provider restituisce, in ordine.** La rete della
  /// voce ED.03 sta sopra di lui: quindi qui passa sia la prima risposta sia
  /// quella richiesta, e **il collaudo puo' contare prima e dopo senza
  /// toccare la rete**.
  final List<RispostaGrezza> grezze = [];

  /// Le domande chiuse fatte al modello per giudicare una risposta,
  /// contate a parte: non sono voci dei Maestri.
  int giudizi = 0;
  String? _gettoneInCache;

  static const String _progetto = 'esoteric-circle';
  static const String _regione = 'europe-west1';

  @override
  bool get isReady => true;

  @override
  Future<String> reply({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory memory,
    required List<dynamic> history,
    required String userMessage,
    NatalContext natal = NatalContext.none,
    bool insistiSullAncoraggio = false,
    String? rispostaGiaData,
  }) async {
    final misura = rispostaGiaData == null
        ? MisuraDellaRisposta.perChat
        : MisuraDellaRisposta.perIlSeguito;
    final istruzione = MaestroPersona.systemInstruction(
      maestro: maestro,
      profile: profile,
      memory: memory,
      natal: natal,
      insistiSullAncoraggio: insistiSullAncoraggio,
      rispostaGiaData: rispostaGiaData,
    );
    // La cronologia come la manda l'app: solo i messaggi veri, in ordine.
    final contents = <Map<String, dynamic>>[
      for (final m in history.cast<ChatMessage>())
        if (!m.pending && !m.failed && m.text.trim().isNotEmpty)
          {
            'role': m.isUser ? 'user' : 'model',
            'parts': [
              {'text': m.text}
            ],
          },
      {
        'role': 'user',
        'parts': [
          {'text': userMessage}
        ],
      },
    ];
    final corpo = jsonEncode({
      'systemInstruction': {
        'parts': [
          {'text': istruzione}
        ]
      },
      'contents': contents,
      'generationConfig': {
        'temperature': 0.9,
        'topP': 0.95,
        'maxOutputTokens': misura.tetto,
        'thinkingConfig': {'thinkingBudget': misura.ragionamento},
      },
    });

    // **IL GETTONE SI RINNOVA AL PRIMO RIFIUTO.** `print-access-token` da' il
    // gettone in cache, che in un giro lungo scade: al 401 si rinnova e si
    // riprova una volta sola.
    final cronometro = Stopwatch()..start();
    var risposta = await _chiedi(corpo);
    if (risposta.$1 == 401 || risposta.$1 == 403) {
      _gettoneInCache = null;
      risposta = await _chiedi(corpo);
    }
    chiamate++;
    if (risposta.$1 != 200) {
      throw MaestroAiUnavailable(
          'Vertex ha risposto ${risposta.$1}: ${risposta.$2}');
    }
    final mappa = jsonDecode(risposta.$2) as Map<String, dynamic>;
    final candidati = mappa['candidates'] as List?;
    if (candidati == null || candidati.isEmpty) {
      throw const MaestroAiUnavailable('Nessun candidato nella risposta.');
    }
    final primo = candidati.first as Map<String, dynamic>;
    final parti =
        ((primo['content'] as Map<String, dynamic>?)?['parts'] as List?) ?? [];
    final testo =
        parti.map((p) => ((p as Map)['text'] ?? '') as String).join().trim();
    if (testo.isEmpty) {
      throw const MaestroAiUnavailable('Il Maestro non ha trovato le parole.');
    }
    if (primo['finishReason'] == 'MAX_TOKENS') {
      throw const MaestroAiTroncata();
    }
    // L'ultima riga prima dello schermo, la stessa dell'app.
    final pulito = TestoDelResponso.pulisci(testo);
    cronometro.stop();
    grezze.add(RispostaGrezza(maestro, pulito, cronometro.elapsed));
    return pulito;
  }

  /// **UNA DOMANDA CHIUSA AL MODELLO, per giudicare una risposta libera.**
  ///
  /// Serve dove un elenco di frasi non puo' arrivare: se un testo scritto in
  /// liberta' fa o non fa una certa cosa. Temperatura zero, nessun
  /// ragionamento, una parola sola di risposta: e' un giudice, non una voce.
  ///
  /// **Non giudica il tono e non giudica la qualita'**: quelli restano al
  /// fondatore, che legge le trascrizioni. Qui si risponde a domande con due
  /// sole uscite.
  Future<bool> giudica(String domanda, String testo) async {
    final corpo = jsonEncode({
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': '$domanda\n\n---\n\n$testo'}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0,
        'maxOutputTokens': 8,
        'thinkingConfig': {'thinkingBudget': 0},
      },
    });
    var risposta = await _chiedi(corpo);
    if (risposta.$1 == 401 || risposta.$1 == 403) {
      _gettoneInCache = null;
      risposta = await _chiedi(corpo);
    }
    giudizi++;
    if (risposta.$1 != 200) {
      throw MaestroAiUnavailable(
          'Il giudice ha risposto ${risposta.$1}: ${risposta.$2}');
    }
    final mappa = jsonDecode(risposta.$2) as Map<String, dynamic>;
    final parti = (((mappa['candidates'] as List?)?.firstOrNull
            as Map<String, dynamic>?)?['content']
        as Map<String, dynamic>?)?['parts'] as List?;
    final detto = (parti ?? [])
        .map((p) => ((p as Map)['text'] ?? '') as String)
        .join()
        .trim()
        .toUpperCase();
    return detto.startsWith('SI') || detto.startsWith('SÌ');
  }

  Future<(int, String)> _chiedi(String corpo) async {
    final gettone = _gettoneInCache ??= await _leggiIlGettone();
    final uri = Uri.https(
      '$_regione-aiplatform.googleapis.com',
      '/v1/projects/$_progetto/locations/$_regione/publishers/google/models/'
          '${FirebaseMaestroAiProvider.kMaestroChatModel}:generateContent',
    );
    final client = HttpClient();
    try {
      final richiesta = await client.postUrl(uri);
      richiesta.headers.set('Authorization', 'Bearer $gettone');
      richiesta.headers.set('Content-Type', 'application/json');
      richiesta.add(utf8.encode(corpo));
      final risposta = await richiesta.close();
      final grezzo = await risposta.transform(utf8.decoder).join();
      return (risposta.statusCode, grezzo);
    } finally {
      client.close(force: true);
    }
  }

  static Future<String> _leggiIlGettone() async {
    final esito = await Process.run('gcloud', ['auth', 'print-access-token'],
        runInShell: true);
    final t = (esito.stdout as String).trim();
    if (esito.exitCode != 0 || t.isEmpty) {
      throw const MaestroAiUnavailable(
          'Nessun gettone di accesso: serve una sessione gcloud attiva.');
    }
    return t;
  }

  // --- Le altre vie non servono al collaudo delle chat.
  @override
  Future<Responso> presagioDelleRune({
    required EsitoGettata esito,
    required String domanda,
    required UserProfile profile,
    NatalContext natal = NatalContext.none,
  }) async =>
      throw const MaestroAiUnavailable();

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

  /// **LA SINTESI COMPARATIVA, CHIESTA A GEMINI VERO.** Ordine EE voce 10.
  ///
  /// Prima qui c'era un rifiuto: il collaudo provava le chat, non il
  /// Consiglio. La seconda meta' della voce 10 dice che la sintesi ripete le
  /// tre letture invece di confrontarle, e **senza una misura prima e dopo
  /// non si sa se una cura ha funzionato**: e' cio' che l'ordine EC voce 03
  /// ha insegnato a questa casa.
  @override
  Future<String> synthesize({
    required String theme,
    required List<MaestroLens> lenses,
    NatalContext? natal,
    UserProfile? profile,
  }) async {
    final corpo = jsonEncode({
      'systemInstruction': {
        'parts': [
          {
            'text': MaestroPersona.synthesisInstruction(
                natal: natal, profilo: profile)
          }
        ]
      },
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': _materialeDellaSintesi(theme, lenses)}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.7,
        'topP': 0.95,
        'maxOutputTokens': MisuraDellaRisposta.sintesi.tetto,
        'thinkingConfig': {
          'thinkingBudget': MisuraDellaRisposta.sintesi.ragionamento
        },
      },
    });
    var risposta = await _chiedi(corpo);
    if (risposta.$1 == 401 || risposta.$1 == 403) {
      _gettoneInCache = null;
      risposta = await _chiedi(corpo);
    }
    chiamate++;
    if (risposta.$1 != 200) {
      throw MaestroAiUnavailable('Vertex ha risposto ${risposta.$1}');
    }
    final mappa = jsonDecode(risposta.$2) as Map<String, dynamic>;
    final candidati = mappa['candidates'] as List?;
    if (candidati == null || candidati.isEmpty) {
      throw const MaestroAiUnavailable('Nessun candidato nella sintesi.');
    }
    final primo = candidati.first as Map<String, dynamic>;
    final parti =
        ((primo['content'] as Map<String, dynamic>?)?['parts'] as List?) ?? [];
    final testo =
        parti.map((p) => ((p as Map)['text'] ?? '') as String).join().trim();
    if (testo.isEmpty) {
      throw const MaestroAiUnavailable('La sintesi non ha trovato le parole.');
    }
    return TestoDelResponso.pulisci(testo);
  }

  /// Il materiale della sintesi, **nella stessa forma del provider vero**:
  /// la domanda e le letture gia' date, una per Maestro.
  String _materialeDellaSintesi(String theme, List<MaestroLens> lenses) {
    final b = StringBuffer('Domanda della persona: «${theme.trim()}».\n\n');
    for (final l in lenses) {
      b
        ..writeln('${l.maestro.displayName} (${l.maestro.domainArtsPhrase}):')
        ..writeln('- Colpo d\'occhio: ${l.glance.trim()}')
        ..writeln('- Lettura: ${l.reading.trim()}')
        ..writeln();
    }
    return b.toString();
  }

  @override
  Future<MemoryDigest?> distill({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory previous,
    required List<dynamic> history,
  }) async =>
      null;
}

/// **LE TRE LETTURE DELLA CATTURA DEL FONDATORE.** Ordine EE voce 10.
///
/// Sono quelle vere del 23 settembre 2026, sul Consiglio aperto da una stesa
/// "Denaro e fortuna" con Tre di Denari, Tre di Coppe e La Ruota della
/// Fortuna. **Si parte dallo stesso materiale che ha generato la sintesi che
/// il fondatore ha letto**, o si misurerebbe un'altra cosa.
abstract final class LeLentiDellaCattura {
  static const String domanda = 'Denaro e fortuna';

  static final List<MaestroLens> tutte = [
    MaestroLens.strati(
      maestro: Maestro.medora,
      glance: 'Il cielo si apre oggi sul tuo Cancro solare, un richiamo '
          'all\'intuizione più profonda.',
      reading: 'Le lame ti parlano di un momento in cui la cooperazione e la '
          'gioia condivisa sono fondamentali per il tuo benessere materiale. '
          'Il Tre di Denari suggerisce che il tuo lavoro, la tua dedizione, '
          'troveranno riconoscimento, spesso attraverso l\'abilità di '
          'costruire con gli altri. Segue il Tre di Coppe, un arcano che '
          'celebra la felicità, la festa, la condivisione di successi. La '
          'Ruota della Fortuna indica che il ciclo sta girando a tuo favore, '
          'portando con sé opportunità inattese.',
      invite: 'Ripassa fra 4 giorni, per la Luna piena.',
    ),
    MaestroLens.strati(
      maestro: Maestro.caligo,
      glance: 'Il simbolo del denaro e la sua espansione sono presenti.',
      reading: 'Il Tre di Denari indica la maestria nel tuo operare, la '
          'realizzazione di un progetto. Il Tre di Coppe celebra l\'unione '
          'delle forze, la condivisione del successo. La Ruota della Fortuna '
          'segna un cambiamento, un ciclo che si rinnova. Questi segni '
          'parlano di un lavoro ben fatto che porta frutto, unito a '
          'un\'espansione sociale o creativa.',
      invite: 'Domani al tramonto ti aspetta Ehwaz: portala con te.',
    ),
    MaestroLens.strati(
      maestro: Maestro.aura,
      glance: 'Denaro e fortuna, un respiro che accoglie l\'abbondanza nel '
          'presente.',
      reading: 'Immagina il denaro come un seme che hai piantato, un lavoro '
          'che prendi in mano con cura. Il Tre di Denari lo vedo come '
          'l\'impegno che metti nel tuo fare. Poi, il Tre di Coppe sboccia '
          'come la gioia che nasce dalla condivisione. E la Ruota della '
          'Fortuna è il ritmo della vita che gira, un movimento che ti invita '
          'a danzare con il flusso del momento.',
      invite: 'Domani lavora il fuoco: rileggi con quello acceso.',
    ),
  ];
}

/// La trascrizione della sintesi, per il giudizio del fondatore.
void _scriviLaSintesi(
  Directory cartella,
  String domanda,
  String sintesi,
  EsitoDellaSintesi esito,
) {
  final b = StringBuffer()
    ..writeln('# Mossa 17, la sintesi comparativa del Consiglio')
    ..writeln()
    ..writeln('**Domanda:** $domanda. **Le tre letture sono quelle vere della '
        'cattura del fondatore del 23 settembre 2026.**')
    ..writeln()
    ..writeln('---')
    ..writeln()
    ..writeln('## La sintesi')
    ..writeln()
    ..writeln('> ${sintesi.replaceAll('\n', '\n> ')}')
    ..writeln()
    ..writeln('---')
    ..writeln()
    ..writeln('## Esito dei controlli')
    ..writeln()
    ..writeln('- parole della sintesi: ${esito.paroleProprie}')
    ..writeln('- Maestri chiamati per nome: ${esito.maestriNominati}')
    ..writeln('- sequenze di cinque parole riprese dalle letture: '
        '${esito.sequenzeRipetute}')
    ..writeln('- nomina almeno una relazione fra gli sguardi: '
        '${esito.parlaDiRelazione ? 'si' : 'NO'}')
    ..writeln();
  if (esito.cadute.isEmpty) {
    b.writeln('Nessuna caduta.');
  } else {
    for (final c in esito.cadute) {
      b.writeln('- $c');
    }
  }
  b
    ..writeln()
    ..writeln('**Se la sintesi confronti davvero i tre sguardi, invece di '
        'riassumerli, lo giudica il fondatore leggendo questa pagina: i '
        'controlli qui sopra non lo misurano.**');
  File('${cartella.path}/sintesi.md').writeAsStringSync(b.toString());
}
