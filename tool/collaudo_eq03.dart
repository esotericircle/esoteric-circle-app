// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/consiglio_finale.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_controller.dart';
import 'package:esoteric_circle/services/ai/firebase_maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/registro_dei_guasti.dart';
import 'package:esoteric_circle/services/ai/voce_sorvegliata.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'la_voce_vera_di_gemini.dart';

/// **IL COLLAUDO DELLE RISPOSTE NEL MERITO, ANCHE NEL LIVE, ordine EQ voce
/// 03.** 27 settembre 2026.
///
/// Nelle catture, a *"Ok, le ho scritte e adesso cosa faccio?"* Calìgo
/// risponde *"Il tuo gesto è compiuto. Ora lascia che il tempo faccia il suo
/// corso."*: non dice niente. L'ordine: una risposta dice qualcosa di
/// concreto sulla domanda e tiene conto di cio' che la persona ha appena
/// detto; si misurano le stesse domande in chat e nel LIVE, con Flash e con
/// Flash-Lite, e per il LIVE resta il modello che risponde nel merito, fra
/// due che lo fanno il piu' veloce.
///
/// **Dodici domande di seguito per Maestro**, nella stessa conversazione, con
/// dentro quelle delle catture. Per ogni risposta:
///
/// - **che cosa risponde, in una riga**, scritta da Gemini a temperatura
///   zero: prima il corpo della risposta, poi il gesto della riga con ✦;
/// - **il tempo del modello**, dalla richiesta alla risposta intera: il LIVE
///   comincia a parlare solo quando la risposta e' intera e ha passato le
///   reti, quindi e' questo il pezzo dell'attesa che il modello decide;
/// - **nel merito**, NON da Gemini: da una lettura con la regola scritta
///   (`docs/collaudo/EQ/eq03/regola_della_lettura.md`), nel file
///   `docs/collaudo/EQ/eq03/lettura_<fase>.txt`, applicata con `RILEGGI`.
///
/// **Perche' il merito non lo giudica Gemini.** Quattro stesure del giudice
/// a temperatura zero, tarate sulle risposte vere etichettate a mano, sono
/// arrivate nel controllo a 33, 33 e 29 su 43 (`taratura_*_stesura.txt`):
/// sul confine fra un invito generico e un'indicazione Flash sbaglia da
/// tutte e due le parti, e il merito e' proprio quel confine. Il giudice e la
/// taratura restano qui sotto, come prova di cio' che non basta.
///
/// ```
/// flutter test tool/collaudo_eq03.dart --dart-define=FASE=prima \
///   --dart-define=MODI=live-lite,chat
/// flutter test tool/collaudo_eq03.dart --dart-define=FASE=dopo \
///   --dart-define=MODI=live-lite,live-flash,chat
/// flutter test tool/collaudo_eq03.dart --dart-define=FASE=dopo \
///   --dart-define=RILEGGI=true
/// ```
///
/// Due giri per modo, `GIRI=2`. Le trascrizioni vanno in
/// `docs/collaudo/EQ/eq03/<fase>/`.
const String fase = String.fromEnvironment('FASE', defaultValue: 'dopo');
const String modi =
    String.fromEnvironment('MODI', defaultValue: 'live-lite,live-flash,chat');
const int giri = int.fromEnvironment('GIRI', defaultValue: 2);

/// `--dart-define=TARATURA=true`: il giudice del merito sui casi noti, e
/// nient'altro. E' la prova che il giudice non basta.
const bool taratura = bool.fromEnvironment('TARATURA');

/// `--dart-define=RILEGGI=true`: rilegge le trascrizioni gia' fatte della
/// fase senza chiedere niente ai Maestri. Applica la lettura del merito dal
/// file `lettura_<fase>.txt`, ne fa i conti con i tempi, e con
/// `--dart-define=RIGHE=true` riscrive anche la riga di sintesi, perche'
/// prima e dopo abbiano le righe dalla stessa domanda.
const bool rileggi = bool.fromEnvironment('RILEGGI');
const bool riscriviLeRighe = bool.fromEnvironment('RIGHE');

const natal = NatalContext(
  sunSign: 'Cancro',
  ascendant: 'Gemelli',
  lifeNumber: 3,
  lifeNumberTitle: 'il Creativo',
);

/// Le dodici domande, di seguito: quelle delle catture nell'ordine in cui il
/// fondatore le ha scritte, poi il seguito di una persona vera che torna sul
/// suo passo.
const List<String> domande = [
  'Ciao, chi sei? Come puoi aiutarmi?',
  'Beh, vorrei avere una compagna, vorrei andare in Australia e vorrei '
      'avessi successo col lavoro che sto facendo.',
  'Ok, gli ho scritto adesso.',
  'Ok, le ho scritte e adesso cosa faccio?',
  'Da dove comincio, dal lavoro o dal viaggio?',
  'Il mio capo non mi dà mai un riconoscimento. Come glielo chiedo?',
  'Ho paura che in Australia mi senta solo.',
  'Mia madre dice che è una follia partire. Cosa le rispondo?',
  'Ok, ci ho parlato stamattina e ha pianto.',
  'Quanto tempo mi serve per decidere?',
  'Ho scelto: parto a marzo. E adesso?',
  'Grazie. Cosa faccio domani mattina, appena sveglio?',
];

/// Il modo: dove e con quale modello risponde il Maestro.
class Modo {
  const Modo(this.nome, {required this.nelLive, this.modello});
  final String nome;
  final bool nelLive;

  /// Il modello, se il modo lo sceglie al posto dell'app.
  final String? modello;
}

const Map<String, Modo> tuttiIModi = {
  'live-lite': Modo('LIVE con Flash-Lite',
      nelLive: true, modello: FirebaseMaestroAiProvider.kMaestroBreveModel),
  'live-flash': Modo('LIVE con Flash',
      nelLive: true, modello: FirebaseMaestroAiProvider.kMaestroChatModel),
  'chat': Modo('chat con Flash', nelLive: false),
};

const int _ragionamento = 1024;

/// Tre voti insieme: a temperatura zero con il ragionamento acceso le tre
/// risposte possono ancora differire, e in fila costerebbero il triplo.
Future<bool> _aMaggioranza(Future<bool> Function() voto) async {
  final voti = await Future.wait([voto(), voto(), voto()]);
  return voti.where((v) => v).length >= 2;
}

/// **IL GIUDICE DEL MERITO**, con lo scambio di prima davanti.
///
/// **Terza stesura, una procedura.** La prima, tarata su dodici casi scritti
/// a mano, li indovinava tutti e poi, sulle risposte vere del collaudo
/// "prima", dava nel merito le massime brevi di Calìgo ("La decisione è già
/// tua. Ogni momento è soglia.") e i rimandi gentili a un altro Maestro:
/// nove disaccordi su trentasei con la lettura a mano, tutti dalla stessa
/// parte. La seconda chiedeva "dopo averla letta, la persona sa che cosa
/// fare?" in una domanda sola, e sbagliava da tutte e due le parti (25 su 35
/// in taratura, 33 su 43 nel controllo): bocciava le presentazioni e il
/// gesto per "domani mattina", e promuoveva le massime quando sotto c'era una
/// riga con ✦ qualunque, anche "Parla con tua madre stasera" a "Quanto tempo
/// mi serve per decidere?". La terza, una procedura in tre passi sulla
/// risposta intera, e' arrivata a 28 su 35 e 33 su 43, di nuovo dalla parte
/// dell'indulgenza: "Rispondi con fermezza" e "Prepari il tuo sigillo"
/// passavano come indicazioni. **La quarta** riceve le frasi e la riga con ✦
/// separate, fa la prova dello scambio (la stessa frase andrebbe bene a
/// un'altra persona che ha scritto un'altra cosa?) e ragiona di piu'.
Future<bool> nelMerito(VoceVeraDiGemini voce,
    {required String prima,
    required String domanda,
    required String risposta}) {
  final riga = ConsiglioFinale.sintesiDa(risposta);
  final corpo = ConsiglioFinale.corpoDa(risposta);
  return _aMaggioranza(() => voce.giudica(
        'Scambio precedente della conversazione:\n$prima\n\n'
            'Ultima cosa detta dalla persona: "$domanda".\n\n'
            'Qui sotto ci sono le FRASI della risposta del consulente e, a parte, '
            'la sua RIGA CON ✦, se c\'e\'. Decidi se la risposta e\' NEL MERITO. '
            'Procedi cosi\':\n'
            '1. Se la persona chiede soltanto chi e\' il consulente o come puo\' '
            'aiutarla, e\' NEL MERITO se dice chi e\' e con quali arti aiuta.\n'
            '2. Altrimenti cerca nelle FRASI una frase che, per l\'ultima cosa '
            'detta dalla persona, dica che cosa fare in un modo che si puo\' '
            'eseguire (che cosa dire e a chi, quando, dove, con quale oggetto, '
            'quale strada scegliere) oppure che cosa significa per lei quello che '
            'e\' successo. Per ogni frase candidata fai la PROVA DELLO SCAMBIO: '
            'se la stessa frase andrebbe bene anche a un\'altra persona che ha '
            'scritto un\'altra cosa, non conta. Non contano mai gli inviti '
            'generici (aspettare, non esitare, essere fermi o chiari, ascoltarsi, '
            'prepararsi, organizzarsi), le sentenze, i rimandi a un altro '
            'consulente, le frasi che ignorano quello che la persona ha appena '
            'raccontato. Se una frase conta, e\' NEL MERITO.\n'
            '3. Se nessuna frase conta, guarda la RIGA CON ✦: e\' NEL MERITO solo '
            'se il gesto risponde proprio all\'ultima cosa detta dalla persona, '
            'si puo\' eseguire e passa la prova dello scambio.\n'
            '4. Altrimenti NON e\' nel merito.\n'
            'Rispondi con una parola sola, SI oppure NO.',
        'FRASI:\n$corpo\n\nRIGA CON ✦: ${riga ?? '(nessuna)'}',
        ragionamento: _ragionamento,
      ));
}

/// **UNA TRASCRIZIONE DEL COLLAUDO, riletta**: le domande, le risposte e i
/// tempi, nell'ordine in cui `_scrivi` li ha messi.
List<Esito> leggiLaTrascrizione(File f) {
  final esiti = <Esito>[];
  String? domanda;
  var sintesi = '';
  final risposta = <String>[];
  for (final r in f.readAsLinesSync()) {
    final titolo = RegExp(r'^## \d+\. (.*)$').firstMatch(r);
    final tempo = RegExp(r'^- tempo del modello: (\d+) ms$').firstMatch(r);
    if (titolo != null) {
      domanda = titolo.group(1);
      risposta.clear();
      sintesi = '';
    } else if (r.startsWith('> ')) {
      risposta.add(r.substring(2));
    } else if (r == '>') {
      risposta.add('');
    } else if (r.startsWith('- in una riga: ')) {
      sintesi = r.substring('- in una riga: '.length);
    } else if (tempo != null && domanda != null) {
      esiti.add(Esito(domanda, risposta.join('\n'), int.parse(tempo.group(1)!))
        ..riga = sintesi);
    }
  }
  return esiti;
}

/// **LA LETTURA DEL MERITO DI UNA FASE**, dal file
/// `docs/collaudo/EQ/eq03/lettura_<fase>.txt`: una riga per risposta,
/// `<fase>/<trascrizione>|numero|SI o NO|perche'`. La chiave e'
/// `trascrizione|numero`.
Map<String, (bool, String)> letturaDellaFase() {
  final f = File('docs/collaudo/EQ/eq03/lettura_$fase.txt');
  if (!f.existsSync()) return const {};
  final lettura = <String, (bool, String)>{};
  for (final r in f.readAsLinesSync()) {
    if (r.trim().isEmpty || r.startsWith('#')) continue;
    final p = r.split('|');
    final nome = p[0].split('/').last;
    lettura['$nome|${p[1]}'] = (p[2].trim() == 'SI', p[3].trim());
  }
  return lettura;
}

/// Lo scambio che il giudice vede davanti alla risposta [i]: la domanda e il
/// corpo della risposta di prima, come nella generazione.
String scambioPrima(List<Esito> esiti, int i) => i == 0
    ? '(nessuno: e\' la prima domanda)'
    : 'Persona: "${esiti[i - 1].domanda}"\nConsulente: '
        '"${ConsiglioFinale.corpoDa(esiti[i - 1].risposta)}"';

/// **LE RISPOSTE VERE ETICHETTATE A MANO**, dal file
/// `docs/collaudo/EQ/eq03/<nome>`: una riga per risposta,
/// `trascrizione|numero|SI o NO|perche'`, i commenti con `#`. Le etichette
/// dubbie non si scrivono: una taratura si fa sui casi chiari.
List<CasoNoto> etichetteAMano(String nome) {
  final casi = <CasoNoto>[];
  final file = File('docs/collaudo/EQ/eq03/$nome');
  for (final riga in file.readAsLinesSync()) {
    if (riga.trim().isEmpty || riga.startsWith('#')) continue;
    final p = riga.split('|');
    final esiti = leggiLaTrascrizione(File('docs/collaudo/EQ/eq03/${p[0]}'));
    final i = int.parse(p[1]) - 1;
    casi.add(CasoNoto(scambioPrima(esiti, i), esiti[i].domanda,
        esiti[i].risposta, p[2] == 'SI', '${p[0]} n. ${p[1]}: ${p[3]}'));
  }
  return casi;
}

/// Che cosa risponde, in una riga, dal giudice.
Future<String> inUnaRiga(
        VoceVeraDiGemini voce, String domanda, String risposta) async =>
    (await voce.elenca(
      'Domanda della persona: "$domanda".\n'
      'Scrivi in UNA riga, in italiano, al massimo venti parole, che cosa '
      'risponde il consulente qui sotto: prima che cosa dicono le frasi della '
      'risposta, cioe\' che cosa dice di fare o che cosa afferma; se in fondo '
      'c\'e\' una riga che comincia con ✦, dopo un punto e virgola il gesto '
      'che propone, in poche parole. Niente premesse, niente virgolette.',
      risposta,
      tetto: 100,
    ))
        .replaceAll('\n', ' ')
        .trim();

/// **I CASI NOTI DEL GIUDICE DEL MERITO, scritti a mano.** Il primo e'
/// quello delle catture del fondatore; gli altri sono le forme che una
/// risposta vuota prende e le risposte concrete alle stesse domande: sette
/// si', nove no. Da soli non bastano: le risposte vere etichettate a mano
/// stanno in `docs/collaudo/EQ/eq03/etichette_*.txt`.
class CasoNoto {
  const CasoNoto(
      this.prima, this.domanda, this.risposta, this.atteso, this.perche);
  final String prima;
  final String domanda;
  final String risposta;
  final bool atteso;
  final String perche;
}

const List<CasoNoto> casiNoti = [
  CasoNoto(
      'Persona: "Ok, gli ho scritto adesso."\nConsulente: "Bene, il primo '
          'passo e\' fatto: la carta tiene cio\' che la voce disperde."',
      'Ok, le ho scritte e adesso cosa faccio?',
      "Il tuo gesto è compiuto. Ora lascia che il tempo faccia il suo corso.",
      false,
      'le catture del fondatore'),
  CasoNoto(
      'Persona: "Ok, le ho scritte e adesso cosa faccio?"\nConsulente: '
          '"Piega il foglio in tre e mettilo sotto una candela bianca."',
      'Da dove comincio, dal lavoro o dal viaggio?',
      "Ascolta la voce che senti dentro di te: la risposta è già lì, aspetta "
          "solo che tu la riconosca.",
      false,
      'una frase per chiunque'),
  CasoNoto(
      'Persona: "Mia madre dice che è una follia partire. Cosa le '
          'rispondo?"\nConsulente: "Dille che non parti per scappare ma per '
          'crescere, e mostrale il piano."',
      'Ok, ci ho parlato stamattina e ha pianto.',
      "Parla con tua madre e spiegale con calma le ragioni della tua scelta: "
          "la chiarezza scioglie le paure.",
      false,
      'ignora che la persona ci ha appena parlato'),
  CasoNoto(
      'Persona: "Il mio capo non mi dà mai un riconoscimento. Come glielo '
          'chiedo?"\nConsulente: "Chiedigli dieci minuti venerdì e porta due '
          'risultati con i numeri."',
      'Ho paura che in Australia mi senta solo.',
      "Sulla solitudine e sul cuore saprà dirti di più Aura, rivolgiti a lei.",
      false,
      'rimanda altrove senza dire niente'),
  CasoNoto(
      'Persona: "Ok, ci ho parlato stamattina e ha pianto."\nConsulente: '
          '"Il suo pianto è paura di perderti, non un divieto."',
      'Quanto tempo mi serve per decidere?',
      "Il tempo giusto è quello che il tuo cuore riconosce. Non avere fretta: "
          "ogni cosa arriva quando deve.",
      false,
      'una sentenza senza misura'),
  CasoNoto(
      'Persona: "Quanto tempo mi serve per decidere?"\nConsulente: "Datti '
          'tre settimane, fino alla prossima Luna nuova."',
      'Ho scelto: parto a marzo. E adesso?',
      "Hai fatto un passo importante. Ora osserva cosa si muove dentro di te.",
      false,
      'la forma breve del LIVE, vuota'),
  CasoNoto(
      'Persona: "Ok, gli ho scritto adesso."\nConsulente: "Bene, il primo '
          'passo e\' fatto: la carta tiene cio\' che la voce disperde."',
      'Ok, le ho scritte e adesso cosa faccio?',
      "Adesso piegale in tre e mettile sotto una candela bianca accesa "
          "stasera: quando la fiamma si spegne, tieni da parte il foglio del "
          "desiderio che senti più urgente. Da lì comincia il primo passo.",
      true,
      'un gesto preciso che parte dai fogli scritti'),
  CasoNoto(
      'Persona: "Ok, le ho scritte e adesso cosa faccio?"\nConsulente: '
          '"Piega il foglio in tre e mettilo sotto una candela bianca."',
      'Da dove comincio, dal lavoro o dal viaggio?',
      "Dal lavoro: il viaggio si regge sui soldi e sulla fiducia che il "
          "lavoro ti dà. Questo mese fissa con il capo un obiettivo che si "
          "possa contare, e metti da parte ogni settimana una cifra per "
          "l'Australia.",
      true,
      'sceglie e dice che cosa fare'),
  CasoNoto(
      'Persona: "Mia madre dice che è una follia partire. Cosa le '
          'rispondo?"\nConsulente: "Dille che non parti per scappare ma per '
          'crescere, e mostrale il piano."',
      'Ok, ci ho parlato stamattina e ha pianto.',
      "Il suo pianto è paura di perderti, non un divieto. Stasera richiamala "
          "e raccontale un dettaglio concreto del piano, la città e il "
          "lavoro: la paura cala quando vede che hai i piedi per terra.",
      true,
      'tiene conto del pianto e dice il passo'),
  CasoNoto(
      'Persona: "Ok, ci ho parlato stamattina e ha pianto."\nConsulente: '
          '"Il suo pianto è paura di perderti, non un divieto."',
      'Quanto tempo mi serve per decidere?',
      "Datti tre settimane, fino alla prossima Luna nuova: ogni sera scrivi "
          "un motivo per partire e uno per restare, poi guarda quali pesano "
          "di più.",
      true,
      'una misura e un metodo'),
  CasoNoto(
      'Persona: "Il mio capo non mi dà mai un riconoscimento. Come glielo '
          'chiedo?"\nConsulente: "Chiedigli dieci minuti venerdì e porta due '
          'risultati con i numeri."',
      'Ho paura che in Australia mi senta solo.',
      "È una paura vera per chi ha il Sole in Cancro, che mette radici nella "
          "casa. Prima di partire cerca a Melbourne un gruppo di italiani o "
          "un corso serale: arrivare con un nome da chiamare cambia la prima "
          "settimana.",
      true,
      'legge la paura e dice che cosa fare'),
  CasoNoto(
      'Persona: "Quanto tempo mi serve per decidere?"\nConsulente: "Datti '
          'tre settimane, fino alla prossima Luna nuova."',
      'Ho scelto: parto a marzo. E adesso?',
      "Adesso incidi Raidho, la runa del viaggio, su un sasso e tienilo in "
          "tasca fino alla partenza. Intanto metti in fila le carte: "
          "passaporto e visto entro dicembre.",
      true,
      'la forma breve del LIVE, concreta'),
  // Con la riga d'oro sotto: il giudice guarda tutta la risposta, e un gesto
  // concreto ma estraneo alla domanda non la rende nel merito.
  CasoNoto(
      'Persona: "Ok, gli ho scritto adesso."\nConsulente: "Hai fatto un '
          'passo. Ora attendi la sua risposta."',
      'Ok, le ho scritte e adesso cosa faccio?',
      "Il tuo gesto è compiuto. Ora lascia che il tempo faccia il suo "
          "corso.\n\n✦ Scrivi su un foglio di carta bianca tre cose che "
          "vorresti realizzare.",
      false,
      'le catture del fondatore alla lettera, con la riga d\'oro'),
  CasoNoto(
      'Persona: "Il mio capo non mi dà mai un riconoscimento. Come glielo '
          'chiedo?"\nConsulente: "Chiedigli dieci minuti venerdì e porta due '
          'risultati con i numeri."',
      'Ho paura che in Australia mi senta solo.',
      "La paura è una compagna di viaggio che conosce la strada. Portala con "
          "te senza ascoltarla troppo.\n\n✦ Domani mattina bevi un bicchiere "
          "d'acqua tiepida prima del caffè.",
      false,
      'corpo vuoto e un gesto estraneo alla domanda'),
  CasoNoto(
      'Persona: "Mia madre dice che è una follia partire. Cosa le '
          'rispondo?"\nConsulente: "Dille che non parti per scappare ma per '
          'crescere, e mostrale il piano."',
      'Ok, ci ho parlato stamattina e ha pianto.',
      "Ha pianto perché ha paura di perderti, non perché ti vuole fermare. "
          "Stasera chiamala e dille la data della partenza e dove starai."
          "\n\n✦ Stasera scrivi su un foglio il nome della città dove andrai "
          "e mettilo vicino alla sua foto.",
      true,
      'corpo concreto e riga d\'oro'),
  // Dal collaudo "prima", Aura nel LIVE con Flash-Lite: il giudice l'ha data
  // nel merito, ed e' solo un rimando.
  CasoNoto(
      'Persona: "Ho paura che in Australia mi senta solo."\nConsulente: '
          '"Per esplorare questa sensazione di solitudine puoi chiedere a '
          'Medora."',
      'Mia madre dice che è una follia partire. Cosa le rispondo?',
      "Per le questioni familiari e i consigli su come rispondere a tua "
          "madre, puoi rivolgerti a Medora.\n\n✦ Ascolta il tuo respiro per "
          "un minuto, senza cambiarlo.",
      false,
      'un rimando gentile a un altro Maestro, dal collaudo prima'),
];

class Esito {
  Esito(this.domanda, this.risposta, this.millesimi);
  final String domanda;
  final String risposta;
  final int millesimi;

  /// Nullo finche' la risposta non e' stata letta.
  bool? merito;
  String perche = '';
  String riga = '';
}

int mediana(List<int> valori) {
  if (valori.isEmpty) return 0;
  final v = [...valori]..sort();
  return v.length.isOdd
      ? v[v.length ~/ 2]
      : ((v[v.length ~/ 2 - 1] + v[v.length ~/ 2]) / 2).round();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final cartella = Directory('docs/collaudo/EQ/eq03/$fase');
  final conto = StringBuffer();
  final tempiPerModo = <String, List<int>>{};
  // Per modo: risposte nel merito, risposte lette, risposte.
  final meritoPerModo = <String, List<int>>{};

  // La riga dei modelli della generazione: quando si rilegge resta quella
  // del conto di allora, perche' le risposte sono di allora.
  var modelli = 'Modelli: chat ${FirebaseMaestroAiProvider.kMaestroChatModel}'
      ', LIVE dell\'app '
      '${FirebaseMaestroAiProvider.modelloDelTurno(nelLive: true)}; '
      'europe-west1.';

  setUpAll(() {
    HttpOverrides.global = null;
    if (!cartella.existsSync()) cartella.createSync(recursive: true);
    final vecchio = File('${cartella.path}/_conto.txt');
    if (rileggi && vecchio.existsSync()) {
      modelli = vecchio
          .readAsLinesSync()
          .firstWhere((r) => r.startsWith('Modelli:'), orElse: () => modelli);
    }
  });

  // Il conto si scrive solo quando c'e' qualcosa da contare: la taratura non
  // tocca il conto di nessuna fase.
  tearDownAll(() {
    if (tempiPerModo.isEmpty) return;
    conto.writeln();
    for (final m in tempiPerModo.keys) {
      final nel = meritoPerModo[m] ?? [0, 0, 0];
      final merito = nel[1] == 0
          ? 'merito da leggere'
          : 'nel merito ${nel[0]} su ${nel[1]} lette'
              '${nel[1] < nel[2] ? ' (su ${nel[2]})' : ''}';
      final r = 'TOTALE ${m.toUpperCase()}: $merito, tempo del modello '
          'mediano ${mediana(tempiPerModo[m]!)} ms su '
          '${tempiPerModo[m]!.length} risposte';
      print('EQ.03 $fase $r');
      conto.writeln(r);
    }
    conto.writeln(modelli);
    if (rileggi) {
      conto.writeln('Il merito viene dalla lettura con la regola scritta, '
          'docs/collaudo/EQ/eq03/lettura_$fase.txt; le risposte e i tempi sono '
          'quelli della generazione.');
    }
    File('${cartella.path}/_conto.txt').writeAsStringSync(conto.toString());
  });

  if (rileggi) {
    test('EQ.03 $fase, riletta', () async {
      final voce = VoceVeraDiGemini();
      if (riscriviLeRighe) await voce.scaldaIlGettone();
      final lettura = letturaDellaFase();
      final file = cartella
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.md'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
      expect(file, isNotEmpty);
      for (final f in file) {
        final righe = f.readAsLinesSync();
        // "# Medora, LIVE con Flash-Lite, giro 1, fase prima"
        final testa = righe.first.substring(2).split(', ');
        final maestro =
            Maestro.values.firstWhere((m) => m.displayName == testa[0]);
        final modo = tuttiIModi.values.firstWhere((m) => m.nome == testa[1]);
        final giro = int.parse(testa[2].replaceFirst('giro ', ''));
        final esiti = leggiLaTrascrizione(f);
        expect(esiti.length, domande.length, reason: f.path);
        final nome = f.uri.pathSegments.last;
        for (var i = 0; i < esiti.length; i++) {
          final e = esiti[i];
          if (riscriviLeRighe) {
            e.riga = await inUnaRiga(voce, e.domanda, e.risposta);
          }
          if (lettura['$nome|${i + 1}'] case (final si, final perche)) {
            e
              ..merito = si
              ..perche = perche;
          }
        }
        final nel = esiti.where((e) => e.merito == true).length;
        final letti = esiti.where((e) => e.merito != null).length;
        final tempi = [for (final e in esiti) e.millesimi];
        tempiPerModo.putIfAbsent(modo.nome, () => []).addAll(tempi);
        meritoPerModo.putIfAbsent(modo.nome, () => [0, 0, 0])
          ..[0] += nel
          ..[1] += letti
          ..[2] += esiti.length;
        final riga = 'EQ.03 $fase ${modo.nome} giro $giro ${maestro.id}: '
            '${letti == 0 ? 'merito da leggere' : 'nel merito $nel su $letti lette'}'
            ', tempo del modello mediano ${mediana(tempi)} ms';
        print(riga);
        conto.writeln(riga);
        _scrivi(cartella, modo, giro, maestro, esiti, riga);
      }
    }, timeout: const Timeout(Duration(minutes: 60)));
    return;
  }

  if (taratura) {
    test('EQ.03, la taratura del giudice del merito', () async {
      final voce = VoceVeraDiGemini();
      await voce.scaldaIlGettone();
      // Tre gruppi: i casi scritti a mano, le risposte vere su cui il giudice
      // e' stato scritto, e il CONTROLLO, risposte vere etichettate prima di
      // far girare il giudice su di loro. Il controllo e' l'unico numero che
      // dice quanto sbaglia il giudice su cio' che non ha mai visto.
      final gruppi = <String, List<CasoNoto>>{
        'CASI SCRITTI A MANO': casiNoti,
        'RISPOSTE VERE, TARATURA': etichetteAMano('etichette_taratura.txt'),
        'RISPOSTE VERE, CONTROLLO': etichetteAMano('etichette_controllo.txt'),
      };
      final b = StringBuffer()
        ..writeln('Taratura del giudice del merito, ordine EQ voce 03, '
            'terza stesura: a maggioranza su tre, temperatura zero.')
        ..writeln();
      final conti = <String, List<int>>{};
      for (final g in gruppi.entries) {
        b
          ..writeln('## ${g.key}')
          ..writeln();
        var giusti = 0;
        for (final c in g.value) {
          final dato = await nelMerito(voce,
              prima: c.prima, domanda: c.domanda, risposta: c.risposta);
          final giusto = dato == c.atteso;
          if (giusto) giusti++;
          final r = '${giusto ? 'GIUSTO' : 'SBAGLIATO'}: atteso '
              '${c.atteso ? 'SI' : 'NO'}, dato ${dato ? 'SI' : 'NO'} '
              '(${c.perche})\n  "${c.domanda}"\n  -> '
              '"${c.risposta.replaceAll('\n', ' ')}"';
          print(r);
          b.writeln(r);
        }
        conti[g.key] = [giusti, g.value.length];
        b.writeln();
      }
      for (final c in conti.entries) {
        final tot = 'TARATURA, ${c.key}: ${c.value[0]} su ${c.value[1]}';
        print(tot);
        b.writeln(tot);
      }
      File('docs/collaudo/EQ/eq03/taratura_del_giudice.txt')
        ..parent.createSync(recursive: true)
        ..writeAsStringSync(b.toString());
      // I casi su cui il giudice e' scritto li deve indovinare tutti; il
      // controllo si legge nel file e nel rapporto.
      expect(conti['CASI SCRITTI A MANO']![0], casiNoti.length);
      expect(conti['RISPOSTE VERE, TARATURA']![0],
          conti['RISPOSTE VERE, TARATURA']![1]);
    }, timeout: const Timeout(Duration(minutes: 30)));
    return;
  }

  for (final chiave in modi.split(',')) {
    final modo = tuttiIModi[chiave]!;
    for (var giro = 1; giro <= giri; giro++) {
      for (final maestro in Maestro.values) {
        test('EQ.03 $fase, ${modo.nome}, giro $giro, ${maestro.id}', () async {
          final voce = VoceVeraDiGemini(modello: modo.modello);
          // Il gettone prima della misura: nell'app gcloud non c'e', e la
          // prima risposta di ogni conversazione non deve pagarlo.
          await voce.scaldaIlGettone();
          final controller = MaestroChatController(
            maestro: maestro,
            ai: VoceSorvegliata(voce: voce, registro: RegistroDeiGuasti()),
            memory: InMemoryMaestroMemoryRepository(),
            allowance: QuestionAllowance(freeDailyLimit: 999),
            tier: () => Tier.free,
            natal: () => natal,
            attesaMinima: Duration.zero,
          )..nelLive = modo.nelLive;
          await controller.init();
          final esiti = <Esito>[];
          for (final d in domande) {
            final quante = voce.grezze.length;
            await controller.send(d);
            final ultima = controller.messages.last;
            final testo = ultima.role == ChatRole.maestro ? ultima.text : '';
            // Il tempo del modello: la somma delle chiamate di questo turno,
            // rigenerazioni comprese, perche' la persona le aspetta tutte.
            final ms = voce.grezze
                .skip(quante)
                .fold<int>(0, (a, g) => a + g.durata.inMilliseconds);
            // Il merito non si giudica qui: lo decide la lettura, dopo.
            final e = Esito(d, testo, ms)
              ..riga = await inUnaRiga(voce, d, testo);
            esiti.add(e);
          }
          final tempi = [for (final e in esiti) e.millesimi];
          tempiPerModo.putIfAbsent(modo.nome, () => []).addAll(tempi);
          meritoPerModo.putIfAbsent(modo.nome, () => [0, 0, 0])[2] +=
              esiti.length;
          final riga = 'EQ.03 $fase ${modo.nome} giro $giro ${maestro.id}: '
              'merito da leggere, tempo del modello mediano '
              '${mediana(tempi)} ms';
          print(riga);
          conto.writeln(riga);
          _scrivi(cartella, modo, giro, maestro, esiti, riga);
          expect(esiti.length, domande.length);
        }, timeout: const Timeout(Duration(minutes: 20)));
      }
    }
  }
}

void _scrivi(Directory cartella, Modo modo, int giro, Maestro maestro,
    List<Esito> esiti, String riga) {
  final b = StringBuffer()
    ..writeln('# ${maestro.displayName}, ${modo.nome}, giro $giro, fase $fase')
    ..writeln()
    ..writeln(riga)
    ..writeln();
  for (var i = 0; i < esiti.length; i++) {
    final e = esiti[i];
    b
      ..writeln('## ${i + 1}. ${e.domanda}')
      ..writeln()
      ..writeln('> ${e.risposta.replaceAll('\n', '\n> ')}')
      ..writeln()
      ..writeln('- nel merito: ${switch (e.merito) {
        null => 'da leggere',
        true => 'si',
        false => 'NO',
      }}${e.perche.isEmpty ? '' : ', ${e.perche}'}')
      ..writeln('- in una riga: ${e.riga}')
      ..writeln('- tempo del modello: ${e.millesimi} ms')
      ..writeln();
  }
  final nomeModo = modo.nome.replaceAll(' ', '_').replaceAll('-', '_');
  File('${cartella.path}/${nomeModo}_giro_${giro}_${maestro.id}.md')
      .writeAsStringSync(b.toString());
}
